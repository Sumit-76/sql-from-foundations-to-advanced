-- Topic 5: JOINs

-- 🟢 EASY — Q1–Q10

-- Q1 Display order_id and the product_name for every order.
-- Uses orders.primary_product_id to identify the primary product on the order.
SELECT o.order_id, p.product_name
FROM orders AS o
LEFT JOIN products AS p
    ON o.primary_product_id = p.product_id;

-- Q2 Display order_id, price_usd, and product_name for every order.
SELECT o.order_id, o.price_usd, p.product_name
FROM orders AS o
LEFT JOIN products AS p
    ON o.primary_product_id = p.product_id;

-- Q3 Display every product with product_id, product_name, and order_id.
-- Include products that have no matching order.
SELECT p.product_id, p.product_name, o.order_id
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.primary_product_id
ORDER BY p.product_id, o.order_id;

-- Q4 Display every order with order_id, website_session_id, user_id, and utm_source.
SELECT o.order_id, o.website_session_id, o.user_id, ws.utm_source
FROM orders AS o
LEFT JOIN website_sessions AS ws
    ON o.website_session_id = ws.website_session_id;

-- Q5 Display every website session with website_session_id, user_id, and order_id.
-- Include sessions that did not result in an order.
SELECT ws.website_session_id, ws.user_id, o.order_id
FROM website_sessions AS ws
LEFT JOIN orders AS o
    ON ws.website_session_id = o.website_session_id
ORDER BY ws.website_session_id, o.order_id;

-- Q6 Display order_item_id, order_id, product_id, and product_name for every order item.
SELECT oi.order_item_id, oi.order_id, oi.product_id, p.product_name
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id;

-- Q7 Display order_item_id, product_name, and price_usd for every order item.
SELECT oi.order_item_id, p.product_name, oi.price_usd
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id;

-- Q8 Display each refund and its corresponding product_id.
SELECT r.order_item_refund_id, r.order_id, r.order_item_id,
       r.refund_amount_usd, oi.product_id
FROM order_item_refunds AS r
LEFT JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id;

-- Q9 Display website_pageview_id, website_session_id, and user_id for every pageview.
SELECT wp.website_pageview_id, wp.website_session_id, ws.user_id
FROM website_pageviews AS wp
LEFT JOIN website_sessions AS ws
    ON wp.website_session_id = ws.website_session_id;

-- Q10 Display every website session and its pageviews.
-- Include sessions that have no pageviews.
SELECT ws.website_session_id, ws.user_id,
       wp.website_pageview_id, wp.pageview_url
FROM website_sessions AS ws
LEFT JOIN website_pageviews AS wp
    ON ws.website_session_id = wp.website_session_id
ORDER BY ws.website_session_id, wp.website_pageview_id;


-- 🟡 MEDIUM — Q11–Q20

-- Q11 Display each product name and the number of order items associated with it.
-- Products with no order items are included.
SELECT p.product_name, COUNT(oi.order_item_id) AS order_item_count
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY order_item_count DESC, p.product_name;

-- Q12 Display each product name and its total revenue from order_items.
SELECT p.product_name, COALESCE(SUM(oi.price_usd), 0) AS total_revenue
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- Q13 Display each order with product_name, price_usd, cogs_usd, and calculated profit.
SELECT o.order_id, p.product_name, o.price_usd, o.cogs_usd,
       o.price_usd - o.cogs_usd AS profit
FROM orders AS o
LEFT JOIN products AS p
    ON o.primary_product_id = p.product_id;

-- Q14 Display each user and the number of orders they placed, including users with zero orders.
SELECT u.user_id, COUNT(o.order_id) AS total_orders
FROM users AS u
LEFT JOIN orders AS o
    ON u.user_id = o.user_id
GROUP BY u.user_id
ORDER BY total_orders DESC, u.user_id;

-- Q15 Display each utm_source and the number of orders that came from that source.
SELECT ws.utm_source, COUNT(o.order_id) AS total_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
ORDER BY total_orders DESC;

-- Q16 Display each product name, number of orders, total revenue, and total profit.
-- Aggregate order_items first to avoid mixing product-level metrics with order-level rows.
SELECT p.product_name,
       COUNT(DISTINCT oi.order_id) AS number_of_orders,
       COALESCE(SUM(oi.price_usd), 0) AS total_revenue,
       COALESCE(SUM(oi.price_usd - oi.cogs_usd), 0) AS total_profit
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- Q17 Display each device_type and total sessions and total orders.
SELECT ws.device_type,
       COUNT(DISTINCT ws.website_session_id) AS total_sessions,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM website_sessions AS ws
LEFT JOIN orders AS o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY total_sessions DESC;

-- Q18 Display each product name and the total amount refunded for that product.
SELECT p.product_name,
       COALESCE(SUM(r.refund_amount_usd), 0) AS total_refunds
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds AS r
    ON oi.order_item_id = r.order_item_id
GROUP BY p.product_id, p.product_name
ORDER BY total_refunds DESC;

-- Q19 Display each user_id and their total revenue from orders.
SELECT u.user_id, COALESCE(SUM(o.price_usd), 0) AS total_revenue
FROM users AS u
LEFT JOIN orders AS o
    ON u.user_id = o.user_id
GROUP BY u.user_id
ORDER BY total_revenue DESC;

-- Q20 Display each product name and the number of unique orders containing that product.
SELECT p.product_name, COUNT(DISTINCT oi.order_id) AS unique_order_count
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY unique_order_count DESC;


-- 🔴 HARD — Q21–Q30

-- Q21 For each product, display item count, revenue, COGS, and profit.
-- Sort by total profit descending.
SELECT p.product_name,
       COUNT(oi.order_item_id) AS number_of_order_items,
       COALESCE(SUM(oi.price_usd), 0) AS total_revenue,
       COALESCE(SUM(oi.cogs_usd), 0) AS total_cogs,
       COALESCE(SUM(oi.price_usd - oi.cogs_usd), 0) AS total_profit
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_profit DESC;

-- Q22 For each utm_source, display total sessions, total orders, and total revenue.
-- Aggregate sessions separately so joins do not inflate session counts.
WITH session_metrics AS (
    SELECT utm_source,
           COUNT(DISTINCT website_session_id) AS total_sessions
    FROM website_sessions
    GROUP BY utm_source
),
order_metrics AS (
    SELECT ws.utm_source,
           COUNT(o.order_id) AS total_orders,
           COALESCE(SUM(o.price_usd), 0) AS total_revenue
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    GROUP BY ws.utm_source
)
SELECT sm.utm_source, sm.total_sessions,
       COALESCE(om.total_orders, 0) AS total_orders,
       COALESCE(om.total_revenue, 0) AS total_revenue
FROM session_metrics AS sm
LEFT JOIN order_metrics AS om
    ON sm.utm_source IS NOT DISTINCT FROM om.utm_source
ORDER BY total_revenue DESC;

-- Q23 For each device_type, display total sessions, unique users, total orders, and total revenue.
SELECT ws.device_type,
       COUNT(DISTINCT ws.website_session_id) AS total_sessions,
       COUNT(DISTINCT ws.user_id) AS unique_users,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COALESCE(SUM(o.price_usd), 0) AS total_revenue
FROM website_sessions AS ws
LEFT JOIN orders AS o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY total_revenue DESC;

-- Q24 For each product, display revenue, refunds, and net revenue.
-- Net revenue = revenue - refunds.
WITH product_revenue AS (
    SELECT product_id, SUM(price_usd) AS total_revenue
    FROM order_items
    GROUP BY product_id
),
product_refunds AS (
    SELECT oi.product_id, SUM(r.refund_amount_usd) AS total_refunds
    FROM order_items AS oi
    JOIN order_item_refunds AS r
        ON oi.order_item_id = r.order_item_id
    GROUP BY oi.product_id
)
SELECT p.product_name,
       COALESCE(pr.total_revenue, 0) AS total_revenue,
       COALESCE(pf.total_refunds, 0) AS total_refunds,
       COALESCE(pr.total_revenue, 0) - COALESCE(pf.total_refunds, 0) AS net_revenue
FROM products AS p
LEFT JOIN product_revenue AS pr ON p.product_id = pr.product_id
LEFT JOIN product_refunds AS pf ON p.product_id = pf.product_id
ORDER BY net_revenue DESC;

-- Q25 For each user, display number of sessions, number of orders, and total revenue.
-- Aggregate sessions and orders separately to avoid row multiplication.
WITH user_sessions AS (
    SELECT user_id, COUNT(DISTINCT website_session_id) AS number_of_sessions
    FROM website_sessions
    GROUP BY user_id
),
user_orders AS (
    SELECT user_id, COUNT(order_id) AS number_of_orders,
           SUM(price_usd) AS total_revenue
    FROM orders
    GROUP BY user_id
)
SELECT u.user_id,
       COALESCE(us.number_of_sessions, 0) AS number_of_sessions,
       COALESCE(uo.number_of_orders, 0) AS number_of_orders,
       COALESCE(uo.total_revenue, 0) AS total_revenue
FROM users AS u
LEFT JOIN user_sessions AS us ON u.user_id = us.user_id
LEFT JOIN user_orders AS uo ON u.user_id = uo.user_id
ORDER BY total_revenue DESC;

-- Q26 For each product, display number of unique orders, total revenue, and average selling price.
SELECT p.product_name,
       COUNT(DISTINCT oi.order_id) AS unique_orders,
       COALESCE(SUM(oi.price_usd), 0) AS total_revenue,
       AVG(oi.price_usd) AS average_selling_price
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- Q27 For each utm_source, display sessions, unique users, orders, revenue, and profit.
WITH session_metrics AS (
    SELECT utm_source,
           COUNT(DISTINCT website_session_id) AS number_of_sessions,
           COUNT(DISTINCT user_id) AS unique_users
    FROM website_sessions
    GROUP BY utm_source
),
order_metrics AS (
    SELECT ws.utm_source,
           COUNT(o.order_id) AS number_of_orders,
           COALESCE(SUM(o.price_usd), 0) AS total_revenue,
           COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit
    FROM website_sessions AS ws
    LEFT JOIN orders AS o ON ws.website_session_id = o.website_session_id
    GROUP BY ws.utm_source
)
SELECT sm.utm_source, sm.number_of_sessions, sm.unique_users,
       COALESCE(om.number_of_orders, 0) AS number_of_orders,
       COALESCE(om.total_revenue, 0) AS total_revenue,
       COALESCE(om.total_profit, 0) AS total_profit
FROM session_metrics AS sm
LEFT JOIN order_metrics AS om
    ON sm.utm_source IS NOT DISTINCT FROM om.utm_source
ORDER BY total_revenue DESC;

-- Q28 Find products whose total revenue is greater than 1,000.
SELECT p.product_name, SUM(oi.price_usd) AS total_revenue
FROM products AS p
JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.price_usd) > 1000
ORDER BY total_revenue DESC;

-- Q29 Find utm_source values with more than 100 orders and revenue above 5,000.
SELECT ws.utm_source,
       COUNT(o.order_id) AS total_orders,
       SUM(o.price_usd) AS total_revenue
FROM website_sessions AS ws
JOIN orders AS o ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
HAVING COUNT(o.order_id) > 100
   AND SUM(o.price_usd) > 5000
ORDER BY total_revenue DESC;

-- Q30 For each product, display total orders, revenue, refunds, net revenue, and profit.
-- Refunds are aggregated separately so they do not duplicate order-item revenue/profit.
WITH product_sales AS (
    SELECT product_id,
           COUNT(DISTINCT order_id) AS total_orders,
           SUM(price_usd) AS total_revenue,
           SUM(cogs_usd) AS total_cogs,
           SUM(price_usd - cogs_usd) AS total_profit
    FROM order_items
    GROUP BY product_id
),
product_refunds AS (
    SELECT oi.product_id, SUM(r.refund_amount_usd) AS total_refunds
    FROM order_items AS oi
    JOIN order_item_refunds AS r ON oi.order_item_id = r.order_item_id
    GROUP BY oi.product_id
)
SELECT p.product_name,
       COALESCE(ps.total_orders, 0) AS total_orders,
       COALESCE(ps.total_revenue, 0) AS total_revenue,
       COALESCE(pf.total_refunds, 0) AS total_refunds,
       COALESCE(ps.total_revenue, 0) - COALESCE(pf.total_refunds, 0) AS net_revenue,
       COALESCE(ps.total_profit, 0) AS total_profit
FROM products AS p
LEFT JOIN product_sales AS ps ON p.product_id = ps.product_id
LEFT JOIN product_refunds AS pf ON p.product_id = pf.product_id
ORDER BY net_revenue DESC;
