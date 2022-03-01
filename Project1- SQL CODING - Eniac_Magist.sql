USE magist;

-- how many unique products does Magist sell? -- 32951 // they sold each of them in actual orders

SELECT COUNT(DISTINCT product_id) AS number_products
FROM order_items;

-- How many sellers are there -- 3095

SELECT COUNT(seller_id)

FROM sellers;

-- What’s the average revenue of sellers in Magist?

SELECT seller_id, YEAR(order_approved_at) AS year, MONTH(order_approved_at) AS month, AVG(ROUND(payment_value)) AS avg_revenue
FROM order_items
JOIN order_payments USING(order_id)
JOIN orders USING (order_id)
GROUP BY seller_id, year, month
ORDER BY avg_revenue DESC;

-- are the yearly revenues of Magist growing over time?

SELECT YEAR(order_approved_at) AS year, MONTH(order_approved_at) AS month, SUM(ROUND(payment_value)) AS total_revenue
FROM order_payments
JOIN orders USING (order_id)
GROUP BY year, month
ORDER BY year, month;

-- range of price for the products sold by Magist is very broad -- min 0,85 // max 6735

SELECT MIN(price) AS cheapest, MAX(price) as most_expensive
FROM order_items;

-- they sell products from a very broad range of categories

select distinct product_category_name_english
from products 
left join product_category_name_translation
using(product_category_name)
order by 1;

-- how many products were sold in total? -- 112650

SELECT COUNT(*) AS sold_count
FROM products
INNER JOIN order_items USING(product_id);

-- the percentage of tech products sold is:

SELECT pcnt.product_category_name_english AS product_name, 
		COUNT(*) AS sold_count,
        ROUND(COUNT(*)/112650 * 100, 2) AS overall_sold_percentage
FROM products p
JOIN order_items oi
	USING(product_id)
JOIN product_category_name_translation pcnt
	USING(product_category_name)
WHERE pcnt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "computers", "tablets_printing_image", "telephony")
GROUP BY product_name
ORDER BY sold_count DESC;

-- the average basket is 154

SELECT AVG(payment_value)
FROM order_payments;

-- the average basket for tech products is 164

SELECT AVG(payment_value)
FROM order_payments
JOIN order_items USING (order_id)
JOIN products USING (product_id)
JOIN product_category_name_translation USING (product_category_name)
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "computers", "tablets_printing_image", "telephony");


-- what's the Max prices (top 5) for all tech categories? Do they sell high-end tech products or just regular tech ones?

-- prices of Apple computers in Brasil are very high, between 3K and 4.7K! what are the prices of the most expensive 10 computers Magist sells? 6729-1437

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "computers"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- how many times were the expensive computers sold in Magist? was a one-time thing?

SELECT product_id, COUNT(*)
FROM orders
JOIN order_items USING (order_id)
WHERE product_id IN ("69c590f7ffc7bf8db97190b6cb6ed62e", "259037a6a41845e455183f89c5035f18", "5e954c4ed342c50436d25d5f50a34919", "34f99d82cfc355d08d8db780d14aa002", "34f99d82cfc355d08d8db780d14aa002")
GROUP BY product_id;

-- range top 10 audio prices: 599-439

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "audio"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- range top 10 electronics prices: 2470-700

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "electronics"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- range top 10 computers_accessories prices: 3700-1699

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "computers_accessories"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- range top 10 tablets_printing_image prices: 890-53 (iPad Air costs 1200 on Apple Store)

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "tablets_printing_image"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- range top 10 telephony prices: 2428-1006 (iPhone 13 costs 1142 on Apple Store)

SELECT ROUND(price) price, COUNT(product_id) products
FROM product_category_name_translation
JOIN products USING (product_category_name)
JOIN order_items USING (product_id)
WHERE product_category_name_english = "telephony"
GROUP BY ROUND(price)
ORDER BY ROUND(price) DESC
LIMIT 10;

-- which product categories are more popular on Magist?

SELECT product_category_name_english AS categories, COUNT(DISTINCT product_id) qty
FROM products
LEFT JOIN product_category_name_translation USING (product_category_name)
GROUP BY product_category_name_english
ORDER BY qty DESC;

-- categories of "tech" products: audio / computers / computers_accessories / electronics / tablets_printing_image / telephony
-- how many times where tech products sold? what's the average price for those single categories?

SELECT product_category_name_english AS categories, COUNT(oi.product_id) AS qty_sold, ROUND(AVG(oi.price),2) AS avg_price
FROM order_items oi
JOIN products p USING(product_id)
JOIN product_category_name_translation pcnt USING(product_category_name)
where pcnt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "computers", "tablets_printing_image", "telephony")
GROUP BY product_category_name_english
ORDER BY COUNT(oi.product_id) DESC;




-- how many orders did Magist ship? 99441 orders

SELECT COUNT(order_id) AS Total_Orders
FROM orders;

-- the last order they approved was: 08.08.2018, big batch of orders. After that only one order approved in September.

SELECT YEAR(order_approved_at) AS YEAR,
	MONTH(order_approved_at) AS MONTH, 
	DAY(order_approved_at) AS DAY, count(*) orders_approved
FROM orders
GROUP BY year, month, day
ORDER BY year DESC;

-- how many of these are delivered to customers? 96478 orders

SELECT COUNT(order_status) FROM orders
WHERE order_status = "delivered";

-- What’s the average time between the order being placed and the product being delivered? -- 12 days
-- WHAT'S THE DIFFERENCE BETWEEN THESE TWO?

SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_approved_at)),2)
FROM orders;

 SELECT ROUND(AVG(TIMESTAMPDIFF(DAY, order_approved_at, order_delivered_customer_date)),2)
FROM orders;

-- what's the average difference in DAYS between the estimated delivery and the actual delivery WHEN WITH DELAY? 12 days

SELECT AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS difference_late
FROM orders
WHERE TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) > 1;

-- what's the average difference in DAYS between the estimated delivery and the actual delivery WHEN EARLY? -12 days

SELECT AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS difference_early
FROM orders
WHERE TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) < 1;

-- overall the deliveries are 11 days early

SELECT AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS difference_all
FROM orders;

-- how many orders are delivered on time vs orders delivered with a delay? -- 89810 delivered on-time / 6666 delivered with delay

SELECT COUNT(*)
FROM orders
WHERE DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) <= 0 ;

SELECT Round((89810/99441)*100,2); -- 90.31% delivered on-time
SELECT Round((6666/99441)*100,2); -- 6.7% with delay

-- Is there any pattern for delayed orders, e.g. big products being delayed more often? No

SELECT product_weight_g AS weight, (product_length_cm*product_height_cm*product_width_cm) AS volume, DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS delay
FROM orders o
JOIN order_items oi USING(order_id)
JOIN products p USING(product_id)
WHERE DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) > 1
ORDER BY volume DESC;

# Tableau -- average delivery for tech products in Rio de Janeiro 2-3-5 weeks. The average delivery for all products to all zipcodes is not different.