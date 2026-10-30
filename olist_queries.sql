-- Olist E-Commerce: SQL analysis queries
-- Tables (one per Olist CSV): orders, order_items, order_payments, order_reviews,
-- customers, products, sellers, category_translation
-- Revenue = SUM(price) on delivered orders (excludes freight). Works in SQLite and, with small date-function changes, in MySQL/PostgreSQL.

-- Q1. Headline KPIs
SELECT
    ROUND(SUM(oi.price), 0)                               AS total_revenue,
    COUNT(DISTINCT o.order_id)                            AS delivered_orders,
    ROUND(SUM(oi.price) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Q2. Monthly revenue and orders (full months only)
SELECT
    STRFTIME('%Y-%m', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 0)                       AS revenue,
    COUNT(DISTINCT o.order_id)                    AS orders
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01'
GROUP BY month
ORDER BY month;

-- Q3. Top 10 product categories by revenue
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    ROUND(SUM(oi.price), 0)      AS revenue,
    COUNT(DISTINCT oi.order_id)  AS orders
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id AND o.order_status = 'delivered'
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q4. Revenue by customer state with share of total (window function)
SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 0) AS revenue,
    ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 1) AS pct_of_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customers c    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- Q5. Late vs on-time delivery: order count, average review score, share of 1-2 star reviews
WITH order_review AS (
    SELECT order_id, AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'Late' ELSE 'On time' END                  AS delivery_status,
    COUNT(*)                                             AS orders,
    ROUND(AVG(r.review_score), 2)                        AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1.0 ELSE 0 END), 1) AS pct_low_reviews
FROM orders o
JOIN order_review r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- Q6. Average delivery days and late rate by state (states with 500+ orders)
SELECT
    c.customer_state,
    COUNT(*) AS orders,
    ROUND(AVG(JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    ROUND(100.0 * AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1.0 ELSE 0 END), 1) AS pct_late
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) > 500
ORDER BY avg_delivery_days;

-- Q7. Payment type share of total payment value
SELECT
    p.payment_type,
    ROUND(SUM(p.payment_value), 0) AS total_value,
    ROUND(100.0 * SUM(p.payment_value) / SUM(SUM(p.payment_value)) OVER (), 1) AS pct_of_value
FROM order_payments p
JOIN orders o ON o.order_id = p.order_id AND o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_value DESC;

-- Q8. Repeat customers: share of customers with 2+ delivered orders
WITH per_customer AS (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS n_orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*)                                                  AS customers,
    SUM(CASE WHEN n_orders > 1 THEN 1 ELSE 0 END)             AS repeat_customers,
    ROUND(100.0 * AVG(CASE WHEN n_orders > 1 THEN 1.0 ELSE 0 END), 1) AS pct_repeat
FROM per_customer;

-- Q9. Seller concentration: revenue share of the top 10% of sellers
WITH seller_rev AS (
    SELECT oi.seller_id, SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id AND o.order_status = 'delivered'
    GROUP BY oi.seller_id
),
ranked AS (
    SELECT revenue, NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM seller_rev
)
SELECT
    COUNT(*) AS sellers,
    ROUND(100.0 * SUM(CASE WHEN decile = 1 THEN revenue ELSE 0 END) / SUM(revenue), 1) AS pct_revenue_top_decile
FROM ranked;
