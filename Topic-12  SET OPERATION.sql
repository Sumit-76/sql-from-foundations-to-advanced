-- Q1 Get all user_id values from orders where price_usd > 100 OR items_purchased > 1 using UNION.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD > 100
UNION
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED > 1; 
--Q2 Repeat Q1 using UNION ALL.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD > 100
UNION ALL
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED > 1;
--Q3 Find users who have:
-- an order with price_usd > 100
-- AND an order with items_purchased > 1
-- Use INTERSECT.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD > 100
INTERSECT
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED > 1;
-- Q4
-- Find users who have an order with price_usd > 100 but do NOT have an order with items_purchased > 1.
-- Use EXCEPT.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD > 100
EXCEPT
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED > 1;
-- Q5 Get all product_id values from order_items where price_usd > 50 OR cogs_usd > 30 using UNION.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE PRICE_USD > 50
UNION
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE COGS_USD > 30;
-- Q6 Repeat Q5 using UNION ALL.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE PRICE_USD > 50
UNION ALL
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE COGS_USD > 30;
-- Q7
-- Find product IDs that have both:
-- - an item priced above 50
-- - an item with COGS above 30.
-- Use INTERSECT.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE PRICE_USD>50
INTERSECT 
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE COGS_USD>30;
-- Q8
-- Find product IDs that have an item priced above 50 but never have an item with COGS above 30.
-- Use EXCEPT.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE PRICE_USD>50
EXCEPT 
SELECT PRODUCT_ID
FROM ORDER_ITEMS
WHERE COGS_USD>30;
-- Q9
-- Combine all user_id values from:
-- - orders
-- - website_sessions
-- Remove duplicates.
SELECT USER_ID
FROM ORDERS
UNION 
SELECT USER_ID
FROM WEBSITE_SESSIONS;
-- Q10
-- Combine all user_id values from:
-- - orders
-- - website_sessions
-- Keep duplicates.
SELECT USER_ID
FROM ORDERS
UNION ALL
SELECT USER_ID
FROM WEBSITE_SESSIONS;

--MEDIUM
-- Q11
-- Find users who either:
-- - placed an order above 200
-- - OR placed more than one item in an order.
-- Use UNION.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD>200
UNION
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED>1;
-- Q12
-- Find users who satisfy both conditions from Q11.
-- Use INTERSECT.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD>200
INTERSECT
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED>1;
-- Q13
-- Find users who placed an order above 200 but never placed an order containing more than one item.
-- Use EXCEPT.
SELECT USER_ID
FROM ORDERS
WHERE PRICE_USD>200
EXCEPT
SELECT USER_ID
FROM ORDERS
WHERE ITEMS_PURCHASED>1;
-- Q14
-- Find all product IDs that appear in either:
-- - orders.primary_product_id
-- - order_items.product_id
-- Remove duplicates.
SELECT PRIMARY_PRODUCT_ID
FROM ORDERS
UNION
SELECT PRODUCT_ID
FROM ORDER_ITEMS;
-- Q15
-- Find product IDs that appear in both:
-- - orders.primary_product_id
-- - order_items.product_id.
SELECT PRIMARY_PRODUCT_ID
FROM ORDERS
INTERSECT
SELECT PRODUCT_ID
FROM ORDER_ITEMS;
-- Q16
-- Find product IDs that appear in order_items but never appear as primary_product_id in orders.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
EXCEPT 
SELECT PRIMARY_PRODUCT_ID
FROM ORDERS;
-- Q17
-- Combine the user IDs from:
-- - orders created before 2014
-- - orders created during 2014
-- Remove duplicates.
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE<'2014/01/01'
UNION
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE BETWEEN '2014/01/01' AND '2014/12/31';
-- Q18
-- Find users who placed orders both:
-- - before 2014
-- - during 2014.
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE<'2014/01/01'
INTERSECT
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE BETWEEN '2014/01/01' AND '2014/12/31';
-- Q19
-- Find users who placed orders before 2014 but did not place any orders during 2014.
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE<'2014/01/01'
EXCEPT
SELECT USER_ID
FROM ORDERS
WHERE CREATED_AT::DATE BETWEEN '2014/01/01' AND '2014/12/31';
-- Q20
-- Create a list of all user IDs from orders and website sessions, remove duplicates, and sort ascending.
SELECT USER_ID
FROM ORDERS
UNION 
SELECT USER_ID
FROM WEBSITE_SESSIONS;
-- 🔴 HARD — Q21–Q30
-- Q21
-- Find users who either:
-- - have total order revenue above 500
-- - OR have placed at least 3 orders.
-- Return unique users.
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD)>500
UNION
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING COUNT(*)>=3;
-- Q22
-- Find users who satisfy both:
-- - total revenue above 500
-- - at least 3 orders.
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD)>500
INTERSECT
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING COUNT(*)>=3;
-- Q23
-- Find users who have total revenue above 500 but have fewer than 3 orders.
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD)>500
INTERSECT
SELECT USER_ID
FROM ORDERS
GROUP BY USER_ID
HAVING COUNT(*)<3;
-- Q24
-- Find products that:
-- - have generated revenue above 1000 from order_items
-- - OR have appeared in more than 500 order items.
-- Return unique product IDs.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD)>1000
UNION
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING COUNT(*)>500;
-- Q25
-- Find products satisfying both conditions in Q24.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD)>1000
INTERSECT
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING COUNT(*)>500;
-- Q26
-- Find products that generated revenue above 1000 but appeared in fewer than 500 order items.
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD)>1000
INTERSECT
SELECT PRODUCT_ID
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING COUNT(*)<500;
-- Q27
-- Create a single list containing:
-- - user IDs from orders
-- - user IDs from website sessions
-- Keep duplicates and add a column indicating the source:
-- user_id | source
-- --------|--------
-- 101     | Orders
-- 101     | Sessions
-- 102     | Orders
SELECT USER_ID,'ORDERS'AS SOURCE
FROM ORDERS
UNION ALL
SELECT USER_ID,'SESSIONS'AS SOURCE
FROM WEBSITE_SESSIONS;
-- Q28
-- Create a unique list of users who either:
-- - placed an order
-- - OR had a website session
-- Return:
-- user_id sorted ascending.
SELECT USER_ID
FROM ORDERS
UNION
SELECT USER_ID
FROM WEBSITE_SESSIONS
ORDER BY USER_ID;
-- Q29
-- Find users who:
-- - had at least one website session
-- - AND placed at least one order
-- - but whose first session user ID exists in sessions while their order activity belongs to the same user.
-- Use set operations rather than JOINs.
SELECT user_id
FROM website_sessions
INTERSECT
SELECT user_id
FROM orders;
-- Q30 — Analyst-level
-- Build three customer groups:
-- Group A
-- Customers with total revenue > 500.
-- Group B
-- Customers with at least 3 orders.
-- Group C
-- Customers satisfying both A and B.
-- Return the customers who belong to A or B but NOT C.
-- Use set operations.
WITH A AS (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING SUM(price_usd) > 500
),
B AS (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(*) >= 3
),
C AS (
    SELECT user_id FROM A
    INTERSECT
    SELECT user_id FROM B
)
SELECT user_id FROM A
UNION
SELECT user_id FROM B
EXCEPT
SELECT user_id FROM C;