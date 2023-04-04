# Danny's Diner
Case Study from Data with Danny, more information about the project can be found on https://8weeksqlchallenge.com/case-study-1/

![image](https://user-images.githubusercontent.com/85653222/229926334-1659193c-bdf3-428e-aea8-2e533c0c7985.png)

<b>Introduction</b><br>
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

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

What is the most purchased item on the menu and how many times was it purchased by all customers?
Which item was the most popular for each customer?
Which item was purchased first by the customer after they became a member?
Which item was purchased just before the customer became a member?
What is the total items and amount spent for each member before they became a member?
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
