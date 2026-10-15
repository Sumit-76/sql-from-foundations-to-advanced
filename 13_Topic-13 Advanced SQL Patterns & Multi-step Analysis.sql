-- Easy — Q1–Q10
-- 1. Find each customer's total revenue and total number of orders.
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY USER_ID;
-- 2. Find customers whose total revenue exceeds $500. Display their user ID and total revenue.
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD) > 500;
-- 3. Find each product's total revenue and total number of items sold. Sort by revenue from highest to lowest.
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_REV,COUNT(*) AS TOTAL_ITEMS_SOLD
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
ORDER BY SUM(PRICE_USD) DESC; 

-- 4. Find the average order revenue across all orders, then display orders whose revenue is above that average.
SELECT order_id, user_id, price_usd
FROM orders
WHERE price_usd > (
    SELECT AVG(price_usd)
    FROM orders
);
-- 5. Find each customer's first order date and most recent order date.
SELECT USER_ID,MIN(CREATED_AT)AS FIRST_ORDER_DATE,MAX(CREATED_AT)AS RECENT_ORDER_DATE
FROM ORDERS
GROUP BY USER_ID;
-- 6. Find each website session's pageview count and identify sessions with more than three pageviews.
SELECT WEBSITE_SESSION_ID,COUNT(*)AS WS_PAGEVIEW_COUNT 
FROM WEBSITE_PAGEVIEWS
GROUP BY WEBSITE_SESSION_ID
HAVING COUNT(*) > 3;
-- 7. Find each customer's total revenue and total profit. Treat a NULL cost of goods sold as zero when calculating profit.
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV,SUM(PRICE_USD-COALESCE(COGS_USD,0))AS TOTAL_PROFIT
FROM ORDERS
GROUP BY USER_ID;
-- 8. Find the top three customers by revenue, including their user ID, total revenue, and order count.
SELECT USER_ID,SUM(PRICE_USD) AS TOTAL_REV,COUNT(*)AS TOTAL_ORDERS
FROM ORDERS
GROUP BY USER_ID
ORDER BY SUM(PRICE_USD) DESC
LIMIT 3;
-- 9. Find each product's revenue and the percentage of overall order-item revenue it contributes.
WITH product_revenue AS (
    SELECT
        product_id,
        SUM(price_usd) AS product_revenue
    FROM order_items
    GROUP BY product_id
)
SELECT
    product_id,
    product_revenue,
    product_revenue * 100.0 /
        NULLIF(SUM(product_revenue) OVER (), 0)
        AS contribution_percentage
FROM product_revenue
ORDER BY product_revenue DESC;

-- 10. Find customers who have placed at least two orders and have total revenue greater than $300.
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV,COUNT(*)AS NO_OF_ORDERS
FROM ORDERS
GROUP BY USER_ID
HAVING SUM(PRICE_USD) > 300 AND COUNT(*) >=2;

-- Medium — Q11–Q20
-- 11. Find customers whose total revenue is greater than the average revenue per customer. Return user ID, total revenue, and the average customer revenue benchmark.
WITH CUS_LEV AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
)
SELECT *
FROM CUS_LEV
WHERE TOTAL_REV > (SELECT AVG(TOTAL_REV)AS AVG_CUSTOMER_REV FROM CUS_LEV);
-- 12. Find each traffic source's total sessions, unique users, orders, and revenue. Include sessions even if they have no orders.
SELECT
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT ws.user_id) AS unique_users,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.price_usd), 0) AS revenue
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
ORDER BY revenue DESC;
-- 13. Find the conversion rate for each traffic source, defined as the percentage of sessions associated with at least one order. Count each session only once.
SELECT
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS converted_sessions,
    COUNT(DISTINCT o.website_session_id) * 100.0
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0)
        AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
ORDER BY conversion_rate_pct DESC;
-- 14. Find the top two products by revenue within each product category. The available products table has no category column, so first identify what extra data would be needed; then solve using product-level revenue without inventing categories.
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.price_usd) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 2;
		
-- 15. Find customers who made their first purchase in 2014 and calculate their total revenue from orders placed during 2014.
WITH first_purchase AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order_date
    FROM orders
    GROUP BY user_id
)
SELECT
    o.user_id,
    SUM(o.price_usd) AS revenue_2014
FROM orders o
JOIN first_purchase fp
    ON o.user_id = fp.user_id
WHERE fp.first_order_date >= DATE '2014-01-01'
  AND fp.first_order_date < DATE '2015-01-01'
  AND o.created_at >= DATE '2014-01-01'
  AND o.created_at < DATE '2015-01-01'
GROUP BY o.user_id;
-- 16. Find the percentage of each customer's orders that have a value above $100.
--We need the percentage of each customer's orders with an order value above $100. 
--The denominator is all orders for that customer; the numerator is only orders above $100
SELECT
    user_id,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE price_usd > 100
    ) AS orders_over_100,
    COUNT(*) FILTER (
        WHERE price_usd > 100
    ) * 100.0 / NULLIF(COUNT(*), 0)
        AS percentage_over_100
FROM orders
GROUP BY user_id;
-- 17. Find products whose revenue is above the average product revenue, returning product ID, product name, and revenue.
WITH PRO_LEV AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
),
PRO_LEV2 AS
(SELECT PRODUCT_ID,TOTAL_REV
FROM PRO_LEV
WHERE TOTAL_REV >(SELECT AVG(TOTAL_REV) FROM PRO_LEV))
SELECT PL2.PRODUCT_ID,P.PRODUCT_NAME,PL2.TOTAL_REV
FROM PRO_LEV2 PL2
LEFT JOIN PRODUCTS P
ON PL2.PRODUCT_ID=P.PRODUCT_ID;
-- 18. Compare total revenue and order count for repeat-session users versus non-repeat-session users. Count each order once.
SELECT
    CASE
        WHEN ws.is_repeat_session = 1 THEN 'Repeat'
        ELSE 'Non-repeat'
    END AS session_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.price_usd), 0) AS total_revenue
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY
    CASE
        WHEN ws.is_repeat_session = 1 THEN 'Repeat'
        ELSE 'Non-repeat'
    END;

-- 19. Find sessions that viewed the /products page but did not place an order in that session.
SELECT DISTINCT
    wp.website_session_id
FROM website_pageviews wp
WHERE wp.pageview_url = '/products'
  AND NOT EXISTS (
      SELECT 1
      FROM orders o
      WHERE o.website_session_id = wp.website_session_id
  );
-- 20. For each month, calculate revenue and the absolute and percentage change from the previous month. Handle the first month and any zero-revenue comparison correctly.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)
),
monthly_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month)
            AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    revenue - previous_month_revenue AS absolute_change,
    (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0)
        AS percentage_change
FROM monthly_comparison
ORDER BY month;
-- Hard — Q21–Q30
-- 21. Find customers who have placed at least three orders, have total revenue above $500, and have an average order value above $150.
SELECT USER_ID,COUNT(*)TOTAL_ORDERS,SUM(PRICE_USD)AS TOTAL_REV,AVG(PRICE_USD)AS AVG_ORDER_PRICE
FROM ORDERS
GROUP BY USER_ID
HAVING COUNT(*)>=3 AND SUM(PRICE_USD) > 500 AND AVG(PRICE_USD) >150;
-- 22. Find each customer's first order, last order, total revenue, and number of days between their first and last orders.
SELECT user_id,MIN(CREATED_AT)AS FIRST_ORDER,MAX(CREATED_AT)AS LAST_ORDER,SUM(PRICE_USD)AS TOTAL_REVENUE,MAX(created_at)::date - MIN(created_at)::date AS days_between
FROM ORDERS
GROUP BY USER_ID;
-- 23. Calculate each product's total revenue, refunded amount, and net revenue. Use the appropriate order-item and refund relationships so item-level refunds are not incorrectly duplicated.
WITH product_revenue AS (
    SELECT
        product_id,
        SUM(price_usd) AS total_revenue
    FROM order_items
    GROUP BY product_id
),
product_refunds AS (
    SELECT
        oi.product_id,
        SUM(r.refund_amount_usd) AS refunded_amount
    FROM order_item_refunds r
    JOIN order_items oi
        ON r.order_item_id = oi.order_item_id
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    pr.total_revenue,
    COALESCE(pf.refunded_amount, 0) AS refunded_amount,
    pr.total_revenue - COALESCE(pf.refunded_amount, 0)
        AS net_revenue
FROM product_revenue pr
JOIN products p
    ON pr.product_id = p.product_id
LEFT JOIN product_refunds pf
    ON pr.product_id = pf.product_id
ORDER BY net_revenue DESC;
-- 24. Find the top 10 sessions by pageview count and determine whether each session resulted in an order. Return session ID, pageviews, and an order indicator.
WITH session_pageviews AS (
    SELECT
        website_session_id,
        COUNT(*) AS pageview_count
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT
    sp.website_session_id,
    sp.pageview_count,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM orders o
            WHERE o.website_session_id = sp.website_session_id
        ) THEN 'Yes'
        ELSE 'No'
    END AS placed_order
FROM session_pageviews sp
ORDER BY sp.pageview_count DESC, sp.website_session_id
LIMIT 10;
-- 25. Find customers whose revenue in their most recent calendar year of purchasing exceeded their revenue in the previous calendar year. Return both yearly revenue values and the percentage change.
-- The trick is to aggregate revenue by customer and year first, then compare the latest year with the immediately preceding calendar year.
WITH yearly_revenue AS (
    SELECT
        user_id,
        EXTRACT(YEAR FROM created_at)::int AS order_year,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY
        user_id,
        EXTRACT(YEAR FROM created_at)::int
),
latest_year AS (
    SELECT
        user_id,
        MAX(order_year) AS latest_year
    FROM yearly_revenue
    GROUP BY user_id
)
SELECT
    ly.user_id,
    ly.latest_year,
    current_year.revenue AS latest_year_revenue,
    previous_year.revenue AS previous_year_revenue,
    (current_year.revenue - previous_year.revenue) * 100.0
        / NULLIF(previous_year.revenue, 0) AS percentage_change
FROM latest_year ly
JOIN yearly_revenue current_year
    ON current_year.user_id = ly.user_id
   AND current_year.order_year = ly.latest_year
JOIN yearly_revenue previous_year
    ON previous_year.user_id = ly.user_id
   AND previous_year.order_year = ly.latest_year - 1
WHERE current_year.revenue > previous_year.revenue;
-- 26. Identify customers who purchased a product more than once across separate orders. Return user ID, product ID, purchase count, and total spending on that product.
SELECT
    o.user_id,
    oi.product_id,
    COUNT(DISTINCT oi.order_id) AS purchase_count,
    SUM(oi.price_usd) AS total_spending
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
GROUP BY o.user_id, oi.product_id
HAVING COUNT(DISTINCT oi.order_id) > 1
ORDER BY purchase_count DESC, total_spending DESC;
-- 27. For each traffic source, calculate session-to-order conversion rate, revenue per session, and average order value. Ensure that joins do not inflate session counts or revenue.
SELECT
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS converted_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.price_usd), 0) AS total_revenue,
    COUNT(DISTINCT o.website_session_id) * 100.0
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0)
        AS conversion_rate_pct,
    COALESCE(SUM(o.price_usd), 0)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0)
        AS revenue_per_session,
    SUM(o.price_usd)
        / NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS average_order_value
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
ORDER BY total_revenue DESC;
-- 28. Find the highest-revenue product for each month. If two products tie for the highest revenue, include both.
WITH monthly_product_revenue AS (
    SELECT
        DATE_TRUNC('month', oi.created_at)::date AS month,
        oi.product_id,
        SUM(oi.price_usd) AS revenue
    FROM order_items oi
    GROUP BY
        DATE_TRUNC('month', oi.created_at)::date,
        oi.product_id
),
ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY month
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM monthly_product_revenue
)
SELECT
    month,
    product_id,
    revenue
FROM ranked_products
WHERE revenue_rank = 1
ORDER BY month, product_id;
-- 29. Identify customers whose latest order value is greater than their own average order value across all orders. Return customer ID, latest order ID, latest order value, and historical average order value.
WITH customer_orders AS (
    SELECT
        order_id,
        user_id,
        created_at,
        price_usd,
        AVG(price_usd) OVER (
            PARTITION BY user_id
        ) AS average_order_value,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at DESC, order_id DESC
        ) AS recency_rank
    FROM orders
)
SELECT
    user_id,
    order_id AS latest_order_id,
    price_usd AS latest_order_value,
    average_order_value
FROM customer_orders
WHERE recency_rank = 1
  AND price_usd > average_order_value;
-- 30. Build a customer-level analysis that returns user ID, order count, total revenue, total profit, average order value, first order date, and most recent order date. Include customers with sessions but no orders, label missing metrics appropriately, and rank purchasing customers by total revenue.
WITH session_users AS (
    SELECT DISTINCT user_id
    FROM website_sessions
    WHERE user_id IS NOT NULL
),
customer_orders AS (
    SELECT
        user_id,
        COUNT(*) AS order_count,
        SUM(price_usd) AS total_revenue,
        SUM(price_usd - COALESCE(cogs_usd, 0)) AS total_profit,
        AVG(price_usd) AS average_order_value,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS most_recent_order_date
    FROM orders
    GROUP BY user_id
),
ranked_customers AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM customer_orders
)
SELECT
    su.user_id,
    COALESCE(rc.order_count, 0) AS order_count,
    COALESCE(rc.total_revenue, 0) AS total_revenue,
    COALESCE(rc.total_profit, 0) AS total_profit,
    COALESCE(rc.average_order_value, 0) AS average_order_value,
    rc.first_order_date,
    rc.most_recent_order_date,
    CASE
        WHEN rc.user_id IS NULL THEN 'No orders'
        ELSE 'Has orders'
    END AS order_status,
    rc.revenue_rank
FROM session_users su
LEFT JOIN ranked_customers rc
    ON su.user_id = rc.user_id
ORDER BY rc.revenue_rank NULLS LAST, su.user_id;
