# -----------------------------------------------------------
# Script Name: ui
# Purpose: This script is used to ....
# -----------------------------------------------------------

# load package ------------------------------------------------
library(shiny)
library(shinythemes)
library(rworldmap)
library(dplyr)

df = read.csv("../../data/derived/01_COVID-19_global_data_country.csv")

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
                            column(width = 6),
                            column(width = 6)
                            ))),
             tabPanel("Developers")
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


}

shinyApp(ui = ui, server = server)



