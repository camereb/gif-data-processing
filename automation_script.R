source("automation_helper_functions.R")
library(stringr)


automation_scripts <- list.files(path = "CIF/R", pattern = ".R", full.names = TRUE)

table_nos <- c()

for (file in automation_scripts) {
  
  code <- readLines(file)
  data_line <- code[stringr::str_detect(code, "get_cansim")]
  
  if (length(data_line) == 1) {
    
    table_no <- stringr::str_extract(data_line, regex("([0-9]+-)*[0-9]+"))
    
  } else {
    
    table_no <- "COMPLEX"
    
  }
  
  
  test <- paste0(file, ": ", table_no)
  table_nos <- c(table_nos, test)
  
  
}





# TODO: Figure out a way to check if tables need updating before automatically running the update
# TODO: Handle a source changing for an indicator (i.e. no longer use automation code so that updates don't override new data from new source)
# TODO: Get table number from codes (options: create a codeset with indicator:source correspondences)