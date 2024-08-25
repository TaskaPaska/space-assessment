-- The following script includes queries for analysis.
USE greenplum
GO
-- 1. Calculating the total sales amount and the total number of transactions for each month.

-- Storing the data into a temporary table, because both queries need similar logic.

-- Optionally, temporary table could be dropped in case it exists, for script reusability.
-- IF OBJECT_ID('tempdb..#monthly_total_sales') IS NOT NULL
-- BEGIN
--    DROP TABLE #monthly_total_sales;
--END

SELECT MONTH(st.purchase_date) + ' ' + YEAR(st.purchase_date) AS [date], -- Year and month
	   SUM(st.quantity * p.price) AS sales_amount, -- Total sales amount is calculated as a sum of: price of a single item * quantity of the item
	   COUNT(st.sales_transaction_id) AS number_of_transactions
INTO #monthly_total_sales 
FROM dbo.sales_transactions st
JOIN dbo.products p 
	ON st.product_id = p.product_id
GROUP BY MONTH(st.purchase_date) + ' ' + YEAR(st.purchase_date) -- Data is aggregated by year and month
ORDER BY [date]

-- Results for the first query:
SELECT *
FROM #monthly_total_sales



-- 2. Calculating the 3-month moving average of sales amount for each month, results for the 2-nd query:
SELECT [date],
	   AVG(sales_amount) OVER (ORDER BY [date] ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average_3_months
FROM #monthly_total_sales 

