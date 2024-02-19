

install.packages("rsurveycto")
install.packages("httr")
install.packages("tidyverse")
install.packages("lubridate")
install.packages("sjmisc")
install.packages("knitr")
install.packages("kableExtra")
install.packages("readxl")
install.packages("stargazer")
install.packages("haven")
install.packages("googlesheets4")
install.packages("dplyr")
install.packages("rsurveycto")
install.packages("data.table")
install.packages("ggridges")




library(rsurveycto)
library(httr)
library(tidyverse)
library(lubridate)
library(sjmisc)
library(knitr)
library(kableExtra)
library(readxl)
#library(experiment)
library(stargazer)
library(haven)
library(googlesheets4)
library(dplyr)
library(rsurveycto)
library(data.table)


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
    path = "C:/Users/Archi Gupta/Box/Data/1_raw"
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
    github = "C:/Users/Archi Gupta/Documents/GitHub/i-h2o-india/Code"
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

#------------------------ Load the data ----------------------------------------#
#everyone please set your paths here
global_working_directory <- "C:/Users/Archi Gupta/Box/Data/1_raw/"

# Set the working directory to the global variable
setwd(global_working_directory)

# Print a message to confirm the working directory
print(paste("Working directory set to:", global_working_directory))


df.daily.cl <- read.csv(file.path(global_working_directory,"Daily Chlorine Monitoring Form_WIDE.csv"))  
df.super <- read.csv(file.path(global_working_directory,"india_ilc_pilot_monitoring_WIDE.csv"))

View(df.daily.cl)
View(df.super)

#extracting dates out of submission date
df.daily.cl$SubmissionDate <- substr(df.daily.cl$SubmissionDate, 1, regexpr(",", df.daily.cl$SubmissionDate) - 1)



df_edited <- df.super %>%
  select(-deviceid, -devicephonenum, -devicephonenum, -district_name, -block_name, -gp_name, -hamlet_name)
View(df_edited)

#---------------------------------------------------------------------------------#
#--------Firstly appending pump opeartor dataset into daily survey form ----------------------------------------#
#---------------------------------------------------------------------------------#


# Get the column names of the dataframe
all_vars <- colnames(df_edited)

# Find the positions of "enum_name" and "no_temp_settlement"
enum_name_pos <- which(all_vars == "enum_name")
no_temp_settlement_pos <- which(all_vars == "no_temp_settlement")

# Drop columns between "enum_name" and "no_temp_settlement", including these columns
df_final <- df_edited %>%
  select(-all_vars[(enum_name_pos + 1):(no_temp_settlement_pos - 1)])


df_recent <- df_final %>%
  select(-subscriberid, -enum_name, -no_temp_settlement, -subscriberid, -simid)

View(df_recent)
#extracting dates out of submission date
df_recent$SubmissionDate <- substr(df_recent$SubmissionDate, 1, regexpr(",", df_recent$SubmissionDate) - 1)


#Appending the datasets

# Get common column names between df.daily.cl and df_recent
common_column_names <- intersect(names(df.daily.cl), names(df_recent))
print(common_column_names)

# Subset df_recent to include only the common column names
df_recent_subset <- df_recent[, common_column_names]

# Append the datasets
combined_df <- rbind(df.daily.cl[, common_column_names], df_recent_subset)

View(combined_df)
combined_df$starttime <- substr(combined_df$starttime, 1, regexpr(",", combined_df$starttime) - 1)


# Filter observations where SubmissionDate is not equal to starttime
filtered_data <- combined_df %>%
  filter(SubmissionDate != starttime)

# View the filtered data
View(filtered_data)



#---------------------------------------------------------------------------------#
#--------Now appending google sheets data into combined_df----------------------------------------#
#---------------------------------------------------------------------------------#

google_sheet_data <- read_excel(file.path(global_working_directory,"Formatted_chlorine_survey_readings.xlsx"), sheet = "Sheet1")
View(google_sheet_data)

google_sheet_data <- google_sheet_data %>%
  select(-nearest_tap_sample_R, -nearest_tap_sample_S, -farthest_tap_sample_R, -farthest_tap_sample_S)

#DATE 

#changing the formatting of the date
google_sheet_data <- google_sheet_data %>%
  mutate(Date = as.Date(Date),  # Convert to Date object
         Date  = format(Date , "%m/%d/%Y"))  # Format in desired MDY format

#renaming the date var to match combined_df
google_sheet_data <- google_sheet_data %>%
  rename(starttime = Date)


# Get common column names between google_sheet_data and combined_df
common_column_names <- intersect(names(combined_df), names(google_sheet_data))
print(common_column_names)

#printing unmatched column names from 2 datasets
unmatched_columns_df2 <- setdiff(names(google_sheet_data), names(combined_df))

# Print unmatched column names
print(unmatched_columns_df2)


# Subset google_sheet_data to include only the common column names
google_sheet_data_subset <- google_sheet_data[, common_column_names]

# Append the datasets
final_combined_df <- rbind(combined_df[, common_column_names], google_sheet_data_subset)


View(final_combined_df)


#------------------------ Water Quality Stats ----------------------------------------#


# Assign final_combined_df to df.temp
df.temp <- final_combined_df


View(df.temp)


# Replace village name codes with their respective names
df.temp <- df.temp %>%
  mutate(village_name = case_when(
    village_name == "30701" ~ "Gopi Kankubadi",
    village_name == "50401" ~ "Birnarayanpur",
    village_name == "50501" ~ "Nathma",
    village_name == "30301" ~ "Tandipur",
    village_name == "20101" ~ "Badabangi",
    village_name == "40201" ~ "Bichikote",
    village_name == "10101" ~ "Asada",
    village_name == "30202" ~ "BK Padar",
    village_name == "30602" ~ "Mukundpur",
    village_name == "40101" ~ "Karnapadu",
    village_name == "40401" ~ "Naira",
    TRUE ~ village_name  # Keep the original value if not matched
  ))

# Convert village_name to lowercase and remove leading/trailing whitespace
df.temp$village_name <- tolower(trimws(df.temp$village_name))

# Print unique values to verify uniformity
unique(df.temp$village_name)

# Replace "gopikankubadi" with "gopi kankubadi" in village_name
df.temp$village_name <- gsub("gopikankubadi", "gopi kankubadi", df.temp$village_name)

# Convert village_name to lowercase and remove leading/trailing whitespace
df.temp$village_name <- tolower(trimws(df.temp$village_name))

# Print unique values to verify uniformity
unique(df.temp$village_name)

# Drop observations where village_name is equal to "88888" as these were practise observations used in training
df.temp <- subset(df.temp, village_name != "88888")



#------------------------ Dropping duplicates ----------------------------------------#
vars <- names(df.temp)
print(vars)

# Specify the columns based on which to identify duplicates
variables_to_check <- c("village_name", 
                        "first_nearest_tap_fc",
                        "second_nearest_tap_fc",
                        "first_nearest_tap_tc",
                        "second_nearest_tap_tc",
                        "first_stored_water_fc",
                        "second_stored_water_fc",
                        "first_stored_water_tc",
                        "second_stored_water_tc",
                        "first_farthest_tap_fc",
                        "second_farthest_tap_fc",
                        "first_farthest_tap_tc",
                        "second_farthest_tap_tc",
                        "far_first_stored_water_fc",
                        "far_second_stored_water_fc",
                        "far_first_stored_water_tc",
                        "far_second_stored_water_tc")

# Concatenate the values of specified variables into a single string
df.temp$concat_vars <- apply(df.temp[, variables_to_check], 1, paste, collapse = ",")

# Check for duplicate rows based on the concatenated string
duplicates <- df.temp[duplicated(df.temp$concat_vars) | 
                        duplicated(df.temp$concat_vars, fromLast = TRUE), ]


# Create a variable with today's date
today_date <- as.Date("2024-02-16")

# Add today_date column to duplicates dataset
duplicates$today_date <- today_date

# Convert starttime to date format
duplicates$starttime <- as.Date(duplicates$starttime, format = "%m/%d/%Y")

# Calculate the difference in days between starttime and today_date
duplicates$days_difference <- as.numeric(today_date - duplicates$starttime)

# Sort duplicates by days_difference in ascending order
duplicates <- duplicates[order(duplicates$days_difference), ]

# Keep only the first occurrence of each set of duplicate rows
duplicates <- duplicates[!duplicated(duplicates$concat_vars), ]

# Remove the concatenated column and days_difference column
duplicates <- duplicates[, !names(duplicates) %in% c("concat_vars", "days_difference", "today_date")]



# Remove the concatenated column from df.temp dataset
df.temp <- df.temp[, !names(df.temp) %in% "concat_vars"]


duplicates <- duplicates %>%
  mutate(starttime = as.Date(starttime),  # Convert to Date object
         starttime  = format(starttime , "%m/%d/%Y"))  # Format in desired MDY format

# Load the lubridate package for date manipulation
library(lubridate)

# Convert starttime column to Date format and MDY format in duplicates dataset
duplicates$starttime <- mdy(duplicates$starttime)

# Check the converted starttime values
head(duplicates$starttime)

# Check for NA values after conversion
sum(is.na(duplicates$starttime))

# Convert starttime column to Date format and MDY format in duplicates dataset
df.temp$starttime <- mdy(df.temp$starttime)

# Check the converted starttime values
head(df.temp$starttime)

# Check for NA values after conversion
sum(is.na(df.temp$starttime))

df.temp <- df.temp %>%
  mutate(starttime = as.Date(starttime),  # Convert to Date object
         starttime  = format(starttime , "%m/%d/%Y"))  # Format in desired MDY format

duplicates <- duplicates %>%
  mutate(starttime = as.Date(starttime),  # Convert to Date object
         starttime  = format(starttime , "%m/%d/%Y"))  # Format in desired MDY format



# Check if column names are identical in both datasets
identical(names(df.temp), names(duplicates))

# Check if data types are identical for all columns in both datasets
identical(sapply(df.temp, class), sapply(duplicates, class))


variables_to_check <- c("starttime", 
                        "village_name", 
                        "first_nearest_tap_fc",
                        "second_nearest_tap_fc",
                        "first_nearest_tap_tc",
                        "second_nearest_tap_tc",
                        "first_stored_water_fc",
                        "second_stored_water_fc",
                        "first_stored_water_tc",
                        "second_stored_water_tc",
                        "first_farthest_tap_fc",
                        "second_farthest_tap_fc",
                        "first_farthest_tap_tc",
                        "second_farthest_tap_tc",
                        "far_first_stored_water_fc",
                        "far_second_stored_water_fc",
                        "far_first_stored_water_tc",
                        "far_second_stored_water_tc")



# Store the initial row count of df.temp
initial_row_count <- nrow(df.temp)
print(initial_row_count)

# Perform anti-join
df.temp <- anti_join(df.temp, duplicates, by = variables_to_check)

# Store the final row count of df.temp
final_row_count <- nrow(df.temp)
print(final_row_count)

# Check if only rows from duplicates dataset were deleted
if (final_row_count == initial_row_count - nrow(duplicates)) {
  print("Only rows from duplicates dataset were deleted.")
} else {
  print("Rows from other datasets might also have been deleted.")
}



#------------------------ Dropping duplicates (#DOUBLE CHECK) ----------------------------------------#

#We want to make sure that only rows from duplicates dataset is deleted from df.temp 


# Create concat_vars in df.temp
df.temp$concat_vars <- apply(df.temp[, variables_to_check], 1, paste, collapse = ",")

# Create concat_vars in duplicates dataset
duplicates$concat_vars <- apply(duplicates[, variables_to_check], 1, paste, collapse = ",")

# Check if rows from duplicates dataset are deleted in df.temp dataset
deleted_rows <- df.temp[df.temp$concat_vars %in% duplicates$concat_vars, ]

if (nrow(deleted_rows) == 0) {
  print("All rows from duplicates dataset were deleted from df.temp dataset.")
} else {
  print("Some rows from duplicates dataset were not deleted from df.temp dataset.")
}


# Displaying chlorine concentration for each village
# Arranging data so chlorine test data is in one column
df.temp <- df.temp %>% 
  mutate(nearest_tap_fc = (first_nearest_tap_fc + second_nearest_tap_fc) / 2, 
         nearest_tap_tc = (first_nearest_tap_tc + second_nearest_tap_tc) / 2,
         nearest_stored_fc = (first_stored_water_fc + second_stored_water_fc) / 2,
         nearest_stored_tc = (first_stored_water_tc + second_stored_water_tc) / 2,
         farthest_tap_fc = (first_farthest_tap_fc + second_farthest_tap_fc) / 2,
         farthest_tap_tc = (first_farthest_tap_tc + second_farthest_tap_tc) / 2,
         farthest_stored_fc = (far_first_stored_water_fc + far_second_stored_water_fc) / 2,
         farthest_stored_tc = (far_first_stored_water_tc + far_second_stored_water_tc) / 2) 

chlorine <- df.temp%>%
  pivot_longer(cols = c(nearest_tap_fc, nearest_tap_tc, 
                        farthest_tap_fc,farthest_tap_tc, 
                        nearest_stored_fc, farthest_stored_fc, 
                        nearest_stored_tc, farthest_stored_tc), values_to = "chlorine_concentration", names_to = "chlorine_test_type")



chlorine <- chlorine %>%
  rename(Date = starttime)


chlorine <- chlorine %>% dplyr::select(village_name, chlorine_test_type, chlorine_concentration, Date )



chlorine <- chlorine %>% mutate(village = ifelse(village_name == 30701, "Gopi Kankubadi", 
                                                 ifelse(village_name == 50401, "Birnarayanpur", 
                                                        ifelse(village_name == 50501,"Nathma", 
                                                               ifelse(village_name == 30301,"Tandipur",
                                                                      ifelse(village_name == 20101, "Badabangi", 
                                                                             ifelse(village_name == 40201, "Bichikote", 
                                                                                    ifelse(village_name == 10101, "Asada", 
                                                                                           ifelse(village_name == 30202, "BK Padar", 
                                                                                                  ifelse(village_name == 30602, "Mukundpur",
                                                                                                         ifelse(village_name == 40101, "Karnapadu",
                                                                                                                ifelse(village_name == 40401, "Naira",NA)))))))))))) %>%
  mutate(Distance = ifelse(chlorine_test_type == "nearest_tap_tc"| chlorine_test_type == "nearest_stored_tc"|
                             chlorine_test_type == "nearest_stored_fc"|chlorine_test_type == "nearest_tap_fc", "Nearest", "Farthest")) %>%
  mutate(Test = ifelse(chlorine_test_type == "nearest_tap_tc"| chlorine_test_type == "farthest_tap_tc", "Tap Water: Total Chlorine", 
                       ifelse(chlorine_test_type == "nearest_tap_fc"| chlorine_test_type == "farthest_tap_fc", "Tap Water: Free Chlorine", 
                              ifelse(chlorine_test_type == "nearest_stored_fc"| chlorine_test_type == "farthest_stored_fc", "Stored Water: Free Chlorine", 
                                     "Stored Water: Total Chlorine")))) 


chlorine <- subset(chlorine, select = -village)

chlorine <- chlorine %>%
  rename(village = village_name)



village_list <- unique(chlorine$village) 
View(village_list)

df.stored <- chlorine %>% filter(chlorine_test_type == "nearest_stored_tc"|chlorine_test_type == "nearest_stored_fc"|
                                   chlorine_test_type == "farthest_stored_tc"|  chlorine_test_type == "farthest_stored_fc" )
df.tap <- chlorine %>% filter(chlorine_test_type == "nearest_tap_tc"|chlorine_test_type == "nearest_tap_fc"|
                                chlorine_test_type == "farthest_tap_tc"|  chlorine_test_type == "farthest_tap_fc" )
View(df.stored)
View(df.tap)



# STORED WATER 

library(lubridate)

plot_list_stored <- list()

for (i in village_list) {
  df.vil.cl <- df.stored %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +  # Adjust date_breaks to 5 days
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.position = c(1, 1),
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(6, 6, 6, 6), 
      axis.text.x = element_text(angle = 90, size = 10)
    ) + 
    scale_color_brewer(palette = "Dark2") + 
    ggtitle(paste0('Stored water: Village_', i))
  
  print(p)
  plot_list_stored[[i]] <- p
}


#TAP WATER

library(lubridate)

plot_list_tap <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8)  + 
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +  # Add horizontal lines at concentration 0.2 and 0.5
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', 
                 labels = scales::date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0.00, 2.00, 0.1)) +
    theme(
      legend.position = c(1, 1),
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(6, 6, 6, 6), axis.text.x = element_text(angle = 90, size = 10)
    ) +  scale_color_brewer(palette = "Dark2") + 
    ggtitle(paste0('Tap water: Village_', i))
  
  print(p)
  plot_list_tap[[i]] <- p
}



# Reading Excel File

#----------------------MASTER TRACKER-----------------------------------------#

print("Reading Excel file...")
Master_tracker <- read_excel(file.path(global_working_directory, "India ILC_MASTER Installation Tracker.xlsx"), sheet = "EventModification Tracking")
View(Master_tracker)

class(Master_tracker$Date)

# Convert village_name to lowercase and remove leading/trailing whitespace
print("Converting village names to lowercase and removing whitespace...")
Master_tracker$Village <- tolower(trimws(Master_tracker$Village))

# Print unique values to verify uniformity
print("Unique village names after transformation:")
print(unique(Master_tracker$Village))

# Making specific replacements
print("Replacing specific village name...")
Master_tracker$Village <- gsub("mukundapur", "mukundpur", Master_tracker$Village)

# Make dates uniform
#print("Converting dates to uniform format...")
Master_tracker <- Master_tracker %>%
  mutate(Date = as.Date(Date),  # Convert to Date object
         Date  = format(Date , "%m/%d/%Y"))  # Format in desired MDY format

Master_tracker$Date <- mdy(Master_tracker$Date)

class(Master_tracker$Date)
class(df.stored$Date)
class(df.vil.cl$Date)
# Renaming columns
print("Renaming columns...")
Master_tracker <- Master_tracker %>%
  rename(village = Village) %>%
  rename(modification = `General event or modification?`)

unique(Master_tracker$village)
unique(df.temp$village_name)

# Plotting
library(lubridate)
library(ggplot2)

print("Generating plots for each village...")
View(Master_tracker)

#-----------------STORED WATER WITH MODIFICATIONS-------------------------------#

plot_list_stored <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  df.vil.cl <- df.stored %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    geom_vline(data = Master_tracker, aes(xintercept = Date, color = modification), linetype = "solid") +
    labs(title = "Concentration of Chlorine", x = "Date", y = "") +
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 5),  # Reduce legend text size
      legend.key.size = unit(0.5, "cm"),     # Reduce legend key size
      legend.box = "horizontal",             # Arrange legends horizontally
      legend.spacing.x = unit(0.5, "cm"),     # Add spacing between legends
      legend.position = c(1, 1),          # Position legends at the top
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),     # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10)
    ) +
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan")) +  # Use distinct colors
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) +  # Abbreviate Test labels
    ggtitle(paste0('Stored water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(p)
  plot_list_stored[[i]] <- p
}

print("Plots generated for all villages.")


#-----------------TAP WATER WITH MODIFICATIONS-------------------------------#



library(lubridate)

plot_list_tap <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    geom_vline(data = Master_tracker, aes(xintercept = Date, color = modification), linetype = "solid") +
    labs(title = "Concentration of Chlorine", x = "Date", y = "") +
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 5),  # Reduce legend text size
      legend.key.size = unit(0.5, "cm"),     # Reduce legend key size
      legend.box = "horizontal",             # Arrange legends horizontally
      legend.spacing.x = unit(0.5, "cm"),     # Add spacing between legends
      legend.position = c(1, 1),          # Position legends at the top
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),     # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10)
    ) +
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan")) +  # Use distinct colors
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) +  # Abbreviate Test labels
    ggtitle(paste0('Tap water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(p)
  plot_list_tap[[i]] <- p
}
print("Plots generated for all villages.")


#--------------------------------------------------------------------------------------------------#
#------------------------IMPORTING GRAM VIKAS DATASET (work in progress)----------------------------------------------#
#--------------------------------------------------------------------------------------------------#


# Import an Excel file using the global_working_directory variable
Gram_vikas_data <- read_excel(file.path(global_working_directory, "India ILC_Gram Vikas Chlorine Monitoring.xlsx"))
View(Gram_vikas_data)

# Identify columns containing problematic values
problematic_columns <- c("Dosing control valve setting")

# Replace problematic values in selected columns
Gram_vikas_data[problematic_columns] <- lapply(Gram_vikas_data[problematic_columns], function(x) {
  # Replace values containing ":" with appropriate numeric values
  ifelse(grepl(":", x), as.numeric(gsub(":", ".", x)), x)
})

# Verify the changes
head(Gram_vikas_data)



#--------------------------------------------------------------------------------------------------#
#this dataset needs to be cleaned further




#----------------------INITIAL INSTALLATION-----------------------------------------#

print("Reading Excel file...")
initial_install <- read_excel(file.path(global_working_directory, "India ILC_MASTER Installation Tracker.xlsx"), sheet = "Initial Overall Installation Re")
View(initial_install)


# Convert village_name to lowercase and remove leading/trailing whitespace
print("Converting village names to lowercase and removing whitespace...")
initial_install$Village <- tolower(trimws(initial_install$Village))

# Print unique values to verify uniformity
print("Unique village names after transformation:")
print(unique(initial_install$Village))
print(unique(df.temp$village_name))

#All village names are matching 
class(initial_install$`Installation Date`)
class(df.temp$starttime)

initial_install <- initial_install %>%
  rename(installation_date = `Installation Date`)


#print("Converting dates to uniform format...")
initial_install <- initial_install %>%
  mutate(installation_date = as.Date(installation_date),  # Convert to Date object
         installation_date  = format(installation_date , "%m/%d/%Y"))  # Format in desired MDY format


initial_install$installation_date <- mdy(initial_install$installation_date)

initial_install <- initial_install %>%
  rename(village = Village)

initial_install <- initial_install %>%
  rename(Date = installation_date)

initial_install$Ins_status <- "first_installation_date"



#----------------------CURRENT INSTALLATION-----------------------------------------#

print("Reading Excel file...")
current_install <- read_excel(file.path(global_working_directory, "India ILC_MASTER Installation Tracker.xlsx"), sheet = "Current Installation Status")
View(current_install)

###Streamlining village values and  dates

# Convert village_name to lowercase and remove leading/trailing whitespace
print("Converting village names to lowercase and removing whitespace...")
current_install$Village <- tolower(trimws(current_install$Village))

# Print unique values to verify uniformity
print("Unique village names after transformation:")
print(unique(current_install$Village))
print(unique(df.temp$village_name))


current_install <- current_install %>%
  rename(last_installation_date = `Last Installation Date`)


# Make dates uniform
#print("Converting dates to uniform format...")
current_install <- current_install %>%
  mutate(last_installation_date = as.Date(last_installation_date),  # Convert to Date object
         last_installation_date  = format(last_installation_date , "%m/%d/%Y"))  # Format in desired MDY format

current_install$last_installation_date <- mdy(current_install$last_installation_date)


current_install <- current_install %>%
  rename(village = Village)

current_install <- current_install %>%
  rename(Date = last_installation_date)


current_install$Ins_status <- "last_installation_date"


class(df.stored$Date)
class(df.vil.cl$Date)
class(initial_install$Date)
class(current_install$Date)



#APPEND INITIAL_INSTALL AND 
# Make sure column names are the same in both datasets

# Select only the desired columns from initial_install
initial_install_subset <- initial_install %>%
  select(Date, village, Ins_status)

# Select only the desired columns from current_install
current_install_subset <- current_install %>%
  select(Date, village, Ins_status)

# Merge the two datasets by row-wise binding
Installation_df <- bind_rows(initial_install_subset, current_install_subset, .id = "installation_status")

View(Installation_df)

print(Installation_df)




#_______________________________________________________________________________
#STORED WATER with installation dates 
#_______________________________________________________________________________



plot_list_stored <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  
  df.vil.cl <- df.stored %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  min_plot_date <- min(min(df.vil.cl$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(df.vil.cl$Date), max(unique_install_dates)) + days(5)
  
  # Create plot with adjustments
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = "blue" # Example color
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = "red" # Example color
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = "green" # Example color
    ) +
    labs(title = "Concentration of Chlorine", x = "Date", y = "") +
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 5), # Reduce legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "horizontal",       # Arrange legends horizontally
      legend.spacing.x = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = c(1, 1),       # Position legends at the top
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10)
    ) +
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan")) + # Use distinct colors
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) + # Abbreviate Test labels
    ggtitle(paste0('Stored water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(p)
  plot_list_stored[[i]] <- p
}

print("Plots generated for all villages.")



#_______________________________________________________________________________
#TAP WATER with installation dates 
#_______________________________________________________________________________

plot_list_stored <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  
  df.vil.cl <- df.tap %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  min_plot_date <- min(min(df.vil.cl$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(df.vil.cl$Date), max(unique_install_dates)) + days(5)
  
  # Create plot with adjustments
  p <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
    geom_line(linewidth = 0.8) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = "blue" # Example color
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = "red" # Example color
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = "green" # Example color
    ) +
    labs(title = "Concentration of Chlorine", x = "Date", y = "") +
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 5), # Reduce legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "horizontal",       # Arrange legends horizontally
      legend.spacing.x = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = c(1, 1),       # Position legends at the top
      legend.justification = c("right", "top"),
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10)
    ) +
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan")) + # Use distinct colors
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) + # Abbreviate Test labels
    ggtitle(paste0('Tap water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(p)
  plot_list_stored[[i]] <- p
}

print("Plots generated for all villages.")





#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________


library(ggplot2)

# Remove NA values from the dataset
df.stored <- na.omit(df.stored)

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.stored, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Stored water chlorine concentration",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5)) +  # Adjust legend margin
  scale_fill_hue() +  # Set fill color
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)





#BOXPLOTS TAP WATER

library(ggplot2)

# Remove NA values from the dataset
df.tap <- na.omit(df.tap)

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.tap, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Tap water chlorine concentration",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5)) +  # Adjust legend margin
  scale_fill_hue() +  # Set fill color
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)


#_______________________________________________________________________________
#Ridges plot STORED WATER 
#_______________________________________________________________________________

#------------------------------NEAREST----------------------------#

library(ggridges)

df.stored.nearest <- df.stored %>% filter(Distance== "Nearest")

# Remove NA values from the dataset
df.stored.nearest <- na.omit(df.stored.nearest)

# Create a ridgeline plot
ridgeline_plot <- ggplot(df.stored.nearest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Nearest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot)


#------------------------------FARTHEST----------------------------#

df.stored.farthest <- df.stored %>% filter(Distance== "Farthest")

# Remove NA values from the dataset
df.stored.farthest <- na.omit(df.stored.farthest)

# Create a ridgeline plot
ridgeline_plot <- ggplot(df.stored.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Farthest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot)


#_______________________________________________________________________________
#Ridges plot TAP WATER
#_______________________________________________________________________________


#------------------------------NEAREST----------------------------#

# Remove NA values from the dataset
df.tap.nearest <- df.tap %>% filter(Distance== "Nearest")

df.tap.nearest <- na.omit(df.tap.nearest)

# Create a ridgeline plot
ridgeline_plot <- ggplot(df.tap.nearest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Nearest Tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot)



#------------------------------FARTHEST----------------------------#

df.tap.farthest <- df.tap %>% filter(Distance== "Farthest")

# Remove NA values from the dataset
df.tap.farthest  <- na.omit(df.tap.farthest)

# Create separate ridgeline plots for "nearest" and "farthest"
ridgeline_plot <- ggplot(df.tap.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Farthest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  facet_wrap(~ Distance)

# Print the ridgeline plot
print(ridgeline_plot)






























#------------------------------------------------------------------------------------------
#----------------------- WORK IN PROGRESS (KINDLY IGNORE) ----------------------------------
#-------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------




#_______________________________________________________________________________
#CHLORINE STATISTICS
#_______________________________________________________________________________


#Classify it by stored and running water 


#------------------------------------------------------------------------------
#STORED WATER
#--------------------------------------------------------------------------------

df.stored$Date <- mdy(df.stored$Date)

# Append datasets while preserving all columns

appended_df <- full_join(df.stored, Installation_df, by = c("Date", "village"))

View(appended_df)


#checking if village names are unique 
print(unique(appended_df$village))


result <- appended_df %>%
  group_by(village, Date) %>%
  summarize(
    out_of_range_low = any(chlorine_concentration < 0.2, na.rm = TRUE),  # Exclude NA values from any()
    out_of_range_high = any(chlorine_concentration > 0.5, na.rm = TRUE),  # Exclude NA values from any()
    out_of_range = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  # Exclude NA values from any()
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low = sum(out_of_range_low, na.rm = TRUE),  # Exclude NA values from sum()
    days_out_of_range_high = sum(out_of_range_high, na.rm = TRUE),  # Exclude NA values from sum()
    days_out_of_range = sum(out_of_range, na.rm = TRUE)  # Exclude NA values from sum()
  )


#######################################################################



# View the result
print(result)

#Finding NAs for Gopi kankubadi 

# Filter the data for the village 'Gopi Kankubadi'
gopi_data <- chlorine %>% filter(village == "Gopi Kankubadi")

# Find missing values (NAs) in the column 'chlorine_concentration' for 'Gopi Kankubadi'
missing_values <- is.na(gopi_data$chlorine_concentration)

# Print the indices of missing values
print(which(missing_values))


library(ggplot2)

# Assuming you have a dataframe called result with columns village, days_out_of_range_low, and days_out_of_range_high

# Define colors for the bars
colors <- c("#FF5733", "#33FF57")  # You can change these colors as needed

# Create a bar plot
ggplot(result, aes(x = village)) +
  geom_bar(aes(y = days_out_of_range_low, fill = "Days < 0.2"), stat = "identity", alpha = 0.8, width = 0.4, na.rm = TRUE) +
  geom_bar(aes(y = days_out_of_range_high, fill = "Days > 0.5"), stat = "identity", alpha = 0.8, width = 0.4, na.rm = TRUE) +
  labs(title = "Number of Days with Chlorine Readings",
       x = "Village",
       y = "Number of Days") +
  scale_fill_manual(values = colors, guide = guide_legend(title = "Chlorine Concentration")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "top",
        legend.title = element_blank(),
        legend.box.background = element_rect(color = "black")) +
  coord_flip()

# Export the result dataframe into a CSV file
write.csv(result, "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/result_table.csv", row.names = FALSE)


# Create a lookup table for installation dates
installation_dates <- data.frame(
  village = c("Nathma", "Birnarayanpur", "Gopi Kankubadi", "Badabangi", "Bichikote", "Tandipur", "Karnapadu", "Asada", "Mukundpur", "Naira"),
  installation_date = as.Date(c("11/22/2023", "11/24/2023", "11/28/2023", "12/27/2023", "12/25/2023", "12/23/2023", "1/11/2024", "1/10/2024", "1/13/2024", "1/18/2024"), format = "%m/%d/%Y")
)

View(installation_dates)

# Merge the installation_dates lookup table with the chlorine dataframe
chlorine_with_installation_date <- merge(chlorine, installation_dates, by = "village", all.x = TRUE)

# View the result
print(chlorine_with_installation_date)

View(chlorine_with_installation_date)


# Calculate the number of days between installation date and reading date
chlorine_with_installation_date$days_since_installation <- as.numeric(chlorine_with_installation_date$Date - chlorine_with_installation_date$installation_date)

# Identify unique dates where the reading was not in the range (0.2-0.5) for each village
unique_dates_out_of_range <- chlorine_with_installation_date %>%
  filter(chlorine_concentration < 0.2 | chlorine_concentration > 0.5) %>%
  distinct(village, Date)

# Count the number of unique dates for each village when the reading was not in the range
count_unique_dates <- unique_dates_out_of_range %>%
  group_by(village) %>%
  summarize(days_out_of_range = sum(!is.na(Date)))

# Count the total number of visits (unique dates) for each village
total_visits_per_village <- chlorine_with_installation_date %>%
  group_by(village) %>%
  summarize(total_visits = n_distinct(Date, na.rm = TRUE))

# Group by village and find the maximum number of days
max_days_per_village <- chlorine_with_installation_date %>%
  group_by(village) %>%
  summarize(max_days_since_installation = max(days_since_installation, na.rm = TRUE))

# Merge the count of unique dates, total number of visits, and the maximum number of days per village
merged_data <- merge(count_unique_dates, total_visits_per_village, by = "village", all.x = TRUE)
merged_data <- merge(merged_data, max_days_per_village, by = "village", all.x = TRUE)

# Calculate the percentage of days when the reading was not in the range for each village
merged_data <- merged_data %>%
  mutate(percentage_out_of_range = days_out_of_range / max_days_since_installation * 100)

# Print the result
print(merged_data)
View(merged_data)

# Merge the chlorine_with_installation_datelookup table with the merged_data
chlorine_with_installation_date <- merge(chlorine_with_installation_date, merged_data, by = "village", all.x = TRUE)

#GRAPHS

library(ggplot2)
install.packages("cowplot")
library(cowplot)
#cowplot- It provides functions and themes for combining multiple plots into a single layout, allowing users to customize the appearance and arrangement of the plots.


# Create separate line plots for each variable
plot_days_out_of_range <- ggplot(merged_data, aes(x = village, y = days_out_of_range, group = 1)) +
  geom_line(color = "red", size = 1.5) +
  labs(y = "Days Out of Range",
       title = "Days Out of Range vs. Village") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

plot_max_days <- ggplot(merged_data, aes(x = village, y = max_days_since_installation, group = 1)) +
  geom_line(color = "blue", size = 1.5) +
  labs(y = "Max Days Since Installation",
       title = "Max Days Since Installation vs. Village") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

plot_percentage_out_of_range <- ggplot(merged_data, aes(x = village, y = percentage_out_of_range, group = 1)) +
  geom_line(color = "green", linetype = "dotted", size = 1.5) +
  labs(y = "Percentage Out of Range",
       title = "Percentage Out of Range vs. Village") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print the line plots
print(plot_days_out_of_range)
print(plot_max_days)
print(plot_percentage_out_of_range)



#------------------------ Other out of range stats ----------------------------------------#

###VILLAGE WISE GRPAHS

# Assuming you have a dataframe called chlorine with columns village, Date, and chlorine_concentration

# Filter the data for chlorine concentrations less than 0.2 or 0.5
filtered_data <- chlorine %>%
  filter(chlorine_concentration < 0.2 | chlorine_concentration > 0.5)

# Abbreviate village names
filtered_data$village_abbr <- substr(filtered_data$village, 1, 4)

# Group the data by village abbreviation and date, and calculate mean or median chlorine concentration
summary_data <- filtered_data %>%
  group_by(village_abbr, Date) %>%
  summarize(avg_chlorine_concentration = mean(chlorine_concentration))

# Define a custom color palette with highly distinguished colors
custom_palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999", "#000000")

# Plot the trend lines for each village with custom colors and adjusted label size
plot <- ggplot(summary_data, aes(x = Date, y = avg_chlorine_concentration, group = village_abbr, color = village_abbr)) +
  geom_line() +
  labs(title = "Trend of Chlorine Concentration for Chlorine < 0.2 or > 0.5",
       x = "Date",
       y = "Average Chlorine Concentration") +
  theme_minimal() +
  theme(legend.position = "top",
        axis.text.x = element_text(size = 6),  # Adjust label size for x-axis
        axis.text.y = element_text(size = 6),  # Adjust label size for y-axis
        plot.title = element_text(size = 8),  # Adjust title size
        legend.text = element_text(size = 6)) +  # Adjust legend text size
  scale_color_manual(values = custom_palette)  # Apply custom color palette

# Print the plot
print(plot)

#CHLORINE CONCENTRATION BETWEEN 0.2-0.5


library(dplyr)
library(ggplot2)


# Assuming you have a dataframe called chlorine with columns village, Date, and chlorine_concentration

# Filter the data for chlorine concentrations in the range of 0.2-0.5
filtered_data <- chlorine %>%
  filter(chlorine_concentration >= 0.2 & chlorine_concentration <= 0.5)

# Group the filtered data by village and unique date, and count the number of unique dates
days_in_range <- filtered_data %>%
  group_by(village, Date) %>%
  summarize() %>%
  group_by(village) %>%
  summarize(days_in_range = n_distinct(Date))

# Plot the number of days for each village where chlorine concentration was in the range of 0.2-0.5
plot <- ggplot(days_in_range, aes(x = village, y = days_in_range)) +
  geom_bar(stat = "identity", fill = "blue") +  # Bar plot
  labs(title = "No. of Days with Chlorine Conct. in the Range of 0.2-0.5",
       x = "Village",
       y = "Number of Days") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),  # Adjust label size for x-axis
        axis.text.y = element_text(size = 8),  # Adjust label size for y-axis
        plot.title = element_text(size = 10))  # Adjust title size

# Print the plot
print(plot)



#TO-DO :

#relevant start date for each village this comparison
#separately for running and stored water 
#better event recording (record it better whenever we talk to PO regarding issues)
#do event reporting (they closed the device) record the date when the device was closed or open 
#% of the tests that we had the correct dose (do this for running and stored)
#differentiate our J-PAL tests and GV tests
#community participation 
#Day-wise response protocol 
#prioritise free chlorine testing especially running water 
#using tap water as a denominator 
#classify it test wise 
#nearest-farther classification
#start with villages and do it for every village 
#add multiple lines on the graph itself 
#make it a diff color 
#vertical lines on the days of installation 
#take Jeremy's tracker 
#chunks for each village and start appending things for each vilage (include vertical lines)
#create a folder on box
#village wise priority graphs


                         

