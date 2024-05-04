# -----------------------------------------------------------
# Script Name: app.R
# Purpose: This script is used to ....
# -----------------------------------------------------------

# load package ------------------------------------------------
library(shiny) # for shiny
library(shinythemes)
library(dplyr) # for data chosen
library(rworldmap) # drawing map
library(ggplot2) # drawing line plots

# read data
df = read.csv("../../data/derived/01_COVID-19_global_data_country.csv")
df_world = read.csv("../../data/derived/02_COVID-19_global_data_world.csv")

# confirm Date Formatting in Data Frames
df$Date = as.Date(df$Date)
df_world$Date = as.Date(df_world$Date)

# find first and last date in dataframe
date_min = min(df$Date)
date_max = max(df$Date)

country_list = function(region){
  # find country name for each region
  unique_countries = unique(df$Country[df$WHO_region == region])

  # Create a list of lists, each containing one country name
  country_lists = lapply(unique_countries, function(country) c(country))

  # Print the lists to see the output
  print(country_lists)
}

ui = fluidPage(
  titlePanel("COVID-19 Dashboard"),

  tags$head(
    tags$style(HTML("
                    .panel-background {
                      background-color: #f7f7f7; /* light grey background */
                      border-radius: 5px; /* rounded corners */
                      padding: 10px; /* padding inside the panel */
                      margin-bottom: 5px; /* gap between panels */
                    }
                    .section-title {
                      font-size: 24px; /* Main title size */
                      font-weight: bold; /* Bold font */
                      margin-bottom: 10px; /* space below the title */
                    }
                    .sub-title {
                      font-size: 20px; /* subtitle size */
                      font-weight: bold; /* Bold font */
                      margin-bottom: 10px; /* space below the title */
                    }
                    .vertical-space {
                      margin-top: 40px; /* vertical space element */
                    }
                    .large-font {
                      font-size: 17px; /* larger font size for titles */
                      margin-top: 20px; /* additional space above the title */
                      margin-bottom: 10px; /* space below the title */
                      font-weight: bold; /* make the text bold */
                    }
                    .white-background {
                      background-color: #ffffff; /* white background */
                      padding: 10px; /* padding inside the white background */
                      border-radius: 5px; /* rounded corners for the white background */
                      margin-bottom: 5px; /* space below the white background */
                    }
                    label[for='countryInput2'] {
                      display: block;
                      margin-bottom: 30px; /* Increase space below the label */
                    }
                    .selectize-control .selectize-input {
                      margin-top: 5px; /* Adjust the top margin to create space */
                    }
                    "))
  ),

  navbarPage("COVID-19 Cases",
             theme = shinytheme("readable"),

             tabPanel("Cumulative Data",
                      div(class = "section-title",
                          h3("Number of COVID-19 Cases or Deaths")),
                      div(class = "panel-background",
                          fluidRow(
                            column(width = 3,
                                   div(class = "vertical-space"),
                                   ## choose Date
                                   sliderInput("slider1", "Date",
                                               min = as.Date(date_min, "%Y-%m-%d"),
                                               max = as.Date(date_max, "%Y-%m-%d"),
                                               value = as.Date(date_max),
                                               timeFormat = "%Y-%m-%d",
                                               step = 7
                                   ),
                                   div(class = "vertical-space"),
                                   ## Choose case or death
                                   selectInput("dataChoice", "Type:",
                                               choices = c("Cases" = "Cases", "Deaths" = "Deaths")),
                                   div(class = "vertical-space", style = "height: 40px;"),
                                   div(class = "white-background",
                                       htmlOutput("dynamicTitle"),
                                       selectizeInput("countryInput",
                                                      "Choose a Country:",
                                                      list(
                                                        `Eastern Mediterranean` = country_list("EMRO"),
                                                        `Europe` = country_list("EURO"),
                                                        `Africa` = country_list("AFRO"),
                                                        `Western Pacific` = country_list("WPRO"),
                                                        `Americas` = country_list("AMRO"),
                                                        `South-East Asia` = country_list("SEARO"),
                                                        `Others` = c(country_list("OTHER"), country_list(""))),
                                                      options = list(selectize = FALSE)),
                                       uiOutput("countryData"))),
                            column(width = 9,
                                   plotOutput(outputId = "worldMap",
                                              height = "600px"))))),

             tabPanel("Daily Data",
                      div(class = "section-title",
                          h3("Number of COVID-19 New Cases or Deaths")),
                      div(class = "panel-background",
                          fluidRow(
                            column(width = 5,
                                   sliderInput("slider2", "Date",
                                               min = as.Date(date_min, "%Y-%m-%d"),
                                               max = as.Date(date_max, "%Y-%m-%d"),
                                               value = c(as.Date(date_min), as.Date(date_max)),
                                               timeFormat = "%Y-%m-%d",
                                               step = 7,
                                               width = "70%"
                                   )),
                            column(width = 1),
                            column(width = 3,
                                   selectizeInput("countryInput2",
                                                  "Country:",
                                                  list(
                                                    "Total",
                                                    `Eastern Mediterranean` = country_list("EMRO"),
                                                    `Europe` = country_list("EURO"),
                                                    `Africa` = country_list("AFRO"),
                                                    `Western Pacific` = country_list("WPRO"),
                                                    `Americas` = country_list("AMRO"),
                                                    `South-East Asia` = country_list("SEARO"),
                                                    `Others` = c(country_list("OTHER"), country_list(""))),
                                                  options = list(selectize = FALSE))),
                            column(width = 3)
                            ),
                          fluidRow(
                            column(width = 6,
                                   div(class = "sub-title", "COVID-19 New Cases Over Time"),
                                   plotOutput("plotNewCases")),
                            column(width = 6,
                                   div(class = "sub-title", "COVID-19 New Deaths Over Time"),
                                   plotOutput("plotNewDeaths"))
                          )
                          )),
             tabPanel("About")
  ))


server = function(input, output, session) {

  # Filter data based on the selected date and data type
  filteredData = reactive({
    df[df$Date == as.Date(input$slider1), ]
  })

  # Generate a world map with cases or deaths by country for the selected date
  output$worldMap = renderPlot({
    data = filteredData()
    ## No available data
    if (nrow(data) == 0) {
      plot.new()
      title("No data available for this date.")
      return()
    }
    ## Draw data in the world map
    worldMap = joinCountryData2Map(data, joinCode = "NAME",
                                   nameJoinColumn = "Country",
                                   mapResolution = "li")
    ## Create the map
    map = mapCountryData(worldMap, nameColumnToPlot = input$dataChoice,
                         catMethod = "fixedWidth",
                         colourPalette = c("#98DAFF", "#7BBFFC",
                                           "#3D89C3", "#00588D"),
                         mapTitle = "",
                         addLegend = FALSE)

    # Customize and add a map legend manually
    do.call(addMapLegend, c(map, legendLabels = "none",
                            digits = 1,
                            legendShrink = .7,
                            legendIntervals = "data",
                            legendMar = 2,
                            horizontal = FALSE))

    print(map)
  })

  output$dynamicTitle = renderUI({
    HTML(paste("<div class='large-font'>Number of", input$dataChoice, "for a Country</div>"))
  })

  output$countryData = renderUI({
    data = filteredData()
    if (nrow(data) == 0) {
      "No data available on selected date."
    }
    data = data[data$Country == input$countryInput, ]
    if (nrow(data) == 0) {
      "No data available for this country on selected date."
    } else {
      output_num = data[[input$dataChoice]]
      output_num = format(output_num, big.mark = ",", scientific = FALSE)
      HTML(paste("The number of", input$dataChoice, "on",
                 format(input$slider1, "%Y-%m-%d"), "is",
                 tags$b(output_num), '<br><div style="margin-bottom:10px;"></div>'))
    }
  })

  # Calculate the filtered data based on user selections
  reactiveFilteredData = reactive({
    if (input$countryInput2 == "Total") {
      subset(df_world, Date >= input$slider2[1] & Date <= input$slider2[2])
    } else {
      subset(df, Country == input$countryInput2 & Date >= input$slider2[1] & Date <= input$slider2[2])
    }
  })

  # Generate the plot for new cases
  output$plotNewCases = renderPlot({
    data = reactiveFilteredData()

    ## plot the line plots for new_cases
    ggplot(data, aes(x = Date, y = New_cases)) +
      geom_line(color = "#3D89C3") +
      labs(x = "Date",
           y = "New Cases") +
      coord_cartesian(ylim = input$yAxisRangeCases) +
      theme_minimal() +
      theme(axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0, unit = "pt")),
            axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")))
  })

  # Generate the plot for new deaths
  output$plotNewDeaths = renderPlot({
    data = reactiveFilteredData()

    ## plot the line plots for new_deaths
    ggplot(data, aes(x = Date, y = New_deaths)) +
      geom_line(color = "#3D89C3") +
      labs(x = "Date",
           y = "New Deaths") +
      coord_cartesian(ylim = input$yAxisRangeDeaths) +
      theme_minimal() +
      theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0, unit = "pt")),
            axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")))
  })

}

shinyApp(ui = ui, server = server)



