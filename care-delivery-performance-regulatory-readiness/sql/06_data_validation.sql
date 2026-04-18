
-- ============================================================================
-- DATA VALIDATION dim and fact tables 
-- ============================================================================
-- Project:   Care Delivery Performance & CQC Regulatory Readiness Analysis


-- ============================================================================
-- STEP 1: REFERENTIAL INTEGRITY VALIDATION
-- ============================================================================

-- Any visits pointing to a client NOT in dim_client?
SELECT COUNT(*) AS orphan_clients
FROM fact_visits f
LEFT JOIN dim_client c ON f.client_id = c.client_id
WHERE c.client_id IS NULL;

 
-- Any visits pointing to a carers NOT in dim_carer?
SELECT COUNT(*) AS orphan_carers
FROM fact_visits f
LEFT JOIN dim_carer c ON f.carer_id = c.carer_id
WHERE c.carer_id IS NULL;


-- VALIDATION Reverse orphan check — any dimension rows with no facts?
SELECT COUNT(*) FROM dim_client c
LEFT JOIN fact_visits f ON c.client_id = f.client_id
WHERE f.client_id IS NULL;
 
SELECT COUNT(*) FROM dim_carer c
LEFT JOIN fact_visits f ON c.carer_id = f.carer_id
WHERE f.carer_id IS NULL;

 
-- ============================================================================
-- STEP 2: STRUCTURAL SUMMARY
-- ============================================================================

-- The final confirmation that everything is as expected ,  EXPECTED: 731 | 499 | 65 | 75,000
 
SELECT
    (SELECT COUNT(*) FROM dim_client)  AS dim_client_rows,
    (SELECT COUNT(*) FROM dim_carer)   AS dim_carer_rows,
    (SELECT COUNT(*) FROM fact_visits) AS fact_visits_rows;


-- database now has 5 layers:
--   1. stg_visits_raw      → untouched archive (77,250 rows)
--   2. stg_visits_working   → cleaned staging (75,000 rows)
--   3. clean_visits         → cleaned staging (75,000 rows)
--   4. dim_* tables         → normalised dimensions
--   5. fact_visits          → analysis-ready fact table
 