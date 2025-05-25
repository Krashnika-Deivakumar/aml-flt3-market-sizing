# sankey_plot.R

library(dplyr)
library(readr)
library(ggplot2)
library(ggalluvial)

# Read data with treatment line info
lot_data <- read_csv("final_lot_assignment.csv")  # Should contain patient_token, lot_number, drug_name, flt3_status

# Pivot to wide format: one row per patient with LoT1 and LoT2
sankey_data <- lot_data %>%
  filter(lot_number %in% c(1, 2)) %>%
  select(patient_token, lot_number, drug_name, flt3_status) %>%
  pivot_wider(names_from = lot_number, values_from = drug_name, names_prefix = "LoT") %>%
  filter(!is.na(LoT1), !is.na(LoT2)) %>%
  count(flt3_status, LoT1, LoT2)

# Plot Sankey
ggplot(sankey_data,
       aes(axis1 = LoT1, axis2 = LoT2, y = n)) +
  geom_alluvium(aes(fill = LoT1), width = 1/12) +
  geom_stratum(width = 1/12, fill = "gray90", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 3.5) +
  facet_wrap(~flt3_status) +
  scale_x_discrete(limits = c("First-line", "Second-line"), expand = c(.05, .05)) +
  labs(title = "Treatment Sequence from 1L to 2L by FLT3 Status",
       y = "Number of Patients",
       x = "Line of Therapy") +
  theme_minimal()
