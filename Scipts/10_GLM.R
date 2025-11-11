library(lme4)
library(survminer)
library(dplyr)
library(glmmTMB)
library(emmeans)
library(car)

Alltaxa_responses <- read.csv("Data/All_taxa_data/allTaxa_responses.csv")
Alltaxa_responses_lng <- read.csv("Data/All_taxa_data/allTaxa_responses_lng.csv")

Taxon1_responses_filtered <- read.csv("/Data/Taxon1_data/Taxon1_responses_filtered.csv")
Taxon1_responses_with_thermal_metrics <- read.csv("/Data/Taxon1_data/Taxon1_responses_with_thermal_metrics.csv")

options(contrasts = c("contr.sum", "contr.poly"))

#### Last time alive  -----------------------------------------------------
LTA_model <- glmmTMB(data=Alltaxa_responses, time_alive ~ (1|IndividualID) + (1|SumpID/TankID) + Taxon, family = nbinom1)
summary(LTA_model)
Anova(LTA_model, type = 3)
emm_LTA <- emmeans(LTA_model, ~ Taxon, type = "response")

LTA_model_T1 <- glmmTMB(data=Taxon1_responses_with_thermal_metrics, time_alive ~ (1|IndividualID) + (1|SumpID/TankID) + tempPC1 + tempPC2, family = nbinom1)
summary(LTA_model_T1)

#### Last time unbleached -----------------------------------------------------
LTU_model <- glmmTMB(data=Alltaxa_responses, time_without_bleaching ~ (1|IndividualID) + (1|SumpID/TankID) + Taxon, family = nbinom1)
Anova(LTU_model, type = 3)
emm_LTU <- emmeans(LTU_model, ~ Taxon, type = "response")

LTU_model_T1 <- glmmTMB(data=Taxon1_responses_with_thermal_metrics, time_without_bleaching ~ (1|IndividualID) + (1|SumpID/TankID) + tempPC1 + tempPC2, family = nbinom1)
summary(LTU_model_T1)

#### Maximum bleaching area GLM  -----------------------------------------------------
epsilon <- 1e-6
Alltaxa_responses_lng$max_bleaching_adj <- pmin(pmax(Alltaxa_responses_lng$max_bleaching, epsilon), 1 - epsilon)
MB_model <- glmmTMB(data=Alltaxa_responses_lng, max_bleaching_adj ~ (1|IndividualID) + (1|SumpID/TankID) + Taxon, family=beta_family)
emm_MB <- emmeans(MB_model, ~ Taxon, type = "response")

Taxon1_responses_filtered$max_bleaching_adj <- pmin(pmax(Taxon1_responses_filtered$max_bleaching, epsilon), 1 - epsilon)
MB_model_T1 <- glmmTMB(data=Taxon1_responses_filtered, max_bleaching_adj ~ (1|IndividualID) + (1|SumpID/TankID) + tempPC1 + tempPC2, family=beta_family)
summary(MB_model_T1)

#### Time to recovery -----------------------------------------------------
TR_model <- glmmTMB(data=Alltaxa_responses_lng, time_to_recovery_paling ~ (1|IndividualID) + (1|SumpID/TankID) + Taxon, family = nbinom1)
summary(TR_model)
Anova(TR_model, type = 3)
emm_TR <- emmeans(TR_model, ~ Taxon, type = "response")
emm_TR_df<- as.data.frame(emm_TR)

pairwise_TR <- contrast(emm_TR, method = "pairwise", adjust = "tukey")
summary(pairwise_TR)

TR_model_T1 <- glmmTMB(data=Taxon1_responses_filtered, time_to_recovery ~ (1|IndividualID) + (1|SumpID/TankID) + tempPC1 + tempPC2, family = nbinom1)
summary(TR_model_T1)



