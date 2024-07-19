#------------------------------------------------ 
# title: "Code for Checks for High-frequency Follow Ups"
# author: "Jeremy Lowe, Archi Gupta"
# modified date: "2024-07-19"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------


library(rsurveycto)
library(expss)
library(labelled)
library(httr)
library(lubridate)
library(quantitray)
library(sjmisc)
library(knitr)
library(kableExtra)
library(readxl)
library(experiment)
library(stargazer)
library(readxl)
library(haven)
library(googlesheets4)
library(ggsignif)
library(patchwork)
library(table1)
library(gtsummary)
library(gt)
library(webshot2)
library(clubSandwich)
library(sandwich)
library(lmtest)
library(broom)
library(tidyverse)



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
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

github <- github_path()

#Setting overleaf
overleaf_path <- function() {
  # Return a hardcoded path to Overleaf that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  #
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    
  } 
  else if (user=="akitokamei"){
    
    overleaf = "/Users/akitokamei/Dropbox/Apps/Overleaf"
    
  } 
  else if (user == "jerem"){
    overleaf = "C:/Users/jerem/DropBox/Apps/Overleaf"
  }  
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}

overleaf <- overleaf_path()



#----------------------------------Loading Data-------------------------------

#Monthly Surveys - ms
ms <- read_csv(paste0(user_path(), "1_raw/Chlorine and IDEXX Monitoring Survey_WIDE.csv"))

#Key village details
village_details <- read_sheet("https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1710429467")


#IDEXX results
idexx <- read_csv(paste0(user_path(), "1_raw/IDEXX Results Reporting - July 2024_WIDE.csv"))


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


ms <- ms%>%
  rename(sample_ID_stored = "stored_sample_id",
         sample_ID_tap = "tap_sample_id")



#---------------------IDEXX Data Cleaning------------------------------------


#PREPARING IDEXX DATA##########################################################
#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
ms_idexx <- ms%>%
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
ms_sample_ids <- ms_idexx$sample_ID
idexx_id_check <- idexx%>%
  filter(!(sample_ID %in% ms_sample_ids))


#combining idexx results to survey results
ms_idexx$sample_ID <- as.character(bl_idexx$sample_ID)
idexx <- inner_join(idexx, ms_idexx, by = "sample_ID")

#checking duplicate IDs
x <- idexx%>%
  count(sample_ID)%>% 
  filter(n > 1)


#creating new variable to tell the sample type
idexx$sample_type <- idexx$sample_type%>%
  factor()%>%
  fct_recode("Stored" = "sample_ID_stored",
             "Tap" = "sample_ID_tap")

#Renaming assignment names
idexx$assignment <- factor(idexx$assignment)
idexx$assignment <- fct_recode(idexx$assignment,
                               "Control" = "C", 
                               "Treatment" = "T")

# #Renaming Panchayat village variable
# idexx <- idexx%>%
#   mutate(panchayat_village = `Panchat village`)

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


#Code for writing/updating final file
#Writing files to lab_data and final folders
write_csv(idexx,paste0(user_path(),"/5_lab data/idexx/cleaned/idexx_monthly_master_cleaned.csv"))
write_csv(idexx,paste0(user_path(),"/3_final/idexx_monthly_master_cleaned.csv"))





