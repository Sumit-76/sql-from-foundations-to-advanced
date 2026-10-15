-- Q1 Display each order's order_id, created_at, and order year.
SELECT ORDER_ID,CREATED_AT,EXTRACT(YEAR FROM CREATED_AT)AS ORDER_YEAR
FROM ORDERS;
-- Q2 Display each order's order_id, created_at, and order month number.
SELECT ORDER_ID,CREATED_AT,EXTRACT(MONTH FROM CREATED_AT)AS ORDER_MONTH
FROM ORDERS;
-- Q3 Find the earliest order date.
SELECT CREATED_AT
FROM ORDERS 
ORDER BY CREATED_AT 
LIMIT 1;
-- Q4 Find the latest order date.
SELECT CREATED_AT
FROM ORDERS
ORDER BY CREATED_AT DESC 
LIMIT 1;
-- Q5 Count the number of orders for each year.
SELECT DATE_TRUNC('YEAR',CREATED_AT)AS ORDERS_OF_YR,COUNT(*)AS TOTAL_ORDERS_OF_YR
FROM ORDERS
GROUP BY DATE_TRUNC('YEAR',CREATED_AT);
-- Q6 Count the number of orders for each month.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS ORDERS_OF_MONTH,COUNT(*)AS TOTAL_ORDERS_PER_MONTH
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q7 Find total revenue for each year.
SELECT DATE_TRUNC('YEAR',CREATED_AT)AS ORDERS_OF_YR,SUM(PRICE_USD)AS TOTAL_REV_OF_YR
FROM ORDERS
GROUP BY DATE_TRUNC('YEAR',CREATED_AT);
-- Q8 Find total revenue for each month.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS MONTH,SUM(PRICE_USD)AS REVENUE_PER_MONTH
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q9 Display every order with its date only, without the time.
SELECT ORDER_ID,USER_ID,PRICE_USD,CREATED_AT::DATE
FROM ORDERS;
-- Q10 Find the number of orders placed on each day.
SELECT DATE_TRUNC('DAY',CREATED_AT)AS ORDERS_DAY,COUNT(*)AS ORDERS_PER_DAY
FROM ORDERS
GROUP BY  DATE_TRUNC('DAY',CREATED_AT);
-- 🟡 MEDIUM — Q11–Q20
-- Q11 Find monthly revenue and sort it chronologically.
SELECT DATE_TRUNC('MONTH',CREATED_AT)::DATE AS ORDER_MONTH,SUM(PRICE_USD)AS MONTHLY_REV
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT)
ORDER BY DATE_TRUNC('MONTH',CREATED_AT) ;
-- Q12 Find monthly order count and monthly revenue together.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS ORDER_MONTH,COUNT(*)AS TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REV_PER_MONTH
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q13 Find the average order price for each month.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS ORDER_MONTH,AVG(PRICE_USD)AS MONTHLY_AVG_ORDERS_PRICE
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q14 Find the total profit for each month.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS ORDER_MONTH,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT_PER_MONTH
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q15 Find the number of unique customers for each month.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS ORDER_MONTH,COUNT(DISTINCT USER_ID)AS UNIQUE_CUS_PER_MONTH
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT);
-- Q16 Find the first order date for every customer.
WITH CUS_LEV AS(
SELECT USER_ID,CREATED_AT,ROW_NUMBER() OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)AS RN
FROM ORDERS
)
SELECT USER_ID,CREATED_AT
FROM CUS_LEV
WHERE RN=1;
-- Q17 Find the latest order date for every customer.
WITH CUS_LEV AS(
SELECT USER_ID,CREATED_AT,ROW_NUMBER() OVER(PARTITION BY USER_ID ORDER BY CREATED_AT DESC)AS RN
FROM ORDERS
)
SELECT USER_ID,CREATED_AT
FROM CUS_LEV
WHERE RN=1;
-- Q18 Find customers whose first order was after the overall first order date.
WITH customer_first_order AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order_date
    FROM orders
    GROUP BY user_id
)
SELECT
    user_id,
    first_order_date
FROM customer_first_order
WHERE first_order_date > (
    SELECT MIN(created_at)
    FROM orders
);
-- Q19 Find orders placed during the first month of the dataset.
SELECT *
FROM orders
WHERE created_at >= DATE_TRUNC('month',(SELECT MIN(created_at) FROM orders))
AND created_at < DATE_TRUNC('month',(SELECT MIN(created_at) FROM orders)) + INTERVAL '1 month';
-- Q20 Find the number of orders placed on each day of the week.
SELECT TO_CHAR(CREATED_AT,'DAY')AS DAY_OF_WEEK,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY DAY_OF_WEEK,EXTRACT(ISODOW FROM CREATED_AT)
ORDER BY EXTRACT(ISODOW FROM CREATED_AT);
-- 🔴 HARD — Q21–Q30
-- Q21 Find monthly revenue and monthly profit.
SELECT DATE_TRUNC('MONTH',CREATED_AT)::DATE AS ORDER_MONTH,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY ORDER_MONTH;
-- Q22 Find the month with the highest total revenue.
SELECT DATE_TRUNC('MONTH',CREATED_AT)::DATE AS ORDER_MONTH,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY ORDER_MONTH
ORDER BY SUM(PRICE_USD) DESC
LIMIT 1;
-- Q23 Find the month with the highest number of orders.
SELECT DATE_TRUNC('MONTH',CREATED_AT)::DATE AS ORDER_MONTH,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY ORDER_MONTH
ORDER BY COUNT(*) DESC
LIMIT 1;
-- Q24 For every customer, display:
-- - user_id
-- - first order date
-- - last order date
-- - total orders
-- - total revenue
SELECT
    user_id,
    MIN(created_at) AS first_order_date,
    MAX(created_at) AS last_order_date,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue
FROM orders
GROUP BY user_id;
-- Q25 For every customer, calculate the number of days between their first and last order.
SELECT
    user_id,
    MIN(created_at) AS first_order_date,
    MAX(created_at) AS last_order_date,
    MAX(created_at)::DATE - MIN(created_at)::DATE AS days_between
FROM orders
GROUP BY user_id;
-- Q26 For every order, calculate the number of days since that customer's previous order.
SELECT
    order_id,
    created_at - LAG(created_at) OVER(
        PARTITION BY user_id
        ORDER BY created_at
    ) AS time_since_previous_order
FROM orders;
-- Q27 Find the average number of days between orders for each customer.
WITH order_gaps AS (
    SELECT
        user_id,
        created_at::DATE
        - LAG(created_at::DATE) OVER(
            PARTITION BY user_id
            ORDER BY created_at
        ) AS days_between_orders
    FROM orders
)
SELECT
    user_id,
    AVG(days_between_orders) AS avg_days_between_orders
FROM order_gaps
WHERE days_between_orders IS NOT NULL
GROUP BY user_id;
-- Q28 Find customers whose first and last orders are at least 30 days apart.
SELECT
    user_id,
    MIN(created_at) AS first_order_date,
    MAX(created_at) AS last_order_date,
    MAX(created_at)::DATE - MIN(created_at)::DATE AS days_between
FROM orders
GROUP BY user_id
HAVING MAX(created_at)::DATE - MIN(created_at)::DATE >= 30;
-- Q29
-- Find the monthly revenue and the previous month's revenue.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::DATE AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER(
        ORDER BY month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY month;
-- Q30 — Analyst-Level
-- Create a monthly sales analysis containing:
-- - month
-- - total orders
-- - unique customers
-- - total revenue
-- - total profit
-- - average order value
-- Then sort chronologically.
SELECT DATE_TRUNC('MONTH',CREATED_AT)AS MON,COUNT(*)AS TOTAL_ORDERS,COUNT(DISTINCT USER_ID)AS UNIQUE_CUS,
		SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT,AVG(PRICE_USD)
FROM ORDERS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT)
ORDER BY DATE_TRUNC('month', created_at);
