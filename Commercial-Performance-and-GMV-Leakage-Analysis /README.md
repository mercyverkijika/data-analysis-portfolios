# Commercial Performance & Revenue Leakage Analysis - Nexora Commerce Ltd



## Project Background

> **Note:** Nexora Commerce Ltd is a fictionalised company name applied to the Olist Brazilian E-Commerce Public Dataset (Kaggle). All analysis, findings, and recommendations are genuine and derived from the underlying data.

Nexora Commerce Ltd is a Brazilian e-commerce marketplace that operated between October 2016 and August 2018. The platform operates as a two-sided marketplace, connecting 3,025 independent sellers to consumers across 27 Brazilian states, handling product discovery, payment processing, and order fulfilment coordination as the intermediary layer. Nexora generates revenue through commission fees and marketplace service charges applied to each completed transaction. The exact commission rates are not captured in the source dataset, so all revenue figures in this analysis are expressed in GMV terms.

The Brazilian e-commerce market during this period was characterised by strong growth and intensifying competition, with Mercado Livre and Amazon Brazil both expanding aggressively. The platform had achieved meaningful volume growth, reaching 96,478 delivered orders across the operating window, but commercial leadership identified two structural problems that were capping sustainable growth.

The first was retention. Preliminary signals suggested the vast majority of customers were placing one order and never returning, a fundamental problem in marketplace economics where customer acquisition cost is only recovered through repeat purchase. The second was leakage. The business had no clear view of the gap between the revenue it was processing on paper and the revenue it was successfully converting to delivered, completed transactions.

The Chief Commercial Officer commissioned this analysis to quantify both problems, trace them to their root causes across revenue, customer behaviour, delivery operations, and seller performance, and build a data-driven case for commercial intervention.

The analysis is structured around four areas:

- Revenue Performance and Leakage - GMV versus target, the freight cost composition of every transaction, and the volume and value of orders that failed to convert to revenue
- Customer Retention and Lifetime Value - how many customers returned for a second purchase, when they returned, and the commercial cost of the ones that did not
- Delivery Experience and Review Impact - platform and seller-level late delivery rates, the fulfilment gap between on-time and late orders, and the downstream effect on review scores
- Seller Portfolio Performance - revenue concentration risk, the identification of high-risk sellers, and the case for a formal seller tiering framework

---

The SQL queries used to load, profile, clean, and model the data for this analysis can be found **[here](./sql)**

---

## Data Structure and Initial Checks

The project was built on nine source CSV files from the Olist Brazilian E-Commerce Public Dataset on Kaggle, spanning October 2016 to August 2018. The files were loaded individually into MySQL, profiled, cleaned, and joined before being modelled into a Power BI star schema.

The core transaction table operates at **order item grain**, meaning one order can appear multiple times if it contains multiple items. Order-level metrics such as delivered orders, late orders, cancellation rate, and customer retention were therefore calculated using distinct order and customer counts to avoid inflation.

**Source Files**

| CSV File | Purpose |
| --- | --- |
| `olist_orders_dataset.csv` | Order status and lifecycle timestamps |
| `olist_order_items_dataset.csv` | Item-level product, seller, price, and freight data |
| `olist_order_payments_dataset.csv` | Payment type, instalments, and payment value |
| `olist_order_reviews_dataset.csv` | Customer review scores and review timestamps |
| `olist_customers_dataset.csv` | Customer IDs, location, and unique customer identifier |
| `olist_sellers_dataset.csv` | Seller IDs and seller location |
| `olist_products_dataset.csv` | Product IDs, product category, and product attributes |
| `olist_geolocation_dataset.csv` | Zip-code-level geographic data |
| `product_category_name_translation.csv` | Portuguese-to-English category translation |

**Final Analytical Model**

| Table | Rows | Description |
| --- | ---: | --- |
| `fact_order_items` | 110,197 | Item-grain fact table for delivered order GMV, freight, fulfilment, reviews, and derived analytical flags (is_delivered, is_late, is_negative_review, is_leakage). Primary source for all KPI measures. |
| `fact_leakage` | 1,234 | Leakage fact table covering cancelled and unavailable orders that failed to convert into delivered transactions. |
| `dim_customer` | 96,096 | One row per unique customer, rebuilt using customer_unique_id to support accurate retention analysis. |
| `dim_seller` | 3,095 | One row per registered seller, used for seller performance, tiering, and risk segmentation. |
| `dim_product` | 31,625 | One row per unique product, including translated English product category names. |
| `dim_date` | 729 | Date spine supporting time intelligence, monthly trends, and dashboard slicers. |

**Entity Relationship Diagram**

<!-- Add ERD screenshot here -->

All model relationships are single-direction, one-to-many from dimension to fact. fact_order_items and fact_leakage are appended as a unified fact table in Power Query before the model is built.

> **Note on revenue figures:** The Olist dataset does not include seller commission rates or fee structures. Every revenue metric in this analysis, including Total GMV, Average Order Value, Leakage Revenue, and Revenue per Customer, represents Gross Merchandise Value: the full transaction value processed through the platform. Nexora's actual platform revenue would be GMV multiplied by the applicable commission rate, which is not available in this dataset. All revenue findings must be converted using internal commission data before being presented as net platform revenue.

---

## Executive Summary

### Overview of Findings

Nexora Commerce Ltd generated **R$15.42M in GMV** across **96,478 delivered orders** between October 2016 and August 2018. Against a **R$18.0M CCO target**, the platform sits **R$2.58M short**. The shortfall is not driven by a basket-size problem alone. Average Order Value is **R$159.8**, broadly in line with the **R$160 benchmark** but slightly below target. The larger issue is commercial efficiency: the platform acquires customers, converts them once, and then loses almost all of them.

Below is the overview page from the Power BI dashboard. Other examples are included throughout this README.

<img width="851" height="639" alt="Screenshot 2026-05-19 054230" src="https://github.com/user-attachments/assets/926ac6e3-ce8c-4ab2-abde-a03e7251ba7c" />
<!-- Add Executive Summary dashboard screenshot here -->

&nbsp;

The three most important findings are:

- **1.** Customer retention is extremely weak. Only **2.9%** of customers with at least one delivered order returned for another purchase, meaning **97.1%** placed one order and did not return.

- **2.** Late delivery is strongly associated with weaker customer experience. Late orders received an average review score of **2.27**, compared with **4.29** for on-time orders. Customers whose first order arrived late were also far less likely to return.

- **3.** Seller performance risk is concentrated. **577 sellers** are classified as high-risk, representing **18.6%** of registered sellers. These sellers require structured intervention because poor delivery and review performance can affect retention and future GMV.


&nbsp;

*All revenue figures are GMV. See Assumptions and Caveats.*

---

## Insights Deep Dive

### Revenue Performance and Leakage

<img width="859" height="645" alt="Screenshot 2026-05-19 054627" src="https://github.com/user-attachments/assets/093f1bc0-f7fb-4279-a80a-392a3ae92a24" />

&nbsp;

**1. The platform is R$2.58M short of its GMV target and has no structural mechanism in place to close the gap.**

R$15.42M of GMV against an R$18.0M target is a 14.3% shortfall. Monthly GMV grew steadily through 2017 and into mid-2018 but shows plateau behaviour in the final months of the dataset, the period when compounding from repeat purchase should be accelerating growth if retention were functioning. AOV of R$159.8 is broadly in line with the R$160 benchmark. The problem is frequency. A platform where 97% of customers never return cannot build GMV momentum regardless of how many new sellers it recruits. Filling the top of the funnel while losing almost all customers at the bottom is not a growth model; it is a substitution treadmill.

&nbsp;
**2. Freight charges account for 14.3% of every transaction, sitting just inside the ceiling but with category and regional variation the platform cannot currently see.**

Of every R$1 in platform GMV, R$0.86 is product revenue and R$0.14 is freight charged to the customer. The average freight value per order is R$22.79, against an average product price of R$120.65, putting freight at roughly 19 cents per dollar of product value. That 14.3% platform average sits just inside the 15% ceiling, but averages at marketplace scale routinely obscure the extremes that drive customer behaviour. A low-ticket category with a high freight cost creates a purchase economics problem that suppresses conversion and repeat order rates in ways that aggregate GMV metrics will not surface. The platform currently has no visibility into freight ratios at category or state level, which means it cannot identify which segments are structurally uncompetitive on price-to-delivery cost.


**3. 1,234 leakage orders represent R$97.24K in product revenue the platform attempted but failed to convert.**

625 cancelled and 609 unavailable orders produced a GMV leakage rate of 0.6%, representing R$97.24K in committed product revenue that failed to convert to a delivered transaction. The 0.6% rate is measured against total GMV including freight, which is the correct commercial denominator: it reflects what the platform processed versus what it completed. The absolute figure understates the true commercial cost. Each leakage event is a customer who initiated a purchase, committed intent, and then experienced a fulfilment failure. The downstream damage (a customer who is now unlikely to return and who may leave a negative review of an order they never received) is worth more commercially than the recovered unit revenue. Leakage at this volume is manageable and traceable to specific sellers, but the platform currently has no seller-level leakage monitoring in place.


---

### Customer Retention and Lifetime Value

<img width="911" height="683" alt="Screenshot 2026-05-19 092227" src="https://github.com/user-attachments/assets/474e6e59-d87b-4b2c-ba23-29908f511e1f" />
&nbsp;



**1. 97% of customers never came back. This is the most commercially material finding in the dataset.**

Of 96,096 registered customers, 90,557 placed exactly one order and exited permanently. Only 2,573 placed a second order, 181 placed a third, and 47 placed four or more. Total returning customers: 2,801, a 2.9% retention rate against a 15% target. That frequency collapse is not a rounding error in the data; it is the defining commercial reality of the platform. The consequence is that the platform cannot compound the return on its customer acquisition spend. Every cohort of new customers generates exactly one revenue cycle before being written off, making sustained GMV growth wholly dependent on the next cohort of first-time buyers. In a maturing market with rising acquisition costs, that is not a viable long-term position.
There is no post-purchase engagement infrastructure on the platform. No triggered email, no loyalty programme, no personalised re-engagement. The 2,801 customers who returned did so without any commercial prompt. They represent what organic retention looks like with zero investment. It is a baseline, not a ceiling.

**2. Returning customers generate materially higher revenue per head, which means every percentage point of retention improvement compounds directly into GMV.**

The 2,801 returning customers represent 2.9% of the customer base but account for 4.7% of total GMV, a 1.6x CLV ratio achieved with zero retention investment. In marketplace economics, the ratio of returning customer CLV to one-time customer CLV determines whether retention investment has better unit economics than acquisition. At 1.6x, without any infrastructure in place, the case for retention investment over marginal acquisition spend is clear. A platform that moved retention from 2.9% to 6% while holding AOV constant would generate the GMV equivalent of acquiring roughly 3,000 additional first-time customers at zero acquisition cost.


**3. Half of the customers who will ever return do so within 34 days. The intervention window is day 20 to 25 after first delivery.**

The median time between first and last order among the 2,801 returning customers is 34 days. The mean is 88 days, stretched by a long tail of late returners. In absolute terms, 1,346 customers returned within the first 30 days, nearly half of all returning customers, buying again before the end of their first month. The median is the number that matters for campaign design. It says that if the platform does nothing by day 34, half of the returnable customer pool has already made their repurchase decision, with or without any commercial prompt. A re-engagement trigger at day 20 to 25 post-delivery catches customers at their highest-intent window, before the decision is locked in either direction.


### Delivery Experience and Review Impact

<img width="903" height="688" alt="Screenshot 2026-05-19 092533" src="https://github.com/user-attachments/assets/4e282c8f-4536-46dc-a9ea-3e8c3c21d6c4" />
&nbsp;


**1. A 6.8% late delivery rate exceeds the 5% ceiling and is driven by a concentrated seller cohort, not by systemic logistics failure.**

6.8% of delivered orders arrived after the estimated delivery date, 1.8 percentage points above the ceiling. The distinction between a platform-wide logistics problem and a seller-quality problem matters enormously for the remedy. Regional analysis surfaces meaningful state-level variation: Alagoas (AL) records a 21.4% late rate, Maranhão (MA) 17.4%, and Sergipe (SE) 15.1%, all more than double the platform ceiling. Sao Paulo, which handles 42% of all order volume, performs broadly at the platform average, confirming the problem is not driven by the highest-volume state. At seller level, 577 sellers individually exceed a 10% late rate while the remaining 81% of the seller base performs within or near target. The platform's late delivery problem has a precise geographic and seller-level address. It is not a logistics network problem. It is a seller management problem.

**2. Late orders take 33.8 days to arrive. On-time orders take 10.9 days. The gap is 3.1x and it is not a rounding error in the data.**

Average fulfilment for on-time orders is 10.9 days from order placement to delivery. For late orders it is 33.8 days, a 22.9-day difference and a 3.1x ratio. A customer who expects delivery in 10 days and waits 34 days has not experienced a mildly late delivery. They have experienced a fulfilment failure of a scale that will almost certainly prevent them from placing a second order. The 33.8-day figure is consistent with seller dispatch delays compounding with carrier transit time: a seller who holds an order for 15 to 20 days before dispatching, combined with 10 to 15 days of carrier transit, produces the 34-day average naturally. The delivery date estimation model is not accounting for this seller-level variance, so customers are not being warned that their order is at risk of late delivery.

**3. The 4.08 average review score sits 0.42 points below target and is being suppressed by a delivery performance problem, not a product quality problem.**

4.08 out of 5.0 against a 4.5 target is a gap that can close, but not through review management or customer service initiatives alone. The data is unambiguous: on-time orders average a 4.29 review score. Late orders average 2.27. That 2.02-point gap between the same platform, the same products, and the same sellers, differentiated only by whether the order arrived on time, is not a product quality problem. It is a delivery quality problem. The 4.08 platform average is a weighted blend of those two populations, and it will not move until the 6.8% late delivery rate moves. The same root cause is suppressing both KPIs simultaneously. There is also a direct retention link: customers who received an on-time delivery retained at 2.9%, while customers who experienced a late delivery retained at just 0.5%, a 5.8x gap that makes late delivery functionally equivalent to permanent customer loss.

### Seller Portfolio Performance

<img width="905" height="682" alt="Screenshot 2026-05-19 092555" src="https://github.com/user-attachments/assets/fdd8c1e5-b722-48a7-bb61-13dbf24273bc" />
&nbsp;



**1. Revenue is highly concentrated in a small seller cohort, and the platform has no mechanism to identify or protect those relationships.**

3,025 sellers generated R$15.42M in GMV across the period, an average of approximately R$5,100 per seller. That average is distorted by extreme concentration at the top: the highest-performing 4.98% of sellers (roughly 150 sellers) account for 54% of total GMV. The remaining 95% share the other 46%. In Lorenz curve terms, the platform's seller base is operating well inside the inequality boundary that would be expected even from a healthy two-sided marketplace. What is not standard is having no commercial framework to manage this concentration. The platform's 150 highest-GMV sellers currently receive the same treatment as sellers generating a few hundred reais in annual transactions. There is no tiering, no account management, and no early warning system if a high-value seller begins moving volume to a competing marketplace.

**2. 577 sellers have a late delivery rate above 10%. They are a concentrated, identifiable source of platform-level delivery failure and its downstream commercial damage.**

577 sellers (19% of the active seller base) individually exceed a 10% late rate. The remaining 81% perform at or below the ceiling. This distribution is commercially significant because it means the platform's delivery problem has a precise address. These are not anonymous carriers or opaque logistics networks. These are sellers with IDs, catalogues, and order histories. The platform can contact them, issue performance notices, track improvement, and remove them if improvement does not materialise. What is missing is the commercial and operational framework to do this at scale.

The High Value / High Risk sellers deserve separate treatment. They are simultaneously generating meaningful GMV and systematically damaging the delivery experience and review scores of the customers who buy from them. Removing them without a commercial plan costs revenue. Retaining them without an improvement plan costs retention. Both sides of that trade-off need active management rather than the passive monitoring that currently exists.

---

## Recommendations

**1. Issue performance improvement notices to all 577 high-risk sellers and build the enforcement framework to follow through.**
Every seller with a late delivery rate above 10% should receive a formal notice with a 60-day target and a defined consequence for non-compliance. For sellers in the High Value / High Risk quadrant, pair the notice with a commercial account manager who can co-develop a fulfilment improvement plan before enforcement action becomes necessary. This is the single intervention with the most direct impact on the platform's late delivery rate, review scores, and customer retention simultaneously. The data shows late delivery is associated with retention falling from 2.9% to 0.5% and review scores from 4.29 to 2.27, both concentrated in the same 577-seller cohort.

**2. Build a post-purchase retention programme anchored to the 34-day return window.**
Set an automated email trigger at day 20 to 25 after confirmed first delivery. The communication should reference the customer's purchase category, include a personalised recommendation, and carry a time-limited incentive. Measure click-to-purchase conversion as the primary KPI. The 34-day median return window is specific enough to build a campaign around: 1,346 customers returned within 30 days with no prompt at all. That is the floor. A 2.9% retention rate is not a market problem. It is an infrastructure problem. The infrastructure does not exist yet.

**3. Assign commercial account managers to the Top seller tier within 30 days and implement the full tiering framework within 90 days.**
Without a seller tier classification, the platform cannot prioritise its commercial relationships, protect its highest-GMV sellers, or rationally allocate account management resource. Implement Top, Mid, and Tail tiers using the revenue percentile thresholds defined in this project. Review Tail-tier sellers for inactive listings and remove catalogue items that have generated no sales in 90 days.

**4. Implement a seller dispatch SLA and a post-delivery service recovery workflow.**
Set a maximum dispatch window of 5 business days from order placement. Monitor compliance at seller level and escalate sellers who breach this threshold on more than 10% of orders to the At-Risk tier. For orders confirmed as late, trigger a proactive service recovery communication to the customer before the review prompt appears. Measure whether this reduces the negative review rate for the affected cohort.

**5. Classify and action all 1,234 leakage events before the next commercial review.**
Segment the 1,234 leakage orders by seller and root cause. Identify sellers with 3 or more leakage events and issue mandatory stock availability improvement notices within 30 days. Trigger a win-back communication to all 1,234 affected customers within two weeks. The R$97.24K leakage revenue figure is recoverable only if the seller-level failure driving it is addressed first.

---

## Assumptions and Caveats

**Caveat 1: All revenue figures are Gross Merchandise Value, not Nexora's net platform revenue.**

***Impact: Critical.***

The Olist dataset does not include seller commission rates, fee structures, or net payout data. Every revenue figure in this analysis (Total GMV, Average Order Value, Leakage Revenue, Revenue per Customer) represents the full transaction value processed through the platform (item_price + freight_value for delivered orders). Nexora's actual revenue would be GMV multiplied by the applicable commission rate per transaction. The R$2.58M GMV gap and the R$97.24K leakage figure must be converted using internal commission rate data before being presented as net revenue impacts to finance or the board.

**Caveat 2: The source data is at order item grain, not order grain.**

***Impact: High.***

One order can contain multiple items and therefore appears more than once in the order items table. Order-level KPIs such as order count and average order value are calculated using DISTINCTCOUNT on order_id throughout to avoid double-counting. Analysts extending this work should verify the grain of any new measure before publishing.

**Caveat 3: The customer dimension contained 122 duplicate customer_unique_id values and was rebuilt.**

***Impact: Low.***

The original dim_customer view used SELECT DISTINCT across customer_unique_id, customer_state, and customer_city. This produced 122 customers appearing more than once because they placed orders from different cities or states across the operating period. The fix uses GROUP BY customer_unique_id with MAX(customer_state) and MAX(customer_city) to enforce one row per customer. The confirmed unique customer count of 96,096 is post-fix. The duplicate pattern, customers with orders from multiple states, is itself commercially interesting as an indicator of a mobile customer base or inconsistent address recording.

**Caveat 4: Customer retention is measured on customer_unique_id and may marginally understate true repeat purchase behaviour.**

***Impact: Low.***

customer_unique_id is the stable cross-order customer identifier in the Olist schema. A physical customer who placed orders under two separate accounts would be counted as two distinct non-returning customers. The 3% retention rate may be marginally understated as a result. The directional conclusion of near-zero retention is robust regardless of this variance. In a dataset of 96,096 customers, even a 1% correction would not change the commercial priority or recommended action.

**Caveat 5: Leakage revenue is calculated on product price only and excludes freight.**

***Impact: Moderate.***

The leakage revenue figure of R$97.24K is SUM(item_price) for leakage orders, not SUM(total_item_revenue). Freight is treated as a pass-through cost and excluded from leakage calculations throughout. The leakage rate denominator is total product revenue (item_price for delivered orders), not total GMV. This approach correctly isolates the product revenue component that was committed and not recovered. All leakage metrics are clearly labelled in the DAX measures file and applied consistently across Power BI visuals.

**Caveat 6: Review scores are not available for all delivered orders.**

***Impact: Moderate.***

Average Review Score and Negative Review Rate are calculated against reviewed orders only, not the full 96,478 delivered order population. The denominator is reviewed orders, not total delivered orders, and is labelled as such on all dashboard visuals. The directional conclusions (4.08 average against a 4.5 target, and elevated negative review rates in the late-delivery cohort) are robust within the reviewed population.

**Caveat 7: The relationship between delivery performance and retention is observational, not causal.**

***Impact: Moderate.***

The association between late delivery, review score, and repeat purchase rate is based on observed patterns in the data. No controlled experiment was conducted. Other factors such as product category, price point, or customer segment may explain part of the observed variation. All insights in this analysis use association language rather than causal language for this reason.

**Caveat 8: The first quarter of the dataset (October to December 2016) reflects platform ramp-up, not steady-state operations.**

***Impact: Low.***

Order volumes in October to December 2016 are substantially lower than the volumes seen from January 2017 onward, consistent with an early-stage platform still building its seller and buyer base. Including this period in trend analysis distorts growth rate calculations. Time-series visuals on the dashboard flag this period and trend analysis begins from January 2017 to avoid ramp-up distortion.

**Caveat 9: Seller tiering thresholds are analytical decisions, not Nexora business rules.**

***Impact: Low.***

Top, Mid, and Tail seller tiers are assigned using revenue percentile thresholds defined for this project. The seller quadrant classification (High Value / High Risk, High Value / Low Risk, Low Value / High Risk, Low Value / Low Risk) uses the platform median GMV and a 10% late rate threshold as the quadrant boundaries. These are analytical choices and can be adjusted using slicers in the Power BI dashboard. The thresholds are documented in the DAX measures file and the project brief.

**Caveat 10: The geolocation file requires aggregation before use.**

***Impact: Moderate.***

The olist_geolocation dataset contains multiple rows per zip code prefix, as the same prefix can cover several latitude and longitude coordinates. Direct joins without prior aggregation would duplicate customer or seller records and distort any geographic analysis. The dim_geolocation model aggregates to one row per zip code prefix using mean latitude and mean longitude values before joining to the customer and seller dimensions.

---

<details>
<summary>Repository Structure</summary>

```
nexora-commercial-performance-analysis
 ┣ sql
 ┃ ┣ 00_database_setup.sql
 ┃ ┣ 01_data_profiling.sql
 ┃ ┣ 02_clean_views.sql
 ┃ ┣ 02b_distributions.sql
 ┃ ┣ 03_analysis.sql
 ┃ ┗ 4_dimensions.sql
 ┣ excel
 ┃ ┗ nexora_DQ_issues_log.xlsx
 ┣ docs
 ┃ ┣ 01_analysis_report.md
 ┃ ┗ 02_project_bried.md
 ┗ README.md
```

</details>

---

*Analysis conducted using MySQL, Microsoft Excel, and Microsoft Power BI. Data source: Olist Brazilian E-Commerce Public Dataset (Kaggle), nine source CSV files, October 2016 to August 2018. Company name and business context fictionalised for portfolio presentation purposes.*
