# -----------------------------------------------------------
# Script Name: 01_code-regional_cumcases_cumdeaths.R

# Purpose: This script is designed to visualize the latest cumulative COVID-19 cases and deaths
# data by country on a geographic map. The maps are saved as PNG files.
# -----------------------------------------------------------

# install packages
library(rworldmap)

# load and prepare data
df = read.csv("data/derived/01_COVID-19_global_data_country.csv")
df$Date = as.Date(df$Date)

# extract data for the most recent date
df_max = df[df$Date == max(df$Date), ]
df_max = df_max %>%
  mutate(logCases = log(Cases + 1), logDeaths = log(Deaths + 1))

# join country data to a map based on country names
worldMap = joinCountryData2Map(df_max, joinCode = "NAME",
                               nameJoinColumn = "Country",
                               mapResolution = "li")

# open a device to plot cases
png("analysis/02_analysis_regional_diff/01_plot-regional_diff_cases.png",
    width = 10 * 320, height = 6 * 310,res = 300)
par(mai = c(0, 0, 0.2, 0),xaxs = "i",yaxs = "i") # set margins

# plot the data on the map for cases
map_case = mapCountryData(worldMap, nameColumnToPlot = "logCases",
                     catMethod = "fixedWidth",
                     colourPalette = c("#cbdef0", "#abd0e6", "#82badb",
                                       "#59a1cf", "#3788c0", "#1c6aaf", "#0b4e94"),
                     mapTitle = "The number of COVID-19 Cases by April 7, 2024 (Log transformed)",
                     addLegend = "FALSE")

# customize and add a map legend manually
do.call(addMapLegend, c(map_case, legendLabels = "limits",
                        legendShrink = .7,
                        legendMar = 2))
# Close the device
dev.off()

# open a device to plot deaths
png("analysis/02_analysis_regional_diff/02_plot-regional_diff_deaths.png",
    width = 10 * 320, height = 6 * 310,res = 300)
par(mai = c(0, 0, 0.2, 0),xaxs = "i",yaxs = "i") # set margins

# Plot the data on the map for deaths
map_case = mapCountryData(worldMap, nameColumnToPlot = "logDeaths",
                          catMethod = "fixedWidth",
                          colourPalette = c("#cbdef0", "#abd0e6", "#82badb",
                                            "#59a1cf", "#3788c0", "#1c6aaf", "#0b4e94"),
                          mapTitle = "The number of COVID-19 Deaths by April 7, 2024 (Log transformed)",
                          addLegend = "FALSE")

# customize and add a map legend manually
do.call(addMapLegend, c(map_case, legendLabels = "limits",
                        legendShrink = .7,
                        digits = 3,
                        legendMar = 2))
# Close the device
dev.off()

