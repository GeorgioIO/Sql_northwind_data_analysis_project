/*
Question: Which products are supplied by the top-performing suppliers?
- Objective: Query the products that are only related to the top 10 suppliers in sales contribution.
- Method: 
    1. Compute total revenue per supplier (based on unit price, quantity, and discount).
    2. Compute total store revenue.
    3. Compute the top ten suppliers.
    4. Query the product related to those suppliers.
- Why: Identifying the products related to the top contributing provides insight 
       into their portfolio and highlights key supplier-product.
*/


WITH suppliers_sales AS (
    SELECT 
        s.supplier_id,
        s.company_name,
        SUM((od.unit_price * od.quantity) * (1 - od.discount))::NUMERIC AS total_supplier_sales
    FROM suppliers s
    JOIN products p ON s.supplier_id = p.supplier_id
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY s.supplier_id , s.company_name
), 
total_store_sales AS 
(
    SELECT 
        SUM((unit_price * quantity) * (1 - discount))::NUMERIC AS total_sales
    FROM order_details
), 
top_ten_suppliers AS 
( 
SELECT
    ss.supplier_id,
    ss.company_name,
    ROUND(ss.total_supplier_sales) AS supplier_sales,
    ROUND((ss.total_supplier_sales / tss.total_sales) * 100 , 2) AS sales_contribution
    FROM suppliers_sales ss , total_store_sales tss
    ORDER BY sales_contribution DESC
    LIMIT 10
)

SELECT  
    tts.supplier_id,
    tts.company_name,
    c.category_name,
    p.product_name
FROM top_ten_suppliers tts
JOIN products p ON tts.supplier_id = p.supplier_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY tts.company_name;