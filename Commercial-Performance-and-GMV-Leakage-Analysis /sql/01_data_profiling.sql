====================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Data Profiling 
-- Dataset: Olist Brazilian E-Commerce (9 source tables)
-- ================================================================


USE nexora_commerce;


-- ================================================================
-- Step 0: VOLUME OVERVIEW .get a feel for relative scale before profiling each table 
-- ================================================================

SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
ORDER BY row_count DESC;
-- geolocation has ~10x more rows than any other operational table.
-- order_payments has more rows than orders means some orders have multiple payment rows.
--   Both needs to be investigated.


-- ================================================================
-- Step 1: orders TABLE
-- ================================================================

-- 1.1: preview of data 
SELECT * 
FROM orders 
LIMIT 30;

-- 1.2: are they any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id)  AS duplicates
FROM orders;
-- no duplicates found so primary key is clean 


-- 1.3 order_status; what values exist?
SELECT
    order_status,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY row_count DESC;
--   8 statuses confirmed. No unexpected values, no placeholders.

-- 2.0 DATE FORMAT CHECKS

-- 2.1 What date formats exist in order_purchase_timestamp?
SELECT
    CASE
        WHEN order_purchase_timestamp IS NULL THEN 'NULL'
        WHEN CONVERT(order_purchase_timestamp, CHAR) REGEXP '^0000' THEN 'Zero date(0000-00-00...)'
        WHEN CONVERT(order_purchase_timestamp, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN CONVERT(order_purchase_timestamp, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN CONVERT(order_purchase_timestamp, CHAR) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(order_purchase_timestamp, CHAR), 25))
    END AS format_found
FROM orders
GROUP BY format_found ORDER BY n DESC;
-- all dates 'YYYY-MM-DD HH:MM:SS' fromat

-- 2.2 What date formats exist in order_approved_at?
SELECT
    CASE
        WHEN order_approved_at IS NULL THEN 'NULL'
        WHEN CONVERT(order_approved_at, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN CONVERT(order_approved_at, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN CONVERT(order_approved_at, CHAR) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(order_approved_at, CHAR), 25))
    END AS format_found
FROM orders
GROUP BY format_found ORDER BY n DESC;
-- all dates 'YYYY-MM-DD HH:MM:SS'

-- 2.3 What date formats exist in order_delivered_carrier_date? 
SELECT
    CASE
        WHEN order_delivered_carrier_date IS NULL THEN 'NULL'
        WHEN CONVERT(order_delivered_carrier_date, CHAR) REGEXP '^0000'
            THEN 'Zero date(0000-00-00...)'
        WHEN CONVERT(order_delivered_carrier_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN CONVERT(order_delivered_carrier_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN CONVERT(order_delivered_carrier_date, CHAR) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(order_delivered_carrier_date, CHAR), 25))
    END  AS format_found
FROM orders
GROUP BY format_found ORDER BY n DESC;
-- all dates 'YYYY-MM-DD HH:MM:SS'


-- 2.4: What date formats exist in order_delivered_customer_date?
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL THEN 'NULL'
        WHEN CONVERT(order_delivered_customer_date, CHAR) REGEXP '^0000' THEN 'Zero date(0000-00-00...)'
        WHEN CONVERT(order_delivered_customer_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN CONVERT(order_delivered_customer_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN CONVERT(order_delivered_customer_date, CHAR) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(order_delivered_customer_date, CHAR), 25))
    END AS format_found
FROM orders
GROUP BY format_found ORDER BY n DESC;
-- all dates 'YYYY-MM-DD HH:MM:SS'

-- 2.5: order_estimated_delivery_date
SELECT
    CASE
        WHEN order_estimated_delivery_date IS NULL THEN 'NULL'
        WHEN CONVERT(order_estimated_delivery_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN CONVERT(order_estimated_delivery_date, CHAR) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN CONVERT(order_estimated_delivery_date, CHAR) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(order_estimated_delivery_date, CHAR), 25))
    END AS format_found,
    COUNT(*) AS n,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders) * 100, 2) AS pct
FROM orders
GROUP BY format_found ORDER BY n DESC;
-- all dates 'YYYY-MM-DD HH:MM:SS'


-- 3.0 NULLS CHECK — Where is data missing?
SELECT
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_status IS NULL OR order_status = '' THEN 1 ELSE 0 END) AS missing_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_ts,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS missing_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_customer_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_estimated_date,
    COUNT(*) AS total_rows
FROM orders;
-- three columns with nulls 

-- 3.1 Are missing dates limited to non-delivered orders?
SELECT
    order_status,
    COUNT(*) AS total,
    SUM(CASE WHEN order_approved_at IS NULL  THEN 1 ELSE 0 END) AS missing_approved,
    SUM(CASE WHEN order_delivered_carrier_date  IS NULL THEN 1 ELSE 0 END) AS missing_carrier,
    SUM(CASE WHEN order_delivered_customer_date IS NULL  THEN 1 ELSE 0 END) AS missing_delivered
FROM orders
GROUP BY order_status
ORDER BY total DESC;


-- 4.0: Date logic — are sequences chronologically valid?
SELECT
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS approved_before_purchase,
    SUM(CASE WHEN order_delivered_carrier_date  < order_approved_at THEN 1 ELSE 0 END) AS shipped_before_approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS delivered_before_shipped,
    SUM(CASE WHEN order_estimated_delivery_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS estimate_before_purchase
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_delivered_carrier_date  IS NOT NULL 
  AND order_delivered_customer_date IS NOT NULL;
--   shipped_before_approved   → 1,350, carrier pickup logged before approval timestamp
--   delivered_before_shipped  → 23, physically impossible — timestamp corruption


-- 4.1 Inspect the 23 orderes delivered before shipped. How large is the discrepancy? Are they in 'delivered' status?
SELECT
    order_id,
    order_status,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date) AS gap_days
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
ORDER BY gap_days;
-- all 23 in 'delivered' status and gap_days range from 1 to 16 days, but majority within 0 to 3 days so its likely clock drift


-- 4.2 Inspect the 1,350 shipped-before-approved orders. How large is the approval lag? Consistent pattern or one-off?
SELECT
    order_status,
    COUNT(*)  AS affected_orders,
    ROUND(AVG(DATEDIFF(order_approved_at, order_delivered_carrier_date)), 1) AS avg_approval_lag_days,
    MIN(DATEDIFF(order_approved_at, order_delivered_carrier_date)) AS min_lag_days,
    MAX(DATEDIFF(order_approved_at, order_delivered_carrier_date)) AS max_lag_days
FROM orders
WHERE order_delivered_carrier_date < order_approved_at
  AND order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
GROUP BY order_status
ORDER BY affected_orders DESC;
-- Average lag < 1 day → systemic recording pattern, not random error.
-- 171-day outlier in delivered requires separate investigation 

-- WHAT THIS MEANS:
--   The average lag of under 1 day tells us this is not random data corruption.
--   It is a systematic pattern — the approval timestamp is routinely recorded
--   hours after the carrier has already collected the parcel. This is a known
--   behaviour in systems where physical operations run ahead of back-office processing.


-- 4.3 Identify orders with approval lag > 7 days (outliers beyond recording lag)
-- Anything over 7 days is not a recording delay — it warrants individual inspection.
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    DATEDIFF(order_approved_at, order_delivered_carrier_date) AS approval_lag_days
FROM orders
WHERE order_delivered_carrier_date < order_approved_at
  AND order_approved_at IS NOT NULL 
  AND order_delivered_carrier_date IS NOT NULL
  AND DATEDIFF(order_approved_at, order_delivered_carrier_date) > 7
ORDER BY approval_lag_days DESC;
--   Drilling into the 13 orders with lags over 7 days revealed three distinct
--   causes, each with a clear explanation:
--
--   (1) One order (171-day lag) has a carrier date entered 6 months before the
--       order was even placed. The approval itself was stamped 9 minutes after
--       purchase — perfectly normal. The carrier date is a data entry error,
--       not an approval problem.
--   (2) Eight orders were all placed and all approved on
--       twelve days later — while carriers collected them on 2-3days after order was placed.alter
--        The fact that an entire cohort of orders placed on the
--       same day share the same approval date points to a platform-level
--       approval system outage between September 1–13, 2017, not individual
--       mistakes.
--   (3) Four isolated orders from mid-2017 show the same approval lag pattern
--       on a smaller scale — likely the same systemic issue at lower volume.
--
-- DECISION:
--   All 1,359 orders stay in the analysis. Revenue, delivery dates, and customer
--   data are unaffected by the approval lag. A flag column (approval_sequence_valid)
--   will be added to vw_orders_clean to mark these rows. Any future query measuring
--   approval timing should filter to approval_sequence_valid = 'Yes'. No query
--   in the current CCO brief requires that filter.

-- 5.0: Dataset date range
SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order,
    DATEDIFF(MAX(order_purchase_timestamp), MIN(order_purchase_timestamp)) AS span_days,
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m'))  AS months_covered
FROM orders;
-- Sep 2016 – Oct 2018 | 772 days | 25 months

-- Edge month check — are the first and last months complete?
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month, COUNT(*) AS orders
FROM orders
WHERE DATE_FORMAT(order_purchase_timestamp, '%Y-%m') IN ('2016-09','2016-10','2018-08','2018-09','2018-10')
GROUP BY month ORDER BY month;
-- RESULT: Sep 2016 = 1 order (exclude from trends) | Oct 2018 = ~1,017 (partial month — caveat all charts)


-- ================================================================
-- Step 2: customers TABLE
-- ================================================================

-- 1.1 preview of data 
SELECT * FROM customers LIMIT 30;


-- 1.2: are they any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id)  AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_actual_customers,
    COUNT(*) - COUNT(DISTINCT customer_id) AS dup_customer_id,
    COUNT(*) - COUNT(DISTINCT customer_unique_id) AS dup_customer_unique_id
FROM customers;
-- no duplicate customer_id. there are 3345 repeat customers 

-- 1.3: how many customer states are there?
SELECT
    customer_state,
    COUNT(*) AS row_count
FROM customers
GROUP BY customer_state
ORDER BY row_count DESC;
-- 27 distinct states 


-- 1.4: NULLS CHECK — Where is data missing?
SELECT
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL OR customer_unique_id = '' THEN 1 ELSE 0 END) AS missing_unique_id,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL OR customer_zip_code_prefix = '' THEN 1 ELSE 0 END) AS missing_zip,
    SUM(CASE WHEN customer_city IS NULL OR customer_city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN customer_state IS NULL OR customer_state = '' THEN 1 ELSE 0 END) AS missing_state,
    COUNT(*) AS total_rows
FROM customers;
-- no nulls 


-- 1.5 Retention distribution — how many orders per customer?
-- Follows from the duplicate check (3,348 repeat customer_unique_ids)
SELECT
    orders_placed,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_unique_id)
				     FROM customers) * 100, 2) AS pct_of_customers
FROM (
    SELECT c.customer_unique_id, COUNT(DISTINCT o.order_id) AS orders_placed
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t
GROUP BY orders_placed
ORDER BY orders_placed;
-- 1 order  → 93,099 (96.88%)  ← 97% of customers never returned


-- ================================================================
-- Step 3: order_items TABLE
-- ================================================================

-- 1.1 preview of data
SELECT * 
FROM order_items 
LIMIT 30;

-- 1.2  are they any duplicates?
-- No single primary key — composite key is (order_id + order_item_id)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(order_id, '-', order_item_id)) AS unique_composite_keys,
    COUNT(*) - COUNT(DISTINCT CONCAT(order_id, '-', order_item_id)) AS duplicates
FROM order_items;
-- no duplicates found

-- 1.3 How many orders have no items at all?
SELECT COUNT(DISTINCT o.order_id) AS total_orders,
	   COUNT(DISTINCT oi.order_id) AS orders_with_items,
       COUNT(DISTINCT o.order_id)- COUNT(DISTINCT oi.order_id) AS orders_missing_items
FROM orders AS o
LEFT JOIN order_items AS oi
  ON o.order_id = oi.order_id;
-- 775 orders have no items.

-- 1.4. 775 Orders missing items — what are their statuses?
SELECT o.order_status, 
       COUNT(*) AS orders_with_no_items
FROM orders  AS o
LEFT JOIN order_items AS oi 
   ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_with_no_items DESC;
-- mostly unavailable/canceled (expected) | 1 shipped order has no items, log as anomaly

  
-- 2. CATEGORICAL COLUMNS 

-- 2.1 order_item_id — what values exist?
SELECT
    order_item_id,
    COUNT(*) AS row_count
FROM order_items
GROUP BY order_item_id
ORDER BY order_item_id;
-- Confirms max items per order and whether sequencing looks clean

-- 2.2 seller_id — how many distinct sellers appear?
SELECT COUNT(DISTINCT seller_id) AS distinct_sellers 
FROM order_items;
-- 3095 sellers same row count with sellers table 


-- 3. what date formates exist?
SELECT
    CASE
        WHEN shipping_limit_date IS NULL THEN 'NULL'
        WHEN shipping_limit_date  REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN shipping_limit_date  REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN shipping_limit_date  REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$' THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(CONVERT(shipping_limit_date, CHAR), 25))
    END AS format_found,
    COUNT(*) AS n,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM order_items) * 100, 2) AS pct
FROM order_items
GROUP BY format_found ORDER BY n DESC;
-- all shipping_limit_date are in 'YYYY-MM-DD HH:MM:SS' format


-- 4. NULLS CHECK — Where is data missing?
SELECT
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN order_item_id IS NULL OR order_item_id = '' THEN 1 ELSE 0 END) AS missing_item_id,
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) AS missing_seller_id,
    SUM(CASE WHEN price IS NULL OR price = '' THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS missing_freight,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS missing_ship_date,
    COUNT(*) AS total_rows
FROM order_items;
-- no missing values

-- 5. Price and freight range
SELECT
    ROUND(MIN(price), 2) AS min_price,
    ROUND(MAX(price), 2) AS max_price,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(STDDEV(price), 2) AS stddev_price,
    ROUND(MIN(freight_value), 2) AS min_freight,
    ROUND(MAX(freight_value), 2) AS max_freight,
    ROUND(AVG(freight_value), 2) AS avg_freight,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS zero_neg_price,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight,
    SUM(CASE WHEN freight_value = 0 THEN 1 ELSE 0 END) AS zero_freight_items
FROM order_items;
--   383 items have freight_value = 0. These are NOT missing data — they are
--   explicitly recorded as zero, meaning the seller offered free shipping on these items. 


-- High price spot check — do expensive items belong to plausible categories?
SELECT oi.price, oi.freight_value, p.product_category_name
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE oi.price > 3000
ORDER BY oi.price DESC;
-- pcs, eletronicos, construcao — all plausible 


-- ================================================================
-- Step 4: order_payments TABLE 
-- ================================================================

-- 1.1 data preview
SELECT * 
FROM order_payments 
LIMIT 30;


-- 1.2 are they duplicates? 
-- order_id is not unique here — multiple payment rows per order are expected.
-- The real question: how many extra rows exist and why?
SELECT
    COUNT(*) AS total_payment_rows,
    COUNT(DISTINCT order_id) AS orders_with_payments,
    COUNT(*) - COUNT(DISTINCT order_id) AS extra_payment_rows,
    (SELECT COUNT(*) FROM orders) - COUNT(DISTINCT order_id) AS orders_with_no_payment
FROM order_payments;
--   extra_payment_rows   →   4,446  ← split/instalment payments
--   orders_with_no_payment →    1   ← investigate below

-- 1.3 Which order has no payment at all?
SELECT o.order_id, 
       o.order_status, 
       o.order_delivered_customer_date
FROM orders AS o
LEFT JOIN order_payments AS  p 
   ON o.order_id = p.order_id
WHERE p.order_id IS NULL;
-- 1 delivered order with no payment — data integrity gap. Exclude from revenue.


-- 2. CATEGORICAL COLUMNS 

-- 2.1 payment_type variants checking for placeholders or unexpected values
SELECT
    payment_type,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM order_payments) * 100, 2) AS pct,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_value), 2) AS avg_value
FROM order_payments
GROUP BY payment_type
ORDER BY row_count DESC;
-- about 74% orders pais by credit_card
--   5 payment_types confirmed.
--   in the "not_defined"category  3 orders have  R$ 0

-- 2.2 what is the order_status for 3 orders  that have payment_value of  R$ 0?
SELECT o.order_id,
       o.order_status
FROM orders o
LEFT JOIN order_payments p
  ON o.order_id = p.order_id
WHERE p.payment_type = 'not_defined'
    AND p.payment_value = 0;
-- all orders were cancelled. so exclude from revenue analysis.

-- 3. NULLS CHECK — Where is data missing?
SELECT
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS missing_sequential,
    SUM(CASE WHEN payment_type IS NULL OR payment_type = '' THEN 1 ELSE 0 END) AS missing_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS missing_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS missing_value,
    COUNT(*) AS total_rows
FROM order_payments;
-- no missing values


-- 4. Instalment range — are credit card instalment counts realistic?
SELECT
    MIN(payment_installments) AS min_instalments,
    MAX(payment_installments) AS max_instalments,
    ROUND(AVG(payment_installments), 1) AS avg_instalments
FROM order_payments
WHERE payment_type = 'credit_card';
-- max_installments is  24 which is within Brazilian credit card norms

-- 5. Payment value range
SELECT
    ROUND(MIN(payment_value), 2) AS min_value,
    ROUND(MAX(payment_value), 2) AS max_value,
    ROUND(AVG(payment_value), 2) AS avg_value,
    SUM(CASE WHEN payment_value <  0 THEN 1 ELSE 0 END) AS negative_values,
    SUM(CASE WHEN payment_value =  0 THEN 1 ELSE 0 END) AS zero_values
FROM order_payments;
-- no negatives. 9 rows ahve zero payment_value. 3 were identified in step 2.1 . investigate the order 6 rows 

-- 5.1 what is the status for the 6 orders with zero payment_value?
SELECT o.order_id,
       o.order_status,
       p.payment_type
FROM orders AS o
LEFT JOIN order_payments AS p
   ON o.order_id = p.order_id 
WHERE payment_value = 0;
-- all have payment type of voucher and 4 out of 6 were delivered to customers.

-- 5.2 do those orders have other payment rows that covered the actual cost?
SELECT
    p.order_id,
    o.order_status,
    COUNT(*) AS total_payment_rows,
    SUM(p.payment_value) AS total_payment_value,
    GROUP_CONCAT(
        CONCAT(p.payment_type, ' R$', p.payment_value)
        ORDER BY p.payment_sequential
        SEPARATOR ' | ') AS payment_breakdown
FROM order_payments p
JOIN orders o 
  ON p.order_id = o.order_id
WHERE p.order_id IN (
    SELECT order_id
    FROM order_payments
    WHERE payment_type = 'voucher'
      AND payment_value = 0
)
GROUP BY p.order_id, o.order_status
ORDER BY total_payment_value;
-- All 6 zero-value voucher orders have positive payment values from other methods covering the full order cost. 

-- ================================================================
-- Step 5: order_reviews TABLE
-- ================================================================

-- 1.1 data preview
SELECT * 
FROM order_reviews 
LIMIT 30;


-- 1.2 Are they any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS unique_review_ids,
    COUNT(*) - COUNT(DISTINCT review_id) AS duplicate_review_ids
FROM order_reviews;
-- no duplicates found 

-- 3. CATEGORICAL COLUMNS 

-- 3.1 review_score — all variants checking  for values outside 1–5
SELECT
    review_score,
    COUNT(*) AS row_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM order_reviews) * 100, 2) AS pct
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;
--   Valid range 1–5 confirmed. 

-- 3.2 Confirm no out-of-range scores
SELECT COUNT(*) AS invalid_scores 
FROM order_reviews 
WHERE review_score NOT BETWEEN 1 AND 5;
-- no review_score out of range

-- 3.3 Comment fields — how many have text vs empty? (optional fields, expect high null rate)
SELECT
    SUM(CASE WHEN review_comment_title IS NULL OR review_comment_title = '' THEN 1 ELSE 0 END) AS empty_title,
    SUM(CASE WHEN review_comment_message IS NULL OR review_comment_message = '' THEN 1 ELSE 0 END) AS empty_message,
    ROUND(SUM(CASE WHEN review_comment_title IS NULL OR review_comment_title = '' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_no_title,
    ROUND(SUM(CASE WHEN review_comment_message IS NULL OR review_comment_message = '' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_no_message,
    COUNT(*) AS total_rows
FROM order_reviews;
-- ~88% no title | ~59% no message. so review_score is the only reliable field for sentiment analysis


-- 4. What date formats exist? 

-- 4.1 review_creation_date
SELECT
    CASE
        WHEN review_creation_date IS NULL THEN 'NULL'
        WHEN review_creation_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN review_creation_date  REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN review_creation_date  REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(review_creation_date, 25))
    END AS format_found,
    COUNT(*) AS n,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM order_reviews) * 100, 2)AS pct
FROM order_reviews
GROUP BY format_found 
ORDER BY n DESC;
-- all YYYY-MM-DD HH:MM:SS format


-- 4.2 review_answer_timestamp
SELECT
    CASE
        WHEN review_answer_timestamp IS NULL THEN 'NULL'
        WHEN review_answer_timestamp REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN review_answer_timestamp REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
        WHEN review_answer_timestamp REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 'DD/MM/YYYY or MM/DD/YYYY'
        ELSE CONCAT('Other: ', LEFT(review_answer_timestamp, 25))
    END AS format_found,
    COUNT(*) AS n,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM order_reviews) * 100, 2) AS pct
FROM order_reviews
GROUP BY format_found 
ORDER BY n DESC;
-- all YYYY-MM-DD HH:MM:SS format

-- 5. NULLS + EMPTY STRINGS 
SELECT
    SUM(CASE WHEN review_id IS NULL OR review_id = '' THEN 1 ELSE 0 END) AS missing_review_id,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS missing_score,
    SUM(CASE WHEN review_creation_date IS NULL  THEN 1 ELSE 0 END) AS missing_creation_date,
    SUM(CASE WHEN review_answer_timestamp IS NULL  THEN 1 ELSE 0 END) AS missing_answer_ts,
    COUNT(*) AS total_rows
FROM order_reviews;
-- no missing values 


-- 6. How many orders have more than one review row?
WITH review_count AS (
     SELECT order_id,
            COUNT(*) AS cnt
	 FROM order_reviews
     GROUP BY order_id)
     
SELECT cnt as review_number,
      COUNT(*) AS total
FROM review_count
GROUP BY review_number;
-- 243 orders have 2 reviews so deduplication is required 


-- ================================================================
-- Step 6: products TABLE 
-- ================================================================

-- 1.1 data preview
SELECT * 
FROM products 
LIMIT 30;


-- 1.2. are they any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicates
FROM products;
-- no duplicates found 


-- 2. CATEGORICAL COLUMNS 

-- 2.1 product_category_name — all variants (check for placeholders, nulls as a category)
SELECT
    product_category_name,
    COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count DESC;
-- 73 named categories + NULL appearing as a value
-- NULL appears 610 times — same count repeated in step 5 drives further investigation

-- 2.2 Bottom of category list — any categories with suspiciously few products?
SELECT product_category_name, 
       COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count ASC
LIMIT 10;
-- Some categories have only 1–3 products 


-- 3. NULLS + EMPTY STRINGS 
SELECT
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name  = '' THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN product_name_lenght IS NULL OR product_name_lenght = 0 THEN 1 ELSE 0 END) AS missing_name_len,
    SUM(CASE WHEN product_description_lenght IS NULL OR product_description_lenght = 0 THEN 1 ELSE 0 END) AS missing_desc_len,
    SUM(CASE WHEN product_photos_qty IS NULL OR product_photos_qty = 0 THEN 1 ELSE 0 END) AS missing_photos,
    SUM(CASE WHEN product_weight_g IS NULL OR product_weight_g = 0 THEN 1 ELSE 0 END) AS missing_weight,
    SUM(CASE WHEN product_length_cm IS NULL OR product_length_cm = 0 THEN 1 ELSE 0 END) AS missing_length,
    SUM(CASE WHEN product_height_cm IS NULL OR product_height_cm = 0 THEN 1 ELSE 0 END) AS missing_height,
    SUM(CASE WHEN product_width_cm IS NULL OR product_width_cm = 0 THEN 1 ELSE 0 END) AS missing_width,
    COUNT(*) AS total_rows
FROM products;
--   610 products missing_category, missing_name_len, missing_desc_len, missing_photos
--   2 products missing_weight, missing_length, missing_width


-- 3.1 Are the same 610 products null across all four fields simultaneously?
SELECT COUNT(*) AS products_null_in_all_four
FROM products
WHERE product_category_name IS NULL 
      AND (product_name_lenght IS NULL OR product_name_lenght  = 0)
      AND (product_description_lenght IS NULL OR product_description_lenght = 0)
      AND product_photos_qty IS NULL OR product_photos_qty = 0;
-- this are mot correlated nulls


-- 3.2 Did these incomplete products generate real revenue?
SELECT
    COUNT(DISTINCT oi.order_id) AS orders_affected,
    ROUND(SUM(oi.price), 2) AS revenue_at_stake
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NULL OR p.product_category_name = '';
-- These products generated real revenue — cannot be ignored. Label as 'Uncategorised' in cleaning layer.

    
-- 3.2 Physical dimension validity
SELECT
    ROUND(MIN(product_weight_g), 0) AS min_weight_g,
    ROUND(MAX(product_weight_g), 0) AS max_weight_g,
    SUM(CASE WHEN product_weight_g <= 0 THEN 1 ELSE 0 END) AS zero_neg_weight
FROM products
WHERE product_weight_g IS NOT NULL;
-- min weight = 0g (physically impossible -maybe a data entry error)

-- whats the revenue from this 0g products?
SELECT
    COUNT(DISTINCT oi.order_id) AS orders_affected,
    ROUND(SUM(oi.price), 2) AS revenue_at_stake
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_weight_g = 0 ;
-- these products generated revenue so exclude from freight analysis

-- ================================================================
-- Step 7: sellers TABLE
-- ================================================================

-- 1.1 sellers TABLE
SELECT * 
FROM sellers 
LIMIT 30;


-- 1.2 are there any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_ids,
    COUNT(*) - COUNT(DISTINCT seller_id) AS duplicates
FROM sellers;
-- no duplicates found


-- 2. CATEGORICAL COLUMNS 

-- 2.1 seller_state — all variants
SELECT
    seller_state,
    COUNT(*)AS seller_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM sellers) * 100, 1) AS pct
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;
-- SP dominant (~40%)

-- 1.3 seller_city — top and bottom values
SELECT seller_city, COUNT(*) AS n FROM sellers GROUP BY seller_city ORDER BY n DESC LIMIT 10;
SELECT seller_city, COUNT(*) AS n FROM sellers GROUP BY seller_city ORDER BY n ASC  LIMIT 10;

-- 1.4 seller_zip_code_prefix — format consistency
SELECT
    LENGTH(seller_zip_code_prefix) AS zip_length,
    COUNT(*) AS row_count
FROM sellers
GROUP BY zip_length
ORDER BY row_count DESC;
-- Confirm consistent zip length of 5


-- 2. NULLS + EMPTY STRINGS
SELECT
    SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) AS missing_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL OR seller_zip_code_prefix = '' THEN 1 ELSE 0 END) AS missing_zip,
    SUM(CASE WHEN seller_city IS NULL OR seller_city  = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN seller_state IS NULL OR seller_state = '' THEN 1 ELSE 0 END) AS missing_state,
    COUNT(*) AS total_rows
FROM sellers;
-- no nulls or missing values 

-- 3. Seller order volume distribution

WITH seller_orders AS (
		SELECT seller_id, COUNT(DISTINCT order_id) AS orders_per_seller
			FROM order_items
			GROUP BY seller_id)
    
SELECT
		MAX(orders_per_seller) AS max_orders,
		MIN(orders_per_seller) AS min_orders,
		ROUND(AVG(orders_per_seller), 1) AS avg_orders,
		SUM(CASE WHEN orders_per_seller = 1 THEN 1 ELSE 0 END) AS sellers_1_order,
		SUM(CASE WHEN orders_per_seller BETWEEN 2 AND 9 THEN 1 ELSE 0 END) AS sellers_2_to_9,
		SUM(CASE WHEN orders_per_seller BETWEEN 10 AND 99  THEN 1 ELSE 0 END) AS sellers_10_to_99,
		SUM(CASE WHEN orders_per_seller >= 100 THEN 1 ELSE 0 END) AS sellers_100_plus
FROM seller_orders;
--   max: 1,854 | avg: 32.3
--   18.4% of sellers completed only 1 order — one-and-done vendors
--   6.8% of sellers have 100+ orders — these drive the majority of GMV


-- ================================================================
-- Step 8: geolocation TABLE
-- ================================================================

-- 1.1 data preview
SELECT * 
FROM geolocation 
LIMIT 30;


-- 1.2 are they any duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_codes,
    COUNT(*) - COUNT(DISTINCT geolocation_zip_code_prefix) AS duplicate_rows,
    ROUND((COUNT(*) - COUNT(DISTINCT geolocation_zip_code_prefix)) / COUNT(*) * 100, 1) AS pct_duplicate,
    ROUND(COUNT(*) / COUNT(DISTINCT geolocation_zip_code_prefix), 0) AS avg_rows_per_zip
FROM geolocation;
-- 98.1% duplicates
--   unique zip codes     →  19,015
--   duplicate rows       → 981,148 (98.1%)
--   avg rows per zip     →      53
--
--   This is NOT a lookup table. It is a raw GPS dataset with multiple
--   lat/lng readings per zip code. Joining this raw to customers or sellers
--   multiplies every row by ~53 — completely corrupting any aggregation.
--   Deduplicate with ROW_NUMBER() PARTITION BY zip required


-- 2. CATEGORICAL COLUMNS 

-- 2.1 geolocation_state — all variants
SELECT
    geolocation_state,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zips,
    COUNT(*) AS raw_rows
FROM geolocation
GROUP BY geolocation_state
ORDER BY unique_zips DESC;
-- 27 states present. SP has most zip codes

-- 2.2 geolocation_city — spot check for encoding issues
SELECT geolocation_city, COUNT(*) AS n FROM geolocation GROUP BY geolocation_city ORDER BY n DESC  LIMIT 10;
SELECT geolocation_city, COUNT(*) AS n FROM geolocation GROUP BY geolocation_city ORDER BY n ASC   LIMIT 10;


-- 2.3 NULLS + EMPTY STRINGS 
SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL OR geolocation_zip_code_prefix = '' THEN 1 ELSE 0 END) AS missing_zip,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS missing_lat,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS missing_lng,
    SUM(CASE WHEN geolocation_city IS NULL OR geolocation_city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN geolocation_state  IS NULL OR geolocation_state = '' THEN 1 ELSE 0 END) AS missing_state,
    COUNT(*) AS total_rows
FROM geolocation;
-- no missing values 


-- ================================================================
-- Step 9: category_translation TABLE
-- ================================================================

-- 1.1 data preview
SELECT * 
FROM category_translation 
LIMIT 30;


-- 1.2 are they any duplicates?
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name)AS unique_pt_names,
    COUNT(DISTINCT product_category_name_english) AS unique_en_names,
    COUNT(*) - COUNT(DISTINCT product_category_name) AS duplicate_pt_names
FROM category_translation;
-- 71 rows | confirmed 1:1 mapping between Portuguese and English names


-- 1.3 Does the translation table cover every category that exists in products?
SELECT
    p.product_category_name AS portuguese_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    t.product_category_name_english AS english_translation
FROM products p
LEFT JOIN category_translation t 
   ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name, t.product_category_name_english
ORDER BY product_count DESC;
-- 2 product categories with 10 products have no English translation, will show NULL in all English reports
-- patch before any English-language report runs

-- 1.4 Reverse: are there translations for categories that don't exist in products?
SELECT COUNT(*) AS phantom_translations
FROM category_translation t
LEFT JOIN products p 
   ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NULL;
-- none found

-- 2. NULLS + EMPTY STRINGS 
SELECT
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) AS missing_pt_name,
    SUM(CASE WHEN product_category_name_english IS NULL OR product_category_name_english = '' THEN 1 ELSE 0 END) AS missing_en_name,
    COUNT(*) AS total_rows
FROM category_translation;
-- no missing values


-- ================================================================
-- Step 10:CROSS-TABLE REFERENTIAL INTEGRITY
-- ================================================================

-- All individual tables profiled, checking for relationship holds as Orphaned records vanish silently in INNER JOINs.

SELECT COUNT(*) AS orphaned_items FROM order_items AS i LEFT JOIN orders AS o ON i.order_id = o.order_id WHERE o.order_id IS NULL;
SELECT COUNT(*) AS orphaned_payments FROM order_payments AS p LEFT JOIN orders AS o ON p.order_id = o.order_id WHERE o.order_id IS NULL;
SELECT COUNT(*) AS orphaned_reviews FROM order_reviews AS r LEFT JOIN orders AS o ON r.order_id = o.order_id WHERE o.order_id IS NULL;
SELECT COUNT(*) AS items_no_product FROM order_items AS i LEFT JOIN products AS p ON i.product_id = p.product_id WHERE p.product_id IS NULL;
SELECT COUNT(*) AS items_no_seller FROM order_items AS  i LEFT JOIN sellers AS s ON i.seller_id = s.seller_id WHERE s.seller_id IS NULL;
SELECT COUNT(*) AS orders_no_customer FROM orders AS o LEFT JOIN customers AS c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL;
-- all 0, referential integrity clean across all joins

-- 1.2 Review coverage
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS orders_with_review,
    COUNT(DISTINCT o.order_id) - COUNT(DISTINCT r.order_id) AS orders_no_review,
    ROUND((COUNT(DISTINCT o.order_id) - COUNT(DISTINCT r.order_id))
        / COUNT(DISTINCT o.order_id) * 100, 1) AS pct_no_review
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id;
-- 99.2% of orders have a review always use LEFT JOIN when attaching reviews

-- 2.2 Customer zip → geolocation match rate
SELECT
    COUNT(DISTINCT c.customer_zip_code_prefix) AS customer_zips,
    COUNT(DISTINCT g.geolocation_zip_code_prefix) AS matched_zips,
    COUNT(DISTINCT c.customer_zip_code_prefix) - COUNT(DISTINCT g.geolocation_zip_code_prefix) AS unmatched_zips
FROM customers c
LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM geolocation) g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
-- 157 customers without geogrphical location

-- Seller zip → geolocation match rate
SELECT
    COUNT(DISTINCT s.seller_zip_code_prefix) AS seller_zips,
    COUNT(DISTINCT g.geolocation_zip_code_prefix) AS matched_zips,
    COUNT(DISTINCT s.seller_zip_code_prefix)- COUNT(DISTINCT g.geolocation_zip_code_prefix) AS unmatched_zips
FROM sellers s
LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM geolocation) g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;
-- 7 sellers with unmatched_zips


-- ================================================================
-- Step 11: FINDINGS REGISTER
-- ================================================================

--  must fix before any analysis

--  F01  geolocation: 98.1% duplicate rows, never join raw table. Use ROW_NUMBER() PARTITION BY zip in a view.
--
--   F02  order_payments: 4,446 extra rows (instalment/split payments),always SUM(payment_value) GROUP BY order_id before joining.

--   F03  order_reviews: review_id spans multiple order_ids (814 affected) ROW_NUMBER() PARTITION BY order_id ORDER BY answer_timestamp DESC
--        do not deduplicate by review_id alone.

--   F04  1 delivered order has no payment record, exclude from all revenue calculations.

--   F05  8 delivered orders have zero date instead of delivery date filter: AND order_delivered_customer_date IS NOT NULL
--                  AND CONVERT(order_delivered_customer_date, CHAR) IS NOT NULL AND CONVERT(order_delivered_customer_date, CHAR) NOT REGEXP '^0000'

--   F06  3 payment rows: type='not_defined', value=R$0. exclude: WHERE payment_type != 'not_defined'

--   F07  2 product categories missing English translatio. patch: pc_gamer + portateis_cozinha_e_preparadores_de_alimentos

--   F08  Sep 2016 = 1 order (exclude from trends) Oct 2018 = partial month (caveat all charts)

--   F09  23 orders with customer delivery date BEFORE carrier pickup date
--        → gaps range 0 to -16 days, all in 'delivered' status
--        → root cause: carrier logs timestamps retrospectively (batch/manual);
--          customer confirmation arrives in real time — systemic recording lag,
--          not random data corruption
--        → customer_date is reliable; carrier_date is not for these 23 rows
--        → late/on-time flag (customer vs estimated) and fulfilment_days
--          (purchase to customer) are UNAFFECTED — do not hard-exclude
--        → handled via carrier_sequence_valid flag in vw_orders_clean
--        → add WHERE carrier_sequence_valid = 'Yes' ONLY in queries that
--          specifically use order_delivered_carrier_date
--
--   F10 1,359 orders with carrier pickup BEFORE approval timestamp
--        → delivered: 1,350 | avg lag 0.9 days | min 0 | max 171 days
--        → shipped:       9 | avg lag 1.3 days | min 0 | max   4 days
--        → drill-down on lag > 7 days confirmed 13 outlier orders:
--            1 order: corrupted carrier_date (predates purchase by 6 months)
--                     approval on this order is clean (9 min after purchase)
--            8 orders: Sep 2017 approval system outage — all purchased 2017-09-01,
--                      all approved 2017-09-13 (platform-level batch delay)
--            4 orders: isolated approval lag cases, Jun–Sep 2017
--        → all 1,359 revenue values are valid — do NOT exclude from GMV
--        → flag via approval_sequence_valid = 'No' in vw_orders_clean
--        → add WHERE approval_sequence_valid = 'Yes' ONLY for approval-timing analysis
--