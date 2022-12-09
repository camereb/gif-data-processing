

#38-10-0032-01

# CIF 11.6.1 --------------------------------------------------------------------

#load libraries 
library(dplyr)
library(tidyr)
library(cansim)
library(readr)



Raw_data <- get_cansim("38-10-0032-01", factors = FALSE)
Raw_data2 <- get_cansim("17-10-0005-01", factors = FALSE)

#load geocode 

geocodes <- read_csv("geocodes.csv")


Population <- 
  Raw_data2 %>% 
  filter(REF_DATE >= 2002,
         Sex == "Both sexes",
         `Age group` == "All ages",
         ) %>% 
  select(Year = REF_DATE,
         Geography = GEO,
         Population = VALUE)


waste <- 
  Raw_data %>% 
  select(Year = REF_DATE,
         Geography = GEO,
         `Sources of waste for disposal`,
         Value1 = VALUE) %>% 
  mutate(Value1 = Value1 * 1016) %>% 
  left_join(Population, by = c("Year", "Geography")) %>% 
  mutate(Value = round((Value1 / Population),1)) %>%  
  left_join(geocodes, by = "Geography") %>% 
  relocate(GeoCode, .before = Value) %>% 
  select(Year,
         Geography,
         `Sources of waste for disposal`,
         GeoCode,
         Value)



#Create the total line 

total <- 
  waste %>% 
  filter(Geography == "Canada",
        `Sources of waste for disposal` == "All sources of waste for disposal") %>% 
  mutate_at(2:(ncol(.)-2), ~ "")


non_total <- 
  waste %>% 
  filter(!(Geography == "Canada" &
             `Sources of waste for disposal` == "All sources of waste for disposal")) %>% 
  mutate_at(2:(ncol(.)-2), ~ paste0("data.", .x))

final_data <- 
  rbind(total, non_total)


names(final_data)[2:(ncol(final_data)-2)] <- 
  paste0("data.", names(final_data)[2:(ncol(final_data)-2)])


write_csv(final_data, "CIF/data/indicator_11-6-1.csv", na = "")














 






















