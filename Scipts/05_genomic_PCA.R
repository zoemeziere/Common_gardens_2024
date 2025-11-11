library(tidyverse)
library(data.table)
library(dartR)
library(vegan)
library(ggplot2)

Exp_metadata <- read.csv("Data/Metadata/Experiment_MetadataGenetics.csv")

# 1. Check missing data and heterozygosity
ind_miss <- read_delim("Data/Gen_data/Spis_expe.imiss", delim = "\t", col_names = c("ind", "ndata", "nfiltered", "nmiss", "fmiss"), skip = 1)
ggplot(ind_miss, aes(fmiss)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)

ind_het <- read_delim("/Data/Gen_data/Spis_expe.het")
ggplot(ind_het, aes(F)) + geom_histogram(fill = "dodgerblue1", colour = "black", alpha = 0.3)

# 1. PCA on all samples
pca <- fread("Data/Gen_data/Spis_experiments_filtered_prunned.eigenvec")
eigenval <- fread("Data/Gen_data/Spis_experiments_filtered_prunned.eigenval")

pca <- pca[,-1]
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)
ggplot(pve, aes(PC, V1)) + geom_bar(stat = "identity") +
  ylab("Percentage variance explained") + theme_light()
cumsum(pve$V1)

ggplot(pca, aes(PC1, PC2, fill= Exp_metadata$Taxon)) + 
  geom_point(shape=21, size=6) +
  scale_fill_manual(values = c("Taxon1" = "mediumorchid", "Taxon4" = "darkorange1", "Taxon5" = "olivedrab3")) +  
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10)) +
  xlab(paste0("PC1 (", signif(pve$V1[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$V1[2], 3), "%)"))

# 3. Assign taxon
assign_taxon <- function(pc1, pc2) {
  if (pc1 < 0) {
    return("Taxon1")
  } else if (pc2 > 0.1) {
    return("Taxon5")
  } else if (pc2 < -0.05) {
    return("Taxon4")
  }
}

Exp_metadata$Taxon <- mapply(assign_taxon, pca$PC1, pca$PC2)
write.csv(Exp_metadata, "Data/Metadata/Experiment_MetadataGenetics.csv")

# 4. IBS to detect clones
lower_tri <- scan("Data/Gen_data/Spis_experiments_filtered_prunned_ibd.mdist", what = numeric())
id <- read.table("Data/Gen_data/Spis_experiments_filtered_prunned_ibd.mdist.id", header = FALSE)
num_samples <- nrow(id)
dist_matrix <- matrix(0, nrow = num_samples, ncol = num_samples)
dist_matrix[lower.tri(dist_matrix, diag = TRUE)] <- lower_tri
dist_matrix <- dist_matrix + t(dist_matrix)
diag(dist_matrix) <- diag(dist_matrix) / 2
rownames(dist_matrix) <- id$V1
colnames(dist_matrix) <- id$V1
IBS.dist <- as.dist(dist_matrix)
IBS.nj <- nj(IBS.dist)
plot(IBS.nj, cex=0.5)

# 5. PCA with outgroup samples
Outgroups_metadata <- read.csv("Data/Gen_data/Spis_exp_outgroups_metadata.csv")

pca_outgroups <- fread("Data/Gen_data/Spis_experiments_outgroups_filtered_prunned.eigenvec")
eigenval_outgroups <- fread("Data/Gen_data/Spis_experiments_outgroups_filtered_prunned.eigenval")

pca_outgroups <- pca_outgroups[,-1]
names(pca_outgroups)[1] <- "ind"
names(pca_outgroups)[2:ncol(pca_outgroups)] <- paste0("PC", 1:(ncol(pca_outgroups)-1))

pve <- data.frame(PC = 1:10, pve = eigenval_outgroups/sum(eigenval_outgroups)*100)
ggplot(pve, aes(PC, V1)) + geom_bar(stat = "identity") +
  ylab("Percentage variance explained") + theme_light()
cumsum(pve$V1)

ggplot(pca_outgroups, aes(PC1, PC2, fill= Outgroups_metadata$Taxon_ref)) + 
  geom_point(shape=21, size=4, aes(alpha = ifelse(Outgroups_metadata$Taxon_ref == "Exp", 0.9, 1))) +
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10)) +
  xlab(paste0("PC1 (", signif(pve$V1[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$V1[2], 3), "%)")) +
  theme(legend.position = "none")

# 6. PCA with 5 samples per taxon
pca <- fread("Data/Gen_data/5samples_plink.eigenvec")
eigenval <- fread("Data/Gen_data/5samples_plink.eigenval")
metadata <- read.csv("Data/Gen_data/5samples_metadata.csv")

pca <- pca[,-1]
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

ggplot(pca, aes(PC1, PC2, fill=metadata$taxon)) + 
  geom_point(shape=21, size=6) +
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10))

ggplot(pca, aes(PC1, PC2, fill= metadata$taxon)) + 
  geom_point(shape=21, size=6) +
  coord_equal() + theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=10)) +
  scale_fill_manual(values = c("Taxon1" = "mediumorchid", "Taxon4" = "darkorange1", "Taxon5" = "olivedrab3")) +
  xlab(paste0("PC1 (", signif(pve$V1[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$V1[2], 3), "%)")) +
  theme(legend.position = "none")
