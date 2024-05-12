# Derived data

This document provides a comprehensive overview of the processes used to manage and clean the raw data. Key steps include renaming columns, converting data types, merging data and addressing missing or unreasonable values to enhance the efficiency of plotting.

## COVID-19 Data

For COVID-19 Data, we utilized the `dplyr` and `zoo` packages, which can be installed using the `install.packages()` function in R.

Our goal is to visualize the global impact of COVID-19 through two key visual representations. Firstly, we aim to create a map illustrating the cumulative number of COVID-19 cases or deaths for on a given date. Secondly, we will generate line plots to track changes in the number of new cases or deaths over time for a selected country.

-   **Loading Data**: Utilize the `read.csv()` function to load the dataset.

-   **Renaming Columns**: Modify column names for clarity and accessibility:

    -   `Date_reported` to `Date`

    -   `Cumulative_cases` to `Cases`

    -   `Cumulative_deaths` to `Deaths`

-   **Data Type Conversion**: Convert the `Date` column from "Character" to "Date" type to facilitate chronological operations.

-   **Replacing Values**: The `ifelse()` function checks for conditions where `WHO_region` is either empty and replaces these with `"OTHER"`. This helps grouping operations in analysis or visualizations.

-   **Handling Retrospective Corrections**: Replace negative values in the columns `New_cases` and `New_deaths`, which are used for retrospective corrections, with `NA`. This prepares the dataset to estimate more reasonable values.

-   **Handling NA Values**: The dataset was first organised by country to ensure accurate regional analysis. Next, we handled `NA` values in the columns `New_cases` and `New_deaths` by following steps:

    -   **Leading and Trailing NAs**: Replace leading and trailing `NA` values within each country's data with zeros, as these typically represent days before the first reported case or after the last update;

    -   **Interpolation of NAs**: For other `NA` values within the dataset, apply the `na.approx()` function from the `zoo` package. This function approximates missing values using linear interpolation, typically filling each `NA` with the mean of its neighboring values.

-   **Matching country name**: Adjusting specific country names in the dataset to match with function `joinCountryData2Map()`.

-   **Saving Cleaned Data**:

    -   **Country Data**: Save the dataset containing both the cumulative and incremental counts of cases and deaths for each country, as a CSV file named [01_COVID-19_global_data_country.csv](01_COVID-19_global_data_country.csv);

    -   **World Data**: Compute and record the total number of daily and cumulative cases and deaths worldwide into another CSV file named [02_COVID-19_global_data_world.csv](02_COVID-19_global_data_world.csv).

The script [01_COVID-19_global_data.R](../../src/data_cleaning/01_COVID-19_global_data.R) contains all the code used in this data cleaning process.

## Population Data

For COVID-19 Data, we used the `dplyr` packages.

Our aim is to merge two datasets into a single file that represents the number of population by country from 2020 to 2024. The merged dataset will be used to analyze the correlation between COVID-19 case and population figures.

-   **Loading Data**: Using the `read.csv()` function to load the dataset.

-   **Preparing Data for 2023 and 2024**:

    -   Renaming `country` column to `Country` for consistency;
    -   Selecting focused columns `pop2023` and `pop2024`;
    -   Transforming from a wide format to a long format using `pivot_longer()` function, so columns `pop2023` and `pop2024` will be converted into two new columns: `Year` (stores the year) and `pop` (stores the population figures);
    -   Converting `Year` column values into numeric: `"pop2023"` becomes `"2023"` and `"pop2024"` becomes `"2024"`.

-   **Preparing Data for 2020, 2021, and 2022**

    -   Similarly, transforming `population_df2` from wide to long format, handling the years 2020, 2021, and 2022: `Year` (stores the year), `pop` (stores the population figures) and the prefix 'X' is removed;
    -   Converting `Year` column values into numeric;
    -   Renaming `Country.Name` column to `Country` for consistency;
    -   Selecting focused columns `Country`, `Year` and `pop`.

-   **Identifying Common Countries**: Performing `intersect()` between the country lists from both datasets to identify common countries.

-   **Filtering Data for Common Countries**: Filtering both datasets to include only the entries corresponding to the common countries by using `filter()` function.

-   **Combining Datasets**: Combining the filtered datasets for 2020 to 2022 and 2023 to 2024 into one data frame by using **`bind_rows()`** function.

-   **Selecting Data for 2024**: Using `select()` function to select population data for 2024.

-   **Matching country name**: Adjusting specific country names in the dataset to match with function `joinCountryData2Map()`.

-   **Saving Cleaned Data**:

    -   Saving population data by country from 2020 to 2024 into a CSV file named [03_population_by_country.csv](03_population_by_country.csv).

    -   Saving population data by country for 2024 into a CSV file named [04_population_by_country_24.csv](04_population_by_country_24.csv).

The script [02_population_data_clean_and_merge.R](../../src/data_cleaning/02_population_data_clean_and_merge.R) contains all the code used in this data cleaning process.
