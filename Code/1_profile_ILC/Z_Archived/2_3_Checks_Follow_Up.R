#------------------------------------------------ 
# title: "Code for Checks for Baseline HH Survey"
# author: "Astha Vohra"
# modified date: "2023-10-12"
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

df.temp <- read_dta(paste0(user_path(),"2_deidentified/1_2_Followup_cleaned.dta" ))

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

#------------------------ Keep consented cases ----------------------------------------#

df.temp.consent <- df.temp[which(df.temp$R_FU_consent==1) ,]


#------------------------ Progress table ----------------------------------------#

submissions <- df.temp %>% select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate(Submission=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)

resp_available <- df.temp %>%  filter(R_FU_resp_available == 1 & R_FU_replacement == 0 ) %>% 
  select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate("OG Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)
resp_notavailable <- df.temp %>%  filter(R_FU_resp_available != 1  ) %>% 
  select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate("NOT Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)

consented <- df.temp  %>% filter(R_FU_consent == 1) %>% select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate(Consented=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)

refused <- df.temp %>% filter(R_FU_consent != 1) %>% select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate(Refused=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)

replacements <- df.temp %>%  filter( R_FU_replacement == 1 ) %>% 
  select(R_FU_r_cen_village_name_str) %>%
  group_by(R_FU_r_cen_village_name_str) %>% mutate(Replacements=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_FU_r_cen_village_name_str)

df.progress <- left_join(submissions,resp_available)%>% left_join(resp_notavailable) %>% left_join(replacements) %>% 
  left_join(consented) %>% left_join(refused)  %>% 
  rename(Village = R_FU_r_cen_village_name_str)
df.progress[is.na(df.progress)]<-0

Total <- df.progress %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))
Total$Village <- "Total"
df.progress<- rbind(df.progress, Total)

#output to tex 
stargazer(df.progress, summary=F, title= "Overall Progress: Baseline HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Progress_HH_Survey.tex"))


#create a date variable
df.temp$date <- format(as.Date(df.temp$R_FU_starttime, "%b %d, %Y"), "%Y-%m-%d")


#------------------------ Distribution of surveys by dates & villages ----------------------------------------#
date.plt<- df.temp %>% filter(R_FU_consent == 1) %>% 
  group_by( R_FU_r_cen_village_name_str, date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()


# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-1),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_FU_r_cen_village_name_str)
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_date_village.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)


#------------------------ Distribution of surveys by Enumerator, dates & villages ----------------------------------------#

date.plt<- df.temp %>% filter(R_FU_consent == 1) %>% 
  group_by( R_FU_r_cen_village_name_str,R_FU_enum_name_label,  date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()


# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-c(1, 2)),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_FU_r_cen_village_name_str, Enumerator =R_FU_enum_name_label  )
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_enum_date_village.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)


#------------------------  Enumerator: duration for each section and count of DK ----------------------------------------#


# 1. Duration by enumerators

resp_hh_location_dur_enum <- df.temp.consent %>%
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Locating Respondent" = round(mean(FU_locatehh_dur_min),1)) %>% ungroup()
consent_dur_enum <- df.temp.consent %>%
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Consent" = round(mean(FU_consent_dur_min),1)) %>% ungroup()
secA_dur_enum <- df.temp.consent %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Sec A" = round(mean(FU_secA_dur_min),1)) %>% ungroup()
secB_dur_enum <- df.temp.consent %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Sec B" = round(mean(FU_secB_dur_min),1))  %>% ungroup()
secC_dur_enum <- df.temp.consent %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Sec C" = round(mean(FU_secC_dur_min),1))%>% ungroup()
secD_dur_enum <- df.temp.consent %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Sec D" = round(mean(FU_secD_dur_min),1))  %>% ungroup()
total_dur_enum <- df.temp.consent %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Overall" = round(mean(R_FU_duration_end/60),1))  %>% ungroup()

df.duration.enum <- left_join(resp_hh_location_dur_enum,consent_dur_enum) %>% left_join(secA_dur_enum) %>% 
  left_join(secB_dur_enum) %>% 
  left_join(secC_dur_enum) %>% 
  left_join(secC_dur_enum) %>%
  left_join(secD_dur_enum) %>%
  left_join(total_dur_enum) 
df.duration.enum <- df.duration.enum %>% rename(Enumerator = R_FU_enum_name_label )
star.out <- stargazer(df.duration.enum, summary=F, title= "Duraction by section Baseline HH Survey by enumerator",float=F,rownames = F,covariate.labels=NULL)
star.out <- sub("cccccccc", "lccccccc", star.out)
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Duration_enum_HH_Survey.tex"))


# Duration of water quality testing by type of test
secE_cl_dur_enum <- df.temp.consent %>%  filter(R_FU_water_qual_test == 1) %>% 
  mutate(FU_secE_dur_min  = ifelse(FU_secE_dur_min<0 , NA, FU_secE_dur_min)) %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Chlorine Testing"= round(mean(FU_secE_dur_min, na.rm = T),1))  %>% ungroup()

secE_both_dur_enum <- df.temp.consent %>%  filter(R_FU_water_qual_test == 2) %>% 
  mutate(FU_secE_dur_min  = ifelse(FU_secE_dur_min<0 , NA, FU_secE_dur_min)) %>% 
  group_by(R_FU_enum_name_label) %>%
  dplyr:: summarise("Both Testing"= round(mean(FU_secE_dur_min, na.rm = T),1))  %>% ungroup()

df.duration.wq.enum <- left_join(secE_cl_dur_enum,secE_both_dur_enum) 
df.duration.wq.enum <- df.duration.wq.enum %>% rename(Enumerator = R_FU_enum_name_label )
star.out <- stargazer(df.duration.wq.enum, summary=F, title= "Duraction by WQ Test Baseline HH Survey by enumerator",float=F,rownames = F,covariate.labels=NULL)
star.out <- sub("ccc", "lcc", star.out)
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Duration_WQ_enum_HH_Survey.tex"))

#2. Count of Dont Know by enumerators 

df.dk.enum <- df.temp.consent %>%
  group_by(R_FU_enum_name_label) %>%
  summarise_all(~sum(. == 999)) %>% 
  transmute(R_FU_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_FU_enum_name_label, "Count of DK" = sum_dk)

stargazer(df.dk.enum, summary=F, title= "Count of DK by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_DK_enum_HH_Survey.tex"))

#------------------------  Enumerator: Displaying chlorine test data for each village ------------------------  


bl <- df.temp.consent

###Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU_fc_tap, R_FU_fc_stored, R_FU_tc_tap, R_FU_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE)

#Frequency of cases above 0.1 by enumerator
chlorine_check <- chlorine%>%
  filter(chlorine_concentration > 0.10)%>% 
  dplyr::select(R_FU_enum_name_label) %>% 
  group_by(R_FU_enum_name_label) %>% 
  mutate(Case_above_0.1 = n()) %>% ungroup()  %>% unique() 
stargazer(chlorine_check, summary=F, title= "Count of Chlorine reading greater than 0.10",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Chlorine_high_HH_Survey.tex"))

bl <- df.temp.consent

###Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
df.sample <- bl%>%
  pivot_longer(cols = c("R_FU_wq_stored_bag", "R_FU_wq_running_bag"), values_to = "yes_no", names_to = "sample_type")

#Removing NAs from no respondent being available
df.sample <- df.sample%>%
  filter(is.na(yes_no) == FALSE) %>% dplyr::select(R_FU_enum_name_label, R_FU_r_cen_village_name_str, sample_type, yes_no)
#Frequency of sample collection by enumerator
df.sample.stored.enum <- df.sample%>% filter(sample_type == "R_FU_wq_stored_bag") %>% 
  group_by(R_FU_enum_name_label, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU_enum_name_label, Count_of_Sample) %>% 
  rename(Enumerator = R_FU_enum_name_label, "Count-Stored Water" = Count_of_Sample ) %>% 
  unique() 

df.sample.running.enum <- df.sample%>% filter(sample_type == "R_FU_wq_running_bag") %>% 
  group_by(R_FU_enum_name_label, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>%
  dplyr::select(R_FU_enum_name_label, Count_of_Sample) %>% 
  rename(Enumerator = R_FU_enum_name_label, "Count-Running Water" = Count_of_Sample ) %>% 
  unique()
df.sample.enum <- left_join(df.sample.stored.enum, df.sample.running.enum)
stargazer(df.sample.enum, summary=F, title= "Count of Sample collection by enum",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_sample_enum_HH_Survey.tex"))


df.chlorine <- bl%>%
  pivot_longer(cols = c("R_FU_fc_stored", "R_FU_fc_tap", "R_FU_tc_stored", "R_FU_tc_tap"), values_to = "yes_no", names_to = "sample_type")
#Frequency of sample collection by enumerator
df.chlorine.vil.fc.stored <- df.chlorine%>% filter(sample_type == "R_FU_fc_stored") %>% 
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str, "Count-FCl Stored" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.tc.stored <- df.chlorine%>% filter(sample_type == "R_FU_tc_stored") %>% 
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str, "Count-TCl Stored" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.fc.tap <- df.chlorine%>% filter(sample_type == "R_FU_fc_tap") %>% 
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str, "Count-FCl Running" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil.tc.tap <- df.chlorine%>% filter(sample_type == "R_FU_tc_tap") %>%
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = sum(!is.na(yes_no))) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str, "Count-TCl Running" = Count_of_Sample ) %>% 
  unique() 

df.chlorine.vil <-  left_join(df.chlorine.vil.fc.stored, df.chlorine.vil.tc.stored) 
df.chlorine.vil <-  left_join(df.chlorine.vil, df.chlorine.vil.fc.tap) 
df.chlorine.vil <-  left_join(df.chlorine.vil, df.chlorine.vil.tc.tap) 

stargazer(df.chlorine.vil, summary=F, title= "Count of  Chlorine Tests by village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_chlorine_village_HH_Survey.tex"))

#------------------------  Overall checks ------------------------  

#1 Duration of each section
resp_hh_location_dur <- df.temp.consent %>% filter(FU_locatehh_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_locatehh_dur_min),1), min = round(min(FU_locatehh_dur_min),1), max = round(max(FU_locatehh_dur_min),1))  %>%
  mutate(variable = "Locating HH")
consent_dur <- df.temp.consent %>%  filter(FU_consent_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_consent_dur_min),1), min = round(min(FU_consent_dur_min),1), max = round(max(FU_consent_dur_min),1) ) %>%
  mutate(variable = "Consent")
secA_dur <- df.temp.consent %>% filter(FU_secA_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_secA_dur_min),1), min = round(min(FU_secA_dur_min),1), max = round(max(FU_secA_dur_min),1) ) %>%
  mutate(variable = "Sec A: WASH Access")
secB_dur <- df.temp.consent %>% filter(FU_secB_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_secB_dur_min),1), min = round(min(FU_secB_dur_min),1), max = round(max(FU_secB_dur_min),1) ) %>%
  mutate(variable = "Sec B: Government Tap")
secC_dur <- df.temp.consent %>% filter(FU_secC_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_secC_dur_min),1), min = round(min(FU_secC_dur_min),1), max = round(max(FU_secC_dur_min),1) ) %>%
  mutate(variable = "Sec C: Chlorination Perceptions")
secD_dur <- df.temp.consent %>% filter(FU_secD_dur_min > 0) %>%
  dplyr:: summarise(mean = round(mean(FU_secD_dur_min),1), min = round(min(FU_secD_dur_min),1), max = round(max(FU_secD_dur_min),1) ) %>%
  mutate(variable = "Sec D: Burden")

overall_mean <- df.temp.consent %>% filter(R_FU_duration_end > 0) %>%
  dplyr:: summarise(mean = round(mean(R_FU_duration_end/60),1), min = round(min(R_FU_duration_end/60),1), max = round(max(R_FU_duration_end/60),1) ) %>%
  mutate(variable = "Overall")

df.duration <- bind_rows(resp_hh_location_dur,consent_dur, secA_dur,secB_dur, secC_dur, secD_dur, overall_mean)

df.duration <- df.duration %>% select(variable , mean, min, max) %>% mutate(mean = round(mean, 3), min = round(min, 3), max = round(max, 3)) %>%   rename("Duration\ Section" = variable, "Mean \ (in mins)" = mean, "Min \ (in mins)" = min, "Max \ (in mins)" = max ) 
stargazer(df.duration, summary=F, title= "Duraction by section Baseline HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Duration_HH_Survey.tex"))



#2 Section on Water Quality Testing, separate duration by whether sample was collected or not? 

secE_dur_chlorine <- df.temp.consent %>% filter(R_FU_water_qual_test == 1) %>% 
  mutate(FU_secE_dur_min  = ifelse(FU_secE_dur_min<0 , NA, FU_secE_dur_min)) %>% 
  dplyr:: summarise(mean = round(mean(FU_secE_dur_min, na.rm = T),1), min = round(min(FU_secE_dur_min,  na.rm = T),1), max = round(max(FU_secE_dur_min,  na.rm = T),1) ) %>%
  mutate(variable = "Chlorine Testing")
secE_dur_both <- df.temp.consent %>% filter(R_FU_water_qual_test == 2) %>% 
  mutate(FU_secE_dur_min  = ifelse(FU_secE_dur_min<0 , NA, FU_secE_dur_min)) %>% 
  dplyr:: summarise(mean = round(mean(FU_secE_dur_min, na.rm = T),1), min = round(min(FU_secE_dur_min,  na.rm = T),1), max = round(max(FU_secE_dur_min,  na.rm = T),1) ) %>%
  mutate(variable = "Both Testing")

df.duration.wq <- bind_rows(secE_dur_chlorine,secE_dur_both)

df.duration.wq <- df.duration.wq %>% select(variable , mean, min, max) %>% mutate(mean = round(mean, 3), min = round(min, 3), max = round(max, 3)) %>%   rename("Duration\ Section" = variable, "Mean \ (in mins)" = mean, "Min \ (in mins)" = min, "Max \ (in mins)" = max ) 
stargazer(df.duration.wq, summary=F, title= "Duraction for Water Quality Test -  Baseline HH Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Duration_WQ_HH_Survey.tex"))


#3 Displaying chlorine test data for each village
#Arranging data so chlorine test data is in one column
df.sample <- bl%>%
  pivot_longer(cols = c("R_FU_wq_stored_bag", "R_FU_wq_running_bag"), values_to = "yes_no", names_to = "sample_type")

#Removing NAs from no respondent being available
df.sample <- df.sample%>%
  filter(is.na(yes_no) == FALSE) %>% dplyr::select(R_FU_enum_name_label, R_FU_r_cen_village_name_str, sample_type, yes_no)

#Frequency of sample collection
df.count.stored <- df.sample%>% filter(sample_type == "R_FU_wq_stored_bag") %>%
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str,  "Count-Stored Water" = Count_of_Sample ) %>% 
  unique()
df.count.running <- df.sample%>% filter(sample_type == "R_FU_wq_running_bag") %>%
  group_by(R_FU_r_cen_village_name_str, sample_type) %>% 
  mutate(Count_of_Sample = n()) %>% ungroup()  %>% 
  dplyr::select(R_FU_r_cen_village_name_str, Count_of_Sample) %>% 
  rename(Village = R_FU_r_cen_village_name_str, "Count-Running Water" = Count_of_Sample ) %>% 
  unique()

df.count <- left_join(df.count.stored, df.count.running)
stargazer(df.count, summary=F, title= "Count of Sample collection",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_sample_HH_Survey.tex"))

#------------------------ Special Checks ------------------------  


# For Archi - give hh_ids and name of enums who report diff primary water source than government taps
df.wash.not.prim <- df.temp.consent %>% filter(R_FU_water_source_prim != 1) %>% 
  select(R_FU_enum_name_label, R_FU_r_cen_village_name_str, unique_id_num, R_FU_water_source_prim )  %>%
  rename( Enumerator = R_FU_enum_name_label, Village  = R_FU_r_cen_village_name_str, HH_ID = unique_id_num, 
          Primary_Water_Source = R_FU_water_source_prim) %>% 
  mutate(Primary_Water_Source = ifelse(Primary_Water_Source == 2,"Government provided community standpipe",
                                       ifelse(Primary_Water_Source == 3, "Gram Panchayat/Other Community Standpipe", 
                                              ifelse(Primary_Water_Source == 4,"Manual handpump", 
                                                     ifelse(Primary_Water_Source == 5, "Covered dug well", 
                                                            ifelse(Primary_Water_Source == 6, 
                                                                   "Directly fetched by surface water", 
                                                                   ifelse(Primary_Water_Source == 7, 
                                                                          "Uncovered dug well", 
                                                                          ifelse(Primary_Water_Source == 8, 
                                                                                 "Private Surface well", 
                                                                                 Primary_Water_Source))))))))


star.out <- stargazer(df.wash.not.prim, summary=F, title= "",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" cccc"," lccc", star.out) 
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_NOT_Govt_tap_HH_Survey.tex"))

