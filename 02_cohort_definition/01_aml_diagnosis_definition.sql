-- Updated AML Diagnosis Definition (per Section 5.2)

-- Step 1: ICD-10-CM codes for AML diagnosis
WITH icd_based_diagnosis AS (
    SELECT patient_token, claim_date AS diagnosis_date
    FROM (
        SELECT patient_token, claim_date, diagnosis_code
        FROM staging_open_claims
        WHERE diagnosis_code LIKE 'C92%' OR diagnosis_code LIKE 'C94.0%'

        UNION

        SELECT patient_token, claim_date, diagnosis_code
        FROM staging_closed_claims
        WHERE diagnosis_code LIKE 'C92%' OR diagnosis_code LIKE 'C94.0%'
    )
),

-- Step 2: CPT-based diagnosis (bone marrow biopsy/aspiration)
cpt_based_diagnosis AS (
    SELECT patient_token, claim_date AS diagnosis_date
    FROM procedures
    WHERE cpt_code BETWEEN '38220' AND '38223'
),

-- Step 3: Lab evidence of ≥20% blasts
lab_blasts_based AS (
    SELECT patient_token, lab_date AS diagnosis_date
    FROM lab_tests
    WHERE test_name LIKE '%blast%'
      AND TRY_CAST(test_result AS FLOAT) >= 20
),

-- Step 4: NLP mentions in unstructured notes
nlp_mentions AS (
    SELECT patient_token, note_date AS diagnosis_date
    FROM emr_unstructured
    WHERE clinical_note LIKE '%acute myeloid leukemia%' OR clinical_note LIKE '%AML relapse%'
      AND clinical_note NOT LIKE '%no evidence of AML%'  -- negation handling
),

-- Step 5: Claims-based rule: ≥1 inpatient or ≥2 outpatient AML claims ≥30 days apart
claims_rule_based AS (
    SELECT patient_token, claim_date AS diagnosis_date
    FROM (
        SELECT patient_token, claim_date, encounter_type
        FROM emr_structured
        WHERE diagnosis_code LIKE 'C92%' OR diagnosis_code LIKE 'C94.0%'
    ) q
    WHERE encounter_type = 'Inpatient'

    UNION

    SELECT patient_token, MIN(claim_date) AS diagnosis_date
    FROM (
        SELECT patient_token, claim_date
        FROM emr_structured
        WHERE diagnosis_code LIKE 'C92%' OR diagnosis_code LIKE 'C94.0%'
          AND encounter_type = 'Outpatient'
    ) o
    GROUP BY patient_token
    HAVING COUNT(*) >= 2 AND MAX(claim_date) - MIN(claim_date) >= 30
),

-- Combine all diagnosis definitions and pick earliest
aml_diagnosis_all_sources AS (
    SELECT patient_token, diagnosis_date FROM icd_based_diagnosis
    UNION
    SELECT patient_token, diagnosis_date FROM cpt_based_diagnosis
    UNION
    SELECT patient_token, diagnosis_date FROM lab_blasts_based
    UNION
    SELECT patient_token, diagnosis_date FROM nlp_mentions
    UNION
    SELECT patient_token, diagnosis_date FROM claims_rule_based
),

-- Final AML diagnosis date per patient
aml_diagnosis AS (
    SELECT patient_token, MIN(diagnosis_date) AS aml_diagnosis_date
    FROM aml_diagnosis_all_sources
    GROUP BY patient_token
)

-- Use aml_diagnosis CTE for downstream cohort definition
SELECT * FROM aml_diagnosis;
