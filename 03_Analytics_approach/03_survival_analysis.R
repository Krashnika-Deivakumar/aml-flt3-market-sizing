# survival_analysis.R

library(survival)
library(survminer)
library(dplyr)
library(readr)

# Load cohort data
cohort <- read_csv("final_cohort_survival.csv")  # Assumes index_date, event_date, death_flag, flt3_status, age, payer_type, regimen_type, comorbidity_flag

# Prepare survival object
cohort <- cohort %>%
  mutate(time_to_event = as.integer(difftime(event_date, index_date, units = "days")))

surv_object <- Surv(time = cohort$time_to_event, event = cohort$death_flag)

# Kaplan-Meier: by FLT3 status
km_fit_flt3 <- survfit(surv_object ~ flt3_status, data = cohort)
ggsurvplot(km_fit_flt3, data = cohort, pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, title = "Kaplan-Meier Survival by FLT3 Status")

# KM by age group (<60 vs >=60)
cohort <- cohort %>% mutate(age_group = ifelse(age < 60, "<60", "60+"))
km_fit_age <- survfit(surv_object ~ age_group, data = cohort)
ggsurvplot(km_fit_age, data = cohort, pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, title = "Survival by Age Group")

# KM by payer type
km_fit_payer <- survfit(surv_object ~ payer_type, data = cohort)
ggsurvplot(km_fit_payer, data = cohort, pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, title = "Survival by Payer Type")

# KM by regimen type
km_fit_regimen <- survfit(surv_object ~ regimen_type, data = cohort)
ggsurvplot(km_fit_regimen, data = cohort, pval = TRUE, conf.int = TRUE,
           risk.table = TRUE, title = "Survival by Regimen Type")

# Cox proportional hazards model
cox_model <- coxph(surv_object ~ flt3_status + age + payer_type + regimen_type + comorbidity_flag, data = cohort)
summary(cox_model)

# Stratified Cox: by age group and payer type
cox_model_strat <- coxph(surv_object ~ flt3_status + regimen_type + comorbidity_flag + strata(age_group, payer_type), data = cohort)
summary(cox_model_strat)

# Save outputs (KM and Cox summaries)
write.csv(as.data.frame(summary(km_fit_flt3)$table), "km_flt3_summary.csv")
write.csv(as.data.frame(summary(cox_model)$coefficients), "cox_model_summary.csv")
