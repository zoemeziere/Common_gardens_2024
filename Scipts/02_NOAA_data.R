library(httr)
library(ncdf4)
library(tidyverse)

#### Download SST NOAA data ####

base_url <- "https://www.ncei.noaa.gov/thredds-ocean/fileServer/crw/5km/v3.1/nc/v1.0/daily/sst/2024/"
base_url <- "https://www.ncei.noaa.gov/thredds-ocean/fileServer/crw/5km/v3.1/nc/v1.0/daily/sst/2023/"

dates <- seq(as.Date("2023-11-01"), as.Date("2023-12-01"), by = "day")

for (current_date_num in dates) {
  current_date <- as.Date(current_date_num, origin = "1970-01-01")
  print(current_date)
  file_date <- gsub("-", "", as.character(current_date))
  file_name <- paste0("coraltemp_v3.1_", file_date, ".nc")
  file_url <- paste0(base_url, file_name)
  
  cat("Trying to download:", file_name, "\n")
  r <- GET(file_url)
  if (status_code(r) == 200) {
    writeBin(content(r, "raw"), file_name)
    cat("✅ Downloaded:", file_name, "\n")
  } else {
    cat("❌ Failed:", file_name, "status", status_code(r), "\n")
  }
}

nc_files <- list.files(pattern = "\\.nc$")

extract_sst <- function(nc_file, lat_target, lon_target) {
  nc <- nc_open(nc_file)
  
  lat <- ncvar_get(nc, "lat")
  lon <- ncvar_get(nc, "lon")
  
  lat_idx <- which.min(abs(lat - lat_target))
  lon_idx <- which.min(abs(lon - lon_target))
  
  time <- ncvar_get(nc, "time")
  time_units <- ncatt_get(nc, "time", "units")$value
  time_origin <- sub("seconds since ", "", time_units)
  
  time_dates <- as.POSIXct(time, origin = time_origin, tz = "UTC")
  time_dates <- as.Date(time_dates)
  
  sst_raw <- ncvar_get(nc, "analysed_sst", start = c(lon_idx, lat_idx, 1), count = c(1, 1, -1))
  scale_factor <- ncatt_get(nc, "analysed_sst", "scale_factor")$value
  if (is.null(scale_factor)) scale_factor <- 1
  sst <- sst_raw * scale_factor
  
  nc_close(nc)
  
  tibble(date = time_dates, sst = sst)
}

sst_data <- map_dfr(nc_files, extract_sst, lat_target = -23.472241, lon_target = 151.959921)
sst_data <- as.data.frame(sst_data)
  
write.csv(sst_data, "Data/Analysis_data/Temperature/Heron_Island_SST_NovMay2024.csv", row.names = FALSE)

#### Download DHW NOAA data ####

base_url <- "https://www.ncei.noaa.gov/thredds-ocean/fileServer/crw/5km/v3.1/nc/v1.0/daily/dhw/2024/"
dates <- seq(as.Date("2024-02-03"), as.Date("2024-04-26"), by = "day")

for (current_date_num in dates) {
  current_date <- as.Date(current_date_num, origin = "1970-01-01")
  print(current_date)
  file_date <- gsub("-", "", as.character(current_date))
  file_name <- paste0("ct5km_dhw_v3.1_", file_date, ".nc")
  file_url <- paste0(base_url, file_name)
  
  cat("Trying to download:", file_name, "\n")
  r <- GET(file_url)
  if (status_code(r) == 200) {
    writeBin(content(r, "raw"), file_name)
    cat("✅ Downloaded:", file_name, "\n")
  } else {
    cat("❌ Failed:", file_name, "status", status_code(r), "\n")
  }
}

nc_files <- list.files(
  path = "Data/Analysis_data/Temperature/DHW_2024",
  pattern = "\\.nc$",
  full.names = TRUE
)

extract_dhw <- function(nc_file, lat_target, lon_target) {
  nc <- nc_open(nc_file)
  
  lat <- ncvar_get(nc, "lat")
  lon <- ncvar_get(nc, "lon")
  
  lat_idx <- which.min(abs(lat - lat_target))
  lon_idx <- which.min(abs(lon - lon_target))
  
  time <- ncvar_get(nc, "time")
  time_units <- ncatt_get(nc, "time", "units")$value
  time_origin <- sub("seconds since ", "", time_units)
  
  time_dates <- as.POSIXct(time, origin = time_origin, tz = "UTC")
  time_dates <- as.Date(time_dates)
  
  sst_raw <- ncvar_get(nc, "degree_heating_week", start = c(lon_idx, lat_idx, 1), count = c(1, 1, -1))
  scale_factor <- ncatt_get(nc, "degree_heating_week", "scale_factor")$value
  if (is.null(scale_factor)) scale_factor <- 1
  sst <- sst_raw * scale_factor
  
  nc_close(nc)
  
  tibble(date = time_dates, sst = sst)
}

dhw_data <- map_dfr(nc_files, extract_dhw, lat_target = -23.472241, lon_target = 151.959921)
dhw_data <- as.data.frame(dhw_data)

write.csv(dhw_data, "Data/Analysis_data/Temperature/Heron_Island_DHW_JanMay2024.csv", row.names = FALSE)
