/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
/*
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id
*/

-- 2. How many days has each customer visited the restaurant?
/*
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM dannys_diner.sales s
GROUP BY customer_id
*/

-- 3. What was the first item from the menu purchased by each customer?
/*
WITH ranked AS(
SELECT s.customer_id, s.product_id, m.product_name, s.order_date,
	   DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) 
FROM dannys_diner.sales s
LEFT JOIN dannys_diner.menu m
ON s.product_id=m.product_id
ORDER BY s.order_date, s.customer_id)
SELECT customer_id, product_name
FROM ranked
WHERE dense_rank=1
GROUP BY customer_id, product_name
*/

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
/*
SELECT m.product_name AS most_purchased_item, COUNT(s.product_id) AS times_purchased
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY most_purchased_item
ORDER BY times_purchased DESC
LIMIT 1
*/

-- 5. Which item was the most popular for each customer?
/*
WITH ranked AS(
SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS times_purchased,
	   DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC)
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id=m.product_id
GROUP BY s.customer_id,m.product_name
ORDER BY s.customer_id)
SELECT customer_id, product_name, times_purchased
FROM ranked
WHERE dense_rank=1
*/

-- 6. Which item was purchased first by the customer after they became a member?
WITH ranked_orders AS(
SELECT s.customer_id, s.order_date,
	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranked_order,
	s.product_id,menu.product_name, m.join_date
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m
ON s.customer_id=m.customer_id
INNER JOIN dannys_diner.menu menu
ON s.product_id=menu.product_id
WHERE s.order_date>=m.join_date
ORDER BY s.customer_id
)
SELECT customer_id, product_name
FROM ranked_orders
WHERE ranked_order=1


-- 7. Which item was purchased just before the customer became a member?
WITH ranked_orders AS(
SELECT s.customer_id, s.order_date,
	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS ranked_order,
	s.product_id,menu.product_name, m.join_date
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m
ON s.customer_id=m.customer_id
INNER JOIN dannys_diner.menu menu
ON s.product_id=menu.product_id
WHERE s.order_date<m.join_date
ORDER BY s.customer_id
)
SELECT customer_id, product_name
FROM ranked_orders
WHERE ranked_order=1

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(menu.price) AS total_amtspent
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members m
ON s.customer_id=m.customer_id
INNER JOIN dannys_diner.menu menu
ON s.product_id=menu.product_id
WHERE s.order_date<m.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id

/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each 
	customer have?
If customers joined membership right away, this is the amount of points they would have earned */

SELECT s.customer_id, 
  SUM(CASE WHEN product_name='sushi' THEN menu.price*2*10
       ELSE menu.price*10 
       END) AS points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu menu
ON s.product_id=menu.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id

-- Actual points customers earned becoming a  member

SELECT s.customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS points
FROM dannys_diner.menu AS menu
INNER JOIN dannys_diner.sales AS s ON menu.product_id = s.product_id
INNER JOIN dannys_diner.members AS m ON m.customer_id = s.customer_id
WHERE order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

/*10. In the first week after a customer joins the program (including their join date) they earn 2x points on all 
	items, not just sushi - how many points do customer A and B have at the end of January?
We have to consider 2 scenarios for customers joining the program
  1) customer earns double points first week after joining 
  2) customer places order after 7 days of joining, earns 2x points on sushi, 1x points on other items
  
We also limit month to january and orders to only those placed after becoming a member 
*/
SELECT s.customer_id, SUM(
    CASE WHEN s.order_date BETWEEN m.join_date and m.join_date+ INTERVAL '7 days' THEN menu.price*20
         WHEN menu.product_name = 'sushi' AND s.order_date NOT BETWEEN m.join_date 
  		 and m.join_date+ INTERVAL '7 days'THEN menu.price*20
         WHEN menu.product_name != 'sushi' AND s.order_date NOT BETWEEN m.join_date 
  		 and m.join_date+ INTERVAL '7 days'THEN menu.price*10
         END) AS end_of_jan_points
FROM dannys_diner.menu AS menu
INNER JOIN dannys_diner.sales AS s ON menu.product_id = s.product_id
INNER JOIN dannys_diner.members AS m ON m.customer_id = s.customer_id
WHERE DATE_PART('MONTH', s.order_date)=1 
      AND s.order_date >= m.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;




