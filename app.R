# ------------------------------------------------------------------------------
# Script Name: app.R
# Purpose: This script creates an interactive Shiny dashboard to visualize COVID-19 data.
#          The dashboard provides insights into COVID-19 cases and deaths globally,
#          allowing users to filter data by date and country. Users can view cumulative data
#          and incremental statistics on an interactive world map and through line plots.
#
# Dependencies: shiny, shinythemes, dplyr, rworldmap, ggplot2
# ------------------------------------------------------------------------------

# Load necessary packages ------------------------------------------------------
library(shiny) # building interactive web apps
library(shinythemes) # Additional themes for Shiny apps
library(dplyr) # Data manipulation
library(rworldmap) # create geographic maps
library(ggplot2) # draw line plots
library(markdown) # install markdown package for include md files

# Read and format data ---------------------------------------------------------
df = read.csv("data/derived/01_COVID-19_global_data_country.csv")
df_world = read.csv("data/derived/02_COVID-19_global_data_world.csv")

# Ensure 'Date' column is in Date format
df$Date = as.Date(df$Date)
df_world$Date = as.Date(df_world$Date)

# Define the range of dates available in the data
date_min = min(df$Date)
date_max = max(df$Date)

# Precompute the country lists based on WHO regions
country_lists = df %>%
  select(Country, WHO_region) %>%
  distinct() %>%
  split(.$WHO_region) %>%
  lapply(function(x) x$Country)

# UI using a fluid page layout -------------------------------------------------
ui = fluidPage(
  # Main title of the dashboard
  titlePanel("COVID-19 Dashboard"),

  # Add custom styles for visual elements
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
                      margin-top: 30px; /* vertical space element */
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
                    .markdown-content {
                      font-family: Verdana, sans-serif;
                      font-size: 16px;
                    }
                    .markdown-section {
                      margin-top: 7px;  /* Adds space above the Markdown content */
                    }
                    .markdown-section p {
                      text-indent: 2em;  /* Indents the first line of each paragraph */
                    }
                    "))),

  # Navigation bar to organize data views
  navbarPage("COVID-19 Cases",
             theme = shinytheme("readable"), # Set readable theme

             ## Tab panel for cumulative data display
             tabPanel("Cumulative Data",
                      ## Add section title
                      div(class = "section-title",
                          h3("Number of COVID-19 Cases or Deaths")),

                      ## Background colour
                      div(class = "panel-background",
                          fluidRow(
                            column(width = 3,
                                   div(class = "vertical-space"),

                                   ## Slider input for selecting dates
                                   sliderInput("slider1", "Select Date Range:",
                                               ## Date range
                                               min = as.Date(date_min, "%Y-%m-%d"),
                                               max = as.Date(date_max, "%Y-%m-%d"),
                                               ## Initial date choose
                                               value = c(as.Date(date_min), as.Date(date_max)),
                                               timeFormat = "%Y-%m-%d",
                                               step = 7),
                                   ## Add extra space
                                   div(class = "vertical-space"),

                                   ## Drop down to select cases or deaths
                                   selectInput("dataChoice", "Type:",
                                               choices = c("Cases" = "Cases", "Deaths" = "Deaths")),
                                   div(class = "vertical-space", style = "height: 40px;"),

                                   ## Show exact number of cases or deaths for a given country
                                   div(class = "white-background",
                                       ## Title (cases or deaths)
                                       htmlOutput("dynamicTitle"),
                                       ## Drop down to select a country
                                       selectizeInput("countryInput",
                                                      ## Title
                                                      "Choose a Country:",
                                                      ## Country Choice
                                                      list(
                                                        `Eastern Mediterranean` = country_lists[["EMRO"]],
                                                        `Europe` = country_lists[["EURO"]],
                                                        `Africa` = country_lists[["AFRO"]],
                                                        `Western Pacific` = country_lists[["WPRO"]],
                                                        `Americas` = country_lists[["AMRO"]],
                                                        `South-East Asia` = country_lists[["SEARO"]],
                                                        `Others` = c(country_lists[["OTHER"]])),
                                                      options = list(selectize = FALSE)),
                                       ## Number output
                                       uiOutput("countryData"))),

                            ## World map visualization
                            column(width = 9,
                                   plotOutput(outputId = "worldMap", height = "600px"))))),

             ## Tab panel for incremental data (new cases) display
             tabPanel("Incremental Data",

                      ## add section title
                      div(class = "section-title",
                          h3("Number of COVID-19 New Cases or Deaths")),

                      ## add background colour
                      div(class = "panel-background",

                          ## Select section
                          fluidRow(
                            ## Date range slider input for daily data
                            column(width = 5,
                                   sliderInput("slider2", "Date",
                                               ## Date range
                                               min = as.Date(date_min, "%Y-%m-%d"),
                                               max = as.Date(date_max, "%Y-%m-%d"),
                                               ## Initial date choose
                                               value = c(as.Date(date_min), as.Date(date_max)),
                                               timeFormat = "%Y-%m-%d",
                                               step = 7,
                                               width = "70%")),
                            column(width = 1),

                            ## Country selection for incremental data
                            column(width = 3,
                                   selectizeInput("countryInput2",
                                                  ## Title
                                                  "Country:",
                                                  ## Country Choice
                                                  list(
                                                    "Total",
                                                    `Eastern Mediterranean` = country_lists[["EMRO"]],
                                                    `Europe` = country_lists[["EURO"]],
                                                    `Africa` = country_lists[["AFRO"]],
                                                    `Western Pacific` = country_lists[["WPRO"]],
                                                    `Americas` = country_lists[["AMRO"]],
                                                    `South-East Asia` = country_lists[["SEARO"]],
                                                    `Others` = c(country_lists[["OTHER"]])),
                                                  options = list(selectize = FALSE))),
                            column(width = 3)),

                          ## Plot section
                          fluidRow(
                            ## Line plot for new cases
                            column(width = 6,
                                   div(class = "sub-title", "COVID-19 New Cases Over Time"),
                                   plotOutput("plotNewCases")),
                            ## Line plot for new deaths
                            column(width = 6,
                                   div(class = "sub-title", "COVID-19 New Deaths Over Time"),
                                   plotOutput("plotNewDeaths"))))),

             ## Analysis section
             navbarMenu("Analysis",

                        ## Worldwide Trends
                        tabPanel("Worldwide Trends",
                                 ## Add section title
                                 div(class = "section-title",
                                     h3("Analysis of Worldwide COVID-19 Case and Death")),
                                 ## Add background colour
                                 div(class = "panel-background",
                                     fluidRow(column(width = 12,
                                                     ## Add description
                                                     tags$div(class = "markdown-section markdown-content",
                                                              uiOutput("markdownText_world")))))),

                        ## Regional Differences
                        tabPanel("Regional Difference",
                                 ## Add section title
                                 div(class = "section-title",
                                     h3("Analysis of Regional Differences in COVID-19 Cases and Deaths")),
                                 ## Add background colour
                                 div(class = "panel-background",
                                     fluidRow(column(width = 12,
                                                     ## Add description
                                                     tags$div(class = "markdown-section markdown-content",
                                                              uiOutput("markdownText_regional")))))),

                        ## Correlation
                        tabPanel("Correlation with Population",
                                 ## Add section title
                                 div(class = "section-title",
                                     h3("Analysis of Correlation between Population and COVID-19 New Cases")),
                                 ## Add background colour
                                 div(class = "panel-background",
                                     fluidRow(column(width = 12,
                                                     ## Add description
                                                     tags$div(class = "markdown-section markdown-content",
                                                              uiOutput("markdownText_corr"))))))),

             ## About section
             navbarMenu("About",
                        ## Introduce COVID-19
                        tabPanel("About COVID-19",
                                 ## Add section title
                                 div(class = "section-title", h3("About COVID-19")),
                                 ## Add background colour
                                 div(class = "panel-background",
                                     fluidRow(column(width = 12,
                                                     ## Add description
                                                     tags$div(class = "markdown-section markdown-content",
                                                                          uiOutput("markdownText_covid")))))),

                        ## Introduction
                        tabPanel("About this Dashboard",
                                 ## Add section title
                                 div(class = "section-title", h3("About this Dashboard")),
                                 ## Add background colour
                                 div(class = "panel-background",
                                     fluidRow(column(width = 12,
                                                     ## Add description
                                                     tags$div(class = "markdown-section markdown-content",
                                                              uiOutput("markdownText_dashboard")))))))))

# Define server for content ----------------------------------------------------
server = function(input, output, session) {

  # Cumulative data panel
  ## Create a reactive expression that filters the dataset based on the selected date
  filteredData = reactive({
    df[df$Date == as.Date(input$slider1), ]
  })

  ## Reactive expression to fetch data for the selected date range and calculate change
  filteredData = reactive({
    ## Filter data to get the cumulative value at the start and end dates for each country
    start_data = df %>%
      filter(Date == as.Date(input$slider1[1])) %>%
      select(Country, starts_with(input$dataChoice))
    end_data = df %>%
      filter(Date == as.Date(input$slider1[2])) %>%
      select(Country, starts_with(input$dataChoice))
    ## Calculate the change by subtracting start values from end values
    ## 'Cases' or 'Deaths' are the columns based on input$dataChoice
    data_change = end_data %>%
      left_join(start_data, by = "Country", suffix = c("_end", "_start")) %>%
      mutate(Change = get(paste(input$dataChoice, "_end", sep = "")) -
               get(paste(input$dataChoice, "_start", sep = ""))) %>%
      select(Country, Change)
    ## Return result
    data_change
  })

  ## Generate and render a world map based on the filtered data
  output$worldMap = renderPlot({
    ## Load data
    data = filteredData()
    ## Check if there is no data available for the selected date
    if (nrow(data) == 0) {
      ## Create an empty plot
      plot.new()
      ## Warning message if no available data
      title("No data available for this date.")
      return()
    }
    ## Draw map
    ## Join country data to a map based on country names
    worldMap = joinCountryData2Map(data, joinCode = "NAME",
                                   nameJoinColumn = "Country",
                                   mapResolution = "li")
    ## Plot the data on the map with specified options
    map = mapCountryData(worldMap, nameColumnToPlot = "Change",
                         catMethod = "fixedWidth",
                         colourPalette = c("#cbdef0", "#abd0e6", "#82badb",
                                           "#59a1cf", "#3788c0", "#1c6aaf", "#0b4e94"),
                         mapTitle = "",
                         addLegend = FALSE)
    ## Customize and add a map legend manually and remove legend labels
    do.call(addMapLegend, c(map, legendLabels = "none",
                            digits = 1,
                            legendShrink = .7,
                            legendIntervals = "data",
                            legendMar = 2,
                            horizontal = FALSE))
    ## Output the map to the UI
    print(map)
  })

  ## Render a dynamic title based on the selected data type (Cases or Deaths)
  output$dynamicTitle = renderUI({
    ## Making large font size
    HTML(paste("<div class='large-font'>Number of", input$dataChoice, "for a Country</div>"))
  })

  ## Render country-specific data based on user selection
  output$countryData = renderUI({
    ## Load data
    data = filteredData()
    ## Check if there is no data available for the selected date
    if (nrow(data) == 0) {
      ## Warning messages if no available data
      "No data available on selected date."
    }
    ## Check if there is no data available for the selected country
    data_country = data[data$Country == input$countryInput, ]
    if (nrow(data) == 0) {
      ## Warning messages if no available data
      "No data available for this country on selected date."
    } else {
      ## Formatting the number using comma
      output_num = data_country$Change
      output_num = format(output_num, big.mark = ",", scientific = FALSE)
      ## Word output, including selected date and exact number
      HTML(paste("The number of", input$dataChoice, "from",
                 format(as.Date(input$slider1[1]), "%Y-%m-%d"), "to",
                 format(as.Date(input$slider1[2]), "%Y-%m-%d"), "is",
                 tags$b(output_num), '<br><div style="margin-bottom:20px;"></div>'))
    }})

  # Incremental data panel
  ## Filtered data based on user selections
  reactiveFilteredData = reactive({
    ## Check select a country or Total
    if (input$countryInput2 == "Total") {
      subset(df_world, Date >= input$slider2[1] & Date <= input$slider2[2])
    } else {
      subset(df, Country == input$countryInput2 & Date >= input$slider2[1] & Date <= input$slider2[2])
    }
  })

  ## Generate the plot for new cases based on filtered daily data
  output$plotNewCases = renderPlot({
    ## Load data
    data = reactiveFilteredData()
    ## Plot the line plots for new_cases
    ggplot(data, aes(x = Date, y = New_cases)) +
      ## Adjust line color and width
      geom_line(color = "#3D89C3", linewidth = 1.5) +
      ## Axis title
      labs(x = "Date", y = "New Cases") +
      ## Minimal theme
      theme_minimal() +
      ## Adjust gap between axis title and axis
      theme(axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0, unit = "pt")),
            axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")))
  })

  ## Generate the plot for new deaths based on filtered daily data
  output$plotNewDeaths = renderPlot({
    ## Load data
    data = reactiveFilteredData()
    ## plot the line plots for new_deaths
    ggplot(data, aes(x = Date, y = New_deaths)) +
      ## Line color and width
      geom_line(color = "#3788c0", linewidth = 1.5) +
      ## Axis title
      labs(x = "Date", y = "New Deaths") +
      ## Minimal theme
      theme_minimal() +
      ## Adjust gap between axis title and axis
      theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0, unit = "pt")),
            axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0, unit = "pt")))
  })

  # Analysis panel
  ## Add analysis file worldwide trends
  output$markdownText_world = renderUI({
    tags$div(class = "markdown-content",
             includeMarkdown("src/analysis/01_analysis_world/world_trends.md"))
  })

  ## Add analysis of regional difference
  output$markdownText_regional = renderUI({
    tags$div(class = "markdown-content",
             includeMarkdown("src/analysis/02_analysis_regional_diff/regional_diff.md"))
  })

  ## Add analysis of correlation
  output$markdownText_corr = renderUI({
    tags$div(class = "markdown-content",
             includeMarkdown("src/analysis/03_analysis-correlation_with_poopulation/correlation.md"))
  })

  # About panel
  ## Add introduction of COVID-19
  output$markdownText_covid = renderUI({
    tags$div(class = "markdown-content",
             includeMarkdown("src/about/01_COVID.md"))
  })

  ## Add introduction of this dashboard
  output$markdownText_dashboard = renderUI({
    tags$div(class = "markdown-content",
             includeMarkdown("src/about/02_Dashboard.md"))
  })
}

# Start the Shiny app with defined UI and server functions ---------------------
shinyApp(ui = ui, server = server)


