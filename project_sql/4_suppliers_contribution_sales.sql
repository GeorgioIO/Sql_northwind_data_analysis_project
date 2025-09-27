/*
Question: Which supplier contributes the most to overall sales?
- Objective: Calculate each supplier’s total sales and their percentage share of the store’s total revenue.
- Method: 
    1. Compute total revenue per supplier (based on unit price, quantity, and discount).
    2. Compute total store revenue.
    3. Divide supplier revenue by total revenue to get percentage contribution.
- Why: Identifying the top-contributing suppliers highlights the most valuable 
       partnerships and helps guide strategic sourcing decisions.
*/

WITH suppliers_sales AS (
    SELECT 
        s.supplier_id,
        s.company_name,
        s.country,
        SUM((od.unit_price * od.quantity) * (1 - od.discount))::NUMERIC AS total_supplier_sales
    FROM suppliers s
    JOIN products p ON s.supplier_id = p.supplier_id
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY s.supplier_id , s.company_name , s.country
) , total_store_sales AS (
    SELECT 
        SUM((unit_price * quantity) * (1 - discount))::NUMERIC AS total_sales
    FROM order_details
)


SELECT 
    ss.supplier_id,
    ss.company_name,
    ss.country,
    ROUND(ss.total_supplier_sales) AS supplier_sales,
    ROUND((ss.total_supplier_sales / tss.total_sales) * 100 , 2) AS sales_contribution
FROM suppliers_sales ss , total_store_sales tss
ORDER BY sales_contribution DESC
LIMIT 10;

