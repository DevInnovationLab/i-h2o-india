#------------------------------------------------ 
# title: "Code for Checks for Follow Up HH Survey"
# author: "Astha Vohra"
# modified date: "2023-02-04"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------#



#install packages
install.packages("RSQLite")
install.packages("haven")
install.packages("expss")
install.packages("stargazer")
install.packages("Hmisc")
install.packages("labelled")
install.packages("data.table")

# load the libraries
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
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  d
  stopifnot(file.exists(github))
  return(github)
}

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
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}

#------------------------ Load the data ----------------------------------------#


df.temp <- read_stata(paste0(user_path(),"1_raw/1_8_Endline/1_8_Endline_Census_cleaned_consented.dta" ))

View(df.temp)


df.preload <- read_xlsx(paste0(user_path(),"99_Preload/Endline_census_preload.xlsx"))
#------------------------ Apply the labels for variables  ----------------------------------------#

View(df.preload)

temp.labels <- lapply(df.temp , var_lab)
View(temp.labels)
#create a data with labels
df.label <- as.data.frame(t(as.data.frame(do.call(cbind, temp.labels)))) 
df.label<- tibble::rownames_to_column(df.label) 
df.label <- df.label %>% rename(variable = rowname, label = V1)  
auto_generated_labels <- c(df.label$variable)
View(auto_generated_labels)
#include labels given manually 
df.label.manual <- read_xlsx(paste0(user_path(),"4_other/R_code_Endline_survey_label.xlsx"))

View(df.label.manual)
df.var <- as.data.frame(names(df.temp)) #List of variables in the data

# assign labels to variable that were generated
#df.label.manual <- df.label.manual %>% mutate(new_var = ifelse(Variable %in% auto_generated_labels, 0,1)) %>% 
  #filter(new_var == 1) %>% select(-new_var) %>% rename(variable = Variable, label = Label)

#df.label <- rbind(df.label, df.label.manual)
# create a function that assigns the label to appropriate variable

#create a date variable
df.temp$datetime <- strptime(df.temp$R_E_starttime, format = "%Y-%m-%d %H:%M:%S")

df.temp$date <- as.IDate(df.temp$datetime) 

View(df.temp)

#filter out the testing dates
df.temp <- df.temp 

#------------------------ Keep consented cases ----------------------------------------#

#View the cases where consent != 1
filtered_df <- subset(df.temp, R_E_consent != 1)
View(filtered_df)

df.temp.consent <- df.temp[which(df.temp$R_E_consent==1) ,]


#------------------------ Assign the correct treatment to villages ----------------------------------------#

df.temp.consent <- df.temp.consent %>% mutate(Treatment = ifelse(R_E_r_cen_village_name_str %in%
                                                                   c("Birnarayanpur","Nathma", "Badabangi","Naira", "Bichikote", "Karnapadu","Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada"), "T", "C"))


#------------------------ Progress table ----------------------------------------#

submissions <- df.temp  %>% select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate(Submission=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

HH_available <- df.temp %>%  filter(R_E_resp_available == 1) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("HH available to give survey" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

HH_permanently_left <- df.temp %>%  filter(R_E_resp_available == 2  ) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("HH permanently left" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

HH_refused <- df.temp %>%  filter(R_E_resp_available == -77  ) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("HH refused" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

HH_unavailable <- df.temp %>%  filter(R_E_resp_available != 1 & R_E_resp_available != 2 & R_E_resp_available != -77) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("HH unavailable" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

Main_Resp_available <- df.temp %>%  filter(R_E_instruction == 1) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("Main Resp available" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

Main_Resp_unavailable <- df.temp %>%  filter(R_E_instruction != 1) %>% 
  select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate("Main Resp unavailable" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

Main_resp_consented <- df.temp  %>% filter(R_E_consent == 1) %>% select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate(Main_resp_Consented=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)

Main_resp_refused <- df.temp %>% filter(R_E_consent != 1) %>% select(R_E_r_cen_village_name_str) %>%
  group_by(R_E_r_cen_village_name_str) %>% mutate(Main_resp_Refused=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_E_r_cen_village_name_str)


df.progress <- left_join(submissions,HH_available)%>% left_join(HH_permanently_left) %>% left_join(HH_refused) %>% 
  left_join(HH_unavailable) %>% left_join(Main_Resp_available)  %>% left_join(Main_Resp_unavailable) %>%  left_join(Main_resp_consented) %>%  left_join(Main_resp_refused) %>%
  rename(Village = R_E_r_cen_village_name_str)
df.progress[is.na(df.progress)]<-0

Total <- df.progress %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))
Total$Village <- "Total"
df.progress<- rbind(df.progress, Total)

View(df.progress)
#output to tex 
stargazer(df.progress, summary=F, title= "Overall Progress: Endline Census Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Progress_Endline_Census.tex"))


#df.temp$date <- format(as.Date(df.temp$R_FU3_starttime, "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d")



#------------------------ Distribution of surveys by dates & villages ----------------------------------------#
date.plt<- df.temp %>% filter(R_E_consent == 1) %>% filter(date >= as.Date("2024-04-21")) %>%
  group_by( R_E_r_cen_village_name_str, date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()

View(date.plt)

# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-1),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_E_r_cen_village_name_str)
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_date_village_Endline.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)


#------------------------ Distribution of surveys by Enumerator, dates & villages ----------------------------------------#

date.plt<- df.temp %>% filter(R_E_consent == 1)%>% filter(date >= as.Date("2024-04-21")) %>%
  group_by( R_E_r_cen_village_name_str,R_E_enum_name_label,  date) %>%
  dplyr:: summarise(Date_N=n()) %>% ungroup()


# CONVERT TO TABLE
tab<- spread(date.plt,key = "date", value = "Date_N")
tab <- tab %>% dplyr::mutate(total=rowSums(across(-c(1, 2)),na.rm = T))
tab[is.na(tab)] <- 0 
tab <- tab %>% rename(Village = R_E_r_cen_village_name_str, Enumerator =R_E_enum_name_label  )
print(tab)

stargazer(tab,out= paste0(overleaf(), "Table/Table_survey_by_enum_date_village_endline.tex"), summary=F, float=F,rownames = F,
          covariate.labels=NULL)



#2. Count of Dont Know by enumerators 

#display var names from df.temp
names(df.temp)
View(df.temp)



df.dk.enum <- df.temp.consent %>% filter(date >= as.Date("2024-04-21")) %>%
  group_by(R_E_enum_name_label) %>% select(R_E_water_source_prim,R_E_water_sec_yn, R_E_water_source_main_sec,
                                           R_E_quant, R_E_water_sec_freq, R_E_collect_resp, R_E_people_prim_water, R_E_prim_collect_resp, R_E_where_prim_locate, R_E_where_prim_locate_enum_obs, R_E_collect_time, R_E_collect_prim_freq, R_E_water_treat, R_E_water_stored, R_E_not_treat_tim, R_E_treat_resp, R_E_treat_primresp, R_E_treat_time, R_E_treat_freq, R_E_collect_treat_difficult, R_E_clean_freq_containers, R_E_clean_time_containers, R_E_water_source_kids, R_E_water_prim_source_kids, R_E_water_source_preg, R_E_water_prim_source_preg, R_E_water_treat_kids, R_E_jjm_drinking, R_E_tap_supply_freq, R_E_tap_supply_daily, R_E_jjm_stored, R_E_jjm_yes,  R_E_tap_function) %>%
  summarise_all(~sum(. == 999)) %>% 
  transmute(R_E_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_E_enum_name_label, "Count of DK" = sum_dk)


df.dk.enum.Mul <- df.temp.consent %>% filter(date >= as.Date("2024-04-21")) %>%
  group_by(R_E_enum_name_label) %>% select(R_E_sec_source_reason_999, R_E_water_treat_type_999, R_E_water_treat_kids_type_999, R_E_reason_nodrink_999, R_E_jjm_use_999, R_E_tap_function_reason_999) %>%
  summarise_all(~sum(. == 1)) %>% 
  transmute(R_E_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_E_enum_name_label, "Count of DK.Mul" = sum_dk)


View(df.dk.enum)
View(df.dk.enum.Mul)

# Merging using full join to include all Enumerators
merged_df <- full_join(df.dk.enum, df.dk.enum.Mul, by = "Enumerator")
View(merged_df)

# Creating a new variable 'Total Count of DK' by summing both counts

# Convert Count_of_DK and Count_of_DK_Mul columns to numeric
merged_df$`Count of DK` <- as.numeric(merged_df$`Count of DK`)
merged_df$`Count of DK.Mul` <- as.numeric(merged_df$`Count of DK.Mul`)

# Creating a new variable 'Total Count of DK' by summing both counts

merged_df <- merged_df %>%
  mutate(Total_Count_of_DK = coalesce(`Count of DK`, 0) + coalesce(`Count of DK.Mul`, 0))

merged_df <- merged_df %>% select(Enumerator, `Total_Count_of_DK`)

stargazer(merged_df, summary=F, title= "Count of DK by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_DK_enum_endline.tex"))


#2. Count of Dont Know by variables (TO-DO)



#3. Count of 888 by enumerators for 24-7 filter

df.888.enum <- df.temp.consent %>% filter(date >= as.Date("2024-04-21")) %>%
  group_by(R_E_enum_name_label) %>% select(R_E_treat_time, R_E_treat_freq) %>% 
  summarise_all(~sum(. == 888)) %>% 
  transmute(R_E_enum_name_label, sum_dk = rowSums(.[-1], na.rm = T)) %>% 
  rename(Enumerator = R_E_enum_name_label, "Count of 888" = sum_dk)

View(df.888.enum)

View(df.temp.consent)

count_of_888 <- df.temp.consent %>%
  filter(R_E_enum_name_label == "Rasmita Barik") %>%
  select(unique_id, R_E_treat_time, R_E_treat_freq)

view(count_of_888)

stargazer(df.888.enum, summary=F, title= "Count of Permanent filters by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_888_enum_endline.tex"))



#------------------------ Consistency Checks ------------------------  


#checking cases when people say they don't use JJM for drinking and their answers to the last time they used drinking water from JJM taps


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
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_consistency_endline.tex"))


#Counting people accompanying to shadow enumerators

df.shadow <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%   dplyr::select(R_E_enum_name_label,R_E_r_cen_village_name_str, R_E_a42_survey_accompany_num) %>%
  group_by(R_E_enum_name_label,R_E_r_cen_village_name_str ) %>% 
  dplyr:: summarise(mean = round(mean(R_E_a42_survey_accompany_num),1), 
                    min = round(min(R_E_a42_survey_accompany_num),1), max = round(max(R_E_a42_survey_accompany_num),1)) %>%
  rename(Village = R_E_r_cen_village_name_str, Enumerator = R_E_enum_name_label) 

View(df.shadow)

stargazer(df.shadow, summary=F, title= "Check instances of shadowing of enumerators during survey, by enumerator, by village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_shadow_endline.tex"))

