# Indicator 10.4.1 ------------------------------------------------------
# 10.4.1 Labour share of GDP

library(cansim)
library(here)
library(dplyr)
library(stringr)
library(readr)

gdp <- get_cansim("36-10-0103-01", factors = FALSE)

geocodes <- read_csv("geocodes.csv")

labour_share <- 
  gdp %>%
  tidyr::separate(REF_DATE, into = c("Year", "Month")) %>% 
  filter(
    Year >= 2015,
    `Seasonal adjustment` == "Seasonally adjusted at annual rates",
    Estimates %in% c("Compensation of employees", "Gross domestic product at market prices"),
    !GEO %in% c("Outside Canada", "Northwest Territories including Nunavut")
  ) %>% 
  select(
    Year,
    Month,
    Geography = GEO,
    Estimates,
    Value = VALUE
  ) %>%
  group_by(Year, Geography, Estimates) %>% 
  summarise(Value = sum(Value), .groups = "drop") %>% 
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

write_csv(data_final, here("GIF", "data", "indicator_10-4-1.csv"), na = "")  
