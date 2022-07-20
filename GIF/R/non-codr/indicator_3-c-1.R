
# load libraries
library(tidyverse)
library(readxl)
library(janitor)
library(here)

# file with all the provincial data
health_workforce_file <- "F:/Documents/Open SDG/raw data/canada-health-care-providers-2015-2019-data-tables-en.xlsx"

# function to get all relevant data from each p/t sheet
get_pt_health_workforce_data <- function(sheet_name, stat = "per_100_000_pop") {
  
  p_t <- 
    read_excel(health_workforce_file, sheet = sheet_name, range = "A4:H4", col_names = FALSE) %>%
    select_if(is.character) %>%
    pull()
  
  data <- read_excel(health_workforce_file, sheet = sheet_name, range = "A5:H170")
  
  data <- 
    data %>%
    clean_names() %>% 
    select(year, type_of_provider, starts_with(stat)) %>%
    rename_at(vars(starts_with(stat)), function (x) "value") %>%
    mutate(
      geography = p_t,
      value = round(as.numeric(value), 2)
    ) %>%
    relocate(geography, .after = year) %>%
    rename_all(function(x) str_to_sentence( str_replace_all(x, "_", " ") ))
  
  return(data)
  
}

# get rates of p/ts
sheet_names <- readxl::excel_sheets(health_workforce_file)[4:16]
pt_health_workforce <- map_dfr(sheet_names, get_pt_health_workforce_data)
View(pt_health_workforce)

# get counts of all types of provders 
canadian_health_workforce_counts <- map_dfr(sheet_names, get_pt_health_workforce_data, stat = "count")

# get yearly population estimates for each P/T
population_est <- 
  read_excel(health_workforce_file, sheet = "15 Population", range = "A4:F17") %>%
  rename_at(vars(1), function(x) "Geography") %>%
  pivot_longer(
    cols = 2:6,
    names_to = "Year",
    names_transform = list(Year = as.numeric),
    values_to = "Population"
  )
  
# get total yearly population estimates
total_population_est <- 
  population_est %>% 
  group_by(Year) %>%
  summarise(Population = sum(Population))

# calculate rate per 100,000 in all of canada for each type of provider
canadian_health_workforce <- 
  canadian_health_workforce_counts %>%
  group_by(Year, `Type of provider`) %>%
  summarise(Value = sum(Value, na.rm = TRUE), .groups = "keep") %>%
  arrange(`Type of provider`) %>%
  left_join(total_population_est) %>%
  transmute(Value = round((Value/Population)*100000, 2)) %>%
  mutate(Geography = "Canada") %>%
  relocate(Geography, .after = "Year")

# combine everything
data_final <-
  bind_rows(canadian_health_workforce, pt_health_workforce)
# View(data_final)

write_csv(data_final, here("gif-data-processing", "data", "indicator_3-c-1.csv"), na = "")
