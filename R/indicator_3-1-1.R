
# Indicator 3.1.1 ---------------------------------------------------------

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)

deaths <- get_cansim("13-10-0152-01", factors = FALSE)
live_births <- get_cansim("13-10-0414-01", factors = FALSE)

# Total deaths due to pregnancy et al
total_deaths <- 
  deaths %>%
  filter(
    REF_DATE >= 2015,
    `Hierarchy for Cause of death (ICD-10)` == "1.6020",
    #str_starts(`Hierarchy for Cause of death (ICD-10)`, "1.6020"),
    `Hierarchy for Age group` == "1",
    `Hierarchy for Sex` == 1
    ) %>%
  select(REF_DATE, total_deaths = VALUE)

# Total live births (residence in Canada)
total_live_births <- 
  live_births %>%
  filter(
    REF_DATE >= 2015,
    `Hierarchy for Geography, place of occurrence` == "1.2",
    `Hierarchy for GEO` == "1.2"
    ) %>%
  select(REF_DATE, total_live_births = VALUE)

# Calculate MMR
data_final <- 
  total_deaths %>%
  left_join(total_live_births) %>%
  transmute(REF_DATE, Value = (total_deaths/total_live_births)*100000) %>%
  rename(Year = REF_DATE)

write_csv(data_final, here("gif-data-processing", "data", "indicator_3-1-1.csv"))
