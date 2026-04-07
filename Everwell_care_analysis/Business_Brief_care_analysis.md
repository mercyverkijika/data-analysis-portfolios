# Care Delivery Performance & Regulatory Readiness Analysis  
### Everwell Care Services Ltd

**Role:** Data Analyst (End-to-End)  
**Status:** In Progress  
**Tools:** MySQL · Excel · Power BI  

---

## Business Context

Everwell Care Services Ltd is a domiciliary care provider delivering at-home support services to elderly and vulnerable adults across multiple branches in England.  

As the organisation scaled, leadership observed increasing **missed visits, inconsistent service delivery, and rising workforce costs**, raising concerns about both **operational efficiency** and **regulatory compliance** ahead of the next CQC inspection.

Under the CQC Single Assessment Framework, providers are evaluated across five key domains — **Safe, Effective, Caring, Responsive, and Well-Led** — and must demonstrate consistent, high-quality service delivery to maintain their rating and contracts.

---

## Problem Statement

The business lacked clear visibility into:

- Reliability of visit delivery (missed and late visits)  
- Workforce efficiency and staffing capacity  
- Alignment between commissioned and delivered care  
- Compliance performance across key regulatory areas  

This created risks to:

- **Client safety and care quality**  
- **CQC inspection outcomes**  
- **Local authority contracts and revenue stability**  
- **Operational cost control**  

---

## Objective

To analyse care visit and operational data in order to:

- Identify drivers of missed and late visits  
- Evaluate workforce utilisation and scheduling efficiency  
- Assess compliance performance against key regulatory indicators  
- Highlight areas of financial and operational risk  

The goal is to support **data-driven decision making** to improve both service delivery and inspection readiness.

---

## Scope of Analysis

The analysis focuses on three core areas:

### 1. Service Delivery Performance
- Visit completion and missed visit rates  
- Punctuality and lateness patterns  
- High-risk services and time periods  

### 2. Workforce Efficiency
- Staffing coverage vs demand  
- Indicators of scheduling inefficiency  
- Capacity constraints impacting service delivery  

### 3. Compliance & Quality Indicators
- Safeguarding and incident handling  
- Complaint patterns and resolution timelines  
- Alignment with CQC quality expectations  

---

## Key Business Questions

- What percentage of visits are completed, missed, or late?  
- Which branches, services, or time periods show the highest operational risk?  
- Are clients receiving the care hours they are commissioned for?  
- Where are staffing and scheduling inefficiencies impacting service delivery?  
- Which areas present the greatest risk to CQC compliance and inspection outcomes?  

---

## Key Metrics (KPIs)

| KPI                             | Definition                           | Business Relevance                    |
| ------------------------------- | ------------------------------------ | ------------------------------------- |
| Visit Completion Rate           | Completed Visits ÷ Scheduled Visits  | Core indicator of service reliability |
| Missed Visit Rate               | Missed Visits ÷ Scheduled Visits     | Direct risk to client safety          |
| Punctuality Rate                | On-Time Visits ÷ Completed Visits    | Measures service quality              |
| Late Visit Rate                 | Late Visits ÷ Completed Visits       | Operational inefficiency indicator    |
| Delivered vs Commissioned Hours | Delivered Hours ÷ Commissioned Hours | Service and revenue alignment         |
| Complaint Resolution Time       | Avg days to resolve complaint        | Responsiveness and quality            |
| Safeguarding Closure Rate       | Incidents closed within SLA          | Compliance with regulatory standards  |

---

## Methodology

This project follows a structured analytical workflow:

### Data Profiling (MySQL)
- Assessed dataset structure, completeness, and distributions  
- Identified data quality issues and structural limitations  

### Data Cleaning & Transformation (MySQL)
- Standardised visit outcomes and key fields  
- Resolved invalid values and inconsistencies  
- Generated derived fields (care level, service type, visit metrics)  

### Data Quality & Validation (Excel)
- Logged identified issues and applied fixes  
- Performed reconciliation checks to ensure data accuracy and consistency  

### Data Modelling (Power BI)
- Built a star schema model linking visits, clients, and operational dimensions  
- Created reusable measures for KPI calculation  

### Analysis & Visualisation (Power BI)
- Developed an interactive dashboard with branch-level and service-level insights  
- Designed for both operational and management-level decision making  

---

## Data Overview

- **77,250 care visit records**  
- Time period: **Jan 2024 – Dec 2025**  

Simulated source tables include:
- Visit records  
- Client data  
- Incident and complaint logs  
- Training and compliance indicators  

---

## Data Limitations

- The dataset was adapted from appointment-based data and transformed to simulate a domiciliary care environment  
- Visit times, service types, and workforce-related attributes were generated to reflect realistic operational patterns  
- Some compliance metrics are approximations due to the absence of fully integrated real-world systems  

These limitations are acknowledged and considered when interpreting results.

---

## Expected Outcomes

This analysis is designed to:

- Highlight key operational weaknesses affecting service delivery  
- Identify areas of compliance risk ahead of inspection  
- Provide actionable insights to improve efficiency and reliability  
- Support leadership in prioritising operational improvements  

---

## Dashboard

📊 Interactive Power BI dashboard will be linked upon completion  

---

## Key Findings

🔒 Analysis in progress — findings will be published upon completion  

---

*Last updated: March 2026*

*Note: This is a simulated case study based on synthetic data and a fictional care provider.*