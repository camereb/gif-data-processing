library(cansim)
library(dplyr)
library(stringr)
library(readr)

env_protection <- get_cansim("38-10-0132-01", factors = FALSE)
env_management <- get_cansim("38-10-0137-01", factors = FALSE)

activities <- c(
  "Wastewater management",
  "Air pollution management",
  "Protection and remediation of soil, groundwater and surface water",
  "Protection of biodiversity and habitat",
  "Noise and vibration abatement",
  "Total, environmental protection activities",
  "Sold carbon offset credits only or sold more than purchased"
)

env_data <- function(data) {
  
  data %>% 
    select(
      Year = REF_DATE,
      Industries,
      `Environmental protection activities or management practices` = starts_with("Env"),
      Value = VALUE
    ) %>% 
    filter(`Environmental protection activities or management practices` %in% activities) %>% 
    mutate(
      Industries = str_trim(str_remove(Industries, "\\[\\w*\\]"))
    )
  
}

data_final <-
  bind_rows(
    env_data(env_protection),
    env_data(env_management)
  )

total_line <- 
  data_final %>% 
  filter(
    Industries == "Total, industries",
    `Environmental protection activities or management practices` == "Total, environmental protection activities"
  ) %>% 
  mutate_at(2:3, ~ "")

data_final <- 
  bind_rows(
    total_line,
    data_final %>% 
    filter(
     !( Industries == "Total, industries" &
      `Environmental protection activities or management practices` == "Total, environmental protection activities"
      )
    ) %>% 
    mutate_at(2:3, ~ paste0("data.", .x))
  ) %>% 
  rename_at(2:3, ~ paste0("data.", .x))

write_csv(data_final, "indicator_12-2-1.csv", na = "")
