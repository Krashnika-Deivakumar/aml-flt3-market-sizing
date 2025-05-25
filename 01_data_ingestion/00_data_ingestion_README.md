
## Module: `01_data_ingestion.sql`

### Purpose:
This module handles **data ingestion and linkage** across all datasets using the **`patient_token`** identifier. It forms the foundation for subsequent cohort creation, treatment mapping, and biomarker analysis.

---

### Input Datasets:
| Dataset                 | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| `staging_open_claims`   | Raw open claims data with diagnosis, procedure, and drug codes              |
| `staging_closed_claims` | Raw closed claims data                                                      |
| `staging_lab_tests`     | Lab test results, including LOINC codes for genetic/biomarker testing       |
| `staging_emr_structured`| EMR entries with diagnoses, medications, and encounters                     |
| `staging_emr_unstructured`| Unstructured EMR notes (optional NLP usage for biomarkers)                |
| `payer_npi_master`      | Provider information with NPI numbers, specialties, and affiliations        |

---

### Key Tasks Performed:
| Step | Action |
|------|--------|
| **1** | (Optional) Create staging tables for each dataset |
| **2** | Generate a **`patient_universe`** by extracting unique `patient_token`s from all sources |
| **3** | Link patient records across datasets to support downstream analyses (e.g., lab-claims, EMR-lab) |
| **4** | Join claims data with **NPI/Provider** master for additional metadata |
| **5** | Build a comprehensive **`full_linked_dataset`** combining claims, labs, and EMR for each patient |

---

### Output Tables/Views:
| Output Table/View         | Description |
|---------------------------|-------------|
| `patient_universe`        | Core set of unique patients |
| `patient_claims_labs`     | Joined view of claims and lab test results |
| `provider_linked_claims`  | Claims data enriched with NPI and provider specialty |
| `full_linked_dataset`     | Combined claims, labs, and EMR data for downstream use |

---

### Assumptions:
- `patient_token` is consistently used to link records across all datasets.
- Date ranges can be adjusted based on clinical event alignment needs (e.g., lab results ±30 days of claims).
- Data is already cleaned at source ingestion (basic null checks may still apply downstream).

