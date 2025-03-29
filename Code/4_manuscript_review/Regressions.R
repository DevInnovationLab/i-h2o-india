packages <- 
  c(
    "fixest",
    "broom",
    "tidyverse",
    "modelsummary"
  )

pacman::p_load(packages, character.only = TRUE)

# Data -------------------------------------------------------------------------

outcomes <-
  c(
    "Presence of Total Coliform at Taps"= "cf_pa_tap",
    "Presence of E. coli at Taps"= "ec_pa_tap",
    "Presence of Total Coliform in Stored Water"= "cf_pa_stored",
    "Presence of E. coli in Stored Water"= "ec_pa_stored",
    "Taps as Primary Source" = "prim_source_jjm",
    "Use a Secondary Source" = "sec_source",
    "Drink Tap Water" = "jjm_drinking",
    "Treat Water" = "water_treat_binary",
    "Reported Water Taste/Smell Issue" = "tap_taste_binary"
  )


analysis <-
  read_rds(
    file.path(
      user_path(),
      "analysis_data.rds"
    )
  )

fu_village <-
  analysis %>%
  group_by(village, block, panchayat_village, stratum, assignment) %>%
  summarise(
    across(
      c(outcomes) %>% unname,
      ~ sum(., na.rm = TRUE)
    ),
    across(
      ends_with("_bl"),
      ~ unique(.)
    ),
    N = n()
  )

# Running regression models -----------------------------------------------------

# Individual level -------------------------------------------------------------

ind_bl <-
  outcomes[1:7] %>%
  map(
    ~ list(
        paste(., "~ assignment | block + panchayat_village"),
        paste(., "~ assignment | stratum"),
        paste(., "~ assignment"),
        paste(., "~ assignment +", paste0(., "_bl")) 
    ) %>%
      map(~ as.formula(.)) %>%
      map(
        ~ feglm(
          .,
          data = analysis,
          family = poisson,
          cluster = ~ village
        )
      )
  )

# Variables with no baseline values
ind_nobl <-
  outcomes[8:9] %>%
  map(
    ~ list(
      paste(., "~ assignment | block + panchayat_village"),
      paste(., "~ assignment | stratum"),
      paste(., "~ assignment")
    ) %>%
      map(~ as.formula(.)) %>%
      map(
        ~ feglm(
          .,
          data = analysis,
          family = poisson,
          cluster = ~ village,
        )
      )
  )

ind <- c(ind_bl, ind_nobl)

# Village level ----------------------------------------------------------------

vil_bl <-
  outcomes[1:7] %>%
  map(
    ~ list(
      paste(., "~ assignment + offset(log(N)) | block + panchayat_village"),
      paste(., "~ assignment + offset(log(N)) | stratum"),
      paste(., "~ assignment + offset(log(N))"),
      paste(., "~ assignment + offset(log(N)) +", paste0(., "_bl"))
    ) %>%
      map(~ as.formula(.)) %>%
      map(
        ~ feglm(
          .,
          data = fu_village,
          family = poisson,
          se = 'iid'
        )
      )
  )

vil_nobl <-
  outcomes[8:9] %>%
  map(
    ~ list(
      paste(., "~ assignment + offset(log(N)) | block + panchayat_village"),
      paste(., "~ assignment + offset(log(N)) | stratum"),
      paste(., "~ assignment + offset(log(N))")
    ) %>%
      map(~ as.formula(.)) %>%
      map(
        ~ feglm(
          .,
          data = fu_village,
          family = poisson,
          se = 'iid'
        )
      )
  )


add_rows <-
  tribble(
    ~name, ~m1, ~m2, ~m3, ~m4, ~m5, ~m6, ~m7, ~m8,
    "Control: baseline level", "", "", "", "X", "", "", "", "X"
  )

map2(
  ind_bl %>% head(4), 
  vil_bl %>% head(4),
  ~ c(.x, .y)
) %>%
   modelsummary(
      coef_rename = c("assignmentTreatment" = "Treatment"),
      coef_omit = "^(?!.*Treatment)",
      shape = "rcollapse",
      gof_omit = "IC|R2|RMSE",
      add_rows = add_rows
    )


map2(
  ind_bl %>% tail(3), 
  vil_bl %>% tail(3),
  ~ c(.x, .y)
) %>%
  modelsummary(
    coef_rename = c("assignmentTreatment" = "Treatment"),
    coef_omit = "^(?!.*Treatment)",
    shape = "rcollapse",
    gof_omit = "IC|R2|RMSE",
    add_rows = add_rows
  )

map2(
  ind_nobl, 
  vil_nobl,
  ~ c(.x, .y)
) %>%
  modelsummary(
    coef_rename = c("assignmentTreatment" = "Treatment"),
    coef_omit = "^(?!.*Treatment)",
    shape = "rcollapse",
    gof_omit = "IC|R2|RMSE"
  )




# Poisson at village level -----------------------------------------------------


