
-- ============================================================================
-- CREATE clean_visits — The Analytical-Ready Table
-- ============================================================================
-- Project:   Care Delivery Performance & CQC Regulatory Readiness Analysis
-- Source:    stg_visits_working (75,000 rows, cleaned, most columns still VARCHAR)
-- Target:    clean_visits (75,000 rows, only clean columns, proper data types)


-- 5 columns DROPPED:
--   client_age        → static value, calculate dynamically from DOB
--   date_of_birth     → replaced by date_of_birth_clean (parsed DATE)
--   scheduled_date    → replaced by scheduled_date_clean (parsed DATE)
--   actual_clock_in   → replaced by actual_clock_in_clean (parsed DATETIME)
--   actual_clock_out  → replaced by actual_clock_out_clean (parsed DATETIME)
--
-- 4 columns RENAMED (clean version takes the original name):
--   date_of_birth_clean      → date_of_birth
--   scheduled_date_clean     → scheduled_date
--   actual_clock_in_clean    → actual_clock_in
--   actual_clock_out_clean   → actual_clock_out

 
 
-- ============================================================================
-- STEP 1: CREATE THE TABLE WITH PROPER DATA TYPES
-- ============================================================================
 
 USE domiciliary_care_services;
 
DROP TABLE IF EXISTS clean_visits;
 
CREATE TABLE clean_visits (
 
    visit_id   VARCHAR(15)   NOT NULL PRIMARY KEY,
    client_id  VARCHAR(10)   NOT NULL,
    carer_id   VARCHAR(10)   NOT NULL,
    client_name       VARCHAR(30)   NOT NULL,
    client_gender     VARCHAR(10)   NOT NULL,         -- F, M, Unknown
    date_of_birth     DATE          NULL,             -- from date_of_birth_clean
    client_postcode   VARCHAR(10)   NULL,
    area_name         VARCHAR(25)   NOT NULL,
    care_category     VARCHAR(30)   NOT NULL,
    primary_condition VARCHAR(40)   NOT NULL,
    funding_type      VARCHAR(30)   NOT NULL,         -- 4 standard values
    carer_name        VARCHAR(30)   NOT NULL,
    visit_type        VARCHAR(30)   NOT NULL,
    scheduled_date    DATE          NOT NULL,         -- from scheduled_date_clean
    scheduled_time    VARCHAR(5)    NOT NULL,         -- HH:MM
    planned_duration_mins SMALLINT      NOT NULL,         -- 15, 30, 45, 60
    actual_clock_in       DATETIME      NULL,             -- from cactual_lock_in_clean
    actual_clock_out      DATETIME      NULL,             -- from actual_clock_out_clean
    actual_duration_mins  DECIMAL(5,1)  NULL,
    visit_status          VARCHAR(25)   NOT NULL,         -- 8 standard values
    visit_alert_sent      TINYINT       NOT NULL,         -- 0 or 1
    missed_visit_reason   VARCHAR(50)   NULL,
    tasks_completed           TEXT          NULL,
    medication_administered   TEXT          NULL,
    carer_notes               TEXT          NULL,
    client_mood               VARCHAR(15)   NULL,
    safeguarding_flag         TINYINT       NOT NULL,         -- original: what org recorded
    safeguarding_flag_derived   TINYINT       NOT NULL,         -- derived: what should have happened
    incident_reported         TINYINT       NOT NULL,         -- 0 or 1 -- original: what org recorded
    incident_reported_derived   TINYINT       NOT NULL,         -- 0 or 1 derived: what should have happened
    travel_time_mins          DECIMAL(5,1)  NULL,
    mileage                   DECIMAL(5,1)  NULL,
    travel_data_suspect       TINYINT  NOT NULL,
    continuity_flag           TINYINT       NOT NULL,         -- 0 or 1
    pay_rate_per_hour         DECIMAL(5,2)  NOT NULL
 
);
 
-- ============================================================================
-- STEP 2: POPULATE WITH TYPE-CAST DATA FROM stg_visits_working
-- =========================================================================== 
START TRANSACTION;
 
INSERT INTO clean_visits
SELECT
    visit_id,
    client_id,
    carer_id,
    client_name,
    client_gender,
    date_of_birth_clean  AS date_of_birth,
    client_postcode,
    area_name,
    care_category,
    primary_condition,
    funding_type,
    carer_name,
    visit_type,
    scheduled_date_clean  AS scheduled_date,
    scheduled_time,
    CAST(planned_duration_mins AS UNSIGNED)  AS planned_duration_mins,
    actual_clock_in_clean      AS actual_clock_in,
    actual_clock_out_clean     AS actual_clock_out,
    CAST(actual_duration_mins AS DECIMAL(5,1))   AS actual_duration_mins,
    visit_status,
    CAST(visit_alert_sent AS UNSIGNED)  AS visit_alert_sent,
    missed_visit_reason,
    tasks_completed,
    medication_administered,
    carer_notes,
    client_mood,
    CAST(safeguarding_flag AS UNSIGNED)                AS safeguarding_flag,
    CAST(safeguarding_flag_clean AS UNSIGNED)        AS safeguarding_flag_derived,
    CAST(incident_reported AS UNSIGNED)                AS incident_reported,
    CAST(incident_reported_clean AS UNSIGNED)           AS incident_reported_derived,
    CAST(travel_time_mins AS DECIMAL(5,1))             AS travel_time_mins,
    CAST(mileage AS DECIMAL(5,1))                      AS mileage,
    CAST(travel_data_suspect AS UNSIGNED)              AS travel_data_suspect,
    CAST(continuity_flag AS UNSIGNED)                  AS continuity_flag,
    CAST(pay_rate_per_hour AS DECIMAL(5,2))            AS pay_rate_per_hour
FROM stg_visits_working;
 
-- CHECK: row count before committing :EXPECTED: 75,000
SELECT COUNT(*) AS clean_visits_rows FROM clean_visits;
 
COMMIT;
 
 
-- ============================================================================
-- STEP 3: VALIDATION — DATA TYPES
-- ============================================================================

-- Column inventory with types
DESCRIBE clean_visits;
 
-- ============================================================================
-- STEP 4: VALIDATION — ROW COUNT AND KEY INTEGRITY
-- ============================================================================
 
-- Total rows EXPECTED: 75,000
SELECT COUNT(*) AS total_rows 
FROM clean_visits;
 
-- No duplicates
SELECT COUNT(*) - COUNT(DISTINCT visit_id) AS duplicate_count 
FROM clean_visits;

 
-- Entity counts match staging
SELECT
    COUNT(DISTINCT client_id) AS clients,     -- EXPECTED: 499
    COUNT(DISTINCT carer_id)  AS carers,      -- EXPECTED: 65
    COUNT(DISTINCT area_name) AS areas         -- EXPECTED: 25
FROM clean_visits;
 
 
-- ============================================================================
-- STEP 5: VALIDATION — CATEGORICAL COLUMNS
-- ============================================================================
 
-- visit_status — must be exactly 8 standardised values
SELECT visit_status, COUNT(*) AS cnt
FROM clean_visits
GROUP BY visit_status
ORDER BY cnt DESC;
 
-- funding_type — must be exactly 4 standardised values
SELECT funding_type, COUNT(*) AS cnt
FROM clean_visits
GROUP BY funding_type
ORDER BY cnt DESC;
 
-- client_gender — must be exactly 3 values
SELECT client_gender, COUNT(*) AS cnt
FROM clean_visits
GROUP BY client_gender
ORDER BY cnt DESC;
 
-- visit_alert_sent — must be exactly 2 values (1 and 0)
SELECT visit_alert_sent, COUNT(*) AS cnt
FROM clean_visits
GROUP BY visit_alert_sent;
 
-- 5e: care_category — should be 5 values
SELECT care_category, COUNT(*) AS cnt
FROM clean_visits
GROUP BY care_category
ORDER BY cnt DESC;
 
-- visit_type — should be 6 values
SELECT visit_type, COUNT(*) AS cnt
FROM clean_visits
GROUP BY visit_type
ORDER BY cnt DESC;
 
-- planned_duration_mins — should be 4 values (now as SMALLINT)
SELECT planned_duration_mins, COUNT(*) AS cnt
FROM clean_visits
GROUP BY planned_duration_mins
ORDER BY planned_duration_mins;
 
 
-- ============================================================================
-- STEP 6: VALIDATION — DATE AND DATETIME COLUMNS
-- ============================================================================
 
-- scheduled_date — no NULLs, correct range
SELECT
    COUNT(*)                            AS total,
    SUM(CASE WHEN scheduled_date IS NULL THEN 1 ELSE 0 END) AS null_count,
    MIN(scheduled_date)                 AS earliest,
    MAX(scheduled_date)                 AS latest
FROM clean_visits;

 
-- date_of_birth — no NULLs
SELECT
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS null_count,
    MIN(date_of_birth) AS earliest_dob,
    MAX(date_of_birth) AS latest_dob
FROM clean_visits;

 
-- actual_clock_in/out — NULLs only for non-completed visits
SELECT
    SUM(CASE WHEN actual_clock_in IS NULL
              AND visit_status IN ('Completed', 'Completed Late', 'Short Visit')
         THEN 1 ELSE 0 END)    AS completed_missing_clock_in,
    SUM(CASE WHEN actual_clock_out IS NULL
              AND visit_status IN ('Completed', 'Completed Late', 'Short Visit')
         THEN 1 ELSE 0 END)    AS completed_missing_clock_out
FROM clean_visits;

 
-- clock_out after clock_in
SELECT COUNT(*) AS clock_out_before_in
FROM clean_visits
WHERE actual_clock_in IS NOT NULL
  AND actual_clock_out IS NOT NULL
  AND actual_clock_out < actual_clock_in;
-- EXPECTED: 0
 
 
-- ============================================================================
-- STEP 7: VALIDATION — NUMERIC COLUMNS (correct after CAST)
-- ============================================================================
 
-- actual_duration_mins — range check
SELECT
    MIN(actual_duration_mins)  AS min_dur,     -- EXPECTED: ~3.0
    MAX(actual_duration_mins)  AS max_dur,     -- EXPECTED: ~360.0
    AVG(actual_duration_mins)  AS avg_dur,     -- EXPECTED: ~33.5
    SUM(CASE WHEN actual_duration_mins = 0 THEN 1 ELSE 0 END) AS zero_count
FROM clean_visits
WHERE actual_duration_mins IS NOT NULL;
 
-- travel_time_mins — range check
SELECT
    MIN(travel_time_mins)  AS min_tt,          -- EXPECTED: ~2.0
    MAX(travel_time_mins)  AS max_tt,          -- EXPECTED: ~51.0
    AVG(travel_time_mins)  AS avg_tt           -- EXPECTED: ~17.6
FROM clean_visits
WHERE travel_time_mins IS NOT NULL;
 
--  mileage — range check
SELECT
    MIN(mileage)  AS min_mi,                   -- EXPECTED: ~0.5
    MAX(mileage)  AS max_mi,                   -- EXPECTED: ~50.5
    AVG(mileage)  AS avg_mi                    -- EXPECTED: ~4.0
FROM clean_visits
WHERE mileage IS NOT NULL;
 
--  pay_rate_per_hour — range check
SELECT
    MIN(pay_rate_per_hour)  AS min_rate,       -- EXPECTED: ~10.42
    MAX(pay_rate_per_hour)  AS max_rate,       -- EXPECTED: ~21.75
    AVG(pay_rate_per_hour)  AS avg_rate        -- EXPECTED: ~12.96
FROM clean_visits;
 
-- planned_duration_mins — confirm only valid values after CAST
SELECT planned_duration_mins, COUNT(*) AS cnt
FROM clean_visits
GROUP BY planned_duration_mins
ORDER BY planned_duration_mins;

 
-- ============================================================================
-- STEP 8: VALIDATION — TINYINT FLAGS (no silent cast failures)
-- ============================================================================
 
-- All TINYINT flags should only contain 0 or 1
SELECT 'visit_alert_sent' AS flag_column,
       MIN(visit_alert_sent) AS min_val, MAX(visit_alert_sent) AS max_val
FROM clean_visits
UNION ALL
SELECT 'safeguarding_flag',
       MIN(safeguarding_flag), MAX(safeguarding_flag)
FROM clean_visits
UNION ALL
SELECT 'safeguarding_flag_derived',
       MIN(safeguarding_flag_derived), MAX(safeguarding_flag_derived)
FROM clean_visits
UNION ALL
SELECT 'incident_reported',
       MIN(incident_reported), MAX(incident_reported)
FROM clean_visits
UNION ALL
SELECT 'incident_reported_derived',
       MIN(incident_reported_derived), MAX(incident_reported_derived)
FROM clean_visits
UNION ALL
SELECT 'continuity_flag',
       MIN(continuity_flag), MAX(continuity_flag)
UNION ALL
SELECT 'travel_data_suspect',
       MIN(travel_data_suspect), MAX(travel_data_suspect)
       
FROM clean_visits;

 
 
-- ============================================================================
-- STEP 9: VALIDATION — PLACEHOLDER REMOVAL CARRIED FORWARD
-- ============================================================================
 
-- No dash placeholders in carer notes
SELECT
    SUM(CASE WHEN TRIM(carer_notes) = '-' THEN 1 ELSE 0 END)            AS note_dashes
FROM clean_visits;

-- ============================================================================
-- STEP 10: VALIDATION — DERIVED FLAGS CONSISTENCY
-- ============================================================================
 
-- incident_reported_derived should be 1 wherever safeguarding_flag_derived = 1
SELECT COUNT(*) AS flag_but_not_derived
FROM clean_visits
WHERE safeguarding_flag_derived = 1
  AND incident_reported_derived = 0;
 
-- The safeguarding gap — headline CQC finding
SELECT
    safeguarding_flag         AS original,
    safeguarding_flag_derived AS derived,
    COUNT(*)                  AS row_count
FROM clean_visits
GROUP BY safeguarding_flag, safeguarding_flag_derived
ORDER BY safeguarding_flag, safeguarding_flag_derived;

 
-- ============================================================================
-- STEP 11: VALIDATION — CROSS-TABLE RECONCILIATION
-- ============================================================================
 
 -- EXPECTED: both rows should be identical across all columns.
SELECT
    'stg_visits_working' AS source,
    COUNT(*)             AS total_rows,
    COUNT(DISTINCT visit_id) AS distinct_visits,
    COUNT(DISTINCT client_id) AS distinct_clients,
    COUNT(DISTINCT carer_id) AS distinct_carers,
    SUM(CASE WHEN visit_status = 'Completed' THEN 1 ELSE 0 END) AS completed_count
FROM stg_visits_working
UNION ALL
SELECT
    'clean_visits',
    COUNT(*),
    COUNT(DISTINCT visit_id),
    COUNT(DISTINCT client_id),
    COUNT(DISTINCT carer_id),
    SUM(CASE WHEN visit_status = 'Completed' THEN 1 ELSE 0 END)
FROM clean_visits;

 
 
-- ============================================================================
-- COMPLETE — DATABASE LAYER SUMMARY
-- ============================================================================
-- database  has 3 tables:
--
--   stg_visits_raw       77,250 rows  All VARCHAR     Untouched archive
--   stg_visits_working   75,000 rows  All VARCHAR     Cleaned, both old + new columns
--   clean_visits         75,000 rows  Proper types    Only clean columns, production names
--
-- 
-- ============================================================================