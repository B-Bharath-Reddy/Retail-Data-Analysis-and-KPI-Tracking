USE retail_orders;


SHOW TABLES;


SELECT * FROM retail_orders;


-- top 10 products generating the highest revenue.

SELECT product_id,
SUM(sale_price) as sales
FROM retail_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- top 5 highest selling products in each region

 WITH cte AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales
    FROM 
        retail_orders
    GROUP BY 
        region, product_id
)
SELECT 
    *
FROM (
    SELECT 
        region,
        product_id,
        sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM 
        cte
) A
WHERE 
    rn <= 5;
    

-- Find the Month-over-Month (MoM) growth comparing sales of each month in 2022 against the same month in 2023.
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM retail_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;

 
-- for each category which month had highest sales 


WITH cte AS (
    SELECT 
        category,
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        SUM(sale_price) AS sales 
    FROM retail_orders
    GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
)
SELECT category, order_year_month,sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) a
WHERE rn = 1;



-- Which sub-category had the highest profit growth in 2023 compared to 2022?


WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM retail_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT sub_category, profit_2022, profit_2023, 
       (profit_2023 - profit_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC
LIMIT 1;


-- Which sub-category had the highest percentage profit growth in 2023 compared to 2022?
-- Compute the total profit for each sub-category in 2022 and 2023.
-- Then, calculate the percentage growth in profit: ((profit_2023 - profit_2022) / profit_2022) * 100.
-- Identify the sub-category with the highest percentage growth.


WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM retail_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT sub_category, 
       profit_2022, 
       profit_2023, 
       (profit_2023 - profit_2022) AS profit_growth,
       (profit_2023 - profit_2022) * 100 / profit_2022
 AS profit_growth_percentage
FROM cte2
ORDER BY profit_growth_percentage DESC
;





WITH ranked AS (
    SELECT id, name, 
           ROW_NUMBER() OVER (PARTITION BY name ORDER BY id) AS row_num
    FROM employees
)
DELETE FROM employees 
WHERE id IN (
    SELECT id FROM ranked WHERE row_num > 1
);



SELECT salary 
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk 
    FROM employees
) ranked 
WHERE rnk = 2;



   


