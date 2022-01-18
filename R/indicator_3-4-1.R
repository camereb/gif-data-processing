
# Indicator 3.4.1 ---------------------------------------------------------
# Mortality rate attributed to cardiovascular disease, cancer, diabetes or chronic respiratory disease

library(cansim)
library(dplyr)
library(stringr)
library(here)
library(readr)

mortality_data <- get_cansim("13-10-0394-01", factors = FALSE)
View(mortality_data)

diseases <- c(
  "Malignant neoplasms [C00-C97]",
  "In situ neoplasms, benign neoplasms and neoplasms of uncertain or unknown behaviour [D00-D48]",
  "Diabetes mellitus [E10-E14]",
  "Diseases of heart [I00-I09, I11, I13, I20-I51]",
  "Influenza and pneumonia [J09-J18]",
  "Acute bronchitis and bronchiolitis [J20-J21]",
  "Chronic lower respiratory diseases [J40-J47]"
)

ages <- c(
  "Age at time of death, 30 to 34 years",
  "Age at time of death, 35 to 44 years",
  "Age at time of death, 45 to 54 years",
  "Age at time of death, 55 to 64 years",
  "Age at time of death, 65 to 74 years",
  "Age at time of death, 75 to 84 years",
  "Age at time of death, 85 and over"
)

names(mortality_data)

# disease_mort_rate
mortality_data %>%
  filter(
    REF_DATE >= 2015,
    UOM == "Percentage",
    Characteristics == "Percentage of deaths",
    `Age at time of death` %in% ages,
    `Leading causes of death (ICD-10)` %in% diseases 
    ) %>%
  mutate(
    GEO = str_remove(GEO, ", place of residence"),
    `Age at time of death` = str_remove(`Age at time of death`, "Age at time of death, "),
    `Leading causes of death (ICD-10)` = str_remove(`Leading causes of death (ICD-10)`, " \\[.*\\]")
  ) %>%
  select(
    Year = REF_DATE, 
    Geography = GEO, 
    `Age at time of death`, 
    Sex, 
    `Causes of death` = `Leading causes of death (ICD-10)`, 
    Value = VALUE
    )

# total_line <- 
#   suicide_mort_rate %>%
#   filter(Geography == "Canada" & Sex == "Both sexes") %>%
#   mutate_at(c("Geography", "Sex"), ~ "")
# 
# data_final <-
#   bind_rows(
#     total_line,
#     suicide_mort_rate
#     # suicide_mort_rate %>%
#     #   filter(!(Geography == "Canada" & Sex == "Both sexes"))
#   ) %>% 
#   filter(!str_starts(Geography, "Unknown"))
# 
# write_csv(data_final, here("gif-data-processing", "data", "indicator_3-4-2.csv"))
