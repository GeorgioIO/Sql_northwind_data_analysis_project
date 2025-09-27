/*
Question: How does the monthly sales trend evolve over time?
Method : - Extract Year , Month From each Order
         - Calculate total sales per year per month (GROUP BY)
Why ? This helps identify how the sales evolve over the year by each month, 
      and for each year what is the peak month.
*/

SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sale
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_year , order_month
ORDER BY order_year , order_month ;