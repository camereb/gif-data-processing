# Indicator 1.2.1: ------------------------------------------------
# Proportion of population living below the national poverty line, by sex and age

# Load packages
library(cansim)
library(tidyverse)

# get CODR table
raw_table <- cansim::get_cansim("11-10-0135-01", factors = FALSE)

# filter for years past 2015, the proportion (rather than number), and remove "economic family" grouping
low_income <- 
  raw_table %>%
  rename(hier = `Hierarchy for Persons in low income`) %>%
  mutate(REF_DATE = as.numeric(REF_DATE)) %>%
  filter(
    REF_DATE >= 2015, 
    Statistics=="Percentage of persons in low income",
    hier %in% c("1", "1.2", "1.3", "1.4", "5", "5.6", "5.7", "5.8", "9", "9.10", "9.11", "9.12"),
    `Low income lines` == "Market basket measure, 2018 base"
    ) %>%
  select(Year = REF_DATE, Geography = GEO, `Persons in low income`, Value = VALUE)

# create total line for Open SDG format (making totals blank)
total_line <-
  low_income %>%
  filter(Geography=="Canada" & `Persons in low income`=="All persons") %>%
  mutate(
    Geography="", `Persons in low income`=""
  )

# combine total lines with all disaggregations
low_income <- 
  bind_rows(
    total_line,
    low_income %>% 
      filter(!(Geography=="Canada" & `Persons in low income`=="All persons")) %>%
      arrange(Geography, `Persons in low income`, Year)
  )

# write data
write_csv(
  low_income,
  here::here("gif-data-processing", "data", "indicator_1-2-1.csv")
)
