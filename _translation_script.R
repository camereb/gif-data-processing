# Translations -------------------------

library(cansim)
library(dplyr)
library(stringr)
library(readr)

en <- get_cansim("27-10-0273-01", factors = FALSE, language = "en")
fr <- get_cansim("27-10-0273-01", factors = FALSE, language = "fr")

dfs <- list(en, fr)

names(en)

filtering_dfs <- function(df) {
  
  en %>%
    select(c(6, 26)) %>%
    distinct() %>%
    # filter_at(c(2), ~ str_starts(.x, "1.2.3.34")) %>%
    # mutate_at(c(1), ~ str_remove(.x, " \\[.*\\]")) %>%
    rename_at(c(2), ~ "key")
    
  
}

disagg_names <- purrr::map(dfs, filtering_dfs)

disagg_names[[1]] %>% colnames()

translation <- 
  left_join(disagg_names[[1]], disagg_names[[2]]) %>%
  select(-key) %>%
  rename_at(c(1,2), ~ c("var1", "var2")) %>%
  transmute(
    Translation = paste0(var1, ": ", var2)
  ) %>%
  pull()

write_lines(translation, "translation.txt")            
