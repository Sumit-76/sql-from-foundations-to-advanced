-- Easy — Q1–Q10
-- 1. For every order, display order_id, user_id, price_usd, and the user's average order price using a window function.
SELECT ORDER_ID,USER_ID,PRICE_USD,AVG(PRICE_USD) OVER(PARTITION BY USER_ID)AS USERS_AVG_ORDER_PRICE
FROM ORDERS;
-- 2. Display every order along with the user's total revenue. Keep individual orders in the result.
SELECT ORDER_ID,USER_ID,SUM(PRICE_USD) OVER(PARTITION BY USER_ID)AS TOTAL_REV
FROM ORDERS;
-- 3. Assign ROW_NUMBER() to each user's orders, ordered from oldest to newest.
SELECT ORDER_ID,USER_ID,CREATED_AT,ROW_NUMBER()OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)AS OLDEST_TO_NEWEST
FROM ORDERS;
-- 4. Rank all products by total revenue using RANK().
WITH PRO_REV AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
)
SELECT PRODUCT_ID,TOTAL_REV,RANK()OVER( ORDER BY TOTAL_REV DESC)AS RANK_TOTAL_REV
FROM PRO_REV;
-- 5. Show each order's price and the previous order's price for the same user.
SELECT USER_ID,CREATED_AT,PRICE_USD,LAG(PRICE_USD)OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)AS PREV_ORDER_PRICE
FROM ORDERS;
-- 6. Show each order's price and the next order's price for the same user.
SELECT USER_ID,CREATED_AT,PRICE_USD,LEAD(PRICE_USD)OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)AS PREV_ORDER_PRICE
FROM ORDERS;
-- 7. Calculate each order's percentage contribution to the total revenue of all orders.
SELECT
    order_id,
    user_id,
    price_usd,
    price_usd * 100.0 /
        NULLIF(SUM(price_usd) OVER (), 0)
        AS percentage_contribution
FROM orders;
-- 8. Show each user's order price alongside their most expensive order price.
SELECT USER_ID,PRICE_USD,MAX(PRICE_USD) OVER(PARTITION BY USER_ID)
FROM ORDERS;
-- 9. Calculate cumulative revenue ordered by created_at.
SELECT CREATED_AT,PRICE_USD,SUM(PRICE_USD) OVER(ORDER BY CREATED_AT)AS CUMMULATIVE_REV
FROM ORDERS;
-- 10. For each order, display the difference between its price and the user's average order price.
WITH AVG_ORDER_PRICE AS(
SELECT USER_ID,AVG(PRICE_USD)AS AVG_PRICE
FROM ORDERS
GROUP BY USER_ID
)
SELECT A.USER_ID,O.PRICE_USD,A.AVG_PRICE,O.PRICE_USD-A.AVG_PRICE AS PRICE_DIFF
FROM AVG_ORDER_PRICE A
LEFT JOIN ORDERS O
ON A.USER_ID=O.USER_ID;
-- Medium — Q11–Q20
-- 11. Find the top three products by revenue within each month.
WITH monthly_product_revenue AS (
    SELECT
        DATE_TRUNC('month', oi.created_at)::date AS month,
        oi.product_id,
        SUM(oi.price_usd) AS revenue
    FROM order_items AS oi
    GROUP BY
        DATE_TRUNC('month', oi.created_at)::date,
        oi.product_id
),
ranked_products AS (
    SELECT
        month,
        product_id,
        revenue,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY revenue DESC, product_id
        ) AS product_rank
    FROM monthly_product_revenue
)
SELECT month, product_id, revenue, product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY month, product_rank;

-- 12. Calculate monthly revenue and the month-over-month absolute change.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)::date
),
monthly_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    revenue - previous_month_revenue AS absolute_change
FROM monthly_comparison
ORDER BY month;
-- 13. Calculate month-over-month revenue growth as a percentage. Handle a zero previous-month value safely.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)::date
),
monthly_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0) AS growth_percentage
FROM monthly_comparison
ORDER BY month;
-- 14. Calculate a three-row moving average of monthly revenue, including the current month and up to the two preceding rows.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)::date
)
SELECT
    month,
    revenue,
    AVG(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average_3_rows
FROM monthly_revenue
ORDER BY month;
-- 15. Find each user's first order using a window function.
WITH ranked_orders AS (
    SELECT
        order_id,
        user_id,
        created_at,
        price_usd,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at, order_id
        ) AS rn
    FROM orders
)
SELECT order_id, user_id, created_at, price_usd
FROM ranked_orders
WHERE rn = 1;
-- 16. Find each user's most recent order, including order_id, created_at, and price_usd. Resolve timestamp ties using order_id.
WITH ranked_orders AS (
    SELECT
        order_id,
        user_id,
        created_at,
        price_usd,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at DESC, order_id DESC
        ) AS rn
    FROM orders
)
SELECT order_id, user_id, created_at, price_usd
FROM ranked_orders
WHERE rn = 1;
-- 17. Rank users by total revenue and display the top 10 users, preserving tied rankings.
WITH customer_revenue AS (
    SELECT
        user_id,
        SUM(price_usd) AS total_revenue
    FROM orders
    GROUP BY user_id
),
ranked_users AS (
    SELECT
        user_id,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS user_rank
    FROM customer_revenue
)
SELECT user_id, total_revenue, user_rank
FROM ranked_users
WHERE user_rank <= 10
ORDER BY user_rank, user_id;
-- 18. For each product, calculate its revenue and its percentage contribution to total product revenue.
WITH product_revenue AS (
    SELECT
        product_id,
        SUM(price_usd) AS revenue
    FROM order_items
    GROUP BY product_id
)
SELECT
    product_id,
    revenue,
    revenue * 100.0 /
        NULLIF(SUM(revenue) OVER (), 0) AS percentage_contribution
FROM product_revenue
ORDER BY revenue DESC;
-- 19. Display each user's orders with the previous order date and the number of days since that order.
SELECT
    order_id,
    user_id,
    created_at,
    LAG(created_at) OVER (
        PARTITION BY user_id
        ORDER BY created_at, order_id
    ) AS previous_order_date,
    created_at::date
      - (LAG(created_at) OVER (
            PARTITION BY user_id
            ORDER BY created_at, order_id
        ))::date AS days_between_orders
FROM orders
ORDER BY user_id, created_at, order_id;
-- 20. Identify orders whose prices are higher than the user's average order price.
WITH RANKED_ORDERS AS(
SELECT ORDER_ID,USER_ID,PRICE_USD,AVG(PRICE_USD)OVER(PARTITION BY USER_ID)AS USER_AVG_PRICE
FROM ORDERS
)
SELECT *
FROM RANKED_ORDERS
WHERE PRICE_USD>USER_AVG_PRICE;
-- Hard — Q21–Q30
-- 21. Find the top two products by revenue in every month, preserving ties at the second rank.
WITH monthly_product_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        product_id,
        SUM(price_usd) AS revenue
    FROM order_items
    GROUP BY
        DATE_TRUNC('month', created_at)::date,
        product_id
),
ranked_products AS (
    SELECT
        month,
        product_id,
        revenue,
        RANK() OVER (
            PARTITION BY month
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM monthly_product_revenue
)
SELECT month, product_id, revenue, revenue_rank
FROM ranked_products
WHERE revenue_rank <= 2
ORDER BY month, revenue_rank, product_id;
-- 22. Calculate daily revenue and its cumulative total within each calendar year, restarting the cumulative total each year.
WITH daily_revenue AS (
    SELECT
        created_at::date AS order_date,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY created_at::date
)
SELECT
    order_date,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date)
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_yearly_revenue
FROM daily_revenue
ORDER BY order_date;
-- 23. Calculate each month's revenue and a three-month moving average using a ROWS window frame.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)::date
)
SELECT
    month,
    revenue,
    AVG(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average_3_months
FROM monthly_revenue
ORDER BY month;
-- 24. Identify users whose latest order value is greater than their previous order value.
WITH ranked_orders AS (
    SELECT
        order_id,
        user_id,
        created_at,
        price_usd,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at DESC, order_id DESC
        ) AS rn,
        LEAD(price_usd) OVER (
            PARTITION BY user_id
            ORDER BY created_at DESC, order_id DESC
        ) AS previous_order_price
    FROM orders
)
SELECT
    user_id,
    order_id AS latest_order_id,
    price_usd AS latest_order_price,
    previous_order_price
FROM ranked_orders
WHERE rn = 1
  AND price_usd > previous_order_price;
-- 25. Find users whose order revenue increased in three consecutive available monthly observations. State how you handle months with no orders.
WITH monthly_revenue AS (
    SELECT
        user_id,
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY
        user_id,
        DATE_TRUNC('month', created_at)::date
),
comparisons AS (
    SELECT
        user_id,
        month,
        revenue,
        LAG(revenue, 1) OVER (
            PARTITION BY user_id ORDER BY month
        ) AS revenue_1_month_ago,
        LAG(revenue, 2) OVER (
            PARTITION BY user_id ORDER BY month
        ) AS revenue_2_months_ago,
        LAG(revenue, 3) OVER (
            PARTITION BY user_id ORDER BY month
        ) AS revenue_3_months_ago
    FROM monthly_revenue
)
SELECT DISTINCT user_id
FROM comparisons
WHERE revenue > revenue_1_month_ago
  AND revenue_1_month_ago > revenue_2_months_ago
  AND revenue_2_months_ago > revenue_3_months_ago;
-- 26. For each user, calculate total revenue, order count, average order value, and each order's percentage contribution to that user's revenue.
SELECT
    order_id,
    user_id,
    price_usd,
    SUM(price_usd) OVER (
        PARTITION BY user_id
    ) AS total_revenue,
    COUNT(*) OVER (
        PARTITION BY user_id
    ) AS order_count,
    AVG(price_usd) OVER (
        PARTITION BY user_id
    ) AS average_order_value,
    price_usd * 100.0 /
        NULLIF(
            SUM(price_usd) OVER (PARTITION BY user_id),
            0
        ) AS order_revenue_contribution_pct
FROM orders
ORDER BY user_id, created_at, order_id;
-- 27. Identify users who placed orders on at least three consecutive calendar dates. Count distinct order dates, not individual orders, when determining the sequence.
WITH order_dates AS (
    SELECT DISTINCT
        user_id,
        created_at::date AS order_date
    FROM orders
),
numbered_dates AS (
    SELECT
        user_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY order_date
        ) AS rn
    FROM order_dates
),
date_groups AS (
    SELECT
        user_id,
        order_date,
        order_date - rn::int AS group_key
    FROM numbered_dates
),
streaks AS (
    SELECT
        user_id,
        group_key,
        COUNT(*) AS consecutive_days
    FROM date_groups
    GROUP BY user_id, group_key
)
SELECT DISTINCT user_id
FROM streaks
WHERE consecutive_days >= 3;
-- 28. Find each product's best revenue month and show all tied best months.
WITH monthly_product_revenue AS (
    SELECT
        product_id,
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM order_items
    GROUP BY
        product_id,
        DATE_TRUNC('month', created_at)::date
),
ranked_months AS (
    SELECT
        product_id,
        month,
        revenue,
        RANK() OVER (
            PARTITION BY product_id
            ORDER BY revenue DESC
        ) AS month_rank
    FROM monthly_product_revenue
)
SELECT product_id, month, revenue
FROM ranked_months
WHERE month_rank = 1
ORDER BY product_id, month;
-- 29. For each order, calculate the difference between its price and the previous order price for the same user, plus the percentage change. Safely handle a zero previous price.
WITH previous_orders AS (
    SELECT
        order_id,
        user_id,
        created_at,
        price_usd,
        LAG(price_usd) OVER (
            PARTITION BY user_id
            ORDER BY created_at, order_id
        ) AS previous_order_price
    FROM orders
)
SELECT
    order_id,
    user_id,
    created_at,
    price_usd,
    previous_order_price,
    price_usd - previous_order_price AS price_difference,
    (price_usd - previous_order_price) * 100.0
        / NULLIF(previous_order_price, 0) AS percentage_change
FROM previous_orders
ORDER BY user_id, created_at, order_id;
-- 30. Build a monthly performance report with monthly revenue, previous-month revenue, month-over-month growth, cumulative revenue, and monthly revenue rank.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        SUM(price_usd) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)::date
),
monthly_metrics AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue,
        SUM(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        RANK() OVER (
            ORDER BY revenue DESC
        ) AS monthly_revenue_rank
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0) AS month_over_month_growth_pct,
    cumulative_revenue,
    monthly_revenue_rank
FROM monthly_metrics
ORDER BY month;
