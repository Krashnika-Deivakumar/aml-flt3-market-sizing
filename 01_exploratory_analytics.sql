-- exploratory_analytics.sql

-- Step 1: Basic demographics by FLT3 status
SELECT 
    flt3_status,  -- e.g., 'Positive', 'Negative'
    COUNT(*) AS patient_count,
    AVG(DATEDIFF(YEAR, birth_date, index_date)) AS avg_age,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(YEAR, birth_date, index_date)) AS median_age,
    COUNT(DISTINCT CASE WHEN sex = 'F' THEN patient_token END) * 1.0 / COUNT(*) AS pct_female,
    COUNT(DISTINCT geographic_region) AS region_count,
    COUNT(DISTINCT CASE WHEN payer_type = 'Commercial' THEN patient_token END) * 1.0 / COUNT(*) AS pct_commercial
FROM final_cohort
GROUP BY flt3_status;

-- Step 2: Clinical characteristics
SELECT 
    flt3_status,
    COUNT(*) AS n,
    COUNT(DISTINCT CASE WHEN comorbidity_flag = 1 THEN patient_token END) AS with_comorbidity,
    AVG(DATEDIFF(DAY, aml_diagnosis_date, index_date)) AS avg_time_to_2L,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(DAY, aml_diagnosis_date, index_date)) AS median_time_to_2L
FROM final_cohort
GROUP BY flt3_status;

-- Step 3: Mutation testing breakdown
SELECT 
    mutation_tested,
    flt3_subtype,
    COUNT(*) AS n
FROM flt3_testing_summary
GROUP BY mutation_tested, flt3_subtype;

-- Step 4: Treatment characteristics
-- a) Time on 1L therapy
SELECT 
    flt3_status,
    AVG(DATEDIFF(DAY, lot1_start_date, lot2_start_date)) AS avg_days_on_1L,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(DAY, lot1_start_date, lot2_start_date)) AS median_days_on_1L
FROM final_cohort
GROUP BY flt3_status;

-- b) Most common 2L regimens
SELECT 
    flt3_status,
    drug_name,
    COUNT(DISTINCT patient_token) AS patient_count
FROM final_cohort fc
JOIN final_lot_assignment flt ON fc.patient_token = flt.patient_token AND flt.lot_number = 2
GROUP BY flt3_status, drug_name
ORDER BY flt3_status, patient_count DESC;

-- c) HSCT rates
SELECT 
    flt3_status,
    COUNT(DISTINCT CASE WHEN hsct_flag = 1 THEN patient_token END) AS hsct_count,
    COUNT(*) AS total,
    COUNT(DISTINCT CASE WHEN hsct_flag = 1 THEN patient_token END) * 1.0 / COUNT(*) AS hsct_rate
FROM final_cohort
GROUP BY flt3_status;
