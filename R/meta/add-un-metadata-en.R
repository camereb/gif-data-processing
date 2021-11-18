
library(yaml)
library(stringr)
library(here)
library(purrr)

extract_un_metadata_from_uk <- function(yml_file) {
  
  # get UN info from UK meta
  md_file <- str_replace(yml_file, ".yml", ".md")
  uk_meta_path <- paste0("https://raw.githubusercontent.com/ONSdigital/sdg-data/develop/meta/", md_file)
  

  uk_meta_raw <- readLines(uk_meta_path, encoding = "UTF-8")
  un_meta <- uk_meta_raw[str_starts(uk_meta_raw, "un_") | str_starts(uk_meta_raw, "goal_")]
  
  meta_string <- paste(un_meta, collapse="\n")
  un_yaml <- yaml.load(meta_string)
  
  return(un_yaml)
  
}

update_metadata <- function(yml_file) {
  
  meta_path <- paste0("https://raw.githubusercontent.com/sdg-data-canada-odd-donnees/sdg-data-donnees-odd/develop/meta/", yml_file)
  
  current_metadata <- read_yaml(meta_path)
  un_meta <- extract_un_metadata_from_uk(yml_file)
  
  updated_metadata <- c(current_metadata, un_meta)
  
  write_yaml(updated_metadata, here("metadata", "meta", yml_file))
  
}

all_metadata_files <- list.files("C:/Users/maia_/Documents/Open SDG/sdg-data-donnees-odd/meta", pattern = ".yml")
map(all_metadata_files, update_metadata)


