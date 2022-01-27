## File for creating the map and combining the eBird and fish data
## Mark Schulist - January 2022

# Loading Libraries --------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(ggmap)
library(fs)
library(sf)
library(randomcoloR)
library(tmap)
library(tmaptools)

source(here("gen_funs.R"))
source(here("ebird/summarize/src/summarize_ebird.R"))
# source(here("ebird/data_ingest/src/read_ebird.R"))

# Importing data
# link_create(here("ebird/data_ingest/output/ebd_filtered.txt"), here("spatial/data_ingest/input/ebd_filtered.txt"))
# ebd_output <- fread(here("spatial/data_ingest/input/ebd_filtered.txt"))

# dcco_data <- ebd_output %>% 
#  filter(`COMMON NAME` == "Double-crested Cormorant", `OBSERVATION COUNT` != "X")

# delta_map <- st_read(here("ebird/summarize/input/EDSM_shapefile/EDSM_subregions_120418_Phase1.shp"))


# Making the map and inputting area of map
#river_map <- get_stamenmap(
 # bbox = c(left = -123.8, bottom = 37.1, right = -120.8, top = 41.5), 
  # maptype = "terrain", 
  # zoom = 10
# ) %>% 
  #ggmap() +
  #geom_tile(data = dcco_data, aes(LONGITUDE, LATITUDE, fill = `OBSERVATION COUNT`))
  #geom_point(data = dcco_data, aes(LONGITUDE, LATITUDE)) #+
  #transition_states(`LAST EDITED DATE`) +
  #ease_aes()

# Plotting the DCCO with the polygons
# First left_joining colors to the dcco_summary data based on the polygon
colors <- tibble(
  unique(dcco_summary$SQM), 
  distinctColorPalette(length(unique(dcco_summary$SQM)))
) %>% 
  rename(SQM = 1, color = 2)


dcco_summary <- left_join(dcco_summary, colors, by = "SQM")
# Interactive Viewing Map
tmap_mode("view")
  tm_basemap("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png") +
tm_shape(delta_map)+
  tm_polygons(alpha = 0)+
tm_shape(dcco_summary)+
  tm_dots(col = "SubRegion")

# Non-interactive Raster Map
tmap_options(max.categories = 33)
tmap_mode("plot")
  tm_shape(read_osm(delta_map, type="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}")) +
    tm_rgb()+
 tm_shape(delta_map)+
   tm_borders(col = "red", lwd = 1)+
 tm_shape(dcco_summary)+
   tm_dots(col = "SubRegion", size = "count")+
    tm_legend(legend.outside = T, legend.text.size = 2, title.size = 5) +
    tm_layout(main.title = "Double-crested Cormorant Summary", title.size = 2)
  