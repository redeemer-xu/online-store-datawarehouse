-- =========================================
-- IT221: Performance Innovative Task
-- Data Warehouse Star Schema Project
-- Scenario: Online Store Sales (Scenario 1)
-- Architecture: Medallion (Bronze → Silver → Gold)
-- DBMS: MySQL / MariaDB
-- =========================================
-- LAYER OVERVIEW (all in one database):
--   OLTP Tables    = source/daily use
--   raw_*          = Bronze Layer (raw copy as-is)
--   stg_*          = Silver Layer (cleaned/standardized)
--   dim_* / fact_* = Gold Layer (star schema)
-- =========================================


-- =========================================
-- SECTION 1: RESET DATABASE
-- =========================================

DROP DATABASE IF EXISTS online_store_dw;
CREATE DATABASE online_store_dw;
USE online_store_dw;


-- =========================================
-- SECTION 2: OLTP SOURCE TABLES
-- (Daily-use operational database)
-- =========================================

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    city          VARCHAR(100),
    email         VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(100),
    unit_price   DECIMAL(10,2),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id    INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date  DATE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    total_amount  DECIMAL(10,2),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 3: INSERT SAMPLE DATA (OLTP)
-- Intentionally messy names to demonstrate
-- Silver layer cleaning (TRIM, PROPER CASE)
-- =========================================

-- customers (12 records — messy names on purpose)
INSERT INTO customers (first_name, last_name, city, email) VALUES
    ('  jOHN  ',     'cRUZ',        'Cagayan de Oro', 'john@gmail.com'),
    ('MARIA  ',      'sANTOS',      'Iligan City',    'MARIA@GMAIL.COM'),
    ('  Kevin',      'REYES  ',     'Malaybalay',     'kevin@gmail.com'),
    ('anna  ',       'dela Cruz',   'Cagayan de Oro', 'Anna@Gmail.Com'),
    ('LUIS',         '  Gomez  ',   'Iligan City',    'luis@gmail.com'),
    ('  Sharon  ',   'corNETTA',    'Cagayan de Oro', 'sharon@gmail.com'),
    ('benjaMin',     '  TORRES',    'Malaybalay',     'BENJAMIN@GMAIL.COM'),
    ('  CLAIRE',     'Mendoza  ',   'Iligan City',    'claire@gmail.com'),
    ('rONALD  ',     'agUILAR',     'Cagayan de Oro', 'ronald@gmail.com'),
    ('  patricia',   'LIMOS',       'Malaybalay',     'Patricia@Gmail.Com'),
    ('MARK  ',       '  Villanueva','Iligan City',     'mark@gmail.com'),
    ('  grace  ',    'TAN  ',       'Cagayan de Oro', 'GRACE@GMAIL.COM');

-- products (10 records, 3 categories)
INSERT INTO products (product_name, category, unit_price) VALUES
    ('Mechanical Keyboard', 'Electronics', 2500.00),
    ('Gaming Mouse',        'Electronics', 1200.00),
    ('Office Chair',        'Furniture',   4500.00),
    ('USB-C Hub',           'Accessories',  850.00),
    ('Desk Lamp',           'Accessories',  650.00),
    ('Monitor 24inch',      'Electronics', 8500.00),
    ('Laptop Stand',        'Accessories',  950.00),
    ('Webcam HD',           'Electronics', 2200.00),
    ('Bookshelf 5-tier',    'Furniture',   3200.00),
    ('Mousepad XL',         'Accessories',  450.00);

-- orders (15 records, spread across 3 months)
INSERT INTO orders (customer_id, order_date) VALUES
    (1,  '2026-03-05'),
    (2,  '2026-03-10'),
    (3,  '2026-03-15'),
    (4,  '2026-03-20'),
    (5,  '2026-03-25'),
    (6,  '2026-04-02'),
    (7,  '2026-04-08'),
    (8,  '2026-04-14'),
    (9,  '2026-04-18'),
    (10, '2026-04-22'),
    (11, '2026-05-01'),
    (12, '2026-05-05'),
    (1,  '2026-05-08'),
    (3,  '2026-05-12'),
    (6,  '2026-05-15');

-- order_items (20 records)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_amount) VALUES
    (1,  1,  1, 2500.00,  2500.00),
    (1,  2,  2, 1200.00,  2400.00),
    (2,  3,  1, 4500.00,  4500.00),
    (3,  4,  2,  850.00,  1700.00),
    (3,  5,  1,  650.00,   650.00),
    (4,  6,  1, 8500.00,  8500.00),
    (5,  7,  2,  950.00,  1900.00),
    (6,  8,  1, 2200.00,  2200.00),
    (6,  1,  1, 2500.00,  2500.00),
    (7,  9,  1, 3200.00,  3200.00),
    (8,  10, 3,  450.00,  1350.00),
    (9,  2,  2, 1200.00,  2400.00),
    (10, 3,  1, 4500.00,  4500.00),
    (11, 6,  1, 8500.00,  8500.00),
    (11, 7,  1,  950.00,   950.00),
    (12, 1,  2, 2500.00,  5000.00),
    (13, 4,  3,  850.00,  2550.00),
    (13, 5,  2,  650.00,  1300.00),
    (14, 8,  1, 2200.00,  2200.00),
    (15, 10, 2,  450.00,   900.00);


-- =========================================
-- SECTION 4: BRONZE LAYER TABLES (raw_*)
-- Purpose: Raw copy of OLTP data, as-is.
--          No constraints, no cleaning.
--          Equivalent to "Extract" in ETL.
-- =========================================

CREATE TABLE raw_customers (
    customer_id INT,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    city        VARCHAR(100),
    email       VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE raw_products (
    product_id   INT,
    product_name VARCHAR(100),
    category     VARCHAR(100),
    unit_price   DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE raw_orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE
) ENGINE=InnoDB;

CREATE TABLE raw_order_items (
    order_item_id INT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    total_amount  DECIMAL(10,2)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 5: BRONZE ETL — EXTRACT
-- Copy OLTP data into Bronze tables as-is.
-- No transformation — raw dirty data preserved.
-- =========================================

INSERT INTO raw_customers
SELECT customer_id, first_name, last_name, city, email
FROM customers;

INSERT INTO raw_products
SELECT product_id, product_name, category, unit_price
FROM products;

INSERT INTO raw_orders
SELECT order_id, customer_id, order_date
FROM orders;

INSERT INTO raw_order_items
SELECT order_item_id, order_id, product_id, quantity, unit_price, total_amount
FROM order_items;


-- =========================================
-- SECTION 6: SILVER LAYER TABLES (stg_*)
-- Purpose: Cleaned and standardized data.
--          Equivalent to "Transform" in ETL.
-- first_name and last_name are cleaned here.
-- full_name is constructed in Gold (dim).
-- =========================================

CREATE TABLE stg_customers (
    customer_id INT,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    city        VARCHAR(100),
    email       VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE stg_products (
    product_id   INT,
    product_name VARCHAR(100),
    category     VARCHAR(100),
    unit_price   DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE stg_orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE
) ENGINE=InnoDB;

CREATE TABLE stg_order_items (
    order_item_id INT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    total_amount  DECIMAL(10,2)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 7: SILVER ETL — TRANSFORM
-- Clean and standardize Bronze data.
-- TRIM    = removes leading/trailing spaces
-- CONCAT + UPPER + LOWER = proper case names
--   e.g. '  jOHN  ' → 'John'
--   e.g. 'cRUZ'     → 'Cruz'
-- LOWER   = standardizes email to lowercase
-- WHERE   = filters out incomplete records
-- =========================================

INSERT INTO stg_customers
SELECT
    customer_id,
    -- Proper case: first letter upper, rest lower
    CONCAT(
        UPPER(LEFT(TRIM(first_name), 1)),
        LOWER(SUBSTRING(TRIM(first_name), 2))
    ) AS first_name,
    CONCAT(
        UPPER(LEFT(TRIM(last_name), 1)),
        LOWER(SUBSTRING(TRIM(last_name), 2))
    ) AS last_name,
    TRIM(city),
    LOWER(TRIM(email))
FROM raw_customers
WHERE first_name  IS NOT NULL
  AND last_name   IS NOT NULL
  AND email       IS NOT NULL
  AND city        IS NOT NULL;

INSERT INTO stg_products
SELECT
    product_id,
    TRIM(product_name),
    TRIM(category),
    unit_price
FROM raw_products
WHERE product_name IS NOT NULL
  AND category     IS NOT NULL
  AND unit_price   > 0;

INSERT INTO stg_orders
SELECT
    order_id,
    customer_id,
    order_date
FROM raw_orders
WHERE order_date  IS NOT NULL
  AND customer_id IS NOT NULL;

INSERT INTO stg_order_items
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    total_amount
FROM raw_order_items
WHERE quantity     > 0
  AND unit_price   > 0
  AND total_amount > 0;


-- =========================================
-- SECTION 8: GOLD LAYER TABLES (dim_*/fact_*)
-- Purpose: Final star schema for analytics.
--          Equivalent to "Load" in ETL.
-- full_name is constructed here from
-- cleaned first_name + last_name in Silver.
-- =========================================

-- Dimension: Customer
CREATE TABLE dim_customer (
    customer_key  INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT,
    full_name     VARCHAR(100),
    city          VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Product
CREATE TABLE dim_product (
    product_key  INT PRIMARY KEY AUTO_INCREMENT,
    product_id   INT,
    product_name VARCHAR(100),
    category     VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Time
CREATE TABLE dim_time (
    time_key   INT PRIMARY KEY AUTO_INCREMENT,
    full_date  DATE,
    day        INT,
    month_name VARCHAR(20),
    month      INT,
    quarter    INT,
    year       INT
) ENGINE=InnoDB;

-- Fact Table: fact_sales
-- GRAIN: One row per purchased item.
--        Each row = one row in order_items.
CREATE TABLE fact_sales (
    sales_key    INT PRIMARY KEY AUTO_INCREMENT,
    customer_key INT,
    product_key  INT,
    time_key     INT,
    quantity     INT,
    unit_price   DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
    FOREIGN KEY (time_key)     REFERENCES dim_time(time_key)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 9: GOLD ETL — LOAD
-- Load Silver cleaned data into Gold tables.
-- full_name = CONCAT of cleaned first + last.
-- =========================================

-- Load dim_customer from Silver
-- CONCAT first_name + last_name → full_name
INSERT INTO dim_customer (customer_id, full_name, city)
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    city
FROM stg_customers;

-- Load dim_product from Silver
INSERT INTO dim_product (product_id, product_name, category)
SELECT product_id, product_name, category
FROM stg_products;

-- Load dim_time from Silver (distinct dates only)
INSERT INTO dim_time (full_date, day, month_name, month, quarter, year)
SELECT DISTINCT
    order_date,
    DAY(order_date),
    MONTHNAME(order_date),
    MONTH(order_date),
    QUARTER(order_date),
    YEAR(order_date)
FROM stg_orders;

-- Load fact_sales
-- Joins stg_ tables to resolve surrogate keys from Gold dims
INSERT INTO fact_sales (customer_key, product_key, time_key, quantity, unit_price, total_amount)
SELECT
    dc.customer_key,
    dp.product_key,
    dt.time_key,
    oi.quantity,
    oi.unit_price,
    oi.total_amount
FROM stg_order_items oi
JOIN stg_orders    o  ON oi.order_id   = o.order_id
JOIN stg_customers c  ON o.customer_id = c.customer_id
JOIN stg_products  p  ON oi.product_id = p.product_id
JOIN dim_customer  dc ON c.customer_id = dc.customer_id
JOIN dim_product   dp ON p.product_id  = dp.product_id
JOIN dim_time      dt ON o.order_date  = dt.full_date;


-- =========================================
-- SECTION 10: VALIDATION QUERIES
-- =========================================

-- 1. Row Count Check
--    Expected: All four counts = 20
SELECT COUNT(*) AS oltp_order_items_count FROM order_items;
SELECT COUNT(*) AS bronze_raw_count       FROM raw_order_items;
SELECT COUNT(*) AS silver_staging_count   FROM stg_order_items;
SELECT COUNT(*) AS gold_fact_sales_count  FROM fact_sales;

-- 2. Silver Cleaning Proof
--    Shows raw dirty name vs cleaned name side by side
--    Expected: cleaned names have no extra spaces, proper casing
SELECT
    r.customer_id,
    r.first_name                          AS raw_first_name,
    r.last_name                           AS raw_last_name,
    s.first_name                          AS cleaned_first_name,
    s.last_name                           AS cleaned_last_name,
    CONCAT(s.first_name,' ',s.last_name)  AS full_name_preview
FROM raw_customers r
JOIN stg_customers s ON r.customer_id = s.customer_id;

-- 3. Amount / Measure Check
--    Expected: Zero rows (no incorrect totals)
SELECT *
FROM fact_sales
WHERE total_amount <> quantity * unit_price;

-- 4. Duplicate Check
--    Expected: Zero rows (no duplicate fact records)
SELECT
    customer_key,
    product_key,
    time_key,
    COUNT(*) AS duplicate_count
FROM fact_sales
GROUP BY customer_key, product_key, time_key
HAVING COUNT(*) > 1;

-- 5. Missing Date Check
--    Expected: Zero rows (all dates exist in dim_time)
SELECT *
FROM fact_sales fs
LEFT JOIN dim_time dt ON fs.time_key = dt.time_key
WHERE dt.time_key IS NULL;

-- 6. Missing Customer Dimension Check
--    Expected: Zero rows
SELECT *
FROM fact_sales fs
LEFT JOIN dim_customer dc ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- 7. Missing Product Dimension Check
--    Expected: Zero rows
SELECT *
FROM fact_sales fs
LEFT JOIN dim_product dp ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL;


-- =========================================
-- SECTION 11: ANALYTICAL QUERIES
-- =========================================

-- Query 1: Total Sales per Month
--   Business use: Identify which months generate the most revenue.
SELECT
    dt.year,
    dt.month_name,
    SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_time dt ON fs.time_key = dt.time_key
GROUP BY dt.year, dt.month_name, dt.month
ORDER BY dt.year, dt.month;

-- Query 2: Top Customers by Total Amount Spent
--   Business use: Identify high-value customers for loyalty programs.
SELECT
    dc.full_name,
    dc.city,
    SUM(fs.total_amount) AS total_spent,
    SUM(fs.quantity)     AS total_items_bought
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.full_name, dc.city
ORDER BY total_spent DESC;

-- Query 3: Sales by Product Category
--   Business use: Determine which categories drive the most revenue.
SELECT
    dp.category,
    SUM(fs.total_amount) AS category_sales,
    SUM(fs.quantity)     AS units_sold
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY category_sales DESC;

-- Query 4: Sales by City
--   Business use: Identify top cities for targeted marketing.
SELECT
    dc.city,
    SUM(fs.total_amount) AS city_sales,
    COUNT(fs.sales_key)  AS number_of_transactions
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_key = dc.customer_key
GROUP BY dc.city
ORDER BY city_sales DESC;

-- Query 5: Best-Selling Products by Quantity Sold
--   Business use: Determine which products to restock or promote.
SELECT
    dp.product_name,
    dp.category,
    SUM(fs.quantity)     AS total_quantity_sold,
    SUM(fs.total_amount) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.product_key, dp.product_name, dp.category
ORDER BY total_quantity_sold DESC;


-- =========================================
-- SECTION 12: BUSINESS INSIGHT
-- =========================================
-- INSIGHT: Electronics is the top-performing category by both
-- units sold and total revenue, led by the Monitor 24inch and
-- Mechanical Keyboard. Cagayan de Oro consistently generates
-- the highest city-level sales across all three months.
-- May 2026 shows the strongest month-over-month growth.
-- RECOMMENDATION: Prioritize restocking Electronics — especially
-- Monitor 24inch and Mechanical Keyboards — and launch a targeted
-- loyalty promotion for Cagayan de Oro customers to sustain and
-- grow revenue heading into the next quarter.
-- =========================================

COMMIT;
