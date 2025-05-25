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
km_plot <- ggsurvplot(km_fit_flt3, data = cohort, pval = TRUE, conf.int = TRUE,
                      risk.table = TRUE, title = "Kaplan-Meier Survival by FLT3 Status")
print(km_plot)

ggsave("km_curve_flt3.png", km_plot$plot, width = 8, height = 6)

# Cox proportional hazards model
cox_model <- coxph(surv_object ~ flt3_status + age + payer_type + regimen_type + comorbidity_flag, data = cohort)
cox_summary <- summary(cox_model)

# Forest plot for Cox model
forest_plot <- ggforest(cox_model, data = cohort, main = "Cox Proportional Hazards Model", cpositions = c(0.02, 0.22, 0.4), fontsize = 1)

ggsave("cox_forest_plot.png", plot = last_plot(), width = 8, height = 6)

# Stratified Cox (e.g., by age group and payer type)
cohort <- cohort %>% mutate(age_group = ifelse(age < 60, "<60", "60+"))
cox_model_strat <- coxph(surv_object ~ flt3_status + regimen_type + comorbidity_flag + strata(age_group, payer_type), data = cohort)
summary(cox_model_strat)

# Save KM and Cox summaries
write.csv(as.data.frame(cox_summary$coefficients), "cox_model_summary.csv")
write.csv(as.data.frame(summary(km_fit_flt3)$table), "km_summary_flt3.csv")
