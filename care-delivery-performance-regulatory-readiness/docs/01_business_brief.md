# Project Brief
## Care Delivery Performance & CQC Regulatory Readiness Analysis — Everwell Care Services Ltd
**Document Type:** Project Brief 

---

As a data analyst on this project, I've seen how small data gaps can turn into real problems for clients and teams. Missed visits don't just mean paperwork issues—they affect vulnerable people who rely on consistent care. This brief outlines the analysis for Everwell Care Services Ltd, focusing on identifying risks and improving readiness for the next CQC inspection.

## 1. Company Overview

Everwell Care Services Ltd is a UK-registered domiciliary care provider delivering at-home personal care, medication administration, dementia support, palliative care, and companionship services to elderly and vulnerable adults across 25 service areas in the Southampton region.

The business model relies on four main funding streams: local authority commissions through council social services, NHS funding for complex clinical needs, client-managed budgets from the local authority, and private payments from self-funded clients.

## 2. Business Context

As Everwell scaled its operations, leadership observed three converging problems:

- Rising missed visits—clients not receiving their scheduled care
- Inconsistent service delivery—significant variation in quality across areas and care rounds
- Rising workforce costs—without corresponding improvement in care output

These observations raised concerns about both operational efficiency and regulatory compliance ahead of the next CQC inspection. The organization lacked the data infrastructure to understand the scale of these problems, identify their root causes, or demonstrate improvement to commissioners and regulators.

Under the CQC Single Assessment Framework, providers are assessed across five key domains:

- Safe: Are people protected from abuse and avoidable harm?
- Effective: Does care achieve good outcomes?
- Caring: Are staff kind, respectful, and dignified?
- Responsive: Are services organised to meet people's needs?
- Well-Led: Is leadership effective and governance robust?

Failure to demonstrate compliance across these domains risks enforcement action, reputational damage, loss of local authority contracts, and ultimately loss of registration.

## 3. Problem Statement

The organization lacked clear visibility into:

- Reliability of visit delivery (missed and late visits)  
- Workforce efficiency and staffing capacity  
- Alignment between commissioned and delivered care  
- Compliance performance across key regulatory areas  

This created risks to:

- Client safety and care quality  
- CQC inspection outcomes  
- Local authority contracts and revenue stability  
- Operational risk 

## 4. Business Questions

The following five questions were defined as the primary drivers of the analysis:

> **BQ1:** What percentage of visits are completed, missed, or delivered short of the commissioned duration?

> **BQ2:** Which areas, care categories, or time periods show the highest operational risk?

> **BQ3:** Are clients receiving the care hours they are commissioned for—and what is the financial cost of the gap?

> **BQ4:** Where are staffing and scheduling inefficiencies impacting service delivery?

> **BQ5:** Which areas present the greatest risk to CQC compliance and inspection readiness?

## 5. Objectives

This analysis is commissioned to achieve four specific outcomes:

1. Identify the drivers of missed and late visits
2. Evaluate workforce utilisation and scheduling efficiency
3. Assess compliance performance against key regulatory indicators
4. Highlight areas of operational risk
   
The overarching goal is to enable data-driven decision making that improves both service delivery and CQC inspection readiness.

## 6. Scope of Analysis

The analysis covers three core pillars:

### Pillar 1 — Service Delivery Performance

| Analytical Area       | Measures                                                                   |
| --------------------- | -------------------------------------------------------------------------- |
| Visit completion      | Visit Completion Rate, Missed Visit Rate, Short Visit Rate                 |
| Care delivery         | Care Delivery Rate, Commissioned Hours, Delivered Hours, Undelivered Hours |
| Punctuality           | Punctuality Rate, Late Arrival Rate, Arrival Status distribution           |
| Time and day patterns | Completion rate by care round and day of week                              |
| Category performance  | Delivery rate by care category                                             |
| Missed visit drivers  | Missed visit reasons, Missed Reason Category                               |

### Pillar 2 — Workforce Efficiency

| Analytical Area       | Measures                                                       |
| --------------------- | -------------------------------------------------------------- |
| Utilisation           | Utilisation Rate, Carer Hours Worked                           |
| Workload distribution | Visits per Carer, workload range across 65 carers              |
| Travel efficiency     | Avg Travel Time, Travel Time Ratio (travel as % of field time) |
| Continuity            | Continuity Rate, named carer consistency                       |
| Capacity vs demand    | Accountable Visits vs Missed Visits by day of week             |
| Cost                  | Actual Labour Cost, Planned Labour Cost, Cost Variance         |

### Pillar 3 — Compliance & Quality Indicators

| Analytical Area | Measures                                                                                                        |
| --------------- | --------------------------------------------------------------------------------------------------------------- |
| Safeguarding    | Safeguarding Flags Original, Safeguarding Flags Derived, Safeguarding Process Gap, Safeguarding Compliance Rate |
| Medication      | Medication Recording Rate                                                                                       |
| Incidents       | Incident Rate, Clinically Significant Notes                                                                     |
| Documentation   | Carer Notes Completion Rate, Alert Compliance Rate, Data Quality Score                                          |
| Client welfare  | Mood Recording Rate, Positive/Negative Mood Rate, Client Refusals                                               |
| Data governance | Travel Data Quality                                                                                             |

## 7. KPIs and Targets

All KPIs are measured against the accountable visit population—visits where Everwell had operational control (`valid_visit_flag = 1`, `accountability_flag = "Organisational"`).

| #   | KPI                          | Formula                                 | Target   |
| --- | ---------------------------- | --------------------------------------- | -------- |
| 1   | Visit Completion Rate        | Completed Visits ÷ Accountable Visits   | ≥ 95%    |
| 2   | Missed Visit Rate            | Missed Visits ÷ Accountable Visits      | ≤ 2%     |
| 3   | Short Visit Rate             | Short Visits ÷ Accountable Visits       | ≤ 3%     |
| 4   | Care Delivery Rate           | Delivered Hours ÷ Commissioned Hours    | ≥ 95%    |
| 5   | Punctuality Rate             | On-Time Arrivals ÷ Accountable Visits   | ≥ 90%    |
| 6   | Utilisation Rate             | Delivered Hours ÷ Total Field Hours     | ≥ 90%    |
| 7   | Continuity Rate              | Continuity Visits ÷ Accountable Visits  | ≥ 95%    |
| 8   | Travel Time %                | Total Travel Time ÷ Total Field Time    | ≤ 25%    |
| 9   | Avg Travel Time              | Average travel minutes per visit        | ≤ 15 min |
| 10  | Safeguarding Compliance Rate | Flags Original ÷ Flags Derived          | ≥ 98%    |
| 11  | Medication Recording Rate    | Medication Recorded ÷ Medication Visits | ≥ 98%    |
| 12  | Incident Rate                | Incidents Reported ÷ Accountable Visits | ≤ 2%     |
| 13  | Data Quality Score           | Complete Records ÷ Accountable Visits   | ≥ 95%    |
| 14  | Carer Notes Completion Rate  | Notes Completed ÷ Accountable Visits    | ≥ 90%    |
| 15  | Alert Compliance Rate        | Alerts Sent ÷ Accountable Visits        | ≥ 90%    |

### RAG Thresholds

| Status  | Description                                |
| ------- | ------------------------------------------ |
| Green | At or above target                         |
| Amber | Within 5 percentage points below target    |
| Red   | More than 5 percentage points below target |

For metrics where lower is better (Missed Visit Rate, Short Visit Rate, Incident Rate, Travel Time %), RAG logic is inverted.

## 8. Dataset

| Attribute   | Detail                          |
| ----------- | ------------------------------- |
| Source file | `caregivers_station_visits.csv` |
| Raw records | 77,250 rows                     |


## 9. Methodology

This project follows a structured analytical workflow, leveraging key tools to ensure robust data handling and insights:

### Data Profiling (MySQL)
- Used SQL queries to assess dataset structure, completeness, and distributions  
- Identified data quality issues and structural limitations  

### Data Cleaning & Transformation (MySQL)
- Applied SQL scripts to standardise visit outcomes and key fields  
- Resolved invalid values and inconsistencies  
- Generated derived fields (care level, service type, visit metrics)  

### Data Quality & Validation (Excel)
- Logged identified issues and applied fixes using spreadsheets  
- Performed reconciliation checks to ensure data accuracy and consistency  

### Data Modelling (Power BI)
- Built a star schema model linking `fact_visits` to dimensions  
- Created reusable measures for KPI calculation and interactive dashboards

This brief sets the stage for actionable insights. Once the full analysis is delivered, I recommend prioritizing the high-risk areas. Let's discuss next steps.
