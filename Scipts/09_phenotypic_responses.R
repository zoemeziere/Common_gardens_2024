library(dplyr)

AllTaxa_data_lng <- read.csv("Data/All_taxa_data/allTaxa_metadata_lng.csv")
Taxon1_data_lng <- read.csv("Data/Taxon1_data/Taxon1_data_lng.csv")

Alltaxa_responses <- read.csv("Data/All_taxa_data/allTaxa_responses.csv")
Taxon1_responses <- read.csv("Data/Taxon1_data/Taxon1_responses.csv")
Taxon1_responses_filtered<- read.csv("Data/Taxon1_data/Taxon1_responses_filtered.csv")

cols_taxa <- c("Taxon1" = "mediumorchid", "Taxon4" = "darkorange1", "Taxon5" = "olivedrab3")  

# Time non bleached --------------------------------------

time_without_bleaching <- function(group) {
  for (i in 0:12) {
    if (any(group$TimePoint == paste("T", i, sep = "") &
            group$Bleaching %in% c("PartialBleaching", "FullBleaching"))) {
      return(i)
    }
  }
  return(12)
}

AllTaxa_data_lng <- AllTaxa_data_lng %>%
  group_by(FragID) %>%
  mutate(time_without_bleaching = time_without_bleaching(cur_data())) %>%
  ungroup()

Taxon1_data_lng <- Taxon1_data_lng %>%
  group_by(FragID) %>%
  mutate(time_without_bleaching = time_without_bleaching(cur_data())) %>%
  ungroup()

# plot 
       
emm_LTU_df <- as.data.frame(emm_LTU)

colony_means <- Alltaxa_responses %>%
       group_by(Taxon, IndividualID) %>%
       summarise(time_without_bleaching = mean(time_without_bleaching, na.rm = TRUE), .groups = "drop")

ggplot(Alltaxa_responses, aes(x = Taxon, y = time_without_bleaching, fill = Taxon)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  
  # Colony-level means
  geom_point(data = colony_means, 
             aes(x = Taxon, y = time_without_bleaching), 
             position = position_jitter(width = 0.2), 
             color = "black", size = 2, shape = 16, inherit.aes = FALSE) +
  
  # Estimated marginal means from model
  geom_point(data = emm_LTU_df, aes(x = Taxon, y = response), 
             color = "black", size = 3, shape = 18, inherit.aes = FALSE) +
  geom_errorbar(data = emm_LTU_df, aes(x = Taxon, ymin = asymp.LCL, ymax = asymp.UCL), 
                width = 0.2, color = "black", inherit.aes = FALSE) +
  
  labs(x = "Taxon", y = "Time alive") +
  scale_fill_manual(values = cols_taxa) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Time alive --------------------------------------
                         
time_without_death <- function(group) {
  for (i in 0:12) {
    if (any(group$TimePoint == paste("T", i, sep = "") &
         group$Survival == "Dead")) {
      return(i)
      }
  }
    return(12)
}
                         
AllTaxa_data_lng <- AllTaxa_data_lng %>%
  group_by(FragID) %>%
  mutate(time_alive = time_without_death(cur_data())) %>%
  ungroup()
                         
Taxon1_data_lng <- Taxon1_data_lng %>%
  group_by(FragID) %>%
  mutate(time_alive = time_without_death(cur_data())) %>%
  ungroup()
                         
# plot

emm_LTA_df <- as.data.frame(emm_LTA)

colony_means <- Alltaxa_responses %>%
  group_by(Taxon, IndividualID) %>%
  summarise(mean_time_alive = mean(time_alive, na.rm = TRUE), .groups = "drop")

ggplot(Alltaxa_responses, aes(x = Taxon, y = time_alive, fill = Taxon)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  
  # Colony-level means
  geom_point(data = colony_means, 
             aes(x = Taxon, y = mean_time_alive), 
             position = position_jitter(width = 0.2), 
             color = "black", size = 2, shape = 16, inherit.aes = FALSE) +
  
  # Estimated marginal means from model
  geom_point(data = emm_LTA_df, aes(x = Taxon, y = response), 
             color = "black", size = 3, shape = 18, inherit.aes = FALSE) +
  geom_errorbar(data = emm_LTA_df, aes(x = Taxon, ymin = asymp.LCL, ymax = asymp.UCL), 
                width = 0.2, color = "black", inherit.aes = FALSE) +
  
  labs(x = "Taxon", y = "Time alive") +
  scale_fill_manual(values = cols_taxa) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Maximum bleaching #####

AllTaxa_data_lng <- AllTaxa_data_lng %>%
  group_by(FragID) %>%
  mutate(max_bleaching = max(BleachedArea, na.rm = TRUE)) %>%
  ungroup()

colony_bleach_means <- AllTaxa_data_lng %>%
  group_by(Taxon, IndividualID) %>%
  summarise(mean_max_bleach = mean(max_bleaching, na.rm = TRUE), .groups = "drop")

Taxon1_responses <- Taxon1_responses %>%
  group_by(FragID) %>%
  mutate(max_bleaching = max(BleachedArea, na.rm = TRUE)) %>%
  ungroup()

# plot

emm_MB_df <- as.data.frame(emm_MB)

ggplot(AllTaxa_data_lng, aes(x = Taxon, y = max_bleaching, fill = Taxon)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.7) +
  
  # Colony-level means
  geom_point(data = colony_bleach_means,
             aes(x = Taxon, y = mean_max_bleach),
             position = position_jitter(width = 0.2),
             shape = 16, size = 2, color = "black", inherit.aes = FALSE) +
  
  # Model-predicted means
  geom_point(data = emm_MB_df,
             aes(x = Taxon, y = response),
             shape = 18, size = 3, color = "black", inherit.aes = FALSE) +
  geom_errorbar(data = emm_MB_df,
                aes(x = Taxon, ymin = asymp.LCL, ymax = asymp.UCL),
                width = 0.2, color = "black", inherit.aes = FALSE) +
  
  labs(x = "Taxon", y = "Max bleaching") +
  scale_fill_manual(values = cols_taxa) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Time between min score and increased score ---------------
time_to_recover_paling <- function(group) {
  # Remove rows without CoralWatchNumber
  group <- group[!is.na(group$CoralWatchNumber), ]
  if (nrow(group) == 0) return(NA)
  
  # Convert time points to numeric
  group$TimeNum <- as.numeric(gsub("T", "", group$TimePoint))

  # Must be alive at T12
  surv_t12 <- group$Survival[group$TimeNum == 12]
  if (length(surv_t12) == 0 || !any(surv_t12 %in% c("Alive", "Partially dead"))) return(NA)
  
  # Get minimum CoralWatchNumber
  min_score <- min(group$CoralWatchNumber, na.rm = TRUE)
  max_score <- max(group$CoralWatchNumber, na.rm = TRUE)
  
  # If never bleached (min = max), exclude
  if (min_score == max_score) return(NA)
  
  min_idx <- which(group$CoralWatchNumber == min_score)[1]
  min_time <- group$TimeNum[min_idx]
  
  # Look for first increase after minimum
  after_min <- group[group$TimeNum > min_time, ]
  if (nrow(after_min) == 0) return(12)  # no data after min, still alive at T12
  
  increase_row <- after_min[after_min$CoralWatchNumber > min_score, ]
  if (nrow(increase_row) == 0) return(12)  # never increased but alive at T12
  
  recovery_time <- increase_row$TimeNum[1]
  return(recovery_time - min_time)
}

Alltaxa_responses <- Alltaxa_responses %>%
  group_by(FragID) %>%
  mutate(time_to_recovery_paling = time_to_recover_paling(cur_data())) %>%
  ungroup()

# plot
colony_means_paling <- Alltaxa_responses %>%
  group_by(Taxon, IndividualID) %>%
  summarise(time_to_recovery_paling = mean(time_to_recovery_paling, na.rm = TRUE), .groups = "drop")

ggplot(Alltaxa_responses, aes(x = Taxon, y = time_to_recovery_paling, fill = Taxon)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  
  # Colony-level means
  geom_point(data = colony_means_paling, 
             aes(x = Taxon, y = time_to_recovery_paling), 
             position = position_jitter(width = 0.2), 
             color = "black", size = 2, shape = 16, inherit.aes = FALSE) +
  
  # Estimated marginal means from model
  geom_point(data = emm_TR_df, aes(x = Taxon, y = response), 
             color = "black", size = 3, shape = 18, inherit.aes = FALSE) +
  geom_errorbar(data = emm_TR_df, aes(x = Taxon, ymin = asymp.LCL, ymax = asymp.UCL), 
                width = 0.2, color = "black", inherit.aes = FALSE) +
  
  labs(x = "Taxon", y = "Recovery time from paling") +
  scale_fill_manual(values = cols_taxa) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
