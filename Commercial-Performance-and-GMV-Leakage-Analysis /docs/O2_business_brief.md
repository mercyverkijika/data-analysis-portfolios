
# Project Brief  
## Commercial Performance & GMV Leakage Analysis — Nexora Commerce Ltd

**Document Type:** Project Brief  
**Status:** Final   
**Primary Stakeholder:** Chief Commercial Officer  
**Prepared by:** Mercy Verkijika  

---

## Important Notice

This analysis uses the publicly available **Olist Brazilian E-Commerce Public Dataset** from Kaggle. The dataset is provided as **nine separate CSV files** covering orders, customers, sellers, products, payments, reviews, order items, geolocation, and product category translation.

Nexora Commerce Ltd, the stakeholder roles, and the business scenario are fictionalised to simulate a real-world commercial analytics engagement.

All analysis, KPI definitions, dashboard outputs, and recommendations were independently developed for this project. Revenue-related metrics are reported as **Gross Merchandise Value (GMV)**, not net platform revenue, because seller commission rates, fee structures, and seller payout data are not available in the source dataset.

---

## 1. Company Overview

Nexora Commerce Ltd is a fictional Brazilian e-commerce marketplace operating across Brazil between **October 2016 and August 2018**. The platform connects independent sellers to end consumers and acts as an intermediary for product listing, order processing, payment facilitation, fulfilment coordination, and customer experience management.

Nexora’s commercial model is based on marketplace transaction activity. In a real business environment, the platform would generate net revenue through seller commission fees, marketplace service charges, and payment-related fees. However, because the source dataset does not include commission rates or seller payout information, this analysis measures commercial performance using **GMV**, representing the total transaction value processed through the platform.

### Key Operational Facts

| Attribute | Detail |
|---|---:|
| Source dataset files | 9 CSV files |
| Delivered orders | 96,478 |
| Registered customers | 96,096 |
| Customers with at least one delivered order | 93,358 |
| Registered sellers | 3,095 |
| Active sellers | 3,025 |
| Product catalogue | 31,625 unique products |
| Operating period | October 2016 – August 2018 |
| Primary market | Brazil — 27 states |
| Top market | São Paulo state, approximately 42% of orders |

### Commercial Measurement Approach

| Metric Area | Treatment in This Analysis |
|---|---|
| GMV | Calculated as item price plus freight value for delivered orders |
| Product revenue | Calculated as item price only, excluding freight |
| Freight value | Treated as a customer-paid pass-through value, not net platform revenue |
| GMV leakage | Product value from cancelled or unavailable orders that failed to convert into delivered transactions |
| Net revenue | Not calculated because commission rates and seller payout data are unavailable |

---

## 2. Business Context

Nexora Commerce operates in Brazil’s competitive e-commerce marketplace sector, where sustained growth depends on more than order volume. For a marketplace to scale profitably, it must convert first-time buyers into repeat customers, maintain reliable fulfilment standards, protect high-value seller relationships, and identify categories where transaction value is being lost or weakened.

Leadership has identified two commercial concerns that may be limiting sustainable growth.

### Threat 1 — Weak Customer Retention

Preliminary analysis suggests that the majority of customers place one order and never return. In marketplace economics, customer acquisition cost is only recovered properly when customers make repeat purchases. A platform that cannot convert first-time buyers into returning customers is effectively operating as a one-time transaction engine rather than a compounding commercial model.

### Threat 2 — Unclear GMV Leakage and Commercial Inefficiency

The business does not have sufficient visibility into where GMV is being lost, weakened, or placed at risk. Cancelled orders, unavailable products, freight-heavy categories, late delivery, poor review scores, and underperforming sellers all create forms of commercial leakage or risk.

The Chief Commercial Officer has requested an analysis that quantifies these risks, identifies the root causes, and provides a clear commercial roadmap for improving retention, fulfilment performance, seller management, and GMV recovery.

---

## 3. Stakeholder Need

The Chief Commercial Officer needs a business intelligence view that answers:

- Where is Nexora generating commercial value?
- Where is GMV being lost or weakened?
- Why are customers not returning after their first purchase?
- How does delivery performance affect customer satisfaction and repeat behaviour?
- Which sellers should be protected, developed, monitored, or reviewed?

The final deliverable must support commercial decision-making across customer retention, seller performance, delivery operations, and category-level recovery.

---

## 4. Problem Statement

Nexora Commerce lacks data-driven visibility into four critical commercial areas.

### 4.1 GMV Performance and Leakage

The business needs to understand the gap between GMV generated and the commercial target, as well as where transaction value fails to convert into delivered orders.

Key questions include:

- How much GMV is Nexora generating?
- How far is the platform from its commercial target?
- Which categories, sellers, or order types are linked to GMV leakage?
- Is leakage concentrated enough to be recoverable through targeted intervention?

### 4.2 Customer Retention and Lifetime Value

The business needs to understand whether customers return after their first purchase and what value is lost when they do not.

Key questions include:

- What percentage of customers return after their first purchase?
- How large is the one-time customer problem?
- When do repeat customers typically return?
- How much GMV do repeat customers contribute compared with one-time customers?

### 4.3 Delivery Experience and Customer Satisfaction

The business needs to understand whether fulfilment performance is affecting customer reviews and repeat purchase behaviour.

Key questions include:

- Is delivery performance meeting the expected standard?
- Are late deliveries linked to weaker review scores?
- Are customers less likely to return after a late first delivery?
- Which states or operational segments show the highest delivery risk?

### 4.4 Seller Portfolio and Commercial Risk

The business needs to identify which sellers drive value and which sellers create commercial risk through poor service performance.

Key questions include:

- Which sellers contribute the most GMV?
- How concentrated is seller GMV?
- Which sellers are associated with late delivery or weak review performance?
- Which sellers require protection, development, intervention, or review?

Without these answers, the CCO cannot make informed decisions about where to invest commercial effort, which seller relationships to prioritise, or how to address the customer retention problem.

---

## 5. Business Questions

**BQ1:** How much GMV is Nexora generating versus its commercial target, and where is the gap coming from?

**BQ2:** Which product categories, sellers, and regions are driving commercial value, and which are creating leakage, freight pressure, or customer experience risk?

**BQ3:** Are customers returning after their first purchase, and where in the customer journey is Nexora losing them?

**BQ4:** What is the relationship between delivery performance, review scores, and repeat purchase behaviour?

**BQ5:** Which sellers are Nexora’s highest-value commercial partners, and which sellers are creating risk through late delivery, weak reviews, or poor fulfilment performance?

---

## 6. Project Objectives

This analysis was commissioned to deliver five outcomes.

### Objective 1 — Quantify GMV Performance and Leakage

Calculate total GMV, compare performance against the commercial target, and identify where GMV leakage is occurring by source, category, and seller relationship.

### Objective 2 — Diagnose the Retention Problem

Measure customer retention, first-to-second purchase conversion, one-time customer share, repeat customer GMV contribution, and the typical return window for customers who do come back.

### Objective 3 — Connect Delivery Performance to Customer Experience

Measure late delivery, fulfilment duration, review score performance, and the relationship between first-order delivery experience and repeat purchase behaviour.

### Objective 4 — Build a Seller Risk Framework

Segment sellers by commercial value and service quality so Nexora can identify sellers to protect, develop, intervene with, or review.

### Objective 5 — Produce a Stakeholder-Ready BI Deliverable

Deliver a Power BI dashboard, written analysis report, project brief, SQL scripts, data quality log, and supporting documentation that allow the CCO to make evidence-based commercial decisions.

---

## 7. Scope of Analysis

The analysis is organised around four analytical pillars, supported by an executive summary view.

### Executive Summary View

A leadership-facing summary page will synthesise the overall commercial position, headline KPIs, major risks, and recommended priorities.

---

### Pillar 1 — Revenue Performance and GMV Leakage

| Analytical Area | Measures |
|---|---|
| GMV performance | Total GMV, GMV target gap, AOV |
| Revenue composition | Product revenue, freight value, freight cost ratio |
| Leakage quantification | GMV leakage value, leakage rate, leakage orders |
| Category risk | GMV leakage by product category, freight pressure by category |
| Commercial efficiency | Average freight per order, AOV, freight burden |

---

### Pillar 2 — Customer Retention and Lifetime Value

| Analytical Area | Measures |
|---|---|
| Retention | Retention rate, first-to-second purchase rate |
| Customer behaviour | One-time customer share, order frequency distribution |
| Customer value | Repeat customer GMV, repeat customer value contribution |
| Return timing | Average days to return, median days to return, return bands |
| Experience link | Repeat purchase by review score and first-order delivery status |

---

### Pillar 3 — Delivery Experience and Customer Satisfaction

| Analytical Area | Measures |
|---|---|
| Delivery performance | On-time delivery rate, late delivery rate |
| Fulfilment speed | Average fulfilment days, average delay for late orders |
| Customer satisfaction | Average review score, low review rate |
| Delivery impact | Review score by delivery status, retention by delivery status |
| Geographic risk | Late delivery rate by customer state |

---

### Pillar 4 — Seller Portfolio and Commercial Risk

| Analytical Area | Measures |
|---|---|
| Seller value | Seller GMV, GMV per seller, top-tier seller GMV share |
| Seller risk | Seller late rate, seller review score, high-risk seller count |
| Seller concentration | Seller tier GMV share, seller count by tier |
| Seller segmentation | Top, Mid, Tail, and High-Risk seller groups |
| Action list | High-risk seller table for commercial review |

---

## 8. KPI Framework and Targets

KPI denominators vary by metric and are specified in the formula column. All GMV values are reported in Brazilian Reais.

Targets used in this analysis are analytical benchmarks designed for stakeholder simulation. In a real business environment, these targets would be validated with commercial, finance, operations, and customer experience leadership before being used for performance management.

| # | KPI | Formula | Target / Benchmark |
|---|---|---|---|
| 1 | Total GMV | SUM(item_price + freight_value) for delivered orders | R$18.0M |
| 2 | Average Order Value | Total GMV ÷ Delivered Orders | > R$160 |
| 3 | Customer Retention Rate | Customers with 2+ delivered orders ÷ Customers with at least 1 delivered order | ≥15% |
| 4 | First-to-Second Purchase Rate | Customers who placed order 2 ÷ Customers who placed order 1 | ≥25% |
| 5 | On-Time Delivery Rate | Orders delivered on or before estimated delivery date ÷ Delivered Orders | ≥95% |
| 6 | Late Delivery Rate | Orders delivered after estimated delivery date ÷ Delivered Orders | ≤5% |
| 7 | Average Review Score | Average review score for reviewed delivered orders | ≥4.5 |
| 8 | Low Review Rate | Orders with review score 1 or 2 ÷ Reviewed Orders | ≤5% |
| 9 | Freight Cost Ratio | Total Freight Value ÷ Total GMV | ≤15% |
| 10 | Average Freight per Order | Total Freight Value ÷ Delivered Orders | ≤R$20 |
| 11 | GMV Leakage Rate | Leakage product value ÷ Total GMV including leakage | ≤1%, monitored as signal |
| 12 | Leakage Orders | Count of cancelled and unavailable leakage orders | Minimise |
| 13 | Revenue per Customer | Total GMV ÷ Customers with at least 1 delivered order | ≥R$250 |
| 14 | High-Risk Seller Share | High-risk sellers ÷ Registered sellers | ≤10% |
| 15 | Top-Tier Seller GMV Share | Top-tier seller GMV ÷ Total seller GMV | Monitor |

### RAG Thresholds

| Status | Description |
|---|---|
| Green | At or better than target |
| Amber | Within 5 percentage points of target or close to benchmark |
| Red | Materially outside target or benchmark |
| Signal | Below threshold but still requires monitoring |
| Reference | Informational metric with no formal RAG status |

For lower-is-better metrics such as Late Delivery Rate, Freight Cost Ratio, Low Review Rate, and GMV Leakage Rate, RAG logic is inverted. GMV Leakage Rate is treated as a monitored signal even when below threshold because any leakage event represents a failed commercial conversion.

---

## 9. Dataset Overview

### Source Dataset

The source data is the **Olist Brazilian E-Commerce Public Dataset** from Kaggle. It is provided as nine CSV files representing different business entities in the e-commerce marketplace.

| CSV File | Row Count | Business Entity / Purpose |
|---|---:|---|
| `olist_orders_dataset.csv` | 99,441 | Order-level information, including order status and order lifecycle timestamps |
| `olist_order_items_dataset.csv` | 112,650 | Item-level order data, including product, seller, price, and freight value |
| `olist_order_payments_dataset.csv` | 103,886 | Payment transactions, payment type, instalments, and payment value |
| `olist_order_reviews_dataset.csv` | 104,719 | Customer review scores and review timestamps |
| `olist_customers_dataset.csv` | 99,441 | Customer IDs, unique customer IDs, city, state, and zip code prefix |
| `olist_sellers_dataset.csv` | 3,095 | Seller IDs, seller city, state, and zip code prefix |
| `olist_products_dataset.csv` | 32,951 | Product IDs, product category, and product attributes |
| `olist_geolocation_dataset.csv` | 1,000,163 | Zip-code-level geographic coordinates and location details |
| `product_category_name_translation.csv` | 71 | Portuguese-to-English product category translation lookup |

### Validated Analytical Dataset

After profiling, cleaning, joining, and modelling the source files, the analysis uses the following validated analytical figures.

| Attribute | Detail |
|---|---:|
| Delivered orders | 96,478 |
| Registered customers | 96,096 |
| Customers with at least one delivered order | 93,358 |
| Registered sellers | 3,095 |
| Active sellers | 3,025 |
| Unique products used in analysis | 31,625 |
| Leakage orders | 1,234 |

### Data Grain and Joining Logic

The source dataset is not a single flat file. It contains multiple entity-level and transaction-level files that must be joined carefully.

The core analytical grain is **order item level**, using `olist_order_items_dataset.csv` as the main transaction fact source. This means one order can appear multiple times if it contains multiple products or multiple sellers.

Order-level metrics such as delivered orders, late orders, cancelled orders, and customer retention are therefore calculated using distinct order and customer counts to avoid inflation.

### Primary Join Keys

| Relationship | Join Key |
|---|---|
| Orders to Customers | `customer_id` |
| Orders to Order Items | `order_id` |
| Orders to Payments | `order_id` |
| Orders to Reviews | `order_id` |
| Order Items to Products | `product_id` |
| Order Items to Sellers | `seller_id` |
| Products to Category Translation | `product_category_name` |
| Customers to Geolocation | `customer_zip_code_prefix` |
| Sellers to Geolocation | `seller_zip_code_prefix` |

The geolocation file contains multiple records per zip code prefix, so it requires aggregation before being used as a stable lookup table.

---

## 10. Methodology

This project follows the **CRISP-DM** analytical framework.

| Phase | Activities |
|---|---|
| Business Understanding | Defined stakeholder need, business questions, KPIs, scope, and success criteria |
| Data Understanding | Profiled all nine source files, reviewed grain, checked missing values, duplicates, and business logic issues |
| Data Preparation | Cleaned and transformed source data in MySQL and Power Query |
| Data Integration | Joined the nine CSV files into an analysis-ready model using validated business keys |
| Data Modelling | Built a Power BI star schema with fact and dimension tables |
| Analysis | Created DAX measures for GMV, leakage, retention, delivery, review, and seller risk |
| Evaluation | Validated outputs against SQL checks and dashboard results |
| Reporting | Built Power BI dashboard, BI Analysis Report, README, and supporting documentation |

### Validation Controls

Validation steps included:

- Reconciling source row counts across all nine CSV files.
- Validating join paths between orders, customers, order items, sellers, products, reviews, payments, and category translations.
- Aggregating the geolocation file before using it as a location lookup due to duplicate zip code prefix records.
- Reconciling delivered order counts between SQL and Power BI.
- Using `DISTINCTCOUNT(order_id)` for order-level measures because order item data is at item grain.
- Rebuilding the customer dimension to enforce one row per `customer_unique_id`.
- Separating registered customers from customers with at least one delivered order.
- Calculating review-based KPIs only against reviewed orders.
- Treating freight as pass-through value rather than net platform revenue.
- Separating delivered order GMV from cancelled and unavailable leakage events.

---

## 11. Tools

| Tool | Purpose |
|---|---|
| MySQL | Data loading, profiling, cleaning, joining, validation, and analytical views |
| Microsoft Excel | Data quality issue log |
| Power Query | Data transformation and star schema preparation |
| Power BI | Data modelling, DAX measures, dashboard design, and analysis |
| GitHub | Project documentation and version-controlled portfolio presentation |

---

## 12. Deliverables

| Deliverable | Description |
|---|---|
| Project Brief | Analytical contract defining business problem, stakeholder need, scope, KPIs, assumptions, and deliverables |
| SQL Scripts | Data load, profiling, cleaning, validation, joining, and analytical view scripts |
| Excel Data Quality Log | Data quality issues, severity, resolution, and notes |
| Power BI Dashboard | Five-page interactive dashboard covering executive health, revenue/leakage, retention, delivery, and seller risk |
| BI Analysis Report | Stakeholder-facing report with findings, evidence, business impact, recommendations, and limitations |
| GitHub README | Portfolio overview, project navigation, screenshots, and skills demonstrated |

### Power BI Dashboard Pages

| Page | Purpose |
|---|---|
| Executive Summary — Commercial Health & Revenue Risk | Leadership view of commercial performance, headline KPIs, and major risks |
| Revenue Performance & GMV Leakage Drivers | Deep dive into GMV leakage, freight burden, and commercial efficiency |
| Customer Retention & Lifetime Value | Analysis of one-time customers, repeat buyers, return timing, and customer value |
| Delivery Experience & Customer Satisfaction | Links delivery performance to reviews and repeat purchase behaviour |
| Seller Portfolio & Commercial Risk | Segments sellers by value, risk, service quality, and intervention priority |

---

## 13. Key Definitions

| Term | Definition |
|---|---|
| Delivered Order | An order with `order_status = "delivered"` |
| Total GMV | SUM(item_price + freight_value) for delivered orders |
| Product Revenue | SUM(item_price) for delivered orders, excluding freight |
| Freight Value | SUM(freight_value), treated as customer-paid pass-through value |
| GMV Leakage | Product value from cancelled and unavailable orders that failed to convert into delivered transactions |
| Leakage Order | A cancelled or unavailable order included in leakage analysis |
| Freight Cost Ratio | Freight value ÷ total GMV |
| Repeat Customer | A customer with two or more delivered orders |
| One-Time Customer | A customer with exactly one delivered order |
| Customer Retention Rate | Repeat customers ÷ customers with at least one delivered order |
| On-Time Delivery | Delivered customer date is on or before estimated delivery date |
| Late Delivery | Delivered customer date is after estimated delivery date |
| Low Review Score | Review score of 1 or 2 out of 5 |
| High-Risk Seller | Seller with weak service performance based on late delivery and review score thresholds |
| Seller Tier | A derived classification used to group sellers by GMV contribution and service risk |

---

## 14. Assumptions and Constraints

| # | Assumption / Constraint | Impact |
|---|---|---|
| 1 | The Olist dataset does not include seller commission rates, fee structures, or seller payout data. All revenue-related analysis is reported as GMV, not net platform revenue. | Critical — internal commission data would be required to convert GMV into net revenue impact. |
| 2 | Freight value is treated as pass-through value and not counted as Nexora’s own net revenue. | Critical — freight is analysed as a commercial burden and customer cost, not as profit. |
| 3 | GMV leakage is calculated using product value from cancelled and unavailable orders. Freight is excluded from leakage value. | Moderate — this isolates product value that failed to convert into delivered transactions. |
| 4 | Customer retention is measured using `customer_unique_id`. If a physical customer used multiple accounts, retention may be slightly understated. | Moderate — the directional conclusion of very low retention remains robust. |
| 5 | Retention denominator uses customers with at least one delivered order, not all registered customers. | Moderate — this focuses retention on customers who had a completed transaction experience. |
| 6 | Review score analysis includes only orders with available review scores. | Moderate — review KPIs are calculated against reviewed orders only. |
| 7 | The first quarter of the dataset reflects platform ramp-up and may distort trend analysis. | Low — early-period effects should be flagged in trend visuals. |
| 8 | Seller tiering and high-risk thresholds are analytical assumptions created for this engagement. | Low — thresholds should be validated with business stakeholders before operational use. |
| 9 | Delivery and retention relationships are observational associations, not causal proof. | Moderate — findings should be interpreted as strong directional signals requiring business validation. |
| 10 | The geolocation file contains multiple rows per zip code prefix and must be aggregated before being used for geographic analysis. | Moderate — incorrect use of raw geolocation rows could duplicate records or distort geographic outputs. |

---

## 15. Success Criteria

The project will be considered successful if it delivers:

1. A validated Power BI dashboard that allows the CCO to monitor GMV, leakage, retention, delivery experience, and seller risk.
2. A clear quantified view of Nexora’s commercial health and priority risks.
3. Evidence-based recommendations for retention recovery, delivery improvement, category review, and seller management.
4. Documented KPI definitions, assumptions, and limitations.
5. Reproducible SQL scripts showing how the nine source files were profiled, cleaned, joined, and prepared for analysis.
6. A stakeholder-ready BI Analysis Report supported by transparent methodology and dashboard evidence.

---

## 16. Project Close Statement

This project brief serves as the analytical contract for the **Commercial Performance & GMV Leakage Analysis** engagement. All dashboard pages, KPI definitions, written findings, and recommendations should remain traceable to the business questions, scope, assumptions, and success criteria defined in this document.