-- -- Topic 1: SELECT + WHERE + ORDER BY + LIMIT
-- 🟢 LEVEL 1 — EASY
-- Q1 From products, display: product_id & product_name
SELECT product_id,product_name
FROM products;
-- Q2 From products, display all columns.
SELECT *
FROM products;
-- Q3 From products, display only the product_name.
SELECT product_name
FROM products;
-- Q4 From orders, display: order_id, user_id, price_usd.
SELECT order_id,user_id,price_usd
FROM orders;
-- Q5 Display the first 10 orders from orders.
SELECT *
FROM orders
LIMIT 10;
-- Q6 Display the first 20 products from products.
SELECT *
FROM products
LIMIT 20;
-- Q7 From orders, display orders where price_usd is greater than 50.
SELECT *
FROM orders
where price_usd > 50;
-- Q8 From orders, display orders where items_purchased is greater than 1.
SELECT *
FROM orders
where items_purchased > 1;
-- Q9 From products, display products where the product_id is less than 10.
SELECT *
FROM products
where product_id < 10;
-- Q10 Display the 10 most expensive orders based on price_usd.
SELECT *
FROM orders
ORDER BY price_usd DESC
LIMIT 10;

-- 🟡 LEVEL 2 — MEDIUM
-- Q11
-- Display orders where price_usd is greater than 100, showing: order_id, user_id, price_usd
SELECT order_id,user_id,price_usd
FROM orders
WHERE price_usd>100;
-- Q12 Display orders where price_usd is between 50 and 100.
SELECT *
FROM orders
WHERE price_usd BETWEEN 50 AND 100;
-- Q13 Display orders where items_purchased is 2 or more, sorted by items_purchased from highest to lowest.
SELECT *
FROM orders
where items_purchased >=2
ORDER BY items_purchased DESC;
-- Q14 Display the 5 cheapest orders based on price_usd.
SELECT *
FROM orders
ORDER BY price_usd 
LIMIT 5;
-- Q15 Display the 10 most expensive orders, but show only: order_id, user_id, price_usd.
SELECT order_id,user_id,price_usd
FROM orders
ORDER BY price_usd DESC
LIMIT 10;
-- Q16 Find orders where price_usd is greater than 100 AND items_purchased is greater than 1.
SELECT *
FROM orders
WHERE price_usd>100 AND items_purchased >1;
-- Q17 Find orders where price_usd is less than 50 OR items_purchased is greater than 2.
SELECT *
FROM orders
WHERE price_usd<50 OR items_purchased > 2;
-- Q18 Display orders with price_usd greater than 50, sorted from highest price to lowest price, and show only the first 10.
SELECT *
FROM orders
WHERE price_usd > 50
ORDER BY price_usd DESC
LIMIT 10;
-- Q19 Display products with product_id between 1 and 5, sorted by product_id descending.
SELECT *
FROM products
WHERE product_id BETWEEN 1 AND 5
ORDER BY product_id DESC;
-- Q20 Display the 20 most recent orders based on created_at.
SELECT *
FROM orders
ORDER BY created_at DESC
LIMIT 20;
-- 🔴 LEVEL 3 — HARD
-- Q21 Find the 5 highest-value orders where:
-- - items_purchased is greater than 1
-- - price_usd is greater than 50
-- Display: order_id, user_id, items_purchased, price_usd
SELECT order_id, user_id, items_purchased, price_usd 
FROM orders 
WHERE items_purchased > 1 AND price_usd > 50 
ORDER BY price_usd DESC 
LIMIT 5;

-- Q22 Find the 10 cheapest orders where items_purchased is at least 2.
SELECT *
FROM orders
WHERE items_purchased >=2
ORDER BY price_usd 
LIMIT 10;
-- Q23 Find the 5 most expensive orders where the price is between 50 and 200.
SELECT *
FROM orders
WHERE price_usd BETWEEN 50 AND 200
ORDER BY price_usd DESC
LIMIT 5;
-- Q24 Display the 10 most recent orders where price_usd is greater than 100.
SELECT *
FROM orders
WHERE price_usd > 100
ORDER BY created_at DESC
LIMIT 10;
-- Q25 Find the 5 orders with the highest price per purchased item.
-- Hint: You will need an expression involving price_usd and items_purchased.
-- Don't use SUM, GROUP BY, or any advanced concept.
SELECT
    order_id,
    price_usd,
    items_purchased,
    price_usd / items_purchased AS price_per_item
FROM orders
ORDER BY price_per_item DESC
LIMIT 5;
-- Q26 Find the 10 orders with the highest COGS, but only where price_usd is greater than 100.
-- Display: order_id, price_usd, cogs_usd
SELECT order_id, price_usd, cogs_usd
FROM orders
WHERE price_usd > 100
ORDER BY cogs_usd DESC
LIMIT 10;
-- Q27 Find orders where:
-- - price is greater than 100
-- - items purchased is at least 2
-- Sort them by price descending, and if two orders have the same price, sort them by items_purchased descending.
SELECT *
FROM orders
WHERE price_usd > 100 AND items_purchased >=2
ORDER BY price_usd DESC,items_purchased DESC;
-- Q28 Find the 5 most expensive orders where:
-- - price is greater than 50
-- - items purchased is greater than 1
-- - order was placed before a date you choose from the data
-- You'll need to use created_at.
SELECT *
FROM orders
WHERE price_usd > 50 AND items_purchased > 1 AND created_at < '2015-03-18 18:15:00'
ORDER BY price_usd DESC
LIMIT 5;