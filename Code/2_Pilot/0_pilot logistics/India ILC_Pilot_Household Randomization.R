#India ILC Project
#Pilot Field Logistics
#Author: Jeremy Lowe
#Created: 8/25/23

#Household Randomization Script
#This script randomly selects households to be surveyed during follow-up survey rounds
################################################################################
#Package loading
################################################################################
library(rsurveycto)
library(httr)
library(lubridate)
library(quantitray)
library(sjmisc)
library(knitr)
library(kableExtra)
library(googlesheets4)
library(googledrive)
library(readxl)
library(experiment)
library(tidyverse)

################################################################################
#DATA DOWNLOAD
################################################################################
#Data is pulled from SurveyCTO and uploaded as an Excel file using a separate R code

#From Google Drive -- Excel
# drive_auth()
# files <- drive_find(n_max = 1, pattern = "India ILC_Pilot_Household Tracking.xlsx", type = "spreadsheet")
# hh <- drive_download(files)%>%
#   read_excel()

#from Google Drive -- Google Sheets
#gs4_auth()
#sheet_url <- "https://docs.google.com/spreadsheets/d/1pQISSkcqa1VQYoaWnfXaXMHUWYs4nhqYCcxviQqUn3Y/edit#gid=0"
#hh <- read_sheet(sheet_url, sheet = 3)
#hh <- gs4_find(sheet_url)

#Raw data: From Box
setwd(box_path)
ilc <- read_csv("1_raw/0_field logistics/1_raw/India ILC_Pilot_Household Tracking_raw.csv")

#Previously randomized HHs
setwd(box_path)
hh_randomization <- read_csv("1_raw/0_field logistics/3_household tracking/India ILC_Pilot_Household Tracking_full.csv")


################################################################################
#RANDOMIZATION PREP
################################################################################
#Selecting key variables for household tracking
#and renaming variables so they line up with the existing household tracking sheet
ilc <- ilc%>%
  dplyr::select(unique_ID,
         A1_resp_name,
         A6_phone_num,
         A8_address,
         A9_landmark, 
         district_name, 
         block_name, 
         gp_name, 
         village_name, 
         hamlet_name, 
         A3_malehead_name, 
         A7_phone_oth, 
         A4_oldmale_name, 
         A9_GPS, 
         starttime
  )%>%
  rename(household_ID = unique_ID,
         participant_name = A1_resp_name,
         phone = A6_phone_num,
         second_name = A3_malehead_name,
         backup_phone = A7_phone_oth,
         elder_male_name = A4_oldmale_name,
         address = A8_address,
         landmark = A9_landmark,
         district = district_name,
         block = block_name,
         village =village_name,
         gps = A9_GPS,
         baseline_census_date = starttime)%>%
  mutate(village_ID = village) #Need to create a variable that assigns village names to the village IDs generated in surveycto


#Conducting randomization of households in each village to be visited each round
#IMPORTANT: Only conduct randomization once for a village. Do not overwrite
#           any prior randomization that has already been done!


#Filter for villages that need to have HHs randomized for follow-up visits
#Allows for us to select villages that need to be randomized at different times
#Based on the data collection schedule

#Manual
#ID_selected <- c(11321, 11111)

#Automatic based on HH IDs that have not been randomized yet
#village_ID variable is the IDs that have not yet been randomized
IDs_existing <- hh_randomization$village_ID%>%
  unique()

village_ID <- ilc%>%
  filter(!(village_ID %in% IDs_existing))%>% 
  #This serves as a survey data check to confirm the ID is in the dataset 
  dplyr::select(village_ID)%>%
  unique()

#Filter for villages that only have pregnant/expecting women or children under 5


#initializing empty tibble to store random numbers
hh_randomization <- tibble(household_ID = character(),
                           participant_name = character(),
                           phone = numeric(),
                           second_name = character(),
                           backup_phone = character(),
                           elder_male_name = character(),
                           address = character(),
                           landmark = character(),
                           district = numeric(),
                           block = numeric(),
                           gp_name = numeric(),
                           hamlet_name = character(),
                           village = numeric(),
                           village_ID = numeric(),
                           gps = character(),
                           assignment = numeric(),
                           baseline_census_date = dmy(),
                           selected_for_baseline_survey = numeric() ,
                           selected_for_baseline_WQ_sample = numeric(),
                           baseline_survey_date = dmy(),
                           selected_for_follow_up_1 = numeric() ,
                           selected_for_follow_up_1_WQ_sample = numeric(),
                           follow_up_1_date = dmy(),
                           selected_for_follow_up_2 = numeric() ,
                           selected_for_follow_up_2_WQ_sample = numeric(),
                           follow_up_2_date = dmy(),
                           selected_for_follow_up_3 = numeric() ,
                           selected_for_follow_up_3_WQ_sample = numeric(),
                           follow_up_3_date = character())




################################################################################
#HOUSEHOLD RANDOMIZATION
################################################################################
#Selecting village for randomization ----
#HHs will be randomized one village at a time
for (i in village_ID$village_ID){
  hh_select <- ilc%>%
    filter(village_ID == i)
  
  #Filter for HHs that only have pregnant/expecting women or children under 5
  #and report using the JJM tap as their primary drinking water source
  #hh_select <- hh_select%>%
  #  filter(preg_moth == 1 | child_under5 == 1)%>%
  #  filter(primary_source == "JJM Tap")
  # UNCOMMENT LINES ABOVE BEFORE RUNNING
  ###############################################################################
  
  #Assigning random numbers to HHs, 
  #numbers 1-10 will be selected for HH follow-up visits
  set.seed(123)
  random_numbers_0 <-  sample(1:length(hh_select$household_ID))
  random_numbers_1 <-  sample(1:length(hh_select$household_ID))
  random_numbers_2 <-  sample(1:length(hh_select$household_ID))
  random_numbers_3 <-  sample(1:length(hh_select$household_ID))
  #Assigning random numbers
  hh_select <- hh_select%>%
    mutate(selected_for_baseline_survey = random_numbers_0)%>%
    mutate(selected_for_baseline_WQ_sample = random_numbers_0)%>%
    mutate(selected_for_follow_up_1 = random_numbers_1)%>%
    mutate(selected_for_follow_up_1_WQ_sample = random_numbers_1)%>%
    mutate(selected_for_follow_up_2 = random_numbers_2)%>%
    mutate(selected_for_follow_up_2_WQ_sample = random_numbers_2)%>%
    mutate(selected_for_follow_up_3 = random_numbers_3)%>%
    mutate(selected_for_follow_up_3_WQ_sample = random_numbers_3)
  #Joining random numbers to main dataset
  hh_randomization <- hh_randomization%>%
    bind_rows(hh_select)
  
}


#Setting sheet path directory to reference correct file
#Jeremy's
setwd(box_path)
#Updating overall household tracking sheet
#This sheet will be used as a backup list by the field manager in case any HHs cannot be visited
write_csv(hh_randomization, file = "1_raw/0_field logistics/2_randomization list/India ILC_Pilot_Household Tracking_randomized.csv",
          append = TRUE
          #, col_names = TRUE #Needed for initializing the dataset so there are column names
)
#For Google Sheets
#sheet_append(hh_randomization, ss = sheet_url, sheet = 2)


#Assigning 1 for HHs that should be visited in the follow-up round
#based on if their random number is 1-10
hh_randomization <- hh_randomization%>%
  mutate(selected_for_baseline_survey = 
           ifelse(selected_for_baseline_survey <= 10, 1, 0))%>%
  mutate(selected_for_baseline_WQ_sample = 
           ifelse(selected_for_baseline_WQ_sample <= 4, 1, 0))%>%
  mutate(selected_for_follow_up_1 = 
           ifelse(selected_for_follow_up_1 <= 10, 1, 0))%>%
  mutate(selected_for_follow_up_1_WQ_sample = 
           ifelse(selected_for_follow_up_1_WQ_sample <= 4, 1, 0))%>%
  mutate(selected_for_follow_up_2 = 
           ifelse(selected_for_follow_up_2 <= 10, 1, 0))%>%
  mutate(selected_for_follow_up_2_WQ_sample = 
           ifelse(selected_for_follow_up_2_WQ_sample <= 4, 1, 0))%>%
  mutate(selected_for_follow_up_3 = 
           ifelse(selected_for_follow_up_3 <= 10, 1, 0))%>%
  mutate(selected_for_follow_up_3_WQ_sample = 
           ifelse(selected_for_follow_up_3_WQ_sample <= 4, 1, 0))
#Setting sheet path
setwd(box_path)
#Appending rows to existing main household tracker
write_csv(hh_randomization, append = TRUE, file = "1_raw/0_field logistics/3_household tracking/India ILC_Pilot_Household Tracking_full.csv"
          #, col_names = TRUE #Needed for initializing the dataset so there are column names
)

#Writing preload file for Akito's SurveyCTO case management
#This smaller dataset is meant to be plugged into the SurveyCTO Follow-up Surveys
#To allow for easier tracking of IDs by enumerators
hh_preload <- hh_randomization%>%
  mutate(info = paste(participant_name, "_", phone,"_", second_name,"_", 
                      backup_phone, "_", elder_male_name,"_", address, "_", 
                      landmark, "_", village))%>%
  select(household_ID, info)


#Setting sheet path
setwd(box_path)
#Appending rows to existing main household tracker
write_csv(hh_preload, append = TRUE, file = "1_raw/0_field logistics/4_SurveyCTO preload/followup_preload.csv"
          #, col_names = TRUE #Needed for initializing the dataset so there are column names
)


