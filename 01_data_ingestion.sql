-- Step 1: Create staging tables 

CREATE TABLE staging_open_claims (
    patient_token VARCHAR(64),
    claim_date DATE,
    diagnosis_code VARCHAR(10),
    procedure_code VARCHAR(10),
    ndc_code VARCHAR(20),
    hcpcs_code VARCHAR(10),
    payer_id VARCHAR(20),
    provider_id VARCHAR(20)
);

CREATE TABLE staging_closed_claims (
    patient_token VARCHAR(64),
    claim_date DATE,
    diagnosis_code VARCHAR(10),
    procedure_code VARCHAR(10),
    ndc_code VARCHAR(20),
    hcpcs_code VARCHAR(10),
    payer_id VARCHAR(20),
    provider_id VARCHAR(20)
);

CREATE TABLE staging_lab_tests (
    patient_token VARCHAR(64),
    lab_test_date DATE,
    loinc_code VARCHAR(10),
    test_result VARCHAR(100)
);

CREATE TABLE staging_emr_structured (
    patient_token VARCHAR(64),
    record_date DATE,
    diagnosis_code VARCHAR(10),
    medication_code VARCHAR(20),
    encounter_type VARCHAR(50)
);

CREATE TABLE staging_emr_unstructured (
    patient_token VARCHAR(64),
    note_date DATE,
    clinical_note TEXT
);

CREATE TABLE payer_npi_master (
    provider_id VARCHAR(20),
    npi_number VARCHAR(20),
    specialty VARCHAR(100),
    organization_name VARCHAR(100)
);

-- Step 2: Link datasets using patient_token

-- Unified Patient Profile (core patient universe)
CREATE TABLE patient_universe AS
SELECT DISTINCT patient_token
FROM (
    SELECT patient_token FROM staging_open_claims
    UNION
    SELECT patient_token FROM staging_closed_claims
    UNION
    SELECT patient_token FROM staging_lab_tests
    UNION
    SELECT patient_token FROM staging_emr_structured
    UNION
    SELECT patient_token FROM staging_emr_unstructured
) AS all_sources;

-- Step 3: Join all sources to patient_universe (linked data layer)

-- Example: Link open claims with lab results
CREATE TABLE patient_claims_labs AS
SELECT oc.patient_token,
       oc.claim_date,
       oc.diagnosis_code,
       lt.lab_test_date,
       lt.loinc_code,
       lt.test_result
FROM staging_open_claims oc
JOIN staging_lab_tests lt
  ON oc.patient_token = lt.patient_token
WHERE DATEDIFF(day, oc.claim_date, lt.lab_test_date) BETWEEN -30 AND 30;

-- Step 4: Link with NPI Master
CREATE TABLE provider_linked_claims AS
SELECT c.*, p.npi_number, p.specialty, p.organization_name
FROM staging_open_claims c
LEFT JOIN payer_npi_master p
  ON c.provider_id = p.provider_id;

-- Optional: Create final joined dataset with EMR and lab details
CREATE TABLE full_linked_dataset AS
SELECT u.patient_token,
       oc.claim_date,
       cc.claim_date AS closed_claim_date,
       lt.lab_test_date,
       lt.test_result,
       emr.record_date,
       emr.diagnosis_code AS emr_diagnosis
FROM patient_universe u
LEFT JOIN staging_open_claims oc ON u.patient_token = oc.patient_token
LEFT JOIN staging_closed_claims cc ON u.patient_token = cc.patient_token
LEFT JOIN staging_lab_tests lt ON u.patient_token = lt.patient_token
LEFT JOIN staging_emr_structured emr ON u.patient_token = emr.patient_token;
