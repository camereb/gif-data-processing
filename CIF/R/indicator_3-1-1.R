
#13-10-0096-01

# CIF 3.1.1 ---------------------------------------------------------------

# load libraries
library(dplyr)
library(tidyr)
library(cansim)
library(readr)

# load CODR table from stc api
raw_data <- get_cansim("13-10-0096-01", factors = FALSE)

# load geocode
geocodes <- read_csv("geocodes.csv")


#Format table 

fruits_veg <- 
  raw_data %>%
  filter(Indicators == "Fruit and vegetable consumption, 5 times or more per day", 
         Characteristics == "Percent") %>%
  select(REF_DATE, GEO, `Age group`, Sex, VALUE) %>%
  rename(Year = REF_DATE, Geography = GEO, Value = VALUE) %>%
  left_join(geocodes, by = "Geography") %>%
  relocate(GeoCode, .before = Value)


#Create the aggregate line

total <- 
  fruits_veg %>%
  filter(Geography == "Canada", `Age group` == "Total, 12 years and older", 
         Sex == "Both sexes") %>%
  mutate_at(2:(ncol(.)-2), ~ "") 


#Create the non - aggregate line

fruits_veg <- 
  fruits_veg %>%
  filter(!(Geography == "Canada"& `Age group` == "Total, 12 years and older"&
           Sex == "Both sexes")) %>%
  mutate_at(2:(ncol(.)-2), ~ paste0("data.", .x))


#Add the two rows together 
 final_data <- 
   bind_rows(total, fruits_veg)

names(final_data)[2:(ncol(final_data)-2)] <- paste0("data.", names(final_data)[2:(ncol(final_data)-2)])




  
  