library(ggplot2)
library(scatterpie)
library(dplyr)
library(sf)
library(cowplot)
library(patchwork)
library(rnaturalearth)
library(tidyr)

Heron_experiments_coordinates <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Raw_data/Experiment_coordinates_RAW.csv", header = TRUE)
Exp_metadata <- read.csv("/Users/zoemeziere/Documents/PhD/Chapter4_analyses/Data/Analysis_data/Experiment_MetadataGenetics.csv")

# Plot Australia

map1 <- ne_countries(type = "countries", country = "Australia",
                     scale = "medium", returnclass = "sf")

# Plot sampling sites

summarized_data <- Exp_metadata %>%
  group_by(EcoLocationID, Longitude, Latitude, Taxon) %>%
  summarize(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = Taxon, values_from = count, values_fill = 0)

summarized_data <- summarized_data %>%
  mutate(total = rowSums(select(., -c(EcoLocationID, Longitude, Latitude))))

geomorphic <- read_sf("/Users/zoemeziere/Documents/DP26/figureDP/Heron_2007_GeomorphicZoneMap/hr20070701qb_eco_geo_final_nm.shp")
names(geomorphic)[names(geomorphic) == 'Classname('] <- 'Classname'
geomorphic$Classname <- factor(geomorphic$Classname, levels = c("Deep Areas", "Reef Slope", "Reef Crest", "Reef Flat Outer", "Reef flat Inner", "Shallow Lagoon", "Deep Lagoon", "Land", "unclassified"))
col_geo=c("cadetblue", "bisque2", "beige", "cadetblue3", "cadetblue3", "cadetblue3", "cadetblue3", "darkolivegreen", "grey")

sites_sp = st_as_sf(summarized_data, coords = c("Longitude", "Latitude"))
st_crs(sites_sp) <- 4326
sites_sp <- st_transform(sites_sp, crs = st_crs(geomorphic))

ggplot() +
  geom_sf(data= geomorphic, aes(fill = Classname), lwd=0, color=NA) +
  geom_sf(data= sites_sp, shape=20, aes(color=EcoLocationID), size=5) +
  theme_void() +
  scale_fill_manual(values = col_geo) +
  geom_text(data=sites_sp, aes(label=EcoLocationID, geometry=geometry), stat = "sf_coordinates") +
  theme(legend.position = "top", legend.title = element_blank()) 

# Plot bar charts with cryptic taxa
long_df <- sites_sp %>%
  pivot_longer(cols = c(Taxon1, Taxon4, Taxon5),  
               names_to = "Taxon",               
               values_to = "Count") 

long_df <- as.data.frame(long_df) %>%
  left_join(as.data.frame(long_df)[, c("EcoLocationID", "total")], by = "EcoLocationID") %>%
  mutate(radius = sqrt(total.x) / max(sqrt(as.data.frame(long_df)$total)) * 10)  

long_df <- long_df %>%
  filter(Count > 0)

ggplot(long_df, aes(x = total.x/2, y = Count, fill = Taxon, width = total.x)) +
  geom_bar(stat = "identity", width = 1, show.legend = FALSE) +  
  coord_polar(theta = "y") +  
  facet_wrap(~ EcoLocationID, scales = "free_y" ) +  
  scale_fill_manual(values = c("Taxon1" = "mediumorchid", "Taxon4" = "darkorange1", "Taxon5" = "olivedrab3")) +  
  theme_void() +
  theme(legend.position = "top", legend.title = element_blank()) 

# Plot bar charts following heat wave

summarized_data <- Exp_metadata %>%
  group_by(EcoLocationID, Longitude, Latitude, Taxon, Reassessment_survival) %>%
  summarize(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = Taxon, values_from = count, values_fill = 0)

summarized_data$Reassessment_survival[summarized_data$Reassessment_survival==""] <- "NotReassessed"

summarized_data <- summarized_data %>%
  mutate(total = rowSums(select(., -c(EcoLocationID, Longitude, Latitude, Reassessment_survival))))

geomorphic <- read_sf("/Users/zoemeziere/Documents/DP26/figureDP/Heron_2007_GeomorphicZoneMap/hr20070701qb_eco_geo_final_nm.shp")
names(geomorphic)[names(geomorphic) == 'Classname('] <- 'Classname'
geomorphic$Classname <- factor(geomorphic$Classname, levels = c("Deep Areas", "Reef Slope", "Reef Crest", "Reef Flat Outer", "Reef flat Inner", "Shallow Lagoon", "Deep Lagoon", "Land", "unclassified"))
col_geo=c("cadetblue", "bisque2", "beige", "cadetblue3", "cadetblue3", "cadetblue3", "cadetblue3", "darkolivegreen", "grey")

sites_sp = st_as_sf(summarized_data, coords = c("Longitude", "Latitude"))
st_crs(sites_sp) <- 4326
sites_sp <- st_transform(sites_sp, crs = st_crs(geomorphic))

long_df <- sites_sp %>%
  pivot_longer(cols = c(Taxon1, Taxon4, Taxon5),  
               names_to = "Taxon",               
               values_to = "Count") 

long_df <- as.data.frame(long_df) %>%
  left_join(as.data.frame(long_df)[, c("EcoLocationID", "total")], by = "EcoLocationID") %>%
  mutate(radius = sqrt(total.x) / max(sqrt(as.data.frame(long_df)$total)) * 10)  

# plot all

ggplot(long_df, aes(x = 1, y = Count, fill = Taxon, 
                    pattern = Reassessment_survival)) +
  geom_bar_pattern(
    stat = "identity", width = 1, colour = NA, 
    pattern_density = 0.3, pattern_spacing = 0.05) +
  coord_polar(theta = "y") +
  facet_wrap(~ EcoLocationID, scales = "free_y") +
  scale_fill_manual(values = c(
    "Taxon1" = "mediumorchid",
    "Taxon4" = "darkorange1",
    "Taxon5" = "olivedrab3")) +
  scale_pattern_manual(values = c(
    "Alive" = "none",
    "PartiallyDead" = "none",
    "Dead" = "stripe",
    "NotReassessed" = "circle")) +
  theme_void()

# plot only dead and alive (not not found) - scaled by sample size

long_df_filtered <- long_df %>%
  filter(Reassessment_survival %in% c("Alive", "Dead"))

ggplot(long_df_filtered, aes(x = 1, y = Count, fill = Taxon, 
                    pattern = Reassessment_survival)) +
  geom_bar_pattern(
    stat = "identity", width = 1, colour = NA, 
    pattern_density = 0.3, pattern_spacing = 0.05) +
  coord_polar(theta = "y") +
  facet_wrap(~ EcoLocationID, scales = "free_y") +
  scale_fill_manual(values = c(
    "Taxon1" = "mediumorchid",
    "Taxon4" = "darkorange1",
    "Taxon5" = "olivedrab3")) +
  scale_pattern_manual(values = c(
    "Alive" = "none",
    "Dead" = "stripe")) +
  theme_void()
