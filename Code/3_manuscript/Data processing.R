# Packages =====================================================================
packages <-
  c(
    "broom",
    "tidyverse",
    "janitor",
    "assertthat"
  )

pacman::p_load(packages, character.only = TRUE)

# Load data ====================================================================
# See Process Doc for details on cleaning code and clean datasets:
#https://docs.google.com/document/d/1Hpv5HF5ICO5FSVdQnPtDECCYORn2qy5S7C_KIx0pDuM/edit

cen         <- read_csv(file.path(user_path(), "1_1_baseline_census.csv")) %>% clean_names
bl          <- read_csv(file.path(user_path(), "1_1_baseline_survey.csv")) %>% clean_names
el          <- read_csv(file.path(user_path(), "1_8_endline_census.csv")) %>% clean_names
idexx_tab   <- read_csv(file.path(user_path(), "1_10_idexx_all_rounds.csv")) %>% clean_names
idexx_abr   <- read_csv(file.path(user_path(), "1_10_idexx_abr.csv")) %>% clean_names
mon_summary <- read_csv(file.path(user_path(), "1_11_weekly_monitoring.csv")) %>% clean_names
all_rounds  <- read_csv(file.path(user_path(), "1_8_surveys_all_rounds.csv")) %>% clean_names


# Water testing ================================================================

## Regular ---------------------------------------------------------------------
idexx_tab %>%
  group_by(sample_id) %>%
  filter(n() > 1) 

assert_that(
  nrow(idexx_tab) == 
    (idexx_tab %>% select(sample_id) %>% n_distinct)
)

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
    cf_pa = cf_pa_binary,
    ec_pa = ec_pa_binary,
    cf_log,
    ec_log
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

## Antibiotic resistant --------------------------------------------------------

# Two duplicates:
idexx_abr %>%
  group_by(sample_id) %>%
  filter(n() > 1) 

idexx_abr_clean <-
  idexx_abr %>%
  group_by(sample_id) %>%
  filter(n() == 1) %>%
  ungroup %>%
  dplyr::select(
    unique_id,
    data_round,
    pooled_round,
    sample_id,
    sample_type,
    assignment,
    village,
    block,
    panchayat_village,
    cf_abr_pa = cf_pa_binary,
    ec_abr_pa = ec_pa_binary,
    cf_abr_log = cf_log,
    ec_abr_log = ec_log,
    fc_tap_avg_abr = fc_tap_avg,
    fc_sotred_avg_abr = fc_stored_avg
  ) %>%
  pivot_wider(
    id_cols = c(unique_id, data_round),
    values_from = c(
      sample_id,
      cf_abr_pa,
      ec_abr_pa,
      cf_abr_log,
      ec_abr_log
    ),
    names_sep = "_",
    names_from = sample_type
  ) %>%
  clean_names

idexx <- full_join(idexx_clean, idexx_abr_clean)

# Survey analysis data =========================================================

survey_idexx <- 
  all_rounds %>%
  inner_join(idexx) %>%
  mutate(
    across(
      c(panchayat_village, block),
      ~ as_factor(.)
    ),
    across(
      c(jjm_drinking),
      ~ (. == "Yes") %>% as.numeric
    ),
    stratum = fct_cross(panchayat_village, block)
  )

# Follow up data only
fu <-
  survey_idexx %>%
  filter(data_round != "BL") 

# Baseline data only
bl <- 
  survey_idexx %>%
  filter(data_round == "BL") %>%
  select(
    unique_id,
    village,
    contains("ec"),
    contains("cf"),
    contains("tc"),
    prim_source_jjm,
    sec_source,
    jjm_drinking
  ) %>%
  rename_with(
    ~ paste0(.x, "_bl"),
    - c(unique_id, village)
  ) %>%
  group_by(village) %>%
  summarise(
    across(
      -unique_id,
      ~ mean(., na.rm = TRUE)
    )
  )

# Baseline in columns
analysis <-
  fu %>%
  left_join(bl)

write_rds(
  analysis,
  file.path(
    user_path(),
    "analysis_data.rds"
  )
)

write_rds(
  survey_idexx,
  file.path(
    user_path(),
    "all_survey_rounds.rds"
  )
)

# Census =======================================================================

assignment <-
  analysis %>%
  select(village, block, stratum, assignment) %>%
  unique

census <-
  bind_rows(
    cen, el,
    .id = "data_round"
  ) %>%
  mutate(
    across(
      c(
        hhhead_gender_binary, 
        read_write_binary, 
        sec_source, 
        jjm_drinking, 
        water_treat_binary, 
        electricity_binary, 
        tv_binary, 
        mobile_binary, 
        fridge_binary, 
        motorcycle_binary
      ),
      ~ case_when(
        . %in% c("yes", "Yes", "1") ~ 1,
        . %in% c("no", "No", "0") ~ 0,
        TRUE ~ NA_real_ # Ensures missing values remain as NA
      )
    ),
    tap_issues_taste = tap_issues_taste - 1,
    data_round = factor(
      data_round,
      levels = c(1, 2),
      labels = c("BL", "EL")
    )
  ) %>%
  select(-assignment) %>%
  left_join(assignment)

write_rds(
  census,
  file.path(
    user_path(),
    "census.rds"
  )
)

