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


#------------------------ Load the data ----------------------------------------#


df.main <- read_stata(paste0(pre_path(),"1_8_Endline_XXX.dta"))
View(df.main)

#removing _merge var
df.main$`_merge` <- NULL

#removing R_E prefix
names(df.main) <- gsub("^R_E_", "", names(df.main))

View(df.main)
# Apply as.character to all columns in df.main
df.main <- data.frame(lapply(df.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.main)

df.revisit <- read_stata(paste0(pre_path(),"1_9_Endline_revisit_final_XXX.dta"))

df.revisit.f <- subset(df.revisit, wash_applicable == 1)

# Display the filtered data frame to confirm the changes
View(df.revisit.f)

# Apply as.character to all columns in df.main
df.revisit.f <- data.frame(lapply(df.revisit.f, as.character), stringsAsFactors = FALSE)

# Full join on unique_id
merged_df <- full_join(df.main, df.revisit.f, by = "unique_id", suffix = c("_main", "_revisit"))

View(merged_df)

# Get common columns
common_cols <- intersect(names(df.main), names(df.revisit.f))
common_cols <- setdiff(common_cols, "unique_id")


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


#---------------------------------------------------------------
#REPLACING EMPTY STRINGS WITH NA VALUES 
#---------------------------------------------------------------

df.main <- read_stata(paste0(pre_path(),"1_8_Endline_XXX.dta"))
View(df.main)

#removing _merge var
df.main$`_merge` <- NULL

#removing R_E prefix
names(df.main) <- gsub("^R_E_", "", names(df.main))

View(df.main)
# Apply as.character to all columns in df.main
df.main <- data.frame(lapply(df.main, as.character), stringsAsFactors = FALSE)

# Display the structure of the modified data frame to confirm the changes
str(df.main)

df.revisit <- read_stata(paste0(pre_path(),"1_9_Endline_revisit_final_XXX.dta"))

df.revisit.f <- subset(df.revisit, wash_applicable == 1)

# Display the filtered data frame to confirm the changes
View(df.revisit.f)

# Apply as.character to all columns in df.main
df.revisit.f <- data.frame(lapply(df.revisit.f, as.character), stringsAsFactors = FALSE)


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
subset_df <- final_df %>% select(unique_id, water_source_prim, resp_available, instruction, n_new_members, n_hhmember_count, wash_applicable, Revisit_key)

# View the subset dataset
View(subset_df)



# Reattach the prefix R_E_ to all variables except unique_id
final_df <- final_df %>%
  rename_with(~ ifelse(. == "unique_id", ., str_c("R_E_", .)), .cols = -unique_id, -unique_id_num)

# View the final dataframe with renamed columns
View(final_df)

# Save the final_df dataset to the specified directory as a .dta file
output_path <- file.path(pre_path(), "final_df.dta")
write_dta(final_df, output_path)



library(stringr)

# Function to check for valid Stata variable names
is_valid_stata_name <- function(var_name) {
  return(str_detect(var_name, "^[a-zA-Z][a-zA-Z0-9_]{0,31}$"))
}

# Apply the function to variable names in final_df
invalid_names <- names(final_df)[!sapply(names(final_df), is_valid_stata_name)]

# Count the number of invalid variable names
num_invalid_names <- length(invalid_names)

# Print the invalid names and their count
print(invalid_names)
print(paste("Number of variables requiring renaming:", num_invalid_names))
