/*
Question : Which employees show consistent sales performance over time?
- Identify what employee are top three in sales in each available year of the store 
- Include the top 5 only in each year
- Why ? Highlight the top performing customers over three years, 
    offering an idea of what employees continously perform on a high level.
*/

WITH top_three_emp_yearly AS (
    SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    e.employee_id,
    CONCAT(first_name , ' ' , last_name) AS full_name,
    e.country,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales,
    RANK() OVER (PARTITION BY EXTRACT(YEAR FROM order_date) ORDER BY ROUND(SUM((unit_price * quantity) * (1 - discount))) DESC) AS rank_in_year
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY year , e.employee_id , e.country , full_name
    ORDER BY year 
)


SELECT 
    employee_id,  
    full_name,
    country
FROM 
    top_three_emp_yearly
WHERE rank_in_year <= 5
GROUP BY employee_id , full_name , country
HAVING COUNT(DISTINCT year) = (SELECT COUNT(DISTINCT year) FROM top_three_emp_yearly);