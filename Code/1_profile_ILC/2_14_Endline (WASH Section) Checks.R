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
install.packages("haven")
install.packages("remotes")
# Attempt using devtools package
install.packages("devtools")

#please note that starpolishr pacakge isn't available on CRAN so it has to be installed from github using rmeotes pacakage 
install.packages("remotes")
remotes::install_github("ChandlerLutz/starpolishr")

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

View(df.temp.consent)


# Convert labelled columns to factors
df.temp.consent <- df.temp.consent %>%
  mutate(across(where(is.labelled), as_factor))



df.temp.consent$R_E_water_source_prim <- ifelse(df.temp.consent$R_E_water_source_prim == "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM", "JJM", 
                                                ifelse(df.temp.consent$R_E_water_source_prim == "Government provided community standpipe (connected to piped system, through Vasu", "Govt provided community standpipe", 
                                                       ifelse(df.temp.consent$R_E_water_source_prim == "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)", "Gram Panchayat/other community standpipe", 
                                                              ifelse(df.temp.consent$R_E_water_source_prim == "Manual handpump", "Manual handpump", 
                                                                     ifelse(df.temp.consent$R_E_water_source_prim == "Covered dug well", "Covered dug well", 
                                                                            ifelse(df.temp.consent$R_E_water_source_prim == "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c", "surface water",
                                                                                   ifelse(df.temp.consent$R_E_water_source_prim == "Uncovered dug well", "Uncovered dug well", 
                                                                                          ifelse(df.temp.consent$R_E_water_source_prim == "Private Surface well", "Private Surface well", 
                                                                                                 ifelse(df.temp.consent$R_E_water_source_prim == "Borewell operated by electric pump", "Borewell", 
                                                                                                        ifelse(df.temp.consent$R_E_water_source_prim == "Household tap connections not connected to RWSS/Basudha/JJM tank", "Non-JJM household tap connections", 
                                                                                                               ifelse(df.temp.consent$R_E_water_source_prim == "Other", "Other", 
                                                                                                                      df.temp.consent$R_E_water_source_prim)))))))))))
                                                





#-------------------------------------------------------------------------------------------------------------------
# PRIMARY WATER SOURCE DISTRIBUTION BY ENUM 
#-------------------------------------------------------------------------------------------------------------------


browse <- df.temp.consent %>% filter(unique_id == "30501107007" | unique_id == "30501107010" | unique_id == "30501106006" | unique_id == "30501111013" | unique_id == "50401107034" | unique_id == "40202108027"  )
browse <- browse %>% select(R_E_water_source_prim, R_E_water_source_sec )
View(browse)

# Group and count occurrences
counts <- df.temp.consent %>%
  group_by(R_E_enum_name_label, R_E_water_source_prim) %>%
  summarise(count = n(), .groups = 'drop')

# Calculate total counts for each enumerator
total_counts <- counts %>%
  group_by(R_E_enum_name_label) %>%
  summarise(total = sum(count), .groups = 'drop')

# Join the total counts with the counts and calculate percentages
percentage_df <- counts %>%
  left_join(total_counts, by = "R_E_enum_name_label") %>%
  mutate(percentage = (count / total) * 100) %>%
  select(R_E_enum_name_label, R_E_water_source_prim, percentage)



View(percentage_df)

stargazer(percentage_df, summary=F, title= "Primary water source by enumerator",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_primwater_enum_endline.tex"))


#-------------------------------------------


# Create the bar plot with adjusted legend size and increased plot size


water_prim_enum <- ggplot(percentage_df, aes(x = R_E_enum_name_label, y = percentage, fill = R_E_water_source_prim)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of Water Source Choices by Enumerator",
       x = "Enumerator",
       y = "Percentage",
       fill = "Water Source") +
  scale_fill_brewer(palette = "Set2") +  # Use a colorblind-friendly palette
  theme_minimal() +
  theme(
    legend.text = element_text(size = 8),      # Reduce legend text size
    legend.title = element_text(size = 10),    # Reduce legend title size
    legend.key.size = unit(0.5, "cm"),         # Reduce legend key size
    plot.title = element_text(size = 14),      # Increase plot title size
    axis.title = element_text(size = 12),      # Increase axis titles size
    axis.text = element_text(size = 13),       # Increase axis text size
    axis.text.x = element_text(angle = 45, hjust = 1),  # Tilt x-axis labels
    legend.position = "right",                 # Position legend to the right
    legend.justification = "center",           # Center the legend vertically
    legend.box.margin = margin(0, 0, 0, 10)    # Add margin to move the legend outside
  )

print(water_prim_enum)

ggplot2::ggsave( paste0(overleaf(),"Figure/water_source_prim_enum_endline.png"), water_prim_enum, bg = "white", width = 15, height= 10,dpi=200)



#-------------------------------------------------------------------------------------------------------------------
# PRIMARY WATER SOURCE DISTRIBUTION IN GENERAL
#-------------------------------------------------------------------------------------------------------------------

# Group and count occurrences

water_source_percentage <- df.temp.consent %>%
  group_by(R_E_water_source_prim) %>%
  summarise(count = n()) %>%
  mutate(percentage = (count / sum(count)) * 100)


View(water_source_percentage)

stargazer(water_source_percentage, summary=F, title= "Primary water source breakdown",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Prim_source_endline.tex"))


#-------------------------------------------------------------------------------------------------------------------
# SECONDARY WATER SOURCE DISTRIBUTION IN GENERAL
#-------------------------------------------------------------------------------------------------------------------

names(df.temp.consent)

var_label(df.temp.consent$R_E_water_source_sec_1) <- "JJM"
var_label(df.temp.consent$R_E_water_source_sec_2) <- "Govt provided community standpipe"
var_label(df.temp.consent$R_E_water_source_sec_3) <- "Gram Panchayat/other community standpipe"
var_label(df.temp.consent$R_E_water_source_sec_4) <- "Manual handpump"
var_label(df.temp.consent$R_E_water_source_sec_5) <- "Covered dug well"
var_label(df.temp.consent$R_E_water_source_sec_6) <- "surface water"
var_label(df.temp.consent$R_E_water_source_sec_7) <- "Uncovered dug well"
var_label(df.temp.consent$R_E_water_source_sec_8) <- "Private Surface well"
var_label(df.temp.consent$R_E_water_source_sec_9) <- "Borewell"
var_label(df.temp.consent$R_E_water_source_sec_10) <- "Non-JJM household tap connections"
var_label(df.temp.consent$R_E_water_source_sec__77) <- "Other secondary source"


variables <- c("R_E_water_source_sec_1", 
               "R_E_water_source_sec_2", 
               "R_E_water_source_sec_3", 
               "R_E_water_source_sec_4", 
               "R_E_water_source_sec_5", 
               "R_E_water_source_sec_6", 
               "R_E_water_source_sec_7", 
               "R_E_water_source_sec_8", 
               "R_E_water_source_sec_9", 
               "R_E_water_source_sec_10", 
               "R_E_water_source_sec__77")


sums <- df.temp.consent %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))

sums_long <- sums %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Sum")

print(sums_long)

View(sums_long)

# Calculate the total sum of all the variables
total_sum <- sum(sums_long$Sum)

# Add a percentage column
sums_long <- sums_long %>%
  mutate(Percentage = (Sum / total_sum) * 100)

# Print the results
print(sums_long)


sums_long$Variable <- sapply(sums_long$Variable, function(x) var_label(df.temp.consent[[x]]))


# Generate the LaTeX table
stargazer(sums_long, 
          summary = FALSE, 
          title = "Secondary water source breakdown", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/Sec_source_endline.tex"))



#-------------------------------------------------------------------------------------------------------------------
# SECONDARY WATER SOURCE DISTRIBUTION BY ENUM
#-------------------------------------------------------------------------------------------------------------------

# Group by enumerator and calculate the sums for each secondary water source
enum_sums <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))



# Convert to long format for better readability
enum_sums_long <- enum_sums %>%
  pivot_longer(cols = -R_E_enum_name_label, names_to = "Secondary_Water_Source", values_to = "Sum")

# Calculate the total sum of secondary water sources for each enumerator
enum_totals <- enum_sums_long %>%
  group_by(R_E_enum_name_label) %>%
  summarise(Total_Sum = sum(Sum))

# Merge the totals back with the long format data
enum_sums_long <- enum_sums_long %>%
  left_join(enum_totals, by = "R_E_enum_name_label")

# Calculate the percentage of each secondary water source within each enumerator group
enum_sums_long <- enum_sums_long %>%
  mutate(Percentage = (Sum / Total_Sum) * 100)

# Print the results
print(enum_sums_long)

View(enum_sums_long)


enum_sums_long$Secondary_Water_Source <- sapply(enum_sums_long$Secondary_Water_Source, function(x) var_label(df.temp.consent[[x]]))



# Create the bar plot with adjusted legend size and increased plot size
enum_sums_long_filtered <- enum_sums_long %>%
  filter(Percentage > 0)

water_sec_enum <- ggplot(enum_sums_long_filtered, aes(x = R_E_enum_name_label, y = Percentage, fill = Secondary_Water_Source)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of Secondary water Source Choices by Enumerator",
       x = "Enumerator",
       y = "Percentage",
       fill = "Sec Water Source") +
  scale_fill_brewer(palette = "Set2") +  # Use a colorblind-friendly palette
  theme_minimal() +
  theme(
    legend.text = element_text(size = 8),      # Reduce legend text size
    legend.title = element_text(size = 10),    # Reduce legend title size
    legend.key.size = unit(0.5, "cm"),         # Reduce legend key size
    plot.title = element_text(size = 14),      # Increase plot title size
    axis.title = element_text(size = 12),      # Increase axis titles size
    axis.text = element_text(size = 13),       # Increase axis text size
    axis.text.x = element_text(angle = 45, hjust = 1),  # Tilt x-axis labels
    legend.position = "right",                 # Position legend to the right
    legend.justification = "center",           # Center the legend vertically
    legend.box.margin = margin(0, 0, 0, 10)    # Add margin to move the legend outside
  )

print(water_sec_enum)

ggplot2::ggsave( paste0(overleaf(),"Figure/water_source_sec_enum_endline.png"), water_sec_enum, bg = "white", width = 15, height= 10,dpi=200)



names(df.temp.consent)

#-------------------------------------------------------------------------------------------------------------------
# CHECKING IF PRIMARY SOURCE AND SECONDARY SPURCE ARE SAME AT THE SAME TIME UNIQUE ID WISE
#-------------------------------------------------------------------------------------------------------------------

# Create a logical condition to flag matching primary and secondary sources
df.temp.flag <- df.temp.consent %>%
  rowwise() %>%
  mutate(flag = any(c_across(all_of(variables)) == R_E_water_source_prim))

View(df.temp.flag)
# Filter and list out the flagged cases
flagged_cases <- df.temp.flag %>%
  filter(flag == TRUE)

View(flagged_cases)
# Print the flagged cases
print(flagged_cases)


#-------------------------------------------------------------------------------------------------------------------
# WATER COLLECTION
#-------------------------------------------------------------------------------------------------------------------

browse <- df.temp.consent %>% select(R_E_collect_resp, R_E_where_prim_locate, R_E_where_prim_locate_enum_obs, R_E_sec_source_reason_999 )

 View(browse)


#-------------------------------------------------------------------------------------------------------------------
# LOCATION OF PRIMARY SOURCE
#-------------------------------------------------------------------------------------------------------------------


df.temp.consent$R_E_where_prim_locate<- ifelse(df.temp.consent$R_E_where_prim_locate == 1, "In own dwelling", 
                                                ifelse(df.temp.consent$R_E_where_prim_locate == 2, "In own yard/plot", 
                                                       ifelse(df.temp.consent$R_E_where_prim_locate == 3, "Elsewhere", 
                                                              df.temp.consent$R_E_where_prim_locate)))

df.temp.consent$R_E_where_prim_locate_enum_obs<- ifelse(df.temp.consent$R_E_where_prim_locate_enum_obs == 1, "In own dwelling", 
                                               ifelse(df.temp.consent$R_E_where_prim_locate_enum_obs == 2, "In own yard/plot", 
                                                      ifelse(df.temp.consent$R_E_where_prim_locate_enum_obs == 3, "Elsewhere", 
                                                             df.temp.consent$R_E_where_prim_locate_enum_obs)))

# Create the dataframe
result_df <- df.temp.consent %>%
  filter(R_E_where_prim_locate != R_E_where_prim_locate_enum_obs) %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    total_count = n(),
    R_E_where_prim_locate = list(R_E_where_prim_locate),
    R_E_where_prim_locate_enum_obs = list(R_E_where_prim_locate_enum_obs)
  )

# Print the result
View(result_df)

stargazer(result_df, 
          summary = FALSE, 
          title = "Different locations of primary source", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/location_prim_endline.tex"))


#--------------------------------------------------------------------------------
#Consistency of  collect_prim_freq with quant
#-----------------------------------------------------------------------------

#option 1 2 3 in  collect_prim_freq  shouldnt be with 2  in quant
#option 4 5 in  collect_prim_freq shouldnt be with more than 5 in quant

browse <- df.temp.consent %>% select(R_E_quant , R_E_collect_prim_freq, R_E_water_sec_yn, R_E_water_sec_freq, R_E_tap_supply_daily )
View(browse)

#part 1

df.temp.consent$R_E_quant <- ifelse(df.temp.consent$R_E_quant == "All of it (100%)", "All of it (100%)", 
                                               ifelse(df.temp.consent$R_E_quant == "More than half of it", "More than half of it", 
                                                      ifelse(df.temp.consent$R_E_quant == "Half of it (50%)", "Half of it (50%)", 
                                                             ifelse(df.temp.consent$R_E_quant == "Less than half of it", "Less than half of it", 
                                                                    ifelse(df.temp.consent$R_E_quant == "None of it (0%)", "None of it (0%)", 
                                                                           df.temp.consent$R_E_quant)))))
                                                      


filtered_df <- df.temp.consent %>%
  filter(R_E_quant %in% c("Less than half of it", "None of it (0%)") & R_E_collect_prim_freq > 5)

View(filtered_df)


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_quant, R_E_collect_prim_freq) %>%
  ungroup()



View(result)

stargazer(result, summary=F, title= "Inconsistency between 'how much of your drinking watercame from your primary drinking water source' and 'In the past week, how many times did you collect drinking water from your primary water source ?'",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/collect_quant_endline.tex"))


#part 2

filtered_df <- df.temp.consent %>%
  filter(R_E_quant %in% c("All of it (100%)", "More than half of it", "Half of it (50%)" ) & R_E_collect_prim_freq < 3)

View(filtered_df)


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_quant, R_E_collect_prim_freq) %>%
  ungroup()



View(result)

stargazer(result, summary=F, title= "Inconsistency between 'how much of your drinking watercame from your primary drinking water source' and 'In the past week, how many times did you collect drinking water from your primary water source ?'",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/collect_quant2_endline.tex"))



#--------------------------------------------------------------------------------
#Consistency of  secondary source with quant
#-----------------------------------------------------------------------------


filtered_df <- df.temp.consent %>%
  filter(R_E_quant %in% c("Half of it (50%)", "Less than half of it", "None of it (0%)") & R_E_water_sec_yn == "No")

View(filtered_df)


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_quant, R_E_water_sec_yn) %>%
  ungroup()



View(result)


#--------------------------------------------------------------------------------
#Consistency of  sec_source_reason and water_sec_freq
#-----------------------------------------------------------------------------

#to check- check if enum has marked dont know in sec_source_reason even though they gave an asnwer to water_sec_freq

names(df.temp.consent)

df.temp.consent$R_E_water_sec_freq <- ifelse(df.temp.consent$R_E_water_sec_freq == "Daily", "Daily", 
                                    ifelse(df.temp.consent$R_E_water_sec_freq == "Every 2-3 days in a week", "Every 2-3 days in a week", 
                                           ifelse(df.temp.consent$R_E_water_sec_freq == "Once a week", "Once a week", 
                                                  ifelse(df.temp.consent$R_E_water_sec_freq == "Once every two weeks", "Once every two weeks", 
                                                         ifelse(df.temp.consent$R_E_water_sec_freq == "Once a month", "Once a month", 
                                                                ifelse(df.temp.consent$R_E_water_sec_freq == "Once every few months", "Once every few months", 
                                                                       ifelse(df.temp.consent$R_E_water_sec_freq == "Once a year", "Once a year", 
                                                                              ifelse(df.temp.consent$R_E_water_sec_freq == "No fixed schedule", "No fixed schedule", 
                                                                                     df.temp.consent$R_E_water_sec_freq))))))))
                                                  
                                                                              
                                                                       



filtered_df <- df.temp.consent %>%
  filter(R_E_sec_source_reason_999 == 1 & R_E_water_sec_freq != "Don’t know")



View(filtered_df)


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_sec_source_reason_999, R_E_water_sec_freq) %>%
  ungroup()


View(result)

stargazer(result, summary=F, title= "Inconsistency between 'In what circumstances do you collect drinking water from these other/secondary water sources?' and 'A15) Generally, when do you collect water for drinking from these other/secondary water sources?'  ",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/sec_reason_freq_endline.tex"))



#--------------------------------------------------------------------------------
#Consistency of  tap_supply_daily and tap_supply_freq
#-----------------------------------------------------------------------------
#to do- check for any negative values in tap_supply_daily along with 0 because this questions generally in a day how mant times it happens so if they say that they drink from JJM and in the ques tap_supply_freq they have selected option 1 i..e daily then they shouldn't write 0 here

# 1. check for negative values in tap_supply_daily

filtered_df <- df.temp.consent %>%
  filter(R_E_tap_supply_daily < 0)


df.temp.consent$R_E_tap_supply_freq <- ifelse(df.temp.consent$R_E_tap_supply_freq == "Daily", "Daily", 
                                             ifelse(df.temp.consent$R_E_tap_supply_freq == "Few days in a week", "Few days in a week", 
                                                    ifelse(df.temp.consent$R_E_tap_supply_freq == "Once a week", "Once a week", 
                                                           ifelse(df.temp.consent$R_E_tap_supply_freq == "Few times in a month", "Few times in a month", 
                                                                  ifelse(df.temp.consent$R_E_tap_supply_freq == "Once a month", "Once a month", 
                                                                         ifelse(df.temp.consent$R_E_tap_supply_freq == "No fixed schedule", "No fixed schedule", 
                                                                                ifelse(df.temp.consent$R_E_tap_supply_freq == "Other", "Other", 
                                                                                       ifelse(df.temp.consent$R_E_tap_supply_freq == "Don’t know", "Don’t know", 
                                                                                              ifelse(df.temp.consent$R_E_tap_supply_freq == "Refused to answer", "Refused to answer", 
                                                                                                     df.temp.consent$R_E_tap_supply_freq)))))))))
                                             


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_tap_supply_daily) %>%
  ungroup()

View(result)


# 2. check for 0 values in  tap_supply_daily and at the same time 1 in tap_supply_freq


filtered_df <- df.temp.consent %>%
  filter(R_E_tap_supply_daily == 0 & R_E_tap_supply_freq == "Daily")


result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_tap_supply_daily, R_E_tap_supply_freq) %>%
  ungroup()


View(result)


#--------------------------------------------------------------------------------
#Consistency of  water_treat_kids and water_treat
#-----------------------------------------------------------------------------

#to do- check if they say Yes in this water_treat_kids but say No to water_treat variable because it can't be the case that the treat water for thier HH but say no to treatment in general. 

browse <- df.temp.consent %>% select(R_E_water_treat_kids, R_E_water_treat )
View(browse)

df.temp.consent$R_E_water_treat_kids <- ifelse(df.temp.consent$R_E_water_treat_kids == 1, "Yes", 
                                              ifelse(df.temp.consent$R_E_water_treat_kids == 0, "No", 
                                                     ifelse(df.temp.consent$R_E_water_treat_kids == 999, "Don't know", 
                                                            ifelse(df.temp.consent$R_E_water_treat_kids == -98, "Refused to answer", 
                                                                   df.temp.consent$R_E_water_treat_kids))))


df.temp.consent$R_E_water_treat <- ifelse(df.temp.consent$R_E_water_treat == 1, "Yes", 
                                               ifelse(df.temp.consent$R_E_water_treat == 0, "No", 
                                                      ifelse(df.temp.consent$R_E_water_treat == 999, "Don't know", 
                                                             ifelse(df.temp.consent$R_E_water_treat == -98, "Refused to answer", 
                                                                    df.temp.consent$R_E_water_treat))))

df.temp.consent$R_E_water_source_kids <- ifelse(df.temp.consent$R_E_water_source_kids == 1, "Yes", 
                                          ifelse(df.temp.consent$R_E_water_source_kids == 0, "No", 
                                                 ifelse(df.temp.consent$R_E_water_source_kids == 999, "Don't know", 
                                                        ifelse(df.temp.consent$R_E_water_source_kids == -98, "Refused to answer", 
                                                               ifelse(df.temp.consent$R_E_water_source_kids == 3, "No U5 child present in the HH", 
                                                                      ifelse(df.temp.consent$R_E_water_source_kids == 4, "U5 child is being breastfed exclusively", 
                                                                             df.temp.consent$R_E_water_source_kids))))))
                                                 
                                                                      

filtered_df <- df.temp.consent %>%
  filter(R_E_water_treat_kids == "Yes" & R_E_water_treat == "No" & R_E_water_source_kids == "Yes")



result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_water_treat_kids, R_E_water_treat, R_E_water_source_kids) %>%
  ungroup()



View(result)


stargazer(result, summary=F, title= "Inconsistency between 'Do you ever do anything to the water for your youngest children to make it safe for drinking?' and 'In the last one month, did your household do anything extra to the drinking water to make it safe before drinking it?'  ",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/treat_kids_HH_endline.tex"))



#--------------------------------------------------------------------------------
#Consistency of  Water_prim_source_kids and water_source_prim
#-----------------------------------------------------------------------------

browse <- df.temp.consent %>% select(R_E_water_prim_source_kids, R_E_water_source_prim )
View(browse)


df.temp.consent$R_E_water_prim_source_kids <- ifelse(df.temp.consent$R_E_water_prim_source_kids == "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM", "JJM", 
                                                ifelse(df.temp.consent$R_E_water_prim_source_kids == "Government provided community standpipe (connected to piped system, through Vasu", "Govt provided community standpipe", 
                                                       ifelse(df.temp.consent$R_E_water_prim_source_kids == "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)", "Gram Panchayat/other community standpipe", 
                                                              ifelse(df.temp.consent$R_E_water_prim_source_kids == "Manual handpump", "Manual handpump", 
                                                                     ifelse(df.temp.consent$R_E_water_prim_source_kids == "Covered dug well", "Covered dug well", 
                                                                            ifelse(df.temp.consent$R_E_water_prim_source_kids == "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c", "surface water",
                                                                                   ifelse(df.temp.consent$R_E_water_prim_source_kids == "Uncovered dug well", "Uncovered dug well", 
                                                                                          ifelse(df.temp.consent$R_E_water_prim_source_kids == "Private Surface well", "Private Surface well", 
                                                                                                 ifelse(df.temp.consent$R_E_water_prim_source_kids == "Borewell operated by electric pump", "Borewell", 
                                                                                                        ifelse(df.temp.consent$R_E_water_prim_source_kids == "Household tap connections not connected to RWSS/Basudha/JJM tank", "Non-JJM household tap connections", 
                                                                                                               ifelse(df.temp.consent$R_E_water_prim_source_kids == "Other", "Other", 
                                                                                                                      df.temp.consent$R_E_water_prim_source_kids)))))))))))

                                                                                                                      



filtered_df <- df.temp.consent %>%
  filter(R_E_water_prim_source_kids == R_E_water_source_prim)



result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_water_prim_source_kids, R_E_water_source_prim) %>%
  ungroup()



View(result)




#--------------------------------------------------------------------------------
#Consistency of  Water_prim_source_preg and water_source_prim
#-----------------------------------------------------------------------------

browse <- df.temp.consent %>% select(R_E_water_prim_source_preg, R_E_water_source_prim )
View(browse)


df.temp.consent$R_E_water_prim_source_preg <- ifelse(df.temp.consent$R_E_water_prim_source_preg == "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM", "JJM", 
                                                     ifelse(df.temp.consent$R_E_water_prim_source_preg == "Government provided community standpipe (connected to piped system, through Vasu", "Govt provided community standpipe", 
                                                            ifelse(df.temp.consent$R_E_water_prim_source_preg == "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)", "Gram Panchayat/other community standpipe", 
                                                                   ifelse(df.temp.consent$R_E_water_prim_source_preg == "Manual handpump", "Manual handpump", 
                                                                          ifelse(df.temp.consent$R_E_water_prim_source_preg == "Covered dug well", "Covered dug well", 
                                                                                 ifelse(df.temp.consent$R_E_water_prim_source_preg == "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c", "surface water",
                                                                                        ifelse(df.temp.consent$R_E_water_prim_source_preg == "Uncovered dug well", "Uncovered dug well", 
                                                                                               ifelse(df.temp.consent$R_E_water_prim_source_preg == "Private Surface well", "Private Surface well", 
                                                                                                      ifelse(df.temp.consent$R_E_water_prim_source_preg == "Borewell operated by electric pump", "Borewell", 
                                                                                                             ifelse(df.temp.consent$R_E_water_prim_source_preg == "Household tap connections not connected to RWSS/Basudha/JJM tank", "Non-JJM household tap connections", 
                                                                                                                    ifelse(df.temp.consent$R_E_water_prim_source_preg == "Other", "Other", 
                                                                                                                           df.temp.consent$R_E_water_prim_source_preg)))))))))))





filtered_df <- df.temp.consent %>%
  filter(R_E_water_prim_source_preg == R_E_water_source_prim)



result <- filtered_df %>%
  select(unique_id, R_E_enum_name_label, R_E_water_prim_source_preg, R_E_water_source_prim) %>%
  ungroup()



View(result)



#--------------------------------------------------------------------------------
#Consistency of  water_source_kids 
#-----------------------------------------------------------------------------
#to do- In the var- water_source_kids check the % of each option and do a consistency check with U5 child in that household. For ge check new member roster if they have added any non visitor U5 child or check the census member list to see if there is nay non viistor U5 child living in that housheold (you can also directly check the var Cen_child_residence but this might not present for all the applicable U5 child if they were unavilable at the time of the survey

# PRIMARY WATER SOURCE DISTRIBUTION IN GENERAL


water_source_percentage <- df.temp.consent %>%
  group_by(R_E_water_prim_source_kids) %>%
  summarise(count = n()) %>%
  mutate(percentage = (count / sum(count)) * 100)


View(water_source_percentage)



#is U5 kid present there 
water_source_percentage <- df.temp.consent %>%
  group_by(R_E_water_source_kids) %>%
  summarise(count = n()) %>%
  mutate(percentage = (count / sum(count)) * 100)


View(water_source_percentage)


stargazer(water_source_percentage, summary=F, title= "Do your youngest children drink from the same water source as the household’s primary drinking water source?",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/U5_child_same_as_HH_endline.tex"))


#///////////////////////////////////////////////////////////////////////////////
#--------------------------------------------------------------------------------
#CHECKS For DON'T KNOWS VARIABLE WISE 
#-----------------------------------------------------------------------------
#///////////////////////////////////////////////////////////////////////////////


# Define the previous and new sets of variables to check for "999"
previous_vars <- c("R_E_water_source_prim", "R_E_water_sec_yn", "R_E_water_source_main_sec",
                   "R_E_quant", "R_E_water_sec_freq", "R_E_collect_resp", "R_E_people_prim_water",
                   "R_E_prim_collect_resp", "R_E_where_prim_locate", "R_E_where_prim_locate_enum_obs",
                   "R_E_collect_time", "R_E_collect_prim_freq", "R_E_water_treat", "R_E_water_stored",
                   "R_E_not_treat_tim", "R_E_treat_resp", "R_E_treat_primresp", "R_E_treat_time",
                   "R_E_treat_freq", "R_E_collect_treat_difficult", "R_E_clean_freq_containers",
                   "R_E_clean_time_containers", "R_E_water_source_kids", "R_E_water_prim_source_kids",
                   "R_E_water_source_preg", "R_E_water_prim_source_preg", "R_E_water_treat_kids",
                   "R_E_jjm_drinking", "R_E_tap_supply_freq", "R_E_tap_supply_daily",
                   "R_E_jjm_stored", "R_E_jjm_yes", "R_E_tap_function")

new_vars <- c("R_E_sec_source_reason_999", "R_E_water_treat_type_999", "R_E_water_treat_kids_type_999",
              "R_E_reason_nodrink_999", "R_E_jjm_use_999", "R_E_tap_function_reason_999")



# Function to calculate count and percentage of "999" for a variable

calculate_dont_know <- function(data, var) {
  total <- sum(!is.na(data[[var]]))
  count_999 <- sum(data[[var]] == 999, na.rm = TRUE)
  percent_999 <- (count_999 / total) * 100
  return(data.frame(Variable = var, Count_of_DK = count_999, Total_count_of_DK = total, Percent_of_DK = percent_999))
}

calculate_dont_know_M <- function(data, var) {
  total <- sum(!is.na(data[[var]]))
  count_999 <- sum(data[[var]] == 1, na.rm = TRUE)
  percent_999 <- (count_999 / total) * 100
  return(data.frame(Variable = var, Count_of_DK = count_999, Total_count_of_DK = total, Percent_of_DK = percent_999))
}

# Apply the function to each variable in the previous and new sets
previous_summary <- do.call(rbind, lapply(previous_vars, calculate_dont_know, data = df.temp.consent))
View(previous_summary)
new_summary <- do.call(rbind, lapply(new_vars, calculate_dont_know_M, data = df.temp.consent))

# Combine the two summary tables
combined_summary <- bind_rows(previous_summary, new_summary)

# Print the combined summary table

combined_summary <- combined_summary %>%
  mutate(Percent_of_DK = round(Percent_of_DK, 2))


View(combined_summary)


stargazer(combined_summary, summary=F, title= "Variable wise dont knows",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/var_wise_999_endline.tex"))


#--------------------------------------------------------------------------------
#CHECKS For DON'T KNOWS VARIABLE WISE AND ENUM WISE
#-----------------------------------------------------------------------------

# Define the previous and new sets of variables to check for "999"
previous_vars <- c("R_E_water_source_prim", "R_E_water_sec_yn", "R_E_water_source_main_sec",
                   "R_E_quant", "R_E_water_sec_freq", "R_E_collect_resp", "R_E_people_prim_water",
                   "R_E_prim_collect_resp", "R_E_where_prim_locate", "R_E_where_prim_locate_enum_obs",
                   "R_E_collect_time", "R_E_collect_prim_freq", "R_E_water_treat", "R_E_water_stored",
                   "R_E_not_treat_tim", "R_E_treat_resp", "R_E_treat_primresp", "R_E_treat_time",
                   "R_E_treat_freq", "R_E_collect_treat_difficult", "R_E_clean_freq_containers",
                   "R_E_clean_time_containers", "R_E_water_source_kids", "R_E_water_prim_source_kids",
                   "R_E_water_source_preg", "R_E_water_prim_source_preg", "R_E_water_treat_kids",
                   "R_E_jjm_drinking", "R_E_tap_supply_freq", "R_E_tap_supply_daily",
                   "R_E_jjm_stored", "R_E_jjm_yes", "R_E_tap_function")

new_vars <- c("R_E_sec_source_reason_999", "R_E_water_treat_type_999", "R_E_water_treat_kids_type_999",
              "R_E_reason_nodrink_999", "R_E_jjm_use_999", "R_E_tap_function_reason_999")

# Function to calculate count and percentage of "999" for a variable grouped by R_E_enum_name_label
calculate_dont_know <- function(data, var) {
  data %>%
    group_by(R_E_enum_name_label) %>%
    summarise(
      Count_999 = sum(data[[var]] == 999, na.rm = TRUE),
      Total_count = sum(!is.na(data[[var]])),
      Percent_999 = (Count_999 / Total_count) * 100
    ) %>%
    mutate(Variable = var) %>%
    select(Variable, R_E_enum_name_label, Count_999, Total_count, Percent_999)
}

# Function to calculate count and percentage of "1" for a variable grouped by R_E_enum_name_label
calculate_dont_know_M <- function(data, var) {
  data %>%
    group_by(R_E_enum_name_label) %>%
    summarise(
      Count_999 = sum(data[[var]] == 1, na.rm = TRUE),
      Total_count = sum(!is.na(data[[var]])),
      Percent_999 = (Count_999 / Total_count) * 100
    ) %>%
    mutate(Variable = var) %>%
    select(Variable, R_E_enum_name_label, Count_999, Total_count, Percent_999)
}

# Apply the function to each variable in the previous and new sets grouped by R_E_enum_name_label
previous_summary <- do.call(rbind, lapply(previous_vars, calculate_dont_know, data = df.temp.consent))
new_summary <- do.call(rbind, lapply(new_vars, calculate_dont_know_M, data = df.temp.consent))

# Combine the two summary tables
combined_summary <- bind_rows(previous_summary, new_summary)

# Print the combined summary table
View(combined_summary)

combined_summary_filtered <-  combined_summary %>%
  filter(Count_999 != 0)

View(combined_summary_filtered)


combined_summary_filtered <- combined_summary_filtered %>%
  mutate(Percent_999 = round(Percent_999, 1))

stargazer(combined_summary_filtered, summary=F, title= "Variable and Enum wise dont knows",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/var_enum_wise_999_endline.tex"))




#--------------------------------------------------------------------------------
#CHECKS For OUTLIERS VARIABLE WISE
#-----------------------------------------------------------------------------

# Define the previous and new sets of variables to check for "999"

  

# List of variables to check for outliers
outliers_vars <- c("R_E_treat_time", "R_E_clean_freq_containers", "R_E_clean_time_containers", 
                   "R_E_collect_time", "R_E_collect_prim_freq", "R_E_treat_time", 
                   "R_E_treat_freq", "R_E_collect_time")

# Function to find outliers using IQR method and excluding specific values
find_outliers <- function(data, var) {
  # Remove NAs and filter out specific values
  filtered_data <- data %>%
    filter(!is.na(.[[var]]) & !.[[var]] %in% c(999, 888, -98)) %>%
    select(all_of(var))
  
  var_data <- filtered_data[[var]]
  
  # Calculate Q1, Q3, and IQR
  Q1 <- quantile(var_data, 0.10)
  Q3 <- quantile(var_data, 0.90)
  IQR <- Q3 - Q1
  
  # Define outliers
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  outliers <- data %>%
    filter((.[[var]] < lower_bound | .[[var]] > upper_bound) & 
             !is.na(.[[var]]) & !.[[var]] %in% c(999, 888, -98))
  
  return(outliers %>% mutate(Variable = var))
}

# Apply the function to each variable
outliers_list <- lapply(outliers_vars, find_outliers, data = df.temp.consent)

# Combine results into a single data frame with variable names
outliers_combined <- bind_rows(outliers_list)

# Print the combined outliers data frame
print(outliers_combined)

outliers_combined_f <- outliers_combined %>% select(R_E_treat_time, R_E_clean_freq_containers, R_E_clean_time_containers, R_E_collect_time,  
                                                    R_E_collect_prim_freq, R_E_treat_time,  
                                                    R_E_treat_freq, R_E_collect_time)

outliers_combined_f_filtered <- outliers_combined_f %>%
  filter_all(all_vars(!(. %in% c(999, 888, -98))))


View(outliers_combined_f_filtered)


stargazer(outliers_combined_f_filtered, summary=F, title= "Variable wise Outliers",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/var_outliers_endline.tex"))


#--------------------------------------------------------------------------------
#CHECKS For OUTLIERS VARIABLE AND ENUM WISE
#-----------------------------------------------------------------------------

# List of variables to check for outliers
outliers_vars <- c("R_E_treat_time", "R_E_clean_freq_containers", "R_E_clean_time_containers", 
                   "R_E_collect_time", "R_E_collect_prim_freq", "R_E_treat_time", 
                   "R_E_treat_freq", "R_E_collect_time")

# Function to find outliers using IQR method and excluding specific values
find_outliers <- function(data, var) {
  # Remove NAs and filter out specific values
  filtered_data <- data %>%
    filter(!is.na(.[[var]]) & !.[[var]] %in% c(999, 888, -98)) %>%
    select(all_of(var), unique_id, R_E_enum_name_label)
  
  var_data <- filtered_data[[var]]
  
  # Calculate Q1, Q3, and IQR
  Q1 <- quantile(var_data, 0.10)
  Q3 <- quantile(var_data, 0.90)
  IQR <- Q3 - Q1
  
  # Define outliers
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  outliers <- data %>%
    filter((.[[var]] < lower_bound | .[[var]] > upper_bound) & 
             !is.na(.[[var]]) & !.[[var]] %in% c(999, 888, -98)) %>%
    select(unique_id, R_E_enum_name_label, all_of(var)) %>%
    mutate(Variable = var)
  
  return(outliers)
}

names(df.temp.consent)
issues <- df.temp.consent %>% filter(R_E_enum_name_label == "Pabitra Sahoo" & R_E_tap_issues == "Yes")
View(issues)
issues <- issues %>% select(R_E_r_cen_village_name_str, R_E_water_source_prim, R_E_tap_issues, R_E_water_source_sec, R_E_jjm_drinking, R_E_jjm_yes)

# Apply the function to each variable
outliers_list <- lapply(outliers_vars, find_outliers, data = df.temp.consent)

# Combine results into a single data frame with variable names
outliers_combined <- bind_rows(outliers_list)

# Print the combined outliers data frame
print(outliers_combined)

# Split the combined data frame into a list of data frames, one for each variable
outliers_split <- split(outliers_combined, outliers_combined$Variable)

# Print each table of outliers
for (var in names(outliers_split)) {
  cat(paste("\nOutliers for variable:", var, "\n"))
  print(outliers_split[[var]])
}

# Optionally, save each table to a separate CSV file
for (var in names(outliers_split)) {
  write.csv(outliers_split[[var]], paste0("outliers_", var, ".csv"), row.names = FALSE)
}

# View the combined outliers data frame with unique_id and R_E_enum_name_label
View(outliers_combined)

star.out <- stargazer(outliers_combined, 
                      summary = FALSE, 
                      title = "Variable and Enum wise Outliers", 
                      float = FALSE,
                      rownames = FALSE,
                      covariate.labels = NULL,
                      type = "latex")


star.out <- sub(" cccccccc", " |L|L|L|L|L|L|L|L|L|", star.out)


starpolishr::star_tex_write(star.out, file = paste0(overleaf(), "Table/var_enum_outliers_endline.tex"))




# Install and load the required packages
if (!requireNamespace("kableExtra", quietly = TRUE))
  install.packages("kableExtra")

library(knitr)
library(kableExtra)

# Create a table using kable and kableExtra
star.out <- kable(outliers_combined, format = "latex", booktabs = TRUE) %>%
  kable_styling(latex_options = c("striped", "scale_down", "hold_position"), 
                full_width = FALSE)

View(star.out)
# Write the table to a .tex file
writeLines(star.out, con = paste0(overleaf(), "Table/var_enum_outliers_endline.tex"))



#--------------------------------------------------------------------------------
#CHECKS For % of 555 in tap_supply_daily
#-----------------------------------------------------------------------------

filtered_df <- df.temp.consent %>%
  filter(R_E_tap_supply_daily== 555)

filtered_df <- filtered_df %>% select(R_E_enum_name_label, R_E_tap_supply_daily)

View(filtered_df)
new_vars <- c("R_E_tap_supply_daily")

calculate_555 <- function(data, var) {
  data %>%
    summarise(
      Count_555 = sum(data[[var]] == 555, na.rm = TRUE),
      Total_count = sum(!is.na(data[[var]])),
      Percent_555 = (Count_555 / Total_count) * 100
    ) %>%
    mutate(Variable = var) %>%
    select(Variable, Count_555, Total_count, Percent_555)
}

# Apply the function to each variable in the previous and new sets grouped by R_E_enum_name_label
no_of_555 <- do.call(rbind, lapply(new_vars, calculate_555, data = df.temp.consent))

View(no_of_555)



#--------------------------------------------------------------------------------
#CHECKS For % Yes and No in R_E_jjm_yes
#-----------------------------------------------------------------------------

summary_df_yes <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_yes == "Yes"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_yes)


summary_df_no <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_yes == "No"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_no)



# Combine the data frames
combined_summary_df <- bind_rows(
  mutate(summary_df_yes, Response = "Yes"),
  mutate(summary_df_no, Response = "No")
)

View(combined_summary_df)


# Plotting the data
plot <- ggplot(combined_summary_df, aes(x = R_E_enum_name_label, y = Percent_JJM, fill = Response)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of JJM Responses by Enum Category",
       x = "Enum Category",
       y = "Percentage (%)",
       fill = "Response") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

# Display the plot
print(plot)


ggplot2::ggsave( paste0(overleaf(),"Figure/jjm_enum_endline.png"), plot, bg = "white", width = 10, height= 10,dpi=200)



#--------------------------------------------------------------------------------
#CHECKS For % Yes and No in tap_issues
#-----------------------------------------------------------------------------


summary_df_yes <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_tap_issues == "Yes"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_yes)


summary_df_no <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_tap_issues == "No"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_no)



# Combine the data frames
combined_summary_df <- bind_rows(
  mutate(summary_df_yes, Response = "Yes"),
  mutate(summary_df_no, Response = "No")
)

View(combined_summary_df)


# Plotting the data
plot <- ggplot(combined_summary_df, aes(x = R_E_enum_name_label, y = Percent_JJM, fill = Response)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of Tap issuess by Enum Category",
       x = "Enum Category",
       y = "Percentage (%)",
       fill = "Response") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

# Display the plot
print(plot)


ggplot2::ggsave( paste0(overleaf(),"Figure/tap_issues_enum_endline.png"), plot, bg = "white", width = 10, height= 10,dpi=200)



#--------------------------------------------------------------------------------
#CHECKS For % tap issues type
#-----------------------------------------------------------------------------



var_label(df.temp.consent$R_E_tap_issues_type_1) <- "Smell issues"
var_label(df.temp.consent$R_E_tap_issues_type_2) <- "Taste issues"
var_label(df.temp.consent$R_E_tap_issues_type_3) <- "Water is muddy/silty"
var_label(df.temp.consent$R_E_tap_issues_type_4) <- "Cooking issues"
var_label(df.temp.consent$R_E_tap_issues_type_5) <- "Skin-related issues"
var_label(df.temp.consent$R_E_tap_issues_type__77) <- "Other"

names(df.temp.consent)
variables <- c("R_E_tap_issues_type_1", 
               "R_E_tap_issues_type_2", 
               "R_E_tap_issues_type_3", 
               "R_E_tap_issues_type_4", 
               "R_E_tap_issues_type_5", 
               "R_E_tap_issues_type__77")


sums <- df.temp.consent %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))

sums_long <- sums %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Sum")

print(sums_long)

View(sums_long)

# Calculate the total sum of all the variables
total_sum <- sum(sums_long$Sum)

# Add a percentage column
sums_long <- sums_long %>%
  mutate(Percentage = (Sum / total_sum) * 100)

# Print the results
print(sums_long)


sums_long$Variable <- sapply(sums_long$Variable, function(x) var_label(df.temp.consent[[x]]))


sums_long_filtered <- sums_long %>%
  mutate(Percentage = round(Percentage, 1))


# Generate the LaTeX table
stargazer(sums_long_filtered, 
          summary = FALSE, 
          title = "Tap issues breakdown", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/tap_issues_endline.tex"))



#-------------------------------------------------------------------------------------------------------------------
# tap issues type DISTRIBUTION BY ENUM
#-------------------------------------------------------------------------------------------------------------------

# Group by enumerator and calculate the sums for each secondary water source
enum_sums <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))



# Convert to long format for better readability
enum_sums_long <- enum_sums %>%
  pivot_longer(cols = -R_E_enum_name_label, names_to = "Tap_issues_type", values_to = "Sum")

# Calculate the total sum of secondary water sources for each enumerator
enum_totals <- enum_sums_long %>%
  group_by(R_E_enum_name_label) %>%
  summarise(Total_Sum = sum(Sum))

# Merge the totals back with the long format data
enum_sums_long <- enum_sums_long %>%
  left_join(enum_totals, by = "R_E_enum_name_label")

# Calculate the percentage of each secondary water source within each enumerator group
enum_sums_long <- enum_sums_long %>%
  mutate(Percentage = (Sum / Total_Sum) * 100)

# Print the results
print(enum_sums_long)

View(enum_sums_long)

enum_sums_long <- enum_sums_long %>% filter(Percentage != 0 | Percentage != NaN )

enum_sums_long$Tap_issues_type <- sapply(enum_sums_long$Tap_issues_type, function(x) var_label(df.temp.consent[[x]]))



# Create the bar plot with adjusted legend size and increased plot size
enum_sums_long_filtered <- enum_sums_long %>%
  filter(Percentage > 0)

water_sec_enum <- ggplot(enum_sums_long_filtered, aes(x = R_E_enum_name_label, y = Percentage, fill = Tap_issues_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of tap issues type by Enumerator",
       x = "Enumerator",
       y = "Percentage",
       fill = "Tap_issues_type") +
  scale_fill_brewer(palette = "Set2") +  # Use a colorblind-friendly palette
  theme_minimal() +
  theme(
    legend.text = element_text(size = 8),      # Reduce legend text size
    legend.title = element_text(size = 10),    # Reduce legend title size
    legend.key.size = unit(0.5, "cm"),         # Reduce legend key size
    plot.title = element_text(size = 14),      # Increase plot title size
    axis.title = element_text(size = 12),      # Increase axis titles size
    axis.text = element_text(size = 13),       # Increase axis text size
    axis.text.x = element_text(angle = 45, hjust = 1),  # Tilt x-axis labels
    legend.position = "right",                 # Position legend to the right
    legend.justification = "center",           # Center the legend vertically
    legend.box.margin = margin(0, 0, 0, 10)    # Add margin to move the legend outside
  )

print(water_sec_enum)

ggplot2::ggsave( paste0(overleaf(),"Figure/tap_type_enum_endline.png"), water_sec_enum, bg = "white", width = 15, height= 10,dpi=200)



#--------------------------------------------------------------------------------
#CHECKS For % JJM_drinking
#-----------------------------------------------------------------------------

#----------------------------------------------------------------------
#overall percentage
#----------------------------------------------------------------------

summary_df_all_yes <- df.temp.consent %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_drinking == "Yes"),
    Percent_JJM = (JJM_count / Total) * 100
  )


summary_df_all_no <- df.temp.consent %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_drinking  == "No"),
    Percent_JJM = (JJM_count / Total) * 100
  )


combined_summary_all <- bind_rows(
  mutate(summary_df_all_yes, Response = "Yes"),
  mutate(summary_df_all_no, Response = "No")
)

View(combined_summary_all)

stargazer(combined_summary_all, 
          summary = FALSE, 
          title = "JJM for drinking (general)", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/jjm_drinking_all_endline.tex"))




#----------------------------------------------------------------------
#enum wise % 
#----------------------------------------------------------------------

summary_df_yes <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_drinking == "Yes"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_yes)


summary_df_no <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(
    Total = n(),
    JJM_count = sum(R_E_jjm_drinking  == "No"),
    Percent_JJM = (JJM_count / Total) * 100
  )

View(summary_df_no)



# Combine the data frames
combined_summary_df <- bind_rows(
  mutate(summary_df_yes, Response = "Yes"),
  mutate(summary_df_no, Response = "No")
)

View(combined_summary_df)


# Plotting the data
plot <- ggplot(combined_summary_df, aes(x = R_E_enum_name_label, y = Percent_JJM, fill = Response)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of JJM for drinking by Enum Category",
       x = "Enum Category",
       y = "Percentage (%)",
       fill = "Response") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

# Display the plot
print(plot)


ggplot2::ggsave( paste0(overleaf(),"Figure/jjm_drinking_enum_endline.png"), plot, bg = "white", width = 10, height= 10,dpi=200)


#--------------------------------------------------------------------------------
#CHECKS For % collect_treat_difficult by enum
#-----------------------------------------------------------------------------

browse <- df.temp.consent %>% select(R_E_collect_treat_difficult)
View(browse)

df.temp.consent$R_E_collect_treat_difficult <- ifelse(df.temp.consent$R_E_collect_treat_difficult == "Very difficult", "Very difficult", 
                                                ifelse(df.temp.consent$R_E_collect_treat_difficult == "Somewhat difficult", "Somewhat difficult", 
                                                       ifelse(df.temp.consent$R_E_collect_treat_difficult == "Neither difficult nor easy", "Neither difficult nor easy", 
                                                              ifelse(df.temp.consent$R_E_collect_treat_difficult == "Somewhat easy", "Somewhat easy", 
                                                                     ifelse(df.temp.consent$R_E_collect_treat_difficult == "Very easy", "Very easy", 
                                                                            ifelse(df.temp.consent$R_E_collect_treat_difficult == "Don’t know", "Don’t know",
                                                                                   df.temp.consent$R_E_collect_treat_difficult))))))




# Group and count occurrences
counts <- df.temp.consent %>%
  group_by(R_E_enum_name_label, R_E_collect_treat_difficult) %>%
  summarise(count = n(), .groups = 'drop')

# Calculate total counts for each enumerator
total_counts <- counts %>%
  group_by(R_E_enum_name_label) %>%
  summarise(total = sum(count), .groups = 'drop')

# Join the total counts with the counts and calculate percentages
percentage_df <- counts %>%
  left_join(total_counts, by = "R_E_enum_name_label") %>%
  mutate(percentage = (count / total) * 100) %>%
  select(R_E_enum_name_label, R_E_collect_treat_difficult, percentage)


View(percentage_df)

percentage_df <- percentage_df %>%
  filter(!is.na(R_E_collect_treat_difficult))
# Create the bar plot with adjusted legend size and increased plot size


water_prim_enum <- ggplot(percentage_df, aes(x = R_E_enum_name_label, y = percentage, fill = R_E_collect_treat_difficult)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of Difficulty in treating drinking water by Enumerator",
       x = "Enumerator",
       y = "Percentage",
       fill = "R_E_collect_treat_difficult") +
  scale_fill_brewer(palette = "Set2") +  # Use a colorblind-friendly palette
  theme_minimal() +
  theme(
    legend.text = element_text(size = 8),      # Reduce legend text size
    legend.title = element_text(size = 10),    # Reduce legend title size
    legend.key.size = unit(0.5, "cm"),         # Reduce legend key size
    plot.title = element_text(size = 14),      # Increase plot title size
    axis.title = element_text(size = 12),      # Increase axis titles size
    axis.text = element_text(size = 13),       # Increase axis text size
    axis.text.x = element_text(angle = 45, hjust = 1),  # Tilt x-axis labels
    legend.position = "right",                 # Position legend to the right
    legend.justification = "center",           # Center the legend vertically
    legend.box.margin = margin(0, 0, 0, 10)    # Add margin to move the legend outside
  )

print(water_prim_enum)

ggplot2::ggsave( paste0(overleaf(),"Figure/treat_diff_enum_endline.png"), water_prim_enum, bg = "white", width = 15, height= 10,dpi=200)




#--------------------------------------------------------------------------------
#CHECKS For % treatment type
#-----------------------------------------------------------------------------

names(df.temp.consent)

var_label(df.temp.consent$R_E_water_treat_type_1) <- "Filter the water through a cloth or sieve"
var_label(df.temp.consent$R_E_water_treat_type_2) <- "Let the water stand for some time before drinking"
var_label(df.temp.consent$R_E_water_treat_type_3) <- "Boil the water"
var_label(df.temp.consent$R_E_water_treat_type_4) <- "Add chlorine/ bleaching powder to the water"
var_label(df.temp.consent$R_E_water_treat_type__77) <- "Other"
var_label(df.temp.consent$R_E_water_treat_type_999) <- "Don’t know"

variables <- c("R_E_water_treat_type_1", 
               "R_E_water_treat_type_2", 
               "R_E_water_treat_type_3", 
               "R_E_water_treat_type_4", 
               "R_E_water_treat_type__77", 
               "R_E_water_treat_type_999")


sums <- df.temp.consent %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))

sums_long <- sums %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Sum")

print(sums_long)

View(sums_long)

# Calculate the total sum of all the variables
total_sum <- sum(sums_long$Sum)

# Add a percentage column
sums_long <- sums_long %>%
  mutate(Percentage = (Sum / total_sum) * 100)

# Print the results
print(sums_long)


sums_long$Variable <- sapply(sums_long$Variable, function(x) var_label(df.temp.consent[[x]]))


sums_long_filtered <- sums_long %>%
  mutate(Percentage = round(Percentage, 1))


sums_long_filtered  <- sums_long_filtered  %>% select(Variable, Percentage )
# Generate the LaTeX table
stargazer(sums_long_filtered, 
          summary = FALSE, 
          title = "Treatment types breakdown", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/treat_type_all_endline.tex"))


names(df.temp.consent)
# Tabulate counts of unique values in R_E_water_treat_oth
tabulated_counts <- table(df.temp.consent$R_E_water_treat_oth,df.temp.consent$R_E_enum_name_label, df.temp.consent$R_E_water_source_prim )

counts_df <- as.data.frame(tabulated_counts)
# Print the tabulated counts
View(counts_df)
stargazer(counts_df, 
          summary = FALSE, 
          title = "Others breakdown in Treatment types", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/treat_type_oth_endline.tex"))




#-------------------------------------------------------------------------------------------------------------------
# treatment type DISTRIBUTION BY ENUM
#-------------------------------------------------------------------------------------------------------------------

# Group by enumerator and calculate the sums for each secondary water source
enum_sums <- df.temp.consent %>%
  group_by(R_E_enum_name_label) %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))



# Convert to long format for better readability
enum_sums_long <- enum_sums %>%
  pivot_longer(cols = -R_E_enum_name_label, names_to = "Treatment_type", values_to = "Sum")

# Calculate the total sum of secondary water sources for each enumerator
enum_totals <- enum_sums_long %>%
  group_by(R_E_enum_name_label) %>%
  summarise(Total_Sum = sum(Sum))

# Merge the totals back with the long format data
enum_sums_long <- enum_sums_long %>%
  left_join(enum_totals, by = "R_E_enum_name_label")

# Calculate the percentage of each secondary water source within each enumerator group
enum_sums_long <- enum_sums_long %>%
  mutate(Percentage = (Sum / Total_Sum) * 100)

# Print the results
print(enum_sums_long)

View(enum_sums_long)

enum_sums_long <- enum_sums_long %>% filter(Percentage != 0 | Percentage != NaN )

enum_sums_long$Treatment_type <- sapply(enum_sums_long$Treatment_type, function(x) var_label(df.temp.consent[[x]]))



# Create the bar plot with adjusted legend size and increased plot size
enum_sums_long_filtered <- enum_sums_long %>%
  filter(Percentage > 0)

water_sec_enum <- ggplot(enum_sums_long_filtered, aes(x = R_E_enum_name_label, y = Percentage, fill = Treatment_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Percentage of Treatment type by Enumerator",
       x = "Enumerator",
       y = "Percentage",
       fill = "Treatment_type") +
  scale_fill_brewer(palette = "Set2") +  # Use a colorblind-friendly palette
  theme_minimal() +
  theme(
    legend.text = element_text(size = 8),      # Reduce legend text size
    legend.title = element_text(size = 10),    # Reduce legend title size
    legend.key.size = unit(0.5, "cm"),         # Reduce legend key size
    plot.title = element_text(size = 14),      # Increase plot title size
    axis.title = element_text(size = 12),      # Increase axis titles size
    axis.text = element_text(size = 13),       # Increase axis text size
    axis.text.x = element_text(angle = 45, hjust = 1),  # Tilt x-axis labels
    legend.position = "right",                 # Position legend to the right
    legend.justification = "center",           # Center the legend vertically
    legend.box.margin = margin(0, 0, 0, 10)    # Add margin to move the legend outside
  )

print(water_sec_enum)

ggplot2::ggsave( paste0(overleaf(),"Figure/treat_type_enum_endline.png"), water_sec_enum, bg = "white", width = 15, height= 10,dpi=200)









df.shadow <- df.temp.consent %>% filter(date >= as.Date("2024-02-15")) %>%   dplyr::select(R_E_enum_name_label,R_E_r_cen_village_name_str, R_E_a42_survey_accompany_num) %>%
  group_by(R_E_enum_name_label,R_E_r_cen_village_name_str ) %>% 
  dplyr:: summarise(mean = round(mean(R_E_a42_survey_accompany_num),1), 
                    min = round(min(R_E_a42_survey_accompany_num),1), max = round(max(R_E_a42_survey_accompany_num),1)) %>%
  rename(Village = R_E_r_cen_village_name_str, Enumerator = R_E_enum_name_label) 

View(df.shadow)

stargazer(df.shadow, summary=F, title= "Check instances of shadowing of enumerators during survey, by enumerator, by village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_shadow_endline.tex"))

