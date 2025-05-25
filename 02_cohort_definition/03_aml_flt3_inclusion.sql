-- Final Inclusion Criteria for AML FLT3+ 2L Patients

-- Step 1: AML diagnosis already defined in aml_diagnosis CTE
-- Step 2: Age ≥18 years at diagnosis
WITH adult_aml_patients AS (
    SELECT d.patient_token, d.aml_diagnosis_date
    FROM aml_diagnosis d
    JOIN demographics dem ON d.patient_token = dem.patient_token
    WHERE DATEDIFF(YEAR, dem.birth_date, d.aml_diagnosis_date) >= 18
),

-- Step 3: Identify LoT1 start date
lot1_dates AS (
    SELECT patient_token, MIN(med_date) AS lot1_start_date
    FROM final_lot_assignment
    WHERE lot_number = 1
    GROUP BY patient_token
),

-- Step 4: Identify LoT2 start date (index date)
lot2_dates AS (
    SELECT patient_token, MIN(med_date) AS lot2_start_date
    FROM final_lot_assignment
    WHERE lot_number = 2
    GROUP BY patient_token
),

-- Step 5: Ensure 1L starts within 30 days of diagnosis
valid_lot1_patients AS (
    SELECT a.patient_token, a.aml_diagnosis_date, l1.lot1_start_date
    FROM adult_aml_patients a
    JOIN lot1_dates l1 ON a.patient_token = l1.patient_token
    WHERE DATEDIFF(DAY, a.aml_diagnosis_date, l1.lot1_start_date) BETWEEN 0 AND 30
),

-- Step 6: Add 2L index and enforce presence
patients_with_index_date AS (
    SELECT v.patient_token, v.aml_diagnosis_date, v.lot1_start_date, l2.lot2_start_date
    FROM valid_lot1_patients v
    JOIN lot2_dates l2 ON v.patient_token = l2.patient_token
),

-- Step 7: Continuous enrollment ≥12 months prior to 2L
continuous_enrollment AS (
    SELECT p.patient_token
    FROM patients_with_index_date p
    JOIN activity_log a ON p.patient_token = a.patient_token
    WHERE a.activity_date BETWEEN DATEADD(MONTH, -12, p.lot2_start_date) AND p.lot2_start_date
    GROUP BY p.patient_token, p.lot2_start_date
    HAVING COUNT(DISTINCT a.activity_month) >= 12
),

-- Step 8: At least 1 day follow-up after 2L
post_index_followup AS (
    SELECT p.patient_token
    FROM patients_with_index_date p
    JOIN activity_log a ON p.patient_token = a.patient_token
    WHERE a.activity_date > p.lot2_start_date
),

-- Step 9: FLT3 testing within –6M to +1M of 2L index date
flt3_tested_patients AS (
    SELECT DISTINCT p.patient_token
    FROM patients_with_index_date p
    JOIN lab_tests l ON p.patient_token = l.patient_token
    WHERE l.test_code IN ('FLT3-ITD', 'FLT3-TKD')
      AND l.lab_date BETWEEN DATEADD(MONTH, -6, p.lot2_start_date) AND DATEADD(MONTH, 1, p.lot2_start_date)

    UNION

    SELECT DISTINCT p.patient_token
    FROM patients_with_index_date p
    JOIN emr_unstructured u ON p.patient_token = u.patient_token
    WHERE u.clinical_note LIKE '%FLT3%'
      AND u.note_date BETWEEN DATEADD(MONTH, -6, p.lot2_start_date) AND DATEADD(MONTH, 1, p.lot2_start_date)
)

-- Final Inclusion Set
SELECT p.*
FROM patients_with_index_date p
WHERE p.patient_token IN (SELECT patient_token FROM continuous_enrollment)
  AND p.patient_token IN (SELECT patient_token FROM post_index_followup)
  AND p.patient_token IN (SELECT patient_token FROM flt3_tested_patients);
