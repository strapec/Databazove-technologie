-- Active: 1790866429854@@127.0.0.1@5432@retail@public
-- Active: 1790866429854@@127.0.0.1@5432@postgres@public

--1. úloha
CREATE DATABASE retail;

CREATE Table retail_sales(
    invoice_no varchar(20),
    stock_code varchar(50),
    description TEXT,
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price DECIMAL(10,2),
    customer_id INT,
    country varchar(100)
);

SELECT * FROM retail_sales;

--2. úloha
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    (quantity * unit_price) AS revenue,
    sum(quantity * unit_price) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    )AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id ASC, invoice_date ASC;

--3. úloha
SELECT
    stock_code,
    country,
    invoice_date,
    quantity,
    round(
        avg(quantity) OVER(
            PARTITION BY stock_code, country
            ORDER BY invoice_date
            RANGE BETWEEN INTERVAL '7days' PRECEDING AND CURRENT ROW
        ), 2
    ) AS avg_quantity_7_days
    FROM retail_sales
    WHERE quantity > 1
    ORDER BY stock_code ASC, country ASC, invoice_date ASC;

--4. úloha

WITH unique_invoices AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
invoice_leads AS (
    SELECT
    customer_id,
    invoice_no,
    invoice_date,
    lead(invoice_date) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date ASC
    ) AS next_invoice_date
    FROM unique_invoices
),
invoice_diffs AS(
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        next_invoice_date,
        (next_invoice_date - invoice_date) AS days_to_next_invoice
        FROM invoice_leads
        WHERE next_invoice_date IS NOT NULL
)

SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    days_to_next_invoice
FROM invoice_diffs
ORDER BY days_to_next_invoice DESC;

--5. úloha
SELECT
    stock_code,
    invoice_no,
    invoice_date,
    LAG(unit_price) OVER(
        PARTITION BY stock_code
        ORDER BY invoice_date
    ) AS previous_price,
    unit_price AS current_price,
    (current_price - previous_price) AS price_difference
    FROM retail_sales
    WHERE previous_price IS NOT NULL AND current_price != previous_price;

WITH price_comparison AS(
    SELECT
    stock_code,
    invoice_no,
    invoice_date,
    LAG(unit_price) OVER(
        PARTITION BY stock_code
        ORDER BY invoice_date
    ) AS previous_price,
    unit_price AS current_price
    FROM retail_sales
)
SELECT
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    (current_price - previous_price) AS price_difference
    FROM price_comparison
    WHERE previous_price IS NOT NULL AND current_price <> previous_price
    ORDER BY invoice_date ASC;

--6. úloha
WITH customers_sales AS(
    SELECT
    customer_id,
    sum(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_amount,
    NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
    FROM customers_sales
    ORDER BY total_amount DESC;

--7. úloha
WITH monthly_sales AS (
    SELECT
        country,
        date_trunc('month', invoice_date)::DATE AS MONTH,
        sum(quantity * unit_price) AS total_amount
        FROM retail_sales
        GROUP BY country, date_trunc('month', invoice_date)
)
SELECT
country,
month,
total_amount,
NTILE(4) OVER (
    PARTITION BY country
    ORDER BY total_amount DESC
) AS sales_quartile
FROM monthly_sales
ORDER BY country ASC, MONTH ASC

--8. úloha
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        row_number() over(
            PARTITION BY customer_id
            ORDER BY invoice_date ASC, invoice_no ASC
        ) AS rn
        FROM retail_sales
        WHERE customer_id IS NOT NULL
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM customer_first_purchase
WHERE rn = 1
ORDER BY customer_id ASC;

--9. úloha
WITH ranked_items AS (
    SELECT
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        (quantity * unit_price) AS amount,
        ROW_NUMBER() OVER(
            PARTITION BY invoice_no
            ORDER BY (quantity * unit_price) DESC
        ) AS row_num
        FROM retail_sales
)
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
FROM ranked_items
WHERE row_num <= 3
ORDER BY invoice_no ASC, row_num ASC;

--10. úloha
WITH customer_monthly_sales AS (
    SELECT
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY country, DATE_TRUNC('month', invoice_date), customer_id
),
ranked_customers AS (
    SELECT
        country,
        month,
        customer_id,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY country, month
            ORDER BY total_amount DESC
        ) AS sales_rank
    FROM customer_monthly_sales
)
SELECT
    country,
    month,
    customer_id,
    total_amount,
    sales_rank
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY country ASC, month ASC, sales_rank ASC, customer_id ASC;

--11. úloha
WITH ranked_items AS (
    SELECT
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        DENSE_RANK() OVER (
            PARTITION BY invoice_no
            ORDER BY unit_price DESC
        ) AS price_rank
    FROM retail_sales
)
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM ranked_items
WHERE price_rank BETWEEN 1 AND 5
ORDER BY invoice_no ASC, price_rank ASC, stock_code ASC;