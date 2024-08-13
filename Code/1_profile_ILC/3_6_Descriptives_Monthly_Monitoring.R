

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
#install.packages("ggplot2")
#install.packages("RColorBrewer")
#install.packages("patchwork")

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
# Install and load required packages
library(ggplot2)
library(RColorBrewer)
library(patchwork)


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



Lab_path <- function() {
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
    path = "C:/Users/Archi Gupta/Box/Data/5_lab data/idexx/cleaned/"
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
knitr::opts_knit$set(root.dir = Lab_path())




#---------------chlorine decay plots village wise----------------------------#


#---------------------------------------------
# OVER STORAGE TIME 
#-----------------------------------------------

#geenrating auniform time measurement variable 

# Create a conversion factor

ms_consent <- read_csv(paste0(user_path(),"/3_final/2_11_monthly_follow_up_cleaned_consented.csv"))

village_details_x <- read_csv(paste0(user_path(), "/3_final/village_details.csv"))
View(village_details_x)

ms_consent_v <- ms_consent %>% select(SubmissionDate, Date)
View(ms_consent_v)

ms_consent$stored_time_in_hours <- with(ms_consent, ifelse(stored_time_unit == 1, stored_time / 60, 
                                                           ifelse(stored_time_unit == 2, stored_time, 
                                                                  ifelse(stored_time_unit == 3, stored_time * 24, 
                                                                         ifelse(stored_time_unit == 4, stored_time * 24 * 7, NA)))))


# Now ms_consent will have a new column stored_time_in_hours with all times converted to hours
ms_view <- ms_consent %>% select(unique_id, stored_water_fc, stored_water_tc, stored_time, stored_time_unit, stored_time_in_hours  )
#View(ms_view)


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
#View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
#View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns
names(ms_consent)[names(ms_consent) == "R_Cen_village_name_str"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(ms_consent$village)

# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, ms_consent, by = "village")
#View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit

merged_data_view <- merged_data %>% select(village, stored_water_fc)
#View(merged_data_view)

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


#---------------------------------------------------------
#Density plots- T vs C
#--------------------------------------------------------


#Format SubmissionDate to MDY format for displaying - The date right now is in character format
ms_consent$Date_f <- format(ms_consent$SubmissionDate, "%m/%d/%Y")

# Convert SubmissionDate to POSIXct type- The date now is in thje fomr that can be used in ggpplot
ms_consent$Date_f <- as.POSIXct(ms_consent$Date_f, format = "%m/%d/%Y")


ms_consent_v <- ms_consent %>% select(stored_water_fc, village, tap_water_fc, Date, Date_f, SubmissionDate)
View(ms_consent_v)


names(village_details_x)
#village_name #assignment

village_details_x <- village_details_x %>% 
  rename(
    village = village_name,
  )

village_details_f <- village_details_x %>% select(village, assignment )
  
merged_data <- ms_consent %>%
  left_join(village_details_f, by = "village")

View(merged_data)




############################


# Assuming ms_consent is your dataframe
# Define the x-axis limits
x_limits <- c(min(c(ms_consent$tap_water_fc, ms_consent$stored_water_fc), na.rm = TRUE),
              max(c(ms_consent$tap_water_fc, ms_consent$stored_water_fc), na.rm = TRUE))

# Create the density plot for tap water
density_plot <- ggplot(ms_consent, aes(x = tap_water_fc, fill = assignment)) +
  geom_density(alpha = 0.7) +
  labs(title = "Density Plot of Tap Water FC",
       x = "Tap Water FC",
       y = "Density",
       fill = "Assignment") +
  xlim(x_limits) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, hjust = 0.5),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  scale_fill_brewer(palette = "Set3")

# Print the plot
print(density_plot)


# Create the density plot for stored water
density_plot_s <- ggplot(ms_consent, aes(x = stored_water_fc, fill = assignment)) +
  geom_density(alpha = 0.7) +
  labs(title = "Density Plot of Stored Water FC",
       x = "Stored Water FC",
       y = "Density",
       fill = "Assignment") +
  xlim(x_limits) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, hjust = 0.5),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  scale_fill_brewer(palette = "Set3")

# Print the plot
print(density_plot_s)


# Combine the plots using patchwork
combined_plot <- density_plot + density_plot_s + 
  plot_annotation(title = "Density Plots of Tap Water FC and Stored Water FC by Assignment") &
  theme(plot.title = element_text(size = 14, hjust = 0.5))

# Print the combined plot
print(combined_plot)

# Save the combined plot
ggplot2::ggsave(paste0(overleaf(), "Figure/combined_density_plot.png"), combined_plot, bg = "white", width = 10, height = 10, dpi = 200)

#----------------------------------------------------------------------------------------------

# PULLING IN FOLLOW UP ROUNDS DATA TO CHECK FOR CHLORINE DECAY 

#---------------------------------------------------------------------------------------------

#___________________________________________________________

#Cleaned baseline HH round 
#___________________________________________________________


#___________________________________________________________

##### FIRSTLY OVER STORED TIME IN HOURS  ##################

#___________________________________________________________


BH_Clean <- read_dta(paste0(user_path(),"2_deidentified/1_2_Followup_cleaned.dta" ))
BH_Clean <- BH_Clean %>% filter(R_FU_consent == 1)

#wq_chlorine_storedfc wq_chlorine_storedfc_again wq_chlorine_storedtc wq_chlorine_storedtc_again
#wq_tap_fc wq_tap_fc_again wq_tap_tc wq_tap_tc_again
#stored_bag_source #bag_stored_time #bag_stored_time_unit
#CAVEAT: Here I had to drop those observations where stored time was not present and its respective chlorine values had to be droppe dout 


View(BH_Clean)
names(BH_Clean)
BH_Clean_view <- BH_Clean %>% select(R_FU_r_cen_village_name_str, R_FU_stored_bag_source, R_FU_stored_bag_source_oth, R_FU_bag_stored_time, R_FU_bag_stored_time_unit,  R_FU_fc_stored,  R_FU_wq_chlorine_storedfc_again, R_FU_tc_stored, R_FU_wq_chlorine_storedtc_again )
View(BH_Clean_view )

#Since there are a lot of NA values we need to use coalesce function to make sure original Non NA values are retained
BH_Clean_view <- BH_Clean_view %>%
  rowwise() %>%
  mutate(
    stored_water_fc = ifelse(is.na(R_FU_fc_stored) | is.na(R_FU_wq_chlorine_storedfc_again), 
                             coalesce(R_FU_fc_stored, R_FU_wq_chlorine_storedfc_again), 
                             (R_FU_fc_stored + R_FU_wq_chlorine_storedfc_again) / 2),
    stored_water_tc = ifelse(is.na(R_FU_tc_stored) | is.na(R_FU_wq_chlorine_storedtc_again), 
                             coalesce(R_FU_tc_stored, R_FU_wq_chlorine_storedtc_again), 
                             (R_FU_tc_stored + R_FU_wq_chlorine_storedtc_again) / 2)
  ) %>%
  ungroup()

BH_Clean_view_f <- BH_Clean_view %>%
  filter(R_FU_stored_bag_source == 1 | is.na(R_FU_stored_bag_source))
View(BH_Clean_view_f)



#geenrating auniform time measurement variable 

# removing prefix R_FU_
BH_Clean_view_f <- BH_Clean_view_f %>%
  rename_all(~ sub("^R_FU_", "", .))

# Create a conversion factor
BH_Clean_view_f$stored_time_in_hours <- with(BH_Clean_view_f, ifelse(bag_stored_time_unit == 1, bag_stored_time / 60, 
                                                                     ifelse(bag_stored_time_unit == 2, bag_stored_time, 
                                                                            ifelse(bag_stored_time_unit == 3, bag_stored_time * 24, 
                                                                                   ifelse(bag_stored_time_unit == 4, bag_stored_time * 24 * 7, NA)))))



# Assuming BH_Clean_view is your dataframe
BH_Clean_view_f <- BH_Clean_view_f %>%
  mutate(stored_time_in_hours = round(stored_time_in_hours, 1))

View(BH_Clean_view_f)

# Assuming df is your dataframe
BH_Clean_view_f <- BH_Clean_view_f %>%
  rename(
    Village = r_cen_village_name_str
  )


# Assuming BH_Clean_view_f is your dataframe
BH_Clean_view_f_x <- BH_Clean_view_f %>%
  filter(!is.na(stored_water_fc))

BH_Clean_view_f_x <- BH_Clean_view_f_x %>%
  filter(!is.na(stored_time_in_hours))


View(BH_Clean_view_f_x)

# Scatter plot for stored_time_in_hours vs stored_water_fc
plot_fc <- ggplot(BH_Clean_view_f_x, aes(x = stored_time_in_hours, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Stored Water FC vs Stored Time for Baseline Housheold round",
       x = "Stored Time (hours)",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_fc)

BH_Clean_view_f_y <- BH_Clean_view_f %>%
  filter(!is.na(stored_water_tc))

BH_Clean_view_f_y <- BH_Clean_view_f_y %>%
  filter(!is.na(stored_time_in_hours))


View(BH_Clean_view_f_y)


# Scatter plot for stored_time_in_hours vs stored_water_tc
plot_tc <- ggplot(BH_Clean_view_f_y, aes(x = stored_time_in_hours, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Stored Water TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_tc)


ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_stored_time_BH.png"), plot_fc, bg = "white", width = 7, height = 7, dpi = 200)



#---------------------------------------------
# OVER SUPPLY FREQUENCY
#-----------------------------------------------


df.PO <- read_stata(paste0(DI_path(),"pump_operator_survey.dta" ))
#View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
#View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns

names(BH_Clean_view_f)[names(BH_Clean_view_f) == "Village"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(BH_Clean_view_f$village)


# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, BH_Clean_view_f, by = "village")
#View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit


merged_data_view <- merged_data %>% select(village, stored_water_fc)
#View(merged_data_view)

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
  labs(title = "Stored Water FC and TC vs Supply time frequency for Baseline HH",
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

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_BH.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)




#___________________________________________________________

#FOLLOW UP R1
#___________________________________________________________
#stored_bag_source #bag_stored_time #bag_stored_time_unit
F1_Clean <- read_dta(paste0(user_path(),"2_deidentified/1_5_Followup_R1_cleaned.dta" ))
names(F1_Clean)
View(F1_Clean)
F1_Clean <- F1_Clean %>% filter(R_FU1_consent == 1)
F1_Clean_view <- F1_Clean %>% select(R_FU1_r_cen_village_name_str, R_FU1_fc_stored,  R_FU1_wq_chlorine_storedfc_again, R_FU1_tc_stored, R_FU1_wq_chlorine_storedtc_again, R_FU1_stored_bag_source, R_FU1_stored_bag_source_oth, R_FU1_bag_stored_time, R_FU1_bag_stored_time_unit )
View(F1_Clean_view )

#Since there are a lot of NA values we need to use coalesce function to make sure original Non NA values are retained
F1_Clean_view <- F1_Clean_view %>%
  rowwise() %>%
  mutate(
    stored_water_fc = ifelse(is.na(R_FU1_fc_stored) | is.na(R_FU1_wq_chlorine_storedfc_again), 
                             coalesce(R_FU1_fc_stored, R_FU1_wq_chlorine_storedfc_again), 
                             (R_FU1_fc_stored + R_FU1_wq_chlorine_storedfc_again) / 2),
    stored_water_tc = ifelse(is.na(R_FU1_tc_stored) | is.na(R_FU1_wq_chlorine_storedtc_again), 
                             coalesce(R_FU1_tc_stored, R_FU1_wq_chlorine_storedtc_again), 
                             (R_FU1_tc_stored + R_FU1_wq_chlorine_storedtc_again) / 2)
  ) %>%
  ungroup()

F1_Clean_view_f <- F1_Clean_view %>%
  filter(R_FU1_stored_bag_source == 1 | is.na(R_FU1_stored_bag_source))
View(F1_Clean_view_f)



#geenrating auniform time measurement variable 

# removing prefix R_FU_
F1_Clean_view_f <- F1_Clean_view_f %>%
  rename_all(~ sub("^R_FU1_", "", .))

# Create a conversion factor
F1_Clean_view_f$stored_time_in_hours <- with(F1_Clean_view_f, ifelse(bag_stored_time_unit == 1, bag_stored_time / 60, 
                                                                     ifelse(bag_stored_time_unit == 2, bag_stored_time, 
                                                                            ifelse(bag_stored_time_unit == 3, bag_stored_time * 24, 
                                                                                   ifelse(bag_stored_time_unit == 4, bag_stored_time * 24 * 7, NA)))))



# Assuming BH_Clean_view is your dataframe
F1_Clean_view_f <- F1_Clean_view_f %>%
  mutate(stored_time_in_hours = round(stored_time_in_hours, 1))

View(F1_Clean_view_f)

# Assuming df is your dataframe
F1_Clean_view_f <- F1_Clean_view_f %>%
  rename(
    Village = r_cen_village_name_str
  )


View(F1_Clean_view_f)
# Assuming BH_Clean_view_f is your dataframe

#here we are filtering because only 4 out of 10 HH was aksed question for time of stored water
F1_Clean_view_f_x <- F1_Clean_view_f %>%
  filter(!is.na(stored_water_fc))

F1_Clean_view_f_x <- F1_Clean_view_f_x %>%
  filter(!is.na(stored_time_in_hours))



# Scatter plot for stored_time_in_hours vs stored_water_fc
plot_fc <- ggplot(F1_Clean_view_f_x, aes(x = stored_time_in_hours, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Stored Water FC vs Stored Time for Follow up R1 round",
       x = "Stored Time (hours)",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_fc)

F1_Clean_view_f_y <- F1_Clean_view_f %>%
  filter(!is.na(stored_water_tc))

F1_Clean_view_f_y <- F1_Clean_view_f_y %>%
  filter(!is.na(stored_time_in_hours))


View(F1_Clean_view_f_y)


# Scatter plot for stored_time_in_hours vs stored_water_tc
plot_tc <- ggplot(F1_Clean_view_f_y, aes(x = stored_time_in_hours, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Stored Water TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_tc)


ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_stored_time_F1.png"), plot_fc, bg = "white", width = 7, height = 7, dpi = 200)



#---------------------------------------------
# OVER SUPPLY FREQUENCY
#-----------------------------------------------


df.PO <- read_stata(paste0(DI_path(),"pump_operator_survey.dta" ))
#View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
#View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns

names(F1_Clean_view_f)[names(F1_Clean_view_f) == "Village"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(F1_Clean_view_f$village)


# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, F1_Clean_view_f, by = "village")
View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit


merged_data_view <- merged_data %>% select(village, stored_water_fc)
#View(merged_data_view)

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
  labs(title = "Stored Water FC and TC vs Supply time frequency for Follow up R1",
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

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_F1.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)



#wq_chlorine_storedfc #wq_chlorine_storedfc_again #wq_chlorine_storedtc #wq_chlorine_storedtc_again #wq_tap_fc #wq_tap_fc_again #wq_tap_tc #wq_tap_tc_again

#___________________________________________________________

#FOLLOW UP R2
#___________________________________________________________

#stored_bag_source #bag_stored_time #bag_stored_time_unit
F2_Clean <- read_dta(paste0(user_path(),"2_deidentified/1_6_Followup_R2_cleaned.dta" ))
names(F2_Clean)
F2_Clean <- F2_Clean %>% filter(R_FU2_consent == 1)
F2_Clean_view <- F2_Clean %>% select(R_FU2_r_cen_village_name_str, R_FU2_fc_stored,  R_FU2_wq_chlorine_storedfc_again, R_FU2_tc_stored, R_FU2_wq_chlorine_storedtc_again, R_FU2_stored_bag_source, R_FU2_stored_bag_source_oth, R_FU2_bag_stored_time, R_FU2_bag_stored_time_unit  )
View(F2_Clean_view )



#Since there are a lot of NA values we need to use coalesce function to make sure original Non NA values are retained
F2_Clean_view <- F2_Clean_view %>%
  rowwise() %>%
  mutate(
    stored_water_fc = ifelse(is.na(R_FU2_fc_stored) | is.na(R_FU2_wq_chlorine_storedfc_again), 
                             coalesce(R_FU2_fc_stored, R_FU2_wq_chlorine_storedfc_again), 
                             (R_FU2_fc_stored + R_FU2_wq_chlorine_storedfc_again) / 2),
    stored_water_tc = ifelse(is.na(R_FU2_tc_stored) | is.na(R_FU2_wq_chlorine_storedtc_again), 
                             coalesce(R_FU2_tc_stored, R_FU2_wq_chlorine_storedtc_again), 
                             (R_FU2_tc_stored + R_FU2_wq_chlorine_storedtc_again) / 2)
  ) %>%
  ungroup()

F2_Clean_view_f <- F2_Clean_view %>%
  filter(R_FU2_stored_bag_source == 1 | is.na(R_FU2_stored_bag_source))
View(F2_Clean_view_f)



#geenrating auniform time measurement variable 

# removing prefix R_FU_
F2_Clean_view_f <- F2_Clean_view_f %>%
  rename_all(~ sub("^R_FU2_", "", .))

# Create a conversion factor
F2_Clean_view_f$stored_time_in_hours <- with(F2_Clean_view_f, ifelse(bag_stored_time_unit == 1, bag_stored_time / 60, 
                                                                     ifelse(bag_stored_time_unit == 2, bag_stored_time, 
                                                                            ifelse(bag_stored_time_unit == 3, bag_stored_time * 24, 
                                                                                   ifelse(bag_stored_time_unit == 4, bag_stored_time * 24 * 7, NA)))))



# Assuming BH_Clean_view is your dataframe
F2_Clean_view_f <- F2_Clean_view_f %>%
  mutate(stored_time_in_hours = round(stored_time_in_hours, 1))

View(F2_Clean_view_f)

# Assuming df is your dataframe
F2_Clean_view_f <- F2_Clean_view_f %>%
  rename(
    Village = r_cen_village_name_str
  )


#View(F1_Clean_view_f)

#here we are filtering because only 4 out of 10 HH was aksed question for time of stored water
F2_Clean_view_f_x <- F2_Clean_view_f %>%
  filter(!is.na(stored_water_fc))

F2_Clean_view_f_x <- F2_Clean_view_f_x %>%
  filter(!is.na(stored_time_in_hours))



# Scatter plot for stored_time_in_hours vs stored_water_fc
plot_fc <- ggplot(F2_Clean_view_f_x, aes(x = stored_time_in_hours, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Stored Water FC vs Stored Time for Follow up R2 round",
       x = "Stored Time (hours)",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_fc)

F2_Clean_view_f_y <- F2_Clean_view_f %>%
  filter(!is.na(stored_water_tc))

F2_Clean_view_f_y <- F2_Clean_view_f_y %>%
  filter(!is.na(stored_time_in_hours))


View(F2_Clean_view_f_y)


# Scatter plot for stored_time_in_hours vs stored_water_tc
plot_tc <- ggplot(F2_Clean_view_f_y, aes(x = stored_time_in_hours, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Stored Water TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_tc)


ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_stored_time_F2.png"), plot_fc, bg = "white", width = 7, height = 7, dpi = 200)




#---------------------------------------------
# OVER SUPPLY FREQUENCY
#-----------------------------------------------


df.PO <- read_stata(paste0(DI_path(),"pump_operator_survey.dta" ))
#View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
#View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns

names(F2_Clean_view_f)[names(F2_Clean_view_f) == "Village"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(F2_Clean_view_f$village)


# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, F2_Clean_view_f, by = "village")
View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit


merged_data_view <- merged_data %>% select(village, stored_water_fc)
#View(merged_data_view)

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
  labs(title = "Stored Water FC and TC vs Supply time frequency for Follow up R2",
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

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_F2.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)




#wq_chlorine_storedfc #wq_chlorine_storedfc_again #wq_chlorine_storedtc #wq_chlorine_storedtc_again #wq_tap_fc #wq_tap_fc_again #wq_tap_tc #wq_tap_tc_again

#___________________________________________________________

#FOLLOW UP R3
#___________________________________________________________

#stored_bag_source #bag_stored_time #bag_stored_time_unit

F3_Clean <- read_dta(paste0(user_path(),"2_deidentified/1_7_Followup_R3_cleaned.dta" ))
names(F3_Clean)
F3_Clean <- F3_Clean %>% filter(R_FU3_consent == 1)
F3_Clean_view <- F3_Clean %>% select(R_FU3_r_cen_village_name_str, R_FU3_fc_stored,  R_FU3_wq_chlorine_storedfc_again, R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again, R_FU3_stored_bag_source, R_FU3_stored_bag_source_oth, R_FU3_bag_stored_time, R_FU3_bag_stored_time_unit )
View(F3_Clean_view )


#Since there are a lot of NA values we need to use coalesce function to make sure original Non NA values are retained
F3_Clean_view <- F3_Clean_view %>%
  rowwise() %>%
  mutate(
    stored_water_fc = ifelse(is.na(R_FU3_fc_stored) | is.na(R_FU3_wq_chlorine_storedfc_again), 
                             coalesce(R_FU3_fc_stored, R_FU3_wq_chlorine_storedfc_again), 
                             (R_FU3_fc_stored + R_FU3_wq_chlorine_storedfc_again) / 2),
    stored_water_tc = ifelse(is.na(R_FU3_tc_stored) | is.na(R_FU3_wq_chlorine_storedtc_again), 
                             coalesce(R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again), 
                             (R_FU3_tc_stored + R_FU3_wq_chlorine_storedtc_again) / 2)
  ) %>%
  ungroup()

F3_Clean_view_f <- F3_Clean_view %>%
  filter(R_FU3_stored_bag_source == 1 | is.na(R_FU3_stored_bag_source))
View(F3_Clean_view_f)



#geenrating auniform time measurement variable 

# removing prefix R_FU_
F3_Clean_view_f <- F3_Clean_view_f %>%
  rename_all(~ sub("^R_FU3_", "", .))

# Create a conversion factor
F3_Clean_view_f$stored_time_in_hours <- with(F3_Clean_view_f, ifelse(bag_stored_time_unit == 1, bag_stored_time / 60, 
                                                                     ifelse(bag_stored_time_unit == 2, bag_stored_time, 
                                                                            ifelse(bag_stored_time_unit == 3, bag_stored_time * 24, 
                                                                                   ifelse(bag_stored_time_unit == 4, bag_stored_time * 24 * 7, NA)))))



# Assuming BH_Clean_view is your dataframe
F3_Clean_view_f <- F3_Clean_view_f %>%
  mutate(stored_time_in_hours = round(stored_time_in_hours, 1))

View(F3_Clean_view_f)

# Assuming df is your dataframe
F3_Clean_view_f <- F3_Clean_view_f %>%
  rename(
    Village = r_cen_village_name_str
  )


#View(F1_Clean_view_f)

#here we are filtering because only 4 out of 10 HH was aksed question for time of stored water
F3_Clean_view_f_x <- F3_Clean_view_f %>%
  filter(!is.na(stored_water_fc))

F3_Clean_view_f_x <- F3_Clean_view_f_x %>%
  filter(!is.na(stored_time_in_hours))



# Scatter plot for stored_time_in_hours vs stored_water_fc
plot_fc <- ggplot(F3_Clean_view_f_x, aes(x = stored_time_in_hours, y = stored_water_fc)) +
  geom_point() +
  labs(title = "Stored Water FC vs Stored Time for Follow up R3 round",
       x = "Stored Time (hours)",
       y = "Stored Water FC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_fc)

F3_Clean_view_f_y <- F3_Clean_view_f %>%
  filter(!is.na(stored_water_tc))

F3_Clean_view_f_y <- F3_Clean_view_f_y %>%
  filter(!is.na(stored_time_in_hours))


View(F3_Clean_view_f_y)


# Scatter plot for stored_time_in_hours vs stored_water_tc
plot_tc <- ggplot(F3_Clean_view_f_y, aes(x = stored_time_in_hours, y = stored_water_tc)) +
  geom_point() +
  labs(title = "Stored Water TC vs Stored Time (in hours) by Village",
       x = "Stored Time (hours)",
       y = "Stored Water TC") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),  # Increase x-axis text size
        axis.text.y = element_text(size = 12),  # Increase y-axis text size
        axis.title.x = element_text(size = 14), # Increase x-axis title size
        axis.title.y = element_text(size = 14), # Increase y-axis title size
        plot.title = element_text(size = 16, hjust = 0.5)) + # Increase plot title size and center it
  facet_wrap(~ Village) # Facet wrap by village

print(plot_tc)


ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_stored_time_F3.png"), plot_fc, bg = "white", width = 7, height = 7, dpi = 200)


#---------------------------------------------
# OVER SUPPLY FREQUENCY
#-----------------------------------------------


df.PO <- read_stata(paste0(DI_path(),"pump_operator_survey.dta" ))
#View(df.PO)

names(df.PO)

df.PO.sub <- df.PO %>% select(po_village_name, po_water_supply_freq)
#View(df.PO.sub)

#renaming village variable name


# Example: Renaming specific columns

names(F3_Clean_view_f)[names(F3_Clean_view_f) == "Village"] <- "village"
names(df.PO.sub)[names(df.PO.sub) == "po_village_name"] <- "village"


unique(df.PO.sub$village)

unique(F3_Clean_view_f$village)


# Merge datasets with an inner join
merged_data <- merge(df.PO.sub, F3_Clean_view_f, by = "village")
View(merged_data)

#stored_water_fc
#stored_water_tc
#stored_time
#stored_time_unit


merged_data_view <- merged_data %>% select(village, stored_water_fc)
#View(merged_data_view)

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
  labs(title = "Stored Water FC and TC vs Supply time frequency for Follow up R3",
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

ggplot2::ggsave(paste0(overleaf(), "Figure/scatter_village_supply_freq_F3.png"), combined_plot, bg = "white", width = 7, height = 7, dpi = 200)





#wq_chlorine_storedfc #wq_chlorine_storedfc_again #wq_chlorine_storedtc #wq_chlorine_storedtc_again #wq_tap_fc #wq_tap_fc_again #wq_tap_tc #wq_tap_tc_again

#T-TEST 



# POOLING IN ALL IDEXX ROUND DATA 

BL_idexx <- read_csv(paste0(Lab_path(), "BL_idexx_master_cleaned.csv"))
View(BL_idexx)
names(BL_idexx)
#sample_ID #bag_ID #sample_type #bag_ID_stored #bag_ID_tap
BL_idexx_v <- BL_idexx %>% select(unique_id, sample_ID, bag_ID, sample_type, bag_ID_stored, bag_ID_tap)
View(BL_idexx_v)


#doing basic cleaning 
BH_Clean <- read_dta(paste0(user_path(),"2_deidentified/1_2_Followup_cleaned.dta" ))
BH_Clean <- BH_Clean %>% filter(R_FU_consent == 1)

#wq_chlorine_storedfc wq_chlorine_storedfc_again wq_chlorine_storedtc wq_chlorine_storedtc_again
#wq_tap_fc wq_tap_fc_again wq_tap_tc wq_tap_tc_again
#stored_bag_source #bag_stored_time #bag_stored_time_unit
#CAVEAT: Here I had to drop those observations where stored time was not present and its respective chlorine values had to be droppe dout 


names(BH_Clean)
BH_Clean_view <- BH_Clean %>% select(unique_id_num, R_FU_r_cen_village_name_str, R_FU_stored_bag_source, R_FU_stored_bag_source_oth, R_FU_bag_stored_time, R_FU_bag_stored_time_unit,  R_FU_fc_stored,  R_FU_wq_chlorine_storedfc_again, R_FU_tc_stored, R_FU_wq_chlorine_storedtc_again, R_FU_bag_ID_stored, R_FU_sample_ID_stored, R_FU_sample_ID_tap, R_FU_bag_ID_tap)
View(BH_Clean_view )

#Since there are a lot of NA values we need to use coalesce function to make sure original Non NA values are retained
BH_Clean_view <- BH_Clean_view %>%
  rowwise() %>%
  mutate(
    stored_water_fc = ifelse(is.na(R_FU_fc_stored) | is.na(R_FU_wq_chlorine_storedfc_again), 
                             coalesce(R_FU_fc_stored, R_FU_wq_chlorine_storedfc_again), 
                             (R_FU_fc_stored + R_FU_wq_chlorine_storedfc_again) / 2),
    stored_water_tc = ifelse(is.na(R_FU_tc_stored) | is.na(R_FU_wq_chlorine_storedtc_again), 
                             coalesce(R_FU_tc_stored, R_FU_wq_chlorine_storedtc_again), 
                             (R_FU_tc_stored + R_FU_wq_chlorine_storedtc_again) / 2)
  ) %>%
  ungroup()



#geenrating auniform time measurement variable 

# removing prefix R_FU_
BH_Clean_view_f <- BH_Clean_view %>%
  rename_all(~ sub("^R_FU_", "", .))


BH_Clean_view_f <- BH_Clean_view_f %>%
  rename(
    Village = r_cen_village_name_str
  )



View(BH_Clean_view_f)

#"unique_id"     "sample_ID"     "bag_ID"        "sample_type"   "bag_ID_stored" "bag_ID_tap"  
#unique_id  sample_ID_stored  sample_ID_tap  bag_ID_stored bag_ID_tap
names(BH_Clean_view_f)

names(BL_idexx_v)

BH_fil <- BH_Clean_view_f %>% select(unique_id_num,  sample_ID_stored,  sample_ID_tap,  bag_ID_stored, bag_ID_tap)

BH_Clean_view_long <- BH_fil %>%
  pivot_longer(
    cols = starts_with("sample_ID") | starts_with("bag_ID"),  # Specify the columns to reshape
    names_to = c(".value", "sample_type"),  # `.value` keeps part of the column names as variables
    names_pattern = "(sample_ID|bag_ID)_(stored|tap)"         # Use a regular expression to capture the `stored` and `tap` parts
  )

View(BH_Clean_view_long)


BH_Clean_view_long <- BH_Clean_view_long %>%
  rename(
    unique_id = unique_id_num
  )

names(BH_Clean_view_long)

BH_Clean_view_long$sample_type <- ifelse(BH_Clean_view_long$sample_type == "stored", "Stored", BH_Clean_view_long$sample_type)
BH_Clean_view_long$sample_type <- ifelse(BH_Clean_view_long$sample_type == "tap", "Tap", BH_Clean_view_long$sample_type)


BH_Clean_view_long <- BH_Clean_view_long %>%
  filter(!(is.na(sample_ID) & is.na(bag_ID)))

View(BH_Clean_view_long)
merged_data <- full_join(BL_idexx_v, BH_Clean_view_long, 
                         by = c("unique_id"),
                         suffix = c("_BL", "_BH"))





merged_data <- merged_data %>%
  mutate(flag_mismatch = if_else(sample_ID_BL != sample_ID_BH & bag_ID_BL != bag_ID_BH & sample_type_BL == sample_type_BH, 1, 0))

View(merged_data)

#I found one mismatch

##########################################################################

#-------------- BASELINE HH SURVEY ----------------------------------
##########################################################################



BL_idexx <- read_csv(paste0(Lab_path(), "BL_idexx_master_cleaned.csv"))
View(BL_idexx)

names(BL_idexx)

BL_idexx<- BL_idexx %>%
  mutate(cf_95lo = quantify_95lo(y_large, y_small, "qt-2000"),
         cf_mpn  = quantify_mpn(y_large, y_small, "qt-2000"),
         cf_95hi = quantify_95hi(y_large, y_small, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

BL_idexx <- BL_idexx %>%
  mutate(ec_95lo = quantify_95lo(f_large, f_small, "qt-2000"),
         ec_mpn  = quantify_mpn(f_large, f_small, "qt-2000"),
         ec_95hi = quantify_95hi(f_large, f_small, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
BL_idexx <- BL_idexx %>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

BL_idexx <- BL_idexx %>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

BL_idexx <- BL_idexx %>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

BL_idexx <- BL_idexx %>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
BL_idexx <- BL_idexx %>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
BL_idexx <- BL_idexx %>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))


View(BL_idexx)


names(BL_idexx)
BL_idexx_vis <- BL_idexx %>% select(sample_type, ec_log, cf_log, ec_risk, ec_pa, cf_pa, date, ec_mpn, cf_mpn, village_name, fc_tap_avg)
View(BL_idexx_vis)

BL_idexx_vis <- BL_idexx_vis %>%
  rename(
    village = village_name
  )

View(BL_idexx_vis)

str(BL_idexx_vis$date)



##########################################################################

#-------------- FOLLOW UP R1 SURVEY ----------------------------------
##########################################################################


FU1_idexx <- read_csv(paste0(Lab_path(), "R1_idexx_master_cleaned.csv"))

View(FU1_idexx)

FU1_idexx <- FU1_idexx %>%
  mutate(cf_95lo = quantify_95lo(y_large, y_small, "qt-2000"),
         cf_mpn  = quantify_mpn(y_large, y_small, "qt-2000"),
         cf_95hi = quantify_95hi(y_large, y_small, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

FU1_idexx <- FU1_idexx %>%
  mutate(ec_95lo = quantify_95lo(f_large, f_small, "qt-2000"),
         ec_mpn  = quantify_mpn(f_large, f_small, "qt-2000"),
         ec_95hi = quantify_95hi(f_large, f_small, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
FU1_idexx <- FU1_idexx %>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

FU1_idexx <- FU1_idexx %>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

FU1_idexx <- FU1_idexx %>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

FU1_idexx<- FU1_idexx %>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
FU1_idexx <- FU1_idexx %>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
FU1_idexx <- FU1_idexx %>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))

names(FU1_idexx)

FU1_idexx_vis <- FU1_idexx %>% select(sample_type, ec_log, cf_log, ec_risk, ec_pa, cf_pa, date, ec_mpn, cf_mpn, village_name, fc_tap_avg)
View(FU1_idexx_vis)

FU1_idexx_vis <- FU1_idexx_vis %>%
  rename(
    village = village_name
  )

str(FU1_idexx_vis$date)

ggplot(data = FU1_idexx_vis, aes(x = sample_type, fill = factor(ec_pa))) +
  geom_bar(position = "dodge") +
  labs(title = "Presence and Absence of E. coli by Sample Type",
       x = "Sample Type",
       y = "Count",
       fill = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()


box_BL <- ggplot(data = FU1_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

print(box_BL)

box_FU1 <- ggplot(data = BL_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

print(box_BL)


# Load the required library
library(ggplot2)

# Combine the data
combined_data <- bind_rows(
  FU1_idexx_vis %>% mutate(period = "Baseline"),
  BL_idexx_vis %>% mutate(period = "Follow-up")
)

# Create the combined boxplot
combined_boxplot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  facet_wrap(~ period) +  # Facet by the time period
  labs(title = "Distribution of E. coli Magnitude by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# Print the combined plot
print(combined_boxplot)


# Combine the data
combined_data <- bind_rows(
  FU1_idexx_vis %>% mutate(period = "Baseline"),
  BL_idexx_vis %>% mutate(period = "Follow-up")
)

# Create the combined plot
combined_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot(alpha = 0.5) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

# Print the combined plot
print(combined_plot)




# Combine the data
combined_data <- bind_rows(
  FU1_idexx_vis %>% mutate(period = "Baseline"),
  BL_idexx_vis %>% mutate(period = "Follow-up")
)

# Create the enhanced plot
enhanced_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2, alpha = 0.8) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        legend.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"),
        axis.text = element_text(size = 12),
        strip.text = element_text(size = 12, face = "bold"))

# Print the enhanced plot
print(enhanced_plot)


##########################################################################

#-------------- FOLLOW UP R2 SURVEY ----------------------------------
##########################################################################


FU2_idexx <- read_csv(paste0(Lab_path(), "R2_idexx_master_cleaned.csv"))

View(FU2_idexx)

names(FU2_idexx)

FU2_idexx <- FU2_idexx %>%
  mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_mpn  = quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

FU2_idexx <- FU2_idexx %>%
  mutate(ec_95lo = quantify_95lo(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_mpn  = quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_95hi = quantify_95hi(large_c_flurosce, small_c_flurosce, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
FU2_idexx <- FU2_idexx %>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

FU2_idexx <- FU2_idexx %>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

FU2_idexx <- FU2_idexx %>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

FU2_idexx<- FU2_idexx %>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
FU2_idexx <- FU2_idexx %>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
FU2_idexx <- FU2_idexx %>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))

View(FU2_idexx)

# Convert SubmissionDate to POSIXct type- The date now is in thje fomr that can be used in ggpplot
FU2_idexx$date <- as.POSIXct(FU2_idexx$SubmissionDate, format = "%m/%d/%Y")


FU2_idexx_vis <- FU2_idexx %>% select(sample_type, ec_log, cf_log, ec_risk, ec_pa, cf_pa, ec_mpn, cf_mpn, village_name, date_processed, date, fc_tap_avg)

FU2_idexx_vis <- FU2_idexx_vis %>%
  rename(
    village = village_name
  )


View(FU2_idexx_vis)

str(FU2_idexx_vis$date)

##########################################################################

#-------------- COMBINED GRAPHS ----------------------------------
##########################################################################


box_BL <- ggplot(data = FU1_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

print(box_BL)

box_FU1 <- ggplot(data = BL_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

box_FU2 <- ggplot(data = FU2_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()


# Combine the data
combined_data <- bind_rows(
  FU1_idexx_vis %>% mutate(period = "Baseline"),
  BL_idexx_vis %>% mutate(period = "Follow-up R1"),
  FU2_idexx_vis %>% mutate(period = "Follow-up R2")
)

# Create the combined boxplot
combined_boxplot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  facet_wrap(~ period) +  # Facet by the time period
  labs(title = "Distribution of E. coli Magnitude by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# Print the combined plot
print(combined_boxplot)

# VIOLIN PLOT WITH PRESENCE AND ABSENCE DATA 

# Create the enhanced plot
enhanced_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2, alpha = 0.8) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        legend.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"),
        axis.text = element_text(size = 12),
        strip.text = element_text(size = 12, face = "bold"))

# Print the enhanced plot
print(enhanced_plot)


# BOXPLOT WITH PRESENCE AND ABSENCE DATA 

# Create the combined plot
combined_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot(alpha = 0.5) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

# Print the combined plot
print(combined_plot)



##########################################################################

#-------------- FOLLOW UP R3 SURVEY ----------------------------------
##########################################################################


FU3_idexx <- read_csv(paste0(Lab_path(), "R3_idexx_master_cleaned.csv"))

View(FU3_idexx)

names(FU3_idexx)

FU3_idexx <- FU3_idexx %>%
  mutate(cf_95lo = quantify_95lo(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_mpn  = quantify_mpn(large_c_yellow, small_c_yellow, "qt-2000"),
         cf_95hi = quantify_95hi(large_c_yellow, small_c_yellow, "qt-2000"))%>%
  mutate_at(vars(cf_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))

FU3_idexx <- FU3_idexx %>%
  mutate(ec_95lo = quantify_95lo(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_mpn  = quantify_mpn(large_c_flurosce, small_c_flurosce, "qt-2000"),
         ec_95hi = quantify_95hi(large_c_flurosce, small_c_flurosce, "qt-2000"))%>%
  mutate_at(vars(ec_mpn), ~ifelse(is.na(.) == TRUE, 2419, .))



#Adding presence/absence data
FU3_idexx <- FU3_idexx %>%
  mutate(cf_pa = case_when(
    is.na(cf_mpn) == TRUE ~ "Presence",
    cf_mpn > 0 ~ 'Presence',
    cf_mpn == 0 ~ 'Absence'))

FU3_idexx <- FU3_idexx %>%
  mutate(ec_pa = case_when(
    is.na(ec_mpn) == TRUE ~ "Presence",
    ec_mpn > 0 ~ 'Presence',
    ec_mpn == 0 ~ 'Absence'))

FU3_idexx <- FU3_idexx %>%
  mutate(cf_pa_binary = case_when(
    cf_mpn > 0 ~ 1,
    cf_mpn == 0 ~ 0))

FU3_idexx<- FU3_idexx %>%
  mutate(ec_pa_binary = case_when(
    ec_mpn > 0 ~ 1,
    ec_mpn == 0 ~ 0))


#log transforming data
FU3_idexx <- FU3_idexx %>%
  mutate(ec_mpn_2 = case_when(ec_mpn <= 0 ~ 0.5, #half the detection limit
                              ec_mpn > 0 ~ ec_mpn))%>%
  mutate(cf_mpn_2 = case_when(cf_mpn <= 0 ~ 0.5,
                              cf_mpn > 0 ~ cf_mpn))%>%
  mutate(ec_log = log(ec_mpn_2, base = 10))%>%
  mutate(cf_log = log(cf_mpn_2, base = 10))
#Make - inf values be 0

#Adding in WHO risk levels
FU3_idexx <- FU3_idexx %>%
  mutate(ec_risk = case_when(ec_mpn < 1 ~ "Very Low Risk - Nondetectable",
                             (ec_mpn >= 1 & ec_mpn <= 10) ~ "Low Risk",
                             (ec_mpn > 10 & ec_mpn <= 100) ~ "Intermediate Risk",
                             ec_mpn > 100 ~ "High Risk"))


names(FU3_idexx)

FU3_idexx$date <- as.POSIXct(FU3_idexx$SubmissionDate, format = "%m/%d/%Y")

FU3_idexx_vis <- FU3_idexx %>% select(sample_type, ec_log, cf_log, ec_risk, ec_pa, cf_pa,ec_mpn, cf_mpn, village,  date_processed, date, fc_tap_avg)

View(FU3_idexx_vis)

str(FU3_idexx_vis$date)
##########################################################################

#-------------- COMBINED GRAPHS ----------------------------------
##########################################################################


box_BL <- ggplot(data = FU1_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

print(box_BL)

box_FU1 <- ggplot(data = BL_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

box_FU2 <- ggplot(data = FU2_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

box_FU3 <- ggplot(data = FU3_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()



# Combine the data
combined_data <- bind_rows(
  FU1_idexx_vis %>% mutate(period = "Baseline"),
  BL_idexx_vis %>% mutate(period = "Follow-up R1"),
  FU2_idexx_vis %>% mutate(period = "Follow-up R2"),
  FU3_idexx_vis %>% mutate(period = "Follow-up R3")
)

# Extract the month as a numeric value
combined_data$month <- format(combined_data$date, "%m")

# Assuming combined_data$date is of Date class
combined_data$month_name <- month.name[as.numeric(combined_data$month)]  # Map month numbers to names

View(combined_data)

combined_data_f <- combined_data %>% filter(sample_type == "Tap")

#show MPN 
View(combined_data)
# Create the combined boxplot
combined_boxplot <- ggplot(data = combined_data_f, aes(x = month, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# Print the combined plot
print(combined_boxplot)

# VIOLIN PLOT WITH PRESENCE AND ABSENCE DATA 

# Create the enhanced plot
enhanced_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2, alpha = 0.8) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        legend.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"),
        axis.text = element_text(size = 12),
        strip.text = element_text(size = 12, face = "bold"))

# Print the enhanced plot
print(enhanced_plot)


# BOXPLOT WITH PRESENCE AND ABSENCE DATA 

# Create the combined plot
combined_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot(alpha = 0.5) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

# Print the combined plot
print(combined_plot)


##########################################################################

#-------------- Monthly Monitoring R1 Survey ----------------------------------
##########################################################################


MM_idexx <- read_csv(paste0(Final_path(), "idexx_monthly_master_cleaned.csv"))


MM_idexx$date <- as.POSIXct(MM_idexx$SubmissionDate.x, format = "%m/%d/%Y")

names(MM_idexx)
MM_idexx_vis <- MM_idexx %>% select(sample_type, ec_log, cf_log, ec_risk, ec_pa, cf_pa, village_name, ec_mpn, cf_mpn, date_processed, date, tap_water_fc)

MM_idexx_vis <- MM_idexx_vis %>% 
  rename (fc_tap_avg = tap_water_fc)

MM_idexx_vis <- MM_idexx_vis %>% 
  rename (village = village_name)


View(MM_idexx_vis)

str(MM_idexx_vis$date)
##########################################################################

#-------------- COMBINED GRAPHS ----------------------------------
##########################################################################


box_BL <- ggplot(data = FU1_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

print(box_BL)

box_FU1 <- ggplot(data = BL_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

box_FU2 <- ggplot(data = FU2_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

box_FU3 <- ggplot(data = FU3_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_mpn)") +
  theme_minimal()

box_MM <- ggplot(data = MM_idexx_vis, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  labs(title = "Distribution of E. coli Magnitude by Sample Type",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_)") +
  theme_minimal()



# Convert 'village' to character in each dataset
BL_idexx_vis <- BL_idexx_vis %>% mutate(village = as.character(village))
FU1_idexx_vis <- FU1_idexx_vis %>% mutate(village = as.character(village))
FU2_idexx_vis <- FU2_idexx_vis %>% mutate(village = as.character(village))
FU3_idexx_vis <- FU3_idexx_vis %>% mutate(village = as.character(village))
MM_idexx_vis <- MM_idexx_vis %>% mutate(village = as.character(village))

# Combine the data
#combined_data <- bind_rows(
  #BL_idexx_vis %>% mutate(period = "26th Sep-17th Nov"),
  #FU1_idexx_vis %>% mutate(period = "5th Feb-24th Feb"),
  #FU2_idexx_vis %>% mutate(period = "5th Mar-4th Apr"),
  #FU3_idexx_vis %>% mutate(period = "6th Apr-30th Apr"),
  #MM_idexx_vis %>% mutate(period = "20th July-9th Aug")
#)

combined_data <- bind_rows(
  BL_idexx_vis %>% mutate(period = "Baseline HH"),
  FU1_idexx_vis %>% mutate(period = "Follow up R1"),
  FU2_idexx_vis %>% mutate(period = "Follow up R2"),
  FU3_idexx_vis %>% mutate(period = "Follow up R3"),
  MM_idexx_vis %>% mutate(period = "Monthly monitoring")
)


View(combined_data)

str(combined_data$date)
village_details <- read_csv(paste0(user_path(), "/3_final/village_details.csv"))
View(village_details)

village_details <- village_details %>% 
  rename (village = village_name)

# Merge datasets based on the 'village_name' variable
merged_data <- merge(combined_data, village_details[, c("village", "assignment")], 
                     by = "village", all.x = TRUE)


# Assuming combined_data is your dataframe
merged_data <- merged_data %>%
  mutate(date = as.Date(date))

# Convert dates to POSIXct and extract month and year


merged_data <- merged_data %>%
  mutate(
    month = month(date),               # Extract month
    year = year(date),                 # Extract year
    year_month = as.Date(paste(year, month, "01", sep = "-"), format = "%Y-%m-%d")  # Combine year and month
  )

View(merged_data)

unique(merged_data$sample_type)

# Replace specific values
merged_data<- merged_data %>%
  mutate(sample_type = ifelse(sample_type == "tap_sample_id", "Tap", sample_type))

merged_data<- merged_data %>%
  mutate(sample_type = ifelse(sample_type == "stored_sample_id", "Stored", sample_type))


#merged_data_f <- merged_data %>% filter(sample_type == "Tap" & assignment == "C")

merged_data_f <- merged_data %>% filter(sample_type == "Tap")

View(merged_data_f)
names(merged_data_f)


merged_data_f <- merged_data_f %>%
  mutate(year_month = as.factor(year_month)) %>%
  mutate(year_month = case_when(
    year_month == "2023-10-01" ~ "Oct23",
    year_month == "2023-11-01" ~ "Nov23",
    year_month == "2024-02-01" ~ "Feb24",
    year_month == "2024-03-01" ~ "Mar24",
    year_month == "2024-04-01" ~ "Apr24",
    year_month == "2024-05-01" ~ "May24",
    year_month == "2024-07-01" ~ "July24",
    year_month == "2024-08-01" ~ "August24",
    TRUE ~ as.character(year_month)  # Keep the original value if no match
  ))

# Convert back to factor if needed
merged_data_f <- merged_data_f %>%
  mutate(year_month = as.factor(year_month))


# Manually specify the order of levels for year_month
merged_data_f <- merged_data_f %>%
  mutate(year_month = factor(year_month, levels = c("Oct23", "Nov23", "Feb24", "Mar24", "Apr24", "May24", "July24", "August24")))

# Plot the boxplot with the correctly ordered year_month
unique(merged_data_f$sample_type)
#basic plot
ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  labs(x = "Year-Month", y = "ec_log", title = "Boxplot of ec_log by Year-Month for Control and tap") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



# Assuming merged_data_f is already ordered by year_month as before
#plot with mean
ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  labs(x = "Year-Month", y = "ec_log", title = "Boxplot of ec_log by Year-Month with Mean") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

merged_data_f <- merged_data_f %>%
  mutate(assignment = ifelse(assignment == "T", "Treatment", assignment))

merged_data_f <- merged_data_f %>%
  mutate(assignment = ifelse(assignment == "C", "Control", assignment))

threshold <- -0.3010 # Example threshold, log10(1) = 0

ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  geom_hline(yintercept = threshold, linetype = "dashed", color = "blue") +
  facet_wrap(~ assignment) +
  labs(x = "Month of test", y = "Log10 E.Coli MPN", title = "Boxplot of ec_log by Year-Month with Mean and Threshold for treatment-tap") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  annotate("text", x = Inf, y = threshold, label = "threshold", vjust = -1, hjust = 1.1, color = "blue")


#########################

# Draw the threshold line separately
threshold_line <- geom_hline(aes(yintercept = threshold), linetype = "dashed", color = "blue")

# Combine the threshold line with your existing plot
ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  facet_wrap(~ assignment) +
  labs(x = "Month of test", y = "Log10 E.Coli MPN", title = "Boxplot of ec_log by Year-Month with Mean and Threshold for treatment-tap") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  annotate("text", x = Inf, y = threshold, label = "threshold", vjust = -1, hjust = 1.1, color = "blue") +
  threshold_line


#-----------------------------------------

#FINAL 
#-----------------------
threshold_value <- threshold  # Store the threshold value if not already stored

# Combine the threshold line with your existing plot
ecoli <- ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  facet_wrap(~ assignment) +
  labs(
    x = "Month of test", 
    y = "Log10 E.Coli MPN", 
    title = "Temporal Analysis of E.Coli Contamination: Log10 MPN Distribution by Month and Treatment Assignment",
    caption = paste("Note: Threshold value for E.Coli presence is ", threshold_value, 
                    ". Values above this threshold indicate a presence of E.Coli contamination.")
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    plot.caption = element_text(size = 9, hjust = 0, face = "italic", color = "gray40")  # Style the caption
  ) +
  annotate("text", x = Inf, y = threshold, label = "threshold", vjust = -1, hjust = 1.1, color = "blue") +
  threshold_line


ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_temporal.png"), ecoli, bg = "white", width = 8, height = 8, dpi = 200)

#--------without mean

threshold_value <- threshold  # Store the threshold value if not already stored

# Combine the threshold line with your existing plot
ecoli <- ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  facet_wrap(~ assignment) +
  labs(
    x = "Month of test", 
    y = "Log10 E.Coli MPN", 
    title = "Temporal Analysis of E.Coli Contamination: Log10 MPN Distribution by Month and Treatment Assignment",
    caption = paste("Note: Threshold value for E.Coli presence is ", threshold_value, 
                    ". Values above this threshold indicate a presence of E.Coli contamination.")
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    plot.caption = element_text(size = 9, hjust = 0, face = "italic", color = "gray40")  # Style the caption
  ) +
  annotate("text", x = Inf, y = threshold, label = "threshold", vjust = -1, hjust = 1.1, color = "blue") +
  threshold_line


ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_temporal.png"), ecoli, bg = "white", width = 8, height = 6, dpi = 200)


#inreasex text sizie

ecoli <- ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  facet_wrap(~ assignment) +
  labs(
    x = "Month of test", 
    y = "Log10 E.Coli MPN", 
    title = "Temporal Presentation of E.Coli Contamination: Log10 MPN Distribution by Month and Treatment Assignment",
    caption = paste(      "A boxplot displays data distribution through the median (central line),",
                          "the interquartile range (box edges from Q1 to Q3), and variability",
                          "(whiskers extending to the smallest and largest non-outlier values).",
                          "Outliers are shown as individual points beyond the whiskers, highlighting",
                          "any deviations from the overall pattern. ")
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10),   # Increase x-axis text size
    axis.text.y = element_text(size = 10),                         # Increase y-axis text size
    axis.title.x = element_text(size = 12),                        # Increase x-axis title size
    axis.title.y = element_text(size = 10),                        # Increase y-axis title size
    strip.text = element_text(size = 10),                          # Increase facet label size
    plot.title = element_text(size = 10),                          # Increase title size
    plot.caption = element_text(size = 9.5, hjust = 0, face = "italic", color = "gray40")  # Style the caption
  ) +
  annotate("text", x = Inf, y = threshold, label = "Presence/Absence", vjust = -1, hjust = 1.1, color = "blue") +
  threshold_line

print(ecoli)
# Save the plot
ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_temporal.png"), ecoli, bg = "white", width = 8, height = 6, dpi = 200)






#######

ecoli <- ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  facet_wrap(~ assignment) +
  labs(
    x = "Month of test", 
    y = "Log10 E.Coli MPN", 
    title = "Temporal Presentation of E.Coli Contamination: Log10 MPN Distribution by Month and Treatment Assignment",
    caption = "A boxplot displays data distribution through the median (central line), the interquartile range (box edges from Q1 to Q3),  and variability (whiskers extending\n\
to the smallest and largest non-outlier values). Outliers are shown as individual points beyond the whiskers, highlighting any deviations from the overall pattern\n\
and the red dot indicates the Mean.\n\
Samples measuring < 1 MPN/100 mL were imputed with a values of 0.5 (half the detection limit) to allow for log-transformation of the data."
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 10),   # Increase x-axis text size
    axis.text.y = element_text(size = 10),                         # Increase y-axis text size
    axis.title.x = element_text(size = 12),                        # Increase x-axis title size
    axis.title.y = element_text(size = 10),                        # Increase y-axis title size
    strip.text = element_text(size = 10),                          # Increase facet label size
    plot.title = element_text(size = 10),                          # Increase title size
    plot.caption = element_text(size = 9.5, hjust = 0, face = "italic", color = "gray40", lineheight = 0.5)  # Style the caption
  ) +
  annotate("text", x = Inf, y = threshold, label = "Presence/Absence", vjust = -1, hjust = 1.1, color = "blue") +
  threshold_line

print(ecoli)


ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_temporal.png"), ecoli, bg = "white", width = 10, height = 6, dpi = 200)


#label to appear only once 
# Create a base plot without the threshold line and label
p <- ggplot(merged_data_f, aes(x = year_month, y = ec_log)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  facet_wrap(~ assignment) +
  labs(x = "Month of test", y = "Log10 E.Coli MPN", title = "Boxplot of ec_log by Year-Month with Mean and Threshold for treatment-tap") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Add the threshold line and label only to the first facet
p + 
  geom_hline(aes(yintercept = threshold), linetype = "dashed", color = "blue",
             data = merged_data_f %>% filter(assignment == unique(merged_data_f$assignment)[1])) +
  geom_text(aes(x = Inf, y = threshold, label = "threshold"), vjust = -1, hjust = 1.1, color = "blue",
            data = merged_data_f %>% filter(assignment == unique(merged_data_f$assignment)[1]))

#############################################
#now descriptive stats 

View(merged_data_f)

# Ensure ec_log is numeric
merged_data_f <- merged_data_f %>%
  mutate(ec_log = as.numeric(ec_log))

# Using base R to calculate the percentage of samples with ec_log > 1

# First, ensure ec_log is numeric
merged_data_f$ec_log <- as.numeric(merged_data_f$ec_log)

# Calculate the percentage of samples with ec_log > 1, grouped by assignment and period
percentage_above_threshold <- with(merged_data_f, {
  aggregate(ec_log ~ assignment + period, data = merged_data_f, FUN = function(x) {
    total_samples <- length(x)
    above_threshold <- sum(x > 1, na.rm = TRUE)
    percentage_above_threshold <- (above_threshold / total_samples) * 100
    return(c(total_samples = total_samples, above_threshold = above_threshold, percentage_above_threshold = percentage_above_threshold))
  })
})


# Convert to data frame if it's not already
percentage_above_threshold <- as.data.frame(percentage_above_threshold)

View(percentage_above_threshold)


library(dplyr)

View(merged_data_f)
#ARCHI COME HERE 
names(merged_data_f)
percentage_above_threshold <- merged_data_f  %>%
  group_by(period, assignment) %>%
  summarise(
    total_samples = n(),
    above_threshold = sum(ec_log > 1 & fc_tap_avg < 0.2, na.rm = TRUE),
    percentage_above_threshold = round((above_threshold / total_samples) * 100,2)
  )

percentage_above_threshold <- percentage_above_threshold %>%
  rename(
    Assignment = assignment,
    Survey = period,
    Total_Samples = total_samples,
    Above_Threshold = above_threshold,
    Percentage = percentage_above_threshold
  )


perc <- percentage_above_threshold %>% select(Assignment, Survey,Total_Samples, Percentage)

View(perc)
stargazer(perc, 
          summary = FALSE, 
          title = "E.Coli samples greater than Log10 E.Coli MPN > 1 and FC<0.2", 
          float = FALSE, 
          rownames = FALSE, 
          out = paste0(overleaf(), "Table/percentage_above_threshold.tex"))

















# Example wide format table
percentage_above_threshold <- merged_data_f %>%
  group_by(assignment, period) %>%
  summarise(
    Total_Samples = n(),
    Above_Threshold = sum(ec_log > 1, na.rm = TRUE),
    Percentage_Above_Threshold = (Above_Threshold / Total_Samples) * 100
  )

long_format_table <- percentage_above_threshold %>%
  pivot_longer(cols = c(Total_Samples, Above_Threshold, Percentage_Above_Threshold),
               names_to = "Metric",
               values_to = "Value")
# View the reshaped data
print(long_format_table)

View(long_format_table)









#plot with mpn instead of log
ggplot(merged_data_f, aes(x = year_month, y = ec_mpn)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red", color = "black") +
  labs(x = "Year-Month", y = "ec_mpn", title = "Boxplot of ec_mpn by Year-Month with Mean") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


























#################################################################
#########################################################################
########################################################################
###########################################################################

# Create the combined boxplot
combined_boxplot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  facet_wrap(~ period) +  # Facet by the time period
  labs(title = "Distribution of E. coli Magnitude by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# Print the combined plot
print(combined_boxplot)

# VIOLIN PLOT WITH PRESENCE AND ABSENCE DATA 

# Create the enhanced plot
enhanced_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2, alpha = 0.8) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal() +
  theme(legend.position = "bottom", 
        legend.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"),
        axis.text = element_text(size = 12),
        strip.text = element_text(size = 12, face = "bold"))

# Print the enhanced plot
print(enhanced_plot)


# BOXPLOT WITH PRESENCE AND ABSENCE DATA 

# Create the combined plot
combined_plot <- ggplot(data = combined_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot(alpha = 0.5) +
  geom_jitter(aes(color = factor(ec_pa)), size = 2, shape = 16, position = position_jitter(width = 0.2)) +
  facet_wrap(~ period) +
  scale_color_manual(values = c("red", "blue"), labels = c("Absent", "Present")) +
  labs(title = "Distribution of E. coli Magnitude and Presence/Absence by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)",
       fill = "Sample Type",
       color = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

# Print the combined plot
print(combined_plot)

ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_presencevsRounds.png"), combined_plot, bg = "white", width = 10, height = 10, dpi = 200)



View(combined_data)


combined_boxplot <- ggplot(data = merged_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  facet_wrap(~ period) +  # Facet by the time period
  labs(title = "Distribution of E. coli Magnitude by Sample Type and Time Period",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

combined_boxplot <- ggplot(data = merged_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  facet_wrap(~ period + assignment) +  # Facet by both period and assignment
  labs(title = "Distribution of E. coli Magnitude by Sample Type, Time Period, and Assignment",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# To display the plot
print(combined_boxplot)

View(merged_data)

# Print the combined plot
print(combined_boxplot)

# Assuming the detection threshold is at a specific log value
detection_threshold <- 1  # Replace this with the actual log value

combined_boxplot <- ggplot(data = merged_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  geom_hline(yintercept = detection_threshold, linetype = "dashed", color = "red") +  # Add horizontal line
  facet_wrap(~ period + assignment) +  # Facet by both period and assignment
  labs(title = "Distribution of E. coli Magnitude by Sample Type, Time Period, and Assignment",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# To display the plot
print(combined_boxplot)

ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_TvsCvsRounds.png"), combined_boxplot, bg = "white", width = 10, height = 10, dpi = 200)


##############################################

combined_boxplot <- ggplot(data = merged_data, aes(x = sample_type, y = ec_log, fill = sample_type)) +
  geom_boxplot() +
  geom_hline(yintercept = detection_threshold, linetype = "dashed", color = "red") +  # Add horizontal line
  facet_wrap(~ period + village) +  # Facet by both period and assignment
  labs(title = "Distribution of E. coli Magnitude by Sample Type, Time Period, and Assignment",
       x = "Sample Type",
       y = "E. coli Magnitude (ec_log)") +
  theme_minimal()

# To display the plot
print(combined_boxplot)

ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_villagevsRounds.png"), combined_boxplot, bg = "white", width = 10, height = 10, dpi = 200)

#####################################################
#presnece and absence data 
ggplot(data = merged_data, aes(x = sample_type, fill = factor(ec_pa))) +
  geom_bar(position = "dodge") +
  facet_wrap(~ period + assignment) +
  labs(title = "Presence and Absence of E. coli by Sample Type",
       x = "Sample Type",
       y = "Count",
       fill = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

ggplot(data = merged_data, aes(x = sample_type, fill = factor(ec_pa))) +
  geom_bar(position = "fill", aes(y = ..count.. / sum(..count..) * 100)) +  # Calculate percentages
  facet_wrap(~ period + assignment) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +  # Show y-axis as percentage
  labs(title = "Percentage of E. coli Presence and Absence by Sample Type",
       x = "Sample Type",
       y = "Percentage",
       fill = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

ecoli_pa <- ggplot(data = merged_data, aes(x = sample_type, fill = factor(ec_pa))) +
  geom_bar(position = "fill", aes(y = after_stat(count) / sum(after_stat(count)) * 100)) +  # Calculate percentages
  facet_wrap(~ period + assignment) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +  # Show y-axis as percentage
  labs(title = "Percentage of E. coli Presence and Absence by Sample Type",
       x = "Sample Type",
       y = "Percentage",
       fill = "E. coli Presence (1 = Present, 0 = Absent)") +
  theme_minimal()

print(ecoli_pa)

ggplot2::ggsave(paste0(overleaf(), "Figure/e-coli_PATvsCvsRounds.png"), ecoli_pa, bg = "white", width = 10, height = 10, dpi = 200)


# 