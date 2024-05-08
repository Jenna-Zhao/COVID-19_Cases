# -----------------------------------------------------------
# Script Name: 01_code-world_new_cases_deaths
#
# Purpose: This script analyzes and visualizes the trends of new COVID-19
# cases and deaths worldwide. The line plots are saved as PNG files.
# -----------------------------------------------------------

# install packages
library(ggplot2)

# read data
df_world = read.csv("data/derived/02_COVID-19_global_data_world.csv")

# Ensure 'Date' column is in Date format
df_world$Date = as.Date(df_world$Date)

# plot new cases
new_cases = ggplot(df_world, aes(x = Date, y = New_cases)) +
  geom_line(color = "#3D89C3", linewidth = 1.5) +
  labs(title = "The number of COVID-19 New Cases Over Time",
    x = "Date",
    y = "New Cases") +
  theme_minimal() +
  ## adjust gap between axis title and axis and title position
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0, unit = "pt")),
        axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")),
        plot.title = element_text(margin = margin(t = 5, r = 0, b = 10, l = 0, unit = "pt"),
                                  hjust = -3))

# plot new deaths
new_deaths = ggplot(df_world, aes(x = Date, y = New_deaths)) +
  geom_line(color = "#3D89C3", linewidth = 1.5) +
  labs(title = "The number of COVID-19 New Deaths Over Time",
       x = "Date",
       y = "New Deaths") +
  theme_minimal() +
  ## adjust gap between axis title and axis and title position
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0, unit = "pt")),
        axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")),
        plot.title = element_text(margin = margin(t = 5, r = 0, b = 10, l = 0, unit = "pt"),
                                  hjust = -3))

# save plot cases and deaths
ggsave("analysis/01_analysis_world/01_plot-world_new_cases.png", new_cases)
ggsave("analysis/01_analysis_world/02_plot-world_new_deaths.png", new_deaths)
