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
  filter(`COMMON NAME` == "Double-crested Cormorant")

# Adding spatial region to eBird data ---------
# Importing shapefile for delta
delta_map <- st_read(here("ebird/summarize/input/EDSM_shapefile/EDSM_subregions_120418_Phase1.shp"))


# Making eBird data into sf object
dcco_sf <- dcco_ebd_data %>% 
  st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 26910)

dcco_ebd_data_points <- st_join(dcco_sf, delta_map, join = st_within)
