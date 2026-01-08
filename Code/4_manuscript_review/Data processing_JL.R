
# Packages ---------------------------------------------------------------------
packages <-
  c(
    "broom",
    "tidyverse",
    "janitor"
  )

pacman::p_load(packages, character.only = TRUE)

# Load data --------------------------------------------------------------------

cen         <- read_csv(file.path(user_path(), "1_1_baseline_census.csv"))
bl          <- read_csv(file.path(user_path(), "1_1_baseline_survey.csv"))
el          <- read_csv(file.path(user_path(), "1_8_endline_census.csv"))
idexx_tab   <- read_csv(file.path(user_path(), "1_10_idexx_all_rounds.csv")) %>% clean_names
idexx_abr   <- read_csv(file.path(user_path(), "1_10_idexx_abr.csv"))
mon         <- read_csv(file.path(user_path(), "1_11_weekly_monitoring_WIDE.csv"))
all_rounds  <- read_csv(file.path(user_path(), "1_8_surveys_all_rounds.csv"))



#Processing Endline Datasets ---------------------------------------------------


# Microbial Contamination 
# Separating stored vs tap water tests 
idexx_clean <-
  idexx_tab %>%
  dplyr::select(
    unique_id,
    data_round,
    pooled_round,
    sample_type,
    sample_id,
    assignment,
    village,
    block,
    panchayat_village,
    cf_pa_binary,
    ec_pa_binary,
    cf_log,
    ec_log
  ) %>%
  rename(
    cf_pa = cf_pa_binary,
    ec_pa = ec_pa_binary
  ) %>%
  pivot_wider(
    values_from = c(
      sample_id,
      cf_pa,
      ec_pa,
      cf_log,
      ec_log
    ),
    names_sep = "_",
    names_from = sample_type
  ) %>%
  clean_names

#Antibiotic Resistant Testing
idexx_abr_clean <-
  idexx_abr %>%
  dplyr::select(
    unique_id,
    data_round,
    pooled_round,
    sample_type,
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
  rename(
    cf_pa_abr = cf_pa_binary,
    ec_pa_abr = ec_pa_binary,
    cf_log_abr = cf_log,
    ec_log_abr = ec_log
  ) %>%
  pivot_wider(
    values_from = c(
      sample_ID,
      cf_pa_abr,
      ec_pa_abr,
      cf_log_abr,
      ec_log_abr
    ),
    names_sep = "_",
    names_from = sample_type
  ) %>%
  clean_names

#Endline Census
el_clean <- 
  el%>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    stratum = fct_cross(panchayat_village, block)
  )

# All household data collection rounds (not baseline or endline censuses)
all_rounds_clean <- 
  all_rounds %>%
  clean_names

all_data <- 
  all_rounds_clean %>%
  left_join(idexx_clean)%>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    stratum = fct_cross(panchayat_village, block)
  )

#Creating new variables to represent chlorination thresholds
all_data <- all_data%>%
  mutate(fc_tap_pa_2 = case_when(fc_tap_avg >= 0.2 & fc_tap_avg < 0.6 ~
                                   ">= 0.2 mg/L, < 0.6 mg/L",
                                 fc_tap_avg >= 0.6 & fc_tap_avg < 1.0 ~
                                   ">= 0.6 mg/L, < 1.0 mg/L",
                                 fc_tap_avg >= 1.0 & fc_tap_avg <= 2.2 ~
                                   ">= 1.0 mg/L, < 2.2 mg/L",
                                 fc_tap_avg < 0.2 ~ "< 0.2 mg/L"))
all_data$fc_tap_pa_2 <- factor(all_data$fc_tap_pa_2)%>%
  fct_recode("< 0.2 mg/L" = "< 0.2 mg/L",
             ">= 0.2 mg/L, < 0.6 mg/L" = ">= 0.2 mg/L, < 0.6 mg/L",
             ">= 0.6 mg/L, < 1.0 mg/L" = ">= 0.6 mg/L, < 1.0 mg/L",
             ">= 1.0 mg/L, < 2.2 mg/L"= ">= 1.0 mg/L, < 2.2 mg/L"
  )


#Processing baseline data ------------------------------------------------------

bl_variables <- #Only selecting needed variables from this dataset
  bl%>%
  select(
    unique_id,
    village,
    treat_time_5min,
    collect_resp_women,
    collect_resp_men,
    collect_resp_both,
    treat_resp_women,
    treat_resp_men,
    treat_resp_both
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    c(
      treat_time_5min,
      collect_resp_women,
      collect_resp_men,
      collect_resp_both,
      treat_resp_women,
      treat_resp_men,
      treat_resp_both
    )
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ sum(., na.rm = TRUE)
    )
  )


#Baseline Microbial Contamination
idexx_bl <- #Only selecting needed variables from this dataset
  all_data %>%
  filter(data_round == "BL") %>%
  select(
    unique_id,
    village,
    cf_pa_tap,
    ec_pa_tap,
    cf_pa_stored,
    ec_pa_stored,
    ec_log_tap,
    ec_log_stored,
    cf_log_tap,
    cf_log_stored
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    c(
      cf_pa_tap,
      ec_pa_tap,
      cf_pa_stored,
      ec_pa_stored,
      ec_log_tap,
      ec_log_stored,
      cf_log_tap,
      cf_log_stored
    )
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ mean(., na.rm = TRUE)
    )
  )


#Baseline ABR
idexx_abr_bl <- #Only selecting needed variables from this dataset
  idexx_abr_clean%>%
  filter(data_round == "BL") %>%
  select(
    unique_id,
    village,
    ec_pa_abr_tap,
    ec_pa_abr_stored
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    c(
      ec_pa_abr_tap,
      ec_pa_abr_stored
    )
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ mean(., na.rm = TRUE)
    )
  )


#Baseline Census
cen_data <- #Only selecting needed variables from this dataset
  cen%>%
  select(
    unique_id,
    village,
    prim_source_jjm,
    sec_source,
    jjm_drinking,
    water_treat_binary
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    c(
      prim_source_jjm,
      sec_source,
      jjm_drinking,
      water_treat_binary
    )
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ sum(., na.rm = TRUE)
    )
  )


#Joining Baseline and Endline Variables into Analysis Datasets -----------------

analysis <-
  el_clean %>%
  left_join(bl_variables)%>%
  left_join(cen_data)%>%
  mutate(
    tap_issues_taste_bl = 1
  )%>%
  rename(time_spent_treat_5_bl = treat_time_5min_bl)


analysis_idexx <- idexx_clean%>%
  filter(pooled_round == "FU")%>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    stratum = fct_cross(panchayat_village, block)
  )%>%
  left_join(idexx_bl)

analysis_abr <- idexx_abr_clean%>%
  filter(data_round != "BL")%>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    stratum = fct_cross(panchayat_village, block)
  )%>%
  left_join(idexx_abr_bl)




#Chlorine Monitoring Data ------------------------------------------------------


#Filtering for data after intervention delivery was completed in February 2024
mon <- mon%>%
  filter(test_date >= ymd("2024-02-01"))


#Adding doser type
mon <- mon%>%
  mutate(doser_type = case_when(village_code == "AS" ~ "CTI-8",
                                village_code == "BA" ~ "CTI-8",
                                village_code == "BI" ~ "CTI-8",
                                village_code == "BN" ~ "PurAll",
                                village_code == "GO" ~ "CTI-8",
                                village_code == "KA" ~ "PurAll",
                                village_code == "MU" ~ "CTI-8",
                                village_code == "NAI" ~ "PurAll",
                                village_code == "NAT" ~ "PurAll",
                                village_code == "TA" ~ "CTI-8"
  ))

#Creating long data set where each row represents a chlorine test
mon_long <- mon%>%
  pivot_longer(names_to = "chlorine_test", values_to = "chlorine_concentration",
               cols = c(nearest_tap_fc, farthest_tap_fc, nearest_stored_fc, farthest_stored_fc,
                        nearest_tap_tc, farthest_tap_tc, nearest_stored_tc, farthest_stored_tc))
#creating new variables to represent test type and location
mon_long <- mon_long%>%
  mutate(test_sample = case_when(str_detect(chlorine_test, "tap") ~ "Tap",
                                 str_detect(chlorine_test, "stored") ~ "Stored"
  ))%>%
  mutate(free_or_total = case_when(str_detect(chlorine_test, "fc") ~ "Free",
                                   str_detect(chlorine_test, "tc") ~ "Total"
  ))%>%
  mutate(test_tap = case_when(str_detect(chlorine_test, "farthest") ~ "Far",
                              str_detect(chlorine_test, "nearest") ~ "Near"
  ))




#Recoding chlorine concentration sample types
mon_long$chlorine_test <- factor(mon_long$chlorine_test)
mon_long$chlorine_test <- fct_recode(mon_long$chlorine_test,
                                "Nearest Tap Free" = "nearest_tap_fc",
                                "Nearest Stored Free" = "nearest_stored_fc",
                                "Farthest Tap Free" = "farthest_tap_fc",
                                "Farthest Stored Free" = "farthest_stored_fc",
                                "Nearest Tap Total" = "nearest_tap_tc",
                                "Nearest Stored Total" = "nearest_stored_tc",
                                "Farthest Tap Total" = "farthest_tap_tc",
                                "Farthest Stored Total" = "farthest_stored_tc")

#Summarizing data on a weekly basis for taps only
#Creating presence/absence variable
mon_long <- mon_long%>%
  mutate(cl_pa = case_when(chlorine_concentration >= 0.1 ~ 1,
                           chlorine_concentration < 0.1 ~ 0,
  ))

# Create a test week variable
mon_long <- mon_long%>%
mutate(test_week = floor_date(test_date - days(as.numeric(test_date - ymd("2024-01-01")) %% 14),
                              unit = "day"))%>% #Selecting weeks on a bi-weekly basis
  mutate(test_month = floor_date(test_date - days(as.numeric(test_date - ymd("2024-01-01")) %% 31),
                                unit = "day"))

#Diagnosing chlorine monitoring data problems:

#Summarizing
# mon_summary <- mon_long%>%
#   group_by(test_date, chlorine_test, 
#            village_name
#   )%>% #Previously, village_name was not included
#   summarise("chlorine_concentration" = mean(chlorine_concentration),
#             "village" = village_name
#   ) #Was I averaging across all villages because I didn't group by them?
#I don't think these are needed, use mon_long directly

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#Summarizing data on a weekly basis for taps only
# Create a week variable
# mon_long_weekly <- mon_long%>%
#   filter(chlorine_test == "Nearest Tap Free" | chlorine_test == "Farthest Tap Free")%>% #Filtering only for tap water here
#   #mutate(test_week = floor_date(test_date, unit = "week"))%>%
#   mutate(test_week = floor_date(test_date - days(as.numeric(test_date - ymd("2024-01-01")) %% 14),
#                                 unit = "day"))#Selecting weeks on a bi-weekly basis
# 
# # Group by week and calculate the average concentration
# mon_long_weekly <- mon_long_weekly%>%
#   group_by(test_week)%>% #To add back in nearest vs farthest tap, add in "chlorine_test" variable here
#   summarise(avg_concentration = mean(chlorine_concentration, na.rm = TRUE),
#             se_concentration = sd(chlorine_concentration, na.rm = TRUE) / sqrt(n()),
#             lower_ci = avg_concentration - qt(0.975, df = n() - 1) * se_concentration,
#             upper_ci = avg_concentration + qt(0.975, df = n() - 1) * se_concentration,
#             cl_presence = round((sum(cl_pa == 1) / n()) * 100, 1),
#             lower_ci_pa = (sum(cl_pa == 1) / n()) * 100 -
#               (qt(0.975, n() - 1) * sd(cl_pa*100)/sqrt(n())), #Can I use a 95% CI on presence/absence data?
#             upper_ci_pa = (sum(cl_pa == 1) / n()) * 100 +
#               (qt(0.975, n() - 1) * sd(cl_pa*100)/sqrt(n())),
#             sample_size = n()
#   )%>%
#   # Correcting negative lower CI values to be 0 instead
#   mutate(lower_ci_pa = case_when(lower_ci_pa < 0 ~ 0,
#                                  lower_ci_pa >= 0 ~ lower_ci_pa))%>%
#   mutate(upper_ci_pa = case_when(upper_ci_pa > 100 ~ 100,
#                                  upper_ci_pa <= 100 ~ upper_ci_pa))%>%
#   mutate(lower_ci = ifelse(lower_ci < 0, 0, lower_ci))



#Writing analysis data =========================================================

write_rds(
  analysis,
  file.path(
    user_path(),
    "analysis_data.rds"
  )
)

write_rds(
  analysis_idexx,
  file.path(
    user_path(),
    "analysis_idexx.rds"
  )
)

write_rds(
  analysis_abr,
  file.path(
    user_path(),
    "analysis_abr.rds"
  )
)

write_rds(
  all_data,
  file.path(
    user_path(),
    "rounds.rds"
  )
)

write_rds(
  mon,
  file.path(
    user_path(),
    "chlorine_monitoring.rds"
  )
)

write_rds(
  mon_long,
  file.path(
    user_path(),
    "chlorine_monitoring_long.rds"
  )
)
