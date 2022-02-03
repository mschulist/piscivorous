## Quick_Fish_Map.R
## Mike Tillotson - Febuary 2022


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

source(here("gen_funs.R"))

# Loading Fish data from google
drive_sync(here("spatial/basic_map/input/hydro-delta-marsh/"), "https://drive.google.com/drive/u/0/folders/1vhkP37Ls1R08o_-iPwzuM3zFAjnbx4CR")
drive_sync(here("spatial/basic_map/input/EDSM_extended_west/"), "https://drive.google.com/drive/u/0/folders/1v2ogJUx0M5jO-LEpdMySv1aGn1-Iaiq9")
drive_sync(here("spatial/basic_map/input/"), "https://drive.google.com/drive/u/0/folders/1-8yBgpc8nIF5b1-z9lvKA1a1VHK70C5P")


load(here("spatial/basic_map/input/Fish_Data_For_Birds.rda"))

# ===============================================================================
# Provide year constraint on Fish Data

Fish_Data <- Fish_Data %>% filter(Year > 2015)

# ===============================================================================
# Delta Base Layers and Station Coordinates

EDSM_Strata <- st_read("spatial/basic_map/input/EDSM_extended_west/EDSM_extended_west.shp") %>%
  mutate(SubRegion = recode(SubRegion, "Mid San Pablo extended west" = "Mid San Pablo Bay ext.")) %>%
  select(-c(OBJECTID, OBJECTID_1, Shape_Leng, Shape_Area, OBJECTID_2, Shape_Le_1))


marsh <- st_read(
  "spatial/basic_map/input/hydro-delta-marsh/hydro_delta_marsh.shp"
)

stations <- Fish_Data %>%
  filter(Year > 2001) %>%
  mutate(SurveySeason = factor(Study, levels = c("SLS", "20mm", "STN", "FMWT", "SKT"))) %>%
  distinct(across(c(Study, StationCode, Latitude, Longitude)), .keep_all = T) %>%
  group_by(StationCode) %>%
  mutate(N_Studies = length(unique(Study))) %>%
  st_as_sf(
    coords = c("Longitude", "Latitude"),
    crs = st_crs(marsh), agr = "constant"
  )

# Transform marsh and station layers to be consistent with EDSM polygons
marsh <- st_transform(marsh, crs = st_crs(EDSM_Strata))
stations <- st_transform(stations, st_crs(EDSM_Strata))

# Quick map of station locations
# Note that the far west point is a typo in an EDSM station longitude
ggplot() +
  theme_bw() +
  geom_sf(data = marsh, size = .25, color = "cornflowerblue", fill = "lightcyan", alpha = .5) +
  geom_sf(data = EDSM_Strata, fill = NA, size = 1) +
  geom_sf(data = stations, aes(color = SubRegion), size = 2)
