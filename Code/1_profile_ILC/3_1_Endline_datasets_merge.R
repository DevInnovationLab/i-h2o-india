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


#------------------------ Load the data ----------------------------------------#


df.main <- read_stata(paste0(Final_path(),"1_8_Endline_Census_cleaned.dta"))

View(df.main)

#removing _merge var
df.main$`_merge` <- NULL

#removing R_E prefix
#names(df.main) <- gsub("^R_E_", "", names(df.main))

# Apply as.character to all columns in df.main
df.main <- data.frame(lapply(df.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.main)

df.revisit <- read_stata(paste0(Final_path(),"1_9_Endline_revisit_final_cleaned.dta"))

View(df.revisit)
df.revisit.f <- subset(df.revisit, R_E_wash_applicable == 1)

# Display the filtered data frame to confirm the changes
View(df.revisit.f)

# Apply as.character to all columns in df.main
df.revisit.f <- data.frame(lapply(df.revisit.f, as.character), stringsAsFactors = FALSE)

#removing _merge var
df.revisit.f$`_merge` <- NULL


# Full join on unique_id
merged_df <- full_join(df.main, df.revisit.f, by = "unique_id", suffix = c("_main", "_revisit"))

names(merged_df)
View(merged_df)

# Get common columns
common_cols <- intersect(names(df.main), names(df.revisit.f))
common_cols <- setdiff(common_cols, "unique_id")

print(common_cols)

#also print different col names

# Extract column names from both datasets
main_cols <- names(df.main)
revisit_cols <- names(df.revisit.f)

# Identify columns that are present in one dataset but not the other
unique_to_main <- setdiff(main_cols, revisit_cols)
unique_to_revisit <- setdiff(revisit_cols, main_cols)

# Print the non-matching column names
cat("Columns unique to df.main:\n")
print(unique_to_main)

cat("\nColumns unique to df.revisit.f:\n")
print(unique_to_revisit)


# Initialize a data frame to store flags and comparisons
flagged_df <- data.frame(unique_id = merged_df$unique_id)

# Iterate through common columns to flag discrepancies and store values
for (col in common_cols) {
  flag_col <- paste0("flag_", col)
  main_col <- paste0(col, "_main")
  revisit_col <- paste0(col, "_revisit")
  
  flagged_df[[flag_col]] <- ifelse(!is.na(merged_df[[main_col]]) & merged_df[[main_col]] != "" & 
                                     !is.na(merged_df[[revisit_col]]) & merged_df[[revisit_col]] != "" & 
                                     merged_df[[main_col]] != merged_df[[revisit_col]],
                                   1, 0)
  
  # Add columns for values from df.main and df.revisit.f where flag is 1
  flagged_df[[paste0(col, "_main_value")]] <- ifelse(flagged_df[[flag_col]] == 1, merged_df[[main_col]], NA)
  flagged_df[[paste0(col, "_revisit_value")]] <- ifelse(flagged_df[[flag_col]] == 1, merged_df[[revisit_col]], NA)
}

# Filter rows to keep only those where any flag is 1
flagged_df <- flagged_df[rowSums(flagged_df[ , grepl("^flag_", names(flagged_df))]) > 0, ]

# Remove flag columns where all values are 0
flagged_df <- flagged_df %>% select_if(function(col) !all(is.na(col) | col == 0))

# View the flagged dataframe
View(flagged_df)

#After comparing everything we found no flags 

#---------------------------------------------------------------
#REPLACING EMPTY STRINGS WITH NA VALUES 
#---------------------------------------------------------------

df.main <- read_stata(paste0(Final_path(),"1_8_Endline_Census_cleaned.dta"))

View(df.main)

#removing _merge var
df.main$`_merge` <- NULL

#removing R_E prefix
#names(df.main) <- gsub("^R_E_", "", names(df.main))

# Apply as.character to all columns in df.main
df.main <- data.frame(lapply(df.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.main)

df.revisit <- read_stata(paste0(Final_path(),"1_9_Endline_revisit_final_cleaned.dta"))

View(df.revisit)
df.revisit.f <- subset(df.revisit, R_E_wash_applicable == 1)

# Display the filtered data frame to confirm the changes
View(df.revisit.f)

# Apply as.character to all columns in df.main
df.revisit.f <- data.frame(lapply(df.revisit.f, as.character), stringsAsFactors = FALSE)

#removing _merge var
df.revisit.f$`_merge` <- NULL


# Function to replace empty strings with NA
replace_empty_with_na <- function(df) {
  df[df == ""] <- NA
  return(df)
}


# Apply the function to both datasets
df.main <- replace_empty_with_na(df.main)
df.revisit.f <- replace_empty_with_na(df.revisit.f)

# Check the result
str(df.main)
str(df.revisit.f)

#---------------------------------------------------------------
#DOING THE FINAL REPLACEMENT IN THE MAIN ENDLINE XXX DATASET 
#---------------------------------------------------------------

# Identify common columns, excluding 'unique_id'
common_cols <- intersect(names(df.main), names(df.revisit.f))
common_cols <- setdiff(common_cols, "unique_id")

# Match indices
matched_indices <- match(df.main$unique_id, df.revisit.f$unique_id)
valid_indices <- !is.na(matched_indices)

View(matched_indices)


# Update df.main with matched and common variables from df.revisit.f
for (col in common_cols) {
  revisit_values <- df.revisit.f[[col]][matched_indices[valid_indices]]
  df.main[[col]][valid_indices] <- revisit_values
}


# Merge additional columns from df.revisit.f that are not in df.main
additional_cols <- setdiff(names(df.revisit.f), names(df.main))
additional_data <- df.revisit.f %>% select(unique_id, all_of(additional_cols))

final_df <- left_join(df.main, additional_data, by = "unique_id")

# View the final merged dataset
View(final_df)


names(final_df)

# Tabulate the 'instruction' column
instruction_table <- table(final_df$instruction)

# Print the frequency table
print(instruction_table)

#putting this as a check 

# Create a subset dataset with the specified variables
subset_df <- final_df %>% select(unique_id, R_E_water_source_prim, R_E_resp_available, R_E_instruction, R_E_n_new_members, R_E_n_hhmember_count, R_E_wash_applicable, R_E_Revisit_key)

# View the subset dataset
View(subset_df)


# Save the final_df dataset to the specified directory as a .dta file
output_path <- file.path(Final_path(), "Endline_HH_level_merged_dataset_final.dta")
write_dta(final_df, output_path)





#---------------------------------------------------------------
#CHILD LEVEL DATASET MERGE 
#---------------------------------------------------------------

df.child.main <- read_stata(paste0(temp_path(),"U5_Child_23_24_part1.dta"))
View(df.child.main)

#removing _merge var
df.child.main$`_merge` <- NULL

#removing R_E prefix
#names(df.main) <- gsub("^R_E_", "", names(df.main))



# Apply as.character to all columns in df.main
df.child.main <- data.frame(lapply(df.child.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.child.main)



# Sort df.child.main by comb_child_comb_name_label alphabetically
df.child.main <- df.child.main %>% arrange(comb_child_comb_name_label)

# View the sorted dataset
View(df.child.main)

names(df.child.main)
df.child.main <- subset(df.child.main, comb_child_caregiver_present == 3 | comb_child_caregiver_present == 4 | comb_child_caregiver_present == 5 | comb_child_caregiver_present == 6 )

View(df.child.main)

df.child.revisit <- read_stata(paste0(temp_path(),"1_2_Endline_Revisit_U5_Child_23_24_part1.dta"))
View(df.child.revisit)


# Apply as.character to all columns in df.child.revisit
df.child.revisit <- data.frame(lapply(df.child.revisit, as.character), stringsAsFactors = FALSE)

#removing _merge var
df.child.revisit$`_merge` <- NULL

names(df.child.revisit)

# Sort df.child.main by comb_child_comb_name_label alphabetically
df.child.revisit <- df.child.revisit %>% arrange(comb_child_comb_name_label)


#df.child.revisit <- subset(df.child.revisit, comb_child_caregiver_present == 1)


# Full join on unique_id
merged_df <- full_join(df.child.main, df.child.revisit, by = "unique_id", suffix = c("_main", "_revisit"))

names(merged_df)
View(merged_df)

# Ensure child names are aligned correctly within each unique_id
merged_df <- merged_df %>%
  group_by(unique_id) %>%
  arrange(comb_child_comb_name_label_main, comb_child_comb_name_label_revisit, .by_group = TRUE) %>%
  ungroup()

View(merged_df)


subset <- merged_df %>% select (unique_id, comb_child_comb_name_label_main, comb_child_comb_name_label_revisit, comb_child_caregiver_name_main, comb_child_caregiver_name_revisit )
View(subset)

flagged_df <- data.frame(unique_id = subset$unique_id)

View(flagged_df)
# Check for duplicates and handle if necessary
duplicates <- merged_df[duplicated(merged_df$unique_id), ]
if (nrow(duplicates) > 0) {
  cat("There are duplicated unique_ids in the merged dataset.\n")
  # Handle duplicates if necessary (e.g., by aggregation, removing duplicates, etc.)
}

# Get common columns
common_cols <- intersect(names(df.child.main), names(df.child.revisit))
common_cols <- setdiff(common_cols, "unique_id")

print(common_cols)

#also print different col names

# Extract column names from both datasets
main_cols <- names(df.child.main)
revisit_cols <- names(df.child.revisit)

# Identify columns that are present in one dataset but not the other
unique_to_main <- setdiff(main_cols, revisit_cols)
unique_to_revisit <- setdiff(revisit_cols, main_cols)

# Print the non-matching column names
cat("Columns unique to df.child.main:\n")
print(unique_to_main)

cat("\nColumns unique to df.child.revisit.f:\n")
print(unique_to_revisit)


# Initialize a data frame to store flags and comparisons
flagged_df <- data.frame(unique_id = merged_df$unique_id)

# Iterate through common columns to flag discrepancies and store values
for (col in common_cols) {
  flag_col <- paste0("flag_", col)
  main_col <- paste0(col, "_main")
  revisit_col <- paste0(col, "_revisit")
  
  flagged_df[[flag_col]] <- ifelse(!is.na(merged_df[[main_col]]) & merged_df[[main_col]] != "" & 
                                     !is.na(merged_df[[revisit_col]]) & merged_df[[revisit_col]] != "" & 
                                     merged_df[[main_col]] != merged_df[[revisit_col]],
                                   1, 0)
  
  # Add columns for values from df.main and df.revisit.f where flag is 1
  flagged_df[[paste0(col, "_main_value")]] <- ifelse(flagged_df[[flag_col]] == 1, merged_df[[main_col]], NA)
  flagged_df[[paste0(col, "_revisit_value")]] <- ifelse(flagged_df[[flag_col]] == 1, merged_df[[revisit_col]], NA)
}

# Filter rows to keep only those where any flag is 1
flagged_df <- flagged_df[rowSums(flagged_df[ , grepl("^flag_", names(flagged_df))]) > 0, ]

# Remove flag columns where all values are 0
flagged_df <- flagged_df %>% select_if(function(col) !all(is.na(col) | col == 0))

# View the flagged dataframe
View(flagged_df)
names(flagged_df)

#We see here that names are inter changed 

#After comparing everything we found no flags 

#---------------------------------------------------------------
#REPLACING EMPTY STRINGS WITH NA VALUES 
#---------------------------------------------------------------

df.child.main <- read_stata(paste0(Final_path(),"1_1_Endline_U5_Child_23_24.dta"))
View(df.child.main)

#removing _merge var
df.child.main$`_merge` <- NULL

#removing R_E prefix
#names(df.main) <- gsub("^R_E_", "", names(df.main))

# Apply as.character to all columns in df.main
df.child.main <- data.frame(lapply(df.child.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.child.main)


df.child.revisit <- read_stata(paste0(Final_path(),"1_2_Endline_Revisit_U5_Child_23_24.dta"))
View(df.child.revisit)


# Apply as.character to all columns in df.child.revisit
df.child.revisit <- data.frame(lapply(df.child.revisit, as.character), stringsAsFactors = FALSE)

#removing _merge var
df.child.revisit$`_merge` <- NULL


# Function to replace empty strings with NA
replace_empty_with_na <- function(df) {
  df[df == ""] <- NA
  return(df)
}


# Apply the function to both datasets
df.child.main <- replace_empty_with_na(df.child.main)
df.child.revisit <- replace_empty_with_na(df.child.revisit)

# Check the result
str(df.child.main)
str(df.child.revisit)

#---------------------------------------------------------------
#DOING THE FINAL REPLACEMENT IN THE MAIN ENDLINE XXX DATASET 
#---------------------------------------------------------------

# Identify common columns, excluding 'unique_id'
common_cols <- intersect(names(df.child.main), names(df.child.revisit))
common_cols <- setdiff(common_cols, "unique_id")

# Match indices
matched_indices <- match(df.child.main$unique_id, df.child.revisit$unique_id)
valid_indices <- !is.na(matched_indices)

View(matched_indices)


# Update df.main with matched and common variables from df.revisit.f
for (col in common_cols) {
  revisit_values <- df.child.revisit[[col]][matched_indices[valid_indices]]
  df.child.main[[col]][valid_indices] <- revisit_values
}


# Merge additional columns from df.revisit.f that are not in df.main
additional_cols <- setdiff(names(df.child.revisit), names(df.child.main))
additional_data <-df.child.revisit %>% select(unique_id, all_of(additional_cols))

final_df <- left_join(df.child.main, additional_data, by = "unique_id")

# View the final merged dataset
View(final_df)


names(final_df)


#putting this as a check 

# Create a subset dataset with the specified variables
#subset_df <- final_df %>% select(unique_id, R_E_water_source_prim, R_E_resp_available, R_E_instruction, R_E_n_new_members, R_E_n_hhmember_count, R_E_wash_applicable, R_E_Revisit_key)

# View the subset dataset
#View(subset_df)


# Save the final_df dataset to the specified directory as a .dta file
output_path <- file.path(Final_path(), "Endline_Child_level_merged_dataset_final.dta")

write_dta(final_df, output_path)









