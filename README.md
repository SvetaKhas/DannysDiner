# Danny's Diner
Case Study from Data with Danny, more information about the project can be found on https://8weeksqlchallenge.com/case-study-1/

![image](https://user-images.githubusercontent.com/85653222/229926334-1659193c-bdf3-428e-aea8-2e533c0c7985.png)

<b>Introduction</b><br>
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

Entity Relationship Diagram: <br>
![image](https://user-images.githubusercontent.com/85653222/230747617-2bf4beb7-52c4-442e-b18a-5302fdd989b0.png)


<b>Case Study Questions</b> <br>
Each of the following case study questions can be answered using a single SQL statement:

<b>1. What is the total amount each customer spent at the restaurant?</b><br>


    SELECT s.customer_id, SUM(m.price) AS total_spent
    FROM dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
    ON s.product_id=m.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |


<b>2. How many days has each customer visited the restaurant?</b><br>


    SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
    FROM dannys_diner.sales s
    GROUP BY customer_id;

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |

<b>3. What was the first item from the menu purchased by each customer?</b><br>


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
    GROUP BY customer_id, product_name;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |


<b>4. What is the most purchased item on the menu and how many times was it purchased by all customers?</b><br>


    SELECT m.product_name AS most_purchased_item, COUNT(s.product_id) AS times_purchased
    FROM dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
    ON s.product_id=m.product_id
    GROUP BY most_purchased_item
    ORDER BY times_purchased DESC
    LIMIT 1;

| most_purchased_item | times_purchased |
| ------------------- | --------------- |
| ramen               | 8               |


<b>5. Which item was the most popular for each customer? </b><br>


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
    WHERE dense_rank=1;

| customer_id | product_name | times_purchased |
| ----------- | ------------ | --------------- |
| A           | ramen        | 3               |
| B           | ramen        | 2               |
| B           | curry        | 2               |
| B           | sushi        | 2               |
| C           | ramen        | 3               |

 
 <b>6. Which item was purchased first by the customer after they became a member?</b><br>

    
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
    WHERE ranked_order=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

 
 <b>7. Which item was purchased just before the customer became a member? </b><br>


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
    WHERE ranked_order=1;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |


<b>8. What is the total items and amount spent for each member before they became a member?</b><br>


    SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(menu.price) AS total_amtspent
    FROM dannys_diner.sales s
    INNER JOIN dannys_diner.members m
    ON s.customer_id=m.customer_id
    INNER JOIN dannys_diner.menu menu
    ON s.product_id=menu.product_id
    WHERE s.order_date<m.join_date
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | total_items | total_amtspent |
| ----------- | ----------- | -------------- |
| A           | 2           | 25             |
| B           | 3           | 40             |


<b>9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?</b><br>
If customers joined membership right away, this is the amount of points they would have earned<br>

    SELECT s.customer_id, 
      SUM(CASE WHEN product_name='sushi' THEN menu.price*2*10
           ELSE menu.price*10 
           END) AS points
    FROM dannys_diner.sales s
    INNER JOIN dannys_diner.menu menu
    ON s.product_id=menu.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 860    |
| B           | 940    |
| C           | 360    |
 
Actual points customers earned after becoming a  member<br>


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

| customer_id | points |
| ----------- | ------ |
| A           | 510    |
| B           | 440    |


<b>10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? </b> <br>



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

| customer_id | end_of_jan_points |
| ----------- | ----------------- |
| A           | 1020              |
| B           | 440               |



