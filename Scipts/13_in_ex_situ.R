library(dplyr)
library(ggplot2)
library(ggpattern)

genetics_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Experiment_MetadataGenetics.csv")
experiments_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/experiments_merged.csv")

# Colony level exp survival 

survival_summary <- experiments_metadata %>%
  group_by(IndividualID) %>%
  summarise(
    dead_count = sum(Survival_T12 == "Dead", na.rm = TRUE),
    survival_exp = case_when(
      dead_count == 2 ~ "Dead",
      dead_count <= 1 ~ "Alive",
      TRUE ~ "Dead"
    ),
    .groups = "drop"
  )

genetics_metadata <- genetics_metadata %>%
  left_join(survival_summary, by = "IndividualID") %>%
  mutate(
    Reassessment_survival = case_when(
      Reassessment_survival == "PartiallyDead" ~ "Alive",
      Reassessment_survival == "" ~ "NotFound",
      TRUE ~ Reassessment_survival
    )
  )

genetics_metadata$Reassessment_survival[genetics_metadata$Reassessment_survival == ""] <- "NotFound"

# tests to compare survival

survival_table <- table(genetics_metadata$Reassessment_survival, genetics_metadata$survival_exp)
print(survival_table)

chi_square_result <- chisq.test(survival_table)
print(chi_square_result)

# Plot with patterns - for all and for each taxon

ggplot(genetics_metadata, aes(x = survival_exp, fill = Reassessment_survival, pattern = Reassessment_survival)) +
       geom_bar_pattern(position = "dodge", color = "black", fill = "grey70",
       pattern_fill = "black", pattern_density = 0.3, pattern_spacing = 0.02, pattern_angle = 45) +
       scale_pattern_manual(values = c("Alive" = "none", "Dead" = "stripe","NotFound" = "circle" )) +
       scale_fill_manual(values = c("Alive" = "grey70", "Dead" = "grey70", "NotFound" = "grey70")) +
       labs(x = "Experimental Survival", y = "Count") +
       theme_bw()

ggplot(genetics_metadata, 
       aes(x = survival_exp, 
           fill = Reassessment_survival, 
           pattern = Reassessment_survival)) +
  geom_bar_pattern(position = "dodge", 
                   color = "black", 
                   fill = "grey70",
                   pattern_fill = "black", 
                   pattern_density = 0.3, 
                   pattern_spacing = 0.02, 
                   pattern_angle = 45) +
  scale_pattern_manual(values = c("Alive" = "none", 
                                  "Dead" = "stripe", 
                                  "NotFound" = "circle")) +
  scale_fill_manual(values = c("Alive" = "grey70", 
                               "Dead" = "grey70", 
                               "NotFound" = "grey70")) +
  labs(x = "Experimental Survival", y = "Count") +
  theme_bw() +
  facet_wrap(~ Taxon, nrow = 1, ncol = 3)

# Kappa test

genetics_metadata_sub <- genetics_metadata %>%
  mutate(Reassessment_survival = na_if(Reassessment_survival, "")) %>%
  filter(!is.na(Reassessment_survival))

genetics_metadata_sub <- genetics_metadata_sub %>%
  mutate(
    reassess_bin = Reassessment_survival,      
    survival_exp_bin = ifelse(survival_exp == "Dead", "Dead", "Survived"))

kappa_data <- genetics_metadata_sub %>%
  select(reassess_bin, survival_exp_bin)

kappa_result <- irr::kappa2(kappa_data)
print(kappa_result)

# Kappa test by taxon

kappa_by_taxon <- genetics_metadata_sub %>%
  group_by(Taxon) %>%
  summarise(
    kappa_result = list(kappa2(select(cur_data(), reassess_bin, survival_exp_bin))),
    .groups = "drop")

kappa_by_taxon <- kappa_by_taxon %>%
  mutate(
    Kappa = map_dbl(kappa_result, ~.$value),
    z = map_dbl(kappa_result, ~.$statistic),
    p = map_dbl(kappa_result, ~.$p.value)) %>%
  select(Taxon, Kappa, z, p)

print(kappa_by_taxon)

# Heat map plots

genetics_metadata_sub <- genetics_metadata %>%
  mutate(Reassessment_survival = na_if(Reassessment_survival, "")) %>%
  filter(!is.na(Reassessment_survival))

# Create a single contingency table across all taxa
contingency_all <- table(
  genetics_metadata_sub$Reassessment_survival,
  genetics_metadata_sub$survival_exp
)

# Convert to data frame and rename columns
heatmap_data_long <- as.data.frame(contingency_all) %>%
  rename(
    Reassessment_survival = Var1,
    survival_exp = Var2
  ) %>%
  mutate(
    Total = sum(Freq),
    Prop = Freq / Total,
    FractionLabel = paste0(Freq, "/", Total)
  )

# Plot
ggplot(heatmap_data_long, aes(x = survival_exp, y = Reassessment_survival, fill = Prop)) +
  geom_tile(color = "white") +
  geom_text(aes(label = FractionLabel), color = "black") +
  scale_fill_gradient(low = "beige", high = "darkorange4") +
  labs(
    x = "Common Garden Survival",
    y = "Field Survival",
    fill = "Proportion"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Heat map right/wrong

heatmap_data_long <- heatmap_data_long %>%
  mutate(
    Reassessment_survival = tolower(Reassessment_survival),
    survival_exp = tolower(survival_exp),
    category = case_when(
      Reassessment_survival == "alive" & survival_exp == "alive" ~ "Correct",
      Reassessment_survival == "dead"  & survival_exp == "dead"  ~ "Correct",
      Reassessment_survival == "alive" & survival_exp == "dead"  ~ "Mismatch",
      Reassessment_survival == "dead"  & survival_exp == "alive" ~ "Mismatch",
      Reassessment_survival == "notfound" & survival_exp == "dead" ~ "Correct",
      Reassessment_survival == "notfound" & survival_exp == "alive" ~ "Mismatch",
      TRUE ~ "Other"
    ),
    alpha_val = Freq / max(Freq)  # for shading intensity
  )

# Color mapping
color_map <- c(
  "Correct"    = "cadetblue3",
  "Mismatch"   = "coral")

# Plot
ggplot(heatmap_data_long, aes(x = survival_exp, y = Reassessment_survival)) +
  geom_tile(aes(fill = category, alpha = alpha_val), color = "white") +
  geom_text(aes(label = Freq), color = "black") +
  scale_fill_manual(values = color_map) +
  scale_alpha(range = c(0.3, 1), guide = "none") +
  labs(
    x = "Common Garden Survival",
    y = "Field Survival",
    fill = "Classification"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Heat map for the three taxa separately

genetics_metadata_sub <- genetics_metadata %>%
  mutate(Reassessment_survival = na_if(Reassessment_survival, "")) %>%
  filter(!is.na(Reassessment_survival))

contingency_by_taxon <- genetics_metadata_sub %>%
  group_by(Taxon) %>%
  summarise(
    table_list = list(table(Reassessment_survival, survival_exp)),
    .groups = "drop"
  )

heatmap_data <- contingency_by_taxon %>%
  mutate(
    df = map(table_list, ~ as.data.frame(.x))
  )

heatmap_data_long <- heatmap_data %>%
  dplyr::select(Taxon, df) %>%
  unnest(df)

heatmap_data_long <- heatmap_data_long %>%
  mutate(Total = sum(Freq),
         Prop = Freq / Total,
         FractionLabel = paste0(Freq, "/", Total)) %>%
  ungroup()

ggplot(heatmap_data_long, aes(x = survival_exp, y = Reassessment_survival, fill = Prop)) +
  geom_tile(color = "white") +
  geom_text(aes(label = FractionLabel), color = "black") +
  facet_wrap(~Taxon, nrow = 1) +  # facet by Taxon as columns
  scale_fill_gradient(low = "beige", high = "darkorange4") +
  labs(x = "Common Garden Survival",
       y = "Field Survival",
       fill = "Proportion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Frag level exp survival

post_bleaching_metadata <- left_join(experiments_metadata, genetics_metadata, by="IndividualID")
post_bleaching_metadata <- cbind("FragID"=post_bleaching_metadata$FragID, 
                                 "IndividualID"=post_bleaching_metadata$IndividualID,
                                 "Reassessment_survival"=post_bleaching_metadata$Reassessment_survival.x,
                                 "Reassessment_bleaching"=post_bleaching_metadata$Reassessment_bleaching.x,
                                 "Bleaching_T12"=post_bleaching_metadata$Bleaching_T12,
                                 "Survival_T12"=post_bleaching_metadata$Survival_T12)

post_bleaching_metadata <- as.data.frame(post_bleaching_metadata)

ggplot(post_bleaching_metadata, aes(x = Reassessment_survival, fill = Survival_T12)) +
  geom_bar(position = "dodge", color = "black") +
  labs(title = "Comparison of Survival Field vs Survival Exp", x = "Survival Field", y = "Count") +
  scale_fill_manual(values=c("brown4", "grey90", "brown3")) +
  theme_minimal()

survival_table <- table(post_bleaching_metadata$Reassessment_survival, post_bleaching_metadata$Survival_T12)
chi_square_result <- chisq.test(survival_table)
print(survival_table)
print(chi_square_result)
