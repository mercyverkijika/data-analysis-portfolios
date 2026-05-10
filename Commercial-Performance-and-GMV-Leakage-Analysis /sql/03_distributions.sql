-- =============================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Business Distributions
-- =============================================================
-- PURPOSE:
--   Run business distributions AFTER cleaning views are built.
--   All queries use vw_master or vw_orders_clean — never raw tables.
--   This ensures distributions and analysis scripts are consistent.

-- EXCEPTION: BD2 (revenue leakage):
--   vw_master contains delivered orders only by design.
--   Canceled and unavailable orders require raw tables.
--   This is intentional — not a data quality gap.

-- NOTE ON vw_master grain
--   vw_master is at ORDER ITEM level — one row per item per order.



USE nexora_commerce;


-- =============================================================
-- BD1. Monthly Revenue Trend (BQ1)
-- =============================================================
-- Boundary months excluded — proven partial by first/last order
--   2016-09:  4 orders | 2016-09-04 to 2016-09-15 | 11 days
--   2016-10: 324 orders | 2016-10-02 to 2016-10-22 | 20 days
--   2018-09:  16 orders | 2018-09-03 to 2018-09-29 | data cutoff
-- Full months: 2016-11-01 through 2018-08-31 inclusive.

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')  AS YearMonth,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(item_price), 2) AS product_revenue,
    ROUND(SUM(item_freight), 2)  AS freight_revenue,
    ROUND(SUM(item_total_revenue), 2) AS total_gmv
FROM vw_master
WHERE order_purchase_timestamp >= '2016-11-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY YearMonth
ORDER BY YearMonth;



-- =============================================================
-- BD2. Revenue Leakage — Unfulfilled Orders (BQ1)
-- =============================================================
-- uses raw tables — vw_master is delivered orders only.

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(i.price), 2) AS attempted_revenue
FROM orders o
LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status IN ('canceled', 'unavailable')
GROUP BY o.order_status;

-- =============================================================
-- BD3. Category Revenue vs Volume (BQ2)
-- =============================================================

SELECT
    category_english,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(item_price), 2) AS total_revenue,
    ROUND(AVG(item_price), 2) AS avg_item_price,
    ROUND(SUM(item_price) / SUM(SUM(item_price)) OVER () * 100, 2) AS pct_of_revenue
FROM vw_master
GROUP BY category_english
ORDER BY total_revenue DESC
LIMIT 20;


-- =============================================================
-- BD4. Regional Revenue Distribution (BQ2)
-- =============================================================

SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(item_price), 2) AS total_revenue,
    ROUND(SUM(item_price) / SUM(SUM(item_price)) OVER () * 100, 1)  AS pct_of_revenue
FROM vw_master
GROUP BY customer_state
ORDER BY total_revenue DESC;
-- SP ~40% of revenue. Top 3 states ~64%. Geographic concentration = commercial risk (BQ2).


-- =============================================================
-- BD5. Delivery Performance Summary (BQ4)
-- =============================================================

SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_count,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2
    ) AS late_pct,
    ROUND(AVG(delivery_delay_days), 1) AS avg_days_vs_estimate
FROM vw_orders_clean;
-- 6.8% of orders are late 


-- =============================================================
-- BD6. Late Delivery vs Review Score (BQ4)
-- =============================================================
-- Deduplicated to order level before aggregating review score.
-- vw_master is item-level — averaging review_score directly would weight multi-item orders more heavily.

WITH order_level AS (
	SELECT DISTINCT
        order_id,
        delivery_status,
        review_score
    FROM vw_master
    WHERE review_score IS NOT NULL
    )
SELECT
    delivery_status,
    COUNT(*)  AS order_count,
    ROUND(AVG(review_score), 2) AS avg_score,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_negative
FROM order_level
GROUP BY delivery_status;
-- Causal chain: late delivery → poor review → customer does not return (BQ3 + BQ4)


-- =============================================================
-- BD7. Late Delivery — Monetised Exposure (BQ4)
-- =============================================================

SELECT
    delivery_status,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_unique_id) AS customers_affected,
    ROUND(SUM(item_price), 2) AS revenue_at_risk
FROM vw_master
GROUP BY delivery_status;



-- =============================================================
-- BD8. Seller Scorecard — Revenue vs Operational Quality (BQ5)
-- =============================================================

SELECT
    seller_id,
    seller_state,
    COUNT(DISTINCT order_id)  AS orders_fulfilled,
    ROUND(SUM(item_price), 2)  AS gross_revenue,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(
        COUNT(DISTINCT CASE WHEN delivery_status = 'Late' THEN order_id END)
        / COUNT(DISTINCT order_id) * 100, 1
    )  AS late_pct
FROM vw_master
GROUP BY seller_id, seller_state
ORDER BY gross_revenue DESC
LIMIT 20;



-- =============================================================
-- BD9. Review Score by Category (BQ2 × BQ4)
-- =============================================================

SELECT
    category_english,
    COUNT(*)  AS order_count,
    ROUND(AVG(review_score), 2) AS avg_score,
    ROUND(SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS pct_one_star,
    ROUND(SUM(total_revenue), 2) AS category_revenue
FROM (
    SELECT DISTINCT
        order_id,
        category_english,
        review_score,
        SUM(item_price) OVER (PARTITION BY order_id, category_english)  AS total_revenue
    FROM vw_master
    WHERE review_score IS NOT NULL
) order_level
GROUP BY category_english
HAVING order_count > 100
ORDER BY avg_score ASC
LIMIT 20;