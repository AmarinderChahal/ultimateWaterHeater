
library(readxl)
library(ggplot2)
library(tidyr)
library(dplyr)

# Exploratory analysis of main heater based on number of household members

if(!exists("tidyData", mode="function")) source("Utilities.R")

# Read from formatted file
# Main Heater numbers per housing unit
fuel_water_members <- read_excel(
  sheet=2,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterMembers.xls",
  na=c("Q","N"))
size_water_members <- read_excel(
  sheet=3,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterMembers.xls",
  na=c("Q","N"))
age_water_members <- read_excel(
  sheet=1,
  "~/Documents/Dev/DataScience/HomeWaterHeater/hc8_all/HomeWaterMembers.xls",
  na=c("Q","N"))



exploreTypeVsCount(
  tidyData(fuel_water_members),
  "Fuel used by main water heater",
  "Fuel source"
  )
exploreTypeVsCount(
  tidyData(size_water_members),
  "Size of main water heater",
  "Size"
  )

exploreTypeVsCount(
  tidyData(age_water_members),
  "Age of main water heater",
  "Age"
  )


# Average household need # of members * 12 gallons of water
swm_tidy <- tidyData(size_water_members[1:3,]) %>%
  mutate("Average Waste" = rep(c(30,49,60),5) - sort(rep(1:5,3)) * 12) %>%
  mutate("Wasting water" = `Average Waste` < 0)

ggplot(data=swm_tidy,aes(x=`Unit Type`,fill=`Size of main water heater`)) +
  geom_col(aes(y=`Unit Count (million)`),position="dodge") +
  geom_point(aes(y=`Average Waste`,size=`Average Waste`),position=position_dodge(width = 0.9)) +
  guides(fill=guide_legend(title="Size of heater")) +
  xlab("") + ggtitle("Heater Size and Average Waste versus # of Household Members") +
  scale_y_continuous(sec.axis = sec_axis( ~ .,name = "Gallons of waste"))







# Average individual wastes 1.2 gallons of water in warmup
# put that against