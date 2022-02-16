# Translations -------------------------

library(cansim)
library(dplyr)
library(stringr)
library(readr)

employment_en <- get_cansim("14-10-0202-01", factors = FALSE, language = "en")
employment_fr <- get_cansim("14-10-0202-01", factors = FALSE, language = "fr")

employment_dfs <- list(employment_en, employment_fr)

names(employment_en)

filtering_dfs <- function(df) {
  
  df %>%
    select(c(5, 22)) %>%
    distinct() %>%
    filter_at(c(2), ~ str_starts(.x, "1.2.3.34")) %>%
    mutate_at(c(1), ~ str_remove(.x, " \\[.*\\]")) %>%
    rename_at(c(2), ~ "key")
  
}

disagg_names <- purrr::map(employment_dfs, filtering_dfs)

translation <- 
  left_join(disagg_names[[1]], disagg_names[[2]]) %>%
  select(-key) %>%
  rename_at(c(1,2), ~ c("var1", "var2")) %>%
  transmute(
    Translation = paste0(var1, ": ", var2)
  ) %>%
  pull()

write_lines(translation, "translation.txt")            
