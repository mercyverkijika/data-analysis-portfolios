-- ================================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Dimensional Model for Power BI Reporting
-- Dataset: Olist Brazilian E-Commerce
-- ================================================================

--   This script builds a star schema on top of the existing data:
--   one fact table at item grain, surrounded by four dimension views.


-- STAR SCHEMA:
--   fact_order_items  central fact table (item grain)
--   dim_date(order_purchase_date → date_day)
--   dim_customer(customer_unique_id)
--   dim_seller(seller_id)
--   dim_product(category_english)


USE nexora_commerce;


-- ================================================================
-- DIM_DATE
-- ================================================================

DROP VIEW IF EXISTS dim_date;

CREATE VIEW dim_date AS
WITH RECURSIVE date_range AS (
    SELECT DATE(MIN(order_purchase_timestamp)) AS date_day
    FROM vw_master
    UNION ALL
    SELECT date_day + INTERVAL 1 DAY
    FROM date_range
    WHERE date_day < (SELECT DATE(MAX(order_purchase_timestamp)) FROM vw_master)
)
SELECT
    date_day,
    YEAR(date_day) AS year,
    QUARTER(date_day) AS quarter,
    MONTH(date_day) AS month_num,
    MONTHNAME(date_day) AS month_name,
    DATE_FORMAT(date_day, '%Y-%m') AS YearMonth,
    DAYNAME(date_day)  AS day_name,
    DAYOFWEEK(date_day)  AS day_of_week_num,
    CASE WHEN DAYOFWEEK(date_day) IN (1,7)
         THEN 'Weekend' ELSE 'Weekday'
    END AS day_type
FROM date_range;

-- ================================================================
-- DIM_CUSTOMER
-- ================================================================
-- One row per unique customer.
-- customer_unique_id is the stable cross-order identifier.
-- customer_id (per-order ID) is excluded — it is not a
-- reliable customer key and is not used in the analysis.


DROP VIEW IF EXISTS dim_customer;

CREATE VIEW dim_customer AS
SELECT DISTINCT
    customer_unique_id,
    customer_state,
    customer_city
FROM customers;


-- ================================================================
-- DIM_SELLER
-- ================================================================
-- One row per seller.
-- seller_label is the Power BI display field to make it human-readable as original seller_id is long and not readable
-- unique within any filter context, short enough for chart axes.
-- seller_id is retained as the join key.


DROP VIEW IF EXISTS dim_seller;

CREATE VIEW dim_seller AS
SELECT
    seller_id,
    seller_city,
    seller_state,
    CONCAT('S', RANK() OVER (ORDER BY seller_id), ' — ', seller_city) AS seller_label
FROM sellers;


-- ================================================================
-- DIM_PRODUCT
-- ================================================================
-- Category-level dimension, not product-level.
-- Product IDs are too granular for CCO-level reporting and
-- have no meaningful standalone attributes in this dataset.


DROP VIEW IF EXISTS dim_product;

CREATE VIEW dim_product AS
SELECT
    COALESCE(ct.product_category_name_english, 'Unknown')  AS category_english,
    COUNT(DISTINCT p.product_id) AS products_in_category
FROM products p
LEFT JOIN category_translation ct
       ON p.product_category_name = ct.product_category_name
GROUP BY category_english
 
UNION ALL
 
SELECT 'Unknown' AS category_english, 0 AS products_in_category
WHERE NOT EXISTS (
    SELECT 1
    FROM products p
    LEFT JOIN category_translation ct
           ON p.product_category_name = ct.product_category_name
    WHERE COALESCE(ct.product_category_name_english, 'Unknown') = 'Unknown'
);
 
 


-- ================================================================
-- FACT_ORDER_ITEMS 
-- ================================================================
-- Central fact table. One row per item within each order.
-- All additive measures (revenue, freight) are at item grain.
-- Non-additive measures (review_score, delay_days) are at order grain — repeated across items in the same order,
-- so we always aggregate with AVG not SUM in Power BI.

DROP VIEW IF EXISTS fact_order_items;

CREATE VIEW fact_order_items AS 
-- DELIVERED ORDERS 
 
SELECT
    -- Keys
    CAST(order_id AS CHAR(36)) AS order_id,
    CAST(customer_unique_id  AS CHAR(36))  AS customer_unique_id,
    CAST(seller_id AS CHAR(36)) AS seller_id,
    CAST(category_english  AS CHAR(100)) AS category_english,
    CAST(DATE(order_purchase_timestamp) AS DATE) AS order_purchase_date,
 
    -- Status & flags
    CAST(order_status AS CHAR(20)) AS order_status,
    CAST(1 AS UNSIGNED)  AS is_delivered,
    CAST(0  AS UNSIGNED)  AS is_leakage,
 
    -- Revenue measures
    CAST(item_price AS DECIMAL(10,2)) AS item_price,
    CAST(item_freight  AS DECIMAL(10,2))  AS item_freight,
    CAST(item_total_revenue AS DECIMAL(10,2)) AS item_total_revenue,
 
    -- Delivery metrics (order-grain — use AVG not SUM in Power BI)
    CAST(review_score AS DECIMAL(3,1))  AS review_score,
    CAST(delivery_delay_days AS DECIMAL(7,2))  AS delivery_delay_days,
    CAST(fulfilment_days AS DECIMAL(7,2))  AS fulfilment_days,
    CAST(delivery_status  AS CHAR(10))  AS delivery_status,
    CAST(CASE WHEN delivery_status = 'Late'
              THEN 1 ELSE 0 END AS UNSIGNED) AS is_late,
    CAST(CASE WHEN review_score <= 2
              THEN 1 ELSE 0 END AS UNSIGNED)  AS is_negative_review,
 
    -- Payment context
    CAST(primary_payment_type  AS CHAR(30)) AS primary_payment_type
 
FROM vw_master;
 
-- ================================================================
-- FACT_LEAKAGE  (canceled + unavailable orders only)
-- ================================================================

DROP VIEW IF EXISTS fact_leakage;
 
CREATE VIEW fact_leakage AS
SELECT
    -- Keys
    CAST(o.order_id AS CHAR(36)) AS order_id,
    CAST(c.customer_unique_id  AS CHAR(36)) AS customer_unique_id,
    CAST(oi.seller_id AS CHAR(36)) AS seller_id,
 
    -- Three-level category fallback (matches vw_products_clean and dim_product):
    --   1. English translation  2. Portuguese name  3. 'Uncategorised'
    CAST(COALESCE(
        pt.product_category_name_english,
        NULLIF(p.product_category_name, ''),
        'Uncategorised'
    )  AS CHAR(100)) AS category_english,
 
    CAST(DATE(o.order_purchase_timestamp) AS DATE) AS order_purchase_date,
 
    -- Status & flags
    CAST(o.order_status AS CHAR(20)) AS order_status,
    CAST(0 AS UNSIGNED)  AS is_delivered,
    CAST(1  AS UNSIGNED)   AS is_leakage,
 
    -- Revenue measures
    CAST(oi.price  AS DECIMAL(10,2))  AS item_price,
    CAST(oi.freight_value AS DECIMAL(10,2))  AS item_freight,
    CAST(oi.price + oi.freight_value AS DECIMAL(10,2)) AS item_total_revenue,
 
    -- Delivery metrics — NULL (no delivery took place)
    NULL  AS review_score,
    NULL  AS delivery_delay_days,
    NULL AS fulfilment_days,
    NULL  AS delivery_status,
    CAST(0 AS UNSIGNED)  AS is_late,
    CAST(0   AS UNSIGNED)  AS is_negative_review,
 
    -- Payment context — NULL (canceled order payment records unreliable)
    NULL  AS primary_payment_type
 
FROM  orders  o
JOIN  customers  c   ON o.customer_id  = c.customer_id
JOIN  order_items  oi  ON o.order_id = oi.order_id
LEFT JOIN products  p   ON oi.product_id  = p.product_id
LEFT JOIN category_translation pt
                               ON p.product_category_name = pt.product_category_name
WHERE o.order_status IN ('canceled', 'unavailable');


-- ================================================================
-- VALIDATION — ROW AND KEY CHECKS
-- ================================================================

-- Row count should match vw_master
SELECT COUNT(*) AS fact_rows FROM fact_order_items;
-- '110197' which matches vw_master


-- Dimension row counts
SELECT COUNT(*) AS dim_date_rows FROM dim_date;
SELECT COUNT(DISTINCT date_day) AS date_unique_days  FROM dim_date;
SELECT COUNT(*) AS dim_customer_rows FROM dim_customer;
SELECT COUNT(*) AS dim_seller_rows FROM dim_seller;
SELECT COUNT(*) AS dim_product_rows FROM dim_product;

-- Orphan check: fact rows with no matching dim_customer key
SELECT COUNT(*) AS unmatched_customers
FROM fact_order_items f
LEFT JOIN dim_customer c 
  ON f.customer_unique_id = c.customer_unique_id
WHERE c.customer_unique_id IS NULL;

-- Orphan check: fact rows with no matching dim_seller key
SELECT COUNT(*) AS unmatched_sellers
FROM fact_order_items f
LEFT JOIN dim_seller s 
  ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Orphan check: fact rows with no matching dim_date key
SELECT COUNT(*) AS unmatched_dates
FROM fact_order_items f
LEFT JOIN dim_date d 
  ON f.order_purchase_date = d.date_day
WHERE d.date_day IS NULL;

-- Revenue reconciliation — should match R$15419774 GMV in analysis script
SELECT ROUND(SUM(item_total_revenue), 0) AS total_gmv 
FROM fact_order_items;