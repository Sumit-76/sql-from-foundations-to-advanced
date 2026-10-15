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
WITH CUS_REV AS(
SELECT USER_ID,SUM(PRICE_USD)AS CUS_TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
),
TOTAL_REV AS(
SELECT SUM(PRICE_USD) AS TOTAL_REV
FROM ORDERS
)
SELECT USER_ID,CUS_TOTAL_REV,TOTAL_REV,CUS_TOTAL_REV*100.0/(NULLIF(TOTAL_REV,0))AS PERCENTAGE_CONTRIBUTION
FROM CUS_REV 
CROSS JOIN TOTAL_REV ;
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
WITH MONTHLY_PRODUCT_REV AS(
SELECT PRODUCT_ID,DATE_TRUNC('MONTH',CREATED_AT)::DATE AS MONTH,SUM(PRICE_USD)AS REVENUE
FROM ORDER_ITEMS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT)::DATE,PRODUCT_ID
)
SELECT MONTH,REVENUE,SUM(REVENUE) OVER(ORDER BY MONTH)AS MONTHLY_ABSOLUTE_CHANGE
FROM MONTHLY_PRODUCT_REV;
-- 13. Calculate month-over-month revenue growth as a percentage. Handle a zero previous-month value safely.
WITH MONTHLY_PRODUCT_REV AS(
SELECT PRODUCT_ID,DATE_TRUNC('MONTH',CREATED_AT)::DATE AS MONTH,SUM(PRICE_USD)AS REVENUE
FROM ORDER_ITEMS
GROUP BY DATE_TRUNC('MONTH',CREATED_AT)::DATE,PRODUCT_ID
)
SELECT MONTH,REVENUE,(LEAD(REVENUE) OVER(ORDER BY MONTH)-REVENUE)*100.0/NULLIF(REVENUE,0) AS REVENUE_GROWTH_PERCENTAGE
FROM MONTHLY_PRODUCT_REV;
-- 14. Calculate a three-row moving average of monthly revenue, including the current month and up to the two preceding rows.

-- 15. Find each user's first order using a window function.
SELECT USER_ID,MIN(CREATED_AT)OVER(PARTITION BY USER_ID)AS FIRST_ORDER_DATE
FROM ORDERS;
-- 16. Find each user's most recent order, including order_id, created_at, and price_usd. Resolve timestamp ties using order_id.
SELECT USER_ID,ORDER_ID,CREATED_AT,PRICE_USD,MAX(CREATED_AT)OVER(PARTITION BY USER_ID ORDER BY CREATED_AT DESC,USER_ID)AS LATEST_ORDER
FROM ORDERS;
-- 17. Rank users by total revenue and display the top 10 users, preserving tied rankings.
WITH CUS_REV AS(
SELECT USER_ID,SUM(PRICE_USD)AS TOTAL_REV
FROM ORDERS
GROUP BY USER_ID
)
SELECT USER_ID,TOTAL_REV,RANK()OVER(ORDER BY TOTAL_REV DESC)AS USER_RANK
FROM CUS_REV
LIMIT 10;
-- 18. For each product, calculate its revenue and its percentage contribution to total product revenue.
WITH PRO_REV AS(
SELECT PRODUCT_ID,SUM(PRICE_USD)AS REVENUE
FROM ORDER_ITEMS
GROUP BY PRODUCT_ID
),
TOTAL_REV AS(
SELECT SUM(PRICE_USD)AS TOTAL_REV
FROM ORDER_ITEMS
)
SELECT PRODUCT_ID,REVENUE,REVENUE*100.0/TOTAL_REV AS PERCENTAGE_CONTRIBUTION
FROM PRO_REV P
CROSS JOIN TOTAL_REV T;
-- 19. Display each user's orders with the previous order date and the number of days since that order.
SELECT USER_ID,CREATED_AT,
		LAG(CREATED_AT) OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)AS PREV_ORDER_DATE,
		CREATED_AT::DATE - LAG(CREATED_AT) OVER(PARTITION BY USER_ID ORDER BY CREATED_AT)::DATE AS DAYS_BET
FROM ORDERS;
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
-- 22. Calculate daily revenue and its cumulative total within each calendar year, restarting the cumulative total each year.
-- 23. Calculate each month's revenue and a three-month moving average using a ROWS window frame.
-- 24. Identify users whose latest order value is greater than their previous order value.
-- 25. Find users whose order revenue increased in three consecutive available monthly observations. State how you handle months with no orders.
-- 26. For each user, calculate total revenue, order count, average order value, and each order's percentage contribution to that user's revenue.
-- 27. Identify users who placed orders on at least three consecutive calendar dates. Count distinct order dates, not individual orders, when determining the sequence.
-- 28. Find each product's best revenue month and show all tied best months.
-- 29. For each order, calculate the difference between its price and the previous order price for the same user, plus the percentage change. Safely handle a zero previous price.
-- 30. Build a monthly performance report with monthly revenue, previous-month revenue, month-over-month growth, cumulative revenue, and monthly revenue rank.