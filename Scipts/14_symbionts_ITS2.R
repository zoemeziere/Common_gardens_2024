library(tidyverse)

# 1. Clean up data
ITS2_profile_rel <- read.csv("Data/Symbiont_data/ITS2_rel_abundance.csv", header = TRUE, check.names = FALSE) # ITS2 profiles
ITS2_profile_rel <- read.csv("Data/Symbiont_data/seq_rel_abundance.csv", header = TRUE, check.names = FALSE) # Sequence Variants

ITS2_profile_long <- ITS2_profile_rel %>%
  pivot_longer(
    cols = -1,
    names_to = "ITS2_profile",
    values_to = "abundance") %>%
  mutate(abundance = as.numeric(abundance))

# 2. remove -D duplicates
ITS2_profile_long <- ITS2_profile_long %>%
  filter(!grepl("-D", SampleName))

# 3. Rename samples
ITS2_profile_long$SampleName <- gsub("^Spis-", "EXP", ITS2_profile_long$SampleName)
ITS2_profile_long$SampleName <- gsub("^(EXP\\d+)([A-Z])$", "\\1_\\2", ITS2_profile_long$SampleName)
ITS2_profile_long$SampleName <- gsub("^(EXP\\d+)(T\\d+)$", "\\1_\\2", ITS2_profile_long$SampleName)

# 4. Only keep source colonies
ITS2_profile_long <- ITS2_profile_long %>% filter(!str_detect(SampleName, "^EXP\\d+_"))

# 5. Merge with cryptic species ID
experiments_metadata <- read.csv("Data/Metadata/Experiment_MetadataGenetics.csv")

ITS2_profile_long <- ITS2_profile_long %>% left_join(experiments_metadata %>%
              select(IndividualID, Taxon) %>% rename(SampleName = IndividualID), by = "SampleName")

# 6. Standardize abundances
ITS2_profile_long_rel <- ITS2_profile_long %>%
  group_by(SampleName) %>%
  mutate(abundance = abundance / sum(abundance, na.rm = TRUE)) %>%
  ungroup()

# 7. Plot bar charts
ITS2_profile_long_rel$SampleName <- factor(ITS2_profile_long_rel$SampleName, 
                                           levels = unique(ITS2_profile_long_rel$SampleName[order(as.numeric(gsub("[^0-9]", "", ITS2_profile_long_rel$SampleName)))]))

pastel_colors <- c(
  "#F1C6C6", "#F1D3B1", "#F1D15C", "#C1F0A1", "#A1E168", 
  "#D1B3F1", "#A1C1F0", "#C1A1F0", "#F0A1F0", "#F0A1C1",
  "#F1B3E0", "#F0C1A1", "#A1F0F0", "#B3B3F1", "#B3F1B3")

ggplot(ITS2_profile_long_rel, aes(x = SampleName, y = abundance, fill = ITS2_profile)) +
  geom_col(width = 0.9) +
  facet_grid(. ~ Taxon, scales = "free_x", space = "free_x") +
  labs(x = "Sample", y = "Relative Abundance") +
  scale_fill_manual(values = pastel_colors) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    panel.spacing.x = unit(1, "lines"),
    legend.position = "none",
    strip.background = element_blank(),
    strip.text = element_text(size = 10))

# 8. Plot PCA

ITS2_profile_rel <- ITS2_profile_rel %>% distinct(SampleName, .keep_all = TRUE)
ITS2_profile_matrix <- ITS2_profile_rel %>% column_to_rownames("SampleName")

ITS2_profile_matrix <- ITS2_profile_matrix %>% mutate_all(~ as.numeric(as.character(.)))

its2_pca <- prcomp(ITS2_profile_matrix, center = TRUE, scale. = TRUE)

pca_scores <- as.data.frame(its2_pca$x)
pca_scores$SampleName <- rownames(pca_scores)

# Rename
pca_scores <- pca_scores %>% filter(!grepl("-D", SampleName))
pca_scores$SampleName <- gsub("^Spis-", "EXP", pca_scores$SampleName)
pca_scores$SampleName <- gsub("^(EXP\\d+)([A-Z])$", "\\1_\\2", pca_scores$SampleName)
pca_scores$SampleName <- gsub("^(EXP\\d+)(T\\d+)$", "\\1_\\2", pca_scores$SampleName)
pca_scores <- pca_scores %>% filter(!str_detect(SampleName, "^EXP\\d+_"))

# Merge with cryptic species ID
pca_scores <- pca_scores %>%
  left_join(experiments_metadata %>% select(IndividualID, Taxon) %>%
              rename(SampleName = IndividualID), by = "SampleName")
# Plot
ggplot(pca_scores, aes(x = PC1, y = PC2, color = Taxon)) +
  geom_point(size = 3) +
  labs(title = "PCA of ITS2 Profiles", x = "PC1", y = "PC2") +
  theme_minimal()

