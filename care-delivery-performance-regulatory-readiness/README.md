# 🏥 Care Delivery & CQC Regulatory Readiness Analysis — Everwell Care Services Ltd



## 📋 Project Background

Everwell Care Services Ltd is a UK-registered domiciliary care provider delivering at-home personal care, medication administration, dementia support, palliative care, and companionship services to elderly and vulnerable adults across 25 service areas in the Southampton region. The organisation operates under the regulatory oversight of the Care Quality Commission (CQC) and is subject to the CQC Single Assessment Framework, under which providers are assessed across five key domains: Safe, Effective, Caring, Responsive, and Well-Led.

As the analyst embedded in this project, the business model was reviewed in full: Everwell generates revenue through local authority contracts, NHS Continuing Healthcare (CHC) funding, direct payments, and private arrangements. The organisation employs **65 carers** delivering care to **499 active clients**, with service demand distributed across four care rounds — Morning, Lunchtime, Tea-Time, and Bedtime/Night — seven days a week.

Leadership commissioned this analysis following observable increases in missed visits, inconsistent service delivery, and rising workforce costs — all of which raised concerns about operational efficiency and CQC inspection readiness. The goal was to move from anecdotal observation to data-driven evidence: to quantify what was going wrong, identify where and why, and provide an actionable path to improvement.

Insights and recommendations are provided on the following key areas:

- 🚑 **Service Delivery Performance** — Visit completion, missed visits, short visit rates, and care delivery against commissioned hours
- 👥 **Workforce Efficiency** — Carer utilisation, workload distribution, travel burden, continuity of care, and weekend coverage
- ✅ **Care Quality & CQC Compliance** — Safeguarding compliance, medication recording, incident rates, documentation quality, and data governance
- 💷 **Operational Risk & Financial Exposure** — Cost variance between planned and delivered care, financial impact of missed and short visits, and contractual risk

---

📂 The SQL queries used to load, profile, and clean the data for this analysis can be found **[here](#)**

📂 Targeted SQL queries addressing specific business questions during the profiling phase can be found **[here](#)**

📊 The interactive Power BI dashboard used to report and explore operational trends can be found **[here](#)**

---

## 🗄️ Data Structure & Initial Checks

The project database `domicilairy_care_services` was built in MySQL and consists of four tables derived from a single source CSV file after profiling, cleaning, and dimensional modelling. The raw data comprised **77,250 records**; after deduplication, **75,000 validated visit records** were loaded into the star schema. The total accountable visit population — visits within the organisation's operational control — is **68,973**.

| Table         | Rows   | Description                                                                                                                                                                                                                                                                  |
| ------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `fact_visits` | 75,000 | Central transactional table. One row per care visit. Contains 29 columns covering scheduling, timing, duration, status, carer notes, medication records, safeguarding flags, travel data, continuity flags, and all derived analytical columns. Source for all KPI measures. |
| `dim_client`  | 499    | One row per unique client. Holds demographics (gender, age group, date of birth), geographic attributes (postcode, area name), clinical attributes (primary condition, care category), and funding type. Age calculated dynamically from date of birth.                      |
| `dim_carer`   | 65     | One row per unique carer. Holds carer ID and name. Primary lookup for all workforce analysis.                                                                                                                                                                                |
| `dim_date`    | 731    | Generated date dimension covering 1 Jan 2024 – 31 Dec 2025. Columns include date key, full date, day of week, week number, month name, quarter, year, weekend flag, bank holiday flag, and month-year sort key. Enables all time intelligence in Power BI.                   |

**Entity Relationship Diagram**

```
dim_client (client_id) ──────< fact_visits >────── dim_carer (carer_id)
                                    │
                              dim_date (Date)
```

All relationships are single-direction, one-to-many from dimension to fact table.

---

## 📊 Executive Summary

### Overview of Findings

Everwell Care Services Ltd is not inspection-ready. Across 68,973 accountable visits delivered between January 2024 and December 2025, the organisation achieved a **Visit Completion Rate of 57.65%** and a **Care Delivery Rate of 59.69%** — both less than two-thirds of the 95% target set by commissioners and the CQC.

Below is the overview page from power bi dashbaord. other examples are included through out this report. the entire intereactive dashboard can be seen **[here](#)**

The three most important findings are:

> **1.** More than 40% of all accountable visits were either missed entirely (14.80%) or delivered short of the commissioned duration (27.55%), leaving clients routinely without their full care.

> **2.** 52% of welfare concerns identified in carer notes were never formally escalated as safeguarding alerts, creating both a statutory compliance failure and direct client safety risk.

> **3.** Carers are spending 37.88% of their total field time travelling rather than delivering care — a structural scheduling inefficiency driving short visits, late arrivals, and carer overload across all 25 service areas.


*Requires external validation — see Assumptions and Caveats*

---

## 🔍 Insights Deep Dive

### Service Delivery Performance

**1. Visit completion is 37 percentage points below target and has shown no meaningful improvement across 24 months.**

The Visit Completion Rate of 57.65% against a ≥95% target represents a gap that has remained consistent from January 2024 through December 2025. Monthly trend data shows Care Delivery Rate oscillating between approximately 54% and 62% with no upward trajectory. The absence of any improving trend across two full years indicates this is not a temporary performance dip — it is an embedded structural failure requiring operational redesign rather than incremental management.

**2. 27.55% of visits are short, making call clipping the largest single driver of undelivered care.**

The Short Visit Rate of 27.55% — nearly 1 in 3 visits — means carers are routinely leaving before the commissioned visit end time. Combined with the 14.80% missed visit rate, over 40% of all accountable visits are either absent or incomplete. The Care Delivery Rate of 59.69% confirms the scale: of approximately 38,000 commissioned hours, roughly **15,000 hours were not delivered** as specified. This is the primary exposure to commissioner clawback and CQC enforcement action.

**3. Palliative Care is delivering at only 36.29% — a 35 percentage-point gap versus Medication Administration at 71.62%.**

| Care Category             | Delivery Rate |
| ------------------------- | ------------- |
| Medication Administration | 71.62%        |
| Personal Care             | 67.55%        |
| Dementia Care             | 51.90%        |
| Companionship / Wellbeing | 51.69%        |
| **Palliative Care**       | **36.29%**    |

Palliative Care accounts for approximately 2,500 under-delivered hours — the joint highest of any category alongside Dementia Care. These clients are approaching end of life with complex, time-sensitive care needs. A delivery rate below 40% for this cohort represents the most serious patient safety risk in the dataset.

**4. The Bedtime/Night Round has the lowest completion rates across every day of the week, reaching as low as 23.46% on Monday nights.**

| Round                     | Monday     | Saturday   | Sunday     |
| ------------------------- | ---------- | ---------- | ---------- |
| Morning Round             | 61.94%     | 58.72%     | 59.88%     |
| Lunchtime Round           | 57.50%     | 54.54%     | 54.90%     |
| Tea-Time Round            | 60.50%     | 59.83%     | 59.17%     |
| **Bedtime / Night Round** | **23.46%** | **32.93%** | **46.12%** |

The Bedtime/Night Round is chronically understaffed. This is the period of highest vulnerability for clients — bedtime medication, comfort positioning, and overnight safety checks are all at risk when completion rates fall below 25%.

---

### Workforce Efficiency

**1. Carers spend 37.88% of field time travelling — 12 percentage points above the ≤25% target.**

| Area      | Care Time | Travel Time |
| --------- | --------- | ----------- |
| Bitterne  | 62.73%    | 37.27%      |
| Hedge End | 61.49%    | 38.51%      |
| Shirley   | 62.85%    | 37.15%      |
| Millbrook | 63.30%    | 36.70%      |
| Bassett   | 63.75%    | 36.25%      |

The uniformity across geographically different areas is the critical signal — this is not a localised routing problem, it is a scheduling architecture problem. Carers are not working within defined geographic zones and are spending approximately 22 minutes of every working hour driving rather than delivering care.

**2. Carer workload ranges from 162 to 826.6 average hours — a five-fold difference — creating fragile operational capacity.**

A small cohort of high-volume carers at 600–800 average hours are managing 1,500–2,000 visits each. When these individuals take sick leave — already the second-largest documented reason for missed visits at approximately 1,700 instances — the impact on the rota is disproportionately large. The organisation's operational resilience is concentrated in a small number of individuals, creating a fragile and unsustainable structure.

**3. Weekend missed visits are structurally higher than weekday, with Saturday and Sunday showing approximately 1,600–1,700 missed visits versus 1,300–1,400 on weekdays.**

The organisation is scheduling the same volume of visits at weekends (~9,700–8,800 accountable visits) with fewer available carers, resulting in a service that is materially less reliable on the two days when supervisory cover is also lowest. The CQC explicitly assesses whether quality is maintained at weekends.

**4. The Continuity Rate of 68.5% means nearly 1 in 3 visits involves an unfamiliar carer.**

For the 13,021 Dementia Care visits in the dataset, continuity of carer is not a quality preference — it is a clinical need. An unfamiliar carer visiting a dementia client causes genuine distress and increases the risk of missed welfare observations. Low continuity is a direct consequence of the geographic scheduling failure identified above.

---

### Care Quality & CQC Compliance

**1. Safeguarding Compliance Rate is 48% — 52% of welfare concerns identified in carer notes were never formally escalated.**

| Area                | Safeguarding Compliance |
| ------------------- | ----------------------- |
| Hythe               | 37.50%                  |
| Netley              | 40.91%                  |
| Hamble              | 42.00%                  |
| Thornhill           | 42.15%                  |
| St Denys            | 42.19%                  |
| Chandlers Ford      | 43.55%                  |
| **All Areas Total** | **48.00%**              |

The safeguarding compliance trend oscillates between 30% and 50% across the full 24-month period with no improvement. Every visible area performs below 45%. Carer notes containing references to bruising, falls, medication errors, cold homes, and social isolation are being documented but never converted into formal safeguarding referrals. This is a statutory failure under the Care Act 2014.

**2. The Incident Rate of 3.89% is almost double the ≤2% target, and the trend is flat across 2024 and 2025.**

Visit volumes with carer notes run at 3,000–4,500 per month throughout both years, while the incident rate holds at approximately 3.5–4.5%. The flat trend signals that the early intervention mechanism — identifying welfare concerns in notes before they become incidents — is not functioning. The safeguarding process failure and the elevated incident rate are directly connected.

**3. The Data Quality Score is 69.09% — documentation gaps exist in approximately 1 in 3 completed visits.**

| Metric                 | Rate    |
| ---------------------- | ------- |
| Data Quality Score     | 69.09%  |
| Carer Notes Completion | 73.17%  |
| Alert Compliance       | 73.22%  |
| Mood Recording Rate    | ~89.00% |

Both Carer Notes Completion and Alert Compliance sit at approximately 73%, flat across the entire reporting period. Where notes are absent, the organisation cannot evidence to a CQC inspector that care was delivered, welfare was monitored, or concerns were acted upon.

**4. Medication Recording Rate is 100%, but this requires validation against the source care management system.**

The 100% rate is the single metric meeting its target on the CQC dashboard. However, if the care management system enforces medication entry for visits classified as medication visits, the rate may reflect system logic rather than genuine clinical recording. Until confirmed, this metric should not be used as standalone evidence of compliance in an inspection context.

---

### Operational Risk & Financial Exposure

**1. The cost variance between planned and actual labour is -£129,514, representing care commissioned but not delivered.**

|                     | Amount        |
| ------------------- | ------------- |
| Planned Labour Cost | £481,737      |
| Actual Labour Cost  | £352,223      |
| **Cost Variance**   | **-£129,514** |

This is not a saving — it is undelivered care that was commissioned and expected by clients and commissioners. The gap reflects the financial consequence of 14.80% missed visits and 27.55% short visits combined.

**2. Approximately 4,100 missed visits (~40% of all missed visits) have no documented reason.**

| Reason             | Count  |
| ------------------ | ------ |
| No reason provided | ~4,100 |
| Carer sickness     | ~1,700 |
| Vehicle breakdown  | ~900   |
| No carer available | ~900   |
| Traffic delay      | ~900   |
| Carer running late | ~900   |
| Weather conditions | ~900   |

Without a documented reason, the organisation cannot distinguish preventable workforce failures from uncontrollable external events, cannot build an evidence-based improvement plan, and cannot respond credibly to commissioner or CQC enquiries.

**3. All 25 service areas show completion rates between 54.4% and 64.9% — no area is meeting the 95% target.**

| Area           | Care Delivery Rate |
| -------------- | ------------------ |
| Swaythling     | 58.81%             |
| West End       | 58.35%             |
| Shirley        | 57.59%             |
| Chandlers Ford | 57.06%             |
| Fair Oak       | 56.92%             |
| Millbrook      | 56.91%             |
| Ocean Village  | 56.07%             |
| Netley         | 55.00%             |

The narrow 10 percentage-point band across areas confirms this is a system-wide failure. There is no internal best-practice area from which to draw lessons — the improvement must come from structural change at the organisational level.

**4. Utilisation Rate of 62.12% confirms the workforce is operating at less than two-thirds of its productive potential.**

For every hour of available carer time, only 37 minutes is converted into delivered care. The remaining time is absorbed by travel (37.88% of field time), administrative gaps, and undelivered visits — a financial inefficiency and a capacity constraint operating simultaneously.

---

## 💡 Recommendations

Based on the insights and findings above, the Senior Leadership Team and Registered Manager are recommended to consider the following:

**1. Address the safeguarding process failure immediately — 52% of welfare concerns were never formally escalated.**
The Designated Safeguarding Lead should audit all visits with clinically significant carer notes and no corresponding formal safeguarding flag. Any historical concerns requiring escalation to the local authority safeguarding team should be referred without delay. All 65 carers should complete mandatory safeguarding recognition refresher training within 30 days. The care management system should be configured to prompt a formal referral consideration when welfare-related keywords are detected in note content.

**2. Make missed visit reason recording mandatory — 40% of missed visits currently have no documented reason.**
The care management system should be configured so that no visit can be closed as missed without a reason selected. A target of reducing undocumented missed visits to below 5% within 60 days should be set and reviewed weekly. A same-day escalation process should be introduced: any missed visit with no reason assigned within four hours should trigger a supervisor alert.

**3. Treat Palliative Care as a clinical priority — delivery at 36.29% is a patient safety risk.**
The Registered Manager and clinical leads should be briefed immediately. A review of all current palliative care clients should be conducted to assess whether planned visit durations remain appropriate. A ring-fenced cohort of senior carers with specialist experience should be designated for this category, and palliative care visits should be the last to be shortened or reassigned under rota pressure.

**4. Implement geographic zoning to address the 37.88% travel time ratio.**
A pilot in Bitterne and Hedge End — the two highest-volume areas — should assign each carer to a defined cluster of 2–3 adjacent areas per shift. The target is to reduce Travel Time % from 37.88% toward ≤30% within 90 days, releasing an estimated 680 additional care hours per month for client delivery. This change is expected to have cascading positive effects on short visit rates, punctuality, and continuity.

**5. Establish dedicated weekend staffing — weekend missed rates are structurally higher than weekday.**
A dedicated weekend care team with guaranteed weekend-contracted hours should be established, alongside an on-call weekend coordinator with authority to arrange emergency cover. The target is to bring the weekend missed visit rate within 2 percentage points of the weekday rate within 90 days. Weekend performance should be tracked separately in board-level reporting.

---

## ⚠️ Assumptions and Caveats

Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

**Caveat 1 — Medication Recording Rate of 100% requires external validation. Impact: Moderate.**
If the care management system enforces medication entry for visits flagged as medication visits, the 100% rate may reflect system configuration rather than genuine clinical recording practice. Until confirmed against the source system, this metric is not recommended for use as standalone evidence of compliance in an inspection or commissioner context.

**Caveat 2 — Ambiguous date formats were resolved using UK convention. Impact: Low.**
Three columns (scheduled_date, actual_clock_in, actual_clock_out) contained a mixture of YYYY-MM-DD, DD/MM/YYYY, and MM/DD/YYYY within the same field. For dates where the day or month portion exceeded 12, the format was unambiguous. For fully ambiguous dates where both parts were 12 or below, the UK convention of DD/MM/YYYY was applied. A small number of these dates may have been parsed incorrectly, but the volume is insufficient to materially change the direction of any finding.

**Caveat 3 — visit_status_derived is a derived column and underpins every KPI. Impact: High.**
The original visit_status field contained 34 inconsistent variants and demonstrably misattributed statuses relative to documented missed visit reasons. The correct status logic derives each visit's true outcome from actual_duration_mins, planned_duration_mins, and missed_visit_reason using a ±5 minute duration tolerance. A different tolerance assumption would change the distribution of Completed, Completed Late, and Short Visit counts. The ±5 minute threshold is conservative and aligns with UK industry practice.

**Caveat 4 — 7.2% of travel records were excluded due to impossible speed calculations. Impact: Moderate.**
4,204 travel records were flagged as suspect where the implied speed (mileage ÷ travel time) exceeded 60mph or fell below 3mph. These were excluded from all travel time and mileage metrics. The average travel time of 18.0 minutes and travel time ratio of 37.88% are based on the remaining clean records and are considered reliable. The exclusion rate itself is reported as a data governance finding on the CQC compliance dashboard.

**Caveat 5 — Safeguarding_flag_derived is indicative, not exhaustive. Impact: Moderate.**
The derived safeguarding flag was built using a defined list of 19 welfare-related keywords detected in carer notes. Some concerns expressed in language outside the keyword list may be understated; conversely, some keyword matches may reflect routine care events rather than safeguarding concerns. The Safeguarding Compliance Rate of 48% should be read as an indicative minimum. The directional conclusion — significant safeguarding process failure — is robust regardless of minor variation in the derived count.

---

<details>
<summary>📁 Repository Structure</summary>

```
📦 care-delivery-performance-regulatory-readiness
 ┣ 📂 sql
 ┃ ┣ 📄 00_database_setup.sql
 ┃ ┣ 📄 01_data_profiling.sql
 ┃ ┣ 📄 02_data_cleaning.sql
 ┃ ┣ 📄 03_clean_visits.sql
 ┃ ┣ 📄 04_dim_tabels.sql
 ┃ ┣ 📄 05_fact_visits.sql
 ┃ ┗ 📄 06_data_validation.sql
 ┣ 📂 excel
 ┃ ┗ 📄 DQ_Issue_Log_Everwell_Care_Services.xlsx
 ┣ 📂 powerbi
 ┣ 📂 docs
 ┃ ┣ 📄 00_analysis_report.md
 ┃ ┗ 📄 01_business_brief.md
 ┗ 📄 README.md
```

</details>

---

*Analysis conducted using MySQL, Microsoft Excel, and Microsoft Power BI. Dataset: 75,000 care visit records, January 2024 – December 2025. 
