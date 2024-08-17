-- Create table
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct NUMERIC(6,4) NOT NULL,
    total NUMERIC(12,4) NOT NULL,
    date TIMESTAMP NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs NUMERIC(10,2) NOT NULL,
    gross_margin_pct NUMERIC(11,9),
    gross_income NUMERIC(12,4),
    rating NUMERIC(2,1)
);
ALTER TABLE sales
ALTER COLUMN rating TYPE NUMERIC;

copy sales FROM 'D:/Backup data/C drive/Downloads/WalmartSalesData.csv.csv' DELIMITER ',' CSV HEADER ENCODING 'WIN1252';
Select * from Sales;


--1.How many unique product lines does the data have?
Select distinct product_line from Sales;

--2.What is the most common payment method?
Select payment, sum(gross_income) as Gross_Income from Sales
group by payment order by Gross_Income desc;

--3.What is the most selling product line?
Select product_line, sum(gross_income) as Gross_Income from Sales
group by product_line order by Gross_Income desc;

--4.What is the total revenue by month?
SELECT 
    EXTRACT(MONTH FROM date) AS Month, 
    sum(gross_income) as Gross_Revenue from Sales
group by Month order by Gross_Revenue desc

--5.What month had the largest COGS?
SELECT 
    EXTRACT(MONTH FROM date) AS Month, 
sum(cogs) as COGS from Sales
group by Month order by COGS desc limit 1;

--6.What product line had the largest revenue?
Select product_line, sum(gross_income) as Total_Revenue from Sales
group by product_line order by Total_Revenue desc limit 1;

--7.What is the city with the largest revenue?
Select city, sum(gross_income) as Total_Revenue from Sales
group by city order by Total_Revenue desc;

--8.What product line had the largest VAT?
Select product_line, sum(tax_pct) as VAT from Sales
group by product_line order by VAT desc limit 1;

--9.Fetch each product line and add a column to those product line showing "Good", "Bad".
--Good if its greater than average sales


WITH AverageSales AS (
    SELECT product_line, AVG(gross_income) AS avg_gross_income
    FROM Sales
    GROUP BY product_line
)
SELECT 
    s.product_line, 
    s.gross_income,
    CASE 
        WHEN s.gross_income > a.avg_gross_income THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM 
    Sales s
JOIN 
    AverageSales a ON s.product_line = a.product_line;

--10.Which branch sold more products than average product sold?
WITH AverageSold AS (
    SELECT branch, AVG(quantity) AS avg_products_sold
    FROM Sales
    GROUP BY branch
)
SELECT 
    s.branch,
    SUM(s.quantity) AS total_products_sold
FROM 
    Sales s
GROUP BY 
    s.branch
HAVING 
    SUM(s.quantity) > (SELECT avg_products_sold FROM AverageSold WHERE branch = s.branch);

--11.What is the most common product line by gender?
Select Gender, product_line, sum(gross_income) as Gross_income from Sales
group by product_line, gender order by Gross_Income desc limit 2;

SELECT 
    gender, 
    product_line, 
    COUNT(*) AS product_line_count
FROM 
    Sales
GROUP BY 
    gender, 
    product_line
ORDER BY 
    product_line_count desc 

--12.What is the average rating of each product line?
Select product_line, avg(Rating) as Average_Rating from Sales
group by product_line order by Average_Rating desc

--13.Number of sales made in each time of the day per weekday 
SELECT 
    EXTRACT(HOUR FROM time) AS Hour, 
    sum(gross_income) as Gross_Revenue from Sales
group by Hour order by Gross_Revenue desc

--14.Which of the customer types brings the most revenue?
Select customer_type, sum(gross_income) as Gross_Revenue from Sales
group by Customer_type order by Gross_Revenue desc

--15.Which city has the largest tax/VAT percent?
Select city, round(AVG(tax_pct),2)AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

--16. Which customer type pays the most in VAT?
Select customer_type,round(AVG(tax_pct),2)AS avg_tax_pct
FROM sales
GROUP BY customer_type 
ORDER BY avg_tax_pct DESC;