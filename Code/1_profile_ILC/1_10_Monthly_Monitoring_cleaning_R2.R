#------------------------------------------------ 
# title: "Code for Checks for High-frequency Follow Ups"
# author: "Jeremy Lowe, Archi Gupta"
# modified date: "2024-07-19"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------

#Jeremy to Archi -- Commenting out package install so it doesn't run every time
# install.packages("RSQLite")
# install.packages("haven")
# install.packages("expss")
# install.packages("stargazer")
# install.packages("Hmisc")
# install.packages("labelled")
# install.packages("data.table")
# install.packages("haven")
# install.packages("remotes")
# # Attempt using devtools package
# install.packages("devtools")
# install.packages("geosphere")
# 
# #please note that starpolishr pacakge isn't available on CRAN so it has to be installed from github using rmeotes pacakage 
# install.packages("remotes")
# remotes::install_github("ChandlerLutz/starpolishr")
# install.packages("ggrepel")
# install.packages("reshape2")

#Archi to Jeremy: If you dont have this already plz donwload it to convert dates proeprly 
#install.packages("lubridate")


#install.packages("remotes")
#remotes::install_github("jknappe/quantitray") #Quantitray package installation

# load the libraries
library(haven)
library(data.table)
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
library(tidyverse)
library(Hmisc)
library(ggplot2)
library(labelled)
library(starpolishr)
library(geosphere)
library(leaflet)
library(ggrepel)
library(reshape2)
library(quantitray)

#library(xtable)



#------------------------ setting user path ----------------------------------------


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
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/"
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
    github = "C:/Users/jerem/Documents/i-h2o-india/Code"
  } 
  else if (user == "Archi Gupta") {
    github = "C:/Users/Archi Gupta/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

github <- github_path()


# setting overleaf directory
overleaf <- function() {
  user <- Sys.info()["user"]
  if (user == "asthavohra") {
    overleaf = "/Users/asthavohra/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user=="akitokamei"){
    overleaf = "/Users/akitokamei/Library/CloudStorage/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user == "Archi Gupta") {
    overleaf = "C:/Users/Archi Gupta/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user == "jerem"){
    overleaf = "C:/Users/jerem/Dropbox/Apps/Overleaf/Everything document -ILC/"
  }  
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}



#Jeremy to add rest of the paths for his directory 

pre_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/99_Preload/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = pre_path())



temp_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/99_temp/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = temp_path())


Final_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/3_final/" 
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = Final_path())


raw_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/1_raw/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = raw_path())



DI_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == "Archi Gupta"){
    path = "C:/Users/Archi Gupta/Box/Data/2_deidentified/"
  } 
  else if (user == "jerem"){
    path = "C:/Users/jerem/Box/India Water project/2_Pilot/Data/2_deidentified/"
  } 
  
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = DI_path())




#----------------------------------Loading Data-------------------------------

#Monthly Surveys - ms
ms <- read_csv(paste0(user_path(), "1_raw/Chlorine and IDEXX Monitoring Survey R2_WIDE.csv"))
#View(ms)

#Key village details
village_details <- read_sheet("https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1710429467")

#View(village_details)

#IDEXX results
idexx <- read_csv(paste0(user_path(), "1_raw/IDEXX Results Reporting - Aug 2024_WIDE.csv"))

#-------------------------------Cleaning Village Details for Joining----------


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

#Adding anonymous village code
village_details <- village_details%>%
  mutate(village_code = case_when(village_name == "Asada" ~ "AS",
                                  village_name == "Mukundpur" ~ "MU",
                                  village_name == "Gopi Kankubadi" ~ "GO",
                                  village_name == "Bichikote" ~ "BI",
                                  village_name == "Badabangi" ~ "BA",
                                  village_name == "Nathma" ~ "NAT",
                                  village_name == "Tandipur" ~ "TA",
                                  village_name == "Birnarayanpur" ~ "BN",
                                  village_name == "Naira" ~ "NAI",
                                  village_name == "Karnapadu" ~ "KA"
                                  
  ))

View(village_details)

write_csv(village_details, paste0(user_path(), "/3_final/village_details.csv"))


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



#----------------------------Monthly Follow up Cleaning-----------------------

#Archi to Jeremy- I am commenting this out
#ms <- ms%>%
#rename(sample_ID_stored = "stored_sample_id",
#sample_ID_tap = "tap_sample_id")

names(ms)

#Adding village details to Monthly Survey
ms <- ms%>%
  mutate(village_name = R_Cen_village_name_str) #Renaming to easier variable name

#Left join village_details and ms
ms <- left_join(ms, village_details, by = "village_name")



#------------------------------------------------------------------------
# Drop rows where resp_available != 1
#------------------------------------------------------------------------

#ms_consent <- subset(ms, consent == 1)
#View(ms_consent)

#------------------------------------------------------------------------
#checking for duplicate UIDs
#------------------------------------------------------------------------

# Check for duplicates in the unique_id column
duplicates <- ms[duplicated(ms$unique_id) | duplicated(ms$unique_id, fromLast = TRUE), ]

# Display the duplicate rows
print(duplicates)

# Alternatively, to get only the unique_id values that are duplicated
duplicate_ids <- ms$unique_id[duplicated(ms$unique_id)]
print(duplicate_ids)

#------------------------------------------------------------------------
#MANUAL CLEANING OF SAMPLE IDs
#------------------------------------------------------------------------
# Replace the value
#View(ms)
names(ms)




#------------------------------------------------------------------------
#CHECKING DUPLICATES IN SAMPLE ID AND TAP ID 
#------------------------------------------------------------------------

#stored sample ID 

# Filter out rows where stored_sample_id is NA

#We dont wnat NA to be flagged as a duplicate that is why
ms_filtered <- ms %>%
  filter(!is.na(stored_sample_id))

duplicates <- ms_filtered[duplicated(ms_filtered$stored_sample_id) | duplicated(ms_filtered$stored_sample_id, fromLast = TRUE), ]

print(duplicates)

#stored bag ID 
ms_filtered <- ms %>%
  filter(!is.na(stored_bag_id))

duplicates <- ms_filtered[duplicated(ms_filtered$stored_bag_id) | duplicated(ms_filtered$stored_bag_id, fromLast = TRUE), ]

print(duplicates)

#tap sample ID
ms_filtered <- ms %>%
  filter(!is.na(tap_sample_id))

duplicates <- ms_filtered[duplicated(ms_filtered$tap_sample_id) | duplicated(ms_filtered$tap_sample_id, fromLast = TRUE), ]

print(duplicates)

#tap bag ID 
ms_filtered <- ms %>%
  filter(!is.na(tap_bag_id))

duplicates <- ms_filtered[duplicated(ms_filtered$tap_bag_id) | duplicated(ms_filtered$tap_bag_id, fromLast = TRUE), ]

print(duplicates)


#-------------------------------------------------------------------------
#checking if again variable is not similar to its respective UID
#--------------------------------------------------------------------
#stored_sample_id  stored_sample_id_again




# Group by unique_id and flag mismatches where stored_sample_id is not equal to stored_sample_id_again
ms_flagged <- ms %>%
  filter(!is.na(stored_sample_id) & !is.na(stored_sample_id_again)) %>%
  group_by(unique_id) %>%
  mutate(flag_mismatch = ifelse(stored_sample_id != stored_sample_id_again, TRUE, FALSE)) %>%
  ungroup() %>%
  filter(flag_mismatch)

# Print the flagged observations
View(ms_flagged)


#tap_sample_id #tap_sample_id_again
# Group by unique_id and flag mismatches where stored_sample_id is not equal to stored_sample_id_again
ms_flagged <- ms %>%
  filter(!is.na(tap_sample_id) & !is.na(tap_sample_id_again)) %>%
  group_by(unique_id) %>%
  mutate(flag_mismatch = ifelse(tap_sample_id != tap_sample_id_again, TRUE, FALSE)) %>%
  ungroup() %>%
  filter(flag_mismatch)

# Print the flagged observations

ms_flag_v <- ms_flagged %>% select(tap_sample_id, tap_sample_id_again, flag_mismatch, resp_available, replacement, unique_id, village_name, enum_name_label, stored_sample_id, stored_sample_id_again)
View(ms_flag_v)


#enumerator made a data entry error and by mistake put 510406 for this UID 

ms$tap_sample_id[ms$unique_id == "40202113028" & ms$tap_sample_id == 510406] <- 10406

ms_view <- ms %>% select(tap_sample_id, tap_sample_id_again, resp_available, replacement, unique_id, village_name, enum_name_label, stored_sample_id, stored_sample_id_again)
#View(ms_view)
correct_replacement <- all(ms$tap_sample_id[ms$unique_id == "40202113028"] == 10406)
if (correct_replacement) {
  cat("The replacement is correct.\n")
} else {
  cat("The replacement is incorrect. Some values do not match 510406.\n")
}

#--------------------Cleaning monthly survey data/transforming variables----------------------------

#Assigning more meaningful variable names
ms <- ms%>%
  rename(fc_tap_avg = "tap_water_fc")%>%
  rename(fc_stored_avg = "stored_water_fc")%>%
  rename(tc_tap_avg = "tap_water_tc")%>%
  rename(tc_stored_avg = "stored_water_tc")



#---------------------IDEXX Data Cleaning------------------------------------


#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
ms_idexx <- ms%>%
  pivot_longer(cols = c(stored_sample_id, tap_sample_id), values_to = "sample_ID", names_to = "sample_type")


ms_idexx_v <- ms_idexx %>% select(sample_ID, sample_type, unique_id, village_name)
  
#View(ms_idexx_v)



#------------------------------------------------------------------------
#Generating IDEXX Data Variables (MPN, Presence/Absence, Log transformation, etc.)
#------------------------------------------------------------------------



#Noting duplicate samples
#Not needed because we are not running duplicates
# idexx <- idexx%>%
#   mutate(duplicate = ifelse(end_comments == "DUPLICATE", 1, 0))%>%
#   tidyr::replace_na(duplicate, value = 0)

#Renaming sample_ID variable
idexx <- idexx%>%
  rename(sample_ID = "unique_sample_id")

View(idexx)

#Noting blank samples
idexx <- idexx%>%
  mutate(blank = ifelse(sample_ID == 0, 1, 0))

#Dropping lab blanks, field blanks, and duplicates
idexx <- idexx%>%
  filter(blank != 1)#%>%
#filter(duplicate != 1) #No duplicates, not running


#Checking IDs which do not match between survey data and lab data
idexx_ids <- idexx$sample_ID
ms_sample_ids <- ms_idexx$sample_ID
idexx_id_check <- idexx%>%
  filter(!(sample_ID %in% ms_sample_ids))

print(idexx_id_check)

merged_data <- idexx %>%
  left_join(ms_idexx_v, by = c("sample_ID"))

# Checking for mismatches
mismatch_check <- merged_data %>%
  filter(is.na(unique_id)) # This will filter out rows where unique_id is missing after the join

print(mismatch_check)

View(merged_data)


#combining idexx results to survey results
ms_idexx$sample_ID <- as.character(ms_idexx$sample_ID)
idexx$sample_ID <- as.character(idexx$sample_ID)

View(ms_idexx)
View(idexx)

idexx <- inner_join(idexx, ms_idexx, by = "sample_ID")




#creating new variable to tell the sample type
idexx$sample_type <- idexx$sample_type%>%
  factor()%>%
  fct_recode("Stored" = "stored_sample_id",
             "Tap" = "tap_sample_id")

#Renaming bag ID variables
idexx <- idexx%>%
  rename("bag_ID_tap" = tap_bag_id)%>%
  rename("bag_ID_stored" = stored_bag_id)

#need to relabel idexx variables


#Renaming assignment names
idexx$assignment <- factor(idexx$assignment)
idexx$assignment <- fct_recode(idexx$assignment,
                               "Control" = "C", 
                               "Treatment" = "T")

# #Renaming Panchayat village variable
# idexx <- idexx%>%
#   mutate(panchayat_village = `Panchat village`)

#Calculating MPN for each IDEXX test
#Calculating MPN for each IDEXX test
idexx <- idexx %>%
  mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_mpn  = ifelse(is.na(quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000")), 2419,
                          quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000")),
         cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))


#idexx <- idexx%>%
#mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
#cf_mpn  = quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000"),
#cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))%>%
#mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))


idexx <- idexx%>%
  mutate(ec_95lo = quantify_95lo(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_mpn  = ifelse(is.na(quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000")), 2419,
                          quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000")),
         ec_95hi = quantify_95hi(large_c_flurosce, small_c_flurosce, "qt-2000"))



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


#log transforming data
idexx <- idexx%>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
idexx <- idexx%>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))







#-------------------------Writing Cleaned Final Datasets----------------------

#IDEXX Results
#Writing files to lab_data and final folders
write_csv(idexx,paste0(user_path(),"/5_lab data/idexx/cleaned/idexx_monthly_master_cleaned_R2.csv"))
write_csv(idexx,paste0(user_path(),"/3_final/idexx_monthly_master_cleaned_R2.csv"))


#Monthly Survey
write_csv(ms, paste0(user_path(), "/3_final/1_10_monthly_follow_up_cleaned_R2.csv"))





