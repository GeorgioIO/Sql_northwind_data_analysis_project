WITH highest_revenue_countries AS (SELECT
    country,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10)

SELECT
    hrc.country,
    p.product_name,
    ca.category_name,
    SUM(od.quantity) AS total_quantity
FROM highest_revenue_countries hrc
LEFT JOIN customers c ON hrc.country = c.country
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories ca ON p.category_id = ca.category_id
GROUP BY hrc.country , p.product_name , ca.category_name
HAVING SUM(od.quantity) > 150
ORDER BY total_quantity DESC;