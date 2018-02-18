
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# Exploratory analysis of main heater based on house type

if(!exists("tidyData", mode="function")) source("Utilities.R")

# Read from formatted file
# Main Heater numbers per housing unit
fuel_water_units <- read_excel(
  sheet=1,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterUnits.xls",
  na=c("Q","N"))
size_water_units <- read_excel(
  sheet=2,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterUnits.xls",
  na=c("Q","N"))
age_water_units <- read_excel(
  sheet=3,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterUnits.xls",
  na=c("Q","N"))



exploreTypeVsCount(
  tidyData(fuel_water_units),
  "Fuel used by main water heater",
  "Fuel source"
  )
exploreTypeVsCount(
  tidyData(size_water_units),
  "Size of main water heater",
  "Size"
  )
exploreTypeVsCount(
  tidyData(age_water_units),
  "Age of main water heater",
  "Age"
  )






