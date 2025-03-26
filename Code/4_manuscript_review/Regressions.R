packages <- 
  c(
    "fixest",
    "broom",
    "tidyverse"
  )

pacman::p_load(packages, character.only = TRUE)

# Data -------------------------------------------------------------------------

analysis <-
  read_rds(
    file.path(
      user_path(),
      "analysis_data.rds"
    )
  )

fu_village_level <-
  analysis %>%
  group_by(village, data_round, block, panchayat_village, stratum, assignment) %>%
  summarise(
    across(
      c(ec_pa_tap),
      ~ sum(., na.rm = TRUE)
    ),
    across(
      ends_with("_bl"),
      ~ unique(.)
    ),
    N = n()
  )



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
    "Reported Water Taste/Smell Issue" = "tap_issues_taste",
    "Time Spent Treating Water is >5 Minutes" = "time_spent_treat_5"
  )

# Jeremy's original function ---------------------------------------------------
# (For reference only, the canned function gives the same results)
fit_poisson <- function(data, var){
  
  #Specifying the formula
  formula <- as.formula(paste(var, "~ assignment + block + panchayat_village"))
  #Running model
  model <- glm(formula, data = data, family = poisson)
  
  
  # Adjust SEs for clustering at the village level
  cluster_vcov <- vcovCL(model, cluster = data$village, type = "HC1")
  # Get the coefficients with clustered standard errors
  clustered_results <- coeftest(model, vcov. = cluster_vcov)
  
  #Adding N
  tidy_results <- 
    clustered_results %>%
    tidy %>%
    set_names(c("covariate", "estimate", "std_error", "z_statistic", "p_value")) %>%
    mutate(
      N = length(model$y),
      lb = estimate - (qt(0.975, N) * std_error),
      ub = estimate + (qt(0.975, N) * std_error),
      across(
        c(estimate, std_error, lb, ub),
        ~ exp(.),
        .names = "{.col}_exp"
      ),
      lb_exp = if_else(lb_exp < 0, 0, lb_exp)
    )
  
  return(tidy_results)
}

fit_logbin <- function(data, var){
  
  #Specifying the formula
  formula <- as.formula(paste(var, "~ assignment + block + panchayat_village"))
  #Running model
  model <- glm(formula, data = data, family = binomial(link = "log"))
  
  
  # Adjust SEs for clustering at the village level
  cluster_vcov <- vcovCL(model, cluster = data$village, type = "HC1")
  # Get the coefficients with clustered standard errors
  clustered_results <- coeftest(model, vcov. = cluster_vcov)
  
  #Adding N
  tidy_results <- 
    clustered_results %>%
    tidy %>%
    set_names(c("covariate", "estimate", "std_error", "z_statistic", "p_value")) %>%
    mutate(
      N = length(model$y),
      lb = estimate - (qt(0.975, N) * std_error),
      ub = estimate + (qt(0.975, N) * std_error),
      across(
        c(estimate, std_error, lb, ub),
        ~ exp(.),
        .names = "{.col}_exp"
      ),
      lb_exp = if_else(lb_exp < 0, 0, lb_exp)
    )
  
  return(tidy_results)
}

#Running regression models -----------------------------------------------------

# Poisson ----------------------------------------------------------------------

feglm(
  ec_pa_tap ~ assignment | block + panchayat_village,
  data = analysis,
  family = poisson,
  cluster = ~ village
) %>% 
  tidy(conf.int = TRUE)

feglm(
  ec_pa_tap ~ assignment | stratum,
  data = analysis,
  family = poisson,
  cluster = ~ village
) %>% 
  tidy(conf.int = TRUE) 

feglm(
  ec_pa_tap ~ assignment,
  data = analysis,
  family = poisson,
  cluster = ~ village
) %>% 
  tidy(conf.int = TRUE) %>%
  filter(term != "(Intercept)") 


# Binomial -----------------------------------------------------------------
# Chat GPT says this is a common alternative to calculate prevalence ratios

feglm(
  ec_pa_tap ~ assignment | block + panchayat_village,
  data = analysis,
  family = binomial(link = "logit"),
  cluster = ~ village
) %>% 
  tidy(conf.int = TRUE)

# Log binomial does work
# feglm(
#   ec_pa_tap ~ assignment | block + panchayat_village,
#   data = analysis,
#   family = binomial(link = "log"),
#   cluster = ~ village
# ) %>% 
#   tidy(conf.int = TRUE)

# Negative binomial needs a parameters that I'm unsure about

# feglm(
#   ec_pa_tap ~ assignment | block + panchayat_village,
#   data = analysis,
#   family = neg.bin,
#   cluster = ~ village
# ) %>% 
#   tidy(conf.int = TRUE) 


# Poisson at village level -----------------------------------------------------

feglm(
  ec_pa_tap ~ assignment + offset(log(N))| block + panchayat_village,
  data = fu_village_level,
  family = poisson,
) %>% 
  tidy(conf.int = TRUE) 

# Controlling for baseline levels
feglm(
  ec_pa_tap ~ assignment + ec_pa_tap_bl + offset(log(N))| block + panchayat_village,
  data = fu_village_level,
  family = poisson,
) %>% 
  tidy(conf.int = TRUE) 

# Controlling for baseline value of the outcome -----------------------------------

feglm(
  ec_pa_tap ~ assignment + ec_pa_tap_bl | block + panchayat_village,
  data = analysis,
  family = poisson,
  cluster = ~ village
) %>% 
  tidy(conf.int = TRUE)

