SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sale
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_month , order_year
ORDER BY order_month , order_year ;