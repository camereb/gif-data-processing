# Indicator 9.5.2 ------------------------------------------------------
# 9.5.2 9.5.2 Researchers (in full-time equivalent) per million inhabitants

library(cansim)
library(here)
library(dplyr)
library(stringr)
library(readr)

rd_personnel <- get_cansim("27-10-0022-01", factors = FALSE)

pop_ests <- get_cansim("17-10-0005-01", factors = FALSE)


#researchers <- 
  left_join(
    # Researcher numbers
    rd_personnel %>%
      filter(
        REF_DATE >= 2010,
        `Occupational category` %in% c("Researchers", "On-site research consultants"),
        `Performing sector` == "Total performing sector"
      ) %>%
      select(
        Year = REF_DATE,
        Geography = GEO,
        #`Performing sector`,
        `Type of science`,
        `Occupational category`,
        No_Personnel = VALUE
      ) %>%
      group_by_at(1:3) %>%
      summarise(No_Personnel = sum(No_Personnel)),
    # Population estimate
    pop_ests %>% 
      filter(
        REF_DATE >= 2010,
        GEO == "Canada",
        Sex == "Both sexes",
        `Age group` == "18 years and over" # Need 15+
      ) %>%
      select(
        Year = REF_DATE,
        Population = VALUE
      )
    ) %>%
    transmute(
      Year, Geography, `Type of science`,
      Value = (No_Personnel/Population)*1000000
    )





data_final <- 
  bind_rows(
    rd_gdp_data %>%
      filter(Geography == "Canada", `Science type` == "Total sciences") %>%
      mutate(across(2:(ncol(.)-2), ~ "")),
    rd_gdp_data %>%
      filter(!(Geography == "Canada" & `Science type` == "Total sciences"))
  )  

write_csv(data_final, here("gif-data-processing", "data", "indicator_9-5-1.csv"))

