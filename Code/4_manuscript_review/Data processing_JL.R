# Packages =====================================================================
packages <-
  c(
    "broom",
    "tidyverse",
    "janitor"
  )

pacman::p_load(packages, character.only = TRUE)

# Load data ====================================================================
# See Process Doc for details on cleaning code and clean datasets:
#https://docs.google.com/document/d/1Hpv5HF5ICO5FSVdQnPtDECCYORn2qy5S7C_KIx0pDuM/edit

cen         <- read_csv(file.path(user_path(), "1_1_baseline_census.csv"))
bl          <- read_csv(file.path(user_path(), "1_1_baseline_survey.csv"))
el          <- read_csv(file.path(user_path(), "1_8_endline_census.csv"))
idexx_tab   <- read_csv(file.path(user_path(), "1_10_idexx_all_rounds.csv")) %>% clean_names
idexx_abr   <- read_csv(file.path(user_path(), "1_10_idexx_abr.csv"))
mon_summary <- read_csv(file.path(user_path(), "1_11_weekly_monitoring.csv"))
all_rounds  <- read_csv(file.path(user_path(), "1_8_surveys_all_rounds.csv"))



# Fixing Tandipur and Bhujbal observations in different treatment assignments

cen <- cen%>%
  mutate(assignment = ifelse(village == "Bhujbal", "Control", 
                             ifelse(village == "Tandipur", "Treatment",
                                    assignment)
                             )
         )


# All survey rounds ============================================================

all_rounds_clean <- 
  all_rounds %>%
  clean_names


# Water testing ================================================================
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


# Combine all data =============================================================
# 
# all_data <-
#   all_rounds_clean %>%
#   left_join(idexx_clean) %>%
#   mutate(
#     across(
#       c(panchayat_village, block),
#       ~ as_factor(.)
#     ),
#     across(
#       c(jjm_drinking),
#       ~ (. == "Yes") %>% as.numeric
#     ),
#     stratum = fct_cross(panchayat_village, block)
#   )
# 
# fu <-
#   all_data %>%
#   filter(data_round != "BL")
# 
# bl <-
#   all_data %>%
#   filter(data_round == "BL") %>%
#   select(
#     unique_id,
#     village,
#     cf_pa_tap,
#     ec_pa_tap,
#     cf_pa_stored,
#     ec_pa_stored,
#     prim_source_jjm,
#     sec_source,
#     jjm_drinking,
#     treat_time_5min
#   ) %>%
#   rename_with(
#     ~ paste0(.x, "_bl"),
#     c(
#       cf_pa_tap,
#       ec_pa_tap,
#       cf_pa_stored,
#       ec_pa_stored,
#       prim_source_jjm,
#       sec_source,
#       jjm_drinking,
#       treat_time_5min
#     )
#   ) %>%
#   group_by(village) %>%
#   summarise(
#     across(
#       -unique_id,
#       ~ mean(., na.rm = TRUE)
#     )
#   )
# 
#  analysis <-
#    fu %>%
#    left_join(bl)


#JL: Repeating for endline census data with 880 observations ===========================

el_clean <- 
  el%>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    stratum = fct_cross(panchayat_village, block)
  )


#Prepping baseline data
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



bl_treat_time <- #Only selecting needed variables from this dataset
  all_data %>%
  filter(data_round == "BL") %>%
  select(
    unique_id,
    village,
    treat_time_5min
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    c(
      treat_time_5min
    )
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ sum(., na.rm = TRUE)
    )
  )


#Baseline IDEXX
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


#IDEXX ABR
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



analysis <-
  el_clean %>%
  left_join(bl_treat_time)%>%
  left_join(cen_data)

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








#Loading Luiza's data ==========================================================

# survey <-
#   read_rds(
#     file.path(
#       user_path(),
#       "analysis_data.rds"
#     )
#   ) %>%
#   mutate(
#     water_treat_binary_bl = 1,
#     tap_taste_binary_bl = 1
#   )
# 
# fu_village <-
#   survey %>%
#   group_by(village, block, panchayat_village, stratum, assignment) %>%
#   summarise(
#     across(
#       all_of(contamination %>% unname),
#       ~ sum(., na.rm = TRUE)
#     ),
#     across(
#       ends_with("_bl"),
#       ~ unique(.)
#     ),
#     N = n()
#   )

# survey <-
#   read_rds(
#     file.path(
#       user_path(),
#       "all_survey_rounds.rds"
#     )
#   ) 
# 
# census <-
#   read_rds(
#     file.path(
#       user_path(),
#       "census.rds"
#     )
#   ) 
