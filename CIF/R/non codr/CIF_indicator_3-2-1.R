
# CIF 3.2.1 ---------------------------------------------------------------

library(rvest)
library(tidyverse)
library(here)

url <- "https://www.canada.ca/en/health-canada/services/canadian-student-tobacco-alcohol-drugs-survey/2014-2015-supplementary-tables.html#t12"
download.file(url, destfile = "scrapedpage.html", quiet=TRUE)
content <- read_html("scrapedpage.html")

abbreviations <- read_csv("geo_abbreviations.csv")
geocodes <- read_csv("geocodes.csv")

tobacco_use <-
  content %>%
  html_elements("table") %>% 
  .[12] %>%
  html_table() %>%
  .[[1]]

vaping <- 
  tobacco_use %>% 
  janitor::clean_names() %>% 
  select(c(1,3)) %>% 
  slice(-nrow(.)) %>% 
  rename_all(~ c("category", "value")) %>% 
  mutate(
    value = str_remove(value, "\\[.*\\]"),
    value = str_extract(value, "[0-9]*\\.[0-9]*"),
    value = as.numeric(value),
    category = str_remove(category, "Footnote [0-9]"),
    Sex = ifelse(category %in% c("Male", "Female"), category, "Both sexes"),
    Grade = ifelse(str_detect(category, "Grade"), category, "All grades"),
    category = ifelse(
      category == "Canada" | str_detect(category, "[A-Z]{2}"),
      category,
      NA_character_
    ),
    Year = "2014-2015",
    `Type of e-cigarettes` = "Both type"
  ) %>% 
  fill(category) %>% 
  left_join(abbreviations, by = c("category" = "Code")) %>% 
  left_join(geocodes) %>% 
  mutate(Geography = ifelse(is.na(Geography), "Canada", Geography)) %>% 
  select(
    Year, 
    Geography, 
    Sex, 
    Grade, 
    `Type of e-cigarettes`, 
    GeoCode, 
    Value = value
  ) %>% 
  mutate_at(2:5, ~ paste0("data.", .x)) %>% 
  rename_at(2:5, ~ paste0("data.", .x))

write_csv(
  vaping,
  here("CIF", "R", "non codr", "data", "2015_indicator_3-2-1.csv"),
  na = ""
)
