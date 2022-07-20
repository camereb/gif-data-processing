# Indicator 11.1.1 ------------------------------------------------------
# 11.1.1.PR Proportion of urban population in core housing need

library(cansim)
library(here)
library(dplyr)
# library(stringr)
library(readr)

housing_need <- get_cansim("46-10-0046-01", factors = FALSE)

#geocodes <- read_csv("gif-data-processing/geocodes.csv")

names(housing_need)

core_housing_need <- 
  housing_need %>%
  filter(
    `Living with housing problems` == "Living in core housing need",
    `Statistics` == "Percentage of households"
  ) %>%
  select(
    Year = REF_DATE,
    `Selected housing vulnerable populations`,
    Value = VALUE
  )

data_final <- 
  bind_rows(
    core_housing_need %>%
      filter(`Selected housing vulnerable populations` == "All households") %>%
      mutate(`Selected housing vulnerable populations` = ""),
    core_housing_need %>%
      filter(`Selected housing vulnerable populations` != "All households")
)

write_csv(data_final, here("gif-data-processing", "data", "indicator_11-1-1.csv"))

