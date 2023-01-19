# CIF 11.2.1 --------------------------------------------------------------------

#load libraries
library(dplyr)
library(cansim)


Raw_data <- get_cansim("46-10-0067-01", factors = FALSE)


# load geocode
geocodes <- read.csv("geocodes.csv")


# Format Table
housing_problems <- c(
  "Living in core housing need",
  "Living in unaffordable housing",
  "Living in unsuitable housing",
  "Living in inadequate housing"
)

core_housing <-
  Raw_data %>%
  filter(
    `Living with housing problems` %in% housing_problems,
    Statistics == "Percentage of households",
  ) %>%
  select(
    Year = REF_DATE,
    `Select housing vulnerable populations` = `Select housing-vulnerable populations`,
    `Living with housing problems`,
    Value = VALUE
  )


# Create total and non-total format
total <-
  core_housing %>%
  filter(
    `Select housing vulnerable populations` == "All households",
    `Living with housing problems` == "Living in core housing need"
  ) %>%
  mutate_at(2:(ncol(.) - 1), ~ "")


non_total <-
  core_housing %>%
  filter(
    !(
      `Select housing vulnerable populations` == "All households" &
        `Living with housing problems` == "Living in core housing need"
    )
  ) %>%
  mutate_at(2:(ncol(.) - 1), ~ paste0("data.", .x))


# Format the final table and write the csv
final_data <-
  bind_rows(total, non_total) %>%
  mutate_at(2:(ncol(.) - 1), ~ paste0("data.", .x))

write.csv(final_data,
          "data/indicator_11-2-1.csv",
          na = "",
          row.names = TRUE)
