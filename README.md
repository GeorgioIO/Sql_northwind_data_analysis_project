# _Sales and Customer Insights with SQL (Northwind Database)_

Dive into my project of analyzing the famous **Northwind** database! Focusing on answering questions to get insights , This project explore 🚚 Top Contributing Suppliers, 📈 High demand products , 🌍 High revenue countries and many more.

🔍 SQL queries ? Check them out here [project_sql](/project_sql)

# Background

## The questions i wanted to answer through my SQL queries were :

1. Which employee generated the highest total sales?
2. Which employees show consistent sales performance over time?
3. What are the top products ranked by total revenue?
4. Which supplier contributes the most to overall sales?
5. Which products are supplied by the top-performing suppliers?
6. Which country generates the highest revenue?
7. What are the most demanded products within the highest-revenue countries?
8. How does the monthly sales trend evolve over time?

# Tools I Used

For my deep dive into the **Northwind** database , i harnessed the power of several key tools :

- **SQL:** The backbone of my analysis, allowing me to query the database.
- **PostgreSQL:** The chosen database management system.
- **Visual Studio Code:** My go-to for writing queries.
- **Git & Github:** Essential for version control and sharing my SQL scripts and analysis.

# 📊 The Analysis

## Entity Relationship Diagram

![ERD Photo](assets/erd_database_photo.png)

Each query for this project is aimed at investigating specific aspect of the database , Here how i approached each question :

## 1️⃣ Which employee generated the highest total sales?

To identify which employee generated the highest total revenue (sales) , i joined employees with two tables orders and order_details , grouped by employee_id , country and employee_name and finally ordered by rounded total sales.

```sql
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
```

| Employee ID | Country | Employee Name    | Total Sales |
| ----------: | :------ | :--------------- | ----------: |
|           4 | USA     | Margaret Peacock |     232,891 |
|           3 | USA     | Janet Leverling  |     202,813 |
|           1 | USA     | Nancy Davolio    |     192,108 |
|           2 | USA     | Andrew Fuller    |     166,538 |
|           8 | USA     | Laura Callahan   |     126,862 |
|           7 | UK      | Robert King      |     124,568 |
|           9 | UK      | Anne Dodsworth   |      77,308 |
|           6 | UK      | Michael Suyama   |      73,913 |
|           5 | UK      | Steven Buchanan  |      68,792 |

Here's the breakown of employees with the highest total sales:

- **USA Employees Domination** : The Employees that are from the USA dominates the top 5 ranks in the list , with their sales starting at **$232,000** to **$126,000**.

- **Wide Sales Range** : Top 10 employees total sales span from $68,000 to $232,000 , indicating significant difference in products revenue.

## 2️⃣ Which employees show consistent sales performance over time?

To identify the employees that showed consistent sales performance across the years in the database , i used **CTE** to get the top three employees each year , using `RANK()` and `PARTITION BY` so i can classify and rank them by year.

In the second query i extracted the employees that are ranked above the fifth rank but also the time they are appearing is equal to the count of the distinct years.

```sql
WITH top_three_emp_yearly AS (
    SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    e.employee_id,
    CONCAT(first_name , ' ' , last_name) AS full_name,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales,
    RANK() OVER (PARTITION BY EXTRACT(YEAR FROM order_date) ORDER BY ROUND(SUM((unit_price * quantity) * (1 - discount))) DESC) AS rank_in_year
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY year , e.employee_id , full_name
    ORDER BY year
)

SELECT
    employee_id,
    full_name
FROM
    top_three_emp_yearly
WHERE rank_in_year <= 5
GROUP BY employee_id , full_name
HAVING COUNT(DISTINCT year) = (SELECT COUNT(DISTINCT year) FROM top_three_emp_yearly);
```

| Employee ID | Full Name        | Country |
| ----------: | :--------------- | :------ |
|           1 | Nancy Davolio    | USA     |
|           2 | Andrew Fuller    | USA     |
|           4 | Margaret Peacock | USA     |

Here's the breakown of which employees are consistent in the database:

- **USA Consistency** : The **USA** again show a strong position in sales also when it comes to consistency for her employees over the time.

- **Nancy Davolio** is the best and most consistent supplier in the database , in second place comes **Andrew Fuller** also from the USA , and lastly **Margaret Peacock**.

## 3️⃣ What are the top products ranked by total revenue?

To identify the top products ranked by total revenue , I joined product table with order_details **to calculate total sales per product** , category **to get the category of the product** , i limited the result to ten rows and ordered by total sales.

```sql
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
```

| Product ID | Product Name            | Category Name  | Total Sales |
| ---------: | :---------------------- | :------------- | ----------: |
|         38 | Côte de Blaye           | Beverages      |     141,397 |
|         29 | Thüringer Rostbratwurst | Meat/Poultry   |      80,369 |
|         59 | Raclette Courdavault    | Dairy Products |      71,156 |
|         62 | Tarte au sucre          | Confections    |      47,235 |
|         60 | Camembert Pierrot       | Dairy Products |      46,825 |
|         56 | Gnocchi di nonna Alice  | Grains/Cereals |      42,593 |
|         51 | Manjimup Dried Apples   | Produce        |      41,820 |
|         17 | Alice Mutton            | Meat/Poultry   |      32,698 |
|         18 | Carnarvon Tigers        | Seafood        |      29,172 |
|         28 | Rössle Sauerkraut       | Produce        |      25,697 |

Here's the breakown of the top ten products ranked by total revenue:

- **Diverse Categories** : Different type of categories is present in the top ten products by total revenue like **Beverages** , **Meat/Poultry** , **Dairy Products**...

- **Wide Sales Range** : The total sales per product span from **$25,000** to **$141,000** , indicating big difference in the revenue per product.

## 4️⃣ Which supplier contributes the most to overall sales?

To identify the suppliers with the most contribution of the total revenue (sales) , i joined suppliers with products and order_details tables to calculate the total revenue for each supplier.

In Another CTE i caculated the total sales for the database , and finally i extracted the supplier id , company name , his total sales rounded , and how much he contributed by dividing his total sales to the database total sales.

```sql
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
```

| Supplier ID | Company Name                      | Country   | Supplier Sales | Sales Contribution (%) |
| ----------: | :-------------------------------- | :-------- | -------------: | ---------------------: |
|          18 | Aux joyeux ecclésiastiques        | France    |        153,691 |                  12.14 |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Germany   |        145,372 |                  11.48 |
|          28 | Gai pâturage                      | France    |        117,981 |                   9.32 |
|           7 | Pavlova, Ltd.                     | Australia |        106,460 |                   8.41 |
|          24 | G'day, Mate                       | Australia |         65,627 |                   5.18 |
|          29 | Forêts d'érables                  | Canada    |         61,588 |                   4.87 |
|           8 | Specialty Biscuits, Ltd.          | UK        |         59,032 |                   4.66 |
|          26 | Pasta Buttini s.r.l.              | Italy     |         50,255 |                   3.97 |
|          14 | Formaggi Fortini s.r.l.           | Italy     |         48,225 |                   3.81 |
|          15 | Norske Meierier                   | Norway    |         43,142 |                   3.41 |

Here's the breakown of the suppliers with the top contribution in the database total sales :

- **European Dominance** : European countries like **France** , **Germany** , **Italy** , **Norway** and **UK** make most of the list of the best suppliers , with suppliers like **Aux joyeux ecclésiastiques** , **Plutzer Lebensmittelgroßmärkte AG** and **Gai pâturage** the top three suppliers being from europe , also we can see **Australian participation** with **Pavlova, Ltd** , **G'day, Mate**.

- **Wide Sales Range** : Again we can identify a wide sale range as the total sales for a supplier span from $43,000 to $150,000 , with **Aux Joyeux Ecclesiastiques** being the top contributor with 12% of the database sales.

# 5️⃣ Which products are supplied by the top-performing suppliers?

To identify the products related to the top-performing suppliers , i used the two last CTEs from the last question . I added on them one CTE to get top ten suppliers only and then to answer to question , I joined the last CTE `top_ten_suppliers` with products table to get the products related to the top ten suppliers and joined with category to get each product category

```sql
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

```

| Supplier ID | Company Name                      | Category Name  | Product Name                    |
| ----------: | :-------------------------------- | :------------- | :------------------------------ |
|          18 | Aux joyeux ecclésiastiques        | Beverages      | Côte de Blaye                   |
|          18 | Aux joyeux ecclésiastiques        | Beverages      | Chartreuse verte                |
|          29 | Forêts d'érables                  | Confections    | Tarte au sucre                  |
|          29 | Forêts d'érables                  | Condiments     | Sirop d'érable                  |
|          14 | Formaggi Fortini s.r.l.           | Dairy Products | Mozzarella di Giovanni          |
|          14 | Formaggi Fortini s.r.l.           | Dairy Products | Mascarpone Fabioli              |
|          14 | Formaggi Fortini s.r.l.           | Dairy Products | Gorgonzola Telino               |
|          24 | G'day, Mate                       | Meat/Poultry   | Perth Pasties                   |
|          24 | G'day, Mate                       | Grains/Cereals | Filo Mix                        |
|          24 | G'day, Mate                       | Produce        | Manjimup Dried Apples           |
|          28 | Gai pâturage                      | Dairy Products | Raclette Courdavault            |
|          28 | Gai pâturage                      | Dairy Products | Camembert Pierrot               |
|          15 | Norske Meierier                   | Dairy Products | Gudbrandsdalsost                |
|          15 | Norske Meierier                   | Dairy Products | Flotemysost                     |
|          15 | Norske Meierier                   | Dairy Products | Geitost                         |
|          26 | Pasta Buttini s.r.l.              | Grains/Cereals | Ravioli Angelo                  |
|          26 | Pasta Buttini s.r.l.              | Grains/Cereals | Gnocchi di nonna Alice          |
|           7 | Pavlova, Ltd.                     | Beverages      | Outback Lager                   |
|           7 | Pavlova, Ltd.                     | Condiments     | Vegie-spread                    |
|           7 | Pavlova, Ltd.                     | Meat/Poultry   | Alice Mutton                    |
|           7 | Pavlova, Ltd.                     | Confections    | Pavlova                         |
|           7 | Pavlova, Ltd.                     | Seafood        | Carnarvon Tigers                |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Condiments     | Original Frankfurter grüne Soße |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Produce        | Rössle Sauerkraut               |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Meat/Poultry   | Thüringer Rostbratwurst         |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Grains/Cereals | Wimmers gute Semmelknödel       |
|          12 | Plutzer Lebensmittelgroßmärkte AG | Beverages      | Rhönbräu Klosterbier            |
|           8 | Specialty Biscuits, Ltd.          | Confections    | Sir Rodney's Scones             |
|           8 | Specialty Biscuits, Ltd.          | Confections    | Sir Rodney's Marmalade          |
|           8 | Specialty Biscuits, Ltd.          | Confections    | Teatime Chocolate Biscuits      |
|           8 | Specialty Biscuits, Ltd.          | Beverages      | Chai                            |
|           8 | Specialty Biscuits, Ltd.          | Confections    | Scottish Longbreads             |

Here's the breakown of the products for the top performing suppliers:

- **Category Variety** : We can clearly notice a huge variety of product categories.

- **Dairy Products / Beveraves** : Category like **Dairy Products** Dominate the list with more than 10 appeareances while **Beverages** with 5 , indicating that dairy products or beverages suppliers tend to perform better than the others.

# 6️⃣ Which country generates the highest revenue?

To identify the countries that generate the highest revenue , i simply joined customers with orders and order_details , grouping by country , i calculated the total revenue (sales) for each one , ordering the results by total_sales and finally limiting the result to ten rows.

```sql
SELECT
    country,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10;

```

| Country   | Total Sales |
| :-------- | ----------: |
| USA       |     245,585 |
| Germany   |     230,285 |
| Austria   |     128,004 |
| Brazil    |     106,926 |
| France    |      81,358 |
| UK        |      58,971 |
| Venezuela |      56,811 |
| Sweden    |      54,495 |
| Canada    |      50,196 |
| Ireland   |      49,980 |

Here's the breakown of the countries that generates the highest revenue:

- **American Appearance** : When it comes to total revenue generated per countries by customers we can clearly see that american countries appear beside european countries , different to when it comes to revenue (sales) from suppliers where europe nearly dominate the list.

- Countries like **USA** topping the lists with **$245,000** total sales while **Germany** come in the second place with **$230,000**

# 7️⃣ What are the most demanded products within the highest-revenue countries (as in quantity)?

- To identify the most demanded products withing the highest-revenue countries , i first used the last question query as an CTE **to get the top ten best performing countries**

- In the query i joined the CTE to five tables , i filtered only the product that **are ordered more than 150 times (by quantity)** , finally ordered the result by total quantity.

```sql
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
```

| Country | Product Name                    | Category       | Total Quantity |
| ------- | ------------------------------- | -------------- | -------------- |
| Germany | Camembert Pierrot               | Dairy Products | 405            |
| USA     | Gnocchi di nonna Alice          | Grains/Cereals | 386            |
| USA     | Alice Mutton                    | Meat/Poultry   | 361            |
| USA     | Tarte au sucre                  | Confections    | 356            |
| Germany | Boston Crab Meat                | Seafood        | 345            |
| Germany | Raclette Courdavault            | Dairy Products | 337            |
| USA     | Rhönbräu Klosterbier            | Beverages      | 297            |
| USA     | Pavlova                         | Confections    | 295            |
| USA     | Chang                           | Beverages      | 294            |
| Germany | Lakkalikööri                    | Beverages      | 287            |
| Austria | Guaraná Fantástica              | Beverages      | 283            |
| Germany | Sir Rodney's Scones             | Confections    | 280            |
| USA     | Raclette Courdavault            | Dairy Products | 276            |
| USA     | Konbu                           | Seafood        | 262            |
| Germany | Gorgonzola Telino               | Dairy Products | 250            |
| USA     | Scottish Longbreads             | Confections    | 247            |
| Germany | Teatime Chocolate Biscuits      | Confections    | 246            |
| USA     | Gorgonzola Telino               | Dairy Products | 241            |
| USA     | Tourtière                       | Meat/Poultry   | 240            |
| Germany | Chang                           | Beverages      | 235            |
| Germany | Tunnbröd                        | Grains/Cereals | 227            |
| Austria | Wimmers gute Semmelknödel       | Grains/Cereals | 224            |
| Germany | Pâté chinois                    | Meat/Poultry   | 223            |
| USA     | Geitost                         | Dairy Products | 221            |
| Germany | Tarte au sucre                  | Confections    | 215            |
| USA     | Flotemysost                     | Dairy Products | 215            |
| Brazil  | Camembert Pierrot               | Dairy Products | 212            |
| USA     | Jack's New England Clam Chowder | Seafood        | 211            |
| Germany | Wimmers gute Semmelknödel       | Grains/Cereals | 208            |
| Austria | Sirop d'érable                  | Condiments     | 206            |
| Germany | Gumbär Gummibärchen             | Confections    | 202            |
| Germany | Original Frankfurter grüne Soße | Condiments     | 198            |
| Austria | Alice Mutton                    | Meat/Poultry   | 191            |
| USA     | Pâté chinois                    | Meat/Poultry   | 191            |
| Germany | Singaporean Hokkien Fried Mee   | Grains/Cereals | 191            |
| Germany | Flotemysost                     | Dairy Products | 190            |
| Germany | Uncle Bob's Organic Dried Pears | Produce        | 190            |
| Austria | Gudbrandsdalsost                | Dairy Products | 190            |
| USA     | Rogede sild                     | Seafood        | 186            |
| USA     | Perth Pasties                   | Meat/Poultry   | 186            |
| UK      | Gorgonzola Telino               | Dairy Products | 185            |
| USA     | Inlagd Sill                     | Seafood        | 185            |
| Germany | Konbu                           | Seafood        | 184            |
| Germany | Mozzarella di Giovanni          | Dairy Products | 183            |
| Germany | Pavlova                         | Confections    | 180            |
| USA     | Chai                            | Beverages      | 180            |
| Austria | Raclette Courdavault            | Dairy Products | 180            |
| Austria | Gorgonzola Telino               | Dairy Products | 178            |
| Austria | Chartreuse verte                | Beverages      | 175            |
| France  | Tarte au sucre                  | Confections    | 174            |
| Germany | Chartreuse verte                | Beverages      | 174            |
| USA     | Steeleye Stout                  | Beverages      | 174            |
| USA     | Camembert Pierrot               | Dairy Products | 173            |
| Germany | Steeleye Stout                  | Beverages      | 173            |
| USA     | Thüringer Rostbratwurst         | Meat/Poultry   | 173            |
| Brazil  | Teatime Chocolate Biscuits      | Confections    | 171            |
| USA     | Lakkalikööri                    | Beverages      | 170            |
| USA     | Côte de Blaye                   | Beverages      | 170            |
| Germany | Chai                            | Beverages      | 170            |
| UK      | Camembert Pierrot               | Dairy Products | 166            |
| Austria | Pavlova                         | Confections    | 164            |
| Germany | Inlagd Sill                     | Seafood        | 162            |
| Austria | Camembert Pierrot               | Dairy Products | 160            |
| Germany | Rhönbräu Klosterbier            | Beverages      | 156            |
| Germany | Manjimup Dried Apples           | Produce        | 155            |
| France  | Carnarvon Tigers                | Seafood        | 154            |
| USA     | Gula Malacca                    | Condiments     | 152            |

Here a breakdown of the most demanded products for the top-performing countries :

- **Germany Dominance** : Germany clearly leads in total product quantities, escpially **Dairy Products** like **Camember Pierrot (405 units)** and **Raclette Courdavault (337 units)** Other top categories include **Beverages** and **Confections** showing diverse consumer demand.

- **USA Strengh in Meat and Sweets** : The USa shows strong demand in **Meat/Poultry** and **Confections** , with products like **Alice Mutton (361 units)** and **Tarte au sucre (356 units)** , **Beverages** like **Rhonbrau Klosterbier** performs well.

# 8️⃣ How does the monthly sales trend evolves over time?

- To identify how the sales trend evolves over time by each month of the year , simply from the orders table i joined it with order_details table to calculate the total sales , i extracted the order year and month and grouped by each month and year

```sql
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    ROUND(SUM((unit_price * quantity) * (1 - discount))) AS total_sale
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_year , order_month
ORDER BY order_year , order_month ;
```

| Order Year | Order Month | Total Sale |
| ---------- | ----------: | ---------: |
| 1996       |           7 |     27,862 |
| 1996       |           8 |     25,485 |
| 1996       |           9 |     26,381 |
| 1996       |          10 |     37,516 |
| 1996       |          11 |     45,600 |
| 1996       |          12 |     45,240 |
| 1997       |           1 |     61,258 |
| 1997       |           2 |     38,484 |
| 1997       |           3 |     38,547 |
| 1997       |           4 |     53,033 |
| 1997       |           5 |     53,781 |
| 1997       |           6 |     36,363 |
| 1997       |           7 |     51,021 |
| 1997       |           8 |     47,288 |
| 1997       |           9 |     55,629 |
| 1997       |          10 |     66,749 |
| 1997       |          11 |     43,534 |
| 1997       |          12 |     71,398 |
| 1998       |           1 |     94,222 |
| 1998       |           2 |     99,415 |
| 1998       |           3 |    104,854 |
| 1998       |           4 |    123,799 |
| 1998       |           5 |     18,334 |

Here a breakdown of the sales over each month over the years :

- **1997 is the only consistent year** with the sales spanning over all the months of the year from **January** (1) to **December** (12)

- **Higher Sales in 1998** as we can see the beginning of sales in **1998** is better than both **1997** and **1996** with numbers in **1998** approximately above $90k , while in both **1997** and **1996** less than $50k , indicating significant improvement in **1998**

- **Peaks at the end of the year** for both **1996** and **1997** we can clearly identify peaks in sales at the end of the year for the months **10** , **11** , **12**.

# What I Learned

Throughout this project , i've turbocharged my SQL knowledge with some serious challenges :

- **Window Functions:** Used window functions for the first time in this project, applying them with CTEs. This opened my eyes to a new way of solving problems and I’m excited to explore them deeper.

- **Complex Query Crafting:** Learned how to break down tough business questions into smaller parts, then build queries step by step until I got the right output.

- **Analytical Thinking:** This project wasn’t just about writing SQL — it was about asking the right questions, interpreting results, and thinking like an analyst instead of just a coder.

- **Data Storytelling:** Realized that numbers alone don’t mean much. The real skill is turning query results into insights that actually explain what’s happening in the business.

# So What ?

### Below the insights i gathered from all the analysis :

1. **Top-performing customers :** The top-performing customers of the database between the **UK** and **USA** , is clearly **USA** . the highes total sales of an employee is **$232,000!**.

2. **Profitable Products :** Products like **Cote de Blaye** is the most profitable product with approximately **$140,000** in sales , products like **Meat/Poultry** is also profitable.

3. **Best Suppliers :** When it comes to suppliers **European** ones dominate the list with 7 out of the top 10 being **European** , The France suppliers **Aux Joyeux ecclesiastiques** is the highest in sales contribution.

4. **Top Performing Categories :** Suppliers that sells beverages typically tops the list of the best suppliers like **Aux Joyeux Ecclesiastiques** , **Plutzer LebensmittelgroBmark** , as well as **Dairy Products** that made **Gai paturage** ranked third by only selling them.

5. **Highest Revenue Countries :** When it comes to revenue from customers **USA** again top the list with approximately **$245,000** sales , while **Germany** comes in second with **$230,000**.

# Closing Thoughts

Finally this project safe to say enhanced my SQL skils and provided valuable insights of the **Northwind** database.
