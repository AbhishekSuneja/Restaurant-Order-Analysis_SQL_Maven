----Maven analytics coffee shop ----

select * from order_details

select * from menu_items

-----***********  BASIC LEVEL  **********--------

/*Q-1    View the menu_items table and write a query to find the 
         number of items on the menu*/

		 select count(item_name)as tot_items from menu_items


/*Q-2    What are the least and most expensive items on the menu?*/

         --For Most expensive item
		 select top 1 item_name, max(price) as M_exp from menu_items
		 group by item_name
		 order by 2 desc
		
         -- For Least expensive item
		 select top 1 item_name, min(price) as L_exp from menu_items
		 group by item_name
		 order by 2 asc


/*Q-3    How many Italian dishes are on the menu? What are the least and most expensive 
         Italian dishes on the menu?*/

		-- Italian dishes count--
		 select count(category) as CNT 
		 from menu_items
		 where category in ('italian')

		 -- Most expensive Italian dish--
		 select top 1 with ties item_name, price from menu_items
		 where category in ('italian')
		 order by price desc

		 --Least expensive Italian dish--
		 select top 1 with ties item_name, price from menu_items
		 where category in ('italian')
		 order by price asc


/*Q-4   How many dishes are in each category? 
        What is the average dish price within each category?*/
		

		select category, count(item_name)as Dish_CNt, 
		avg(price) as Avg_price 
		from menu_items
		group by category


-----***********  INTERMEDIATE LEVEL (ORDERS TABLE) **********--------

        SELECT * FROM ORDER_DETAILS

/*Q-1   View the order_details table. What is the date range of the table?*/

        SELECT MIN(ORDER_DATE)AS MIN_DATE, MAX(ORDER_DATE)AS MAX_DATE
		 FROM order_details


		--IN TERMS OF DAYS--

		SELECT DATEDIFF(DAY, MIN(ORDER_DATE),MAX(ORDER_DATE))AS DATA_OF_DAYS 
		FROM order_details

/*Q-2   How many orders were made within this date range? 
        How many items were ordered within this date range?*/

		--NO OF ORDERS
        SELECT COUNT(DISTINCT ORDER_ID) AS ORDER_CNT FROM order_details

		--NO OF ITEMS
		SELECT COUNT(ITEM_ID) AS ITEM_CNT FROM order_details


/*Q-3   Which orders had the most number of items?*/

       -- SIMPLEST APPROACH--
		SELECT * FROM
		(
		SELECT TOP 1 WITH TIES ORDER_ID, COUNT(ITEM_ID) AS ITEM_CNT
		FROM order_details
		GROUP BY ORDER_ID
		ORDER BY 2 DESC )A

	   --ADVANCED APPROACH--
		WITH A AS
		(  
		 SELECT ORDER_ID, COUNT(ITEM_ID) AS ITEM_CNT 
		  FROM order_details
		  GROUP BY ORDER_ID 
		  )
          SELECT ORDER_ID, ITEM_CNT FROM A
		  WHERE ITEM_CNT = (SELECT MAX(ITEM_CT) 
		                     FROM (SELECT COUNT(ITEM_ID) AS ITEM_CT 
							       FROM order_details 
								   GROUP BY ORDER_ID)AS B
								   )


/*Q-4   How many orders had more than 12 items?*/

        
		SELECT COUNT(ORDER_ID)AS ORD_CNT FROM (
		SELECT ORDER_ID, COUNT(ITEM_ID) AS ID_CNT 
		FROM order_details
		GROUP BY ORDER_ID
		HAVING COUNT(ITEM_ID)>12
		)A
		


----*******INTERMEDIATE 2******------
select * from order_details

select * from menu_items

/*Q-1   Combine the menu_items and order_details tables into a single table*/

        SELECT * FROM menu_items A JOIN order_details B
		 ON A.MENU_ITEM_ID = B.ITEM_ID


/*Q-2   What were the least and most ordered items? What categories were they in?*/

       --MOST ORDERED ITEM--
	   WITH A AS
	    (
	     SELECT CATEGORY ,ITEM_NAME, COUNT(ITEM_NAME) AS ITEM_CNT
		  FROM order_details A LEFT JOIN menu_items B 
		   ON A.item_id = b.menu_item_id
		    GROUP BY CATEGORY, ITEM_NAME
			 
			 )
      	SELECT CATEGORY, ITEM_NAME, ITEM_CNT FROM A 
		WHERE ITEM_CNT = (SELECT MAX(CNT_ITM) FROM 
		                   (SELECT CATEGORY, ITEM_NAME, COUNT(ITEM_NAME) AS CNT_ITM 
						     FROM order_details A LEFT JOIN menu_items B 
		                      ON A.item_id = b.menu_item_id
							   GROUP  BY CATEGORY, ITEM_NAME )Q)
		    
	   ----FOR LEAST ITEM
	   
	      WITH A AS
	    (
	     SELECT CATEGORY ,ITEM_NAME, COUNT(ITEM_NAME) AS ITEM_CNT
		  FROM order_details A INNER JOIN menu_items B 
		   ON A.item_id = b.menu_item_id
		    GROUP BY CATEGORY, ITEM_NAME
			 
			 )
      	SELECT CATEGORY, ITEM_NAME, ITEM_CNT FROM A 
		WHERE ITEM_CNT = (SELECT MIN(CNT_ITM) FROM 
		                   (SELECT CATEGORY, ITEM_NAME, COUNT(ITEM_NAME) AS CNT_ITM 
						     FROM order_details A INNER JOIN menu_items B 
		                      ON A.item_id = b.menu_item_id
							   GROUP  BY CATEGORY, ITEM_NAME)Q)				  
						  

/*Q-3   What were the top 5 orders that spent the most money?*/

        SELECT TOP 5 WITH TIES ORDER_ID, SUM(PRICE) AS TOT_VAL 
	    FROM order_details A INNER JOIN menu_items B 
	    ON A.item_id = b.menu_item_id
	    GROUP BY ORDER_ID
	    ORDER BY 2 DESC

/*Q-4   View the details of the highest spend order. Which specific items were purchased?*/
      
	    SELECT * 
	    FROM order_details A INNER JOIN menu_items B 
	    ON A.item_id = b.menu_item_id
	    WHERE ORDER_ID = (select top 1 order_id from order_details A INNER JOIN menu_items B 
	                      ON A.item_id = b.menu_item_id 
						  group by order_id
						  order by sum(b.price) desc
						  )
						  
	    

/*Q-5   View the details of the top 5 highest spend orders*/
  
        SELECT * 
	    FROM order_details A INNER JOIN menu_items B 
	    ON A.item_id = b.menu_item_id
	    WHERE ORDER_ID IN (440,2075,1957,330,2675)

		---or---

		select * from
		order_details A inner join menu_items b 
		on a.item_id=b.menu_item_id
		where order_id in(select top 5 order_id from
		                  order_details A inner join menu_items b 
		                  on a.item_id=b.menu_item_id
						  group by order_id
						  order by sum(price) desc)
         
		  ----OR----
		With CTE as (select top 5 order_id from
		                  order_details A inner join menu_items b 
		                  on a.item_id=b.menu_item_id
						  group by order_id
						  order by sum(price) desc)
						  
	   select * from order_details A inner join menu_items b 
		on a.item_id=b.menu_item_id inner join CTE on cte.order_id = a.order_id			  
        



		

        