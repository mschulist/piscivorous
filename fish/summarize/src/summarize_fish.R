## summarize_fish.R
## Script meant to summarize fish data for comparing with bird data
## Mark Schulist - Februrary 2022

# Loading Libraries -----------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(fs)
library(sf)
library(lubridate)

source(here("gen_funs.R"))

# Importing data -----------
# Making symlink from output of read_fish.R
if (dir.exists(here("fish/summarize/output")) == F) {
  dir.create(here("fish/summarize/output"))
}
link_create(here("fish/data_ingest/output/fish_data.csv"), here("fish/summarize/input/fish_data.csv"))
# Ingesting 
fish_data <- fread(here("fish/summarize/input/fish_data.csv")) %>% 
  separate(geometry, into = c("longitude", "latitude"), sep = "\\|") %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) # Making into sf object


# Summarizing ---------------
# Summarizing the fish data into fewer rows with counts
small_fish_data <- fish_data %>% 
  group_by(SampleDate, CommonName, SQM) %>% 
  summarize(count = n(), month_yr, geometry, SubRegion.x, Gear, StationCode) %>% 
  slice_sample()
# Grouping by location, month (year dependent), and species
summary_fish_data <- small_fish_data %>% 
  group_by(SQM, month_yr, CommonName) %>% 
  summarize(count = mean(count), geometry, SubRegion.x, Gear, StationCode)
# Writing -----------
if (dir.exists(here("fish/summarize/output")) == F) {
  dir.create(here("fish/summarize/output"))
}
fwrite(summary_fish_data, here("fish/summarize/output/fish_summary.csv"))
