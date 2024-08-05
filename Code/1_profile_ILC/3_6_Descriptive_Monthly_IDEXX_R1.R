

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



#---------------chlorine decay plots village wise----------------------------#


#---------------------------------------------
# OVER STORAGE TIME 
#-----------------------------------------------

#geenrating auniform time measurement variable 

# Create a conversion factor

ms_consent <- read_csv(paste0(user_path(),"/3_final/2_11_monthly_follow_up_cleaned_consented.csv"))


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

