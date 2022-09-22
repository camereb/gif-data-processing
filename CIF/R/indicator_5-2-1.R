

#10-10-0137-01, 14-10-0335-01, 37-10-0208-01, 41-10-0048-01

# CIF 5.2.1 ---------------------------------------------------------------

# load libraries
library(dplyr)
library(tidyr)
library(cansim)
library(readr)
library(stringr)

# load CODR table from stc api
Raw_data <- get_cansim("10-10-0137-01", factors = FALSE)
Raw_data2 <- get_cansim("14-10-0335-01", factors = FALSE) 
Raw_data3 < get_cansim("37-10-0208-01", factors = FALSE)
Raw_data4 <- get_cansim("41-10-0048-01", factors = FALSE)




# load geocode
geocodes <- read_csv("geocodes.csv")



#load national parliament and federal cabinet

View(Raw_data)

selected_parl <- c( 
                   "Members of Parliament on July 1, 2002",
                   "Members of Parliament on July 1, 2003",
                   "Members of Parliament on July 1, 2004",
                   "Members of Parliament on July 1, 2005",
                   "Members of Parliament on July 1, 2006",
                   "Members of Parliament on July 1, 2007",
                   "Members of Parliament on July 1, 2008",
                   "Members of Parliament on July 1, 2009",
                   "Members of Parliament on July 1, 2010",
                   "Members of Parliament on July 1, 2011",
                   "Members of Parliament on July 1, 2012",
                   "Members of Parliament on July 1, 2013",
                   "Members of Parliament on July 1, 2014",
                   "Members of Parliament on July 1, 2015",
                   "Members of Parliament on July 1, 2016",
                   "Members of Parliament on July 1, 2017",
                   "Members of Parliament on July 1, 2018",
                   "Members of Parliament on July 1, 2019",
                   "Members of Parliament on July 1, 2020",
                   "Members of Parliament on July 1, 2021")


selected_cab <- c( "Members of Cabinet on July 1, 2002",
                   "Members of Cabinet on July 1, 2003",
                   "Members of Cabinet on July 1, 2004",
                   "Members of Cabinet on July 1, 2005",
                   "Members of Cabinet on July 1, 2006",
                   "Members of Cabinet on July 1, 2007",
                   "Members of Cabinet on July 1, 2008",
                   "Members of Cabinet on July 1, 2009",
                   "Members of Cabinet on July 1, 2010",
                   "Members of Cabinet on July 1, 2011",
                   "Members of Cabinet on July 1, 2012",
                   "Members of Cabinet on July 1, 2013",
                   "Members of Cabinet on July 1, 2014",
                   "Members of Cabinet on July 1, 2015",
                   "Members of Cabinet on July 1, 2016",
                   "Members of Cabinet on July 1, 2017",
                   "Members of Cabinet on July 1, 2018",
                   "Members of Cabinet on July 1, 2019",
                   "Members of Cabinet on July 1, 2020",
                   "Members of Cabinet on July 1, 2021")

cabinet1 <- 
  Raw_data %>% 
  filter(GEO == "Canada",
         `National elected officials` %in% selected_parl, 
         Gender == "Female gender", 
         Statistics == "Proportion") %>% 
  select(`Leadership position` = `National elected officials`, Value = VALUE) %>% 
  mutate(Year = rep(c(2002:2021))) %>% 
  relocate(Year, .before = "Leadership position") %>% 
  mutate(`Leadership position` = substr(`Leadership position`, 1, 21))

cabinet2 <- 
  Raw_data %>% 
  filter(GEO == "Canada",
         `National elected officials` %in% selected_cab, 
         Gender == "Female gender", 
         Statistics == "Proportion") %>% 
  select(`Leadership position` = `National elected officials`, Value = VALUE) %>% 
  mutate(Year = rep(c(2002:2021))) %>% 
  relocate(Year, .before = "Leadership position") %>% 
  mutate(`Leadership position` = substr(`Leadership position`, 1, 18))

cabinet <- 
  bind_rows(cabinet1, cabinet2)






selected_job <- c("Management occupations [0]",
                  "Senior management occupations [00]",
                  "Specialized middle management occupations [01-05]",
                  "Middle management occupations in retail and wholesale trade and customer services [06]",
                  "Middle management occupations in trades, transportation, production and utilities [07-09]")

management <- 
  Raw_data2 %>% 
  filter(REF_DATE >= 2002,
         GEO == "Canada", 
         `Labour force characteristics` == "Proportion of employment",
         Sex == "Females",
         `National Occupational Classification (NOC)` %in% selected_job) %>% 
  select(Year = REF_DATE, 
         `Leadership position` = `National Occupational Classification (NOC)`,
         Value = VALUE) %>% 
  mutate(`Leadership position` = 
           recode(`Leadership position`,
                                        "Management occupations [0]" = "All management occupations",
                                        "Senior management occupations [00]" = "Senior management occupations",
                  "Specialized middle management occupations [01-05]" = "Specialized middle management occupations",
                  "Middle management occupations in retail and wholesale trade and customer services [06]" = "Middle management occupations in retail and wholesale trade and customer services",
                  "Middle management occupations in trades, transportation, production and utilities [07-09]" = "Middle management occupations in trades, transportation, production and utilities"
                  ))

View(management)



#Indigenous occupations  

View(Raw_data4)

Indigenous <- 
  Raw_data4 %>% 
  filter(REF_DATE >= 2002, 
         `First Nation Official` %in% 
           c("Chiefs in First Nation communities", "First Nation council members"),
         Sex == "Female",
         Statistics == "Proportion") %>% 
  select(Year = REF_DATE, 
         `Leadership position` = `First Nation Official`, 
         Value = VALUE)

View(Indigenous)
  
  
  
  
  
  
  
  
  
  