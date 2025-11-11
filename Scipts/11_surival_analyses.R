# 1. Survival analysis all taxa
AllTaxa_data_lng <- read.csv("Data/All_taxa_data/allTaxa_metadata_lng.csv")

AllTaxa_data_lng <- AllTaxa_data_lng %>%
  mutate(TimePoint = as.numeric(gsub("^T", "", TimePoint))) %>%
  mutate(TimePoint = TimePoint, 
         status = ifelse(Survival == "Dead", 1, 0))

surv_object <- Surv(time = AllTaxa_data_lng$TimePoint, 
                    event = AllTaxa_data_lng$status)

km_fit <- survfit(surv_object ~ Taxon, data = AllTaxa_data_lng)

AllTaxa_data_lng$Taxon <- factor(AllTaxa_data_lng$Taxon)
AllTaxa_data_lng$Taxon <- relevel(AllTaxa_data_lng$Taxon, ref = "Taxon1")

coxme_model <- coxme(surv_object ~ Taxon + (1 | SumpID/TankID) + (1 | IndividualID),
                     data = AllTaxa_data_lng)

ggsurvplot(km_fit, data = AllTaxa_data_lng,
           xlab = "Time (weeks)", ylab = "Surival Probability",
           conf.int = TRUE, pval = TRUE,
           palette = c("mediumorchid", "darkorange1", "olivedrab3"))

# 2. Get HR estimates
coef_df <- summary(coxme_model)$coefficients

hr_df <- data.frame(
  Taxon = rownames(coef_df),
  HR = exp(coef_df[, "coef"]),
  lower = exp(coef_df[, "coef"] - 1.96 * coef_df[, "se(coef)"]),
  upper = exp(coef_df[, "coef"] + 1.96 * coef_df[, "se(coef)"]),
  p = coef_df[, "p"])

hr_df

# 3. Survival analyses in Taxon1
Taxon1_data_lng <- read.csv("Data/Taxon1_data/Taxon1_data_lng.csv")

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