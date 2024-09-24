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

village_details <- read_sheet("https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1710429467")

mon_long <- read_csv(paste0(user_path(), "1_raw/1_11_Longitudinal Testing/Longitudinal Testing Survey_WIDE.csv"))

#-------------------------Village information cleaning-----------------------#

#Making village IDs compatible to the surveys
village_details <- village_details%>%
  mutate(village_ID = `Village codes`)

village_details$village_ID <- as.character(village_details$village_ID)

#Making Panchayat village variable compatible with the existing data
village_details <- village_details%>%
  mutate(panchayat_village = Panchayat)

#Making block variable compatible with existing data
village_details <- village_details%>%
  rename(block = "Block")

#Creating village codes for anonymity 
village_details <- village_details%>%
  mutate(village_code = case_when(Village == "Asada" ~ "AS",
                                  Village == "Mukundpur" ~ "MU",
                                  Village == "Gopi Kankubadi" ~ "GO",
                                  Village == "Bichikote" ~ "BI",
                                  Village == "Badabangi" ~ "BA",
                                  Village == "Nathma" ~ "NAT",
                                  Village == "Tandipur" ~ "TA",
                                  Village == "Birnarayanpur" ~ "BN",
                                  Village == "Naira" ~ "NAI",
                                  Village == "Karnapadu" ~ "KA"
                                  
  ))

#Renaming village variable
village_details <- village_details%>%
  rename(village_name = "Village")





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



#Writing final chlorine monitoring file
write_dta(mon_wide,paste0(user_path(), "/3_final/1_X_chlorine_monitoring.dta"))
#write_csv(mon_wide,paste0(user_path(), "/3_final/1_X_chlorine_monitoring.csv"))






###---------------Longitudinal chlorine monitoring cleaning-------------####

#Assigning more meaningful variable names
mon_long <- mon_long%>%
  rename(village_ID = "village_name")


#Pairing village information
mon_long$village_ID <- as.character(mon_long$village_ID)
mon_long <- left_join(mon_long, village_details, by = "village_ID")




# Reshape data
mon_long <- mon_long%>%
  # First pivot to long format for time variables
  pivot_longer(
    cols = starts_with("tw_time_"),  # Specify columns starting with "tw_time_"
    names_to = "tw_time_variable",    # Name for the column that stores original column names
    values_to = "tw_time"             # Name for the column that stores the values
  ) %>%
  # Then pivot to long format for chlorine concentration variables
  pivot_longer(
    cols = starts_with("tw_fc_"),    # Specify columns starting with "tw_fc_"
    names_to = "tw_fc_variable",      # Name for the column that stores original column names
    values_to = "tw_fc"               # Name for the column that stores the values
  ) %>%
  # Filter rows to align time and chlorine concentration values
  filter(str_replace(tw_time_variable, "tw_time_", "tw_fc_") == tw_fc_variable) %>%
  # Remove unnecessary columns
  select(-tw_time_variable, -tw_fc_variable)



#Creating new var for submission date with only the date component 
mon_long$SubmissionDate <- mdy_hms(mon_long$SubmissionDate, tz="Asia/Kolkata")

# Extract date only
mon_long$date_only <- date(mon_long$SubmissionDate)


# adding variable labels
#location of tap:
mon_long$location <- factor(mon_long$location, 
                           levels = c(1, 2),
                           labels = c("Nearest Tap", "Farthest Tap"))

# Remove rows with missing values in 'tw_time' or 'tw_fc'
mon_long <- mon_long %>%
  filter(is.na(tw_time) == FALSE)%>%
  filter(is.na(tw_fc) == FALSE)

# Maunal corrections
mon_long <- mon_long %>%
  mutate(tw_time_char = as.character(tw_time)) %>%  # Ensuring that tw_time is in character format
  mutate(tw_time_corrected = case_when(
    tw_time_char == "18:42:59" ~ "06:42:59",
    tw_time_char == "18:47:21" ~ "06:47:21",
    tw_time_char == "18:52:14" ~ "06:52:14",
    tw_time_char == "18:57:31" ~ "06:57:31",
    tw_time_char == "19:03:47" ~ "07:03:47",
    TRUE ~ tw_time_char
  )) %>%
  mutate (tw_time = tw_time_corrected)
#  mon_long$tw_time <- format(tw_time, "%H:%M:%S")
#  mutate(tw_time = as.POSIXct(paste("2024-01-01", tw_time_corrected), format = "%Y-%m-%d %H:%M:%S")) %>%  # Convert corrected times to POSIXct with a temp date
#  select(-tw_time_char, -tw_time_corrected)  # removing temporary columns

# Converting the tw_time variable to hms object

#today's date
mon_long$todays_date <- today()
#combining with tw_time
mon_long$time_hms <- paste(mon_long$todays_date, mon_long$tw_time)

#Making date time object
mon_long$time_hms <- ymd_hms(mon_long$time_hms)

# Combine hours and minutes into a single column
mon_long$time <- sprintf("%02d:%02d", hour(mon_long$time_hms), minute(mon_long$time_hms))
#select(-hours, -minutes, -time_hms)  # removing temporary columns()



#Removing Mukundpur data that had no chlorine detected on the first test date
mon_long <- mon_long%>%
  filter(!(village_code == "MU" & deviceid != "a5c18f73beda3586"))

#Removing duplicate Asada data
mon_long <- mon_long%>%
  filter(!(village_code == "AS" & date_only < "2024-09-01"))

#Removing duplicate Gopi Kankubadi data
mon_long <- mon_long%>%
  filter(!(village_code == "GO" & date_only > "2024-09-02"))

#Removing duplicate Badabangi data
mon_long <- mon_long%>%
  filter(!(village_code == "BA" & date_only > "2024-09-01"))

#Removing duplicate Naira data
mon_long <- mon_long%>%
  filter(!(village_code == "NAI" & date_only < "2024-09-03"))

#Writing clean dataset
write_csv(mon_long,paste0(user_path(),"/3_final/1_11_Longitudinal Testing/longitudinal_testing_cleaned.csv"))






