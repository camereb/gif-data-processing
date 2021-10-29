
# Metadata automation -----------------------------------------------------

library(here)
library(yaml)
library(stringr)
library(purrr)

extract_en_metadata <- function(yml_file) {
  
  file_name <- yml_file %>% str_extract("[0-9]*-[0-9a-z]*-[0-9a-z]*\\.yml$")
  
  raw_meta <- read_yaml(yml_file)
  
  definition_field <- unlist(str_split(raw_meta$STAT_CONC_DEF, "\n"))
  definition_position <- which(str_detect(definition_field, "Definition:")) + 1
  raw_meta$STAT_CONC_DEF  <- definition_field[definition_position]
  
  raw_meta$SDG_GOAL__GLOBAL <- raw_meta$SDG_GOAL
  raw_meta$SDG_TARGET__GLOBAL <- raw_meta$SDG_TARGET
  raw_meta$SDG_INDICATOR__GLOBAL <- raw_meta$SDG_INDICATOR
  
  
  fields <- c(
    "SDG_GOAL", 
    "SDG_TARGET",
    "SDG_INDICATOR",
    "STAT_CONC_DEF",
    "SDG_GOAL__GLOBAL",
    "SDG_TARGET__GLOBAL",
    "SDG_INDICATOR__GLOBAL"
  )
  
  write_yaml(raw_meta[fields], here("metadata", "meta", file_name))
  return(raw_meta[fields])
  
}


all_metadata_files <- list.files(here("metadata", "translations-metadata", "en"), full.names = TRUE)
# temp until can figure out 5-4-1 fix
all_metadata_files <- all_metadata_files[!str_ends(all_metadata_files, "/5-4-1.yml")]
all_metadata <- map(all_metadata_files, extract_en_metadata)

