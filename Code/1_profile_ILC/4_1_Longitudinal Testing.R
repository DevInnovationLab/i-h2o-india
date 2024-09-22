#------------------------------------------------ 
# title: "Code for Creating Plots for Longitudinal Testing Survey"
# author: "Niharika Bhagavatula"
# modified date: "2024-09-03"
#------------------------------------------------ 

#------------------------ Installing and loading the libraries ----------------------------------------

install.packages("RSQLite")
install.packages("haven")
install.packages("expss")
install.packages("stargazer")
install.packages("Hmisc")
install.packages("labelled")
install.packages("data.table")
install.packages("haven")
install.packages("remotes")
install.packages("devtools")
install.packages("geosphere")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("leaflet")
install.packages("quantitray")
install.packages("xtable")
install.packages("scales")


#please note that starpolishr pacakge isn't available on CRAN so it has to be installed from github using rmeotes pacakage 
install.packages("remotes")
remotes::install_github("ChandlerLutz/starpolishr")
install.packages("ggrepel")
install.packages("reshape2")
install.packages("lubridate")
install.packages("remotes")
remotes::install_github("jknappe/quantitray") #Quantitray package installation

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
#library(leaflet)
library(ggrepel)
library(reshape2)
library(quantitray)
library(xtable)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(scales)
library(lubridate)


#------------------------ setting user directories ----------------------------------------

#setting raw data directory
user_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  #
  
  user <- Sys.info()["user"]
  
  if (user == "uchicago") { #niharika's pathway
    path = "/Users/uchicago/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
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


# setting overleaf directory
overleaf <- function() {
  user <- Sys.info()["user"]
  if (user == "uchicago") {
    overleaf = "/Users/uchicago/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user == ""){
    overleaf = ""
  }  
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}



#----------------------------------Loading Data-------------------------------

#longitudinal survey data
# Load data
long_test <- read_csv(paste0(user_path(), "1_raw/1_11_Longitudinal Testing/Longitudinal Testing Survey_WIDE.csv"))

# View the dataset
View(long_test)

#-----------------------------Reshaping and cleaning--------------------------
# Reshape data
df_long <- long_test %>%
  # First pivot to long format for time variables
  pivot_longer(
    cols = starts_with("tw_time_"),  # Specify columns starting with "tw_time_"
    names_to = "tw_time_variable",    # Name for the column that stores original column names
    values_to = "tw_time"             # Name for the column that stores the values
  ) %>%
  # Then pivot to long format for chlorine concentration variables
  pivot_longer(
    cols = starts_with("tw_fc_"),    # Specify columns starting with "tw_fc_"
    names_to = "tw_fc_variable",      # Name for the column that stores original column names
    values_to = "tw_fc"               # Name for the column that stores the values
  ) %>%
  # Filter rows to align time and chlorine concentration values
  filter(str_replace(tw_time_variable, "tw_time_", "tw_fc_") == tw_fc_variable)
# Remove unnecessary columns
#select(-tw_time_variable, -tw_fc_variable)

# View the reshaped data
View(df_long)

#View the columnnames
colnames(df_long)

#Creating new var for submission date with only the date component 
# Convert to POSIXct with the correct format
df_long$SubmissionDate <- as.POSIXct(df_long$SubmissionDate, format="%d-%b-%Y %H:%M:%S", tz="Asia/Kolkata")

# Extract date only
df_long$date_only <- as.Date(df_long$SubmissionDate)
View(df_long)

# adding variable labels
#location of tap:
df_long$village_name <- factor(df_long$village_name, 
                               levels = c(10101, 20101, 30301, 30602, 30701, 40201, 40401, 50401, 50501),
                               labels = c("Asada", "Badabangi", "Tandipur", "Mukundpur", "Gopi Kankubadi", "Bichikote", "Naira", "Birnarayanpur", "Nathma"))

df_long$location <- factor(df_long$location, 
                           levels = c(1, 2),
                           labels = c("Nearest Tap", "Farthest Tap"))

# Remove rows with missing values in 'tw_time' or 'tw_fc'
df_long <- df_long %>%
  filter(complete.cases(tw_time, tw_fc))

# Maunal corrections
df_clean <- df_long %>%
  mutate(tw_time_char = as.character(tw_time)) %>%  # Ensuring that tw_time is in character format
  mutate(tw_time_corrected = case_when(
    tw_time_char == "18:42:59" ~ "06:42:59",
    tw_time_char == "18:47:21" ~ "06:47:21",
    tw_time_char == "18:52:14" ~ "06:52:14",
    tw_time_char == "18:57:31" ~ "06:57:31",
    tw_time_char == "19:03:47" ~ "07:03:47",
    TRUE ~ tw_time_char
  )) %>%
  mutate (tw_time = tw_time_corrected)
#  df_clean$tw_time <- format(tw_time, "%H:%M:%S")
#  mutate(tw_time = as.POSIXct(paste("2024-01-01", tw_time_corrected), format = "%Y-%m-%d %H:%M:%S")) %>%  # Convert corrected times to POSIXct with a temp date
#  select(-tw_time_char, -tw_time_corrected)  # removing temporary columns

# Converting the tw_time variable to hms object
df_clean$time_hms <- hms(df_clean$tw_time)
# Extract hours and minutes from the tw_time variable and store in a new var 'time'
df_clean$hours <- hour(df_clean$time_hms)
df_clean$minutes <- minute(df_clean$time_hms)
# Combine hours and minutes into a single column
df_clean$time <- sprintf("%02d:%02d", df_clean$hours, df_clean$minutes)
#select(-hours, -minutes, -time_hms)  # removing temporary columns()

View(df_clean)

#------------------------------Creating variables for minutes since supply and round--------

#converting the start time of supply to hh:mm format form hh:mm:ss format

# Checking if supply_start_time is in hms format
class(df_clean$supply_start_time)
# Extract hours and minutes from the supply_start_time variable and store in a new var 'time_supply_new'
df_clean$hours_supply <- hour(df_clean$supply_start_time)
df_clean$minutes_supply <- minute(df_clean$supply_start_time)
# Combine hours and minutes into a single column
df_clean$time_supply_new <- sprintf("%02d:%02d", df_clean$hours_supply, df_clean$minutes_supply)

#converting the time var and the time of supply to POSIX format
df_clean <- df_clean %>%
  mutate(
    time = as.POSIXct(time, format = "%H:%M"),   # Adjust format if necessary
    time_supply_new = as.POSIXct(time_supply_new, format = "%H:%M")
  )

#generating a new variable for time since start of supply 
df_clean <- df_clean %>%
  mutate(time_since_supply = as.numeric(difftime(time, time_supply_new, units = "mins")))

#generating a new variable mentioning the round of the survey (R1 or R2); started R2 on Sep 4
df_clean <- df_clean %>%
  mutate(round = ifelse(date_only < "2024-09-04", "Round 1", "Round 2")) 

#------------------------------Creating new dfs for each round-----------------

# Define the cutoff date for different rounds of Longitudinal Testing
cutoff_date <- as.Date("2024-09-04")

# Filtering the data for Round 1
filtered_data_r1 <- df_clean %>%
  filter(date_only < cutoff_date)

View(filtered_data_r1)

# Filtering the data for Round 2
filtered_data_r2 <- df_clean %>%
  filter(date_only >= cutoff_date)

View(filtered_data_r2)

#-----------------------------------Creating GGplots - round-wise---------------
#Round 1 of Longitudinal Testing
# Defining the IST limits and breaks
#start_time <- as.POSIXct("2024-01-01 06:00:00", tz = "Asia/Kolkata")
#end_time <- as.POSIXct("2024-01-01 09:00:00", tz = "Asia/Kolkata")

# Add a new column for custom text annotation for each village
filtered_data_r1 <- filtered_data_r1 %>%
  mutate(annotation_text = case_when(
    village_name == "Asada" ~ "Days since Refill: 5, Valve: 75 degrees",
    village_name == "Badabangi" ~ "Days since Refill: 17, Valve: 75 degrees",
    village_name == "Mukundpur" ~ "Days since Refill: 5, Valve: 75 degrees",
    village_name == "Gopi Kankubadi" ~ "Days since Refill: 5, Valve: 75 degrees",
    village_name == "Naira" ~ "Days since Refill: 5, Valve: 75 degrees",
    village_name == "Birnarayanpur" ~ "Days since Refill: 17, Valve: 65 degrees"
  ))

plot1 <- ggplot(data = filtered_data_r1) +
  geom_point(aes(x = time_since_supply, y = tw_fc, color = factor(location))) +
  geom_line(aes(x = time_since_supply, y = tw_fc, color = factor(location), group = location)) +
  facet_wrap(~ village_name, scales = "free_x") +
  geom_hline(yintercept = 0.40, linetype = "dashed", color = "grey") +
  geom_hline(yintercept = 0.60, linetype = "dashed", color = "grey") +
  # Adjusted annotations
  annotate("text", x = max(filtered_data_r1$time_since_supply), y = 0.37, label = "Targeted Range", hjust = 1, size = 3) +
  annotate("text", x = max(filtered_data_r1$time_since_supply), y = 0.63, label = "Targeted Range", hjust = 1, size = 3) +
  labs(
    title = "Temporal Presentation of Chlorine Readings by Village and Tap - Round 1",
    x = "Minutes since start of supply time",
    y = "Free Chlorine Concentration (mg/L)",
    color = "Tap"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 8, angle = 45, vjust = 1, hjust = 1),
    legend.position = "bottom",
    strip.text = element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 0, face = "italic", color = "gray40", lineheight = 0.5)  # Style the caption
  ) +
  scale_y_continuous(
    limits = c(0, 2),
    breaks = seq(from = 0.0, to = 2.0, by = 0.2)
  ) +
  scale_x_continuous(
    limits = c(0, max(filtered_data_r1$time_since_supply)),
    breaks = seq(0, max(filtered_data_r1$time_since_supply), by = 10),
  ) 


print(plot1)
ggplot2::ggsave(paste0(overleaf(), "Figure/longitudinal_R1.png"), plot1, bg = "white", width = 10, height = 6, dpi = 200)


#Round 2 of Longitudinal Testing 
# Defining the IST limits and breaks
#start_time <- as.POSIXct("2024-01-01 06:00:00", tz = "Asia/Kolkata")
#end_time <- as.POSIXct("2024-01-01 09:00:00", tz = "Asia/Kolkata")

plot2 <- ggplot(data = filtered_data_r2) +
  geom_point(aes(x = time_since_supply, y = tw_fc, color = factor(location))) +
  geom_line(aes(x = time_since_supply, y = tw_fc, color = factor(location), group = location)) +
  facet_wrap(~ village_name, scales = "free_x") +
  geom_hline(yintercept = 0.40, linetype = "dashed", color = "grey") +
  geom_hline(yintercept = 0.60, linetype = "dashed", color = "grey") +
  # Adjusted annotations
  annotate("text", x = max(filtered_data_r2$time_since_supply), y = 0.37, label = "Targeted Range", hjust = 1, size = 3) +
  annotate("text", x = max(filtered_data_r2$time_since_supply), y = 0.63, label = "Targeted Range", hjust = 1, size = 3) +
  labs(
    title = "Temporal Presentation of Chlorine Readings by Village and Tap - Round 2",
    x = "Minutes since start of supply time",
    y = "Free Chlorine Concentration (mg/L)",
    color = "Tap"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 8, angle = 45, vjust = 1, hjust = 1),
    legend.position = "bottom",
    strip.text = element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 0, face = "italic", color = "gray40", lineheight = 0.5)  # Style the caption
  ) +
  scale_y_continuous(
    limits = c(0, 2),
    breaks = seq(from = 0.0, to = 2.0, by = 0.2)
  ) +
  scale_x_continuous(
    limits = c(0, max(filtered_data_r2$time_since_supply)),
    breaks = seq(0, max(filtered_data_r2$time_since_supply), by = 10),
  ) 


print(plot2)
ggplot2::ggsave(paste0(overleaf(), "Figure/longitudinal_R2.png"), plot2, bg = "white", width = 10, height = 6, dpi = 200)

plot2 <- ggplot(data = filtered_data_r2) +
  geom_point(aes(x = time_since_supply, y = tw_fc, color = factor(location))) +
  geom_line(aes(x = time_since_supply, y = tw_fc, color = factor(location), group = location)) +
  facet_wrap(~ village_name, scales = "free_x") +
  geom_hline(yintercept = 0.40, linetype = "dashed", color = "red") +
  geom_hline(yintercept = 0.60, linetype = "dashed", color = "red") +
  labs(
    title = "Chlorine Readings Across Time by Village and Tap - Round 2",
    x = "Time of sample collection",
    y = "Chlorine Concentration (mg/L)",
    color = "Tap"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
    legend.position = "bottom",
    strip.text = element_text(size = 12)
  ) +
  scale_y_continuous(
    limits = c(0, 2),
    breaks = seq(from = 0.0, to = 2.0, by = 0.2)
  ) 
#  scale_x_datetime(
#    limits = c(start_time, end_time),
#    breaks = seq(from = start_time, to = end_time, by = "10 mins"),
#    labels = date_format("%H:%M")
#  ) 

print(plot2)

#------------------------Creating new dfs for each village----------------------

#dropping temporary variables 
#library(dplyr)
#df_clean <- df_clean %>%
#  select(-hours_supply, -minutes_supply)

#creating a separate dataset for each village for creation of separate ggplots
#Asada
asada_data <- df_clean %>% 
  filter(village_name == "Asada")
View(asada_data)

bangi_data <- df_clean %>% 
  filter(village_name == "Badabangi")

gopi_data <- df_clean %>% 
  filter(village_name == "Gopi Kankubadi")


#--------------------------Creating GGplots for each village--------------------
#creating a ggplot for Asada 

plot_asada <- ggplot(data = asada_data) +
  geom_point(aes(x = time_since_supply, y = tw_fc, color = factor(location))) +
  geom_line(aes(x = time_since_supply, y = tw_fc, color = factor(location), group = location)) +
  facet_wrap(~ round, nrow = 1, scales = "free_x") +
  geom_hline(yintercept = 0.40, linetype = "dashed", color = "grey") +
  geom_hline(yintercept = 0.60, linetype = "dashed", color = "grey") +
  # Adjusted annotations
  annotate("text", x = max(asada_data$time_since_supply), y = 0.37, label = "Targeted Range", hjust = 1, size = 3) +
  annotate("text", x = max(asada_data$time_since_supply), y = 0.63, label = "Targeted Range", hjust = 1, size = 3) +
  labs(
    title = "Temporal Presentation of Free Chlorine Readings across Supply Time in Asada",
    x = "Minutes since start of water supply",
    y = "Free Chlorine Concentration (mg/L)",
    color = "Tap",
    caption = "The graph displays results from two rounds of longitudinal testing at the nearest and farthest taps in Asada village during water supply time. The left\n\
    image shows results from the first round of testing, conducted 6 days after the refill with the dosing control valve set to 75 degrees. The right image\n\
    shows results from the second round of testing, conducted 11 days after the refill with the valve at 60 degrees, indicating lower dosing."
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 0, vjust = 1, hjust = 1),
    legend.position = "bottom",
    strip.text = element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 0, face = "italic", color = "gray40", lineheight = 0.5)  # Style the caption
  ) +
  scale_y_continuous(
    limits = c(0, 2),
    breaks = seq(from = 0.0, to = 2.0, by = 0.2)
  ) +
  scale_x_continuous(
    limits = c(0, max(asada_data$time_since_supply)),
    breaks = seq(0, max(asada_data$time_since_supply), by = 10),
  ) 

print(plot_asada)
ggplot2::ggsave(paste0(overleaf(), "Figure/longitudinal_asada.png"), plot_asada, bg = "white", width = 10, height = 6, dpi = 200)

-----------------------------------
  #creating a ggplot for Bangi
  
  
  
  #-----------------------------Saving the dataset------------------------
#saving the cleaned dataset
write_csv(df_clean,paste0(user_path(),"/3_final/1_11_Longitudinal Testing/longitudinal_testing_cleaned.csv"))




