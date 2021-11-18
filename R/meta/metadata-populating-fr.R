library(here)
library(yaml)
library(stringr)
library(purrr)
library(readr)

extract_fr_metadata <- function(yml_file) {
  
  #yml_file <- "10-4-2.yml"
  
  # extract indicator number from file path
  file_name <- yml_file
  
  # get path to file
  yml_file <- here("metadata", "translations-metadata", "fr", yml_file)
  
  # read yml (rather than calling read_yaml, which for some reason is not using encoding argument)
  meta_string <- paste(readLines(yml_file, encoding = "UTF-8"), collapse="\n")
  raw_meta <- yaml.load(meta_string)
  
  fields <- c(
    "SDG_GOAL", 
    "SDG_TARGET",
    "SDG_INDICATOR"
  )
  
  # add fields if they don't exist (in some of the french files, the basic metadata is empty)
  # TO DO: add in the actual goal/target/indicator info
  for (field in fields) {
    if ( is.null(raw_meta[[field]]) ) {
      raw_meta[field] <- "   "
    } else {
      raw_meta[field] <- raw_meta[field]
    }
  }
  
  # extract definition from definition and concepts (WIP)
  definition_field <- unlist(str_split(raw_meta$STAT_CONC_DEF, "\n"))
  
  if ( any(str_detect(definition_field, "Définition :")) ) {
    definition_position <- which(str_detect(definition_field, "Définition :")) + 1
    raw_meta$STAT_CONC_DEF  <- definition_field[definition_position]
  } else {
    definition_position <- NULL
    raw_meta$STAT_CONC_DEF  <- "   "
  }
  # else if ( any(str_detect(definition_field, "Definitions:")) ) {
  #   definition_position <- which(str_detect(definition_field, "Definitions:")) + 1
  # } 
  
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


extract_fr_source_metadata <- function(source_file) {
  
  #source_file <- "9-c-1.yml"

  source_file <- paste0("indicator_", str_replace(source_file, ".yml", ".txt"))
  source_file <- here("metadata", "gcdocs", source_file)

  if (!file.exists(source_file)) {

    return(list(reporting_status = "notstarted"))

  } else {

    # read metadata files (text files)
    gcdocs_md <- readLines(source_file)

    # filter for source fields
    fields <- gcdocs_md[which(str_detect(gcdocs_md, "source"))]
    fields <- 
      c(
        fields[!str_detect(fields, "source_url_[0-9]")],
        str_replace(fields[str_detect(fields, "source_url_[0-9]")], "-eng", "-fra")
      ) %>%
      str_replace_all("Statistics Canada", "Statistique Canada") %>%
      str_replace_all("Annual", "Annuelle")
    
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

write_new_metadata_fr <- function(file) {
  
  
  sdg_md <- as.yaml(extract_fr_metadata(file))
  source_md <- as.yaml(extract_fr_source_metadata(file))
  all_metadata <- c(sdg_md, source_md)
  
  
  # write the new yml for the new metadata
  readr::write_lines(all_metadata, here("metadata", "meta", "fr", file))
  
}

all_metadata_files <- list.files(here("metadata", "translations-metadata", "fr"))
map(all_metadata_files, write_new_metadata_fr)



