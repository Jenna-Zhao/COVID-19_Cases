# COVID-19_Dashboard

<!-- badges: start -->

<!-- badges: end -->

---
The Dashboard link: [https://jenna-zhao.shinyapps.io/COVID-19_Dashboard/]( https://jenna-zhao.shinyapps.io/COVID-19_Dashboard/)
---

[COVID-19](https://en.wikipedia.org/wiki/COVID-19), officially known as the coronavirus disease 2019, is a contagious disease caused by the coronavirus SARS-CoV-2. This dashboard is designed to visualize both cumulative and incremental COVID-19 cases or deaths worldwide, spanning from May 1, 2020, to April 7, 2024. It is hosted on shinyapps.io, allowing for seamless online operation.

-   For cumulative data, we utilize maps to illustrate the total number of cases or deaths across different regions for selected time periods;

<div align="center">

<img src="photo/01_dashboard_cum.png" width="90%"/> 

</div>

-   For incremental data, line plots are used to track the fluctuations in new cases and deaths over time in a specific country or worldwide.

<div align="center">

<img src="photo/02_dashboard_incremental.png" width="90%"/> 

</div>

## Data

The [**raw**](data/raw) folder contains raw data stored in CSV format:

-   [01-COVID-19_global_data.csv](data/raw/01-COVID-19_global_data.csv) - This file contains weekly records of COVID-19 cases and deaths from May 1, 2020, to April 7, 2024, derived from the [WHO COVID-19 dashboard data](https://data.who.int/dashboards/covid19/data?n=o) on the website [World Health Organization Data](https://data.who.int/);

-   [02-population_countries.csv](data/raw/02-population_countries.csv) - This file includes population numbers for each country for the years 2023 and 2024, sourced from the [World Population Review](https://worldpopulationreview.com/);

-   [03-population_countries_before_22.csv](data/raw/03-population_countries_before_22.csv) - This file includes population data from 2020 to 2022 for each country, obtained from the [Data Bank, World Development Indicators](https://databank.worldbank.org/reports.aspx?source=2&series=SP.POP.TOTL&country=#advancedDownloadOptions).

Additionally, the folder includes a detailed description ([About_data.md](data/raw/About_data.md)) of main variables for these three files.

 

The [**derived**](data/derived) folder contains processed data files, which are utilized for creating visualizations and conducting [analysis](src/analysis) in the [Shiny app](app.R):

-   [01_COVID-19_global_data_country.csv](data/derived/01_COVID-19_global_data_country.csv) - This file contains cleaned COVID-19 data aggregated by country;

-   [02_COVID-19_global_data_world.csv](data/derived/02_COVID-19_global_data_world.csv) - This file compiles global-level COVID-19 data;

-   [03_population_by_country.csv](data/derived/03_population_by_country.csv) - This file includes population figures for each country spanning from 2020 to 2024;

-   [04_population_by_country_24.csv](data/derived/04_population_by_country_24.csv) - This file specifically contains population data in 2024 for each country.

For detailed information on the data process, please refer to [derived_data.md](data/derived/derived_data.md).

## Interactive Visualization

In this dashboard, we have developed a [Shiny app](app.R) to visualize COVID-19 data effectively.

-   For cumulative data, users can select their interested time period, data type (cases or deaths), and view the exact figures for any specific country.

-   For incremental data, users have the flexibility to choose both the time period and the country of interest.

For further details and an introduction to the dashboard, please refer to the document [02_Dashboard.md](src/about/02_Dashboard.md), which can be found in the "About" section of the COVID-19 dashboard as well.

## Analysis

We conducted a further exploration of [worldwide trends](src/analysis/01_analysis_world), [regional differences](src/analysis/02_analysis_regional_diff), and the [correlation between population size and COVID-19 cases](src/analysis/03_analysis-correlation_with_poopulation). Our analyses revealed several key findings:

-   There is a downward trend in both COVID-19 cases and deaths from 2024;

-   There is a clear regional difference in the distribution of COVID-19 cases and deaths;

-   There appears to be a positive relationship between population size and COVID-19 cases, indicating a higher likelihood of cases in areas with dense populations.

For detailed analysis and interpretation, please refer to the documents [world_trends.md](src/analysis/01_analysis_world/world_trends.md), [regional_diff.md](src/analysis/02_analysis_regional_diff/regional_diff.md), and [correlation.md](src/analysis/03_analysis-correlation_with_poopulation/correlation.md). Additionally, these analyses are included in the "Analysis" section of the COVID-19 dashboard.

## Reproducible

1.  **Initial Setup**

    -   Running the script [dependencies-check_and_install_packages.R](src/reproducible/dependencies-check_and_install_packages.R) to install and update all required packages. This step ensures that all dependencies are up-to-date, which is essential for the proper functioning of subsequent scripts.

2.  **Data Preparation**

    -   Continue with the scripts [01_COVID-19_global_data.R](src/data_cleaning/01_COVID-19_global_data.R) and [02_population_data_clean_and_merge.R](src/data_cleaning/02_population_data_clean_and_merge.R). These scripts are tasked with cleaning and merging the raw datasets, setting the stage for accurate and insightful analyses.

3.  **Viewing the Dashboard**

    -   Execute [app.R](app.R) to launch the final dashboard. This script activates the Shiny application, enabling interactive visualization.

4.  **Analysis**

    -   For a specific analyses conducted in this project, review the scripts [01_code-world_new_cases_deaths.R](src/analysis/01_analysis_world/01_code-world_new_cases_deaths.R), [01_code-regional_cumcases_cumdeaths.R](src/analysis/02_analysis_regional_diff/01_code-regional_cumcases_cumdeaths.R), and [01_code-corr_population_COVID.R](src/analysis/03_analysis-correlation_with_poopulation/01_code-corr_population_COVID.R). These scripts provide detailed steps used to reproduce the outputs presented in the dashboard.

5.  **Supplementary Documentation**

    -   For textual parts related to the "Analysis" and "About" sections of the dashboard, refer to the Markdown files located in the [**analysis**](src/analysis) and [**about**](src/about) folders. These documents provide detailed descriptions of the visualisations.
    
6.  **Deploy your first application**

    -   Finally, we published the application following the steps in [shinyapps.io](https://www.shinyapps.io/).

Following these instructions will enable users to reproduce the analysis and interact with the visualizations as intended.

## License

This project is licensed under the MIT license.
