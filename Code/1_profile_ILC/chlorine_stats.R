

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
install.packages("patchwork")
install.packages("cowplot")




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
library(patchwork)
library(cowplot)


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


# Convert 'all Dates columns back to deafult date  column to POSIXct format
df.daily.cl$SubmissionDate <- mdy_hms(df.daily.cl$SubmissionDate)

df.daily.cl$SubmissionDate <- format(df.daily.cl$SubmissionDate, "%m/%d/%Y, %I:%M:%S %p")

df.daily.cl$starttime <- mdy_hms(df.daily.cl$starttime)

df.daily.cl$starttime <- format(df.daily.cl$starttime, "%m/%d/%Y, %I:%M:%S %p")

df.daily.cl$endtime <- mdy_hms(df.daily.cl$endtime)

df.daily.cl$endtime <- format(df.daily.cl$endtime, "%m/%d/%Y, %I:%M:%S %p")


View(df.super)
View(df.daily.cl)
class(df.daily.cl$endtime)
class(df.super$endtime)


#extracting dates out of submission date
df.daily.cl$SubmissionDate <- substr(df.daily.cl$SubmissionDate, 1, regexpr(",", df.daily.cl$SubmissionDate) - 1)
# Parse the dates from both data frames to Date objects
df.daily.cl$SubmissionDate <- mdy(df.daily.cl$SubmissionDate)
# Format the dates back to character in the desired format (mm/dd/yyyy)
df.daily.cl$SubmissionDate <- format(df.daily.cl$SubmissionDate, "%m/%d/%Y")

#extracting dates out of  starttime
df.daily.cl$starttime <- substr(df.daily.cl$starttime, 1, regexpr(",", df.daily.cl$starttime) - 1)
# Parse the dates from both data frames to Date objects
df.daily.cl$starttime <- mdy(df.daily.cl$starttime)
# Format the dates back to character in the desired format (mm/dd/yyyy)
df.daily.cl$starttime <- format(df.daily.cl$starttime, "%m/%d/%Y")

#extracting dates out of  endtime
df.daily.cl$endtime <- substr(df.daily.cl$endtime , 1, regexpr(",", df.daily.cl$endtime) - 1)
# Parse the dates from both data frames to Date objects
df.daily.cl$endtime  <- mdy(df.daily.cl$endtime)
# Format the dates back to character in the desired format (mm/dd/yyyy)
df.daily.cl$endtime  <- format(df.daily.cl$endtime , "%m/%d/%Y")



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
df_recent$SubmissionDate <- mdy(df_recent$SubmissionDate)
df_recent$SubmissionDate <- format(df_recent$SubmissionDate, "%m/%d/%Y")
#extracting dates out of starttime
df_recent$starttime <- substr(df_recent$starttime, 1, regexpr(",", df_recent$starttime) - 1)
df_recent$starttime <- mdy(df_recent$starttime)
df_recent$starttime <- format(df_recent$starttime, "%m/%d/%Y")
#extracting dates out of endtime
df_recent$endtime <- substr(df_recent$endtime, 1, regexpr(",", df_recent$endtime) - 1)
df_recent$endtime <- mdy(df_recent$endtime)
df_recent$endtime <- format(df_recent$endtime, "%m/%d/%Y")


class(df_recent$SubmissionDate)
class(df.daily.cl$SubmissionDate)

#Appending the datasets

# Get common column names between df.daily.cl and df_recent
common_column_names <- intersect(names(df.daily.cl), names(df_recent))
print(common_column_names)

# Subset df_recent to include only the common column names
df_recent_subset <- df_recent[, common_column_names]

# Append the datasets
combined_df <- rbind(df.daily.cl[, common_column_names], df_recent_subset)

View(combined_df)


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

View(duplicates)

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


View(df.temp)

# Count the number of surveys in each village
village_surveys <-  df.temp %>%
  group_by(village_name) %>%
  summarise(Total_Surveys = n()) # 'n()' counts the number of rows in each group

# View the result
print(village_surveys)


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


df.stored <- df.stored %>%
  mutate(Test = ifelse(Test == "Stored Water: Free Chlorine", "Free_Chlorine_stored", Test))
df.stored <- df.stored %>%
  mutate(Test = ifelse(Test == "Stored Water: Total Chlorine", "Total_Chlorine_stored", Test))
df.tap <- df.tap %>%
  mutate(Test = ifelse(Test == "Tap Water: Free Chlorine", "Free_Chlorine_tap", Test))
df.tap <- df.tap %>%
  mutate(Test = ifelse(Test == "Tap Water: Total Chlorine", "Total_Chlorine_tap", Test))


# STORED WATER 
#Orginial plot

plot_list_stored <- list()

for (i in village_list) {
  df.vil.cl <- df.stored %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  s <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  
  print(s)
  plot_list_stored[[i]] <- s
}

# STORED WATER 
#new plot with scatter plot type graph 

plot_list_stored <- list()

for (i in village_list) {
  df.vil.cl <- df.stored %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  su <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +  # Scatter plot with points
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +  # Adjust date_breaks to 5 days
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.position = c(1, 1),  # Adjust legend position
      legend.box = "horizontal",  
      legend.justification = c("right", "top"),
      legend.box.just = "top",
      legend.margin = margin(6, 6, 6, 6),  # Increase right margin
      legend.title = element_text(size = 8),  # Reduce legend title size
      legend.text = element_text(size = 8),  # Reduce legend text size
      axis.text.x = element_text(angle = 90, size = 10)
    ) + 
    scale_color_brewer(palette = "Dark2") + 
    ggtitle(paste0('Stored water: Village_', i))
  
  print(su)
  plot_list_stored[[i]] <- su
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = su, device = 'png', width = 10, height = 6)

}



#TAP WATER
#Original plot 

plot_list_tap <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  t <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  
  print(t)
  plot_list_tap[[i]] <- t
}


#TAP WATER 
#new plot with scatter plot type graph 

plot_list_tap <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  tu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +  # Scatter plot with points
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +  # Adjust date_breaks to 5 days
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.position = c(1, 1),  # Adjust legend position
      legend.box = "horizontal",  
      legend.justification = c("right", "top"),
      legend.box.just = "top",
      legend.margin = margin(6, 6, 6, 6),  # Increase right margin
      legend.title = element_text(size = 8),  # Reduce legend title size
      legend.text = element_text(size = 8),  # Reduce legend text size
      axis.text.x = element_text(angle = 90, size = 10)
    ) + 
    scale_color_brewer(palette = "Dark2") + 
    ggtitle(paste0('Tap Water: Village_', i))
  
  print(tu)
  plot_list_tap[[i]] <- tu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = tu, device = 'png', width = 10, height = 6)
  
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


print("Generating plots for each village...")
View(Master_tracker)

#-----------------STORED WATER WITH MODIFICATIONS-------------------------------#

#Orginial plot 
plot_list_stored <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  df.vil.cl <- df.stored %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  smu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  print(smu)
  plot_list_stored[[i]] <- smu
}

print("Plots generated for all villages.")



#Scatter plot 

plot_list_stored <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  df.vil.cl <- df.stored %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  ssmu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    geom_vline(data = Master_tracker, aes(xintercept = Date, color = modification), linetype = "solid") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
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
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan"), name = "Dis & Modif") +  # Rename the legend box for "Distance"
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) +  # Abbreviate Test labels
    ggtitle(paste0('Stored water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(ssmu)
  plot_list_stored[[i]] <- ssmu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Modif_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = ssmu, device = 'png', width = 10, height = 6)
  
}

print("Plots generated for all villages.")


#-----------------TAP WATER WITH MODIFICATIONS-------------------------------#

#Orginal plot 

plot_list_tap <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% filter(village == i) 
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  tm <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  print(tm)
  plot_list_tap[[i]] <- tm
}
print("Plots generated for all villages.")

#Scatter plot 

plot_list_tap <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  df.vil.cl <- df.tap %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  stmu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    geom_vline(data = Master_tracker, aes(xintercept = Date, color = modification), linetype = "solid") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
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
    scale_color_manual(values = c("orange", "magenta", "red", "blue", "cyan"), name = "Dis & Modif") +  # Rename the legend box for "Distance"
    scale_linetype_discrete(labels = c("TC" = "TC", "FC" = "FC")) +  # Abbreviate Test labels
    ggtitle(paste0('Tap: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(stmu)
  plot_list_tap[[i]] <- stmu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Modif_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = stmu, device = 'png', width = 10, height = 6)
  
}

print("Plots generated for all villages.")



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

#original plot 

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
  si <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  print(si)
  plot_list_stored[[i]] <- si
}

print("Plots generated for all villages.")


#scatter plot


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
  
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  # Find the first and last installation dates specifically
  first_installation_date <- installations %>% 
    filter(Ins_status == "first_installation_date") %>% 
    summarize(min_date = min(Date)) %>% 
    .$min_date
  
  last_installation_date <- installations %>% 
    filter(Ins_status == "last_installation_date") %>% 
    summarize(max_date = max(Date)) %>% 
    .$max_date
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  min_plot_date <- min(min(df.vil.cl$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(df.vil.cl$Date), max(unique_install_dates)) + days(5)
  
  # Create plot with adjustments
  siu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
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
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = "blue") +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = "red") +
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
  print(siu)
  plot_list_stored[[i]] <- siu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Install_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = siu, device = 'png', width = 10, height = 6)
  
}

print("Plots generated for all villages.")


#_______________________________________________________________________________
#TAP WATER with installation dates 
#_______________________________________________________________________________


#original plot

plot_list_tap <- list()

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
  t <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, linetype = Test)) +
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
  print(t)
  plot_list_tap[[i]] <- t
}

print("Plots generated for all villages.")


#scatter plot 

plot_list_tap <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  
  df.vil.cl <- df.tap %>% filter(village == i)
  
  # Parse Date variable
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  min_plot_date <- min(min(df.vil.cl$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(df.vil.cl$Date), max(unique_install_dates)) + days(5)
  
  # Find the first and last installation dates specifically
  first_installation_date <- installations %>% 
    filter(Ins_status == "first_installation_date") %>% 
    summarize(min_date = min(Date)) %>% 
    .$min_date
  
  last_installation_date <- installations %>% 
    filter(Ins_status == "last_installation_date") %>% 
    summarize(max_date = max(Date)) %>% 
    .$max_date
  
  # Create plot with adjustments
  tiu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
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
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = "blue") +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = "red") +
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
    ggtitle(paste0('Tap: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(tiu)
  plot_list_tap[[i]] <- tiu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Install_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = tiu, device = 'png', width = 10, height = 6)
  
}

print("Plots generated for all villages.")



#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________

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
file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Boxplots_Villages",".png")

# Now, save the plot to the specified path
ggsave(file_path, plot = boxplot_all_villages, device = 'png', width = 10, height = 6, bg = "white")




#_______________________________________________________________________________
#BOXPLOTS TAP WATER
#_______________________________________________________________________________

# Remove NA values from the dataset
df.tap <- na.omit(df.tap)

# Create boxplot with fill color and remove NA values
boxplot_all_villages_T <- ggplot(df.tap, aes(x = village, y = chlorine_concentration, fill = village)) +
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
print(boxplot_all_villages_T)
file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Boxplots_Villages",".png")

# Now, save the plot to the specified path
ggsave(file_path, plot = boxplot_all_villages_T, device = 'png', width = 10, height = 6, bg = "white")


#_______________________________________________________________________________
#Ridges plot STORED WATER 
#_______________________________________________________________________________

#------------------------------NEAREST----------------------------#

library(ggridges)

df.stored.nearest <- df.stored %>% filter(Distance== "Nearest")

# Remove NA values from the dataset
df.stored.nearest <- na.omit(df.stored.nearest)

# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.stored.nearest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Nearest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot_nearest)


#------------------------------FARTHEST----------------------------#

df.stored.farthest <- df.stored %>% filter(Distance== "Farthest")

# Remove NA values from the dataset
df.stored.farthest <- na.omit(df.stored.farthest)

# Create a ridgeline plot
ridgeline_plot_farthest <- ggplot(df.stored.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Farthest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot_farthest)

# Combine the two ridgeline plots into a single plot
combined_plot_ridges <- ridgeline_plot_nearest + ridgeline_plot_farthest

# Print the combined plot
print(combined_plot_ridges)

file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Ridge_Village.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = combined_plot_ridges, device = 'png', width = 15, height = 7)


#_______________________________________________________________________________
#Ridges plot TAP WATER
#_______________________________________________________________________________


#------------------------------NEAREST----------------------------#

# Remove NA values from the dataset
df.tap.nearest <- df.tap %>% filter(Distance== "Nearest")

df.tap.nearest <- na.omit(df.tap.nearest)

# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.tap.nearest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Nearest Tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal()

# Print the ridgeline plot
print(ridgeline_plot_nearest)



#------------------------------FARTHEST----------------------------#

df.tap.farthest <- df.tap %>% filter(Distance== "Farthest")

# Remove NA values from the dataset
df.tap.farthest  <- na.omit(df.tap.farthest)

# Create separate ridgeline plots for "nearest" and "farthest"
ridgeline_plot_farthest <- ggplot(df.tap.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges() +
  labs(title = "Farthest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  facet_wrap(~ Distance)

# Print the ridgeline plot
print(ridgeline_plot_farthest)

# Combine the two ridgeline plots into a single plot
combined_plot_ridges_T <- ridgeline_plot_nearest + ridgeline_plot_farthest

# Print the combined plot
print(combined_plot_ridges_T)

file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Ridge_Village.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = combined_plot_ridges_T, device = 'png', width = 15, height = 7)


#--------------------------------------------------------------------------------------------------#
#------------------------IMPORTING GRAM VIKAS DATASET (work in progress)----------------------------------------------#
#--------------------------------------------------------------------------------------------------#


# Import an Excel file using the global_working_directory variable
Gram_vikas_data <- read_excel(file.path(global_working_directory, "India ILC_Gram Vikas Chlorine Monitoring.xlsx"))
View(Gram_vikas_data)

Gram_vikas_data <- Gram_vikas_data %>%
  select(-c(
    `Flow control valve setting`,
    `Dosing control valve setting`,
    `Third valve setting (if needed)`,
    `Time Outlet Valve Opened`,
    `Sample 1 Time`,
    `Sample 2 Time`,
    `Sample 3 Time`,
    `Sample 4 Time`,
    `Sample 5 Time`,
    `Sample 6 Time`,
    `Sample 7 Time`,
    `Sample 8 Time`,
    `Sample 9 Time`,
    `Sample 10 Time`,
    `Sample 11 Time`,
    `Sample 12 Time`,
     Comment,
    `Sample 1 Comment`,
    `Sample 2 Comment`,
    `Sample 3 Comment`,
    `Sample 4 Comment`,
    `Sample 5 Comment`,
    `Sample 6 Comment`,
    `Sample 7 Comment`, 
    `Sample 8 Comment`,
    `Sample 9 Comment`,
    `Sample 10 Comment`,
    `Sample 11 Comment`,
    `Sample 12 Comment`
  ))


print(unique(Gram_vikas_data$Village))
print(unique(df.stored$village))

Gram_vikas_data$Village <- tolower(trimws(Gram_vikas_data$Village))

print("Replacing specific village name...")
Gram_vikas_data$Village <- gsub("b n pur", "birnarayanpur", Gram_vikas_data$Village)
Gram_vikas_data$Village <- gsub("bada bangi", "badabangi", Gram_vikas_data$Village)
Gram_vikas_data$Village <- gsub("mukundapur", "mukundpur", Gram_vikas_data$Village)

renamed_data <- Gram_vikas_data %>%
  rename(
    `Sp 1 - Location` = `Sample 1 - Location`,
    `Sp 2 - Location` = `Sample 2 - Location`,
    `Sp 3 - Location` = `Sample 3 - Location`,
    `Sp 4 - Location` = `Sample 4 - Location`,
    `Sp 5 - Location` = `Sample 5 - Location`,
    `Sp 6 - Location` = `Sample 6 - Location`,
    `Sp 7 - Location` = `Sample 7 - Location`,
    `Sp 8 - Location` = `Sample 8 - Location`,
    `Sp 9 - Location` = `Sample 9 - Location`,
    `Sp 10 - Location` = `Sample 10 - Location`,
    `Sp 11 - Location` = `Sample 11 - Location`,
    `Sp 12 - Location` = `Sample 12 - Location`
  )

reshaped_GV.df <- renamed_data%>%
  pivot_longer(cols = c(`Sample 1 - Free Chlorine (mg/L)`, `Sample 1 - Total Chlorine (mg/L)`,
                        `Sample 2 - Free Chlorine (mg/L)`,`Sample 2 - Total Chlorine (mg/L)`,
                        `Sample 3 - Free Chlorine (mg/L)`, `Sample 3 - Total Chlorine (mg/L)`,
                        `Sample 4 - Free Chlorine (mg/L)`, `Sample 4 - Total Chlorine (mg/L)`,
                        `Sample 5 - Free Chlorine (mg/L)`, `Sample 5 - Total Chlorine (mg/L)`,
                        `Sample 6 - Free Chlorine (mg/L)`, `Sample 6 - Total Chlorine (mg/L)`,
                        `Sample 7 - Free Chlorine (mg/L)`, `Sample 7 - Total Chlorine (mg/L)`, 
                        `Sample 8 - Free Chlorine (mg/L)`,`Sample 8 - Total Chlorine (mg/L)`, 
                        `Sample 9 - Free Chlorine (mg/L)`, `Sample 9 - Total Chlorine (mg/L)`, 
                        `Sample 10 - Free Chlorine (mg/L)`, `Sample 10 - Total Chlorine (mg/L)`,
                        `Sample 11 - Free Chlorine (mg/L)`, `Sample 11 - Total Chlorine (mg/L)`,
                        `Sample 12 - Free Chlorine (mg/L)`, `Sample 12 - Total Chlorine (mg/L)`), values_to = "chlorine_concentration", names_to = "chlorine_test_type")%>%
  pivot_longer(cols = c(`Sp 1 - Location`,
                        `Sp 2 - Location`,
                        `Sp 3 - Location`,
                        `Sp 4 - Location`,
                        `Sp 5 - Location`,
                        `Sp 6 - Location`,
                        `Sp 7 - Location`,
                        `Sp 8 - Location`,
                        `Sp 9 - Location`,
                        `Sp 10 - Location`,
                        `Sp 11 - Location`,
                        `Sp 12 - Location`), values_to = "Distance", names_to = "location")

View(reshaped_GV.df)


reshaped_GV.df <- reshaped_GV.df %>%
  mutate(final_test_type = str_extract(chlorine_test_type, "(Free|Total) Chlorine"))


View(chlorine)
chlorine.updated <- chlorine %>%
  mutate(chlorine_test_type = str_extract(chlorine_test_type, "(fc|tc)"))
View(chlorine.updated)

chlorine.updated <- chlorine.updated %>%
  mutate(chlorine_test_type = case_when(
    chlorine_test_type == "fc" ~ "Free Chlorine",
    chlorine_test_type == "tc" ~ "Total Chlorine",
    TRUE ~ chlorine_test_type  # Keep other values unchanged
  ))


chlorine.updated <- chlorine.updated %>%
  rename(chlorine_test = chlorine_test_type)


reshaped_GV.df <- reshaped_GV.df %>%
  rename(village = Village)

reshaped_GV.df <- reshaped_GV.df %>%
  rename(chlorine_test = final_test_type)


print(unique(chlorine$Distance))

reshaped_GV.df$Distance<- gsub("Nearest tap", "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last Tap", "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap — both valves to 12 oclock" , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest tap — 12 oclock dosing valve change" , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest tap" , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Farthest Tap"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("last tap"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Tap"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water in Nearest Tap"  , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("nearest tap"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Nearest Tap"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Farthest"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Test"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water - Nearest Tap"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest — 12 oclock dosing valve change"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Mid-way Tap"   , "Middle", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Middle Tap"   , "Middle", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Near"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("middle Tap"    , "Middle", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Fathest Tap"   , "Farthest", reshaped_GV.df$Distance)

print(unique(reshaped_GV.df$Distance))


# Create the first scatter plot
plot3 <- ggplot(reshaped_GV.df, aes(x = village, y = chlorine_concentration, color = chlorine_test)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +  # Use geom_point for scatter plot
  scale_color_manual(values = c("blue", "red"), name = "Final Test Type") +  # Custom color scale
  labs(title = "Chlorine Concentration by Village (GV)",
       x = "Village",
       y = "Chlorine Concentration") +
  theme_minimal() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(size = 10, face = "bold", hjust = 0.5),
        axis.title = element_text(size = 8),
        axis.text.x = element_text(size = 8, angle = 45, hjust = 1),  # Rotate and align labels
        axis.text.y = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10))

# Create the second scatter plot
plot4 <- ggplot(chlorine.updated, aes(x = village, y = chlorine_concentration, color = chlorine_test)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +  # Use geom_point for scatter plot
  scale_color_manual(values = c("green", "magenta"), name = "Final Test Type") +  # Custom color scale
  labs(title = "Chlorine Concentration by Village (J-PAL)",
       x = "Village",
       y = "Chlorine Concentration") +
  theme_minimal() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(size = 10, face = "bold", hjust = 0.5),
        axis.title = element_text(size = 8),
        axis.text.x = element_text(size = 8, angle = 45, hjust = 1),  # Rotate and align labels
        axis.text.y = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10))

# Combine the plots
combined_plot <- plot_grid(plot3, plot4, nrow = 1)

# Print the combined plot
print(combined_plot)


graphs_directory <- "C:/Users/Archi Gupta/Box/Data/1_raw/New folder"


# Ensure the directory exists, and if not, create it
if (!dir.exists(graphs_directory)) {
  dir.create(graphs_directory, recursive = TRUE)
}

# Specify the full path for the output file
output_file_path <- file.path(graphs_directory, "combined_plot.png")

# Use ggsave to save the plot
ggsave(filename = output_file_path, plot = combined_plot, width = 15, height = 6, dpi = 300, bg = "white", pointsize = 12)


file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_JPAL_Village.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = combined_plot, device = 'png', width = 15, height = 7, bg = "white")




#Comparing 
#______________ TIME SERIES PLOTS FOR GV DATASET______________________#

print(unique(reshaped_GV.df$Date))


#we need to make these dates workable 

# List of values not in date format
non_date_values <- c("45268.0", "45269.0", "45270.0", "45271.0", "45272.0", "45285.0",
                     "45286.0", "45288.0", "45289.0", "45290.0", "45291.0", "45299.0",
                     "45300.0", "45302.0", "45303.0", "45304.0", "45305.0", "45308.0",
                     "45312.0", "45324.0", "45353.0", "45384.0", "45445.0", "45628.0")

# Convert reshaped_GV.df$Date to character to match non_date_values
reshaped_GV.df <- mutate(reshaped_GV.df, Date = as.character(Date))

# Create convert_date variable containing non-date values
reshaped_GV.df <- mutate(reshaped_GV.df, convert_date = ifelse(Date %in% non_date_values, Date, NA))


reshaped_GV.df$converted_date <- as.Date(as.numeric(reshaped_GV.df$convert_date), origin = "1899-12-30")


# Convert Date variable to Date format with specified format string
reshaped_GV.df$Date <- dmy(reshaped_GV.df$Date)

# Convert Date variable to "YMD" format
reshaped_GV.df$Date <- as.Date(reshaped_GV.df$Date)


reshaped_GV.df$Date <- ymd(reshaped_GV.df$Date)



# Assuming reshaped_GV.df is your data frame

# Combine Date and converted_date variables into final_date
reshaped_GV.df <- mutate(reshaped_GV.df, final_date = coalesce(converted_date, Date))

# If you no longer need the Date and converted_date columns, you can remove them
reshaped_GV.df <- select(reshaped_GV.df, -Date, -converted_date)
reshaped_GV.df <- select(reshaped_GV.df, -convert_date)


print(unique(reshaped_GV.df$final_date))


# Find the indices of rows with the dates to be replaced
indices_to_replace <- which(reshaped_GV.df$final_date %in% c("2024-03-02", "2024-04-02", "2024-06-02"))

# Replace the dates with the desired dates
reshaped_GV.df$final_date[indices_to_replace] <- c("2024-02-03", "2024-02-04", "2024-02-06")


# Assuming reshaped_GV.df is your data frame

# Filter rows where final_date is NA
na_final_date_rows <- reshaped_GV.df$final_date %in% NA
print(na_final_date_rows)

# Print values from Date and converted_date variables where final_date is NA
print(reshaped_GV.df$Date[na_final_date_rows])
print(reshaped_GV.df$converted_date[na_final_date_rows])

reshaped_GV.df <- reshaped_GV.df %>%
  rename(Date = final_date)

plot_list <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- reshaped_GV.df %>% filter(village == i)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  
  # Parse Date variable
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  # Find the first and last installation dates specifically
  first_installation_date <- installations %>% 
    filter(Ins_status == "first_installation_date") %>% 
    summarize(min_date = min(Date)) %>% 
    .$min_date
  
  last_installation_date <- installations %>% 
    filter(Ins_status == "last_installation_date") %>% 
    summarize(max_date = max(Date)) %>% 
    .$max_date
  
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  min_plot_date <- min(min(GV.df.com$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(GV.df.com$Date), max(unique_install_dates)) + days(5)
  
  # Create plot with adjustments
  GV <- ggplot(GV.df.com, aes(x = Date , y = chlorine_concentration, color = chlorine_test)) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.5), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.49, label = "Targeted Range", hjust = 1, size = 3) +
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
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = "blue") +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = "red") +
    labs(title = "Concentration of Chlorine", x = "Date", y = "") +
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '5 day', 
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
    ggtitle(paste0('Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(GV)
  plot_list[[i]] <- GV
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = GV, device = 'png', width = 10, height = 6)
  
}

print(GV)

print("Plots generated for all villages.")

#----------------------------------------------------------------------------#
#Combine village wise plots for GV and J-PAL
#----------------------------------------------------------------------------#




#_______________________________________________________________________________


#CHLORINE STATS
#Classify it by stored and running water 

#_______________________________________________________________________________

#------------------------------------------------------------------------------
#STORED WATER
#--------------------------------------------------------------------------------

#please run it only once. In second time R will make all dates NA
df.vil.cl <- df.stored 


# Append datasets while preserving all columns

appended_df_stored <- full_join(df.vil.cl, Installation_df, by = c("Date", "village"))

View(appended_df_stored )


#checking if village names are unique 
print(unique(appended_df_stored$village))


changed_df_stored <- appended_df_stored  %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_stored <- changed_df_stored %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])


View(changed_df_stored)

#_______________EXCLUDED DATES BEFORE CURRENT INSTALLATION DATE______________________#


result_stored_aftercurrent <- changed_df_stored %>%
  group_by(village, Date) %>%
  filter(Date > current_installation_status) %>%  # Exclude dates earlier than current_installation_date
  summarize(
    out_of_range_low = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_current = sum(out_of_range_low, na.rm = TRUE),  
    days_out_of_range_high_current = sum(out_of_range_high, na.rm = TRUE),  
    days_out_of_range_current = sum(out_of_range, na.rm = TRUE)  
  )


View(result_stored_aftercurrent)


#_______________ALL DATES______________________#


result_stored_all <- changed_df_stored %>%
  group_by(village, Date) %>%
  summarize(
    out_of_range_low_all = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high_all = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range_all = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_all = sum(out_of_range_low_all, na.rm = TRUE),  
    days_out_of_range_high_all = sum(out_of_range_high_all, na.rm = TRUE),  
    days_out_of_range_all = sum(out_of_range_all, na.rm = TRUE)  
  )


View(result_stored_all)



#merge two datastes by village

merged_result <- left_join(result_stored_all, result_stored_aftercurrent, by = "village")
View(merged_result)

merged_result <- merged_result %>%
  mutate(watertype = "Stored")
View(merged_result)


#-------------------------------------------------------------------------------#
# Plot for days_out_of_range_current
#-------------------------------------------------------------------------------#

plot_current <- ggplot(merged_result, aes(x = village, y = days_out_of_range_current)) +
  geom_point(color = "blue", size = 3) +  # Changed to scatter plot
  labs(title = "Days Out of Range (Current) Stored water",
       x = "Village",
       y = "Days Out of Range (Current)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

# Plot for days_out_of_range_all
plot_all <- ggplot(merged_result, aes(x = village, y = days_out_of_range_all)) +
  geom_point(color = "red", size = 3) +  # Changed to scatter plot
  labs(title = "Days Out of Range (All) Stored water",
       x = "Village",
       y = "Days Out of Range (All)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

# Combine the two plots
combined_plots <- plot_current + plot_all

# Display the combined plots
combined_plots




#------------------------------------------------------------------------------
#TAP WATER
#--------------------------------------------------------------------------------

df.vil.cl <- df.tap


# Append datasets while preserving all columns

appended_df_tap <- full_join(df.vil.cl, Installation_df, by = c("Date", "village"))

View(appended_df_tap )


#checking if village names are unique 
print(unique(appended_df_tap$village))


changed_df_tap <- appended_df_tap  %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_tap <- changed_df_tap %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])


View(changed_df_tap)

#_______________EXCLUDED DATES BEFORE CURRENT INSTALLATION DATE______________________#


result_tap_aftercurrent <- changed_df_tap %>%
  group_by(village, Date) %>%
  filter(Date > current_installation_status) %>%  # Exclude dates earlier than current_installation_date
  summarize(
    out_of_range_low = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_current = sum(out_of_range_low, na.rm = TRUE),  
    days_out_of_range_high_current = sum(out_of_range_high, na.rm = TRUE),  
    days_out_of_range_current = sum(out_of_range, na.rm = TRUE)  
  )


View(result_tap_aftercurrent)


#_______________ALL DATES______________________#


result_tap_all <- changed_df_tap %>%
  group_by(village, Date) %>%
  summarize(
    out_of_range_low_all = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high_all = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range_all = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_all = sum(out_of_range_low_all, na.rm = TRUE),  
    days_out_of_range_high_all = sum(out_of_range_high_all, na.rm = TRUE),  
    days_out_of_range_all = sum(out_of_range_all, na.rm = TRUE)  
  )


View(result_tap_all)



#merge two datastes by village

merged_result_tap <- left_join(result_tap_all, result_tap_aftercurrent, by = "village")
View(merged_result_tap)

merged_result_tap <- merged_result_tap %>%
  mutate(watertype = "Tap")


#plots

plot_current_tap <- ggplot(merged_result_tap, aes(x = village, y = days_out_of_range_current)) +
  geom_point(color = "magenta", size = 3) +  # Changed to scatter plot
  labs(title = "Days Out of Range (Current) Tap water",
       x = "Village",
       y = "Days Out of Range (Current)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

# Plot for days_out_of_range_all
plot_all_tap <- ggplot(merged_result_tap, aes(x = village, y = days_out_of_range_all)) +
  geom_point(color = "orange", size = 3) +  # Changed to scatter plot
  labs(title = "Days Out of Range (All) Tap water",
       x = "Village",
       y = "Days Out of Range (All)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

# Combine the two plots
combined_plots_tap <- plot_current_tap + plot_all_tap

# Display the combined plots
combined_plots_tap


appended_data_stats <- rbind(merged_result_tap, merged_result)
View(appended_data_stats)
appended_data_stats <- appended_data_stats %>%
  select(village, watertype, everything())

# Assuming labels is a vector containing the labels for each variable
labels <- c("Village", "Watertype", "Days_when_less_than_0.2ppm (All days)", "Days_when_more_than_0.5ppm (All days)", "Days_when_both_happened (All days)", "Days_when_less_than_0.2ppm (Only days after last installation)", "Days_when_more_than_0.5ppm (Only days after last installation)", "Days_when_both_happened (Only days after last installation)"  )  # Add labels for all variables

# Assign the labels to the existing column names of the dataset
names(appended_data_stats) <- labels

install.packages("openxlsx")
library(openxlsx)
# Define the file path for the Excel file
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Days_stats.xlsx"

# Write the DataFrame to an Excel file
write.xlsx(appended_data_stats, file_path)

formatted_kable_stats <- kbl(appended_data_stats)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Water Quality Test Results (Water Type) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")

file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/days_stats.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable_stats, file_path)



#------------------------------------------------------------------------------
#BOTH STORED AND TAP WATER
#--------------------------------------------------------------------------------


# Append datasets while preserving all columns

appended_df_both <- full_join(chlorine, Installation_df, by = c("Date", "village"))

View(appended_df_both)


#checking if village names are unique 
print(unique(appended_df_both$village))


changed_df_both <- appended_df_both  %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_both <- changed_df_both %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])


View(changed_df_both)

#_______________EXCLUDED DATES BEFORE CURRENT INSTALLATION DATE______________________#


result_both_aftercurrent <- changed_df_both %>%
  group_by(village, Date) %>%
  filter(Date > current_installation_status) %>%  # Exclude dates earlier than current_installation_date
  summarize(
    out_of_range_low = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_current = sum(out_of_range_low, na.rm = TRUE),  
    days_out_of_range_high_current = sum(out_of_range_high, na.rm = TRUE),  
    days_out_of_range_current = sum(out_of_range, na.rm = TRUE),
    total_unique_dates_current = n_distinct(Date) 
  )


View(result_both_aftercurrent)


#_______________ALL DATES______________________#


result_both_all <- changed_df_both %>%
  group_by(village, Date) %>%
  summarize(
    out_of_range_low_all = any(chlorine_concentration < 0.2, na.rm = TRUE),  
    out_of_range_high_all = any(chlorine_concentration > 0.5, na.rm = TRUE),  
    out_of_range_all = any(chlorine_concentration < 0.2 | chlorine_concentration > 0.5, na.rm = TRUE)  
  ) %>%
  group_by(village) %>%
  summarize(
    days_out_of_range_low_all = sum(out_of_range_low_all, na.rm = TRUE),  
    days_out_of_range_high_all = sum(out_of_range_high_all, na.rm = TRUE),  
    days_out_of_range_all = sum(out_of_range_all, na.rm = TRUE),
    total_unique_dates_all = n_distinct(Date) 
  )


View(result_both_all)



#merge two datastes by village

merged_result_both <- left_join(result_both_all, result_both_aftercurrent, by = "village")
View(merged_result_both)


#-------------------------------------------------------------------------------#
# Plot for days_out_of_range_current
#-------------------------------------------------------------------------------#

plot_current_both <- ggplot(merged_result_both, aes(x = village)) +
  geom_point(aes(y = days_out_of_range_current), color = "blue", size = 3) +  # Scatter plot for days_out_of_range_current
  geom_point(aes(y = total_unique_dates_current), color = "red", size = 3) +  # Scatter plot for total_unique_dates_current
  labs(title = "Days Out of Range after the last Installation date",
       x = "Village",
       y = "Days Out of Range (Current) / Total Unique Dates (Current)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

print(plot_current_both)
# Plot for days_out_of_range_all
plot_all_both <- ggplot(merged_result_both, aes(x = village, y = days_out_of_range_all)) +
  geom_point(color = "red", size = 3) +  # Changed to scatter plot
  labs(title = "Days Out of Range after the first installation date",
       x = "Village",
       y = "Days Out of Range (All)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 7),  # Adjust title size
        axis.title = element_text(size = 10))  # Adjust axis label size

# Combine the two plots
combined_plots_both <- plot_current_both + plot_all_both

# Display the combined plots
combined_plots_both



################_JEREMY'S CODE_#########################################


# Extract "Stored Water" and "Tap Water" using str_extract()
chlorine$WaterType <- str_extract(chlorine$Test, "Stored Water|Tap Water")
chlorine$Chlorine_type <- str_extract(chlorine$Test, "Total Chlorine|Free Chlorine")
chlorine_tc <- chlorine %>% filter(Chlorine_type == "Total Chlorine")
chlorine_fc <- chlorine %>% filter(Chlorine_type == "Free Chlorine")
View(chlorine_tc)
View(chlorine_fc)
View(chlorine)

all_stats <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Total Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )

all_stats_2 <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Free Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )


View(all_stats_2)
View(all_stats)


# Merge the datasets based on village, WaterType, and Number of Samples
merged_stats <- merge(all_stats, all_stats_2, by = c("village", "WaterType", "Number of Samples"), all = TRUE)

# View the merged dataset
View(merged_stats)


all_stats_2 <- chlorine %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )


all_stats_3 <- chlorine %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.1 mg/L after Jan 10th" = round(sum(chlorine_concentration > 0.1 & Date > as.Date("2024-01-10"), na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
     )


formatted_kable <- kbl(all_stats_3)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Water Quality Test Results (Water Type) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/all_stats_3.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)


all_stats_4 <- chlorine %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, Distance, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.1 mg/L after Jan 10th" = round(sum(chlorine_concentration > 0.1 & Date > as.Date("2024-01-10"), na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2)
    
    )


formatted_kable_2 <- kbl(all_stats_4)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Water Quality Test Results (Distance and Water Type) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")

file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/all_stats_4.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable_2, file_path)

























































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


                         

