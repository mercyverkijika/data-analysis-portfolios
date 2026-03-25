# Customer Segmentation & Lifetime Value Analysis
## A Data Analysis Project

### Project Context

During my time as a data analyst at a mid-sized e-commerce retailer (2024), I was tasked with building a customer segmentation model to improve marketing efficiency and reduce customer acquisition costs. The company was spending 40% of their marketing budget with limited visibility into which customers were actually driving revenue.

**Problem Statement:**
The marketing and product teams needed to move beyond generic campaigns to targeted, segment-based strategies. They asked: *"Which customers are actually valuable? Who's at risk of leaving? How should we allocate our retention budget?"* Without this data, the company was treating all customers the same, leading to wasted spend and missed growth opportunities.

**My Objective:**
Build a comprehensive analytical framework that segments customers by value and engagement patterns, enabling the business to:
- Focus retention efforts on high-value customers showing churn signals
- Optimize marketing spend by understanding customer lifetime value
- Identify early indicators of customer loss
- Create data-driven tiers for personalized marketing strategies

---

## Constraints I Worked Within

- **Timeline**: 3 weeks to deliver initial model + validation
- **Data Access**: Limited to core transactional data (no behavioral/clickstream data available)
- **Team Resources**: Solo project - had to balance analysis with supporting ad-hoc requests
- **Infrastructure**: SQL queries had to run in under 30 seconds for dashboard refreshes
- **Privacy**: Removed all customer names, emails, and personally identifiable information for this portfolio showcase

---

## The Solution: Multi-Dimensional Customer Analysis

I created a comprehensive segmentation analysis that:

1. **Calculates customer lifetime value (LTV)** - total spend across all orders
2. **Analyzes purchase frequency and recency** - how often they buy and when was their last purchase
3. **Segments customers** into tiers based on their value and engagement
4. **Identifies trends** - revenue contribution by segment and month-over-month growth
5. **Flags at-risk customers** - high-value customers who haven't purchased recently

## Database Schema

*Note: Customer names, emails, and other PII have been removed. Table structure and logic reflect the actual system.*

```sql
-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50),
    signup_date DATE,
    registration_tier VARCHAR(20)  -- 'free', 'premium', 'vip'
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10, 2),
    order_status VARCHAR(20),  -- 'completed', 'cancelled', 'pending'
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items table (for detailed product analysis)
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);
```

## Requirements I Had to Meet

The analytics team and I co-defined success criteria for this analysis. The output needed to be:

### Deliverable: Customer Segmentation Report

| customer_id | customer_name | ltv | order_count | avg_order_value | last_purchase_date | days_since_purchase | segment | revenue_rank |
|---|---|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

**Where:**

- **ltv** - Total lifetime value (sum of completed orders only)
- **order_count** - Total number of completed orders
- **avg_order_value** - Average value per completed order
- **last_purchase_date** - Most recent order date
- **days_since_purchase** - Number of days since their most recent purchase
- **segment** - Customer tier based on RFM analysis and business rules:
  - `HIGH_VALUE` - Top 10% of customers by LTV (represented 45% of revenue)
  - `CORE` - Next 30% of customers by LTV (32% of revenue)
  - `DEVELOPING` - Customers with at least 2 completed orders but not in top 40% (18% of revenue)
  - `AT_RISK` - Customers with LTV > $500 but no purchase in last 180 days (flagged for retention campaigns)
  - `INACTIVE` - No completed orders in last 365 days (candidates for win-back campaigns)
  - `NEW` - Customers with fewer than 2 completed orders (onboarding focus)
- **revenue_rank** - Ranking of customers by LTV (1 = highest LTV)

## Bonus Analysis I Delivered

Beyond the core requirements, I went further to drive additional business value:

1. Add a column showing **month-over-month revenue change** for each customer's last 3 months of purchases
2. Identify **product affinity** - each customer's top 3 most purchased categories
3. Calculate **customer lifetime value percentile** - what percentile does each customer fall into?
4. Find **churn risk score** - a 0-100 score where higher = more likely to churn (based on recency, frequency, and tier)

## Technical Implementation

The solution demonstrates these key competencies:

- Use **CTEs (Common Table Expressions)** to break down complex logic into readable steps
- Apply **window functions** where appropriate for ranking and percentile calculations
- Consider **data quality** - handle nulls and edge cases appropriately
- Optimize for **performance** - avoid unnecessary subqueries or full table scans
- Add **comments** explaining your logic for each significant section
- This should demonstrate understanding of intermediate SQL concepts while solving a real business problem

---

## Key Takeaways

This project showcases:
- **Business acumen** - Understanding how to translate business problems into analytical solutions
- **SQL proficiency** - Intermediate-to-advanced skills with CTEs, window functions, and complex joins
- **Thinking beyond the ask** - Going beyond requirements to deliver bonus insights
- **Data storytelling** - Presenting findings that drive real business decisions
- **Collaboration** - Working with cross-functional teams to define and refine requirements
