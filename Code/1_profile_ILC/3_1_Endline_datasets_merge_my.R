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


#DOING THE FINAL REPLACEMENT 

# Identify common columns, excluding 'unique_id'
common_cols <- intersect(names(df.main), names(df.revisit.f))
common_cols <- setdiff(common_cols, "unique_id")

# Merge based on matched unique_id (inner join)
matched_df <- inner_join(df.main, df.revisit.f, by = "unique_id", suffix = c("_main", "_revisit"))


# Update df.main with matched and common variables from df.revisit.f
for (col in common_cols) {
  matched_indices <- match(df.main$unique_id, matched_df$unique_id)
  # Replace only where the matched indices are not NA and the value in revisit is not NA
  is_not_na <- !is.na(matched_df[[paste0(col, "_revisit")]])
  df.main[[col]][matched_indices[is_not_na]] <- matched_df[[paste0(col, "_revisit")]][is_not_na]
}

# Final merge to include all records and columns
final_df <- full_join(df.main, df.revisit.f, by = "unique_id")

# View the final merged dataset
View(final_df)
