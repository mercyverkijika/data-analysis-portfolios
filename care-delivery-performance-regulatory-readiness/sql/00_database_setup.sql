
-- =========================================
-- DATABASE SETUP
-- =========================================
-- Project: Care Delivery Performance & CQC Regulatory Readiness Analysis
-- Purpose: Create domain-level analytics database for domiciliary care analysis
-- Author: Mercy Burinyuy
-- =========================================

CREATE DATABASE IF NOT EXISTS domiciliary_care_analytics;

USE domiciliary_care_analytics;

-- Step 2: Create raw staging table for source dataset

DROP TABLE IF EXISTS stg_visits_raw;

CREATE TABLE stg_visits_raw(
    row_id                  INT AUTO_INCREMENT PRIMARY KEY,  
    visit_id                VARCHAR(20),
    client_id               VARCHAR(20),
    client_name             VARCHAR(100),
    client_gender           VARCHAR(20),       
    client_age              VARCHAR(10),        
    date_of_birth           VARCHAR(30),        
    client_postcode         VARCHAR(20),
    area_name               VARCHAR(50),
    care_category           VARCHAR(100),
    primary_condition       VARCHAR(100),
    funding_type            VARCHAR(100),       
    carer_id                VARCHAR(20),
    carer_name              VARCHAR(100),
    visit_type              VARCHAR(100),
    scheduled_date          VARCHAR(30),       
    scheduled_time          VARCHAR(10),
    actual_clock_in         VARCHAR(30),        
    actual_clock_out        VARCHAR(30),        
    planned_duration_mins   VARCHAR(10),
    actual_duration_mins    VARCHAR(10),        
    visit_status            VARCHAR(50),       
    visit_alert_sent        VARCHAR(10),        
    carer_notes             TEXT,               
    tasks_completed         TEXT,               
    medication_administered VARCHAR(255),
    client_mood             VARCHAR(30),
    safeguarding_flag       VARCHAR(5),
    incident_reported       VARCHAR(5),
    travel_time_mins        VARCHAR(10),
    mileage                 VARCHAR(10),
    continuity_flag         VARCHAR(5),
    missed_visit_reason     VARCHAR(100),
    pay_rate_per_hour       VARCHAR(10)
);

-- STEP 3: Load raw data from CSV

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Everwell_care_analysis/caregivers_visits.csv'
INTO TABLE stg_visits_raw
FIELDS 
    TERMINATED BY ','           
    OPTIONALLY ENCLOSED BY '"'  
    ESCAPED BY '\\'
LINES 
    TERMINATED BY '\n'          
IGNORE 1 ROWS                  
(
    visit_id,
    client_id,
    client_name,
    client_gender,
    client_age,
    date_of_birth,
    client_postcode,
    area_name,
    care_category,
    primary_condition,
    funding_type,
    carer_id,
    carer_name,
    visit_type,
    scheduled_date,
    scheduled_time,
    actual_clock_in,
    actual_clock_out,
    planned_duration_mins,
    actual_duration_mins,
    visit_status,
    visit_alert_sent,
    carer_notes,
    tasks_completed,
    medication_administered,
    client_mood,
    safeguarding_flag,
    incident_reported,
    travel_time_mins,
    mileage,
    continuity_flag,
    missed_visit_reason,
    pay_rate_per_hour
);

-- STEP 4: VALIDATING THE LOAD

-- CHECK 1: Total row count
-- Expected: 77,250
SELECT COUNT(*) AS total_rows 
FROM stg_visits_raw;

-- CHECK 2: Confirm no columns loaded as entirely NULL (shifted columns)

SELECT 
    SUM(CASE WHEN visit_id IS NOT NULL AND visit_id != '' THEN 1 ELSE 0 END)           AS visit_id_populated,
    SUM(CASE WHEN client_id IS NOT NULL AND client_id != '' THEN 1 ELSE 0 END)          AS client_id_populated,
    SUM(CASE WHEN client_name IS NOT NULL AND client_name != '' THEN 1 ELSE 0 END)      AS client_name_populated,
    SUM(CASE WHEN carer_id IS NOT NULL AND carer_id != '' THEN 1 ELSE 0 END)            AS carer_id_populated,
    SUM(CASE WHEN visit_status IS NOT NULL AND visit_status != '' THEN 1 ELSE 0 END)    AS visit_status_populated,
    SUM(CASE WHEN scheduled_date IS NOT NULL AND scheduled_date != '' THEN 1 ELSE 0 END) AS scheduled_date_populated,
    SUM(CASE WHEN pay_rate_per_hour IS NOT NULL AND pay_rate_per_hour != '' THEN 1 ELSE 0 END) AS pay_rate_populated
FROM stg_visits_raw;

-- CHECK 3: Confirming all visit_id pattern start with VIS-
SELECT COUNT(*) AS valid_visit_ids
FROM stg_visits_raw
WHERE visit_id LIKE 'VIS-%';

-- Preview sample data
SELECT * 
FROM  stg_visits_raw 
LIMIT 20;