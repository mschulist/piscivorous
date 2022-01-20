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
if (file.exists(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.zip")) == F) {
  drive_download("https://drive.google.com/file/d/1YxCmF4VdNxxsEzZbziJg6YonA0TC7bQe/view?usp=sharing", here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.tar.gz"))
}

# Unzipping file if not already unzipped
if (dir.exists(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021/")) == F) {
  unzip(here("ebird/data_ingest/input/ebd_US-CA_relDec-2021.tar.gz"), exdir = here("ebird/data_ingest/input/"))
}



