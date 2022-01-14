
# Indicator 5.5.2 ---------------------------------------------------------

# 14-10-0335-01

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)


repr_in_mgmt <- get_cansim("14-10-0335-01", factors = FALSE)

clean_repr_in_mgmt <- 
  repr_in_mgmt %>% 
  #janitor::clean_names() %>% names()
  #distinct(`Labour force characteristics`)
  filter(
    REF_DATE >= 2015,
    `Labour force characteristics` == "Proportion of employment",
    Sex == "Females",
    str_starts(`Hierarchy for National Occupational Classification (NOC)`, "1\\.2\\.") | `Hierarchy for National Occupational Classification (NOC)` == "1.2"
  ) %>%
  select(
    Year = REF_DATE,
    Geography = GEO,
    Occupation = `National Occupational Classification (NOC)`,
    #Occ_Classif = `Hierarchy for National Occupational Classification (NOC)`,
    Value = VALUE
  ) %>%
  mutate(
    Occupation = str_trim(str_remove(Occupation, "\\[.*\\]"))
  )

total_line <- 
  clean_repr_in_mgmt %>%
  filter(
    Geography == "Canada",
    Occupation == "Management occupations"
  ) %>%
  mutate_at(c("Geography", "Occupation"), ~ "")

data_final <- 
  bind_rows(
    total_line,
    clean_repr_in_mgmt %>%
      filter(!(Geography == "Canada" & Occupation == "Management occupations"))
  )

write_csv(data_final, here("gif-data-processing", "data", "indicator_5-5-2.csv"), na = "")
