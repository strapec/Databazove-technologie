-- Active: 1790866429854@@127.0.0.1@5432@datacraftinglab_db@public
-- Active: 1790866429854@@127.0.0.1@5432@postgres-- Active: 1790866429854@@127.0.0.1@5432@postgres@public
CREATE DATABASE datacraftinglab_db;

CREATE Table fourmills_sales(
    sales_id INT PRIMARY KEY,
    sale_date DATE,
    region varchar(100),
    state varchar(100),
    product_category varchar(100),
    product_name varchar(150),
    customer_type varchar(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    discount_rate INT,
    payment_method varchar(100),
    sales_rep varchar(150),
    warehouse varchar(100),
    delivery_status varchar(100),
    order_channel varchar(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10,2)
);

SELECT * FROM fourmills_sales;

--2. úloha
SELECT product_name, total_amount FROM fourmills_sales
WHERE total_amount > 
    (SELECT AVG(total_amount)
    FROM fourmills_sales);

--3. úloha
SELECT sales_id, sale_date, region, product_category FROM fourmills_sales
WHERE product_category =(
    SELECT product_category FROM fourmills_sales
    GROUP BY product_category
    ORDER BY sum(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;


--4. úloha
SELECT product_name, total_amount,(
        SELECT avg(total_amount)
        FROM fourmills_sales)
        AS avg_amount
FROM fourmills_sales;

--5. úloha
SELECT product_name, total_amount,
    (total_amount / (SELECT sum(total_amount)
    FROM fourmills_sales))
    AS amount_share
FROM fourmills_sales;

--6. úloha
SELECT mesiac, monthly_sales FROM(
    SELECT extract(MONTH FROM sale_date) AS mesiac, sum(total_amount) AS monthly_sales
    FROM fourmills_sales
    GROUP BY mesiac
    ORDER BY mesiac ASC
);

--7. úloha
SELECT * FROM(
    SELECT product_category, sum(total_amount) AS total_sales
    FROM fourmills_sales
    GROUP BY product_category
)
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

--8. úloha
SELECT product_name, product_category, total_amount FROM fourmills_sales t1
WHERE total_amount > (
    SELECT avg(total_amount) FROM fourmills_sales t2
    WHERE t2.product_category = t1.product_category
);

--9. úloha
SELECT product_name, region, total_amount, 
(SELECT min(total_amount) AS region_min_amount FROM fourmills_sales t2
    WHERE t2.region = t1.region)
FROM fourmills_sales t1
;

--10. úloha
SELECT * FROM fourmills_sales t1
WHERE EXISTS (
    SELECT product_name FROM fourmills_sales t2
    WHERE t2.product_name = t1.product_name
    GROUP BY t2.product_name
    HAVING count(DISTINCT extract(MONTH FROM sale_date)) >1
);

--11. úloha
SELECT product_category, product_name, total_amount FROM fourmills_sales t1
WHERE EXISTS(
    SELECT 1
    FROM fourmills_sales t2
    WHERE t2.product_category = t1.product_category
    AND total_amount > 200000
);

--12. úloha
SELECT product_category FROM fourmills_sales t1
WHERE EXISTS(
    SELECT 1
    FROM fourmills_sales t2
    WHERE t2.product_category = t1.product_category
)
GROUP BY product_category
HAVING count(DISTINCT region) > 3;

--13. úloha
SELECT * FROM fourmills_sales t1
WHERE EXISTS(
    SELECT 1
    FROM fourmills_sales t2
    WHERE t2.region = t1.region
    AND extract(YEAR FROM sale_date) = 2024
);

--14. úloha
SELECT DISTINCT product_category FROM fourmills_sales t1
WHERE NOT EXISTS(
    SELECT 1
    FROM fourmills_sales t2
    WHERE t2.product_category = t1.product_category
    AND total_amount > 500000
);

--15. úloha
SELECT region FROM fourmills_sales t1
WHERE NOT EXISTS(
    SELECT 1
    FROM fourmills_sales t2
    WHERE t2.region = t1.region
    AND product_category LIKE 'Flour'
);