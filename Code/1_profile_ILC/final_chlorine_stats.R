

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
install.packages("tools")
install.packages("plotrix")
install.packages("gg.gap")



library(plotrix)
library(gg.gap)
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
library(tools)



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
    overleaf = "C:/Users/Archi Gupta/Dropbox/Overleaf/"
  } 
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}




#------------------------ Load the data ----------------------------------------#
#everyone please set your paths here
global_working_directory <- "C:/Users/Archi Gupta/Box/Data/1_raw/"

# Set the working directory to the global variable
setwd(global_working_directory)

# Print a message to confirm the working directory
print(paste("Working directory set to:", global_working_directory))


df.daily.cl <- read.csv(paste0(user_path(),"Daily Chlorine Monitoring Form_WIDE.csv"))  
df.super <- read.csv(paste0(user_path(),"india_ilc_pilot_monitoring_WIDE.csv"))

View(df.daily.cl)

View(df.super)


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

# Check if there are any duplicate deviceid values
any(duplicated(df.super$deviceid))

#dropping training entry for tandipur by device id since devce id are unique
df.super <- subset(df.super, !(village_name == "30301" & deviceid == "865525051839421"))

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

names(df.daily.cl)

View(df.daily.cl)


df.daily.cl <- df.daily.cl %>%
  mutate(starttime = ifelse(village_name == "40401" & KEY == "uuid:77c48c7b-e213-476f-b272-2af0f15637eb" & starttime == "02/29/2024", "01/23/2024", starttime))

df.daily.cl <- df.daily.cl %>%
  mutate(HR_farthest_nearest_tap_fc = ifelse(village_name == "40401" & KEY == "uuid:a9616dc4-08ff-45e5-940d-47c801227600" & HR_farthest_nearest_tap_fc == "8.8", "0.25", HR_farthest_nearest_tap_fc))



# Renaming multiple variables at once for HR testing to include it in the graphs 

df.daily.cl <- df.daily.cl %>%
  rename(HR_nearest_stored_fc = HR_neareststored_tap_fc,
         HR_nearest_stored_tc = HR_neareststored_tap_tc,
         HR_farthest_tap_fc = HR_farthest_nearest_tap_fc,
         HR_farthest_stored_fc = HR_fartheststored_tap_fc,
         HR_farthest_stored_tc = HR_fartheststored_tap_tc)


#to check if its done or not
df.selected <- df.daily.cl %>% 
  select(starttime, village_name, KEY, starts_with("HR"))

View(df.selected)

View(df.daily.cl)
View(df_recent)

df_recent <- df_recent %>%
  rename(HR_nearest_stored_fc = HR_neareststored_tap_fc,
         HR_nearest_stored_tc = HR_neareststored_tap_tc,
         HR_farthest_tap_fc = HR_farthest_nearest_tap_fc,
         HR_farthest_stored_fc = HR_fartheststored_tap_fc,
         HR_farthest_stored_tc = HR_fartheststored_tap_tc)

df.selected <- df_recent %>% 
  select(starttime, village_name, KEY, starts_with("HR"))

View(df.selected)

# Get common column names between df.daily.cl and df_recent
common_column_names <- intersect(names(df.daily.cl), names(df_recent))
print(common_column_names)

# Subset df_recent to include only the common column names
df_recent_subset <- df_recent[, common_column_names]

# Append the datasets
appended_df <- rbind(df.daily.cl[, common_column_names], df_recent_subset)

View(appended_df)

df.selected <- appended_df %>% 
  select(starttime, village_name, KEY, starts_with("HR"))

View(df.selected)


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

View(google_sheet_data)

# Assuming `google_sheet_data` is your dataset

# Create a column named "KEY"
google_sheet_data$KEY <- NA

# Get common column names between df.daily.cl and df_recent
common_column_names <- intersect(names(appended_df), names(google_sheet_data))
print(common_column_names)

# Subset df_recent to include only the common column names
df_recent_subset <- google_sheet_data[, common_column_names]

# Append the datasets
final_appended_df <- rbind(appended_df[, common_column_names], df_recent_subset)

View(final_appended_df)


mini_dataset <- appended_df %>%
  select(starts_with("HR"), village_name, KEY)



# Merge datasets with all.x = TRUE to preserve unmatched rows from final_appended_df
final_final_dataset <- merge(final_appended_df, mini_dataset, by = c("village_name", "KEY"), all.x = TRUE)

# Select desired columns
df.selected <- final_final_dataset %>%
  select(starttime, village_name, KEY, starts_with("HR"))

View(df.selected)


View(final_final_dataset)


# Assign final_combined_df to df.temp
df.temp <- final_final_dataset


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


View(df.temp)

# Select columns starting with "HR"
hr_columns <- grep("^HR", names(df.temp), value = TRUE)

# Create an empty list to store unique values for each HR variable
unique_values_list <- list()

# Loop through each HR variable
for (hr_var in hr_columns) {
  # Get unique values for the current HR variable
  unique_values <- unique(df.temp[[hr_var]])
  # Store unique values in the list
  unique_values_list[[hr_var]] <- unique_values
}

# Print unique values for each HR variable
for (hr_var in hr_columns) {
  cat("Unique values for", hr_var, ":", unique_values_list[[hr_var]], "\n")
}


#Dropping all the HR vars where all values are NA 

# Select columns starting with "HR"
hr_columns <- grep("^HR", names(df.temp), value = TRUE)

# Calculate the number of NA values for each HR variable
na_counts <- colSums(is.na(df.temp[hr_columns]))

# Identify HR variables with all NA values
hr_to_drop <- names(na_counts[na_counts == nrow(df.temp)])

# Drop HR variables with all NA values from the dataset
df.temp <- df.temp[, !names(df.temp) %in% hr_to_drop]

# Now df.temp contains HR variables where not all values are NA


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

View(duplicates)

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


View(df.temp)

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



clone <- df.temp %>%
  mutate(starttime = mdy(starttime))  # Format in desired MDY format
View(clone)

# Find the first visit date for each village
first_visit_dates <- clone %>%
  group_by(village_name) %>%
  summarise(First_Visit_Date = min(starttime, na.rm = TRUE))

# View the result
print(first_visit_dates)

#list all var names
names(df.temp)
# Specify the variables of interest
variables_of_interest <- c("first_nearest_tap_fc", "second_nearest_tap_fc", "first_nearest_tap_tc", 
                           "second_nearest_tap_tc", "first_stored_water_fc", "second_stored_water_fc", 
                           "first_stored_water_tc", "second_stored_water_tc", "first_farthest_tap_fc", 
                           "second_farthest_tap_fc", "first_farthest_tap_tc", "second_farthest_tap_tc", 
                           "far_first_stored_water_fc", "far_second_stored_water_fc", 
                           "far_first_stored_water_tc", "far_second_stored_water_tc")

# Filter rows where any of the specified variables have missing values
missing_values <- df.temp[rowSums(is.na(df.temp[, variables_of_interest])) > 0, ]


View(missing_values)


# Displaying chlorine concentration for each village


df.temp.all <- df.temp %>%
  rowwise() %>%
  mutate(nearest_tap_fc = (first_nearest_tap_fc + second_nearest_tap_fc) / 2, 
         nearest_tap_tc = (first_nearest_tap_tc + second_nearest_tap_tc) / 2,
         nearest_stored_fc = (first_stored_water_fc + second_stored_water_fc) / 2,
         nearest_stored_tc = (first_stored_water_tc + second_stored_water_tc) / 2,
         farthest_tap_fc = (first_farthest_tap_fc + second_farthest_tap_fc) / 2,
         farthest_tap_tc = (first_farthest_tap_tc + second_farthest_tap_tc) / 2,
         farthest_stored_fc = (far_first_stored_water_fc + far_second_stored_water_fc) / 2,
         farthest_stored_tc = (far_first_stored_water_tc + far_second_stored_water_tc) / 2) %>%
  ungroup()


names(df.temp.all)
View(df.temp.all)
# Assuming chlorine dataset is named df.daily.cl

# Convert HR_farthest_tap_fc and HR_farthest_tap_tc from character to numeric
df.temp.all$HR_farthest_tap_fc <- as.numeric(df.temp.all$HR_farthest_tap_fc)
df.temp.all$HR_farthest_tap_tc <- as.numeric(df.temp.all$HR_farthest_tap_tc)

# Check if there are any non-numeric values in the converted variables
non_numeric_fc <- sum(!is.na(df.temp.all$HR_farthest_tap_fc) & !is.numeric(df.temp.all$HR_farthest_tap_fc))
non_numeric_tc <- sum(!is.na(df.temp.all$HR_farthest_tap_tc) & !is.numeric(df.temp.all$HR_farthest_tap_tc))

# Print number of non-numeric values found
cat("Non-numeric values in HR_farthest_tap_fc:", non_numeric_fc, "\n")
cat("Non-numeric values in HR_farthest_tap_tc:", non_numeric_tc, "\n")


View(df.temp.all)


chlorine <- df.temp.all%>%
  pivot_longer(cols = c(nearest_tap_fc, nearest_tap_tc, 
                        farthest_tap_fc,farthest_tap_tc, 
                        nearest_stored_fc, farthest_stored_fc, 
                        nearest_stored_tc, farthest_stored_tc, HR_farthest_tap_fc, HR_farthest_tap_tc ), values_to = "chlorine_concentration", names_to = "chlorine_test_type")



chlorine$chlorine_test_type <- ifelse(chlorine$chlorine_test_type == "HR_farthest_tap_fc", "farthest_tap_fc", chlorine$chlorine_test_type)
chlorine$chlorine_test_type <- ifelse(chlorine$chlorine_test_type == "HR_farthest_tap_tc", "farthest_tap_tc", chlorine$chlorine_test_type)

View(chlorine)

chlorine <- chlorine %>%
  rename(Date = starttime)


#chlorine <- chlorine %>% dplyr::select(village_name, chlorine_test_type, chlorine_concentration, Date )


chlorine <- chlorine %>% 
  dplyr::select(village_name, chlorine_test_type, chlorine_concentration, Date) 
#%>%mutate(chlorine_concentration = (chlorine_concentration, 2))


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



# Create a dataframe with NA values in chlorine_concentration
na_rows <- chlorine %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
chlorine <- chlorine %>%
  drop_na(chlorine_concentration)

View(chlorine)
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



names(chlorine)
# STORED WATER 


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
# Renaming columns
print("Renaming columns...")
Master_tracker <- Master_tracker %>%
  rename(village = Village) %>%
  rename(modification = `General event or modification?`)

unique(Master_tracker$village)
unique(df.temp$village_name)


print("Generating plots for each village...")
View(Master_tracker)



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


#--------------------------------------------------------------------------------------------------#
#------------------------IMPORTING GRAM VIKAS DATASET (work in progress)----------------------------------------------#
#--------------------------------------------------------------------------------------------------#

# Import an Excel file using the global_working_directory variable
Gram_vikas_data <- read_excel(file.path(global_working_directory, "India ILC_Gram Vikas Chlorine Monitoring (1).xlsx"))
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
Gram_vikas_data$Village <- gsub("gopikankubadi", "gopi kankubadi", Gram_vikas_data$Village)

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
print(unique(reshaped_GV.df$village))

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

reshaped_GV.df$Distance<- gsub("Nearest tap", "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last Tap", "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap — both valves to 12 oclock" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest tap — 12 oclock dosing valve change" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest tap" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Farthest Tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("last tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water in Nearest Tap"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("nearest tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Nearest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Farthest"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Test"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water - Nearest Tap"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest — 12 oclock dosing valve change"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Mid-way Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Middle Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Near"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("middle Tap"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Fathest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Sample"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Stored Water"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored water from previous day at first tap"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Farthest"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water in Nearest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stpred water  Farthest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored in Nearest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Tap — 12 oclock dosing valve change"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last TAp"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last tap"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored in Tap"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stpred water  Tap"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Tapp"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Tap stored water"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Tap"    , "Stored", reshaped_GV.df$Distance)

print(unique(reshaped_GV.df$Distance))






#Comparing 
#______________ TIME SERIES PLOTS FOR GV DATASET______________________#

print(unique(reshaped_GV.df$Date))
na_rows <- reshaped_GV.df %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
na_rows <- reshaped_GV.df %>%
  filter(is.na(Date))

na_rows <- reshaped_GV.df %>%
  filter(is.na(village))

na_rows <- reshaped_GV.df %>%
  filter(is.na(chlorine_test))

#dropping NA values
reshaped_GV.df <- reshaped_GV.df %>%
  drop_na(chlorine_concentration)

View(reshaped_GV.df)
class(reshaped_GV.df$Date)

df.new.GV <- reshaped_GV.df
df.new.GV$Date <- as.Date(df.new.GV$Date)
print(unique(df.new.GV$Date))
class(df.new.GV$Date)
class(df.new.GV$Date)
View(df.new.GV)

df.new.GV.free <- df.new.GV 

df.new.GV.free <- df.new.GV.free %>% filter(chlorine_test == "Free Chlorine")

View(df.new.GV.free)


View(df.new.GV)

df.new.GV.stored <- df.new.GV %>%
  filter(Distance == "Stored")
df.new.GV.tap <- df.new.GV %>%
  filter(Distance == "Tap")


###############################################################################

#_____________________GV - TAP WATER TIME SERIES____________________________#
###############################################################################


df.new.GV.LI <- df.new.GV.tap
df.new.GV.LI$village <- toTitleCase(df.new.GV.LI$village)
Installation_df$village <- toTitleCase(Installation_df$village)


View(Installation_df)
View(df.new.GV.LI)
# Append datasets while preserving all columns
appended_df_GV_LI <- full_join(df.new.GV.LI, Installation_df, by = c("Date", "village"))

View(Installation_df)
View(appended_df_GV_LI)

# Checking if village names are unique 
print(unique(appended_df_GV_LI$village))
print(unique(df.new.GV.LI$village))

changed_df_GV_LI <- appended_df_GV_LI %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_GV_LI <- changed_df_GV_LI %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_GV_LI)

changed_df_GV_after_LI_LI <- changed_df_GV_LI %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_GV_after_LI_LI$Date < changed_df_GV_after_LI_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_GV_after_LI_LI)


na_rows <- changed_df_GV_after_LI_LI %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_GV_after_LI_LI <- changed_df_GV_after_LI_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_GV_after_LI_LI)

View(changed_df_GV_after_LI_LI)


#changed_df_GV_after_LI_LI$village <- toTitleCase(changed_df_GV_after_LI_LI$village)
#Installation_df$village <- toTitleCase(Installation_df$village)

View(changed_df_GV_after_LI_LI)
View(Installation_df)
changed_df_GV_after_LI_LI.free <- changed_df_GV_after_LI_LI %>%
  filter(chlorine_test == "Free Chlorine")

#df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.free %>%
  #filter(chlorine_concentration <= 2)

#capitalising village names

df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.free 

df.new.GV.less <- changed_df_GV_after_LI_LI.free

View(df.new.GV.filtered.tap)

print(unique(df.new.GV.filtered.tap$village))

#________________________________________________________________________________#

############   FINAL PLOT  FREE CHLORINE  ####################################
#________________________________________________________________________________#

##including values till 2.5
# Your village variable


View(Installation_df)
View(df.new.GV.filtered.tap)
#in progress
GV_village_list <- unique( df.new.GV.filtered.tap$village) 
View(GV_village_list)

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

library(dplyr)
# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in GV_village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- df.new.GV.filtered.tap %>% filter(village == i)
  GV.df.com <- GV.df.com %>% arrange(Date)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  min_date <- min(GV.df.com$Date, na.rm = TRUE)
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  View(installations)
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  #min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  if(i == "Naira") {
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(20)
  }
  else {
    # For other villages, the min_plot_date is set as before
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  }
  max_plot_date <- max(GV.df.com$Date, na.rm = TRUE) + days(5)
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  gv.tap <- ggplot(GV.df.com , aes(x = Date, y = chlorine_concentration, color = chlorine_test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") + # Adjusted y-axis limit to 3
    annotate("text", x = max_plot_date, y = 0.18, label = "Ideal Range", hjust = 1, size = 3) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 3) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + # Increased y-axis limit to 3
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV plot for Tap Water: Village_', i)) +
    # Add footnote for villages with chlorine concentrations > 2.5
    if (any(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5)) {
      annotate("text", x = max(df.new.GV.less$Date[df.new.GV.less$village == i], na.rm = TRUE), y = 2.5, label = paste0("Note: ", sum(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
    }
  
  print(paste("Plot for village", i, "generated."))
  print(gv.tap)
  plot_list_tap[[i]] <- gv.tap
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Tap_Village_free", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv.tap, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")


#DO IT FOR TOTAL TOO
#________________________________________________________________________________#

############   FINAL PLOT  TOTAL CHLORINE  ####################################
#________________________________________________________________________________#

##including values till 2.5

View(changed_df_GV_after_LI_LI)
changed_df_GV_after_LI_LI.total <- changed_df_GV_after_LI_LI %>%
  filter(chlorine_test == "Total Chlorine")

#df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.free %>%
#filter(chlorine_concentration <= 2)

df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.total 

df.new.GV.less <- changed_df_GV_after_LI_LI.total

View(df.new.GV.filtered.tap)



#in progress
GV_village_list <- unique( df.new.GV.filtered.tap$village) 
View(GV_village_list)

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in GV_village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- df.new.GV.filtered.tap %>% filter(village == i)
  GV.df.com <- GV.df.com %>% arrange(Date)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  min_date <- min(GV.df.com$Date, na.rm = TRUE)
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  #min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  if(i == "Naira") {
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(20)
  }
  else {
    # For other villages, the min_plot_date is set as before
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  }
  max_plot_date <- max(GV.df.com$Date, na.rm = TRUE) + days(5)
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  gv.tap <- ggplot(GV.df.com , aes(x = Date, y = chlorine_concentration, color = chlorine_test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") + # Adjusted y-axis limit to 3
    annotate("text", x = max_plot_date, y = 0.18, label = "Ideal Range", hjust = 1, size = 3) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 3) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + # Increased y-axis limit to 3
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV plot for Tap Water: Village_', i)) +
    # Add footnote for villages with chlorine concentrations > 2.5
    if (any(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5)) {
      annotate("text", x = max(df.new.GV.less$Date[df.new.GV.less$village == i], na.rm = TRUE), y = 2.5, label = paste0("Note: ", sum(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
    }
  
  print(paste("Plot for village", i, "generated."))
  print(gv.tap)
  plot_list_tap[[i]] <- gv.tap
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Tap_Village_total", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv.tap, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")



#_____________________GV - STORED WATER TIME SERIES____________________________#
###############################################################################



df.new.GV.stored <- df.new.GV %>%
  filter(Distance == "Stored")


###############################################################################

#_____________________GV - stored WATER TIME SERIES____________________________#
###############################################################################


df.new.GV.LI <- df.new.GV.stored

df.new.GV.LI$village <- toTitleCase(df.new.GV.LI$village)

# Append datasets while preserving all columns
appended_df_GV_LI <- full_join(df.new.GV.LI, Installation_df, by = c("Date", "village"))

View(appended_df_GV_LI)

# Checking if village names are unique 
print(unique(appended_df_GV_LI$village))
print(unique(df.new.GV.LI$village))

changed_df_GV_LI <- appended_df_GV_LI %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_GV_LI <- changed_df_GV_LI %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_GV_LI)

changed_df_GV_after_LI_LI <- changed_df_GV_LI %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_GV_after_LI_LI$Date < changed_df_GV_after_LI_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_GV_after_LI_LI)


na_rows <- changed_df_GV_after_LI_LI %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_GV_after_LI_LI <- changed_df_GV_after_LI_LI %>%
  drop_na(chlorine_concentration)


View(changed_df_GV_after_LI_LI)
#Installation_df$village <- toTitleCase(Installation_df$village)

#View(Installation_df)
changed_df_GV_after_LI_LI.free <- changed_df_GV_after_LI_LI %>%
  filter(chlorine_test == "Free Chlorine")

#df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.free %>%
#filter(chlorine_concentration <= 2)
# Convert the first letter to uppercase

#capitalising village names

df.new.GV.filtered.stored <- changed_df_GV_after_LI_LI.free 

df.new.GV.less <- changed_df_GV_after_LI_LI.free

View(df.new.GV.filtered.stored)


#________________________________________________________________________________#

############   FINAL PLOT  FREE CHLORINE  ####################################
#________________________________________________________________________________#

##including values till 2.5
# Your village variable


View(Installation_df)
View(df.new.GV.filtered.stored)
#in progress
GV_village_list <- unique( df.new.GV.filtered.stored$village) 
View(GV_village_list)

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in GV_village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- df.new.GV.filtered.stored %>% filter(village == i)
  GV.df.com <- GV.df.com %>% arrange(Date)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  min_date <- min(GV.df.com$Date, na.rm = TRUE)
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  #min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  # Assuming 'village' is the column in 'GV' dataset where we are checking for "Naira"
  # Check if either "Naira" or "Tandipur" is present in the 'village' column
  if("Naira" %in% GV.df.com$village || "Tandipur" %in% GV.df.com$village || "Bichikote" %in% GV.df.com$village) {
    # This block executes if either "Naira" or "Tandipur" is found in the 'village' column
    if(i == "Naira" || i == "Tandipur" || i == "Bichikote") {
      # Special condition for "Naira" and "Tandipur"
      min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(50)
    } else {
      # For other villages, the min_plot_date is set as before
      min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
    }
  }
  else {
    # This block executes if neither "Naira" nor "Tandipur" is found in the 'village' column
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  }
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  
  # Define the village names of interest
  village_names <- c("Tandipur")
  

  # Loop through the village names
  for (village in village_names) {
    if (village %in% GV.df.com$village) {
      max_plot_date <- max(GV.df.com$Date[GV.df.com$village == village], na.rm = TRUE)
    
  } else {
    max_plot_date <- min(GV.df.com$Date, na.rm = TRUE) + days(10)
  } 
  }
  
  
  gv.stored <- ggplot(GV.df.com , aes(x = Date, y = chlorine_concentration, color = chlorine_test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") + # Adjusted y-axis limit to 3
    annotate("text", x = max_plot_date, y = 0.18, label = "Ideal Range", hjust = 1, size = 3) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 3) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Stored water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + # Increased y-axis limit to 3
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV plot for Stored Water: Village_', i)) 
    # Add footnote for villages with chlorine concentrations > 2.5
    if (any(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5)) {
      annotate("text", x = max(df.new.GV.less$Date[df.new.GV.less$village == i], na.rm = TRUE), y = 2.5, label = paste0("Note: ", sum(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
    }
  
  print(paste("Plot for village", i, "generated."))
  print(gv.stored)
  plot_list_tap[[i]] <- gv.stored
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Stored_Village_free", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv.stored, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")



##########################################################################

#___________________________-TOTAL CHLORINE STORED
#######################################################################

changed_df_GV_after_LI_LI.total <- changed_df_GV_after_LI_LI %>%
  filter(chlorine_test == "Total Chlorine")

#df.new.GV.filtered.tap <- changed_df_GV_after_LI_LI.free %>%
#filter(chlorine_concentration <= 2)
# Convert the first letter to uppercase

#capitalising village names

df.new.GV.filtered.stored <- changed_df_GV_after_LI_LI.total 

df.new.GV.less <- changed_df_GV_after_LI_LI.total

View(df.new.GV.filtered.stored)


#________________________________________________________________________________#

############   FINAL PLOT  total CHLORINE  ####################################
#________________________________________________________________________________#

##including values till 2.5
# Your village variable


View(Installation_df)
View(df.new.GV.filtered.stored)
#in progress
GV_village_list <- unique( df.new.GV.filtered.stored$village) 
View(GV_village_list)

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in GV_village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- df.new.GV.filtered.stored %>% filter(village == i)
  GV.df.com <- GV.df.com %>% arrange(Date)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  min_date <- min(GV.df.com$Date, na.rm = TRUE)
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  # Set x-axis limits based on the minimum and maximum dates in the combined data
  #min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  # Assuming 'village' is the column in 'GV' dataset where we are checking for "Naira"
  # Check if either "Naira" or "Tandipur" is present in the 'village' column
  if("Naira" %in% GV.df.com$village || "Tandipur" %in% GV.df.com$village || "Bichikote" %in% GV.df.com$village) {
    # This block executes if either "Naira" or "Tandipur" is found in the 'village' column
    if(i == "Naira" || i == "Tandipur" || i == "Bichikote") {
      # Special condition for "Naira" and "Tandipur"
      min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(50)
    } else {
      # For other villages, the min_plot_date is set as before
      min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
    }
  }
  else {
    # This block executes if neither "Naira" nor "Tandipur" is found in the 'village' column
    min_plot_date <- min(GV.df.com$Date, na.rm = TRUE) - days(10)
  }
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  gv.stored <- ggplot(GV.df.com , aes(x = Date, y = chlorine_concentration, color = chlorine_test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") + # Adjusted y-axis limit to 3
    annotate("text", x = max_plot_date, y = 0.18, label = "Ideal Range", hjust = 1, size = 3) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 3) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Stored water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + # Increased y-axis limit to 3
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV plot for Stored Water: Village_', i)) +
    # Add footnote for villages with chlorine concentrations > 2.5
    if (any(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5)) {
      annotate("text", x = max(df.new.GV.less$Date[df.new.GV.less$village == i], na.rm = TRUE), y = 2.5, label = paste0("Note: ", sum(df.new.GV.less$chlorine_concentration[df.new.GV.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
    }
  
  print(paste("Plot for village", i, "generated."))
  print(gv.stored)
  plot_list_tap[[i]] <- gv.stored
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Stored_Village_total", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv.stored, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")



#_______________________________________________________________________________#



#DATES ONLY AFTER THE CURRENT INSTALLATION



#_______________________________________________________________________________#


#For graphs
#For stats 


#_______________________________________________________________________________#

#------------------------------------------------------------------------------
#STORED WATER
#--------------------------------------------------------------------------------

#general graph
View(df.stored)

df.stored.edit <- df.stored 

# Make date usable
df.stored.edit$Date <- mdy(df.stored.edit$Date)

df.stored.edit$village <- toTitleCase(df.stored.edit$village)

village_list <- unique(df.stored.edit$village) 
View(village_list)


# Append datasets while preserving all columns
appended_df_stored <- full_join(df.stored.edit, Installation_df, by = c("Date", "village"))

View(appended_df_stored)

# Checking if village names are unique 
print(unique(appended_df_stored$village))

changed_df_stored <- appended_df_stored %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_stored <- changed_df_stored %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_stored)

df.stored.after_L <- changed_df_stored %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(df.stored.after_L$Date < df.stored.after_L$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(df.stored.after_L)


na_rows <- df.stored.after_L %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
df.stored.after_L <- df.stored.after_L %>%
  drop_na(chlorine_concentration)

View(df.stored.after_L)
class(df.stored.after_L$Date)
#NOW MAKE THE GRAPHS 


View(df.stored.after_L)

#######################################################################
#######################################################################
#JPAL.filtered.stored <- df.stored.after_L %>%
  #filter(chlorine_concentration <= 2.5)


JPAL.filtered.stored.free <-  df.stored.after_L %>%
  filter(Test == "Free_Chlorine_stored")

View(JPAL.filtered.stored.free)

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#_______________________________________________________________________________________________________________#


View(village_list)
#######################################################################

# FINAL COMMAND ( DO THE SMAE FOR TAP WATER) 
#########################################################################
plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  stored.AI <- JPAL.filtered.stored.free %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(stored.AI$Date[!is.na(stored.AI$chlorine_concentration)])
  max_date <- max(stored.AI$Date[!is.na(stored.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  min_plot_date <- min(stored.AI$Date, na.rm = TRUE) - days(15)
  max_plot_date <- max(stored.AI$Date, na.rm = TRUE) + days(10)
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  
  Stored_after_L <- ggplot(stored.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") +
    annotate("text", x = max_plot_date, y = 0.17, label = "Ideal Range", hjust = 1, size = 4) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 4) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Stored water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + 
    # Theme adjustments here
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 12),
      axis.text.y = element_text(size = 12),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette, name = "Distance") +
    scale_shape_manual(values = c(16, 17), name = "Distance") +
    ggtitle(paste0('Stored Water: Village_', i, '(Free Chlorine Concentration Post Installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  #if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    #Stored_after_L <- Stored_after_L +
      #annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  #}
  
  print(paste("Plot for village", i, "generated."))
  print(Stored_after_L)
  plot_list_tap[[i]] <- Stored_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Village_Free_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Stored_after_L, device = 'png', width = 10, height = 6, dpi = 300)
}

print("Plots generated for all villages.")

#------------------------------------------------------------------------------
#TAP WATER
#--------------------------------------------------------------------------------

#general graph



df.tap.edit <- df.tap 

# Make date usable
df.tap.edit$Date <- mdy(df.tap.edit$Date)

df.tap.edit$village <- toTitleCase(df.tap.edit$village)

village_list <- unique(df.tap.edit$village) 
View(village_list)


# Append datasets while preserving all columns
appended_df_tap <- full_join(df.tap.edit, Installation_df, by = c("Date", "village"))

View(appended_df_tap)

# Checking if village names are unique 
print(unique(appended_df_tap$village))

changed_df_tap <- appended_df_tap %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_tap <- changed_df_tap %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_tap)

df.tap.after_L <- changed_df_tap %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(df.tap.after_L$Date <= df.tap.after_L$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(df.tap.after_L)


na_rows <- df.tap.after_L %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
df.tap.after_L <- df.tap.after_L %>%
  drop_na(chlorine_concentration)


#NOW MAKE THE GRAPHS 

#___________________________________________________________________________#

df.tap.after_L.free <- df.tap.after_L %>%
  filter(Test == "Free_Chlorine_tap")

#JPAL.filtered.tap <- df.tap.after_L.free %>%
#filter(chlorine_concentration <= 2.5)

JPAL.filtered.tap <- df.tap.after_L.free 

View(JPAL.filtered.tap)


df.new.JPAL.less <- df.tap.after_L.free

# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#_______________________________________________________________________________________________________________#


###########        ORIGINAL COMMAND           ################################
# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.50), breaks = seq(0, 2.5, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) +
    ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    Tap_after_L <-  Tap_after_L +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  print(paste("Plot for village", i, "generated."))
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 6, dpi = 300)
}

print("Plots generated for all villages.")



#########################################################






dataset_below_or_equal_2 <- JPAL.filtered.tap %>% filter(chlorine_concentration <= 2)
dataset_above_2 <- JPAL.filtered.tap %>% filter(chlorine_concentration > 2)
y_spacing_factor <- 0.2

#_#_#_#_#
plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  Tap.AI <- dataset_below_or_equal_2 %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(Tap.AI$Date[!is.na(Tap.AI$chlorine_concentration)])
  max_date <- max(Tap.AI$Date[!is.na(Tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  # Filter Installation_df for relevant data
  installations <- Installation_df %>% filter(village == i)
  
  # Find the unique installation dates for this village
  unique_install_dates <- unique(installations$Date)
  
  min_plot_date <- min(Tap.AI$Date, na.rm = TRUE) - days(15)
  max_plot_date <- max(Tap.AI$Date, na.rm = TRUE) + days(10)
  
  last_installation_date <- max(installations$Date[installations$Ins_status == "last_installation_date"], na.rm = TRUE)
  
  
  Tap_after_L <- ggplot(Tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2.5, by = 0.1), linetype = "dotted", color = "gray") +
    annotate("text", x = max_plot_date, y = 0.17, label = "Ideal Range", hjust = 1, size = 4) +
    annotate("text", x = max_plot_date, y = 0.56, label = "Ideal Range", hjust = 1, size = 4) +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "3 days"), linetype = "dotted", color = "gray") +
    # Add geom_vline for the last installation date with annotation
    geom_vline(
      data = filter(installations, Ins_status == "last_installation_date"),
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    annotate(
      "text", x = last_installation_date, y = Inf, label = "Last Installation Date",
      hjust = 1.1, vjust = 1, angle = 90, color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2.5, by = 0.1)) + 
    # Theme adjustments here
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 12),
      axis.text.y = element_text(size = 12),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette, name = "Distance") +
    scale_shape_manual(values = c(16, 17), name = "Distance") +
    ggtitle(paste0('Tap Water: Village_', i, '(Free Chlorine Concentration Post Installation)'))
  
  tap_above_2 <- dataset_above_2 %>% filter(village == i) %>% arrange(desc(chlorine_concentration))  
  # Plotting points and labels for > 2
  if (nrow(tap_above_2) > 0) {
    # Calculate dynamic y-positions for each point above 2 to avoid overlap
    # Start y-positions at 2.1 and increment based on the spacing factor
    tap_above_2$plot_y <- 2.4 - seq(0, by = y_spacing_factor, length.out = nrow(tap_above_2))
    # Assuming your dataset is a data frame named df

    # Plotting points dynamically based on their calculated plot_y positions
    Tap_after_L <- Tap_after_L +
      geom_point(data = tap_above_2, aes(x = Date, y = plot_y, shape = 'Above 2', color = as.factor(Distance)), size = 3, alpha = 1) +
      geom_point(data = tap_above_2, aes(x = Date, y = plot_y, color = as.factor(Distance)), shape = 2, size = 4, stroke = 1.5) +  # Triangle shape with thicker outline and same color as points
      geom_text(data = tap_above_2, aes(x = Date, y = plot_y, label = paste("Actual:", round(chlorine_concentration, 1))), vjust = -1, hjust = -0.02, color = "darkgreen", alpha = 1) +
      scale_shape_manual(values = c('Above 2' = 2))   # Assigning a triangle shape for "Above 2"
      #guides(color = guide_legend(title = "Distance", override.aes = list(shape = NA, linetype = 1))) 
  }  
  
  
  # Add footnote for villages with chlorine concentrations > 2.5
  #if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
  #Stored_after_L <- Stored_after_L +
  #annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  #}
  
  print(paste("Plot for village", i, "generated."))
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_Free_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 6, dpi = 300)
}

print("Plots generated for all villages.")

































#GG.GAP plot 


# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.0), expand = c(0,0), breaks = seq(0, 2.0, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) 
  
  ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    Tap_after_L <-  Tap_after_L +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  print(paste("Plot for village", i, "generated."))
  # Apply gg.gap to the plot with all theme settings included
  Tap_after_L <- gg.gap(
    plot = Tap_after_L,
    segments = c(2, 2.01),
    ylim = c(0, 9),
    tick_width = c(0.1, 1))
  
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 10, dpi = 300)
}

print("Plots generated for all villages.")



#ALMOST FINAL
#_#----------------------------------------------------------------------------#

# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.5), expand = c(0,0), breaks = seq(0, 2.5, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) 
  
  ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    Tap_after_L <-  Tap_after_L +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
    
    # Apply gg.gap to the plot with all theme settings included
    gg.gap_plot <- gg.gap(
      plot = Tap_after_L,
      segments = c(2.5, 3.5),
      ylim = c(0, 9),
      tick_width = c(0.1, 1))
    
    print(gg.gap_plot)
    plot_list_tap[[i]] <- gg.gap_plot
    file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
    
    # Now, save the plot to the specified path
    ggsave(file_path, plot = gg.gap_plot, device = 'png', width = 10, height = 10, dpi = 300)
  } else {
    print(Tap_after_L)
    plot_list_tap[[i]] <- Tap_after_L
    file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
    
    # Now, save the plot to the specified path
    ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 10, dpi = 300)
  }
  
  print(paste("Plot for village", i, "generated."))
}

print("Plots generated for all villages.")


#------------------------------------------------------------------------------#

plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.0), expand = c(0,0), breaks = seq(0, 2.0, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) 
  
  ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    Tap_after_L <-  Tap_after_L +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  print(paste("Plot for village", i, "generated."))
  # Apply gg.gap to the plot with all theme settings included
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 10, dpi = 300)
}

print("Plots generated for all villages.")









plot_list_tap <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.0), breaks = seq(0, 2.0, by = 0.1))+
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) +
    ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)'))
  
  # Add footnote for villages with chlorine concentrations > 2.5
  
  print(paste("Plot for village", i, "generated."))
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 6, dpi = 300)
}

print("Plots generated for all villages.")


df.tap.after_L.free <- df.tap.after_L %>%
  filter(Test == "Free_Chlorine_tap")



library(plotrix)
View(JPAL.filtered.tap)
View(tap.AI)
from <- 2
to <- 8
JPAL.filtered.tap.F <- JPAL.filtered.tap %>% filter(village == "Naira")
gap.plot(JPAL.filtered.tap.F$Date, JPAL.filtered.tap.F$chlorine_concentration, gap=c(from,to), type="b", xlab="index", ylab="value")
axis.break(2, from, breakcol="snow", style="gap")
axis.break(2, from*(1+0.02), breakcol="black", style="slash")
axis.break(4, from*(1+0.02), breakcol="black", style="slash")
axis(2, at=from)



library(ggplot2)
library(dplyr)

library(plotrix)

# Assuming JPAL.filtered.tap.F is already filtered and exists
# and `from` and `to` are defined as in your question

# Create a simple plot
gap.plot(JPAL.filtered.tap.F$Date, JPAL.filtered.tap.F$chlorine_concentration, gap=c(from,to), type="b", 
         xlab="Date", ylab="Chlorine Concentration", 
         main="Chlorine Concentration in Naira Village")

# Add a legend
legend("topright", legend=c("Chlorine Concentration"), col="blue", pch=1, bty="n")

# Add a title
title(main="Chlorine Concentration Over Time")

# Add axis breaks and customize
axis.break(2, from, breakcol="snow", style="gap")
axis.break(2, from*(1+0.02), breakcol="black", style="slash")
axis.break(4, from*(1+0.02), breakcol="black", style="slash")
axis(2, at=from)

# Add background color

# Add gridlines

# Adjust margins if necessary
# You might need to play with the values to fit your plot
par(mar = c(5, 4, 4, 2) + 0.1)




library(plotrix)

# Create a line and point plot
gap.plot(JPAL.filtered.tap.F$Date, JPAL.filtered.tap.F$chlorine_concentration, gap=c(from,to), type="l", 
         xlab="Date", ylab="Chlorine Concentration", 
         main="Chlorine Concentration in Naira Village")

# Add points to the plot
points(JPAL.filtered.tap.F$Date, JPAL.filtered.tap.F$chlorine_concentration, pch=16, col="blue")

# Add a legend
legend("topright", legend=c("Chlorine Concentration"), col="blue", pch=16, bty="n")

# Add a title
title(main="Chlorine Concentration Over Time")

# Add axis breaks and customize
axis.break(2, from, breakcol="snow", style="gap")
axis.break(2, from*(1+0.02), breakcol="black", style="slash")
axis.break(4, from*(1+0.02), breakcol="black", style="slash")
axis(2, at=from)

# Add background color

#_______________________________________________________
## FACETS GRAPHS
#_________________________________________________________


# Load necessary library
library(plotrix)

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  tap.AI <- JPAL.filtered.tap %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  # Create plot with adjustments
  Tap_after_L <- ggplot(tap.AI , aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = scales::date_format("%b %d")) + # Set x-axis limits to only include dates with non-missing values
    scale_y_continuous(limits = c(0.00, 2.0), breaks = seq(0, 2.0, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8),
      legend.key.size = unit(0.5, "cm"),
      legend.box = "vertical",
      legend.spacing.y = unit(0.5, "cm"),
      legend.position = "right",
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"),
      panel.border = element_rect(color = "black", fill = NA),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color = "black")
    ) +
    scale_color_manual(values = colorblind_palette) +
    scale_shape_manual(values = c(16, 17)) +
    ggtitle(paste0('Tap Water: Village_', i, '(Only dates after the last installation)')) +
    facet_wrap(~ ifelse(chlorine_concentration > 2, "Above 2", "Below or Equal to 2"), scales = "free")
  
  # Add footnote for villages with chlorine concentrations > 2.5
  
  print(paste("Plot for village", i, "generated."))
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 6, dpi = 300)
}

print("Plots generated for all villages.")
# Optionally, you can further customize the appearance of the plot as needed


#___________________________________________________#


#____________________________________________________#


library(ggplot2)
library(dplyr)
library(scales)

# Assuming JPAL.filtered.tap is your dataset and village_list contains your list of villages
# Dividing the dataset
dataset_below_or_equal_2 <- JPAL.filtered.tap %>% filter(chlorine_concentration <= 2)
dataset_above_2 <- JPAL.filtered.tap %>% filter(chlorine_concentration > 2)
y_spacing_factor <- 0.2
plot_list_tap <- list()

for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter for current village with chlorine concentration <= 2
  tap.AI <- dataset_below_or_equal_2 %>% filter(village == i)
  
  # Get the maximum and minimum dates with non-missing values for the village
  min_date <- min(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  max_date <- max(tap.AI$Date[!is.na(tap.AI$chlorine_concentration)])
  
  print(paste("Generating plot for village:", i))
  
  # Create base plot
  Tap_after_L <- ggplot(tap.AI, aes(x = Date, y = chlorine_concentration, color = as.factor(Distance), group = as.factor(Distance))) +
    geom_line(linewidth = 1) + 
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") +
    scale_x_date(limits = c(min_date, max_date), date_breaks = '3 day', labels = date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.5, breaks = seq(0, 2.5, by = 0.1))) +
    theme_minimal() +
    scale_color_manual(values = colorblind_palette) # Define 'colorblind_palette' appropriately
  
  # Now filter for current village with chlorine concentration > 2
  tap_above_2 <- dataset_above_2 %>% filter(village == i) %>% arrange(desc(chlorine_concentration))  
  # Plotting points and labels for > 2
  if (nrow(tap_above_2) > 0) {
    # Calculate dynamic y-positions for each point above 2 to avoid overlap
    # Start y-positions at 2.1 and increment based on the spacing factor
    tap_above_2$plot_y <- 2.4 - seq(0, by = y_spacing_factor, length.out = nrow(tap_above_2))
    
    # Plotting points dynamically based on their calculated plot_y positions
    Tap_after_L <- Tap_after_L +
      geom_point(data = tap_above_2, aes(x = Date, y = plot_y, shape = 'Above 2', color = as.factor(Distance)), size = 3, alpha = 1) +
      geom_text(data = tap_above_2, aes(x = Date, y = plot_y, label = paste("Actual:",round(chlorine_concentration, 1))), vjust = -1, hjust = -0.02, color = "darkgreen", alpha = 1)+
      scale_shape_manual(values = c('Above 2' = 2))    #theme(legend.margin = margin(r = 20))
  }  
  print(paste("Plot for village", i, "generated."))
  print(Tap_after_L)
  plot_list_tap[[i]] <- Tap_after_L
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_L", i, ".png")
  
  # Save the plot
  ggsave(file_path, plot = Tap_after_L, device = 'png', width = 10, height = 6, dpi = 300, bg = "white")
}

print("Plots generated for all villages.")









# Define a function to set Y-axis limits based on chlorine concentration
# Simulate data with gaps
#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________


df.stored.free <- df.stored.after_L %>% filter(Test == "Free_Chlorine_stored")

View(df.stored.free)
install.packages("viridis")
library(viridis)  # Load viridis package for color palettes

# Generate color palette with enough colors for all unique villages
color_palette <- viridis_pal()(length(unique(df.stored.free$village)))

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.stored.free, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Stored water chlorine concentration for free chlorine (After the Last Installation Date)",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5),  # Adjust legend margin
        panel.border = element_rect(color = "black", fill = NA),  # Add outside boundary
        panel.grid.major = element_line(color = "gray", size = 0.5),  # Add gridlines
        axis.line = element_line(color = "black")) +  # Add axis lines
  scale_fill_manual(values = color_palette) +  # Set color palette
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)

# Save the plot
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Boxplots_Villages.png"
ggsave(file_path, plot = boxplot_all_villages, device = 'png', width = 10, height = 6, bg = "white")

#_______________________________________________________________________________
#BOXPLOTS TAP WATER
#_______________________________________________________________________________

# Generate color palette with enough colors for all unique villages

df.tap.free <- df.tap.after_L %>% filter(Test == "Free_Chlorine_tap")

color_palette <- viridis_pal()(length(unique(df.tap.free$village)))

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.tap.free, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Tap water chlorine concentration for free chlorine (After the Last Installation Date)",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5),  # Adjust legend margin
        panel.border = element_rect(color = "black", fill = NA),  # Add outside boundary
        panel.grid.major = element_line(color = "gray", size = 0.5),  # Add gridlines
        axis.line = element_line(color = "black")) +  # Add axis lines
  scale_fill_manual(values = color_palette) +  # Set color palette
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)

# Save the plot
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Boxplots_Villages.png"
ggsave(file_path, plot = boxplot_all_villages, device = 'png', width = 10, height = 6, bg = "white")



# Concatenate the data frames for stored water and tap water
df_combined <- rbind(df.stored.free, df.tap.free)

# Generate color palette with enough colors for all unique villages
color_palette <- viridis_pal()(length(unique(df_combined$village)))

# Create a combined boxplot for stored water and tap water
combined_boxplot <- ggplot(df_combined, aes(x = village, y = chlorine_concentration, fill = Test)) +
  geom_boxplot(position = position_dodge(width = 0.75)) +  # Dodge position to separate boxplots
  labs(title = "Chlorine concentration for free chlorine (After the Last Installation Date)",
       x = "Village",
       y = "Chlorine Concentration") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.position = "right",
        legend.box = "vertical",
        legend.margin = margin(t = 5),
        panel.border = element_rect(color = "black", fill = NA),
        panel.grid.major = element_line(color = "gray", size = 0.5),
        axis.line = element_line(color = "black")) +
  scale_fill_manual(values = color_palette, labels = c("Stored", "Tap")) +  # Set color palette and labels
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the combined boxplot
print(combined_boxplot)

# Save the plot
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Combined_Boxplots_Villages.png"
ggsave(file_path, plot = combined_boxplot, device = 'png', width = 10, height = 6, bg = "white")

#_______________________________________________________________________________
#Ridges plot STORED WATER 
#_______________________________________________________________________________

#------------------------------NEAREST----------------------------#


df.stored.nearest <- df.stored.after_L %>% filter(Distance== "Nearest")

View(df.stored.nearest)

# Rename values in the chlorine_test_type column
df.stored.nearest <- df.stored.nearest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "nearest_stored_fc" = "Free Chlorine",
                                     "nearest_stored_tc" = "Total Chlorine"))

# Remove NA values from the dataset

library(ggridges)
library(grid)


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.stored.nearest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.stored.filtered <- df.stored.nearest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.stored.filtered, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Nearest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, 
           label = if (length(villages_to_remove) > 0)
             paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", "))
           else "",
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_nearest)

#------------------------------FARTHEST----------------------------#

df.stored.farthest <- df.stored.after_L %>% filter(Distance== "Farthest")

View(df.stored.farthest)
library(ggridges)
library(grid)

# Rename values in the chlorine_test_type column
df.stored.farthest <- df.stored.farthest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "farthest_stored_fc" = "Free Chlorine",
                                     "farthest_stored_tc" = "Total Chlorine"))


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.stored.farthest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.stored.filtered.farthest <- df.stored.farthest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_farthest <- ggplot(df.stored.filtered.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Farthest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, 
           label = if (length(villages_to_remove) > 0)
             paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", "))
           else "",
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

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
df.tap.nearest <- df.tap.after_L %>% filter(Distance== "Nearest")



# Rename values in the chlorine_test_type column
df.tap.nearest <- df.tap.nearest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "nearest_tap_fc" = "Free Chlorine",
                                     "nearest_tap_tc" = "Total Chlorine"))

# Remove NA values from the dataset

library(ggridges)
library(grid)


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.tap.nearest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.tap.filtered <- df.tap.nearest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.tap.filtered, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Nearest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, 
           label = if (length(villages_to_remove) > 0)
             paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", "))
           else "",
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_nearest)

#------------------------------FARTHEST----------------------------#

df.tap.farthest <- df.tap.after_L %>% filter(Distance== "Farthest")

View(df.tap.farthest)
library(ggridges)
library(grid)

# Rename values in the chlorine_test_type column
df.tap.farthest <- df.tap.farthest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "farthest_tap_fc" = "Free Chlorine",
                                     "farthest_tap_tc" = "Total Chlorine"))


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.tap.farthest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.tap.filtered.farthest <- df.tap.farthest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_farthest <- ggplot(df.tap.filtered.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Farthest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, 
           label = if (length(villages_to_remove) > 0)
             paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", "))
           else "",
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_farthest)

# Combine the two ridgeline plots into a single plot
combined_plot_ridges <- ridgeline_plot_nearest + ridgeline_plot_farthest

# Print the combined plot
print(combined_plot_ridges)

file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Ridge_Village.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = combined_plot_ridges, device = 'png', width = 15, height = 7)


#----------------------------------------------------------------------------#
#Combine village wise plots for GV and J-PAL 
#----------------------------------------------------------------------------#

#GV dataset - df.new.GV.free
#J-pal- 


#________________________________________________________________________________#
##########      STORED WATER    ##########################################
#________________________________________________________________________________#

View(chlorine)

JPAL.stored <- df.stored 

# Make date usable
JPAL.stored$Date <- mdy(JPAL.stored$Date)

View(JPAL.stored)

# Append datasets while preserving all columns
JPAL_appended_stored <- full_join(JPAL.stored, Installation_df, by = c("Date", "village"))

View(JPAL_appended_stored)

# Checking if village names are unique 
print(unique(JPAL_appended_stored$village))

changed_df_JPAL_stored <- JPAL_appended_stored %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_JPAL_stored <- changed_df_JPAL_stored %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_JPAL_stored)

changed_df_JPAL_stored_after_LI <- changed_df_JPAL_stored %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_JPAL_stored_after_LI$Date < changed_df_JPAL_stored_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_JPAL_stored_after_LI)


na_rows <- changed_df_JPAL_stored_after_LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_JPAL_stored_after_LI <- changed_df_JPAL_stored_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_JPAL_stored_after_LI)

#check again for NA values
na_rows <- changed_df_JPAL_stored_after_LI%>%
  filter(is.na(chlorine_concentration))



#----------------------------------------------------------------------------
###EXCLUDE DATES BEFORE INSTALLATION FROM GV DATASET AS WELL 
#----------------------------------------------------------------------------


View(df.new.GV)
df.new.GV.AI <- df.new.GV 

# Append datasets while preserving all columns
appended_df_GV <- full_join(df.new.GV.AI, Installation_df, by = c("Date", "village"))

View(appended_df_GV)

# Checking if village names are unique 
print(unique(appended_df_GV$village))
print(unique(df.new.GV.AI$village))

changed_df_GV <- appended_df_GV %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_GV <- changed_df_GV %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_GV)

changed_df_GV_after_LI <- changed_df_GV %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_GV_after_LI$Date < changed_df_GV_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_GV_after_LI)


na_rows <- changed_df_GV_after_LI %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_GV_after_LI <- changed_df_GV_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_GV_after_LI)

View(changed_df_JPAL_stored_after_LI)

changed_df_JPAL_stored_after_LI$Test <- gsub("Free_Chlorine_stored"    , "Free Chlorine", changed_df_JPAL_stored_after_LI$Test)

changed_df_JPAL_stored_after_LI$Test <- gsub("Total_Chlorine_stored"    , "Total Chlorine", changed_df_JPAL_stored_after_LI$Test)


#We want only stored values from GV datastet

print(unique(changed_df_GV_after_LI$Distance))
changed_df_GV_after_LI.stored <- changed_df_GV_after_LI %>% filter(Distance == "Stored")

View(changed_df_GV_after_LI.stored)


#filter out free chlorine only from both

changed_df_GV_after_LI.stored.free <- changed_df_GV_after_LI.stored %>% filter(chlorine_test == "Free Chlorine")


View(changed_df_GV_after_LI.stored.free)



changed_df_JPAL_stored_after_LI.free <- changed_df_JPAL_stored_after_LI %>% filter(Test == "Free Chlorine")


View(changed_df_JPAL_stored_after_LI.free)



changed_df_GV_after_LI.stored.free$Organization <- "Gram Vikas"
changed_df_JPAL_stored_after_LI.free$Organization <- "J-PAL"
names(changed_df_GV_after_LI.stored.free)
names(changed_df_JPAL_stored_after_LI.free)

changed_df_GV_after_LI.stored.free <- rename(changed_df_GV_after_LI.stored.free, Test = chlorine_test)
# Get common column names

changed_df_GV_after_LI.stored.free <- select(changed_df_GV_after_LI.stored.free, -chlorine_test_type, -location)
changed_df_GV_after_LI.stored.free <- select(changed_df_GV_after_LI.stored.free, -installation_status, -Ins_status)
changed_df_GV_after_LI.stored.free <- rename(changed_df_GV_after_LI.stored.free, Source = Distance)


common_cols <- intersect(names(changed_df_GV_after_LI.stored.free), names(changed_df_JPAL_stored_after_LI.free))
print(common_cols)


# Append datasets using common columns
appended_data_GV_JPAL <- bind_rows(
  select(changed_df_GV_after_LI.stored.free, all_of(common_cols)),
  select(changed_df_JPAL_stored_after_LI.free, all_of(common_cols)),
  .id = "Dataset"
)

# View the appended data
View(appended_data_GV_JPAL)

na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(chlorine_concentration))

View(na_rows)

na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(Date))

View(na_rows)
print(unique(appended_data_GV_JPAL$village))
na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(village))


View(appended_data_GV_JPAL)
appended_data_GV_JPAL.F <- appended_data_GV_JPAL %>%
  filter(chlorine_concentration <= 2.5)

df.new.JPAL.less <- appended_data_GV_JPAL

# Define colorblind friendly colors

#______________________________________________________________________________#

#_______ WITH INSTALLATION DATES _____________________________________________#
#_______________________________________________________________________________#
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV <- appended_data_GV_JPAL.F %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV$Date, na.rm = TRUE)
  
  
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
  min_plot_date <- min(min(JPAL_GV$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(JPAL_GV$Date), max(unique_install_dates)) + days(5)
  
  
  gv_j <- ggplot(JPAL_GV, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Stored water: Village_', i  ,'(Only Dates after last installation)'))
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    gv_j <- gv_j +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j)
  plot_list_c[[i]] <- gv_j
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}


##################################################################

#______________________________________________________________________________#

#_______ WITHOUT INSTALLATION DATES _____________________________________________#
#_______________________________________________________________________________#

# Create a list to store plots
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV <- appended_data_GV_JPAL.F %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV$Date, na.rm = TRUE)
  min_date <- min(JPAL_GV$Date[!is.na(JPAL_GV$chlorine_concentration)])
  max_date <- max(JPAL_GV$Date[!is.na(JPAL_GV$chlorine_concentration)])
  
  
  
  print(paste("Generating plot for village:", i))
  
  
  gv_j <- ggplot(JPAL_GV, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_date, max_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Stored water: Village_', i  ,'(Only Dates after last installation)'))
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    gv_j <- gv_j +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j)
  plot_list_c[[i]] <- gv_j
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}


#######################################################################

# NOW DIVIDE COMBINED PLOT BY TAP 

########################################################################


#GV dataset (only free and tap)

View(chlorine)

JPAL.tap <- df.tap 

# Make date usable
JPAL.tap$Date <- mdy(JPAL.tap$Date)

View(JPAL.tap)

# Append datasets while preserving all columns
JPAL_appended_tap <- full_join(JPAL.tap, Installation_df, by = c("Date", "village"))

View(JPAL_appended_tap)

# Checking if village names are unique 
print(unique(JPAL_appended_tap$village))

changed_df_JPAL_tap <- JPAL_appended_tap %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_JPAL_tap <- changed_df_JPAL_tap %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_JPAL_tap)

changed_df_JPAL_tap_after_LI <- changed_df_JPAL_tap %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_JPAL_tap_after_LI$Date < changed_df_JPAL_tap_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_JPAL_tap_after_LI)


na_rows <- changed_df_JPAL_tap_after_LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_JPAL_tap_after_LI <- changed_df_JPAL_tap_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_JPAL_tap_after_LI)

#check again for NA values
na_rows <- changed_df_JPAL_tap_after_LI%>%
  filter(is.na(chlorine_concentration))



#----------------------------------------------------------------------------
###EXCLUDE DATES BEFORE INSTALLATION FROM GV DATASET AS WELL 
#----------------------------------------------------------------------------



changed_df_JPAL_tap_after_LI$Test <- gsub("Free_Chlorine_tap"    , "Free Chlorine", changed_df_JPAL_tap_after_LI$Test)

changed_df_JPAL_tap_after_LI$Test <- gsub("Total_Chlorine_tap"    , "Total Chlorine", changed_df_JPAL_tap_after_LI$Test)

View(changed_df_JPAL_tap_after_LI)

#We want only stored values from GV datastet

print(unique(changed_df_GV_after_LI$Distance))
changed_df_GV_after_LI.tap <- changed_df_GV_after_LI %>% filter(Distance == "Tap")

View(changed_df_GV_after_LI.tap)


#filter out free chlorine only from both

changed_df_GV_after_LI.tap.free <- changed_df_GV_after_LI.tap %>% filter(chlorine_test == "Free Chlorine")


View(changed_df_GV_after_LI.tap.free)



changed_df_JPAL_tap_after_LI.free <- changed_df_JPAL_tap_after_LI %>% filter(Test == "Free Chlorine")


View(changed_df_JPAL_tap_after_LI.free)



changed_df_GV_after_LI.tap.free$Organization <- "Gram Vikas"
changed_df_JPAL_tap_after_LI.free$Organization <- "J-PAL"
names(changed_df_GV_after_LI.tap.free)
names(changed_df_JPAL_tap_after_LI.free)

changed_df_GV_after_LI.tap.free <- rename(changed_df_GV_after_LI.tap.free, Test = chlorine_test)
# Get common column names

changed_df_GV_after_LI.tap.free <- select(changed_df_GV_after_LI.tap.free, -chlorine_test_type, -location)
changed_df_GV_after_LI.tap.free <- select(changed_df_GV_after_LI.tap.free, -installation_status, -Ins_status)
changed_df_GV_after_LI.tap.free <- rename(changed_df_GV_after_LI.tap.free, Source = Distance)


common_cols <- intersect(names(changed_df_GV_after_LI.tap.free), names(changed_df_JPAL_tap_after_LI.free))
print(common_cols)


# Append datasets using common columns
appended_data_GV_JPAL_tap <- bind_rows(
  select(changed_df_GV_after_LI.tap.free, all_of(common_cols)),
  select(changed_df_JPAL_tap_after_LI.free, all_of(common_cols)),
  .id = "Dataset"
)

# View the appended data
View(appended_data_GV_JPAL_tap)

na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(chlorine_concentration))

View(na_rows)

na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(Date))

View(na_rows)
print(unique(appended_data_GV_JPAL_tap$village))
na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(village))

View(appended_data_GV_JPAL_tap)
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV_tap <- appended_data_GV_JPAL_tap %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV_tap$Date, na.rm = TRUE)
  
  
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
  min_plot_date <- min(min(JPAL_GV_tap$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(JPAL_GV_tap$Date), max(unique_install_dates)) + days(5)
  
  
  gv_j_t <- ggplot(JPAL_GV_tap, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Tap water: Village_', i  ,'(Only Dates after last installation)'))
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j_t)
  plot_list_c[[i]] <- gv_j_t
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j_t, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

#______________________________________________________________________________#

#_______ TAP WITHOUT INSTALLATION DATES _____________________________________________#
#_______________________________________________________________________________#
appended_data_GV_JPAL.F <- appended_data_GV_JPAL_tap %>%
  filter(chlorine_concentration <= 2.5)

df.new.JPAL.less <- appended_data_GV_JPAL_tap

# Create a list to store plots
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV <- appended_data_GV_JPAL.F %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV$Date, na.rm = TRUE)
  min_date <- min(JPAL_GV$Date[!is.na(JPAL_GV$chlorine_concentration)])
  max_date <- max(JPAL_GV$Date[!is.na(JPAL_GV$chlorine_concentration)])
  
  
  
  print(paste("Generating plot for village:", i))
  
  
  gv_j <- ggplot(JPAL_GV, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_date, max_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.5), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Tap water: Village_', i  ,'(Only Dates after last installation)'))
  # Add footnote for villages with chlorine concentrations > 2.5
  if (any(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5)) {
    gv_j <- gv_j +
      annotate("text", x = max_date, y = 2.5, label = paste0("Note: ", sum(df.new.JPAL.less$chlorine_concentration[df.new.JPAL.less$village == i] > 2.5), " values > 2.5"), hjust = 1)
  }
  
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j)
  plot_list_c[[i]] <- gv_j
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}


#CHLORINE STATS
#Classify it by stored and running water 


################_JEREMY'S CODE_#########################################




chlorine.AI <- chlorine 

# Make date usable
chlorine.AI$Date <- mdy(chlorine.AI$Date)

View(chlorine.AI)

# Append datasets while preserving all columns
chlorine.AI.IS <- full_join(chlorine.AI, Installation_df, by = c("Date", "village"))

View(chlorine.AI.IS)

# Checking if village names are unique 
print(unique(chlorine.AI.IS$village))

chlorine.AI.final <- chlorine.AI.IS %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

chlorine.AI.final <- chlorine.AI.final %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(chlorine.AI.final)

chlorine.only.LI <- chlorine.AI.final %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(chlorine.only.LI$Date < chlorine.only.LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(chlorine.only.LI)


na_rows <- chlorine.only.LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)

chlorine.only.LI <- chlorine.only.LI %>%
  drop_na(chlorine_concentration)

# Extract "Stored Water" and "Tap Water" using str_extract()

#exclude dates after the last installation date for each village 
chlorine.only.LI$WaterType <- str_extract(chlorine.only.LI$Test, "Stored Water|Tap Water")
chlorine.only.LI$Chlorine_type <- str_extract(chlorine.only.LI$Test, "Total Chlorine|Free Chlorine")
chlorine_tc <- chlorine.only.LI %>% filter(Chlorine_type == "Total Chlorine")
chlorine_fc <- chlorine.only.LI %>% filter(Chlorine_type == "Free Chlorine")
View(chlorine_tc)
View(chlorine_fc)
View(chlorine.only.LI)

TC_stats <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Total Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )

FC_stats <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Free Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )




# Merge the datasets based on village, WaterType, and Number of Samples
merged_TC_FC <- merge(TC_stats, FC_stats, by = c("village", "WaterType", "Number of Samples"), all = TRUE)

# View the merged dataset
View(merged_TC_FC)

formatted_kable <- kbl(merged_TC_FC)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise average Chlorine Concentration (After the last installation) " = 5)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")

View(formatted_kable)

file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/merged_TC_FC.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)


#Only free chlorine 

FC_stats <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, WaterType) %>%
  summarize(
    "Number of Free Chlorine Samples" = n(),
    "Average Free chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(FC_stats)

formatted_kable <- kbl(FC_stats)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for free chlorine (After the last installation) " = 7)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/FC_stats.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)


#Only Total chlorine 


TC_stats <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, WaterType) %>%
  summarize(
    "Number of Total Chlorine Samples" = n(),
    "Average Total chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(TC_stats)

formatted_kable <- kbl(TC_stats)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for Total chlorine (After the last installation) " = 7)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/TC_stats.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)





#fREE CHLORINE (Distance too)


FC_stats_D <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, Distance, WaterType) %>%
  summarize(
    "Number of Free Chlorine Samples" = n(),
    "Average Free chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(FC_stats_D)

formatted_kable <- kbl(FC_stats_D)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for free chlorine categorised by Distance and water source (After the last installation) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/FC_stats_distance.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)




#TOTAL CHLORINE  DISTANCE WISE 

TC_stats_D <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, Distance, WaterType) %>%
  summarize(
    "Number of Total Chlorine Samples" = n(),
    "Average Total chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(TC_stats_D)

formatted_kable <- kbl(TC_stats_D)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for Total chlorine categorised by Distance and water source (After the last installation) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/TC_stats_distance.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)




# Load required libraries
library(ggplot2)

# Define colorblind-friendly palette
colorblind_palette <- c("#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create a heatmap
heatmap <- ggplot(FC_stats, aes(x = village, y = WaterType, fill = `Average Free chlorine Concentration (mg/L)`)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = colorblind_palette[1], high = colorblind_palette[6]) +  # Using colorblind-friendly colors
  labs(title = "Average Free Chlorine Concentration by Village and Water Type",
       x = "Village",
       y = "Water Type",
       fill = "Average Free Chlorine Concentration (mg/L)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, color = "black"),  # Adjust text properties
        axis.text.y = element_text(size = 12, color = "black"),  # Adjust text properties
        axis.title = element_text(size = 14, color = "black"),  # Adjust title properties
        legend.position = "right",  # Move legend to the right
        legend.title.align = 0.5,  # Center align legend title
        legend.text = element_text(size = 10, color = "black"),  # Increase legend text size and change color
        plot.title = element_text(size = 18, face = "bold", color = "black"),  # Increase title size, bold, and change color
        panel.grid = element_blank(),  # Remove gridlines for cleaner look
        panel.background = element_rect(fill = "white"))  # Set background color to white

# Print the heatmap
print(heatmap)


file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Heatmap.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = heatmap, device = 'png', width = 10, height = 6, bg= "white", dpi = 300) # Increased dpi for better resolution


print(unique(FC_stats$village))


install.packages("sf")
library(sf)
# Replace the path below with the path to your shapefile
shapefile_path <- "C:/Users/Archi Gupta/Downloads/Village Boundary Database/RAYAGARHA.shp"

# Read the shapefile
my_shapefile <- st_read(shapefile_path)

# Check the contents
plot(my_shapefile)


# Convert all village names to lowercase

my_shapefile$VILLAGE <- tolower(my_shapefile$VILLAGE)

# Install and load the stringdist package
install.packages("stringdist")
library(stringdist)



# Create an empty list to store matches
matched_villages <- list()

# Set the threshold for similarity
threshold <- 0.3  # Adjust as needed, lower values allow for more spelling variations

# Loop through each village name in chlorine.only.LI dataset
for (village_chlorine in FC_stats$village) {
  # Use stringdist to find closest match in selected_tehsil dataset
  closest_match <- stringdist::amatch(village_chlorine, my_shapefile$VILLAGE, method = "lv", maxDist = threshold * nchar(village_chlorine))
  
  # If a match is found, add it to the list
  if (!is.na(closest_match)) {
    matched_villages[[village_chlorine]] <- my_shapefile$VILLAGE[closest_match]
  }
}

# Print the matched villages
matched_villages



my_shapefile$VILLAGE <- gsub("bichkota"    , "bichikote", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("karnipadu"    , "karnapadu", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("gopikanhubadi"    , "gopi kankubadi", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("biranarayanpur"    , "birnarayanpur", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("mukundapur"    , "mukundpur", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("nathama"    , "nathma", my_shapefile$VILLAGE)


matched_villages <- list()

# Set the threshold for similarity
threshold <- 0.3  # Adjust as needed, lower values allow for more spelling variations

# Loop through each village name in chlorine.only.LI dataset
for (village_chlorine in FC_stats$village) {
  # Use stringdist to find closest match in selected_tehsil dataset
  closest_match <- stringdist::amatch(village_chlorine, my_shapefile$VILLAGE, method = "lv", maxDist = threshold * nchar(village_chlorine))
  
  # If a match is found, add it to the list
  if (!is.na(closest_match)) {
    matched_villages[[village_chlorine]] <- my_shapefile$VILLAGE[closest_match]
  }
}

# Print the matched villages
matched_villages

# Assuming df is your dataframe and "old_name" is the current column name you want to change
colnames(my_shapefile)[colnames(my_shapefile) == "VILLAGE"] <- "village"



# Create an empty data frame to store merged data
merged_data <- data.frame()

# Loop through each matched village
for (village_chlorine in names(matched_villages)) {
  # Get the matched village name from my_shapefile dataset
  matched_village_shapefile <- matched_villages[[village_chlorine]]
  
  # Subset data for the matched village from my_shapefile dataset
  village_data_shapefile <- my_shapefile[my_shapefile$village == matched_village_shapefile, ]
  
  # Subset data for the matched village from chlorine.only.LI dataset
  village_data_chlorine <- FC_stats[FC_stats$village == village_chlorine, ]
  
  # Merge the data for the matched village
  merged_data <- rbind(merged_data, merge(village_data_shapefile, village_data_chlorine, by = "village", all = TRUE))
}

# Print the merged data
View(merged_data)



print(unique(merged_data$village))


na_rows <- merged_data%>%
  filter(is.na(village))

View(na_rows)

merged_data<- merged_data %>%
  drop_na(village)

View(merged_data)

names(merged_data)
merged_data <- select(merged_data, -DISTRICT, -STATE)


# Load the required libraries
library(ggplot2)
library(sf)
install.packages("plotly")
library(plotly)

names(merged_data)

# Convert merged_data to sf object
merged_data_sf <- st_as_sf(merged_data)

# Extract unique villages from your dataset
unique_villages <- unique(merged_data$village)


#_______________________________________________________________________#

# STORED WATER FREE CHLORINE 
#________________________________________________________________________#

merged_data_S <- merged_data_sf %>% filter (WaterType == "Stored Water")

View(merged_data_S)
# Filter merged_data_sf to include only villages present in your dataset
merged_data_S <- merged_data_S[merged_data_S$village %in% unique_villages, ]

View(merged_data_S)

# Create the TEHSIL variable based on conditions
merged_data_S <- merged_data_S %>%
  mutate(TEHSIL = case_when(
    village == "asada" ~ "Gudari",
    village == "badabangi" ~ "Ramnagauda",
    village == "bichikote" ~ "Padmapur",
    village == "birnarayanpur" ~ "Rayagada",
    village == "gopi kankubadi" ~ "Kolnara",
    village == "karnapadu" ~ "Padmapur",
    village == "mukundpur" ~ "Kolnara",
    village == "naira" ~ "Padmapur",
    village == "nathma" ~ "Rayagada",
    village == "tandipur" ~ "Kolnara",
    TRUE ~ NA_character_ # This is for villages not specified in your list, assigns NA
  ))




# First, create a new column in 'merged_data_sf' that includes the text for the tooltip
merged_data_S$tooltip_text <- paste(
  "Village: ", merged_data_S$village,
  "<br>% Samples between 0.1 and 0.6 mg/L: ", merged_data_S$`% Samples between 0.1 and 0.6 mg/L`,
  "<br>% Samples above 0.1 mg/L: ", merged_data_S$`% Samples above 0.1 mg/L`, # Adjust the column name as per your dataset
  "<br>% Samples above 0.6 mg/L: ", merged_data_S$`% Samples above 0.6 mg/L`, # Adjust the column name as per your dataset
  "<br>Number of Free Chlorine Samples: ", merged_data_S$`Number of Free Chlorine Samples`, # Adjust the column name as per your dataset
  
  sep = ""
)

# Update the ggplot creation to use this new 'tooltip_text' column for the 'text' aesthetic
chloropleth_map_S <- ggplot() +
  geom_sf(data = merged_data_S, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = tooltip_text), color = "black", size = 0.5) +
  scale_fill_gradient(name = "% Samples above  0.1 and 0.6 mg/L", low = "#E69F00", high = "#56B4E9") + 
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine", caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")

# Convert the ggplot to a plotly object
# Specify 'tooltip' argument to 'text' to ensure custom tooltips are displayed
interactive_choropleth_S <- ggplotly(chloropleth_map_S, tooltip = "text", height = 600, width = 800)

# Print the interactive choropleth map
print(interactive_choropleth_S)


library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth_S <- ggplotly(
  chloropleth_map_S, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Choropleth_All_vars.html"



# Save the map with specified file path
saveWidget(interactive_choropleth_S, file = file_path)
#more vars




##############################################################
#google map
library(sf)
library(leaflet)

# Assuming merged_data_S is your spatial dataframe

# Transform the spatial data to WGS 84 (longitude and latitude)
merged_data_S <- st_transform(merged_data_S, crs = 4326)

# Then, create your interactive map with the transformed data
map <- leaflet(merged_data_S) %>%
  addProviderTiles(providers$OpenStreetMap) %>% # Add base map tiles
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              fillColor = ~colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`)(`% Samples above 0.1 mg/L`),
              fillOpacity = 0.5,
              popup = ~paste("Village:", village,
                             "<br>TEHSIL:", TEHSIL,
                             "<br>% Samples above 0.1 mg/L:", `% Samples above 0.1 mg/L`,
                             "<br>% Samples above 0.6 mg/L:", `% Samples above 0.6 mg/L`,
                             "<br>% Samples between 0.1 and 0.6 mg/L:", `% Samples between 0.1 and 0.6 mg/L`,
                             "<br>Avg. Free Chlorine Concentration (mg/L):", `Average Free chlorine Concentration (mg/L)`,
                             "<br>Number of Free Chlorine Samples:", `Number of Free Chlorine Samples`,
                             sep = "")) %>%
  addLegend("bottomright", pal = colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`),
            values = merged_data_S$`% Samples above 0.1 mg/L`,
            title = "% Samples above 0.1 mg/L", opacity = 1)

# Print the map
map


library(htmlwidgets)
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_googlemap_All_vars_type1.html"



# Save the map with specified file path
saveWidget(map, file = file_path)




##############with labels on top##############################

library(sf)
library(leaflet)

# Assuming merged_data_S is already transformed to WGS 84

# Calculate centroids of polygons for label placement
centroids <- st_centroid(merged_data_S)

# Create labels
labels <- paste("Village: ", centroids$village)

# Now, build the map
map <- leaflet(merged_data_S) %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              fillColor = ~colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`)(`% Samples above 0.1 mg/L`),
              fillOpacity = 0.5,
              popup = ~paste("Village:", village,
                             "<br>TEHSIL:", TEHSIL,
                             "<br>% Samples above 0.1 mg/L:", `% Samples above 0.1 mg/L`,
                             "<br>% Samples above 0.6 mg/L:", `% Samples above 0.6 mg/L`,
                             "<br>% Samples between 0.1 and 0.6 mg/L:", `% Samples between 0.1 and 0.6 mg/L`,
                             "<br>Avg. Free Chlorine Concentration (mg/L):", `Average Free chlorine Concentration (mg/L)`,
                             "<br>Number of Free Chlorine Samples:", `Number of Free Chlorine Samples`,
                             sep = "")) %>%
  addLegend("bottomright", pal = colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`),
            values = merged_data_S$`% Samples above 0.1 mg/L`,
            title = "% Samples above 0.1 mg/L", opacity = 1)

# Add labels to the map using centroids
map <- map %>%
  addMarkers(data = centroids, label = ~village, labelOptions = labelOptions(noHide = TRUE, direction = 'auto'))

# Print the map
map


library(htmlwidgets)
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_googlemap_All_vars.html"



# Save the map with specified file path
saveWidget(map, file = file_path)





################################################################

#markers with reducded label size 

library(sf)
library(leaflet)

# Assuming merged_data_S is already transformed to WGS 84

# Calculate centroids of polygons for label placement
centroids <- st_centroid(merged_data_S)

# Create a custom icon
smallIcon <- makeIcon(
  iconUrl = "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png",
  iconWidth = 12, # Adjust the width as needed
  iconHeight = 20, # Adjust the height as needed
  iconAnchorX = 6, # Adjust to center the icon horizontally
  iconAnchorY = 10 # Adjust to anchor the icon's bottom tip
)

# Build the map
map <- leaflet(merged_data_S) %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              fillColor = ~colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`)(`% Samples above 0.1 mg/L`),
              fillOpacity = 0.5,
              popup = ~paste("Village:", village,
                             "<br>TEHSIL:", TEHSIL,
                             "<br>% Samples above 0.1 mg/L:", `% Samples above 0.1 mg/L`,
                             "<br>% Samples above 0.6 mg/L:", `% Samples above 0.6 mg/L`,
                             "<br>% Samples between 0.1 and 0.6 mg/L:", `% Samples between 0.1 and 0.6 mg/L`,
                             "<br>Avg. Free Chlorine Concentration (mg/L):", `Average Free chlorine Concentration (mg/L)`,
                             "<br>Number of Free Chlorine Samples:", `Number of Free Chlorine Samples`,
                             sep = "")) %>%
  addLegend("bottomright", pal = colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`),
            values = merged_data_S$`% Samples above 0.1 mg/L`,
            title = "% Samples above 0.1 mg/L", opacity = 1)

# Add custom-sized markers to the map
map <- map %>%
  addMarkers(data = centroids, icon = smallIcon, label = ~village, labelOptions = labelOptions(noHide = TRUE, direction = 'auto'))

# Print the map
map

library(htmlwidgets)
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_googlemap_All_vars_Small.html"



# Save the map with specified file path
saveWidget(map, file = file_path)





#######################################################
#bring TEHSIL BOundary around this 
library(sf)
library(leaflet)

# Load TEHSIL boundary data
tehsil_boundaries <- st_read("tehsil_boundaries.shp")

# Assuming merged_data_S is already transformed to WGS 84

# Calculate centroids of polygons for label placement
centroids <- st_centroid(merged_data_S)

# Create a custom icon
smallIcon <- makeIcon(
  iconUrl = "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png",
  iconWidth = 12, # Adjust the width as needed
  iconHeight = 20, # Adjust the height as needed
  iconAnchorX = 6, # Adjust to center the icon horizontally
  iconAnchorY = 10 # Adjust to anchor the icon's bottom tip
)

# Build the map
map <- leaflet() %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  addPolygons(data = tehsil_boundaries, fillColor = "transparent", color = "blue", weight = 2) %>% # Add TEHSIL boundaries
  addPolygons(data = merged_data_S, color = "#444444", weight = 1, smoothFactor = 0.5,
              fillColor = ~colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`)(`% Samples above 0.1 mg/L`),
              fillOpacity = 0.5,
              popup = ~paste("Village:", village,
                             "<br>TEHSIL:", TEHSIL,
                             "<br>% Samples above 0.1 mg/L:", `% Samples above 0.1 mg/L`,
                             "<br>% Samples above 0.6 mg/L:", `% Samples above 0.6 mg/L`,
                             "<br>% Samples between 0.1 and 0.6 mg/L:", `% Samples between 0.1 and 0.6 mg/L`,
                             "<br>Avg. Free Chlorine Concentration (mg/L):", `Average Free chlorine Concentration (mg/L)`,
                             "<br>Number of Free Chlorine Samples:", `Number of Free Chlorine Samples`,
                             sep = "")) %>%
  addLegend("bottomright", pal = colorFactor(palette = "viridis", domain = merged_data_S$`% Samples above 0.1 mg/L`),
            values = merged_data_S$`% Samples above 0.1 mg/L`,
            title = "% Samples above 0.1 mg/L", opacity = 1)

# Add custom-sized markers to the map
map <- map %>%
  addMarkers(data = centroids, icon = smallIcon, label = ~village, labelOptions = labelOptions(noHide = TRUE, direction = 'auto'))

# Print the map
map


#_______________________________________________________________________#

# TAP WATER FREE CHLORINE 
#________________________________________________________________________#

View(merged_data_sf)
merged_data_T <- merged_data_sf %>% filter (WaterType == "Tap Water")

View(merged_data_T)
# Filter merged_data_sf to include only villages present in your dataset
merged_data_T <- merged_data_T[merged_data_T$village %in% unique_villages, ]

View(merged_data_T)

# Create the TEHSIL variable based on conditions
merged_data_T <- merged_data_T %>%
  mutate(TEHSIL = case_when(
    village == "asada" ~ "Gudari",
    village == "badabangi" ~ "Ramnagauda",
    village == "bichikote" ~ "Padmapur",
    village == "birnarayanpur" ~ "Rayagada",
    village == "gopi kankubadi" ~ "Kolnara",
    village == "karnapadu" ~ "Padmapur",
    village == "mukundpur" ~ "Kolnara",
    village == "naira" ~ "Padmapur",
    village == "nathma" ~ "Rayagada",
    village == "tandipur" ~ "Kolnara",
    TRUE ~ NA_character_ # This is for villages not specified in your list, assigns NA
  ))




# First, create a new column in 'merged_data_sf' that includes the text for the tooltip
merged_data_T$tooltip_text <- paste(
  "Village: ", merged_data_T$village,
  "<br>% Samples between 0.1 and 0.6 mg/L: ", merged_data_T$`% Samples between 0.1 and 0.6 mg/L`,
  "<br>% Samples above 0.1 mg/L: ", merged_data_T$`% Samples above 0.1 mg/L`, # Adjust the column name as per your dataset
  "<br>% Samples above 0.6 mg/L: ", merged_data_T$`% Samples above 0.6 mg/L`, # Adjust the column name as per your dataset
  "<br>Number of Free Chlorine Samples: ", merged_data_T$`Number of Free Chlorine Samples`, # Adjust the column name as per your dataset
  
  sep = ""
)

# Update the ggplot creation to use this new 'tooltip_text' column for the 'text' aesthetic
chloropleth_map_T <- ggplot() +
  geom_sf(data = merged_data_T, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = tooltip_text), color = "black", size = 0.5) +
  scale_fill_gradient(name = "% Samples above  0.1 and 0.6 mg/L", low = "#E69F00", high = "#56B4E9") + 
  labs(title = "% Tap Samples between 0.1 and 0.6 mg/L for free chlorine", caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")

# Convert the ggplot to a plotly object
# Specify 'tooltip' argument to 'text' to ensure custom tooltips are displayed
interactive_choropleth_T <- ggplotly(chloropleth_map_T, tooltip = "text", height = 600, width = 800)

# Print the interactive choropleth map
print(interactive_choropleth_T)


library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth_T <- ggplotly(
  chloropleth_map_T, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Choropleth_All_vars.html"



# Save the map with specified file path
saveWidget(interactive_choropleth_T, file = file_path)
#more vars





















































































########################################################################


#EN DOF THE MAIN GRAPH COMMANDS 


#####################################################################






































































# Create the choropleth map
chloropleth_map <- ggplot() +
  geom_sf(data = merged_data_S, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = village), color = "black", size = 0.5) +
  scale_fill_gradient(name = "Chlorine Concentration", low = "#E69F00", high = "#56B4E9") +  # Colorblind-friendly colors
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine ", 
       caption = "Source: Your Data Source") +  # Add title and caption
  theme_minimal() +  # Choose a theme
  theme(legend.position = "right")  # Adjust legend position

# Convert the ggplot to a plotly object
interactive_choropleth <- ggplotly(chloropleth_map, height = 600, width = 600)  # Increase map size

# Print the interactive choropleth map
print(interactive_choropleth)

#############################################################
install.packages("htmlwidgets")

library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth <- ggplotly(
  chloropleth_map, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Choropleth.html"



# Save the map with specified file path
saveWidget(interactive_choropleth, file = file_path)
#more vars



library(ggplot2)
library(plotly)


# Replace the path below with the path to your shapefile
shapefile_path_block <- "C:/Users/Archi Gupta/Downloads/Odisha_all_shapefiles_blocks/ODISHA_SUBDISTRICT_BDY.shp"

# Read the shapefile
my_shapefile_block <- st_read(shapefile_path_block)

# Check the contents
plot(my_shapefile_block)

View(my_shapefile_block)


my_shapefile_block_odisha <- my_shapefile_block %>%
  filter(STATE == "ODISHA")

View(my_shapefile_block_odisha)



my_shapefile_block_odisha <- my_shapefile_block_odisha %>%
  filter(District == "R>YAGARHA")


my_shapefile_block_odisha$District <- gsub("R>YAGARHA"    , "Rayagada", my_shapefile_block_odisha$District)
my_shapefile_block_odisha$TEHSIL <- gsub("R>YAGARHA"    , "Rayagada", my_shapefile_block_odisha$TEHSIL)

my_shapefile_block_odisha <- my_shapefile_block_odisha %>%
  filter(TEHSIL == "Rayagada" | TEHSIL =="GUNUPUR" )

# Base layer with TEHSIL boundaries
# Ensure that `my_shapefile_block_odisha` is your TEHSIL level shapefile data
choropleth_map <- ggplot() +
  geom_sf(data = my_shapefile_block_odisha, fill = NA, color = "gray", size = 0.25) +
  geom_sf(data = merged_data_sf, aes(fill = `% Samples between 0.1 and 0.6 mg/L`), color = "black", size = 0.5) +
  scale_fill_gradient(name = "Chlorine Concentration", low = "#E69F00", high = "#56B4E9") +
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine",
       caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")

# Assuming `village` and `% Samples between 0.1 and 0.6 mg/L` are columns in `merged_data_sf`
# For tooltips in Plotly, create a custom text column if needed
merged_data_sf$text <- paste("Village:", merged_data_sf$village, 
                             "<br>% Samples between 0.1 and 0.6 mg/L:", merged_data_sf$`% Samples between 0.1 and 0.6 mg/L`)

# Convert to a plotly object for interactivity
interactive_choropleth <- ggplotly(choropleth_map, tooltip = "text", height = 600, width = 800)

# Print the interactive choropleth map
print(interactive_choropleth)


names(merged_data_sf)
View(merged_data_sf)

# First, create a new column in 'merged_data_sf' that includes the text for the tooltip
merged_data_sf$tooltip_text <- paste(
  "Village: ", merged_data_sf$village,
  "<br>% Samples between 0.1 and 0.6 mg/L: ", merged_data_sf$`% Samples between 0.1 and 0.6 mg/L`,
  "<br>% Samples above 0.1 mg/L: ", merged_data_sf$`% Samples above 0.1 mg/L`, # Adjust the column name as per your dataset
  "<br>% Samples above 0.6 mg/L: ", merged_data_sf$`% Samples above 0.6 mg/L`, # Adjust the column name as per your dataset
  "<br>Number of Free Chlorine Samples: ", merged_data_sf$`Number of Free Chlorine Samples`, # Adjust the column name as per your dataset
  
  sep = ""
)

# Update the ggplot creation to use this new 'tooltip_text' column for the 'text' aesthetic
chloropleth_map_M <- ggplot() +
  geom_sf(data = merged_data_sf, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = tooltip_text), color = "black", size = 0.5) +
  scale_fill_gradient(name = "% Samples above  0.1 and 0.6 mg/L", low = "#E69F00", high = "#56B4E9") + 
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine", caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")

# Convert the ggplot to a plotly object
# Specify 'tooltip' argument to 'text' to ensure custom tooltips are displayed
interactive_choropleth_M <- ggplotly(chloropleth_map_M, tooltip = "text", height = 600, width = 800)

# Print the interactive choropleth map
print(interactive_choropleth_M)


library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth_M <- ggplotly(
  chloropleth_map_M, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Choropleth_All_vars.html"



# Save the map with specified file path
saveWidget(interactive_choropleth_M, file = file_path)
#more vars



######################################################################

#

#######################################################################




merged_data_sf <- merged_data_sf %>% filter (WaterType == "Stored Water")

# Filter merged_data_sf to include only villages present in your dataset
merged_data_sf <- merged_data_sf[merged_data_sf$village %in% unique_villages, ]

View(merged_data_sf)

# Create the TEHSIL variable based on conditions
merged_data_sf <- merged_data_sf %>%
  mutate(TEHSIL = case_when(
    village == "asada" ~ "Gudari",
    village == "badabangi" ~ "Ramnagauda",
    village == "bichikote" ~ "Padmapur",
    village == "birnarayanpur" ~ "Rayagada",
    village == "gopi kankubadi" ~ "Kolnara",
    village == "karnapadu" ~ "Padmapur",
    village == "mukundpur" ~ "Kolnara",
    village == "naira" ~ "Padmapur",
    village == "nathma" ~ "Rayagada",
    village == "tandipur" ~ "Kolnara",
    TRUE ~ NA_character_ # This is for villages not specified in your list, assigns NA
  ))




# First, create a new column in 'merged_data_sf' that includes the text for the tooltip
merged_data_sf$tooltip_text <- paste(
  "Village: ", merged_data_sf$village,
  "<br>% Samples between 0.1 and 0.6 mg/L: ", merged_data_sf$`% Samples between 0.1 and 0.6 mg/L`,
  "<br>% Samples above 0.1 mg/L: ", merged_data_sf$`% Samples above 0.1 mg/L`, # Adjust the column name as per your dataset
  "<br>% Samples above 0.6 mg/L: ", merged_data_sf$`% Samples above 0.6 mg/L`, # Adjust the column name as per your dataset
  "<br>Number of Free Chlorine Samples: ", merged_data_sf$`Number of Free Chlorine Samples`, # Adjust the column name as per your dataset
  
  sep = ""
)

# Update the ggplot creation to use this new 'tooltip_text' column for the 'text' aesthetic
chloropleth_map_M <- ggplot() +
  geom_sf(data = merged_data_sf, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = tooltip_text), color = "black", size = 0.5) +
  scale_fill_gradient(name = "% Samples above  0.1 and 0.6 mg/L", low = "#E69F00", high = "#56B4E9") + 
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine", caption = "Source: Your Data Source") +
  theme_minimal() +
  theme(legend.position = "right")

# Convert the ggplot to a plotly object
# Specify 'tooltip' argument to 'text' to ensure custom tooltips are displayed
interactive_choropleth_M <- ggplotly(chloropleth_map_M, tooltip = "text", height = 600, width = 800)

# Print the interactive choropleth map
print(interactive_choropleth_M)


library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth_M <- ggplotly(
  chloropleth_map_M, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Choropleth_All_vars.html"



# Save the map with specified file path
saveWidget(interactive_choropleth_M, file = file_path)




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

# Check if there are any duplicate deviceid values
any(duplicated(df.super$deviceid))

#dropping training entry for tandipur by device id since devce id are unique
df.super <- subset(df.super, !(village_name == "30301" & deviceid == "865525051839421"))

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



clone <- df.temp %>%
  mutate(starttime = mdy(starttime))  # Format in desired MDY format
View(clone)

# Find the first visit date for each village
first_visit_dates <- clone %>%
  group_by(village_name) %>%
  summarise(First_Visit_Date = min(starttime, na.rm = TRUE))

# View the result
print(first_visit_dates)

#list all var names
names(df.temp)
# Specify the variables of interest
variables_of_interest <- c("first_nearest_tap_fc", "second_nearest_tap_fc", "first_nearest_tap_tc", 
                           "second_nearest_tap_tc", "first_stored_water_fc", "second_stored_water_fc", 
                           "first_stored_water_tc", "second_stored_water_tc", "first_farthest_tap_fc", 
                           "second_farthest_tap_fc", "first_farthest_tap_tc", "second_farthest_tap_tc", 
                           "far_first_stored_water_fc", "far_second_stored_water_fc", 
                           "far_first_stored_water_tc", "far_second_stored_water_tc")

# Filter rows where any of the specified variables have missing values
missing_values <- df.temp[rowSums(is.na(df.temp[, variables_of_interest])) > 0, ]


View(missing_values)


# Displaying chlorine concentration for each village


df.temp.all <- df.temp %>%
  rowwise() %>%
  mutate(nearest_tap_fc = (first_nearest_tap_fc + second_nearest_tap_fc) / 2, 
         nearest_tap_tc = (first_nearest_tap_tc + second_nearest_tap_tc) / 2,
         nearest_stored_fc = (first_stored_water_fc + second_stored_water_fc) / 2,
         nearest_stored_tc = (first_stored_water_tc + second_stored_water_tc) / 2,
         farthest_tap_fc = (first_farthest_tap_fc + second_farthest_tap_fc) / 2,
         farthest_tap_tc = (first_farthest_tap_tc + second_farthest_tap_tc) / 2,
         farthest_stored_fc = (far_first_stored_water_fc + far_second_stored_water_fc) / 2,
         farthest_stored_tc = (far_first_stored_water_tc + far_second_stored_water_tc) / 2) %>%
  ungroup()



View(df.temp.all)
chlorine <- df.temp.all%>%
  pivot_longer(cols = c(nearest_tap_fc, nearest_tap_tc, 
                        farthest_tap_fc,farthest_tap_tc, 
                        nearest_stored_fc, farthest_stored_fc, 
                        nearest_stored_tc, farthest_stored_tc), values_to = "chlorine_concentration", names_to = "chlorine_test_type")


View(chlorine)

chlorine <- chlorine %>%
  rename(Date = starttime)


#chlorine <- chlorine %>% dplyr::select(village_name, chlorine_test_type, chlorine_concentration, Date )


chlorine <- chlorine %>% 
  dplyr::select(village_name, chlorine_test_type, chlorine_concentration, Date) 
#%>%mutate(chlorine_concentration = (chlorine_concentration, 2))


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



# Create a dataframe with NA values in chlorine_concentration
na_rows <- chlorine %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
chlorine <- chlorine %>%
  drop_na(chlorine_concentration)


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
#new plot with scatter plot type graph (line point graphs)

plot_list_stored <- list()

for (i in village_list) {
  df.vil.cl <- df.stored %>% 
    filter(village == i) %>%
    arrange(Date)  # Ensure data is sorted by Date
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  # Define Okabe-Ito color palette for color-blindness
  okabe_ito_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  
  su <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_line() +  # Draw lines connecting points
    geom_point(size = 3) +  # Scatter plot with points
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.position = c(1, 1),
      legend.box = "horizontal",  
      legend.justification = c("right", "top"),
      legend.box.just = "top",
      legend.margin = margin(6, 6, 6, 6),
      legend.title = element_text(size = 8),
      legend.text = element_text(size = 8),
      axis.text.x = element_text(angle = 90, size = 10)
    ) + 
    scale_color_manual(values = okabe_ito_palette) +  # Use Okabe-Ito palette
    ggtitle(paste0('Stored water: Village_', i))
  
  print(su)
  plot_list_stored[[i]] <- su
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Village_", i, ".png")
  
  # Save the plot to the specified path
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

plot_list_stored <- list()

for (i in village_list) {
  df.vil.cl <- df.tap %>% 
    filter(village == i) %>%
    arrange(Date)  # Ensure data is sorted by Date
  
  # Parse Date variable to Date class using mdy() function
  df.vil.cl$Date <- mdy(df.vil.cl$Date)
  max_date <- max(df.vil.cl$Date, na.rm = TRUE)
  
  # Define Okabe-Ito color palette for color-blindness
  okabe_ito_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  
  tup <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test)) +
    geom_line() +  # Draw lines connecting points
    geom_point(size = 3) +  # Scatter plot with points
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    labs(title = "Concentration of Chlorine",
         x = "Date",
         y = "") +  
    scale_x_date(date_breaks = '3 day', labels = scales::date_format("%b %d")) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.position = c(1, 1),
      legend.box = "horizontal",  
      legend.justification = c("right", "top"),
      legend.box.just = "top",
      legend.margin = margin(6, 6, 6, 6),
      legend.title = element_text(size = 8),
      legend.text = element_text(size = 8),
      axis.text.x = element_text(angle = 90, size = 10)
    ) + 
    scale_color_manual(values = okabe_ito_palette) +  # Use Okabe-Ito palette
    ggtitle(paste0('Tap water: Village_', i))
  
  print(tup)
  plot_list_stored[[i]] <- tup
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_", i, ".png")
  
  # Save the plot to the specified path
  ggsave(file_path, plot = tup, device = 'png', width = 10, height = 6)
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


#-----------------------------------------------------------------------------#
#Point line plots for stored water with installation dates
#-----------------------------------------------------------------------------#


# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_stored <- list()

# Loop through each village
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
  siu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('Stored water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('Stored water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(siu)
  plot_list_stored[[i]] <- siu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Install_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = siu, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
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

#-----------------------------------------------------------------------------#
#Point line plots for tap water with installation dates
#-----------------------------------------------------------------------------#


# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_tap <- list()

# Loop through each village
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
  tiu <- ggplot(df.vil.cl, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test, group = 1)) +
    geom_line(linewidth = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('Tap water: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('Tap water: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(tiu)
  plot_list_stored[[i]] <- tiu
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Install_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = tiu, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")



#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________

# Remove NA values from the dataset

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
Gram_vikas_data <- read_excel(file.path(global_working_directory, "India ILC_Gram Vikas Chlorine Monitoring (1).xlsx"))
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
Gram_vikas_data$Village <- gsub("gopikankubadi", "gopi kankubadi", Gram_vikas_data$Village)

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
print(unique(reshaped_GV.df$village))

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

reshaped_GV.df$Distance<- gsub("Nearest tap", "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last Tap", "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap — both valves to 12 oclock" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest tap — 12 oclock dosing valve change" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest tap" , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Farthest Tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("last tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Tap"  , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water in Nearest Tap"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("nearest tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Nearest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Farthest"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest Test"  , "Farthest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water - Nearest Tap"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest — 12 oclock dosing valve change"   , "Nearest", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Mid-way Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Middle Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Near"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("middle Tap"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Fathest Tap"   , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Sample"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Next Hamlet, Stored Water"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest Stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Nearest stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Farthest stored water"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored water from previous day at first tap"  , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Farthest"   , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored Water in Nearest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stpred water  Farthest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored in Nearest"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Tap — 12 oclock dosing valve change"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last TAp"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Last tap"    , "Tap", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stored in Tap"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Stpred water  Tap"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Tapp"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("Tap stored water"    , "Stored", reshaped_GV.df$Distance)
reshaped_GV.df$Distance<- gsub("stpred water from previous day at Tap"    , "Stored", reshaped_GV.df$Distance)

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
na_rows <- reshaped_GV.df %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
na_rows <- reshaped_GV.df %>%
  filter(is.na(Date))

na_rows <- reshaped_GV.df %>%
  filter(is.na(village))

na_rows <- reshaped_GV.df %>%
  filter(is.na(chlorine_test))

#dropping NA values
reshaped_GV.df <- reshaped_GV.df %>%
  drop_na(chlorine_concentration)

View(reshaped_GV.df)
class(reshaped_GV.df$Date)

df.new.GV <- reshaped_GV.df
df.new.GV$Date <- as.Date(df.new.GV$Date)
print(unique(df.new.GV$Date))
class(df.new.GV$Date)
class(df.new.GV$Date)
View(df.new.GV)

df.new.GV.free <- df.new.GV 

df.new.GV.free <- df.new.GV.free %>% filter(chlorine_test == "Free Chlorine")

View(df.new.GV.free)





# Define colorblind friendly colors
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_gv <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  GV.df.com <- df.new.GV %>% filter(village == i)
  GV.df.com <- GV.df.com %>% arrange(Date)
  max_date <- max(GV.df.com$Date, na.rm = TRUE)
  
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
  gv <- ggplot(GV.df.com, aes(x = Date, y = chlorine_concentration, color = chlorine_test, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('GV plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV plot: Village_', i))
  
  print(paste("Plot for village", i, "generated."))
  print(gv)
  plot_list_stored[[i]] <- gv
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/GV_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}

print("Plots generated for all villages.")









#_______________________________________________________________________________#



#DATES ONLY AFTER THE CURRENT INSTALLATION



#_______________________________________________________________________________#


#For graphs
#For stats 


#_______________________________________________________________________________#

#------------------------------------------------------------------------------
#STORED WATER
#--------------------------------------------------------------------------------

#general graph
View(df.stored)

df.stored.edit <- df.stored 

# Make date usable
df.stored.edit$Date <- mdy(df.stored.edit$Date)

# Append datasets while preserving all columns
appended_df_stored <- full_join(df.stored.edit, Installation_df, by = c("Date", "village"))

View(appended_df_stored)

# Checking if village names are unique 
print(unique(appended_df_stored$village))

changed_df_stored <- appended_df_stored %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_stored <- changed_df_stored %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_stored)

df.stored.after_L <- changed_df_stored %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(df.stored.after_L$Date < df.stored.after_L$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(df.stored.after_L)


na_rows <- df.stored.after_L %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
df.stored.after_L <- df.stored.after_L %>%
  drop_na(chlorine_concentration)

View(df.stored.after_L)
class(df.stored.after_L$Date)
#NOW MAKE THE GRAPHS 

#########################################################

View(df.stored.after_L)
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  stored.AI <- df.stored.after_L %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(stored.AI$Date, na.rm = TRUE)
  
  
  print(paste("Generating plot for village:", i))
  
  
  # Create plot with adjustments
  SAII <- ggplot(stored.AI, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test , group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('Stored water : Village_', i  ,'(Only Dates after last installation)'))
  
  print(paste("Plot for village", i, "generated."))
  print(SAII)
  plot_list_c[[i]] <- SAII
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = SAII, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}



warnings()

#------------------------------------------------------------------------------
#TAP WATER
#--------------------------------------------------------------------------------

#general graph



df.tap.edit <- df.tap 

# Make date usable
df.tap.edit$Date <- mdy(df.tap.edit$Date)

# Append datasets while preserving all columns
appended_df_tap <- full_join(df.tap.edit, Installation_df, by = c("Date", "village"))

View(appended_df_tap)

# Checking if village names are unique 
print(unique(appended_df_tap$village))

changed_df_tap <- appended_df_tap %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_tap <- changed_df_tap %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_tap)

df.tap.after_L <- changed_df_tap %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(df.tap.after_L$Date <= df.tap.after_L$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(df.tap.after_L)


na_rows <- df.tap.after_L %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
df.tap.after_L <- df.tap.after_L %>%
  drop_na(chlorine_concentration)


#NOW MAKE THE GRAPHS 


View(df.tap.after_L)
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create an empty list to store plots
plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  tap.AI <- df.tap.after_L %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(tap.AI$Date, na.rm = TRUE)
  
  
  print(paste("Generating plot for village:", i))
  
  
  # Create plot with adjustments
  SAII <- ggplot(tap.AI, aes(x = Date, y = chlorine_concentration, color = Distance, shape = Test , group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = colorblind_palette) + # Use colorblind friendly colors
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('Tap water : Village_', i  ,'(Only Dates after last installation)'))
  
  print(paste("Plot for village", i, "generated."))
  print(SAII)
  plot_list_c[[i]] <- SAII
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = SAII, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}






#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________


df.stored.free <- df.stored.after_L %>% filter(Test == "Free_Chlorine_stored")

View(df.stored.free)
install.packages("viridis")
library(viridis)  # Load viridis package for color palettes

# Generate color palette with enough colors for all unique villages
color_palette <- viridis_pal()(length(unique(df.stored.free$village)))

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.stored.free, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Stored water chlorine concentration for free chlorine (After the Last Installation Date)",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5),  # Adjust legend margin
        panel.border = element_rect(color = "black", fill = NA),  # Add outside boundary
        panel.grid.major = element_line(color = "gray", size = 0.5),  # Add gridlines
        axis.line = element_line(color = "black")) +  # Add axis lines
  scale_fill_manual(values = color_palette) +  # Set color palette
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)

# Save the plot
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_Boxplots_Villages.png"
ggsave(file_path, plot = boxplot_all_villages, device = 'png', width = 10, height = 6, bg = "white")

#_______________________________________________________________________________
#BOXPLOTS TAP WATER
#_______________________________________________________________________________

# Generate color palette with enough colors for all unique villages

df.tap.free <- df.tap.after_L %>% filter(Test == "Free_Chlorine_tap")

color_palette <- viridis_pal()(length(unique(df.tap.free$village)))

# Create boxplot with fill color and remove NA values
boxplot_all_villages <- ggplot(df.tap.free, aes(x = village, y = chlorine_concentration, fill = village)) +
  geom_boxplot() +  # Create boxplot
  labs(title = "Tap water chlorine concentration for free chlorine (After the Last Installation Date)",
       x = "Village",
       y = "Chlorine Concentration") +  # Labels for axes
  theme_minimal() +  # Minimal theme
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels
        legend.position = "right",  # Move legend to bottom
        legend.box = "vertical",  # Arrange legend items horizontally
        legend.margin = margin(t = 5),  # Adjust legend margin
        panel.border = element_rect(color = "black", fill = NA),  # Add outside boundary
        panel.grid.major = element_line(color = "gray", size = 0.5),  # Add gridlines
        axis.line = element_line(color = "black")) +  # Add axis lines
  scale_fill_manual(values = color_palette) +  # Set color palette
  guides(fill = guide_legend(override.aes = list(size = 2)))  # Adjust legend size

# Print the boxplot
print(boxplot_all_villages)

# Save the plot
file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Boxplots_Villages.png"
ggsave(file_path, plot = boxplot_all_villages, device = 'png', width = 10, height = 6, bg = "white")

#_______________________________________________________________________________
#Ridges plot STORED WATER 
#_______________________________________________________________________________

#------------------------------NEAREST----------------------------#


df.stored.nearest <- df.stored.after_L %>% filter(Distance== "Nearest")

View(df.stored.nearest)

# Rename values in the chlorine_test_type column
df.stored.nearest <- df.stored.nearest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "nearest_stored_fc" = "Free Chlorine",
                                     "nearest_stored_tc" = "Total Chlorine"))

# Remove NA values from the dataset

library(ggridges)
library(grid)


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.stored.nearest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.stored.filtered <- df.stored.nearest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.stored.filtered, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Nearest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, label = paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", ")), 
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_nearest)

#------------------------------FARTHEST----------------------------#

df.stored.farthest <- df.stored.after_L %>% filter(Distance== "Farthest")

View(df.stored.farthest)
library(ggridges)
library(grid)

# Rename values in the chlorine_test_type column
df.stored.farthest <- df.stored.farthest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "farthest_stored_fc" = "Free Chlorine",
                                     "farthest_stored_tc" = "Total Chlorine"))


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.stored.farthest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.stored.filtered.farthest <- df.stored.farthest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_farthest <- ggplot(df.stored.filtered.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Farthest stored water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, label = paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", ")), 
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

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
df.tap.nearest <- df.tap.after_L %>% filter(Distance== "Nearest")



# Rename values in the chlorine_test_type column
df.tap.nearest <- df.tap.nearest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "nearest_tap_fc" = "Free Chlorine",
                                     "nearest_tap_tc" = "Total Chlorine"))

# Remove NA values from the dataset

library(ggridges)
library(grid)


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.tap.nearest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.tap.filtered <- df.tap.nearest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_nearest <- ggplot(df.tap.filtered, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Nearest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, label = paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", ")), 
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_nearest)

#------------------------------FARTHEST----------------------------#

df.tap.farthest <- df.tap.after_L %>% filter(Distance== "Farthest")

View(df.tap.farthest)
library(ggridges)
library(grid)

# Rename values in the chlorine_test_type column
df.tap.farthest <- df.tap.farthest %>%
  mutate(chlorine_test_type = recode(chlorine_test_type,
                                     "farthest_tap_fc" = "Free Chlorine",
                                     "farthest_tap_tc" = "Total Chlorine"))


# Define colorblind-friendly palette
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Calculate the total number of rows per village
village_total_rows <- df.tap.farthest %>%
  group_by(village) %>%
  summarise(total_rows = n())

print(village_total_rows)
# Extract villages with a total number of rows less than 5
villages_to_remove <- village_total_rows %>%
  filter(total_rows < 5) %>%
  pull(village)

print(villages_to_remove)
# Filter out rows for villages with a total number of rows less than 5
df.tap.filtered.farthest <- df.tap.farthest %>%
  filter(!village %in% villages_to_remove)


# Create a ridgeline plot
ridgeline_plot_farthest <- ggplot(df.tap.filtered.farthest, aes(x = chlorine_concentration, y = village, fill = chlorine_test_type)) +
  geom_density_ridges(scale = 3, alpha = 0.7) +  # Increase scale and transparency for better visualization
  labs(title = "Farthest tap water Chlorine Concentration",
       x = "Chlorine Concentration",
       y = "Village") +
  theme_minimal() +
  scale_fill_manual(values = colorblind_palette) +  # Set colorblind-friendly colors
  guides(fill = guide_legend(override.aes = list(size = 2))) +  # Adjust legend size
  theme(panel.border = element_rect(color = "black", fill = NA)) +  # Add black border around the plot
  annotate(geom = "text", x = Inf, y = -Inf, label = paste("**Villages that aren't plotted because of less density:", paste(villages_to_remove, collapse = ", ")), 
           hjust = 1, vjust = 0, size = 2.5, color = "black") +  # Add footnote with names of villages outside the plot
  coord_cartesian(clip = "off")  # Allow annotations to extend outside the plot area

# Print the ridgeline plot
print(ridgeline_plot_farthest)

# Combine the two ridgeline plots into a single plot
combined_plot_ridges <- ridgeline_plot_nearest + ridgeline_plot_farthest

# Print the combined plot
print(combined_plot_ridges)

file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_Ridge_Village.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = combined_plot_ridges, device = 'png', width = 15, height = 7)


#----------------------------------------------------------------------------#
#Combine village wise plots for GV and J-PAL 
#----------------------------------------------------------------------------#

#GV dataset - df.new.GV.free
#J-pal- 


#________________________________________________________________________________#
##########      STORED WATER    ##########################################
#________________________________________________________________________________#

View(chlorine)

JPAL.stored <- df.stored 

# Make date usable
JPAL.stored$Date <- mdy(JPAL.stored$Date)

View(JPAL.stored)

# Append datasets while preserving all columns
JPAL_appended_stored <- full_join(JPAL.stored, Installation_df, by = c("Date", "village"))

View(JPAL_appended_stored)

# Checking if village names are unique 
print(unique(JPAL_appended_stored$village))

changed_df_JPAL_stored <- JPAL_appended_stored %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_JPAL_stored <- changed_df_JPAL_stored %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_JPAL_stored)

changed_df_JPAL_stored_after_LI <- changed_df_JPAL_stored %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_JPAL_stored_after_LI$Date < changed_df_JPAL_stored_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_JPAL_stored_after_LI)


na_rows <- changed_df_JPAL_stored_after_LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_JPAL_stored_after_LI <- changed_df_JPAL_stored_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_JPAL_stored_after_LI)

#check again for NA values
na_rows <- changed_df_JPAL_stored_after_LI%>%
  filter(is.na(chlorine_concentration))



#----------------------------------------------------------------------------
###EXCLUDE DATES BEFORE INSTALLATION FROM GV DATASET AS WELL 
#----------------------------------------------------------------------------


View(df.new.GV)
df.new.GV.AI <- df.new.GV 

# Append datasets while preserving all columns
appended_df_GV <- full_join(df.new.GV.AI, Installation_df, by = c("Date", "village"))

View(appended_df_GV)

# Checking if village names are unique 
print(unique(appended_df_GV$village))
print(unique(df.new.GV.AI$village))

changed_df_GV <- appended_df_GV %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_GV <- changed_df_GV %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_GV)

changed_df_GV_after_LI <- changed_df_GV %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_GV_after_LI$Date < changed_df_GV_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_GV_after_LI)


na_rows <- changed_df_GV_after_LI %>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_GV_after_LI <- changed_df_GV_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_GV_after_LI)

View(changed_df_JPAL_stored_after_LI)

changed_df_JPAL_stored_after_LI$Test <- gsub("Free_Chlorine_stored"    , "Free Chlorine", changed_df_JPAL_stored_after_LI$Test)

changed_df_JPAL_stored_after_LI$Test <- gsub("Total_Chlorine_stored"    , "Total Chlorine", changed_df_JPAL_stored_after_LI$Test)


#We want only stored values from GV datastet

print(unique(changed_df_GV_after_LI$Distance))
changed_df_GV_after_LI.stored <- changed_df_GV_after_LI %>% filter(Distance == "Stored")

View(changed_df_GV_after_LI.stored)


#filter out free chlorine only from both

changed_df_GV_after_LI.stored.free <- changed_df_GV_after_LI.stored %>% filter(chlorine_test == "Free Chlorine")


View(changed_df_GV_after_LI.stored.free)



changed_df_JPAL_stored_after_LI.free <- changed_df_JPAL_stored_after_LI %>% filter(Test == "Free Chlorine")


View(changed_df_JPAL_stored_after_LI.free)



changed_df_GV_after_LI.stored.free$Organization <- "Gram Vikas"
changed_df_JPAL_stored_after_LI.free$Organization <- "J-PAL"
names(changed_df_GV_after_LI.stored.free)
names(changed_df_JPAL_stored_after_LI.free)

changed_df_GV_after_LI.stored.free <- rename(changed_df_GV_after_LI.stored.free, Test = chlorine_test)
# Get common column names

changed_df_GV_after_LI.stored.free <- select(changed_df_GV_after_LI.stored.free, -chlorine_test_type, -location)
changed_df_GV_after_LI.stored.free <- select(changed_df_GV_after_LI.stored.free, -installation_status, -Ins_status)
changed_df_GV_after_LI.stored.free <- rename(changed_df_GV_after_LI.stored.free, Source = Distance)


common_cols <- intersect(names(changed_df_GV_after_LI.stored.free), names(changed_df_JPAL_stored_after_LI.free))
print(common_cols)


# Append datasets using common columns
appended_data_GV_JPAL <- bind_rows(
  select(changed_df_GV_after_LI.stored.free, all_of(common_cols)),
  select(changed_df_JPAL_stored_after_LI.free, all_of(common_cols)),
  .id = "Dataset"
)

# View the appended data
View(appended_data_GV_JPAL)

na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(chlorine_concentration))

View(na_rows)

na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(Date))

View(na_rows)
print(unique(appended_data_GV_JPAL$village))
na_rows <- appended_data_GV_JPAL %>%
  filter(is.na(village))


View(appended_data_GV_JPAL)
# Define colorblind friendly colors

plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV <- appended_data_GV_JPAL %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV$Date, na.rm = TRUE)
  
  
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
  min_plot_date <- min(min(JPAL_GV$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(JPAL_GV$Date), max(unique_install_dates)) + days(5)
  
  
  gv_j <- ggplot(JPAL_GV, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Stored water: Village_', i  ,'(Only Dates after last installation)'))
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j)
  plot_list_c[[i]] <- gv_j
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Stored_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}




#######################################################################

# NOW DIVIDE COMBINED PLOT BY TAP 

########################################################################


#GV dataset (only free and tap)

View(chlorine)

JPAL.tap <- df.tap 

# Make date usable
JPAL.tap$Date <- mdy(JPAL.tap$Date)

View(JPAL.tap)

# Append datasets while preserving all columns
JPAL_appended_tap <- full_join(JPAL.tap, Installation_df, by = c("Date", "village"))

View(JPAL_appended_tap)

# Checking if village names are unique 
print(unique(JPAL_appended_tap$village))

changed_df_JPAL_tap <- JPAL_appended_tap %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

changed_df_JPAL_tap <- changed_df_JPAL_tap %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(changed_df_JPAL_tap)

changed_df_JPAL_tap_after_LI <- changed_df_JPAL_tap %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(changed_df_JPAL_tap_after_LI$Date < changed_df_JPAL_tap_after_LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(changed_df_JPAL_tap_after_LI)


na_rows <- changed_df_JPAL_tap_after_LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)
#dropping NA values
changed_df_JPAL_tap_after_LI <- changed_df_JPAL_tap_after_LI %>%
  drop_na(chlorine_concentration)

View(changed_df_JPAL_tap_after_LI)

#check again for NA values
na_rows <- changed_df_JPAL_tap_after_LI%>%
  filter(is.na(chlorine_concentration))



#----------------------------------------------------------------------------
###EXCLUDE DATES BEFORE INSTALLATION FROM GV DATASET AS WELL 
#----------------------------------------------------------------------------



changed_df_JPAL_tap_after_LI$Test <- gsub("Free_Chlorine_stored"    , "Free Chlorine", changed_df_JPAL_stored_after_LI$Test)

changed_df_JPAL_tap_after_LI$Test <- gsub("Total_Chlorine_stored"    , "Total Chlorine", changed_df_JPAL_stored_after_LI$Test)


#We want only stored values from GV datastet

print(unique(changed_df_GV_after_LI$Distance))
changed_df_GV_after_LI.tap <- changed_df_GV_after_LI %>% filter(Distance == "Tap")

View(changed_df_GV_after_LI.tap)


#filter out free chlorine only from both

changed_df_GV_after_LI.tap.free <- changed_df_GV_after_LI.tap %>% filter(chlorine_test == "Free Chlorine")


View(changed_df_GV_after_LI.tap.free)



changed_df_JPAL_tap_after_LI.free <- changed_df_JPAL_tap_after_LI %>% filter(Test == "Free Chlorine")


View(changed_df_JPAL_tap_after_LI.free)



changed_df_GV_after_LI.tap.free$Organization <- "Gram Vikas"
changed_df_JPAL_tap_after_LI.free$Organization <- "J-PAL"
names(changed_df_GV_after_LI.tap.free)
names(changed_df_JPAL_tap_after_LI.free)

changed_df_GV_after_LI.tap.free <- rename(changed_df_GV_after_LI.tap.free, Test = chlorine_test)
# Get common column names

changed_df_GV_after_LI.tap.free <- select(changed_df_GV_after_LI.tap.free, -chlorine_test_type, -location)
changed_df_GV_after_LI.tap.free <- select(changed_df_GV_after_LI.tap.free, -installation_status, -Ins_status)
changed_df_GV_after_LI.tap.free <- rename(changed_df_GV_after_LI.tap.free, Source = Distance)


common_cols <- intersect(names(changed_df_GV_after_LI.tap.free), names(changed_df_JPAL_tap_after_LI.free))
print(common_cols)


# Append datasets using common columns
appended_data_GV_JPAL_tap <- bind_rows(
  select(changed_df_GV_after_LI.tap.free, all_of(common_cols)),
  select(changed_df_JPAL_tap_after_LI.free, all_of(common_cols)),
  .id = "Dataset"
)

# View the appended data
View(appended_data_GV_JPAL_tap)

na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(chlorine_concentration))

View(na_rows)

na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(Date))

View(na_rows)
print(unique(appended_data_GV_JPAL_tap$village))
na_rows <- appended_data_GV_JPAL_tap %>%
  filter(is.na(village))


plot_list_c <- list()

# Loop through each village
for (i in village_list) {
  print(paste("Processing village:", i))
  
  # Filter GV_free dataset for the current village
  JPAL_GV_tap <- appended_data_GV_JPAL_tap %>% filter(village == i)
  #df.vil.cl$Date <- mdy(df.vil.cl$Date)
  
  #JPAL_GV$Date <- mdy(JPAL_GV$Date)
  max_date <- max(JPAL_GV_tap$Date, na.rm = TRUE)
  
  
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
  min_plot_date <- min(min(JPAL_GV_tap$Date), min(unique_install_dates)) - days(5)
  max_plot_date <- max(max(JPAL_GV_tap$Date), max(unique_install_dates)) + days(5)
  
  
  gv_j_t <- ggplot(JPAL_GV_tap, aes(x = Date, y = chlorine_concentration, color = Organization, group = 1)) +
    geom_line(size = 1) + # Increase line thickness
    geom_point(size = 3) +
    geom_hline(yintercept = c(0.2, 0.6), linetype = "twodash", color = "black") +
    # Add x-axis and y-axis lines
    geom_hline(yintercept = seq(0, 2, by = 0.1), linetype = "dotted", color = "gray") +
    geom_vline(xintercept = seq(min_plot_date, max_plot_date, by = "1 week"), linetype = "dotted", color = "gray") +
    # Adjusted annotations
    annotate("text", x = max_date, y = 0.19, label = "Targeted Range", hjust = 1, size = 3) +
    annotate("text", x = max_date, y = 0.59, label = "Targeted Range", hjust = 1, size = 3) +
    # Add geom_vline for each installation date
    geom_vline(
      data = installations[installations$Ins_status == "first_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[1]
    ) +
    geom_vline(
      data = installations[installations$Ins_status == "last_installation_date", ],
      aes(xintercept = Date), linetype = "solid", color = colorblind_palette[2]
    ) +
    # Add geom_vline for each unique installation date
    geom_vline(
      data = installations,
      aes(xintercept = Date), linetype = "dashed", color = colorblind_palette[3]
    ) +
    # Adjust the position of annotations for first and last installation dates
    annotate("text", x = first_installation_date, y = Inf, label = "First Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[1]) +
    annotate("text", x = last_installation_date, y = Inf, label = "Last Installation", hjust = 2, angle = 90, size = 3.5, color = colorblind_palette[2]) +
    labs(title = paste0('GV-JPAL plot: Village_', i), x = "Date", y = "Chlorine Concentration") + # Added Y-axis label
    scale_x_date(
      limits = c(min_plot_date, max_plot_date), # Set x-axis limits based on combined data with padding
      date_breaks = '3 day', 
      labels = scales::date_format("%b %d")
    ) +
    scale_y_continuous(limits = c(0.00, 2.00), breaks = seq(0, 2, by = 0.1)) +
    theme(
      legend.text = element_text(size = 8), # Increased legend text size
      legend.key.size = unit(0.5, "cm"),   # Reduce legend key size
      legend.box = "vertical",       # Change legend box to vertical
      legend.spacing.y = unit(0.5, "cm"),  # Add spacing between legends
      legend.position = "right",       # Position legends at the right
      legend.justification = "top",
      legend.box.just = "right",
      legend.margin = margin(0, 0, 6, 0),  # Adjust legend margins
      axis.text.x = element_text(angle = 90, size = 10),
      panel.background = element_rect(fill = "white"), # Change background color to white
      panel.border = element_rect(color = "black", fill = NA), # Add border around plot
      panel.grid.major = element_blank(), # Remove major gridlines
      panel.grid.minor = element_blank(), # Remove minor gridlines
      axis.line = element_line(color = "black") # Add axis lines
    ) +
    scale_color_manual(values = c("J-PAL" = colorblind_palette[5], "Gram Vikas" = colorblind_palette[1])) + # Use colorblind friendly colors and specify colors for each group
    scale_shape_manual(values = c(16, 17)) + # Change shapes
    ggtitle(paste0('GV-JPAL plot for Free Chlorine for Tap water: Village_', i  ,'(Only Dates after last installation)'))
  
  
  print(paste("Plot for village", i, "generated."))
  print(gv_j_t)
  plot_list_c[[i]] <- gv_j_t
  file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Tap_combined_Village_", i, ".png")
  
  # Now, save the plot to the specified path
  ggsave(file_path, plot = gv_j_t, device = 'png', width = 10, height = 6, dpi = 300) # Increased dpi for better resolution
}



#CHLORINE STATS
#Classify it by stored and running water 

#------------------------------------------------------------------------------------#
#STORED WATER 
#-------------------------------------------------------------------------------------#

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




chlorine.AI <- chlorine 

# Make date usable
chlorine.AI$Date <- mdy(chlorine.AI$Date)

View(chlorine.AI)

# Append datasets while preserving all columns
chlorine.AI.IS <- full_join(chlorine.AI, Installation_df, by = c("Date", "village"))

View(chlorine.AI.IS)

# Checking if village names are unique 
print(unique(chlorine.AI.IS$village))

chlorine.AI.final <- chlorine.AI.IS %>%
  group_by(village) %>%
  mutate(current_installation_status = Date[which.max(Ins_status == "last_installation_date")])

chlorine.AI.final <- chlorine.AI.final %>%
  group_by(village) %>%
  mutate(first_installation_status = Date[which.max(Ins_status == "first_installation_date")])

View(chlorine.AI.final)

chlorine.only.LI <- chlorine.AI.final %>%
  group_by(village, Date) %>%
  filter(Date >= current_installation_status)  # Exclude dates earlier than current_installation_date

# Check if any dates before the current installation are still present
if (any(chlorine.only.LI$Date < chlorine.only.LI$current_installation_status)) {
  cat("Some dates before current installation are still present.\n")
} else {
  cat("Dates only before the current installation are removed for each village.\n")
}

View(chlorine.only.LI)


na_rows <- chlorine.only.LI%>%
  filter(is.na(chlorine_concentration))

View(na_rows)

chlorine.only.LI <- chlorine.only.LI %>%
  drop_na(chlorine_concentration)

# Extract "Stored Water" and "Tap Water" using str_extract()

#exclude dates after the last installation date for each village 
chlorine.only.LI$WaterType <- str_extract(chlorine.only.LI$Test, "Stored Water|Tap Water")
chlorine.only.LI$Chlorine_type <- str_extract(chlorine.only.LI$Test, "Total Chlorine|Free Chlorine")
chlorine_tc <- chlorine.only.LI %>% filter(Chlorine_type == "Total Chlorine")
chlorine_fc <- chlorine.only.LI %>% filter(Chlorine_type == "Free Chlorine")
View(chlorine_tc)
View(chlorine_fc)
View(chlorine.only.LI)

TC_stats <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Total Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )

FC_stats <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%  # Exclude rows with NA values in chlorine_concentration
  group_by(village, WaterType) %>%
  summarize(
    "Number of Samples" = n(),
    "Average Free Chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3)
  )




# Merge the datasets based on village, WaterType, and Number of Samples
merged_TC_FC <- merge(TC_stats, FC_stats, by = c("village", "WaterType", "Number of Samples"), all = TRUE)

# View the merged dataset
View(merged_TC_FC)

formatted_kable <- kbl(merged_TC_FC)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise average Chlorine Concentration (After the last installation) " = 5)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")

View(formatted_kable)

file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/merged_TC_FC.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)


#Only free chlorine 

FC_stats <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, WaterType) %>%
  summarize(
    "Number of Free Chlorine Samples" = n(),
    "Average Free chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(FC_stats)

formatted_kable <- kbl(FC_stats)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for free chlorine (After the last installation) " = 7)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/FC_stats.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)


#Only Total chlorine 


TC_stats <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, WaterType) %>%
  summarize(
    "Number of Total Chlorine Samples" = n(),
    "Average Total chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(TC_stats)

formatted_kable <- kbl(TC_stats)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for Total chlorine (After the last installation) " = 7)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/TC_stats.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)





#fREE CHLORINE (Distance too)


FC_stats_D <- chlorine_fc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, Distance, WaterType) %>%
  summarize(
    "Number of Free Chlorine Samples" = n(),
    "Average Free chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(FC_stats_D)

formatted_kable <- kbl(FC_stats_D)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for free chlorine categorised by Distance and water source (After the last installation) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/FC_stats_distance.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)




#TOTAL CHLORINE  DISTANCE WISE 

TC_stats_D <- chlorine_tc %>%
  filter(!is.na(chlorine_concentration)) %>%
  group_by(village, Distance, WaterType) %>%
  summarize(
    "Number of Total Chlorine Samples" = n(),
    "Average Total chlorine Concentration (mg/L)" = round(mean(chlorine_concentration, na.rm = TRUE), 3),
    "% Samples above 0.1 mg/L" = round(sum(chlorine_concentration > 0.1, na.rm = TRUE) / n() * 100, 2),
    "% Samples above 0.6 mg/L" = round(sum(chlorine_concentration > 0.6, na.rm = TRUE) / n() * 100, 2),
    "% Samples between 0.1 and 0.6 mg/L" = round(sum(chlorine_concentration > 0.1 & chlorine_concentration < 0.6 , na.rm = TRUE) / n() * 100, 2)
    
  )

View(TC_stats_D)

formatted_kable <- kbl(TC_stats_D)%>%
  kable_styling(bootstrap_options = "striped", full_width = TRUE) %>%
  add_header_above(c("Village wise sample % for Total chlorine categorised by Distance and water source (After the last installation) " = 8)) %>%
  row_spec(0, bold = TRUE, color = "black", background = "white") %>%
  column_spec(1, bold = TRUE) %>%
  column_spec(2, width = "75px")



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/TC_stats_distance.html"  # Replace this with your directory path

# Save to file
save_kable(formatted_kable, file_path)




# Load required libraries
library(ggplot2)

# Define colorblind-friendly palette
colorblind_palette <- c("#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Create a heatmap
heatmap <- ggplot(FC_stats, aes(x = village, y = WaterType, fill = `Average Free chlorine Concentration (mg/L)`)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = colorblind_palette[1], high = colorblind_palette[6]) +  # Using colorblind-friendly colors
  labs(title = "Average Free Chlorine Concentration by Village and Water Type",
       x = "Village",
       y = "Water Type",
       fill = "Average Free Chlorine Concentration (mg/L)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12, color = "black"),  # Adjust text properties
        axis.text.y = element_text(size = 12, color = "black"),  # Adjust text properties
        axis.title = element_text(size = 14, color = "black"),  # Adjust title properties
        legend.position = "right",  # Move legend to the right
        legend.title.align = 0.5,  # Center align legend title
        legend.text = element_text(size = 10, color = "black"),  # Increase legend text size and change color
        plot.title = element_text(size = 18, face = "bold", color = "black"),  # Increase title size, bold, and change color
        panel.grid = element_blank(),  # Remove gridlines for cleaner look
        panel.background = element_rect(fill = "white"))  # Set background color to white

# Print the heatmap
print(heatmap)


file_path <- paste0("C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Heatmap.png")

# Now, save the plot to the specified path
ggsave(file_path, plot = heatmap, device = 'png', width = 10, height = 6, bg= "white", dpi = 300) # Increased dpi for better resolution


print(unique(FC_stats$village))


install.packages("sf")
library(sf)
# Replace the path below with the path to your shapefile
shapefile_path <- "C:/Users/Archi Gupta/Downloads/Village Boundary Database/RAYAGARHA.shp"

# Read the shapefile
my_shapefile <- st_read(shapefile_path)

# Check the contents
plot(my_shapefile)


# Check the unique values in the column representing village names
unique_tehsil <- unique(my_shapefile$TEHSIL)
print(unique_tehsil)





# Convert all village names to lowercase

my_shapefile$VILLAGE <- tolower(my_shapefile$VILLAGE)

# Install and load the stringdist package
install.packages("stringdist")
library(stringdist)



# Create an empty list to store matches
matched_villages <- list()

# Set the threshold for similarity
threshold <- 0.3  # Adjust as needed, lower values allow for more spelling variations

# Loop through each village name in chlorine.only.LI dataset
for (village_chlorine in FC_stats$village) {
  # Use stringdist to find closest match in selected_tehsil dataset
  closest_match <- stringdist::amatch(village_chlorine, my_shapefile$VILLAGE, method = "lv", maxDist = threshold * nchar(village_chlorine))
  
  # If a match is found, add it to the list
  if (!is.na(closest_match)) {
    matched_villages[[village_chlorine]] <- my_shapefile$VILLAGE[closest_match]
  }
}

# Print the matched villages
matched_villages



my_shapefile$VILLAGE <- gsub("bichkota"    , "bichikote", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("karnipadu"    , "karnapadu", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("gopikanhubadi"    , "gopi kankubadi", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("biranarayanpur"    , "birnarayanpur", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("mukundapur"    , "mukundpur", my_shapefile$VILLAGE)
my_shapefile$VILLAGE <- gsub("nathama"    , "nathma", my_shapefile$VILLAGE)


matched_villages <- list()

# Set the threshold for similarity
threshold <- 0.3  # Adjust as needed, lower values allow for more spelling variations

# Loop through each village name in chlorine.only.LI dataset
for (village_chlorine in FC_stats$village) {
  # Use stringdist to find closest match in selected_tehsil dataset
  closest_match <- stringdist::amatch(village_chlorine, my_shapefile$VILLAGE, method = "lv", maxDist = threshold * nchar(village_chlorine))
  
  # If a match is found, add it to the list
  if (!is.na(closest_match)) {
    matched_villages[[village_chlorine]] <- my_shapefile$VILLAGE[closest_match]
  }
}

# Print the matched villages
matched_villages

# Assuming df is your dataframe and "old_name" is the current column name you want to change
colnames(my_shapefile)[colnames(my_shapefile) == "VILLAGE"] <- "village"



# Create an empty data frame to store merged data
merged_data <- data.frame()

# Loop through each matched village
for (village_chlorine in names(matched_villages)) {
  # Get the matched village name from my_shapefile dataset
  matched_village_shapefile <- matched_villages[[village_chlorine]]
  
  # Subset data for the matched village from my_shapefile dataset
  village_data_shapefile <- my_shapefile[my_shapefile$village == matched_village_shapefile, ]
  
  # Subset data for the matched village from chlorine.only.LI dataset
  village_data_chlorine <- FC_stats[FC_stats$village == village_chlorine, ]
  
  # Merge the data for the matched village
  merged_data <- rbind(merged_data, merge(village_data_shapefile, village_data_chlorine, by = "village", all = TRUE))
}

# Print the merged data
View(merged_data)



print(unique(merged_data$village))


na_rows <- merged_data%>%
  filter(is.na(village))

View(na_rows)

merged_data<- merged_data %>%
  drop_na(village)

View(merged_data)

names(merged_data)
merged_data <- select(merged_data, -TEHSIL, -DISTRICT, -STATE)


# Load the required libraries
library(ggplot2)
library(sf)
install.packages("plotly")
library(plotly)

names(merged_data)

# Convert merged_data to sf object
merged_data_sf <- st_as_sf(merged_data)

# Extract unique villages from your dataset
unique_villages <- unique(merged_data$village)

merged_data_sf <- merged_data_sf %>% filter (WaterType == "Stored Water")

# Filter merged_data_sf to include only villages present in your dataset
merged_data_sf <- merged_data_sf[merged_data_sf$village %in% unique_villages, ]

View(merged_data_sf)
# Create the choropleth map
chloropleth_map <- ggplot() +
  geom_sf(data = merged_data_sf, aes(fill = `% Samples between 0.1 and 0.6 mg/L`, text = village), color = "black", size = 0.5) +
  scale_fill_gradient(name = "Chlorine Concentration", low = "#E69F00", high = "#56B4E9") +  # Colorblind-friendly colors
  labs(title = "% Stored Samples between 0.1 and 0.6 mg/L for free chlorine ", 
       caption = "Source: Your Data Source") +  # Add title and caption
  theme_minimal() +  # Choose a theme
  theme(legend.position = "right")  # Adjust legend position

# Convert the ggplot to a plotly object
interactive_choropleth <- ggplotly(chloropleth_map, height = 600, width = 800)  # Increase map size

# Print the interactive choropleth map
print(interactive_choropleth)


install.packages("htmlwidgets")

library(htmlwidgets)

# Assuming map is stored in a variable called 'map'


# Convert the ggplot to a plotly object with specified projection
interactive_choropleth <- ggplotly(
  chloropleth_map, 
  height = 600, 
  width = 800, 
  config = list(
    geo = list(
      projection = list(type = "equirectangular")  # Set projection type
    )
  )
)



file_path <- "C:/Users/Archi Gupta/Box/Data/99_Archi_things in progress/Choropleth.html"



# Save the map with specified file path
saveWidget(interactive_choropleth, file = file_path)
#more vars




########################################
# Assuming you have spatial data for villages and blocks in merged_data_sf and block_data_sf respectively


















# Load the required libraries
library(plotly)
library(sf)

# Convert merged_data to sf object
merged_data_sf <- st_as_sf(merged_data)

# Extract unique villages from your dataset
unique_villages <- unique(merged_data$village)

# Filter merged_data_sf to include only villages present in your dataset
merged_data_sf <- merged_data_sf[merged_data_sf$village %in% unique_villages, ]

# Create the choropleth map
chloropleth_map <- ggplot() +
  geom_sf(data = merged_data_sf, aes(fill = `Number of Free Chlorine Samples`), color = "black", size = 0.5) +
  geom_sf(data = merged_data_sf, aes(fill = `Average Free chlorine Concentration (mg/L)`), color = "black", size = 0.5, alpha = 0.5) +  # Add another variable
  scale_fill_gradient(name = "No. of free chlorine samples", low = "#E69F00", high = "#56B4E9") +  # Colorblind-friendly colors for both variables
  labs(title = "Chlorine Concentration Spread over Villages", 
       caption = "Source: Your Data Source") +  # Add title and caption
  theme_minimal() +  # Choose a theme
  theme(legend.position = "right") +  # Adjust legend position
  geom_text(data = merged_data_sf, aes(label = village, x = longitude, y = latitude), size = 3, nudge_y = 0.1)  # Add village labels with x and y aesthetics

# Convert the ggplot to a plotly object
interactive_choropleth <- ggplotly(chloropleth_map, height = 600, width = 800)  # Increase map size

# Print the interactive choropleth map
print(interactive_choropleth)

































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

# List of values not in date format
#non_date_values <- c("45268.0", "45269.0", "45270.0", "45271.0", "45272.0", "45285.0",
#"45286.0", "45288.0", "45289.0", "45290.0", "45291.0", "45299.0",
#"45300.0", "45302.0", "45303.0", "45304.0", "45305.0", "45308.0",
#"45312.0", "45324.0", "45353.0", "45384.0", "45445.0", "45628.0")

# Convert reshaped_GV.df$Date to character to match non_date_values
#reshaped_GV.df <- mutate(reshaped_GV.df, Date = as.character(Date))

# Create convert_date variable containing non-date values
#reshaped_GV.df <- mutate(reshaped_GV.df, convert_date = ifelse(Date %in% non_date_values, Date, NA))


#reshaped_GV.df$converted_date <- as.Date(as.numeric(reshaped_GV.df$convert_date), origin = "1899-12-30")

#View(reshaped_GV.df)

# Create a new dataframe
#new_df <- reshaped_GV.df


#View(new_df)
#print(unique(new_df$Date))
# Convert Date variable to "YMD" format

# Current year

# Verify the conversio

#reshaped_GV.df$Date <- as.Date(reshaped_GV.df$Date)


#reshaped_GV.df$Date <- ymd(reshaped_GV.df$Date)



# Assuming reshaped_GV.df is your data frame

# Combine Date and converted_date variables into final_date
#reshaped_GV.df <- mutate(reshaped_GV.df, final_date = coalesce(converted_date, Date))

# If you no longer need the Date and converted_date columns, you can remove them
#reshaped_GV.df <- select(reshaped_GV.df, -Date, -converted_date)
#reshaped_GV.df <- select(reshaped_GV.df, -convert_date)


#print(unique(reshaped_GV.df$final_date))


# Find the indices of rows with the dates to be replaced
#indices_to_replace <- which(reshaped_GV.df$final_date %in% c("2024-03-02", "2024-04-02", "2024-06-02"))

# Replace the dates with the desired dates
#reshaped_GV.df$final_date[indices_to_replace] <- c("2024-02-03", "2024-02-04", "2024-02-06")


# Assuming reshaped_GV.df is your data frame

# Filter rows where final_date is NA
#na_final_date_rows <- reshaped_GV.df$final_date %in% NA
#print(na_final_date_rows)


#reshaped_GV.df <- reshaped_GV.df %>%
#rename(Date = final_date)
























# Load the required libraries
library(plotly)
library(sf)

# Convert merged_data to sf object
merged_data_sf <- st_as_sf(merged_data)

# Extract unique villages from your dataset
unique_villages <- unique(merged_data$village)

# Filter merged_data_sf to include only villages present in your dataset
merged_data_sf <- merged_data_sf[merged_data_sf$village %in% unique_villages, ]

# Create the choropleth map
chloropleth_map <- ggplot() +
  geom_sf(data = merged_data_sf, aes(fill = `Number of Free Chlorine Samples`), color = "black", size = 0.5) +
  geom_sf(data = merged_data_sf, aes(fill = `Average Free chlorine Concentration (mg/L)`), color = "black", size = 0.5, alpha = 0.5) +  # Add another variable
  scale_fill_gradient(name = "No. of free chlorine samples", low = "#E69F00", high = "#56B4E9") +  # Colorblind-friendly colors for both variables
  labs(title = "Chlorine Concentration Spread over Villages", 
       caption = "Source: Your Data Source") +  # Add title and caption
  theme_minimal() +  # Choose a theme
  theme(legend.position = "right") +  # Adjust legend position
  geom_text(data = merged_data_sf, aes(label = village, x = longitude, y = latitude), size = 3, nudge_y = 0.1)  # Add village labels with x and y aesthetics

# Convert the ggplot to a plotly object
interactive_choropleth <- ggplotly(chloropleth_map, height = 600, width = 800)  # Increase map size

# Print the interactive choropleth map
print(interactive_choropleth)




install.packages("shiny")
library(shiny)




# Define UI
ui <- fluidPage(
  titlePanel("Chlorine Concentration Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("village", "Choose a Village:",
                  choices = unique(chlorine$village)),
      selectInput("testType", "Choose Test Type:",
                  choices = unique(chlorine$chlorine_test_type))
    ),
    mainPanel(
      plotlyOutput("chlorinePlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$chlorinePlot <- renderPlotly({
    # Filter data based on input
    filtered_data <- chlorine %>%
      filter(village == input$village, chlorine_test_type == input$testType)
    
    # Create plot
    plot <- plot_ly(filtered_data, x = ~Date, y = ~chlorine_concentration,
                    type = 'scatter', mode = 'lines+markers',
                    color = ~Test)
    plot
  })
}

# Run the application
shinyApp(ui = ui, server = server)


install.packages("shinyWidgets")
library("shinyWidgets")

ui <- navbarPage("Chlorine Concentration Dashboard",
                 tabPanel("Data Visualization",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("village", "Choose a Village:",
                                          choices = c("All", unique(chlorine$village))),
                              selectInput("testType", "Choose Test Type:",
                                          choices = c("All", unique(chlorine$chlorine_test_type))),
                              sliderInput("distanceRange", "Select Distance Range:",
                                          min = min(chlorine$Distance, na.rm = TRUE), 
                                          max = max(chlorine$Distance, na.rm = TRUE),
                                          value = c(min(chlorine$Distance, na.rm = TRUE), max(chlorine$Distance, na.rm = TRUE))),
                              pickerInput("test", "Select Test:",
                                          choices = unique(chlorine$Test), 
                                          options = list(`actions-box` = TRUE), 
                                          multiple = TRUE)
                            ),
                            mainPanel(
                              plotlyOutput("chlorinePlot")
                            )
                          )
                 )
                 # You can add more tabs or tabPanels here for additional pages or visualizations.
)



server <- function(input, output) {
  output$chlorinePlot <- renderPlotly({
    # Filter data based on input with additional conditions
    filtered_data <- chlorine %>%
      filter((village == input$village | input$village == "All") &
               (chlorine_test_type == input$testType | input$testType == "All") &
               Distance >= input$distanceRange[1] & Distance <= input$distanceRange[2] &
               Test %in% input$test)
    
    # Create plot with some enhancements
    plot <- plot_ly(filtered_data, x = ~Date, y = ~chlorine_concentration,
                    type = 'scatter', mode = 'lines+markers',
                    color = ~Test, colors = "Viridis",
                    marker = list(size = 10, opacity = 0.6)) %>%
      layout(title = "Chlorine Concentration Over Time",
             xaxis = list(title = "Date"),
             yaxis = list(title = "Chlorine Concentration"))
    plot
  })
}

# Run the application
shinyApp(ui = ui, server = server)




































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

#_______________________________________________________________________________
#BOXPLOTS STORED WATER
#_______________________________________________________________________________

# Remove NA values from the dataset

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

# List of values not in date format
#non_date_values <- c("45268.0", "45269.0", "45270.0", "45271.0", "45272.0", "45285.0",
#"45286.0", "45288.0", "45289.0", "45290.0", "45291.0", "45299.0",
#"45300.0", "45302.0", "45303.0", "45304.0", "45305.0", "45308.0",
#"45312.0", "45324.0", "45353.0", "45384.0", "45445.0", "45628.0")

# Convert reshaped_GV.df$Date to character to match non_date_values
#reshaped_GV.df <- mutate(reshaped_GV.df, Date = as.character(Date))

# Create convert_date variable containing non-date values
#reshaped_GV.df <- mutate(reshaped_GV.df, convert_date = ifelse(Date %in% non_date_values, Date, NA))


#reshaped_GV.df$converted_date <- as.Date(as.numeric(reshaped_GV.df$convert_date), origin = "1899-12-30")

#View(reshaped_GV.df)

# Create a new dataframe
#new_df <- reshaped_GV.df


#View(new_df)
#print(unique(new_df$Date))
# Convert Date variable to "YMD" format

# Current year

# Verify the conversio

#reshaped_GV.df$Date <- as.Date(reshaped_GV.df$Date)


#reshaped_GV.df$Date <- ymd(reshaped_GV.df$Date)



# Assuming reshaped_GV.df is your data frame

# Combine Date and converted_date variables into final_date
#reshaped_GV.df <- mutate(reshaped_GV.df, final_date = coalesce(converted_date, Date))

# If you no longer need the Date and converted_date columns, you can remove them
#reshaped_GV.df <- select(reshaped_GV.df, -Date, -converted_date)
#reshaped_GV.df <- select(reshaped_GV.df, -convert_date)


#print(unique(reshaped_GV.df$final_date))


# Find the indices of rows with the dates to be replaced
#indices_to_replace <- which(reshaped_GV.df$final_date %in% c("2024-03-02", "2024-04-02", "2024-06-02"))

# Replace the dates with the desired dates
#reshaped_GV.df$final_date[indices_to_replace] <- c("2024-02-03", "2024-02-04", "2024-02-06")


# Assuming reshaped_GV.df is your data frame

# Filter rows where final_date is NA
#na_final_date_rows <- reshaped_GV.df$final_date %in% NA
#print(na_final_date_rows)


#reshaped_GV.df <- reshaped_GV.df %>%
#rename(Date = final_date)

#------------------------------------------------------------------------------------#
#STORED WATER 
#-------------------------------------------------------------------------------------#

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




