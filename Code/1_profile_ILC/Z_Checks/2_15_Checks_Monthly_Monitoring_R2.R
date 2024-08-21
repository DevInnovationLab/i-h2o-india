#------------------------------------------------ 
# title: "Code for Checks for High-frequency Follow Ups"
# author: "Jeremy Lowe, Archi Gupta"
# modified date: "2024-07-19"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------

#install.packages("experiment")
#install.packages("ggsignif")
#install.packages("table1")
#install.packages("gtsummary")
#install.packages("webshot2")
#install.packages("clubSandwich")
#install.packages("lmtest")
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


#---------------------------------Loading functions------------------------------


tc_stats <- function(idexx_data){
  
  tc <- idexx_data%>%
    group_by(assignment, sample_type) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      #"Upper CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 + 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      # "Lower CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   round(est - qt(0.975, df.residual(model)) * se, 1)
      # },
      # "Upper CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   round(est + qt(0.975, df.residual(model)) * se, 1)
      # },
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      #"Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 + 
      #  (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      # "Lower CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   round(est - qt(0.975, df.residual(model)) * se, 1)
      # },
      # "Upper CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   round(est + qt(0.975, df.residual(model)) * se, 1)
      # },
      #"Median MPN E. coli/100 mL" = median(ec_mpn),
      "Mean Log10 MPN Total Coliform/100 mL" = round(mean(cf_log), 3),
      "Mean Log10 MPN E. coli/100 mL" = round(mean(ec_log), 3),
      "WHO Risk - % of Samples with 'High Risk' (> 100 MPN/100 mL)" = round((sum(ec_risk == "High Risk") / n()) * 100, 1),
      "Tap Average Free Chlorine Concentration (mg/L)" = round(mean(tap_water_fc), 3)
    )
  
  # tc <- tc%>%
  #   #Adjusting so the CI cannot be more or less than 0 or 100
  #   mutate(`Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0,
  #                                      `Lower CI - EC` >= 0 ~ `Lower CI - EC`))%>%
  #   mutate(`Upper CI - TC` = case_when(`Upper CI - TC` > 100 ~ 100,
  #                                      `Upper CI - TC` <= 100 ~ `Upper CI - TC`))
  return(tc)
}


names(ms)
#stored_water_fc #tap_water_fc #R_Cen_village_name_str #assignment 

#----------------------------------Loading Cleaned Data---------------------------------

#Monthly IDEXX data
idexx <- read_csv(paste0(user_path(),"/3_final/idexx_monthly_master_cleaned_R2.csv"))

#Monthly household survey data
ms <- read_csv(paste0(user_path(), "/3_final/1_10_monthly_follow_up_cleaned_R2.csv"))


#Consented cases
ms_consent <- ms%>%  
  filter(consent == 1)

#------------------------------------------------------------------------
#HH availability stats 
#------------------------------------------------------------------------

HH_available <- ms %>%  filter(resp_available == 1) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("HH available" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

HH_permanently_left <- ms %>%  filter(resp_available == 2  ) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("HH permanently left" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)


HH_unavailable <- ms %>%  filter(resp_available != 1 & resp_available != 2) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("HH unavailable" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

Consented <- ms %>%  
  filter(consent == 1) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("HH consented" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)


df.progress <- left_join(HH_available,HH_permanently_left) %>% 
  left_join(HH_unavailable)  %>% left_join(Consented) %>% 
  rename(Village = R_Cen_village_name_str)
df.progress[is.na(df.progress)]<-0

Total <- df.progress %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))
Total$Village <- "Total"
df.progress<- rbind(df.progress, Total)

#View(df.progress)

#output to tex 
stargazer(df.progress, summary=F, title= "Overall Progress: Monthly IDEXX Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Progress_idexx_R2.tex"))



star.out <- stargazer(df.progress, 
                      summary = FALSE, 
                      title = "Overall Progress: Monthly IDEXX Survey", 
                      float = FALSE,
                      rownames = FALSE,
                      covariate.labels = NULL,
                      type = "latex")


star.out <- sub("cccccccc", " |L|L|L|L|L|L|L|L|L|", star.out)

star.out <- sub("cccccccc", "lccccccc", star.out)


starpolishr::star_tex_write(star.out, file = paste0(overleaf(), "Table/Table_Progress_idexx_R2.tex"))


#------------------------------------------------------------------------
#checking for replacements 
#------------------------------------------------------------------------



submissions <- ms  %>% select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate(Submission=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

Original_submissions <- ms %>%  filter(resp_available == 1 & replacement == 0 ) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("Original HH Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

Not_found <- ms  %>%  filter(resp_available != 1  ) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate("NOT Found" =n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

replacements <- ms %>%  filter( replacement == 1 ) %>% 
  select(R_Cen_village_name_str) %>%
  group_by(R_Cen_village_name_str) %>% mutate(Replacements=n()) %>% ungroup()  %>% unique() %>% 
  arrange(R_Cen_village_name_str)

df.rep <- left_join(submissions,Original_submissions)%>% left_join(Not_found) %>% left_join(replacements) %>% 
  rename(Village = R_Cen_village_name_str)
df.rep[is.na(df.rep)]<-0

Total <- df.rep %>% summarise(across(where(is.numeric), ~ sum(.x, na.rm = TRUE)))
Total$Village <- "Total"
df.rep<- rbind(df.rep, Total)

#output to tex 
stargazer(df.rep, summary=F, title= "Distribution of Replacements by Village",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/replacements_idexx_R2.tex"))



star.out <- stargazer(df.rep, 
                      summary = FALSE, 
                      title = "Distribution of Replacements by Village", 
                      float = FALSE,
                      rownames = FALSE,
                      covariate.labels = NULL,
                      type = "latex")








#-------------------------------------------------------------------------------------------------------------------
# reason of replacement
#-------------------------------------------------------------------------------------------------------------------

ms_consent_v <- ms_consent %>% select(reason_replacement)
#view(ms_consent_v)

# Recode the variable reason_replacement
ms_consent <- ms_consent %>%
  mutate(reason_replacement = ifelse(reason_replacement == 2, 1, reason_replacement))

ms_consent$reason_replacement <- ifelse(ms_consent$reason_replacement == "1", "HH was unavailable", 
                                        ifelse(ms_consent$water_source_prim == "3", "Household refused", 
                                               ifelse(ms_consent$water_source_prim == "4", "No stored or running water", 
                                                      ms_consent$water_source_prim)))

replace_percentage <- ms_consent %>%
  group_by(reason_replacement) %>%
  summarise(count = n()) %>%
  mutate(percentage = (count / sum(count)) * 100)


#View(replace_percentage)

stargazer(replace_percentage, summary=F, title= "Reasons of Replacement breakdown",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/replacement_reason_idexx.tex"))





#------------------------------------------------------------------------
# Drop rows where resp_available != 1
#------------------------------------------------------------------------

#View(ms_consent)


#------------------------------------------------------------------------------------------------------
# Consistency checks 
#-----------------------------------------------------------------------------------------------------

#_____________________________________________

#stored_sample_collection
#_____________________________________________


# Filter the dataset where replacement is 0
filtered_data <- ms_consent %>%
  filter(replacement == 0)

# Calculate the percentages of Yes and No for stored_sample_collection
stored_sample_summary <- filtered_data %>%
  group_by(stored_sample_collection) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

print(stored_sample_summary)

#_____________________________________________

#stored_tap
#_____________________________________________

# Calculate the percentages of Yes and No for stored_sample_collection
stored_sample_summary <- filtered_data %>%
  group_by(stored_tap) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

print(stored_sample_summary)

#_____________________________________________
#tap_sample_collection
#_____________________________________________

# Calculate the percentages of Yes and No for stored_sample_collection
tap_sample_summary <- filtered_data %>%
  group_by(tap_sample_collection) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

print(tap_sample_summary)

#_____________________________________________

#tap_error
#_____________________________________________

tap_error_sum <- ms_consent %>%
  group_by(tap_error) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

print(tap_error_sum)

#_____________________________________________

#stored_error
#_____________________________________________
stored_error_sum <- ms_consent %>%
  group_by(stored_error) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = (Count / sum(Count)) * 100)

print(stored_error_sum)



#-----------------------------------------------------------------
#  stored_water_fc    stored_water_tc   tap_water_tc tap_water_fc
#------------------------------------------------------------------

# NO values greater than 0.1 in C

# Filter the dataset for assignment == "C"
ms_C <- ms_consent %>% filter(assignment == "C")

View(ms_C)
# Count values greater than 1 for each variable
count_stored_water_fc <- sum(ms_C$stored_water_fc > 0.1, na.rm = TRUE)
count_stored_water_tc <- sum(ms_C$stored_water_tc > 0.1, na.rm = TRUE)
count_tap_water_tc <- sum(ms_C$tap_water_tc > 0.1, na.rm = TRUE)
count_tap_water_fc <- sum(ms_C$tap_water_fc > 0.1, na.rm = TRUE)

# Create a summary dataframe
summary_counts <- data.frame(
  Variable = c("stored_water_fc", "stored_water_tc", "tap_water_tc", "tap_water_fc"),
  Count_Greater_Than_0.1 = c(count_stored_water_fc, count_stored_water_tc, count_tap_water_tc, count_tap_water_fc)
)

# Print the summary dataframe
print(summary_counts)



#--------------------------------------------------------------------
# how many cases are there where values of FC is greater than TC 
#-------------------------------------------------------------------



# Count cases and include values for each unique_id
summary_counts <- ms_consent %>%
  group_by(unique_id) %>%
  summarise(
    stored_flag = sum(stored_water_tc < stored_water_fc, na.rm = TRUE),
    tap_flag = sum(tap_water_tc < tap_water_fc, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  # Join with the original dataset to include the values
  inner_join(ms_consent, by = "unique_id") %>%
  filter(stored_flag > 0 | tap_flag > 0) %>%
  select(unique_id, stored_water_fc, stored_water_tc, tap_water_tc, tap_water_fc,
         stored_flag, tap_flag)

# Print the summary dataframe
print(summary_counts)

stargazer(summary_counts, summary=F, title= "Cases where FC is lower than TC",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/TC_lower_than_FC_idexx.tex"))


#------------------------------------------------------------------------
#RANGE OF CHLORINE VALUES IN FC AND TC 
#------------------------------------------------------------------------

# Variables to check
variables <- c("stored_water_fc", "stored_water_tc", "HR_stored_fc", "HR_stored_tc", 
               "tap_water_fc", "tap_water_tc", "HR_tap_fc", "HR_tap_tc")

# Check the range of each variable
for (var in variables) {
  cat(paste("Range of", var, ":", range(ms_consent[[var]], na.rm = TRUE), "\n"))
}

variables_x <- c("stored_water_fc", "stored_water_tc", 
                 "tap_water_fc", "tap_water_tc")

# Melt the data for ggplot2
ms_melt <- melt(ms_consent, measure.vars = variables_x)

# Create the boxplot
# Create the boxplot with increased text size
tests <- ggplot(ms_melt, aes(x = variable, y = value)) +
  geom_boxplot() +
  labs(title = "Boxplot of Types of test",
       x = "Variables",
       y = "Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) # Increase plot title size and center it
print(tests)

# Save the plot
ggplot2::ggsave(paste0(overleaf(), "Figure/boxplot_test_types.png"), tests, bg = "white", width = 5, height = 5, dpi = 200)

#cases of HR testing village wise and dates for it 
#_______________________________________________________________
# HIGH RANGE TESTING VILLAGE AND DATE WISE
#_____________________________________________________________
# Variables to check
variables_H <- c( "HR_stored_fc", "HR_stored_tc", "HR_tap_fc", "HR_tap_tc")

names(ms_consent)

#SubmissionDate R_Cen_village_name_str

# Convert SubmissionDate to Date type

ms_consent$SubmissionDate <- mdy_hms(ms_consent$SubmissionDate)

#Format SubmissionDate to MDY format for displaying - The date right now is in character format
ms_consent$Date <- format(ms_consent$SubmissionDate, "%m/%d/%Y")

# Convert SubmissionDate to POSIXct type- The date now is in thje fomr that can be used in ggpplot
ms_consent$Date <- as.POSIXct(ms_consent$Date, format = "%m/%d/%Y")


ms_consent_view <- ms_consent %>% select(SubmissionDate,Date, R_Cen_village_name_str, HR_stored_fc, HR_stored_tc, HR_tap_fc, HR_tap_tc)
View(ms_consent_view)

class(ms_consent_view$Date)



plots <- list()
for (var in variables_H) {
  p <- ggplot(ms_consent, aes(x = Date, y = .data[[var]], color = R_Cen_village_name_str)) +
    geom_point() +
    facet_wrap(~R_Cen_village_name_str) +
    scale_x_datetime(labels = scales::date_format("%m/%d/%Y")) +
    labs(title = paste("Scatter plot of", var, "over Date"),
         x = "Date",
         y = var,
         color = "Village Name") +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  # Store the plot in the list
  plots[[var]] <- p
  
  # Print the plot
  print(p)
}

# Save the plots as PNG files
for (var in names(plots)) {
  ggsave(paste0(overleaf(),"Figure/scatter_plot_", var, ".png"), plot = plots[[var]], bg = "white", width = 10, height = 6)
}



# Assuming ms_melt includes a 'village' column
ms_melt <- melt(ms_consent, measure.vars = variables_x, id.vars = "R_Cen_village_name_str")

# Create the boxplot with facet wrap by village
tests <- ggplot(ms_melt, aes(x = variable, y = value)) +
  geom_boxplot() +
  labs(title = "Boxplot of Types of Test by Village",
       x = "Variables",
       y = "Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ R_Cen_village_name_str) # Facet wrap by village
print(tests)

ggplot2::ggsave(paste0(overleaf(), "Figure/boxplot_village_test_types.png"), tests, bg = "white", width = 5, height = 5, dpi = 200)


#water_source_prim

#-------------------------------------------------------------------------------------------------------------------
# PRIMARY SOURCE DISTRIBUTION IN GENERAL
#-------------------------------------------------------------------------------------------------------------------

ms_consent$water_source_prim <- ifelse(ms_consent$water_source_prim == "1", "JJM", 
                                       ifelse(ms_consent$water_source_prim == "2", "Govt provided community standpipe", 
                                              ifelse(ms_consent$water_source_prim == "3", "Gram Panchayat/other community standpipe", 
                                                     ifelse(ms_consent$water_source_prim == "4", "Manual handpump", 
                                                            ifelse(ms_consent$water_source_prim == "5", "Covered dug well", 
                                                                   ifelse(ms_consent$water_source_prim == "6", "surface water",
                                                                          ifelse(ms_consent$water_source_prim == "7", "Uncovered dug well", 
                                                                                 ifelse(ms_consent$water_source_prim == "8", "Private Surface well", 
                                                                                        ifelse(ms_consent$water_source_prim == "9", "Borewell", 
                                                                                               ifelse(ms_consent$water_source_prim == "10", "Non-JJM household tap connections", 
                                                                                                      ifelse(ms_consent$water_source_prim == "-77", "Other", 
                                                                                                             ms_consent$water_source_prim)))))))))))

water_source_percentage <- ms_consent %>%
  group_by(water_source_prim) %>%
  summarise(count = n()) %>%
  mutate(percentage = round((count / sum(count)) * 100, 1))

print(water_source_percentage)

#"% free chlorine samples > 0.6" = round((sum(chlorine_fc > 0.6, na.rm = TRUE) / n()) * 100, 1),


#View(water_source_percentage)

stargazer(water_source_percentage, summary=F, title= "Primary water source breakdown",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Prim_source_idexx.tex"))


#-------------------------------------------------------------------------------------------------------------------
# SECONDARY WATER SOURCE DISTRIBUTION IN GENERAL
#-------------------------------------------------------------------------------------------------------------------
# Summarize the data to get the count of each response
response_counts <- ms_consent %>%
  group_by(water_sec_yn) %>%
  summarise(count = n()) %>%
  ungroup()

# Calculate the total number of responses
total_responses <- sum(response_counts$count)

# Calculate the percentage for each response
response_percentages <- response_counts %>%
  mutate(percentage = (count / total_responses) * 100)

# Print the result
print(response_percentages)

stargazer(response_percentages, summary=F, title= "",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/sec_source_idexx.tex"))

var_label(ms_consent$water_source_sec_1) <- "JJM"
var_label(ms_consent$water_source_sec_2) <- "Govt provided community standpipe"
var_label(ms_consent$water_source_sec_3) <- "Gram Panchayat/other community standpipe"
var_label(ms_consent$water_source_sec_4) <- "Manual handpump"
var_label(ms_consent$water_source_sec_5) <- "Covered dug well"
var_label(ms_consent$water_source_sec_6) <- "surface water"
var_label(ms_consent$water_source_sec_7) <- "Uncovered dug well"
var_label(ms_consent$water_source_sec_8) <- "Private Surface well"
var_label(ms_consent$water_source_sec_9) <- "Borewell"
var_label(ms_consent$water_source_sec_10) <- "Non-JJM household tap connections"
var_label(ms_consent$water_source_sec__77) <- "Other secondary source"


variables <- c("water_source_sec_1", 
               "water_source_sec_2", 
               "water_source_sec_3", 
               "water_source_sec_4", 
               "water_source_sec_5", 
               "water_source_sec_6", 
               "water_source_sec_7", 
               "water_source_sec_8", 
               "water_source_sec_9", 
               "water_source_sec_10", 
               "water_source_sec__77")


sums <- ms_consent %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))

sums_long <- sums %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Sum")

print(sums_long)

#View(sums_long)

# Calculate the total sum of all the variables
total_sum <- sum(sums_long$Sum)



# Add a percentage column
sums_long <- sums_long %>%
  mutate(Percentage = round((Sum / total_sum) * 100, 1))

# Print the results
print(sums_long)


sums_long$Variable <- sapply(sums_long$Variable, function(x) var_label(ms_consent[[x]]))


# Generate the LaTeX table
stargazer(sums_long, 
          summary = FALSE, 
          title = "Secondary water source breakdown", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/Sec_source_break_idexx.tex"))




#------------------------------------------------------------------------
#--------------------------------------------------------------
#--------------------------------------------------------------


# Assuming `ms_consent` is your data frame

# Step 1: Calculate the percentage of "Yes" and "No" for `water_sec_yn`
water_sec_yn_summary <- ms_consent %>%
  group_by(water_sec_yn) %>%
  summarise(Sum = n()) %>%
  mutate(Percentage = round((Sum / sum(Sum)) * 100, 2))
print(water_sec_yn_summary)

# Step 2: For those who said "Yes" (assuming "Yes" is coded as 1), calculate the percentage of each secondary water source
ms_consent_yes <- ms_consent %>%
  filter(water_sec_yn == 1)

variables <- c("water_source_sec_1", 
               "water_source_sec_2", 
               "water_source_sec_3", 
               "water_source_sec_4", 
               "water_source_sec_5", 
               "water_source_sec_6", 
               "water_source_sec_7", 
               "water_source_sec_8", 
               "water_source_sec_9", 
               "water_source_sec_10", 
               "water_source_sec__77")

sums_yes <- ms_consent_yes %>%
  summarise(across(all_of(variables), sum, na.rm = TRUE))

sums_long_yes <- sums_yes %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Sum")

# Calculate the total sum of all the variables for "Yes"
total_sum_yes <- sum(sums_long_yes$Sum)

#"% free chlorine samples > 0.6" = round((sum(chlorine_fc > 0.6, na.rm = TRUE) / n()) * 100, 1),

# Add a percentage column for "Yes"
sums_long_yes <- sums_long_yes %>%
  mutate(Percentage = round((Sum / total_sum_yes) * 100, 1))
print(sums_long_yes)

# Step 3: Combine the `water_sec_yn_summary` with `sums_long_yes`
# Create a combined table
combined_table <- bind_rows(
  water_sec_yn_summary %>% mutate(Variable = if_else(water_sec_yn == 1, "Yes to secondary source", "No to secondary source"), .keep = "unused"),
  sums_long_yes %>% mutate(Variable = sapply(Variable, function(x) var_label(ms_consent[[x]])))
)

#View(combined_table)
# Select and reorder columns
combined_table <- combined_table %>% select(Variable, Sum, Percentage)

# Rename columns for clarity
colnames(combined_table) <- c("Variable", "Sum", "Percentage")


# Generate the LaTeX table
stargazer(combined_table, 
          summary = FALSE, 
          title = "Breakdown of Secondary Water Source Usage", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/Sec_source_combined_breakdown.tex"))

# Print the combined table
print(combined_table)



star.out <- stargazer(combined_table, summary=F, title= "Breakdown of Secondary Water Source Usage",float=F,rownames = F,
                      covariate.labels=NULL)

#Jeremy to Archi: This line broke my code so I'm just commenting out for now until it can be fixed
#star.out <- sub("Yes to secondary source","\hline", star.out) 

# Example: Insert \hline after the header row
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Sec_source_combined_breakdown.tex"))




#JJM drinking
jjm_drinking_sum <- ms_consent %>%
  group_by(jjm_drinking) %>%
  summarise(Sum = n()) %>%
  mutate(Percentage = round((Sum / sum(Sum)) * 100, 2))
print(jjm_drinking_sum)

write_csv(ms_consent, paste0(user_path(), "/3_final/2_11_monthly_follow_up_cleaned_consented.csv"))

#-----------------------------------IDEXX Data Check-----------------------------------



#Checking for duplicate IDs
idexx%>%
  count(sample_ID)%>% 
  filter(n > 1)
idexx%>%
  count(unique_bag_id)%>% 
  filter(n > 1)
#Sample ID 20351 is duplicated. Sample ID was recorded incorrectly in the survey. 
#Bag ID 90722 corresponds to ID 20354
#Change made in cleaning code

#Checking IDs which do not match between survey data and lab data
#Gathering IDEXX sample IDs
idexx_ids <- idexx$sample_ID
#Gathering monthly survey sample IDs
ms_sample_ids <- cbind(ms$tap_sample_id, ms$stored_sample_id)%>%
  data.frame()%>%
  pivot_longer(cols = c("X1", "X2"), values_to = "sample_ID", values_drop_na = TRUE, names_to = "sample_type")
#Filtering out
idexx_id_check <- idexx%>%
  filter(!(sample_ID %in% ms_sample_ids$sample_ID))

print(idexx_id_check)


#Summarizing desc stats
idexx_desc_stats <- tc_stats(idexx)
idexx_desc_stats <- t(idexx_desc_stats) #Transposing data
idexx_desc_stats <- idexx_desc_stats[,c(1,3,2,4)]%>%
  data.frame() #Switching Columns
colnames(idexx_desc_stats) <-  c("Control - Stored Water", "Treatment - Stored Water",
                                 "Control - Tap Water", "Treatment - Tap Water") #Setting Column Names
idexx_desc_stats <- idexx_desc_stats[3:9,] #Indexing for rows of interest
rownames(idexx_desc_stats) <- c("Number of Samples",
                                "% Positive for Total Coliform",
                                "% Positive for E. coli",
                                "Average Log10 MPN Total Coliform/100 mL",
                                "Average Log10 MPN E. coli/100 mL",
                                "% 'High Risk' Samples (> 100 MPN E. coli/100 mL)",
                                #"Median MPN E. coli/100 mL",
                                #expression(paste0("% Positive for ", italic("E. coli"))),
                                #expression(paste0("Median MPN ", italic("E. coli"),"/100 mL")),
                                "Tap Average Free Chlorine Concentration (mg/L)")

#Creating table output
idexx_desc_stats <- stargazer(idexx_desc_stats, summary=FALSE,
                              title= "Monthly Survey - IDEXX Results",
                              float=FALSE,
                              rownames = TRUE,
                              covariate.labels=NULL,
                              font.size = "tiny",
                              column.sep.width = "1pt",
                              out=paste0(overleaf(),"Table/Desc_stats_idexx.tex"))





filtered <- ms_consent %>% select(stored_water_fc, tap_water_fc, assignment )
View(filtered)
filtered <- ms_consent %>% select(stored_water_fc, tap_water_fc, assignment)

# Convert to long format, ensuring assignment is retained
long_dataset <- filtered %>%
  pivot_longer(
    cols = c(stored_water_fc, tap_water_fc),
    names_to = "sample_type",
    values_to = "chlorine_fc"
  ) %>%
  mutate(
    sample_type = case_when(
      sample_type == "stored_water_fc" ~ "stored",
      sample_type == "tap_water_fc" ~ "tap"
    )
  ) %>%
  select(assignment, sample_type, chlorine_fc)





# Calculate the percentage of chlorine samples above 0.1 and average chlorine concentration by assignment variable
chlorine_stats <- long_dataset %>%
  group_by(assignment, sample_type) %>%
  summarise(
    "% free chlorine samples > 0.1" = round((sum(chlorine_fc > 0.1, na.rm = TRUE) / n()) * 100, 1),
    "% free chlorine samples > 0.6" = round((sum(chlorine_fc > 0.6, na.rm = TRUE) / n()) * 100, 1),
    "Average free chlorine" = round(mean(chlorine_fc, na.rm = TRUE), 3),
  )

# Print the result
View(chlorine_stats)

# Transform the data to long format for pivoting
chlorine_stats_long <- chlorine_stats %>%
  pivot_longer(
    cols = c(`% free chlorine samples > 0.1`, `% free chlorine samples > 0.6`, `Average free chlorine`),
    names_to = "Statistic",
    values_to = "Value"
  )

View(chlorine_stats_long)


# Pivot the data to wide format with statistics as rows and conditions as columns
chlorine_stats_wide <- chlorine_stats_long %>%
  unite("Condition", assignment, sample_type, sep = " - ") %>%
  pivot_wider(
    names_from = Condition,
    values_from = Value
  )

View(chlorine_stats_wide)
# Adjust column names to match desired format
colnames(chlorine_stats_wide) <- c(
  "Variables",
  "Control - Stored Water", "Control - Tap Water",
  "Treatment - Stored Water", "Treatment - Tap Water"
)

# Print the result
print(chlorine_stats_wide)
View(chlorine_stats_wide)

chlorine_stats_wide <- stargazer(chlorine_stats_wide, summary=FALSE,
                                 title= "Monthly Survey - Chlorine Results",
                                 float=FALSE,
                                 rownames = TRUE,
                                 covariate.labels=NULL,
                                 font.size = "tiny",
                                 column.sep.width = "1pt",
                                 out=paste0(overleaf(),"Table/chlorine_stats_wide .tex"))


