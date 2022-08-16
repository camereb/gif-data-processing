
library(lubridate)
library(cansim)

# opensdg_col_rename <- function(col_names) {
#   
# 
#   
# }
# 
# test_colnames <- c("Geography", "Sex", "GeoCode", "Value")
# ignore <- c("Geography", "Units", "GeoCode", "Value")
# 
# ignore[ignore == test_colnames]



get_current_ref_date <- function(table_no) {
  
  tbl_md <- cansim::get_cansim_cube_metadata(table_no)
  current_date <- tbl_md$cubeEndDate
  current_year <- lubridate::year(current_date)
  
  return(current_year)
  
}

check_data_update <- function(data, current_year) {
  
  data_max_year <- max(data$REF_DATE)
  
  return(ifelse(max_year < current_year, TRUE, FALSE))
  
}

table_no <- "37-10-0170-01"
current_year <- get_current_ref_date(table_no)
data <- get_cansim(table_no, factors = FALSE)
check_data_update(data, current_year)
