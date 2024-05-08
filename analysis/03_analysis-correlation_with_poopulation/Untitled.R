df = read.csv("data/derived/01_COVID-19_global_data_country.csv")

df$Year <- format(as.Date(df$Date), "%Y")
annual_cases <- df %>%
  group_by(Country, Year) %>%
  summarise(
    Start_Cases = first(Cases),
    End_Cases = last(Cases),
    Total_Case_Change = End_Cases - Start_Cases,
    .groups = 'drop'
  )

data_analysis <- merge(population_2324, annual_cases, by = c("Country", "Year"))

correlation_result <- cor(data_analysis$pop, data_analysis$Total_Case_Change, use = "complete.obs")
print(correlation_result)

ggplot(data_analysis, aes(x = pop, y = Total_Case_Change)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "Correlation between Population and Total Annual Case Change",
       x = "Population",
       y = "Total Annual Case Change")

# Logarithmic transformation example
data_analysis <- data_analysis %>%
  mutate(log_pop = log(pop + 1),  # Adding 1 to avoid log(0)
         log_case_change = log(Total_Case_Change + 1))  # Adding 1 to avoid log(0)

# Recompute correlation
correlation_log <- cor(data_analysis$log_pop, data_analysis$log_case_change, use = "complete.obs")
print(correlation_log)

# New plot with transformations
ggplot(data_analysis, aes(x = log_pop, y = log_case_change)) +
  geom_point() +
  geom_smooth(method = "lm", col = "blue") +
  labs(title = "Correlation with Log Transformations",
       x = "Log of Population",
       y = "Log of Total Annual Case Change")

