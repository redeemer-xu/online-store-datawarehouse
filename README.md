# Online Store Sales Data Warehouse

## Project Overview
This project demonstrates a beginner-friendly ETL and Data Warehouse implementation using MySQL and phpMyAdmin.

## Architecture
- ETL Process
- Medallion Architecture
- Star Schema

## Technologies Used
- MySQL
- phpMyAdmin
- XAMPP
- GitHub
- draw.io
- Notion

## Database Structure
### OLTP Tables
- Customers
- Products
- Orders
- OrderItems

### Data Warehouse Tables
- DimCustomer
- DimProduct
- DimTime
- FactSales

## ETL Process
- Extract data from OLTP tables
- Transform and clean data
- Load data into Star Schema tables

## Validation Queries
- Row count validation
- Duplicate validation
- Missing dimension validation
- Amount validation

## Analytical Queries
- Total Sales per Month
- Top Customers
- Sales by Category
- Sales by City
- Best-Selling Products

## Repository Structure
```text
online-store-datawarehouse/
│
├── setup.sql
├── diagrams/
├── screenshots/
└── README.md
