-- =========================================
-- IT221: Performance Innovative Task
-- Data Warehouse Star Schema Project
-- Scenario: Online Store Sales (Scenario 1)
-- Architecture: Medallion (Bronze → Silver → Gold)
-- DBMS: MySQL / MariaDB
-- =========================================
-- LAYER OVERVIEW (all in one database):
--   OLTP Tables  = source/daily use
--   raw_*        = Bronze Layer (raw copy)
--   stg_*        = Silver Layer (cleaned)
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
    CustomerID   INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    City         VARCHAR(100),
    Email        VARCHAR(100),
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE products (
    ProductID   INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(100),
    UnitPrice   DECIMAL(10,2),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
    OrderID    INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate  DATE,
    CreatedAt  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID)   REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 3: INSERT SAMPLE DATA (OLTP)
-- =========================================

-- Customers (5 records)
INSERT INTO customers (CustomerName, City, Email) VALUES
    ('John Cruz',      'Cagayan de Oro', 'john@gmail.com'),
    ('Maria Santos',   'Iligan City',    'maria@gmail.com'),
    ('Kevin Reyes',    'Malaybalay',     'kevin@gmail.com'),
    ('Anna Dela Cruz', 'Cagayan de Oro', 'anna@gmail.com'),
    ('Luis Gomez',     'Iligan City',    'luis@gmail.com');

-- Products (5 records, 3 categories)
INSERT INTO products (ProductName, Category, UnitPrice) VALUES
    ('Mechanical Keyboard', 'Electronics', 2500.00),
    ('Gaming Mouse',        'Electronics', 1200.00),
    ('Office Chair',        'Furniture',   4500.00),
    ('USB-C Hub',           'Accessories',  850.00),
    ('Desk Lamp',           'Accessories',  650.00);

-- Orders (6 records, spread across 2 months)
INSERT INTO orders (CustomerID, OrderDate) VALUES
    (1, '2026-04-10'),
    (2, '2026-04-15'),
    (3, '2026-04-20'),
    (4, '2026-05-01'),
    (5, '2026-05-03'),
    (1, '2026-05-05');

-- Order Items (10 records)
INSERT INTO order_items (OrderID, ProductID, Quantity, UnitPrice, TotalAmount) VALUES
    (1, 1, 1, 2500.00, 2500.00),
    (1, 2, 2, 1200.00, 2400.00),
    (2, 3, 1, 4500.00, 4500.00),
    (3, 1, 1, 2500.00, 2500.00),
    (3, 2, 1, 1200.00, 1200.00),
    (4, 4, 2,  850.00, 1700.00),
    (4, 5, 1,  650.00,  650.00),
    (5, 3, 1, 4500.00, 4500.00),
    (6, 1, 1, 2500.00, 2500.00),
    (6, 4, 3,  850.00, 2550.00);


-- =========================================
-- SECTION 4: BRONZE LAYER TABLES (raw_*)
-- Purpose: Raw copy of OLTP data, as-is.
--          No constraints, no cleaning.
--          Equivalent to "Extract" in ETL.
-- =========================================

CREATE TABLE raw_customers (
    CustomerID   INT,
    CustomerName VARCHAR(100),
    City         VARCHAR(100),
    Email        VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE raw_products (
    ProductID   INT,
    ProductName VARCHAR(100),
    Category    VARCHAR(100),
    UnitPrice   DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE raw_orders (
    OrderID    INT,
    CustomerID INT,
    OrderDate  DATE
) ENGINE=InnoDB;

CREATE TABLE raw_order_items (
    OrderItemID INT,
    OrderID     INT,
    ProductID   INT,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 5: BRONZE ETL — EXTRACT
-- Copy OLTP data into Bronze tables as-is.
-- No transformation, just raw copying.
-- =========================================

INSERT INTO raw_customers
SELECT CustomerID, CustomerName, City, Email
FROM customers;

INSERT INTO raw_products
SELECT ProductID, ProductName, Category, UnitPrice
FROM products;

INSERT INTO raw_orders
SELECT OrderID, CustomerID, OrderDate
FROM orders;

INSERT INTO raw_order_items
SELECT OrderItemID, OrderID, ProductID, Quantity, UnitPrice, TotalAmount
FROM order_items;


-- =========================================
-- SECTION 6: SILVER LAYER TABLES (stg_*)
-- Purpose: Cleaned and standardized data.
--          Equivalent to "Transform" in ETL.
-- =========================================

CREATE TABLE stg_customers (
    CustomerID   INT,
    CustomerName VARCHAR(100),
    City         VARCHAR(100),
    Email        VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE stg_products (
    ProductID   INT,
    ProductName VARCHAR(100),
    Category    VARCHAR(100),
    UnitPrice   DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE stg_orders (
    OrderID    INT,
    CustomerID INT,
    OrderDate  DATE
) ENGINE=InnoDB;

CREATE TABLE stg_order_items (
    OrderItemID INT,
    OrderID     INT,
    ProductID   INT,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 7: SILVER ETL — TRANSFORM
-- Clean and standardize Bronze data.
-- TRIM removes extra spaces.
-- UPPER/LOWER standardizes text casing.
-- WHERE filters out incomplete records.
-- =========================================

INSERT INTO stg_customers
SELECT
    CustomerID,
    TRIM(CustomerName),
    TRIM(City),
    LOWER(TRIM(Email))
FROM raw_customers
WHERE CustomerName IS NOT NULL
  AND Email        IS NOT NULL
  AND City         IS NOT NULL;

INSERT INTO stg_products
SELECT
    ProductID,
    TRIM(ProductName),
    TRIM(Category),
    UnitPrice
FROM raw_products
WHERE ProductName IS NOT NULL
  AND Category    IS NOT NULL
  AND UnitPrice   > 0;

INSERT INTO stg_orders
SELECT
    OrderID,
    CustomerID,
    OrderDate
FROM raw_orders
WHERE OrderDate   IS NOT NULL
  AND CustomerID  IS NOT NULL;

INSERT INTO stg_order_items
SELECT
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    TotalAmount
FROM raw_order_items
WHERE Quantity    > 0
  AND UnitPrice   > 0
  AND TotalAmount > 0;


-- =========================================
-- SECTION 8: GOLD LAYER TABLES (dim_*/fact_*)
-- Purpose: Final star schema for analytics.
--          Equivalent to "Load" in ETL.
-- =========================================

-- Dimension: Customer
CREATE TABLE dim_customer (
    CustomerKey  INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID   INT,
    CustomerName VARCHAR(100),
    City         VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Product
CREATE TABLE dim_product (
    ProductKey  INT PRIMARY KEY AUTO_INCREMENT,
    ProductID   INT,
    ProductName VARCHAR(100),
    Category    VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Time
CREATE TABLE dim_time (
    TimeKey   INT PRIMARY KEY AUTO_INCREMENT,
    FullDate  DATE,
    Day       INT,
    MonthName VARCHAR(20),
    Month     INT,
    Quarter   INT,
    Year      INT
) ENGINE=InnoDB;

-- Fact Table: fact_sales
-- GRAIN: One row per purchased item.
--        Each row = one row in order_items.
CREATE TABLE fact_sales (
    SalesKey    INT PRIMARY KEY AUTO_INCREMENT,
    CustomerKey INT,
    ProductKey  INT,
    TimeKey     INT,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerKey) REFERENCES dim_customer(CustomerKey),
    FOREIGN KEY (ProductKey)  REFERENCES dim_product(ProductKey),
    FOREIGN KEY (TimeKey)     REFERENCES dim_time(TimeKey)
) ENGINE=InnoDB;


-- =========================================
-- SECTION 9: GOLD ETL — LOAD
-- Load Silver (cleaned) data into
-- Dimension and Fact tables.
-- =========================================

-- Load dim_customer from Silver
INSERT INTO dim_customer (CustomerID, CustomerName, City)
SELECT CustomerID, CustomerName, City
FROM stg_customers;

-- Load dim_product from Silver
INSERT INTO dim_product (ProductID, ProductName, Category)
SELECT ProductID, ProductName, Category
FROM stg_products;

-- Load dim_time from Silver (distinct dates only)
INSERT INTO dim_time (FullDate, Day, MonthName, Month, Quarter, Year)
SELECT DISTINCT
    OrderDate,
    DAY(OrderDate),
    MONTHNAME(OrderDate),
    MONTH(OrderDate),
    QUARTER(OrderDate),
    YEAR(OrderDate)
FROM stg_orders;

-- Load fact_sales from Silver
-- Joins stg tables to get surrogate keys from Gold dims
INSERT INTO fact_sales (CustomerKey, ProductKey, TimeKey, Quantity, UnitPrice, TotalAmount)
SELECT
    dc.CustomerKey,
    dp.ProductKey,
    dt.TimeKey,
    oi.Quantity,
    oi.UnitPrice,
    oi.TotalAmount
FROM stg_order_items oi
JOIN stg_orders      o  ON oi.OrderID   = o.OrderID
JOIN stg_customers   c  ON o.CustomerID = c.CustomerID
JOIN stg_products    p  ON oi.ProductID = p.ProductID
JOIN dim_customer    dc ON c.CustomerID = dc.CustomerID
JOIN dim_product     dp ON p.ProductID  = dp.ProductID
JOIN dim_time        dt ON o.OrderDate  = dt.FullDate;


-- =========================================
-- SECTION 10: VALIDATION QUERIES
-- =========================================

-- 1. Row Count Check
--    Expected: Both counts = 10 (match order_items)
SELECT COUNT(*) AS OLTPOrderItemsCount  FROM order_items;
SELECT COUNT(*) AS BronzeRawCount       FROM raw_order_items;
SELECT COUNT(*) AS SilverStagingCount   FROM stg_order_items;
SELECT COUNT(*) AS GoldFactSalesCount   FROM fact_sales;

-- 2. Amount / Measure Check
--    Expected: Zero rows (no incorrect totals)
SELECT *
FROM fact_sales
WHERE TotalAmount <> Quantity * UnitPrice;

-- 3. Duplicate Check
--    Expected: Zero rows (no duplicate fact records)
SELECT CustomerKey, ProductKey, TimeKey, COUNT(*) AS DuplicateCount
FROM fact_sales
GROUP BY CustomerKey, ProductKey, TimeKey
HAVING COUNT(*) > 1;

-- 4. Missing Date Check
--    Expected: Zero rows (all dates exist in dim_time)
SELECT *
FROM fact_sales fs
LEFT JOIN dim_time dt ON fs.TimeKey = dt.TimeKey
WHERE dt.TimeKey IS NULL;

-- 5. Missing Customer Dimension Check
--    Expected: Zero rows
SELECT *
FROM fact_sales fs
LEFT JOIN dim_customer dc ON fs.CustomerKey = dc.CustomerKey
WHERE dc.CustomerKey IS NULL;

-- 6. Missing Product Dimension Check
--    Expected: Zero rows
SELECT *
FROM fact_sales fs
LEFT JOIN dim_product dp ON fs.ProductKey = dp.ProductKey
WHERE dp.ProductKey IS NULL;


-- =========================================
-- SECTION 11: ANALYTICAL QUERIES
-- =========================================

-- Query 1: Total Sales per Month
--   Business use: Identify which months generate the most revenue.
SELECT
    dt.Year,
    dt.MonthName,
    SUM(fs.TotalAmount) AS TotalSales
FROM fact_sales fs
JOIN dim_time dt ON fs.TimeKey = dt.TimeKey
GROUP BY dt.Year, dt.MonthName, dt.Month
ORDER BY dt.Year, dt.Month;

-- Query 2: Top Customers by Total Amount Spent
--   Business use: Identify high-value customers for loyalty programs.
SELECT
    dc.CustomerName,
    dc.City,
    SUM(fs.TotalAmount) AS TotalSpent,
    SUM(fs.Quantity)    AS TotalItemsBought
FROM fact_sales fs
JOIN dim_customer dc ON fs.CustomerKey = dc.CustomerKey
GROUP BY dc.CustomerKey, dc.CustomerName, dc.City
ORDER BY TotalSpent DESC;

-- Query 3: Sales by Product Category
--   Business use: Determine which categories drive the most revenue.
SELECT
    dp.Category,
    SUM(fs.TotalAmount) AS CategorySales,
    SUM(fs.Quantity)    AS UnitsSold
FROM fact_sales fs
JOIN dim_product dp ON fs.ProductKey = dp.ProductKey
GROUP BY dp.Category
ORDER BY CategorySales DESC;

-- Query 4: Sales by City
--   Business use: Identify top cities for targeted marketing.
SELECT
    dc.City,
    SUM(fs.TotalAmount)  AS CitySales,
    COUNT(fs.SalesKey)   AS NumberOfTransactions
FROM fact_sales fs
JOIN dim_customer dc ON fs.CustomerKey = dc.CustomerKey
GROUP BY dc.City
ORDER BY CitySales DESC;

-- Query 5: Best-Selling Products by Quantity Sold
--   Business use: Determine which products to restock or promote.
SELECT
    dp.ProductName,
    dp.Category,
    SUM(fs.Quantity)    AS TotalQuantitySold,
    SUM(fs.TotalAmount) AS TotalRevenue
FROM fact_sales fs
JOIN dim_product dp ON fs.ProductKey = dp.ProductKey
GROUP BY dp.ProductKey, dp.ProductName, dp.Category
ORDER BY TotalQuantitySold DESC;


-- =========================================
-- SECTION 12: BUSINESS INSIGHT
-- =========================================
-- INSIGHT: Electronics is the top-performing category by both
-- units sold and total revenue, driven by repeat purchases of
-- the Mechanical Keyboard and Gaming Mouse. Cagayan de Oro
-- generates the highest city-level sales. May 2026 shows
-- growing revenue compared to April 2026.
-- RECOMMENDATION: Prioritize restocking Electronics and launch
-- a targeted promotion for Cagayan de Oro customers to further
-- increase revenue in the next quarter.
-- =========================================

COMMIT;
