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



#----------------------------Dataset loading----------------------------#####
#from Box

bl <- read_stata(paste0(user_path(),"/2_deidentified/1_2_Followup_cleaned.dta"))

r1 <- read_stata(paste0(user_path(),"/2_deidentified/1_5_followup_R1_cleaned.dta"))

r2 <- read_stata(paste0(user_path(),"/2_deidentified/1_6_followup_R2_cleaned.dta"))

r3 <- read_stata(paste0(user_path(),"/2_deidentified/1_7_followup_R3_cleaned.dta"))

idx <- read_xlsx(paste0(user_path(),"/5_lab data/idexx/raw/_India ILC_IDEXX_data_MASTER.xlsx"))

abr <- read_xlsx(paste0(user_path(),"/5_lab data/idexx/raw/_India ILC_ABR_data_MASTER.xlsx"), skip = 1)

idexx_r2 <- read_csv(paste0(user_path(),"/5_lab data/idexx/raw/_India ILC_IDEXX_data_R2.csv"))

idexx_r3 <- read_csv(paste0(user_path(),"/5_lab data/idexx/raw/_India ILC_IDEXX_data_R3.csv"))

village_details <- read_sheet("https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1710429467")


#-------------------------Village information cleaning-----------------------#

#Making village IDs compatible to the surveys
village_details <- village_details%>%
  mutate(village_ID = `Village codes`)

village_details$village_ID <- as.character(village_details$village_ID)

#Making Panchayat village variable compatible with the existing data
village_details <- village_details%>%
  mutate(`Panchat village` = Panchayat)

#Making block variable compatible with existing data
village_details <- village_details%>%
  rename(block = "Block")

#Making village_name variable compatible
village_details <- village_details%>%
  rename(village_name = "Village")


###-------------------Defining overall functions------------------------####

labelmaker <- function(x){
  z <- colnames(x)
  for(i in z){
    labels <-  val_labels(x[i])
    if(is.na(labels) == FALSE){
      x[i] <- to_label(x[i])
      
    }
  }
  return(x)
}


###--------------------Baseline Data Cleaning------------------------------#####


###GENERAL DATA CLEANING##################################################
#Filtering out test data from training, based on village IDs
unique(bl$R_FU_unique_id_1)
bl <- bl%>%
  filter(!(R_FU_unique_id_1 == 88888 |
             R_FU_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting bl data key variables for WQ testing
bl <- bl%>%
  dplyr::select(R_FU_unique_id_1, R_FU_unique_id_2, R_FU_unique_id_3, unique_id_num, R_FU_r_cen_village_name_str, R_FU_consent, R_FU_water_source_prim, R_FU_primary_water_label, R_FU_water_qual_test, R_FU_wq_stored_bag, R_FU_stored_bag_source, R_FU_sample_ID_stored, R_FU_bag_ID_stored, R_FU_fc_stored, R_FU_wq_chlorine_storedfc_again, R_FU_tc_stored, R_FU_wq_chlorine_storedtc_again, R_FU_sample_ID_tap, R_FU_bag_ID_tap, R_FU_fc_tap, R_FU_wq_tap_fc_again, R_FU_tc_tap, R_FU_wq_tap_tc_again, R_FU_instancename)

#Assigning more meaningful variable names
bl <- bl%>%
  rename_all(~stringr::str_replace(.,"R_FU_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
bl$village_ID <- as.character(bl$village_ID)
bl <- left_join(bl, village_details, by = "village_ID")

xx <- bl%>%
  filter(is.na(block) == TRUE)

#Filtering out Bada Alubadi village since it has been replaced
bl <- bl%>%
  filter(!(village == "Badaalubadi"))%>%
  filter(!(village == "Haathikambha"))

#Filtering out HHs that did not consent
bl <- bl%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)




#Correcting one sample ID in BL dataset
for(i in (1:length(bl$unique_id))){
  if(bl$unique_id[i] == 50301106013){
    bl$sample_ID_stored[i] = 20290
  }
}


#Averaging chlorine data across two tests
bl <- bl%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(bl, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(bl, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(bl, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(bl, starts_with("tc_tap")), na.rm = TRUE))

bl$fc_stored_avg <- round(bl$fc_stored_avg, digits = 3)
bl$fc_tap_avg <- round(bl$fc_tap_avg, digits = 3)
bl$tc_stored_avg <- round(bl$tc_stored_avg, digits = 3)
bl$tc_tap_avg <- round(bl$tc_tap_avg, digits = 3)


#Renaming assignment names
bl$assignment <- factor(bl$assignment)
bl$assignment <- fct_recode(bl$assignment,
                            "Control" = "C", 
                            "Treatment" = "T")

#Using labelmaker function to change variable answer labels
bl <- labelmaker(bl)


#Changing primary source labels
bl <- bl%>%
  mutate(prim_source = NA)
bl$prim_source <- bl$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani)",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )


#Storing idx dataset to idexx -- just to have a dataset for BL data. Lazy coding.
idexx <- idx

#PREPARING IDEXX DATA##########################################################
#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
bl_idexx <- bl%>%
  pivot_longer(cols = c(sample_ID_stored, sample_ID_tap), values_to = "sample_ID", names_to = "sample_type")

#Noting duplicate samples
idexx <- idexx%>%
  mutate(duplicate = ifelse(comments == "DUPLICATE", 1, 0))%>%
  replace_na(duplicate, value = 0)

#Dropping lab blanks, field blanks, and duplicates
idexx <- idexx%>%
  filter(sample_ID != "Lab Blank",
         sample_ID != "Field Blank")%>%
  filter(duplicate < 1)

#Checking IDs which do not match between survey data and lab data
idexx_ids <- idexx$sample_ID
bl_sample_ids <- bl_idexx$sample_ID
idexx_id_check <- idexx%>%
  filter(!(sample_ID %in% bl_sample_ids))


#combining idexx results to survey results
bl_idexx$sample_ID <- as.character(bl_idexx$sample_ID)
idexx <- inner_join(idexx, bl_idexx, by = "sample_ID")
abr$sample_ID <- as.character(abr$sample_ID)
abr <- inner_join(abr, bl_idexx, by = "sample_ID")

#checking duplicate IDs
x <- idexx%>%
  count(sample_ID)%>% 
  filter(n > 1)
#x_BL <- idexx%>%
 # filter(sample_ID %in% x$sample_ID)

#10237 is a duplicate that was incorrectly recorded during R1. 
#Remove Bag ID 90274 from the baseline data
#Need to check why this ID was listed in the BL followup survey data
idexx <- idexx%>%
  filter(bag_ID != 90274)

#creating new variable to tell the sample type
idexx$sample_type <- idexx$sample_type%>%
  factor()%>%
  fct_recode("Stored" = "sample_ID_stored",
             "Tap" = "sample_ID_tap")
abr$sample_type <- abr$sample_type%>%
  factor()%>%
  fct_recode("Stored" = "sample_ID_stored",
             "Tap" = "sample_ID_tap")


#Renaming assignment names
idexx$assignment <- factor(idexx$assignment)
idexx$assignment <- fct_recode(idexx$assignment,
                               "Control" = "C", 
                               "Treatment" = "T")

#Renaming Panchayat village variable
idexx <- idexx%>%
  mutate(panchayat_village = `Panchat village`)

#Calculating MPN for each IDEXX test
idexx <- idexx%>%
  mutate(cf_95lo = quantify_95lo(y_large, y_small, "qt-2000"),
         cf_mpn  = quantify_mpn(y_large, y_small, "qt-2000"),
         cf_95hi = quantify_95hi(y_large, y_small, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))


idexx <- idexx%>%
  mutate(ec_95lo = quantify_95lo(f_large, f_small, "qt-2000"),
         ec_mpn  = quantify_mpn(f_large, f_small, "qt-2000"),
         ec_95hi = quantify_95hi(f_large, f_small, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))


abr <- abr%>%
  mutate(cf_95lo = quantify_95lo(y_large, y_small, "qt-2000"),
         cf_mpn  = quantify_mpn(y_large, y_small, "qt-2000"),
         cf_95hi = quantify_95hi(y_large, y_small, "qt-2000"))

abr <- abr%>%
  mutate(ec_95lo = quantify_95lo(f_large, f_small, "qt-2000"),
         ec_mpn  = quantify_mpn(f_large, f_small, "qt-2000"),
         ec_95hi = quantify_95hi(f_large, f_small, "qt-2000"))

#Checking cases of NA for total coliform and e coli
#xx <- idexx%>%
# filter(is.na(cf_mpn) == TRUE)
#xxx <- idexx%>%
# filter(y_large == 49 & y_small == 48)


#Adding presence/absence data
idexx <- idexx%>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

idexx <- idexx%>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

idexx <- idexx%>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

idexx <- idexx%>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


abr <- abr%>%
  mutate(cf_pa = case_when(
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

abr <- abr%>%
  mutate(ec_pa = case_when(
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

abr <- abr%>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

abr <- abr%>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))

#log transforming data
idexx <- idexx%>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))


#Adding in WHO risk levels
idexx <- idexx%>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))

#Adding long-transformed data for baseline ABR
abr <- abr%>%
  mutate(ec_log = log(ec_mpn, base = 10))%>%
  mutate(cf_log = log(cf_mpn, base = 10))

#Code for writing/updating final file
#Writing files to lab_data and final folders
write_csv(idexx,paste0(user_path(),"/5_lab data/idexx/cleaned/BL_idexx_master_cleaned.csv"))
write_csv(idexx,paste0(user_path(),"/3_final/BL_idexx_master_cleaned.csv"))






###-----------------------Round 1 data cleaning--------------------####


###GENERAL DATA CLEANING##################################################
#Filtering out test data from training, based on village IDs
unique(r1$R_FU1_unique_id_1)
r1 <- r1%>%
  filter(!(R_FU1_unique_id_1 == 88888 |
             R_FU1_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r1 data key variables for WQ testing
r1 <- r1%>%
  dplyr::select(R_FU1_unique_id_1, R_FU1_unique_id_2, R_FU1_unique_id_3, unique_id_num, R_FU1_r_cen_village_name_str, R_FU1_consent, R_FU1_water_source_prim, R_FU1_primary_water_label, R_FU1_water_qual_test, R_FU1_wq_stored_bag, R_FU1_stored_bag_source, R_FU1_sample_ID_stored, R_FU1_bag_ID_stored, R_FU1_fc_stored, R_FU1_wq_chlorine_storedfc_again, R_FU1_tc_stored, R_FU1_wq_chlorine_storedtc_again, R_FU1_sample_ID_tap, R_FU1_bag_ID_tap, R_FU1_fc_tap, R_FU1_wq_tap_fc_again, R_FU1_tc_tap, R_FU1_wq_tap_tc_again, R_FU1_instancename)

#Assigning more meaningful variable names
r1 <- r1%>%
  rename_all(~stringr::str_replace(.,"R_FU1_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r1$village_ID <- as.character(r1$village_ID)
r1 <- left_join(r1, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r1 <- r1%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)

#Correcting sample IDs in R1 dataset? Need to check
#for(i in (1:length(r1$unique_id))){
# if(r1$unique_id[i] == 50301106013){
#  r1$sample_ID_stored[i] = 20290
#  }
#}

#Renamed control vs treatment assignment
r1$assignment <- factor(r1$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
xx <- r1%>%
  filter(fc_stored > 2.0 |
           fc_stored_2 > 2.0 |
           fc_tap > 2.0 |
           fc_tap_2 > 2.0 |
           tc_stored > 2.0 |
           tc_stored_2 > 2.0 |
           tc_tap > 2.0 |
           tc_tap_2 > 2.0)

r1 <- r1 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))

#Averaging chlorine data across two tests
r1 <- r1%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r1, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r1, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r1, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r1, starts_with("tc_tap")), na.rm = TRUE))

r1$fc_stored_avg <- round(r1$fc_stored_avg, digits = 3)
r1$fc_tap_avg <- round(r1$fc_tap_avg, digits = 3)
r1$tc_stored_avg <- round(r1$tc_stored_avg, digits = 3)
r1$tc_tap_avg <- round(r1$tc_tap_avg, digits = 3)






#Storing raw idx data to idexx_r1. Lazy coding. Much of this should be processed once.
#Will update more later
idexx_r1 <- idx

#PREPARING IDEXX DATA##########################################################
#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
r1_for_idexx <- r1%>%
  pivot_longer(cols = c(sample_ID_stored, sample_ID_tap), values_to = "sample_ID", names_to = "sample_type")

#Noting duplicate samples
idexx_r1 <- idexx_r1%>%
  mutate(duplicate = ifelse(comments == "DUPLICATE", 1, 0))%>%
  replace_na(duplicate, value = 0)

#Dropping lab blanks, field blanks, and duplicates
idexx_r1 <- idexx_r1%>%
  filter(sample_ID != "Lab Blank",
         sample_ID != "Field Blank")%>%
  filter(duplicate < 1)

#Noting borehole water sample and dropping it
idexx_r1 <- idexx_r1%>%
  mutate(solar_water = ifelse((sample_ID == 20258), 1, 0))%>% #Sample ID for stored water from private borewell
  replace_na(solar_water, value = 0)%>%
  filter(solar_water == 0)

#Checking IDs which do not match between survey data and lab data
#this is where baseline samples are dropped from the idx dataset
idexx_ids <- idexx_r1$sample_ID
r1_sample_ids <- r1_for_idexx$sample_ID
idexx_id_check <- idexx_r1%>%
  filter(!(sample_ID %in% r1_sample_ids))


#General cleaning checks
#Counting duplicate ids in R1 data
#idexx_id_check <- r1_for_idexx%>%
 # count(sample_ID)%>% 
  #filter(n > 1) #238 instances of NA
#idexx_id_check <- idexx_r1%>%
 # count(sample_ID)%>% 
  #filter(n > 1) #6 cases of duplicate IDs -- I have since removed them, see Github Issues

#Filtering out duplicate IDs to understand why they exist
#idexx_check <- idexx_r1%>%
 # filter(sample_ID %in% idexx_id_check$sample_ID)

#Checked the handwritten data
#Cases with duplicate IDs were corrected in the raw data and listed on Github issues




#combining idexx results to survey results
r1_for_idexx$sample_ID <- as.character(r1_for_idexx$sample_ID)
idexx_r1 <- inner_join(idexx_r1, r1_for_idexx, by = "sample_ID")
#abr$sample_ID <- as.character(abr$sample_ID)
#abr <- inner_join(abr, bl_idexx, by = "sample_ID")


#creating new variable to tell the sample type
idexx_r1$sample_type <- idexx_r1$sample_type%>%
  factor()%>%
  fct_recode("Stored" = "sample_ID_stored",
             "Tap" = "sample_ID_tap")

#Renaming panchayat variable
idexx_r1 <- idexx_r1%>%
  mutate(panchayat_village = `Panchat village`)


#Calculating MPN for each IDEXX test
idexx_r1 <- idexx_r1%>%
  mutate(cf_95lo = quantify_95lo(y_large, y_small, "qt-2000"),
         cf_mpn  = quantify_mpn(y_large, y_small, "qt-2000"),
         cf_95hi = quantify_95hi(y_large, y_small, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

idexx_r1 <- idexx_r1%>%
  mutate(ec_95lo = quantify_95lo(f_large, f_small, "qt-2000"),
         ec_mpn  = quantify_mpn(f_large, f_small, "qt-2000"),
         ec_95hi = quantify_95hi(f_large, f_small, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
idexx_r1 <- idexx_r1%>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

idexx_r1 <- idexx_r1%>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

idexx_r1 <- idexx_r1%>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

idexx_r1 <- idexx_r1%>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
idexx_r1 <- idexx_r1%>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0


#Adding in WHO risk levels
idexx_r1 <- idexx_r1%>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))


#Writing/updating final csv file
write_csv(idexx_r1,paste0(user_path(),"/5_lab data/idexx/cleaned/R1_idexx_master_cleaned.csv"))
write_csv(idexx_r1,paste0(user_path(),"/3_final/R1_idexx_master_cleaned.csv"))





###--------------Round 2 data cleaning----------------------------------#####

###GENERAL DATA CLEANING##################################################
#Filtering out test data from training, based on village IDs
unique(r2$R_FU2_unique_id_1)
r2 <- r2%>%
  filter(!(R_FU2_unique_id_1 == 88888 |
             R_FU2_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r2 data key variables for WQ testing
r2 <- r2%>%
  dplyr::select(R_FU2_unique_id_1, R_FU2_unique_id_2,
                R_FU2_unique_id_3, unique_id_num, R_FU2_r_cen_village_name_str,
                R_FU2_consent, R_FU2_water_source_prim,
                R_FU2_primary_water_label, R_FU2_water_qual_test,
                R_FU2_wq_stored_bag, R_FU2_stored_bag_source,
                R_FU2_sample_ID_stored, R_FU2_bag_ID_stored, 
                R_FU2_fc_stored, R_FU2_wq_chlorine_storedfc_again,
                R_FU2_tc_stored, R_FU2_wq_chlorine_storedtc_again, 
                R_FU2_sample_ID_tap, R_FU2_bag_ID_tap, R_FU2_fc_tap, 
                R_FU2_wq_tap_fc_again, R_FU2_tc_tap, R_FU2_wq_tap_tc_again,
                R_FU2_instancename)

#Assigning more meaningful variable names
r2 <- r2%>%
  rename_all(~stringr::str_replace(.,"R_FU2_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r2$village_ID <- as.character(r2$village_ID)
r2 <- left_join(r2, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r2 <- r2%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)

#Correcting sample IDs in r2 dataset? Need to check
#for(i in (1:length(r2$unique_id))){
# if(r2$unique_id[i] == 50301106013){
#  r2$sample_ID_stored[i] = 20290
#  }
#}

#Renamed control vs treatment assignment
r2$assignment <- factor(r2$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
#xx <- r2%>%
 # filter(fc_stored > 2.0 |
  #         fc_stored_2 > 2.0 |
   #        fc_tap > 2.0 |
    #       fc_tap_2 > 2.0 |
     #      tc_stored > 2.0 |
      #     tc_stored_2 > 2.0 |
       #    tc_tap > 2.0 |
        #   tc_tap_2 > 2.0)
#write_csv(xx, "C:/Users/jerem/Box/India Water project/2_Pilot/Data/0-data cleaning/chlorine_data_review_20240229.csv")

r2 <- r2 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))

#Averaging chlorine data across two tests
r2 <- r2%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r2, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r2, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r2, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r2, starts_with("tc_tap")), na.rm = TRUE))

r2$fc_stored_avg <- round(r2$fc_stored_avg, digits = 3)
r2$fc_tap_avg <- round(r2$fc_tap_avg, digits = 3)
r2$tc_stored_avg <- round(r2$tc_stored_avg, digits = 3)
r2$tc_tap_avg <- round(r2$tc_tap_avg, digits = 3)

#




#PREPARING IDEXX DATA##########################################################
#Renaming variables
idexx_r2 <- idexx_r2%>%
  mutate(village_ID = as.character(village))%>%
  mutate(sample_ID = unique_sample_id)

#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
r2_for_idexx <- r2%>%
  pivot_longer(cols = c(sample_ID_stored, sample_ID_tap), 
               values_to = "sample_ID", names_to = "sample_type")


#Noting duplicate samples
idexx_r2 <- idexx_r2%>%
 mutate(duplicate = ifelse(end_comments == "DUPLICATE", 1, 0))%>%
 replace_na(duplicate, value = 0)

#Noting lab blank and field blanks
idexx_r2 <- idexx_r2%>%
  mutate(lab_blank = ifelse((end_comments == "Lab Blank" | 
                               end_comments == "Lab blank" |
                               end_comments == "This is LAB BLANK results" |
                               end_comments == "Tray count reviewed by PRASHANT KUMAR PANDA and This is LAB BLANK")
                            & sample_ID == 0, 1, 0))%>%
  replace_na(lab_blank, value = 0)

idexx_r2 <- idexx_r2%>%
  mutate(field_blank = ifelse((end_comments == "Field Blank" | 
                                 end_comments == "Field blank" |
                                 end_comments == "This is FIELD BLANK")
                              & sample_ID == 0, 1, 0))%>%
  replace_na(field_blank, value = 0)




#Dropping lab blanks, field blanks, and duplicates
idexx_r2 <- idexx_r2%>%
 filter(lab_blank != 1,
       field_blank != 1)%>%
filter(duplicate < 1)

#Checking IDs which do not match between survey data and lab data
#idexx_ids <- idexx_r2$sample_ID
#r2_sample_ids <- r2_for_idexx$sample_ID
#idexx_id_check <- idexx_r2%>%
# filter(!(sample_ID %in% r2_sample_ids))


#combining idexx results to survey results
r2_for_idexx$sample_ID <- as.numeric(r2_for_idexx$sample_ID)
idexx_r2 <- left_join(idexx_r2, r2_for_idexx, by = "sample_ID")

#Fixing variable names after the join
idexx_r2 <- idexx_r2%>%
  rename(village_ID = "village.x")%>%
  rename(village = "village.y")%>%
  #rename(assignment = "assignment.y")%>%
  dplyr::select(-c("village_ID.x", "village_ID.y"))

#Renaming panchayat variable
idexx_r2 <- idexx_r2%>%
  mutate(panchayat_village = `Panchat village`)


#creating new variable to tell the sample type
idexx_r2 <- idexx_r2%>%
  mutate(sample_type = ifelse((sample_ID < 11000 & sample_ID > 9000), "Tap", 
                              ifelse((sample_ID > 19000 & sample_ID < 21000), "Stored", "Blank")))


#Other way using survey data
#idexx_r2$sample_type <- idexx_r2$sample_type%>%
#factor()%>%
#fct_recode("Stored" = "sample_ID_stored",
#"Tap" = "sample_ID_tap")

#abr$sample_type <- abr$sample_type%>%
# factor()%>%
#fct_recode("Stored" = "sample_ID_stored",
#          "Tap" = "sample_ID_tap")

#Calculating MPN for each IDEXX test
idexx_r2 <- idexx_r2%>%
  mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_mpn  = quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

idexx_r2 <- idexx_r2%>%
  mutate(ec_95lo = quantify_95lo(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_mpn  = quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_95hi = quantify_95hi(large_c_flurosce, small_c_flurosce, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
idexx_r2 <- idexx_r2%>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

idexx_r2 <- idexx_r2%>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

idexx_r2 <- idexx_r2%>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

idexx_r2 <- idexx_r2%>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
idexx_r2 <- idexx_r2%>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
idexx_r2 <- idexx_r2%>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))


#Writing/updating final csv file
write_csv(idexx_r2,paste0(user_path(),"/5_lab data/idexx/cleaned/R2_idexx_master_cleaned.csv"))
write_csv(idexx_r2,paste0(user_path(),"/3_final/R2_idexx_master_cleaned.csv"))




###-------------------------Round 3 data cleaning------------------------#####


###GENERAL DATA CLEANING##################################################
#Filtering out test data from training, based on village IDs
unique(r3$R_FU3_unique_id_1)
r3 <- r3%>%
  filter(!(R_FU3_unique_id_1 == 88888 |
             R_FU3_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r3 data key variables for WQ testing
r3 <- r3%>%
  dplyr::select(R_FU3_unique_id_1, R_FU3_unique_id_2, R_FU3_unique_id_3, unique_id_num, R_FU3_r_cen_village_name_str, submission_date, R_FU3_consent, R_FU3_water_source_prim, R_FU3_primary_water_label, R_FU3_water_qual_test, R_FU3_wq_stored_bag, R_FU3_stored_bag_source, R_FU3_sample_ID_stored, R_FU3_bag_ID_stored, R_FU3_fc_stored, R_FU3_wq_chlorine_storedfc_again, R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again, R_FU3_sample_ID_tap, R_FU3_bag_ID_tap, R_FU3_fc_tap, R_FU3_wq_tap_fc_again, R_FU3_tc_tap, R_FU3_wq_tap_tc_again, R_FU3_instancename)

#Assigning more meaningful variable names
r3 <- r3%>%
  rename_all(~stringr::str_replace(.,"R_FU3_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r3$village_ID <- as.character(r3$village_ID)
r3 <- left_join(r3, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r3 <- r3%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)


#Renamed control vs treatment assignment
r3$assignment <- factor(r3$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
xx <- r3%>%
  filter(fc_stored > 2.0 |
           fc_stored_2 > 2.0 |
           fc_tap > 2.0 |
           fc_tap_2 > 2.0 |
           tc_stored > 2.0 |
           tc_stored_2 > 2.0 |
           tc_tap > 2.0 |
           tc_tap_2 > 2.0)

#write_csv(xx, "C:/Users/jerem/Box/India Water project/2_Pilot/Data/0-data cleaning/chlorine_data_review_20240229.csv")

r3 <- r3 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))

#Averaging chlorine data across two tests
r3 <- r3%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r3, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r3, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r3, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r3, starts_with("tc_tap")), na.rm = TRUE))

r3$fc_stored_avg <- round(r3$fc_stored_avg, digits = 3)
r3$fc_tap_avg <- round(r3$fc_tap_avg, digits = 3)
r3$tc_stored_avg <- round(r3$tc_stored_avg, digits = 3)
r3$tc_tap_avg <- round(r3$tc_tap_avg, digits = 3)

#


#PREPARING IDEXX DATA##########################################################
#Adding village name column
village_ID <- village_details%>%
  dplyr::select(village_name, village_ID, assignment)
idexx_r3 <- idexx_r3%>%
  mutate(village_ID = as.character(village))%>%
  mutate(sample_ID = unique_sample_id)

idexx_r3 <- left_join(idexx_r3, village_ID, by = "village_ID")


#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
r3_for_idexx <- r3%>%
  pivot_longer(cols = c(sample_ID_stored, sample_ID_tap), values_to = "sample_ID", names_to = "sample_type_survey")

#Noting duplicate samples
#idexx_r3 <- idexx_r3%>%
# mutate(duplicate = ifelse(comments == "DUPLICATE", 1, 0))%>%
#replace_na(duplicate, value = 0)


#creating new variable to tell the sample type
idexx_r3 <- idexx_r3%>%
  mutate(sample_type = ifelse((sample_ID < 11000 & sample_ID > 9000), "Tap", 
                              ifelse((sample_ID > 19000 & sample_ID < 21000), "Stored", "Blank")))



#Noting lab blank and field blanks
idexx_r3 <- idexx_r3%>%
  mutate(lab_blank = ifelse((end_comments == "Lab Blank" | 
                               end_comments == "Lab blank" |
                               end_comments == "This is LAB BLANK results" |
                               sample_type == "Blank") #This line doesn't differentiate between field blank and lab blank
                            & sample_ID == 0, 1, 0))%>%
  replace_na(lab_blank, value = 0)

idexx_r3 <- idexx_r3%>%
  mutate(field_blank = ifelse((end_comments == "Field Blank" | 
                                 end_comments == "Field blank" |
                                 end_comments == "This is FIELD BLANK" |
                                 sample_type == "Blank") #This line doesn't differentiate between field blank and lab blank
                              & sample_ID == 0, 1, 0))%>%
  replace_na(field_blank, value = 0)

#Noting solar tank water
idexx_r3 <- idexx_r3%>%
  mutate(solar_water = ifelse((end_comments == "Solar water" | 
                                 end_comments == "Solar Tank Water"), 1, 0))%>%
  replace_na(solar_water, value = 0)

#Dropping lab blanks, field blanks, and duplicates
idexx_r3 <- idexx_r3%>%
  filter(lab_blank != 1,
         field_blank != 1)


#Dropping lab blanks, field blanks, and duplicates
#idexx_r3 <- idexx_r3%>%
# filter(sample_ID != "Lab Blank",
#       sample_ID != "Field Blank")%>%
#filter(duplicate < 1)

#Checking IDs which do not match between survey data and lab data
#idexx_ids <- idexx_r3$sample_ID
#r3_sample_ids <- r3_for_idexx$sample_ID
#idexx_id_check <- idexx_r3%>%
# filter(!(sample_ID %in% r3_sample_ids))%>%
#filter(sample_ID != 0)
#x <- r3%>%
# filter(village_ID == idexx_id_check$village)
#Checking which villages have missing IDEXX data
#xx <- unique(idexx_r3$village_name.x)
#village_check <- r3_for_idexx%>%
#filter(!(village_name %in% xx))%>%
#filter(sample_ID != 0)

#Updating sample ID for 10141


#combining idexx results to survey results
r3_for_idexx$sample_ID <- as.numeric(r3_for_idexx$sample_ID)
idexx_r3 <- left_join(idexx_r3, r3_for_idexx, by = "sample_ID")


#Fixing variable names after the join
idexx_r3 <- idexx_r3%>%
  rename(village_ID = "village.x")%>%
  rename(village = "village.y")%>%
  rename(assignment = "assignment.y")%>%
  dplyr::select(-c("village_ID.x", "village_ID.y", "village_name.x", "village_name.y", "assignment.x"))

#Renaming panchayat variable
idexx_r3 <- idexx_r3%>%
  mutate(panchayat_village = `Panchat village`)



#Other way using survey data
#idexx_r3$sample_type <- idexx_r3$sample_type%>%
#factor()%>%
#fct_recode("Stored" = "sample_ID_stored",
#"Tap" = "sample_ID_tap")

#abr$sample_type <- abr$sample_type%>%
# factor()%>%
#fct_recode("Stored" = "sample_ID_stored",
#          "Tap" = "sample_ID_tap")

#Calculating MPN for each IDEXX test
idexx_r3 <- idexx_r3%>%
  mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_mpn  = quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

idexx_r3 <- idexx_r3%>%
  mutate(ec_95lo = quantify_95lo(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_mpn  = quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_95hi = quantify_95hi(large_c_flurosce, small_c_flurosce, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
idexx_r3 <- idexx_r3%>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

idexx_r3 <- idexx_r3%>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

idexx_r3 <- idexx_r3%>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

idexx_r3 <- idexx_r3%>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
#Making nondetects == 0.5 MPN/100 mL so the data can be log-transformed#
idexx_r3 <- idexx_r3%>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0


#Adding in WHO risk levels
idexx_r3 <- idexx_r3%>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))


#Dropping ABR samples
idexx_r3 <- idexx_r3%>%
  filter(abr == 0)

#Writing/updating final file
write_csv(idexx_r3,paste0(user_path(),"/5_lab data/idexx/cleaned/R3_idexx_master_cleaned.csv"))
write_csv(idexx_r3,paste0(user_path(),"/3_final/R3_idexx_master_cleaned.csv"))






#COMBINING DATASETS --------------------------------------------------------

#Combining Datasets
#Selecting key variables and transforming the dataset
idexx_comb <- idexx%>%
  dplyr::select(assignment, unique_id, village, block, panchayat_village, 
                sample_ID, bag_ID_tap, bag_ID_stored, sample_type, cf_mpn, ec_mpn,
                cf_95hi, cf_95lo, ec_95hi, ec_95lo,
                cf_pa_binary, ec_pa_binary, cf_pa, ec_pa, cf_log, ec_log)%>%
  mutate(data_round = "BL")%>%
  mutate(pooled_round = "BL")

idexx_r1_comb <- idexx_r1%>%
  dplyr::select(assignment, unique_id, village, block, panchayat_village, 
                sample_ID, bag_ID_tap, bag_ID_stored, sample_type, cf_mpn, ec_mpn,
                cf_95hi, cf_95lo, ec_95hi, ec_95lo,
                cf_pa_binary, ec_pa_binary, cf_pa, ec_pa, cf_log, ec_log)%>%  
  mutate(data_round = "R1")%>%
  mutate(pooled_round = "FU")

idexx_r2_comb <- idexx_r2%>%
  dplyr::select(assignment, unique_id, village, block, panchayat_village, 
                sample_ID, bag_ID_tap, bag_ID_stored, sample_type, cf_mpn, ec_mpn,
                cf_95hi, cf_95lo, ec_95hi, ec_95lo,
                cf_pa_binary, ec_pa_binary, cf_pa, ec_pa, cf_log, ec_log)%>%
  mutate(data_round = "R2")%>%
  mutate(pooled_round = "FU")

idexx_r3_comb <- idexx_r3%>%
  dplyr::select(assignment, unique_id, village, block, panchayat_village, 
                sample_ID, bag_ID_tap, bag_ID_stored, sample_type, cf_mpn, ec_mpn,
                cf_95hi, cf_95lo, ec_95hi, ec_95lo,
                cf_pa_binary, ec_pa_binary, cf_pa, ec_pa, cf_log, ec_log)%>%
  mutate(data_round = "R3")%>%
  mutate(pooled_round = "FU")

#combining
idexx_comb <- rbind(idexx_comb, idexx_r1_comb, idexx_r2_comb, idexx_r3_comb)

#Writing/updating final file
write_csv(idexx_comb,paste0(user_path(),"/5_lab data/idexx/cleaned/POOLED_idexx_master_cleaned.csv"))
write_csv(idexx_comb,paste0(user_path(),"/3_final/POOLED_idexx_master_cleaned.csv"))








