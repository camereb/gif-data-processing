# Indicator 5.b.1 ---------------------------------------------------------
# 5.b.1 Proportion of individuals who own a mobile telephone, by sex

library(tidyverse)
library(here)
library(cansim)

# get CODR table
dwelling_equipment <- cansim::get_cansim("11-10-0228-01", factors = FALSE)

# get geocodes to join with data
geocodes <- read_csv("gif-data-processing/geocodes.csv")

household_cellphones <- 
  dwelling_equipment %>%
  filter(
    REF_DATE >= 2015,
    UOM == "Percent",
    `Dwelling characteristics and household equipment` == "Households having cellular telephones"
    ) %>% 
  select(
    Year = REF_DATE,
    Geography = GEO,
    Value = VALUE
  ) %>%
  left_join(geocodes) %>%
  relocate(GeoCode, .after = Geography) %>%
  mutate(Geography = ifelse(Geography == "Canada", "", Geography))

write_csv(household_cellphones, here("gif-data-processing", "data", "indicator_5-b-1.csv"))
