#India ILC Pilot - File Path Configuration Script
#Author: Jeremy Lowe
#Date: 6/5/24


#------------------------ setting user path ----------------------------------------#


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
