# Care Delivery Performance & CQC Regulatory Readiness Analysis Report
## Everwell Care Services Ltd
**Prepared by:** Mercy Verkijika

**Classification:** Confidential

---


## Executive Summary

Everwell Care Services Ltd is not ready for inspection. Across 68,973 accountable visits delivered between January 2024 and December 2025, the organisation achieved a Visit Completion Rate of 57.65% and a Care Delivery Rate of 59.69%. Both are well below the 95% target set by commissioners and the CQC.

Three findings define the position:

- More than 40% of all accountable visits were either missed entirely (14.80%) or delivered short of the commissioned duration (27.55%), leaving clients without their full care.
- 52% of welfare concerns identified in carer notes were never formally escalated as safeguarding alerts. This is a statutory compliance failure under the Care Act 2014.
- Carers are spending 37.88% of their total field time travelling rather than delivering care. This scheduling inefficiency is the root cause of short visits, late arrivals, and carer overload across all 25 service areas.

Headline KPI Scorecard

![Headline KPI Scorecard](<Screenshot 2026-04-19 075240.png>)

*Requires external validation. See Data Notes.*

---

## Data Notes

Before presenting these findings externally, note the following:

- All metrics are drawn from 75,000 validated records after deduplication of 2,250 exact duplicate rows.
- 291 visits were excluded from all KPI calculations because they were scheduling errors or double bookings.
- 6,544 external visits (client cancelled, client hospitalised) are excluded from performance metrics. The organisation is not accountable for these outcomes.
- All KPIs are calculated against 68,973 accountable visits, where Everwell had full operational control.
- `visit_status_derived` is used throughout instead of the original `visit_status` field, which contained 34 inconsistent variants and misattributed statuses.
- 4,204 travel records flagged as suspect (implied speeds above 60mph or below 3mph) were excluded from travel-related calculations only: Average Travel Time, Total Travel Time, Travel Time Ratio, Average Mileage, and Total Mileage. These visits remain in all other KPI calculations.
- The Medication Recording Rate of 100% requires validation against the source care management system before being used as inspection evidence.

---

## Section 1 - Service Delivery Performance

---

### Insight 1 - Visit completion is 37 percentage points below target, with no improving trend across 24 months

**The finding:** The Visit Completion Rate of 57.65% has been stable from January 2024 through December 2025. The Care Delivery Rate has hovered between 54% and 62% with no upward movement. Two years of flat performance show this is not a temporary dip.

**Why it matters:** At 57.65% completion, clients are receiving care on fewer than 6 in 10 scheduled visits. Commissioners pay for full visit delivery, so this level of performance exposes the organisation to financial clawback and potential contract review.

**Possible cause:** Planned visit durations and travel time allocations do not match actual demand. Carers are being given rota slots that are impossible to deliver in full because the scheduling model does not reflect reality.

**Risk:** If commissioners compare delivered versus commissioned hours, the 40-point gap would trigger a contract performance review. A CQC inspection would likely rate this as Requires Improvement or Inadequate under Safe.

**Recommended action:** Review rota design urgently. Recalibrate planned visit durations by care category and build travel time into rotas as a genuine allowance.

---

### Insight 2 - 27.55% of visits are short, making call clipping the largest single driver of undelivered care

**The finding:** More than 1 in 4 visits are short because the carer left more than 5 minutes before the scheduled end time. With the 14.80% missed visit rate, over 40% of accountable visits are either absent or incomplete. Of about 38,000 commissioned hours, roughly 15,000 were not delivered as specified.

**Why it matters:** Short visits are one of the most scrutinised practices under the CQC's Safe key question. For clients with dementia, complex medication needs, or mobility limitations, even 5 to 10 minutes of missed care can have direct health consequences.

**Possible cause:** Carers are under-scheduled and leave early to get to the next appointment on time. The 37.88% travel time ratio shows that insufficient travel allowance in the rota creates a cascade effect that causes visits to be shortened.

**Risk:** This is the main financial exposure. Commissioners are paying for full visit durations but receiving a fraction of the commissioned service. There is also legal risk if a shortened visit leads to harm.

**Recommended action:** Set a rota standard that includes realistic travel time between visits. Encourage carers to record actual clock-out times and track short visits weekly as a carer-level KPI.

---

### Insight 3 - Palliative Care is delivering at 36.29%, a 35-point gap versus the best performing category

**The finding:** Palliative Care accounts for about 2,500 under-delivered hours, the joint highest of any category alongside Dementia Care. These clients are approaching end of life with complex, time-sensitive care needs. A delivery rate below 40% for this cohort is the most serious patient safety risk in the dataset.

**Why it matters:** Palliative care clients have complex, time-sensitive needs involving pain management, comfort positioning, medication administration, and family support. A 36.29% delivery rate means these clients receive care in barely 1 in 3 scheduled visits.

**Possible cause:** Palliative care visits are longer and require experienced carers. Without specialist carers ring-fenced for this category, these visits are the first to be shortened or skipped when the rota is under pressure.

**Risk:** CQC inspectors treat end-of-life care with heightened scrutiny under Safe and Caring. This delivery rate would almost certainly result in an Inadequate finding for this category. There is also reputational risk if families escalate complaints.

**Recommended action:** Ring-fence a dedicated cohort of senior carers for palliative care visits. These visits should not be shortened or missed when rotas are under pressure, and the Registered Manager should be briefed immediately.

---

### Insight 4 - The Bedtime/Night Round drops to 23.46% on Monday nights, indicating chronic understaffing

**The finding:** The Bedtime/Night Round is chronically understaffed. This is the period of highest vulnerability for clients, and completion rates below 25% put bedtime medication, comfort positioning, and overnight safety checks at risk.

**Why it matters:** Monday nights are especially poor, with three in four clients not receiving their scheduled bedtime visit. For clients on evening medication or at fall risk, this is a direct patient safety gap.

**Possible cause:** This shift has the fewest carers and the hardest working conditions. Weekend carers rotating off shift leave Monday evening rotas thin.

**Risk:** Inspectors will see the lowest completion period aligned with the highest client safety risk. That creates a specific enforcement risk under Safe.

**Recommended action:** Recruit or designate dedicated carers for the Bedtime/Night Round. Consider enhanced pay rates for this shift, and measure progress monthly.

---

## Section 2 - Workforce Efficiency

### Insight 5 - Carers spend 37.88% of field time travelling, meaning nearly 2 hours of driving per 3 hours of care

**The finding:** Travel consumes 36 to 39% of total field time across the top 10 areas, showing the problem is consistent and not location-specific.

**Why it matters:** At roughly £12.95 per hour, every hour of unnecessary travel is a direct cost with no care value. A carer spending 38 minutes per hour travelling arrives late, leaves early, and has no buffer for extra client time.

**Possible cause:** The issue is scheduling architecture, not geography. Carers are not assigned to geographic clusters and cover the full 25-area service each shift.

**Risk:** The organisation is effectively paying a third of carer time for non-care activity. Each 1% reduction in travel time ratio frees about 680 care hours per month.

**Recommended action:** Implement geographic zoning immediately. Pilot within Bitterne and Hedge End, assigning each carer to 2 to 3 adjacent areas per shift. Aim to reduce Travel Time % from 37.88% toward 30% within 90 days.

---

### Insight 6 - Carer workload ranges from 162 to 826.6 average hours, creating fragile capacity

**The finding:** A small cohort of carers at 600 to 800 average hours manage 1,500 to 2,000 visits each. The top 10% carry a disproportionate share of the workload, while completion rates remain uniform across all carers.

**Why it matters:** When high-volume carers take sick leave, the impact on the rota is outsized. The organisation has concentrated fragility into a small number of individuals.

**Possible cause:** Visits are assigned to whoever is available rather than being capped by workload. This may also reflect a retention problem, where the most reliable carers are overloaded because overall headcount is insufficient.

**Risk:** Overworked carers are more likely to leave, make errors, and take sick leave. That worsens service delivery directly.

**Recommended action:** Introduce a weekly workload cap per carer. Identify carers above 600 average hours and redistribute assignments where possible. Commission a staffing needs analysis to determine whether headcount is the root constraint.

---

### Insight 7 - Weekend missed visits are structurally higher, with 300 more missed visits per day than weekdays

**The finding:** Accountable visits are consistent across the week, but missed visits spike on Saturday and Sunday by about 300 more per day than weekdays.

**Why it matters:** The CQC explicitly assesses whether quality is maintained at weekends. A consistent weekend gap signals a two-tier service and a direct finding risk under Safe and Responsive.

**Possible cause:** Weekend staffing relies on a smaller pool of carers. Without dedicated weekend contracts or enhanced pay, the gap will persist.

**Risk:** Contracts typically require consistent seven-day service delivery. A weekend performance gap is a contractual risk and a safeguarding risk for clients without continuity.

**Recommended action:** Establish a dedicated weekend care team with guaranteed weekend-contracted hours. Introduce a weekend on-call coordinator with authority to arrange emergency cover. Aim to bring weekend missed rate within 2 percentage points of weekday rate within 90 days.

---

### Insight 8 - Continuity Rate of 68.5% means nearly 1 in 3 visits involves an unfamiliar carer

**The finding:** 31.5% of accountable visits involve a carer the client has not recently seen. For 13,021 Dementia Care visits, continuity is not a quality preference, it is a clinical need.

**Why it matters:** An unfamiliar carer visiting a dementia client causes distress and increases the risk of missed welfare observations. A carer who knows their client will notice changes in condition that a new carer cannot.

**Possible cause:** Carers are not assigned to defined caseloads. Scheduling assigns whoever is available across the full area.

**Risk:** The CQC assesses continuity under Caring. A 68.5% rate, especially in dementia and palliative care, could be cited as a finding.

**Recommended action:** Introduce a named carer model. Each client should have a primary carer and a designated backup. The rota system should prioritise primary carer assignment and track continuity monthly.

---

## Section 3 - Care Quality & CQC Compliance

### Insight 9 - Safeguarding Compliance Rate is 48%, with 52% of welfare concerns never formally escalated

**The finding:** Safeguarding compliance has stayed between 30% and 50% over 24 months, with every area below 45%.

**Why it matters:** When carers note concerns such as bruises or medication issues and no safeguarding alert is raised, those concerns are documented but not acted on. That is a statutory failure under the Care Act 2014.

**Possible cause:** Carers are using personal judgement rather than a clear policy. The care management system does not prompt a formal referral when note content suggests a welfare concern.

**Risk:** This is the highest-priority risk in the report. A CQC inspection that finds a 52% escalation gap would likely result in Inadequate under Safe. If harm follows an unreported concern, the organisation could face civil liability.

**Recommended action:** The Designated Safeguarding Lead should review all clinically significant notes without a formal flag immediately. Historical concerns requiring escalation should be referred without delay. All 65 carers should complete safeguarding refresher training within 30 days. The care management system should prompt "Does this note indicate a safeguarding concern?" before a note can be submitted.

---

### Insight 10 - Incident Rate of 3.89% is almost double the target, and the trend is flat across 2024 and 2025

**The finding:** The Incident Rate has stayed flat at around 3.89% across both years, while note volumes remain between 3,000 and 4,500 per month.

**Why it matters:** A flat, elevated incident rate means early intervention is not working. The issue identified in Insight 9 is directly related.

**Possible cause:** When note concerns are not escalated, clients do not receive a welfare review or increased monitoring. The issue continues until it becomes serious enough to require an incident report.

**Risk:** Regulators expect incident rates to decline with proactive management. A flat, above-target rate indicates weak quality assurance.

**Recommended action:** Implement a weekly clinical review. A senior care coordinator should assess all visits with clinically significant notes and determine whether each requires a safeguarding referral, care plan review, or increased monitoring.

---

### Insight 11 - Data Quality Score is 69.09%, meaning the organisation cannot fully evidence its own care to a CQC inspector

**The finding:** Carer Notes Completion and Alert Compliance are both around 73%, leaving 30.91% of completed visits with at least one key documentation field missing.

**Why it matters:** During a CQC inspection, the organisation must show records that care was delivered, welfare was monitored, and concerns were acted on. Missing notes mean that evidence does not exist.

**Possible cause:** Documentation burden falls on carers who are already under pressure from short visits and excessive travel. A carer who finishes a visit early to make the next appointment does not have time for thorough notes.

**Risk:** A Data Quality Score of 69.09% exposes the organisation to a CQC finding under Well-Led and reduces its ability to defend itself in regulatory or legal challenges.

**Recommended action:** Introduce structured note templates in the care management system. Drop-down selections for routine visits can reduce documentation time to under 60 seconds. Make documentation completion a team performance indicator in weekly supervision.

---

## Section 4 - Recommendations

### Immediate Actions - Within 30 Days

| #   | Action                                                                                                                                               | Owner                        | Success Measure                                                          |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------------------ |
| 1   | Safeguarding audit: review all clinically significant notes with no formal flag. Refer outstanding concerns to the local authority safeguarding team | Designated Safeguarding Lead | All outstanding concerns reviewed and closed or escalated within 30 days |
| 2   | Mandatory safeguarding retraining for all 65 carers                                                                                                  | Training Lead                | 100% completion within 30 days                                           |
| 3   | Make missed visit reason a mandatory field in the care management system                                                                             | IT / Operations Manager      | Undocumented missed visits below 5% within 60 days                       |
| 4   | Brief Registered Manager and clinical leads on the 36.29% Palliative Care delivery rate. Conduct immediate caseload review                           | Registered Manager           | Review completed and escalation plan in place within 2 weeks             |
| 5   | Establish weekend on-call coordinator with emergency cover authority                                                                                 | Operations Manager           | Weekend missed rate within 2pp of weekday rate within 90 days            |

---

### Short-Term Actions - 30 to 90 Days

| #   | Action                                                                      | Owner                     | Success Measure                                             |
| --- | --------------------------------------------------------------------------- | ------------------------- | ----------------------------------------------------------- |
| 6   | Geographic zoning pilot in Bitterne and Hedge End                           | Scheduling Manager        | Travel Time % reduces from 37.88% toward 30% within 90 days |
| 7   | Visit duration recalibration by care category                               | Quality & Governance Lead | Short Visit Rate reduces from 27.55% toward 20%             |
| 8   | Workload cap per carer introduced. Redistribute from carers above 600 hours | Operations Manager        | Workload range narrows; burnout risk cohort below 600 hours |
| 9   | Named carer model: primary and backup assigned to each client               | Scheduling Manager        | Continuity Rate from 68.5% toward 75% within 90 days        |
| 10  | Structured note templates deployed in care management system                | IT / Quality Lead         | Data Quality Score from 69.09% toward 80% within 90 days    |

---

### Long-Term Actions - 90 Days and Beyond

| #   | Action                                                                                       | Owner                     | Success Measure                                        |
| --- | -------------------------------------------------------------------------------------------- | ------------------------- | ------------------------------------------------------ |
| 11  | Staffing needs analysis and board-level investment case for recruitment                      | HR / Operations Director  | Visit Completion Rate above 80% within 12 months       |
| 12  | Automated safeguarding keyword prompts in care management system                             | IT / Safeguarding Lead    | Safeguarding Compliance Rate above 90% within 6 months |
| 13  | CQC pre-inspection programme: mock inspection, Quality Improvement Plan, evidence portfolios | Quality & Governance Lead | CQC inspection rating of Good or above                 |
| 14  | Embed Power BI dashboards into weekly operational and monthly board reporting cycle          | All department leads      | Monthly KPI review embedded within 60 days             |

---

## Appendix - KPI Reference Table

| Metric                  | Result   | Target   | Gap      |
| ----------------------- | -------- | -------- | -------- |
| Visit Completion Rate   | 57.65%   | ≥ 95%    | -37.35pp |
| Care Delivery Rate      | 59.69%   | ≥ 95%    | -35.31pp |
| Missed Visit Rate       | 14.80%   | ≤ 2%     | +12.80pp |
| Short Visit Rate        | 27.55%   | ≤ 3%     | +24.55pp |
| Punctuality Rate        | 68.78%   | ≥ 90%    | -21.22pp |
| Utilisation Rate        | 62.12%   | ≥ 90%    | -27.88pp |
| Continuity Rate         | 68.5%    | ≥ 95%    | -26.5pp  |
| Travel Time %           | 37.88%   | ≤ 25%    | +12.88pp |
| Avg Travel Time         | 18.0 min | ≤ 15 min | +3.0 min |
| Safeguarding Compliance | 48.00%   | ≥ 98%    | -50pp    |
| Medication Recording    | 100.00%  | ≥ 98%    | Validate |
| Incident Rate           | 3.89%    | ≤ 2%     | +1.89pp  |
| Data Quality Score      | 69.09%   | ≥ 95%    | -25.91pp |
| Carer Notes Completion  | 73.17%   | ≥ 90%    | -16.83pp |
| Alert Compliance        | 73.22%   | ≥ 90%    | -16.78pp |

---

*Analysis based on 75,000 validated care visit records, January 2024 to December 2025.*
