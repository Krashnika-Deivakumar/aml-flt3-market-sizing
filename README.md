
# AML 2L FLT3+ Market Sizing & Survival Analysis

This project evaluates the size, characteristics, and outcomes of **Acute Myeloid Leukemia (AML)** patients who received **second-line (2L) therapy** and underwent **FLT3 mutation testing** using real-world data from 2017 to 2024.

---

## Objective

To simulate a real-world biopharma data project by:
- Creating an AML FLT3+ 2L cohort using claims, EMR, and lab data
- Applying robust inclusion and exclusion logic
- Performing survival and treatment sequence analysis
- Delivering visual insights using KM curves, Sankey flows, and forest plots

---

## Data Sources

- **Open/Closed Claims**
- **Lab Testing** (including FLT3 biomarkers)
- **Payer/NPI Master**
- **EMR Structured and Unstructured Clinical Notes**

All sources are tokenized and linked using `patient_token`.

---

## Folder Structure

| Folder | Description |
|--------|-------------|
| `01_data_ingestion/` | SQL to import and link patient-level data |
| `02_cohort_definition/` | AML diagnosis, LoT logic, FLT3 testing, inclusion/exclusion |
| `03_Analytics_approach/` | Descriptive statistics, KM curves, Cox models, visualizations |

---

## Methodology Summary

1. **Data Ingestion** – Merge claims, labs, EMRs by token
2. **Cohort Selection** – Apply inclusion (7 rules) and exclusion (4 rules)
3. **Line of Therapy Logic** – Detect transitions using drug codes and gaps
4. **FLT3 Mutation Flagging** – LOINC codes + NLP mentions
5. **Descriptive Analytics** – Demographics, regimens, mutation subtypes
6. **Survival Analysis** – KM curves, Cox regression, subgroup stratification

---

## Key Outputs

- `km_curve_flt3.png`: Kaplan–Meier curve by FLT3 status
- `cox_forest_plot.png`: Forest plot for hazard ratios
- `sankey_treatment_flow.png`: 1L → 2L transition visualization
- CSVs: Summary statistics, model outputs

---

## Tech Stack

- **SQL**: Preprocessing, patient selection
- **R**: `survival`, `survminer`, `ggplot2`, `ggalluvial` for analytics

---

## Author

**Krashnika Deivakumar**  
[LinkedIn](https://www.linkedin.com/in/krashnika-deivakumar/) | [GitHub](https://github.com/Krashnika-Deivakumar)

---

## How to Use

1. Run SQL scripts in order: ingestion → cohort → FLT3 → exclusion
2. Export final cohort to CSV
3. Load CSV into R and run `survival_analysis.R` or `exploratory_visuals.R`
4. Review outputs in the `outputs/` folder or embed in the report

---

## Data Disclaimer

This is a simulated analytics project designed for mock evaluation and interview preparation.  
No real patient-level data was used. All code, structure, and logic were developed based on publicly described methods and hypothetical assumptions in alignment with standard RWD practices.

---

## Notes

This is a simulated project for interview demonstration purposes, not a real-world study.
