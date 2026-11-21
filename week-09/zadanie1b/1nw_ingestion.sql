\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE TABLE IF NOT EXISTS bronze.categories (
    categoryid   INT,
    categoryname TEXT,
    description  TEXT,
    _source_file TEXT DEFAULT 'categories.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.customers (
    customerid   INT,
    customername TEXT,
    contactname  TEXT,
    address      TEXT,
    city         TEXT,
    postalcode   TEXT,
    country      TEXT,
    _source_file TEXT DEFAULT 'customers.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.employees (
    employeeid   INT,
    lastname     TEXT,
    firstname    TEXT,
    birthdate    TIMESTAMP,
    photo        TEXT,
    notes        TEXT,
    _source_file TEXT DEFAULT 'employees.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.orderdetails (
    orderdetailid INT,
    orderid       INT,
    productid     INT,
    quantity      INT,
    _source_file  TEXT DEFAULT 'orderdetails.csv',
    _loaded_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.orders (
    orderid      INT,
    customerid   INT,
    employeeid   INT,
    orderdate    TIMESTAMP,
    shipperid    INT,
    _source_file TEXT DEFAULT 'orders.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.products (
    productid    INT,
    productname  TEXT,
    supplierid   INT,
    categoryid   INT,
    unit         TEXT,
    price        NUMERIC(10,2),
    _source_file TEXT DEFAULT 'products.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.shippers (
    shipperid    INT,
    shippername  TEXT,
    phone        TEXT,
    _source_file TEXT DEFAULT 'shippers.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.suppliers (
    supplierid   INT,
    suppliername TEXT,
    contactname  TEXT,
    address      TEXT,
    city         TEXT,
    postalcode   TEXT,
    country      TEXT,
    phone        TEXT,
    _source_file TEXT DEFAULT 'suppliers.csv',
    _loaded_at   TIMESTAMPTZ DEFAULT now()
);

BEGIN;

TRUNCATE bronze.categories;
\COPY bronze.categories (categoryid, categoryname, description) FROM 'csv/categories.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.customers;
\COPY bronze.customers (customerid, customername, contactname, address, city, postalcode, country) FROM 'csv/customers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.employees;
\COPY bronze.employees (employeeid, lastname, firstname, birthdate, photo, notes) FROM 'csv/employees.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.orderdetails;
\COPY bronze.orderdetails (orderdetailid, orderid, productid, quantity) FROM 'csv/orderdetails.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.orders;
\COPY bronze.orders (orderid, customerid, employeeid, orderdate, shipperid) FROM 'csv/orders.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.products;
\COPY bronze.products (productid, productname, supplierid, categoryid, unit, price) FROM 'csv/products.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.shippers;
\COPY bronze.shippers (shipperid, shippername, phone) FROM 'csv/shippers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

TRUNCATE bronze.suppliers;
\COPY bronze.suppliers (supplierid, suppliername, contactname, address, city, postalcode, country, phone) FROM 'csv/suppliers.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';')

COMMIT;