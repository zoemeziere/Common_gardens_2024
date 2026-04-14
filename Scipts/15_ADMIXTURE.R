library(stringr)
library(tidyr)
library(dplyr)
library(ggplot2)

setwd("~/Documents/PhD/Chapter4_analyses/03_PCA_ADMIXTURE")
#prefix <- "Spis_experiments_filtered_prunned"
prefix="Spis_experiments_5samples_filtered_linked"
metadata <- read.csv("~/Documents/PhD/Chapter4_analyses/Data/Analysis_data/All_taxa_data/Experiment_MetadataGenetics.csv")
metadata$Sample <- metadata$IndividualID

qfiles <- list.files(pattern = paste0("^", prefix, "\\.[0-9]+\\.Q$"))
getK <- function(x) as.numeric(str_extract(x, "(?<=\\.)[0-9]+(?=\\.Q$)"))
fam <- read.table(paste0(prefix, ".fam"), header = FALSE)

# Function to read admixture Q files
readQ <- function(qfile) {
  Kval <- getK(qfile)
  qdat <- read.table(qfile, header = FALSE)
  colnames(qdat) <- paste0("Cluster_", 1:Kval)
  qdat$Sample <- fam$V2
  qdat$K <- Kval   # keep numeric
  qdat
}

admix_df <- bind_rows(lapply(qfiles, readQ))

# Merge metadata to get Taxon
admix_df <- admix_df %>%
  left_join(metadata %>% select(Sample, Taxon), by = "Sample")

if (any(is.na(admix_df$Taxon))) {
  warning("Some samples in ADMIXTURE output do not match metadata.")
}

# Convert to long format
admix_long <- admix_df %>%
  pivot_longer(
    cols = starts_with("Cluster_"),
    names_to = "Cluster",
    values_to = "Ancestry"
  )

# Make K an ordered factor
K_max <- max(admix_long$K)

admix_highK <- admix_long %>%
  filter(K == K_max)

admix_wide <- admix_highK %>%
  select(Sample, Cluster, Ancestry) %>%
  pivot_wider(
    names_from = Cluster,
    values_from = Ancestry,
    values_fn = mean   # handles duplicates safely
  )

mat <- as.matrix(admix_wide[,-1])
rownames(mat) <- admix_wide$Sample

hc <- hclust(dist(mat, method = "euclidean"))
sample_order <- rownames(mat)[hc$order]

admix_long$Sample <- factor(admix_long$Sample, levels = sample_order)

admix_long$K <- factor(admix_long$K, levels = sort(unique(admix_long$K)))

# Plot ADMIXTURE barplot
ggplot(admix_long, aes(x = Sample, y = Ancestry, fill = Cluster)) +
  geom_bar(stat = "identity", width = 1) +
  facet_grid(K ~ ., switch = "y") +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 6),
    panel.spacing = unit(0.3, "lines"),
    strip.text.y.left = element_text(angle = 0),
    panel.grid.major = element_blank()
  ) +
  labs(x = "Individuals", y = "Ancestry proportion") +
  scale_fill_brewer(palette = "Set3")
