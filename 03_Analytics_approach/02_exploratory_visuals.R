# exploratory_visuals.R

# Load required libraries
library(ggplot2)
library(dplyr)
library(readr)
library(ggalluvial)  # For Sankey plots
library(forcats)
library(scales)

# Load datasets
cohort <- read_csv("final_cohort.csv")
lot <- read_csv("final_lot_assignment.csv")

# Bar Chart: Mutation Prevalence by FLT3 Status
cohort %>%
  count(flt3_status) %>%
  ggplot(aes(x = flt3_status, y = n, fill = flt3_status)) +
  geom_bar(stat = "identity") +
  labs(title = "FLT3 Mutation Status Distribution", x = "FLT3 Status", y = "Count") +
  theme_minimal()

# Bar Chart: Payer Type Distribution by FLT3 Status
cohort %>%
  count(flt3_status, payer_type) %>%
  ggplot(aes(x = payer_type, y = n, fill = flt3_status)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Payer Type by FLT3 Status", x = "Payer Type", y = "Count") +
  theme_minimal()

# Sankey Diagram: Treatment Sequences from 1L to 2L
sankey_data <- lot %>%
  filter(lot_number %in% c(1, 2)) %>%
  select(patient_token, lot_number, drug_name) %>%
  pivot_wider(names_from = lot_number, values_from = drug_name, names_prefix = "LoT") %>%
  filter(!is.na(LoT1) & !is.na(LoT2)) %>%
  count(LoT1, LoT2)

ggplot(sankey_data, aes(axis1 = LoT1, axis2 = LoT2, y = n)) +
  geom_alluvium(aes(fill = LoT1), width = 1/12) +
  geom_stratum(width = 1/12, fill = "grey", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_x_discrete(limits = c("1L", "2L"), expand = c(.05, .05)) +
  labs(title = "Treatment Sequence: 1L to 2L", y = "Number of Patients") +
  theme_minimal()

# Box Plot: Age Distribution by FLT3 Status
cohort <- cohort %>%
  mutate(age = as.integer(difftime(index_date, birth_date, units = "days") / 365.25))

ggplot(cohort, aes(x = flt3_status, y = age, fill = flt3_status)) +
  geom_boxplot() +
  labs(title = "Age Distribution by FLT3 Status", x = "FLT3 Status", y = "Age") +
  theme_minimal()

# Histogram: Time from Diagnosis to 2L
cohort <- cohort %>%
  mutate(days_to_2L = as.integer(difftime(index_date, aml_diagnosis_date, units = "days")))

ggplot(cohort, aes(x = days_to_2L)) +
  geom_histogram(binwidth = 30, fill = "#1f78b4", color = "white") +
  facet_wrap(~flt3_status) +
  labs(title = "Time from AML Diagnosis to 2L Initiation", x = "Days", y = "Patients") +
  theme_minimal()

# Line Chart: Year-over-Year FLT3 Testing Trends
cohort <- cohort %>%
  mutate(index_year = lubridate::year(index_date))

cohort %>%
  count(index_year, flt3_status) %>%
  ggplot(aes(x = index_year, y = n, color = flt3_status)) +
  geom_line(size = 1.2) +
  labs(title = "Year-over-Year FLT3 Testing Trends", x = "Year", y = "Patients") +
  theme_minimal()
