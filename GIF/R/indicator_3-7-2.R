# Indicator 3.7.2 ---------------------------------------------------------
#  Adolescent birth rate (aged 10–14 years; aged 15–19 years) per 1,000 women in that age group

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)

birth_rates <- get_cansim("13-10-0418-01", factors = FALSE)

adolescent_birth_rates <-
  birth_rates %>%
  filter(
    REF_DATE >= 2015,
    Characteristics == "Age-specific fertility rate, females 15 to 19 years"
  ) %>%
  mutate(
    # Age = str_remove(Characteristics, "Age-specific fertility rate, "),
    # Age = str_to_sentence(Age),
    GEO = str_remove(GEO, ", place of residence of mother")
  ) %>%
  select(
    Year = REF_DATE,
    Geography = GEO,
    Value = VALUE
  )

total_line <- 
  adolescent_birth_rates %>%
  filter(
    Geography == "Canada"
  ) %>%
  mutate_at(c("Geography"), ~ "")  

data_final <- bind_rows(total_line, adolescent_birth_rates)  

write_csv(data_final, here("gif-data-processing", "data", "indicator_3-7-2.csv"))
