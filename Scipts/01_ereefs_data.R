library(dplyr)
library(lubridate)

# Transform eReef data to five metrics

temp_data <- read.csv("Data/Env_data/ereef-collected.csv")
response_data <- read.csv("Data/All_taxa_data/allTaxa_responses.csv")

# Make Depth positive and standardize column names
temp_data_clean <- temp_data %>%
  mutate(
    Date = as.Date(strptime(Aggregated.Date.Time, format = "%Y-%m-%dT%H:%M")),
    Depth = abs(Depth))

# Prepare temp_data with DailyRange
temp_data_clean <- temp_data %>%
  mutate(
    Date = as.Date(strptime(Aggregated.Date.Time, "%Y-%m-%dT%H:%M")),
    Depth = abs(Depth),
    DailyRange = highest - lowest  # compute daily range
  )

# Compute monthly stats per Site × Depth × Month
monthly_stats <- temp_data_clean %>%
  mutate(Month = month(Date)) %>%
  group_by(Site, Depth, Month) %>%
  summarise(
    MonthlyMean       = mean(mean, na.rm = TRUE),
    MonthlyDailyRange = mean(DailyRange, na.rm = TRUE),
    .groups = "drop"
  )

# Compute the five thermal metrics per Site × Depth
thermal_metrics <- monthly_stats %>%
  group_by(Site, Depth) %>%
  summarise(
    MeanAnnualTemp      = mean(MonthlyMean, na.rm = TRUE),
    MaxMonthlyTemp      = max(MonthlyMean, na.rm = TRUE),
    MinMonthlyTemp      = min(MonthlyMean, na.rm = TRUE),
    SeasonalVariability = sd(MonthlyMean, na.rm = TRUE),
    MeanDailyRange      = mean(MonthlyDailyRange, na.rm = TRUE),
    .groups = "drop"
  )

# Merge with metadata
response_data$Site <- response_data$LocationID     

# Function to assign nearest thermal metric depth
assign_nearest_depth <- function(individual_depth, metric_depths) {
  metric_depths[which.min(abs(metric_depths - individual_depth))]
}

# Add the nearest Depth_bin from thermal_metrics
metadata_with_metrics <- response_data %>%
  rowwise() %>%
  mutate(Depth_nearest = assign_nearest_depth(Depth, thermal_metrics$Depth)) %>%
  ungroup() %>%
  left_join(thermal_metrics, by = c("Site" = "Site", "Depth_nearest" = "Depth"))

# Save
write.csv(metadata_with_metrics, "Data/All_taxa_data/allTaxa_responses_with_thermal_metrics.csv", row.names = FALSE)


