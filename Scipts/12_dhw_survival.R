library(survival)
library(coxme)
library(dplyr)
library(ggplot2)
library(tidyr)
library(survminer)

experiments_metadata_lng <- read.csv("Data/Analysis_data/experiments_metadata_lng.csv")
DHW_data <- read.csv("Data/Analysis_data/DHW_data.csv")

experiments_metadata_lng <- experiments_metadata_lng %>%
  mutate(date = as.Date(Date, format = "%d/%m/%Y")) 

DHW_data <- DHW_data %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d"))

# Join DHW data from DHW_data to experiments_metadata_lng
experiments_metadata_DHW <- experiments_metadata_lng %>%
  left_join(
    DHW_data %>% dplyr::select(date, DHW),
    by = "date")

# Make sure surival status is numeric 0/1 in experiments_metadata_DHW
experiments_metadata_DHW <- experiments_metadata_DHW %>%
  mutate(
    status = ifelse(Survival == "Dead", 1, 0),
    Taxon = factor(Taxon)) %>%
  mutate(Taxon = relevel(Taxon, ref = "Taxon1"))

# Make sure bleaching status is numeric 0/1 in experiments_metadata_DHW
experiments_metadata_DHW <- experiments_metadata_DHW %>%
  mutate(
    status_bleaching = ifelse(Bleaching == "NoBleaching", 0, 1),
    Taxon = factor(Taxon)) %>%
  mutate(Taxon = relevel(Taxon, ref = "Taxon1"))

# Find peak DHW date in the dataset
peak_date <- DHW_data %>% filter(DHW == max(DHW)) %>% pull(date)

# Survival analysis over DHW --- Before peak DHW ----

# Filter metadata to only include records up to peak date
experiments_metadata_DHW_before <- experiments_metadata_DHW %>%
  filter(date <= peak_date)

# Create Surv object from the same data frame
dhw_surv_object_before <- Surv(time = experiments_metadata_DHW_before$DHW, event = experiments_metadata_DHW_before$status)

# Kaplan-Meier fit
dhw_km_fit_before <- survfit(dhw_surv_object_before ~ Taxon, data = experiments_metadata_DHW_before)

# Plot
ggsurvplot(
  dhw_km_fit_before, 
  data = experiments_metadata_DHW_before,
  xlab = "DHW (°C-weeks)", 
  ylab = "Survival Probability",
  conf.int = TRUE, 
  pval = TRUE,
  palette = c("mediumorchid", "darkorange1", "olivedrab3"))

# Cox mixed-effects model
coxph_model <- coxme(dhw_surv_object_before ~ Taxon + (1 | SumpID/TankID) + (1 | IndividualID),
                     data = experiments_metadata_DHW_before)
summary(coxph_model)

full_model <- coxme(dhw_surv_object_before ~ Taxon + (1 | SumpID/TankID) + (1 | SumpID) + (1 | IndividualID),
                    data = experiments_metadata_DHW_before)

# Reduced model without Taxon
reduced_model <- coxme(dhw_surv_object_before ~ 1 + (1 | SumpID/TankID) + (1 | SumpID) + (1 | IndividualID),
                       data = experiments_metadata_DHW_before)

# Likelihood ratio test
lrt <- anova(reduced_model, full_model)
print(lrt)

# Survival analysis over DHW --- After peak DHW ----

# Filter metadata to only include records up to peak date
experiments_metadata_DHW_after <- experiments_metadata_DHW %>%
  filter(date > peak_date)

# Create Surv object from the same data frame
dhw_surv_object_after <- Surv(time = experiments_metadata_DHW_after$DHW, event = experiments_metadata_DHW_after$status)

# Kaplan-Meier fit
dhw_km_fit_after <- survfit(dhw_surv_object_after ~ Taxon, data = experiments_metadata_DHW_after)

# Plot
ggsurvplot(
  dhw_km_fit_after, 
  data = experiments_metadata_DHW_after,
  xlab = "DHW (°C-weeks)", 
  ylab = "Survival Probability",
  conf.int = TRUE, 
  pval = TRUE,
  palette = c("mediumorchid", "darkorange1", "olivedrab3"))

# Cox mixed-effects model
coxph_model <- coxme(dhw_km_fit_before ~ Taxon + (1 | SumpID/TankID) + (1 | IndividualID),
                     data = experiments_metadata_DHW_before)
summary(coxph_model)

# Bleaching analysis over DHW --- Before peak DHW ----

# Filter metadata to only include records up to peak date
experiments_metadata_DHW_before <- experiments_metadata_DHW %>%
  filter(date <= peak_date)

# Create Surv object from the same data frame
dhw_blc_object_before <- Surv(time = experiments_metadata_DHW_before$DHW, event = experiments_metadata_DHW_before$status_bleaching)

# Kaplan-Meier fit
dhw_km_blc_fit_before <- survfit(dhw_blc_object_before ~ Taxon, data = experiments_metadata_DHW_before)

# Plot
ggsurvplot(
  dhw_km_blc_fit_before, 
  data = experiments_metadata_DHW_before,
  xlab = "DHW (°C-weeks)", 
  ylab = "Bleaching probability",
  conf.int = TRUE, 
  pval = TRUE,
  fun = "event",
  palette = c("mediumorchid", "darkorange1", "olivedrab3"))

# Bleaching analysis over DHW --- After peak DHW ----

# Filter metadata to only include records up to peak date
experiments_metadata_DHW_after <- experiments_metadata_DHW %>%
  filter(date > peak_date)

# Create Surv object from the same data frame
dhw_blc_object_after <- Surv(time = experiments_metadata_DHW_after$DHW, event = experiments_metadata_DHW_after$status_bleaching)

# Kaplan-Meier fit
dhw_km_blc_fit_after <- survfit(dhw_blc_object_after ~ Taxon, data = experiments_metadata_DHW_after)

# Plot
ggsurvplot(
  dhw_km_blc_fit_after, 
  data = experiments_metadata_DHW_after,
  xlab = "DHW (°C-weeks)", 
  ylab = "Bleaching probability",
  conf.int = TRUE, 
  pval = TRUE,
  fun = "event",
  palette = c("mediumorchid", "darkorange1", "olivedrab3"))