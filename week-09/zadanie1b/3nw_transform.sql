\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_employee;
DROP TABLE IF EXISTS gold.dim_customer;
DROP TABLE IF EXISTS gold.dim_shipper;
DROP TABLE IF EXISTS gold.dim_product;
DROP TABLE IF EXISTS gold.dim_supplier;
DROP TABLE IF EXISTS gold.dim_category;

CREATE TABLE gold.dim_date (
    date_key  INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day       INT,
    month     INT,
    quarter   INT,
    year      INT
);

CREATE TABLE gold.dim_employee (
    employee_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id  INT NOT NULL UNIQUE,
    last_name    VARCHAR(15),
    first_name   VARCHAR(15),
    birth_date   TIMESTAMP,
    photo        VARCHAR(25),
    notes        VARCHAR(1024)
);

CREATE TABLE gold.dim_customer (
    customer_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   INT NOT NULL UNIQUE,
    customer_name VARCHAR(50),
    contact_name  VARCHAR(50),
    address       VARCHAR(50),
    city          VARCHAR(20),
    postal_code   VARCHAR(10),
    country       VARCHAR(15)
);

CREATE TABLE gold.dim_shipper (
    shipper_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipper_id   INT NOT NULL UNIQUE,
    shipper_name VARCHAR(25),
    phone        VARCHAR(15)
);

CREATE TABLE gold.dim_category (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(25),
    description   VARCHAR(255)
);

CREATE TABLE gold.dim_supplier (
    supplier_id   INT PRIMARY KEY,
    supplier_name VARCHAR(50),
    contact_name  VARCHAR(50),
    address       VARCHAR(50),
    city          VARCHAR(20),
    postal_code   VARCHAR(10),
    country       VARCHAR(15),
    phone         VARCHAR(15)
);

CREATE TABLE gold.dim_product (
    product_key  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id   INT NOT NULL UNIQUE,
    product_name VARCHAR(50),
    unit         VARCHAR(25),
    price        DECIMAL(10,2),
    category_id  INT REFERENCES gold.dim_category(category_id),
    supplier_id  INT REFERENCES gold.dim_supplier(supplier_id)
);

CREATE TABLE gold.fact_sales (
    sales_id     INT PRIMARY KEY,
    order_id     INT NOT NULL,
    product_key  INT NOT NULL REFERENCES gold.dim_product(product_key),
    customer_key INT NOT NULL REFERENCES gold.dim_customer(customer_key),
    employee_key INT NOT NULL REFERENCES gold.dim_employee(employee_key),
    shipper_key  INT NOT NULL REFERENCES gold.dim_shipper(shipper_key),
    date_key     INT NOT NULL REFERENCES gold.dim_date(date_key),
    quantity     INT NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL,
    sales_amount DECIMAL(12,2) NOT NULL
);

BEGIN;

INSERT INTO gold.dim_date (date_key, full_date, day, month, quarter, year)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT,
    d::DATE,
    EXTRACT(day FROM d)::INT,
    EXTRACT(month FROM d)::INT,
    EXTRACT(quarter FROM d)::INT,
    EXTRACT(year FROM d)::INT
FROM GENERATE_SERIES(
    (SELECT MIN(order_date)::DATE FROM silver.stg_orders),
    (SELECT MAX(order_date)::DATE FROM silver.stg_orders),
    INTERVAL '1 day'
) AS gs(d);

INSERT INTO gold.dim_employee (employee_id, last_name, first_name, birth_date, photo, notes)
SELECT employee_id, last_name, first_name, birth_date, photo, notes
FROM silver.stg_employees
ORDER BY employee_id;

INSERT INTO gold.dim_customer (customer_id, customer_name, contact_name, address, city, postal_code, country)
SELECT customer_id, customer_name, contact_name, address, city, postal_code, country
FROM silver.stg_customers
ORDER BY customer_id;

INSERT INTO gold.dim_shipper (shipper_id, shipper_name, phone)
SELECT shipper_id, shipper_name, phone
FROM silver.stg_shippers
ORDER BY shipper_id;

INSERT INTO gold.dim_category (category_id, category_name, description)
SELECT category_id, category_name, description
FROM silver.stg_categories
ORDER BY category_id;

INSERT INTO gold.dim_supplier (supplier_id, supplier_name, contact_name, address, city, postal_code, country, phone)
SELECT supplier_id, supplier_name, contact_name, address, city, postal_code, country, phone
FROM silver.stg_suppliers
ORDER BY supplier_id;

INSERT INTO gold.dim_product (product_id, product_name, unit, price, category_id, supplier_id)
SELECT product_id, product_name, unit, price, category_id, supplier_id
FROM silver.stg_products
ORDER BY product_id;

INSERT INTO gold.fact_sales
    (sales_id, order_id, product_key, customer_key, employee_key,
     shipper_key, date_key, quantity, unit_price, sales_amount)
SELECT
    od.order_detail_id,
    od.order_id,
    dp.product_key,
    dc.customer_key,
    de.employee_key,
    ds.shipper_key,
    TO_CHAR(o.order_date, 'YYYYMMDD')::INT,
    od.quantity,
    p.price,
    od.quantity * p.price
FROM silver.stg_orderdetails od
JOIN silver.stg_orders   o  ON o.order_id    = od.order_id
JOIN silver.stg_products p  ON p.product_id  = od.product_id
JOIN gold.dim_product    dp ON dp.product_id  = od.product_id
JOIN gold.dim_customer   dc ON dc.customer_id = o.customer_id
JOIN gold.dim_employee   de ON de.employee_id = o.employee_id
JOIN gold.dim_shipper    ds ON ds.shipper_id  = o.shipper_id;

CREATE INDEX ON gold.fact_sales(product_key);
CREATE INDEX ON gold.fact_sales(customer_key);
CREATE INDEX ON gold.fact_sales(employee_key);
CREATE INDEX ON gold.fact_sales(shipper_key);
CREATE INDEX ON gold.fact_sales(date_key);
CREATE INDEX ON gold.fact_sales(order_id);

COMMIT;