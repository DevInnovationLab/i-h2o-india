## IDEXX Data Cleaning Script
## Author: Jeremy Lowe
## Date: 05/31/24
## Note: This file was drafted based on another old cleaning file in the 2_Pilot folder
##        (India-ILC_Pilot_WQ_Checks.Rmd). This file was drafted in place to process the raw data for data cleaning.




# load the libraries
library(readxl) 
library(googledrive)
library(googlesheets4)
library(DBI)
library(RSQLite)
library(dplyr)
library(lubridate)
library(haven)
library(expss)
library(stargazer)
library(Hmisc)
library(ggplot2)
library(labelled)
library(data.table)
library(rsurveycto)
library(httr)
library(tidyverse)
library(lubridate)
library(quantitray)
library(sjmisc)
library(knitr)
library(kableExtra)
library(readxl)
library(experiment)
library(readxl)
library(haven)
library(ggsignif)
library(patchwork)
library(table1)
library(gtsummary)
#library(xtable)


####---------------------- setting user path -----------------------------####


user_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  #
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "jerem"){
    path = "C:/Users/jerem/Box/India Water project/2_Pilot/Data/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = user_path())

# setting github directory
github_path <- function() {
  user <- Sys.info()["user"]
  if (user == "asthavohra") {
    github = "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/2_Pilot/0_pilot logistics/"
  } 
  else if (user=="akitokamei"){
    github = "/Users/akitokamei/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/i-h2o-india/Code/2_Pilot/0_pilot logistics/"
  } 
  else if (user == "jerem") {
    github = "C:/Users/jerem/Documents/i-h2o-india/Code/1_profile_ILC"
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

### setting overleaf ###
# This section was commented out because we are not using overleaf for this file yet
# overleaf <- function() {
#   user <- Sys.info()["user"]
#   if (user == "asthavohra") {
#     overleaf = "/Users/asthavohra/Dropbox/Apps/Overleaf/Everything document -ILC/"
#   } 
#   else if (user=="akitokamei"){
#     overleaf = "/Users/akitokamei/Library/CloudStorage/Dropbox/Apps/Overleaf/Everything document -ILC/"
#   } 
#   else if (user == "jerem") {
#     overleaf = ""
#   } 
#   else {
#     warning("No path found for current user (", user, ")")
#     overleaf = getwd()
#   }
#   
#   stopifnot(file.exists(overleaf))
#   return(overleaf)
# }








###-----------------Loading datasets---------------------------------####


mon <- read_csv(paste0(user_path(),"/1_raw/Daily Chlorine Monitoring Form_WIDE.csv"))

mon_full <- read_csv(paste0(user_path(),"/1_raw/india_ilc_pilot_monitoring_WIDE.csv"))

village_details <- read_xlsx("C:/Users/jerem/Box/India Water project/2_Pilot/Data/5_lab data/India_ILC_Pilot_Rayagada_Village_Tracking.xlsx")





###---------------Chlorine monitoring data cleaning-------------####

#Assigning more meaningful variable names
mon <- mon%>%
  rename(village_ID = "village_name")

mon_full <- mon_full%>%
  rename(village_ID = "village_name")

#Pairing village information
mon$village_ID <- as.character(mon$village_ID)
mon <- left_join(mon, village_details, by = "village_ID")

mon_full$village_ID <- as.character(mon_full$village_ID)
mon_full <- left_join(mon_full, village_details, by = "village_ID")

#Averaging chlorine data
mon <- mon%>%
  mutate(nearest_tap_fc = (first_nearest_tap_fc + second_nearest_tap_fc)/2)%>%
  mutate(nearest_tap_tc = (first_nearest_tap_tc + second_nearest_tap_tc)/2)%>%
  mutate(farthest_tap_fc = (first_farthest_tap_fc + second_farthest_tap_fc)/2)%>%
  mutate(farthest_tap_tc = (first_farthest_tap_tc + second_farthest_tap_tc)/2)%>%
  mutate(nearest_stored_fc = (first_stored_water_fc + second_stored_water_fc)/2)%>%
  mutate(nearest_stored_tc = (first_stored_water_tc + second_stored_water_tc)/2)%>%
  mutate(farthest_stored_fc = (far_first_stored_water_fc + far_second_stored_water_fc)/2)%>%
  mutate(farthest_stored_tc = (far_first_stored_water_tc + far_second_stored_water_tc)/2)

mon_full <- mon_full%>%
  mutate(nearest_tap_fc = (first_nearest_tap_fc + second_nearest_tap_fc)/2)%>%
  mutate(nearest_tap_tc = (first_nearest_tap_tc + second_nearest_tap_tc)/2)%>%
  mutate(farthest_tap_fc = (first_farthest_tap_fc + second_farthest_tap_fc)/2)%>%
  mutate(farthest_tap_tc = (first_farthest_tap_tc + second_farthest_tap_tc)/2)%>%
  mutate(nearest_stored_fc = (first_stored_water_fc + second_stored_water_fc)/2)%>%
  mutate(nearest_stored_tc = (first_stored_water_tc + second_stored_water_tc)/2)%>%
  mutate(farthest_stored_fc = (far_first_stored_water_fc + far_second_stored_water_fc)/2)%>%
  mutate(farthest_stored_tc = (far_first_stored_water_tc + far_second_stored_water_tc)/2)


#Getting date of test
mon$valve_open_time <- mdy_hms(mon$valve_open_time)
mon <- mon%>%
  mutate(test_date = date(valve_open_time))

mon_full$valve_open_time <- mdy_hms(mon_full$valve_open_time)
mon_full <- mon_full%>%
  mutate(test_date = date(valve_open_time))

#Selecting for variables only in the shorter daily monitoring form
mon <- bind_rows(mon, mon_full)


### Cleaning and formatting datasets ### 
mon_villages <- unique(mon$village_name)


#Pivoting to make datasets only have a single column for chlorine concentration measurement
#saving wide format
mon_wide <- mon
mon <- mon%>%
  pivot_longer(cols = c(nearest_tap_fc, nearest_tap_tc, farthest_tap_fc, farthest_tap_tc, nearest_stored_fc, nearest_stored_tc, farthest_stored_fc, farthest_stored_tc), names_to = "chlorine_test", values_to = "chlorine_concentration")


#Subsetting for nearest and farthest tap connections
mon_near <- mon%>%
  filter(chlorine_test %in% c("nearest_tap_fc", "nearest_stored_fc", "nearest_tap_tc", "nearest_stored_tc"))

mon_far <- mon%>%
  filter(chlorine_test %in% c("farthest_tap_fc", "farthest_stored_fc", "farthest_tap_tc", "farthest_stored_tc"))



#Setting variable labels for stata compatibility
make_stata_compatible <- function(name) {
  name <- gsub("[^a-zA-Z0-9_]", "_", name)  # Replace illegal characters with underscores
  if (nchar(name) > 32) {
    name <- substr(name, 1, 32)  # Trim to 32 characters
  }
  name
}
# Apply the function to all column names
new_names <- sapply(names(mon_wide), make_stata_compatible)
names(mon_wide) <- new_names

#Reducing length of variable name
mon_wide <- mon_wide %>% 
  rename(Village_ID = `Corresponding Village ID from census`)


#Writing final chlorine monitoring file
write_dta(mon_wide,paste0(user_path(), "/2_deidentified/1_X_chlorine_monitoring.dta"))
write_csv(mon_wide,paste0(user_path(), "/2_deidentified/1_X_chlorine_monitoring.csv"))



