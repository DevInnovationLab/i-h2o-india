#India ILC Pilot - Defining functions
#Author: Jeremy Lowe
#Date: 6/5/24





#labelmaker
#Converts stata formatted data to R datasets with labels
#x: .dta file from Stata
labelmaker <- function(x){
  #Works best with Stata data to convert variable names to their labels
  z <- colnames(x)
  for(i in z){
    labels <-  val_labels(x[i])
    if(is.na(labels) == FALSE){
      x[i] <- to_label(x[i])
      
    }
  }
  return(x)
}

#factormaker
#Converts all selected variables to factors/numbers. Used for Poisson regression
#x: Data
#vars: List of variables

factormaker <- function(x, vars){
  x <- x %>%
    mutate(across(all_of(vars), ~ as.numeric(factor(.)))) #First converts variables to factors so they are numbers,
  #Then converts them to numeric types. This mutates "across" all variables listed.
  return(x)
}



#Microbiological contamination descriptive stats -----------------------------


#idexx_data: Formatted IDEXX data including variables listed in the function
village_stats <- function(idexx_data){
  idexx_data%>%
    dplyr::group_by(village, sample_type) %>%
    dplyr::summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      "Median MPN E. coli/100 mL" = median(ec_mpn),
      "Average Free Chlorine Concentration (mg/L)" = round(mean(fc_tap), 3)
    )
  
  
}



tc_stats <- function(idexx_data){
  
  tc <- idexx_data%>%
    group_by(assignment, sample_type) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      #"Upper CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 + 
      # (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      "Lower CI - TC" = { #Robust standard errors accounting for clustering at villages
        model <- glm(cf_pa_binary ~ 1, family = binomial)
        vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
        se <- sqrt(vcov_cluster[1, 1])
        est <- (sum(cf_pa == "Presence") / n()) * 100
        est - qt(0.975, df.residual(model)) * se
      },
      "Upper CI - TC" = { #Robust standard errors accounting for clustering at villages
        model <- glm(cf_pa_binary ~ 1, family = binomial)
        vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
        se <- sqrt(vcov_cluster[1, 1])
        est <- (sum(cf_pa == "Presence") / n()) * 100
        est + qt(0.975, df.residual(model)) * se
      },
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      #"Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 - 
      # (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      #"Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 + 
      #  (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      "Lower CI - EC" = {
        model <- glm(ec_pa_binary ~ 1, family = binomial)
        vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
        se <- sqrt(vcov_cluster[1, 1])
        est <- (sum(ec_pa == "Presence") / n()) * 100
        est - qt(0.975, df.residual(model)) * se
      },
      "Upper CI - EC" = {
        model <- glm(ec_pa_binary ~ 1, family = binomial)
        vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
        se <- sqrt(vcov_cluster[1, 1])
        est <- (sum(ec_pa == "Presence") / n()) * 100
        est + qt(0.975, df.residual(model)) * se
      },
      "Median MPN E. coli/100 mL" = median(ec_mpn),
      "Average Free Chlorine Concentration (mg/L)" = round(mean(fc_tap), 3)
    )
  
  tc <- tc%>%
    #Adjusting so the CI cannot be more or less than 0 or 100
    mutate(`Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0,
                                       `Lower CI - EC` >= 0 ~ `Lower CI - EC`))%>%
    mutate(`Upper CI - TC` = case_when(`Upper CI - TC` > 100 ~ 100,
                                       `Upper CI - TC` <= 100 ~ `Upper CI - TC`))
  return(tc)
}




pooled_stats <- function(idexx_data){
  
  tc <- idexx_data%>%
    group_by(assignment, sample_type) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "Lower CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      "Upper CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      #   "Lower CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   est - qt(0.975, df.residual(model)) * se
      # },
      # "Upper CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   est + qt(0.975, df.residual(model)) * se
      # },
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      "Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      "Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      # # "Lower CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   est - qt(0.975, df.residual(model)) * se
      # },
      # "Upper CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   est + qt(0.975, df.residual(model)) * se
      # },
      # "Median MPN E. coli/100 mL" = median(ec_mpn)#,
      "Tap - Average Free Chlorine Concentration (mg/L)" = round(mean(fc_tap_avg), 2),
      "Stored - Average Free Chlorine Concentration (mg/L)" = round(mean(fc_stored_avg), 2)
      
    )
  
  tc <- tc%>%
    #Adjusting so the CI cannot be more or less than 0 or 100
    mutate(`Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0,
                                       `Lower CI - EC` >= 0 ~ `Lower CI - EC`))%>%
    mutate(`Upper CI - TC` = case_when(`Upper CI - TC` > 100 ~ 100,
                                       `Upper CI - TC` <= 100 ~ `Upper CI - TC`))
  return(tc)
}


#Calculates desc stats stratified by round for IDEXX data
round_stats <- function(idexx_data){
  
  tc <- idexx_data%>%
    group_by(assignment, sample_type, data_round) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "Lower CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      "Upper CI - TC" = (sum(cf_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(cf_pa_binary*100)/sqrt(n())),
      #   "Lower CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   est - qt(0.975, df.residual(model)) * se
      # },
      # "Upper CI - TC" = { #Robust standard errors accounting for clustering at villages
      #   model <- glm(cf_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(cf_pa == "Presence") / n()) * 100
      #   est + qt(0.975, df.residual(model)) * se
      # },
      "% Positive for E. coli" = round((sum(ec_pa == "Presence") / n()) * 100, 1),
      "Lower CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 -
        (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      "Upper CI - EC" = (sum(ec_pa == "Presence") / n()) * 100 +
        (qt(0.975, n() - 1) * sd(ec_pa_binary*100)/sqrt(n())),
      # # "Lower CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   est - qt(0.975, df.residual(model)) * se
      # },
      # "Upper CI - EC" = {
      #   model <- glm(ec_pa_binary ~ 1, family = binomial)
      #   vcov_cluster <- vcovCR(model, cluster = village, type = "CR2")
      #   se <- sqrt(vcov_cluster[1, 1])
      #   est <- (sum(ec_pa == "Presence") / n()) * 100
      #   est + qt(0.975, df.residual(model)) * se
      # },
      # "Median MPN E. coli/100 mL" = median(ec_mpn)#,
      "Tap - Average Free Chlorine Concentration (mg/L)" = round(mean(fc_tap_avg), 2),
      "Stored - Average Free Chlorine Concentration (mg/L)" = round(mean(fc_stored_avg), 2)
      
    )
  
  tc <- tc%>%
    #Adjusting so the CI cannot be more or less than 0 or 100
    mutate(`Lower CI - EC` = case_when(`Lower CI - EC` < 0 ~ 0,
                                       `Lower CI - EC` >= 0 ~ `Lower CI - EC`))%>%
    mutate(`Upper CI - TC` = case_when(`Upper CI - TC` > 100 ~ 100,
                                       `Upper CI - TC` <= 100 ~ `Upper CI - TC`))
  return(tc)
}






all_stats <- function(idexx_data){
  idexx_data%>%
    group_by(sample_type) %>%
    summarise(
      "Number of Samples" = n(),
      "% Positive for Total Coliform" = round((sum(cf_pa == "Presence") / n()) * 100, 1),
      "% Positive for E. coli" = round(mean(ec_pa_binary), 3)*100,
      "Average MPN E. coli/100 mL" = round(mean(ec_mpn),3),
      "Average Free Chlorine Concentration (mg/L)" = round(mean(fc_tap), 3)
    )
}


risk_stats <- function(idexx_data){
  idexx_data%>%
    group_by(assignment, ec_risk)%>%
    summarise(count = n())%>%
    mutate("E. coli Risk Levels %" = round(count/sum(count) * 100, 2))
}


#Regression results functions ----------------------------------------------

#ilc_glm
#Runs generalized linear model for comparing control and treatment group outcomes using Poisson regression
#data: overall dataset to pull from
#var: vector containing binary outcome variable names in each dataset to model
ilc_glm <- function(data, var){
  
  #Specifying the formula
  formula <- as.formula(paste(var, "~ assignment + block + panchayat_village"))
  #Running model
  model <- glm(formula, data = data, family = poisson)
  
  #Storing N
  N <- length(model$y)
  
  # Adjust for clustering at the village level
  cluster_vcov <- vcovCL(model, cluster = data$village, type = "HC1")
  # Get the coefficients with clustered standard errors
  clustered_results <- coeftest(model, vcov. = cluster_vcov)
  
  #Tidying models -- need to understand how to use clustered results option
  tidy_results <- tidy(clustered_results)
  # Rename the columns for better readability
  colnames(tidy_results) <- c("covariate", "estimate", "std_error", "z_statistic", "p_value")
  
  #Adding N
  tidy_results <- tidy_results%>%
    mutate(N = N)
  
  #exponentiate the estimates/std errors to get Prevalence Ratio
  
  tidy_results$estimate <- exp(tidy_results$estimate)
  tidy_results$std_error <- exp(tidy_results$std_error)
  
  
  return(tidy_results)
}



#ilc_lm
#Runs LINEAR model for comparing control and treatment group outcomes
#data: overall dataset to pull from
#var: vector containing outcome variable names in each dataset to model
ilc_lm <- function(data, var){
  
  #Specifying the formula
  formula <- as.formula(paste(var, "~ assignment + block + panchayat_village"))
  
  #Running model
  model <- lm(formula, data = data)
  
  #Storing N
  N <- length(model$residuals)
  
  # Adjust for clustering at the village level
  cluster_vcov <- vcovCL(model, cluster = data$village, type = "HC1")
  # Get the coefficients with clustered standard errors
  clustered_results <- coeftest(model, vcov. = cluster_vcov)
  
  #Tidying models -- need to understand how to use clustered results option
  tidy_results <- tidy(clustered_results)
  # Rename the columns for better readability
  colnames(tidy_results) <- c("covariate", "estimate", "std_error", "z_statistic", "p_value")
  
  #Adding N
  tidy_results <- tidy_results%>%
    mutate(N = N)
  
  return(tidy_results)
}

#ilc_model_table_only
#Converts model outputs to a basic data frame
#models: regression models to pull information from
ilc_model_table_only <- function(models = all_models){
  #Gathering model name information
  model_names <- names(models)
  
  #Initializing empty model table
  model_table <- data.frame(model_name = NULL, covariate = NULL, estimate = NULL,
                            std_error = NULL, p_value = NULL, signif = NULL, N = NULL)
  
  #Placing model into model_table
  for(i in (1:length(model_names))){
    one_model <- models[[i]]%>%
      data.frame()
    
    
    one_model <- one_model%>%
      dplyr::filter(covariate == "assignmentTreatment")%>%
      dplyr::select(!(z_statistic))%>% #Removing z statistic
      mutate(model_name = model_names[i])%>%
      dplyr::select(model_name, everything())%>% #moves model_name to front
      mutate(signif = case_when(p_value > 0.10 ~ " ",
                                p_value <= 0.10 & p_value > 0.05 ~ "*",
                                p_value <= 0.05 & p_value > 0.01 ~ "**",
                                p_value <= 0.01 ~ "***"))%>%
      mutate(Lower_CI = estimate - qt(0.975, N) * std_error)%>%
      mutate(Lower_CI = case_when(Lower_CI < 0 ~ 0,
                                  Lower_CI >= 0 ~ Lower_CI))%>% #Making lower CI = 0 when it's negative
      mutate(Upper_CI = estimate + qt(0.975, N) * std_error)
    
    #Rounding numbers to 3 digits
    one_model[3:4] <- round(one_model[3:4], digits = 3)
    
    
    #Appending to model_table
    model_table <- rbind(model_table, one_model)
    
    
  }
  return(model_table)
    
  }



#ilc_model_table
#Converts model outputs to an organized latex table output using Kable()
#models: regression models to pull information from
ilc_model_table <- function(models = all_models){
  #Gathering model name information
  model_names <- names(models)
  
  #Initializing empty model table
  model_table <- data.frame(model_name = NULL, covariate = NULL, estimate = NULL,
                            std_error = NULL, p_value = NULL, signif = NULL, N = NULL)
  
  #Placing model into model_table
  for(i in (1:length(model_names))){
    one_model <- models[[i]]%>%
      data.frame()
    
    
    one_model <- one_model%>%
      dplyr::filter(covariate == "assignmentTreatment")%>%
      dplyr::select(!(z_statistic))%>% #Removing z statistic
      mutate(model_name = model_names[i])%>%
      dplyr::select(model_name, everything())%>% #moves model_name to front
      mutate(signif = case_when(p_value > 0.10 ~ " ",
                                p_value <= 0.10 & p_value > 0.05 ~ "*",
                                p_value <= 0.05 & p_value > 0.01 ~ "**",
                                p_value <= 0.01 ~ "***"))
    
    #Rounding numbers to 3 digits
    one_model[3:4] <- round(one_model[3:4], digits = 3)
    
    
    #Appending to model_table
    model_table <- rbind(model_table, one_model)
    
  }
  #Formatting Kable to print latex table
  model_table_kbl <- 
    kbl(model_table)%>%
    kable_styling(bootstrap_options = "striped", full_width = TRUE, font_size = 10) %>%
    add_header_above(c("Regression Results " = 7)) %>%
    row_spec(0, bold = TRUE, color = "black", background = "white") %>%
    column_spec(1, bold = TRUE) %>%
    column_spec(2, width = "75px")
  
  return(model_table_kbl)
  
}
