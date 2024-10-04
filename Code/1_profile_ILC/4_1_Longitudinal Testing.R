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
install.packages("hms")


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

#-----------------------------Creating a separate df for stored water--------

#creating a new cleaned dataframe for stored water readings
df_clean_sw <- df_clean 

# Converting the time_sw_collect variable to hms object
df_clean_sw$time_sw_hms <- hms(df_clean$time_sw_collect)
# Extract hours and minutes from the tw_time variable and store in a new var 'time'
df_clean_sw$sw_hours <- hour(df_clean_sw$time_sw_hms)
df_clean_sw$sw_minutes <- minute(df_clean_sw$time_sw_hms)
# Combine hours and minutes into a single column
df_clean_sw$sw_time_collect <- sprintf("%02d:%02d", df_clean_sw$sw_hours, df_clean_sw$sw_minutes)
#select(-hours, -minutes, -time_hms)  # removing temporary columns()
View(df_clean_sw)


# Convert times to a suitable format
#df_clean_sw$time <- as.POSIXct(df_clean_sw$time, format = "%I:%M %p")
#df_clean_sw$sw_time_collect <- as.POSIXct(df_clean_sw$sw_time_collect, format = "%I:%M %p")

#Exact Match Filtering
df_exact_match <- df_clean_sw %>%
  filter(time == sw_time_collect)
View(df_exact_match)


# Manual filtering (using Specific Conditions) for obs where time differnce does not allow exact matching 
# Creating a list of conditions to retain values
specific_conditions <- data.frame(
  sw_time_collect = c("06:19", "06:14", "06:31", "06:45", "07:28", "07:21", "07:01", "07:17", "06:31", "06:09", "07:43", "07:15", "06:09", "06:08"),  # stored water collection times
  time = c("06:16", "06:13", "06:29", "06:42", "07:23", "07:19", "06:56", "07:15", "06:27", "06:06", "07:39", "07:12", "06:07", "06:06"),              # running water times
  village_name = c("Badabangi", "Badabangi", "Asada", "Asada", "Naira", "Naira", "Asada", "Asada", "Badabangi", "Mukundpur", "Mukundpur", "Naira", "Bichikote", "Bichikote")           # Corresponding villages
)
View(specific_conditions)

# Initialize an empty dataframe for manual selections
df_manual_selection <- data.frame()

# Loop through each row in specific_conditions
for (i in 1:nrow(specific_conditions)) {
  matched_rows <- df_clean_sw %>%
    filter(sw_time_collect == specific_conditions$sw_time_collect[i] &
             time == specific_conditions$time[i] &
             village_name == specific_conditions$village_name[i])
  
  # Append matching rows to the manual selection dataframe
  df_manual_selection <- rbind(df_manual_selection, matched_rows)
}

# Combine results from both steps 
df_clean_sw_final <- bind_rows(df_exact_match, df_manual_selection) %>%
  distinct()  # Remove duplicates, if any
View(df_clean_sw_final)

#Creating new variable to store anonymised village names
df_clean_sw_final_new <- df_clean_sw_final %>%
  mutate(anonymized_village_name = paste("Village", dense_rank(village_name)))



# Create the scatterplot for decay in stored water with Village names 
plot <- ggplot(df_clean_sw_final, aes(x = tw_fc, y = sw_fc, color = village_name)) +
  geom_point() +  # Add points
  labs(title = "Chlorine Decay in Stored Water Over Time",
       x = "FC in Running Water at Time of Stored Water Collection (mg/L)", 
       y = "FC in Stored Water 45 Minutes After Water Collection (mg/L)",
       caption = "Note: Data points are from longitudinal testing of stored water conducted 45 minutes after sample collection in seven villages. \nTesting was performed across two rounds at different chlorine levels at the nearest and farthest taps, which accounts for multiple observations per village.") +
  theme_minimal() +  # Use a minimal theme
  scale_color_discrete(name = "Village") +  # Legend title
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +  # 45-degree line
  annotate("text", x = 1.2, y = 1.2, label = "45° Line of Reference", 
           color = "red", size = 4, vjust = -1) +  # Annotate 45-degree line
  geom_smooth(aes(linetype = "Trend Line"), method = "lm", se = FALSE, color = "black", show.legend = FALSE) +  # Dotted trend line without legend
  annotate("text", x = 1.2, y = 0.8, label = "Trend Line", 
           color = "black", size = 4, vjust = -1) +  # Annotate trend line
  scale_linetype_manual(name = "Line Type", values = "dotted") +  # Add legend for line type
  scale_x_continuous(
    limits = c(0.0, 1.4),
    breaks = seq(from = 0.0, to = 1.4, by = 0.2)
  ) +
  scale_y_continuous(
    limits = c(0.0, 1.4),
    breaks = seq(from = 0.0, to = 1.4, by = 0.2)
  ) +
  theme(plot.caption = element_text(hjust = 0))  # Left-justify the caption
print(plot)
ggplot2::ggsave(paste0(overleaf(), "Figure/Chlorine decay in stored water.png"), plot, bg = "white", width = 10, height = 6, dpi = 200)


# Create the scatterplot for decay in stored water without  Village names 
plot_sw <- ggplot(df_clean_sw_final_new, aes(x = tw_fc, y = sw_fc, color = anonymized_village_name)) +
  geom_point() +  # Add points
  labs(title = "Chlorine Decay in Stored Water Over Time",
       x = "FC in Running Water at Time of Stored Water Collection (mg/L)", 
       y = "FC in Stored Water 45 Minutes After Water Collection (mg/L)",
       caption = "Note: Data points are from longitudinal testing of stored water conducted 45 minutes after sample collection in seven villages. \nTesting was performed across two rounds at different chlorine levels at the nearest and farthest taps, which accounts for multiple observations per village.") +
  theme_minimal() +  # Use a minimal theme
  scale_color_discrete(name = "Village") +  # Legend title
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +  # 45-degree line
  annotate("text", x = 1.2, y = 1.2, label = "45° Line of Reference", 
           color = "red", size = 4, vjust = -1) +  # Annotate 45-degree line
  geom_smooth(aes(linetype = "Trend Line"), method = "lm", se = FALSE, color = "black", show.legend = FALSE) +  # Dotted trend line without legend
  annotate("text", x = 1.2, y = 0.8, label = "Trend Line", 
           color = "black", size = 4, vjust = -1) +  # Annotate trend line
  scale_linetype_manual(name = "Line Type", values = "dotted") +  # Add legend for line type
  scale_x_continuous(
    limits = c(0.0, 1.4),
    breaks = seq(from = 0.0, to = 1.4, by = 0.2)
  ) +
  scale_y_continuous(
    limits = c(0.0, 1.4),
    breaks = seq(from = 0.0, to = 1.4, by = 0.2)
  ) +
  theme(plot.caption = element_text(hjust = 0))  # Left-justify the caption
print(plot_sw)
ggplot2::ggsave(paste0(overleaf(), "Figure/Chlorine decay_stored water_wo vill names.png"), plot_sw, bg = "white", width = 10, height = 6, dpi = 200)


# Calculate chlorine decay
df_clean_sw_final <- df_clean_sw_final %>%
  mutate(chlorine_decay = tw_fc - sw_fc)  # Calculate the decay

# Calculate the average chlorine decay
average_decay <- df_clean_sw_final %>%
  summarise(average_decay = mean(chlorine_decay, na.rm = TRUE))  # Mean decay, excluding NA values

# View the result
print(average_decay)

# Calculate the percent decrease in chlorine levels
df_clean_sw_final <- df_clean_sw_final %>%
  mutate(percent_decrease = ((tw_fc - sw_fc) / tw_fc) * 100)  # Calculate percent decrease

# Calculate the average percent decrease
average_percent_decrease <- df_clean_sw_final %>%
  summarise(average_percent_decrease = mean(percent_decrease, na.rm = TRUE))  # Mean percent decrease, excluding NA values

# View the result
print(average_percent_decrease)

# Calculate average tw_fc and sw_fc
averages <- df_clean_sw_final %>%
  summarise(
    average_tw_fc = mean(tw_fc, na.rm = TRUE),
    average_sw_fc = mean(sw_fc, na.rm = TRUE)
  )

# Create a message about the average decrease
average_decrease_message <- paste(
  "The average chlorine level decreased from",
  round(averages$average_tw_fc, 2), "mg/L to",
  round(averages$average_sw_fc, 2), "mg/L."
)

# Print the message
print(average_decrease_message)

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

#Filtering dtaa for Round 2 (Data collectiuon done in Mukundpur twice, removing teh first instance's obs)
filtered_data_r2_new <- df_clean %>%
  filter(date_only >= cutoff_date & !(village_name == "Mukundpur" & date_only == "2024-09-06"))

#removing the observations of Tandipur where test was conducted at the nearest tap by Jeremy 
filtered_data_r2_new <- filtered_data_r2_new %>%
  filter(date_only >= cutoff_date & !(village_name == "Tandipur" & date_only == "2024-09-12"))
#Creating new variable to store anonymised village names
filtered_data_r2_new <- filtered_data_r2_new %>%
  mutate(anonymized_village_name = paste("Village", dense_rank(village_name)))

View(filtered_data_r2_new)


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
ggplot2::ggsave(paste0(overleaf(), "Figure/longitudinal_R2.png"), plot2, bg = "white", width = 10, height = 6, dpi = 200)


#Figure with adjustments for sharing results 
# Define colors for nearest and farthest taps
color_nearest <- "blue"
color_farthest <- "#FF8C00" 

# Adjust the color mapping based on location
plot3 <- ggplot(data = filtered_data_r2_new) +
  geom_point(aes(x = time_since_supply, y = tw_fc, color = factor(location))) +
  geom_line(aes(x = time_since_supply, y = tw_fc, color = factor(location), group = location)) +
  facet_wrap(~ anonymized_village_name, scales = "free_x") +
  labs(
    title = "Chlorine Concentrations Over Supply Time in Rayagada Study Sample",
    x = "Minutes since start of supply time",
    y = "Free Chlorine Concentration in Running Water (mg/L)",
    color = "Tap",
    caption = "Note: Data points from longitudinal testing throughout the supply time in six villages at the nearest and farthest taps."
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 8, angle = 90, vjust = 1, hjust = 1),
    legend.position = "bottom",
    strip.text = element_text(size = 12),
    plot.caption = element_text(size = 10, hjust = 0, face = "plain", color = "black", lineheight = 0.5)
  ) +
  scale_y_continuous(
    limits = c(0, 2),
    breaks = seq(from = 0.0, to = 2.0, by = 0.2)
  ) +
  scale_x_continuous(
    limits = c(0, max(filtered_data_r2_new$time_since_supply)),
    breaks = seq(0, max(filtered_data_r2_new$time_since_supply), by = 10)
  ) +
  scale_color_manual(values = c("Nearest Tap" = color_nearest, "Farthest Tap" = color_farthest))

print(plot3)
ggplot2::ggsave(paste0(overleaf(), "Figure/longitudinal_findings.png"), plot3, bg = "white", width = 10, height = 6, dpi = 200)

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




