# -----------------------------------------------------------
# Script Name: 01_code-corr_population_COVID.R

# Purpose: This script analyzes the correlation between population and COVID-19 cases across countries.
# It plots population and COVID-19 case data on world maps and calculates the correlation between
# population size and annual changes in COVID-19 cases, using logarithmic transformations for better
# data visualization and interpretation.
# -----------------------------------------------------------

# install packages
library(rworldmap)
library(dplyr)

# load data
df_covid = read.csv("data/derived/01_COVID-19_global_data_country.csv")
df_pop = read.csv("data/derived/03_population_by_country.csv")
df_pop_24 = read.csv("data/derived/04_population_by_country_24.csv")

# change country name to match function
df_pop_24 = df_pop_24 %>%
  mutate(country = ifelse(country == "DR Congo", "Democratic Republic of the Congo", country)) %>%
  mutate(pop2024 = log(pop2024 + 1)) # log transformation, Adding 1 to avoid log(0)

# open a device to plot cases
png("src/analysis/03_analysis-correlation_with_poopulation/01_plot-population_map.png",
    width = 10 * 320, height = 6 * 310,res = 300)
par(mai = c(0, 0, 0.2, 0),xaxs = "i",yaxs = "i") # set margins

# join country data to a map based on country names
worldMap_pop = joinCountryData2Map(df_pop_24, joinCode = "NAME",
                               nameJoinColumn = "country",
                               mapResolution = "li",
                               verbose = TRUE)

# plot the data on the map for population 2024
map_case_pop = mapCountryData(worldMap_pop, nameColumnToPlot = "pop2024",
                          catMethod = "fixedWidth",
                          colourPalette = c("#cbdef0", "#abd0e6", "#82badb",
                                            "#59a1cf", "#3788c0", "#1c6aaf", "#0b4e94"),
                          mapTitle = "Total Popultaion by Country with Log Transformation (2024)",
                          addLegend = "FALSE")

# customize and add a map legend manually
do.call(addMapLegend, c(map_case_pop, legendLabels = "limits",
                        legendShrink = .7,
                        legendMar = 2))
# Close the device
dev.off()

# Prepare COVID-19 data by year
df_covid$Year = format(as.Date(df_covid$Date), "%Y")
annual_cases = df_covid %>%
  group_by(Country, Year) %>%
  summarise(Start_Cases = first(Cases), End_Cases = last(Cases),
            Total_Case_Change = End_Cases - Start_Cases, .groups = 'drop') %>%
  mutate(Total_Case_Change = ifelse(Total_Case_Change < 0, 0, Total_Case_Change)) %>%
  mutate(log_case_change = log(Total_Case_Change + 1))

# Filter data for 2023 and 2024
data_2324 = annual_cases %>%
  filter(Year == 2023 | Year == 2024)

# open a device to plot cases
png("src/analysis/03_analysis-correlation_with_poopulation/02_plot-COVID19_2324.png",
    width = 10 * 320, height = 6 * 310,res = 300)
par(mai = c(0, 0, 0.2, 0),xaxs = "i",yaxs = "i") # set margins

# join country data to a map based on country names
worldMap_case = joinCountryData2Map(data_2324, joinCode = "NAME",
                                    nameJoinColumn = "Country",
                                    mapResolution = "li",
                                    verbose = TRUE)

# plot the data on the map for cases
map_case_pop = mapCountryData(worldMap_case, nameColumnToPlot = "log_case_change",
                                catMethod = "fixedWidth",
                                colourPalette = c("#cbdef0", "#abd0e6", "#82badb",
                                                  "#59a1cf", "#3788c0", "#1c6aaf", "#0b4e94"),
                                mapTitle = "The number of COVID-19 Cases with Log Transformation (2023 - 2024)",
                                addLegend = "FALSE")

# customize and add a map legend manually
do.call(addMapLegend, c(map_case_pop, legendLabels = "limits",
                          legendShrink = .7,
                          legendMar = 2))


# Merge datasets for correlation analysis
data_analysis = merge(df_pop, annual_cases, by = c("Country", "Year"))

# Logarithmic transformation example
data_analysis = data_analysis %>%
  mutate(log_pop = log(pop + 1))  #log transformation

# Calculate and print the correlation between log-transformed population and case change
correlation_log = cor(data_analysis$log_pop, data_analysis$log_case_change,
                      use = "complete.obs")
# print(correlation_log)
# 0.390156

# Create a ggplot to visualize the correlation with log transformations
ggplot(data_analysis, aes(x = log_pop, y = log_case_change)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "Correlation with Log Transformations",
       x = "Log of Population",
       y = "Log of Annual COVID-19 Case") +
  theme_minimal()
ggsave("src/analysis/03_analysis-correlation_with_poopulation/03_plot-correlation.png")
