# Exploring time series by taxon for bleaching status and survival

experiments_metadata_lng <- read.csv("experiments_metadata_lng.csv")

experiments_metadata_lng$TimePoint <- factor(experiments_metadata_lng$TimePoint, 
                                             levels = c("T0", "T1", "T2", "T3", "T4", "T5", 
                                                        "T6", "T7", "T8", "T9", "T10", "T11", "T12"))

experiments_metadata_lng$Survival <- factor(experiments_metadata_lng$Survival,
                                            levels = c("Alive", "PartiallyDead", "Dead"))

experiments_metadata_lng$Bleaching <- factor(experiments_metadata_lng$Bleaching,
                                            levels = c("FullBleaching", "PartialBleaching", "NoBleaching"))

summary_data <- experiments_metadata_lng %>%
  group_by(Taxon, Bleaching, TimePoint) %>% # change Survival or Bleaching
  summarize(count = n(), .groups = 'drop')

color_mapping <- c("Dead" = "grey", "PartiallyDead" = "#b9a9b9", "Alive" = "#5a3c5c")
color_mapping <- c("NoBleaching" = "darkgoldenrod4", "PartialBleaching" = "burlywood3", "FullBleaching" = "beige")

ggplot(summary_data, aes(x = Bleaching, y = count, fill = Bleaching)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "black") + # change Survival or Bleaching
  scale_fill_manual(values = color_mapping) + 
  theme_bw(base_size = 15) +
  theme(axis.title.y = element_blank(), 
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),  
        axis.ticks.x = element_blank(), 
        legend.title = element_blank(), 
        legend.position = c(.85, .2)) +
  facet_grid(Taxon ~ TimePoint, scales = "free_y")


# Exploring time series by location for bleaching status and survival

Taxon1_data_lng <- read.csv("Taxon1_data_lng.csv")

Taxon1_data_lng$TimePoint <- factor(Taxon1_data_lng$TimePoint, 
                                             levels = c("T0", "T1", "T2", "T3", "T4", "T5", 
                                                        "T6", "T7", "T8", "T9", "T10", "T11", "T12"))

Taxon1_data_lng$Survival <- factor(Taxon1_data_lng$Survival,
                                            levels = c("Alive", "PartiallyDead", "Dead"))

Taxon1_data_lng$Bleaching <- factor(Taxon1_data_lng$Bleaching,
                                             levels = c("FullBleaching", "PartialBleaching", "NoBleaching"))

summary_data <- Taxon1_data_lng %>%
  group_by(LocationID, Bleaching, TimePoint) %>% # change Survival or Bleaching
  summarize(count = n(), .groups = 'drop')

color_mapping <- c("Dead" = "grey", "PartiallyDead" = "#b9a9b9", "Alive" = "#5a3c5c")
color_mapping <- c("NoBleaching" = "darkgoldenrod4", "PartialBleaching" = "burlywood3", "FullBleaching" = "beige")

ggplot(summary_data, aes(x = Bleaching, y = count, fill = Bleaching)) +
  geom_bar(stat = "identity", position = position_dodge(), color = "black") + # change Survival or Bleaching
  scale_fill_manual(values = color_mapping) + 
  theme_bw(base_size = 15) +
  theme(axis.title.y = element_blank(), 
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),  
        axis.ticks.x = element_blank(), 
        legend.title = element_blank(), 
        legend.position = c(.85, .2)) +
  facet_grid(LocationID ~ TimePoint, scales = "free_y")

