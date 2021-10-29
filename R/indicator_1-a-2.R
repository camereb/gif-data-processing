# load packages
library(tidyverse)
library(cansim)
library(here)

# get CODR table
gov_spending <- get_cansim("10-10-0024-01") %>% janitor::clean_names()

# keep needed data and tidy data for open sdg format
gov_spending_tidy <- 
  gov_spending %>%
  select(year = ref_date, geo, value, public_sector_components, gov_functions = canadian_classification_of_functions_of_government_ccofog, hierarchy = hierarchy_for_canadian_classification_of_functions_of_government_ccofog) %>%
  filter(year>=2015, as.numeric(hierarchy)%%1 == 0, value > 0) %>%
  mutate(
    gov_functions = str_trim(str_remove_all(gov_functions, "\\[[0-9]*\\]")),
    gov_functions = ifelse(gov_functions %in% c("Education", "Health", "Social protection"), gov_functions, "Other expenditure")
    ) %>%
  group_by(year, geo, gov_functions) %>%
  summarise(value = sum(value))

# Calculate proportion on essential services
gov_spending_final <- 
  gov_spending_tidy %>%
  mutate(
    value = round((value/sum(value))*100, 3)
  )

# Calculuate total line for total % on essential services federally
total_line <- 
  gov_spending_tidy %>%
    filter(geo == "Canada") %>%
    mutate(gov_functions = ifelse(gov_functions %in% c("Education", "Health", "Social protection"), "Essential", gov_functions)) %>%
    group_by(year, gov_functions) %>%
    summarise(value = sum(value)) %>%
    mutate(
      value = round((value/sum(value))*100, 3)
    ) %>%
    filter(gov_functions=="Essential") %>%
    mutate(geo = "", gov_functions = "") %>%
    relocate(geo, .after = year)

# Calculuate total line for total % on essential services provincially
total_line_prov <-
  gov_spending_tidy %>%
    mutate(gov_functions = ifelse(gov_functions %in% c("Education", "Health", "Social protection"), "Essential", gov_functions)) %>%
    group_by(year, geo, gov_functions) %>%
    summarise(value = sum(value)) %>%
    mutate(
      value = round((value/sum(value))*100, 3)
    ) %>%
    filter(gov_functions=="Essential") %>%
    mutate(gov_functions = "") %>%
    relocate(geo, .after = year)
  
  
# Bind data together and rename columns for final data
data_final <-
  bind_rows(
    total_line,
    total_line_prov,
    gov_spending_final
  ) %>%
  rename(
    Year = year,
    Geography = geo,
    `Function of Government` = gov_functions,
    Value = value
  )

write_csv(data_final, here("data", "indicator_1-a-2.csv"))
