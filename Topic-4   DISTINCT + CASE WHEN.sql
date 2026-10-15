--Topic 4 — DISTINCT + CASE WHEN
-- 🟢 EASY — Q1–Q10
-- Q1. Find all unique user_id values from the orders table.
SELECT DISTINCT user_id 
FROM orders;
-- Q2. Find all unique primary_product_id values from orders.
SELECT DISTINCT primary_product_id 
FROM orders;
-- Q3. Find all unique items_purchased values from orders.
SELECT DISTINCT items_purchased 
FROM orders;
-- Q4. Find all unique device_type values from website_sessions.
SELECT DISTINCT device_type 
FROM website_sessions;
-- Q5. Find all unique utm_source values from website_sessions.
SELECT DISTINCT utm_source 
FROM website_sessions;
-- Q6. Display every order with a new column called order_type:
-- - Single Item if items_purchased = 1
-- - Multiple Items if items_purchased > 1
SELECT *,
       CASE 
           WHEN items_purchased = 1 THEN 'Single Item'
           WHEN items_purchased > 1 THEN 'Multiple Items'
       END AS order_type
FROM orders;
-- Q7. Display every order with a new column called price_category:
-- - Low if price_usd < 50
-- - High otherwise
SELECT *,
       CASE 
           WHEN price_usd < 50 THEN 'Low'
           ELSE 'High'
       END AS price_category
FROM orders;
-- Q8. Display every order with a new column called profit_status:
-- - Profit if price_usd > cogs_usd
-- - No Profit otherwise
SELECT *,
       CASE 
           WHEN price_usd > cogs_usd THEN 'Profit'
           ELSE 'No Profit'
       END AS profit_status
FROM orders;
-- Q9. Display every website session with a new column called session_type:
-- - New if is_repeat_session = 0
-- - Repeat if is_repeat_session = 1
SELECT *,
       CASE 
           WHEN is_repeat_session = 0 THEN 'New'
           WHEN is_repeat_session = 1 THEN 'Repeat'
       END AS session_type
FROM website_sessions;
-- Q10. Display every order with a new column called order_size:
-- - Small if items_purchased = 1
-- - Large if items_purchased = 2
SELECT *,
       CASE 
           WHEN items_purchased = 1 THEN 'Small'
           WHEN items_purchased = 2 THEN 'Large'
       END AS order_size
FROM orders;

-- 🟡 MEDIUM — Q11–Q20
-- Q11. Find the number of unique customers in the orders table.
SELECT COUNT(DISTINCT user_id) AS unique_customers
FROM orders;
-- Q12. Find the number of unique products that have appeared in order_items.
SELECT COUNT(DISTINCT product_id) AS unique_products
FROM order_items;
-- Q13. Find the number of unique website sessions that resulted in an order.
SELECT COUNT(DISTINCT website_session_id) AS sessions_with_orders
FROM orders;
-- Q14. Display each order with: order_id, price_usd, cogs_usd, a calculated profit
-- - a profit_category:
--   - High Profit if profit > 50
--   - Low Profit otherwise
SELECT 
    order_id,
    price_usd,
    cogs_usd,
    (price_usd - cogs_usd) AS profit,
    CASE 
        WHEN (price_usd - cogs_usd) > 50 THEN 'High Profit'
        ELSE 'Low Profit'
    END AS profit_category
FROM orders;

-- Q15. Categorize orders based on price:
-- - Low → price < 50
-- - Medium → 50–100
-- - High → > 100
-- Display order_id, price_usd, and the category.
SELECT 
    order_id,
    price_usd,
    CASE 
        WHEN price_usd < 50 THEN 'Low'
        WHEN price_usd BETWEEN 50 AND 100 THEN 'Medium'
        WHEN price_usd > 100 THEN 'High'
    END AS price_category
FROM orders;

-- Q16. Categorize customers based on their order price:
-- - Budget Order → price < 50
-- - Regular Order → 50–100
-- - Premium Order → > 100
-- Display user_id, order_id, price_usd, and the category.
SELECT 
    user_id,
    order_id,
    price_usd,
    CASE 
        WHEN price_usd < 50 THEN 'Budget Order'
        WHEN price_usd BETWEEN 50 AND 100 THEN 'Regular Order'
        WHEN price_usd > 100 THEN 'Premium Order'
    END AS category
FROM orders;

-- Q17. Categorize website sessions:
-- - New Session
-- - Repeat Session
-- Then count how many sessions belong to each category.
SELECT 
    CASE 
        WHEN is_repeat_session = 0 THEN 'New Session'
        WHEN is_repeat_session = 1 THEN 'Repeat Session'
    END AS session_category,
    COUNT(*) AS session_count
FROM website_sessions
GROUP BY 
    CASE 
        WHEN is_repeat_session = 0 THEN 'New Session'
        WHEN is_repeat_session = 1 THEN 'Repeat Session'
    END;

-- Q18. Categorize orders as:
-- - Profitable if profit > 0
-- - Loss if profit < 0
-- - Break Even if profit = 0
-- Show the category and number of orders in each category.
SELECT 
    CASE 
        WHEN (price_usd - cogs_usd) > 0 THEN 'Profitable'
        WHEN (price_usd - cogs_usd) < 0 THEN 'Loss'
        ELSE 'Break Even'
    END AS profit_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 
    CASE 
        WHEN (price_usd - cogs_usd) > 0 THEN 'Profitable'
        WHEN (price_usd - cogs_usd) < 0 THEN 'Loss'
        ELSE 'Break Even'
    END;

-- Q19. Find the number of unique customers who have placed orders with price_usd > 100.
SELECT COUNT(DISTINCT user_id) AS unique_premium_customers
FROM orders
WHERE price_usd > 100;

-- Q20. Find the number of unique products in order_items where the product was purchased as a primary item (is_primary_item = 1).
SELECT COUNT(DISTINCT product_id) AS unique_primary_products
FROM order_items
WHERE is_primary_item = 1;

-- 🔴 HARD — Q21–Q30
-- Q21. For every customer, calculate their total number of orders and classify them:
-- - One-time Customer → 1 order
-- - Repeat Customer → more than 1 order
-- Display user_id, order count, and category.
SELECT 
    user_id,
    COUNT(*) AS order_count,
    CASE 
        WHEN COUNT(*) = 1 THEN 'One-time Customer'
        WHEN COUNT(*) > 1 THEN 'Repeat Customer'
    END AS category
FROM orders
GROUP BY user_id;

-- Q22. For every customer, calculate total revenue and classify them:
-- - Low Value → total revenue < 100
-- - Medium Value → 100–200
-- - High Value → > 200
-- Display user_id, total revenue, and category.
SELECT 
    user_id,
    SUM(price_usd) AS total_revenue,
    CASE 
        WHEN SUM(price_usd) < 100 THEN 'Low Value'
        WHEN SUM(price_usd) BETWEEN 100 AND 200 THEN 'Medium Value'
        WHEN SUM(price_usd) > 200 THEN 'High Value'
    END AS category
FROM orders
GROUP BY user_id;

-- Q23. For every product, calculate total revenue and classify the product:
-- - Low Revenue → < 500
-- - Medium Revenue → 500–1000
-- - High Revenue → > 1000
-- Display primary_product_id, total revenue, and category.
SELECT 
    primary_product_id,
    SUM(price_usd) AS total_revenue,
    CASE 
        WHEN SUM(price_usd) < 500 THEN 'Low Revenue'
        WHEN SUM(price_usd) BETWEEN 500 AND 1000 THEN 'Medium Revenue'
        WHEN SUM(price_usd) > 1000 THEN 'High Revenue'
    END AS category
FROM orders
GROUP BY primary_product_id;

-- Q24. For every customer, calculate total profit and classify them:
-- - Loss → total profit < 0
-- - Low Profit → 0–100
-- - High Profit → > 100
-- Display user_id, total profit, and category.
SELECT 
    user_id,
    SUM(price_usd-cogs_usd) AS total_profit,
    CASE 
        WHEN SUM(price_usd-cogs_usd) < 0 THEN 'Loss'
        WHEN SUM(price_usd-cogs_usd) BETWEEN 0 AND 100 THEN 'Low Profit'
        WHEN SUM(price_usd-cogs_usd) > 100 THEN 'High Profit'
    END AS category
FROM orders
GROUP BY user_id;

-- Q25. Find the number of customers in each customer category:
-- - One-time Customer
-- - Repeat Customer
WITH customer_counts AS (
    SELECT 
        user_id,
        CASE 
            WHEN COUNT(*) = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS category
    FROM orders
    GROUP BY user_id
)
SELECT 
    category,
    COUNT(*) AS number_of_customers
FROM customer_counts
GROUP BY category;

-- Q26. Find the number of orders in each price category:
-- - Low → < 50
-- - Medium → 50–100
-- - High → > 100
-- Return category and number of orders.
SELECT 
    CASE 
        WHEN price_usd < 50 THEN 'Low'
        WHEN price_usd BETWEEN 50 AND 100 THEN 'Medium'
        WHEN price_usd > 100 THEN 'High'
    END AS category,
    COUNT(order_id) AS number_of_orders
FROM orders
GROUP BY 
    CASE 
        WHEN price_usd < 50 THEN 'Low'
        WHEN price_usd BETWEEN 50 AND 100 THEN 'Medium'
        WHEN price_usd > 100 THEN 'High'
    END;

-- Q27. For each device_type, calculate:
-- - total sessions
-- - repeat sessions
-- - new sessions
-- Use CASE WHEN to identify new/repeat sessions.
SELECT
    device_type,
    COUNT(*) AS total_sessions,
    COUNT(CASE
        WHEN is_repeat_session = 0 THEN 1
    END) AS new_sessions,
    COUNT(CASE
        WHEN is_repeat_session = 1 THEN 1
    END) AS repeat_sessions
FROM website_sessions
GROUP BY device_type;

-- Q28. For each customer, calculate:
-- - total orders
-- - total revenue
-- - total profit
-- - customer segment:
--   - Low Value → revenue < 100
--   - Medium Value → 100–200
--   - High Value → > 200
SELECT 
    user_id,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_profit,
    CASE 
        WHEN SUM(price_usd) < 100 THEN 'Low Value'
        WHEN SUM(price_usd) BETWEEN 100 AND 200 THEN 'Medium Value'
        WHEN SUM(price_usd) > 200 THEN 'High Value'
    END AS customer_segment
FROM orders
GROUP BY user_id;

-- Q29. Find the number of unique customers in each revenue category:
-- - Low Value → total revenue < 100
-- - Medium Value → 100–200
-- - High Value → > 200
SELECT
    revenue_category,
    COUNT(*) AS customer_count
FROM (
    SELECT
        user_id,
        CASE
            WHEN SUM(price_usd) < 100 THEN 'Low Value'
            WHEN SUM(price_usd) <= 200 THEN 'Medium Value'
            ELSE 'High Value'
        END AS revenue_category
    FROM orders
    GROUP BY user_id
) AS customer_categories
GROUP BY revenue_category;
-- Q30. 🔥 Challenge
-- For each customer, calculate:
-- - user_id
-- - total orders
-- - total revenue
-- - average order price
-- - total profit
-- - customer type:
--   - One-time Low Value
--   - One-time High Value
--   - Repeat Low Value
--   - Repeat High Value
-- Where:
-- - One-time = exactly 1 order
-- - Repeat = more than 1 order
-- - Low Value = total revenue ≤ 200
-- - High Value = total revenue > 200
-- Sort customers by total revenue descending.
SELECT
    user_id,
    COUNT(order_id) AS total_orders,
    SUM(price_usd) AS total_revenue,
    AVG(price_usd) AS average_order_price,
    SUM(price_usd - cogs_usd) AS total_profit,
    CASE
        WHEN COUNT(order_id) = 1
             AND SUM(price_usd) <= 200
            THEN 'ONE_TIME LOW_VAL'

        WHEN COUNT(order_id) = 1
             AND SUM(price_usd) > 200
            THEN 'ONE_TIME HIGH_VAL'

        WHEN COUNT(order_id) > 1
             AND SUM(price_usd) <= 200
            THEN 'REPEAT LOW_VAL'

        WHEN COUNT(order_id) > 1
             AND SUM(price_usd) > 200
            THEN 'REPEAT HIGH_VAL'
    END AS cust_type
FROM orders
GROUP BY user_id
ORDER BY SUM(price_usd) DESC;
