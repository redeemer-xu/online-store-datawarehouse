-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: May 10, 2026 at 11:15 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `online_store_dw`
--

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL,
  `CustomerName` varchar(100) NOT NULL,
  `City` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`CustomerID`, `CustomerName`, `City`, `Email`, `CreatedAt`) VALUES
(1, 'John Cruz', 'Cagayan de Oro', 'john@gmail.com', '2026-05-10 08:30:36'),
(2, 'Maria Santos', 'Iligan City', 'maria@gmail.com', '2026-05-10 08:30:36'),
(3, 'Kevin Reyes', 'Malaybalay', 'kevin@gmail.com', '2026-05-10 08:30:36');

-- --------------------------------------------------------

--
-- Table structure for table `dimcustomer`
--

CREATE TABLE `dimcustomer` (
  `CustomerKey` int(11) NOT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `CustomerName` varchar(100) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dimcustomer`
--

INSERT INTO `dimcustomer` (`CustomerKey`, `CustomerID`, `CustomerName`, `City`) VALUES
(1, 1, 'John Cruz', 'Cagayan de Oro'),
(2, 2, 'Maria Santos', 'Iligan City'),
(3, 3, 'Kevin Reyes', 'Malaybalay');

-- --------------------------------------------------------

--
-- Table structure for table `dimproduct`
--

CREATE TABLE `dimproduct` (
  `ProductKey` int(11) NOT NULL,
  `ProductID` int(11) DEFAULT NULL,
  `ProductName` varchar(100) DEFAULT NULL,
  `Category` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dimproduct`
--

INSERT INTO `dimproduct` (`ProductKey`, `ProductID`, `ProductName`, `Category`) VALUES
(1, 1, 'Mechanical Keyboard', 'Electronics'),
(2, 2, 'Gaming Mouse', 'Electronics'),
(3, 3, 'Office Chair', 'Furniture');

-- --------------------------------------------------------

--
-- Table structure for table `dimtime`
--

CREATE TABLE `dimtime` (
  `TimeKey` int(11) NOT NULL,
  `FullDate` date DEFAULT NULL,
  `MonthName` varchar(20) DEFAULT NULL,
  `Year` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dimtime`
--

INSERT INTO `dimtime` (`TimeKey`, `FullDate`, `MonthName`, `Year`) VALUES
(1, '2026-05-01', 'May', 2026),
(2, '2026-05-02', 'May', 2026),
(3, '2026-05-03', 'May', 2026);

-- --------------------------------------------------------

--
-- Table structure for table `factsales`
--

CREATE TABLE `factsales` (
  `SalesKey` int(11) NOT NULL,
  `CustomerKey` int(11) DEFAULT NULL,
  `ProductKey` int(11) DEFAULT NULL,
  `TimeKey` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  `TotalAmount` decimal(10,2) DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `factsales`
--

INSERT INTO `factsales` (`SalesKey`, `CustomerKey`, `ProductKey`, `TimeKey`, `Quantity`, `UnitPrice`, `TotalAmount`, `CreatedAt`) VALUES
(1, 1, 1, 1, 1, 2500.00, 2500.00, '2026-05-10 08:30:36'),
(2, 3, 1, 3, 1, 2500.00, 2500.00, '2026-05-10 08:30:36'),
(3, 1, 2, 1, 2, 1200.00, 2400.00, '2026-05-10 08:30:36'),
(4, 3, 2, 3, 1, 1200.00, 1200.00, '2026-05-10 08:30:36'),
(5, 2, 3, 2, 1, 4500.00, 4500.00, '2026-05-10 08:30:36');

-- --------------------------------------------------------

--
-- Table structure for table `orderitems`
--

CREATE TABLE `orderitems` (
  `OrderItemID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  `TotalAmount` decimal(10,2) DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderitems`
--

INSERT INTO `orderitems` (`OrderItemID`, `OrderID`, `ProductID`, `Quantity`, `UnitPrice`, `TotalAmount`, `CreatedAt`) VALUES
(1, 1, 1, 1, 2500.00, 2500.00, '2026-05-10 08:30:36'),
(2, 1, 2, 2, 1200.00, 2400.00, '2026-05-10 08:30:36'),
(3, 2, 3, 1, 4500.00, 4500.00, '2026-05-10 08:30:36'),
(4, 3, 1, 1, 2500.00, 2500.00, '2026-05-10 08:30:36'),
(5, 3, 2, 1, 1200.00, 1200.00, '2026-05-10 08:30:36');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  `OrderDate` date DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`OrderID`, `CustomerID`, `OrderDate`, `CreatedAt`) VALUES
(1, 1, '2026-05-01', '2026-05-10 08:30:36'),
(2, 2, '2026-05-02', '2026-05-10 08:30:36'),
(3, 3, '2026-05-03', '2026-05-10 08:30:36');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `ProductID` int(11) NOT NULL,
  `ProductName` varchar(100) NOT NULL,
  `Category` varchar(100) DEFAULT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`ProductID`, `ProductName`, `Category`, `UnitPrice`, `CreatedAt`) VALUES
(1, 'Mechanical Keyboard', 'Electronics', 2500.00, '2026-05-10 08:30:36'),
(2, 'Gaming Mouse', 'Electronics', 1200.00, '2026-05-10 08:30:36'),
(3, 'Office Chair', 'Furniture', 4500.00, '2026-05-10 08:30:36');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`CustomerID`),
  ADD KEY `idx_customer_city` (`City`);

--
-- Indexes for table `dimcustomer`
--
ALTER TABLE `dimcustomer`
  ADD PRIMARY KEY (`CustomerKey`);

--
-- Indexes for table `dimproduct`
--
ALTER TABLE `dimproduct`
  ADD PRIMARY KEY (`ProductKey`);

--
-- Indexes for table `dimtime`
--
ALTER TABLE `dimtime`
  ADD PRIMARY KEY (`TimeKey`);

--
-- Indexes for table `factsales`
--
ALTER TABLE `factsales`
  ADD PRIMARY KEY (`SalesKey`),
  ADD KEY `CustomerKey` (`CustomerKey`),
  ADD KEY `ProductKey` (`ProductKey`),
  ADD KEY `TimeKey` (`TimeKey`);

--
-- Indexes for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD PRIMARY KEY (`OrderItemID`),
  ADD KEY `idx_orderitems_orderid` (`OrderID`),
  ADD KEY `idx_orderitems_productid` (`ProductID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`OrderID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `idx_order_date` (`OrderDate`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `idx_product_category` (`Category`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `dimcustomer`
--
ALTER TABLE `dimcustomer`
  MODIFY `CustomerKey` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `dimproduct`
--
ALTER TABLE `dimproduct`
  MODIFY `ProductKey` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `dimtime`
--
ALTER TABLE `dimtime`
  MODIFY `TimeKey` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `factsales`
--
ALTER TABLE `factsales`
  MODIFY `SalesKey` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `OrderItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `factsales`
--
ALTER TABLE `factsales`
  ADD CONSTRAINT `factsales_ibfk_1` FOREIGN KEY (`CustomerKey`) REFERENCES `dimcustomer` (`CustomerKey`),
  ADD CONSTRAINT `factsales_ibfk_2` FOREIGN KEY (`ProductKey`) REFERENCES `dimproduct` (`ProductKey`),
  ADD CONSTRAINT `factsales_ibfk_3` FOREIGN KEY (`TimeKey`) REFERENCES `dimtime` (`TimeKey`);

--
-- Constraints for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`),
  ADD CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
