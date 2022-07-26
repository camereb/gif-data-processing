library(tidyverse)

opioid_data <- read_csv("cif raw data/SubstanceHarmsData.csv")

events <- c(
  "Total apparent opioid toxicity deaths",
  "Total opioid-related poisoning hospitalizations",
  "EMS responses to suspected opioid-related overdoses",
  "Total apparent stimulant toxicity deaths",
  "Total stimulant-related poisoning hospitalizations"
)

sdg_opioid_data <- 
  opioid_data %>% 
    filter(
      Specific_Measure == "Overall numbers",
      Type_Event %in% events,
      Time_Period == "By year",
      Year_Quarter != "2021 (Jan to Sep)",
      Unit %in% c("Crude rate", "Number")
    ) %>% 
    select(
      Year = Year_Quarter,
      Units = Unit,
      Geography = Region,
      `Type of event` =  Type_Event,
      Value
    ) %>% 
    mutate(
      Units = ifelse(Units == "Crude rate", "Rate per 100,000 population", Units),
      `Type of event` = str_remove(`Type of event`, "Total "),
      `Type of event` = ifelse(str_detect(`Type of event`, "EMS"), `Type of event`, str_to_sentence(`Type of event`))
    ) %>% 
    mutate_at(2:4, ~ paste0("data.", .x))

write_csv(sdg_opioid_data, "Various CIF Updates/CIF_indicator_3-12-1.csv")
