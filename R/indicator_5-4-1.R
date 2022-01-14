# Indicator 5.4.1 ---------------------------------------------------------

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)

unpaid_work_time <- get_cansim("45-10-0014-01", factors = FALSE)

unpaid_work_time <- 
  unpaid_work_time %>%
  filter(
    str_starts(`Hierarchy for Activity group`, "11"),
    Statistics == "Proportion of day, population",
    Sex != "Both sexes"
  ) %>%
  select(
    Year = REF_DATE,
    Geography = GEO,
    `Activity group`,
    `Age group`,
    Sex,
    Value = VALUE
  )

# No total line needed as this will be a bar chart comparing 2 sexes at one period in time


write_csv(unpaid_work_time, here("gif-data-processing", "data", "indicator_5-4-1.csv"))
