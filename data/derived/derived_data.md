# Derived data

This document provides a comprehensive overview of the processes used to manage and clean the raw data. Key steps include renaming columns, converting data types, and addressing missing or unreasonable values to enhance the efficiency of plot generation. For data processing, we utilized the `dplyr` and `zoo` packages, which can be installed using the `install.packages()` function in R.

Our goal is to visualize the global impact of COVID-19 through two key visual representations. Firstly, we aim to create a map illustrating the cumulative number of COVID-19 cases or deaths for on a given date. Secondly, we will generate line plots to track changes in the number of new cases or deaths over time for a selected country.

-   **Loading Data**: Utilize the `read.csv()` function to load the dataset.

-   **Renaming Columns**: Modify column names for clarity and accessibility:

    -   **`Date_reported`** to **`Date`**

    -   **`Cumulative_cases`** to **`Cases`**

    -   **`Cumulative_deaths`** to **`Deaths`**

-   **Data Type Conversion**: Convert the `Date` column from "Character" to "Date" type to facilitate chronological operations.

-   **Handling Retrospective Corrections**: Replace negative values in the columns `New_cases` and `New_deaths`, which are used for retrospective corrections, with `NA`. This prepares the dataset for the imputation of more reasonable values.

-   **Handling NA Values**: The dataset was first organised by country to ensure accurate regional analysis. Next, we handled `NA` values in the columns `New_cases` and `New_deaths` by following steps:

    -   **Leading and Trailing NAs**: Replace leading and trailing `NA` values within each country's data with zeros, as these typically represent days before the first reported case or after the last update;

    -   **Interpolation of NAs**: For other `NA` values within the dataset, apply the `na.approx()` function from the `zoo` package. This function approximates missing values using linear interpolation, typically filling each `NA` with the mean of its neighboring values.

-   **Saving Cleaned Data**:

    -   **Country Data**: Save the dataset containing both the cumulative and new counts of cases and deaths for each country, as a CSV file named [01_COVID-19_global_data_country.csv](01_COVID-19_global_data_country.csv);

    -   **World Data**: Compute and record the total number of daily and cumulative cases and deaths worldwide into another CSV file named [02_COVID-19_global_data_world.csv](02_COVID-19_global_data_world.csv).

The script [01_COVID-19_global_data.R](../../src/data_cleaning/01_COVID-19_global_data.R) contains all the code used in the data cleaning process.
