#Purpose: To create bar graphs for HH level dataset (Baseline Census and Endline)
#Created by: Niharika
#Last modified on: Oct 3, 2024

# Loading libraries
library(haven)  # For reading STATA files
library(dplyr)  # For data manipulation
library(ggplot2)  # For plotting

# Defining base directory to my device
base_dir <- "/Users/uchicago/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/3_final/"  
overleaf_dir <- "/Users/uchicago/Dropbox/Apps/Overleaf/Everything document -ILC/"

# Defining specific directories relative to the base
data_dir <- file.path(base_dir, "0_Master_HHLevel_new.dta")
overleaf <- file.path(overleaf_dir, "Figure")

# Loading the final HH level dataset for Baseline Census and Endline
data <- read_dta(data_dir)
View(data)

# Creating temporary dataframe to store only baseline variables 
baseline_data <- data %>%
  select(-starts_with("R_E_"), -submissiondate, -starttime, -endtime) %>%
  rename_with(~ gsub("^R_Cen_", "", .)) %>%
  mutate(survey = 1)  # new var to store information that these are Baseline observations
View(baseline_data)

# Creating temp dataset for endline, dropping rows with missing or zero consent
endline_data <- data %>%
  select(-starts_with("R_Cen_"), -submissiondate, -starttime, -endtime) %>%
  rename_with(~ gsub("^R_E_", "", .)) %>%
  mutate(survey = 2) %>%  # Endline observations
  filter(consent != 0, !is.na(consent))  # Dropping missing or zero consent
#32 observations dropped - obs pertain to endline dataset which are empty given these respondents were only surveyed during basleine

View(endline_data)

# Dropping unnecessary variables from baseline_data (storage type is different in both datasets)
baseline_data <- baseline_data %>%
  select(-enum_name, -enum_code, -resp_available, -instruction, 
         -visit_num, -intro_dur_end, -sectiong_dur_end, 
         -formdef_version, -consent_duration)

# Dropping the same variables from endline_data
endline_data <- endline_data %>%
  select(-enum_name, -enum_code, -resp_available, -instruction, 
         -visit_num, -intro_dur_end, -sectiong_dur_end, 
         -formdef_version, -consent_duration)

# Binding the rows to append the data 
combined_data <- bind_rows(baseline_data, endline_data)
View(combined_data)

# Preparing data for creation of bar graphs for absolute number of users of jjm as drinking water 
data_summary_absolute <- combined_data %>%
  group_by(Treat_V, survey) %>%
  summarise(use_drinking = sum(jjm_drinking, na.rm = TRUE), .groups = "drop") %>%
  mutate(Treat_V = ifelse(Treat_V == 1, "Treatment Group", "Control Group"),
         survey = factor(ifelse(survey == 1, "Baseline", "Endline"), levels = c("Baseline", "Endline")))

# Preparing data for creation of bar graphs for percentage of users of jjm for dirnking
data_summary_primary_percentage <- primary_source_data %>%
  group_by(Treat_V, survey) %>%
  summarise(
    total_users = sum(jjm_drinking, na.rm = TRUE),
    total_respondents = n(),  # Count total respondents
    use_primary_percentage = (total_users / total_respondents) * 100,  # Calculate percentage
    .groups = "drop"
  )

#Creating the bar graph for absolute values for usage of JJM as drinking water source
barchart_absolute <- ggplot(data_summary_absolute, aes(x = Treat_V, y = use_drinking, fill = Treat_V)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  facet_wrap(~ survey, strip.position = "bottom", nrow = 1) +
  scale_fill_manual(values = c("Treatment Group" = "#4CAF50", "Control Group" = "#F44336")) +
  labs(x = "Survey Period and Treatment Assignment", 
       y = "Number of households using JJM taps as source of drinking water",
       title = "Usage of JJM Tap Water for Drinking: Before and After Chlorination",
       fill = "Assignment") +
  geom_text(aes(label = use_drinking), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5) +
  theme_minimal() +
  theme(strip.background = element_blank(), 
        strip.placement = "outside", 
        plot.caption = element_text(hjust = 0)) +  # Left justify the caption
  labs(caption = "Baseline observations: 905; Endline observations: 880. Data collected from household surveys in October 2023 and April 2024")

print(barchart_absolute)


#Creating the bar graph for percentage of users of jjm as drinking water source
barchart_percentage <- ggplot(data_summary_percentage, aes(x = Treat_V, y = use_drinking, fill = Treat_V)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  facet_wrap(~ survey, strip.position = "bottom", nrow = 1) +
  scale_fill_manual(values = c("Treatment Group" = "#4CAF50", "Control Group" = "#F44336")) +
  labs(x = "Survey Period and Treatment Assignment", 
       y = "Percentage of households using JJM taps as source of drinking water(%)",
       title = "Usage of JJM Tap Water for Drinking: Before and After Chlorination",
       fill = "Assignment") +
  geom_text(aes(label = sprintf("%.1f%%", use_drinking)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5) +
  theme_minimal() +
  theme(strip.background = element_blank(), 
        strip.placement = "outside", 
        plot.caption = element_text(hjust = 0)) +  # Left justify the caption
  labs(caption = "Baseline observations: 905; Endline observations: 880. Data collected from household surveys in October 2023 and April 2024.")

print(barchart_percentage)




# Prepare data for absolute values using water_source_prim
data_summary_primary_absolute <- combined_data %>%
  group_by(Treat_V, survey) %>%
  summarise(use_primary = sum(water_source_prim == 1, na.rm = TRUE), .groups = "drop") %>%
  mutate(Treat_V = ifelse(Treat_V == 1, "Treatment Group", "Control Group"),
         survey = ifelse(survey == 1, "Baseline", "Endline"))

# Create the bar graph for absolute values
barchart_primary_absolute <- ggplot(data_summary_primary_absolute, aes(x = Treat_V, y = use_primary, fill = Treat_V)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  facet_wrap(~ survey, strip.position = "bottom", nrow = 1) +
  scale_fill_manual(values = c("Treatment Group" = "#4CAF50", "Control Group" = "#F44336")) +
  labs(x = "Survey Period and Treatment Assignment", 
       y = "Absolute number of households using JJM taps as primary source of water",
       title = "Usage of JJM Tap Water as Primary Source before and after Chlorination",
       fill = "Assignment") +
  geom_text(aes(label = use_primary), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5) +
  theme_minimal() +
  theme(strip.background = element_blank(), 
        strip.placement = "outside", 
        plot.caption = element_text(hjust = 0)) + 
  labs(caption = "Baseline observations: 914; Endline observations: 880. Data collected from household surveys in October 2023 and April 2024.")

print(barchart_primary_absolute)

# Prepare data for percentage values using water_source_prim
data_summary_primary_percentage <- combined_data %>%
  group_by(Treat_V, survey) %>%
  summarise(
    total_users = sum(water_source_prim == 1, na.rm = TRUE),  # Users using JJM tap water as primary
    total_respondents = n(),  # Count all respondents
    use_primary_percentage = (total_users / total_respondents) * 100,  # Calculate percentage
    .groups = "drop"
  ) %>%
  mutate(Treat_V = ifelse(Treat_V == 1, "Treatment Group", "Control Group"),
         survey = ifelse(survey == 1, "Baseline", "Endline"))

# Create the bar graph for percentage values
barchart_primary_percentage <- ggplot(data_summary_primary_percentage, aes(x = Treat_V, y = use_primary_percentage, fill = Treat_V)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  facet_wrap(~ survey, strip.position = "bottom", nrow = 1) +
  scale_fill_manual(values = c("Treatment Group" = "#4CAF50", "Control Group" = "#F44336")) +
  labs(x = "Survey Period and Treatment Assignment", 
       y = "Percentage of households using JJM taps as primary source of water(%)",
       title = "Usage of JJM Tap Water as Primary Source before and after Chlorination",
       fill = "Assignment") +
  geom_text(aes(label = sprintf("%.1f%%", use_primary_percentage)), 
            position = position_dodge(width = 0.9), 
            vjust = -0.5) +
  theme_minimal() +
  theme(strip.background = element_blank(), 
        strip.placement = "outside", 
        plot.caption = element_text(hjust = 0)) + 
  labs(caption = "Baseline observations: 914; Endline observations: 880. Data collected from household surveys in October 2023 and April 2024.")

print(barchart_primary_percentage)