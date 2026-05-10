# Commercial Performance and GMV Leakage Analysis Report
## Nexora Commerce Ltd

**Prepared by:** Mercy Verkijika

**Document Type:** Portfolio BI Analysis Report

---

## Important Notice

This analysis uses the publicly available **Olist Brazilian E-Commerce Public Dataset** sourced from Kaggle. The dataset is provided as **nine separate CSV files** covering orders, customers, sellers, products, order items, payments, reviews, geolocation, and product category translation.

Nexora Commerce Ltd, the business context, and stakeholder roles have been fictionalised to simulate a real-world commercial analytics engagement. All analytical findings, KPI definitions, dashboard outputs, and recommendations are original work.

All revenue-related metrics in this report are expressed as **Gross Merchandise Value (GMV)**, not net platform revenue. The Olist dataset does not include seller commission rates, marketplace fee structures, or seller payout data. Therefore, Nexora’s actual net revenue cannot be calculated from the available data.

---

## Executive Summary

Nexora Commerce Ltd generated R$15.42M in Gross Merchandise Value across 96,478 delivered orders between October 2016 and August 2018, against a CCO target of R$18.0M. The R$2.58M shortfall is not driven by a severe basket-size problem alone. Average Order Value is R$159.8, broadly in line with the R$160 benchmark but slightly below target. The larger constraint is commercial efficiency: the platform acquires customers at cost and recovers that cost exactly once, because 97.1% of customers never place a second order.

Five findings define the commercial position:

- GMV growth is real but commercially fragile. At 2.9% customer retention, Nexora is entirely dependent on continuous new customer acquisition to sustain transaction volume. There is no compounding return from the existing base.
- Late delivery is not only a logistics issue; it is a retention risk. Retention after an on-time first delivery is 2.9%. After a late delivery it is 0.5%. Customers whose first order arrived late left a 2.27 average review score versus 4.29 for on-time orders. The delivery performance problem is strongly associated with reduced customer lifetime value.
- GMV leakage is concentrated and addressable. The GMV leakage rate is 0.6%, representing R$97.24K in committed revenue the platform did not convert. Leakage is not spread evenly across the catalogue. It is concentrated in specific categories and seller relationships.
- Late delivery risk is geographically concentrated. States including Alagoas (21.4%), Maranhao (17.4%), and Sergipe (15.1%) carry late delivery rates more than three times the platform average, pointing to specific carrier or seller-location failures rather than systemic logistics weakness.
- Seller concentration creates structural revenue risk. The top 4.98% of sellers generate approximately 54% of seller GMV. Of 3,095 registered sellers, 577 are classified as high-risk based on delivery and review performance. Poor management of either group carries outsized commercial consequence.

**Headline KPI Scorecard**

| KPI | Result | Target | Status |
|---|---|---|---|
| Total GMV | R$15.42M | R$18.0M | Red |
| Average Order Value | R$159.8 | > R$160 | Amber |
| Customer Retention Rate | 2.9% | 15% | Red |
| Late Delivery Rate | 6.8% | <= 5% | Amber |
| Average Review Score | 4.08 / 5.0 | 4.5 / 5.0 | Red |
| Avg Review Score — Late Orders | 2.27 / 5.0 | 4.5 / 5.0 | Red |
| Avg Review Score — On-Time Orders | 4.29 / 5.0 | 4.5 / 5.0 | Amber |
| Freight Cost Ratio | 14.3% | <= 15% | Green |
| Average Freight per Order | R$22.79 | <= R$20 | Amber |
| GMV Leakage Rate | 0.6% | <= 1% | Signal |
| High-Risk Sellers | 577 | ≤10% of sellers | Red |

*See Appendix for full KPI reference table with actuals, targets, and gaps.*

---

## Business Context and Objectives

Nexora Commerce Ltd is a Brazilian e-commerce marketplace that operated between October 2016 and August 2018. The platform connects independent sellers to end consumers across Brazil, acting as an intermediary that facilitates product listing, payment processing, order fulfilment coordination, and customer service. In a real marketplace model, Nexora would generate net revenue through seller commission fees, marketplace service charges, and payment-related fees applied to completed transactions. However, because the source dataset does not include commission rates, fee structures, or seller payout data, this analysis evaluates commercial performance using GMV rather than net platform revenue.

**Key operational facts**

| Attribute | Detail |
|---|---|
| Total registered customers | 96,096 |
| Total delivered orders | 96,478 |
| Active sellers | 3,025 |
| Registered sellers | 3,095 |
| Product catalogue | 31,625 unique products |
| Operating period | October 2016 to August 2018 |
| Primary market | Brazil, 27 states |
| Top market | Sao Paulo state (42% of all orders) |

The platform operates in Brazil's rapidly growing e-commerce sector, competing against established players including Mercado Livre and Amazon Brazil. Leadership identified two converging commercial threats that were limiting sustainable growth.

**Threat 1: Near-zero customer retention.** Preliminary data indicated the overwhelming majority of customers place a single order and never return. In an e-commerce marketplace, customer acquisition cost is only recovered through repeat purchases. A platform that cannot convert first-time buyers into returning customers is filling a leaking bucket from the top while losing value from the bottom.

**Threat 2: Unquantified GMV leakage and commercial inefficiency.** The business lacked clear visibility into the gap between GMV it attempted to process and GMV successfully converted into delivered transactions. Cancelled orders, unavailable products, high freight costs relative to product value, and underperforming seller and category segments all represent areas where commercial value is lost, weakened, or placed at risk.

The Chief Commercial Officer commissioned this analysis to quantify both threats with precision, identify their root causes, and provide a clear commercial roadmap for recovery.

**Business Questions**

> **BQ1:** How much GMV is Nexora generating versus its commercial target, and where specifically is the gap coming from?

> **BQ2:** Which product categories, sellers, and regions are driving commercial value, and which are creating GMV leakage, freight pressure, or customer experience risk?

> **BQ3:** Are customers returning after their first purchase, and if not, at which point in the experience are we losing them?

> **BQ4:** What is the relationship between delivery performance, customer review scores, and repeat purchase behaviour, and which operational failures are costing the most revenue?

> **BQ5:** Which sellers are Nexora's highest-value commercial partners and which are creating risk through poor delivery, high cancellations, or low ratings?

---

## Scope of Analysis

The report is organised into five dashboard-aligned sections, each addressing one or more of the five business questions.

**Section 1: Executive Commercial Health**

This section synthesises the platform's overall commercial position, connecting GMV performance to retention and fulfilment risk. It addresses BQ1. Note: this is a summary layer rather than a standalone analytical pillar — its findings are drawn from the four sections below.

**Section 2: Revenue Performance and GMV Leakage**

This section quantifies total GMV, identifies leakage by source and category, and measures freight cost pressure across the revenue model. It addresses BQ1 and BQ2.

| Analytical Area | Measures |
|---|---|
| Total revenue | Total GMV, Revenue by Month, Revenue Growth Rate |
| Revenue composition | Revenue by Category, Revenue by State, Revenue by Seller Tier |
| Leakage quantification | GMV Leakage Rate, Leakage by Type, Leakage by Category |
| Freight pressure | Freight Cost Ratio, Average Freight per Order, Freight by Category and State |

**Section 3: Customer Retention and Lifetime Value**

This section measures first-to-second purchase conversion, the commercial value of repeat customers versus one-time buyers, the optimal intervention window, and the association between review scores and repeat behaviour. It addresses BQ3 and BQ4.

| Analytical Area | Measures |
|---|---|
| Retention | Customer Retention Rate, First-to-Second Purchase Conversion Rate |
| Customer value | Revenue per Customer, Repeat vs One-Time GMV Contribution |
| Purchase behaviour | Customer Order Frequency Distribution, Median and Average Days to Return |
| Experience link | Retention Rate by Review Score, Repeat Purchase Rate by First-Order Delivery Status |

**Section 4: Delivery Experience and Customer Satisfaction**

This section examines delivery performance alongside review scores and retention outcomes, identifies geographic hotspots, and quantifies the commercial risk associated with fulfilment failure. It addresses BQ4.

| Analytical Area | Measures |
|---|---|
| Delivery | On-Time Delivery Rate, Late Delivery Rate, Average Fulfilment Days |
| Experience impact | Review Score by Delivery Status, Retention Rate by Delivery Status |
| Geographic concentration | Late Delivery Rate by State |

**Section 5: Seller Portfolio and Commercial Risk**

This section tiers the seller base by commercial value and risk, quantifies revenue concentration, and identifies sellers whose performance is creating commercial exposure. It addresses BQ5.

| Analytical Area | Measures |
|---|---|
| Seller performance | Revenue per Seller, Seller Late Rate, Seller Review Score |
| Seller tiering | Top, Mid, and Tail segments by revenue percentile |
| Concentration risk | Top-Tier GMV Share, High-Risk Seller Count |
| Risk matrix | Seller GMV vs Late Rate quadrant classification |

---

## KPI Framework

All GMV-related KPIs are calculated in Brazilian Reais (R$). KPI denominators vary by metric and are specified in the formula column. Revenue-related metrics are reported as GMV rather than net platform revenue because commission rates and seller payout data are not available in the source dataset.

| # | KPI | Formula | Target |
|---|---|---|---|
| 1 | Total GMV | SUM(item_price + freight_value) for delivered orders. Represents Gross Merchandise Value, not Nexora net revenue. | R$18.0M |
| 2 | Average Order Value | Total GMV / Total Delivered Orders | > R$160 |
| 3 | Customer Retention Rate | Customers with 2+ delivered orders / Customers with at least 1 delivered order | >= 15% |
| 4 | First-to-Second Purchase Rate | Customers who placed order 2 / Customers who placed order 1 | >= 25% |
| 5 | On-Time Delivery Rate | Orders delivered on or before estimated date / Total Delivered Orders | >= 95% |
| 6 | Late Delivery Rate | Orders delivered after estimated date / Total Delivered Orders | <= 5% |
| 7 | Average Review Score | Average review score for reviewed delivered orders | >= 4.5 |
| 8 | Negative Review Rate | Orders with score 1 or 2 / Total Reviewed Orders | <= 5% |
| 9 | Freight Cost Ratio | Total Freight Value / Total GMV | <= 15% |
| 10 | Average Freight per Order | Total Freight Value / Delivered Orders | <= R$20 |
| 11 | GMV Leakage Rate | Leakage product value / Total GMV including leakage | <= 1%, monitored as signal |
| 12 | Revenue Concentration | Top-Tier Seller GMV / Total Seller GMV | Monitor |
| 13 | High-Risk Seller Share | High-risk sellers / Registered sellers | <= 10% |
| 14 | Cancellation Rate | Cancelled Orders / Total Orders | <= 2% |
| 15 | Revenue per Customer | Total GMV / Customers with at least 1 delivered order | >= R$250 |

**RAG Thresholds**

| Status | Description |
|---|---|
| Green | At or above target |
| Amber | Within 5 percentage points of target |
| Red | More than 5 percentage points below target |

For metrics where lower is better (Late Delivery Rate, Freight Cost Ratio, Cancellation Rate, Negative Review Rate, GMV Leakage Rate) the RAG logic is inverted. GMV Leakage Rate is an exception: any leakage is a commercial failure signal and should prompt investigation regardless of RAG status.

---

## Dataset Source and Integration

The analysis was built from the original **Olist Brazilian E-Commerce Public Dataset**, which is provided as nine CSV files. These files represent different marketplace entities and transaction processes.

| CSV File | Business Entity / Purpose |
|---|---|
| `olist_orders_dataset.csv` | Order-level information, including order status and lifecycle timestamps |
| `olist_order_items_dataset.csv` | Item-level order data, including product, seller, price, and freight value |
| `olist_order_payments_dataset.csv` | Payment transactions, payment type, instalments, and payment value |
| `olist_order_reviews_dataset.csv` | Customer review scores and review timestamps |
| `olist_customers_dataset.csv` | Customer IDs, customer unique IDs, city, state, and zip code prefix |
| `olist_sellers_dataset.csv` | Seller IDs, seller city, state, and zip code prefix |
| `olist_products_dataset.csv` | Product IDs, product category, and product attributes |
| `olist_geolocation_dataset.csv` | Zip-code-level geographic coordinates and location details |
| `product_category_name_translation.csv` | Portuguese-to-English product category translation lookup |

The core analytical grain is **order item level**, using `olist_order_items_dataset.csv` as the main transaction fact source. This means a single order can appear multiple times if it contains multiple items. Order-level KPIs such as delivered orders, late orders, cancellation rate, and customer retention were therefore calculated using distinct order and customer counts to avoid duplication.

The source files were loaded, profiled, cleaned, and joined in MySQL before being transformed into an analysis-ready model for Power BI.

---

## Methodology

This project follows the CRISP-DM framework across six phases.

| Phase | Activities |
|---|---|
| Business Understanding | Defined business questions, KPIs, scope, stakeholder need, and analytical success criteria |
| Data Understanding | Profiled all nine source CSV files, reviewed grain, missing values, duplicates, data types, and business logic issues |
| Data Preparation | Cleaned and transformed source data in MySQL; resolved customer duplication and prepared analysis-ready views |
| Data Integration | Joined orders, customers, order items, sellers, products, reviews, payments, and category translation tables using validated business keys |
| Data Modelling | Built a Power BI star schema with fact and dimension tables using Power Query |
| Analysis | Created DAX measures for GMV, leakage, retention, delivery, review, freight, and seller risk |
| Evaluation | Validated Power BI outputs against SQL checks and dashboard totals |
| Reporting | Produced interactive Power BI dashboards, BI Analysis Report, Project Brief, and GitHub README |

**Tools used**

| Tool | Purpose |
|---|---|
| MySQL | Data loading, profiling, cleaning, joining, validation, and analytical views |
| Microsoft Excel | Data Quality Issue Log |
| Power Query | Data transformation and star schema preparation |
| Microsoft Power BI | Data modelling, DAX measures, dashboard design, and analysis |
| GitHub | Project documentation and portfolio presentation |

**Data and Calculation Notes**

The analysis is based on the original nine-file Olist dataset. The transaction model is built primarily from orders, order items, customers, products, sellers, reviews, and category translation data.

All KPIs are calculated against **96,478 validated delivered orders** where `order_status = "delivered"`, unless otherwise stated.

The source order item table is at item grain. A single order can contain multiple item rows, so order-level KPIs use `DISTINCTCOUNT(order_id)` to avoid inflation.

All revenue figures in this report represent **Gross Merchandise Value (GMV)**: the total value of transactions processed through the platform. For delivered orders, Total GMV is calculated as `item_price + freight_value`. The dataset does not include commission rates, marketplace fee structures, or seller payout data, so Nexora’s actual net revenue cannot be calculated.

The GMV leakage rate is calculated as leakage product value divided by total GMV including leakage. Leakage value uses `item_price` from cancelled and unavailable orders. Freight is excluded from leakage value because it is treated as a pass-through customer-paid value rather than Nexora’s net revenue.

The retention denominator is **93,358**, representing customers with at least one delivered order. This is the commercial retention denominator because customers whose orders were never delivered had no completed transaction experience from which to return. The broader registered customer count is **96,096**.

Customer retention analysis splits returning customers into: customers with exactly two orders, exactly three orders, and four or more orders. Customers with exactly one delivered order are classified as one-time customers.

Review scores are not available for all delivered orders. Review-based KPIs are calculated against reviewed delivered orders only and are labelled as such in the dashboard.

Customer retention is measured using `customer_unique_id`, the stable cross-order customer identifier. The customer dimension was rebuilt during data preparation to enforce one row per `customer_unique_id` after duplicate customer records were identified.

The geolocation file contains multiple rows per zip code prefix. Where geolocation data is used, it must be aggregated before being used as a stable geographic lookup to avoid record duplication.

---

## Dashboard Deliverable

The Power BI dashboard contains five stakeholder-facing pages aligned to the business questions and analytical sections in this report.

| Dashboard Page | Purpose |
|---|---|
| Executive Summary — Commercial Health & Revenue Risk | Summarises GMV performance, retention risk, late delivery, review score, and leakage exposure |
| Revenue Performance & GMV Leakage Drivers | Explains GMV leakage, freight burden, and category-level commercial efficiency |
| Customer Retention & Lifetime Value | Analyses one-time customers, repeat customers, return timing, and customer value |
| Delivery Experience & Customer Satisfaction | Connects delivery performance to review scores and repeat purchase behaviour |
| Seller Portfolio & Commercial Risk | Segments sellers by value, delivery risk, review performance, and intervention priority |

---

## Key Findings

---

### Section 1: Executive Commercial Health

---

#### Insight 1: Nexora shows strong GMV growth, but commercial health is weakened by retention and fulfilment risk

**Finding:** Nexora generated strong marketplace activity across the operating period, but growth is not translating into sustainable customer value. The platform is producing transaction volume without the retention infrastructure to compound it.

**Evidence:** Total GMV reached R$15.42M against an R$18.0M target, a shortfall of R$2.58M. Customer retention is 2.9%, late delivery is 6.8%, and GMV leakage is R$97.24K. Average Order Value is R$159.8, broadly in line with the R$160 benchmark but slightly below target, confirming that the commercial problem is not driven by basket size alone. The larger issue is frequency and retention.

**Business Impact:** The platform is acquiring customers, processing their first order, and then losing them. With 97.1% of customers making only one purchase, Nexora is operating as a one-time transaction engine rather than a marketplace that builds compounding customer value. Every incremental investment in acquisition produces exactly one order before the relationship ends.

**Recommended Action:** Prioritise retention recovery and fulfilment improvement before scaling acquisition or seller growth. Adding more customers into a platform that retains 2.9% of them deepens the acquisition dependency without improving commercial sustainability.

---

#### Insight 2: Customer retention is the largest single commercial risk on the platform

**Finding:** The overwhelming majority of customers do not return after their first purchase. This is not a marginal retention gap. It is a near-complete absence of repeat purchase behaviour.

**Evidence:** Of 93,358 customers with at least one delivered order, only 2,801 returned for a second purchase, a retention rate of 2.9% against a 15% target. The customer order frequency breakdown is stark: 90,557 customers placed exactly one order, 2,573 placed two orders, 181 placed three orders, and 47 placed four or more. The tail of loyal customers is extremely thin.

**Business Impact:** This creates a leaking bucket problem in which Nexora must continuously acquire new customers simply to replace those who do not return, with no compounding return on prior acquisition spend. As customer acquisition cost rises with market maturity and competitive intensity, this model becomes increasingly expensive to sustain.

**Recommended Action:** Launch a first-to-second purchase conversion programme anchored to the 30-day post-delivery window. The programme should include automated post-purchase communication, personalised category recommendations, and targeted offers for high-GMV categories. The objective is to move the retention rate from 2.9% to at least 6% within 12 months without increasing acquisition spend.

---

### Section 2: Revenue Performance and GMV Leakage Drivers

---

#### Insight 3: Recorded GMV leakage is low at 0.6%, but it is concentrated in specific drivers and categories

**Finding:** GMV leakage is not a widespread platform problem. It is concentrated in identifiable failure modes that can be targeted through specific seller and category interventions.

**Evidence:** The GMV leakage rate is 0.6%, representing R$97.24K in committed revenue that was not converted to delivered orders. Within the 1,234 leakage events, cancelled order value is the larger component, with unavailable order value contributing a smaller share. Leakage is not evenly distributed across the catalogue.

**Business Impact:** Because leakage is concentrated rather than diffuse, Nexora does not need a platform-wide fix. Targeting the specific sellers and categories responsible for the highest leakage volume would recover the majority of the R$97.24K without broad operational disruption. The commercial case for intervention is strong: leakage revenue is recoverable, and each leakage customer represents a lost acquisition investment and a future order that will not happen.

**Recommended Action:** Segment all 1,234 leakage events by seller, category, and root cause. Identify whether leakage clusters around seller reliability failures, product availability gaps, or freight burden in specific categories. Issue performance notices to sellers with three or more leakage events and trigger a win-back communication to all 1,234 affected customers within two weeks.

---

#### Insight 4: Freight burden is a material pressure point in the revenue model

**Finding:** Freight cost is close to the risk threshold and is creating commercial pressure across the platform, with the potential to suppress conversion and repeat purchase rates in freight-heavy categories.

**Evidence:** The freight cost ratio is 14.3%, sitting inside but close to the 15% ceiling target. Average freight per order is R$22.79 against an average product price of R$120.65, putting freight at roughly 19 cents per dollar of product value. At platform level this looks manageable, but the average conceals significant variation. Low-ticket categories and geographically distant states will carry materially higher freight ratios that are not visible at platform level.

**Business Impact:** Freight is the customer's cost, not Nexora's. A customer spending R$20 on a product and R$22 on freight is experiencing a cost structure that is commercially unsustainable for the category. High freight burden suppresses conversion, reduces order frequency, and can make specific categories structurally uncompetitive against platforms with better logistics infrastructure or negotiated carrier rates.

**Recommended Action:** Segment freight cost ratio by product category and by customer state. Identify categories where freight exceeds 25% of transaction value and evaluate whether the seller base is appropriately located relative to the buyer base. For persistently high-freight categories, consider minimum product price thresholds for listing or freight subsidy models for high-volume sellers.

---

#### Insight 5: High freight burden and leakage risk tend to overlap in the same categories

**Finding:** Some product categories show both elevated freight cost ratios and higher leakage rates simultaneously, creating a compounded commercial risk that GMV alone does not surface.

**Evidence:** Leakage driver analysis shows categories clustering around higher freight ratios and above-average leakage rates. These categories may appear commercially attractive on a gross GMV basis but carry hidden inefficiency once freight pressure and fulfilment failure rates are factored in.

**Business Impact:** A category generating strong GMV but carrying a 25% freight ratio and elevated leakage is less commercially efficient than its headline revenue suggests. It is also likely delivering a weaker customer experience, with high delivery cost and higher failure rates combining to suppress repeat purchase. The platform cannot make informed category investment decisions without this visibility.

**Recommended Action:** Build a category efficiency scorecard that combines GMV, freight cost ratio, leakage rate, average review score, and seller reliability for each major product category. Use this framework to prioritise category development investment and to identify which categories require operational intervention before further growth.

---

### Section 3: Customer Retention and Lifetime Value

---

#### Insight 6: Nexora has a severe one-time customer problem that compounds with each new acquisition cohort

**Finding:** Most customers stop after one purchase. The platform has not built the conditions that convert first-time buyers into repeat marketplace users at any meaningful scale.

**Evidence:** 90,557 customers placed exactly one order and did not return. Of the small group who returned: 2,573 placed two orders, 181 placed three, and 47 placed four or more. The step-down between one order and two orders is the steepest drop in the customer journey. The platform is losing customers at precisely the point where commercial value begins to compound.

**Business Impact:** Customer lifetime value is capped at a single transaction for 97.1% of the customer base. The commercial value of each acquired customer is, in expectation, one order. This reduces every acquisition decision to a break-even calculation on a single transaction, which is not a viable marketplace economics model in a competitive and maturing market.

**Recommended Action:** Focus retention strategy on the transition between first and second order. This is where the decision to return or leave is made. The post-delivery window in the first 30 days is the highest-probability intervention point, supported by the data on return timing in Insight 8.

---

#### Insight 7: Repeat customers are few in number but commercially disproportionate in GMV contribution

**Finding:** Repeat customers represent a very small share of the customer base but generate a measurably larger share of platform GMV, confirming that retention investment has better unit economics than equivalent acquisition spend.

**Evidence:** Repeat customers account for 2.9% of customers with delivered orders but generate 4.7% of platform GMV — a 1.6x CLV ratio achieved with zero retention infrastructure in place. The ratio of GMV contribution to customer share demonstrates that returning customers place higher-value orders, purchase more frequently, and compound commercial output in ways that single-purchase customers structurally cannot.

**Business Impact:** At this CLV ratio, every percentage point improvement in retention delivers a greater than proportional lift in GMV. The platform does not need to double its customer base to materially improve revenue. It needs to convert a fraction of the 90,557 one-time customers into returning buyers. The commercial return on retention investment is demonstrably higher than the return on equivalent acquisition spend at current performance levels.

**Recommended Action:** Build targeted retention campaigns for customers who exhibit high-value first-order behaviour: higher basket value, purchase from high-GMV categories, or stronger first-order review scores. These customers are the most likely to generate above-average CLV if retained and should be prioritised in the first iteration of any post-purchase programme.

---

#### Insight 8: The strongest return window is the first 30 days. Delayed campaigns will miss the majority of returnable customers

**Finding:** Customers who return for a second purchase do so quickly. The largest returning cohort returns within the first 30 days after their initial order.

**Evidence:** 1,346 returning customers placed their second order within 0 to 30 days of their first, representing the single largest return band in the distribution. The median return window across all returning customers is 34 days. The average is 88 days, pulled upward by a long tail of customers who return much later. The practical implication: 50% of the customers who will ever return do so within 34 days, and the majority of the high-probability return window falls within the first month post-delivery.

**Business Impact:** A retention campaign triggered after 60 or 90 days post-purchase is too late for the majority of customers who were inclined to return. The intervention window is not the period when customers are thinking about coming back. It is the period before they have decided not to.

**Recommended Action:** Trigger automated post-purchase communications within 20 to 25 days of confirmed first delivery, before the 34-day median is crossed. The communication should reference the customer's purchase category, include a personalised product recommendation, and carry a time-limited incentive. Measure click-to-second-purchase conversion as the primary campaign KPI and report weekly cohort performance against the 34-day benchmark.

---

#### Insight 9: Customers who leave stronger reviews are measurably more likely to return

**Finding:** Review score is not only a satisfaction metric. It is a reliable signal of future purchase intention and a leading indicator of retention risk.

**Evidence:** Customers with 5-star reviews show the highest repeat purchase rate at 2.2%. Repeat purchase rates decline progressively across weaker review score bands. A customer who leaves a 1-star or 2-star review after their first order is, based on observed behaviour, functionally unlikely to place a second.

**Business Impact:** Low review scores are not only reputational damage. They are a direct signal that a customer has been lost. Every order that generates a 1 or 2-star review represents a customer whose probability of return has dropped to near zero. At scale, the platform's negative review rate is a forward-looking indicator of future retention performance, not only a backward-looking measure of past service quality.

**Recommended Action:** Route all orders generating a review score of 1 or 2 into a customer recovery workflow immediately after the review is submitted. The recovery communication should acknowledge the experience, offer a specific remedy, and include a time-limited incentive to purchase again. Track recovery campaign conversion rate and measure whether it changes the second-purchase rate among the low-review cohort.

---

### Section 4: Delivery Experience and Customer Satisfaction

---

#### Insight 10: Late delivery is a customer trust failure with a quantified impact on review scores

**Finding:** Late delivery produces a qualitatively different customer experience that is measurable in review data and directly connected to retention outcomes. This is not a logistics inconvenience. It is a commercial failure event.

**Evidence:** The platform late delivery rate is 6.8%, above the 5% ceiling. Orders delivered late receive an average review score of 2.27, compared to 4.29 for on-time orders. That is a 2.02-point gap on a 5-point scale. Late-delivery customers are not slightly less satisfied. They are experiencing a fundamentally different transaction than on-time customers, and their reviews reflect it.

**Business Impact:** Late delivery is associated with two compounding commercial risks: a customer who is far less likely to return, and a review score that suppresses future conversion from new customers browsing the same listings. The 6.8% late rate is not only a performance metric. It is a retention and acquisition risk that compounds across every affected cohort.

**Recommended Action:** Treat late delivery management as a commercial risk programme, not an operations programme. Monitor seller-level SLA compliance weekly. For orders flagged as at risk of late delivery based on seller historical performance, proactively communicate with the customer before the estimated delivery date rather than reactively after it passes.

---

#### Insight 11: Late delivery on a first order is associated with an 83% lower repeat purchase rate

**Finding:** Customers whose first order was delivered late are substantially less likely to place a second order. First-order delivery experience is the strongest predictor of retention in the dataset.

**Evidence:** Retention rate after an on-time first delivery is 2.9%. Retention rate after a late first delivery is 0.5% — an 83% lower repeat rate among the late-delivery cohort. This is an observed association from the dataset; controlled analysis would be required to establish causality. The directional signal is nonetheless strong and commercially significant: a poor first delivery experience is associated with near-complete loss of the customer relationship in a marketplace where 97% of customers were already not returning after even a good experience.

**Business Impact:** The platform's 6.8% late rate is not randomly distributed across all customer relationships. It falls disproportionately on first-time customers whose entire perception of Nexora is shaped by that single order. Improving delivery reliability for new customers specifically would have a greater impact on retention than an equivalent improvement across the full customer base.

**Recommended Action:** Prioritise first-order delivery reliability for new customers above all other fulfilment improvements. Introduce seller routing logic that steers new customer orders away from sellers with above-average late rates during the first-purchase window. For new customers who experience a late first delivery, trigger an immediate service recovery communication before they are prompted to review, including a clear explanation and a meaningful recovery offer.

---

#### Insight 12: Late delivery risk is geographically concentrated in a small number of states

**Finding:** Late delivery is not evenly distributed across Brazil. A small group of geographic hotspots is generating disproportionate fulfilment failure and carrying retention and satisfaction risk far above the platform average.

**Evidence:** Three states show late delivery rates dramatically above the 6.8% platform average: Alagoas at 21.4%, Maranhao at 17.4%, and Sergipe at 15.1%. These rates are two to three times the platform ceiling. The concentration suggests specific carrier performance failures, seller location mismatches, or infrastructure constraints rather than generalised platform-wide logistics weakness.

**Business Impact:** Customers in these states are receiving a materially worse delivery experience than customers in higher-served regions. Given the relationship between late delivery and retention demonstrated in Insight 11, the 0.5% retention rate after late delivery is likely even lower for customers in the highest-risk states. These geographies are creating disproportionate customer satisfaction and retention risk relative to their order volume.

**Recommended Action:** Investigate the three highest-risk states by seller location, carrier route performance, product category mix, and average delivery distance. Determine whether late delivery is driven by seller dispatch delays, carrier network gaps, or a combination. Consider restricting the seller pool available to buyers in these states to sellers with proven on-time performance in that geography, or surfacing delivery time expectations to customers at the point of purchase.

---

### Section 5: Seller Portfolio and Commercial Risk

---

#### Insight 13: Seller risk must be managed as a portfolio problem, not a case-by-case operational issue

**Finding:** Seller performance varies significantly across revenue contribution, delivery reliability, and customer review quality. Without a structured portfolio view, the platform cannot identify where commercial value is created and where it is destroyed.

**Evidence:** Of 3,095 registered sellers, 577 are classified as high-risk based on late delivery rate and review score performance. The platform late delivery rate of 6.8% and average review score of 4.08 are both below their respective targets. Both metrics are directly driven by the performance distribution of the seller base.

**Business Impact:** Poor seller performance does not damage only that seller's GMV. It damages the customer experience of every buyer who orders from them, reduces those customers' probability of returning to the platform, and generates review scores that suppress future conversion from new customers browsing those categories. The commercial spillover from underperforming sellers extends well beyond their individual transaction value.

**Recommended Action:** Implement a formal seller tiering framework with four action groups: protect (high GMV, strong performance), develop (moderate GMV, improvable performance), intervene (above-threshold late rate or review score), and review (below-minimum performance with formal improvement notice). Assign accountability for each tier to a named commercial or operations owner and report tier composition monthly to the CCO.

---

#### Insight 14: The top 4.98% of sellers generate 54% of seller GMV, creating concentrated commercial dependency

**Finding:** A small group of sellers contributes the overwhelming majority of commercial value. This concentration is a structural risk that the platform currently has no framework to monitor or protect against.

**Evidence:** The highest-performing 4.98% of sellers — roughly 150 sellers — account for approximately 54% of total seller GMV. In Lorenz curve terms, the platform's seller base is operating well inside the inequality boundary expected even from a healthy two-sided marketplace. The average GMV across all 3,025 active sellers is approximately R$5,100, but this figure is heavily distorted by the long tail of low-volume sellers. The majority of sellers generate marginal revenue relative to their presence on the platform.

**Business Impact:** If a disproportionate share of top-tier sellers reduces their activity, moves catalogue to a competing marketplace, or exits the platform, the GMV impact is not proportional to their headcount. The platform has no early warning mechanism for this risk. There is no account management, no commercial relationship programme, and no monitoring system that would flag a high-value seller beginning to disengage before the revenue impact appears in monthly GMV figures.

**Recommended Action:** Assign named commercial account managers to all top-tier sellers within 30 days. Conduct structured quarterly commercial reviews with each top-tier seller covering order volume trends, delivery performance, review scores, and growth opportunities. Establish a seller health score that tracks early-warning signals of disengagement, including declining order acceptance rates, rising late rates, and falling catalogue activity.

---

#### Insight 15: High-GMV sellers with weak service performance require priority commercial intervention

**Finding:** A subset of sellers combines meaningful GMV contribution with poor delivery reliability or review scores. These sellers present a dual exposure: removing them creates a revenue gap, but retaining them without intervention continues to damage customer retention and platform trust.

**Evidence:** The seller risk matrix identifies sellers in the High Value / High Risk quadrant: those with above-median GMV and late delivery rates or review scores that breach performance thresholds. These sellers are commercially significant enough that a standard enforcement approach carries revenue risk, but operationally damaging enough that passive retention carries retention and reputational risk.

**Business Impact:** The commercial trade-off for High Value / High Risk sellers cannot be managed with a one-size-fits-all policy. Applying the same performance notice process used for low-volume sellers to a top-tier seller with significant GMV dependency creates unacceptable revenue risk. Applying no consequence at all allows delivery failures and poor reviews to compound unchecked across a commercially important seller relationship.

**Recommended Action:** For sellers in the High Value / High Risk quadrant, assign a dedicated commercial account manager to co-develop a time-bound fulfilment improvement plan before any formal enforcement action is taken. Set specific performance targets, a monitoring cadence, and a defined escalation point at which enforcement applies if improvement is not demonstrated. This approach protects near-term GMV while creating a structured path toward sustainable performance.

---

## Recommendations

### Immediate Actions: Within 30 Days

| # | Action | Owner | Success Measure |
|---|---|---|---|
| 1 | Assign commercial account managers to all top-tier sellers. Establish quarterly review cadence for each relationship | Commercial Director | Top-tier sellers contacted and reviewed within 30 days |
| 2 | Issue performance improvement notices to all 577 high-risk sellers, with 60-day targets and defined escalation consequences. Late delivery is associated with retention falling from 2.9% to 0.5% and review scores from 4.29 to 2.27 — this cohort is the primary driver | Seller Operations | 100% of high-risk sellers contacted within 30 days; 60-day improvement plans in place for all High Value / High Risk sellers |
| 3 | For High Value / High Risk sellers, assign dedicated account managers and begin co-designed improvement plans before enforcement | Commercial Director | Improvement plans in place for all HV/HR sellers within 30 days |
| 4 | Classify all 1,234 leakage events by seller and root cause. Notify sellers with 3+ leakage events. Launch win-back campaign for all 1,234 affected customers | Seller Operations / CRM | Win-back campaign live within 14 days |
| 5 | Brief the CCO on the 2.9% retention rate and 0.5% post-late-delivery retention, and agree retention as highest-priority commercial programme | Chief Commercial Officer | Retention programme resourced and workplan agreed within 30 days |

### Short-Term Actions: 30 to 90 Days

| # | Action | Owner | Success Measure |
|---|---|---|---|
| 6 | Build automated post-purchase email trigger at day 20 to 25 after first delivery. Include category recommendation and time-limited incentive. Note: 1,346 customers returned within 30 days organically — that is the floor this programme must beat | CRM / Marketing | Click-to-second-purchase rate tracked; 34-day median used as benchmark |
| 7 | Route all 1-star and 2-star reviews into a customer recovery workflow immediately after submission | CRM / Customer Experience | Recovery conversion rate tracked; low-review second-purchase rate measured |
| 8 | Introduce seller routing logic that steers new customer orders away from sellers with above-average late rates | Platform Operations / Technology | First-order late rate for new customers tracked separately; improvement monitored monthly |
| 9 | Implement proactive customer communication for orders flagged at late-delivery risk, before the estimated delivery date | Operations / CRM | Customer satisfaction score for flagged orders tracked versus unflagged late orders |
| 10 | Segment freight cost ratio and leakage rate by category and state. Build category efficiency scorecard | Commercial Analytics | Scorecard delivered to CCO; high-risk categories identified and prioritised |

### Long-Term Actions: 90 Days and Beyond

| # | Action | Owner | Success Measure |
|---|---|---|---|
| 11 | Design and launch formal retention programme: loyalty incentive, category-based follow-up sequences, seasonal re-engagement calendar | Commercial Director / Marketing | Retention rate improves by at least 3pp within 12 months (from 2.9% to ≥6%) |
| 12 | Implement seller tiering framework (protect, develop, intervene, review) across all commercial and operations processes | Commercial Director / Seller Operations | All sellers classified; tier movement tracked monthly |
| 13 | Investigate high-risk states (Alagoas, Maranhao, Sergipe) by carrier, seller location, and category. Implement targeted carrier or seller routing improvements | Logistics / Operations | Late delivery rate in target states moves toward platform average within 6 months |
| 14 | Build category recovery framework using GMV, freight ratio, leakage rate, review score, and seller reliability per category | Commercial Analytics | Framework embedded in quarterly category planning cycle |
| 15 | Establish Power BI dashboards as the CCO's primary commercial review instrument within a weekly operational and monthly board reporting cycle | All commercial leads | Monthly KPI review cycle embedded within 60 days |

---

## Limitations, Assumptions, and Methodological Notes

| # | Note | Impact |
|---|---|---|
| 1 | All revenue figures represent GMV, not Nexora net platform revenue. The Olist dataset does not include seller commission rates. The CCO must apply internal commission rate data to convert all GMV and leakage figures into net revenue impact. | Critical |
| 2 | Observed associations between delivery performance and retention (2.9% on-time vs 0.5% post-late repeat rate) are correlational findings from this dataset. They are strong and directionally reliable but should not be treated as causal without controlled analysis. This caveat applies to all findings linking delivery status to review scores and repeat purchase behaviour. | Moderate |
| 3 | All revenue figures in the leakage analysis use item_price only, treating freight as a pass-through cost excluded from leakage calculations. The GMV leakage rate (0.6%) is calculated as leakage revenue divided by total GMV including leakage — this is the correct commercial denominator but is not directly comparable to a gross revenue leakage rate that includes freight. | Moderate |
| 4 | The retention denominator is 93,358 (customers with at least one delivered order), not 96,096 (all registered customers). Customers whose orders were never delivered had no transactional opportunity to return. Using 93,358 is the correct methodological choice for a commercial retention calculation. The headline figure of 96,096 is used for context only. | Methodological note |
| 5 | Review scores are not available for all delivered orders. Review-based KPIs (average review score, negative review rate, review score by delivery status) are calculated against reviewed orders only, not total delivered orders. | Moderate |
| 6 | The dim_customer table was rebuilt to resolve 122 duplicate customer_unique_id rows caused by customers placing orders from multiple states. The fix uses GROUP BY customer_unique_id with MAX(customer_state) and MAX(customer_city). Post-fix unique customer count of 96,096 is confirmed. | Low |
| 7 | The first quarter of the dataset (October to December 2016) reflects platform ramp-up rather than steady-state operations. Order volumes in this period are substantially lower than 2017 onward. Time-series trend analysis should exclude or flag this period to avoid ramp-up distortion. | Low |
| 8 | Seller tiering thresholds (Top, Mid, Tail) and the high-risk seller classification are analytical decisions defined for this project, not Nexora business rules. Thresholds are documented in the DAX measures file and are adjustable via slicers in the Power BI dashboard. | Low |
| 9 | The original Olist dataset is provided as nine separate CSV files. Joins across orders, customers, order items, sellers, products, payments, reviews, and category translation rely on correct use of business keys such as `order_id`, `customer_id`, `product_id`, and `seller_id`. | Moderate — incorrect joins could duplicate records or distort KPI outputs. |
| 10 | The geolocation dataset contains multiple rows per zip code prefix and cannot be joined directly to transaction-level data without aggregation. | Moderate — direct joins could inflate records or distort geographic analysis. |

---

## Appendix: KPI Reference Table

| Metric | Result | Target | Gap | Status |
|---|---|---|---|---|
| Total GMV | R$15.42M | R$18.0M | -R$2.58M | Red |
| Average Order Value | R$159.8 | > R$160 | -R$0.2 below benchmark | Amber |
| Customer Retention Rate | 2.9% | 15% | -12.1pp | Red |
| First-to-Second Purchase Rate | 2.9% | 25% | -22.1pp | Red |
| On-Time Delivery Rate | 93.2% | >= 95% | -1.8pp | Amber |
| Late Delivery Rate | 6.8% | <= 5.0% | +1.8pp above ceiling | Amber |
| Avg Review Score — All Delivered | 4.08 / 5.0 | 4.5 / 5.0 | -0.42 | Red |
| Avg Review Score — On-Time Orders | 4.29 / 5.0 | 4.5 / 5.0 | -0.21 | Amber |
| Avg Review Score — Late Orders | 2.27 / 5.0 | 4.5 / 5.0 | -2.23 | Red |
| Avg Fulfilment Days — On-Time | 10.9 days | <= 12 days | On target | Green |
| Avg Fulfilment Days — Late | 33.8 days | <= 12 days | +21.9 days | Red |
| Freight Cost Ratio | 14.3% | <= 15% | On target | Green |
| Average Freight per Order | R$22.79 | <= R$20 | +R$2.79 above benchmark | Amber |
| GMV Leakage Rate | 0.6% | <= 1% | On target | Signal |
| Leakage Revenue | R$97.24K | Minimise | Signal | Signal |
| Leakage Orders | 1,234 | Minimise | Signal | Signal |
| Retention after On-Time Delivery | 2.9% | 15% | -12.1pp | Red |
| Retention after Late Delivery | 0.5% | 15% | -14.5pp | Red |
| Repeat Customer GMV Share | 4.7% | Monitor | Disproportionate vs 2.9% headcount | Reference |
| High-Risk Sellers | 577 | ≤10% of registered sellers | +8.6pp above threshold | Red |
| Top-Tier Seller GMV Share | ~54% | Monitor | 4.98% of sellers | Reference |
| Revenue per Customer | ~R$165 | >= R$250 | -R$85 | Red |
| Cancellation Rate | < 0.01% | <= 2% | On target | Green |
| Median Days to Return | 34 days | Inform | Intervention window: day 20 to 25 | Reference |
| Average Days to Return | 88 days | Inform | Use median for campaign timing | Reference |
| Late Rate — Alagoas | 21.4% | <= 5% | +16.4pp above ceiling | Red |
| Late Rate — Maranhao | 17.4% | <= 5% | +12.4pp above ceiling | Red |
| Late Rate — Sergipe | 15.1% | <= 5% | +10.1pp above ceiling | Red |

**RAG key:** Green = at or above target. Amber = within 5 percentage points of target. Red = more than 5 percentage points below target. For lower-is-better metrics the RAG logic is inverted. Signal = metric is below the concern threshold but warrants monitoring; the leakage rate never receives Green status regardless of volume. Reference = informational metric with no RAG assignment.

---

*Analysis based on the publicly available Olist Brazilian E-Commerce Public Dataset from Kaggle, provided as nine source CSV files and modelled into an analysis-ready Power BI dataset. Final dashboard metrics are based on 96,478 validated delivered orders between October 2016 and August 2018. Nexora Commerce Ltd, stakeholder roles, and business context are fictionalised to simulate a real-world commercial analytics engagement.*