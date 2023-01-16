# scratch - add geocodes to cif 3.2.1

library(tidyverse)

data <- read_csv("C:/Users/pellmai/Documents/Open SDG/cif-data-donnees-cic/data/indicator_3-2-1.csv")
geocodes <- read_csv("geocodes.csv") %>% 
  mutate(Geography = paste0("data.", Geography)) %>% 
  rename(data.Geography = Geography)


data <- 
  data %>% 
  left_join(geocodes) %>% 
  relocate(GeoCode, .before = "Value")
  
write_csv(
  data,
  "C:/Users/pellmai/Documents/Open SDG/cif-data-donnees-cic/data/indicator_3-2-1.csv",
  na = ""
)