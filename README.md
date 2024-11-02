# MySQL_Project ![image](https://github.com/user-attachments/assets/037eaeca-bc59-4be5-8f90-a009f3125fe3)

This project showcases my proficiency in data cleaning and exploratory data analysis (EDA) using MySQL.

## Analyzing Coffee Sales
[index.csv][coffee_sales.sql]
## Project Description
This project creates a table for coffee sales data, loads data from a CSV file, and performs various analyses. It includes checks for duplicate records, data standardization, and exploratory data analysis using functions like SUM, COUNT, and window functions with OVER. Additionally, it categorizes customers into spending tiers based on their total purchases.

## Task Performed
### Table Creation: 
  - A table named `coffee_sales` is created with the following columns:
    - `date`: Date of the transaction.
    - `datetime`: Date and time of the transaction.
    - `payment_type`: Method of payment (cash or card).
    - `card_number`: Card number used for payment.
    - `amount_paid`: Total amount paid.
    - `coffee_purchased`: Type of coffee purchased.

### Data Loading: 
  - **Data Import**: Data is loaded from a CSV file named `index.csv`, with fields separated by commas.

### Data Integrity Checks
  - **Duplicate Records**: The script checks for duplicates in the sales records using `GROUP BY` and `Common Table Expressions (CTEs)`, confirming that no duplicates exist.
  - **Data Standardization**:
    - The date and datetime columns are converted from strings to their respective         date and time formats.
    - Empty strings in the card_number column are replaced with NULL values to             handle potential data integrity issues.

### Exploratory Data Analysis (EDA)
  - **Basic Analysis**:
    - Unique types of coffee sold are identified.
    - The earliest and latest sales records are retrieved.
    - Daily total sales are calculated, highlighting the top 10 sales days.
      
  - **Revenue Analysis**: Total revenue is calculated based on different types of coffee sold.
    
  - **Customer Spending Analysis**: The top 10 spenders using card payments are identified based on transaction counts and total spent using `'COUNT'`, `ORDER BY`, `GROUP BY` and `HAVING` statements.
    
  - **Popularity Ranking**: A ranking of coffee types based on the number of cups sold is generated using WINDOW functions using `RANK` and `OVER` statements.
    
  - **Price Comparison**:
    - Analyzes prices for coffee purchased with cash versus card payments, providing insights into minimum, maximum, and average prices for each payment type
    - Combines results from CTEs to compare prices based on payment methods using `JOIN` method.
      
  - **Transaction Milestones**:
    - The earliest date on which a customer reaches ten transactions is determined.
    - The earliest date for customers who spend at least $1000 is also identified by analyzing rolling total calculation using `SUM()` function with the `OVER` and `PARTITION BY` clause.
      
  - **Customer Tier Categorization**
    - Customers are categorized into tiers based on their total spending by using `CASE` statement:
      - Tier 1 for spending over $1500,
      - Tier 2 for spending between $1000 and $1500,
      - Tier 3 for spending between $500 and $1000,
      - Tier 4 for lower spending.

## Summary of Key Functions
| Function	  | Purpose     |
| ----------- | ------------- |
|CREATE TABLE	| Define the structure of a new table|
|LOAD DATA INFILE| Import data from an external file|
|GROUP BY	| Aggregate records based on specified columns|
|HAVING	| Filter aggregated results|
|STR_TO_DATE | Convert string to date/datetime format|
|UPDATE	| Modify existing records|
|DISTINCT	| Retrieve unique values|
|MIN, MAX, etc.	| Perform aggregate calculations|
|RANK() OVER	| Rank results within partitioned data|
|CASE	| Conditional logic for categorization|
|JOIN	| Combine rows from two or more tables|
