/*
Question: Which country generates the highest revenue?
- Objective: Calculate each country total sales.
- Include the top 10 countris
- Why: Identifying the top countries when it come to sales allows us to specify what countries perform the best and asks questions why they perform better than the others.
*/

SELECT 
    country, 
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10;