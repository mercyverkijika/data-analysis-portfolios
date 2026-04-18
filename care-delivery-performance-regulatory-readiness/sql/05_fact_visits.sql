
-- ============================================================================
-- BUILD FACT TABLE
-- ============================================================================
-- Project:   Care Delivery Performance & CQC Regulatory Readiness Analysis
-- Source:    clean_visits (75,000 rows, cleaned)
-- Target:    1 fact tabl
 
 
-- ============================================================================
-- STEP 1: fact_visits — The Fact Table
-- ============================================================================

USE domiciliary_care_services

DROP TABLE IF EXISTS fact_visits;
 
CREATE TABLE fact_visits (
    visit_id                  VARCHAR(15)   NOT NULL PRIMARY KEY,
    client_id                 VARCHAR(10)   NOT NULL,
    carer_id                  VARCHAR(10)   NOT NULL,
    scheduled_date            DATE           NOT NULL,
    visit_type                VARCHAR(30)   NOT NULL,
    scheduled_time            VARCHAR(5)    NOT NULL,          
    planned_duration_mins     SMALLINT      NOT NULL,         
    actual_clock_in           DATETIME      NULL,
    actual_clock_out          DATETIME      NULL,
    actual_duration_mins      DECIMAL(5,1)  NULL,
    visit_status              VARCHAR(25)   NOT NULL,         
    visit_alert_sent          TINYINT       NOT NULL,         
    missed_visit_reason       VARCHAR(50)   NULL,
    tasks_completed           TEXT          NULL,
    medication_administered   TEXT          NULL,
    carer_notes               TEXT          NULL,
    client_mood               VARCHAR(15)   NULL,
    safeguarding_flag         TINYINT       NOT NULL,          
    safeguarding_flag_derived TINYINT       NOT NULL,         
    incident_reported         TINYINT       NOT NULL,         
	incident_reported_derived    TINYINT       NOT NULL,         
    travel_time_mins          DECIMAL(5,1)  NULL,
    mileage                   DECIMAL(5,1)  NULL,
    travel_data_suspect       TINYINT NOT NULL,
    continuity_flag           TINYINT       NOT NULL,         
    pay_rate_per_hour         DECIMAL(5,2)  NOT NULL,
 
    CONSTRAINT fk_fact_client FOREIGN KEY (client_id) REFERENCES dim_client(client_id),
    CONSTRAINT fk_fact_carer  FOREIGN KEY (carer_id)  REFERENCES dim_carer(carer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
 
-- Populate fact table from clean_visits
START TRANSACTION;
 
INSERT INTO fact_visits
SELECT
   visit_id,
    client_id,
    carer_id,
    scheduled_date,
    visit_type,
    scheduled_time,         
    planned_duration_mins,        
    actual_clock_in,
    actual_clock_out,
    actual_duration_mins,
    visit_status,       
    visit_alert_sent,       
    missed_visit_reason,
    tasks_completed,
    medication_administered,
    carer_notes,
    client_mood,
    safeguarding_flag,         
    safeguarding_flag_derived,        
    incident_reported,        
	incident_reported_derived,      
    travel_time_mins,
    mileage,
    travel_data_suspect,
    continuity_flag,         
    pay_rate_per_hour

FROM clean_visits;
 
-- VALIDATE row_count before committing, EXPECTED: 75,000
SELECT COUNT(*) AS fact_rows FROM fact_visits;

COMMIT;
 