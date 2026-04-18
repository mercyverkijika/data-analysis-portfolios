
-- ============================================
-- DATA CLEANING
-- ============================================
-- Project:  Care Delivery Performance & CQC Regulatory Readiness 


-- STEP 1: create a new working table that will be cleaned 

USE domiciliary_care_services;

CREATE TABLE stg_visits_working AS
SELECT * FROM stg_visits_raw;

-- verifying the new table is created properly
-- 77250 rows expected
SELECT COUNT(* ) FROM stg_visits_working;

-- ====================================================
-- STEP 2: REMOVE DUPLICATES

-- ====================================================

START TRANSACTION;

-- recomfirm the duplicte count of 2250 rows identified during profiling
SELECT COUNT(*) AS total_count,
       COUNT(DISTINCT visit_id) AS uniyue_rows,
       COUNT(*) - COUNT(DISTINCT visit_id) AS duplicate_rows
FROM stg_visits_working;

-- Preview duplicates
SELECT visit_id, COUNT(*) AS duplicate_count
FROM stg_visits_working
GROUP BY visit_id
HAVING COUNT(*) > 1;

-- Delete duplicates (duplicates are exact copies)
DELETE FROM stg_visits_working
WHERE row_id NOT IN (
            SELECT min_id
            FROM (
                  SELECT MIN(row_id) AS min_id
                  FROM stg_visits_working
                  GROUP BY visit_id
                  ) AS rows_keeped
);

-- Validate deletion
SELECT visit_id, 
       COUNT(*) AS duplicate_count
FROM stg_visits_working
GROUP BY visit_id
HAVING COUNT(*) > 1;

COMMIT;

-- =====================================================
-- STEP 3: STANDARDIZE visit_status
-- =====================================================

START TRANSACTION;

-- pre-validation
SELECT visit_status,
      COUNT(*) AS total_count
FROM stg_visits_working
GROUP BY visit_status
ORDER BY visit_status DESC;

-- standardidize 24 distinct variants into 8 actual visit_status

UPDATE stg_visits_working
SET visit_status = 

     CASE
         WHEN visit_status IN ('No-show', 'No Show', 'Çarer No-Show', 'çarer no show', 'Carer DNS', 'Çarer Did Not Attend') THEN 'Carer No-Show'
         WHEN visit_status IN ('Office Cancelled', 'cancelled by office') THEN 'Officed Cancelled'
         WHEN visit_status IN ('Missed') THEN 'Missed'
         WHEN visit_status IN ('Short Visit', 'Brief Visit') THEN 'Short Visit'
         WHEN visit_status IN ( 'Late Arrival', 'Completed Late', 'Completed - Late') THEN 'Completed Late'
         WHEN visit_status IN ('Hospitalised', 'Hospital Admission', 'Client in Hospital') THEN 'Client Hospitalized'
         WHEN visit_status IN ('Finished', 'Done', 'COMPLETED', 'Complete') THEN 'Completed'
         WHEN visit_status IN ('Client Cancelled', 'cancelled by client', 'Cancelled - Client') THEN 'Client Cancelled'
         ELSE 'Oops we missed this'
         END;

-- Confirm exactly 8 standard values
SELECT visit_status, 
       COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY visit_status
ORDER BY cnt DESC;

-- confirm total count is perserved 
SELECT COUNT(*) AS total_after_status_clean 
FROM stg_visits_working;

COMMIT;

-- ========================================================================
-- STEP 4: STANDARDISE funding_type 
-- ============================================================================
-- ISSUE:   18 distinct variants representing 4 actual funding types.
 
START TRANSACTION; 
 
-- the current funding_types variants 
SELECT funding_type, COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY funding_type
ORDER BY cnt DESC;
 
-- standardize 14 distinct funding type variants into 4 actual funding types
UPDATE stg_visits_working
SET funding_type = 

 CASE
     WHEN funding_type IN ('Local Authority', 'Council Funded', 'LA', 'Local Auth') THEN 'Local Authority'
	 WHEN funding_type IN ('Private', 'Self Funded', 'Self-funded') THEN 'Self Funded'
     WHEN funding_type IN ('Direct Payment', 'DP', 'Direct Payments') THEN 'Direct Payment'
	 WHEN funding_type IN ('NHS CHC', 'CHC', 'NHS Continuing Healthcare') THEN 'NHS CHC'
     ELSE 'Oops we missed this'
     END;

-- confirm there are exactly 4 funding_types     
SELECT funding_type, COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY funding_type
ORDER BY cnt DESC;

-- confirm total count is perserved 
SELECT COUNT(*) AS total_after_status_clean 
FROM stg_visits_working;

COMMIT;


-- ============================================================================
-- STEP 5: STANDARDISE client_gender 
-- ============================================================================
-- ISSUE:   5 non-null variants + 500 NULLs.

START TRANSACTION;
 
-- the current gender variants (including NULLs)
SELECT
    COALESCE(client_gender, '[NULL]') AS gender_value,
    LENGTH(client_gender) AS char_length,
    COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY client_gender
ORDER BY cnt DESC;
 
-- CLEANING: Trim whitespace, normalise to F/M/Unknown
UPDATE stg_visits_working
SET client_gender = 
		CASE
			WHEN TRIM(client_gender) IN ('F', 'female')  THEN 'F'
			WHEN TRIM(client_gender) IN ('M', 'male')      THEN 'M'
			ELSE 'Unknown'
		END;
 
-- Confirm exactly 3 standard values
SELECT client_gender, 
       COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY client_gender
ORDER BY cnt DESC;

-- confirm total count is perserved 
SELECT COUNT(*) AS total_after_status_clean 
FROM stg_visits_working;

COMMIT;

-- ============================================================================
-- STEP 6: STANDARDISE visit_alert_sent
-- ============================================================================
-- ISSUE:   3 values (1, 0, yes) — should be binary 1/0.

START TRANSACTION;
 
-- Current visit_alert_sent variants
SELECT visit_alert_sent, 
       COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY visit_alert_sent;

 
-- standardize values into 2 (1, 0)
UPDATE stg_visits_working
SET visit_alert_sent = CASE
    WHEN LOWER(TRIM(visit_alert_sent)) IN ('1', 'yes') THEN '1'
    WHEN LOWER(TRIM(visit_alert_sent)) IN ('0', 'no')  THEN '0'
    ELSE visit_alert_sent
END;
 
-- Confirm exactly 2 values
SELECT visit_alert_sent, 
       COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY visit_alert_sent;

-- ============================================================================
-- STEP 7: STANDARDIZE scheduled_date  format
-- ============================================================================
-- ISSUE:   Mixed formats in same column: - YYYY-MM-DD, XX/XX/YYYY( DD/MM/YYYY, MM/DD/YYYY,  Ambiguous (both parts ≤12)
 
-- Add clean date column
ALTER TABLE stg_visits_working
    ADD COLUMN scheduled_date_clean VARCHAR(30);

START TRANSACTION;

-- Confirm format distribution
SELECT
    CASE
        WHEN scheduled_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'  THEN 'YYYY-MM-DD'
        WHEN scheduled_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'  THEN 'XX/XX/YYYY'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY format_pattern;
 
-- CLEANING: standardize  all scheduled-dates into YYYY-MM-DD format
UPDATE stg_visits_working
SET scheduled_date_clean = 

		CASE
			
			WHEN scheduled_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'THEN scheduled_date
			WHEN scheduled_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN
				CASE
					-- First part > 12: MUST be DD/MM/YYY
					WHEN CAST(SUBSTRING_INDEX(scheduled_date, '/', 1) AS UNSIGNED) > 12
						THEN CONCAT(
                             SUBSTRING_INDEX(scheduled_date, '/', -1), '-', -- YYYY
							 LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2),'/', -1), 2, '0'), '-', -- MM
							 LPAD(SUBSTRING_INDEX(scheduled_date, '/', 1), 2, '0') -- DD
                             )
                     -- second part > 12: MUST be MM/DD/YYYY       
					WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2), '/', -1) AS UNSIGNED) > 12
						THEN CONCAT(
                             SUBSTRING_INDEX(scheduled_date, '/', -1), '-', -- YYYY
							 LPAD(SUBSTRING_INDEX(scheduled_date, '/', 1), 2, '0'), '-', -- MM
                             LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2),'/', -1), 2, '0')  -- DD
                             )
					
                    -- Both part > 12: default  to DD/MM/YYY(UK convention)
					ELSE CONCAT(
                             SUBSTRING_INDEX(scheduled_date, '/', -1), '-', -- YYYY
							 LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(scheduled_date, '/', 2),'/', -1), 2, '0'), '-', -- MM
							 LPAD(SUBSTRING_INDEX(scheduled_date, '/', 1), 2, '0') -- DD
                             )
					END 
                    
		ELSE NULL
        END;


-- No NULLs in clean column (every row should have a date)
SELECT COUNT(*) AS null_scheduled_dates
FROM stg_visits_working
WHERE scheduled_date_clean IS NULL;

 
-- checking Date range is correct (dates run from 2024-01-01 to 2025-12-31
SELECT
    MIN(scheduled_date_clean) AS earliest_date,
    MAX(scheduled_date_clean) AS latest_date
FROM stg_visits_working;

 
-- Spot-check if DD/MM/YYYY or MM/DD/YYYY date have been converted 
SELECT
        scheduled_date_clean
FROM stg_visits_working
WHERE scheduled_date_clean REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

COMMIT;

 
-- ============================================================================
-- STEP 8: STANDARDIZE actual_clock_in
-- ============================================================================
-- ISSUE:   Same mixed format issue as scheduled_date, with HH:MM appended.
--          clock_in: XX/XX/YYYY HH:MM, YYYY-MM-DD HH:MM 

 
ALTER TABLE stg_visits_working
ADD COLUMN actual_clock_in_clean DATETIME AFTER actual_clock_in;

START TRANSACTION;

-- CLEANING: standardize  all actual_clock_in into YYYY-MM-DD format
UPDATE stg_visits_working
SET actual_clock_in_clean =  
    CASE
        WHEN actual_clock_in IS NULL OR actual_clock_in = '' THEN NULL

        -- YYYY-MM-DD HH:MM:SS (already clean — just truncate seconds)
        WHEN actual_clock_in REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN CONCAT(
                 SUBSTRING_INDEX(actual_clock_in, ' ', 1), ' ',
                 SUBSTRING(SUBSTRING_INDEX(actual_clock_in, ' ', -1), 1, 5), ':00'
                 )

        -- YYYY-MM-DD HH:MM (already clean — append :00)
        WHEN actual_clock_in REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
            THEN CONCAT(actual_clock_in, ':00')

        -- XX/XX/YYYY HH:MM:SS (disambiguate date, truncate seconds)
        WHEN actual_clock_in REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$' THEN
            CASE
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'),
                         ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_in, ' ', -1), 1, 5), ':00'
                         )
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'),
                         ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_in, ' ', -1), 1, 5), ':00'
                         )
                ELSE CONCAT(
                     SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'),
                     ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_in, ' ', -1), 1, 5), ':00'
                     )
            END

        --  XX/XX/YYYY HH:MM 
        WHEN actual_clock_in REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$' THEN
            CASE
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'),
                         ' ', SUBSTRING_INDEX(actual_clock_in, ' ', -1), ':00'
                         )
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'),
                         ' ', SUBSTRING_INDEX(actual_clock_in, ' ', -1), ':00'
                         )
                ELSE CONCAT(
                     SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', -1), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_in, ' ', 1), '/', 1), 2, '0'),
                     ' ', SUBSTRING_INDEX(actual_clock_in, ' ', -1), ':00'
                     )
            END

        ELSE NULL
    END;
    
-- Spot-check if there are any silent nulls
SELECT COUNT(*) AS total_count
FROM stg_visits_working
WHERE actual_clock_in IS NOT NULL
  AND TRIM(actual_clock_in) != ''
  AND actual_clock_in_clean IS NULL;


-- Spot-check if DD/MM/YYYY or MM/DD/YYYY date have been converted 
SELECT
        actual_clock_in_clean
FROM stg_visits_working
WHERE actual_clock_in_clean REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$';

COMMIT;


-- ============================================================================
-- STEP 9: STANDARDIZE actual_clock_out
-- ============================================================================
-- ISSUE:   Same mixed format issue as scheduled_date, with HH:MM appended.
--          clock_in: XX/XX/YYYY HH:MM, YYYY-MM-DD HH:MM 

 
ALTER TABLE stg_visits_working
ADD COLUMN actual_clock_out_clean DATETIME AFTER actual_clock_out;

START TRANSACTION;

-- CLEANING: standardize  all actual_clock_out into YYYY-MM-DD format
UPDATE stg_visits_working
SET actual_clock_out_clean =  
    CASE
        WHEN actual_clock_out IS NULL OR actual_clock_out = '' THEN NULL

        -- YYYY-MM-DD HH:MM:SS (already clean — just truncate seconds)
        WHEN actual_clock_out REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN CONCAT(
                 SUBSTRING_INDEX(actual_clock_out, ' ', 1), ' ',
                 SUBSTRING(SUBSTRING_INDEX(actual_clock_out, ' ', -1), 1, 5), ':00'
                 )

        -- YYYY-MM-DD HH:MM (already clean — append :00)
        WHEN actual_clock_out REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
            THEN CONCAT(actual_clock_out, ':00')

        -- XX/XX/YYYY HH:MM:SS (disambiguate date, truncate seconds)
        WHEN actual_clock_out REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$' THEN
            CASE
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'),
                         ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_out, ' ', -1), 1, 5), ':00'
                         )
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'),
                         ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_out, ' ', -1), 1, 5), ':00'
                         )
                ELSE CONCAT(
                     SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'),
                     ' ', SUBSTRING(SUBSTRING_INDEX(actual_clock_out, ' ', -1), 1, 5), ':00'
                     )
            END

        --  XX/XX/YYYY HH:MM 
        WHEN actual_clock_out REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$' THEN
            CASE
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'),
                         ' ', SUBSTRING_INDEX(actual_clock_out, ' ', -1), ':00'
                         )
                WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1) AS UNSIGNED) > 12
                    THEN CONCAT(
                         SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'), '-',
                         LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'),
                         ' ', SUBSTRING_INDEX(actual_clock_out, ' ', -1), ':00'
                         )
                ELSE CONCAT(
                     SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', -1), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 2), '/', -1), 2, '0'), '-',
                     LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(actual_clock_out, ' ', 1), '/', 1), 2, '0'),
                     ' ', SUBSTRING_INDEX(actual_clock_out, ' ', -1), ':00'
                     )
            END

        ELSE NULL
    END;

-- Spot-check if there are any silent nulls
SELECT COUNT(*) AS total_count
FROM stg_visits_working
WHERE actual_clock_out IS NOT NULL
  AND TRIM(actual_clock_out) != ''
  AND actual_clock_out_clean IS NULL;

-- Spot-check if DD/MM/YYYY or MM/DD/YYYY date have been converted 
SELECT
        actual_clock_out_clean
FROM stg_visits_working
WHERE actual_clock_out_clean REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$';

COMMIT;

-- ============================================================================
-- STEP 10: STANDARDIZE date_of_birth
-- ============================================================================
-- ISSUE:   Same mixed format issue as scheduled_date, with HH:MM appended.
--          clock_in: XX/XX/YYYY HH:MM, YYYY-MM-DD HH:MM 

 
ALTER TABLE stg_visits_working
ADD COLUMN date_of_birth_clean DATE AFTER date_of_birth;

START TRANSACTION;

-- CLEANING: standardize  all date_of_birth  into YYYY-MM-DD format
UPDATE stg_visits_working
SET date_of_birth_clean =  

		CASE
			WHEN date_of_birth IS NULL OR date_of_birth = '' THEN NULL
			WHEN date_of_birth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN date_of_birth
            WHEN date_of_birth REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN
				CASE
					-- First part > 12: MUST be DD/MM/YYY
					WHEN CAST(SUBSTRING_INDEX(date_of_birth, '/', 1) AS UNSIGNED) > 12
						THEN CONCAT(
                             SUBSTRING_INDEX(date_of_birth, '/', -1), '-', -- YYYY
                             LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(date_of_birth, '/', 2), '/', -1), 2, '0'), '-', -- MM
							 LPAD(SUBSTRING_INDEX(date_of_birth, '/', 1), 2, '0')
                             )
                     -- second part > 12: MUST be MM/DD/YYYY 
                     WHEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(date_of_birth ,'/', 2), '/', -1) AS UNSIGNED) > 12
						THEN CONCAT(
                             SUBSTRING_INDEX(date_of_birth, '/', -1), '-', -- YYYY
							 LPAD(SUBSTRING_INDEX(date_of_birth, '/', 1), 2, '0'), '-', -- MM
                             LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(date_of_birth,'/', 2), '/', -1), 2, '0') -- DD
                             )
					
                    -- Both part > 12: default  to DD/MM/YYY(UK convention)
					ELSE CONCAT(
                             SUBSTRING_INDEX(date_of_birth, '/', -1), '-', -- YYYY
                             LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(date_of_birth, '/', 2), '/', -1), 2, '0'), '-', -- MM
							 LPAD(SUBSTRING_INDEX(date_of_birth, '/', 1), 2, '0') -- DD
                             )
					END 
                    
		ELSE NULL
        END;

-- Spot-check if DD/MM/YYYY or MM/DD/YYYY date have been converted 
SELECT 
        date_of_birth_clean
FROM stg_visits_working
WHERE date_of_birth_clean REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

COMMIT;

-- ============================================================================
-- STEP 11: calculate the right client age 
-- ============================================================================

-- does client_age match the accurate_age 
SELECT 
    client_id,
    client_age,
    -- Accurate age calculation
    TIMESTAMPDIFF(YEAR, date_of_birth_clean, scheduled_date_clean)
    - (
        DATE_FORMAT(scheduled_date_clean, '%m%d') 
        < 
        DATE_FORMAT(date_of_birth_clean, '%m%d')
      ) AS age_at_visit

FROM stg_visits_working
WHERE date_of_birth_clean IS NOT NULL
  AND scheduled_date_clean IS NOT NULL;
 
 -- creating new client_age column with accurate age 
ALTER TABLE stg_visits_working
ADD COLUMN client_age_clean INT AFTER client_age;
   
START TRANSACTION; 

UPDATE stg_visits_working
SET client_age_clean = 

		TIMESTAMPDIFF(YEAR, date_of_birth_clean, scheduled_date_clean)
			- (
				DATE_FORMAT(scheduled_date_clean, '%m%d') 
				< 
				DATE_FORMAT(date_of_birth_clean, '%m%d')
			  );

-- confirming the new ages are accurate
WITH validation AS (
    SELECT 
        client_id,
        client_age,
        client_age_clean,

        -- Recalculated correct age
        TIMESTAMPDIFF(YEAR, date_of_birth_clean, scheduled_date_clean)
        - (
            DATE_FORMAT(scheduled_date_clean, '%m%d') 
            < 
            DATE_FORMAT(date_of_birth_clean, '%m%d')
        ) AS expected_age

    FROM stg_visits_working
    WHERE date_of_birth_clean IS NOT NULL
      AND scheduled_date_clean IS NOT NULL
),

validation_status AS (
	SELECT *,
		client_age_clean - expected_age AS age_diff,
		
		CASE 
			WHEN client_age_clean = expected_age THEN 'Correct'
			ELSE 'Incorrect'
		END AS validation_flag
	FROM validation)

SELECT *
FROM validation_status
WHERE validation_flag = 'Correct';

COMMIT;

-- ===========================================================================
-- STEP 12: REPLACE carer_notes DASHES 
-- ============================================================================
 
-- PRE-VALIDATION: identify placeholders
SELECT carer_notes,
       COUNT(*) AS total_count
FROM stg_visits_working
GROUP BY carer_notes
ORDER BY total_count DESC;

-- CLEANING: Remove dash placeholders

START TRANSACTION;

UPDATE stg_visits_working
SET carer_notes = 
   CASE
     WHEN TRIM(carer_notes) = '-' OR TRIM(carer_notes) = ' ' THEN null
     ELSE carer_notes 
     END;
   
-- POST-VALIDATION: No dashes remaining
SELECT COUNT(*) AS remaining_dashes
FROM stg_visits_working
WHERE TRIM(carer_notes) = '-'
   OR TRIM(carer_notes) = ' ';

COMMIT; 


-- ===========================================================================
-- STEP 13: REPLACE medication_administered DASHES 
-- ============================================================================
 
-- PRE-VALIDATION: identify placeholders
SELECT medication_administered,
       COUNT(*) AS total_count
FROM stg_visits_working
GROUP BY medication_administered
ORDER BY total_count DESC;

-- CLEANING: Remove dash placeholders

START TRANSACTION;

UPDATE stg_visits_working
SET medication_administered = 
   CASE
     WHEN TRIM(medication_administered) = '-' OR TRIM(medication_administered) = ' ' THEN null
     ELSE medication_administered
     END;
   
-- POST-VALIDATION: No dashes remaining
SELECT COUNT(*) AS remaining_dashes
FROM stg_visits_working
WHERE TRIM(medication_administered) = '-'
   OR TRIM(medication_administered) = ' ';

COMMIT; 


-- ===========================================================================
-- STEP 14: CREATE AN ACCURATE safegaurding flag and incident_reported flag columns
-- ============================================================================
 
-- confirming safeguarding language identified during profiling which were not flaged or reported.
-- carer notes and identifying language that indicates a potential concern.
SELECT carer_notes,
       safeguarding_flag,
       incident_reported
FROM stg_visits_working
WHERE carer_notes IS NOT NULL
  AND safeguarding_flag = 0
  AND incident_reported = 0
  AND (
    -- Physical abuse indicators
       LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%mark on%'
    OR LOWER(carer_notes) LIKE '%wound%'
    OR LOWER(carer_notes) LIKE '%ulcer%'

    -- Falls
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%found on floor%'

    -- Medication concerns
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%missed medication%'
    OR LOWER(carer_notes) LIKE '%blister pack%'

    -- Neglect indicators
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
    OR LOWER(carer_notes) LIKE '%soiled%'
    OR LOWER(carer_notes) LIKE '%no food%'
    OR LOWER(carer_notes) LIKE '%no heating%'

    -- Self-neglect
    OR LOWER(carer_notes) LIKE '%refused%'

    -- Emotional/psychological indicators
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%crying%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%distressed%'
  );
  
ALTER TABLE stg_visits_working
ADD COLUMN safeguarding_flag_clean TINYINT NOT NULL DEFAULT 0;

START TRANSACTION;

UPDATE stg_visits_working
SET safeguarding_flag_clean = 1
WHERE carer_notes IS NOT NULL
  AND (
    -- Physical abuse indicators
       LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%mark on%'
    OR LOWER(carer_notes) LIKE '%wound%'
    OR LOWER(carer_notes) LIKE '%ulcer%'

    -- Falls
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%found on floor%'

    -- Medication concerns
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%missed medication%'
    OR LOWER(carer_notes) LIKE '%blister pack%'

    -- Neglect indicators
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
    OR LOWER(carer_notes) LIKE '%soiled%'
    OR LOWER(carer_notes) LIKE '%no food%'
    OR LOWER(carer_notes) LIKE '%no heating%'

    -- Self-neglect
    OR LOWER(carer_notes) LIKE '%refused%'

    -- Emotional/psychological indicators
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%crying%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%distressed%'
  );
  
COMMIT;
     
-- POST-VALIDATION: Check if some safegaurding langauage have not been flaged
SELECT carer_notes,
       safeguarding_flag_clean,
       incident_reported
FROM stg_visits_working
WHERE carer_notes IS NOT NULL
  AND safeguarding_flag_clean = 0
  AND incident_reported = 0
  AND (
    -- Physical abuse indicators
       LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%mark on%'
    OR LOWER(carer_notes) LIKE '%wound%'
    OR LOWER(carer_notes) LIKE '%ulcer%'

    -- Falls
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%found on floor%'

    -- Medication concerns
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%missed medication%'
    OR LOWER(carer_notes) LIKE '%blister pack%'

    -- Neglect indicators
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
    OR LOWER(carer_notes) LIKE '%soiled%'
    OR LOWER(carer_notes) LIKE '%no food%'
    OR LOWER(carer_notes) LIKE '%no heating%'

    -- Self-neglect
    OR LOWER(carer_notes) LIKE '%refused%'

    -- Emotional/psychological indicators
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%crying%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%distressed%'
  );
  
 
-- create a new incident_reported_clean column to ensure all carer_notes with safeguarding language are reported
 ALTER TABLE stg_visits_working
 ADD COLUMN incident_reported_clean TINYINT NOT NULL DEFAULT 0 AFTER incident_reported;
 
START TRANSACTION;

UPDATE stg_visits_working
SET incident_reported_clean = 1
WHERE safeguarding_flag_clean = 1;

-- checking to ensure all safeguarding language are reported
SELECT carer_notes,
       safeguarding_flag_clean,
       incident_reported_clean
FROM stg_visits_working
WHERE incident_reported_clean = 0
  AND (
    -- Physical abuse indicators
       LOWER(carer_notes) LIKE '%bruise%'
    OR LOWER(carer_notes) LIKE '%skin tear%'
    OR LOWER(carer_notes) LIKE '%pressure sore%'
    OR LOWER(carer_notes) LIKE '%mark on%'
    OR LOWER(carer_notes) LIKE '%wound%'
    OR LOWER(carer_notes) LIKE '%ulcer%'

    -- Falls
    OR LOWER(carer_notes) LIKE '%fall%'
    OR LOWER(carer_notes) LIKE '%fell%'
    OR LOWER(carer_notes) LIKE '%found on floor%'

    -- Medication concerns
    OR LOWER(carer_notes) LIKE '%medication error%'
    OR LOWER(carer_notes) LIKE '%wrong dos%'
    OR LOWER(carer_notes) LIKE '%missed medication%'
    OR LOWER(carer_notes) LIKE '%blister pack%'

    -- Neglect indicators
    OR LOWER(carer_notes) LIKE '%not eaten%'
    OR LOWER(carer_notes) LIKE '%dehydrat%'
    OR LOWER(carer_notes) LIKE '%weight loss%'
    OR LOWER(carer_notes) LIKE '%soiled%'
    OR LOWER(carer_notes) LIKE '%no food%'
    OR LOWER(carer_notes) LIKE '%no heating%'

    -- Self-neglect
    OR LOWER(carer_notes) LIKE '%refused%'

    -- Emotional/psychological indicators
    OR LOWER(carer_notes) LIKE '%weepy%'
    OR LOWER(carer_notes) LIKE '%crying%'
    OR LOWER(carer_notes) LIKE '%withdrawn%'
    OR LOWER(carer_notes) LIKE '%aggressive%'
    OR LOWER(carer_notes) LIKE '%agitat%'
    OR LOWER(carer_notes) LIKE '%distressed%'
  );
  
COMMIT;

-- ============================================================================
-- STEP 15: FLAG SUSPECT TRAVEL DATA (DQ-014)
-- ============================================================================


ALTER TABLE stg_visits_working
ADD COLUMN travel_data_suspect TINYINT NOT NULL DEFAULT 0 AFTER mileage;
 
-- CLEANING: Flag records with implausible implied speeds

START TRANSACTION; 

UPDATE stg_visits_working
SET travel_data_suspect = 1
WHERE travel_time_mins IS NOT NULL
  AND mileage IS NOT NULL
  AND CAST(travel_time_mins AS DECIMAL(6,1)) > 0
  AND CAST(mileage AS DECIMAL(5,1)) > 0
  AND (
    -- Implied speed > 60 mph (impossible in Southampton residential areas)
    (CAST(mileage AS DECIMAL(5,1)) / (CAST(travel_time_mins AS DECIMAL(6,1)) / 60)) > 60
 
    -- Implied speed < 3 mph for distance > 0.5 miles (walking pace for a car)
    OR (
        CAST(mileage AS DECIMAL(5,1)) > 0.5
        AND (CAST(mileage AS DECIMAL(5,1)) / (CAST(travel_time_mins AS DECIMAL(6,1)) / 60)) < 3
    )
  );
 
-- POST-VALIDATION  Check flagged count
SELECT travel_data_suspect, COUNT(*) AS cnt
FROM stg_visits_working
GROUP BY travel_data_suspect;
 
-- POST-VALIDATION: Verify the extremes are flagged
SELECT
    visit_id,
    travel_time_mins,
    mileage,
    ROUND(CAST(mileage AS DECIMAL(5,1)) /
          (CAST(travel_time_mins AS DECIMAL(6,1)) / 60), 1) AS implied_mph,
    travel_data_suspect
FROM stg_visits_working
WHERE travel_time_mins IS NOT NULL
  AND CAST(travel_time_mins AS DECIMAL(6,1)) > 0
  AND CAST(mileage AS DECIMAL(5,1)) > 0
ORDER BY implied_mph DESC
LIMIT 10;

COMMIT; 

-- ============================================================
-- STEP 16: TRIM WHITESPACE FROM ALL TEXT COLUMNS
-- ============================================================
-- Catche any remaining leading/trailing spaces across the entire dataset. 

UPDATE stg_visits_working 
SET
    visit_id = TRIM(visit_id),
    client_id = TRIM(client_id),
    client_name = TRIM(client_name),
    client_postcode = TRIM(client_postcode),
    area_name = TRIM(area_name),
    care_category = TRIM(care_category),
    primary_condition = TRIM(primary_condition),
    carer_id = TRIM(carer_id),
    carer_name = TRIM(carer_name),
    visit_type = TRIM(visit_type),
    scheduled_time = TRIM(scheduled_time),
    tasks_completed = TRIM(tasks_completed),
    medication_administered = TRIM(medication_administered),
    client_mood = TRIM(client_mood),
    missed_visit_reason = TRIM(missed_visit_reason);


-- ============================================================
-- STEP 16: CONVERT EMPTY STRINGS TO NULL
-- ============================================================

-- data was loaded INFILE so blanks are loaded as empty strings. so cloumns where nulls can exist convert '' to NULL so they behave correctly in queries
-- (JOINs, IS NULL checks, COUNT, etc).

UPDATE stg_visits_working SET
    actual_duration_mins = NULLIF(actual_duration_mins, ''),
    travel_time_mins = NULLIF(travel_time_mins, ''),
    mileage = NULLIF(mileage, ''),
    tasks_completed = NULLIF(tasks_completed, ''),
    medication_administered = NULLIF(medication_administered, ''),
    client_mood = NULLIF(client_mood, ''),
    missed_visit_reason = NULLIF(missed_visit_reason, ''),
    client_gender = NULLIF(client_gender, '');


-- ============================================================
-- FINAL VALIDATION: Confirm all cleaning was successful
-- ============================================================

-- V1: Row count should be 75,000
SELECT COUNT(*) AS final_row_count FROM stg_visits_working;

-- V2: visit_status should have exactly 8 values
SELECT visit_status, COUNT(*) AS cnt
FROM stg_visits_working GROUP BY visit_status ORDER BY cnt DESC;

-- V3: funding_type should have exactly 4 values
SELECT funding_type, COUNT(*) AS cnt
FROM stg_visits_working GROUP BY funding_type ORDER BY cnt DESC;

-- V4: client_gender should have exactly 3 values (F, M, Unknown)
SELECT client_gender, COUNT(*) AS cnt
FROM stg_visits_working GROUP BY client_gender ORDER BY cnt DESC;

-- V5: visit_alert_sent should have exactly 2 values (1, 0)
SELECT visit_alert_sent, COUNT(*) AS cnt
FROM stg_visits_working GROUP BY visit_alert_sent;

-- V6: All scheduled_date_clean values in YYYY-MM-DD format
SELECT COUNT(*) AS bad_dates
FROM stg_visits_working
WHERE scheduled_date_clean NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
-- Expected: 0

-- V7: Date range check
SELECT 
    MIN(scheduled_date_clean) AS earliest_visit,
    MAX(scheduled_date_clean) AS latest_visit
FROM stg_visits_working;
-- Expected: within 2024-01-01 to 2025-12-31

-- V8: All actual_clock_in_clean in YYYY-MM-DD format
SELECT COUNT(*) AS bad_dates
FROM stg_visits_working
WHERE actual_clock_in_clean NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';
-- Expected: 0

-- V9: All actual_clock_out_clean in YYYY-MM-DD format
SELECT COUNT(*) AS bad_dates
FROM stg_visits_working
WHERE actual_clock_out_clean NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';
-- Expected: 0


-- V10: Referential integrity pre-check Each client_id should now map to exactly 1 gender and 1 funding_type
SELECT client_id,
       COUNT(DISTINCT client_gender) AS genders,
       COUNT(DISTINCT funding_type) AS funding_types
FROM stg_visits_working
GROUP BY client_id
HAVING COUNT(DISTINCT client_gender) > 1
    OR COUNT(DISTINCT funding_type) > 1;
-- Expected: 0 rows (

