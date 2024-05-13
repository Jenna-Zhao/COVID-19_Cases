# -----------------------------------------------------------
# Script Name: 01_dependencies-check_and_install_packages.R
# Purpose: This script ensures that all required R packages are installed, supporting the reproducibility
#          of this project by managing dependencies efficiently. It checks for the presence of required
#          R packages and installs any that are missing.
#
# Usage: Run this script in an R environment before executing any major scripts or projects
#        that rely on these packages. This ensures all dependencies are met.
# -----------------------------------------------------------

# list of packages required for the project
packages = c("shiny", "shinythemes", "tidyverse",
             "knitr",  "dplyr", "zoo", "htmltools", "markdown")

# function to check and install packages
package_check = lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    cat(sprintf("Package '%s' is not installed. Installing now.\n", x))
    install.packages(x, dependencies = TRUE)
    cat(sprintf("Package '%s' has been installed.\n", x))
  } else {
    cat(sprintf("Package '%s' is already installed.\n", x))
  }
})

cat("All packages are checked and installed if necessary.\n")

# define the minimum required version of the htmltools package
required_version = "0.5.8"

# get the currently installed version of 'htmltools'
current_version = packageVersion("htmltools")

# check if the installed version is older than the required version
if (current_version < required_version) {
  cat(sprintf("The installed version of 'htmltools' (%s) is older than required (%s). Updating now.\n",
              as.character(current_version), required_version))

  # Install the latest version of 'htmltools' from CRAN
  install.packages("htmltools", dependencies = TRUE)

  cat(sprintf("Package 'htmltools' has been updated to version %s.\n", as.character(packageVersion("htmltools"))))
  } else {
    cat(sprintf("Package 'htmltools' is already installed and meets the required version (%s).\n", required_version))
  }

# Confirm the package status
cat("The 'htmltools' package is checked and up-to-date with the required version or higher.\n")

