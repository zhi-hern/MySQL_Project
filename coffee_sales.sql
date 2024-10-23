-- Creating table WITH column name
CREATE TABLE coffee_sales 
(`date` varchar(50),
`datetime` varchar(50),
payment_type varchar(50),
card_number varchar(50),
amount_paid double,
coffee_purchased varchar(50)
);

-- Load data
LOAD DATA INFILE 'index.csv' INTO TABLE coffee_sales
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

-- View all datas
SELECT *
FROM coffee_sales;

-- PART I: DATA INTEGRITY CHECK
-- 1. Check for any duplicates using GROUP BY and HAVING functions
SELECT `datetime`, COUNT(*)
FROM coffee_sales
GROUP BY `datetime`
HAVING COUNT(*) > 1;

-- or CTE
WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `date`, `datetime`, payment_type, card_number, amount_paid, coffee_purchased) AS duplicate_count
FROM coffee_sales
)
SELECT *
FROM duplicate_cte
WHERE duplicate_count > 1; 

-- Conclusion: No duplicates was found

-- 2. Standardizing data
-- 2(a) Converting date column from string to date 
SELECT `date`,
STR_TO_DATE(`date`,'%Y-%m-%d')
FROM coffee_sales;

UPDATE coffee_sales
SET `date` = STR_TO_DATE(`date`,'%Y-%m-%d');

ALTER TABLE coffee_sales
MODIFY COLUMN `date` DATE;

-- 2(b) Converting datetime column from string to datetime 
SELECT `datetime`,
STR_TO_DATE(`datetime`,'%Y-%m-%d %H:%i:%s')
FROM coffee_sales;

UPDATE coffee_sales
SET `datetime` = STR_TO_DATE(`datetime`,'%Y-%m-%d %H:%i:%s');

ALTER TABLE coffee_sales
MODIFY COLUMN `datetime` DATETIME;

-- 2(c) Convert datetime column to time column
SELECT `datetime`, TIME(`datetime`) AS time_trans
FROM coffee_sales;

UPDATE coffee_sales
SET `datetime` = TIME(`datetime`);

ALTER TABLE coffee_sales
MODIFY COLUMN `datetime` TIME;

ALTER TABLE coffee_sales
RENAME COLUMN `datetime` to `time_trans`;

-- Conclusion : Convert strings to date and time data types

-- 3. Look at null values 
SELECT *
FROM coffee_sales
WHERE `date` IS NULL OR time_trans IS NULL OR payment_type IS NULL OR 
card_number IS NULL OR amount_paid IS NULL OR coffee_purchased IS NULL;

-- unable to identify null values even though some of the rows in card_number column have no data

-- use NULLIF to replace empty strings with null 
UPDATE coffee_sales
SET card_number = NULLIF(card_number, '')
WHERE card_number = '';

-- run the query to find null values again
SELECT *
FROM coffee_sales
WHERE `date` IS NULL OR time_trans IS NULL OR payment_type IS NULL OR 
card_number IS NULL OR amount_paid IS NULL OR coffee_purchased IS NULL;

-- Conclusion: Payment BY cash leads to null values for card_number

-- PART II: EXPLORATORY DATA ANALYSIS

-- 1. Using DISTINCT, MIN, MAX, AVG, SUM, COUNT, GROUP BY, ORDER BY for analysis

-- Types of coffee sold BY the store
SELECT DISTINCT coffee_purchased
FROM coffee_sales;

-- Earliest sales record and latest sales record
SELECT MIN(`date`), MAX(`date`)
FROM coffee_sales;

-- Earliest sales transaction and latest sales transaction
SELECT MIN(time_trans), MAX(time_trans)
FROM coffee_sales;

-- Top 10 sales per day
SELECT `date`, ROUND(SUM(amount_paid),2) AS total_sales
FROM coffee_sales
GROUP BY `date` 
ORDER BY 2 desc
LIMIT 10;

-- Total revenue bASed on types of coffee
SELECT coffee_purchased, ROUND(SUM(amount_paid),2) AS total_revenue
FROM coffee_sales
GROUP BY coffee_purchased
ORDER BY 2 DESC;

-- Top 10 spenders using card payment
SELECT card_number, COUNT(*) AS no_of_trans, ROUND(SUM(amount_paid),2) AS total_spent
FROM coffee_sales
WHERE card_number IS NOT NULL
GROUP BY card_number
HAVING no_of_trans > 10  
ORDER BY total_spent DESC
LIMIT 10;

-- 2.Using CTEs, JOINS, WINDOWS function and CASE statement

-- Popularity (Ranking based on cup sold)
WITH cte_top_sold AS
(
SELECT coffee_purchased, COUNT(*) AS cup_sold
FROM coffee_sales
GROUP BY coffee_purchased
ORDER BY 2 desc
)
SELECT *,
RANK()OVER(ORDER BY cup_sold DESC) AS popularity_ranking
FROM cte_top_sold;

-- Prices based on the types of coffee if customer paid by cash (cte_cash)
SELECT coffee_purchased, MIN(amount_paid) AS min_price, MAX(amount_paid) AS max_price, ROUND(AVG(amount_paid),2) AS average_price
FROM coffee_sales
WHERE card_number is null
GROUP BY coffee_purchased;

-- Prices based on the types of coffee if customer paid by card (cte_card)
SELECT coffee_purchased, MIN(amount_paid) AS min_price, MAX(amount_paid) AS max_price, ROUND(AVG(amount_paid),2) AS average_price
FROM coffee_sales
WHERE card_number IS NOT NULL
GROUP BY coffee_purchased;

-- Use join and ctes to compare prices paid BY card and cash
WITH cte_cash AS
(
SELECT coffee_purchased, MIN(amount_paid) AS min_price_cash, MAX(amount_paid) AS max_price_cash, ROUND(AVG(amount_paid),2) AS average_price_cash
FROM coffee_sales
WHERE card_number is null
GROUP BY coffee_purchased
),

cte_card AS
(
SELECT coffee_purchased, MIN(amount_paid) AS min_price_card, MAX(amount_paid) AS max_price_card, ROUND(AVG(amount_paid),2) AS average_price_card
FROM coffee_sales
WHERE card_number IS NOT NULL
GROUP BY coffee_purchased
)

SELECT *
FROM cte_cash
join cte_card
	on cte_cash.coffee_purchased = cte_card.coffee_purchased
ORDER BY cte_card.average_price_card;

-- Earliest to achieve 10 transactions 
WITH cte_no_of_trans AS
(
SELECT *,
ROW_NUMBER() OVER(partition BY payment_type, card_number) AS no_of_trans
FROM coffee_sales
WHERE payment_type = 'card'
)
SELECT `date`, card_number, no_of_trans
FROM cte_no_of_trans
WHERE no_of_trans = 10
ORDER BY `date` ASC;

-- Earliest to spend $1000 
WITH cte_rolling_total_spend AS
(
SELECT `date`, `time_trans`, card_number, amount_paid,
ROUND(sum(amount_paid) OVER(partition BY card_number ORDER BY `date`,`time_trans`),2) AS rolling_total_spend
FROM coffee_sales
WHERE card_number IS NOT NULL
)
SELECT MIN(`date`) AS date_reach_500, card_number, MIN(rolling_total_spend) AS total_spend
FROM cte_rolling_total_spend
WHERE rolling_total_spend >= 1000 
GROUP BY card_number
ORDER BY date_reach_500;

SELECT card_number,ROUND(sum(amount_paid),2) AS total_spend
FROM coffee_sales
WHERE card_number IS NOT NULL
GROUP BY card_number;

-- Categorize member tier based on total amount spent
WITH cte_total_spend AS
( 
SELECT card_number,ROUND(sum(amount_paid),2) AS total_spend
FROM coffee_sales
WHERE card_number IS NOT NULL
GROUP BY card_number
)
SELECT *, 
CASE
	WHEN total_spend >=500 and total_spend < 1000 then 'Tier 3'
	WHEN total_spend >=1000 and total_spend < 1500 then 'Tier 2'
	WHEN total_spend >=1500 then 'Tier 1'
	ELSE 'Tier 4'
END AS member_tier
FROM cte_total_spend;


 


