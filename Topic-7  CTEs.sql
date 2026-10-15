-- Q1
-- Create a CTE named customer_revenue that calculates the total revenue for each customer.
-- Return:
-- - user_id
-- - total_revenue
WITH CUSTOMER_REVENUE AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_REVENUE
FROM CUSTOMER_REVENUE;
-- Q2
-- Using a CTE, find customers whose total revenue is greater than 200.
-- Return:
-- - user_id
-- - total_revenue
WITH CUSTOMER_REVENUE AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_REVENUE
FROM CUSTOMER_REVENUE
WHERE TOTAL_REVENUE>200;
-- Q3
-- Create a CTE that calculates the total number of orders for each customer.
-- Return:
-- - user_id
-- - total_orders
WITH TOTAL_ORDERS AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDER_PER_CUS
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_ORDER_PER_CUS
FROM TOTAL_ORDERS;
-- Q4
-- Using a CTE, find customers who have placed more than 1 order.
-- Return:
-- - user_id
-- - total_orders
WITH TOTAL_ORDERS AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDER_PER_CUS
FROM ORDERS
GROUP BY USER_ID
HAVING COUNT(*)>1
)SELECT USER_ID,TOTAL_ORDER_PER_CUS
FROM TOTAL_ORDERS;
-- Q5
-- Create a CTE that calculates total revenue for each product using order_items.
-- Return:
-- - product_id
-- - total_revenue
WITH TOTAL_REVENUE_PRODUCT AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
)
SELECT PRODUCT_ID,TOTAL_REVENUE
FROM TOTAL_REVENUE_PRODUCT;
-- Q6
-- Using the CTE from Q5, return only products whose total revenue is greater than 500.
WITH TOTAL_REVENUE_PRODUCT AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD)>500
)
SELECT PRODUCT_ID,TOTAL_REVENUE
FROM TOTAL_REVENUE_PRODUCT;
-- Q7
-- Create a CTE that calculates total profit for each customer.
-- Profit:price_usd - cogs_usd
-- Return:
-- - user_id
-- - total_profit
WITH TOTAL_PROFIT_PER_CUS AS(
SELECT USER_ID,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_PROFIT
FROM TOTAL_PROFIT_PER_CUS;
-- Q8
-- Using a CTE, categorize each customer based on total revenue:
-- < 100       → Low
-- 100–200     → Medium
-- > 200       → High
-- Return:
-- - user_id
-- - total_revenue
-- - customer_category
WITH TOTAL_REVENUE_PER_CUS AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_REVENUE,
	CASE
		WHEN TOTAL_REVENUE<100 THEN 'LOW'
		WHEN TOTAL_REVENUE BETWEEN 100 AND 200 THEN 'MEDIUM'
		ELSE 'HIGH'
	END AS CUSTOMER_CATEGORY
FROM TOTAL_REVENUE_PER_CUS;
-- Q9
-- Create a CTE that calculates the number of sessions for each device_type.
-- Return:
-- - device_type
-- - total_sessions
WITH NO_OF_SESSIONS AS(
SELECT DEVICE_TYPE,COUNT(WEBSITE_SESSION_ID)AS TOTAL_SESSIONS
FROM WEBSITE_SESSIONS
GROUP BY DEVICE_TYPE
)
SELECT DEVICE_TYPE,TOTAL_SESSIONS
FROM NO_OF_SESSIONS;
-- Q10
-- Using a CTE, find device types that have more than 1000 sessions.
-- Return:
-- - device_type
-- - total_sessions
WITH NO_OF_SESSIONS AS(
SELECT DEVICE_TYPE,COUNT(WEBSITE_SESSION_ID)AS TOTAL_SESSIONS
FROM WEBSITE_SESSIONS
GROUP BY DEVICE_TYPE
HAVING COUNT(WEBSITE_SESSION_ID)>1000
)
SELECT DEVICE_TYPE,TOTAL_SESSIONS
FROM NO_OF_SESSIONS;

-- 🟡 MEDIUM — Q11–Q20
-- Q11
-- Create a CTE containing customer-level metrics:
-- - user_id
-- - total_orders
-- - total_revenue
-- - total_profit
-- Then return only customers whose total profit is greater than 100.
WITH CUSTOMER_LEVEL AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REVENUE,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD-COGS_USD)>100
)
SELECT USER_ID,TOTAL_REVENUE,TOTAL_PROFIT
FROM CUSTOMER_LEVEL;
-- Q12
-- Create a CTE containing customer revenue.
-- Then calculate the average customer revenue from that CTE.
-- Return: average_customer_revenue
WITH CUS_TOTAL_REVENUE AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
),
CUS_AVG_TOTAL_REV AS(
SELECT AVG(TOTAL_REVENUE)AS AVG_TOTAL_REV
FROM CUS_TOTAL_REVENUE
)
SELECT AVG_TOTAL_REV
FROM CUS_AVG_TOTAL_REV;
-- Q13
-- Using a CTE containing customer revenue, return customers whose revenue is greater than the average customer revenue.
-- Return:
-- - user_id
-- - total_revenue
WITH CUS_TOTAL_REVENUE AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
),
CUS_AVG_TOTAL_REV AS(
SELECT AVG(TOTAL_REVENUE)AS AVG_TOTAL_REV
FROM CUS_TOTAL_REVENUE
)
SELECT USER_ID,TOTAL_REVENUE
FROM CUS_TOTAL_REVENUE CR
CROSS JOIN CUS_AVG_TOTAL_REV CAR
WHERE CR.TOTAL_REVENUE > CAR.AVG_TOTAL_REV;
-- Q14
-- Create a CTE that calculates revenue for each product.
-- Then categorize products:
-- < 500       → Low
-- 500–1000    → Medium
-- > 1000      → High
-- Return:
-- - product_id
-- - total_revenue
-- - revenue_category
WITH PRODUCT_REVENUE AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_PRODUCT_REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
)
SELECT PRODUCT_ID,TOTAL_PRODUCT_REVENUE,
	CASE
		WHEN TOTAL_PRODUCT_REVENUE<500 THEN 'LOW'
		WHEN TOTAL_PRODUCT_REVENUE BETWEEN 500 AND 1000 THEN 'MEDIUM'
		ELSE 'HIGH'
	END AS REVENUE_CAT
FROM PRODUCT_REVENUE;
-- Q15
-- Create a CTE containing customer order counts.
-- Then categorize customers:
-- 1 order    → One-Time
-- >1 order   → Repeat
-- Return:
-- - user_id
-- - total_orders
-- - customer_type
WITH CUS_ORDER_COUNT AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_ORDERS,
	CASE
		WHEN TOTAL_ORDERS=1 THEN 'ONE-TIME'
		ELSE 'REPEAT'
	END AS CUSTOMER_TYPE
FROM CUS_ORDER_COUNT;
-- Q16
-- Using the CTE from Q15, count how many customers belong to each customer type.
-- Expected:
-- customer_type | customer_count
WITH CUS_ORDER_COUNT AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY USER_ID
)
SELECT 
	CASE
		WHEN TOTAL_ORDERS=1 THEN 'ONE-TIME'
		ELSE 'REPEAT'
	END AS CUSTOMER_TYPE,
	COUNT(*)AS CUSTOMER_COUNT
FROM CUS_ORDER_COUNT
GROUP BY CUSTOMER_TYPE;
-- Q17
-- Create a CTE that calculates revenue by utm_source.
-- Return:
-- - utm_source
-- - total_revenue
-- Then return only sources with revenue greater than 5000.
WITH utm_revenue AS (
    SELECT
        ws.utm_source,
        SUM(o.price_usd) AS total_revenue
    FROM website_sessions ws
    JOIN orders o
        ON ws.website_session_id = o.website_session_id
    GROUP BY ws.utm_source
)
SELECT
    utm_source,
    total_revenue
FROM utm_revenue
WHERE total_revenue > 5000;
-- Q18
-- Create a CTE containing:
-- - device_type
-- - total sessions
-- - total orders
-- Use website_sessions and orders.
-- Return all device types, including device types that have sessions but no orders.
WITH device_metrics AS (
    SELECT
        ws.device_type,
        COUNT(DISTINCT ws.website_session_id) AS total_sessions,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM website_sessions ws
    LEFT JOIN orders o
        ON ws.website_session_id = o.website_session_id
    GROUP BY ws.device_type
)
SELECT
    device_type,
    total_sessions,
    total_orders
FROM device_metrics;
-- Q19
-- Create a CTE that calculates product-level:
-- - total order items
-- - total revenue
-- - total profit
-- Then return products where total profit is greater than 500.
WITH PRODUCT_LEVEL AS(
SELECT PRODUCT_ID,COUNT(*)AS TOTAL_ORDER_ITEMS,SUM(PRICE_USD)AS TOTAL_REVENUE,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD-COGS_USD) > 500
)
SELECT PRODUCT_ID,TOTAL_ORDER_ITEMS,TOTAL_REVENUE,TOTAL_PROFIT
FROM PRODUCT_LEVEL;
-- Q20
-- Create a CTE containing customer-level revenue.
-- Then return:
-- - user_id
-- - total_revenue
-- - customer_category
-- where:
-- < 100       → Low Value
-- 100–200     → Medium Value
-- > 200       → High Value
-- Sort by total revenue descending.
WITH CUS_LEVEL_REVENUE AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REVENUE
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_REVENUE,
	CASE
		WHEN TOTAL_REVENUE<100 THEN 'LOW VALUE'
		WHEN TOTAL_REVENUE BETWEEN 100 AND 200 THEN 'MEDIUM VALUE'
		ELSE 'HIGH VALUE'
	END AS CUS_CAT
FROM CUS_LEVEL_REVENUE
ORDER BY TOTAL_REVENUE DESC;
-- 🔴 HARD — Q21–Q30
-- Q21
-- Create a CTE for customer-level revenue.
-- Then create another CTE containing the average customer revenue.
-- Finally return customers whose revenue is above the average.
-- Return:
-- - user_id
-- - total_revenue
WITH CUSTOMER_LEVEL_REV AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
),
AVG_CUSTOMER_REV AS(
SELECT AVG(TOTAL_REV)AS AVG_REV
FROM CUSTOMER_LEVEL_REV
)
SELECT CLR.USER_ID,CLR.TOTAL_REV
FROM CUSTOMER_LEVEL_REV CLR
CROSS JOIN AVG_CUSTOMER_REV ACR
WHERE CLR.TOTAL_REV>ACR.AVG_REV;
-- Q22
-- Create a CTE containing customer-level:
-- - total orders
-- - total revenue
-- - total profit
-- Then return only repeat customers whose total revenue is greater than 200 and total profit is greater than 50.
WITH CUS_LEVEL AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,
	CASE
		WHEN TOTAL_ORDERS=1 THEN 'ONE-TIME'
		ELSE 'REPEAT'
	END AS CUSTOMER_TYPE
FROM CUS_LEVEL
WHERE TOTAL_ORDERS>1 AND TOTAL_REV > 200 AND TOTAL_PROFIT > 50;
-- Q23
-- Create a CTE for product-level revenue.
-- Then create another CTE for the average product revenue.
-- Return products whose revenue is above the average product revenue.
WITH PRO_LEVEL_REV AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS PRODUCT_REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
),
AVG_PRO_REV AS(
SELECT AVG(PRODUCT_REVENUE)AS AVG_REV
FROM PRO_LEVEL_REV
)
SELECT PLR.PRODUCT_ID,PLR.PRODUCT_REVENUE
FROM PRO_LEVEL_REV PLR
CROSS JOIN AVG_PRO_REV APR
WHERE PLR.PRODUCT_REVENUE > APR.AVG_REV;
-- Q24
-- Create a CTE containing customer-level revenue.
-- Then categorize customers:
-- < 100       → Low
-- 100–200     → Medium
-- > 200       → High
-- Finally count customers in each category.
-- Expected:
-- revenue_category | customer_count
WITH CUS_LEVEL_REV AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
)
SELECT 
	CASE
		WHEN TOTAL_REV < 100 THEN 'LOW'
		WHEN TOTAL_REV BETWEEN 100 AND 200 THEN 'MEDIUM'
		ELSE 'HIGH'
	END AS REVENUE_CATAGORY,
	COUNT(*)AS CUSTOMER_COUNT 
FROM CUS_LEVEL_REV
GROUP BY REVENUE_CATAGORY;

-- Q25
-- Create a CTE containing customer-level:
-- - total orders
-- - total revenue
-- - total profit
-- Then create a customer segment:
-- One-Time Low Value
-- One-Time High Value
-- Repeat Low Value
-- Repeat High Value

-- Rules:
-- 1 order + revenue <= 200  → One-Time Low Value
-- 1 order + revenue > 200   → One-Time High Value
-- >1 order + revenue <= 200 → Repeat Low Value
-- >1 order + revenue > 200  → Repeat High Value

-- Return:
-- - user_id
-- - total_orders
-- - total_revenue
-- - total_profit
-- - customer_segment
WITH CUS_LEVEL AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_ORDERS,TOTAL_REV,TOTAL_PROFIT,
	CASE
		WHEN TOTAL_ORDERS=1 AND TOTAL_REV <= 200 THEN 'One-Time Low-Value'
		WHEN TOTAL_ORDERS=1 AND TOTAL_REV > 200 THEN 'One-Time High-Value'
		WHEN TOTAL_ORDERS>1 AND TOTAL_REV <= 200 THEN 'Repeat Low-Value'
		ELSE 'Repeat High-Value'
	END AS CUSTOMER_SEGMENT
FROM CUS_LEVEL ;
-- Q26
-- Create a CTE containing product-level:
-- - total order items
-- - unique orders
-- - total revenue
-- - total profit
-- Then return products where:
-- - unique orders > 100
-- - total revenue > 1000
-- - total profit > 500
WITH PROD_LEV AS(
SELECT PRODUCT_ID,COUNT(*)AS TOTAL_ORDER_ITEMS,COUNT(DISTINCT ORDER_ITEM_ID)AS UNIQUE_ORDERS,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
)
SELECT PRODUCT_ID,UNIQUE_ORDERS,TOTAL_REV,TOTAL_PROFIT
FROM PROD_LEV
WHERE UNIQUE_ORDERS > 100 AND TOTAL_REV > 1000 AND TOTAL_PROFIT > 500;
-- Q27
-- Create a CTE containing utm_source-level:
-- - total sessions
-- - unique users
-- - total orders
-- - total revenue
-- - total profit
-- Then return sources where:
-- - total orders > 100
-- - total revenue > 5000
-- Sort by revenue descending.
WITH utm_metrics AS (
    SELECT
        ws.utm_source,
        COUNT(DISTINCT ws.website_session_id) AS total_sessions,
        COUNT(DISTINCT ws.user_id) AS unique_users,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.price_usd) AS total_revenue,
        SUM(o.price_usd - o.cogs_usd) AS total_profit
    FROM website_sessions ws
    LEFT JOIN orders o
        ON ws.website_session_id = o.website_session_id
    GROUP BY ws.utm_source
)
SELECT
    utm_source,
    total_sessions,
    unique_users,
    total_orders,
    total_revenue,
    total_profit
FROM utm_metrics
WHERE total_orders > 100
  AND total_revenue > 5000
ORDER BY total_revenue DESC;

-- Q28
-- Create a CTE containing customer-level:
-- - total orders
-- - total revenue
-- Then create another CTE containing the average customer revenue.
-- Finally classify each customer as:
-- Above Average
-- Below Average

-- Return:
-- - user_id
-- - total_orders
-- - total_revenue
-- - revenue_status
WITH CUS_LEV AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
),
AVG_CUS_REV AS(
SELECT AVG(TOTAL_REV)AS AVG_REV
FROM CUS_LEV
)
SELECT USER_ID,TOTAL_ORDERS,TOTAL_REV,
	CASE
		WHEN TOTAL_REV > AVG_REV THEN 'Above-Average'
		ELSE 'Below-Average'
	END AS REVENUE_STATUS
FROM CUS_LEV
CROSS JOIN AVG_CUS_REV;
-- Q29
-- Create a CTE containing product-level revenue.
-- Then:
-- 1. Find the average product revenue.
-- 2. Find the highest product revenue.
-- 3. Return the product(s) having the highest revenue.
-- 4. Also display the average product revenue in the result.
-- Expected columns:
-- product_id
-- total_revenue
-- average_product_revenue
WITH PRO_LEVEL_REV AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS PRODUCT_REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
),
AVG_PRO_REV AS(
SELECT AVG(PRODUCT_REVENUE)AS AVG_REV,MAX(PRODUCT_REVENUE)AS MAX_PRODUCT_REV
FROM PRO_LEVEL_REV
)
SELECT PLR.PRODUCT_REVENUE,APR.AVG_REV
FROM PRO_LEVEL_REV PLR
CROSS JOIN AVG_PRO_REV APR ;

-- Q30 — Final CTE Challenge
-- Build a customer analytics table using multiple CTEs.
-- Your final result must contain:
-- - user_id
-- - total_orders
-- - total_revenue
-- - total_profit
-- - average_order_price
-- - customer_type
-- - revenue_segment
-- - profit_segment
-- Definitions:
-- Customer type
-- 1 order  → One-Time
-- >1 order → Repeat

-- Revenue segment
-- < 100       → Low Value
-- 100–200     → Medium Value
-- > 200       → High Value

-- Profit segment
-- < 0         → Loss
-- 0–100       → Low Profit
-- > 100       → High Profit

-- Sort by total_revenue descending.

WITH CUS_LEV AS(
SELECT USER_ID,COUNT(*)AS TOTAL_ORDER,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COGS_USD)AS TOTAL_PROFIT,AVG(PRICE_USD)AS AVG_ORDER_PRICE
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_ORDER,TOTAL_REV,TOTAL_PROFIT,AVG_ORDER_PRICE,
	CASE 
		WHEN TOTAL_ORDER=1 THEN 'ONE-TIME'
		ELSE 'REPEAT'
	END AS CUSTOMER_TYPE,
	CASE
		WHEN TOTAL_REV < 100 THEN 'LOW-VALUE'
		WHEN TOTAL_REV BETWEEN 100 AND 200 THEN 'MEDIUM-VALUE'
		ELSE 'HIGH-VALUE'
	END AS REVENUE_SEG,
	CASE
		WHEN TOTAL_PROFIT < 0 THEN 'LOSS'
		WHEN TOTAL_PROFIT BETWEEN 0 AND 100 THEN 'LOW-PROFIT'
		ELSE 'HIGH-PROFIT'
	END AS PROFIT_SEG
FROM CUS_LEV ;
