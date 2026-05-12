# Project Brief
## Commercial Performance and GMV Leakage Analysis | Nexora Commerce Ltd

**Document Type:** Project Brief (Updated) | **Status:** Final | **Date:** May 2026 | **Analyst:** Mercy Verkijika

---

## Important Notice

The dataset used in this project is the publicly available Olist Brazilian E-Commerce dataset sourced from Kaggle, provided as nine separate CSV files covering orders, customers, sellers, products, payments, reviews, order items, geolocation, and product category translation.

Nexora Commerce Ltd, the stakeholder roles, and the business scenario are fictionalised to simulate a real-world commercial analytics engagement.

All analysis, KPI definitions, dashboard outputs, and recommendations were independently developed for this project. Revenue-related metrics are reported as Gross Merchandise Value (GMV), not net platform revenue, because seller commission rates, fee structures, and seller payout data are not available in the source dataset.

---

## 1. Company Overview

Nexora Commerce Ltd is a Brazilian e-commerce marketplace operating between October 2016 and August 2018. The platform connects independent sellers to end consumers across Brazil, acting as an intermediary that facilitates product listing, payment processing, order fulfilment coordination, and customer service. Nexora generates revenue through seller commission fees and marketplace service charges applied to each completed transaction.

**Verified Operational Facts (Post-Analysis)**

| Attribute | Detail |
|-----------|--------|
| Source dataset files | 9 CSV files |
| Total delivered orders | 96,478 unique delivered orders |
| Registered customers | 96,096 unique customers (customer_unique_id) |
| Customers with at least one delivered order | 93,358 |
| Registered sellers | 3,095 sellers in the seller dimension table |
| Active sellers | 3,025 distinct seller_ids with at least one delivered order |
| Unique products | 31,625 unique products |
| Operating period | October 2016 to August 2018 |
| Primary market | Brazil, 27 states |
| Top market | Sao Paulo state (42% of all orders) |
| Total GMV (delivered) | R$15.42M (item_price + freight_value, delivered orders only) |
| Seller Product GMV | R$13.22M (item_price only, delivered orders) |
| Avg Order Value | R$159.83 |
| Freight Cost Ratio | 14.3% of total GMV |

> **Note on seller count:** The dim_seller table contains 3,095 rows. The fact_order_items table contains 3,025 distinct seller IDs. The 70-seller gap represents sellers registered on the platform with no delivered orders in the analysis period. Total Sellers is reported as 3,095 (the full registered seller base).

**Commercial Measurement Approach**

| Metric Area | Treatment in This Analysis |
|-------------|---------------------------|
| GMV | Calculated as item_price plus freight_value for delivered orders |
| Product revenue | Calculated as item_price only, excluding freight |
| Freight value | Treated as a customer-paid pass-through cost, not net platform revenue |
| GMV leakage | Product value from cancelled or unavailable orders that failed to convert into delivered transactions |
| Net revenue | Not calculated. Commission rates and seller payout data are unavailable in the source dataset |

**Revenue Model**

| Stream | Description |
|--------|-------------|
| Seller commission | Percentage fee charged on every completed sale |
| Freight margin | Difference between freight charged to buyer and carrier cost to platform |
| Payment processing | Fees generated through credit card and instalment transactions |

---

## 2. Business Context

Nexora Commerce operates in Brazil's rapidly growing e-commerce sector, competing against established players including Mercado Livre and Amazon Brazil. The platform achieved significant order volume growth between 2016 and 2018, with GMV growing approximately fourfold over the analysis period. However, two converging threats limited sustainable commercial growth and prompted this analysis.

**Threat 1: Near-Zero Customer Retention**

Post-analysis, the data confirmed that 97.1% of customers placed a single order and never returned. In an e-commerce marketplace, customer acquisition cost is only recovered through repeat purchases. At a 2.9% retention rate against a 15% target, the platform is acquiring customers at a rate it cannot retain. Every marketing investment yields a single transaction on a 97% probability basis.

**Threat 2: Unclear GMV Leakage and Commercial Inefficiency**

The business lacked clear visibility into where GMV was being lost, weakened, or placed at risk. Cancelled orders (R$97.24K in GMV leakage), a freight cost ratio approaching its 15% structural ceiling (current: 14.3%), a late delivery rate above the 5% target (current: 6.8%), and underperforming sellers all contribute to commercial underperformance. Post-analysis, the total GMV shortfall against the R$18.0M target was confirmed at R$2.58M.

The Chief Commercial Officer commissioned this analysis to quantify both threats with precision, identify their root causes, and provide a clear commercial roadmap for recovery.

---

## 3. Stakeholder Need

The Chief Commercial Officer needs a business intelligence view that answers five questions:

- Where is Nexora generating commercial value, and how far is it from its GMV target?
- Where is GMV being lost or weakened, and which leakage sources are most recoverable?
- Why are customers not returning after their first purchase, and what is the cost of that failure?
- How does delivery performance affect customer satisfaction and repeat purchase behaviour?
- Which sellers should be protected, developed, monitored, or reviewed?

The final deliverable must support commercial decision-making across customer retention, seller performance, delivery operations, and category-level GMV recovery.

---

## 4. Problem Statement

Nexora Commerce lacked data-driven visibility into four critical commercial areas.

**4.1 GMV Performance and Leakage**

The business needed to understand the gap between GMV generated and the commercial target, and where transaction value was failing to convert into delivered orders.

Key questions:
- How much GMV is Nexora generating, and how far is it from its R$18.0M target?
- Which categories, sellers, or order types are linked to GMV leakage?
- Is leakage concentrated enough to be recoverable through targeted intervention?

**4.2 Customer Retention and Lifetime Value**

The business needed to understand whether customers were returning after their first purchase and what value was being lost when they did not.

Key questions:
- What percentage of customers return after their first purchase?
- How large is the one-time customer problem in GMV terms?
- When do repeat customers typically return, and how much more do they spend?

**4.3 Delivery Experience and Customer Satisfaction**

The business needed to understand whether fulfilment performance was affecting customer reviews and repeat purchase behaviour.

Key questions:
- Is delivery performance meeting the expected standard?
- Are late deliveries associated with weaker review scores?
- Are customers less likely to return after a late first delivery?
- Which states or operational segments show the highest delivery risk?

**4.4 Seller Portfolio and Commercial Risk**

The business needed to identify which sellers drive value and which create commercial risk through poor service performance.

Key questions:
- Which sellers contribute the most GMV, and how concentrated is seller revenue?
- Which sellers are associated with late delivery or weak review performance?
- Which sellers require protection, development, intervention, or review?

Without answers to these questions, the CCO could not make informed decisions about where to invest commercial effort, which seller relationships to protect, or how to arrest the customer retention crisis.

---

## 5. Business Questions

**BQ1:** How much GMV is Nexora generating versus its commercial target, and where specifically is the gap coming from?

**BQ2:** Which product categories, sellers, and regions are driving commercial value, and which are actively creating GMV leakage, freight pressure, or customer experience risk?

**BQ3:** Are customers returning after their first purchase, and if not, at which point in the experience are we losing them?

**BQ4:** What is the relationship between delivery performance, customer review scores, and repeat purchase behaviour, and which operational failures are costing the most revenue?

**BQ5:** Which sellers are Nexora's highest-value commercial partners and which are creating risk through poor delivery, high cancellations, or low ratings?

---

## 6. Objectives

This analysis was commissioned to deliver five specific outcomes.

**Objective 1: Quantify GMV Performance and Leakage**

Calculate total GMV, compare performance against the commercial target, and identify where GMV leakage is occurring by source, category, and seller relationship.

**Objective 2: Diagnose the Retention Problem**

Measure customer retention, first-to-second purchase conversion, one-time customer share, repeat customer GMV contribution, and the typical return window for customers who do come back.

**Objective 3: Connect Delivery Performance to Customer Experience**

Measure late delivery rate, fulfilment duration, review score performance, and the association between first-order delivery experience and repeat purchase behaviour.

**Objective 4: Build a Seller Risk Framework**

Tier the seller base by commercial value and service quality so Nexora can identify sellers to protect, develop, intervene with, or review.

**Objective 5: Produce a Stakeholder-Ready BI Deliverable**

Deliver a Power BI dashboard, written analysis report, project brief, SQL scripts, data quality log, and supporting documentation that allow the CCO to make evidence-based commercial decisions.

---

## 7. Scope of Analysis

The analysis is organised around four analytical pillars, supported by an executive summary view.

**Executive Summary View**

A leadership-facing summary page will synthesise the overall commercial position, headline KPIs, major risks, and recommended priorities across all four pillars in a single view.

---

### Pillar 1: Revenue Performance and GMV Leakage

| Analytical Area | Measures |
|----------------|---------|
| GMV performance | Total GMV, GMV target gap, AOV |
| Revenue composition | Product revenue, freight value, freight cost ratio |
| Leakage quantification | GMV Leakage Rate, Leakage by Status (Cancelled vs Unavailable), Leakage by Category |
| Category risk | GMV leakage by product category, freight pressure by category |
| Commercial efficiency | Average freight per order, AOV, freight burden |

### Pillar 2: Customer Retention and Behaviour

| Analytical Area | Measures |
|----------------|---------|
| Retention | Customer Retention Rate, One-Time Customer Share, Returning Customers |
| Customer value | Repeat Customer CLV, Repeat Customer GMV, Platform AOV |
| Purchase behaviour | Order frequency distribution, Days to Return distribution, Median Days to Return |
| Retention drivers | Repeat rate by first-order delivery status, Repeat rate by review score |

### Pillar 3: Delivery Experience and Customer Satisfaction

| Analytical Area | Measures |
|----------------|---------|
| Delivery performance | On-time delivery rate, late delivery rate |
| Fulfilment speed | Average fulfilment days, average delay for late orders |
| Customer satisfaction | Average review score, low review rate |
| Delivery impact | Review score by delivery status, retention by delivery status |
| Geographic risk | Late delivery rate by customer state |

### Pillar 4: Seller Portfolio and Commercial Risk

| Analytical Area | Measures |
|----------------|---------|
| Seller value | Seller GMV, GMV per seller, top-tier seller GMV share |
| Seller risk | Seller late rate, seller review score, high-risk seller count |
| Seller concentration | Seller tier GMV share, seller count by tier |
| Seller segmentation | Top, Mid, and Tail seller groups |
| Action list | High-risk seller table for commercial review |

---

## 8. KPI Framework and Targets

All revenue KPIs are calculated in Brazilian Reais (R$). All rate KPIs are calculated as a percentage of delivered orders unless specified otherwise. The targets below reflect those implemented in the Power BI dashboard and validated against the live dataset.

Targets used in this analysis are analytical benchmarks designed for stakeholder simulation. In a real business environment, these targets would be validated with commercial, finance, operations, and customer experience leadership before being used for performance management.

**Core Platform KPIs**

| KPI | Formula | Target | Actual |
|-----|---------|--------|--------|
| Total GMV | SUM(total_item_revenue) for delivered orders. total_item_revenue = item_price + freight_value | R$18.0M | R$15.42M |
| Seller GMV | SUM(item_price) for delivered orders. Product revenue only, excludes freight | Monitored | R$13.22M |
| Avg Order Value | Total GMV divided by Total Delivered Orders | R$160 benchmark | R$159.83 |
| Customer Retention Rate | Customers with 2 or more distinct orders divided by Customers with at least 1 delivered order | 15% | 2.9% |
| One-Time Customer Share | Customers with exactly 1 order divided by Total Customers | Ceiling 85% | 97.1% |
| Late Delivery Rate | Orders delivered after estimated date divided by Total Delivered Orders | Ceiling 5.0% | 6.8% |
| Avg Delay Days (Late Only) | Average delivery_delay_days where is_late = 1 | Ceiling 5 days | 10.5 days |
| Avg Fulfilment Days | Average fulfilment_days where is_delivered = 1 | Ceiling 10 days | 12.4 days |
| Avg Review Score | AVERAGE(review_score) for delivered orders | 4.5 / 5.0 | 4.08 |
| Low Review Rate | Orders with review_score 1 or 2 divided by Total Delivered Orders | Ceiling 8% | 12.6% |
| GMV Leakage Rate | Leakage Revenue divided by (Total GMV + Leakage Revenue) | Ceiling 2.0% | 0.6% |
| Freight Cost Ratio | SUM(freight_value) divided by SUM(total_item_revenue) for delivered orders | Ceiling 15% | 14.3% |
| Avg Freight Per Order | Total Freight divided by Total Delivered Orders | Ceiling R$20 | R$22.79 |
| High-Risk Seller Share | Sellers with late rate above 10% divided by Total Sellers | Ceiling 10% | 18.6% |
| Repeat Customer CLV | Total GMV from repeat customers divided by Number of Repeat Customers | Benchmark: 2x AOV (R$320) | R$260.05 |

**Seller Tier Classification**

Seller tiers are assigned using a percentile-based classification on delivered item GMV (item_price), implemented as a calculated column on dim_seller in Power BI.

| Tier | Definition | Seller Count | GMV |
|------|-----------|--------------|-----|
| Top | Top 5% of sellers by delivered item GMV | 154 (4.98%) | R$7.1M (~54%) |
| Mid | 5th to 30th percentile by delivered item GMV | 774 (25%) | R$4.9M (~37%) |
| Tail | All remaining sellers | 2,167 (70%) | R$1.2M (~9%) |

**RAG Thresholds**

| Status | Description |
|--------|-------------|
| Green | At or within target |
| Amber | Within 15% of target (or within 1.5 percentage points for rate metrics) |
| Red | More than 15% below target (or more than 1.5 percentage points off for rate metrics) |
| Signal | Below threshold but still requires monitoring |
| Reference | Informational metric with no formal RAG status |

For lower-is-better metrics (Late Delivery Rate, Freight Cost Ratio, High-Risk Seller Share, Low Review Rate, GMV Leakage Rate) the RAG logic is inverted: green means at or below the ceiling, red means materially above it. GMV Leakage Rate is treated as a monitored signal even when below the 2% ceiling, because any leakage event represents a failed commercial conversion.

---

## 9. Dataset

The analysis is built on nine source CSV files from the Olist Brazilian E-Commerce Public Dataset on Kaggle. Each file was loaded individually into MySQL, profiled for data quality issues, joined, cleaned, and modelled into a star schema of six views.

**Source Files**

| CSV File | Row Count | Purpose |
|----------|----------:|---------|
| olist_orders_dataset.csv | 99,441 | Order header records: order ID, customer ID, status, and all lifecycle timestamps |
| olist_order_items_dataset.csv | 112,650 | Line-item records: order ID, product ID, seller ID, item price, and freight value |
| olist_order_payments_dataset.csv | 103,886 | Payment records: order ID, payment type, instalment count, and payment value |
| olist_order_reviews_dataset.csv | 104,719 | Customer review records: order ID, review score (1-5), and comment text |
| olist_customers_dataset.csv | 99,441 | Customer records: customer ID (per-order), customer_unique_id (cross-order), city, state, zip code |
| olist_sellers_dataset.csv | 3,095 | Seller records: seller ID, city, state, and zip code |
| olist_products_dataset.csv | 32,951 | Product records: product ID, category name in Portuguese, and dimensions |
| olist_geolocation_dataset.csv | 1,000,163 | Geolocation reference: zip code prefix, latitude, longitude, city, and state |
| product_category_name_translation.csv | 71 | Category name translation: Portuguese category name to English equivalent |

**Validated Analytical Dataset**

After profiling, cleaning, joining, and modelling, the analysis uses the following validated figures.

| Attribute | Detail |
|-----------|--------|
| Date range | October 2016 to August 2018 |
| Delivered orders | 96,478 distinct order_ids where is_delivered = 1 |
| Unique customers (all statuses) | 96,096 distinct customer_unique_ids in dim_customer |
| Unique customers (delivered orders) | 93,358 distinct customer_unique_ids with at least one delivered order |
| Registered sellers (dim_seller) | 3,095 rows in the seller dimension table |
| Active sellers (fact) | 3,025 distinct seller_ids with at least one delivered order in fact_order_items |
| Unique products | 31,625 |
| Data grain | Item level: one row per item within an order. Multi-item orders appear as multiple rows |

> **Note:** The original project brief reported 95,128 unique orders, 92,081 unique customers, and 2,914 active sellers. These figures were based on early profiling before data quality cleaning and star schema modelling were completed. The figures above reflect the validated counts from the final Power BI model.

**Data Grain and Joining Logic**

The source dataset is not a single flat file. It contains multiple entity-level and transaction-level files that must be joined carefully.

The core analytical grain is order item level, using olist_order_items_dataset.csv as the main transaction fact source. One order can appear more than once if it contains multiple products from multiple sellers. Order-level metrics such as delivered orders, late orders, and customer retention are therefore calculated using distinct order and customer counts to avoid inflation.

**Primary Join Keys**

| Relationship | Join Key |
|-------------|----------|
| Orders to Customers | customer_id |
| Orders to Order Items | order_id |
| Orders to Payments | order_id |
| Orders to Reviews | order_id |
| Order Items to Products | product_id |
| Order Items to Sellers | seller_id |
| Products to Category Translation | product_category_name |
| Customers to Geolocation | customer_zip_code_prefix |
| Sellers to Geolocation | seller_zip_code_prefix |

The geolocation file contains multiple records per zip code prefix and must be aggregated to one row per prefix (using mean latitude and longitude) before being used as a stable lookup table.

---

## 10. Methodology

This project follows the CRISP-DM framework across seven phases:

| Phase | Activities Completed |
|-------|---------------------|
| Business Understanding | Business questions, KPIs, scope, and analytical pillars defined in this project brief |
| Data Understanding | 8-phase SQL profiling process across all source tables. Data quality issues identified, classified by severity, and logged in the Excel DQ Issue Log |
| Data Integration | Nine CSV files loaded individually into MySQL and joined using validated business keys. Derived flags created: is_delivered, is_leakage, is_late, is_negative_review, fulfilment_days, delivery_delay_days |
| Data Preparation | Star schema built in Power Query with fact_order_items, fact_leakage, dim_seller, dim_customer, dim_date, and dim_product |
| Analysis | 16 sections of DAX measures written and validated in Power BI. All measures cross-checked against MySQL ground truth queries |
| Evaluation | All KPI outputs validated against SQL results. Measure inconsistencies identified and corrected (SUMMARIZE anti-pattern fixes, filter context conflicts resolved) |
| Reporting | Five-page interactive Power BI dashboard, Analytical Insights Report, updated Project Brief, GitHub README |

**Validation Controls**

Specific steps taken to ensure analytical accuracy:

- Reconciling source row counts across all nine CSV files before joining
- Validating join paths between orders, customers, order items, sellers, products, reviews, payments, and category translations
- Aggregating the geolocation file to one row per zip code prefix before using it as a location lookup
- Reconciling delivered order counts between SQL queries and Power BI outputs
- Using DISTINCTCOUNT(order_id) for all order-level measures because the fact table is at item grain
- Rebuilding the customer dimension to enforce one row per customer_unique_id (resolving 122 duplicate records)
- Separating registered customers (96,096) from customers with at least one delivered order (93,358)
- Calculating review-based KPIs only against orders with a review score, not total delivered orders
- Treating freight as a pass-through cost rather than net platform revenue throughout
- Separating delivered order GMV from cancelled and unavailable leakage events

---

## 11. Tools

| Tool | Purpose |
|------|---------|
| MySQL | Individual CSV loading, data profiling, joining, cleaning, and star schema view creation. Ground truth for all KPI values before Power BI measures were written |
| Microsoft Excel | Data Quality Issue Log: all identified issues with severity classification, column affected, and resolution applied |
| Microsoft Power BI | Star schema data modelling in Power Query, DAX measure development (16 sections, 60+ measures), and interactive dashboard delivery across five report pages |
| Power Query | ETL layer within Power BI for joining and transforming the MySQL-cleaned data into the star schema |
| GitHub | Version control and portfolio hosting for all project artefacts |

---

## 12. Deliverables

| Deliverable | Description | Status |
|------------|-------------|--------|
| nexora_01_create_and_load.sql | Database creation and data load script | Complete |
| nexora_02_profiling.sql | 8-phase data profiling script covering all source tables | Complete |
| nexora_03_analysis.sql | BQ1 to BQ5 analytical queries with validated KPI results | Complete |
| nexora_04_dimensions.sql | Star schema dimension and view definitions including fact_leakage | Complete |
| nexora_DQ_issues_log.xlsx | Data quality issue log with severity and resolution | Complete |
| nexora_05_powerbi_design_spec.md | Full 5-page dashboard design specification | Complete |
| nexora_06_dax_measures.md | 16-section DAX measures reference document | Complete |
| Power BI Dashboard (.pbix) | 5-page interactive dashboard: Executive Summary, Revenue Performance, Customer Retention, Delivery Experience, Seller Portfolio | Complete |
| nexora_07_insights_report.md | Analytical Insights Report with findings, evidence, business impact, and recommendations | Complete |
| Project_Brief_Nexora.md | This document: updated project brief reflecting final validated data | Complete |

**Dashboard Pages**

| Page | Title | Business Questions Addressed |
|------|-------|------------------------------|
| 1 | Executive Summary: Commercial Health and Revenue Risk | BQ1, BQ3, BQ4 overview |
| 2 | Revenue Performance and GMV Leakage Drivers | BQ1, BQ2 |
| 3 | Customer Retention and Lifetime Value | BQ3 |
| 4 | Delivery Experience and Customer Satisfaction | BQ4 |
| 5 | Seller Portfolio and Commercial Risk | BQ5 |

---

## 13. Key Definitions

| Term | Definition |
|------|-----------|
| Delivered Order | is_delivered = 1 in the fact table. The only status used for revenue and KPI calculations |
| Total GMV | SUM(total_item_revenue) for delivered orders, where total_item_revenue = item_price + freight_value. Represents the full transaction value processed through the platform. Not equivalent to Nexora net revenue as commission rates are not available |
| Seller GMV | SUM(item_price) for delivered orders. Product revenue only, excluding freight. Seller GMV Share = Seller GMV divided by Total GMV (approximately 85.7%, with freight accounting for the remaining 14.3%) |
| GMV Leakage | Revenue from orders where is_leakage = 1 in fact_order_items. Split into cancelled (97.9% of leakage, R$95.24K) and unavailable (2.1%, R$2.01K). Leakage Rate = Leakage Revenue divided by (Total GMV + Leakage Revenue). Freight excluded from leakage as it is a pass-through cost |
| Freight Cost Ratio | SUM(freight_value) divided by SUM(total_item_revenue) for delivered orders. Measures what proportion of total platform GMV is consumed by delivery cost. Current: 14.3%. Ceiling: 15% |
| Repeat Customer | A customer (customer_unique_id) with 2 or more distinct delivered order_ids |
| One-Time Customer | A customer with exactly 1 delivered order_id. Primary retention risk |
| Customer Retention Rate | Repeat Customers divided by Customers with at least one delivered order. Current: 2.9%. Target: 15% |
| On-Time Delivery | order_delivered_customer_date is on or before order_estimated_delivery_date (is_late = 0) |
| Late Delivery | order_delivered_customer_date is after order_estimated_delivery_date (is_late = 1) |
| Avg Fulfilment Days | Average days from order_purchase_date to order_delivered_customer_date for delivered orders |
| Avg Delay Days | Average delivery_delay_days for late orders only (is_late = 1). Measures how late the late orders are, not the average delay across all orders |
| Low Review Score | A review_score of 1 or 2 out of 5. Used as a customer dissatisfaction indicator (is_negative_review = 1) |
| High-Risk Seller | A seller with a delivered order late rate above 10% |
| Seller Tier | Percentile-based classification on delivered item GMV: Top = top 5% by GMV (154 sellers), Mid = 5th to 30th percentile (774 sellers), Tail = remainder (2,167 sellers). Implemented as a calculated column on dim_seller using RANKX |
| Seller Quadrant | Four-quadrant risk matrix: High Value (above-median GMV) vs High Risk (late rate above 10%). Implemented as a calculated column on dim_seller |

---

## 14. Assumptions and Constraints

| No. | Assumption or Constraint | Impact |
|-----|-------------------------|--------|
| 1 | The Olist public dataset does not include seller commission rates, fee structures, or net payout data. All revenue figures are GMV. Nexora net revenue would require applying an internal commission rate to the GMV figures. | Critical: all revenue and leakage figures are GMV-based. The CCO must apply commission rate data to convert to net revenue impact |
| 2 | Freight value is treated as a customer-paid pass-through cost and is not counted as Nexora's net revenue. It is analysed as a commercial burden and cost to the customer, not as platform profit. | Critical: freight is excluded from leakage calculations and is not included in net revenue estimates throughout |
| 3 | GMV leakage is calculated using product value (item_price) from cancelled and unavailable orders. Freight is excluded from the leakage figure. | Moderate: this correctly isolates the product revenue component that was committed and not recovered |
| 4 | The source data is at item grain. One order can appear more than once in the fact table if it contains multiple items. All order-level KPIs use DISTINCTCOUNT(order_id) to avoid inflation. | High: incorrect aggregation at item grain is the single most common DAX error in this model. All measures validated against SQL ground truth |
| 5 | Customer retention is measured using customer_unique_id against customers with at least one delivered order (93,358), not all registered customers (96,096). | Moderate: this focuses retention on customers who had a completed transaction experience. The directional conclusion of near-zero retention is robust either way |
| 6 | The relationship between late delivery, review score, and repeat purchase is observational. No controlled experiment was conducted. Other factors may explain part of the observed association. | Moderate: all delivery and retention insights use association language, not causal language |
| 7 | The dataset covers October 2016 to August 2018. Early months have significantly lower order volumes as the platform was in early growth phase. | Low: trend analysis clearly shows growth trajectory. Early period is clearly distinguishable in time-series visuals |
| 8 | Seller tier thresholds (top 5%, 5th to 30th percentile) are analytical decisions. They can be adjusted by changing the RANKX thresholds in the dim_seller calculated column. | Low: thresholds are documented, transparent, and adjustable |
| 9 | The geolocation file contains multiple rows per zip code prefix. Direct joins without aggregation would duplicate customer or seller records and distort geographic analysis. | Moderate: aggregation applied before any geographic join. Geographic analysis validated against expected state-level counts |
| 10 | Review scores are not available for all delivered orders. Review-based KPIs are calculated only against orders with a review score. | Moderate: review-based KPIs use reviewed orders as denominator. Clearly labelled in all dashboard visuals |

---

## 15. Success Criteria

This project will be considered successful if it delivers:

1. A validated Power BI dashboard that allows the CCO to monitor GMV, leakage, retention, delivery experience, and seller risk across five report pages.
2. A clear quantified view of Nexora's commercial health and priority risks, traceable to the business questions in this brief.
3. Evidence-based recommendations for retention recovery, delivery improvement, category review, and seller management.
4. Documented KPI definitions, assumptions, and limitations that allow findings to be interrogated and challenged.
5. Reproducible SQL scripts showing how the nine source files were profiled, cleaned, joined, and prepared for analysis.
6. A stakeholder-ready BI Analysis Report supported by transparent methodology and dashboard evidence.

---

## 16. Project Close Statement

This project brief is the analytical contract for the Commercial Performance and GMV Leakage Analysis engagement. All dashboard pages, KPI definitions, written findings, and recommendations are traceable to the business questions, scope, assumptions, and success criteria defined in this document. All figures reflect the final validated Power BI model. Company name and business context are fictionalised. Data sourced from the publicly available Olist Brazilian E-Commerce dataset on Kaggle.