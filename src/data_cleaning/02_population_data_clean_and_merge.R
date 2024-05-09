# -----------------------------------------------------------
# Script Name: 02_population_data_clean_and_merge.R
#
# Purpose: This script cleans and merges population data across different years
#          (2020 to 2024) for common countries.
# -----------------------------------------------------------

# load the necessary library
library("dplyr")

# read raw data
population_df1 = read.csv("data/raw/02-population_countries.csv")
population_df2 = read.csv("data/raw/03-population_countries_before_22.csv", header = TRUE)

# prepare population data for the years 2023 and 2024
population_2324 = population_df1 %>%
  # rename 'country' column to 'Country'
  rename(Country = country) %>%
  # select only the relevant columns
  select(Country, pop2023, pop2024) %>%
  # transform the data from wide to long format
  pivot_longer(cols = c(pop2023, pop2024), names_to = "Year", values_to = "pop") %>%
  # convert the 'Year' column to numeric values
  mutate(Year = ifelse(Year == "pop2023", 2023, 2024))

# prepare population data for the years 2020, 2021 and 2022
population_202122 = population_df2 %>%
  # transform the data from wide to long format
  pivot_longer(cols = c(X2020, X2021, X2022), names_to = "Year",
               names_prefix = "X", values_to = "pop") %>%
  # convert the 'Year' from character to numeric
  mutate(Year = as.numeric(Year)) %>%
  # change column names
  rename(Country = Country.Name) %>%
  # select only the relevant columns
  select(Country, Year, pop)

# find common countries
common_countries = intersect(population_202122$Country, population_2324$Country)

# filter both datasets to include only the common countries
df1_202122_common = population_202122 %>%
  filter(Country %in% common_countries) %>%
  # Ensure 'pop' column is numeric
  mutate(pop = as.numeric(pop))

df2_2324_common = population_2324 %>%
  filter(Country %in% common_countries) %>%
  # Ensure 'pop' column is numeric
  mutate(pop = as.numeric(pop))

# bind the rows of the two data frames
combined_df = bind_rows(df1_202122_common, df2_2324_common)

# sort by Country and Year
combined_df = combined_df %>%
  arrange(Country, Year)


# prepare population data for 2024
population_24 = population_df1 %>%
  # select only the relevant columns
  select(country, pop2024)

# save csv file
write.csv(combined_df, file = "data/derived/03_population_by_country.csv")
write.csv(population_24, file = "data/derived/04_population_by_country_24.csv")




