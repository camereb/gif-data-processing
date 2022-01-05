# Metadata automation -----------------------------------------------------

library(here)
library(yaml)
library(stringr)
library(purrr)

# get current metadata from GIF repo
# get metadata from worldbank/sdg-translations
# compare worldbank metadata to current metadata
# if worldbank =/= current, then update to worldbank

get_existing_metadata <- function(indicator_yml) {
  
  # temp ########
  indicator_yml <- "1-2-1.yml"
  #############
  
  # get path to file
  yml_file <- paste0("https://raw.githubusercontent.com/sdg-data-canada-odd-donnees/sdg-data-donnees-odd/develop/meta/", indicator_yml)
  
  # read yml from file
  raw_meta <- read_yaml(yml_file)
  
  return(raw_meta)
  
}

get_worldbank_metadata <- function(indicator_yml) {
  
  #temp ########
  indicator_yml <- "1-2-1.yml"
  #############
  
  wb_path <- paste0("https://raw.githubusercontent.com/worldbank/sdg-metadata/master/translations-metadata/en/", indicator_yml)
  
  worldbank_meta <- read_yaml(wb_path)
  
  # fields to take from the raw_meta data
  fields <- c(
    "SDG_GOAL", 
    "SDG_TARGET",
    "SDG_INDICATOR",
    "STAT_CONC_DEF"
  )
  
  worldbank_meta <- worldbank_meta[fields]
  
}

