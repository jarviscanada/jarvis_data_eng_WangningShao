-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
SELECT COUNT(*) FROM retail;

-- number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT(customer_id)) FROM retail;

-- invoice date range
SELECT 
	MAX(invoice_date) as max,
	MIN(invoice_date ) as min
FROM retail;

-- number of SKU/merchants
SELECT COUNT(distinct (stock_code)) FROM retail;

-- average invoice amount excluding invoices with a negative amount
SELECT AVG(invoice_total) AS avg
FROM (
    SELECT 
        invoice_no, 
        SUM(quantity * unit_price) AS invoice_total
    FROM retail
    GROUP BY invoice_no
    HAVING SUM(quantity * unit_price) > 0
);

--Calculate total revenue
SELECT 
	SUM(quantity * unit_price) AS sum 
FROM retail;

-- Calculate total revenue by YYYYMM 
-- In PostgreSQL EXTRACT will return numeric rather than an integer
SELECT 
    CAST(EXTRACT(YEAR FROM invoice_date) * 100 + EXTRACT(MONTH FROM invoice_date) AS INT) AS yyyymm,
    SUM(quantity * unit_price) AS sum
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;