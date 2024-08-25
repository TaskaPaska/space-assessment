-- The following script creates tables for the Greenplum database as described in the assessment doc.

USE MASTER
GO
-- Before creating the objects, optionally, they could be dropped if they exist.
-- Its so that the code can be modified and re-run more easily without errors.


-- Creating the database.

--IF DB_ID('greenplum') IS NOT NULL
--BEGIN
--	-- Existing connections to the database are stopped.
--	ALTER DATABASE greenplum SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--    DROP DATABASE greenplum;
--END;
CREATE DATABASE greenplum
GO
USE greenplum
GO


-- Creating the tables.



-- Customers table

--IF OBJECT_ID('dbo.customers', 'U') IS NOT NULL
--BEGIN
--    DROP TABLE dbo.customers;
--END;
CREATE TABLE dbo.customers (
	customer_id INT PRIMARY KEY IDENTITY(1,1),
	customer_name NVARCHAR(100) NOT NULL, -- Name is mandatory
	email_address NVARCHAR(255) NOT NULL UNIQUE, -- No two users should have the same email address, also a mandatory field.
	country NVARCHAR(100),
	phone_number VARCHAR(20) UNIQUE -- No two users should have the same phone number
);



-- Products table

--IF OBJECT_ID('dbo.products', 'U') IS NOT NULL
--BEGIN
--    DROP TABLE dbo.products;
--END;
CREATE TABLE dbo.products (
	product_id INT PRIMARY KEY IDENTITY(1,1),
	product_name NVARCHAR(100) NOT NULL, -- All products should have a name
	price DECIMAL(10, 2) CHECK (price >= 0), -- A price can not be negative
	product_category NVARCHAR(100),
	[description] NVARCHAR(255),
);



-- Sales Transactions table

--IF OBJECT_ID('dbo.sales_transactions', 'U') IS NOT NULL
--BEGIN
--    DROP TABLE dbo.sales_transactions;
--END;
CREATE TABLE dbo.sales_transactions (
	sales_transaction_id INT PRIMARY KEY IDENTITY (1,1),
	customer_id INT NOT NULL FOREIGN KEY REFERENCES greenplum.dbo.customers(customer_id), -- All transactions are made my a customer
	product_id INT NOT NULL FOREIGN KEY REFERENCES greenplum.dbo.products(product_id), -- All transactions include a signle product
	purchase_date DATE NOT NULL DEFAULT GETDATE(), -- When a transaction is created, the date could be the current one by default.
	quantity INT CHECK (quantity > 0) -- Quantity can not be negative
);



-- Shipping Details table

--IF OBJECT_ID('dbo.shipping_details', 'U') IS NOT NULL
--BEGIN
--    DROP TABLE dbo.shipping_details;
--END;
CREATE TABLE dbo.shipping_details (
	shipping_detail_id INT PRIMARY KEY IDENTITY(1,1),
	transaction_id INT NOT NULL FOREIGN KEY REFERENCES greenplum.dbo.sales_transactions(sales_transaction_id),
	shipping_date DATE,
	shipping_address NVARCHAR(100) NOT NULL, -- Specifying the address is mandatory
	city NVARCHAR(100),
	country NVARCHAR(100)
);
