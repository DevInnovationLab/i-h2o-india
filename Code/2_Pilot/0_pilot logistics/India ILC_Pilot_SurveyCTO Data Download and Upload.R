#India ILC Project
#Pilot Field Logistics
#Author: Jeremy Lowe
#Created: 8/25/23

#SurveyCTO Data Download and Upload to Box
#This script is used to downlaod data frequently from SurveyCTO and
#upload it directly to a Box folder


#Package Loading
library(rsurveycto)
library(knitr)
library(tidyverse)


#Jeremy's authentication for SurveyCTO API
auth <- scto_auth(auth_file = "~/India-ILC/June 2023 Pilot/data/SurveyCTO_auth/dilserver.txt",
                  servername = NULL,
                  username = NULL,
                  password = NULL,
                  validate = TRUE
)



ilc <- scto_read(auth,
                 ids = "india_ilc_pilot_census_enc",
                 start_date = "1900-01-01",
                 review_status = c("approved", "pending"),
                 private_key = "C:/Users/jerem/Box/India Water project/2_Pilot/Data/0_keys/i-h2o-IndiaILC_PRIVATEDONOTSHARE.pem",
                 drop_empty_cols = TRUE,
                 convert_datetime = c("CompletionDate", "SubmissionDate", "starttime", "endtime"),
                 datetime_format = "%b %e, %Y %I:%M:%S %p",
                 simplify = TRUE
)


setwd(box_path)
download_path <- paste(box_path, 
                  "/1_raw/0_field logistics/1_raw/India ILC_Pilot_Household Tracking_raw.csv",
                  sep = "")

#Writing raw csv file to existing Box folder
write_csv(ilc, download_path)
