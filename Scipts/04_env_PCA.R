# script to perform PCA on environmental variables from collection sites of experiment

experiments_metadata <- read.csv("Data/All_taxa_data/allTaxa_responses_with_thermal_metrics.csv")

dat_scaled <- scale(experiments_metadata[,35:39])
pca <- prcomp(dat_scaled)

scores <- as.data.frame(pca$x)
scores$LocationID <- experiments_metadata$LocationID
scores$Depth <- experiments_metadata$Depth

explained_variance <- pca$sdev^2 / sum(pca$sdev^2) * 100
pc1_percentage <- round(explained_variance[1], 2)
pc2_percentage <- round(explained_variance[2], 2)

loadings <- as.data.frame(pca$rotation)
loadings$Variable <- rownames(loadings)

arrow_multiplier <- 3 
loadings <- loadings %>%
  mutate(PC1 = PC1 * arrow_multiplier,
         PC2 = PC2 * arrow_multiplier)

ggplot(scores, aes(x = PC1, y = PC2, color = LocationID)) +
  geom_point(size = 5) +
  geom_segment(data = loadings,
               aes(x = 0, y = 0, xend = PC1, yend = PC2),
               arrow = arrow(length = unit(0.3, "cm")),
               color = "black") +
  geom_text(data = loadings,
            aes(x = PC1*1.1, y = PC2*1.1, label = Variable),
            color = "black", size = 4) +
  labs(x = paste("PC1 (", pc1_percentage, "%)", sep = ""),
       y = paste("PC2 (", pc2_percentage, "%)", sep = "")) +
  theme_bw()

pc_scores <- cbind(scores$PC1, scores$PC2)
write.csv(pc_scores, "Data/Env_data/pc_scores_env.csv")

# Assign PC scores to samples
pc_scores_df <- as.data.frame(pc_scores)
colnames(pc_scores_df) <- c("tempPC1", "tempPC2")
metadata_with_pc <- cbind(experiments_metadata, pc_scores_df)

write.csv(metadata_with_pc, "Data/All_taxa_data/allTaxa_responses_with_thermal_metrics.csv", row.names = FALSE)
