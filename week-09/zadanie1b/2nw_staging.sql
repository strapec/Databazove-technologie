\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS silver;

CREATE OR REPLACE VIEW silver.stg_categories AS
SELECT
    categoryid          AS category_id,
    TRIM(categoryname)  AS category_name,
    TRIM(description)   AS description
FROM bronze.categories;

CREATE OR REPLACE VIEW silver.stg_customers AS
SELECT
    customerid          AS customer_id,
    TRIM(customername)  AS customer_name,
    TRIM(contactname)   AS contact_name,
    TRIM(address)       AS address,
    TRIM(city)          AS city,
    TRIM(postalcode)    AS postal_code,
    TRIM(country)       AS country
FROM bronze.customers;

CREATE OR REPLACE VIEW silver.stg_employees AS
SELECT
    employeeid          AS employee_id,
    TRIM(lastname)      AS last_name,
    TRIM(firstname)     AS first_name,
    birthdate           AS birth_date,
    TRIM(photo)         AS photo,
    TRIM(notes)         AS notes
FROM bronze.employees;

CREATE OR REPLACE VIEW silver.stg_orderdetails AS
SELECT
    orderdetailid       AS order_detail_id,
    orderid             AS order_id,
    productid           AS product_id,
    quantity
FROM bronze.orderdetails;

CREATE OR REPLACE VIEW silver.stg_orders AS
SELECT
    orderid             AS order_id,
    customerid          AS customer_id,
    employeeid          AS employee_id,
    orderdate           AS order_date,
    shipperid           AS shipper_id
FROM bronze.orders;

CREATE OR REPLACE VIEW silver.stg_products AS
SELECT
    productid           AS product_id,
    TRIM(productname)   AS product_name,
    supplierid          AS supplier_id,
    categoryid          AS category_id,
    TRIM(unit)          AS unit,
    price
FROM bronze.products;

CREATE OR REPLACE VIEW silver.stg_shippers AS
SELECT
    shipperid           AS shipper_id,
    TRIM(shippername)   AS shipper_name,
    TRIM(phone)         AS phone
FROM bronze.shippers;

CREATE OR REPLACE VIEW silver.stg_suppliers AS
SELECT
    supplierid          AS supplier_id,
    TRIM(suppliername)  AS supplier_name,
    TRIM(contactname)   AS contact_name,
    TRIM(address)       AS address,
    TRIM(city)          AS city,
    TRIM(postalcode)    AS postal_code,
    TRIM(country)       AS country,
    TRIM(phone)         AS phone
FROM bronze.suppliers;