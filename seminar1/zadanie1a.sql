-- Active: 1790866429854@@127.0.0.1@5432@superstore@public
--1. úloha
CREATE DATABASE superstore;

CREATE Table customers(
    customer_id varchar(20) PRIMARY KEY,
    customer_name varchar(100),
    segment varchar(50),
    country varchar(50),
    region varchar(50)
);
CREATE Table products(
    product_id varchar(20) PRIMARY KEY,
    category varchar(50),
    sub_category varchar(50),
    product_name varchar(100)
);

CREATE Table orders(
    order_id varchar(20) ,
    customer_id varchar(20),
    product_id varchar(20),
    Foreign Key (customer_id) REFERENCES customers(customer_id),
    Foreign Key (product_id) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2)
);
SELECT * FROM customers;
SELECT * FROM products;
select * FROM orders;

--2. úloha
SELECT orders.order_id, customers.customer_name, orders.sales
FROM orders
JOIN customers customers ON orders.customer_id = customers.customer_id
WHERE orders.sales > 500
order BY orders.sales DESC;

--3. úloha
SELECT orders.order_id, customers.customer_name, products.category, orders.sales
FROM orders
JOIN customers on orders.customer_id = customers.customer_id
JOIN products on orders.product_id = products.product_id;

--4. úloha
SELECT customers.region, sum(orders.sales) AS predaje
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region

--5. úloha
SELECT products.product_name, sum(orders.sales)
FROM products
LEFT JOIN orders ON products.product_id = orders.product_id
GROUP BY products.product_name

--6. úloha
SELECT customers.customer_name, orders.order_id, orders.sales
FROM customers
FULL OUTER JOIN orders on customers.customer_id = orders.customer_id

-- 7. úloha
SELECT customers.region, sum(orders.sales)
FROM customers
join orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region

-- 8. úloha
SELECT customers.customer_name, count(orders.customer_id)
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name;

--9. úloha
SELECT products.category, avg(orders.discount)
FROM products
JOIN orders ON products.product_id = orders.product_id
GROUP BY products.category

--10. úloha
SELECT customers.customer_name, sum(orders.sales)
FROM customers
JOIN orders on customers.customer_id = orders.customer_id
GROUP BY customers.customer_name
HAVING sum(orders.sales) > 2000

--11. úloha
SELECT customers.region, sum(orders.sales), avg(orders.discount), count(orders.order_id)
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
GROUP BY customers.region

--12. úloha
SELECT
    customers.region,
    count(CASE WHEN orders.sales > 1000 THEN 1 END) AS high_value_orders,
    count(CASE WHEN orders.sales <= 1000 THEN 1 END) AS low_value_orders
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region

--13. úloha
SELECT customers.customer_name, sum(orders.sales) AS celkovy_predaj, avg(orders.discount), count(orders.order_id),
CASE 
    WHEN sum(orders.sales) > 2500 THEN 'VIP' 
    ELSE  'REGULAR'
END AS typ_zakaznika
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name
ORDER BY celkovy_predaj DESC;