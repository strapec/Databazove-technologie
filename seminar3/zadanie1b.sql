-- Active: 1790866429854@@127.0.0.1@5432@datacraftinglab_db@public
--1. úloha
WITH daily_sales AS (
    SELECT 
        sale_date, 
        SUM(total_amount) AS total_daily_sales
    FROM fourmills_sales
    GROUP BY sale_date
)
SELECT 
    sale_date, 
    total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

--2. úloha
WITH category_sales AS(
    SELECT
        product_category,
        sum(total_amount) AS total_sales
    FROM fourmills_sales
    GROUP BY product_category
)

SELECT product_category, total_sales
FROM category_sales
ORDER BY total_sales DESC

--3. úloha
WITH total_products_sales AS(
    SELECT
        product_category,
        product_name,
        sum(total_amount) AS total_product_sales
        FROM fourmills_sales
        GROUP BY product_category, product_name
),
ranked_products AS(
    SELECT
        product_category,
        product_name,
        total_products_sales,
        RANK () OVER(
    PARTITION BY product_category
    ORDER BY total_products_sales DESC
    )AS category_rank
FROM total_products_sales
)

SELECT product_category, product_name, total_products_sales, category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category, category_rank

--4. úloha
WITH revenue AS(
    SELECT
        customer_type,
        sum(total_amount) AS revenue
        FROM fourmills_sales
        GROUP BY customer_type
),
revenue_percentage AS(
    SELECT
        customer_type,
        revenue,
        sum(revenue) OVER() AS total_revenue,
        round((revenue / sum(revenue) over()) * 100 , 2) AS revenue_percentage
        FROM revenue
)

SELECT customer_type, revenue, total_revenue, revenue_percentage
FROM revenue_percentage
ORDER BY revenue DESC

--5. úloha
WITH last_trans AS(
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER(
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS row_num
        FROM fourmills_sales
)

SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM last_trans
WHERE row_num = 1
ORDER BY customer_id ASC;

--6. úloha
WITH RECURSIVE date_bounds AS(
    SELECT
        min(sale_date) AS start_date,
        max(sale_date) AS end_date
    FROM fourmills_sales
),
calendar AS (
    SELECT start_date AS sale_date
    FROM date_bounds

    UNION ALL

    SELECT (sale_date + INTERVAL '1 day')::DATE
    FROM calendar
    WHERE sale_date < (SELECT end_date from date_bounds)
)

SELECT sale_date
from calendar
ORDER BY sale_date ASC;

--7. úloha
WITH RECURSIVE monthly_sales AS(
    SELECT
        date_trunc('month', sale_date)::DATE AS month,
        sum(total_amount) AS revenue
        FROM fourmills_sales
        GROUP BY date_trunc('month', sale_date)
),
numbered_sales AS (
    SELECT
        ROW_NUMBER() over (ORDER BY MONTH) AS row_num,
        month,
        revenue
        FROM monthly_sales
),
cumulative_sales AS (
    SELECT
        row_num,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM numbered_sales
    WHERE row_num = 1

    UNION ALL

    SELECT
        n.row_num,
        n.month,
        n.revenue,
        c.cumulative_revenue + n.revenue AS cumulative_revenue
    FROM cumulative_sales c
    JOIN numbered_sales n ON n.row_num = c.row_num + 1
    WHERE c.cumulative_revenue < 500000000
)

SELECT 
    month,
    revenue,
    cumulative_revenue
FROM cumulative_sales
ORDER BY row_num ASC;