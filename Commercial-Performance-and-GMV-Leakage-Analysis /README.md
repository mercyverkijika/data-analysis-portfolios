# Commercial Performance & GMV Leakage Analysis - Nexora Commerce Ltd

## Project Background

Nexora Commerce Ltd is a fictional Brazilian e-commerce marketplace operating between October 2016 and August 2018. The platform connects independent sellers to consumers across 27 Brazilian states, supporting product discovery, payment processing, order fulfilment coordination, and customer experience management.

This project uses the publicly available **Olist Brazilian E-Commerce Public Dataset** from Kaggle. The dataset is provided as **nine CSV files** covering orders, customers, sellers, products, order items, payments, reviews, geolocation, and product category translation.

In a real marketplace model, Nexora would generate net revenue through seller commissions, marketplace service charges, and payment-related fees. However, the dataset does not include commission rates, fee structures, or seller payout data. For that reason, all revenue-related metrics in this project are reported as **Gross Merchandise Value (GMV)**, not net platform revenue.

The Chief Commercial Officer commissioned this analysis to understand four commercial risks:

- Whether GMV growth was translating into sustainable customer value
- Where GMV leakage was occurring
- Why customer retention was extremely weak
- Which sellers were creating commercial risk through poor delivery performance and weaker customer experience

The analysis is structured around four areas:

- **Revenue Performance and GMV Leakage** - GMV versus target, freight burden, and orders that failed to convert into delivered transactions
- **Customer Retention and Lifetime Value** - repeat purchase behaviour, return timing, and the value of retained customers
- **Delivery Experience and Review Impact** - late delivery, fulfilment performance, review scores, and repeat behaviour
- **Seller Portfolio Performance** - seller concentration, high-risk sellers, and seller tiering opportunities

---

The SQL queries used to load, profile, clean, join, and model the data for this analysis can be found **[here](./sql)**.

---

## Data Structure and Initial Checks

The project was built using the original **nine-file Olist Brazilian E-Commerce Public Dataset** from Kaggle. The files were loaded, profiled, cleaned, and joined in MySQL before being modelled into a Power BI star schema.

The core transaction table operates at **order item grain**, meaning one order can appear multiple times if it contains multiple items. Order-level metrics such as delivered orders, late orders, cancellation rate, and customer retention were therefore calculated using distinct order and customer counts to avoid inflation.

### Source Files

| CSV File | Purpose |
|---|---|
| `olist_orders_dataset.csv` | Order status and lifecycle timestamps |
| `olist_order_items_dataset.csv` | Item-level product, seller, price, and freight data |
| `olist_order_payments_dataset.csv` | Payment type, instalments, and payment value |
| `olist_order_reviews_dataset.csv` | Customer review scores and review timestamps |
| `olist_customers_dataset.csv` | Customer IDs, location, and unique customer identifier |
| `olist_sellers_dataset.csv` | Seller IDs and seller location |
| `olist_products_dataset.csv` | Product IDs, product category, and product attributes |
| `olist_geolocation_dataset.csv` | Zip-code-level geographic data |
| `product_category_name_translation.csv` | Portuguese-to-English category translation |

### Final Analytical Model

| Table | Rows | Description |
| --- | ---: | --- |
| `fact_order_items` | 110,197 | Item-grain fact table for delivered order GMV, freight, fulfilment, reviews, seller performance, and derived analytical flags |
| `fact_leakage` | 1,234 | Leakage fact table covering cancelled and unavailable orders that failed to convert into delivered transactions |
| `dim_customer` | 96,096 | One row per unique customer, rebuilt using `customer_unique_id` to support retention analysis |
| `dim_seller` | 3,095 | One row per registered seller, used for seller performance, tiering, and risk segmentation |
| `dim_product` | 31,625 | One row per unique product, including translated English product category names |
| `dim_date` | 729 | Date spine supporting time intelligence, monthly trends, and dashboard slicers |

**Entity Relationship Diagram**

<!-- Add ERD screenshot here -->

All model relationships are single-direction, one-to-many from dimension tables to fact tables. `fact_order_items` and `fact_leakage` are appended in Power Query where needed for unified delivered and undelivered transaction analysis.

> **Note on revenue figures:** The Olist dataset does not include seller commission rates, marketplace fee structures, or seller payout data. Every revenue-related metric in this project represents **GMV**, not Nexora’s net revenue. Net platform revenue would require applying internal commission rates that are not available in the dataset.

---

## Executive Summary

### Overview of Findings

Nexora Commerce Ltd generated **R$15.42M in GMV** across **96,478 delivered orders** between October 2016 and August 2018. Against a **R$18.0M CCO target**, the platform sits **R$2.58M short**.

The shortfall is not driven by a severe basket-size problem alone. Average Order Value is **R$159.8**, broadly in line with the **R$160 benchmark** but slightly below target. The larger issue is commercial efficiency: the platform acquires customers, converts them once, and then loses almost all of them.

Below is the overview page from the Power BI dashboard. Other examples are included throughout this README. The full interactive dashboard can be seen **[here](#)**.

<!-- Add Executive Summary dashboard screenshot here -->

&nbsp;

The three most important findings are:

> **1.** Customer retention is extremely weak. Only **2.9%** of customers with at least one delivered order returned for another purchase, meaning **97.1%** placed one order and did not return.

> **2.** Late delivery is strongly associated with weaker customer experience. Late orders received an average review score of **2.27**, compared with **4.29** for on-time orders. Customers whose first order arrived late were also far less likely to return.

> **3.** Seller performance risk is concentrated. **577 sellers** are classified as high-risk, representing **18.6%** of registered sellers. These sellers require structured intervention because poor delivery and review performance can affect retention and future GMV.

<!-- Add KPI scorecard screenshot here -->

&nbsp;

*All revenue figures are GMV. See Assumptions and Caveats.*

---

## Insights Deep Dive

### Revenue Performance and Leakage

**1. The platform is R$2.58M short of its GMV target, but the issue is not basket size alone.**

Nexora generated **R$15.42M in GMV** against an **R$18.0M target**, leaving a **R$2.58M gap**. Average Order Value is **R$159.8**, broadly in line with the **R$160 benchmark** but slightly below target. This means basket size is not the only issue. The larger commercial problem is frequency and retention: the platform is not converting enough first-time buyers into returning customers.

<!-- Add Revenue Performance dashboard screenshot here -->

&nbsp;

**2. Freight burden is close to the risk threshold.**

Freight represents **14.3%** of total GMV, close to the **15% ceiling**. Average freight per order is **R$22.79**, above the **R$20 benchmark**. At platform level this looks manageable, but the risk is likely concentrated in low-ticket categories and regions where freight cost is high relative to product value.

**3. 1,234 leakage orders represent R$97.24K in product value that failed to convert.**

The analysis identified **1,234 leakage orders**, representing **R$97.24K** in product value from cancelled and unavailable orders. The overall GMV leakage rate is **0.6%**, but leakage still matters because every failed transaction represents a customer who attempted to buy but did not receive a completed order.

---

### Customer Retention and Lifetime Value

**1. 97.1% of customers did not return after their first delivered order.**

Of **93,358 customers** with at least one delivered order, only **2,801 returned** for another purchase. This gives Nexora a **2.9% retention rate** against a **15% target**. The platform is therefore heavily dependent on continuous new customer acquisition rather than compounding value from its existing customer base.

<!-- Add Customer Retention dashboard screenshot here -->

&nbsp;

**2. Repeat customers are small in number but higher value.**

Repeat customers represent **2.9%** of customers but generate **4.7%** of total GMV. This shows that retained customers contribute more value than their headcount share and that even modest retention improvement could create meaningful GMV upside.

**3. The first 30 days after delivery are the key return window.**

The largest returning customer group placed their next order within **0–30 days**, and the median return window is **34 days**. This creates a clear opportunity for post-purchase engagement between day 20 and day 25 after first delivery.

<!-- Add Retention timeline visual screenshot here -->

&nbsp;

---

### Delivery Experience and Review Impact

**1. Late delivery is above target and geographically concentrated.**

The platform late delivery rate is **6.8%**, above the **5% ceiling**. Late delivery is not evenly distributed across Brazil. States such as **Alagoas (21.4%)**, **Maranhao (17.4%)**, and **Sergipe (15.1%)** have late delivery rates far above the platform average.

<!-- Add Delivery Performance dashboard screenshot here -->

&nbsp;

**2. Late orders take significantly longer to fulfil.**

On-time orders take an average of **10.9 days** to reach customers. Late orders take **33.8 days**, creating a fulfilment gap of almost **23 days**. This is not a minor delay; it represents a materially weaker customer experience.

<!-- Add Fulfilment gap visual screenshot here -->

&nbsp;

**3. Late delivery is strongly associated with weaker review scores and lower repeat behaviour.**

On-time orders average **4.29 stars**, while late orders average **2.27 stars**. Retention after an on-time first delivery is **2.9%**, compared with **0.5%** after a late first delivery. This is an observed association, not causal proof, but it is commercially significant.

---

### Seller Portfolio Performance

**1. Seller GMV is highly concentrated.**

The top **4.98%** of sellers generate approximately **54%** of seller GMV. This creates concentration risk because a small group of sellers drives a disproportionate share of platform value.

<!-- Add Seller Portfolio dashboard screenshot here -->

&nbsp;

**2. 577 sellers are classified as high-risk.**

There are **577 high-risk sellers**, representing **18.6%** of registered sellers. These sellers are linked to weaker delivery and review performance and require structured monitoring, improvement plans, or commercial intervention.

<!-- Add Seller quadrant and High Risk Sellers table screenshot here -->

&nbsp;

High Value / High Risk sellers require special attention. They protect near-term GMV but can damage customer experience if poor delivery and review performance are not addressed.

---

## Recommendations

**1. Build a first-to-second purchase retention programme.**  
Trigger automated post-purchase campaigns within **20–25 days** after first delivery. The campaign should include personalised product recommendations, category-based messaging, and a time-limited incentive.

**2. Prioritise first-order delivery reliability.**  
Late first delivery is associated with much weaker repeat behaviour. New customer orders should be routed away from sellers with poor delivery performance where possible.

**3. Implement seller tiering and SLA monitoring.**  
Segment sellers into value-risk groups and monitor delivery performance, review scores, and leakage events. High-risk sellers should receive improvement plans and clear escalation rules.

**4. Assign account management to top-tier sellers.**  
The top 4.98% of sellers generate around 54% of seller GMV. These relationships should be actively protected through structured account reviews and seller health monitoring.

**5. Investigate high-risk delivery states.**  
States such as Alagoas, Maranhao, and Sergipe should be reviewed by seller location, carrier route, delivery distance, and product category mix.

**6. Classify and action all leakage events.**  
The 1,234 leakage orders should be segmented by seller, product category, and root cause. Customers affected by failed transactions should be targeted with win-back communication.

---

## Assumptions and Caveats

**Caveat 1: All revenue figures are GMV, not Nexora's net platform revenue.**

***Impact: Critical.***

The Olist dataset does not include seller commission rates, marketplace fee structures, or seller payout data. Metrics such as Total GMV, Average Order Value, GMV Leakage, and Revenue per Customer represent transaction value, not net platform revenue.

**Caveat 2: The source data is at order item grain.**

***Impact: High.***

One order can appear multiple times if it contains multiple items. Order-level KPIs are therefore calculated using distinct order counts to avoid inflation.

**Caveat 3: Customer retention is measured using `customer_unique_id`.**

***Impact: Moderate.***

`customer_unique_id` is the stable cross-order customer identifier in the Olist schema. If a physical customer used multiple accounts, retention may be slightly understated, but the overall conclusion of very low retention remains robust.

**Caveat 4: Leakage value is calculated using product value and excludes freight.**

***Impact: Moderate.***

GMV leakage is calculated using `item_price` from cancelled and unavailable orders. Freight is excluded because it is treated as customer-paid pass-through value rather than Nexora’s net revenue.

**Caveat 5: Review scores are not available for all delivered orders.**

***Impact: Moderate.***

Review-based KPIs are calculated against reviewed delivered orders only, not the full delivered order population.

**Caveat 6: Delivery and retention relationships are observational.**

***Impact: Moderate.***

The relationship between late delivery, review score, and repeat purchase is based on observed association. Controlled analysis would be required to prove causality.

**Caveat 7: The geolocation file requires aggregation before use.**

***Impact: Moderate.***

The geolocation dataset contains multiple rows per zip code prefix. Direct joins without aggregation could duplicate records or distort geographic analysis.

**Caveat 8: Seller tiering thresholds are analytical assumptions.**

***Impact: Low.***

Seller tiers and high-risk classifications were created for this project and should be validated with business stakeholders before operational use.

---

<details>
<summary>Repository Structure</summary>

```text
nexora-commercial-performance-analysis
 ┣ sql
 ┃ ┣ nexora_01_create_and_load.sql
 ┃ ┣ nexora_02_profiling.sql
 ┃ ┣ nexora_02_views.sql
 ┃ ┣ nexora_02b_distributions.sql
 ┃ ┣ nexora_03_analysis.sql
 ┃ ┗ nexora_04_dimensions.sql
 ┣ excel
 ┃ ┗ nexora_DQ_issues_log.xlsx
 ┣ powerbi
 ┃ ┗ Nexora_Commercial_Performance_Dashboard.pbix
 ┣ docs
 ┃ ┣ Project_Brief_Nexora.md
 ┃ ┣ BI_Analysis_Report_Nexora.md
 ┃ ┗ Dashboard_Screenshots
 ┗ README.md