## Test Map for Test eBird Data
library(fs)
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(ggmap)
library(gganimate)

# Making symlink and input folder
if (dir.exists(here("spatial/test/input")) == F) {
  dir.create(here("spatial/test/input"))
}

link_create(here("ebird/data_ingest/output/ebd_output.txt"), here("spatial/test/input/ebd_output.txt"))

ebd_output <- fread(here("spatial/test/input/ebd_output.txt"))

## Mapping
map <- get_stamenmap(
  bbox = c(top = 33, left = -86.8, right = -85.7, bottom = 31.5),
  maptype = "terrain",
  zoom = 10
) %>% 
  ggmap()+
  geom_point(data = ebd_output, aes(LONGITUDE, LATITUDE, color = `COMMON NAME`, size = `OBSERVATION COUNT`))+
  transition_states(`LAST EDITED DATE`)+
  ease_aes()
