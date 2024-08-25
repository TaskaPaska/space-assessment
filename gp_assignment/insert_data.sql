-- The following script inserts sample data into each table
USE greenplum
GO

-- To maintain referential integrity and avoid hardcoding IDs, in some tables
-- IDs are selected according to values that were already inserted before (in other tables)

INSERT INTO dbo.customers (customer_name, email_address, country, phone_number)
VALUES ('Nick Smith', 'nick.smith@gmail.com', 'Spain', '551778327'),
	   ('Anna Joy', 'annaj89@gmail.com', 'Italy', '91827384'),
	   ('George Lee', 'glee892@gmail.com', NULL, '445332678'),
	   ('Mike Snow', 'mikemike@gmail.com', 'Italy', '23452342');


INSERT INTO dbo.products (product_name, price, product_category, [description])
VALUES ('Earbuds', 100.99, 'Electronics', NULL),
	   ('Bottle', 3, 'Household Items', 'Reuseable glass bottle'),
	   ('Vintage Chair', 60.5, 'Furniture', 'Vitage-looking large chair'),
	   ('Lipstick', 10, 'Makeup', NULL),
	   ('Floor Lamp', 84.99, 'Furniture', NULL),
	   ('Power Bank', 110.39, 'Electronics', NULL);


-- Customer and product IDs are inserted in sales_transactions based on data that has been inserted already (in other tables)
INSERT INTO dbo.sales_transactions (customer_id, product_id, purchase_date, quantity)
VALUES ((SELECT customer_id FROM dbo.customers WHERE customer_name = 'George Lee'), 
        (SELECT product_id FROM dbo.products WHERE product_name = 'Floor Lamp'),
        '2024-08-23', 
        1),
       ((SELECT customer_id FROM dbo.customers WHERE customer_name = 'Anna Joy'), 
        (SELECT product_id FROM dbo.products WHERE product_name = 'Bottle'),
        '2024-07-26', 
        4),
       ((SELECT customer_id FROM dbo.customers WHERE customer_name = 'Anna Joy'), 
        (SELECT product_id FROM dbo.products WHERE product_name = 'Power Bank'),
        '2024-06-01', 
        5),
	   ((SELECT customer_id FROM dbo.customers WHERE customer_name = 'Mike Snow'), 
        (SELECT product_id FROM dbo.products WHERE product_name = 'Floor Lamp'),
        '2024-07-13', 
        2),
	   ((SELECT customer_id FROM dbo.customers WHERE customer_name = 'George Lee'), 
        (SELECT product_id FROM dbo.products WHERE product_name = 'Vintage Chair'),
        '2024-08-03', 
        3);


-- Transaction IDs are inserted in shipping_details according to records that have been inserted already
INSERT INTO dbo.shipping_details (transaction_id, shipping_date, shipping_address, city, country)
VALUES ((SELECT sales_transaction_id FROM dbo.sales_transactions WHERE customer_id = (SELECT customer_id FROM dbo.customers WHERE customer_name = 'George Lee') 
	                                                                            AND product_id = (SELECT product_id FROM dbo.products WHERE product_name = 'Floor Lamp')
	                                                                            AND purchase_date = '2024-08-23'), 
	     '2024-08-24', 
	     '123 Station St', 
	     'Tbilisi', 
	     'Georgia'),
	    ((SELECT sales_transaction_id FROM dbo.sales_transactions WHERE customer_id = (SELECT customer_id FROM dbo.customers WHERE customer_name = 'Anna Joy') 
	                                                                            AND product_id = (SELECT product_id FROM dbo.products WHERE product_name = 'Bottle')
	                                                                            AND purchase_date = '2024-07-26'),
	     '2024-07-27', 
	     '456 Liberty Street', 
	     'Rome', 
	     'Italy'),
	    ((SELECT sales_transaction_id FROM dbo.sales_transactions WHERE customer_id = (SELECT customer_id FROM dbo.customers WHERE customer_name = 'Anna Joy') 
	                                                                            AND product_id = (SELECT product_id FROM dbo.products WHERE product_name = 'Power Bank')
	                                                                            AND purchase_date = '2024-06-01'),
	     '2024-06-02', 
	     '789 Left Street', 
	     'Rome', 
	     'Italy'),
	    ((SELECT sales_transaction_id FROM dbo.sales_transactions WHERE customer_id = (SELECT customer_id FROM dbo.customers WHERE customer_name = 'Mike Snow') 
	                                                                            AND product_id = (SELECT product_id FROM dbo.products WHERE product_name = 'Floor Lamp')
	                                                                            AND purchase_date = '2024-07-13'),
	     '2024-07-14', 
	     '321 Central Street', 
	     'Milan', 
	     'Italy'),
	    ((SELECT sales_transaction_id FROM dbo.sales_transactions WHERE customer_id = (SELECT customer_id FROM dbo.customers WHERE customer_name = 'George Lee') 
	                                                                            AND product_id = (SELECT product_id FROM dbo.products WHERE product_name = 'Vintage Chair')
	                                                                            AND purchase_date = '2024-08-03'),
	     '2024-08-04', 
	     '654 Maple St', 
	     'Tbilisi', 
	     'Georgia');
