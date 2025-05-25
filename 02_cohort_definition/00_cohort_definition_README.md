## Cohort Creation: AML FLT3+ 2L Patients

This module outlines the complete logic used to define the **inclusion cohort** of patients with Acute Myeloid Leukemia (AML) who:
- Initiated second-line (2L) therapy
- Had confirmed FLT3 mutation status
- Met baseline activity and data completeness requirements

---

### Inclusion Criteria Applied

1. **Confirmed AML Diagnosis**
   - ICD-10-CM: C92.0x–C92.9x, C94.0x
   - CPT: 38220–38223 (bone marrow biopsy)
   - Lab: ≥20% blasts in peripheral or marrow
   - NLP: Clinical mentions (e.g., "AML relapse")
   - Claims Rule: ≥1 inpatient or ≥2 outpatient AML claims ≥30 days apart  
   ➤ *Earliest qualifying date assigned as AML diagnosis*

2. **Adult Patients**
   - Age ≥18 years at time of AML diagnosis

3. **1L Therapy Within 30 Days**
   - First AML-specific drug administered within 30 days of diagnosis

4. **2L Therapy Initiation (Index Date)**
   - Based on Line-of-Therapy logic (gap ≥60 days or new drug/regimen)

5. **≥12 Months of Continuous Enrollment Prior to Index**
   - Claims or EMR activity across at least 12 distinct months in baseline period

6. **≥1 Day of Follow-Up After Index**
   - Post-index evidence of claims or EMR activity

7. **FLT3 Biomarker Testing**
   - Lab (LOINC): FLT3-ITD or FLT3-TKD
   - EMR NLP: Clinical note mentions
   - Testing window: –6 months to +1 month relative to 2L start

---


### Exclusion Criteria Applied

1. **non-AML malignancy**
   - ICD-10-CM codes C00–C80, excluding C92.* within 12 months prior to AML diagnosis, to minimize confounding due to other primary cancers

2. **Exposure to non-AML antineoplastic agents**
   - e.g., platinum compounds, taxanes) in the 12-month pre-index period, indicating treatment for another primary cancer
     
3. **clinical trials exposure**
   - identified by claims flagged with “research” or trial-specific codes
     
4. **Missing patient_token in any of the core datasets**
   - claims, lab, or EMR, preventing consistent linkage across sources
        
---


### Dependent Files

| File | Purpose |
|------|---------|
| `01_aml_diagnosis_definition.sql` | Establish earliest AML diagnosis |
| `02_lot_assignment.sql` | Assign LoT and determine index |
| `03_aml_flt3_inclusion.sql` | Apply all 7 inclusion criteria |
| `04_aml_flt3_exclusion.sql` | Apply all 4 exclusion criteria |

---

### Output

The script outputs a table of **patients who meet all inclusion criteria**, with:
- `patient_token`
- `AML diagnosis date`
- `1L start date`
- `2L (index) start date`

