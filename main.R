#==============================================================================#
#                       Development Innovation Lab                             #
#                         Template main script                                 #
#==============================================================================#

# Select scripts to run (set section to TRUE to run it) ------------------------

  IMPORT     <- FALSE
  DEIDENTIFY <- FALSE
  CLEAN      <- FALSE
  TIDY       <- FALSE
  CONSTRUCT  <- FALSE
  ANALYZE    <- FALSE

# Required packages ------------------------------------------------------------

  library(here)

# File paths -------------------------------------------------------------------
# For the file paths below to work, make sure to create a .Rprofile file in the
# repository's root folder following the instructions on 
# 
  
  CODE     <- here("code")
  DATA_BOX <- here(Sys.getenv("BOX"), "project-folder", "data") 
  DATA_GIT <- here("data")
  OTUPUT   <- here("output")
  DOC_BOX  <- here(Sys.getenv("BOX"), "project-folder", "documentation") 
  DOC_GIT  <- here("documentation")
  
# Run selected scripts ---------------------------------------------------------
  
  ## Import raw data into R format --------------------------------------------- 
  if (IMPORT) {
    
    # Import survey data
    # Requires: "DATA_BOX/encrypted/survey.csv"
    # Creates:  "DATA_BOX/encrypted/survey.rds"
    source(here(CODE, "import", "import-survey.R"))
    
  }
  
  ## Remove direct identifiers from data --------------------------------------- 
  if (DEIDENTIFY) {
    
    # Import survey data
    # Requires: "DATA_BOX/encrypted/survey.rds"
    # Creates:  "DATA_BOX/deidentified/survey-deidentified.rds"
    source(here(CODE, "deidentify", "deidentify-survey.R"))
    
  }
  
  ## Normalize units of observation -------------------------------------------- 
  if (TIDY) {
    
    # Tidy child survey data
    # Requires: "DATA_BOX/deidentified/survey-deidentified.rds"
    # Creates:  "DATA_BOX/tidy/survey-child-tidy.rds"
    source(here(CODE, "tidy", "tidy-child-survey.R"))
    
    # Tidy household survey data
    # Requires: "DATA_BOX/deidentified/survey-deidentified.rds"
    # Creates:  "DATA_BOX/tidy/survey-household-tidy.rds"
    source(here(CODE, "tidy", "tidy-household-survey.R"))
  }
  
  ## Optimize data format ------------------------------------------------------ 
  if (CLEAN) {
    
    # Clean child survey data
    # Requires: "DATA_BOX/tidy/survey-child-tidy.rds"
    # Creates:  "DATA_BOX/clean/survey-child-clean.rds"
    source(here(CODE, "clean", "clean-child-survey.R"))
    
    # Clean household survey data
    # Requires: "DATA_BOX/tidy/survey-household-tidy.rds"
    # Creates:  "DATA_BOX/clean/survey-household-clean.rds"
    source(here(CODE, "clean", "clean-household-survey.R"))
  }
  
  ## Create analysis data sets ------------------------------------------------ 
  if (CONSTRUCT) {
    
    # Construct education outcomes
    # Requires: "DATA_BOX/clean/survey-child-rds"
    # Creates:  "DATA_BOX/constructed/child-education-constructed.rds"
    source(here(CODE, "construct", "construct-education.R"))
    
    # Construct household demographics
    # Requires: "DATA_BOX/constructed/survey-household-tidy.rds"
    # Creates:  "DATA_BOX/constructed/household-demo-constructed.rds"
    source(here(CODE, "construct", "construct-demo.R"))
    
    # Create child-level analysis data
    # Requires: "DATA_BOX/constructed/household-demo-constructed.rds"
    #           "DATA_BOX/constructed/child-education-constructed.rds"
    # Creates:  "DATA_BOX/analysis/child.rds"
    source(here(CODE, "construct", "combine-child-data.R"))
  }
  
  ## Analyse data -------------------------------------------------------------- 
  if (ANALYZE) {
    
    # Balance table
    # Requires: "DATA_BOX/analysis/child.dta"
    # Creates:  "DATA_BOX/balance-table.tex"
    source(here(CODE, "analysis", "balance-table.R"))
  }
  
#==============================================================================#