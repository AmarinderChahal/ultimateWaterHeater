
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# Exploratory analysis of main heater based on number of household members

source("Utilities.R")

# Read from formatted file
# Main Heater numbers per housing unit
fuel_water_years <- read_excel(
  sheet=2,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterYears.xls",
  na=c("Q","N"))
size_water_years <- read_excel(
  sheet=1,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterYears.xls",
  na=c("Q","N"))
age_water_years <- read_excel(
  sheet=3,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterYears.xls",
  na=c("Q","N"))



exploreTypeVsCount(
  tidyData(fuel_water_years),
  "Fuel used by main water heater",
  "Fuel source"
  )
exploreTypeVsCount(
  tidyData(size_water_years),
  "Size of main water heater",
  "Size"
  )
exploreTypeVsCount(
  tidyData(age_water_years),
  "Age of main water heater",
  "Age"
  )


fwy_tidy <- tidyData(fuel_water_years)
fwy_freq <- group_by(
  fwy_tidy,
  "Unit Type"=get(colnames(fwy_tidy)[2])) %>%
  summarize("Total"=sum(`Unit Count (million)`))

fwy_ratio <- left_join(fwy_tidy,fwy_freq) %>%
  mutate("Percentage"=`Unit Count (million)`/Total * 100)

ggplot(data=fwy_ratio,aes(x=`Unit Type`,y=`Percentage`,
                             fill=`Fuel used by main water heater`)) +
  geom_col() +
  guides(fill=guide_legend(title="Fuel source")) +
  xlab("")

