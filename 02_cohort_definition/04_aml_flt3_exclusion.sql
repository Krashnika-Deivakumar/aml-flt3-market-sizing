-- AML FLT3+ 2L Cohort Exclusion Criteria

-- Step 1: Exclude patients with non-AML malignancy in the past 12 months
WITH non_aml_cancer_exclusion AS (
    SELECT DISTINCT d.patient_token
    FROM diagnoses d
    JOIN aml_diagnosis ad ON d.patient_token = ad.patient_token
    WHERE d.diagnosis_code BETWEEN 'C00' AND 'C80'
      AND d.diagnosis_code NOT LIKE 'C92%'
      AND d.diagnosis_date BETWEEN DATEADD(MONTH, -12, ad.aml_diagnosis_date) AND ad.aml_diagnosis_date
),

-- Step 2: Exclude patients exposed to non-AML antineoplastic agents in 12 months prior to index
excluded_drugs AS (
    SELECT DISTINCT patient_token
    FROM medications
    JOIN drug_reference r ON medications.ndc_code = r.ndc_code
    WHERE r.drug_class IN ('Platinum', 'Taxane', 'Non-AML antineoplastic')
      AND medications.med_date < (SELECT MIN(lot2_start_date) FROM lot2_start WHERE patient_token = medications.patient_token)
      AND medications.med_date >= DATEADD(MONTH, -12, (SELECT MIN(lot2_start_date) FROM lot2_start WHERE patient_token = medications.patient_token))
),

-- Step 3: Exclude clinical trial participants
clinical_trial_participants AS (
    SELECT DISTINCT patient_token
    FROM clinical_trials
    WHERE trial_flag = 1
),

-- Step 4: Exclude records with missing patient_token in any core dataset
missing_token_exclusion AS (
    SELECT patient_token FROM (
        SELECT patient_token FROM staging_open_claims WHERE patient_token IS NULL
        UNION
        SELECT patient_token FROM staging_closed_claims WHERE patient_token IS NULL
        UNION
        SELECT patient_token FROM lab_tests WHERE patient_token IS NULL
        UNION
        SELECT patient_token FROM emr_structured WHERE patient_token IS NULL
        UNION
        SELECT patient_token FROM emr_unstructured WHERE patient_token IS NULL
    ) AS missing
)

-- Final exclusion list
SELECT DISTINCT patient_token
FROM (
    SELECT patient_token FROM non_aml_cancer_exclusion
    UNION
    SELECT patient_token FROM excluded_drugs
    UNION
    SELECT patient_token FROM clinical_trial_participants
    UNION
    SELECT patient_token FROM missing_token_exclusion
) AS all_exclusions;
