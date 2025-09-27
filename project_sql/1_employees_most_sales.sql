/*
Question : Which employee generated the highest total sales? ?
- Identify what employee generated the highest total sales
- Include the top 10 only and each employee country
- Why ? Highlight the top performing customers, 
  offering an idea of what employees perform on a high level
*/

SELECT
    o.employee_id,
    e.country,
    CONCAT(first_name , ' ' , last_name) AS employee_name,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.employee_id , e.country , employee_name
ORDER BY total_sales DESC
LIMIT 10; 

