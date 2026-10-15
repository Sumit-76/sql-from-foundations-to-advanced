-- Topic-6  SUBQUERY 
-- 🟢 EASY — Q1–Q10
-- Q1 Find all orders whose price_usd is greater than the overall average order price.
SELECT * 
FROM ORDERS
WHERE PRICE_USD > (SELECT AVG(PRICE_USD)
					FROM ORDERS);
-- Q2 Find all orders whose price_usd is equal to the highest order price.
SELECT * 
FROM ORDERS
WHERE PRICE_USD = (SELECT MAX(PRICE_USD)
					FROM ORDERS);
-- Q3 Find all products that have appeared in order_items.
SELECT P.*
FROM PRODUCTS P
WHERE P.PRODUCT_ID IN (SELECT OI.PRODUCT_ID
FROM ORDER_ITEMS OI
WHERE OI.PRODUCT_ID=P.PRODUCT_ID);

-- Q4 Find all orders placed by customers who have placed more than one order.
SELECT *
FROM orders
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(*) > 1
);

-- Q5 Find all orders whose price is below the overall average order price.
SELECT * 
FROM ORDERS
WHERE PRICE_USD < (SELECT AVG(PRICE_USD)
					FROM ORDERS);

-- Q6 Find all products whose product_id exists in order_items.
SELECT P.*
FROM PRODUCTS P
WHERE EXISTS (SELECT OI.PRODUCT_ID
FROM ORDER_ITEMS OI
WHERE OI.PRODUCT_ID=P.PRODUCT_ID);

-- Q7 Find all orders whose price is greater than the minimum order price.
SELECT * 
FROM ORDERS
WHERE PRICE_USD > (SELECT MIN(PRICE_USD)
FROM ORDERS);

-- Q8 Find all customers whose total revenue is greater than 200.
SELECT USER_ID,SUM(PRICE_USD)
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD)>200;

-- Q9 Find all orders belonging to customers who have placed at least 3 orders.
SELECT *
FROM orders
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(*) >= 3
);

-- Q10 Find all products that have never appeared in order_items.
SELECT P.*
FROM PRODUCTS P
WHERE NOT EXISTS (SELECT OI.PRODUCT_ID
FROM ORDER_ITEMS OI
WHERE OI.PRODUCT_ID=P.PRODUCT_ID);
-- 🟡 MEDIUM — Q11–Q20
-- Q11 Find customers whose total revenue is greater than the average total revenue per customer.
SELECT user_id, SUM(price_usd) AS total_revenue
FROM orders
GROUP BY user_id
HAVING SUM(price_usd) > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT user_id, SUM(price_usd) AS total_revenue
        FROM orders
        GROUP BY user_id
    ) x
);

-- Q12 Find products whose total revenue is greater than the average total revenue per product.
SELECT
    product_id,
    SUM(price_usd) AS total_revenue
FROM order_items
GROUP BY product_id
HAVING SUM(price_usd) > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT
            product_id,
            SUM(price_usd) AS product_revenue
        FROM order_items
        GROUP BY product_id
    ) x
);

-- Q13 Find orders whose price is greater than the average order price of that same customer.
SELECT
    o1.order_id,
    o1.user_id,
    o1.price_usd
FROM orders o1
WHERE o1.price_usd > (
    SELECT AVG(o2.price_usd)
    FROM orders o2
    WHERE o2.user_id = o1.user_id
);

-- Q14 Find the customer(s) who have the highest number of orders.
SELECT
    user_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM (
        SELECT
            user_id,
            COUNT(*) AS order_count
        FROM orders
        GROUP BY user_id
    ) x
);

-- Q15 Find all orders belonging to customers whose total profit is greater than 100.
SELECT *
FROM orders
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING SUM(price_usd - cogs_usd) > 100
);

-- Q16 First calculate total orders and total revenue for each customer. Then return only customers whose total revenue is greater than 200.
SELECT *
FROM (
    SELECT
        user_id,
        COUNT(*) AS total_orders,
        SUM(price_usd) AS total_revenue
    FROM orders
    GROUP BY user_id
) x
WHERE total_revenue > 200;

-- Q17 Find products whose total revenue is greater than 500.
SELECT PRODUCT_ID,SUM(PRICE_USD)
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
HAVING SUM(PRICE_USD)>500;
-- Q18 Find customers who have placed at least one order with price greater than 100.

SELECT *
FROM orders
WHERE user_id IN (
    SELECT DISTINCT user_id
    FROM orders
    WHERE price_usd > 100
);

-- Q19 Find customers whose average order price is greater than 75.
SELECT USER_ID,AVG_PR
FROM (SELECT USER_ID,AVG(PRICE_USD)AS AVG_PR
FROM ORDERS
GROUP BY USER_ID
HAVING AVG(PRICE_USD)>75);

-- Q20 Find products that have at least one order and whose total revenue is below the average revenue of products that have orders.
SELECT
    product_id,
    SUM(price_usd) AS total_revenue
FROM order_items
GROUP BY product_id
HAVING SUM(price_usd) < (
    SELECT AVG(product_revenue)
    FROM (
        SELECT
            product_id,
            SUM(price_usd) AS product_revenue
        FROM order_items
        GROUP BY product_id
    ) x
);

-- 🔴 HARD — Q21–Q30
-- Q21 Find customers whose total revenue is greater than the average total revenue across all customers.
SELECT
    user_id,
    SUM(price_usd) AS total_revenue
FROM orders
GROUP BY user_id
HAVING SUM(price_usd) > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT
            user_id,
            SUM(price_usd) AS total_revenue
        FROM orders
        GROUP BY user_id
    ) x
);

-- Q22 Find orders whose price is greater than their own customer's average order price AND greater than the overall average order price.
SELECT
    o.order_id,
    o.user_id,
    o.price_usd
FROM orders o
WHERE o.price_usd > (
    SELECT AVG(o2.price_usd)
    FROM orders o2
    WHERE o2.user_id = o.user_id
)
AND o.price_usd > (
    SELECT AVG(price_usd)
    FROM orders
);

-- Q23 Find the customer(s) with the highest total revenue.
SELECT
    user_id,
    SUM(price_usd) AS total_revenue
FROM orders
GROUP BY user_id
HAVING SUM(price_usd) = (
    SELECT MAX(total_revenue)
    FROM (
        SELECT
            user_id,
            SUM(price_usd) AS total_revenue
        FROM orders
        GROUP BY user_id
    ) x
);
-- Q24 Find products whose total revenue is greater than the average revenue of products that have at least one order.
SELECT
    product_id,
    SUM(price_usd) AS total_revenue
FROM order_items
GROUP BY product_id
HAVING SUM(price_usd) > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT
            product_id,
            SUM(price_usd) AS product_revenue
        FROM order_items
        GROUP BY product_id
    ) x
);
-- Q25 Count how many customers are One-Time customers and how many are Repeat customers.
-- Definitions:
-- - One-Time = exactly 1 order
-- - Repeat = more than 1 order
-- Expected output:
-- customer_type | customer_count

SELECT
    customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT
        user_id,
        CASE
            WHEN COUNT(*) = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM orders
    GROUP BY user_id
) x
GROUP BY customer_type;


-- Q26 Count customers by revenue category.
-- Definitions:
-- < 100       → Low
-- 100–200     → Medium
-- > 200       → High

-- Expected output:
-- revenue_category | customer_count
SELECT
    revenue_category,
    COUNT(*) AS customer_count
FROM (
    SELECT
        user_id,
        CASE
            WHEN SUM(price_usd) < 100 THEN 'Low'
            WHEN SUM(price_usd) <= 200 THEN 'Medium'
            ELSE 'High'
        END AS revenue_category
    FROM orders
    GROUP BY user_id
) x
GROUP BY revenue_category;


-- Q27 Find customers whose total profit is greater than the average total profit across all customers.
SELECT
    user_id,
    SUM(price_usd - cogs_usd) AS total_profit
FROM orders
GROUP BY user_id
HAVING SUM(price_usd - cogs_usd) > (
    SELECT AVG(total_profit)
    FROM (
        SELECT
            user_id,
            SUM(price_usd - cogs_usd) AS total_profit
        FROM orders
        GROUP BY user_id
    ) x
);
-- Q28 Find the highest-priced order for each customer.If a customer has two orders tied for the highest price, both may be returned.
SELECT
    o1.order_id,
    o1.user_id,
    o1.price_usd
FROM orders o1
WHERE o1.price_usd = (
    SELECT MAX(o2.price_usd)
    FROM orders o2
    WHERE o2.user_id = o1.user_id
);
-- Q29 Find products whose total revenue is greater than every product whose total revenue is below 500.
SELECT
    product_id,
    SUM(price_usd) AS total_revenue
FROM order_items
GROUP BY product_id
HAVING SUM(price_usd) > (
    SELECT MAX(product_revenue)
    FROM (
        SELECT
            product_id,
            SUM(price_usd) AS product_revenue
        FROM order_items
        GROUP BY product_id
        HAVING SUM(price_usd) < 500
    ) x
);
-- Q30 Create a customer-level result containing: user_id, total orders, total revenue, customer type
-- Customer type:
-- 1 order + revenue <= 200 → One-Time Low Value
-- 1 order + revenue > 200  → One-Time High Value
-- >1 order + revenue <= 200 → Repeat Low Value
-- >1 order + revenue > 200  → Repeat High Value
SELECT
    user_id,
    total_orders,
    total_revenue,
    CASE
        WHEN total_orders = 1
             AND total_revenue <= 200
            THEN 'One-Time Low Value'

        WHEN total_orders = 1
             AND total_revenue > 200
            THEN 'One-Time High Value'

        WHEN total_orders > 1
             AND total_revenue <= 200
            THEN 'Repeat Low Value'

        ELSE 'Repeat High Value'
    END AS customer_type
FROM (
    SELECT
        user_id,
        COUNT(*) AS total_orders,
        SUM(price_usd) AS total_revenue
    FROM orders
    GROUP BY user_id
) ;



-- ⭐ MOST IMPORTANT SUBQUERY PATTERNS FOR YOU
-- Don't memorize 30 queries. Learn these 5 patterns.
-- Pattern 1 — Compare with one overall value
-- WHERE column > (
--     SELECT AVG(column)
--     FROM table
-- )

-- Example:
-- orders above overall average

-- Pattern 2 — Filter using a list
-- WHERE user_id IN (
--     SELECT user_id
--     FROM orders
--     GROUP BY user_id
--     HAVING ...
-- )

-- Example:
-- orders from repeat customers

-- Pattern 3 — Create an intermediate table
-- FROM (
--     SELECT ...
--     GROUP BY ...
-- ) x

-- Example:
-- customer revenue → then filter/classify customers

-- Pattern 4 — Compare each row with its group
-- WHERE o1.price_usd > (
--     SELECT AVG(o2.price_usd)
--     FROM orders o2
--     WHERE o2.user_id = o1.user_id
-- )

-- This is correlated.