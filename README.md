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

### Source Tables
- customers
- products
- orders
- orderitems

### Dimension Tables
- dimcustomer
- dimproduct
- dimtime

### Fact Table
- factsales

## Analytics Query Example
The project supports reporting queries such as:
- Total Sales per Product
- Sales by Category
- Monthly Sales Reports

## Setup Instructions
1. Open XAMPP
2. Start Apache and MySQL
3. Open phpMyAdmin
4. Create database: `online_store_dw`
5. Import `setup.sql`

## Project Screenshots
See `/screenshots`

## Architecture Diagram
See `/diagrams`
