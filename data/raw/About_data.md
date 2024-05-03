# About data

This document outlines the key variables found in the raw data derived from the [WHO COVID-19 dashboard data](https://data.who.int/dashboards/covid19/data?n=c). We focus on the dataset [COVID-19_global_data.csv](data/raw/COVID-19_global_data.csv), which compiles weekly reports of cumulative and new COVID-19 cases and deaths submitted to WHO. The data spans from 05/01/2020 to 07/04/2024 and includes details for each country.

The main variable shows below:

-   `Date_reported`: The date on which cases and deaths were reported, covering a weekly timeframe from 05/01/2020 to 07/04/2024.

-   `Country_code`, `Country`: The codes and names of the countries reporting the data.

-   `WHO_region`: Abbreviations for WHO regions, including:

    -   **AFRO**: Regional Office for Africa;

    -   **AMRO**: Regional Office for the Americas;

    -   **SEARO**: Regional Office for South-East Asia;

    -   **EURO**: Regional Office for Europe;

    -   **EMRO**: Regional Office for the Eastern Mediterranean;

    -   **WPRO**: Regional Office for the Western Pacific;

    -   **Others**: Additional regions not categorized in the aforementioned list.

        ![](who_regions.png)

-   `New_cases` and `New_deaths`: Daily increments reported for new cases and deaths. These figures are subject to retrospective corrections to ensure accuracy based on new information received, sometimes resulting in negative values.

-   `Cumulative_cases` and `Cumulative_deaths`: The total number of confirmed cases and deaths from COVID-19 up to the reporting date.
