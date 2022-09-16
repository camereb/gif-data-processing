# TEMP #
setwd("F:/Documents/R/gif-data-processing/CIF")
###

source("automation_helper_functions.R")
library(stringr)

automation_scripts <- list.files(path = "R/", pattern = ".R")

required_updates <- c()

for (file in automation_scripts) {
  
  # file <- automation_scripts[2]
  
  indicator <- stringr::str_remove(file, ".R")
  
  code <- readLines(file.path("R", file))
  data_line <- code[stringr::str_detect(code, "get_cansim")]
  
  if (length(data_line) == 1) {
    
    table_no <- stringr::str_extract(data_line, regex("([0-9]+-)*[0-9]+"))
    
  } else {
    
    table_no <- "COMPLEX"
    
  }
  
  
  if (table_no != "COMPLEX") {
    
    data_path <- file.path("data", paste0(indicator, ".csv"))
    
    if (file.exists(data_path)) {
      
      data <- readr::read_csv(data_path, show_col_types = FALSE)
      update_required <- check_data_update(data, table_no)
      
    } else {
      
      # TODO: if no data, just automatically run update script
      update_required <- FALSE # TEMP
      
    }
    

  } else {
    
    update_required <- FALSE # TEMP
    
  }
  
  if (update_required == TRUE) {
    
    required_updates <- c(required_updates, indicator)
    # TODO: after this, updates need to be ran for any indicator listed
    # in the required updates vector
    
  }
  
  ### TEMP ###
  # test <- paste0(file, ": ", table_no)
  # table_nos <- c(table_nos, test)
  ####
  
}




# TODO: Wrap all automation scripts in functions to be called if update is needed
# TODO: Handle complex indicators
# TODO: Handle a source changing for an indicator (i.e. no longer use automation code so that updates don't override new data from new source)
# TODO: MAYBE create a codeset with indicator:source correspondences (cleaner than extracting from code but likely will need to be manually updated)