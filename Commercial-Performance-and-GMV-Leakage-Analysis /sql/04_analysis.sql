
-- ================================================================
-- Commercial Performance and GMV Leakage Analysis; NEXORA COMMERCE LTD 
-- Analytical Queries
-- Dataset: Olist Brazilian E-Commerce (delivered via vw_master)
-- ================================================================

-- ALL REVENUE FIGURES IN THIS SCRIPT ARE GMV (Gross Merchandise Value), NOT Nexora's net platform revenue.
-- GMV = the total value of transactions processed through the platform (item_price + freight_value for delivered orders).
-- It represents what customers paid in full — not what Nexora retains after paying out sellers.

-- WHY NET REVENUE IS NOT CALCULABLE:
--   The Olist public dataset does not include seller commission rates, fee schedules, or net seller payout figures. The exact
--   percentage Nexora charges per sale — which varies by category and seller tier — is absent from all nine source tables.
--   Nexora's actual net revenue = GMV × applicable commission rate, which cannot be derived from this dataset alone.

-- FREIGHT TREATMENT:
--   freight_value is collected from the customer and passed directly to the carrier. It is a pass-through — not Nexora's
--   own revenue. For this reason:
--     • Freight is INCLUDED in Total GMV (reflects full transaction
--       value processed through the platform).
--     • Freight is EXCLUDED from leakage rate calculations, which
--       are computed on item_price (product revenue) only.
--
-- IMPLICATION FOR THE CCO:
--   All KPI values, leakage figures, and revenue targets in this
--   analysis are expressed in GMV terms. To convert any figure to
--   Nexora's net revenue impact, apply the applicable commission
--   rate to the GMV figure. This requires internal rate data not
--   present in the Olist dataset.

-- ALL QUERIES IN THIS SCRIPT USE VIEWS, NOT RAW TABLES.

-- SCRIPT STRUCTURE:
--   Section 1 — BQ1: Revenue Performance & Leakage
--   Section 2 — BQ2: Category, Seller, Regional Breakdown
--   Section 3 — BQ3: Customer Retention & Behaviour
--   Section 4 — BQ4: Delivery Performance, Reviews & Retention
--   Section 5 — BQ5: Seller Value vs Risk

-- GRAIN OF vw_master: one row = one item within one delivered order.

-- ================================================================

USE nexora_commerce;


-- ================================================================
-- SECTION 1 — BQ1: REVENUE PERFORMANCE & LEAKAGE
-- "How much revenue are we generating vs how much should we be generating — where is the gap?"
-- ================================================================


-- 1.1  TOP-LINE REVENUE SUMMARY
-- Single-row executive summary. All figures from delivered orders.

SELECT
    COUNT(DISTINCT order_id) AS total_delivered_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(item_price), 2) AS gross_product_revenue,
    ROUND(SUM(item_freight), 2) AS gross_freight_revenue,
    ROUND(SUM(item_total_revenue), 2) AS gross_item_revenue,
    ROUND(AVG(item_price), 2) AS avg_item_price,
    ROUND(SUM(total_payment_value)
          / COUNT(DISTINCT order_id), 2) AS avg_order_value_paid,
    ROUND(SUM(item_price)
          / COUNT(DISTINCT order_id), 2) AS avg_order_value_catalogue
FROM vw_master;

-- 1.2  MONTHLY REVENUE TREND (Nov 2016 – Aug 2018)
-- ----------------------------------------------------------------
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS YearMonth,
    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(item_price), 2) AS product_revenue,
    ROUND(SUM(item_freight), 2) AS freight_revenue,
    ROUND(SUM(item_total_revenue), 2)  AS total_item_revenue,
    ROUND(AVG(item_price), 2)  AS avg_item_price
FROM vw_master
GROUP BY YearMonth
ORDER BY YearMonth;

-- 1.3  REVENUE LEAKAGE — UNFULFILLED ORDERS
-- ----------------------------------------------------------------
-- This query reaches into the raw orders table because vw_master
-- only contains DELIVERED orders. We need non-delivered orders here
-- to quantify lost revenue.

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(i.price), 2) AS attempted_product_revenue,
    ROUND(SUM(i.freight_value), 2) AS attempted_freight_revenue,
    ROUND(SUM(i.price + i.freight_value), 2) AS total_attempted_revenue,
    ROUND(AVG(i.price), 2)   AS avg_item_price
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status IN ('canceled', 'unavailable')
GROUP BY o.order_status
ORDER BY total_attempted_revenue DESC;

-- 1.4  REVENUE GAP — DELIVERED VS ATTEMPTED
-- ----------------------------------------------------------------
-- Quantifies the gap between revenue that reached the customer and revenue that was attempted but lost (canceled/unavailable).

WITH gap AS (
    SELECT
        'Delivered'  AS outcome,
        COUNT(DISTINCT o.order_id)  AS order_count,
        ROUND(SUM(i.price), 2) AS product_revenue
    FROM orders o
    JOIN order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'

    UNION ALL

    SELECT
        'Lost — Canceled / Unavailable',
        COUNT(DISTINCT o.order_id),
        ROUND(SUM(i.price), 2)
    FROM orders o
    JOIN order_items i ON o.order_id = i.order_id  -- INNER JOIN: only orders with items
    WHERE o.order_status IN ('canceled', 'unavailable')
)

SELECT
    outcome,
    order_count,
    product_revenue,
    ROUND(product_revenue / SUM(product_revenue) OVER () * 100, 1) AS pct_of_total,
    ROUND(order_count / SUM(order_count)     OVER () * 100, 1) AS pct_of_orders
FROM gap
ORDER BY product_revenue DESC; 

-- Orders with no items (some canceled/unavailable) have no revenue to leak  and are excluded — this is intentional, not a data loss.
-- LEAKAGE RATE = Lost revenue / (Delivered + Lost) * 100

-- 1.5  PAYMENT METHOD DISTRIBUTION
-- ----------------------------------------------------------------
-- Understand how customers pay. Instalment-heavy behaviour affects
-- cash flow timing. vw_master carries primary_payment_type from
-- vw_orders_clean, which sourced it from vw_payments_clean.
 
SELECT
    COALESCE(primary_payment_type, 'No Payment Record') AS primary_payment_type,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER () * 100, 1) AS pct_of_orders,
    ROUND(SUM(item_total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_installments), 1) AS avg_installments,
    ROUND(AVG(item_price),2) AS avg_item_price
FROM vw_master
GROUP BY COALESCE(primary_payment_type, 'No Payment Record')
ORDER BY order_count DESC;
  
 
-- 1.6  INSTALMENT DEPTH — HOW FAR ARE CUSTOMERS SPREADING PAYMENTS?
-- ----------------------------------------------------------------
 
SELECT
    total_installments,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(item_price), 2) AS revenue,
    ROUND(AVG(item_price), 2) AS avg_item_price
FROM vw_master
WHERE primary_payment_type = 'credit_card'
GROUP BY total_installments
ORDER BY total_installments;

 
 
-- ================================================================
-- SECTION 2 — BQ2: CATEGORY, SELLER & REGIONAL BREAKDOWN
-- "Which categories, sellers, and regions are driving growth vs destroying value?"
-- ================================================================
 
 
-- 2.1  CATEGORY REVENUE RANKING — TOP 20
-- ----------------------------------------------------------------
-- Revenue, volume, and average price per category.
-- pct_of_revenue shows concentration — does the top 5 dominate?
 
SELECT
    category_english,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*)  AS items_sold,
    ROUND(SUM(item_price),  2)  AS total_revenue,
    ROUND(SUM(item_price) / SUM(SUM(item_price)) OVER () * 100, 2) AS pct_of_revenue,
    ROUND(AVG(item_price), 2)  AS avg_item_price,
    ROUND(SUM(item_price) / COUNT(DISTINCT order_id), 2) AS revenue_per_order
FROM vw_master
GROUP BY category_english
ORDER BY total_revenue DESC
LIMIT 20;
 
 
-- 2.2  CATEGORY REVENUE-PER-ORDER VS VOLUME
-- ----------------------------------------------------------------
-- Categories with fewer orders but higher revenue-per-order are
-- high-value niches. Sorting by revenue_per_order instead of total
-- revenue surfaces different strategic opportunities.

 
SELECT
    category_english,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(item_price), 2)  AS total_revenue,
    ROUND(SUM(item_price) / COUNT(DISTINCT order_id), 2) AS revenue_per_order,
    ROUND(AVG(item_price),  2)  AS avg_item_price,
    ROUND(AVG(review_score), 2)  AS avg_review_score
FROM vw_master
GROUP BY category_english
HAVING total_orders >= 50
ORDER BY revenue_per_order DESC
LIMIT 20;
-- High revenue_per_order + high avg_review_score = grow aggressively.
-- High revenue_per_order + low avg_review_score = quality intervention needed.
 
 
-- 2.3  CATEGORY SENTIMENT MATRIX
-- ----------------------------------------------------------------
-- Revenue concentration vs customer satisfaction by category.
-- Reveals which high-revenue categories have a satisfaction problem.
-- Used to identify where revenue leakage risk is highest.
 
SELECT
    category_english,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(item_price), 2) AS total_revenue,
    ROUND(AVG(review_score),2) AS avg_review_score,
    ROUND(SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END)
          / COUNT(*) * 100,  1) AS pct_positive,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1) AS pct_negative,
    CASE
        WHEN AVG(review_score) >= 4.0 AND SUM(item_price) >= 500000 THEN 'High Value / High Sat'
        WHEN AVG(review_score) < 3.5  AND SUM(item_price) >= 500000 THEN 'High Value / Low Sat'
        WHEN AVG(review_score) >= 4.0 AND SUM(item_price) < 500000  THEN 'Growth Candidate'
        ELSE 'Monitor'
    END AS strategic_label
FROM vw_master
WHERE review_score IS NOT NULL
GROUP BY category_english
HAVING total_orders >= 100
ORDER BY total_revenue DESC
LIMIT 25;
 
 
-- 2.4  STATE REVENUE DISTRIBUTION
-- ----------------------------------------------------------------

SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(item_price), 2)  AS total_revenue,
    ROUND(SUM(item_price) / SUM(SUM(item_price)) OVER () * 100, 1) AS pct_of_revenue,
    ROUND(AVG(item_price),  2)  AS avg_item_price,
    ROUND(SUM(item_price) / COUNT(DISTINCT customer_unique_id), 2) AS revenue_per_customer
FROM vw_master
GROUP BY customer_state
ORDER BY total_revenue DESC;
-- Geographic concentration of revenue. SP historically ~40%.
-- Top 3 states typically account for two thirds of GMV —
-- concentration is both an opportunity and a risk.
 
 
-- 2.5  STATE GROWTH TREND — TOP 5 STATES BY MONTH
-- ----------------------------------------------------------------
-- Tracks whether SP dominance is growing or if other states are
-- catching up. Emerging states represent diversification opportunity.
 
WITH top_states AS (
    SELECT customer_state
    FROM vw_master
    GROUP BY customer_state
    ORDER BY SUM(item_price) DESC
    LIMIT 5
)
SELECT
    DATE_FORMAT(m.order_purchase_timestamp, '%Y-%m') AS YearMonth,
    m.customer_state,
    COUNT(DISTINCT m.order_id) AS orders,
    ROUND(SUM(m.item_price), 2) AS revenue
FROM vw_master m
JOIN top_states t ON m.customer_state = t.customer_state
GROUP BY YearMonth, m.customer_state
ORDER BY YearMonth, revenue DESC;
 
 
-- ================================================================
-- SECTION 3 — BQ3: CUSTOMER RETENTION & BEHAVIOUR
-- "Are customers returning after first purchase?"
-- ================================================================
 

-- 3.1  PURCHASE FREQUENCY DISTRIBUTION
-- ----------------------------------------------------------------
-- The single most important retention metric.
-- 97% of customers placed exactly 1 order — confirmed in profiling.
 
WITH customer_frequency AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM vw_master
    GROUP BY customer_unique_id
)
SELECT
    order_count,
    COUNT(customer_unique_id) AS customers,
    ROUND(COUNT(customer_unique_id)
          / SUM(COUNT(customer_unique_id)) OVER () * 100, 2) AS pct_of_customers,
    ROUND(COUNT(customer_unique_id)
          / SUM(COUNT(customer_unique_id)) OVER () * 100, 2)
        * COUNT(customer_unique_id) / 100 AS weighted_count
FROM customer_frequency
GROUP BY order_count
ORDER BY order_count;
 
-- There is obvious retention crisis
 
 
-- 3.2  REPEAT CUSTOMER REVENUE CONTRIBUTION
-- ----------------------------------------------------------------
-- Even though repeat customers are few, they may contribute
-- disproportionately to revenue 
 
WITH clv AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(item_total_revenue)  AS total_revenue
    FROM vw_master
    GROUP BY customer_unique_id
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-time'
         WHEN order_count = 2 THEN 'Two orders'
         ELSE 'Three or more orders'
    END AS customer_segment,
    COUNT(customer_unique_id) AS customers,
    ROUND(SUM(total_revenue), 2)   AS segment_revenue,
    ROUND(AVG(total_revenue), 2)   AS avg_lifetime_value,
    ROUND(SUM(total_revenue) / SUM(SUM(total_revenue)) OVER () * 100, 1) AS pct_of_revenue
FROM clv
GROUP BY customer_segment
ORDER BY customers DESC;
 
 
-- 3.3  TIME BETWEEN FIRST AND SECOND ORDER — SUMMARY
-- ----------------------------------------------------------------
-- For the ~3% who returned: how long did it take? Benchmarks the re-engagement window — informs when a win-back
-- campaign would need to fire to intercept the repeat purchase.

WITH orders_deduped AS (
    SELECT DISTINCT
        customer_unique_id,
        order_id,
        order_purchase_timestamp
    FROM vw_master
),
ranked AS (
    SELECT
        customer_unique_id,
        order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_purchase_timestamp
        ) AS order_rank
    FROM orders_deduped
),
returning_customers AS (
    SELECT
        customer_unique_id,
        DATEDIFF(
            MIN(CASE WHEN order_rank = 2 THEN order_purchase_timestamp END),
            MIN(CASE WHEN order_rank = 1 THEN order_purchase_timestamp END)
        ) AS days_to_return
    FROM ranked
    GROUP BY customer_unique_id
    HAVING MAX(order_rank) >= 2
)
SELECT
    ROUND(AVG(days_to_return),  0)  AS avg_days_to_second_order,
    MIN(days_to_return) AS fastest_return_days,
    MAX(days_to_return) AS slowest_return_days,
    COUNT(*) AS returning_customers
FROM returning_customers;
-- days_to_return = exact gap between order 1 and order 2.
-- avg is short  17 days  win-back campaign must fire quickly.

  
-- 3.4  RE-ENGAGEMENT WINDOW — DISTRIBUTION SUMMARY
-- ----------------------------------------------------------------
 
WITH returners AS (
    SELECT
        customer_unique_id,
        DATEDIFF(
            MAX(order_purchase_timestamp),
            MIN(order_purchase_timestamp)
        ) AS days_gap
    FROM vw_master
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT order_id) >= 2
)
SELECT
    CASE
        WHEN days_gap <=  30 THEN '0–30 days'
        WHEN days_gap <=  60 THEN '31–60 days'
        WHEN days_gap <=  90 THEN '61–90 days'
        WHEN days_gap <= 180 THEN '91–180 days'
        ELSE 'Over 180 days'
    END AS return_window,
    COUNT(*) AS customers,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 1) AS pct_of_returners
FROM returners
GROUP BY return_window
ORDER BY MIN(days_gap);
 
 
-- 3.5  FIRST-ORDER REVIEW SCORE OF RETURNING VS NON-RETURNING CUSTOMERS
-- ----------------------------------------------------------------
-- The key retention question: does review score on the first order predict whether a customer will return?

WITH orders_deduped AS (
    SELECT DISTINCT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        review_score
    FROM vw_master
),
order_ranked AS (
    SELECT
        customer_unique_id,
        review_score,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_purchase_timestamp
        )  AS order_rank,
        COUNT(*) OVER (PARTITION BY customer_unique_id) AS total_orders
    FROM orders_deduped
),
first_order_review AS (
    SELECT
        customer_unique_id,
        review_score   AS first_review_score,
        total_orders
    FROM order_ranked
    WHERE order_rank = 1
)
SELECT
    CASE WHEN total_orders >= 2 THEN 'Returned' ELSE 'Did Not Return' END AS retention_group,
    COUNT(customer_unique_id) AS customers,
    ROUND(AVG(first_review_score), 2)   AS avg_first_order_review,
    ROUND(SUM(CASE WHEN first_review_score >= 4 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1) AS pct_positive_first_review,
    ROUND(SUM(CASE WHEN first_review_score <= 2 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_negative_first_review
FROM first_order_review
WHERE first_review_score IS NOT NULL
GROUP BY retention_group;
 
-- HYPOTHESIS: customers who received a poor first-order experience
-- (score 1–2) are far less likely to return.
-- If confirmed → first-order experience is the primary retention lever.
 
-- HYPOTHESIS REJECTED.
--   The difference between groups is marginal — 0.08 points on avg score,
--   1.8 percentage points on positive reviews, 1.5 points on negative.
--   Customers who scored their first order highly are ALSO not returning.
--   Review score on the first order is not a predictor of retention.
 
-- 3.6  COHORT RETENTION — MONTHLY FIRST-ORDER COHORTS
-- ----------------------------------------------------------------

WITH orders_deduped AS (
    SELECT DISTINCT
        customer_unique_id,
        order_id,
        order_purchase_timestamp
    FROM vw_master
),
ranked AS (
    SELECT
        customer_unique_id,
        order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_purchase_timestamp
        ) AS order_rank
    FROM orders_deduped
),
cohorts AS (
    SELECT
        customer_unique_id,
        MIN(CASE WHEN order_rank = 1 THEN order_purchase_timestamp END) AS first_order,
        MIN(CASE WHEN order_rank = 2 THEN order_purchase_timestamp END) AS second_order
    FROM ranked
    GROUP BY customer_unique_id
),
summary AS (
    SELECT
        DATE_FORMAT(first_order, '%Y-%m') AS cohort_month,
        COUNT(DISTINCT customer_unique_id) AS total_customers,
        SUM(CASE WHEN second_order IS NOT NULL THEN 1 ELSE 0 END) AS returned_customers,
        AVG(CASE WHEN second_order IS NOT NULL
                 THEN DATEDIFF(second_order, first_order) END)  AS days_to_return
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    cohort_month,
    total_customers,
    returned_customers,
    ROUND(returned_customers / total_customers * 100, 1) AS retention_rate_pct,
    ROUND(days_to_return,  0)  AS avg_days_to_return
FROM summary
ORDER BY cohort_month;
 
--  OBSERVATION WINDOW EFFECT — declining 2018 retention is not a real trend. Later cohorts (2018-03 to 2018-08) had only 1–6
--     months remaining in the dataset to place a second order. Their low retention_rate_pct reflects truncation, not worse behaviour.

--   • TRUE RETENTION for cohorts with full window (2017-01 to 2017-06):
--     4.1–7.3%. The overall 3% figure is depressed by truncated 2018
--     cohorts that have not had time to return within the dataset.
--
--   • avg_days_to_return falls for later cohorts (162 days in Jan 2017
--     → 5 days in Aug 2018). This is selection bias, not faster loyalty:
--     only customers who returned very quickly are visible in late cohorts.
--
--   • No single cohort dramatically outperforms — systemic retention
--     failure confirmed across all periods. No seasonal campaign or
--     operational change produced a meaningful retention uplift.
--
--   • 2017-11 Black Friday cohort (7,060 customers): only 3.2% retention
--     — the largest single-month acquisition with one of the lowest
--     retention rates. BF customers acquired at scale did not return.
--
-- DATASET LIMITATION — "AT WHICH POINT DO WE LOSE CUSTOMERS":
--   The second half of BQ3 cannot be answered from this dataset.
--   Answering "at which point in the experience" requires session data,
--   CRM records, cart abandonment logs, or email engagement data —
--   none of which exists in the Olist dataset. The data only records
--   completed orders, not browsing intent or drop-off behaviour.
--   This gap should be noted in the CCO brief and addressed through
--   supplementary data sources if available.
 
 
 
-- ================================================================
-- SECTION 4 — BQ4: DELIVERY PERFORMANCE, REVIEWS & RETENTION
-- "What is the relationship between delivery performance,
--  review scores, and retention?"
-- ================================================================
 
 
-- 4.1  DELIVERY PERFORMANCE HEADLINE
-- ----------------------------------------------------------------
-- On-time rate, late rate, average delay in days.
 
SELECT
    COUNT(DISTINCT order_id) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN delivery_status = 'Late' THEN order_id END) AS late_orders,
    COUNT(DISTINCT CASE WHEN delivery_status = 'On Time' THEN order_id END) AS on_time_orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN delivery_status = 'Late' THEN order_id END)
        / COUNT(DISTINCT order_id) * 100,
    2)   AS late_pct,
    ROUND(AVG(delivery_delay_days),  1)  AS avg_delay_days,
    ROUND(AVG(fulfilment_days), 1)  AS avg_fulfilment_days
FROM vw_master;

-- KEY SIGNALS:
--   • late_pct = 6.77% vs KPI target ≤5% 
--     (1.77pp above target — within the 5pp amber band)
--     On-time rate = 93.2% vs KPI target ≥95% 

--   • avg_delay_days = -12.0 → orders arrive on average 12 days
--     BEFORE the estimated delivery date. The platform is setting
--     extremely conservative delivery estimates (under-promise,
--     over-deliver). This is a significant finding:
--       1. Most customers receive orders far earlier than promised
--          — a positive experience signal.
--       2. The 6.77% late rate sits alongside a -12 day average,
--          meaning late deliveries are concentrated in specific
--          failure cases (certain sellers or remote regions),
--          not a broad systemic slowness. A4.5 will test this.
--       3. The estimated delivery date is not a reliable SLA
--          metric. it is set too conservatively to be meaningful.

 
-- 4.2  LATE DELIVERY IMPACT ON REVIEW SCORES
-- ----------------------------------------------------------------
-- The causal chain suspected from profiling:
-- Late delivery → poor review → no return purchase.
-- This query quantifies the review score impact.
 
SELECT
    delivery_status,
    COUNT(DISTINCT order_id)  AS order_count,
    ROUND(AVG(review_score),  2)  AS avg_review_score,
    ROUND(SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_five_star,
    ROUND(SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_positive,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_negative,
    ROUND(SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_one_star
FROM vw_master
WHERE review_score IS NOT NULL
GROUP BY delivery_status;
--  The gap is hard to ignore — 4.21 vs 2.26 on a 5-point scale. But the
-- number that really stands out is the one-star rate: 54.4% of late orders
-- got a 1-star review. Not mildly unhappy — the worst possible score.
-- Compare that to 8.4% for on-time orders and you can see how quickly
-- a late delivery destroys the customer relationship.

-- KPI check: on-time avg score (4.21) clears the ≥4.0 target, late (2.26)
-- doesn't come close. Low score rate fails for both groups against the ≤5%
-- target — 11.4% even for on-time orders suggests review scores have a
-- baseline dissatisfaction problem beyond just delivery timing.
--
-- One important caveat to bring forward from A3.5: poor reviews don't
-- actually predict whether a customer returns. So the damage here is to
-- platform reputation and seller ratings — real problems — but fixing
-- delivery alone won't solve the retention crisis.
 
 
 
-- 4.3  DELIVERY DELAY BUCKETS — SCORE DEGRADATION BY SEVERITY
-- ----------------------------------------------------------------
-- Does a 1-day late order hurt as much as a 7-day late order?
-- Quantifies how review score degrades as lateness increases.

 
SELECT
    CASE
        WHEN delivery_delay_days <= -7  THEN 'Very Early (7+ days)'
        WHEN delivery_delay_days <   0  THEN 'Early (1–6 days)'
        WHEN delivery_delay_days =   0  THEN 'Exactly On Time'
        WHEN delivery_delay_days <=  3  THEN 'Slightly Late (1–3 days)'
        WHEN delivery_delay_days <=  7  THEN 'Late (4–7 days)'
        WHEN delivery_delay_days <= 14  THEN 'Very Late (8–14 days)'
        ELSE 'Severely Late (15+ days)'
    END  AS delay_bucket,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(AVG(review_score),  2)   AS avg_review_score,
    ROUND(SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)   AS pct_negative_reviews,
    ROUND(AVG(delivery_delay_days), 1)  AS avg_days_in_bucket
FROM vw_master
WHERE review_score IS NOT NULL
  AND delivery_delay_days IS NOT NULL
GROUP BY delay_bucket
ORDER BY avg_days_in_bucket;
 
-- A few things stand out here. First, the sheer volume in "Very Early"
-- (75,380 orders) confirms what 4.1 showed; the platform is routinely
-- delivering 15 days ahead of estimate. The estimated date is barely usable
-- as a customer promise because the actual delivery lands so much earlier.

-- Second, the score degradation is not gradual — it falls off a cliff.
-- Exactly on time scores 3.99. One to three days late drops to 3.24.
-- Four to seven days late crashes to 2.09. By the time you're 8 days
-- late the score hits 1.68 and barely moves further — 15+ days late
-- scores 1.71, almost identical. Customers reach peak dissatisfaction
-- around day 8 and additional lateness doesn't make it meaningfully worse.

-- That inflection point between 0 and 1 days late is where the SLA
-- threshold should sit. Customers have no tolerance for even minor delays.
-- If the CCO wants to set a compensation or escalation trigger, day 1
-- is the right line — not day 4 or day 7.

-- One more thing worth noting: "Exactly On Time" scores lower than
-- "Early" (3.99 vs 4.13–4.23). Meeting the promise exactly is not
-- enough customers expect to be pleasantly surprised. That partly
-- explains why the conserative estimates exist
 
 
-- 4.4  MONETISED LATE DELIVERY EXPOSURE
-- ----------------------------------------------------------------
-- Translates operational failure into revenue terms 
-- How much GMV was associated with late orders?
 
SELECT
    delivery_status,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT customer_unique_id) AS customers_affected,
    ROUND(SUM(item_total_revenue), 2)  AS total_revenue_at_risk,
    ROUND(SUM(item_total_revenue) / SUM(SUM(item_total_revenue)) OVER () * 100, 1) AS pct_of_total_revenue,
    ROUND(AVG(item_total_revenue),  2)  AS avg_order_revenue
FROM vw_master
GROUP BY delivery_status;
-- R$1.15M of GMV touched late orders , 7.5% of total platform GMV for a delivery failure rate of 6.77%. 

-- Two things are worth pointing out. First, 6,534 late orders affected
-- 6,498 unique customers. almost a perfect 1:1 ratio. Barely any customer
-- had more than one late order. Late delivery is spread wide, not
-- concentrated in repeat bad experiences for the same people.

-- Second, late orders had a higher avg order value (R$158.44) than
-- on-time orders (R$138.62). Higher-value items are more likely to be
-- delayed possibly because they come from more distant sellers, involve
-- bulkier products with complex handling, or attract more scrutiny during
-- fulfilment.
 
 
-- 4.5  DELIVERY PERFORMANCE BY STATE
-- ----------------------------------------------------------------
-- Geographic delivery quality. Some states have structurally longer
-- transit times (remote regions of Brazil). Exposes whether the
-- late delivery problem is concentrated in specific markets.
 
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END)
          / COUNT(DISTINCT order_id) * 100, 1)  AS late_pct,
    ROUND(AVG(delivery_delay_days), 1)  AS avg_delay_days,
    ROUND(AVG(fulfilment_days),  1)  AS avg_fulfilment_days,
    ROUND(AVG(review_score), 2)  AS avg_review_score
FROM vw_master
GROUP BY customer_state
HAVING total_orders >= 100
ORDER BY late_pct DESC;
-- Late delivery is a geographic problem rooted in distance from São Paulo's seller hub. 
-- The Northeast states (AL, MA, SE) are worst at 18–22%, with fulfilment times more than double SP's 8.7 days. 
-- RJ is the biggest commercial exposure in absolute terms — 1,644 late orders despite a moderate 13.3% rate. 
-- SP performs well at 5.0% across 42% of all orders, proving the platform works when sellers are close to customers. 
-- The remote northern states (AM, RO) show artificially low late rates because delivery windows are padded so heavily the SLA is meaningless. 
-- Review scores track lateness consistently — chronic Northeast delays keep satisfaction below 4.0. 
-- The fix is either wider promised windows or investment in regional fulfilment closer to the Northeast.
 
-- 4.6  REVIEW SCORE OVER TIME — IS SERVICE QUALITY IMPROVING?
-- ----------------------------------------------------------------
-- Tracks monthly average review score alongside late delivery rate.
-- If late_pct is falling but review score is flat → other quality
-- factors are emerging. If both improve → operational gains are real.
 
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')   AS YearMonth,
    COUNT(DISTINCT order_id)                          AS orders,
    ROUND(AVG(review_score), 2)  AS avg_review_score,
    ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END)
          / COUNT(DISTINCT order_id) * 100, 1)  AS late_pct,
    ROUND(AVG(delivery_delay_days), 1)  AS avg_delay_days
FROM vw_master
WHERE review_score IS NOT NULL
GROUP BY YearMonth
ORDER BY YearMonth;
-- 2016 through mid-2017 is the clean baseline — late rates under 7%, scores above 4.10. 
-- November 2017 broke that: volume nearly doubled (likely Black Friday) and late_pct hit 13.7%, score dropped to 3.90. 
-- The network couldn't absorb the surge. February–March 2018 were worse — 15.7% and 20.2% late, scores at 3.75, the lowest in the dataset. 
-- April 2018 snapped back to normal almost immediately, which suggests an acute event rather than permanent decline. 
-- The rest of 2018 is the best sustained run in the data. The platform can self-correct,
--  but it hasn't proven it can handle the next volume spike without the same collapse.
 
-- ================================================================
-- SECTION 5 — BQ5: SELLER VALUE VS RISK
-- "Which sellers are highest-value vs creating risk?"
-- ================================================================
 
 
-- 5.1  FULL SELLER SCORECARD
-- ----------------------------------------------------------------
-- The most complete seller-level view in the analysis.
-- Combines revenue contribution, delivery reliability, and
-- customer satisfaction into a single ranked table.
-- Top 20 by gross revenue
 
SELECT
    i.seller_id,
    CONCAT('S', RANK() OVER (ORDER BY SUM(i.item_price) DESC), ' — ', s.seller_city) AS seller_label,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT i.order_id) AS orders_fulfilled,
    COUNT(*)  AS items_sold,
    ROUND(SUM(i.item_price), 2)  AS gross_revenue,
    ROUND(SUM(i.item_price) / SUM(SUM(i.item_price)) OVER () * 100, 2) AS pct_of_total_revenue,
    ROUND(AVG(i.item_price), 2)  AS avg_item_price,
    ROUND(AVG(i.review_score), 2)  AS avg_review_score,
    ROUND(SUM(CASE WHEN i.review_score <= 2 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)  AS pct_negative_review,
    ROUND(SUM(CASE WHEN i.delivery_status = 'Late' THEN 1 ELSE 0 END)
          / COUNT(DISTINCT i.order_id) * 100, 1)  AS late_pct,
    ROUND(AVG(i.delivery_delay_days), 1)  AS avg_delay_days,
    ROUND(AVG(i.fulfilment_days),1)  AS avg_fulfilment_days
FROM vw_master i
JOIN sellers s ON i.seller_id = s.seller_id
GROUP BY i.seller_id, s.seller_city, s.seller_state
ORDER BY gross_revenue DESC
LIMIT 20;
-- Revenue and reliability do not move together in the top 20. The highest-GMV sellers are not the safest — several carry late rates
-- and negative review rates that would be unacceptable from a mid-tier seller, and the platform is currently absorbing that risk because
-- the revenue looks too large to challenge.
 
-- The more valuable seller profile is not the highest-volume one. it is the high avg_item_price seller with controlled late and
-- negative review rates. Those sellers generate comparable GMV with far less operational and reputational exposure. The platform should
-- be actively recruiting in that profile rather than defaulting to volume as the measure of seller quality.
 
 
-- 5.2  PARETO ANALYSIS — REVENUE CONCENTRATION BY SELLER
-- ----------------------------------------------------------------
-- Quantifies how few sellers generate the majority of GMV.
-- does a small % of sellers drive 80% of revenue?

WITH seller_totals AS (
    SELECT
        i.seller_id,
        SUM(i.item_price) AS gross_revenue,
        AVG(i.review_score) AS avg_review_score,
        SUM(CASE WHEN i.delivery_status = 'Late' THEN 1 ELSE 0 END)
            / COUNT(DISTINCT i.order_id) * 100 AS late_pct
    FROM vw_master i
    GROUP BY i.seller_id
),
platform_total AS (
    SELECT SUM(gross_revenue) AS total FROM seller_totals
),
ranked AS (
    SELECT
        st.seller_id,
        st.gross_revenue,
        st.avg_review_score,
        st.late_pct,
        SUM(st.gross_revenue) OVER (ORDER BY st.gross_revenue DESC) AS running_revenue,
        SUM(st.gross_revenue) OVER (ORDER BY st.gross_revenue DESC)
            / pt.total * 100 AS cumulative_pct
    FROM seller_totals st
    CROSS JOIN platform_total pt
),
tiers AS (
    SELECT
        seller_id,
        gross_revenue,
        avg_review_score,
        late_pct,
        CASE
            WHEN cumulative_pct <= 50 THEN 'Top Tier (0–50% revenue)'
            WHEN cumulative_pct <= 80 THEN 'Mid Tier (50–80% revenue)'
            ELSE 'Tail Tier (80–100% revenue)'
        END AS seller_tier
    FROM ranked
)
SELECT
    seller_tier,
    COUNT(seller_id) AS seller_count,
    ROUND(COUNT(seller_id) / SUM(COUNT(seller_id)) OVER () * 100, 1) AS pct_of_sellers,
    ROUND(SUM(gross_revenue), 2)   AS tier_revenue,
    ROUND(SUM(gross_revenue) / SUM(SUM(gross_revenue)) OVER () * 100, 1) AS pct_of_revenue,
    ROUND(AVG(avg_review_score), 2)   AS avg_review_score,
    ROUND(AVG(late_pct),1)   AS avg_late_pct
FROM tiers
GROUP BY seller_tier
ORDER BY tier_revenue DESC;
-- 4.2% of sellers generate 50% of GMV and they actually has a worse late rate than the mid tier. 
-- The sellers driving the most revenue are not the most reliable, hat's a dependency risk the CCO needs to see. 

 
-- 5.3  SELLER RISK MATRIX 
-- ----------------------------------------------------------------
-- Classifies every seller into four quadrants:

--   HIGH VALUE / LOW RISK  → protect and grow
--   HIGH VALUE / HIGH RISK → urgent operational intervention
--   LOW VALUE  / LOW RISK  → monitor — growth candidate
--   LOW VALUE  / HIGH RISK → review for continued listing
 
WITH seller_stats AS (
    SELECT
        i.seller_id,
        COUNT(DISTINCT i.order_id) AS orders_fulfilled,
        ROUND(SUM(i.item_price), 2)  AS gross_revenue,
        ROUND(AVG(i.review_score), 2)  AS avg_review_score,
        ROUND(
            SUM(CASE WHEN i.delivery_status = 'Late' THEN 1 ELSE 0 END)
            / COUNT(DISTINCT i.order_id) * 100,
        1)  AS late_pct
    FROM vw_master i
    GROUP BY i.seller_id
),
ranked_revenue AS (
    -- Rank sellers by revenue to identify the median row(s)
    SELECT
        gross_revenue,
        ROW_NUMBER() OVER (ORDER BY gross_revenue) AS rn,
        COUNT(*) OVER () AS total_sellers
    FROM seller_stats
),
median_calc AS (
    -- For odd counts: one middle row. For even counts: average of two middle rows.
    SELECT AVG(gross_revenue) AS rev_median
    FROM ranked_revenue
    WHERE rn IN (
        FLOOR((total_sellers + 1) / 2),
        CEIL((total_sellers  + 1) / 2)
    )
),
classified AS (
    SELECT
        ss.seller_id,
        ss.orders_fulfilled,
        ss.gross_revenue,
        ss.avg_review_score,
        ss.late_pct,
        CASE
            WHEN ss.gross_revenue >= mc.rev_median AND ss.late_pct <= 10 THEN 'High Value / Low Risk '
            WHEN ss.gross_revenue >= mc.rev_median AND ss.late_pct >  10 THEN 'High Value / High Risk'
            WHEN ss.late_pct <= 10  THEN 'Low Value / Low Risk'
            ELSE 'Low Value / High Risk'
        END AS risk_label
    FROM seller_stats ss
    CROSS JOIN median_calc mc
)
SELECT
    risk_label,
    COUNT(seller_id)  AS seller_count,
    ROUND(SUM(gross_revenue), 2)   AS segment_revenue,
    ROUND(AVG(avg_review_score), 2)   AS avg_review_score,
    ROUND(AVG(late_pct), 1) AS avg_late_pct,
    ROUND(AVG(orders_fulfilled), 0) AS avg_orders
FROM classified
GROUP BY risk_label
ORDER BY segment_revenue DESC;
-- 1,093 sellers sit in High Value / Low Risk. these are the platform's core. They generate R$9.36M at 3.2% late rate and 4.23 review score.
-- That segment is working and should be the benchmark every other seller is measured against.
 
-- The problem segment is High Value / High Risk: 392 sellers generating R$3.42M but at 21.2% late rate and 3.80 review score. 
-- These sellers are generating meaningful revenue while actively degrading the customer experience. 
-- The platform is effectively subsidising poor delivery performance because the GMV looks attractive. 
-- At 21.2% late, roughly one in five orders from these sellers arrives late — that is not an edge case, it is a pattern that needs intervention.
 
-- Low Value / High Risk is the clearest call: 228 sellers, R$84k total revenue, 51.0% late rate, 3.38 review score. 
-- They contribute almost nothing commercially while generating the worst customer outcomes on the platform. 
-- These sellers have no revenue argument for remaining active — the only question is the offboarding process.

-- 5.4  HIGH-VALUE HIGH-RISK SELLERS — DETAIL LIST
-- ----------------------------------------------------------------

WITH seller_stats AS (
    SELECT
        i.seller_id,
        s.seller_state,
        COUNT(DISTINCT i.order_id)  AS orders_fulfilled,
        ROUND(SUM(i.item_price), 2)  AS gross_revenue,
        ROUND(AVG(i.review_score), 2) AS avg_review_score,
        ROUND(
            SUM(CASE WHEN i.delivery_status = 'Late' THEN 1 ELSE 0 END)
            / COUNT(DISTINCT i.order_id) * 100,
        1) AS late_pct,
        ROUND(AVG(i.fulfilment_days), 1) AS avg_fulfilment_days
    FROM vw_master i
    JOIN sellers s ON i.seller_id = s.seller_id
    GROUP BY i.seller_id, s.seller_state
),
platform_rev AS (
    SELECT SUM(gross_revenue) AS total FROM seller_stats
),
ranked_revenue AS (
    SELECT
        gross_revenue,
        ROW_NUMBER() OVER (ORDER BY gross_revenue) AS rn,
        COUNT(*) OVER () AS total_sellers
    FROM seller_stats
),
median_calc AS (
    SELECT AVG(gross_revenue) AS rev_median
    FROM ranked_revenue
    WHERE rn IN (
        FLOOR((total_sellers + 1) / 2),
        CEIL((total_sellers  + 1) / 2)
    )
)
SELECT
    ss.seller_id,
    ss.seller_state,
    ss.orders_fulfilled,
    ss.gross_revenue,
    ss.avg_review_score,
    ss.late_pct,
    ss.avg_fulfilment_days,
    ROUND(ss.gross_revenue / pr.total * 100, 2) AS pct_of_platform_revenue
FROM seller_stats ss
CROSS JOIN platform_rev pr
CROSS JOIN median_calc mc
WHERE ss.gross_revenue >= mc.rev_median
  AND ss.late_pct > 10
ORDER BY ss.gross_revenue DESC;
-- the top seller on the entire High Value / High Risk list is also one of the worst-reviewed on the platform. 
-- That's not a small operational tweak, that's a commercial relationship that needs a formal improvement conversation.
 
 
-- ================================================================
-- SECTION 6 — EXECUTIVE SUMMARY CHECK
-- ================================================================
 
WITH repeat_base AS (
    -- Step 1: isolate customers who placed more than one order
    SELECT customer_unique_id
    FROM vw_master
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT order_id) > 1
),
repeat_customers AS (
    -- Step 2: count them — result referenced in the BQ3 UNION ALL arm
    SELECT COUNT(DISTINCT customer_unique_id) AS repeat_count
    FROM repeat_base
)
SELECT 'BQ1 Revenue' AS pillar, ROUND(SUM(item_total_revenue), 0) AS metric, 
		'Total GMV (delivered)' AS label FROM vw_master
UNION ALL
SELECT 'BQ1 Leakage', COUNT(DISTINCT o.order_id), 'Canceled/Unavailable orders'
    FROM orders o WHERE o.order_status IN ('canceled','unavailable')
UNION ALL
SELECT 'BQ2 States', COUNT(DISTINCT customer_state),  'States with revenue'  FROM vw_master
UNION ALL
SELECT 'BQ2 Categories', COUNT(DISTINCT category_english), 'Categories sold'FROM vw_master
UNION ALL
SELECT 'BQ3 Customers',  COUNT(DISTINCT customer_unique_id), 'Unique customers' FROM vw_master
UNION ALL
SELECT 'BQ3 Retention',  ROUND((SELECT repeat_count FROM repeat_customers)
                               / COUNT(DISTINCT customer_unique_id) * 100, 1), 'Pct returning customers' FROM vw_master
UNION ALL
SELECT 'BQ4 Late', ROUND(SUM(CASE WHEN delivery_status = 'Late' THEN 1 ELSE 0 END)
                               / COUNT(DISTINCT order_id) * 100, 1), 'Late delivery pct'  FROM vw_master
UNION ALL
SELECT 'BQ4 Score', ROUND(AVG(review_score), 2), 'Avg review score (all)'  FROM vw_master
UNION ALL
SELECT 'BQ5 Sellers', COUNT(DISTINCT seller_id), 'Active sellers' FROM vw_master;
 
 
