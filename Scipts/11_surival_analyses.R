# Survival analysis
experiments_metadata_lng <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/experiments_metadata_lng.csv")

experiments_metadata_lng <- experiments_metadata_lng %>%
  mutate(TimePoint = as.numeric(gsub("^T", "", TimePoint))) %>%
  mutate(TimePoint = TimePoint, 
         status = ifelse(Survival == "Dead", 1, 0))

#experiments_metadata_lng <- experiments_metadata_lng %>%
#  mutate(TimePoint = as.numeric(gsub("^T", "", TimePoint))) %>%
#  mutate(
#    status = ifelse(Bleaching %in% c("FullBleaching", "PartialBleaching"), 1, 0))

surv_object <- Surv(time = experiments_metadata_lng$TimePoint, 
                    event = experiments_metadata_lng$status)

km_fit <- survfit(surv_object ~ Taxon, data = experiments_metadata_lng)

experiments_metadata_lng$Taxon <- factor(experiments_metadata_lng$Taxon)
experiments_metadata_lng$Taxon <- relevel(experiments_metadata_lng$Taxon, ref = "Taxon1")

coxme_model <- coxme(surv_object ~ Taxon + (1 | SumpID/TankID) + (1 | IndividualID),
                     data = experiments_metadata_lng)

ggsurvplot(km_fit, data = experiments_metadata_lng,
           xlab = "Time (weeks)", ylab = "Surival Probability",
           conf.int = TRUE, pval = TRUE,
           palette = c("mediumorchid", "darkorange1", "olivedrab3"))

# Get HR estimates

coef_df <- summary(coxme_model)$coefficients

hr_df <- data.frame(
  Taxon = rownames(coef_df),
  HR = exp(coef_df[, "coef"]),
  lower = exp(coef_df[, "coef"] - 1.96 * coef_df[, "se(coef)"]),
  upper = exp(coef_df[, "coef"] + 1.96 * coef_df[, "se(coef)"]),
  p = coef_df[, "p"])

hr_df

# Comparing survival across locations

Taxon1_data_lng <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Taxon1_data_lng.csv")

Taxon1_data_lng <- Taxon1_data_lng %>%
  mutate(TimePoint = as.numeric(gsub("^T", "", TimePoint))) %>%
  mutate(TimePoint = TimePoint, 
         status = ifelse(Survival == "Dead", 1, 0))

surv_object <- Surv(time = Taxon1_data_lng$TimePoint, 
                    event = Taxon1_data_lng$status)

km_fit <- survfit(surv_object ~ LocationID, data = Taxon1_data_lng)

ggsurvplot(km_fit, data = Taxon1_data_lng,
           xlab = "Time (weeks)", ylab = "Survival Probability",
           conf.int = TRUE, pval = TRUE)
#palette = c("mediumorchid", "darkorange1", "olivedrab3"))
