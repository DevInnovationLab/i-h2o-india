
#  title: "Upload_Google_Drive"
#  author: "Astha Vohra"
#  date: "2023-09-24"

# install the packages
#install.packages("googledrive", "googlesheets4", "readxl", "googlesheets", "dplyr", "lubridate")

# load the libraries
library(readxl) 
library(googledrive)
library(googlesheets4)
library(DBI)
library(RSQLite)
library(googlesheets)
library(dplyr)
library(lubridate)



user_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user==""){
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user == ""){
    path = ""
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
  else if (user==""){
    github = ""
  } 
  else if (user == "") {
    github = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

# setting google drive directory
user <- Sys.info()["user"]
if (user == "asthavohra") {
  gdrive = "https://drive.google.com/drive/folders/1KMZWgAgenvU20ac-9kfJUK2spON8owqO"
} 
if (user==""){
  gdrive = ""
} 
if (user == "") {
  gdrive = ""
} 

# Upload the file
td<- drive_get(gdrive)
name_df <- paste0( "HH_Survey_preload_", today())
drive_upload(paste0(user_path(), "99_Preload/Followup_preload.xlsx"), name = name_df, type = "spreadsheet", path= as_id(td))
