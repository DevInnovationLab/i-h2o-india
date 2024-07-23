#------------------------------------------------ 
# title: "Code for Checks for High-frequency Follow Ups"
# author: "Jeremy Lowe, Archi Gupta"
# modified date: "2024-07-19"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------


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
install.packages("geosphere")

#please note that starpolishr pacakge isn't available on CRAN so it has to be installed from github using rmeotes pacakage 
install.packages("remotes")
remotes::install_github("ChandlerLutz/starpolishr")
install.packages("ggrepel")
install.packages("reshape2")
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
    overleaf = "C:/Users/jerem/DropBox/Apps/Overleaf"
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
ms <- read_csv(paste0(user_path(), "1_raw/Chlorine and IDEXX Monitoring Survey_WIDE.csv"))
View(ms)

#Key village details
village_details <- read_sheet("https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1710429467")

View(village_details)

#IDEXX results
idexx <- read_csv(paste0(user_path(), "1_raw/IDEXX Results Reporting - July 2024_WIDE.csv"))

View(idexx)
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

#Archi to Jeremy- I am commenting this out
#ms <- ms%>%
  #rename(sample_ID_stored = "stored_sample_id",
         #sample_ID_tap = "tap_sample_id")

names(ms)

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

Consented <- ms %>%  filter(consent == 1) %>% 
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

View(df.progress)

#output to tex 
stargazer(df.progress, summary=F, title= "Overall Progress: Monthly IDEXX Survey",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_Progress_idexx.tex"))



star.out <- stargazer(df.progress, 
                      summary = FALSE, 
                      title = "Overall Progress: Monthly IDEXX Survey", 
                      float = FALSE,
                      rownames = FALSE,
                      covariate.labels = NULL,
                      type = "latex")


star.out <- sub("cccccccc", " |L|L|L|L|L|L|L|L|L|", star.out)

star.out <- sub("cccccccc", "lccccccc", star.out)


starpolishr::star_tex_write(star.out, file = paste0(overleaf(), "Table/Table_Progress_idexx.tex"))


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
          covariate.labels=NULL, out=paste0(overleaf(),"Table/replacements_idexx.tex"))



star.out <- stargazer(df.rep, 
                      summary = FALSE, 
                      title = "Distribution of Replacements by Village", 
                      float = FALSE,
                      rownames = FALSE,
                      covariate.labels = NULL,
                      type = "latex")





#------------------------------------------------------------------------
# Drop rows where resp_available != 1
#------------------------------------------------------------------------

ms_consent <- subset(ms, consent == 1)
View(ms_consent)

#------------------------------------------------------------------------
#checking for duplicate UIDs
#------------------------------------------------------------------------

# Check for duplicates in the unique_id column
duplicates <- ms_consent[duplicated(ms_consent$unique_id) | duplicated(ms_consent$unique_id, fromLast = TRUE), ]

# Display the duplicate rows
print(duplicates)

# Alternatively, to get only the unique_id values that are duplicated
duplicate_ids <- ms_consent$unique_id[duplicated(ms_consent$unique_id)]
print(duplicate_ids)

#------------------------------------------------------------------------
#MANUAL CLEANING OF SAMPLE IDs
#------------------------------------------------------------------------
# Replace the value
View(ms)
names(ms)

#enumerator made a data entry error and by mistake put 20351 for this UID 

ms_consent$stored_sample_id[ms_consent$unique_id == "40202110019" & ms_consent$stored_sample_id == 20351] <- 20354
ms_consent$stored_sample_id_again[ms_consent$unique_id == "40202110019" & ms_consent$stored_sample_id_again == 20351] <- 20354

ms_view <- ms_consent %>% select(unique_id, stored_sample_id, stored_sample_id_again)

View(ms_view)
correct_replacement <- all(ms_consent$stored_sample_id[ms_consent$unique_id == "40202110019"] == 20354)
if (correct_replacement) {
  cat("The replacement is correct.\n")
} else {
  cat("The replacement is incorrect. Some values do not match 20354.\n")
}

names(ms)

#------------------------------------------------------------------------
#CHECKING DUPLICATES IN SAMPLE ID AND TAP ID 
#------------------------------------------------------------------------

#stored sample ID 
duplicates <- ms_consent[duplicated(ms_consent$stored_sample_id) | duplicated(ms_consent$stored_sample_id, fromLast = TRUE), ]

print(duplicates)

#stored bag ID 
duplicates <- ms_consent[duplicated(ms_consent$stored_bag_id) | duplicated(ms_consent$stored_bag_id, fromLast = TRUE), ]

print(duplicates)

#tap sample ID
duplicates <- ms_consent[duplicated(ms_consent$tap_sample_id) | duplicated(ms_consent$tap_sample_id, fromLast = TRUE), ]

print(duplicates)

#tap bag ID 
duplicates <- ms_consent[duplicated(ms_consent$tap_bag_id) | duplicated(ms_consent$tap_bag_id, fromLast = TRUE), ]

print(duplicates)


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


#---------------chlorine decay plots village wise----------------------------#


#---------------------------------------------
# OVER STORAGE TIME 
#-----------------------------------------------

#geenrating auniform time measurement variable 

# Create a conversion factor
ms_consent$stored_time_in_hours <- with(ms_consent, ifelse(stored_time_unit == 1, stored_time / 60, 
                                                           ifelse(stored_time_unit == 2, stored_time, 
                                                                  ifelse(stored_time_unit == 3, stored_time * 24, 
                                                                         ifelse(stored_time_unit == 4, stored_time * 24 * 7, NA)))))


# Now ms_consent will have a new column stored_time_in_hours with all times converted to hours
ms_view <- ms_consent %>% select(unique_id, stored_water_fc, stored_water_tc, stored_time, stored_time_unit, stored_time_in_hours  )
View(ms_view)


# Assuming your data frame is named ms_consent and it contains stored_time_in_hours, stored_water_fc, stored_water_tc, and village

# Scatter plot for stored_time_in_hours vs stored_water_fc
plot_fc <- ggplot(ms_consent, aes(x = stored_time_in_hours, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Stored Water FC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ R_Cen_village_name_str) # Facet wrap by village

print(plot_fc)

# Scatter plot for stored_time_in_hours vs stored_water_tc
plot_tc <- ggplot(ms_consent, aes(x = stored_time_in_hours, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Stored Water TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ R_Cen_village_name_str) # Facet wrap by village

print(plot_tc)



# Assuming your data frame is named ms_consent and it contains stored_time_in_hours, stored_water_fc, stored_water_tc, and village

# Melt the data to long format
ms_melted <- melt(ms_consent, id.vars = c("stored_time_in_hours", "R_Cen_village_name_str"), 
                  measure.vars = c("stored_water_fc", "stored_water_tc"),
                  variable.name = "Type", value.name = "Value")

# Create the combined scatter plot
combined_plot <- ggplot(ms_melted, aes(x = stored_time_in_hours, y = Value, color = Type)) +
  geom_point() +
  labs(title = "Stored Water FC and TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ R_Cen_village_name_str) + # Facet wrap by village
  scale_color_manual(values = c("stored_water_fc" = "blue", "stored_water_tc" = "red"), 
                     labels = c("Stored Water FC", "Stored Water TC"))

print(combined_plot)



# Assuming your data frame is named ms_consent and it contains stored_time_in_hours, stored_water_fc, stored_water_tc, and R_Cen_village_name_str

# Melt the data to long format
ms_melted <- melt(ms_consent, id.vars = c("stored_time_in_hours", "R_Cen_village_name_str"), 
                  measure.vars = c("stored_water_fc", "stored_water_tc"),
                  variable.name = "Type", value.name = "Value")

# Create the combined scatter plot with lines
combined_plot <- ggplot(ms_melted, aes(x = stored_time_in_hours, y = Value, color = Type)) +
  geom_point() +
  geom_line(aes(group = Type)) +
  labs(title = "Stored Water FC and TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ R_Cen_village_name_str) + # Facet wrap by village
  scale_color_manual(values = c("stored_water_fc" = "blue", "stored_water_tc" = "red"), 
                     labels = c("Stored Water FC", "Stored Water TC"))

print(combined_plot)

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_test_types.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)



#checking chlorine concentration over number of supply times in village 

#---------------------------------------------
# OVER SUPPLY FREQUENCY
#-----------------------------------------------


df.PO <- read_stata(paste0(DI_path(),"pump_operator_survey.dta" ))
View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns
names(ms_consent)[names(ms_consent) == "R_Cen_village_name_str"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(ms_consent$village)

# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, ms_consent, by = "village")
View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit

merged_data_view <- merged_data %>% select(village, stored_water_fc)
View(merged_data_view)

#------------------------------------------------------------------------
# STORED WATER 
#------------------------------------------------------------------------

# Extract unique values for each village
unique_data <- merged_data %>%
  group_by(village) %>%
  distinct(stored_water_fc, po_water_supply_freq, .keep_all = TRUE)

# Create the scatter plot with facet wrap by village
scatter_plot_fc <- ggplot(merged_data, aes(x = po_water_supply_freq, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Scatter Plot of Stored Water FC vs PO Water Supply Frequency by Village",
       x = "PO Water Supply Frequency",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) # Facet wrap by village

# Print the plot
print(scatter_plot_fc)



# Extract unique values for each village
unique_data <- merged_data %>%
  group_by(village) %>%
  distinct(stored_water_tc, po_water_supply_freq, .keep_all = TRUE)

# Create the scatter plot with facet wrap by village
scatter_plot_tc <- ggplot(merged_data, aes(x = po_water_supply_freq, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Scatter Plot of Stored Water TC vs PO Water Supply Frequency by Village",
       x = "PO Water Supply Frequency",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) # Facet wrap by village

# Print the plot
print(scatter_plot_tc)


ms_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                  measure.vars = c("stored_water_fc", "stored_water_tc"),
                  variable.name = "Type", value.name = "Value")

# Create the combined scatter plot with lines
combined_plot <- ggplot(ms_melted, aes(x = po_water_supply_freq, y = Value, color = Type)) +
  geom_point() +
  geom_line(aes(group = Type)) +
  labs(title = "Stored Water FC and TC vs Supply time frequency by Village",
       x = "JJM water supply frequency",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) + # Facet wrap by village
  scale_color_manual(values = c("stored_water_fc" = "blue", "stored_water_tc" = "red"), 
                     labels = c("Stored Water FC", "Stored Water TC"))

print(combined_plot)

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)


#------------------------------------------------------------------------
# TAPWATER 
#------------------------------------------------------------------------

#tap_water_fc
#tap_water_tc

# Extract unique values for each village
unique_data <- merged_data %>%
  group_by(village) %>%
  distinct(stored_water_fc, po_water_supply_freq, .keep_all = TRUE)

# Create the scatter plot with facet wrap by village
scatter_plot_fc <- ggplot(merged_data, aes(x = po_water_supply_freq, y = tap_water_fc)) +
  geom_point() +
  labs(title = "Scatter Plot of Tap Water FC vs PO Water Supply Frequency by Village",
       x = "PO Water Supply Frequency",
       y = "Tap Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) # Facet wrap by village

# Print the plot
print(scatter_plot_fc)



# Extract unique values for each village
unique_data <- merged_data %>%
  group_by(village) %>%
  distinct(stored_water_tc, po_water_supply_freq, .keep_all = TRUE)

# Create the scatter plot with facet wrap by village
scatter_plot_tc <- ggplot(merged_data, aes(x = po_water_supply_freq, y = tap_water_tc)) +
  geom_point() +
  labs(title = "Scatter Plot of Stored Water TC vs PO Water Supply Frequency by Village",
       x = "PO Water Supply Frequency",
       y = "Tap Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) # Facet wrap by village

# Print the plot
print(scatter_plot_tc)


ms_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                  measure.vars = c("tap_water_fc", "tap_water_tc"),
                  variable.name = "Type", value.name = "Value")

# Create the combined scatter plot with lines
combined_plot <- ggplot(ms_melted, aes(x = po_water_supply_freq, y = Value, color = Type)) +
  geom_point() +
  geom_line(aes(group = Type)) +
  labs(title = "Tap Water FC and TC vs Supply time frequency by Village",
       x = "JJM water supply frequency",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) + # Facet wrap by village
  scale_color_manual(values = c("tap_water_fc" = "blue", "tap_water_tc" = "red"), 
                     labels = c("Tap Water FC", "Tap Water TC"))

print(combined_plot)

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_Tap.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)

#_______________________________________________________________________
#combining the graphs of stored and tap
#---------------------------------------------------------------------

# Melting the data for stored water
stored_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                      measure.vars = c("stored_water_fc", "stored_water_tc"),
                      variable.name = "Type", value.name = "Value")

# Melting the data for tap water
tap_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                   measure.vars = c("tap_water_fc", "tap_water_tc"),
                   variable.name = "Type", value.name = "Value")

# Combining both melted data frames
combined_melted <- rbind(
  transform(stored_melted, WaterType = "Stored"),
  transform(tap_melted, WaterType = "Tap")
)

# Create the combined scatter plot with lines
combined_plot <- ggplot(combined_melted, aes(x = po_water_supply_freq, y = Value, color = Type)) +
  geom_point() +
  geom_line(aes(group = interaction(Type, WaterType))) +
  labs(title = "Stored and Tap Water FC and TC vs Supply Time Frequency by Village",
       x = "JJM Water Supply Frequency",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ village) + # Facet wrap by village
  scale_color_manual(values = c("stored_water_fc" = "blue", "stored_water_tc" = "red", 
                                "tap_water_fc" = "green", "tap_water_tc" = "purple"), 
                     labels = c("Stored Water FC", "Stored Water TC", "Tap Water FC", "Tap Water TC"))

print(combined_plot)

# Save the plot
ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_combined.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)



#-------------------------------------------------------------------------------
# Doing a combined for stored and tap water 
#------------------------------------------------------------------------------

# Assuming merged_data is your dataset containing both stored and tap water data
# Melting the data for stored water
stored_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                      measure.vars = c("stored_water_fc", "stored_water_tc"),
                      variable.name = "Type", value.name = "Value")

# Melting the data for tap water
tap_melted <- melt(merged_data, id.vars = c("po_water_supply_freq", "village"), 
                   measure.vars = c("tap_water_fc", "tap_water_tc"),
                   variable.name = "Type", value.name = "Value")

# Adding a new column to indicate the type of water
stored_melted$WaterType <- "Stored"
tap_melted$WaterType <- "Tap"

# Combining both melted data frames
combined_melted <- rbind(stored_melted, tap_melted)

# Create the combined scatter plot with lines
combined_plot <- ggplot(combined_melted, aes(x = po_water_supply_freq, y = Value, color = Type)) +
  geom_point() +
  geom_line(aes(group = interaction(Type, village))) +
  labs(title = "Stored and Tap Water FC and TC vs Supply Time Frequency by Village",
       x = "JJM Water Supply Frequency",
       y = "Value") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_grid(village ~ WaterType) + # Facet grid by village and water type
  scale_color_manual(values = c("stored_water_fc" = "blue", "stored_water_tc" = "red", 
                                "tap_water_fc" = "green", "tap_water_tc" = "purple"), 
                     labels = c("Stored Water FC", "Stored Water TC", "Tap Water FC", "Tap Water TC"))

print(combined_plot)

# Save the plot
ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_bothTS.png"), combined_plot, bg = "white", width = 10, height = 10, dpi = 200)


#---------------------IDEXX Data Cleaning------------------------------------


#PREPARING IDEXX DATA##########################################################
#Pivoting dataset to be longer for pairing IDEXX data to sample IDs
ms_idexx <- ms%>%
  pivot_longer(cols = c(sample_ID_stored, sample_ID_tap), values_to = "sample_ID", names_to = "sample_type")

View(ms_idexx)


#---------------------IDEXX reporting form-----------------------------
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





