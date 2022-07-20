# Indicator 10.4.1 ------------------------------------------------------
# 10.4.1 Labour share of GDP

library(cansim)
library(here)
library(dplyr)
library(stringr)
library(readr)

gdp <- get_cansim("36-10-0221-01", factors = FALSE)

geocodes <- read_csv("gif-data-processing/geocodes.csv")

labour_share <- 
  gdp %>%
  filter(
   REF_DATE >= 2000,
    Estimates %in% c("Compensation of employees", "Gross domestic product at market prices")
    # `Seasonal adjustment` == "Seasonally adjusted at annual rates"
    ) %>% 
  select(
    Year = REF_DATE,
    Geography = GEO,
    Estimates,
    Value = VALUE
  ) %>%
  tidyr::pivot_wider(
    names_from = Estimates,
    values_from = Value
  ) %>%
  transmute(
    Year, Geography,
    Value = round((`Compensation of employees`/`Gross domestic product at market prices`)*100, 2)
  ) %>%
  left_join(geocodes) %>%
  relocate(GeoCode, .before = "Value")

data_final <- 
  bind_rows(
    labour_share %>%
      filter(Geography == "Canada") %>%
      mutate(across(2:(ncol(.)-2), ~ "")),
    labour_share %>%
      filter(Geography != "Canada")
  )

write_csv(data_final, here("gif-data-processing", "data", "indicator_10-4-1.csv"), na = "")  
