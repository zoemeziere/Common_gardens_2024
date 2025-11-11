# Loading packages and metadata wrangling --------------------------------------
library(ggplot2)
library(tidyr)
library(colorspace)
library(ggpubr)
library(dplyr)

experiments_metadata_raw <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Experiment_Metadata.csv")
genetics_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Experiment_MetadataGenetics.csv")
experiments_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/experiments_merged.csv")

experiments_metadata_lng <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/experiments_metadata_lng.csv")

# Transform into long format
experiments_metadata_lng <- experiments_metadata %>%
  pivot_longer(
    cols = -c(IndividualID, FragID, LocationID, TableID, SumpID, TankID, DeathDate, Depth, 
              Reassessment_survival, Longitude, Latitude, Taxon, Reassessment_bleaching, TempMaxMM,
              TempRange, TempMean, TempMinMM, ITS2),
    names_sep = "_",
    names_to = c(".value", "TimePoint")) 

experiments_metadata_lng$TimePoint <- factor(experiments_metadata_lng$TimePoint, levels=c("T0", "T1", "T2", "T3", "T4", "T5", "T6", 
                                                                                          "T7", "T8", "T9", "T10", "T11", "T12"))

experiments_metadata_lng$Bleaching <- factor(experiments_metadata_lng$Bleaching, 
                                             levels = c("FullBleaching", "PartialBleaching", "NoBleaching"))

experiments_metadata_lng <- experiments_metadata_lng %>% separate(CoralWatch, 
                                                                  into=c('CoralWatchLetter', 'CoralWatchNumber'), sep = "(?<=[A-Za-z])(?=[0-9])")

write.csv(experiments_metadata_lng, "/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/experiments_metadata_lng.csv")

# Taxon1 only
Taxon1_data <- experiments_metadata_lng[experiments_metadata_lng$Taxon=="Taxon1",]
write.csv(Taxon1_data, "/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Taxon1_data_lng.csv")



