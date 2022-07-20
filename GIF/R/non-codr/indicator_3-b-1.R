# load libraries
library(rvest)
library(tidyverse)
library(here)

url <- "https://www.canada.ca/en/public-health/services/publications/vaccines-immunization/2019-highlights-childhood-national-immunization-coverage-survey.html"
download.file(url, destfile = "scrapedpage.html", quiet=TRUE)
content <- read_html("scrapedpage.html")

vaccine_coverage <-
  content %>%
  html_elements("tbody") %>%
  .[1] %>%
  html_table() %>%
  .[[1]]

names(vaccine_coverage) <- c("Antigen", "2013", "2015", "2017", "2019")

data_final <-
  vaccine_coverage %>%
  mutate(Antigen = str_remove(Antigen, "Figure 1 Table 1 footnote \\**")) %>%
  mutate_at(vars(`2013`:`2015`), as.numeric) %>%
  pivot_longer(
    cols = c("2013", "2015", "2017", "2019"),
    names_to = "Year",
    values_to = "Value"
  ) %>%
  relocate(Year)

write_csv(data_final, here("gif-data-processing", "data", "indicator_3-b-1.csv"))

url2 <- "https://www.canada.ca/fr/sante-publique/services/publications/vaccins-immunisation/2019-faits-saillants-enquete-nationale-couverture-vaccinale-enfants.html"
download.file(url2, destfile = "scrapedpage.html", quiet=TRUE)
content2 <- read_html("scrapedpage.html")

vaccine_coverage_fr <-
  content2 %>%
  html_elements("tbody") %>%
  .[1] %>%
  html_table() %>%
  .[[1]]

names(vaccine_coverage_fr) <- c("Antigen", "2013", "2015", "2017", "2019")

data_final_fr <- 
  vaccine_coverage_fr %>%
  distinct(Antigen) %>%
  mutate(Antigen_fr = str_remove(Antigen, "Retour à la référence de la Note de bas de page figure 1 tableau 1 - \\**")) %>%
  select(-Antigen)

distinct(data_final, Antigen) %>%
  bind_cols(distinct(data_final_fr, Antigen_fr)) %>%
  transmute(transl = paste0(Antigen, ": ", Antigen_fr)) %>%
  pull(transl) %>%
  write_lines("temp_translation.txt")
