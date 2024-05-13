# ------------------------------------------------------------------------------
# Script Name: 01_COVID-19_global_data_clean
#
# Purpose: This script is used to clean the raw data "COVID-19_global_data"
# help us draw plots more conveniently
# ------------------------------------------------------------------------------

# Load package -----------------------------------------------------------------
library(tidyverse)
library(zoo)

# Read raw data ----------------------------------------------------------------
df = read.csv("data/raw/01-COVID-19_global_data.csv")

# Data Type Conversion ---------------------------------------------------------
# New column names
lookup = c(Date = "Date_reported",
           Cases = "Cumulative_cases",
           Deaths = "Cumulative_deaths")
# Cleaned data sets
df_clean = df %>%
  ## change column names
  rename(all_of(lookup)) %>%
  ## change the class of column Date to date type
  mutate(across(Date, ymd)) %>%
  ## replacing "" with "OTHER"
  mutate(WHO_region = ifelse(WHO_region %in% "", "OTHER", WHO_region))

# Replacing Values -------------------------------------------------------------
# Change all negative values to NA for New_cases and New_deaths columns
df_clean$New_cases = replace(df_clean$New_cases,
                               which(df_clean$New_cases < 0), NA)
df_clean$New_deaths = replace(df_clean$New_deaths,
                                which(df_clean$New_deaths < 0), NA)

# Handling Retrospective Corrections and Handling NA Values --------------------
df_clean = df_clean %>%
  ## Group by country
  group_by(Country) %>%
  ## for New_cases and New_deaths column
  mutate(across(c(New_cases, New_deaths), ~ {
    vec = .x
    # Determine the first and last non-NA indices
    first_non_na = which(!is.na(vec))[1]
    last_non_na = which(!is.na(vec))[length(which(!is.na(vec)))]

    # If entire vector is NA, replace all with 0
    if(is.na(first_non_na)) {
      vec = rep(0, length(vec))
    } else {

      # Replace all leading NAs with 0
      vec[1:(first_non_na - 1)] = 0

      # Replece NAs between the first and last non-NA values
      if (!is.na(last_non_na) && last_non_na > first_non_na) {
        vec[first_non_na:last_non_na] = na.approx(vec[first_non_na:last_non_na],
                                                  na.rm = FALSE)
      }

      # Replace all trailing NAs with 0
      if (!is.na(last_non_na) && last_non_na < length(vec)) {
        vec[(last_non_na + 1):length(vec)] = 0
      } }
    ## Return results
    vec
  })) %>%
  ungroup()

# Matching country name --------------------------------------------------------
df_clean = df_clean %>%
  mutate(Country = ifelse(Country == "Türkiye", "Turkey", Country)) %>%
  mutate(Country = ifelse(Country == "Côte d'Ivoire", "Ivory Coast", Country))

# save csv file ----------------------------------------------------------------
write.csv(df_clean, file = "data/derived/01_COVID-19_global_data_country.csv")
# ------------------------------------------------------------------------------

# Generate total dataset
df_world = df_clean %>%
  ## Group by date
  group_by(Date) %>%
  ## Fill in values
  summarise(
    Country = "Total",
    Country_code = "T",
    WHO_region = "World",
    New_cases = sum(New_cases, na.rm = TRUE),
    Cases = sum(Cases, na.rm = TRUE),
    New_deaths = sum(New_deaths, na.rm = TRUE),
    Deaths = sum(Deaths, na.rm = TRUE)) %>%
  ungroup() %>%
  ## change the class of column Date to date type
  mutate(across(Date, ymd))

# save csv file ----------------------------------------------------------------
write.csv(df_world, file = "data/derived/02_COVID-19_global_data_world.csv")
# ------------------------------------------------------------------------------

