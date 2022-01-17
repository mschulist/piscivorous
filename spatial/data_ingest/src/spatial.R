## File for creating the map and combining the eBird and fish data
## Mark Schulist - January 2022

# Loading Libraries --------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(ggmap)

source(here("gen_funs.R"))
# source(here("ebird/data_ingest/src/read_ebird.R"))

# Making the map and inputting area of map
river_map <- get_stamenmap(
  bbox = c(left = -123.8, bottom = 37.1, right = -120.8, top = 41.5), 
  maptype = "terrain", 
  zoom = 10
) %>% 
  ggmap()
