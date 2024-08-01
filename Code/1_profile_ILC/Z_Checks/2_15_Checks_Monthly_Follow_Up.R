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

#---------------------------------Loading functions------------------------------


tc_stats <- function(idexx_data){
  
  tc <- idexx_data%>%
    group_by(assignment, sample_type) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      #"Upper CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 + 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      # "Lower CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   round(est - qt(0.975, df.residual(model)) * se, 1)
      # },
      # "Upper CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   round(est + qt(0.975, df.residual(model)) * se, 1)
      # },
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      #"Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 + 
      #  (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      # "Lower CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   round(est - qt(0.975, df.residual(model)) * se, 1)
      # },
      # "Upper CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   round(est + qt(0.975, df.residual(model)) * se, 1)
      # },
      "Median MPN E. coli/100 mL" = median(ec_mpn),
      "Average Free Chlorine Concentration (mg/L)" = round(mean(tap_water_fc), 3)
    )
  
  # tc <- tc%>%
  #   #Adjusting so the CI cannot be more or less than 0 or 100
  #   mutate(`Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0,
  #                                      `Lower CI - EC` >= 0 ~ `Lower CI - EC`))%>%
  #   mutate(`Upper CI - TC` = case_when(`Upper CI - TC` > 100 ~ 100,
  #                                      `Upper CI - TC` <= 100 ~ `Upper CI - TC`))
  return(tc)
}



#----------------------------------Loading Cleaned Data---------------------------------

#Monthly IDEXX data
idexx <- read_csv(paste0(user_path(),"/3_final/idexx_monthly_master_cleaned.csv"))

#Monthly household survey data
ms <- read_csv(paste0(user_path(), "/3_final/1_10_monthly_follow_up_cleaned.csv"))





#-----------------------------------IDEXX Data Check-----------------------------------



#Checking for duplicate IDs
idexx%>%
  count(sample_ID)%>% 
  filter(n > 1)
idexx%>%
  count(unique_bag_id)%>% 
  filter(n > 1)
#Sample ID 20351 is duplicated. Sample ID was recorded incorrectly in the survey. 
#Bag ID 90722 corresponds to ID 20354
#Change made in cleaning code

#Checking IDs which do not match between survey data and lab data
#Gathering IDEXX sample IDs
idexx_ids <- idexx$sample_ID
#Gathering monthly survey sample IDs
ms_sample_ids <- cbind(ms$tap_sample_id, ms$stored_sample_id)%>%
  data.frame()%>%
  pivot_longer(cols = c("X1", "X2"), values_to = "sample_ID", values_drop_na = TRUE, names_to = "sample_type")
#Filtering out
idexx_id_check <- idexx%>%
  filter(!(sample_ID %in% ms_sample_ids$sample_ID))


#Summarizing desc stats
idexx_desc_stats <- tc_stats(idexx)
t(idexx_desc_stats)

#Creating table output
idexx_desc_stats <- stargazer(idexx_desc_stats, summary=F, title= "Monthly Survey - IDEXX Results",float=F,rownames = F,
          covariate.labels=NULL, font.size = "tiny", column.sep.width = "1pt", out=paste0(overleaf(),"Table/Desc_stats_idexx.tex"))



