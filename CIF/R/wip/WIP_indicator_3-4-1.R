
#13-10-0096-01

# CIF 3.1.1 ---------------------------------------------------------------

# load libraries
library(dplyr)
library(tidyr)
library(cansim)
library(readr)

# load CODR table from stc api
Raw_data <- get_cansim("13-10-0096-01", factors = FALSE)

# load geocode
geocodes <- read_csv("geocodes.csv")


#Format Table

alcohol_use <- 
  Raw_data %>%
  filter(Characteristics == "Percent", Indicators == "Heavy drinking") %>%
  select(REF_DATE, GEO, `Age group`, Sex, VALUE) %>%
  rename(Year = REF_DATE, Geography = GEO, Value = VALUE) %>%
  left_join(geocodes, by = "Geography") %>%
  relocate(GeoCode, .before = Value)

View(alcohol_use)


#create the aggregate line 

total <- 
  alcohol_use %>%
  filter(Geography == "Canada (excluding territories)", `Age group` == "Total, 12 years and over",
         Sex == "Both sexes") %>%
  mutate_at(2:(ncol(.)-2), ~ "") 


#create the non-aggregate line 

non_total_line <- 
  alcohol_use %>%
  filter(!(Geography == "Canada (excluding territories)" & `Age group` == "Total, 12 years and over" &
            Sex == "Both sexes")) %>%
  mutate_at(2:(ncol(.)-2), ~ paste0("data.", .x))

final_data <- 
  bind_rows(total, non_total_line)

names(final_data)[2:(ncol(final_data)-2)] <- paste0("data.",names(final_data)[2:(ncol(final_data)-2)])










