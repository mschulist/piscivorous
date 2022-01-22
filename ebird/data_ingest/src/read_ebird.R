## read_ebird.R
## Mark Schulist - January 2022

# Loading Libraries --------------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(auk)

source(here("gen_funs.R"))

# Downloading and unzipping eBird Data if not already downloaded --------------

# Creating input folder
if (dir.exists(here("ebird/data_ingest/input/")) == F) {
  dir.create(here("ebird/data_ingest/input/"))
}

# Checking if zip file has been downloaded and downloading if not already downloaded
if (file.exists(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.tar.gz")) == F) {
  drive_download("https://drive.google.com/file/d/1YxCmF4VdNxxsEzZbziJg6YonA0TC7bQe/view?usp=sharing", here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.tar.gz"))
}

# Unzipping file if not already unzipped
if (dir.exists(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021/")) == F) {
  untar(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.tar.gz"), exdir = "ebird/data_ingest/input/")
}

# Downloading list of birds to filter if not already downloaded
if (file.exists(here("ebird/data_ingest/input/birds.txt")) == F) {
  drive_download("https://drive.google.com/file/d/1ipsjUfYje6lISyzgtgGDso9ZbKlfzpq2/view", here("ebird/data_ingest/input/birds.txt"))
}

# Filtering eBird data with birds.txt -------------
species <- fread(here("ebird/data_ingest/input/birds.txt"), fill = T)

ebd_filters <- auk_ebd(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021/ebd_US-CA_relDec-2021.txt")) %>% 
  auk_species(species$species) %>% 
  auk_complete() %>% 
  auk_bbox(c(-123.8, 37.1, -120.8, 41.5))

if (dir.exists(here("ebird/data_ingest/output")) == F) {
  dir.create(here("ebird/data_ingest/output"))
}

auk_filter(ebd_filters, here("ebird/data_ingest/output/ebd_filtered.txt"), overwrite = T)
