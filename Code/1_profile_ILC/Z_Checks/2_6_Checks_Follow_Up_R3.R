#------------------------------------------------ 
# title: "Code for Checks for Follow Up HH Survey"
# author: "Astha Vohra"
# modified date: "2023-02-04"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------#

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
library(tidyverse)
library(Hmisc)
library(ggplot2)
library(labelled)
library(data.table)
#library(xtable)

#------------------------ setting user path ----------------------------------------#




user_path <- function() {
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
    path = "C:/Users/Archi Gupta/Box/Data/"
  } 
  else if (user == ""){
    path = ""
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
  else if (user == "Archi Gupta") {
    github = "C:/Users/Archi Gupta/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/"
  } 
  else if (user == "") {
    github = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

# setting github directory
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
  else if (user == "") {
    overleaf = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}

#------------------------ Load the data ----------------------------------------#

df.temp <- read_dta(paste0(user_path(),"2_deidentified/1_7_Followup_R3_cleaned.dta" ))
df.preload <- read_xlsx(paste0(user_path(),"99_Preload/FollowupR3_preload_5 Apr 2024.xlsx"))
#------------------------ Apply the labels for variables  ----------------------------------------#

temp.labels <- lapply(df.temp , var_lab)

#create a data with labels
df.label <- as.data.frame(t(as.data.frame(do.call(cbind, temp.labels)))) 
df.label<- tibble::rownames_to_column(df.label) 
df.label <- df.label %>% rename(variable = rowname, label = V1)  
auto_generated_labels <- c(df.label$variable)

#include labels given manually 
df.label.manual <- read_xlsx(paste0(user_path(),"4_other/R_code_HH_Survey_labels.xlsx"))

df.var <- as.data.frame(names(df.temp)) #List of variables in the data

# assign labels to variable that were generated
df.label.manual <- df.label.manual %>% mutate(new_var = ifelse(Variable %in% auto_generated_labels, 0,1)) %>% 
  filter(new_var == 1) %>% select(-new_var) %>% rename(variable = Variable, label = Label)

df.label <- rbind(df.label, df.label.manual)
# create a function that assigns the label to appropriate variable


#create a date variable
df.temp$datetime <- strptime(df.temp$R_FU3_starttime, format = "%Y-%m-%d %H:%M:%S")

df.temp$date <- as.IDate(df.temp$datetime) 

#filter out the testing dates
df.temp <- df.temp 

#------------------------ Keep consented cases ----------------------------------------#

df.temp.consent <- df.temp[which(df.temp$R_FU3_consent==1) ,]


#------------------------ Assign the correct treatment to villages ----------------------------------------#

df.temp.consent <- df.temp.consent %>% mutate(Treatment = ifelse(R_FU3_r_cen_village_name_str %in%
                                                                   c("Birnarayanpur","Nathma", "Badabangi","Naira", "Bichikote", "Karnapadu","Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada"), "T", "C"))


#------------------------ Progress table ----------------------------------------#

submissions <- df.temp  %>% select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate(Submission=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)

resp_available <- df.temp %>%  filter(R_FU3_resp_available == 1 & R_FU3_replacement == 0 ) %>% 
  select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate("OG Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)
resp_notavailable <- df.temp %>%  filter(R_FU3_resp_available != 1  ) %>% 
  select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate("NOT Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)

consented <- df.temp  %>% filter(R_FU3_consent == 1) %>% select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate(Consented=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)

refused <- df.temp %>% filter(R_FU3_consent != 1) %>% select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate(Refused=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)

replacements <- df.temp %>%  filter( R_FU3_replacement == 1 ) %>% 
  select(R_FU3_r_cen_village_name_str) %>%
  group_by(R_FU3_r_cen_village_name_str) %>% mutate(Replacements=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU3_r_cen_village_name_str)

df.progress <- left_join(submissions,resp_available)%>% left_join(resp_notavailable) %>% left_join(replacements) %>% 
  left_join(consented) %>% left_join(refused)  %>% 
  rename(Village = R_FU3_r_cen_village_name_str)
df.progress[is.na(df.progress)]<-0

Total <- df.progress %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))
Total$Village <- "Total"
df.progress<- rbind(df.progress, Total)

#output to tex 
stargazer(df.progress, summary=F, title= "Overall Progress: Follow Up Round 1 HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Progress_HH_Survey_R3.tex"))




#df.temp$date <- format(as.Date(df.temp$R_FU3_starttime, "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d")



#------------------------ Distribution of surveys by dates & villages ----------------------------------------#
date.plt<- df.temp %>% filter(R_FU3_consent == 1) %>% filter(date >= as.Date("2024-02-15")) %>%
  group_by( R_FU3_r_cen_village_name_str, date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()


# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-1),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_FU3_r_cen_village_name_str)
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_date_village_R3.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)


#------------------------ Distribution of surveys by Enumerator, dates & villages ----------------------------------------#

date.plt<- df.temp %>% filter(R_FU3_consent == 1)%>% filter(date >= as.Date("2024-02-15")) %>%
  group_by( R_FU3_r_cen_village_name_str,R_FU3_enum_name_label,  date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()


# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-c(1, 2)),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_FU3_r_cen_village_name_str, Enumerator =R_FU3_enum_name_label  )
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_enum_date_village_R3.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)


#------------------------  Enumerator: duration for each section and count of DK ----------------------------------------#


# 1. Duration by enumerators

resp_hh_location_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15"))  %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Locating Respondent" = round(mean(FU3_locatehh_dur_min),1)) %>% ungroup()
consent_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Consent" = round(mean(FU3_consent_dur_min),1)) %>% ungroup()
secA_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Sec A" = round(mean(FU3_secA_dur_min),1)) %>% ungroup()
secB_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Sec B" = round(mean(FU3_secB_dur_min),1))  %>% ungroup()
secC_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Sec C" = round(mean(FU3_secC_dur_min),1))%>% ungroup()
secE_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Sec E" = round(mean(FU3_secE_dur_min),1))  %>% ungroup()
total_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Overall" = round(mean(R_FU3_duration_end/60),1))  %>% ungroup()

df.duration.enum <- left_join(resp_hh_location_dur_enum,consent_dur_enum) %>% left_join(secA_dur_enum) %>% 
  left_join(secB_dur_enum) %>% 
  left_join(secC_dur_enum) %>% 
  left_join(secE_dur_enum) %>%
  left_join(total_dur_enum) 
df.duration.enum <- df.duration.enum %>% rename(Enumerator = R_FU3_enum_name_label )
star.out <- stargazer(df.duration.enum, summary=F, title= "Duraction by section Follow Up R3 HH Survey by enumerator",float=F,rownames = F,covariate.labels=NULL)
star.out <- sub("cccccccc", "lccccccc", star.out)
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Duration_enum_HH_Survey_R3.tex"))


# Value for water quality test has changed now in Round 1 of Follow Up HH survey, compared to Baseline HH Survey, with
# R_FU3_water_qual_test == 1 but whether only chlorine testing or both chlorine and sample collection dependent on R_FU3_ecoli_yn and R_FU3_available_jjm

df.temp.consent <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% mutate(FU3_test_type = ifelse(R_FU3_water_qual_test == 1 & R_FU3_ecoli_yn == 0, 1, 
                                                                                                               ifelse(R_FU3_water_qual_test == 1 & R_FU3_ecoli_yn == 1 &
                                                                                                                        (R_FU3_available_jjm == 1 | R_FU3_available_jjm == 2),2,
                                                                                                                      ifelse(R_FU3_water_qual_test == 1 & R_FU3_ecoli_yn == 1 & (R_FU3_available_jjm == 3 | R_FU3_available_jjm == 4), 1, 0))))
# Duration of water quality testing by type of test
secE_cl_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%  filter(FU3_test_type == 1) %>% 
  mutate(FU3_secE_dur_min  = ifelse(FU3_secE_dur_min<0 , NA, FU3_secE_dur_min)) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Chlorine Testing"= round(mean(FU3_secE_dur_min, na.rm = T),1))   %>% ungroup()

secE_both_dur_enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%  filter(FU3_test_type == 2) %>% 
  mutate(FU3_secE_dur_min  = ifelse(FU3_secE_dur_min<0 , NA, FU3_secE_dur_min)) %>% 
  group_by(R_FU3_enum_name_label) %>%
  dplyr:: summarise("Both Testing"= round(mean(FU3_secE_dur_min, na.rm = T),1)) %>% 
  ungroup()

df.duration.wq.enum <- left_join(secE_cl_dur_enum,secE_both_dur_enum) 
df.duration.wq.enum <- df.duration.wq.enum %>% rename(Enumerator = R_FU3_enum_name_label )
star.out <- stargazer(df.duration.wq.enum, summary=F, title= "Duraction by WQ Test Baseline HH Survey by enumerator",float=F,rownames = F,covariate.labels=NULL)
star.out <- sub("ccc", "lcc", star.out)
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Duration_WQ_enum_HH_Survey_R3.tex"))

#2. Count of Dont Know by enumerators 

df.dk.enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%
  group_by(R_FU3_enum_name_label) %>% select(-R_FU3_fc_stored,-R_FU3_tc_stored, -R_FU3_wq_chlorine_storedfc_again, -R_FU3_wq_chlorine_storedtc_again,
                                             -R_FU3_fc_tap, -R_FU3_tc_tap,-R_FU3_wq_tap_fc_again,-R_FU3_wq_tap_tc_again, -R_FU3_r_cen_a39_phone_name_1, - R_FU3_r_cen_a39_phone_name_2) %>%
  summarise_all(~sum(. == 999)) %>% 
  transmute(R_FU3_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_FU3_enum_name_label, "Count of DK" = sum_dk)

stargazer(df.dk.enum, summary=F, title= "Count of DK by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_DK_enum_HH_Survey_R3.tex"))

#3. Count of 888 by enumerators for 24-7 filter

df.888.enum <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%
  group_by(R_FU3_enum_name_label) %>%
  summarise_all(~sum(. == 888)) %>% 
  transmute(R_FU3_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_FU3_enum_name_label, "Count of 888" = sum_dk)

stargazer(df.888.enum, summary=F, title= "Count of DK by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_888_enum_HH_Survey_R3.tex"))

#------------------------  Enumerator: Displaying chlorine test data for each village ------------------------  


bl <- df.temp.consent %>% filter(date >= as.Date("2024-02-15"))

###Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU3_fc_tap,R_FU3_wq_tap_fc_again , R_FU3_tc_tap,R_FU3_wq_tap_tc_again, R_FU3_fc_stored, R_FU3_wq_chlorine_storedfc_again, R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again), 
               values_to = "chlorine_concentration", names_to = "chlorine_test_type") %>% 
  mutate(chlorine_test_type = ifelse(chlorine_test_type =="R_FU3_fc_tap", "Running FC", 
                                     ifelse(chlorine_test_type == "R_FU3_wq_tap_fc_again", "Running FC- Again",
                                            ifelse(chlorine_test_type =="R_FU3_tc_tap", "Running TC", 
                                                   ifelse(chlorine_test_type == "R_FU3_wq_tap_tc_again", "Running TC- Again", 
                                                          ifelse(chlorine_test_type == "R_FU3_fc_stored", "Stored FC",
                                                                 ifelse(chlorine_test_type == "R_FU3_wq_chlorine_storedfc_again", "Stored FC- Again", 
                                                                        ifelse(chlorine_test_type == "R_FU3_tc_stored", "Stored TC",
                                                                               ifelse(chlorine_test_type == "R_FU3_wq_chlorine_storedtc_again", "Stored TC- Again" , "Missing")))))))))
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE)

#Frequency of cases above 0.1 by enumerator
chlorine_check <- chlorine%>%
  filter(chlorine_concentration > 0.10 & chlorine_concentration != 999)%>% 
  dplyr::select(R_FU3_enum_name_label,R_FU3_r_cen_village_name_str) %>% 
  group_by(R_FU3_enum_name_label, R_FU3_r_cen_village_name_str) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, Enumerator = R_FU3_enum_name_label) %>% 
  mutate(Case_above_0.1 = n()) %>% ungroup()  %>% unique() 
stargazer(chlorine_check, summary=F, title= "Count of Chlorine reading greater than 0.10",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Chlorine_high_HH_Survey_R3.tex"))



#count of errors by enumerators and by colorimeter  

df.error.enum <- chlorine %>%   filter(chlorine_concentration == 999) %>% 
  dplyr::select(R_FU3_enum_name_label, R_FU3_r_cen_village_name_str, R_FU3_colorimeter_id, R_FU3_colorimeter_type,chlorine_test_type) %>% 
  group_by(R_FU3_enum_name_label,chlorine_test_type) %>%
  mutate(sum_dk = n()) %>% 
  rename(Enumerator = R_FU3_enum_name_label, Count_of_Errors =sum_dk, Village = R_FU3_r_cen_village_name_str, Colorimeter_ID = R_FU3_colorimeter_id, Colorimeter_Type = R_FU3_colorimeter_type) %>% 
  unique()



stargazer(df.error.enum, summary=F, title= "Count of Errors by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_count_error_enum_HH_Survey_R3.tex"))

bl <- df.temp.consent

###Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
df.sample <- bl%>%
  pivot_longer(cols = c("R_FU3_wq_stored_bag", "R_FU3_wq_running_bag"), values_to = "yes_no", names_to = "sample_type")

#Removing NAs from no respondent being available
df.sample <- df.sample%>%
  filter(is.na(yes_no) == FALSE) %>% dplyr::select(R_FU3_enum_name_label, R_FU3_r_cen_village_name_str, sample_type, yes_no)
#Frequency of sample collection by enumerator
df.sample.stored.enum <- df.sample%>% filter(sample_type == "R_FU3_wq_stored_bag") %>% 
  group_by(R_FU3_enum_name_label, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU3_enum_name_label, Count_of_Sample) %>% 
  rename(Enumerator = R_FU3_enum_name_label, "Count-Stored Water" = Count_of_Sample ) %>% 
  unique() 

df.sample.running.enum <- df.sample%>% filter(sample_type == "R_FU3_wq_running_bag") %>% 
  group_by(R_FU3_enum_name_label, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>%
  dplyr::select(R_FU3_enum_name_label, Count_of_Sample) %>% 
  rename(Enumerator = R_FU3_enum_name_label, "Count-Running Water" = Count_of_Sample ) %>% 
  unique()
df.sample.enum <- left_join(df.sample.stored.enum, df.sample.running.enum)
stargazer(df.sample.enum, summary=F, title= "Count of Sample collection by enum",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_sample_enum_HH_Survey_R3.tex"))


df.chlorine <- bl%>%
  pivot_longer(cols = c("R_FU3_fc_stored", "R_FU3_fc_tap", "R_FU3_tc_stored", "R_FU3_tc_tap"), values_to = "yes_no", names_to = "sample_type")
#Frequency of sample collection by enumerator
df.chlorine.vil.fc.stored <- df.chlorine%>% filter(sample_type == "R_FU3_fc_stored") %>% 
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-FCl Stored" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.tc.stored <- df.chlorine%>% filter(sample_type == "R_FU3_tc_stored") %>% 
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-TCl Stored" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.fc.tap <- df.chlorine%>% filter(sample_type == "R_FU3_fc_tap") %>% 
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-FCl Running" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.tc.tap <- df.chlorine%>% filter(sample_type == "R_FU3_tc_tap") %>%
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-TCl Running" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil <-  left_join(df.chlorine.vil.fc.stored, df.chlorine.vil.tc.stored) 
df.chlorine.vil <-  left_join(df.chlorine.vil, df.chlorine.vil.fc.tap) 
df.chlorine.vil <-  left_join(df.chlorine.vil, df.chlorine.vil.tc.tap) 

stargazer(df.chlorine.vil, summary=F, title= "Count of  Chlorine Tests by village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_chlorine_village_HH_Survey_R3.tex"))

#------------------------  Overall checks ------------------------  

#1 Duration of each section
resp_hh_location_dur <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% filter(FU3_locatehh_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_locatehh_dur_min),1), min = round(min(FU3_locatehh_dur_min),1), max = round(max(FU3_locatehh_dur_min),1))  %>%
  mutate(variable = "Locating HH")
consent_dur <- df.temp.consent %>%  filter(FU3_consent_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_consent_dur_min),1), min = round(min(FU3_consent_dur_min),1), max = round(max(FU3_consent_dur_min),1) ) %>%
  mutate(variable = "Consent")
secA_dur <- df.temp.consent %>% filter(FU3_secA_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_secA_dur_min),1), min = round(min(FU3_secA_dur_min),1), max = round(max(FU3_secA_dur_min),1) ) %>%
  mutate(variable = "Sec A: WASH Access")
secB_dur <- df.temp.consent %>% filter(FU3_secB_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_secB_dur_min),1), min = round(min(FU3_secB_dur_min),1), max = round(max(FU3_secB_dur_min),1) ) %>%
  mutate(variable = "Sec B: Government Tap")
secC_dur <- df.temp.consent %>% filter(FU3_secC_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_secC_dur_min),1), min = round(min(FU3_secC_dur_min),1), max = round(max(FU3_secC_dur_min),1) ) %>%
  mutate(variable = "Sec C: Chlorination Perceptions")
secE_dur <- df.temp.consent %>% filter(FU3_secE_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU3_secE_dur_min),1), min = round(min(FU3_secE_dur_min),1), max = round(max(FU3_secE_dur_min),1) ) %>%
  mutate(variable = "Sec E: Water Quality testing")

overall_mean <- df.temp.consent %>% filter(date >= as.Date("2024-02-12")) %>% filter(R_FU3_duration_end > 0) %>%
  dplyr:: summarise(mean = round(mean(R_FU3_duration_end/60),1), min = round(min(R_FU3_duration_end/60),1), max = round(max(R_FU3_duration_end/60),1) ) %>%
  mutate(variable = "Overall")

df.duration <- bind_rows(resp_hh_location_dur,consent_dur, secA_dur,secB_dur, secC_dur, secE_dur, overall_mean)

df.duration <- df.duration %>% select(variable , mean, min, max) %>% mutate(mean = round(mean, 3), min = round(min, 3), max = round(max, 3)) %>%   rename("Duration\ Section" = variable, "Mean \ (in mins)" = mean, "Min \ (in mins)" = min, "Max \ (in mins)" = max ) 
stargazer(df.duration, summary=F, title= "Duraction by section Baseline HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Duration_HH_Survey_R3.tex"))



#2 Section on Water Quality Testing, separate duration by whether sample was collected or not? 

secE_dur <- df.temp.consent %>% filter(date >= as.Date("2024-02-12")) %>% mutate(FU3_test_type = ifelse(R_FU3_water_qual_test == 1 & R_FU3_ecoli_yn == 0 &
                                                                                                          (R_FU3_available_jjm == 3 | R_FU3_available_jjm == 4), 1, 
                                                                                                        ifelse(R_FU3_water_qual_test == 1 & R_FU3_ecoli_yn == 1 &
                                                                                                                 (R_FU3_available_jjm == 1 | R_FU3_available_jjm == 2),2, 0)))

secE_dur_chlorine <- secE_dur %>% filter(FU3_test_type == 1) %>% 
  mutate(FU3_secE_dur_min  = ifelse(FU3_secE_dur_min<0 , NA, FU3_secE_dur_min)) %>% 
  dplyr:: summarise(mean = round(mean(FU3_secE_dur_min, na.rm = T),1), min = round(min(FU3_secE_dur_min,  na.rm = T),1), max = round(max(FU3_secE_dur_min,  na.rm = T),1) ) %>%
  mutate(variable = "Chlorine Testing")
secE_dur_both <- df.temp.consent %>% filter(FU3_test_type == 2) %>% 
  mutate(FU3_secE_dur_min  = ifelse(FU3_secE_dur_min<0 , NA, FU3_secE_dur_min)) %>% 
  dplyr:: summarise(mean = round(mean(FU3_secE_dur_min, na.rm = T),1), min = round(min(FU3_secE_dur_min,  na.rm = T),1), max = round(max(FU3_secE_dur_min,  na.rm = T),1) ) %>%
  mutate(variable = "Both Testing")

df.duration.wq <- bind_rows(secE_dur_chlorine,secE_dur_both)

df.duration.wq <- df.duration.wq %>% select(variable , mean, min, max) %>% mutate(mean = round(mean, 3), min = round(min, 3), max = round(max, 3)) %>%   rename("Duration\ Section" = variable, "Mean \ (in mins)" = mean, "Min \ (in mins)" = min, "Max \ (in mins)" = max ) 
stargazer(df.duration.wq, summary=F, title= "Duraction for Water Quality Test -  Baseline HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Duration_WQ_HH_Survey_R3.tex"))


#3 Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
df.sample <- bl%>%
  pivot_longer(cols = c("R_FU3_wq_stored_bag", "R_FU3_wq_running_bag"), values_to = "yes_no", names_to = "sample_type")

#Removing NAs from no respondent being available
df.sample <- df.sample%>%
  filter(is.na(yes_no) == FALSE) %>% dplyr::select(R_FU3_enum_name_label, R_FU3_r_cen_village_name_str, sample_type, yes_no)

#Frequency of sample collection
df.count.stored <- df.sample%>% filter(sample_type == "R_FU3_wq_stored_bag") %>%
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str,  "Count-Stored Water" = Count_of_Sample ) %>% 
  unique()
df.count.running <- df.sample%>% filter(sample_type == "R_FU3_wq_running_bag") %>%
  group_by(R_FU3_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-Running Water" = Count_of_Sample ) %>% 
  unique()

df.count <- left_join(df.count.stored, df.count.running)
stargazer(df.count, summary=F, title= "Count of Sample collection",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_sample_HH_Survey_R3.tex"))


#------------------------ Special Checks ------------------------  

#count of cases when they were supposed to be sample collection but wasn't possible due to available_jjm being 3 or 4 
df.sample.collection <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% filter(R_FU3_ecoli_yn == 1 & (R_FU3_available_jjm ==3 | R_FU3_available_jjm == 4)) %>%
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample, R_FU3_enum_name_label ) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-Sample collection not possible" = Count_of_Sample ) %>% 
  unique()

#count of cases when they were supposed to be chlorine testing but wasn't possible 
df.water.testing <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% filter( R_FU3_water_qual_test == 0) %>%
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU3_r_cen_village_name_str, Count_of_Sample, R_FU3_enum_name_label, R_FU3_no_test_reason  ) %>% 
  rename(Village = R_FU3_r_cen_village_name_str, "Count-Chlorine testing not possible" = Count_of_Sample, "Reason for no test" = R_FU3_no_test_reason ) %>% 
  unique()

df.count <- left_join(df.water.testing, df.sample.collection)
stargazer(df.count, summary=F, title= "Count of Testing not possible",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_test_not_possible_HH_Survey_R3.tex"))




#checking cases when people say they don't use JJM for drinking and their answers to the last time they used drinking water from JJM taps

df.consistency <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% filter(R_FU3_tap_use_drinking_yesno == 0 ) %>%
  dplyr::select(R_FU3_r_cen_village_name_str, R_FU3_enum_name_label, R_FU3_tap_use_drinking , unique_id_num ) %>% 
  mutate(R_FU3_tap_use_drinking = ifelse(R_FU3_tap_use_drinking == 1, "Today", 
                                         ifelse(R_FU3_tap_use_drinking == 2, "Yesterday", 
                                                ifelse(R_FU3_tap_use_drinking == 3, "Earlier this week", 
                                                       ifelse(R_FU3_tap_use_drinking == 4, "Earlier this month", 
                                                              ifelse(R_FU3_tap_use_drinking == 5,"Not used for drinking", 
                                                                     ifelse(R_FU3_tap_use_drinking == -77,"Other", NA))))))) %>%
  rename(Village = R_FU3_r_cen_village_name_str,"Last time collected water from the JJM tap" = R_FU3_tap_use_drinking ) %>% 
  unique()

df.consistency_the_other_way <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>% filter(R_FU3_tap_use_drinking_yesno == 1 & R_FU3_tap_use_drinking == 5) %>%
  dplyr::select(R_FU3_r_cen_village_name_str, R_FU3_enum_name_label, R_FU3_tap_use_drinking  ) %>% 
  mutate(R_FU3_tap_use_drinking = ifelse(R_FU3_tap_use_drinking == 1, "Today", 
                                         ifelse(R_FU3_tap_use_drinking == 2, "Yesterday", 
                                                ifelse(R_FU3_tap_use_drinking == 3, "Earlier this week", 
                                                       ifelse(R_FU3_tap_use_drinking == 4, "Earlier this month", 
                                                              ifelse(R_FU3_tap_use_drinking == 5,"Not used for drinking", 
                                                                     ifelse(R_FU3_tap_use_drinking == -77,"Other", NA))))))) %>%
  rename(Village = R_FU3_r_cen_village_name_str,"Last time collected water from the JJM tap" = R_FU3_tap_use_drinking ) %>% 
  unique()
stargazer(df.consistency, summary=F, title= "Check for not using drinking water, and last time they used drinking water from JJM taps",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_consistency_HH_Survey_R3.tex"))


#Counting people accompanying to shadow enumerators

df.shadow <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%   dplyr::select(R_FU3_enum_name_label,R_FU3_r_cen_village_name_str, R_FU3_survey_accompany_num) %>%
  group_by(R_FU3_enum_name_label,R_FU3_r_cen_village_name_str ) %>% 
  dplyr:: summarise(mean = round(mean(R_FU3_survey_accompany_num),1), 
                    min = round(min(R_FU3_survey_accompany_num),1), max = round(max(R_FU3_survey_accompany_num),1)) %>%
  rename(Village = R_FU3_r_cen_village_name_str, Enumerator = R_FU3_enum_name_label) 

stargazer(df.shadow, summary=F, title= "Check instances of shadowing of enumerators during survey, by enumerator, by village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_shadow_HH_Survey_R3.tex"))

