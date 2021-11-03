# load packages
library(dplyr)
library(cansim)
library(here)
library(janitor)

low_income_codr <- 
  get_cansim("11-10-0135-01", factors = FALSE) %>%
    clean_names()

low_income_codr %>% 
  View()

low_income_codr %>% 
  filter(
    ref_date >= 2015, 
    str_starts(statistics, "Percentage"),
    low_income_lines == "Market basket measure, 2018 base"
    ) %>% View()
  select(ref_date, geo, persons_in_low_income, low_income_lines, value)
