

#38-10-0250-01

# CIF 6.3.1 ---------------------------------------------------------------

# load libraries
library(dplyr)
library(tidyr)
library(cansim)
library(readr)


# load CODR table from stc api
Raw_data <- get_cansim("38-10-0250-01", factors = FALSE)




# load geocode
geocodes <- read_csv("geocodes.csv")

View(Raw_data)


selected_sector <- c("Accommodation and food services [BS72000]",
                     "Administrative and support services [BS56100]",
                     "Waste management and remediation services [BS56200]", 
                     "")




















growth_rate <- 
  Raw_data %>% 
  










