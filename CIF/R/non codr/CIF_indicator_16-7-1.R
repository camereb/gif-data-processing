# load libraries
library(rvest)
library(tidyverse)
library(here)

url <- "https://www150.statcan.gc.ca/n1/pub/85-002-x/2022001/article/00003/tbl/tbl01-eng.htm"
download.file(url, destfile = "scrapedpage.html", quiet=TRUE)
content <- read_html("scrapedpage.html")

inst_confidence <-
  content %>%
  html_elements("table") %>%
  .[1] %>%
  html_table() %>%
  .[[1]] %>% 
  janitor::clean_names() %>% 
  select(c(1, 2, 5, 8, 11))

View(inst_confidence)

names(inst_confidence) <- c("confidence_in_institutions", "Black", "Indigenous", "Other_VM", "White")

tidy_inst_confidence <- 
  inst_confidence %>% 
  slice(-c(1:3)) %>% 
  mutate_all(str_remove, "Table") %>% 
  mutate_all(str_remove, "Note") %>% 
  mutate_all(str_remove, "\\*") %>% 
  mutate_all(str_trim) %>% 
  mutate(confidence_in_institutions = str_remove_all(confidence_in_institutions, "[0-9]")) %>% 
  mutate(
    confidence_level = ifelse(str_detect(confidence_in_institutions, "[Cc]onfident"), confidence_in_institutions, NA),
    confidence_in_institutions = ifelse(str_detect(confidence_in_institutions, "[Cc]onfident"), NA, confidence_in_institutions)
  ) %>% 
  fill(confidence_in_institutions) %>% 
  filter(!is.na(confidence_level)) %>% 
  mutate_at(2:5, as.numeric) %>% 
  rename(
     `First Nations, Métis, or Inuit` = Indigenous,
     `Other group designated as visible minority` = Other_VM,
     `Non-Indigenous, non-visible minority` = White
  ) %>%
  pivot_longer(
    cols = 2:5,
    names_to = "data.Characteristics",
    values_to = "Value"
  ) %>% 
  relocate(data.Characteristics, .before = confidence_level) %>% 
  mutate(Year = 2020) %>% 
  relocate(Year) %>% 
  mutate_at(2:4, ~ paste0("data.", .x)) %>% 
  rename(
    data.Institution = confidence_in_institutions,
    `data.Level of confidence` = confidence_level
  )

write.csv(tidy_inst_confidence, "CIF_indicator_16-7-1.csv", row.names = F, fileEncoding = "UTF-8") 
