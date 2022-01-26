# Indicator 5.2.1 ---------------------------------------------------------
# Proportion of ever-partnered women and girls aged 15 years and older subjected
# to physical, sexual or psychological violence by a current or former intimate
# partner in the previous 12 months, by form of violence and by age

library(rvest)
library(tidyverse)
library(here)

url <- "https://www150.statcan.gc.ca/n1/pub/85-002-x/2021001/article/00003/tbl/tbl02-eng.htm"
download.file(url, destfile = "scrapedpage.html", quiet=TRUE)
content <- read_html("scrapedpage.html")

ipv <-
  content %>%
  html_elements("table") %>%
  .[1] %>%
  html_table() %>%
  .[[1]]

ipv_past_12mo <- 
  ipv %>%
  janitor::clean_names() %>%
  slice(10:14) %>%
  select(c(1,3)) %>%
  rename_all(function(x) c('Type of Intimate partner violence', 'Value')) %>%
  mutate(Year = 2018) %>%
  relocate(Year)

write_csv(ipv_past_12mo,
          here('gif-data-processing', 'data', 'indicator_5-2-1.csv'))
