# Packages =====================================================================
packages <-
  c(
    "rsurveycto",
    "expss",
    "labelled",
    "httr",
    "lubridate",
    "quantitray",
    "sjmisc",
    "knitr",
    "kableExtra",
    "readxl",
    "experiment",
    "stargazer",
    "haven",
    "googlesheets4",
    "ggsignif",
    "patchwork",
    "table1",
    "gtsummary",
    "gt",
    "webshot2",
    "clubSandwich",
    "sandwich",
    "lmtest",
    "broom",
    "tidyverse",
    "sf",
    "gridExtra",
    "crosstable",
    "viridis",
    "flextable"
  )

pacman::p_load(packages, character.only = TRUE)

# Load data ====================================================================
# See Process Doc for details on cleaning code and clean datasets:
#https://docs.google.com/document/d/1Hpv5HF5ICO5FSVdQnPtDECCYORn2qy5S7C_KIx0pDuM/edit

cen         <- read_csv(file.path(user_path(), "1_1_baseline_census.csv"))
bl          <- read_csv(file.path(user_path(), "1_1_baseline_survey.csv"))
el          <- read_csv(file.path(user_path(), "1_8_endline_census.csv"))
idexx_tab   <- read_csv(file.path(user_path(), "1_10_idexx_all_rounds.csv"))
idexx_abr   <- read_csv(file.path(user_path(), "1_10_idexx_abr.csv"))
mon_summary <- read_csv(file.path(user_path(), "1_11_weekly_monitoring.csv"))
all_rounds  <- read_csv(file.path(user_path(), "1_8_surveys_all_rounds.csv"))


# Baseline descriptive statistics =============================================

## Process data ----------------------------------------------------------------

### Census ----------------------------------------------------
# Convert binary categorical variables (character) to numeric (1 = "yes", 0 = "no")
cen <-
  cen %>%
  mutate(
    across(
      all_of(binary_categorical_vars),
      ~ case_when(
        . %in% c("yes", "Yes", "1") ~ 1,
        . %in% c("no", "No", "0") ~ 0,
        TRUE ~ NA_real_ # Ensures missing values remain as NA
      )
    )
  ) 

### Water testing --------------------------------------------------------------
# Separating stored vs tap water tests 
idexx_bl <-
  idexx_tab %>%
  dplyr::select(
    sample_ID,
    assignment,
    village,
    block,
    panchayat_village,
    cf_pa_binary,
    ec_pa_binary,
    cf_log,
    ec_log
  )

index_bl_tap <-
  idexx_bl %>%
  filter(sample_type == "Tap") %>%
  rename(
    cf_pa_tap = "cf_pa_binary",
    ec_pa_tap = "ec_pa_binary",
    cf_log_tap = "cf_log",
    ec_log_tap = "ec_log"
  )

idexx_bl_stored <- 
  idexx_bl %>%
  filter(sample_type == "Stored") %>%
 rename(
    cf_pa_stored = "cf_pa_binary",
    ec_pa_stored = "ec_pa_binary",
    cf_log_stored = "cf_log",
    ec_log_stored = "ec_log"
  )

## Compute stats ---------------------------------------------------------------

### Census ---------------------------------------------------------------------

#### Binary variables ----------------------------------------------------------
binary_vars_census <-
  c(
    "hhhead_gender_binary",
    "read_write_binary",
    "sec_source",
    "jjm_drinking",
    "water_treat_binary",
    "electricity_binary",
    "tv_binary",
    "mobile_binary",
    "fridge_binary",
    "motorcycle_binary"
  )

binary_vars_census_summary <- 
  cen %>%
  select(
    all_of(binary_vars_census),
    assignment
  ) %>%
  pivot_longer(
    cols = all_of(binary_vars_census),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, assignment) %>%
  summarise(
    n = sum(!is.na(value)), # Non-missing values
    p = mean(value, na.rm = TRUE), # Proportion
    se = calculate_se(p, n), # Standard error
    formatted_stat = sprintf("%.1f%% (%.1f)", p * 100, se * 100),
    .groups = "drop"
  ) %>%
  select(variable, assignment, formatted_stat)

#### Multi-level categorical variables -----------------------------------------
categorical_vars_census <- c("prim_source")

categorical_vars_census_summary <- 
  cen %>%
  select(
    all_of(categorical_vars_census), 
    assignment
    ) %>%
  pivot_longer(
    cols = all_of(categorical_vars_census),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, assignment) %>%
  mutate(total = n()) %>%  # Calculate total responses per treatment group
  group_by(variable, value, assignment) %>%  # Now group by category level
  summarise(
    n = n(), # Count per category level
    total = unique(total), # Correctly get the total responses for that treatment group
    p = n / total,  # Proportion of each level within treatment
    se = calculate_se(p, total), # Standard error
    formatted_stat = sprintf("%.1f%% (%.1f)", p * 100, se * 100),
    .groups = "drop"
  ) %>%
  transmute(
    variable = paste0(variable, " - ", value),
    assignment, 
    formatted_stat
  )

#### Continuous variables ------------------------------------------------------
continuous_vars_census <- c("hhmember_count")

continuous_summary <- 
  cen %>%
  select(
    all_of(continuous_vars_census), 
    assignment
    ) %>%
  pivot_longer(
    cols = all_of(continuous_vars_census),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, assignment) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    formatted_stat = sprintf("%.1f (%.1f)", mean, sd),
    .groups = "drop"
  ) %>%
  select(variable, assignment, formatted_stat)

### Water testing --------------------------------------------------------------

#### Binary variables ---------------------------------------------------------

binary_categorical_vars <- 
  c(
    "fc_tap_binary",
    "fc_stored_binary",
    "tap_taste_binary",
    "treat_time_5min"
  )

binary_categorical_vars <- c("ec_pa_tap", "cf_pa_tap")

binary_categorical_summary_bl <- 
  bl %>%
  select(
    all_of(binary_categorical_vars), 
    assignment
    ) %>%
  pivot_longer(
    cols = all_of(binary_categorical_vars),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, assignment) %>%
  summarise(
    n = sum(!is.na(value)), # Count non-missing values
    p = mean(value, na.rm = TRUE), # Proportion
    se = calculate_se(p, n), # Standard error
    formatted_stat = sprintf("%.1f%% (%.1f)", p * 100, se * 100),
    .groups = "drop"
  ) %>%
  select(variable, assignment, formatted_stat)

# Compute stats for continuous variables (Mean + SD)



# Water tests
binary_categorical_vars <- c("ec_pa_tap", "cf_pa_tap")


# Compute stats for binary categorical variables (Proportion + SE)
binary_categorical_summary_tap <- idexx_bl_tap %>%
  select(all_of(binary_categorical_vars), assignment) %>%
  pivot_longer(
    cols = all_of(binary_categorical_vars),
    names_to = "variable",
    values_to = "value"
  ) %>%
  group_by(variable, assignment) %>%
  summarise(
    n = sum(!is.na(value)),
    # Count non-missing values
    p = mean(value, na.rm = TRUE),
    # Proportion
    se = calculate_se(p, n),
    # Standard error
    formatted_stat = sprintf("%.1f%% (%.1f)", p * 100, se * 100),
    .groups = "drop"
  ) %>%
  select(variable, assignment, formatted_stat)


#Baseline followup survey desc stats
binary_categorical_vars <- c(
  "ec_pa_stored",
  "cf_pa_stored"
  #"cf_pa_binary1","cf_pa_binary2","ec_pa_binary1","ec_pa_binary2",#"water_treat_binary)
  
  
  # Compute stats for binary categorical variables (Proportion + SE)
  binary_categorical_summary_stored <- idexx_bl_stored %>%
    select(all_of(binary_categorical_vars), assignment) %>%
    pivot_longer(
      cols = all_of(binary_categorical_vars),
      names_to = "variable",
      values_to = "value"
    ) %>%
    group_by(variable, assignment) %>%
    summarise(
      n = sum(!is.na(value)),
      # Count non-missing values
      p = mean(value, na.rm = TRUE),
      # Proportion
      se = calculate_se(p, n),
      # Standard error
      formatted_stat = sprintf("%.1f%% (%.1f)", p * 100, se * 100),
      .groups = "drop"
    ) %>%
    select(variable, assignment, formatted_stat)
  
  
  
  #Continuous variables microbial contamination results
  continuous_vars <- c("ec_log_tap", "cf_log_tap")
  
  
  # Compute stats for continuous variables (Mean + SD)
  continuous_summary_tap <- idexx_bl_tap %>%
    select(all_of(continuous_vars), assignment) %>%
    pivot_longer(
      cols = all_of(continuous_vars),
      names_to = "variable",
      values_to = "value"
    ) %>%
    group_by(variable, assignment) %>%
    summarise(
      mean = mean(value, na.rm = TRUE),
      sd = sd(value, na.rm = TRUE),
      formatted_stat = sprintf("%.1f (%.2f)", mean, sd),
      .groups = "drop"
    ) %>%
    select(variable, assignment, formatted_stat)
  
  #Continuous variables microbial contamination results
  continuous_vars <- c("ec_log_stored", "cf_log_stored")
  
  
  # Compute stats for continuous variables (Mean + SD)
  continuous_summary_stored <- idexx_bl_stored %>%
    select(all_of(continuous_vars), assignment) %>%
    pivot_longer(
      cols = all_of(continuous_vars),
      names_to = "variable",
      values_to = "value"
    ) %>%
    group_by(variable, assignment) %>%
    summarise(
      mean = mean(value, na.rm = TRUE),
      sd = sd(value, na.rm = TRUE),
      formatted_stat = sprintf("%.1f (%.2f)", mean, sd),
      .groups = "drop"
    ) %>%
    select(variable, assignment, formatted_stat)
  
  
  
  
  
  
  
  # Combine all summaries
  desc_stats_cen <- bind_rows(
    binary_categorical_summary_cen,
    multi_categorical_summary,
    continuous_summary,
    binary_categorical_summary_bl,
    binary_categorical_summary_tap,
    binary_categorical_summary_stored,
    continuous_summary_tap,
    continuous_summary_stored
  ) %>%
    pivot_wider(names_from = assignment, values_from = formatted_stat)
  
  # Convert to gt table
  desc_stats_cen %>%
    gt() %>%
    tab_header(title = "Descriptive Statistics with Standard Errors")
  
  
  
  ```
  
  
  
  
  \newpage
  # Baseline Balance
  
  See Stata code
  
  
  
  
  \newpage
  # Follow-up Surveys Chlorine and Microbiological Contamination - Desc Stats and Figures
  
  ```{
    r Followup Surveys - Chlorine and Microbiological Contamination
  }
  
  
  # Microbiological contamination ------------------------------------------------
  
  #Separating out follow-up rounds
  idexx_fu <- idexx_tab %>%
    filter(data_round != "BL")
  
  #Separating stored vs tap water tests ------
  idexx_ids <- idexx_tab %>%
    dplyr::select(
      assignment,
      village,
      block,
      panchayat_village,
      data_round,
      sample_ID,
      bag_ID_tap,
      bag_ID_stored
    )
  
  idexx_tab_tap <- idexx_tab %>%
    filter(sample_type == "Tap") %>%
    #filter(pooled_round == "FU")%>%
    dplyr::select(
      sample_ID,
      assignment,
      village,
      block,
      panchayat_village,
      data_round,
      pooled_round,
      cf_pa_binary,
      ec_pa_binary,
      cf_log,
      ec_log
    ) %>%
    rename(cf_pa_tap = "cf_pa_binary") %>%
    rename(ec_pa_tap = "ec_pa_binary") %>%
    rename(cf_log_tap = "cf_log") %>%
    rename(ec_log_tap = "ec_log")
  
  idexx_tab_stored <- idexx_tab %>%
    filter(sample_type == "Stored") %>%
    #filter(pooled_round == "FU")%>%
    dplyr::select(
      sample_ID,
      assignment,
      village,
      block,
      panchayat_village,
      data_round,
      pooled_round,
      cf_pa_binary,
      ec_pa_binary,
      cf_log,
      ec_log
    ) %>%
    rename(cf_pa_stored = "cf_pa_binary") %>%
    rename(ec_pa_stored = "ec_pa_binary") %>%
    rename(cf_log_stored = "cf_log") %>%
    rename(ec_log_stored = "ec_log")
  
  
  #Creating desc stats for stored and tap samples ------------------------------------------------
  
  #Used in creating figures below
  tc_stats_pooled <- pooled_stats(idexx_fu)
  
  tc_stats_bl <- pooled_stats(idexx_tab)
  
  tc_stats_round <- round_stats(idexx_tab)
  
  all_stats_bl <- all_stats(idexx_tab)
  
  
  
  #Creating figure of baseline IDEXX results
  #Plotting treatment/control stats on a bar plot
  p_ec_bl <- ggplot(data = tc_stats_bl) +
    geom_point(
      aes(x = sample_type, y = `% Positive for E. coli`, color = assignment),
      position = position_dodge(width = 0.35),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = sample_type,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = assignment
      ),
      position = position_dodge(width = 0.35),
      width = .2
    ) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(
      x = "Sample Type",
      y = expression(paste("% positive for ", italic("E. coli"))),
      color = "Assignment",
      title = expression(
        paste(
          "Presence of Total Coliform and ",
          italic("E. coli"),
          " in Household Drinking Water (N = 160)"
        )
      ),
      caption = "Stored and tap water samples were collected during the baseline survey round in October 2023."
      #title = expression(paste(italic("E. coli"), " r3 - Presence in Tap and Stored Drinking Water in Odisha (N = 166)"))
    ) +
    theme_classic() +
    theme(axis.text.x = element_text(vjust = 1))
  
  p_ec_bl
  
  #ggsave(filename = "manuscript_ecoli_baseline_results.jpeg", path = (paste0(github_path(), "/3_manuscript/figures")), dpi = 1080, width = 4, height = 2, units = "in", scale = 2.6)
  
  
  
  
  #Creating figure of pooled IDEXX results
  
  #Plotting treatment/control stats on a bar plot
  p_ec_pooled <- ggplot(data = tc_stats_pooled) +
    geom_point(
      aes(x = sample_type, y = `% Positive for E. coli`, color = assignment),
      position = position_dodge(width = 0.35),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = sample_type,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = assignment
      ),
      position = position_dodge(width = 0.35),
      width = .2
    ) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(
      x = "Sample Type",
      y = expression(paste("% positive for ", italic("E. coli"))),
      color = "Assignment",
      title = expression(
        paste(
          "Presence of ",
          italic("E. coli"),
          " in Household Drinking Water (N = 961)"
        )
      ),
      caption = "Stored and tap water samples were pooled across 6 household surveys rounds across 20 villages in February, March, April, August, September, and October 2024."
      #title = expression(paste(italic("E. coli"), " r3 - Presence in Tap and Stored Drinking Water in Odisha (N = 166)"))
    ) +
    theme_classic() +
    theme(axis.text.x = element_text(vjust = 1))
  
  p_ec_pooled
  
  #ggsave(filename = "manuscript_ecoli_pooled_results.jpeg", path = (paste0(github_path(), "/3_manuscript/figures")), dpi = 1080, width = 4, height = 2, units = "in", scale = 2.6)
  
  
  
  
  
  #Combining baseline results and pooled results into one figure
  p_ec <- p_ec_bl + p_ec_pooled
  p_ec
  
  ggsave(
    filename = "manuscript_ecoli_results.pdf",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 3.5,
    height = 1.5,
    units = "in",
    scale = 2
  )
  
  
  
  
  #Plotting stacked bar plot for risk levels
  p_ec_risk <- idexx_tab %>%
    filter(pooled_round == "FU") %>%
    ggplot(aes(x = assignment, fill = ec_risk)) +
    geom_bar(position = "fill", aes(y = ..prop.., group = ec_risk)) +
    facet_wrap(~ sample_type) +
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(
      values = c(
        "High Risk" = "red",
        "Intermediate Risk" = "orange",
        "Low Risk" = "yellow",
        "Very Low Risk - Nondetectable" = "green"
      ),
      name = expression(paste(italic("E. coli"), " Risk Level"))
    ) +
    labs(
      title = expression(
        paste(
          "WHO ",
          italic("E. coli"),
          "Risk Classification Levels in Stored and Tap Drinking Water",
          " (0, 1-10, 10-100, >100 MPN ",
          italic("E. coli"),
          " per 100 mL sample) (N = 961)"
        )
      ),
      x = "Study Assignment",
      y = "Proportion (%)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5),
      legend.position = "right"
    )
  
  p_ec_risk
  
  
  ggsave(
    filename = "SI_ecoli_risk_levels_v1.jpeg",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 7,
    height = 3,
    units = "in",
    scale = 2
  )
  
  
  
  
  
  #Comparing IDEXX E. coli results to average chlorine concentration
  #Creating new variables to represent chlorination thresholds (> 0.2 mg/L)
  idexx_tab <- idexx_tab %>%
    mutate(
      fc_tap_pa_2 = case_when(fc_tap_avg >= 0.2 ~ ">= 0.2 mg/L", fc_tap_avg < 0.2 ~ "< 0.2 mg/L")
    ) %>%
    mutate(
      fc_stored_pa_2 = case_when(
        fc_stored_avg >= 0.2 ~ ">= 0.2 mg/L",
        fc_stored_avg < 0.2 ~ "< 0.2 mg/L"
      )
    ) %>%
    mutate(
      fc_ec_tap = case_when(
        fc_tap_avg >= 0.2 &
          ec_pa_binary == 0 ~ ">= 0.2 mg/L and absence of E. coli",
        fc_tap_avg >= 0.2 &
          ec_pa_binary == 1 ~ ">= 0.2 mg/L and presence of E. coli",
        fc_tap_avg < 0.2 &
          ec_pa_binary == 0 ~ "< 0.2 mg/L and absence of E. coli",
        fc_tap_avg < 0.2 &
          ec_pa_binary == 1 ~ "< 0.2 mg/L and presence of E. coli"
      )
    )
  
  
  #Summarizing descriptive statistics for each sample type
  #These descriptive stats then feed into the plot below
  tap_stats_pooled <- idexx_tab %>%
    filter(data_round != "BL") %>% #Filtering for only follow up rounds
    filter(sample_type == "Tap") %>% #Filtering for tap samples only
    group_by(fc_tap_pa_2) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      "Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(ec_pa_binary * 100) / sqrt(n())),
      "Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(ec_pa_binary * 100) / sqrt(n())),
      "% Tap Samples with Free Chlorine > 0.2 mg/L" =
        round((sum(
          fc_tap_pa_2 == "Presence"
        ) / n()) * 100, 1),
      "% Stored Samples with Free Chlorine > 0.2 mg/L" =
        round((sum(
          fc_stored_pa_2 == "Presence"
        ) / n()) * 100, 1)
    ) %>%
    rename(fc_level = "fc_tap_pa_2") %>%
    mutate(sample_type = "Tap") %>%
    mutate(
      `Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0, `Lower CI - EC` >= 0 ~ `Lower CI - EC`)
    ) %>%
    mutate(
      `Upper CI - EC` = case_when(`Upper CI - EC` > 100 ~ 100, `Upper CI - EC` <= 100 ~ `Upper CI - EC`)
    )
  
  stored_stats_pooled <- idexx_tab %>%
    filter(data_round != "BL") %>% #Filtering for followup rounds only
    filter(sample_type == "Stored") %>% #Filtering for stored water samples
    group_by(fc_stored_pa_2) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      "Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(ec_pa_binary * 100) / sqrt(n())),
      "Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(ec_pa_binary * 100) / sqrt(n())),
      "% Tap Samples with Free Chlorine > 0.2 mg/L" =
        round((sum(
          fc_tap_pa_2 == "Presence"
        ) / n()) * 100, 1),
      "% Stored Samples with Free Chlorine > 0.2 mg/L" =
        round((sum(
          fc_stored_pa_2 == "Presence"
        ) / n()) * 100, 1)
    ) %>%
    rename(fc_level = "fc_stored_pa_2") %>% #Renaming threshold variable
    mutate(sample_type = "Stored") %>%
    #Adjusting so the CI cannot be more or less than 0 or 100
    mutate(
      `Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0, `Lower CI - EC` >= 0 ~ `Lower CI - EC`)
    ) %>%
    mutate(
      `Upper CI - EC` = case_when(`Upper CI - EC` > 100 ~ 100, `Upper CI - EC` <= 100 ~ `Upper CI - EC`)
    )
  
  cl_ec_plot_stats <- rbind(tap_stats_pooled, stored_stats_pooled)
  
  
  
  
  
  
  
  #Making plot to display chlorine results vs IDEXX results
  
  #new code
  #Plotting treatment/control stats on a bar plot
  p_cl_ec_pooled <- ggplot(data = cl_ec_plot_stats) +
    geom_point(
      aes(x = sample_type, y = `% Positive for E. coli`, color = fc_level),
      position = position_dodge(width = 0.35),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = sample_type,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = fc_level
      ),
      position = position_dodge(width = 0.35),
      width = .1
    ) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(
      x = "Sample Type",
      y = expression(paste("% positive for ", italic("E. coli"))),
      color = "Free Chlorine Concentration",
      title = expression(paste(
        "Presence of ", italic("E. coli"), " in Drinking Water (N = 961)"
      ))
      #title = expression(paste(italic("E. coli"), " r3 - Presence in Tap and Stored Drinking Water in Odisha (N = 166)"))
    ) +
    theme_classic() +
    theme(axis.text.x = element_text(vjust = 1))
  
  p_cl_ec_pooled
  
  ggsave(
    filename = "manuscript_cl_ecoli_comparison.pdf",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 2.5,
    height = 1.5,
    units = "in",
    scale = 2
  )
  
  
  
  
  
  
  
  
  #Plotting time series data of microbial contamination and chlorine testing
  
  
  #Summarizing weekly chlorine monitoring data
  
  #Summarizing data on a weekly basis for taps only
  # Create a week variable
  mon_summary_weekly <- mon_summary %>%
    filter(chlorine_test == "Nearest Tap" |
             chlorine_test == "Farthest Tap") %>% #Filtering only for tap water here
    #mutate(test_week = floor_date(test_date, unit = "week"))%>%
    mutate(test_week = floor_date(test_date - days(
      as.numeric(test_date - ymd("2024-01-01")) %% 14
    ), unit = "day"))#Selecting weeks on a bi-weekly basis
  
  # Group by week and calculate the average concentration
  mon_summary_weekly <- mon_summary_weekly %>%
    group_by(test_week) %>% #To add back in nearest vs farthest tap, add in "chlorine_test" variable here
    summarise(
      avg_concentration = mean(chlorine_concentration, na.rm = TRUE),
      se_concentration = sd(chlorine_concentration, na.rm = TRUE) / sqrt(n()),
      lower_ci = avg_concentration - qt(0.975, df = n() - 1) * se_concentration,
      upper_ci = avg_concentration + qt(0.975, df = n() - 1) * se_concentration,
      cl_presence = round((sum(cl_pa == 1) / n()) * 100, 1),
      lower_ci_pa = (sum(cl_pa == 1) / n()) * 100 -
        (qt(0.975, n() - 1) * sd(cl_pa * 100) / sqrt(n())),
      #Can I use a 95% CI on presence/absence data?
      upper_ci_pa = (sum(cl_pa == 1) / n()) * 100 +
        (qt(0.975, n() - 1) * sd(cl_pa * 100) / sqrt(n()))
    ) %>%
    # Correcting negative lower CI values to be 0 instead
    mutate(lower_ci_pa = case_when(
      lower_ci_pa < 0 ~ 0, lower_ci_pa >= 0 ~ lower_ci_pa
    )) %>%
    mutate(
      upper_ci_pa = case_when(upper_ci_pa > 100 ~ 100, upper_ci_pa <= 100 ~ upper_ci_pa)
    ) %>%
    mutate(lower_ci = ifelse(lower_ci < 0, 0, lower_ci))
  
  
  
  
  
  
  
  
  #Combining summary IDEXX data with weekly chlorine monitoring
  #Formatting weekly chlorine monitoring dataset to combine with E. coli data
  idexx_cl_comb_1 <- mon_summary_weekly %>%
    select(
      test_week,
      avg_concentration,
      lower_ci,
      upper_ci,
      cl_presence,
      lower_ci_pa,
      upper_ci_pa
    ) %>% #Selecting key variables
    mutate(sample_type = NA) %>%
    mutate(assignment = "Treatment") %>%
    mutate(`% Positive for E. coli` = NA) %>%
    mutate(`Lower CI - EC` = NA) %>%
    mutate(`Upper CI - EC` = NA) %>%
    mutate(`Lower CI - Tap` = NA) %>%
    mutate(`Upper CI - Tap` = NA)#Adding in variables from the other dataset so they can be directly combined
  
  #Formatting IDEXX results to be paired with chlorine monitoring data
  idexx_cl_comb_2 <- tc_stats_round %>%
    rename("test_week" = "data_round_month") %>% #renaming to align with other dataset
    select(
      test_week,
      assignment,
      sample_type,
      `% Positive for E. coli`,
      `Lower CI - EC`,
      `Upper CI - EC`,
      `Tap - Average Free Chlorine Concentration (mg/L)`,
      `Lower CI - Tap`,
      `Upper CI - Tap`
    ) %>%
    filter(sample_type == "Tap") %>%
    mutate(
      lower_ci = NA,
      upper_ci = NA,
      cl_presence = NA,
      lower_ci_pa = NA,
      upper_ci_pa = NA
    )
  idexx_cl_comb_2 <- idexx_cl_comb_2 %>%
    rename("avg_concentration" = `Tap - Average Free Chlorine Concentration (mg/L)`)
  
  #Removing chlorine tests from control group -- all null
  idexx_cl_comb_2 <- idexx_cl_comb_2 %>%
    mutate(
      avg_concentration = ifelse(avg_concentration > 0.05, avg_concentration, NA)
    ) %>%
    mutate(`Lower CI - Tap` = ifelse(
      avg_concentration > 0.05, `Lower CI - Tap`, NA
    )) %>%
    mutate(`Upper CI - Tap` = ifelse(
      avg_concentration > 0.05, `Upper CI - Tap`, NA
    ))
  
  
  #Combining datasets together
  idexx_cl_comb <- rbind(idexx_cl_comb_1, idexx_cl_comb_2)
  rm(idexx_cl_comb_1)
  rm(idexx_cl_comb_2) #Removing preliminary dataframes
  
  
  #Creating scale value for figure
  scale_value <- 100 / 2
  
  
  
  #Creating desc plot of weekly free chlorine positive samples + IDEXX E. coli results
  
  
  
  #Separate microbial contamination and chlorine results -----
  
  #Microbial results
  #Plotting treatment/control stats on a bar plot
  p_ec_cl_1 <- idexx_cl_comb %>%
    ggplot() +
    geom_point(
      aes(x = test_week, y = `% Positive for E. coli`, color = assignment),
      position = position_dodge(width = 5),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = test_week,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = assignment
      ),
      position = position_dodge(width = 5),
      width = 6
    ) +
    geom_vline(
      aes(xintercept = ymd("2024-02-01")),
      lty = 2,
      color = "#FF474C"
    ) + #Placing intervention start date
    geom_text(
      aes(
        x = ymd("2024-02-01"),
        y = 80,
        label = "Intervention Start"
      ),
      nudge_x = -19,
      color = "#FF474C",
      size = 3
    ) +
    geom_vline(
      aes(xintercept = ymd("2024-07-01")),
      lty = 2,
      color = "darkblue"
    ) + #Placing monsoon start date
    geom_text(
      aes(
        x = ymd("2024-07-01"),
        y = 80,
        label = "Monsoon Onset"
      ),
      size = 3,
      nudge_x = -18,
      color = "darkblue"
    ) +
    geom_vline(
      aes(xintercept = ymd("2024-08-20")),
      lty = 2,
      color = "darkgreen"
    ) + #Placing target dose change date
    geom_text(
      aes(
        x = ymd("2024-08-20"),
        y = 80,
        label = "Target"
      ),
      size = 3,
      nudge_x = -10,
      color = "darkgreen"
    ) +
    geom_text(
      aes(
        x = ymd("2024-08-20"),
        y = 75,
        label = "Dose"
      ),
      size = 3,
      nudge_x = -10,
      color = "darkgreen"
    ) +
    geom_text(
      aes(
        x = ymd("2024-08-20"),
        y = 70,
        label = "Increase"
      ),
      size = 3,
      nudge_x = -10,
      color = "darkgreen"
    ) +
    scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
    scale_x_date(
      limits = c(ymd("2023-10-06"), ymd("2024-10-15")),
      date_breaks = "1 month",
      # Adds more frequent x-axis breaks (monthly)
      date_labels = "%b"
    ) +
    scale_fill_brewer(palette = "Pastel1") +
    labs(
      x = "Date",
      y = expression(paste(
        "% of tap samples positive for ", italic("E. coli")
      )),
      color = "Assignment",
      title = "",
      caption = ""
      #title = expression(paste(italic("E. coli"), " r3 - Presence in Tap and Stored Drinking Water in Odisha (N = 166)"))
    ) +
    theme_classic() +
    theme(#axis.text.x = element_text(angle=45, vjust=1, hjust=1)
      axis.text.x = element_blank(), axis.title.x = element_blank())
  
  
  p_ec_cl_1
  
  
  
  #Plotting chlorine positive samples time series
  p_ec_cl_2 <- idexx_cl_comb %>%
    ggplot() +
    geom_errorbar(
      aes(x = test_week, ymin = lower_ci_pa, ymax = upper_ci_pa),
      width = 2,
      color = "black"
    ) + #Does not include robust standard errors for village clustering
    geom_point(aes(x = test_week, y = cl_presence), size = 3) +
    geom_path(aes(x = test_week, y = cl_presence), color = "black") + #Geom path makes the plot cluttered
    geom_vline(
      aes(xintercept = ymd("2024-02-01")),
      lty = 2,
      color = "#FF474C"
    ) + #Placing intervention start date
    geom_vline(
      aes(xintercept = ymd("2024-07-01")),
      lty = 2,
      color = "darkblue"
    ) + #Placing monsoon start date
    geom_vline(
      aes(xintercept = ymd("2024-08-20")),
      lty = 2,
      color = "darkgreen"
    ) + #Placing target dose change date
    # geom_text(aes(x = ymd("2024-02-01"), y = 80, label = "Intervention Start"),
    #           nudge_x = -25, color = "#FF474C")+
    scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
    scale_x_date(
      limits = c(ymd("2023-10-03"), ymd("2024-10-15")),
      date_breaks = "1 month",
      # Adds more frequent x-axis breaks (monthly)
      date_labels = "%b"
    ) +
    scale_fill_brewer(palette = "Pastel1") +
    labs(
      x = "Date",
      y = '% of tap samples positive for chlorine (>0.1 mg/L)',
      color = "Assignment",
      title = "",
      caption = ""
      #title = expression(paste(italic("E. coli"), " r3 - Presence in Tap and Stored Drinking Water in Odisha (N = 166)"))
    ) +
    theme_classic() +
    theme(
      axis.text.x = element_text(
        angle = 45,
        vjust = 1,
        hjust = 1
      ),
      plot.title = element_text(size = 2)
    )
  
  
  p_ec_cl_2
  
  
  #Combining in patchwork so the scales are correct
  p_ec_cl <- p_ec_cl_1 / p_ec_cl_2
  p_ec_cl
  
  ggsave(
    filename = "manuscript_e_coli_chlorine_time_series_v5.pdf",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 6,
    height = 3,
    units = "in",
    scale = 2
  )
  
  
  
  ```
  
  
  
  
  
  
  
  
  
  
  
  \newpage
  # Antibiotic Resistance Desc Stats and Figures
  
  ```{
    r abr analyses, eval = FALSE
  }
  
  
  #Creating plot of baseline ABR results
  
  #Separating out baseline measurements
  #Summarizing desc stats
  tc_stats_abr <- abr_stats(idexx_abr) %>%
    filter(data_round == "BL")
  
  #Plotting treatment/control stats on a bar plot
  p_ec_abr <- ggplot(data = tc_stats_abr) +
    geom_point(
      aes(x = sample_type, y = `% Positive for E. coli`, color = assignment),
      position = position_dodge(width = 0.35),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = sample_type,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = assignment
      ),
      position = position_dodge(width = 0.35),
      width = .2
    ) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(
      x = "Sample Type",
      y = expression(paste("% positive for ABR ", italic("E. coli"))),
      color = "Assignment",
      title = expression(
        paste(
          "Presence of Antibiotic Resistant ",
          italic("E. coli"),
          " in Household Drinking Water (N = 243)"
        )
      )
    ) +
    #facet_wrap(~ data_round)+
    theme_classic() +
    theme(axis.text.x = element_text(vjust = 1))
  
  p_ec_abr
  
  #Creating combined results across data collection rounds
  idexx_abr_fu <- idexx_abr %>%
    filter(data_round == "R3" |
             data_round == "R6") #ABR tests were only conducted in Round 3 and Round 6
  
  #Summarizing descriptive stats
  tc_stats_abr_pooled <- pooled_stats_abr(idexx_abr_fu)
  
  #Plotting treatment/control stats on a bar plot
  p_ec_abr_pooled <- ggplot(data = tc_stats_abr_pooled) +
    geom_point(
      aes(x = sample_type, y = `% Positive for E. coli`, color = assignment),
      position = position_dodge(width = 0.35),
      size = 3
    ) +
    geom_errorbar(
      aes(
        x = sample_type,
        ymin = `Lower CI - EC`,
        ymax = `Upper CI - EC`,
        color = assignment
      ),
      position = position_dodge(width = 0.35),
      width = .2
    ) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(
      x = "Sample Type",
      y = expression(paste("% positive for ABR ", italic("E. coli"))),
      color = "Assignment",
      title = expression(
        paste(
          "Presence of Antibiotic Resistant ",
          italic("E. coli"),
          " in Household Drinking Water (N = 243)"
        )
      )
    ) +
    #facet_wrap(~ data_round)+
    theme_classic() +
    theme(axis.text.x = element_text(vjust = 1))
  
  p_ec_abr_pooled
  
  
  p_abr <- p_ec_abr + p_ec_abr_pooled
  p_abr
  
  ggsave(
    filename = "manuscript_ABR_results.pdf",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 3.5,
    height = 1.5,
    units = "in",
    scale = 2
  )
  
  
  ```
  
  
  
  
  
  
  # Endline Descriptive Stats
  
  ```{
    r Endline Desc Stats, eval = FALSE
  }
  
  #Endline Census Desc Stats
  outcome_vars <- c(
    "assignment",
    "prim_source",
    "sec_source",
    "jjm_drinking",
    "water_treat_binary",
    "time_spent_treat_5",
    "tap_issues_taste"
  )
  
  #Using GT package
  #Summarizing desc stats for each variable
  #reset_gtsummary_theme()
  desc_stats_el <- el %>%
    dplyr::select(all_of(outcome_vars)) %>%
    tbl_summary(
      by = assignment,
      missing = "no",
      statistic = list(all_continuous() ~ "{mean} ({sd})", all_categorical() ~ "{p}%"),
      digits = list(all_continuous() ~ 2, all_categorical() ~ 0),
      label = list(
        prim_source ~ "Primary drinking water source",
        sec_source ~ "Use a secondary drinking water source",
        jjm_drinking ~ "Drink water from their tap connection",
        water_treat_binary ~ "Treat drinking water",
        #time_spent_treat ~ "Time spent treating water is > 10 minutes",
        time_spent_treat_5 ~ "Time spent treating water is > 5 minutes",
        tap_issues_taste ~ "Reported smell or taste issue from tap water"
      )
    ) %>%
    add_n()
  
  desc_stats_el_gt <- as_tibble(desc_stats_el) %>%
    gt::gt()
  
  # desc_stats_cen_gt%>%
  #   gtsave(path = (paste0(github_path(), "/3_manuscript/figures")), filename = "desc_stats_cen.pdf")
  
  desc_stats_el_df <- desc_stats_el %>%
    as.data.frame() %>%
    rename("Treatment" = `**Treatment**  \nN = 405`) %>%
    rename("Control" = `**Control**  \nN = 475`)
  
  
  
  
  
  
  #Subsetting follow-up survey rounds
  fu_rounds <-
    all_rounds %>%
    filter(data_round != "BL")
  
  #Baseline followup survey desc stats
  outcome_vars <- c(
    "assignment",
    "fc_tap_binary",
    "fc_stored_binary",
    "fc_tap_.2",
    "fc_stored_.2",
    "fc_tap_2ppm",
    "fc_stored_2ppm",
    "tap_taste_binary"
  )
  
  desc_stats_fu <- fu_rounds %>%
    dplyr::select(all_of(outcome_vars)) %>%
    tbl_summary(
      by = assignment,
      missing = "no",
      statistic = list(all_continuous() ~ "{mean} ({sd})", all_categorical() ~ "{p}%"),
      digits = list(all_continuous() ~ 2, all_categorical() ~ 0),
      label = list(
        fc_tap_binary ~ "Presence of free chlorine at tap connection",
        fc_stored_binary ~ "Presence of free chlorine in stored water",
        fc_tap_.2 ~ "Proportion of samples > 0.2 mg/L at tap",
        fc_stored_.2 ~ "Proportion of samples > 0.2 mg/L in stored water",
        fc_tap_2ppm ~ "Proportion of samples > 2.0 mg/L at tap",
        fc_stored_2ppm ~ "Proportion of samples > 2.0 mg/L in stored water",
        tap_taste_binary ~ "Satisfied with taste of tap water"
      )
    ) %>%
    add_n()
  
  desc_stats_fu_gt <- as_tibble(desc_stats_fu) %>%
    gt::gt()
  
  # desc_stats_bl_gt%>%
  #   gtsave(path = (paste0(github_path(), "/3_manuscript/figures")), filename = "desc_stats_bl.pdf")
  
  desc_stats_fu_df <- desc_stats_fu %>%
    as.data.frame() %>%
    rename("Treatment" = `**Treatment**  \nN = 421`) %>%
    rename("Control" = `**Control**  \nN = 420`)
  
  
  
  
  
  
  #Summarizing IDEXX results from follow up data collection rounds
  #Separating stored vs tap water tests ------
  idexx_fu_tap <- idexx_fu %>%
    filter(sample_type == "Tap") %>%
    dplyr::select(
      sample_ID,
      assignment,
      village,
      block,
      panchayat_village,
      cf_pa_binary,
      ec_pa_binary,
      cf_log,
      ec_log
    ) %>%
    rename(cf_pa_tap = "cf_pa_binary") %>%
    rename(ec_pa_tap = "ec_pa_binary") %>%
    rename(cf_log_tap = "cf_log") %>%
    rename(ec_log_tap = "ec_log")
  
  idexx_fu_stored <- idexx_fu %>%
    filter(sample_type == "Stored") %>%
    dplyr::select(
      sample_ID,
      assignment,
      village,
      block,
      panchayat_village,
      cf_pa_binary,
      ec_pa_binary,
      cf_log,
      ec_log
    ) %>%
    rename(cf_pa_stored = "cf_pa_binary") %>%
    rename(ec_pa_stored = "ec_pa_binary") %>%
    rename(cf_log_stored = "cf_log") %>%
    rename(ec_log_stored = "ec_log")
  
  
  
  #Summarizing desc stats --------------------------------------
  
  #Tap water
  desc_stats_fu_tap <- idexx_fu_tap %>%
    dplyr::select(assignment, cf_pa_tap, ec_pa_tap, cf_log_tap, ec_log_tap) %>%
    tbl_summary(
      by = assignment,
      missing = "no",
      type = c("cf_pa_tap", "ec_pa_tap", "cf_log_tap", "ec_log_tap") ~ "continuous",
      statistic = list(all_continuous() ~ "{mean} ({sd})", all_categorical() ~ "{p}%"),
      digits = list(all_continuous() ~ 2, all_categorical() ~ 0),
      label = list(
        cf_pa_tap ~ "Tap - Presence/Absence of Total Coliform",
        ec_pa_tap ~ "Tap - Presence/Absence of E. coli",
        cf_log_tap ~ "Tap - Mean Log10 of Total Coliform",
        ec_log_tap ~ "Tap - Mean Log10 of E. coli"
      )
    ) %>%
    add_n() %>%
    as.data.frame() %>%
    rename("Treatment" = `**Treatment**  \nN = 240`) %>%
    rename("Control" = `**Control**  \nN = 241`)
  
  
  #Stored water
  desc_stats_fu_stored <- idexx_fu_stored %>%
    dplyr::select(
      assignment,
      cf_pa_stored,
      ec_pa_stored,
      cf_log_stored,
      ec_log_stored
    ) %>%
    tbl_summary(
      by = assignment,
      missing = "no",
      type = c(
        "cf_pa_stored",
        "ec_pa_stored",
        "cf_log_stored",
        "ec_log_stored"
      ) ~ "continuous",
      statistic = list(all_continuous() ~ "{mean} ({sd})", all_categorical() ~ "{p}%"),
      digits = list(all_continuous() ~ 2, all_categorical() ~ 0),
      label = list(
        cf_pa_stored ~ "Stored - Presence/Absence of Total Coliform",
        ec_pa_stored ~ "Stored - Presence/Absence of E. coli",
        cf_log_stored ~ "Stored - Mean Log10 of Total Coliform",
        ec_log_stored ~ "Stored - Mean Log10 of E. coli"
      )
    ) %>%
    add_n() %>%
    as.data.frame() %>%
    rename("Treatment" = `**Treatment**  \nN = 240`) %>%
    rename("Control" = `**Control**  \nN = 240`)
  
  
  #Recombining tables
  desc_stats_fu <- bind_rows(desc_stats_el_df, desc_stats_fu_df) %>%
    bind_rows(desc_stats_fu_tap) %>%
    bind_rows(desc_stats_fu_stored) %>%
    as_tibble() %>%
    gt::gt()
  
  desc_stats_fu %>%
    gtsave(path = (
      paste0(github_path(), "/3_manuscript/figures")
    ), filename = "desc_stats_fu.pdf")
  
  
  
  
  
  
  ```
  
  
  
  
  
  \newpage
  # Treatment Effect - Chlorine and Microbial Contamination
  
  ```{
    r Chlorine and Microbial Contamination Treatment Effect
  }
  # Poisson Regression - Treatment Effect -------------------------------------------------
  
  #Removing BL data
  idexx_fu <-
    idexx_tab %>%
    filter(data_round != "BL")
  
  #Separating by tap and stored water
  idexx_fu_tap <-
    idexx_fu %>%
    filter(sample_type == "Tap")
  
  idexx_fu_stored <-
    idexx_fu %>%
    filter(sample_type == "Stored")
  
  
  #Running Poisson Regression on Tap Samples ----
  outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
  
  idexx_model <- factormaker(idexx_fu_tap, outcome_vars) #Converting to numeric type
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_poisson_tap <- ilc_model_table_only(all_models)
  idexx_poisson_tap <- idexx_poisson_tap %>%
    mutate(model_name = ifelse(
      model_name == "cf_pa_binary", "cf_tap", "ec_tap"
    )) %>%
    mutate(sample_type = "Tap")
  
  
  #Running Poisson Regression on Stored Samples ----
  outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
  
  idexx_model <- factormaker(idexx_fu_stored, outcome_vars) #Converting to numeric type
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_poisson_stored <- ilc_model_table_only(all_models)
  idexx_poisson_stored <- idexx_poisson_stored %>%
    mutate(
      model_name = ifelse(model_name == "cf_pa_binary", "cf_stored", "ec_stored")
    ) %>%
    mutate(sample_type = "Stored")
  
  
  idexx_poisson <- rbind(idexx_poisson_tap, idexx_poisson_stored)
  
  
  
  #Running Linear Regression on Log-transformed E. coli Counts -- Treatment Effect
  #Running on Tap Samples ----
  outcome_vars <- c("cf_log", "ec_log") #Selecting outcome variables
  
  idexx_model <- idexx_fu_tap #setting model dataset
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_lm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_lm_tap <- ilc_model_lm_table_only(all_models)
  idexx_lm_tap <- idexx_lm_tap %>%
    mutate(model_name = ifelse(model_name == "cf_log", "cf_log", "ec_log")) %>% #Naming models
    mutate(sample_type = "Tap")
  
  
  #Running Poisson Regression on Stored Samples ----
  outcome_vars <- c("cf_log", "ec_log") #Selecting outcome variables
  
  idexx_model <- idexx_fu_stored #setting model dataset
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_lm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_lm_stored <- ilc_model_lm_table_only(all_models)
  idexx_lm_stored <- idexx_lm_stored %>%
    mutate(model_name = ifelse(model_name == "cf_log", "cf_log", "ec_log")) %>% #Naming models
    mutate(sample_type = "Stored")
  
  
  idexx_lm <- rbind(idexx_lm_tap, idexx_lm_stored)
  
  
  
  
  
  
  
  #-----------------------------------------------------------------------------
  
  
  #-----------------------------------------------------------------------------
  
  
  
  
  
  
  
  # Chlorine Concentration -----------------------------------------------------
  
  
  #Running regression models -----------------------------------------------
  
  #Variables
  outcome_vars <- c("fc_tap_binary", "fc_stored_binary")
  
  fu_model <- factormaker(fu_rounds, outcome_vars)
  
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = fu_model, var)
  })
  
  #linear regression
  # all_models <- lapply(outcome_vars,
  #                      function(var){ #This functions "subsets" the ilc_glm function
  #                        ilc_lm(data = fu_rounds, var)
  #                      }
  #                        )
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Making regression table output
  cl_poisson <- ilc_model_table_only(all_models)
  cl_poisson <- cl_poisson %>%
    mutate(
      model_name = ifelse(model_name == "fc_tap_binary", "fc_tap", "fc_stored")
    ) %>%
    mutate(sample_type = ifelse(
      model_name == "fc_tap_binary", "Tap", "Stored"
    ))
  
  
  
  #Combining microbial contamination and chlorination treatment effect results
  fu_poisson <- rbind(idexx_poisson, cl_poisson)
  
  
  
  
  ```
  
  
  # Treatment Effect - Antibiotic Resistance
  
  ```{
    r Treatment Effect - ABR
  }
  
  
  # Poisson Regression - Treatment Effect -------------------------------------------------
  
  #Removing BL data
  idexx_abr_fu <- idexx_abr %>%
    filter(data_round != "BL")
  
  #Separating by tap and stored water
  idexx_abr_tap <- idexx_abr_fu %>%
    filter(sample_type == "Tap")
  
  idexx_abr_stored <- idexx_abr_fu %>%
    filter(sample_type == "Stored")
  
  
  #Running Poisson Regression on Tap Samples ----
  
  outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
  
  idexx_model <- factormaker(idexx_abr_tap, outcome_vars) #Converting to numeric type
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_poisson_tap <- ilc_model_table_only(all_models)
  idexx_poisson_tap <- idexx_poisson_tap %>%
    mutate(model_name = ifelse(
      model_name == "cf_pa_binary", "cf_tap", "ec_tap"
    )) %>%
    mutate(sample_type = "Tap")
  
  
  #Running Poisson Regression on Stored Samples ----
  
  outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
  
  idexx_model <- factormaker(idexx_abr_stored, outcome_vars) #Converting to numeric type
  
  #Running all models
  #Poisson regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = idexx_model, var)
  })
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  idexx_poisson_stored <- ilc_model_table_only(all_models)
  idexx_poisson_stored <- idexx_poisson_stored %>%
    mutate(
      model_name = ifelse(model_name == "cf_pa_binary", "cf_stored", "ec_stored")
    ) %>%
    mutate(sample_type = "Stored")
  
  
  idexx_abr_poisson <- rbind(idexx_poisson_tap, idexx_poisson_stored)
  rm(idexx_poisson_stored, idexx_poisson_tap) #Removing preliminary dataframes
  
  
  
  ```
  
  
  
  
  \newpage
  # Treatment Effect - Endline Census
  
  ```{
    r Endline Census Comparison
  }
  
  
  # Poisson Regression -- Treatment Effect -------------------------------------
  
  outcome_vars <- c(
    "prim_source_jjm",
    "sec_source",
    "jjm_drinking",
    "water_treat_binary",
    "tap_issues_taste",
    "time_spent_treat_5"
  )
  
  el_model <- factormaker(el, outcome_vars) #Making variables numeric
  
  
  #Poisson Regression
  all_models <- lapply(outcome_vars, function(var) {
    #This functions "subsets" the ilc_glm function
    ilc_glm(data = el_model, var)
  })
  
  
  #linear regression -- not used, but available for comparison
  # all_models <- lapply(outcome_vars,
  #                      function(var){ #This functions "subsets" the ilc_glm function
  #                        ilc_lm(data = el_model, var)
  #                      }
  #                        )
  
  #Assigning names to models
  names(all_models) <- outcome_vars
  
  #Formatting table output
  el_models <- ilc_model_table_only(all_models)
  ilc_model_table(all_models)
  
  
  ```
  
  
  
  # Combined Forestplot Using ggplot
  
  
  ```{
    r ggplot forestplot
  }
  
  ####Code provided by Courtney Victor, UNC W&H Conference 2024
  
  
  #Removed total coliform and e. coli tap results from ABR IDEXX
  idexx_abr_poisson <- idexx_abr_poisson %>%
    filter(model_name != "cf_tap") %>%
    filter(model_name != "cf_stored") %>%
    mutate(
      model_name = ifelse(
        model_name == "ec_stored",
        "Presence Antibiotic Resistant E. coli in Stored Water",
        "Presence Antibiotic Resistant E. coli in Tap Water"
      )
    ) %>%
    select(!(sample_type))
  
  
  #Removing chlorine results from regular IDEXX results
  fu_poisson <- fu_poisson %>%
    filter(model_name != "fc_tap") %>%
    filter(model_name != "fc_stored") %>%
    select(!(sample_type))
  
  #Joining poisson model results from different datasets
  el_models_forestplot <- rbind(fu_poisson, idexx_abr_poisson, el_models)
  
  
  
  #Setting order of variables
  #Changing model names
  el_models_forestplot <- el_models_forestplot %>%
    mutate(mean = estimate) %>%
    mutate(estimate = as.character(round(estimate, 2))) %>%
    mutate(Lower_CI = round(Lower_CI, 2)) %>%
    mutate(Upper_CI = round(Upper_CI, 2)) %>%
    mutate(estimate = paste0(estimate, " (", Lower_CI, ", ", Upper_CI, ")")) %>%
    mutate(lower = Lower_CI) %>%
    mutate(upper = Upper_CI) %>%
    mutate(p_value = ifelse(
      p_value < 0.001, "< 0.001", as.character(round(p_value, 3))
    ))
  
  
  el_models_forestplot$model_name <- el_models_forestplot$model_name %>%
    factor() %>%
    fct_recode(
      "Presence of Total Coliform at Taps" = "cf_tap",
      "Presence of E. coli at Taps" = "ec_tap",
      "Presence of Total Coliform in Stored Water" = "cf_stored",
      "Presence of E. coli in Stored Water" = "ec_stored",
      "Presence Antibiotic Resistant E. coli in Stored Water" =
        "Presence Antibiotic Resistant E. coli in Stored Water",
      "Taps as Primary Source" = "prim_source_jjm",
      "Use a Secondary Source" = "sec_source",
      "Drink Tap Water" = "jjm_drinking",
      "Treat Water" = "water_treat_binary",
      "Reported Water Taste/Smell Issue" = "tap_issues_taste",
      "Time Spent Treating Water is >5 Minutes" = "time_spent_treat_5"
    )
  
  #Reordering
  el_models_forestplot$model_name <- factor(
    el_models_forestplot$model_name,
    levels =
      c(
        "Time Spent Treating Water is >5 Minutes",
        "Reported Water Taste/Smell Issue",
        "Treat Water",
        "Drink Tap Water",
        "Use a Secondary Source",
        "Taps as Primary Source",
        "Presence Antibiotic Resistant E. coli in Stored Water",
        "Presence Antibiotic Resistant E. coli in Tap Water",
        "Presence of E. coli in Stored Water",
        "Presence of Total Coliform in Stored Water",
        "Presence of E. coli at Taps",
        "Presence of Total Coliform at Taps"
      )
  )
  
  #Setting model types for color-coding in figure
  el_models_forestplot <- el_models_forestplot %>%
    mutate(
      variable_type = ifelse(
        model_name %in% c(
          "Presence Antibiotic Resistant E. coli in Stored Water",
          "Presence Antibiotic Resistant E. coli in Tap Water",
          "Presence of E. coli in Stored Water",
          "Presence of Total Coliform in Stored Water",
          "Presence of E. coli at Taps",
          "Presence of Total Coliform at Taps"
        ),
        "Water Quality Outcome",
        "Behavioral Outcome"
      )
    )
  
  
  
  #Creating Foresplot using ggplot
  
  p_forestplot <- ggplot(el_models_forestplot, aes(x = mean, y = model_name)) +
    geom_point(aes(color = variable_type), size = 2) +
    geom_errorbarh(
      aes(xmin = Lower_CI, xmax = Upper_CI, color = variable_type),
      height = 0.2
    ) +
    geom_vline(
      xintercept = 1,
      linetype = "dashed",
      color = "black"
    ) + # Dashed line at x = 1 (null Risk Ratio)
    scale_y_discrete(
      labels = function(y)
        str_wrap(y, width = 35)
    ) +
    scale_x_continuous(
      limits = c(0.5, 1.90),
      breaks = c(0.50, 0.75, 1.00, 1.2)
    ) +
    scale_color_manual(
      values = c(
        "Water Quality Outcome" = "#00008B",
        "Behavioral Outcome" = "#EEA944"
      )
    ) +
    labs(x = "Prevalence Ratio", y = "Outcome") +
    theme_classic() +
    theme(
      legend.title = element_blank(),
      axis.text.y = element_text(size = 10),
      axis.title.y = element_text(size = 13),
      axis.title.x = element_text(size = 13)
    )
  
  # Add horizontal lines between levels of outcomes to create separation
  y_levels <- levels(factor(el_models_forestplot$model_name))
  y_positions <- seq_along(y_levels) - 0.5
  for (y in y_positions) {
    p_forestplot <- p_forestplot + geom_hline(
      yintercept = y,
      color = "darkgrey",
      linetype = "solid",
      linewidth = 0.5
    )
  }
  
  #Adding in effect estimates and p-values
  p_forestplot <- p_forestplot +
    geom_text(
      aes(label = estimate, x = max(Upper_CI) + 0.25),
      hjust = 0,
      size = 3
    ) +
    geom_text(
      aes(label = p_value, x = max(Upper_CI) + 0.50),
      hjust = 0,
      size = 3
    ) +
    geom_text(aes(
      label = N, x = max(Upper_CI) + 0.65
    ), hjust = 0, size = 3)
  
  
  #Viewing
  p_forestplot
  
  ggsave(
    filename = "forestplot_v2.pdf",
    path = (paste0(github_path(), "/3_manuscript/figures")),
    dpi = 1080,
    width = 11,
    height = 6,
    units = "in"
  )
  
  
  ```
  
  
  
  
  \newpage
  # Treatment Effect - Controlling for Baseline Measurements
  
  
  ```{
    r Prepping and joining baseline data
  }
  
  
  #Defining bl variables to select
  cen_vars <- c(
    "unique_id",
    "village",
    "prim_source_jjm",
    "sec_source",
    "jjm_drinking",
    "water_treat_binary"
    # Not in data "tap_issues_taste", "time_spent_treat", "time_spent_treat_15", "time_spent_treat_5"
  )
  
  #Selecting census variables to keep
  cen_model <- cen %>%
    dplyr::select(all_of(cen_vars)) %>%
    rename(bl_prim_source_jjm = "prim_source_jjm") %>%
    rename(bl_sec_source = "sec_source") %>%
    rename(bl_jjm_drinking = "jjm_drinking") %>%
    rename(bl_water_treat_binary = "water_treat_binary")
  
  #Summarizing stats for each village
  #The baseline measurements are controlled for in the models using averages across villages
  cen_model <- cen_model %>%
    group_by(village) %>%
    summarise(
      bl_prim_source_jjm = mean(bl_prim_source_jjm, na.rm = TRUE),
      bl_sec_source = mean(bl_sec_source, na.rm = TRUE),
      bl_jjm_drinking = mean(bl_jjm_drinking, na.rm = TRUE),
      bl_water_treat_binary = mean(bl_water_treat_binary, na.rm = TRUE)
    )
  
  
  #Gathering baseline variable names
  cen_model_vars <- colnames(cen_model)[-1] #removing unique id variable
  
  
  #bl dataset
  bl_vars <- c("unique_id", "village", "treat_time_5min") #But can I use this to control for baseline data if the dataset is partial?
  #Selecting census variables to keep
  bl_model <- bl %>%
    dplyr::select(all_of(bl_vars)) %>%
    rename(bl_treat_time_5min = "treat_time_5min")
  
  #Summarizing stats for each village
  bl_model <- bl_model %>%
    group_by(village) %>%
    summarise(bl_treat_time_5min = mean(bl_treat_time_5min, na.rm = TRUE))
  
  
  #Gathering baseline variable names
  bl_model_vars <- colnames(bl_model)[-1]
  
  
  
  
  #IDEXX - Standard
  
  #make unique id a character from "idexx" so it can be joined
  #filter for sample type
  
  idexx_bl_tap <- idexx_tab %>%
    filter(sample_type == "Tap") %>%
    dplyr::select(
      unique_id,
      village,
      cf_log,
      ec_log#, cf_log, ec_log) %>%
      rename(bl_cf_pa_tap = "cf_log") %>%
        rename(bl_ec_pa_tap = "ec_log") %>%
        # rename(cf_log_tap = "cf_log")%>%
        # rename(ec_log_tap = "ec_log")%>%
        mutate(unique_id = as.character(unique_id))
      
      #Summarizing stats for each village
      idexx_bl_tap <- idexx_bl_tap %>%
        group_by(village) %>%
        summarise(
          bl_cf_pa_tap = mean(bl_cf_pa_tap, na.rm = TRUE),
          bl_ec_pa_tap = mean(bl_ec_pa_tap, na.rm = TRUE)
        )
      
      idx_tap_vars <- colnames(idexx_bl_tap)[-1]
      
      idexx_bl_stored <- idexx_tab %>%
        filter(sample_type == "Stored") %>%
        dplyr::select(
          unique_id,
          village,
          cf_log,
          ec_log#, cf_log, ec_log) %>%
          rename(bl_cf_pa_stored = "cf_log") %>%
            rename(bl_ec_pa_stored = "ec_log") %>%
            # rename(cf_log_stored = "cf_log")%>%
            # rename(ec_log_stored = "ec_log")%>%
            mutate(unique_id = as.character(unique_id))
          
          #Summarizing stats for each village
          idexx_bl_stored <- idexx_bl_stored %>%
            group_by(village) %>%
            summarise(
              bl_cf_pa_stored = mean(bl_cf_pa_stored, na.rm = TRUE),
              bl_ec_pa_stored = mean(bl_ec_pa_stored, na.rm = TRUE)
            )
          
          
          idx_stored_vars <- colnames(idexx_bl_stored)[-1]
          
          
          
          #IDEXX - ABR
          idexx_bl_abr_tap <- idexx_abr %>%
            filter(data_round == "BL") %>%
            filter(sample_type == "Tap") %>%
            dplyr::select(unique_id, village, ec_log) %>%
            rename(bl_ec_abr_tap = "ec_log") %>%
            mutate(unique_id = as.character(unique_id))
          
          #Summarizing stats for each village
          idexx_bl_abr_tap <- idexx_bl_abr_tap %>%
            group_by(village) %>%
            summarise(bl_ec_abr_tap = mean(bl_ec_abr_tap, na.rm = TRUE))
          
          abr_tap_vars <- colnames(idexx_bl_abr_tap)[-1]
          
          
          idexx_bl_abr_stored <- idexx_abr %>%
            filter(data_round == "BL") %>%
            filter(sample_type == "Stored") %>%
            dplyr::select(unique_id, village, ec_log) %>%
            rename(bl_ec_abr_stored = "ec_log") %>%
            mutate(unique_id = as.character(unique_id))
          
          #Summarizing stats for each village
          idexx_bl_abr_stored <- idexx_bl_abr_stored %>%
            group_by(village) %>%
            summarise(bl_ec_abr_stored = mean(bl_ec_abr_stored, na.rm = TRUE))
          
          abr_stored_vars <- colnames(idexx_bl_abr_stored)[-1]
          
          
          
          
          
          #Joining data to endline dataset
          el_model <- el %>%
            left_join(cen_model, by = "village") %>%
            left_join(bl_model, by = "village")
          
          
          
          #Joining IDEXX data
          #Removing BL data
          idexx_fu <- idexx_tab %>%
            filter(data_round != "BL")
          
          #Separating by tap and stored water
          idexx_fu_tap <- idexx_fu %>%
            filter(sample_type == "Tap") %>%
            mutate(unique_id = as.character(unique_id))
          
          idexx_fu_stored <- idexx_fu %>%
            filter(sample_type == "Stored") %>%
            mutate(unique_id = as.character(unique_id))
          
          #Joining datasets
          idexx_fu_tap <- idexx_fu_tap %>%
            left_join(idexx_bl_tap, by = "village")
          
          idexx_fu_stored <- idexx_fu_stored %>%
            left_join(idexx_bl_stored, by = "village")
          
          
          
          #Removing BL data
          idexx_abr_fu <- idexx_abr %>%
            filter(data_round != "BL")
          
          #Separating by tap and stored water
          idexx_abr_tap <- idexx_abr_fu %>%
            filter(sample_type == "Tap") %>%
            mutate(unique_id = as.character(unique_id))
          
          idexx_abr_stored <- idexx_abr_fu %>%
            filter(sample_type == "Stored") %>%
            mutate(unique_id = as.character(unique_id))
          
          #Joining datasets
          idexx_abr_tap <- idexx_abr_tap %>%
            left_join(idexx_bl_abr_tap, by = "village")
          
          idexx_abr_stored <- idexx_abr_stored %>%
            left_join(idexx_bl_abr_stored, by = "village")
          
          
          
          
          
          
          
          
          ```
          
          
          ```{
            r Endline Treatment Effect--Controlling for Baseline Measurements
          }
          
          
          #Treatment Effect with Baseline Measurement Controls -- Endline Census
          
          outcome_vars <- c(
            "prim_source_jjm",
            "sec_source",
            #Issue after code cleaning updates
            "jjm_drinking",
            "water_treat_binary",
            "time_spent_treat_5"
          )
          
          bl_vars <- c(
            "bl_prim_source_jjm",
            "bl_sec_source",
            "bl_jjm_drinking",
            "bl_water_treat_binary",
            "bl_treat_time_5min"
          )
          
          
          
          el_model <- factormaker(el_model, outcome_vars) #Making variables numeric
          el_model <- factormaker(el_model, bl_vars) #Making variables numeric
          
          
          
          #Poisson Regression
          all_models <- mapply(function(var, bl_var) {
            ilc_glm_bl(data = el_model,
                       var = var,
                       bl_var = bl_var)
          }, outcome_vars, bl_vars, SIMPLIFY = FALSE)
          
          #Assigning names to models
          names(all_models) <- outcome_vars
          
          #Formatting table output
          el_models <- ilc_model_table_only(all_models)
          ilc_model_table(all_models)
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          # Treatment Effect w/ Baseline Measurement Controls - IDEXX ----------------------------------------
          
          
          #Running Poisson Regression on Tap Samples ----
          
          
          outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
          bl_vars <- c("bl_cf_pa_tap", "bl_ec_pa_tap")
          
          
          idexx_model <- factormaker(idexx_fu_tap, outcome_vars) #Converting to numeric type
          idexx_model <- factormaker(idexx_fu_tap, bl_vars)
          
          #Running all models
          #Poisson regression
          all_models <- mapply(function(var, bl_var) {
            ilc_glm_bl(data = idexx_model,
                       var = var,
                       bl_var = bl_var)
          }, outcome_vars, bl_vars, SIMPLIFY = FALSE)
          
          #Assigning names to models
          names(all_models) <- outcome_vars
          
          #Formatting table output
          idexx_poisson_tap <- ilc_model_table_only(all_models)
          idexx_poisson_tap <- idexx_poisson_tap %>%
            mutate(model_name = ifelse(
              model_name == "cf_pa_binary", "cf_tap", "ec_tap"
            )) %>%
            mutate(sample_type = "Tap")
          
          
          #Running Poisson Regression on Stored Samples ----
          
          outcome_vars <- c("cf_pa_binary", "ec_pa_binary") #Selecting outcome variables
          bl_vars <- c("bl_cf_pa_stored", "bl_ec_pa_stored")
          
          
          idexx_model <- factormaker(idexx_fu_stored, outcome_vars) #Converting to numeric type
          idexx_model <- factormaker(idexx_fu_stored, bl_vars)
          
          #Running all models
          #Poisson regression
          all_models <- mapply(function(var, bl_var) {
            ilc_glm_bl(data = idexx_model,
                       var = var,
                       bl_var = bl_var)
          }, outcome_vars, bl_vars, SIMPLIFY = FALSE)
          
          #Assigning names to models
          names(all_models) <- outcome_vars
          
          #Formatting table output
          idexx_poisson_stored <- ilc_model_table_only(all_models)
          idexx_poisson_stored <- idexx_poisson_stored %>%
            mutate(
              model_name = ifelse(model_name == "cf_pa_binary", "cf_stored", "ec_stored")
            ) %>%
            mutate(sample_type = "Stored")
          
          
          idexx_poisson <- rbind(idexx_poisson_tap, idexx_poisson_stored)
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          # Treatment effect w/ baseline measurement controls -- Antibiotic Resistance
          
          
          
          
          #Running Poisson Regression on Tap Samples ----
          
          outcome_vars <- c("ec_pa_binary") #Selecting outcome variables
          bl_vars <- c("bl_ec_abr_tap")
          
          
          idexx_model <- factormaker(idexx_abr_tap, outcome_vars) #Converting to numeric type
          idexx_model <- factormaker(idexx_model, bl_vars)
          
          #Running all models
          #Poisson regression
          all_models <- mapply(function(var, bl_var) {
            ilc_glm_bl(data = idexx_model,
                       var = var,
                       bl_var = bl_var)
          }, outcome_vars, bl_vars, SIMPLIFY = FALSE)
          
          
          #Assigning names to models
          names(all_models) <- outcome_vars
          
          #Formatting table output
          idexx_poisson_tap <- ilc_model_table_only(all_models)
          idexx_poisson_tap <- idexx_poisson_tap %>%
            mutate(model_name = ifelse(
              model_name == "cf_pa_binary", "cf_tap", "ec_tap"
            )) %>%
            mutate(sample_type = "Tap")
          
          
          #Running Poisson Regression on Stored Samples ----
          
          outcome_vars <- c("ec_pa_binary") #Selecting outcome variables
          bl_vars <- c("bl_ec_abr_stored")
          
          
          idexx_model <- factormaker(idexx_abr_stored, outcome_vars) #Converting to numeric type
          idexx_model <- factormaker(idexx_model, bl_vars)
          
          #Running all models
          #Poisson regression
          all_models <- mapply(function(var, bl_var) {
            ilc_glm_bl(data = idexx_model,
                       var = var,
                       bl_var = bl_var)
          }, outcome_vars, bl_vars, SIMPLIFY = FALSE)
          
          #Assigning names to models
          names(all_models) <- outcome_vars
          
          #Formatting table output
          idexx_poisson_stored <- ilc_model_table_only(all_models)
          idexx_poisson_stored <- idexx_poisson_stored %>%
            mutate(
              model_name = ifelse(model_name == "cf_pa_binary", "cf_stored", "ec_stored")
            ) %>%
            mutate(sample_type = "Stored")
          
          
          idexx_abr_poisson <- rbind(idexx_poisson_tap, idexx_poisson_stored)
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          #Updating idexx_poisson
          idexx_poisson <- idexx_poisson %>%
            dplyr::select(!(sample_type))
          
          
          #Updating idexx_abr_poisson
          idexx_abr_poisson <- idexx_abr_poisson %>%
            filter(model_name != "cf_tap") %>%
            filter(model_name != "cf_stored") %>%
            mutate(
              model_name = ifelse(
                model_name == "ec_stored",
                "Presence Antibiotic Resistant E. coli in Stored Water",
                "Presence Antibiotic Resistant E. coli in Tap Water"
              )
            ) %>%
            select(!(sample_type))
          
          
          #Joining poisson results
          el_models_forestplot <- rbind(idexx_poisson, idexx_abr_poisson, el_models)
          
          #Setting order of variables
          #Changing model names
          el_models_forestplot <- el_models_forestplot %>%
            mutate(mean = estimate) %>%
            mutate(estimate = as.character(round(estimate, 2))) %>%
            mutate(Lower_CI = round(Lower_CI, 2)) %>%
            mutate(Upper_CI = round(Upper_CI, 2)) %>%
            mutate(estimate = paste0(estimate, " (", Lower_CI, ", ", Upper_CI, ")")) %>%
            mutate(lower = Lower_CI) %>%
            mutate(upper = Upper_CI) %>%
            mutate(p_value = ifelse(
              p_value < 0.001, "< 0.001", as.character(round(p_value, 3))
            ))
          
          
          
          
          el_models_forestplot$model_name <- el_models_forestplot$model_name %>%
            factor() %>%
            fct_recode(
              "Presence of Total Coliform at Taps" = "cf_tap",
              "Presence of E. coli at Taps" = "ec_tap",
              "Presence of Total Coliform in Stored Water" = "cf_stored",
              "Presence of E. coli in Stored Water" = "ec_stored",
              "Presence Antibiotic Resistant E. coli in Stored Water" =
                "Presence Antibiotic Resistant E. coli in Stored Water",
              "Taps as Primary Source" = "prim_source_jjm",
              "Use a Secondary Source" = "sec_source",
              "Drink Tap Water" = "jjm_drinking",
              "Treat Water" = "water_treat_binary",
              "Time Spent Treating Water is >5 Minutes" = "time_spent_treat_5"
            )
          #Reordering
          el_models_forestplot$model_name <- factor(
            el_models_forestplot$model_name,
            levels =
              c(
                "Time Spent Treating Water is >5 Minutes",
                "Treat Water",
                "Drink Tap Water",
                "Use a Secondary Source",
                "Taps as Primary Source",
                "Presence Antibiotic Resistant E. coli in Stored Water",
                "Presence Antibiotic Resistant E. coli in Tap Water",
                "Presence of E. coli in Stored Water",
                "Presence of Total Coliform in Stored Water",
                "Presence of E. coli at Taps",
                "Presence of Total Coliform at Taps"
              )
          )
          
          el_models_forestplot <- el_models_forestplot %>%
            mutate(
              variable_type = ifelse(
                model_name %in% c(
                  "Presence Antibiotic Resistant E. coli in Stored Water",
                  "Presence Antibiotic Resistant E. coli in Tap Water",
                  "Presence of E. coli in Stored Water",
                  "Presence of Total Coliform in Stored Water",
                  "Presence of E. coli at Taps",
                  "Presence of Total Coliform at Taps"
                ),
                "Water Quality Outcome",
                "Behavioral Outcome"
              )
            )
          
          
          
          
          #Creating Foresplot using ggplot
          
          ## Create plot
          p_forestplot <- ggplot(el_models_forestplot, aes(x = mean, y = model_name)) +
            geom_point(aes(color = variable_type), size = 2) +
            geom_errorbarh(
              aes(xmin = Lower_CI, xmax = Upper_CI, color = variable_type),
              height = 0.2
            ) +
            geom_vline(
              xintercept = 1,
              linetype = "dashed",
              color = "black"
            ) + # Dashed line at x = 1 (null Risk Ratio)
            scale_y_discrete(
              labels = function(y)
                str_wrap(y, width = 35)
            ) +
            scale_x_continuous(
              limits = c(0.15, 1.90),
              breaks = c(0.25, 0.50, 0.75, 1.00, 1.2)
            ) +
            scale_color_manual(
              values = c(
                "Water Quality Outcome" = "#00008B",
                "Behavioral Outcome" = "#EEA944"
              )
            ) +
            labs(x = "Prevalence Ratio", y = "Outcome") +
            theme_classic() +
            theme(
              legend.title = element_blank(),
              axis.text.y = element_text(size = 10),
              axis.title.y = element_text(size = 13),
              axis.title.x = element_text(size = 13)
            ) #+
          #guides(color = guide_legend(reverse = TRUE)) # Ensures the order of the legend matches the order in which point estimates appear on the plot
          
          # Add horizontal lines between levels of outcomes to create separation
          y_levels <- levels(factor(el_models_forestplot$model_name))
          y_positions <- seq_along(y_levels) - 0.5
          for (y in y_positions) {
            p_forestplot <- p_forestplot + geom_hline(
              yintercept = y,
              color = "darkgrey",
              linetype = "solid",
              linewidth = 0.5
            )
          }
          
          #Adding in effect estimates and p-values
          p_forestplot <- p_forestplot +
            geom_text(
              aes(label = estimate, x = max(Upper_CI) + 0.25),
              hjust = 0,
              size = 3
            ) +
            geom_text(
              aes(label = p_value, x = max(Upper_CI) + 0.50),
              hjust = 0,
              size = 3
            ) +
            geom_text(aes(
              label = N, x = max(Upper_CI) + 0.65
            ), hjust = 0, size = 3)
          
          
          #Viewing
          p_forestplot
          
          ggsave(
            filename = "forestplot_bl_control_v1.pdf",
            path = (paste0(github_path(), "/3_manuscript/figures")),
            dpi = 1080,
            width = 11,
            height = 6,
            units = "in"
          )
          
          
          
          
          
          ```
          