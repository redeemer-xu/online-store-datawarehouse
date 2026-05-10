-- =========================================
-- IT221: Performance Innovative Task
-- Data Warehouse Star Schema Project
-- Scenario: Online Store Sales (Scenario 1)
-- DBMS: MySQL / MariaDB
-- =========================================

-- =========================================
-- SECTION 1: RESET DATABASE
-- =========================================

DROP DATABASE IF EXISTS online_store_dw;

CREATE DATABASE online_store_dw;

USE online_store_dw;

-- =========================================
-- SECTION 2: OLTP SOURCE TABLES
-- =========================================

-- Customers Table
CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    City         VARCHAR(100),
    Email        VARCHAR(100),
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Products Table
CREATE TABLE Products (
    ProductID   INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(100),
    UnitPrice   DECIMAL(10,2),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Orders Table
CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderDate  DATE,
    CreatedAt  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
) ENGINE=InnoDB;

-- OrderItems Table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
) ENGINE=InnoDB;

-- =========================================
-- SECTION 3: INDEXES
-- =========================================

CREATE INDEX idx_customer_city
    ON Customers(City);

CREATE INDEX idx_product_category
    ON Products(Category);

CREATE INDEX idx_order_date
    ON Orders(OrderDate);

CREATE INDEX idx_orderitems_orderid
    ON OrderItems(OrderID);

CREATE INDEX idx_orderitems_productid
    ON OrderItems(ProductID);

-- =========================================
-- SECTION 4: INSERT SAMPLE DATA (OLTP)
-- =========================================

-- Customers (minimum 3 records)
INSERT INTO Customers (CustomerName, City, Email)
VALUES
    ('John Cruz',      'Cagayan de Oro', 'john@gmail.com'),
    ('Maria Santos',   'Iligan City',    'maria@gmail.com'),
    ('Kevin Reyes',    'Malaybalay',     'kevin@gmail.com'),
    ('Anna Dela Cruz', 'Cagayan de Oro', 'anna@gmail.com'),
    ('Luis Gomez',     'Iligan City',    'luis@gmail.com');

-- Products (minimum 3 records, 3 distinct categories)
INSERT INTO Products (ProductName, Category, UnitPrice)
VALUES
    ('Mechanical Keyboard', 'Electronics',    2500.00),
    ('Gaming Mouse',        'Electronics',    1200.00),
    ('Office Chair',        'Furniture',      4500.00),
    ('USB-C Hub',           'Accessories',    850.00),
    ('Desk Lamp',           'Accessories',    650.00);

-- Orders (minimum 3 records, spread across 2 months)
INSERT INTO Orders (CustomerID, OrderDate)
VALUES
    (1, '2026-04-10'),
    (2, '2026-04-15'),
    (3, '2026-04-20'),
    (4, '2026-05-01'),
    (5, '2026-05-03'),
    (1, '2026-05-05');

-- OrderItems (minimum 5 transaction/detail records)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice, TotalAmount)
VALUES
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
-- SECTION 5: STAR SCHEMA / DATA WAREHOUSE
-- =========================================

-- Dimension: Customer
CREATE TABLE DimCustomer (
    CustomerKey  INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID   INT,
    CustomerName VARCHAR(100),
    City         VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Product
CREATE TABLE DimProduct (
    ProductKey  INT PRIMARY KEY AUTO_INCREMENT,
    ProductID   INT,
    ProductName VARCHAR(100),
    Category    VARCHAR(100)
) ENGINE=InnoDB;

-- Dimension: Time
CREATE TABLE DimTime (
    TimeKey   INT PRIMARY KEY AUTO_INCREMENT,
    FullDate  DATE,
    Day       INT,
    MonthName VARCHAR(20),
    Month     INT,
    Quarter   INT,
    Year      INT
) ENGINE=InnoDB;

-- Fact Table: FactSales
CREATE TABLE FactSales (
    SalesKey    INT PRIMARY KEY AUTO_INCREMENT,
    CustomerKey INT,
    ProductKey  INT,
    TimeKey     INT,
    Quantity    INT,
    UnitPrice   DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerKey)
        REFERENCES DimCustomer(CustomerKey),
    FOREIGN KEY (ProductKey)
        REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (TimeKey)
        REFERENCES DimTime(TimeKey)
) ENGINE=InnoDB;

-- =========================================
-- SECTION 6: FACT TABLE GRAIN
-- =========================================
-- GRAIN: One row per purchased item, meaning each record in
-- FactSales corresponds to one row in the OrderItems table.

-- =========================================
-- MEDALLION ARCHITECTURE FLOW
-- Bronze  = OLTP Source Tables
-- Silver  = Cleansed / Standardized Data
-- Gold    = Star Schema / Analytics Layer
-- =========================================

-- =========================================
-- SECTION 7: ETL PROCESS
-- (INSERT INTO ... SELECT from source tables)
-- =========================================

-- Load DimCustomer
INSERT INTO DimCustomer (CustomerID, CustomerName, City)
SELECT
    CustomerID,
    CustomerName,
    City
FROM Customers;

-- Load DimProduct
INSERT INTO DimProduct (ProductID, ProductName, Category)
SELECT
    ProductID,
    ProductName,
    Category
FROM Products;

-- Load DimTime
INSERT INTO DimTime (FullDate, Day, MonthName, Month, Quarter, Year)
SELECT DISTINCT
    OrderDate,
    DAY(OrderDate),
    MONTHNAME(OrderDate),
    MONTH(OrderDate),
    QUARTER(OrderDate),
    YEAR(OrderDate)
FROM Orders;

-- Load FactSales
INSERT INTO FactSales
(
    CustomerKey,
    ProductKey,
    TimeKey,
    Quantity,
    UnitPrice,
    TotalAmount
)
SELECT
    dc.CustomerKey,
    dp.ProductKey,
    dt.TimeKey,
    oi.Quantity,
    oi.UnitPrice,
    oi.TotalAmount

FROM OrderItems oi

JOIN Orders o
    ON oi.OrderID = o.OrderID

JOIN Customers c
    ON o.CustomerID = c.CustomerID

JOIN Products p
    ON oi.ProductID = p.ProductID

JOIN DimCustomer dc
    ON c.CustomerID = dc.CustomerID

JOIN DimProduct dp
    ON p.ProductID = dp.ProductID

JOIN DimTime dt
    ON o.OrderDate = dt.FullDate;

-- =========================================
-- SECTION 8: VALIDATION QUERIES
-- =========================================

-- 1. Row Count Check
--    Expected: Both counts should match (10 rows each).
SELECT COUNT(*) AS OrderItemsCount FROM OrderItems;
SELECT COUNT(*) AS FactSalesCount  FROM FactSales;

-- 2. Amount / Measure Check
--    Expected: Zero rows returned (no incorrect totals).
SELECT *
FROM FactSales
WHERE TotalAmount <> Quantity * UnitPrice;

-- 3. Duplicate Check
--    Expected: Zero rows returned (no duplicate fact records).
SELECT
    CustomerKey,
    ProductKey,
    TimeKey,
    COUNT(*) AS DuplicateCount
FROM FactSales
GROUP BY
    CustomerKey,
    ProductKey,
    TimeKey
HAVING COUNT(*) > 1;

-- 4. Missing Date Check
--    Expected: Zero rows returned (all dates linked to DimTime).
SELECT *
FROM FactSales fs
LEFT JOIN DimTime dt
    ON fs.TimeKey = dt.TimeKey
WHERE dt.TimeKey IS NULL;

-- 5. Missing Dimension Check
--    Expected: Zero rows returned (all customers linked to DimCustomer).
SELECT *
FROM FactSales fs
LEFT JOIN DimCustomer dc
    ON fs.CustomerKey = dc.CustomerKey
WHERE dc.CustomerKey IS NULL;

-- =========================================
-- SECTION 9: ANALYTICAL QUERIES
-- =========================================

-- Query 1: Total Sales per Month
--   Business use: Identify which months generate the most revenue.
SELECT
    dt.Year,
    dt.MonthName,
    SUM(fs.TotalAmount) AS TotalSales
FROM FactSales fs
JOIN DimTime dt
    ON fs.TimeKey = dt.TimeKey
GROUP BY
    dt.Year,
    dt.MonthName,
    dt.Month
ORDER BY
    dt.Year,
    dt.Month;

-- Query 2: Top Customers by Total Amount Spent
--   Business use: Identify high-value customers for loyalty programs.
SELECT
    dc.CustomerName,
    dc.City,
    SUM(fs.TotalAmount)  AS TotalSpent,
    SUM(fs.Quantity)     AS TotalItemsBought
FROM FactSales fs
JOIN DimCustomer dc
    ON fs.CustomerKey = dc.CustomerKey
GROUP BY
    dc.CustomerKey,
    dc.CustomerName,
    dc.City
ORDER BY TotalSpent DESC;

-- Query 3: Sales by Product Category
--   Business use: Determine which product categories drive revenue.
SELECT
    dp.Category,
    SUM(fs.TotalAmount) AS CategorySales,
    SUM(fs.Quantity)    AS UnitsSold
FROM FactSales fs
JOIN DimProduct dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY dp.Category
ORDER BY CategorySales DESC;

-- Query 4: Sales by City
--   Business use: Identify top-performing cities for targeted marketing.
SELECT
    dc.City,
    SUM(fs.TotalAmount) AS CitySales,
    COUNT(fs.SalesKey)  AS NumberOfTransactions
FROM FactSales fs
JOIN DimCustomer dc
    ON fs.CustomerKey = dc.CustomerKey
GROUP BY dc.City
ORDER BY CitySales DESC;

-- Query 5: Best-Selling Products by Quantity Sold
--   Business use: Determine which products to restock or promote.
SELECT
    dp.ProductName,
    dp.Category,
    SUM(fs.Quantity)    AS TotalQuantitySold,
    SUM(fs.TotalAmount) AS TotalRevenue
FROM FactSales fs
JOIN DimProduct dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY
    dp.ProductKey,
    dp.ProductName,
    dp.Category
ORDER BY TotalQuantitySold DESC;

-- =========================================
-- SECTION 10: BUSINESS INSIGHT
-- =========================================
-- INSIGHT: Electronics is the top-performing category by both
-- units sold and total revenue, driven largely by repeat purchases
-- of the Mechanical Keyboard and Gaming Mouse. Cagayan de Oro
-- generates the highest city-level sales. Recommendation: Prioritize
-- restocking Electronics items and launch a targeted promotion for
-- customers in Cagayan de Oro to further increase revenue.
-- =========================================

COMMIT;
