library("rvest")
library(tidyverse)
library(here)

url <- "https://www.canada.ca/en/health-canada/services/canadian-tobacco-nicotine-survey/2019-summary/2019-detailed-tables.html#t5"
download.file(url, destfile = "scrapedpage.html", quiet=TRUE)
content <- read_html("scrapedpage.html")

tobacco_use <-
  content %>%
  html_elements("table") %>%
  .[5] %>%
  html_table() %>%
  .[[1]]

cleaned_tobacco_use <- 
  tobacco_use %>%
  janitor::clean_names() %>% 
  slice(-1) %>%
  rename_all(~ str_remove_all(.x, "footnote_")) %>%
  rename_all(~ str_remove_all(.x, "_percent")) %>%
  rename_all(~ str_remove_all(.x, "_[0-9]")) %>%
  #rename_all(~ str_remove_all(.x, "_table")) %>%
  #slice(-nrow(.)) %>%
  mutate_all(~ str_remove_all(.x, "\\[.*\\]")) %>% 
  mutate_all(~ str_remove_all(.x, "Footnote")) %>% 
  mutate_all(trimws) %>%
  mutate(across(any_tobacco_product:vaping, ~ str_extract(.x, "[0-9]*\\.*[0-9]*") )) %>%
  mutate(across(any_tobacco_product:vaping, as.numeric)) %>%
  mutate(across(gender:age_group_years, ~ str_remove_all(.x, "\\r\\r\\n"))) %>%
  mutate(across(gender:age_group_years, ~ str_remove_all(.x, "     ")))

final_tobacco_use <- 
  cleaned_tobacco_use %>%
  pivot_longer(
    cols = any_tobacco_product:vaping,
    names_to = "Tobacco Product",
    values_to = "Value",
    values_drop_na = TRUE
  ) %>%
  mutate(
    `Tobacco Product` = str_replace_all(`Tobacco Product`, "_", " "),
    `Tobacco Product` = str_to_sentence(`Tobacco Product`),
    `Tobacco Product` = ifelse(`Tobacco Product` == "E cigarettes", "E-cigarettes", `Tobacco Product`),
    Year = 2019
  ) %>%
  rename(
    Sex = gender,
    `Age Group` = age_group_years
  ) %>%
  relocate(Year)

write_csv(final_tobacco_use, here("gif-data-processing", "data", "2019_indicator_3-a-1.csv"))
