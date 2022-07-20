# Indicator 5.3.1 ---------------------------------------------------------
# 5.3.1 Proportion of women aged 20-24 years who were married or in a union
# before age 15 and before age 18

library(tidyverse)
library(here)

census_data <- read_csv(here("gif-data-processing", "raw data", "indicator_5-3-1.csv")) %>%
  select(-c("Total - Age", "Sex"))
geocodes <- read_csv(here("gif-data-processing", "geocodes.csv"))

totals <- 
  census_data %>%
  pivot_longer(
    cols = c("15 to 19 years", "20 to 24 years"),
    names_to = "Age Group",
    values_to = "Value"
  ) %>%
  filter(`Marital status` == "Total - Marital status") %>%
  rename(Total = Value) %>%
  select(-`Marital status`)


girls_married_common_low <- 
  census_data %>%
  filter(`Marital status` != "Total - Marital status") %>%
  pivot_longer(
    cols = c("15 to 19 years", "20 to 24 years"),
    names_to = "Age Group",
    values_to = "Value"
  ) %>%
  left_join(totals) %>%
  mutate(
    Value = as.numeric(Value), Total = as.numeric(Total),
  ) %>%
  filter(!is.na(Value)) %>%
  transmute(
    GEO_NAME, `Census year`, `Marital status`, `Age Group`,
    Value = round((Value/Total)*100, 2)
  ) %>%
  # left_join(geocodes, by = c("GEO_NAME" = "Geography")) %>%
  # mutate(Code = ifelse(`Marital status` == "Married or living common law", Code, NA)) %>%
  select(
    Year = `Census year`,
    Geography = GEO_NAME,
    # GeoCode = Code,
    `Marital status`,
    `Age Group`,
    Value
  )

write_csv(girls_married_common_low, 
          here("gif-data-processing", "data", "indicator_5-3-1.csv"),
          na = "")
