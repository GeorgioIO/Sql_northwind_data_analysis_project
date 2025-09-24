/*
Question : What are is the most demanded category in the most profitable products?
- Identfy the top profitable products and the count how many times each category appear 
- Why ? Identifying the most demanded category in the most profitable products allows us to ddirectly 
know what is the best category in the database
*/
WITH profitable_products AS (
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
LIMIT 10
)

SELECT category_name , COUNT(category_name) AS count_category
FROM profitable_products
GROUP BY category_name
ORDER BY count_category DESC;