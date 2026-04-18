
-- ============================================================================
-- DATA PROFILING 
-- ============================================================================
-- Project:  Care Delivery Performance & CQC Regulatory Readiness Analysis
-- Table:    stg_visits_raw (77,250 rows, 33 columns, all VARCHAR)
-- ============================================================================


-- ============================================================================
-- STEP 1: DOES DATA MEET EXPECTATIONS 
-- ============================================================================

-- 1.1  Total row count
-- EXPECTED: 77,250
SELECT COUNT(*) AS total_rows
FROM stg_visits_raw;


-- 1.2 Confirms all 33 columns loaded correctly. Since you loaded everything as VARCHAR
DESCRIBE stg_visits_raw;

-- 1.3  Actual data preview — first 30 rows
SELECT * FROM stg_visits_raw LIMIT 30;


-- 1.4  Total count vs Distinct count for important columns 
SELECT
    'Total Count'AS measure,
    SUM( CASE WHEN visit_id IS NOT NULL AND visit_id != '' THEN 1 ELSE 0 END )     AS visit_id,
	SUM( CASE WHEN client_id IS NOT NULL AND client_id != '' THEN 1 ELSE 0 END )     AS client_id,
    SUM( CASE WHEN client_name IS NOT NULL AND client_name != '' THEN 1 ELSE 0 END )       AS client_name,
    SUM( CASE WHEN client_gender IS NOT NULL AND client_gender != '' THEN 1 ELSE 0 END )     AS client_gender,
	SUM( CASE WHEN client_postcode IS NOT NULL AND client_postcode != '' THEN 1 ELSE 0 END )     AS client_postcode,
    SUM( CASE WHEN area_name IS NOT NULL AND area_name != '' THEN 1 ELSE 0 END )      AS area_name,
    SUM( CASE WHEN care_category IS NOT NULL AND care_category != '' THEN 1 ELSE 0 END )     AS care_category,
    SUM( CASE WHEN primary_condition IS NOT NULL AND primary_condition != '' THEN 1 ELSE 0 END )     AS primary_condition,
    SUM( CASE WHEN funding_type IS NOT NULL AND funding_type != '' THEN 1 ELSE 0 END )     AS funding_type,
    SUM( CASE WHEN carer_id IS NOT NULL AND carer_id != '' THEN 1 ELSE 0 END )      AS carer_id,
    SUM( CASE WHEN carer_name IS NOT NULL AND carer_name != '' THEN 1 ELSE 0 END )      AS carer_name,
    SUM( CASE WHEN visit_type IS NOT NULL AND visit_type != '' THEN 1 ELSE 0 END )       AS visit_type,
    SUM( CASE WHEN visit_status IS NOT NULL AND visit_status != '' THEN 1 ELSE 0 END )      AS visit_status,
    SUM( CASE WHEN visit_alert_sent IS NOT NULL AND visit_alert_sent != '' THEN 1 ELSE 0 END )      AS visit_alert_sent,
    SUM( CASE WHEN carer_notes IS NOT NULL AND carer_notes != '' THEN 1 ELSE 0 END )      AS carer_notes,
	SUM( CASE WHEN tasks_completed IS NOT NULL AND tasks_completed != '' THEN 1 ELSE 0 END )     AS tasks_completed,
    SUM( CASE WHEN medication_administered IS NOT NULL AND medication_administered != '' THEN 1 ELSE 0 END )      AS medication_administered,
	SUM( CASE WHEN client_mood IS NOT NULL AND client_mood != '' THEN 1 ELSE 0 END )     AS client_mood,
    SUM( CASE WHEN safeguarding_flag IS NOT NULL AND safeguarding_flag != '' THEN 1 ELSE 0 END )      AS safeguarding_flag,
    SUM( CASE WHEN incident_reported IS NOT NULL AND incident_reported != '' THEN 1 ELSE 0 END )     AS incident_reported,
    SUM( CASE WHEN continuity_flag IS NOT NULL AND continuity_flag != '' THEN 1 ELSE 0 END )         AS continuity_flag,
    SUM( CASE WHEN missed_visit_reason IS NOT NULL AND missed_visit_reason != '' THEN 1 ELSE 0 END )        AS missed_visit_reason
FROM stg_visits_raw

UNION ALL 

SELECT
    'Distinct Count'AS measure,
    COUNT(DISTINCT visit_id)                AS visit_id,
    COUNT(DISTINCT client_id)               AS client_id,
    COUNT(DISTINCT client_name)             AS client_name,
    COUNT(DISTINCT client_gender)           AS client_gender,
    COUNT(DISTINCT client_postcode)         AS client_postcode,
    COUNT(DISTINCT area_name)               AS area_name,
    COUNT(DISTINCT care_category)           AS care_category,
    COUNT(DISTINCT primary_condition)        AS primary_condition,
    COUNT(DISTINCT funding_type)            AS funding_type,
    COUNT(DISTINCT carer_id)                AS carer_id,
    COUNT(DISTINCT carer_name)              AS carer_name,
    COUNT(DISTINCT visit_type)              AS visit_type,
    COUNT(DISTINCT visit_status)            AS visit_status,
    COUNT(DISTINCT visit_alert_sent)        AS visit_alert_sent,
    COUNT(DISTINCT carer_notes)             AS carer_notes,
    COUNT(DISTINCT tasks_completed)         AS tasks_completed,
    COUNT(DISTINCT medication_administered) AS medication_administered,
    COUNT(DISTINCT client_mood)             AS client_mood,
    COUNT(DISTINCT safeguarding_flag)       AS safeguarding_flag,
    COUNT(DISTINCT incident_reported)       AS incident_reported,
    COUNT(DISTINCT continuity_flag)         AS continuity_flag,
    COUNT(DISTINCT missed_visit_reason)     AS missed_visit_reason
FROM stg_visits_raw;


-- ============================================================================
-- STEP 2: NULLS — Where is data missing?
-- ============================================================================

-- 2.1  NULL and empty string counts per column
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN visit_id IS NULL OR TRIM(visit_id) = '' THEN 1 ELSE 0 END)                AS visit_id_missing,
    SUM(CASE WHEN client_id IS NULL OR TRIM(client_id) = '' THEN 1 ELSE 0 END)              AS client_id_missing,
    SUM(CASE WHEN carer_id IS NULL OR TRIM(carer_id) = '' THEN 1 ELSE 0 END)                AS carer_id_missing,
    SUM(CASE WHEN client_name IS NULL OR TRIM(client_name) = '' THEN 1 ELSE 0 END)          AS client_name_missing,
    SUM(CASE WHEN client_gender IS NULL OR TRIM(client_gender) = '' THEN 1 ELSE 0 END)      AS client_gender_missing,
    SUM(CASE WHEN client_age IS NULL OR TRIM(client_age) = '' THEN 1 ELSE 0 END)            AS client_age_missing,
    SUM(CASE WHEN date_of_birth IS NULL OR TRIM(date_of_birth) = '' THEN 1 ELSE 0 END)      AS dob_missing,
    SUM(CASE WHEN client_postcode IS NULL OR TRIM(client_postcode) = '' THEN 1 ELSE 0 END)  AS postcode_missing,
    SUM(CASE WHEN area_name IS NULL OR TRIM(area_name) = '' THEN 1 ELSE 0 END)              AS area_missing,
    SUM(CASE WHEN care_category IS NULL OR TRIM(care_category) = '' THEN 1 ELSE 0 END)      AS care_category_missing,
    SUM(CASE WHEN primary_condition IS NULL OR TRIM(primary_condition) = '' THEN 1 ELSE 0 END) AS condition_missing,
    SUM(CASE WHEN funding_type IS NULL OR TRIM(funding_type) = '' THEN 1 ELSE 0 END)        AS funding_missing,
    SUM(CASE WHEN scheduled_date IS NULL OR TRIM(scheduled_date) = '' THEN 1 ELSE 0 END)    AS sched_date_missing,
    SUM(CASE WHEN scheduled_time IS NULL OR TRIM(scheduled_time) = '' THEN 1 ELSE 0 END)    AS sched_time_missing,
    SUM(CASE WHEN visit_type IS NULL OR TRIM(visit_type) = '' THEN 1 ELSE 0 END)            AS visit_type_missing,
    SUM(CASE WHEN planned_duration_mins IS NULL OR TRIM(planned_duration_mins) = '' THEN 1 ELSE 0 END) AS planned_dur_missing,
    SUM(CASE WHEN actual_clock_in IS NULL OR TRIM(actual_clock_in) = '' THEN 1 ELSE 0 END)  AS clock_in_missing,
    SUM(CASE WHEN actual_clock_out IS NULL OR TRIM(actual_clock_out) = '' THEN 1 ELSE 0 END) AS clock_out_missing,
    SUM(CASE WHEN actual_duration_mins IS NULL OR TRIM(actual_duration_mins) = '' THEN 1 ELSE 0 END) AS actual_dur_missing,
    SUM(CASE WHEN visit_status IS NULL OR TRIM(visit_status) = '' THEN 1 ELSE 0 END)        AS status_missing,
    SUM(CASE WHEN visit_alert_sent IS NULL OR TRIM(visit_alert_sent) = '' THEN 1 ELSE 0 END) AS alert_missing,
    SUM(CASE WHEN tasks_completed IS NULL OR TRIM(tasks_completed) = '' THEN 1 ELSE 0 END)  AS tasks_missing,
    SUM(CASE WHEN carer_notes IS NULL OR TRIM(carer_notes) = '' THEN 1 ELSE 0 END)          AS notes_missing,
    SUM(CASE WHEN medication_administered IS NULL OR TRIM(medication_administered) = '' THEN 1 ELSE 0 END) AS medication_missing,
    SUM(CASE WHEN client_mood IS NULL OR TRIM(client_mood) = '' THEN 1 ELSE 0 END)          AS mood_missing,
    SUM(CASE WHEN safeguarding_flag IS NULL OR TRIM(safeguarding_flag) = '' THEN 1 ELSE 0 END) AS safeguard_missing,
    SUM(CASE WHEN incident_reported IS NULL OR TRIM(incident_reported) = '' THEN 1 ELSE 0 END) AS incident_missing,
    SUM(CASE WHEN continuity_flag IS NULL OR TRIM(continuity_flag) = '' THEN 1 ELSE 0 END)  AS continuity_missing,
    SUM(CASE WHEN travel_time_mins IS NULL OR TRIM(travel_time_mins) = '' THEN 1 ELSE 0 END) AS travel_time_missing,
    SUM(CASE WHEN mileage IS NULL OR TRIM(mileage) = '' THEN 1 ELSE 0 END)                  AS mileage_missing,
    SUM(CASE WHEN missed_visit_reason IS NULL OR TRIM(missed_visit_reason) = '' THEN 1 ELSE 0 END) AS missed_reason_missing,
    SUM(CASE WHEN pay_rate_per_hour IS NULL OR TRIM(pay_rate_per_hour) = '' THEN 1 ELSE 0 END) AS pay_rate_missing,
    SUM(CASE WHEN carer_name IS NULL OR TRIM(carer_name) = '' THEN 1 ELSE 0 END)            AS carer_name_missing

FROM stg_visits_raw;

-- 2.2 six columns have the same count of nulls. are they correlated nulls? 

SELECT
    CASE WHEN actual_clock_in IS NULL OR TRIM(actual_clock_in) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS clock_in,
    CASE WHEN actual_clock_out IS NULL OR TRIM(actual_clock_out) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS clock_out,
    CASE WHEN actual_duration_mins IS NULL OR TRIM(actual_duration_mins) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS duration,
    CASE WHEN travel_time_mins IS NULL OR TRIM(travel_time_mins) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS travel,
    CASE WHEN mileage IS NULL OR TRIM(mileage) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS miles,
    CASE WHEN tasks_completed IS NULL OR TRIM(tasks_completed) = '' THEN 'NULL' ELSE 'HAS_VALUE' END AS tasks,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY clock_in, clock_out, duration, travel, miles, tasks
ORDER BY row_count DESC;


-- what is the visit_status of this rows?
SELECT visit_status,
       COUNT(*) AS row_count
FROM stg_visits_raw
WHERE (actual_clock_in IS NULL OR actual_clock_in = '')
    AND (actual_clock_out IS NULL OR actual_clock_out = '')
    AND (actual_duration_mins IS NULL OR actual_duration_mins = '')
    AND (tasks_completed IS NULL OR tasks_completed = '')
    AND (travel_time_mins IS NULL OR travel_time_mins = '')
    AND (mileage IS NULL OR mileage = '')
GROUP BY visit_status
ORDER BY row_count DESC;


-- ============================================================================
-- STEP 3: DUPLICATES — Is any data repeated?
-- ============================================================================

-- 3.1  Are there duplicate visit_ids?
SELECT
    COUNT(*)  AS total_rows,
    COUNT(DISTINCT visit_id)   AS distinct_visit_ids,
    COUNT(*) - COUNT(DISTINCT visit_id) AS duplicate_rows
FROM stg_visits_raw;

-- 3.2  How many visit_ids are duplicated, and how many copies of each?
SELECT 
     visit_id, 
     COUNT(*) AS copies
FROM stg_visits_raw
GROUP BY visit_id
HAVING COUNT(*) > 1
ORDER BY copies DESC
LIMIT 20;


-- 3.3  Are duplicates EXACT (identical across all columns)?
SELECT 
    visit_id, 
    COUNT(*) AS copies
FROM stg_visits_raw
GROUP BY
    visit_id, client_id, client_name, client_gender, client_age,
    date_of_birth, client_postcode, area_name, care_category,
    primary_condition, funding_type, carer_id, carer_name,
    visit_type, scheduled_date, scheduled_time, actual_clock_in,
    actual_clock_out, planned_duration_mins, actual_duration_mins,
    visit_status, visit_alert_sent, carer_notes, tasks_completed,
    medication_administered, client_mood, safeguarding_flag,
    incident_reported, travel_time_mins, mileage, continuity_flag,
    missed_visit_reason, pay_rate_per_hour
HAVING COUNT(*) > 1
ORDER BY copies DESC;


-- ============================================================================
-- STEP 4: CATEGORIES — What are the distinct values in text columns?
-- ============================================================================

-- 4.1  how many variants does visit_status have?
SELECT
    visit_status,
    LENGTH(visit_status) AS char_length,
    COUNT(*)      AS row_count
FROM stg_visits_raw
GROUP BY visit_status
ORDER BY row_count DESC;


-- 4.2  how many variants does funding_type have?
SELECT
    funding_type,
    LENGTH(funding_type)   AS char_length,
    COUNT(*)               AS row_count
FROM stg_visits_raw
GROUP BY funding_type
ORDER BY row_count DESC;

-- 4.3  how many variants does client_gender have?
SELECT
    client_gender,
    LENGTH(client_gender)  AS char_length,
    COUNT(*)               AS row_count
FROM stg_visits_raw
GROUP BY client_gender
ORDER BY row_count DESC;

-- 4.4  how many variants does care_category have?
SELECT 
      care_category, 
      COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY care_category
ORDER BY row_count DESC;

-- 4.5  how many variants does visit_type have?
SELECT 
     visit_type, 
     COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY visit_type
ORDER BY row_count DESC;

-- 4.6  how many variants does primary_condition have?
SELECT 
     primary_condition, 
     COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY primary_condition
ORDER BY row_count DESC;


-- 4.7 how many variants does visit_alert_sent have?
SELECT
    visit_alert_sent,
    LENGTH(visit_alert_sent)        AS char_length,
    COUNT(*)                        AS row_count
FROM stg_visits_raw
GROUP BY visit_alert_sent
ORDER BY row_count DESC;

-- 4.8  how many variants does client_mood have?
SELECT 
    client_mood, 
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY client_mood
ORDER BY row_count DESC;


-- 4.9  how many variants does safeguarding_flag have?
SELECT 
    safeguarding_flag, 
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY safeguarding_flag
ORDER BY row_count DESC;

-- 4.10 how many variants does incident_reported have?
SELECT 
     incident_reported, 
     COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY incident_reported
ORDER BY row_count DESC;


-- 4.11 how many variants does continuity_flag have?
SELECT 
     continuity_flag, 
     COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY continuity_flag
ORDER BY row_count DESC;


-- 4.12 missed_visit_reason
-- This should only be populated for non-completed visits.
SELECT 
    missed_visit_reason, 
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY missed_visit_reason
ORDER BY row_count DESC;


-- 4.13 area_name — all 25 areas
SELECT 
    area_name, 
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY area_name
ORDER BY row_count DESC;

-- 4.15 planned_duration_mins
SELECT 
     planned_duration_mins, 
     COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY planned_duration_mins
ORDER BY row_count DESC;


-- ============================================================================
-- STEP 5: DATES — Are date columns parseable and consistent?
-- ============================================================================


-- 5.1  What date formats exist in scheduled_date?  
SELECT
    CASE
        WHEN scheduled_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'       THEN 'YYYY-MM-DD'
        WHEN scheduled_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'       THEN 'XX/XX/YYYY'
        WHEN scheduled_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}'       THEN 'XX-XX-YYYY'
        WHEN scheduled_date IS NULL OR TRIM(scheduled_date) = ''         THEN 'NULL/EMPTY'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY format_pattern;


-- 5.2  scheduled_date — for the XX/XX/YYYY rows is it  DD/MM/YYYY or MM/DD/YYYY
SELECT
    CASE
        WHEN CAST(SUBSTRING_INDEX(scheduled_date, '/', 1) AS UNSIGNED) > 12 THEN 'DD/MM/YYYY (certain)'
        WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2), '/', -1) AS UNSIGNED) > 12 THEN 'MM/DD/YYYY (certain)'
        ELSE 'AMBIGUOUS (both parts <= 12)'
    END AS date_interpretation,
    COUNT(*) AS row_count
FROM stg_visits_raw
WHERE scheduled_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'
GROUP BY date_interpretation;

-- 5.3  Sample ambiguous dates for manual inspection
SELECT 
   visit_id, 
   scheduled_date, 
   area_name, 
   visit_status
FROM stg_visits_raw
WHERE scheduled_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}'
  AND CAST(SUBSTRING_INDEX(scheduled_date, '/', 1) AS UNSIGNED) <= 12
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2), '/', -1) AS UNSIGNED) <= 12
LIMIT 20;


-- 5.4  What date formats exist in actual_clock_in?
SELECT
    CASE
        WHEN actual_clock_in REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}'    THEN 'YYYY-MM-DD HH:MM'
        WHEN actual_clock_in REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'    THEN 'XX/XX/YYYY HH:MM'
        WHEN actual_clock_in IS NULL OR TRIM(actual_clock_in) = ''                       THEN 'NULL/EMPTY'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY format_pattern;


-- 5.5  What date formats exist in actual_clock_out?
SELECT
    CASE
        WHEN actual_clock_out REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}'   THEN 'YYYY-MM-DD HH:MM'
        WHEN actual_clock_out REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'   THEN 'XX/XX/YYYY HH:MM'
        WHEN actual_clock_out IS NULL OR TRIM(actual_clock_out) = ''                     THEN 'NULL/EMPTY'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY format_pattern;


-- 5.6  What date formats exist in date_of_birth?
SELECT
    CASE
        WHEN date_of_birth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'        THEN 'YYYY-MM-DD'
        WHEN date_of_birth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'        THEN 'XX/XX/YYYY'
        WHEN date_of_birth IS NULL OR TRIM(date_of_birth) = ''           THEN 'NULL/EMPTY'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY format_pattern;


-- ============================================================================
-- STEP 6: NUMBERS — Are numeric columns within reasonable ranges?
-- ============================================================================


-- 6.1  actual_duration_mins — range and distribution
SELECT
    MIN(CAST(actual_duration_mins AS DECIMAL(6,1)))  AS min_duration,
    MAX(CAST(actual_duration_mins AS DECIMAL(6,1)))  AS max_duration,
    AVG(CAST(actual_duration_mins AS DECIMAL(6,1)))  AS avg_duration,
    COUNT(*)                                          AS non_null_count
FROM stg_visits_raw
WHERE actual_duration_mins IS NOT NULL
  AND TRIM(actual_duration_mins) != ''
  AND actual_duration_mins REGEXP '^[0-9]+\.?[0-9]*$';


-- 6.2  Check for non-numeric values in actual_duration_mins
SELECT actual_duration_mins, COUNT(*) AS row_count
FROM stg_visits_raw
WHERE actual_duration_mins IS NOT NULL
  AND TRIM(actual_duration_mins) != ''
  AND actual_duration_mins NOT REGEXP '^-?[0-9]+\.?[0-9]*$'
GROUP BY actual_duration_mins;

-- 6.3  travel_time_mins — range check
SELECT
    MIN(CAST(travel_time_mins AS DECIMAL(6,1)))  AS min_travel,
    MAX(CAST(travel_time_mins AS DECIMAL(6,1)))  AS max_travel,
    AVG(CAST(travel_time_mins AS DECIMAL(6,1)))  AS avg_travel,
    COUNT(*)                                      AS non_null_count
FROM stg_visits_raw
WHERE travel_time_mins IS NOT NULL
  AND TRIM(travel_time_mins) != ''
  AND travel_time_mins REGEXP '^[0-9]+\.?[0-9]*$';


-- 6.4  mileage — range check
SELECT
    MIN(CAST(mileage AS DECIMAL(5,1)))  AS min_mileage,
    MAX(CAST(mileage AS DECIMAL(5,1)))  AS max_mileage,
    AVG(CAST(mileage AS DECIMAL(5,1)))  AS avg_mileage,
    COUNT(*)                             AS non_null_count
FROM stg_visits_raw
WHERE mileage IS NOT NULL
  AND TRIM(mileage) != ''
  AND mileage REGEXP '^[0-9]+\.?[0-9]*$';


-- 6.5  planned_duration_mins — confirm only expected values
SELECT 
    planned_duration_mins, 
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY planned_duration_mins
ORDER BY planned_duration_mins;


-- 6.9  client_age — range check
SELECT
    MIN(CAST(client_age AS UNSIGNED)) AS min_age,
    MAX(CAST(client_age AS UNSIGNED)) AS max_age,
    AVG(CAST(client_age AS UNSIGNED)) AS avg_age
FROM stg_visits_raw
WHERE client_age IS NOT NULL
  AND TRIM(client_age) != '';


-- ============================================================================
-- STEP 7: PLACEHOLDERS CHECKS  — blanks, dashes, or stand-ins
-- ============================================================================


-- 7.1  carer_notes — check for placeholder values
SELECT
    carer_notes,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY carer_notes
ORDER BY row_count DESC;

-- 7.2  carer_notes — search for safeguarding/welfare language 

SELECT
    visit_id,
    carer_notes,
    safeguarding_flag
FROM stg_visits_raw
WHERE carer_notes IS NOT NULL
  AND (
    LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%refused%'
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%cold%'
    OR LOWER(carer_notes) LIKE '%confused%'
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
  )
ORDER BY safeguarding_flag ASC
LIMIT 50;


-- 7.3  Quantify the safeguarding process gap
-- many rows shows safeguarding langiage and are not flaged 
SELECT
    safeguarding_flag,
    COUNT(*) AS row_count
FROM stg_visits_raw
WHERE carer_notes IS NOT NULL
  AND (
    LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%refused%'
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%cold%'
    OR LOWER(carer_notes) LIKE '%confused%'
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
  )
GROUP BY safeguarding_flag;

-- 7.4  missed_visit_reason — check for placeholders
SELECT 
   missed_visit_reason, 
   COUNT(*) AS row_count
FROM stg_visits_raw
WHERE missed_visit_reason IS NOT NULL
  AND TRIM(missed_visit_reason) != ''
GROUP BY missed_visit_reason
ORDER BY row_count DESC
LIMIT 20;


-- ============================================================================
-- STEP 8: RELATIONSHIPS — Do columns that should agree actually agree?
-- ============================================================================


-- 8.1  Referential consistency — client attributes across visits 
-- The same client_id should have the same gender, DOB, postcode, etc. in every row.
SELECT client_id,
       COUNT(DISTINCT client_name)      AS names,
       COUNT(DISTINCT client_gender)    AS genders,
       COUNT(DISTINCT date_of_birth)    AS dobs,
       COUNT(DISTINCT client_postcode)  AS postcodes,
       COUNT(DISTINCT area_name)        AS areas,
       COUNT(DISTINCT care_category)    AS categories,
       COUNT(DISTINCT primary_condition) AS conditions,
       COUNT(DISTINCT funding_type)     AS funding_types
FROM stg_visits_raw
GROUP BY client_id
HAVING genders > 1 OR dobs > 1 OR postcodes > 1 OR areas > 1
    OR funding_types > 1
ORDER BY client_id;

-- 8.2  Referential consistency — carer attributes
SELECT carer_id, COUNT(DISTINCT carer_name) AS names
FROM stg_visits_raw
GROUP BY carer_id
HAVING names > 1;


-- 8.3  visit_status vs missed_visit_reason — logical dependency
-- missed_visit_reason should only be populated for non-completed visits.
SELECT
    visit_status,
    CASE WHEN missed_visit_reason IS NOT NULL AND TRIM(missed_visit_reason) != ''
         THEN 'HAS_REASON' ELSE 'NO_REASON' END AS has_reason,
    COUNT(*) AS row_count
FROM stg_visits_raw
GROUP BY visit_status, has_reason
ORDER BY visit_status, has_reason;
