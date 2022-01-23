## summarize_ebird.R
## script to summarize the eBird data
## also get the zero counts of birds

## Starting just with DCCO
## Mark Schulist - January 2022

# Loading Libraries -------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(auk)
library(fs)
library(sf)
library(lubridate)

source(here("gen_funs.R"))

# Getting filtered eBird data ----------------
if (dir.exists(here("ebird/summarize/input")) == F) {
  dir.create(here("ebird/summarize/input"))
}

# Creating symlink from data_ingest output
link_create(here("ebird/data_ingest/output/ebd_filtered.txt"), here("ebird/summarize/input/ebd_filtered.txt"))

# Reading in eBird data
ebd_data <- fread(here("ebird/summarize/input/ebd_filtered.txt"))

# Filtering eBird data ---------------
dcco_ebd_data <- ebd_data %>%
  filter(`COMMON NAME` == "Double-crested Cormorant") %>%
  filter(`OBSERVATION COUNT` != "X")

# Getting rid of "X"
dcco_ebd_data$`OBSERVATION COUNT` <- as.numeric(dcco_ebd_data$`OBSERVATION COUNT`)

# Adding spatial region to eBird data ---------
# Importing shapefile for delta
if (dir.exists(here("ebird/summarize/input/EDSM_subregions")) == F) {
  dir.create(here("ebird/summarize/input/EDSM_subregions"))
}
drive_sync(here("ebird/summarize/input/EDSM_subregions/"), "https://drive.google.com/drive/u/0/folders/1N-Xgf39IlL4ZW61A2dDq687U79dgWQ7x")

delta_map <- st_read(here("ebird/summarize/input/EDSM_subregions/EDSM_subregions_120418_Phase1.shp")) %>%
  st_transform(crs = 4326) # Changing the coord system to the ebird (correct) coord system


# Making eBird data into sf object
dcco_sf <- dcco_ebd_data %>%
  st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 4326)
# Joining eBird and polygon data
dcco_ebd_data_join <- st_join(dcco_sf, delta_map, left = T) %>%
  filter(!is.na(SQM))

# Summarizing the dcco data by month (for now)
dcco_summary <- dcco_ebd_data_join %>%
  rename(date = `LAST EDITED DATE`) %>% # renaming date to make it pretty
  mutate(
    month_yr = format_ISO8601(date, precision = "ym") # only keeping the month and year
  ) %>%
  group_by(SQM, SubRegion, month_yr) %>%
  filter(n() >= 3) %>% # getting rid of groups that do not have at least 3 data points
  summarize(count = mean(`OBSERVATION COUNT`), st_dev = sd(`OBSERVATION COUNT`))
