-- Walmart Project SQL Queries --------------------------------------------------------------------------------
USE walmart_db;

select * from walmart;
 
-- total number of rows in table
SELECT count(*) FROM walmart;

-- Number of transactions by payment method

SELECT payment_method , count(*)
FROM walmart
GROUP BY payment_method;

-- Distinct branch count
SELECT COUNT(DISTINCT branch)
FROM walmart;

-- Minimum quality sold
SELECT MIN(quantity) FROM walmart;

-- -----------------------------------------------------------------------------------------------------------------------------------

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method

SELECT payment_method , count(*) as no_payment , SUM(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

SELECT branch , category , avg_rating
FROM(
  SELECT branch, category , AVG(rating) as avg_rating ,
  RANK() over (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranks
  FROM walmart
  GROUP BY branch,category
 ) as ranked
 where ranks=1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch , day_name , no_transactions
FROM(
     SELECT 
     branch,
     dayname(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
     count(*) as no_transactions,
	 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranks
     from walmart
     GROUP BY branch , day_name
     ) AS ranked
 WHERE ranks =1;
 
 -- Q4: Calculate the total quantity of items sold per payment method
SELECT payment_method, sum(quantity)
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

SELECT city , category ,
	 MIN(rating), MAX(rating),AVG(rating)
FROM walmart
GROUP BY city,category;

-- Q6: Calculate the total profit for each category

SELECT category , sum(total * profit_margin) as profit
FROM walmart
GROUP BY category
ORDER BY profit DESC;

-- Q7: Determine the most common payment method for each branch

SELECT branch , payment_method 
FROM(
  SELECT branch, payment_method ,
  RANK() over (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranks
  FROM walmart
  GROUP BY branch,payment_method
 ) as ranked
 where ranks=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT 
	branch,
    CASE 
		WHEN HOUR(TIME(time)) <12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END as shifts,
    count(*) as num_invoices
FROM walmart
GROUP BY branch,shifts
ORDER BY branch , num_invoices desc;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue2022 AS (
		SELECT branch , 
			SUM(total) as revenue
		FROM walmart
        WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
        GROUP BY branch
),
revenue2023 AS (
		SELECT branch , 
			SUM(total) as revenue
		FROM walmart
        WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
        GROUP BY branch
)

SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue2022 AS r2022
JOIN revenue2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

-- Q10: Average rating per payment method
-- checks average rating for each payment method
SELECT 
    payment_method, 
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY payment_method
ORDER BY avg_rating DESC;

-- Q 11: Correlation Between Rating and Profit Margin
-- Check if higher ratings correlate with higher profit margins by grouping ratings into ranges
SELECT 
	CASE 
		WHEN rating< 4 THEN 'Poor'
        WHEN rating BETWEEN 4 AND 6 THEN 'Bad'
        WHEN rating BETWEEN 7 AND 8 THEN 'Good'
        ELSE 'Excellent'
	END as ranking_category,
    ROUND(AVG(profit_margin),2) as avg_profit_margin
 FROM walmart
 GROUP BY ranking_category
 ORDER BY avg_profit_margin DESC;
    
        
























