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
install.packages("geosphere")

#please note that starpolishr pacakge isn't available on CRAN so it has to be installed from github using rmeotes pacakage 
install.packages("remotes")
remotes::install_github("ChandlerLutz/starpolishr")
install.packages("ggrepel")
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
library(geosphere)
library(leaflet)
library(ggrepel)
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


raw_path <- function() {
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
knitr::opts_knit$set(root.dir = raw_path())



#------------------------ Load the data ----------------------------------------#

##importing geo location form data 
df.geo <- read.csv(paste0(raw_path(),"Geo location form_WIDE.csv"))  
View(df.geo)

df.geo  <- df.geo  %>%
  mutate( R_Cen_village_str = NA)

# Replace village name codes with their respective names
df.geo <- df.geo %>%
  mutate(R_Cen_village_str = case_when(
    village_name == "30701" ~ "Gopi Kankubadi",
    village_name == "50401" ~ "Birnarayanpur",
    village_name == "50501" ~ "Nathma",
    village_name == "30301" ~ "Tandipur",
    village_name == "20101" ~ "Badabangi",
    village_name == "40201" ~ "Bichikote",
    village_name == "10101" ~ "Asada",
    village_name == "30202" ~ "BK Padar",
    village_name == "30602" ~ "Mukundpur",
    village_name== "40101" ~ "Karnapadu",
    village_name == "40401" ~ "Naira",
    village_name == "10201" ~ "Sanagortha",
    village_name == "20201" ~ "Jaltar",
    village_name == "30202" ~ "BK Padar",
    village_name == "30501" ~ "Bhujbal",
    village_name == "40202" ~ "Gudiabandh",
    village_name == "40301" ~ "Mariguda",
    village_name == "50101" ~ "Dangalodi",
    village_name == "50201" ~ "Barijhola",
    village_name == "50301" ~ "Karlakana",
    village_name == "50402" ~ "Kuljing",
    TRUE ~ R_Cen_village_str  # Keep the original value if not matched
  ))
    


# Convert village_name to lowercase and remove leading/trailing whitespace
df.geo$R_Cen_village_str <- tolower(trimws(df.geo$R_Cen_village_str))

names(df.geo)

df.geo.f <- df.geo %>% select (village_name, R_Cen_village_str, landmark,  GPS_manual.Latitude, GPS_manual.Longitude, GPS_manual.Altitude, GPS_manual.Accuracy, a40_gps_handlongitude, a40_gps_handlatitude)

View(df.geo.f)


df.geo.trim <- df.geo.f %>% filter(village_name != "30601" & village_name != "30101" )

df.geo.trim.f <- df.geo.trim %>% filter(landmark == "1")

View(df.geo.trim.f)


# Convert the relevant variables to numeric if they are not already
df.geo.trim.f <- df.geo.trim.f %>%
  mutate(
    GPS_manual.Latitude = as.numeric(GPS_manual.Latitude),
    GPS_manual.Longitude = as.numeric(GPS_manual.Longitude),
    a40_gps_handlatitude = as.numeric(a40_gps_handlatitude),
    a40_gps_handlongitude = as.numeric(a40_gps_handlongitude)
  )

View(df.geo.trim.f)

# Replace NA values for GPS_manual.Latitude and GPS_manual.Longitude when R_Cen_village_str is "karlakana"
df.geo.trim.f <- df.geo.trim.f %>%
  mutate(
    GPS_manual.Latitude = case_when(
      R_Cen_village_str == "karlakana" & is.na(GPS_manual.Latitude) ~ 19.1535,  # Replace with the desired value
      TRUE ~ GPS_manual.Latitude
    ),
    GPS_manual.Longitude = case_when(
      R_Cen_village_str == "karlakana" & is.na(GPS_manual.Longitude) ~ 83.2342,  # Replace with the desired value
      TRUE ~ GPS_manual.Longitude
    )
  )

df.geo.trim.f <- df.geo.trim.f %>% select (village_name, R_Cen_village_str, landmark,  GPS_manual.Latitude, GPS_manual.Longitude, GPS_manual.Altitude, GPS_manual.Accuracy)

summary_stats <- df.geo.trim.f %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(GPS_manual.Latitude, na.rm = TRUE),
    sd_distance = sd(GPS_manual.Latitude, na.rm = TRUE),
    median_distance = median(GPS_manual.Latitude, na.rm = TRUE),
    IQR_distance = IQR(GPS_manual.Latitude, na.rm = TRUE)
  )

print(summary_stats)

summary_stats <- df.geo.trim.f %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(GPS_manual.Longitude, na.rm = TRUE),
    sd_distance = sd(GPS_manual.Longitude, na.rm = TRUE),
    median_distance = median(GPS_manual.Longitude, na.rm = TRUE),
    IQR_distance = IQR(GPS_manual.Longitude, na.rm = TRUE)
  )

print(summary_stats)


#-------------------------------------------------------------------

df.daily <- read.csv(paste0(raw_path(),"india_ilc_pilot_monitoring_WIDE.csv"))  

View(df.daily)

names(df.daily)

df.daily.view <- df.daily %>% select (village_name, GPS_ILC_device.Latitude, GPS_ILC_device.Longitude, GPS_ILC_device.Altitude, GPS_ILC_device.Accuracy)

View(df.daily.view)

df.daily  <- df.daily  %>%
  mutate( R_Cen_village_str = NA)

# Replace village name codes with their respective names
df.daily <- df.daily %>%
  mutate(R_Cen_village_str = case_when(
    village_name == "30701" ~ "Gopi Kankubadi",
    village_name == "50401" ~ "Birnarayanpur",
    village_name == "50501" ~ "Nathma",
    village_name == "30301" ~ "Tandipur",
    village_name == "20101" ~ "Badabangi",
    village_name == "40201" ~ "Bichikote",
    village_name == "10101" ~ "Asada",
    village_name == "30202" ~ "BK Padar",
    village_name == "30602" ~ "Mukundpur",
    village_name== "40101" ~ "Karnapadu",
    village_name == "40401" ~ "Naira",
    TRUE ~ R_Cen_village_str  # Keep the original value if not matched
  ))



# Convert village_name to lowercase and remove leading/trailing whitespace
df.daily$R_Cen_village_str <- tolower(trimws(df.daily$R_Cen_village_str))

df.daily.view <- df.daily %>% select (village_name, R_Cen_village_str,  GPS_ILC_device.Latitude, GPS_ILC_device.Longitude, GPS_ILC_device.Altitude, GPS_ILC_device.Accuracy)

View(df.daily.view)



df.chlorine <- df.daily %>% filter(village_name != "88888")

View(df.chlorine)

df.chlorine.trim <- df.chlorine %>% select (village_name, R_Cen_village_str,  GPS_ILC_device.Latitude, GPS_ILC_device.Longitude, GPS_ILC_device.Altitude, GPS_ILC_device.Accuracy)

View(df.chlorine.trim)

#_______________________________________________________________
#baseline census data
#_______________________________________________________________

df.census <- read_stata(paste0(pre_path(),"1_1_Census_cleaned_consented.dta"))

View(df.census)


names(df.census)

df.census.view <- df.census %>% select (R_Cen_village_name, R_Cen_a40_gps_latitude, R_Cen_a40_gps_longitude)

View(df.census.view)

df.census$R_Cen_village_str <- tolower(trimws(df.census$R_Cen_village_str))

summary_stats <- df.census  %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(R_Cen_a40_gps_latitude, na.rm = TRUE),
    sd_distance = sd(R_Cen_a40_gps_latitude, na.rm = TRUE),
    median_distance = median(R_Cen_a40_gps_latitude, na.rm = TRUE),
    IQR_distance = IQR(R_Cen_a40_gps_latitude, na.rm = TRUE)
  )

print(summary_stats)

summary_stats <- df.census %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(R_Cen_a40_gps_longitude, na.rm = TRUE),
    sd_distance = sd(R_Cen_a40_gps_longitude, na.rm = TRUE),
    median_distance = median(R_Cen_a40_gps_longitude, na.rm = TRUE),
    IQR_distance = IQR(R_Cen_a40_gps_longitude, na.rm = TRUE)
  )

print(summary_stats)




#_______________________________________________________________
#merging with chlorine data to get ILC device location
#_______________________________________________________________


# Merge df.census and df.chlorine.trim on the common variable R_Cen_village_str
merged_df <- merge(df.census, df.geo.trim.f, by = "R_Cen_village_str")

merged_df  <- merged_df  %>% filter(R_Cen_village_str != "karlakana")


#this dataset has the device cooridnates too 
View(merged_df)

merged_df_view <- merged_df %>% select(R_Cen_village_str, R_Cen_a40_gps_latitude, R_Cen_a40_gps_longitude, GPS_manual.Latitude, GPS_manual.Longitude )
View(merged_df_view)

merged_df  <- merged_df %>%
  mutate( Treat_Control = NA)


merged_df <- merged_df %>%
  mutate(Treat_Control= case_when(
    R_Cen_village_str == "gopi kankubadi" ~ "T",
    R_Cen_village_str == "birnarayanpur" ~ "T",
    R_Cen_village_str == "nathma" ~ "T" ,
    R_Cen_village_str == "tandipur" ~ "T" ,
    R_Cen_village_str == "badabangi" ~ "T" ,
    R_Cen_village_str == "bichikote" ~ "T" ,
    R_Cen_village_str == "asada" ~ "T" ,
    R_Cen_village_str == "mukundpur" ~ "T" ,
    R_Cen_village_str == "karnapadu" ~ "T" ,
    R_Cen_village_str == "naira" ~ "T" ,
    R_Cen_village_str == "sanagortha" ~ "C" ,
    R_Cen_village_str == "jaltar" ~ "C" ,
    R_Cen_village_str == "bk padar" ~ "C" ,
    R_Cen_village_str == "bhujbal" ~ "C" ,
    R_Cen_village_str == "gudiabandh" ~ "C" ,
    R_Cen_village_str == "mariguda" ~ "C" ,
    R_Cen_village_str == "dangalodi" ~ "C" ,
    R_Cen_village_str == "barijhola" ~ "C" ,
    R_Cen_village_str == "karlakana" ~ "C" ,
    R_Cen_village_str == "kuljing" ~ "C" ,
    TRUE ~ Treat_Control  # Keep the original value if not matched
  ))

#checking summary stats individually 

summary_stats <- merged_df  %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(R_Cen_a40_gps_latitude, na.rm = TRUE),
    sd_distance = sd(R_Cen_a40_gps_latitude, na.rm = TRUE),
    median_distance = median(R_Cen_a40_gps_latitude, na.rm = TRUE),
    IQR_distance = IQR(R_Cen_a40_gps_latitude, na.rm = TRUE)
  )

print(summary_stats)

summary_stats <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(R_Cen_a40_gps_longitude, na.rm = TRUE),
    sd_distance = sd(R_Cen_a40_gps_longitude, na.rm = TRUE),
    median_distance = median(R_Cen_a40_gps_longitude, na.rm = TRUE),
    IQR_distance = IQR(R_Cen_a40_gps_longitude, na.rm = TRUE)
  )

print(summary_stats)


summary_stats <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(GPS_manual.Latitude, na.rm = TRUE),
    sd_distance = sd(GPS_manual.Latitude, na.rm = TRUE),
    median_distance = median(GPS_manual.Latitude, na.rm = TRUE),
    IQR_distance = IQR(GPS_manual.Latitude, na.rm = TRUE)
  )

print(summary_stats)

summary_stats <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(GPS_manual.Longitude, na.rm = TRUE),
    sd_distance = sd(GPS_manual.Longitude, na.rm = TRUE),
    median_distance = median(GPS_manual.Longitude, na.rm = TRUE),
    IQR_distance = IQR(GPS_manual.Longitude, na.rm = TRUE)
  )

print(summary_stats)


# chceking for outliers using Z score
merged_df <- merged_df %>%
  mutate(
    Z_score_latitude = scale(R_Cen_a40_gps_latitude),
    Z_score_longitude = scale(R_Cen_a40_gps_longitude),
    Z_score_GPS_Latitude = scale(GPS_manual.Latitude),
    Z_score_GPS_Longitude = scale(GPS_manual.Longitude)
  )

merged_df <- merged_df %>%
  mutate(
    Outlier_latitude = ifelse(abs(Z_score_latitude) > 3, "Outlier", "Not Outlier"),
    Outlier_longitude = ifelse(abs(Z_score_longitude) > 3, "Outlier", "Not Outlier"),
    Outlier_GPS_Latitude = ifelse(abs(Z_score_GPS_Latitude) > 3, "Outlier", "Not Outlier"),
    Outlier_GPS_Longitude = ifelse(abs(Z_score_GPS_Longitude) > 3, "Outlier", "Not Outlier")
  )

##using IQR method 
merged_df <- merged_df %>%
  mutate(
    IQR_latitude = IQR(R_Cen_a40_gps_latitude),
    IQR_longitude = IQR(R_Cen_a40_gps_longitude),
    IQR_GPS_Latitude = IQR(GPS_manual.Latitude),
    IQR_GPS_Longitude = IQR(GPS_manual.Longitude),
    Lower_fence_latitude = quantile(R_Cen_a40_gps_latitude, 0.25) - 1.5 * IQR_latitude,
    Upper_fence_latitude = quantile(R_Cen_a40_gps_latitude, 0.75) + 1.5 * IQR_latitude,
    Lower_fence_longitude = quantile(R_Cen_a40_gps_longitude, 0.25) - 1.5 * IQR_longitude,
    Upper_fence_longitude = quantile(R_Cen_a40_gps_longitude, 0.75) + 1.5 * IQR_longitude,
    Lower_fence_GPS_Latitude = quantile(GPS_manual.Latitude, 0.25) - 1.5 * IQR_GPS_Latitude,
    Upper_fence_GPS_Latitude = quantile(GPS_manual.Latitude, 0.75) + 1.5 * IQR_GPS_Latitude,
    Lower_fence_GPS_Longitude = quantile(GPS_manual.Longitude, 0.25) - 1.5 * IQR_GPS_Longitude,
    Upper_fence_GPS_Longitude = quantile(GPS_manual.Longitude, 0.75) + 1.5 * IQR_GPS_Longitude,
    Outlier_latitude = ifelse(R_Cen_a40_gps_latitude < Lower_fence_latitude | R_Cen_a40_gps_latitude > Upper_fence_latitude, "Outlier", "Not Outlier"),
    Outlier_longitude = ifelse(R_Cen_a40_gps_longitude < Lower_fence_longitude | R_Cen_a40_gps_longitude > Upper_fence_longitude, "Outlier", "Not Outlier"),
    Outlier_GPS_Latitude = ifelse(GPS_manual.Latitude < Lower_fence_GPS_Latitude | GPS_manual.Latitude > Upper_fence_GPS_Latitude, "Outlier", "Not Outlier"),
    Outlier_GPS_Longitude = ifelse(GPS_manual.Longitude < Lower_fence_GPS_Longitude | GPS_manual.Longitude > Upper_fence_GPS_Longitude, "Outlier", "Not Outlier")
  )


merged_df <- merged_df %>%
  mutate(
    Outlier_latitude = ifelse(R_Cen_a40_gps_latitude < Lower_fence_latitude | R_Cen_a40_gps_latitude > Upper_fence_latitude, "Outlier", "Not Outlier"),
    Outlier_longitude = ifelse(R_Cen_a40_gps_longitude < Lower_fence_longitude | R_Cen_a40_gps_longitude > Upper_fence_longitude, "Outlier", "Not Outlier"),
    Outlier_GPS_Latitude = ifelse(GPS_manual.Latitude < Lower_fence_GPS_Latitude | GPS_manual.Latitude > Upper_fence_GPS_Latitude, "Outlier", "Not Outlier"),
    Outlier_GPS_Longitude = ifelse(GPS_manual.Longitude < Lower_fence_GPS_Longitude | GPS_manual.Longitude > Upper_fence_GPS_Longitude, "Outlier", "Not Outlier")
  )


View(merged_df)

#_______________________________________________________________
#finding out nearest and the farthest households from the ILC device
#_______________________________________________________________

#sd deviation by village 



# Calculate distances
merged_df$distance <- distHaversine(
  matrix(c(merged_df$R_Cen_a40_gps_longitude, merged_df$R_Cen_a40_gps_latitude), ncol = 2),
  matrix(c(merged_df$GPS_manual.Longitude, merged_df$GPS_manual.Latitude), ncol = 2)
)


View(merged_df)
merged_df_view <- merged_df %>% select(R_Cen_village_str, R_Cen_a40_gps_latitude, R_Cen_a40_gps_longitude, GPS_manual.Latitude, GPS_manual.Longitude, Treat_Control, distance )
View(merged_df_view)

summary_stats <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    count = n(),
    mean_distance = mean(distance, na.rm = TRUE),
    sd_distance = sd(distance, na.rm = TRUE),
    median_distance = median(distance, na.rm = TRUE),
    IQR_distance = IQR(distance, na.rm = TRUE)
  )


# Calculate distances for each household to the tank using Vincenty's formula
merged_df$distance_to_tank <- distVincentySphere(
  p1 = cbind(merged_df$R_Cen_a40_gps_longitude, merged_df$R_Cen_a40_gps_latitude),
  p2 = cbind(merged_df$GPS_manual.Longitude, merged_df$GPS_manual.Latitude)
)

# View the updated dataset with distances
View(merged_df)

# Summary statistics or further analysis with distances
summary(merged_df$distance_to_tank)

merged_df_view <- merged_df %>% select(R_Cen_village_str, R_Cen_a40_gps_latitude, R_Cen_a40_gps_longitude, GPS_manual.Latitude, GPS_manual.Longitude, Treat_Control, distance, distance_to_tank )
View(merged_df_view)

head(merged_df[, c("R_Cen_a40_gps_longitude", "R_Cen_a40_gps_latitude", "GPS_manual.Longitude", "GPS_manual.Latitude")])
summary(merged_df[, c("R_Cen_a40_gps_longitude", "R_Cen_a40_gps_latitude", "GPS_manual.Longitude", "GPS_manual.Latitude")])
range(merged_df$R_Cen_a40_gps_latitude, na.rm = TRUE)
range(merged_df$R_Cen_a40_gps_longitude, na.rm = TRUE)
range(merged_df$GPS_manual.Latitude, na.rm = TRUE)
range(merged_df$GPS_manual.Longitude, na.rm = TRUE)

str(merged_df[, c("R_Cen_a40_gps_longitude", "R_Cen_a40_gps_latitude", "GPS_manual.Longitude", "GPS_manual.Latitude")])


library(ggplot2)

ggplot(merged_df, aes(x = R_Cen_a40_gps_longitude, y = R_Cen_a40_gps_latitude)) +
  geom_point(color = "blue") +
  geom_point(aes(x = GPS_manual.Longitude, y = GPS_manual.Latitude), color = "red") +
  labs(title = "Household (blue) and Tank (red) Coordinates") +
  theme_minimal()


# Create a subset with unique village names
unique_tanks <- merged_df %>%
  distinct(R_Cen_village_str, GPS_manual.Longitude, GPS_manual.Latitude)



# Create the plot
# Create the plot
ggplot(merged_df) +
  geom_point(aes(x = R_Cen_a40_gps_longitude, y = R_Cen_a40_gps_latitude), color = "blue") +
  geom_point(aes(x = GPS_manual.Longitude, y = GPS_manual.Latitude), color = "red") +
  geom_text_repel(data = unique_tanks, aes(x = GPS_manual.Longitude, y = GPS_manual.Latitude, label = R_Cen_village_str), color = "red") +
  labs(title = "Household (blue) and Tank (red) Coordinates with Unique Village Names",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()


library(ggrepel)  # Ensure ggrepel package is loaded for geom_text_repel

# Plot with facet wrap and colored points




#----------------------------------------------------------
ggplot(merged_df) +
  geom_point(aes(x = R_Cen_a40_gps_longitude, y = R_Cen_a40_gps_latitude, color = Treat_Control)) +
  geom_point(aes(x = GPS_manual.Longitude, y = GPS_manual.Latitude, color = Treat_Control)) +
  geom_text_repel(data = unique_tanks, aes(x = GPS_manual.Longitude, y = GPS_manual.Latitude, label = R_Cen_village_str), color = "red") +
  labs(title = "Household and Tank Coordinates with Unique Village Names by Treatment and Control",
       x = "Longitude",
       y = "Latitude",
       color = "Group") +
  theme_minimal()

# cleaning for coordinates ()
# find nearest HH and check the distnace of other HH from that and check for the balance for the whole village. check for the randomised sample and run that balance for each round. Also check in the randomised sample   
# central point of village and use that 
# neutralize the distances 
# check the location of the outlier on google mapo 
# check the gps coordinates and then treat it as a missing value 
# endline census 
# does it relaly matter? and check if the distance says something
# distnace from the nearest and check the density plot 
# 


#-------------------------------------------------------------------
# facet wraop between T vs C on the distnace of the tank 
# do box plots and density plots for different distance of measures (use a different measure of distance) from the nearest, the centroid, 




print("Summary Statistics:")
print(summary_stats)



# Filter for one value per village based on minimum distance
merged_df_unique <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  filter(distance == min(distance)) %>%
  ungroup()

# Select the required variables
merged_df_final <- merged_df_unique %>%
  select(R_Cen_village_str, R_Cen_a40_gps_latitude, R_Cen_a40_gps_longitude, GPS_manual.Latitude, GPS_manual.Longitude, Treat_Control, distance)

View(merged_df_final)
# Calculate summary statistics
summary_stats <- merged_df_final %>%
  group_by(Treat_Control) %>%
  summarise(
    count = n(),
    mean_distance = mean(distance, na.rm = TRUE),
    sd_distance = sd(distance, na.rm = TRUE),
    median_distance = median(distance, na.rm = TRUE),
    IQR_distance = IQR(distance, na.rm = TRUE)
  )

print("Summary Statistics:")
print(summary_stats)





# Perform a t-test to compare the mean distances between treatment and control groups
t_test_result <- t.test(distance ~ Treat_Control, data = merged_df_final)

# Print the t-test result
print("T-Test Result:")
print(t_test_result)




# Box Plot
box_plot <- ggplot(merged_df_final, aes(x = Treat_Control, y = distance, fill = Treat_Control)) +
  geom_boxplot() +
  labs(title = "Box Plot of Distances by Treatment and Control Groups",
       x = "Group", y = "Distance") +
  theme_minimal() +
  theme(legend.position = "none")

# Density Plot
density_plot <- ggplot(merged_df_final, aes(x = distance, fill = Treat_Control)) +
  geom_density(alpha = 0.5) +
  labs(title = "Density Plot of Distances by Treatment and Control Groups",
       x = "Distance", y = "Density") +
  theme_minimal()

# Print the plots
print(box_plot)
print(density_plot)




library(ggplot2)
library(ggrepel)
library(dplyr)

# Calculate summary statistics
summary_stats <- merged_df_final %>%
  group_by(Treat_Control) %>%
  summarise(
    mean_distance = mean(distance, na.rm = TRUE),
    sd_distance = sd(distance, na.rm = TRUE),
    n = n(),
    ci_lower = mean_distance - qt(0.975, df = n - 1) * sd_distance / sqrt(n),
    ci_upper = mean_distance + qt(0.975, df = n - 1) * sd_distance / sqrt(n)
  )

# Density plot with error bars
density_plot <- ggplot(merged_df_final, aes(x = distance, fill = Treat_Control)) +
  geom_density(alpha = 0.5) +
  geom_vline(data = summary_stats, aes(xintercept = mean_distance, color = Treat_Control), linetype = "dashed", size = 1) +
  geom_errorbar(data = summary_stats, aes(x = mean_distance, ymin = 0, ymax = 0.1, color = Treat_Control), width = 0.1) +
  geom_point(data = summary_stats, aes(x = mean_distance, y = 0.05, color = Treat_Control), size = 3) +
  labs(title = "Density Plot of Distances by Treatment and Control Groups",
       x = "Distance", y = "Density") +
  theme_minimal()

print(density_plot)




# Calculate means and confidence intervals
summary_stats <- merged_df_final %>%
  group_by(Treat_Control) %>%
  summarise(
    mean_distance = mean(distance, na.rm = TRUE),
    ci_lower = mean(distance, na.rm = TRUE) - qt(0.975, df = n() - 1) * sd(distance, na.rm = TRUE) / sqrt(n()),
    ci_upper = mean(distance, na.rm = TRUE) + qt(0.975, df = n() - 1) * sd(distance, na.rm = TRUE) / sqrt(n())
  )
print(summary_stats)
# Box Plot
box_plot <- ggplot(merged_df_final, aes(x = Treat_Control, y = distance, fill = Treat_Control)) +
  geom_boxplot() +
  labs(title = "Box Plot of Distances by Treatment and Control Groups",
       x = "Group", y = "Distance") +
  theme_minimal() +
  theme(legend.position = "none")

density_plot <- ggplot(merged_df_final, aes(x = distance, fill = Treat_Control)) +
  geom_density(alpha = 0.5) +
  labs(title = "Density Plot of Distances by Treatment and Control Groups",
       x = "Distance", y = "Density") +
  theme_minimal()

# Print the plots
print(box_plot)
print(density_plot)
# Density Plot

library(ggplot2)
library(dplyr)

# Calculate summary statistics
summary_stats <- merged_df_final %>%
  group_by(Treat_Control) %>%
  summarise(
    mean_distance = mean(distance, na.rm = TRUE),
    sd_distance = sd(distance, na.rm = TRUE),
    n = n(),
    ci_lower = mean_distance - qt(0.975, df = n - 1) * sd_distance / sqrt(n),
    ci_upper = mean_distance + qt(0.975, df = n - 1) * sd_distance / sqrt(n)
  )

# Density plot with facets
density_plot <- ggplot(merged_df_final, aes(x = distance, fill = Treat_Control)) +
  geom_density(alpha = 0.5) +
  facet_wrap(~ Treat_Control) +
  labs(title = "Density Plot of Distances by Treatment and Control Groups",
       x = "Distance", y = "Density") +
  theme_minimal()

print(density_plot)





# Box plot with facets
boxplot_facet <- ggplot(merged_df_final, aes(x = Treat_Control, y = distance, fill = Treat_Control)) +
  geom_boxplot() +
  facet_wrap(~ Treat_Control) +
  labs(title = "Box Plot of Distances by Treatment and Control Groups",
       x = "Group", y = "Distance") +
  theme_minimal()

print(boxplot_facet)




#------------------------------------------------------------
#---------------------------------------------------------
# Identify the nearest and farthest households
nearest_household <- merged_df[which.min(merged_df$distance), ]
farthest_household <- merged_df[which.max(merged_df$distance), ]

# Print the nearest and farthest households
print("Nearest Household:")
print(nearest_household)
print("Farthest Household:")
print(farthest_household)

# Identify the nearest and farthest households within each village
nearest_and_farthest <- merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    nearest_distance = min(distance),
    farthest_distance = max(distance),
    nearest_household = list(filter(merged_df, R_Cen_village_str == unique(R_Cen_village_str) & distance == min(distance))),
    farthest_household = list(filter(merged_df, R_Cen_village_str == unique(R_Cen_village_str) & distance == max(distance)))
  )

View(nearest_and_farthest)
# Create a base plot
ggplot() +
  # Plot ILC device
  geom_point(aes(x = GPS_ILC_device.Longitude, y = GPS_ILC_device.Latitude), data = merged_df, color = "blue", size = 3, label="ILC Device") +
  # Plot all households
  geom_point(aes(x = R_Cen_a40_gps_longitude, y = R_Cen_a40_gps_latitude), data = merged_df, color = "grey", size = 2) +
  # Highlight the nearest household
  geom_point(aes(x = nearest_household$R_Cen_a40_gps_longitude, y = nearest_household$R_Cen_a40_gps_latitude), color = "green", size = 3) +
  # Highlight the farthest household
  geom_point(aes(x = farthest_household$R_Cen_a40_gps_longitude, y = farthest_household$R_Cen_a40_gps_latitude), color = "red", size = 3) +
  # Add labels
  labs(title = "Household Locations Relative to ILC Device",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()


















#_______________________________________________________________


# Calculate distances (if not already done)
merged_df <- merged_df %>%
  mutate(distance = distHaversine(
    matrix(c(R_Cen_a40_gps_longitude, R_Cen_a40_gps_latitude), ncol = 2),
    matrix(c(GPS_ILC_device.Longitude, GPS_ILC_device.Latitude), ncol = 2)
  ))


# Summary statistics for the distance variable
summary(merged_df$distance)

# Summary statistics by village
merged_df %>%
  group_by(R_Cen_village_str) %>%
  summarise(
    mean_distance = mean(distance, na.rm = TRUE),
    median_distance = median(distance, na.rm = TRUE),
    sd_distance = sd(distance, na.rm = TRUE),
    min_distance = min(distance, na.rm = TRUE),
    max_distance = max(distance, na.rm = TRUE)
  )


# Load ggplot2 for visualization
library(ggplot2)

# Histogram of distances
ggplot(merged_df, aes(x = distance)) +
  geom_histogram(binwidth = 50, fill = "blue", alpha = 0.7) +
  labs(title = "Histogram of Distances", x = "Distance (meters)", y = "Frequency")

# Boxplot of distances by village
ggplot(merged_df, aes(x = R_Cen_village_str, y = distance)) +
  geom_boxplot() +
  labs(title = "Boxplot of Distances by Village", x = "Village", y = "Distance (meters)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# ANOVA to test if there are significant differences in distance by village
anova_result <- aov(distance ~ R_Cen_village_str, data = merged_df)
summary(anova_result)

# Pairwise t-tests to compare distances between each pair of villages
pairwise_t_test <- pairwise.t.test(merged_df$distance, merged_df$R_Cen_village_str, p.adjust.method = "bonferroni")
pairwise_t_test
