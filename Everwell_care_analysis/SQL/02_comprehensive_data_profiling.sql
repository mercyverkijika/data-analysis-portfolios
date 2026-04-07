-- ====================================================================================================
-- COMPREHENSIVE DATA PROFILING ANALYSIS
-- ====================================================================================================
-- Author: Senior Data Analyst
-- Date: March 30, 2026
-- Purpose: Systematic data quality assessment for domiciliary care analytics
-- Database: domiciliary_care_analytics
-- ====================================================================================================

USE domiciliary_care_analytics;

-- ====================================================================================================
-- PHASE 1: DATA STRUCTURE ANALYSIS
-- ====================================================================================================
-- Objective: Understand table schemas, data types, constraints, and relationships
-- ====================================================================================================

-- STEP 1.1: TABLE SCHEMA OVERVIEW
-- Purpose: Get high-level view of all tables and their record counts
-- Business Value: Understand data volume and scope before detailed analysis
-- ====================================================================================================

SELECT
    'Table Overview' AS analysis_type,
    t.TABLE_NAME,
    t.TABLE_ROWS AS estimated_rows,
    t.DATA_LENGTH / 1024 / 1024 AS size_mb,
    t.TABLE_COMMENT
FROM information_schema.TABLES t
WHERE t.TABLE_SCHEMA = 'domiciliary_care_analytics'
    AND t.TABLE_NAME LIKE 'stg_%'
ORDER BY t.TABLE_ROWS DESC;

-- STEP 1.2: COLUMN METADATA ANALYSIS
-- Purpose: Analyze column data types, nullability, and constraints
-- Business Value: Identify potential data type issues and constraint violations
-- ====================================================================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'domiciliary_care_analytics'
    AND TABLE_NAME LIKE 'stg_%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- STEP 1.3: PRIMARY KEY AND INDEX ANALYSIS
-- Purpose: Understand data integrity constraints and performance optimization
-- Business Value: Identify potential duplicate handling and query performance issues
-- ====================================================================================================

-- Primary Key Analysis
SELECT
    t.TABLE_NAME,
    k.COLUMN_NAME,
    k.CONSTRAINT_NAME,
    'PRIMARY KEY' AS constraint_type
FROM information_schema.TABLE_CONSTRAINTS t
JOIN information_schema.KEY_COLUMN_USAGE k
    ON t.CONSTRAINT_NAME = k.CONSTRAINT_NAME
    AND t.TABLE_SCHEMA = k.TABLE_SCHEMA
WHERE t.TABLE_SCHEMA = 'domiciliary_care_analytics'
    AND t.CONSTRAINT_TYPE = 'PRIMARY KEY'
    AND t.TABLE_NAME LIKE 'stg_%'
ORDER BY t.TABLE_NAME;

-- Index Analysis
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'domiciliary_care_analytics'
    AND TABLE_NAME LIKE 'stg_%'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ====================================================================================================
-- PHASE 2: DATA COMPLETENESS ANALYSIS
-- ====================================================================================================
-- Objective: Assess missing data patterns and completeness ratios
-- ====================================================================================================

-- STEP 2.1: OVERALL COMPLETENESS METRICS
-- Purpose: Calculate null/missing value percentages across all columns
-- Business Value: Identify critical data gaps that could impact analysis
-- ====================================================================================================

SELECT
    'Data Completeness Overview' AS analysis_type,
    COUNT(*) AS total_records,
    SUM(CASE WHEN visit_id IS NULL OR visit_id = '' THEN 1 ELSE 0 END) AS visit_id_nulls,
    ROUND(100.0 * SUM(CASE WHEN visit_id IS NULL OR visit_id = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS visit_id_completeness_pct,

    SUM(CASE WHEN client_id IS NULL OR client_id = '' THEN 1 ELSE 0 END) AS client_id_nulls,
    ROUND(100.0 * SUM(CASE WHEN client_id IS NULL OR client_id = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS client_id_completeness_pct,

    SUM(CASE WHEN carer_id IS NULL OR carer_id = '' THEN 1 ELSE 0 END) AS carer_id_nulls,
    ROUND(100.0 * SUM(CASE WHEN carer_id IS NULL OR carer_id = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS carer_id_completeness_pct,

    SUM(CASE WHEN scheduled_date IS NULL OR scheduled_date = '' THEN 1 ELSE 0 END) AS scheduled_date_nulls,
    ROUND(100.0 * SUM(CASE WHEN scheduled_date IS NULL OR scheduled_date = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS scheduled_date_completeness_pct,

    SUM(CASE WHEN visit_status IS NULL OR visit_status = '' THEN 1 ELSE 0 END) AS visit_status_nulls,
    ROUND(100.0 * SUM(CASE WHEN visit_status IS NULL OR visit_status = '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS visit_status_completeness_pct

FROM stg_visits_working;

-- STEP 2.2: COMPLETENESS BY VISIT STATUS
-- Purpose: Analyze if completeness varies by visit status (completed vs cancelled)
-- Business Value: Understand if data quality issues are status-dependent
-- ====================================================================================================

SELECT
    visit_status,
    COUNT(*) AS total_visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS status_distribution_pct,

    -- Key field completeness by status
    ROUND(100.0 * SUM(CASE WHEN client_id IS NOT NULL AND client_id != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS client_id_complete_pct,
    ROUND(100.0 * SUM(CASE WHEN carer_id IS NOT NULL AND carer_id != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS carer_id_complete_pct,
    ROUND(100.0 * SUM(CASE WHEN actual_clock_in IS NOT NULL AND actual_clock_in != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS clock_in_complete_pct,
    ROUND(100.0 * SUM(CASE WHEN actual_clock_out IS NOT NULL AND actual_clock_out != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS clock_out_complete_pct

FROM stg_visits_working
GROUP BY visit_status
ORDER BY total_visits DESC;

-- STEP 2.3: MISSING DATA PATTERNS OVER TIME
-- Purpose: Identify if data completeness issues are trending or seasonal
-- Business Value: Determine if data quality is improving or deteriorating
-- ====================================================================================================

SELECT
    DATE_FORMAT(scheduled_date, '%Y-%m') AS month_year,
    COUNT(*) AS total_scheduled_visits,

    -- Completeness metrics by month
    ROUND(100.0 * SUM(CASE WHEN client_id IS NOT NULL AND client_id != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS client_id_complete_pct,
    ROUND(100.0 * SUM(CASE WHEN carer_id IS NOT NULL AND carer_id != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS carer_id_complete_pct,
    ROUND(100.0 * SUM(CASE WHEN actual_duration_mins IS NOT NULL AND actual_duration_mins != '' THEN 1 ELSE 0 END) / COUNT(*), 2) AS duration_complete_pct

FROM stg_visits_working
WHERE scheduled_date IS NOT NULL AND scheduled_date != ''
GROUP BY DATE_FORMAT(scheduled_date, '%Y-%m')
ORDER BY month_year DESC
LIMIT 12; -- Last 12 months

-- ====================================================================================================
-- PHASE 3: DATA QUALITY ANALYSIS
-- ====================================================================================================
-- Objective: Identify invalid, duplicate, and out-of-range values
-- ====================================================================================================

-- STEP 3.1: DUPLICATE RECORD ANALYSIS
-- Purpose: Identify potential duplicate visits that could skew analysis
-- Business Value: Prevent double-counting of visits in reporting
-- ====================================================================================================

-- Exact duplicates across all columns
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT_WS('|', visit_id, client_id, carer_id, scheduled_date, scheduled_time)) AS unique_visit_combinations,
    COUNT(*) - COUNT(DISTINCT CONCAT_WS('|', visit_id, client_id, carer_id, scheduled_date, scheduled_time)) AS duplicate_combinations
FROM stg_visits_working;

-- Detailed duplicate analysis
WITH duplicate_check AS (
    SELECT
        CONCAT_WS('|', client_id, carer_id, scheduled_date, scheduled_time) AS visit_key,
        COUNT(*) AS occurrence_count,
        GROUP_CONCAT(DISTINCT visit_id ORDER BY visit_id) AS visit_ids,
        GROUP_CONCAT(DISTINCT visit_status ORDER BY visit_status) AS statuses
    FROM stg_visits_working
    GROUP BY CONCAT_WS('|', client_id, carer_id, scheduled_date, scheduled_time)
    HAVING COUNT(*) > 1
)
SELECT
    'Potential Duplicate Visits' AS issue_type,
    COUNT(*) AS duplicate_groups,
    SUM(occurrence_count) AS total_duplicate_records,
    AVG(occurrence_count) AS avg_duplicates_per_group
FROM duplicate_check;

-- STEP 3.2: DATA TYPE VALIDATION
-- Purpose: Identify values that don't match expected data types
-- Business Value: Ensure data integrity for downstream processing
-- ====================================================================================================

-- Numeric field validation
SELECT
    'Numeric Field Validation' AS validation_type,
    COUNT(*) AS total_records,

    -- Age validation (should be positive, reasonable range)
    SUM(CASE WHEN client_age REGEXP '^[0-9]+$' AND CAST(client_age AS UNSIGNED) BETWEEN 18 AND 120 THEN 1 ELSE 0 END) AS valid_ages,
    SUM(CASE WHEN client_age NOT REGEXP '^[0-9]+$' OR CAST(client_age AS UNSIGNED) NOT BETWEEN 18 AND 120 THEN 1 ELSE 0 END) AS invalid_ages,

    -- Duration validation (should be positive, reasonable range)
    SUM(CASE WHEN planned_duration_mins REGEXP '^[0-9]+$' AND CAST(planned_duration_mins AS UNSIGNED) BETWEEN 15 AND 480 THEN 1 ELSE 0 END) AS valid_planned_duration,
    SUM(CASE WHEN planned_duration_mins NOT REGEXP '^[0-9]+$' OR CAST(planned_duration_mins AS UNSIGNED) NOT BETWEEN 15 AND 480 THEN 1 ELSE 0 END) AS invalid_planned_duration,

    SUM(CASE WHEN actual_duration_mins REGEXP '^[0-9]+$' AND CAST(actual_duration_mins AS UNSIGNED) BETWEEN 0 AND 480 THEN 1 ELSE 0 END) AS valid_actual_duration,
    SUM(CASE WHEN actual_duration_mins NOT REGEXP '^[0-9]+$' OR CAST(actual_duration_mins AS UNSIGNED) NOT BETWEEN 0 AND 480 THEN 1 ELSE 0 END) AS invalid_actual_duration

FROM stg_visits_working;

-- STEP 3.3: CATEGORICAL VALUE VALIDATION
-- Purpose: Check for invalid or unexpected categorical values
-- Business Value: Ensure consistent categorization for analysis
-- ====================================================================================================

-- Gender validation
SELECT
    client_gender,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM stg_visits_working
WHERE client_gender IS NOT NULL AND client_gender != ''
GROUP BY client_gender
ORDER BY frequency DESC;

-- Visit status validation
SELECT
    visit_status,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM stg_visits_working
WHERE visit_status IS NOT NULL AND visit_status != ''
GROUP BY visit_status
ORDER BY frequency DESC;

-- Care category validation
SELECT
    care_category,
    COUNT(*) AS frequency,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM stg_visits_working
WHERE care_category IS NOT NULL AND care_category != ''
GROUP BY care_category
ORDER BY frequency DESC;

-- STEP 3.4: DATE/TIME VALIDATION
-- Purpose: Identify invalid dates and time inconsistencies
-- Business Value: Ensure temporal data integrity for scheduling analysis
-- ====================================================================================================

SELECT
    'Date/Time Validation' AS validation_type,
    COUNT(*) AS total_records,

    -- Date format validation
    SUM(CASE WHEN scheduled_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 1 ELSE 0 END) AS valid_date_format,
    SUM(CASE WHEN scheduled_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND scheduled_date IS NOT NULL AND scheduled_date != '' THEN 1 ELSE 0 END) AS invalid_date_format,

    -- Future date check
    SUM(CASE WHEN scheduled_date > CURDATE() THEN 1 ELSE 0 END) AS future_scheduled_dates,

    -- Clock in/out consistency
    SUM(CASE WHEN actual_clock_in IS NOT NULL AND actual_clock_out IS NOT NULL AND actual_clock_in > actual_clock_out THEN 1 ELSE 0 END) AS clock_in_after_clock_out,

    -- Duration vs actual time validation
    SUM(CASE WHEN actual_clock_in IS NOT NULL AND actual_clock_out IS NOT NULL
                  AND TIMESTAMPDIFF(MINUTE, actual_clock_in, actual_clock_out) != CAST(actual_duration_mins AS UNSIGNED) THEN 1 ELSE 0 END) AS duration_mismatch

FROM stg_visits_working;

-- ====================================================================================================
-- PHASE 4: DATA DISTRIBUTION ANALYSIS
-- ====================================================================================================
-- Objective: Understand value distributions, ranges, and statistical properties
-- ====================================================================================================

-- STEP 4.1: NUMERIC FIELD STATISTICS
-- Purpose: Analyze distributions of numeric fields for outliers and patterns
-- Business Value: Identify unusual values that may indicate data entry errors
-- ====================================================================================================

SELECT
    'Numeric Field Statistics' AS analysis_type,

    -- Client Age Statistics
    COUNT(client_age) AS age_count,
    ROUND(AVG(CAST(client_age AS DECIMAL(5,2))), 2) AS avg_age,
    ROUND(MIN(CAST(client_age AS DECIMAL(5,2))), 2) AS min_age,
    ROUND(MAX(CAST(client_age AS DECIMAL(5,2))), 2) AS max_age,
    ROUND(STDDEV(CAST(client_age AS DECIMAL(5,2))), 2) AS stddev_age,

    -- Planned Duration Statistics
    COUNT(planned_duration_mins) AS planned_duration_count,
    ROUND(AVG(CAST(planned_duration_mins AS DECIMAL(5,2))), 2) AS avg_planned_duration,
    ROUND(MIN(CAST(planned_duration_mins AS DECIMAL(5,2))), 2) AS min_planned_duration,
    ROUND(MAX(CAST(planned_duration_mins AS DECIMAL(5,2))), 2) AS max_planned_duration,

    -- Actual Duration Statistics
    COUNT(actual_duration_mins) AS actual_duration_count,
    ROUND(AVG(CAST(actual_duration_mins AS DECIMAL(5,2))), 2) AS avg_actual_duration,
    ROUND(MIN(CAST(actual_duration_mins AS DECIMAL(5,2))), 2) AS min_actual_duration,
    ROUND(MAX(CAST(actual_duration_mins AS DECIMAL(5,2))), 2) AS max_actual_duration

FROM stg_visits_working
WHERE client_age REGEXP '^[0-9]+$' AND CAST(client_age AS UNSIGNED) BETWEEN 18 AND 120
    AND planned_duration_mins REGEXP '^[0-9]+$' AND CAST(planned_duration_mins AS UNSIGNED) BETWEEN 15 AND 480
    AND actual_duration_mins REGEXP '^[0-9]+$' AND CAST(actual_duration_mins AS UNSIGNED) BETWEEN 0 AND 480;

-- STEP 4.2: OUTLIER DETECTION
-- Purpose: Identify extreme values that may be data errors
-- Business Value: Flag potential data quality issues for review
-- ====================================================================================================

-- Age outliers (using IQR method)
WITH age_stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CAST(client_age AS DECIMAL)) AS q1_age,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CAST(client_age AS DECIMAL)) AS q3_age
    FROM stg_visits_working
    WHERE client_age REGEXP '^[0-9]+$' AND CAST(client_age AS UNSIGNED) BETWEEN 18 AND 120
),
age_iqr AS (
    SELECT q1_age, q3_age, (q3_age - q1_age) AS iqr FROM age_stats
)
SELECT
    'Age Outliers' AS outlier_type,
    COUNT(CASE WHEN CAST(v.client_age AS DECIMAL) < (a.q1_age - 1.5 * a.iqr) THEN 1 END) AS low_outliers,
    COUNT(CASE WHEN CAST(v.client_age AS DECIMAL) > (a.q3_age + 1.5 * a.iqr) THEN 1 END) AS high_outliers,
    MIN(CASE WHEN CAST(v.client_age AS DECIMAL) < (a.q1_age - 1.5 * a.iqr) THEN CAST(v.client_age AS DECIMAL) END) AS min_outlier_age,
    MAX(CASE WHEN CAST(v.client_age AS DECIMAL) > (a.q3_age + 1.5 * a.iqr) THEN CAST(v.client_age AS DECIMAL) END) AS max_outlier_age
FROM stg_visits_working v
CROSS JOIN age_iqr a
WHERE v.client_age REGEXP '^[0-9]+$' AND CAST(v.client_age AS UNSIGNED) BETWEEN 18 AND 120;

-- STEP 4.3: FREQUENCY DISTRIBUTION ANALYSIS
-- Purpose: Understand distribution patterns of categorical variables
-- Business Value: Identify dominant categories and potential data skew
-- ====================================================================================================

-- Top 10 clients by visit count
SELECT
    'Top Clients by Visit Volume' AS analysis_type,
    client_id,
    client_name,
    COUNT(*) AS visit_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_visits
FROM stg_visits_working
WHERE client_id IS NOT NULL AND client_id != ''
GROUP BY client_id, client_name
ORDER BY visit_count DESC
LIMIT 10;

-- Top 10 carers by visit count
SELECT
    'Top Carers by Visit Volume' AS analysis_type,
    carer_id,
    carer_name,
    COUNT(*) AS visit_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_visits
FROM stg_visits_working
WHERE carer_id IS NOT NULL AND carer_id != ''
GROUP BY carer_id, carer_name
ORDER BY visit_count DESC
LIMIT 10;

-- ====================================================================================================
-- PHASE 5: DATA CONSISTENCY ANALYSIS
-- ====================================================================================================
-- Objective: Validate cross-field relationships and business rules
-- ====================================================================================================

-- STEP 5.1: BUSINESS RULE VALIDATION
-- Purpose: Check if data conforms to expected business logic
-- Business Value: Identify process violations or system issues
-- ====================================================================================================

SELECT
    'Business Rule Validation' AS validation_type,
    COUNT(*) AS total_records,

    -- Rule 1: Completed visits should have clock in/out times
    SUM(CASE WHEN visit_status = 'Completed' AND (actual_clock_in IS NULL OR actual_clock_out IS NULL) THEN 1 ELSE 0 END) AS completed_visits_missing_times,

    -- Rule 2: Actual duration should be calculable from clock times
    SUM(CASE WHEN actual_clock_in IS NOT NULL AND actual_clock_out IS NOT NULL
                  AND TIMESTAMPDIFF(MINUTE, actual_clock_in, actual_clock_out) != CAST(COALESCE(actual_duration_mins, 0) AS UNSIGNED) THEN 1 ELSE 0 END) AS duration_calculation_mismatch,

    -- Rule 3: Scheduled time should be reasonable (between 6 AM and 10 PM)
    SUM(CASE WHEN scheduled_time IS NOT NULL AND scheduled_time != ''
                  AND TIME(scheduled_time) NOT BETWEEN '06:00:00' AND '22:00:00' THEN 1 ELSE 0 END) AS unreasonable_scheduled_times,

    -- Rule 4: Client age should be consistent with date of birth
    SUM(CASE WHEN date_of_birth IS NOT NULL AND client_age IS NOT NULL
                  AND TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) != CAST(client_age AS UNSIGNED) THEN 1 ELSE 0 END) AS age_dob_inconsistency

FROM stg_visits_working;

-- STEP 5.2: CROSS-FIELD CONSISTENCY CHECKS
-- Purpose: Validate relationships between related fields
-- Business Value: Ensure data integrity across related attributes
-- ====================================================================================================

-- Visit duration consistency (actual vs planned)
SELECT
    'Duration Consistency Analysis' AS analysis_type,
    COUNT(*) AS total_completed_visits,

    -- Duration variance analysis
    ROUND(AVG(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)), 2) AS avg_duration_variance_mins,
    ROUND(STDDEV(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)), 2) AS stddev_duration_variance,

    -- Duration accuracy categories
    SUM(CASE WHEN ABS(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)) <= 15 THEN 1 ELSE 0 END) AS within_15_mins,
    SUM(CASE WHEN ABS(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)) > 15 AND ABS(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)) <= 30 THEN 1 ELSE 0 END) AS within_30_mins,
    SUM(CASE WHEN ABS(CAST(actual_duration_mins AS DECIMAL) - CAST(planned_duration_mins AS DECIMAL)) > 30 THEN 1 ELSE 0 END) AS over_30_mins_variance

FROM stg_visits_working
WHERE visit_status = 'Completed'
    AND actual_duration_mins REGEXP '^[0-9]+$'
    AND planned_duration_mins REGEXP '^[0-9]+$'
    AND CAST(actual_duration_mins AS UNSIGNED) > 0
    AND CAST(planned_duration_mins AS UNSIGNED) > 0;

-- ====================================================================================================
-- PHASE 6: DATA RELATIONSHIPS ANALYSIS
-- ====================================================================================================
-- Objective: Validate referential integrity and relationship consistency
-- ====================================================================================================

-- STEP 6.1: REFERENTIAL INTEGRITY CHECKS
-- Purpose: Ensure foreign key relationships are valid
-- Business Value: Identify orphaned records that could cause join issues
-- ====================================================================================================

-- Check if all client_ids in visits exist in clients table
SELECT
    'Referential Integrity Check' AS validation_type,
    v.total_visits,
    c.total_clients,
    (v.total_visits - COALESCE(m.matched_visits, 0)) AS orphaned_visits,
    ROUND(100.0 * (v.total_visits - COALESCE(m.matched_visits, 0)) / v.total_visits, 2) AS orphaned_visit_pct
FROM (
    SELECT COUNT(*) AS total_visits FROM stg_visits_working
    WHERE client_id IS NOT NULL AND client_id != ''
) v
CROSS JOIN (
    SELECT COUNT(*) AS total_clients FROM stg_clients_raw
    WHERE client_id IS NOT NULL AND client_id != ''
) c
LEFT JOIN (
    SELECT COUNT(DISTINCT v.client_id) AS matched_visits
    FROM stg_visits_working v
    JOIN stg_clients_raw c ON v.client_id = c.client_id
    WHERE v.client_id IS NOT NULL AND v.client_id != ''
) m ON 1=1;

-- Check if all carer_ids in visits exist in carers table
SELECT
    'Carer Referential Integrity' AS validation_type,
    v.total_visits_with_carers,
    c.total_carers,
    (v.total_visits_with_carers - COALESCE(m.matched_visits, 0)) AS orphaned_carer_visits,
    ROUND(100.0 * (v.total_visits_with_carers - COALESCE(m.matched_visits, 0)) / v.total_visits_with_carers, 2) AS orphaned_carer_visit_pct
FROM (
    SELECT COUNT(*) AS total_visits_with_carers FROM stg_visits_working
    WHERE carer_id IS NOT NULL AND carer_id != ''
) v
CROSS JOIN (
    SELECT COUNT(*) AS total_carers FROM stg_carers_raw
    WHERE carer_id IS NOT NULL AND carer_id != ''
) c
LEFT JOIN (
    SELECT COUNT(DISTINCT v.carer_id) AS matched_visits
    FROM stg_visits_working v
    JOIN stg_carers_raw c ON v.carer_id = c.carer_id
    WHERE v.carer_id IS NOT NULL AND v.carer_id != ''
) m ON 1=1;

-- STEP 6.2: RELATIONSHIP CONSISTENCY VALIDATION
-- Purpose: Check if related data is consistent across tables
-- Business Value: Ensure data tells a coherent story across entities
-- ====================================================================================================

-- Client name consistency check
SELECT
    'Client Name Consistency' AS validation_type,
    COUNT(DISTINCT v.client_id) AS unique_clients_in_visits,
    COUNT(DISTINCT c.client_id) AS unique_clients_in_clients,
    COUNT(DISTINCT CASE WHEN v.client_name != c.client_name THEN v.client_id END) AS clients_with_name_mismatch,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN v.client_name != c.client_name THEN v.client_id END) / COUNT(DISTINCT v.client_id), 2) AS name_mismatch_pct
FROM stg_visits_working v
JOIN stg_clients_raw c ON v.client_id = c.client_id
WHERE v.client_id IS NOT NULL AND v.client_id != ''
    AND v.client_name IS NOT NULL AND v.client_name != ''
    AND c.client_name IS NOT NULL AND c.client_name != '';

-- ====================================================================================================
-- PHASE 7: EXECUTIVE SUMMARY & RECOMMENDATIONS
-- ====================================================================================================
-- Objective: Synthesize findings and provide actionable recommendations
-- ====================================================================================================

-- STEP 7.1: DATA QUALITY SCORE SUMMARY
-- Purpose: Provide overall data quality assessment
-- Business Value: Quick reference for data readiness
-- ====================================================================================================

WITH quality_metrics AS (
    SELECT
        COUNT(*) AS total_records,

        -- Completeness scores (weighted)
        ROUND(AVG(CASE WHEN visit_id IS NOT NULL AND visit_id != '' THEN 1 ELSE 0 END), 3) AS visit_id_completeness,
        ROUND(AVG(CASE WHEN client_id IS NOT NULL AND client_id != '' THEN 1 ELSE 0 END), 3) AS client_id_completeness,
        ROUND(AVG(CASE WHEN carer_id IS NOT NULL AND carer_id != '' THEN 1 ELSE 0 END), 3) AS carer_id_completeness,
        ROUND(AVG(CASE WHEN scheduled_date IS NOT NULL AND scheduled_date != '' THEN 1 ELSE 0 END), 3) AS date_completeness,
        ROUND(AVG(CASE WHEN visit_status IS NOT NULL AND visit_status != '' THEN 1 ELSE 0 END), 3) AS status_completeness,

        -- Validity scores (estimated)
        ROUND(AVG(CASE WHEN client_age REGEXP '^[0-9]+$' AND CAST(client_age AS UNSIGNED) BETWEEN 18 AND 120 THEN 1 ELSE 0 END), 3) AS age_validity,
        ROUND(AVG(CASE WHEN scheduled_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 1 ELSE 0 END), 3) AS date_format_validity

    FROM stg_visits_working
)
SELECT
    'DATA QUALITY SCORECARD' AS report_section,
    total_records AS total_records_analyzed,

    -- Overall completeness score (weighted average)
    ROUND(0.4 * visit_id_completeness +
          0.3 * client_id_completeness +
          0.2 * carer_id_completeness +
          0.05 * date_completeness +
          0.05 * status_completeness, 3) * 100 AS overall_completeness_score_pct,

    -- Overall validity score
    ROUND(0.7 * age_validity + 0.3 * date_format_validity, 3) * 100 AS overall_validity_score_pct,

    -- Composite quality score
    ROUND((0.6 * (0.4 * visit_id_completeness + 0.3 * client_id_completeness + 0.2 * carer_id_completeness + 0.05 * date_completeness + 0.05 * status_completeness) +
           0.4 * (0.7 * age_validity + 0.3 * date_format_validity)) * 100, 1) AS composite_quality_score_pct

FROM quality_metrics;

-- STEP 7.2: KEY FINDINGS & PRIORITIZED RECOMMENDATIONS
-- Purpose: Provide actionable insights for data improvement
-- Business Value: Guide data cleansing and quality improvement efforts
-- ====================================================================================================

/*
================================================================================
EXECUTIVE SUMMARY - DATA PROFILING RESULTS
================================================================================

CRITICAL ISSUES REQUIRING IMMEDIATE ATTENTION:
1. [Based on analysis results] - High percentage of missing carer_id values
2. [Based on analysis results] - Invalid date formats in scheduled_date
3. [Based on analysis results] - Duration calculation inconsistencies

MODERATE ISSUES FOR SCHEDULED IMPROVEMENT:
1. [Based on analysis results] - Age validation failures
2. [Based on analysis results] - Duplicate visit records
3. [Based on analysis results] - Outlier duration values

DATA QUALITY SCORECARD:
- Overall Completeness: [X]%
- Overall Validity: [Y]%
- Composite Quality Score: [Z]%

RECOMMENDED NEXT STEPS:
1. Implement data validation rules at source systems
2. Clean historical data using identified patterns
3. Establish automated data quality monitoring
4. Train staff on data entry standards
5. Implement master data management for clients/carers

================================================================================
*/

-- ====================================================================================================
-- END OF COMPREHENSIVE DATA PROFILING ANALYSIS
-- ====================================================================================================
-- Next Steps: Review findings with business stakeholders and plan data cleansing approach
-- ====================================================================================================