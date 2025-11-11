library(stringr)
library(ggplot2)
library(scales)
library(readxl)
library(purrr)
library(zoo)

HoboC1<- read.csv("Data/Logger_data/Hobo_control1.csv")
HoboC2<- read.csv("Data/Logger_data/Hobo_control2.csv")
HoboT11<- read.csv("Data/Logger_data/Hobo_treat1_1.csv")
HoboT12<- read.csv("Data/Logger_data/Hobo_treat1_2.csv")
HoboT22<- read.csv("Data/Logger_data/Hobo_treat2_2.csv")
HoboT21<- read.csv("Data/Logger_data/Hobo_treat2_1.csv")

HoboC1$DateTime <- as.POSIXct(HoboC1$DateTime, format='%m/%d/%Y %H:%M:%S')
HoboC2$DateTime <- as.POSIXct(HoboC2$DateTime, format='%m/%d/%Y %H:%M:%S')
HoboT11$DateTime <- as.POSIXct(HoboT11$DateTime, format=c('%m/%d/%Y %H:%M:%S','%m/%d/%Y %H:%M'))
HoboT12$DateTime <- as.POSIXct(HoboT12$DateTime, format='%m/%d/%Y %H:%M:%S')
HoboT22$DateTime <- as.POSIXct(HoboT22$DateTime, format='%m/%d/%Y %H:%M:%S')
HoboT21$DateTime <- as.POSIXct(HoboT21$DateTime, format='%m/%d/%Y %H:%M:%S')

HoboC1$Sensor <- "HoboC1"
HoboC2$Sensor <- "HoboC2"
HoboT11$Sensor <- "HoboT11"
HoboT12$Sensor <- "HoboT12"
HoboT22$Sensor <- "HoboT22"
HoboT21$Sensor <- "HoboT21"

hobo_combined <- bind_rows(HoboC1, HoboC2, HoboT11, HoboT12, HoboT22, HoboT21)
hobo_combined$DateTime <- as.POSIXct(hobo_combined$DateTime, format='%m/%d/%Y %H:%M:%S')

# Plot one logger
ggplot(data=HoboT11, aes(x=DateTime)) + 
  geom_line(data=HoboT11, aes(y=Temperature)) +
  scale_x_datetime(labels = date_format("%d-%m-%Y"),
                   date_breaks = "1 weeks") +
  ylim (25, 35) +
  theme_bw()

# Plot loggers facetted
ggplot(data=hobo_combined, aes(x=DateTime, y=Temperature)) + 
  geom_line() +
  scale_x_datetime(labels = date_format("%d-%m-%Y"), date_breaks = "1 weeks", limits = c(as.POSIXct("2024-02-03 00:00:00"),
                                                                                         as.POSIXct("2024-04-26 23:59:59"))) +
  ylim(25, 35) +
  facet_grid(rows = vars(Sensor)) + 
  theme_bw()

# Plot all loggers overlapping
ggplot(data = hobo_combined, aes(x = DateTime, y = Temperature, colour = Sensor)) +
  geom_line() +
  scale_x_datetime(labels = date_format("%d-%m-%Y"), date_breaks = "1 weeks", limits = c(as.POSIXct("2024-02-03 00:00:00"),
                                                                                                                  as.POSIXct("2024-04-25 23:59:59"))) +
  theme_bw()

# Plot with DHW

MMM <- 27.3 

# Prepare NOAA SST (already daily) ---
sst_data <- read.csv("Data/Env_data/Heron_Island_SST_NovMay2024.csv")

sst_data <- sst_data %>%
  mutate(date = as.Date(date),
         sst = sst * 100)   # rescale if needed

# Prepare logger data (aggregate to daily mean) ---
logger_daily <- HoboT11 %>%
  mutate(DateTime = as.POSIXct(DateTime),
         date = as.Date(DateTime)) %>%
  group_by(date) %>%
  summarise(sst = mean(Temperature, na.rm = TRUE), .groups = "drop")

# Combine NOAA + logger ---
all_sst <- bind_rows(sst_data, logger_daily) %>%
  arrange(date)

# Calculate daily HotSpot (only if > MMM+1) ---
all_sst <- all_sst %>%
  mutate(HotSpot = ifelse(sst > (MMM + 1), sst - MMM, 0))

# Calculate DHW as rolling sum over 84 days (12 weeks) ---
all_sst <- all_sst %>%
  mutate(DHW = rollapply(HotSpot, width = 84,
                         FUN = function(x) sum(x, na.rm = TRUE)/7, # °C-weeks
                         align = "right", fill = NA))

write.csv(all_sst, "Data/Env_data/DHW_data.csv")

# Plot ---
ggplot(all_sst, aes(x = date)) +
  geom_line(aes(y = sst), color = "steelblue") +
  geom_line(aes(y = DHW), color = "red") +
  labs(y = "Temperature (°C) / DHW (°C-weeks)", x = "Date",
       title = "Logger + NOAA SST with DHW") +
  theme_bw()