
# 11.5.1 ------------------------------------------------------------------

library(cansim)
library(tidyverse)

commuting_data <- get_cansim("23-10-0286-01")
geocodes <- read_csv("gif-data-processing/geocodes.csv")

stats <- c(
  "Count of commuters", 
  "Car, truck or van - 2 or more persons in vehicule - count of commuters",
  "Public transit - count of commuters", 
  "Active transport - count of commuters"
  )

names(commuting_data)

included_geographies <- 
  commuting_data %>% 
  select(GEO, `Hierarchy for GEO`) %>% 
  distinct() %>% 
  mutate(hier_count = str_count(`Hierarchy for GEO`, "\\.")) %>% 
  filter(
    hier_count <= 1,
    !str_detect(GEO, "Census subdivisions in a census agglomeration"),
    !str_detect(GEO, "Area outside census metropolitan areas and census agglomeration")
    ) %>% 
  pull(GEO)

commuting_data %>% 
  select(
    Year = REF_DATE,
    Geography = GEO,
    Characteristics = `Demographic, geodemographic and commuting`,
    Value = VALUE
  ) %>%
  filter(
    Characteristics %in% stats,
    Geography %in% included_geographies
    ) %>% 
  mutate(Characteristics = ifelse(Characteristics == "Count of commuters", "Total", "Shared_Active")) %>% 
  group_by(Year, Geography, Characteristics) %>% 
  summarise(Value = sum(Value)) %>% 
  pivot_wider(
    names_from = "Characteristics",
    values_from = "Value"
  ) %>% 
  transmute(Value = Shared_Active/Total)

