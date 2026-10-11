-- Active: 1790866429854@@127.0.0.1@5432@retail_sales@public
--1. úloha
CREATE View high_value_customers AS
SELECT customers.customer_id, customers.customer_name, sum(orders.sales) AS total_sales
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
group by customers.customer_id, customers.customer_name
HAVING sum(orders.sales) > 2000;

select * from high_value_customers;

--2. úloha
CREATE VIEW regional_monthly_sales AS
SELECT customers.region, DATE_TRUNC('month', orders.order_date) AS month, sum(orders.sales) AS total_sales
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region, DATE_TRUNC('month', orders.order_date);

SELECT * FROM regional_monthly_sales WHERE region = 'West'

--3. úloha
CREATE VIEW analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount
FROM orders;

SELECT * FROM analyst_orders;

--4. úloha
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

SELECT orders.order_id 
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
WHERE customers.customer_id = 'C001';

--5. úloha
CREATE INDEX idx_orders_order_date
ON orders(order_date);

SELECT date_trunc('month', order_date) AS datum, sum(sales) AS suma
FROM orders
GROUP BY datum
ORDER BY suma ASC;

--6. úloha
CREATE INDEX idx_orders_region_category
ON orders(customer_id, order_date);

SELECT customers.customer_name, orders.profit
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
WHERE customers.region LIKE 'West' AND orders.order_date > '2024-01-01'

--7. úloha
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';

--8. úloha
CREATE DATABASE retail_sales;

CREATE Table orders(
    order_id varchar(20) PRIMARY KEY,
    customer_id varchar(20) NOT NULL,
    product_id varchar(20) NOT NULL,
    order_date date NOT NULL,
    region VARCHAR(20) NOT NULL,
    category varchar(50) NOT NULL,
    ship_mode varchar(30) NOT NULL,
    sales DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL
);

ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

SELECT * FROM orders;

--9. úloha
CREATE Procedure get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_total_sales DECIMAL(10,2);
BEGIN
    SELECT sum(sales)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník: %, Celkový predaj: %', p_customer_id, v_total_sales;
END;
$procedure$;

CALL get_customer_sales('C001');

--10. úloha
CREATE Procedure apply_regional_discount(p_region_name varchar, p_discount_rate DECIMAL(10,2))
LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE orders
    SET sales = sales * (1-p_discount_rate)
    WHERE region LIKE p_region_name;

    RAISE NOTICE 'Názov regiónu: %, Použitá zľava: %', p_region_name, p_discount_rate;
END;
$procedure$;

CALL apply_regional_discount('West', 0.10); 

--10. úloha
CREATE PROCEDURE get_sales_between(p_start_date date, p_end_date date)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_total_price DECIMAL(10,2);
BEGIN
    SELECT sum(sales)
    INTO v_total_price
    FROM orders
    WHERE order_date >= p_start_date AND p_end_date <= order_date;

    RAISE NOTICE 'Začiatok obdobia: %, Koniec obdobia: %, Celková cena: %', p_start_date, p_end_date, v_total_price;

END;
$procedure$;

CALL get_sales_between('2024-01-01','2024-03-31')

