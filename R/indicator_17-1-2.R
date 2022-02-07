# Indicator 17.1.2 ---------------------------------------------------------
# Proportion of domestic budget funded by domestic taxes

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)
library(tidyr)

finance_stats <- get_cansim("10-10-0147-01", factors = FALSE)

geocodes <- read_csv("gif-data-processing/geocodes.csv")

ops <- c("Revenue [1]", "Taxes [11]")

tax_revenue <- 
  finance_stats %>%
  filter(
    REF_DATE >= 2015,
    `Display value` == "Stocks",
   # GEO == "Canada",
    `Statement of operations and balance sheet` %in% ops
  ) %>%
  select(
    Year = REF_DATE,
    Geography = GEO,
    `Public sector components`,
    Finances = `Statement of operations and balance sheet`,
    Value = VALUE
    ) %>%
  mutate(
    Finances = str_remove(Finances, " \\[[0-9]*\\]")
    ) %>%
  pivot_wider(
    names_from = "Finances",
    values_from = "Value"
  ) %>%
  mutate(Value = round((Taxes/Revenue)*100, 2)) %>%
  select(!(Revenue:Taxes)) %>%
  left_join(geocodes) %>%
  relocate(GeoCode, .before = Value)

data_final <- 
  bind_rows(
    tax_revenue %>%
      filter(Geography == "Canada", `Public sector components` == "Consolidated Canadian general government") %>%
      mutate(across(Geography: `Public sector components`, ~ "")),
    tax_revenue %>%
      filter(!(Geography == "Canada" & `Public sector components` == "Consolidated Canadian general government"))
  )
 
write_csv(data_final, here("gif-data-processing", "data", "indicator_17-1-2.csv"), na = "")
