
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
mon_summary <- read_csv(file.path(user_path(), "1_11_weekly_monitoring.csv"))
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


#Processing baseline data ------------------------------------------------------
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
