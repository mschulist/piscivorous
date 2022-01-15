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
