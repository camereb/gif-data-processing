# Indicator 3.5.2 ---------------------------------------------------------
# Alcohol per capita consumption

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)

alc_sales <- get_cansim("10-10-0010-01", factors = FALSE)

alc_sales_total <-
  alc_sales %>%
  filter(
    str_sub(REF_DATE, 6, 10) >= 2015,
    UOM == "Litres",
    `Type of sales` == "Total per capita sales",
    `Type of beverage` == "Total alcoholic beverages",
    `Value, volume and absolute volume` == "Absolute volume for total per capita sales"
  ) %>%
  select(
    Date = REF_DATE,
    Geography = GEO,
    Value = VALUE
  )

total_line <- 
  alc_sales_total %>%
  filter(
    Geography == "Canada"
  ) %>%
  mutate_at(c("Geography"), ~ "")  

data_final <- bind_rows(total_line, alc_sales_total)  

write_csv(data_final, here("gif-data-processing", "data", "indicator_3-5-2.csv"))

