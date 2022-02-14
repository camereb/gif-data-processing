# Indicator 10.4.1 ------------------------------------------------------
# 10.4.1 Labour share of GDP

library(cansim)
library(here)
library(dplyr)
library(stringr)
library(readr)

gdp <- get_cansim("36-10-0103-01", factors = FALSE)

geocodes <- read_csv("gif-data-processing/geocodes.csv")

labour_share <- 
  gdp %>%
  filter(
    lubridate::year(Date) >= 2000,
    Estimates %in% c("Compensation of employees", "Gross domestic product at market prices"),
    `Seasonal adjustment` == "Seasonally adjusted at annual rates"
    ) %>% 
  select(
    REF_DATE,
    Date,
    Estimates,
    Value = VALUE
  ) %>%
  tidyr::pivot_wider(
    names_from = Estimates,
    values_from = Value
  ) %>%
  transmute(
    REF_DATE,
    Date,
    `Labour share of GDP` = `Compensation of employees`/`Gross domestic product at market prices`
  )

