
-- ============================================================================
-- BUILD DIMENSION TABLES
-- ============================================================================
-- Project:   Care Delivery Performance & CQC Regulatory Readiness Analysis
-- Source:    clean_visits (75,000 rows, cleaned)
-- Target:    2 dimensions 

-- ============================================================================
-- STEP 1: dim_client — Client Dimension
-- ============================================================================

USE domiciliary_care_services;

-- Every client_id should have exactly 1 value per attribute.
SELECT client_id,
       COUNT(DISTINCT client_name)      AS names,
       COUNT(DISTINCT client_gender)    AS genders,
       COUNT(DISTINCT date_of_birth_clean)        AS dobs,
       COUNT(DISTINCT client_postcode)  AS postcodes,
       COUNT(DISTINCT area_name)        AS areas,
       COUNT(DISTINCT care_category)    AS categories,
       COUNT(DISTINCT primary_condition) AS conditions,
       COUNT(DISTINCT funding_type)     AS funding_types
FROM clean_visits
GROUP BY client_id
HAVING names > 1 OR genders > 1 OR dobs > 1 OR postcodes > 1
    OR areas > 1 OR categories > 1 OR conditions > 1 OR funding_types > 1;

 
DROP TABLE IF EXISTS dim_client;
 
CREATE TABLE dim_client (
    client_id        VARCHAR(10)  NOT NULL PRIMARY KEY,
    client_name      VARCHAR(30)  NOT NULL,
    client_gender    VARCHAR(10)  NOT NULL,              
    date_of_birth    DATE         NULL,
    client_postcode  VARCHAR(10)  NULL,
    area_name        VARCHAR(25)  NULL,
    care_category    VARCHAR(30)  NOT NULL,
    primary_condition VARCHAR(40) NOT NULL,
    funding_type     VARCHAR(30)  NOT NULL
);
 
INSERT INTO dim_client
SELECT
    client_id,
    MAX(client_name)        AS client_name,
    MAX(client_gender)      AS client_gender,
    MAX(date_of_birth)      AS date_of_birth,
    MAX(client_postcode)    AS client_postcode,
    MAX(area_name)          AS area_name,
    MAX(care_category)      AS care_category,
    MAX(primary_condition)  AS primary_condition,
    MAX(funding_type)       AS funding_type
FROM clean_visits
GROUP BY client_id;
 
-- validate Row count
SELECT COUNT(*) AS dim_client_rows 
FROM dim_client;

-- validate Gender distribution
SELECT
      client_gender, COUNT(*) AS cnt
FROM dim_client
GROUP BY client_gender;
 
-- validate Funding type distribution
SELECT 
       funding_type, 
       COUNT(*) AS cnt
FROM dim_client
GROUP BY funding_type
ORDER BY cnt DESC;

 
-- validate Area coverage
SELECT COUNT(DISTINCT area_name) AS distinct_areas FROM dim_client;

 
-- ============================================================================
-- STEP 2: dim_carer — Carer Dimension
-- ============================================================================

 
-- PRE-CHECK: Carer name consistency
SELECT carer_id, COUNT(DISTINCT carer_name) AS names
FROM clean_visits
GROUP BY carer_id
HAVING names > 1;
 
DROP TABLE IF EXISTS dim_carer;
 
CREATE TABLE dim_carer (
    carer_id    VARCHAR(10)  NOT NULL PRIMARY KEY,
    carer_name  VARCHAR(30)  NOT NULL
);
 
INSERT INTO dim_carer
SELECT
    carer_id,
    MAX(carer_name) AS carer_name
FROM clean_visits
GROUP BY carer_id;
 
-- validate Row count; 65 carers
SELECT COUNT(*) AS dim_carer_rows FROM dim_carer;
 