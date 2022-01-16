## read_ebird.R
## Script for ingesting eBird data
## Ingests and does a preliminary filter for future scripts to analyze
## Mark Schulist - January 2022

# Loading Libraries --------------------
library(tidyverse)
library(here)
library(googledrive)
library(data.table)
library(auk)

source(here("gen_funs.R"))

# Syncing eBird data with google drive -------------
drive_sync(here("ebird/data_ingest/input/"), "https://drive.google.com/drive/u/0/folders/1Ts-wV_VCq2eK5TCLgILB2_lm108OcrQM")

# Setting Filter Values ------------------
species <- c("")

# Setting up eBird directory and filtering ----------------
ebd_filters <- auk_ebd(here("ebird/data_ingest/input/")) %>% 
  auk_species(species) %>% 
  auk_complete()

auk_filter(ebd_filters, file = here("ebird/data_ingest/output/ebd_output.txt"))
