-- Q1 Find the number of orders where cogs_usd is NULL.
SELECT COUNT(*)AS TOTAL_NULL_ORDERS
FROM ORDERS 
WHERE COGS_USD IS NULL;
-- Q2 Find the number of orders where price_usd is NOT NULL.
SELECT COUNT(*)AS TOTAL_NULL_ORDERS
FROM ORDERS
WHERE PRICE_USD IS NOT NULL;
-- Q3 Display all website sessions where utm_source is NULL.
SELECT *
FROM WEBSITE_SESSIONS
WHERE UTM_SOURCE IS NULL;
-- Q4 Display all website sessions where utm_source is NOT NULL.
SELECT *
FROM WEBSITE_SESSIONS
WHERE UTM_SOURCE IS NOT NULL;
-- Q5 Display every website session with utm_source, replacing NULL with 'Unknown'.
SELECT WEBSITE_SESSION_ID,COALESCE(UTM_SOURCE, 'UNknown')
FROM WEBSITE_SESSIONS;
-- Q6 Display every order with:
-- - order_id
-- - price_usd
-- - cogs_usd
-- - profit
-- If cogs_usd is NULL, treat it as 0 when calculating profit.
SELECT
    order_id,
    price_usd,
    cogs_usd,
    price_usd - COALESCE(cogs_usd, 0) AS profit
FROM orders;
-- Q7 Count:
-- - total orders
-- - orders having a non-NULL cogs_usd
SELECT COUNT(*)AS TOTAL_ORDERS,COUNT(COGS_USD)AS NON_NULL_COGS
FROM ORDERS;
-- Q8 Find the average cogs_usd from orders.
SELECT AVG(COGS_USD)
FROM ORDERS;
-- Q9 Display every product and its product_name. If product_name is NULL, display 'Unknown Product'.
SELECT PRODUCT_ID,COALESCE(PRODUCT_NAME,'Unknown Product')
FROM PRODUCTS;
-- Q10 Find all orders where cogs_usd is NULL OR price_usd is NULL.
SELECT *
FROM ORDERS
WHERE PRICE_USD IS NULL OR COGS_USD IS NULL;
-- 🟡 MEDIUM — Q11–Q20
-- Q11
-- For each utm_source, count:
-- - total sessions
-- - sessions where utm_source is non-NULL.
SELECT
    utm_source,
    COUNT(*) AS total_sessions,
    COUNT(utm_source) AS non_null_sessions
FROM website_sessions
GROUP BY utm_source;
-- Q12
-- Display each order with:
-- - order_id
-- - price_usd
-- - cogs_usd
-- - profit
-- If cogs_usd is NULL, treat it as 0.
SELECT
    order_id,
    price_usd,
    cogs_usd,
    price_usd - COALESCE(cogs_usd, 0) AS profit
FROM orders;
-- Q13
-- Find the total revenue and total COGS from orders.
-- Treat NULL COGS as 0.
SELECT SUM(COALESCE(PRICE_USD,0))AS TOTAL_REV,SUM(COALESCE(COGS_USD,0)) AS TOTAL_COGS
FROM ORDERS;
-- Q14
-- For each user_id, calculate:
-- - total orders
-- - total revenue
-- - total COGS
-- Treat NULL COGS as 0.
SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue,
    SUM(COALESCE(cogs_usd, 0)) AS total_cogs
FROM orders
GROUP BY user_id;
-- Q15
-- Find customers whose total profit is greater than 100.
-- Treat NULL COGS as 0.
SELECT USER_ID,SUM(PRICE_USD-COALESCE(COGS_USD,0))AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD-COALESCE(COGS_USD,0))>100;
-- Q16
-- Using website_sessions, classify every session as:
-- - 'Organic' → utm_source is NULL
-- - 'Paid' → utm_source is NOT NULL
-- Then count sessions in each category.
SELECT 
	CASE
		WHEN UTM_SOURCE IS NULL THEN 'Organic'
		ELSE 'Paid'
	END AS CATAGORY,
	COUNT(*)AS COUNT_SESSIONS
FROM WEBSITE_SESSIONS
GROUP BY 
	CASE
		WHEN UTM_SOURCE IS NULL THEN 'Organic'
		ELSE 'Paid'
	END;
-- Q17
-- Find the number of orders where either:
-- - price_usd is NULL
-- - cogs_usd is NULL.
SELECT COUNT(*) AS affected_orders
FROM orders
WHERE price_usd IS NULL
   OR cogs_usd IS NULL;
-- Q18
-- Display each order with:
-- - order_id
-- - price_usd
-- - cogs_usd
-- - profit
-- - profit_status
-- Profit status:
-- - 'Profit' → profit > 0
-- - 'Loss' → profit < 0
-- - 'Break Even' → profit = 0
-- - 'Missing Cost' → cogs is NULL
SELECT
    order_id,
    price_usd,
    cogs_usd,
    price_usd - COALESCE(cogs_usd, 0) AS profit,
    CASE
        WHEN cogs_usd IS NULL THEN 'Missing Cost'
        WHEN price_usd - cogs_usd > 0 THEN 'Profit'
        WHEN price_usd - cogs_usd < 0 THEN 'Loss'
        ELSE 'Break Even'
    END AS profit_status
FROM orders;
-- Q19
-- Find the average selling price of orders where price_usd is NOT NULL.
-- Then compare it with the average selling price calculated without explicitly filtering NULLs.
SELECT
    AVG(price_usd) AS average_without_filter
FROM orders;
--COMPARE BOTH
SELECT AVG(PRICE_USD)AS average_with_filter
FROM ORDERS
WHERE PRICE_USD IS NOT NULL;
-- Q20
-- Using COALESCE, display every session with:
-- - session_id
-- - user_id
-- - utm_source
-- Replace NULL utm_source with 'Direct / Organic'.
SELECT WEBSITE_SESSION_ID,USER_ID,COALESCE(UTM_SOURCE,'Direct / Organic')
FROM WEBSITE_SESSIONS;
-- 🔴 HARD — Q21–Q30
-- Q21
-- For every utm_source, calculate:
-- - total sessions
-- - unique users
-- - total orders
-- - total revenue
-- Replace NULL utm_source with 'Unknown'.
SELECT
    COALESCE(ws.utm_source, 'Unknown') AS utm_source,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT ws.user_id) AS unique_users,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.price_usd) AS total_revenue
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Unknown');
-- Q22
-- For every customer, calculate:
-- - total orders
-- - total revenue
-- - total COGS
-- - total profit
-- Treat NULL COGS as 0.
SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue,
    SUM(COALESCE(cogs_usd, 0)) AS total_cogs,
    SUM(price_usd - COALESCE(cogs_usd, 0)) AS total_profit
FROM orders
GROUP BY user_id;
-- Q23
-- Find products that have never appeared in order_items.
-- Return:
-- - product_id
-- - product_name
SELECT
    p.product_id,
    p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);
-- Q24
-- Find every product with:
-- - product_name
-- - total order items
-- Products with no order items must still appear with 0, not NULL.
SELECT
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) AS total_order_items
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;
-- Q25
-- For every product, calculate:
-- - total revenue
-- - total COGS
-- - total profit
-- Products with no sales should still appear, with missing numeric values treated as 0.
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(COALESCE(oi.price_usd,0)),0) AS total_revenue,
    COALESCE(SUM(COALESCE(oi.cogs_usd,0)),0) AS total_cogs,
    COALESCE(
        SUM(
            COALESCE(oi.price_usd,0) -
            COALESCE(oi.cogs_usd,0)
        ),0
    ) AS total_profit
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;
-- Q26
-- Find the percentage of orders where cogs_usd is NULL.
WITH NULL_COUNT_LEV AS(SELECT COUNT(*)AS NULL_COUNT
FROM ORDERS
WHERE COGS_USD IS NULL),
COUNT_LEV AS(
SELECT COUNT(*)AS TOTAL_COUNT
FROM ORDERS
)
SELECT NULL_COUNT*100.0/TOTAL_COUNT AS PERCENTAGE_NULL_COGS
FROM NULL_COUNT_LEV
CROSS JOIN COUNT_LEV;
-- Q27
-- Calculate revenue per item:
-- price_usd / items_purchased

-- But make sure your query does not fail if items_purchased = 0.
SELECT PRICE_USD/NULLIF(ITEMS_PURCHASED,0) AS REV_PER_ITEM
FROM ORDERS;
-- Q28
-- For each customer, calculate:
-- - total orders
-- - total revenue
-- - average order price
-- If a customer has no valid price values, handle the NULL result appropriately.
SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue,
    COALESCE(AVG(price_usd),0) AS average_order_price
FROM orders
GROUP BY user_id;
-- Q29
-- Using website_sessions, create these categories:
-- - Google
-- - Facebook
-- - Other
-- - Unknown
-- Rules:
-- - source contains Google → Google
-- - source contains Facebook → Facebook
-- - source is NULL → Unknown
-- - everything else → Other
-- Then count sessions in each category.
SELECT
    CASE
        WHEN utm_source IS NULL THEN 'Unknown'
        WHEN utm_source ILIKE '%google%' THEN 'Google'
        WHEN utm_source ILIKE '%facebook%' THEN 'Facebook'
        ELSE 'Other'
    END AS utm_category,
    COUNT(*) AS total_sessions
FROM website_sessions
GROUP BY
    CASE
        WHEN utm_source IS NULL THEN 'Unknown'
        WHEN utm_source ILIKE '%google%' THEN 'Google'
        WHEN utm_source ILIKE '%facebook%' THEN 'Facebook'
        ELSE 'Other'
    END;
-- Q30 — Analyst-level NULL problem
-- Build a marketing performance report with:
-- - cleaned utm_source
-- - total sessions
-- - unique users
-- - total orders
-- - total revenue
-- - total profit
-- Requirements:
-- 1. NULL utm_source should become 'Unknown'.
-- 2. Sessions with no orders must remain.
-- 3. Don't double-count sessions, users, or orders because of the JOIN.
-- 4. NULL COGS should be treated as 0.
-- 5. Sort by total revenue descending.
SELECT
    COALESCE(LOWER(TRIM(ws.utm_source)), 'Unknown') AS utm_source,

    COUNT(DISTINCT ws.website_session_id) AS total_sessions,

    COUNT(DISTINCT ws.user_id) AS unique_users,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(o.price_usd) AS total_revenue,

    SUM(
        o.price_usd - COALESCE(o.cogs_usd, 0)
    ) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY
    COALESCE(LOWER(TRIM(ws.utm_source)), 'Unknown')

ORDER BY total_revenue DESC NULLS LAST;