/*
Question : What are the top products by revenue ?
- Identify what product generates the most revenue or sales.
- Include the top 10 only ?
- Why ? identifying what products generates the most sales helps us focusing on them and analysing more in depth why they are the best.
*/

SELECT
    p.product_id,
    p.product_name,
    category_name,
    ROUND(SUM((od.unit_price * quantity) * (1 - discount))) AS total_sales
FROM products p 
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id , p.product_name , category_name
ORDER BY total_sales DESC
LIMIT 10;