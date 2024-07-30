#------------------------------------------------ 
# title: "Code for Checks for High-frequency Follow Ups"
# author: "Jeremy Lowe, Archi Gupta"
# modified date: "2024-07-19"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------


library(rsurveycto)
library(expss)
library(labelled)
library(httr)
library(lubridate)
library(quantitray)
library(sjmisc)
library(knitr)
library(kableExtra)
library(readxl)
library(experiment)
library(stargazer)
library(readxl)
library(haven)
library(googlesheets4)
library(ggsignif)
library(patchwork)
library(table1)
library(gtsummary)
library(gt)
library(webshot2)
library(clubSandwich)
library(sandwich)
library(lmtest)
library(broom)
library(tidyverse)



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
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

github <- github_path()

#Setting overleaf
overleaf_path <- function() {
  # Return a hardcoded path to Overleaf that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  #
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    
  } 
  else if (user=="akitokamei"){
    
    overleaf = "/Users/akitokamei/Dropbox/Apps/Overleaf"
    
  } 
  else if (user == "jerem"){
    overleaf = "C:/Users/jerem/DropBox/Apps/Overleaf"
  }  
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}

overleaf <- overleaf_path()




#----------------------------------Loading Cleaned Data---------------------------------










#-----------------------------------IDEXX Data Check-----------------------------------



#Checking cases of NA for total coliform and e coli
#xx <- idexx%>%
# filter(is.na(cf_mpn) == TRUE)
#xxx <- idexx%>%
# filter(y_large == 49 & y_small == 48)





