
# Care Delivery Performance & CQC Regulatory Readiness Analysis Report
## Everwell Care Services Ltd 
**Prepared by:** Mercy Verkijika

**Classification:** Confidential

---

## Executive Summary

Everwell Care Services Ltd is not inspection-ready. Across **68,973 accountable visits** delivered between January 2024 and December 2025, the organisation achieved a Visit Completion Rate of **57.65%** and a Care Delivery Rate of **59.69%** — both less than two-thirds of the 95% target set by commissioners and the CQC.

Three findings define the organisational position:

> **1.** More than 40% of all accountable visits were either missed entirely (14.80%) or delivered short of the commissioned duration (27.55%), leaving clients routinely without their full care.

> **2.** 52% of welfare concerns identified in carer notes were never formally escalated as safeguarding alerts — a statutory compliance failure carrying direct legal exposure under the Care Act 2014.

> **3.** Carers are spending 37.88% of their total field time travelling rather than delivering care. This structural scheduling inefficiency is the root cause of short visits, late arrivals, and carer overload across all 25 service areas.

### Headline KPI Scorecard

| KPI                          | Result   | Target   | Status        |
| ---------------------------- | -------- | -------- | ------------- |
| Visit Completion Rate        | 57.65%   | ≥ 95%    | 🔴 Critical    |
| Care Delivery Rate           | 59.69%   | ≥ 95%    | 🔴 Critical    |
| Missed Visit Rate            | 14.80%   | ≤ 2%     | 🔴 Critical    |
| Short Visit Rate             | 27.55%   | ≤ 3%     | 🔴 Critical    |
| Punctuality Rate             | 68.78%   | ≥ 90%    | 🔴 Critical    |
| Safeguarding Compliance Rate | 48.00%   | ≥ 98%    | 🔴 Critical    |
| Continuity Rate              | 68.5%    | ≥ 95%    | 🔴 Critical    |
| Utilisation Rate             | 62.12%   | ≥ 90%    | 🔴 Critical    |
| Travel Time %                | 37.88%   | ≤ 25%    | 🔴 Critical    |
| Avg Travel Time              | 18.0 min | ≤ 15 min | 🟡 Approaching |
| Medication Recording Rate    | 100.00%  | ≥ 98%    | 🟢 Met*        |
| Data Quality Score           | 69.09%   | ≥ 95%    | 🔴 Critical    |

*Requires external validation — see Data Notes*

---

## Data Notes

The following should be considered before presenting findings to external stakeholders:

- All metrics are drawn from 75,000 validated records after deduplication of 2,250 exact duplicate rows.
- **291 visits were excluded** from all KPI calculations — these were scheduling errors and double bookings that were never real scheduled visits.
- **6,544 external visits** (client cancelled, client hospitalised) are excluded from performance metrics. The organisation is not accountable for these outcomes.
- All KPIs are calculated against **68,973 accountable visits** — visits where Everwell had full operational control.
- `visit_status_derived` is used throughout in place of the original `visit_status` field, which contained 34 inconsistent variants and demonstrably misattributed statuses.
- **4,204 travel records flagged as suspect** (implied speeds above 60mph or below 3mph) were excluded from travel-related calculations only — Avg Travel Time, Total Travel Time, Travel Time Ratio, Avg Mileage, and Total Mileage. These visits remain in all other KPI calculations.
- The Medication Recording Rate of 100% requires validation against the source care management system before being used as evidence in an inspection context.

---

## Section 1 — Service Delivery Performance

### KPI Summary

| KPI                   | Result      | Target | Status     |
| --------------------- | ----------- | ------ | ---------- |
| Visit Completion Rate | 57.65%      | ≥ 95%  | 🔴 Critical |
| Care Delivery Rate    | 59.69%      | ≥ 95%  | 🔴 Critical |
| Missed Visit Rate     | 14.80%      | ≤ 2%   | 🔴 Critical |
| Short Visit Rate      | 27.55%      | ≤ 3%   | 🔴 Critical |
| Punctuality Rate      | 68.78%      | ≥ 90%  | 🔴 Critical |
| Commissioned Hours    | ~38,000 hrs | —      | Reference  |
| Delivered Hours       | ~23,000 hrs | —      | Reference  |
| Undelivered Hours     | ~15,000 hrs | —      | Reference  |

---

### Insight 1 — Visit completion is 37 percentage points below target with no improving trend across 24 months

**The finding:** The Visit Completion Rate of 57.65% has remained consistent from January 2024 through December 2025. Monthly trend data shows the Care Delivery Rate oscillating between approximately 54% and 62% with no upward trajectory. Two full years of flat performance confirms this is not a temporary dip — it is an embedded structural failure.

**Why it matters:** At 57.65% completion, clients are receiving care on fewer than 6 in 10 scheduled visits. Local authority commissioners pay for full visit delivery. An organisation consistently delivering at this level is contractually exposed to financial clawback and contract suspension.

**Possible root cause:** Planned visit durations and travel time allocations are insufficient relative to actual demand. Carers are being given rota slots that are structurally impossible to deliver in full — not because of individual failure, but because the scheduling model does not reflect reality.

**Business risk:** If commissioners review delivered versus commissioned hours, the 40-percentage-point gap would trigger a contract performance review. If the CQC inspects, a completion rate below 60% would likely result in Requires Improvement or Inadequate under Safe.

**Action required:** Conduct an urgent review of rota design. Planned visit durations must be recalibrated against actual delivery data by care category. Travel time must be built into rotas as a genuine allowance, not an afterthought.

---

### Insight 2 — 27.55% of visits are short — call clipping is the largest single driver of undelivered care

**The finding:** More than 1 in 4 visits are classified as short — the carer attended but left more than 5 minutes before the commissioned end time. Combined with a 14.80% missed visit rate, over 40% of all accountable visits are either absent or incomplete. Of approximately 38,000 commissioned hours, roughly **15,000 hours were not delivered** as specified.

**Why it matters:** Short visits — commonly referred to as call clipping in the domiciliary care sector — are one of the most scrutinised practices under the CQC's Safe key question. For elderly clients with dementia, complex medication needs, or mobility limitations, even 5–10 minutes of missed care time can have direct health consequences.

**Possible root cause:** Carers are under-scheduled relative to client need and are leaving early to reach the next appointment on time. The 37.88% travel time ratio (discussed in Section 2) confirms that insufficient travel time in rotas creates a cascade effect where every visit after the first is at risk of being shortened.

**Business risk:** This is the primary financial exposure in the dataset. Commissioners paying for full visit durations are receiving a fraction of the commissioned service. Legal liability arises if a client experiences harm during a shortened visit that was documented as completed.

**Action required:** Introduce a rota design standard that builds realistic travel time between visits. Carers must be supported to record honest clock-out times rather than scheduled end times. Short visit frequency should be tracked weekly as a carer-level KPI in supervision.

---

### Insight 3 — Palliative Care is delivering at 36.29% — a 35-point gap versus the best performing category

**The finding:**

| Care Category             | Delivery Rate |
| ------------------------- | ------------- |
| Medication Administration | 71.62%        |
| Personal Care             | 67.55%        |
| Dementia Care             | 51.90%        |
| Companionship / Wellbeing | 51.69%        |
| **Palliative Care**       | **36.29%**    |

Palliative Care accounts for approximately 2,500 under-delivered hours — the joint highest of any category alongside Dementia Care.

**Why it matters:** Palliative care clients are approaching end of life with complex, time-sensitive needs involving pain management, comfort positioning, medication administration, and family support. A delivery rate of 36.29% means these clients receive care in barely 1 in 3 scheduled visits. This is a patient dignity and safety issue of the highest order.

**Possible root cause:** Palliative care visits are typically longer (45–60 minutes) and require experienced carers. If the organisation does not ring-fence specialist carers for this category, rota pressure results in these visits being the first shortened or skipped when carers are running behind.

**Business risk:** CQC inspectors give end-of-life care heightened scrutiny under both Safe and Caring. A 36.29% delivery rate would almost certainly result in a finding of Inadequate under Safe for this category. There is also direct risk of harm to clients and reputational risk if families escalate complaints.

**Action required:** Ring-fence a dedicated cohort of senior carers for palliative care visits. These visits should never be shortened or missed when rotas are under pressure. The Registered Manager should be briefed on this finding immediately.

---

### Insight 4 — The Bedtime/Night Round reaches as low as 23.46% on Monday nights — chronically understaffed

**The finding:**

|           | Morning Round | Lunchtime Round | Tea-Time Round | Bedtime/Night Round |
| --------- | ------------- | --------------- | -------------- | ------------------- |
| Monday    | 61.94%        | 57.50%          | 60.50%         | **23.46%**          |
| Tuesday   | 61.91%        | 56.84%          | 60.02%         | **26.32%**          |
| Wednesday | 60.84%        | 55.00%          | 61.33%         | **35.38%**          |
| Thursday  | 60.65%        | 55.22%          | 61.51%         | **40.93%**          |
| Friday    | 61.05%        | 58.02%          | 60.60%         | **41.21%**          |
| Saturday  | 58.72%        | 54.54%          | 59.83%         | **32.93%**          |
| Sunday    | 59.88%        | 54.90%          | 59.17%         | **46.12%**          |

**Why it matters:** The Bedtime/Night Round covers a critical period — bedtime medication, comfort positioning, and overnight safety. On Mondays, three in four clients are not receiving their scheduled bedtime visit. For clients on evening medication regimes or at fall risk, this represents a direct patient safety gap.

**Possible root cause:** This shift carries the fewest carers and the most difficult working conditions. Monday nights are particularly poor because weekend carers rotating off shift leave Monday evening rotas thin.

**Business risk:** CQC inspectors reviewing incident data alongside delivery patterns will see that the period of lowest completion coincides with the highest-risk time for client safety. This is a specific enforcement risk under Safe.

**Action required:** Recruit or designate dedicated carers for the Bedtime/Night Round. Consider enhanced pay rates for this shift to improve recruitment. Measure improvement monthly and report to the board.

---

## Section 2 — Workforce Efficiency

### KPI Summary

| KPI              | Result   | Target   | Status        |
| ---------------- | -------- | -------- | ------------- |
| Utilisation Rate | 62.12%   | ≥ 90%    | 🔴 Critical    |
| Continuity Rate  | 68.5%    | ≥ 95%    | 🔴 Critical    |
| Travel Time %    | 37.88%   | ≤ 25%    | 🔴 Critical    |
| Avg Travel Time  | 18.0 min | ≤ 15 min | 🟡 Approaching |

---

### Insight 5 — Carers spend 37.88% of field time travelling — the organisation pays for nearly 2 hours of driving per 3 hours of care

**The finding:**

| Area      | Care Time | Travel Time |
| --------- | --------- | ----------- |
| Bitterne  | 62.73%    | 37.27%      |
| Hedge End | 61.49%    | 38.51%      |
| Shirley   | 62.85%    | 37.15%      |
| Millbrook | 63.30%    | 36.70%      |
| Bassett   | 63.75%    | 36.25%      |

Every area in the top 10 shows travel consuming between 36% and 39% of total field time — virtually identical across geographically different areas.

**Why it matters:** At an average pay rate of approximately £12.95 per hour, every hour of unnecessary travel is a direct cost generating no care value. More critically, a carer spending 38 minutes per hour travelling arrives at the next client late, leaves early to maintain the rota, and has no buffer for a client who needs extra time. The short visit problem and the travel problem are the same problem from different angles.

**Possible root cause:** The uniformity across all areas confirms this is a scheduling architecture failure, not a geographic one. Carers are not assigned to geographic clusters — they cover the full 25-area service per shift, crossing multiple areas daily.

**Business risk:** The organisation is funding a third of its carer workforce time on non-care activity. Each 1% reduction in travel time ratio releases approximately 680 additional care hours per month for client delivery.

**Action required:** Implement geographic zoning immediately. Pilot in Bitterne and Hedge End — the two highest-volume areas — assigning each carer to a cluster of 2–3 adjacent areas per shift. Target: reduce Travel Time % from 37.88% toward ≤30% within 90 days.

---

### Insight 6 — Carer workload ranges from 162 to 826.6 average hours — a five-fold difference creating fragile capacity

**The finding:** A small cohort of high-volume carers at 600–800 average hours manage 1,500–2,000 visits each. The top 10% of carers carry a disproportionate share of the total workload. Despite this disparity, completion rates are uniform across both high and low workload carers — confirming the problem is systemic, not individual.

**Why it matters:** When high-volume carers take sick leave — already the second-largest documented reason for missed visits at approximately 1,700 instances — the impact on the rota is outsized. The organisation has concentrated fragility into a small number of individuals.

**Possible root cause:** Visits are assigned to whoever is available rather than being distributed to a workload cap. It may also reflect a retention problem: the organisation relies on its most reliable carers because overall headcount is insufficient.

**Business risk:** Overworked carers are more likely to leave, more likely to make errors, and more likely to take sick leave — each of which worsens service delivery directly.

**Action required:** Introduce a weekly workload cap per carer. Identify carers above 600 average hours and redistribute where possible. Commission a staffing needs analysis to determine whether headcount is the root constraint.

---

### Insight 7 — Weekend missed visits are structurally higher — Saturday and Sunday are running approximately 300 more missed visits per day than weekdays

**The finding:** Accountable visits remain consistent across all seven days at approximately 9,700–9,900. However, missed visits spike on Saturday (approximately 1,700) and Sunday (approximately 1,600) versus weekday levels of 1,300–1,400. The organisation is scheduling the same volume with fewer available carers.

**Why it matters:** The CQC explicitly assesses whether quality is maintained at weekends. A consistent weekend performance gap signals a two-tier service — a direct finding risk under Safe and Responsive.

**Possible root cause:** Weekend staffing relies on a structurally smaller pool of available carers. Without dedicated weekend contracts or enhanced pay, this gap persists indefinitely.

**Business risk:** Local authority contracts typically specify consistent seven-day service delivery. A demonstrable weekend performance gap is a contractual risk and a safeguarding risk for clients without weekday-to-weekend continuity.

**Action required:** Establish a dedicated weekend care team with guaranteed weekend-contracted hours. Introduce a weekend on-call coordinator with authority to arrange emergency cover. Target: weekend missed rate within 2 percentage points of weekday rate within 90 days.

---

### Insight 8 — Continuity Rate of 68.5% means nearly 1 in 3 visits involves an unfamiliar carer

**The finding:** 31.5% of all accountable visits involve a carer the client has not recently seen. For the 13,021 Dementia Care visits in the dataset, continuity of carer is not a quality preference — it is a clinical need.

**Why it matters:** An unfamiliar carer visiting a dementia client causes genuine distress and increases the risk of missed welfare observations. A carer who knows their client will notice changes in condition that a new carer cannot. Poor continuity also reduces care efficiency.

**Possible root cause:** Carers are not assigned to defined client caseloads. Scheduling assigns whoever is available across the full area, so clients see different carers on consecutive visits.

**Business risk:** The CQC assesses continuity under Caring. A 68.5% rate, particularly across dementia and palliative care clients, could be cited as a finding in an inspection report.

**Action required:** Introduce a named carer model. Each client should have a primary carer and a designated backup. The rota system should always attempt primary carer assignment first. Track continuity rate monthly at team level.

---

## Section 3 — Care Quality & CQC Compliance

### KPI Summary

| KPI                          | Result  | Target | Status         |
| ---------------------------- | ------- | ------ | -------------- |
| Safeguarding Compliance Rate | 48.00%  | ≥ 98%  | 🔴 Critical     |
| Medication Recording Rate    | 100.00% | ≥ 98%  | 🟢 Met*         |
| Incident Rate                | 3.89%   | ≤ 2%   | 🔴 Above Target |
| Data Quality Score           | 69.09%  | ≥ 95%  | 🔴 Critical     |
| Carer Notes Completion       | 73.17%  | ≥ 90%  | 🔴 Below Target |
| Alert Compliance Rate        | 73.22%  | ≥ 90%  | 🔴 Below Target |

*Requires external validation*

---

### Insight 9 — Safeguarding Compliance Rate is 48% — 52% of welfare concerns were never formally escalated

**The finding:**

| Area                | Safeguarding Compliance |
| ------------------- | ----------------------- |
| Hythe               | 37.50%                  |
| Netley              | 40.91%                  |
| Hamble              | 42.00%                  |
| Thornhill           | 42.15%                  |
| St Denys            | 42.19%                  |
| Chandlers Ford      | 43.55%                  |
| **All Areas Total** | **48.00%**              |

The safeguarding compliance trend oscillates between 30% and 50% across the full 24-month period with no improvement. Every area performs below 45%. This has been consistently broken for two years.

**Why it matters:** When a carer notes "New bruise on upper arm, client cannot explain how" or "Medication found already removed from blister pack, unclear if taken" and no safeguarding alert is raised, that concern exists on paper and nowhere else. There is no escalation, no investigation, no multi-agency contact. This is a statutory failure under the Care Act 2014.

**Possible root cause:** Two systemic failures are operating simultaneously. Carers are applying personal judgement about what constitutes a safeguarding threshold rather than following a clear policy. The care management system does not prompt the carer to consider a formal referral when note content suggests a welfare concern.

**Business risk:** This is the highest-priority risk in the entire report. A CQC inspection that reviews carer notes alongside the safeguarding register and finds a 52% gap would result in Inadequate under Safe. In cases where a client subsequently experienced harm following a documented but unescalated concern, the organisation faces civil liability and potential prosecution under the Safeguarding Vulnerable Groups Act.

**Action required — Immediate:** The Designated Safeguarding Lead must review all visits with clinically significant carer notes where no formal flag was raised. Historical concerns still requiring escalation to the local authority safeguarding team should be referred without delay.

**Action required — Structural:** All 65 carers must complete mandatory safeguarding recognition refresher training within 30 days. The care management system must be configured to prompt "Does this note indicate a safeguarding concern?" when specific keyword content is detected before a note can be submitted.

---

### Insight 10 — Incident Rate of 3.89% is almost double the target — and the trend is flat across 2024 and 2025

**The finding:** The Incident Rate of 3.89% has remained flat throughout both years. Visit volumes with carer notes run at 3,000–4,500 per month while incidents hold at approximately 3.5–4.5%. The organisation is not catching clinical concerns early before they escalate.

**Why it matters:** An elevated and flat incident rate signals that the early intervention mechanism — identifying welfare concerns in notes before they become reportable incidents — is not functioning. The safeguarding process failure in Insight 9 is directly connected to this elevated rate.

**Possible root cause:** When concerns in carer notes are not escalated, clients do not receive a welfare review or increased monitoring. The underlying issue continues unchecked until it becomes serious enough to require a formal incident report.

**Business risk:** A flat, above-target incident rate with no improving trend signals that the organisation's quality assurance processes are not working. Regulators expect rates to be declining as a result of proactive management.

**Action required:** Implement a weekly clinical review: a senior care coordinator should review all visits with clinically significant carer notes and determine whether each requires a safeguarding referral, a care plan review, or increased monitoring. This is the early intervention mechanism the data shows is currently absent.

---

### Insight 11 — Data Quality Score is 69.09% — the organisation cannot fully evidence its own care to a CQC inspector

**The finding:**

| Metric                 | Rate    |
| ---------------------- | ------- |
| Data Quality Score     | 69.09%  |
| Carer Notes Completion | 73.17%  |
| Alert Compliance       | 73.22%  |
| Mood Recording Rate    | ~89.00% |

Both Carer Notes Completion and Alert Compliance sit at approximately 73%, flat across the entire reporting period. In 30.91% of completed visits, at least one key documentation field is missing.

**Why it matters:** During a CQC inspection, the organisation must demonstrate with records that care was delivered, welfare was monitored, and concerns were acted upon. Where notes are absent, that evidence does not exist. Poor documentation also prevents effective internal quality management — patterns of deterioration in individual clients cannot be identified from incomplete records.

**Possible root cause:** Documentation burden falls on carers who are already under time pressure from short visit schedules and excessive travel time. A carer who has just ended a visit 5 minutes early to make the next appointment does not have the time or capacity to complete thorough notes. The system generates conditions that make good documentation structurally difficult.

**Business risk:** A Data Quality Score of 69.09% is a direct CQC finding risk under Well-Led. It also limits the organisation's ability to defend itself in any regulatory or legal challenge requiring contemporaneous records.

**Action required:** Introduce structured note templates in the care management system — drop-down selections for routine visits reduce documentation time to under 60 seconds. Set documentation completion as a team performance indicator in weekly supervision.

---

## Section 4 — Recommendations

### Immediate Actions — Within 30 Days

| #   | Action                                                                                                                                               | Owner                        | Success Measure                                                          |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------------------ |
| 1   | Safeguarding audit: review all clinically significant notes with no formal flag. Refer outstanding concerns to the local authority safeguarding team | Designated Safeguarding Lead | All outstanding concerns reviewed and closed or escalated within 30 days |
| 2   | Mandatory safeguarding retraining for all 65 carers                                                                                                  | Training Lead                | 100% completion within 30 days                                           |
| 3   | Make missed visit reason a mandatory field in the care management system                                                                             | IT / Operations Manager      | Undocumented missed visits below 5% within 60 days                       |
| 4   | Brief Registered Manager and clinical leads on the 36.29% Palliative Care delivery rate. Conduct immediate caseload review                           | Registered Manager           | Review completed and escalation plan in place within 2 weeks             |
| 5   | Establish weekend on-call coordinator with emergency cover authority                                                                                 | Operations Manager           | Weekend missed rate within 2pp of weekday rate within 90 days            |

---

### Short-Term Actions — 30–90 Days

| #   | Action                                                                      | Owner                     | Success Measure                                             |
| --- | --------------------------------------------------------------------------- | ------------------------- | ----------------------------------------------------------- |
| 6   | Geographic zoning pilot in Bitterne and Hedge End                           | Scheduling Manager        | Travel Time % reduces from 37.88% toward 30% within 90 days |
| 7   | Visit duration recalibration by care category                               | Quality & Governance Lead | Short Visit Rate reduces from 27.55% toward 20%             |
| 8   | Workload cap per carer introduced. Redistribute from carers above 600 hours | Operations Manager        | Workload range narrows; burnout risk cohort below 600 hours |
| 9   | Named carer model: primary and backup assigned to each client               | Scheduling Manager        | Continuity Rate from 68.5% toward 75% within 90 days        |
| 10  | Structured note templates deployed in care management system                | IT / Quality Lead         | Data Quality Score from 69.09% toward 80% within 90 days    |

---

### Long-Term Actions — 90 Days and Beyond

| #   | Action                                                                                       | Owner                     | Success Measure                                        |
| --- | -------------------------------------------------------------------------------------------- | ------------------------- | ------------------------------------------------------ |
| 11  | Staffing needs analysis and board-level investment case for recruitment                      | HR / Operations Director  | Visit Completion Rate above 80% within 12 months       |
| 12  | Automated safeguarding keyword prompts in care management system                             | IT / Safeguarding Lead    | Safeguarding Compliance Rate above 90% within 6 months |
| 13  | CQC pre-inspection programme: mock inspection, Quality Improvement Plan, evidence portfolios | Quality & Governance Lead | CQC inspection rating of Good or above                 |
| 14  | Embed Power BI dashboards into weekly operational and monthly board reporting cycle          | All department leads      | Monthly KPI review embedded within 60 days             |

---

## Appendix — KPI Reference Table

| Metric                  | Result   | Target   | Gap        |
| ----------------------- | -------- | -------- | ---------- |
| Visit Completion Rate   | 57.65%   | ≥ 95%    | -37.35pp   |
| Care Delivery Rate      | 59.69%   | ≥ 95%    | -35.31pp   |
| Missed Visit Rate       | 14.80%   | ≤ 2%     | +12.80pp   |
| Short Visit Rate        | 27.55%   | ≤ 3%     | +24.55pp   |
| Punctuality Rate        | 68.78%   | ≥ 90%    | -21.22pp   |
| Utilisation Rate        | 62.12%   | ≥ 90%    | -27.88pp   |
| Continuity Rate         | 68.5%    | ≥ 95%    | -26.5pp    |
| Travel Time %           | 37.88%   | ≤ 25%    | +12.88pp   |
| Avg Travel Time         | 18.0 min | ≤ 15 min | +3.0 min   |
| Safeguarding Compliance | 48.00%   | ≥ 98%    | -50pp      |
| Medication Recording    | 100.00%  | ≥ 98%    | ✅ Validate |
| Incident Rate           | 3.89%    | ≤ 2%     | +1.89pp    |
| Data Quality Score      | 69.09%   | ≥ 95%    | -25.91pp   |
| Carer Notes Completion  | 73.17%   | ≥ 90%    | -16.83pp   |
| Alert Compliance        | 73.22%   | ≥ 90%    | -16.78pp   |

---

*Analysis based on 75,000 validated care visit records, January 2024 – December 2025. 