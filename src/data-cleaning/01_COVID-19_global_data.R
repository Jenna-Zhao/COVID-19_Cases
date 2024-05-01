# -----------------------------------------------------------
# Script Name: 01_COVID-19_global_data
# Purpose: This script is used to clean the raw data "COVID-19_global_data"
# help us draw plots more conveniently
# -----------------------------------------------------------

# load package ------------------------------------------------
library(tidyverse)
library(zoo)

# read raw data ------------------------------------------------
df = read.csv("data/raw/COVID-19_global_data.csv")

# new column names ------------------------------------------------
lookup = c(Date = "Date_reported",
           `New Cases` = "New_cases", Cases = "Cumulative_cases",
           `New Deaths` = "New_deaths", Deaths = "Cumulative_deaths")

df_clean = df %>%
  ## change column names
  rename(all_of(lookup)) %>%
  ## change the class of column Date to date type
  mutate(across(Date, ymd))

# Change all negative values to NA
df_clean$`New Cases` = replace(df_clean$`New Cases`,
                               which(df_clean$`New Cases` < 0), NA)
df_clean$`New Deaths` = replace(df_clean$`New Deaths`,
                                which(df_clean$`New Deaths` < 0), NA)

# Replace NA by country
df_clean = df_clean %>%
  group_by(Country) %>%
  ## for `New Cases` and `New Deaths` column
  mutate(across(c(`New Cases`, `New Deaths`), ~ {
    vec = .x
    ## Find the first non-NA index
    first_non_na = which(!is.na(vec))[1]

    ## If entire vector is NA, replace all with 0
    if(is.na(first_non_na)) {
      vec = rep(0, length(vec))
    } else {
      # Replace all leading NAs with 0
      vec[1:(first_non_na - 1)] = 0
      ## Replace remaining NAs with average of last and next value
      vec[first_non_na:length(vec)] = na.approx(vec[first_non_na:length(vec)], na.rm = FALSE)
    }
    # Replace NA at the end with the nearest non-NA values
    if(is.na(vec[length(vec)]))
      vec[length(vec)] = vec[max(which(!is.na(vec)))]
    vec
  })) %>%
  ungroup()

# save csv file ------------------------------------------------
write.csv(df_clean, file = "data/derived/01_COVID-19_global_data.csv")
