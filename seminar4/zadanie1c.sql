-- Active: 1790866429854@@127.0.0.1@5432@retail@public
-- Active: 1790866429854@@127.0.0.1@5432@postgres@public

--1. úloha
CREATE DATABASE retail;

CREATE Table retail_sales(
    invoice_no varchar(20),
    stock_code varchar(50),
    descriptionn TEXT,
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
