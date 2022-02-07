## read_fish.R
## Script for reading in fish data and adding the spatial region
## Also filter species

## Mark Schulist - February 2022

# Loading Libraries --------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(ggmap)
library(fs)
library(sf)
library(tmap)
library(tmaptools)
library(lubridate)

source(here("gen_funs.R"))

# Getting data from google drive -------------
drive_sync(here("fish/data_ingest/input/EDSM_subregions/"), "https://drive.google.com/drive/u/0/folders/1N-Xgf39IlL4ZW61A2dDq687U79dgWQ7x")
drive_sync(here("fish/data_ingest/input/"), "https://drive.google.com/drive/u/0/folders/15D5ywpasDBS3zN4g0wk0k1qB3ECZTflE")

# Reading in fish data ----------
load(here("fish/data_ingest/input/Fish_Data_For_Birds.rda"))

# Filter fish data -----------
# Filtering by being >= 2015
# Adding a column with just the year and month (to align with eBird data (in summarize))
filter_fish_data <- Fish_Data %>% 
  mutate(Year = as.integer(Year)) %>% 
  filter(Year >= 2015) %>% 
  mutate(month_yr = format_ISO8601(SampleDate, precision = "ym")) %>% 
  relocate(month_yr, .after = SampleDate)

# Joining spatial data to get the polygon for each record -----------
# Reading in spatial data
delta_map <- st_read(here("fish/data_ingest/input/EDSM_subregions/EDSM_subregions_120418_Phase1.shp")) %>%
  st_transform(crs = 4326)

# Making fish data into geometry (sf spatial) object and joining with delta polygons
sf_fish_data <- filter_fish_data %>% 
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>% 
  st_join(delta_map, left = T) %>% 
  filter(!is.na(SQM)) # Getting rid of obs. that are not in any polygon

# Writing data ---------
if (dir.exists(here("fish/data_ingest/output/")) == F) {
  dir.create(here("fish/data_ingest/output/"))
}

fwrite(sf_fish_data, here("fish/data_ingest/output/fish_data.csv"))
