library(tidyverse)

energy <- read_csv("gif-data-processing/raw data/energyuse.csv")
population <- read_csv("gif-data-processing/raw data/population.csv")

population <- population %>% 
  select(
    Year = REF_DATE,
    Geography = GEO,
    Value = VALUE
  )

terajoules <- 
  energy %>% 
  select(c(1, 2, 4, 5), VALUE) %>% 
  mutate(Units = "Terajoules") %>% 
  select(
    Year = REF_DATE,
    Units,
    Geography = GEO,
    `Fuel type`,
    `Demand characteristics` = `Supply and demand characteristics`,
    Value = VALUE
  )

per_capita <- 
  terajoules %>% 
  mutate(Units = "Per capita") %>% 
  left_join(population, by = c("Year", "Geography")) %>% 
  mutate(Value = Value.x/Value.y, .keep = "unused")

data <- bind_rows(terajoules, per_capita)
  

# Missing: 
# - hydroelectricity, 
# - nuclear
# - agriculture
# Including (not needed): 
# - Primary electricity, hydro and nuclear
# - Agriculture, fishing, hunting and trapping
# - Statistical diff
data %>% 
  mutate_at(2:5, ~ paste0("data.", .x)) %>% 
  write_csv("CIF_indicator_7-2-1.csv", na = "")
