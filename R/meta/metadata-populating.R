
# Metadata automation -----------------------------------------------------

library(here)
library(yaml)
library(stringr)
library(purrr)

extract_en_metadata <- function(yml_file) {
  
  # extract indicator number from file path
  file_name <- yml_file
  
  # get path to file
  yml_file <- here("metadata", "translations-metadata", "en", yml_file)
  
  # read yml
  raw_meta <- read_yaml(yml_file)
  
  # extract definition from definition and concepts (WIP)
  definition_field <- unlist(str_split(raw_meta$STAT_CONC_DEF, "\n"))
  
  if ( any(str_detect(definition_field, "Definition:")) ) {
    definition_position <- which(str_detect(definition_field, "Definition:")) + 1
    raw_meta$STAT_CONC_DEF  <- definition_field[definition_position]
  } else if ( any(str_detect(definition_field, "Definitions:")) ) {
    definition_position <- which(str_detect(definition_field, "Definitions:")) + 1
    raw_meta$STAT_CONC_DEF  <- definition_field[definition_position]
  } else {
    definition_position <- NULL
    raw_meta$STAT_CONC_DEF  <- "   "
    
  }
  
  raw_meta$STAT_CONC_DEF  <- definition_field[definition_position]
  
  # create global metadata fields
  raw_meta$SDG_GOAL__GLOBAL <- raw_meta$SDG_GOAL
  raw_meta$SDG_TARGET__GLOBAL <- raw_meta$SDG_TARGET
  raw_meta$SDG_INDICATOR__GLOBAL <- raw_meta$SDG_INDICATOR
  raw_meta$DATA_COMP <- "   "
  raw_meta$REC_USE_LIM <- "   "
  
  # fields to take from the raw_meta data
  fields <- c(
    "SDG_GOAL", 
    "SDG_TARGET",
    "SDG_INDICATOR",
    "STAT_CONC_DEF",
    "DATA_COMP",
    "REC_USE_LIM",
    "SDG_GOAL__GLOBAL",
    "SDG_TARGET__GLOBAL",
    "SDG_INDICATOR__GLOBAL"
  )
  
  return(raw_meta[fields])
  
}


# Extract sources from gcdocs metadata --------------------------------

extract_source_metadata <- function(source_file) {
  
  source_file <- paste0("indicator_", str_replace(source_file, ".yml", ".txt"))
  source_file <- here("metadata", "gcdocs", source_file)
  
  if (!file.exists(source_file)) {
    
    return(NULL)
    
  } else {
    
    # read metadata files (text files)
    gcdocs_md <- readLines(source_file) 
    
    # filter for source fields
    fields <- gcdocs_md[which(str_detect(gcdocs_md, "source"))]
    
    # format for yaml file
    field_names <- str_remove(str_extract(fields, "^\\w*:"), ":")
    fields <- trimws(str_remove(fields, "^\\w*:"))
    fields <- str_remove_all(fields, "\"")
    names(fields) <- field_names
    source_metadata <- as.list(fields)
    
    source_metadata$reporting_status <- "complete"
    source_metadata$COVERAGE <- source_metadata$source_geographical_coverage_1
  
    return(source_metadata)
    
  }
  
}

write_new_metadata <- function(file) {
  
  sdg_md <- extract_en_metadata(file)
  source_md <- extract_source_metadata(file)
  all_metadata <- c(sdg_md, source_md)
  
  # write the new yml for the new metadata
  write_yaml(all_metadata, here("metadata", "meta", file))
  
}



# run script on all meta files --------------------------------------------


all_metadata_files <- list.files(here("metadata", "translations-metadata", "en"))
# temp until can figure out 5-4-1 fix
all_metadata_files <- all_metadata_files[!str_ends(all_metadata_files, "5-4-1.yml")]
all_metadata <- map(all_metadata_files, write_new_metadata)




# # investigate definitions ------------------------------------------------
# 
# all_metadata <- map(all_metadata_files, extract_en_metadata)
# 
# index <- c()
# for (i in (1:length(all_metadata))) {
#   if ( length(all_metadata[[i]]$STAT_CONC_DEF) == 0 ) {
#     index <- c(index, i)
#   } else {
#     index <- c(index)
#   }
# }
# 
# all_metadata[index][[1]]$SDG_INDICATOR
# 
# no_def_indicators <- c()
# for (i in (1:length(all_metadata[index]))) {
#   no_def_indicators <- c(no_def_indicators, all_metadata[index][[i]]$SDG_INDICATOR)
# }
# 
# writeLines(no_def_indicators, "no_definitions2.txt")
