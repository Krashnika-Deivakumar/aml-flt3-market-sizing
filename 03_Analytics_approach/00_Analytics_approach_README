# Exploratory & Outcome Analysis for AML FLT3+ 2L Cohort

This module includes scripts and outputs for:
- Descriptive summary statistics of the patient cohort
- Kaplan–Meier survival curves
- Cox proportional-hazards regression
- Stratified subgroup analyses
- Publication-ready visualizations (bar charts, Sankey, boxplots, forest plots)

---

## 🔍 Exploratory Analysis (Section 8.1 & 8.2)

### Descriptive Statistics
Key metrics computed by FLT3 status (positive vs negative):
- **Demographics**: Age, sex, geographic region, payer type
- **Clinical characteristics**: Time to 2L, comorbidity flags
- **Mutation testing**: FLT3 testing rate, subtype distribution (ITD vs TKD)
- **Treatment**: Time on 1L, most common 2L regimens, HSCT rates

### Visualizations
| Chart Type | Purpose |
|------------|---------|
| **Bar charts** | Mutation prevalence, therapy usage, payer mix |
| **Sankey diagrams** | Treatment sequence transitions from 1L to 2L |
| **Funnel plots** | Patient attrition through inclusion criteria |
| **Histograms / Boxplots** | Age distribution, time-to-treatment |
| **Line charts** | Trends in testing/treatment patterns (YOY) |

Files:
- `exploratory_analytics.sql`
- `exploratory_visuals.R`

---

## 🧪 Outcome Analysis (Section 8.3 & 8.4)

### Survival Data Construction
- Death date derived from:
  - Structured EMR > Unstructured EMR > Closed Claims (priority)
- Censoring based on latest available activity:
  - Claims, labs, or EMR notes
- Outcome:
  - `death_flag`: 1 = died after index, 0 = censored
  - `time_to_event`: days from 2L initiation to death/censoring

### Kaplan–Meier Curves
- Stratified by:
  - FLT3 status
  - Regimen type (FLT3i vs non-FLT3i)
  - Age group (<60 vs ≥60)
  - Payer type

### Cox Proportional-Hazards Models
- Adjusted for:
  - Age at index
  - Payer type
  - Regimen type
  - Comorbidity status
- Forest plot visualization for hazard ratios

### Stratified Subgroup Analyses
- Repeated KM and Cox models across:
  - Age groups
  - Payer types
  - Geographic regions
  - Diagnosis year (2017–2020 vs 2021–2024)

Files:
- `03_outcomes_analysis.sql` (for event data)
- `survival_analysis.R` (KM + Cox models)

---

## 📂 Outputs
- CSVs: Summary tables
- PNGs: KM curves, Sankey diagrams, forest plots
- Ready-to-embed visuals for slides/reports

---

## 🛠 Tools Used
- **SQL**: For data extraction and preprocessing
- **R**: `survival`, `survminer`, `ggplot2`, `ggalluvial` for analytics and plotting
