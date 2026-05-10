-- =============================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Cleaned Views (Cleaning Layer)
-- =============================================================


USE nexora_commerce;


-- =============================================================
-- VIEW 1: vw_payments_clean
-- =============================================================
--   One order can have multiple payment rows (instalments or split payments). Joining raw payments to orders inflates
--   revenue figures by counting the same order multiple times.

--  So we will Collapse all payment rows into ONE row per order using
--   GROUP BY + SUM. Also identifies the primary payment method
--   (the one used first — payment_sequential = 1).


DROP VIEW IF EXISTS vw_payments_clean;
CREATE VIEW vw_payments_clean AS

SELECT
    order_id,
    SUM(payment_value) AS total_payment_value,
    SUM(payment_installments) AS total_installments,
    MAX(CASE WHEN payment_sequential = 1 THEN payment_type END) AS primary_payment_type,
    COUNT(payment_sequential) AS payment_methods_count
FROM order_payments
WHERE payment_type != 'not_defined'
GROUP BY order_id;
-- table grain is one row per order_id



-- =============================================================
-- VIEW 2: vw_geolocation_clean
-- =============================================================

--   The raw geolocation table has 261,831 duplicate rows because
--   multiple GPS readings exist per zip code. Joining it directly
--   to customers or sellers multiplies rows and corrupts counts.

--   Keeps only ONE row per zip code prefix — the first one using ROW_NUMBER() to rank rows within each zip code group.

DROP VIEW IF EXISTS vw_geolocation_clean;
CREATE VIEW vw_geolocation_clean AS

WITH zip_code_ranks AS (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        ROW_NUMBER() OVER (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY geolocation_lat, geolocation_lng
        ) AS rn
    FROM geolocation
)
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM zip_code_ranks
WHERE rn = 1;
-- table grain is one row per zip code prefix


-- =============================================================
-- VIEW 3: vw_products_clean
-- =============================================================
-- ISSUE IDENTIFIED
--   Product categories are in Portuguese. 610 products have no
--   category at all. 2 categories have no English translation.

-- FIX:
--   Joins products to the translation table to get English names.
--   Uses LEFT JOIN so products with no category are kept (not
--   silently dropped). Labels uncategorised products explicitly.


DROP VIEW IF EXISTS vw_products_clean;
CREATE VIEW vw_products_clean AS

SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, 'Uncategorised') AS category_english,
    p.product_category_name AS category_portuguese,
    CASE WHEN p.product_category_name IS NULL OR p.product_category_name = '' THEN 'Yes' ELSE 'No'
    END AS is_uncategorised,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    p.product_photos_qty
FROM products p
LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name;
-- 32,951 rows (same as raw products table)


-- =============================================================
-- VIEW 4: vw_orders_clean
-- =============================================================
-- ISSUE FOUND:
--   The raw orders table mixes all statuses together. Revenue
--   and delivery analysis must only use DELIVERED orders.


--  FIX:
--   1. Filters to delivered orders only
--   2. Calculates actual vs estimated delivery delay in days
--   3. Flags whether each order was late or on time
--   4. Joins to customers for location data
--   5. Joins to cleaned payments for correct revenue figures


DROP VIEW IF EXISTS vw_orders_clean;
CREATE VIEW vw_orders_clean AS

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(
        o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_delay_days,
    CASE
        WHEN DATEDIFF(o.order_delivered_customer_date,o.order_estimated_delivery_date) > 0 THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS fulfilment_days,

    -- F22: Flag orders where customer delivery date precedes carrier pickup date.
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_customer_date >= o.order_delivered_carrier_date THEN 'Yes'
        ELSE 'No'
    END  AS carrier_sequence_valid,

    -- F23: Flag orders where approval was logged AFTER carrier pickup.
    -- These 1,350 orders have valid revenue but unreliable approval timing.
    CASE
        WHEN o.order_approved_at IS NOT NULL
         AND o.order_delivered_carrier_date IS NOT NULL
         AND o.order_delivered_carrier_date >= o.order_approved_at THEN 'Yes'
        ELSE 'No'
    END AS approval_sequence_valid,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code_prefix,
    p.total_payment_value,
    p.total_installments,
    p.primary_payment_type,
    p.payment_methods_count
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN vw_payments_clean p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered';

-- verifying row count
SELECT COUNT(*) FROM vw_orders_clean;
-- 96,478 rows (all delivered orders — flags applied downstream)

-- =============================================================
-- VIEW 5: vw_master
-- =============================================================
-- ISSUE:
--   Analysis queries need data from multiple tables at once.
--   Writing the same joins repeatedly in every query is error prone and hard to maintain.

-- FIX:
--   Joins all 4 cleaned views together at the order-item level.
--   One row = one item within one delivered order.
--   Contains everything needed to answer BQ1 through BQ5.

-- NOTE ON ROW COUNT:
--   This view is at ORDER ITEM level, not order level.
--   An order with 3 items = 3 rows here. This is intentional —
--   item-level data is needed for category and seller analysis.

DROP VIEW IF EXISTS vw_master;
CREATE VIEW vw_master AS

SELECT
    -- Order & Customer 
    o.order_id,
    o.customer_id,
    o.customer_unique_id,
    o.order_purchase_timestamp,
    o.order_status,
    o.delivery_delay_days,
    o.delivery_status,
    o.fulfilment_days,
    o.customer_city,
    o.customer_state,
    o.customer_zip_code_prefix,

    -- Payment 
    o.total_payment_value,
    o.primary_payment_type,
    o.total_installments,

    -- Item 
    i.order_item_id,
    i.price  AS item_price,
    i.freight_value  AS item_freight,

    -- Total item revenue (product price + shipping cost)
    (i.price + i.freight_value) AS item_total_revenue,

    i.shipping_limit_date,

    -- Seller 
    i.seller_id,
    s.seller_city,
    s.seller_state,
    s.seller_zip_code_prefix,

    -- Product & Category 
    i.product_id,
    p.category_english,
    p.category_portuguese,
    p.is_uncategorised,
    p.product_weight_g,
    p.product_photos_qty,

    -- Review 
    r.review_score,
    r.review_creation_date,

    -- Sentiment label based on score (useful for Power BI)
    CASE
        WHEN r.review_score >= 4 THEN 'Positive'   -- 4 or 5 stars
        WHEN r.review_score = 3  THEN 'Neutral'    -- 3 stars
        WHEN r.review_score <= 2 THEN 'Negative'   -- 1 or 2 stars
        ELSE 'No Review'
    END AS review_sentiment,

    -- Seller Geo 
    geo_s.geolocation_lat AS seller_lat,
    geo_s.geolocation_lng  AS seller_lng,

    -- Customer Geo (optional for mapping) 
    geo_c.geolocation_lat AS customer_lat,
    geo_c.geolocation_lng AS customer_lng
    
FROM vw_orders_clean o
INNER JOIN order_items i
    ON o.order_id = i.order_id
LEFT JOIN sellers s
    ON i.seller_id = s.seller_id
LEFT JOIN vw_products_clean p
    ON i.product_id = p.product_id
LEFT JOIN (
    SELECT
        order_id,
        review_score,
        review_creation_date,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_creation_date DESC
        ) AS rn
    FROM order_reviews
) r ON o.order_id = r.order_id AND r.rn = 1

LEFT JOIN vw_geolocation_clean geo_s
    ON s.seller_zip_code_prefix = geo_s.geolocation_zip_code_prefix

LEFT JOIN vw_geolocation_clean geo_c
    ON o.customer_zip_code_prefix = geo_c.geolocation_zip_code_prefix;
    
-- confirming row count
SELECT COUNT(*)
FROM vw_master;
-- 11,0197 rows (order-item level, delivered orders)


-- =============================================================
-- VERIFY ALL VIEWS
-- =============================================================
 
SELECT '1. vw_payments_clean'  AS view_name, COUNT(*) AS row_count, 'One row per order'AS note FROM vw_payments_clean
UNION ALL
SELECT '2. vw_geolocation_clean', COUNT(*), 'One row per zip code' FROM vw_geolocation_clean
UNION ALL
SELECT '3. vw_products_clean', COUNT(*), 'Same as products table' FROM vw_products_clean
UNION ALL
SELECT '4. vw_orders_clean', COUNT(*), 'Delivered orders only' FROM vw_orders_clean
UNION ALL
SELECT '5. vw_master', COUNT(*),  'One row per order item' FROM vw_master;
 
-- =============================================================
-- QUICK SANITY CHECK — does the master view make sense?
-- =============================================================
 
SELECT
    COUNT(DISTINCT order_id)        AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    COUNT(DISTINCT seller_id)       AS unique_sellers,
    COUNT(DISTINCT category_english) AS unique_categories,
    ROUND(SUM(item_price), 2)       AS total_product_revenue,
    ROUND(SUM(item_freight), 2)     AS total_freight_revenue,
    ROUND(SUM(item_total_revenue), 2) AS total_revenue,
    ROUND(AVG(item_price), 2)       AS avg_item_price,
    ROUND(AVG(review_score), 2)     AS avg_review_score
FROM vw_master;
 