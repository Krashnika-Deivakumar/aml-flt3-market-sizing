-- Line of Therapy (LoT) Assignment for AML Patients

-- Step 1: Identify First AML Drug Post Diagnosis (Start of LoT1)
WITH first_aml_drug AS (
    SELECT m.patient_token, MIN(m.med_date) AS lot1_start_date
    FROM medications m
    JOIN aml_diagnosis d ON m.patient_token = d.patient_token
    WHERE m.drug_class = 'AML-specific'
      AND m.med_date >= d.aml_diagnosis_date
    GROUP BY m.patient_token
),

-- Step 2: Define Initial Regimen Window (28 days from first AML drug)
initial_regimen AS (
    SELECT m.patient_token, m.drug_name, m.med_date, f.lot1_start_date
    FROM medications m
    JOIN first_aml_drug f ON m.patient_token = f.patient_token
    WHERE m.drug_class = 'AML-specific'
      AND m.med_date BETWEEN f.lot1_start_date AND DATEADD(DAY, 28, f.lot1_start_date)
),

-- Step 3: Group Identical Regimens within the 60-day gap as same LoT
regimen_continuation AS (
    SELECT m.patient_token, m.drug_name, m.med_date,
           LAG(m.med_date) OVER (PARTITION BY m.patient_token, m.drug_name ORDER BY m.med_date) AS prev_date
    FROM medications m
    JOIN initial_regimen r ON m.patient_token = r.patient_token
    WHERE m.drug_class = 'AML-specific'
),

-- Step 4: Identify gaps ≥60 days or new drugs triggering new LoT
lot_transitions AS (
    SELECT patient_token, drug_name, med_date,
           CASE 
             WHEN DATEDIFF(DAY, prev_date, med_date) >= 60 THEN 1
             ELSE 0
           END AS is_new_lot
    FROM regimen_continuation
),

-- Step 5: Assign LoT number by cumulative sum of transitions
lot_numbering AS (
    SELECT *,
           SUM(is_new_lot) OVER (PARTITION BY patient_token ORDER BY med_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) + 1 AS lot_number
    FROM lot_transitions
),

-- Step 6: HSCT (Stem Cell Transplant) Rules
hsct_lot_rule AS (
    SELECT h.patient_token, h.hsct_date, MAX(l.med_date) AS last_drug_date
    FROM stem_cell_transplants h
    JOIN lot_numbering l ON h.patient_token = l.patient_token
    WHERE DATEDIFF(DAY, l.med_date, h.hsct_date) <= 60
    GROUP BY h.patient_token, h.hsct_date
),

-- Final Output: Patient, drug, LoT number, start date
final_lot_assignment AS (
    SELECT l.patient_token, l.drug_name, l.med_date, l.lot_number
    FROM lot_numbering l
    WHERE NOT EXISTS (
        SELECT 1
        FROM hsct_lot_rule h
        WHERE h.patient_token = l.patient_token
          AND h.hsct_date = l.med_date
    )
)

SELECT * FROM final_lot_assignment
ORDER BY patient_token, lot_number, med_date;
