# CIF update 12.1.1 -------------------------------------------------------

library(tidyverse)

vehicle_data <- read_csv("cif raw data/new-vehicle-registrations.csv")
View(vehicle_data)

new_data <- 
  vehicle_data %>%
  select(REF_DATE, GEO, `Fuel type`, VALUE) %>% 
  rename(Year = REF_DATE, Geography = GEO, Value = VALUE) %>%
  mutate(
    `Fuel type` = ifelse(`Fuel type` == "All fuel types", `Fuel type`, "Electric")
  ) %>% 
  group_by(Year, Geography, `Fuel type`) %>% 
  summarise(Value = sum(Value, na.rm = TRUE)) %>% 
  pivot_wider(names_from = `Fuel type`, values_from = Value) %>% 
  mutate(Value = round((Electric / `All fuel types`) * 100)) %>% 
  filter(!is.na(Value)) %>% 
  select(Year, Geography, Value) %>% 
  mutate(Geography = paste0("data.", Geography))

write_csv(new_data, "Various CIF Updates/indicator_12-1-1.csv")
