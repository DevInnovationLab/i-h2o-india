#India ILC Pilot - Data Cleaning Script
#Author: Jeremy Lowe
#Date: 6/5/24


#-----------------------------Introduction----------------------------------


#Defining Functions

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


#-------------------------Village information cleaning-----------------------

#Making village IDs compatible to the surveys
village_details <- village_details%>%
  mutate(village_ID = `Village codes`)

village_details$village_ID <- as.character(village_details$village_ID)

#Making Panchayat village variable compatible with the existing data
village_details <- village_details%>%
  mutate(`Panchat village` = Panchayat)

#Making block variable compatible with existing data
village_details <- village_details%>%
  rename(block = "Block")

#Adding anonymous village code
village_details <- village_details%>%
  mutate(village_code = case_when(Village == "Asada" ~ "AS",
                                  Village == "Mukundpur" ~ "MU",
                                  Village == "Gopi Kankubadi" ~ "GO",
                                  Village == "Bichikote" ~ "BI",
                                  Village == "Badabangi" ~ "BA",
                                  Village == "Nathma" ~ "NAT",
                                  Village == "Tandipur" ~ "TA",
                                  Village == "Birnarayanpur" ~ "BN",
                                  Village == "Naira" ~ "NAI",
                                  Village == "Karnapadu" ~ "KA"
                                  
  ))


#-----------------------------------Map Data Cleaning-------------------------

odisha <- shp_file_1%>%
  filter(NAME_1 == "Odisha")


rayagada <- shp_file_2%>%
  filter(NAME_2 == "Rayagada")




#--------------------------Baseline Census Data Cleaning-------------------

#Removing duplicate variables
cen <- cen%>%
  dplyr::select(!c(submissiondate, starttime, endtime))

#Changing variable names
cen <- cen%>%
  rename_all(~stringr::str_replace(.,"R_Cen_",""))%>%
  rename_all(~stringr::str_replace(.,"a1_",""))%>%
  rename_all(~stringr::str_replace(.,"a2_",""))%>%
  rename_all(~stringr::str_replace(.,"a3_",""))%>%
  rename_all(~stringr::str_replace(.,"a4_",""))%>%
  rename_all(~stringr::str_replace(.,"a5_",""))%>%
  rename_all(~stringr::str_replace(.,"a6_",""))%>%
  rename_all(~stringr::str_replace(.,"a7_",""))%>%
  rename_all(~stringr::str_replace(.,"a8_",""))%>%
  rename_all(~stringr::str_replace(.,"a9_",""))%>%
  rename_all(~stringr::str_replace(.,"a10_",""))%>%
  rename_all(~stringr::str_replace(.,"a11_",""))%>%
  rename_all(~stringr::str_replace(.,"a12_",""))%>%
  rename_all(~stringr::str_replace(.,"a13_",""))%>%
  rename_all(~stringr::str_replace(.,"a14_",""))%>%
  rename_all(~stringr::str_replace(.,"a15_",""))%>%
  rename_all(~stringr::str_replace(.,"a16_",""))%>%
  rename_all(~stringr::str_replace(.,"a17_",""))%>%
  #rename_all(~stringr::str_replace(.,"a18_",""))%>%
  rename_all(~stringr::str_replace(.,"a19_",""))%>%
  rename_all(~stringr::str_replace(.,"a20_",""))%>%
  rename_all(~stringr::str_replace(.,"a21_",""))%>%
  rename_all(~stringr::str_replace(.,"a22_",""))%>%
  rename_all(~stringr::str_replace(.,"a23_",""))%>%
  rename_all(~stringr::str_replace(.,"a24_",""))%>%
  rename_all(~stringr::str_replace(.,"a33_",""))
  
#rename_all(~stringr::str_replace(.,"a25_",""))


#create a date variable
cen$datetime <- strptime(cen$starttime, format = "%Y-%m-%d %H:%M:%S")
cen$date <- as_date(cen$datetime) 



#Keep consented cases
cen <- cen%>%
  filter(consent == 1)


#--Assign the correct treatment to villages---#

#Renaming village_ID variable
cen <- cen%>%
  rename(village_ID = "village_name")

#Adding village information
cen$village_ID <- as.character(cen$village_ID)
x <- village_details%>%
  dplyr::select(village_ID, block, assignment, village_code, `Panchat village`)%>%
  rename(panchayat_village = `Panchat village`)
cen <- left_join(cen, x, by = "village_ID")


#Changing village variable name
cen <- cen%>%
  mutate(village = village_str)


#Using labelmaker to make transfer labels for the whole dataset
cen <- labelmaker(cen)

#Filtering out backup villages
cen <- cen%>%
  filter(village != "Badaalubadi")%>%
  filter(village != "Hatikhamba")





#---Cleaning specific variables---#

#Recoding assignment variable
cen$assignment <- factor(cen$assignment)
cen$assignment <- cen$assignment%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#Recoding literacy variable
cen$read_write_1 <- cen$read_write_1%>%
  droplevels() #This removes "Don't know" and "Refused" responses

#Recoding gender variable
cen$hhhead_gender <- cen$hhhead_gender%>%
  droplevels()

#Recoding factor levels for ws_prim
cen <- cen%>%
  mutate(prim_source = NA)
cen$prim_source <- cen$ws_prim%>%
  fct_recode(
    "Government-provided Tap" = "PWS: JJM Taps",
    "Community Tap" = "PWS: Govt. community standpipe",
    "Community Tap" = "PWS: GP/Other community standpipe",
    "Surface Water"  = "PWS: Surface water",
    "Surface Water" = "PWS: Private surface well",
    "Covered Dug Well" = "PWS: Covered dug well",
    "Borehole" = "PWS: Manual handpump",
    "Other" = "PWS: Other"
  )%>%
  as.character()

#Other sources reported in baseline were for private electric boreholes
#Changing responses to reflect this
cen <- cen%>%
  mutate(prim_source = ifelse(prim_source == "Other", "Borehole", prim_source))

#recoding secondary source
cen$water_sec_yn <- cen$water_sec_yn%>%
  fct_recode(
    "No" = "SWS: No secondary water source",
    "Yes" = "SWS: Yes"
  )


#Setting primary source binary variable
cen <- cen%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
cen <- cen%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type JJM
# cen <- cen%>%
#   mutate(sec_source_jjm = case_when(
#     sec_jjm_use == 1 ~ 1,
#     sec_jjm_use == 0 ~ 0
#   ))

#recoding secondary source
cen$water_treat <- cen$water_treat%>%
  fct_recode(
    "No" = "WT: No water treatment",
    "Yes" = "WT: Yes"
  )


#Updating water treatment binary variable
cen <- cen%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))


#Setting JJM use variable
cen <- cen%>%
  mutate(jjm_drinking_yn = jjm_yes)%>%
  mutate(jjm_drinking = case_when(
    jjm_yes == "Yes" ~ 1,
    jjm_yes == "No" ~ 0))











#---------------------------Baseline Survey Data Cleaning-----------------


#Filtering out test data from training, based on village IDs
bl <- bl%>%
  filter(!(R_FU_unique_id_1 == 88888 |
             R_FU_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting bl data key variables for WQ testing
#bl <- bl%>%
 # dplyr::select(R_FU_unique_id_1, R_FU_unique_id_2, R_FU_unique_id_3, unique_id_num,
  #              R_FU_r_cen_village_name_str, R_FU_consent, R_FU_water_source_prim, 
   #             R_FU_primary_water_label, R_FU_water_qual_test, R_FU_wq_stored_bag,
    #            R_FU_stored_bag_source, R_FU_sample_ID_stored, R_FU_bag_ID_stored, 
     #           R_FU_fc_stored, R_FU_wq_chlorine_storedfc_again, R_FU_tc_stored,
      #          R_FU_wq_chlorine_storedtc_again, R_FU_sample_ID_tap, R_FU_bag_ID_tap,
       #         R_FU_fc_tap, R_FU_wq_tap_fc_again, R_FU_tc_tap, R_FU_wq_tap_tc_again,
        #        R_FU_instancename)

#Assigning more meaningful variable names
bl <- bl%>%
  rename_all(~stringr::str_replace(.,"R_FU_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
bl$village_ID <- as.character(bl$village_ID)
bl <- left_join(bl, village_details, by = "village_ID")


#Filtering out villages that are backup/replaced
bl <- bl%>%
  filter(!(village == "Badaalubadi"))%>%
  filter(!(village == "Haathikamba"))

#Filtering out HHs that did not consent
bl <- bl%>%
  filter(is.na(consent) == FALSE)


#Correcting one sample ID in BL dataset
#Better way to do this than looping
for(i in (1:length(bl$unique_id))){
  if(bl$unique_id[i] == 50301106013){
    bl$sample_ID_stored[i] = 20290
  }
}


#Averaging chlorine data across two tests
bl <- bl%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(bl, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(bl, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(bl, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(bl, starts_with("tc_tap")), na.rm = TRUE))
#Rounding digits
bl$fc_stored_avg <- round(bl$fc_stored_avg, digits = 3)
bl$fc_tap_avg <- round(bl$fc_tap_avg, digits = 3)
bl$tc_stored_avg <- round(bl$tc_stored_avg, digits = 3)
bl$tc_tap_avg <- round(bl$tc_tap_avg, digits = 3)

#Adding presence/absence variable
bl <- bl%>%
  mutate(fc_tap_pa = case_when(
    fc_tap_avg >= 0.14 ~ "Presence",
    fc_tap_avg < 0.14 ~ 'Absence'))%>%
  mutate(tc_tap_pa = case_when(
    tc_tap_avg >= 0.14 ~ "Presence",
    tc_tap_avg < 0.14 ~ 'Absence'))%>%
  mutate(fc_stored_pa = case_when(
    fc_stored_avg >= 0.14 ~ "Presence",
    fc_stored_avg < 0.14 ~ 'Absence'))%>%
  mutate(tc_stored_pa = case_when(
    tc_stored_avg >= 0.14 ~ "Presence",
    tc_stored_avg < 0.14 ~ 'Absence'))

#Adding presence/absence variable
bl <- bl%>%
  mutate(fc_tap_binary = case_when(
    fc_tap_avg >= 0.14 ~ 1,
    fc_tap_avg < 0.14 ~ 0))%>%
  mutate(tc_tap_binary = case_when(
    tc_tap_avg >= 0.14 ~ 1,
    tc_tap_avg < 0.14 ~ 0))%>%
  mutate(fc_stored_binary = case_when(
    fc_stored_avg >= 0.14 ~ 1,
    fc_stored_avg < 0.14 ~ 0))%>%
  mutate(tc_stored_binary = case_when(
    tc_stored_avg >= 0.14 ~ 1,
    tc_stored_avg < 0.14 ~ 0))




#Renaming assignment names
bl$assignment <- factor(bl$assignment)
bl$assignment <- fct_recode(bl$assignment,
                            "Control" = "C", 
                            "Treatment" = "T")

#classifying panchayat village
bl <- bl%>%
  mutate(panchayat_village = `Panchat village`)


#Using labelmaker function to change variable answer labels
bl <- labelmaker(bl)


#Changing primary source labels
bl <- bl%>%
  mutate(prim_source = NA)
bl$prim_source <- bl$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani)",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )

#Setting primary source binary variable
bl <- bl%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
bl <- bl%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type


#Updating stored bag water quality testing sources
bl$stored_bag_source <- bl$stored_bag_source%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Government-provided Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Government-provided Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Government-provided Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Government-provided Tap" = "Other (please specify)"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")


#Updating satisfaction and confidence questions to be binary
bl <- bl%>%
  mutate(tap_trust_binary = case_when(
    tap_trust == "Very confident" ~ 1,
    tap_trust == "Somewhat confident" ~ 1,
    tap_trust == "Neither confident or not confident" ~ 0,
    tap_trust == "Somewhat not confident" ~ 0,
    tap_trust == "Not confident at all" ~ 0
  ))

bl <- bl%>%
  mutate(tap_taste_binary = case_when(
    tap_taste_satisfied == "Very satisfied" ~ 1,
    tap_taste_satisfied == "Satisfied" ~ 1,
    tap_taste_satisfied == "Neither satisfied nor dissatisfied" ~ 0,
    tap_taste_satisfied == "Dissatisfied" ~ 0,
    tap_taste_satisfied == "Very dissatisfied" ~ 0,
    tap_taste_satisfied == "Don't know" ~ 0 
  ))
bl <- bl%>%
  mutate(tap_future_binary = case_when(
    tap_use_future == "Very likely" ~ 1,
    tap_use_future == "Somewhat likely" ~ 1,
    tap_use_future == "Neither likely nore unlikely" ~ 0,
    tap_use_future == "Somewhat unlikely" ~ 0,
    tap_use_future == "Very unlikely" ~ 0,
    tap_use_future == "Don't know" ~ 0 
  ))




#Updating water treatment binary variable
bl <- bl%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))

#Setting JJM use variable
bl <- bl%>%
  mutate(jjm_drinking = tap_use_1)

#Checking median stored water time
bl <- bl%>%
  mutate(stored_water_time = case_when(bag_stored_time_unit == "Hours" ~ bag_stored_time,
                                       bag_stored_time_unit == "Days" ~ bag_stored_time*24
  ))




#Updating BL IDs to be characters instead of numeric types
bl$unique_id <- as.character(bl$unique_id)

#Variable List:
#assignment, unique_id, sample_id, village, block, panchayat_village,
#prim_source, prim_source_jjm, sec_source, jjm_drinking, water_treat_binary, 
#tap_trust_binary, tap_taste_binary, tap_future_binary
#fc_tap_avg, fc_stored_avg, fc_tap_binary, fc_stored_binary



#---------------------------Follow Up R1 Data Cleaning--------------------


#Filtering out test data from training, based on village IDs
r1 <- r1%>%
  filter(!(R_FU1_unique_id_1 == 88888 |
             R_FU1_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r1 data key variables for WQ testing
#r1 <- r1%>%
 # dplyr::select(R_FU1_unique_id_1, R_FU1_unique_id_2, R_FU1_unique_id_3,
  #              unique_id_num, R_FU1_r_cen_village_name_str, R_FU1_consent,
   #             R_FU1_water_source_prim, R_FU1_primary_water_label, 
    #            R_FU1_water_qual_test, R_FU1_wq_stored_bag, R_FU1_stored_bag_source, R_FU1_sample_ID_stored, R_FU1_bag_ID_stored, R_FU1_fc_stored, R_FU1_wq_chlorine_storedfc_again, R_FU1_tc_stored, R_FU1_wq_chlorine_storedtc_again, R_FU1_sample_ID_tap, R_FU1_bag_ID_tap, R_FU1_fc_tap, R_FU1_wq_tap_fc_again, R_FU1_tc_tap, R_FU1_wq_tap_tc_again, R_FU1_instancename)

#Assigning more meaningful variable names
r1 <- r1%>%
  rename_all(~stringr::str_replace(.,"R_FU1_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r1$village_ID <- as.character(r1$village_ID)
r1 <- left_join(r1, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r1 <- r1%>%
  filter(is.na(consent) == FALSE)


#Correcting sample IDs in R1 dataset? Need to check
#for(i in (1:length(r1$unique_id))){
# if(r1$unique_id[i] == 50301106013){
#  r1$sample_ID_stored[i] = 20290
#  }
#}

#Renamed control vs treatment assignment
r1$assignment <- factor(r1$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#classifying panchayat village
r1 <- r1%>%
  mutate(panchayat_village = `Panchat village`)


#Using labelmaker function to change variable answer labels
r1 <- labelmaker(r1)


#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
# xx <- r1%>%
#   filter(fc_stored > 2.0 |
#            fc_stored_2 > 2.0 |
#            fc_tap > 2.0 |
#            fc_tap_2 > 2.0 |
#            tc_stored > 2.0 |
#            tc_stored_2 > 2.0 |
#            tc_tap > 2.0 |
#            tc_tap_2 > 2.0)
r1 <- r1 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))


#Averaging chlorine data across two tests
r1 <- r1%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r1, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r1, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r1, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r1, starts_with("tc_tap")), na.rm = TRUE))


r1$fc_stored_avg <- round(r1$fc_stored_avg, digits = 3)
r1$fc_tap_avg <- round(r1$fc_tap_avg, digits = 3)
r1$tc_stored_avg <- round(r1$tc_stored_avg, digits = 3)
r1$tc_tap_avg <- round(r1$tc_tap_avg, digits = 3)


#Adding presence/absence variable
r1 <- r1%>%
  mutate(fc_tap_pa = case_when(
    fc_tap_avg >= 0.10 ~ "Presence",
    fc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_tap_pa = case_when(
    tc_tap_avg >= 0.10 ~ "Presence",
    tc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(fc_stored_pa = case_when(
    fc_stored_avg >= 0.10 ~ "Presence",
    fc_stored_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_stored_pa = case_when(
    tc_stored_avg >= 0.10 ~ "Presence",
    tc_stored_avg < 0.10 ~ 'Absence'))

#Adding presence/absence variable
r1 <- r1%>%
  mutate(fc_tap_binary = case_when(
    fc_tap_avg >= 0.10 ~ 1,
    fc_tap_avg < 0.10 ~ 0))%>%
  mutate(tc_tap_binary = case_when(
    tc_tap_avg >= 0.10 ~ 1,
    tc_tap_avg < 0.10 ~ 0))%>%
  mutate(fc_stored_binary = case_when(
    fc_stored_avg >= 0.10 ~ 1,
    fc_stored_avg < 0.10 ~ 0))%>%
  mutate(tc_stored_binary = case_when(
    tc_stored_avg >= 0.10 ~ 1,
    tc_stored_avg < 0.10 ~ 0))





#Changing primary source labels
r1 <- r1%>%
  mutate(prim_source = NA)
r1$prim_source <- r1$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")

#Setting primary source binary variable
r1 <- r1%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
r1 <- r1%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type JJM
r1 <- r1%>%
  mutate(sec_source_jjm = case_when(
    water_source_sec_1 == 1 ~ 1,
    water_source_sec_1 == 0 ~ 0
  ))

#Updating stored bag sources
r1$stored_bag_source <- r1$stored_bag_source%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Government-provided Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Government-provided Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Government-provided Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other (please specify)"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")

#Updating satisfaction and confidence questions to be binary
r1 <- r1%>%
  mutate(tap_trust_binary = case_when(
    tap_trust == "Very confident" ~ 1,
    tap_trust == "Somewhat confident" ~ 1,
    tap_trust == "Neither confident or not confident" ~ 0,
    tap_trust == "Somewhat not confident" ~ 0,
    tap_trust == "Not confident at all" ~ 0
  ))

r1 <- r1%>%
  mutate(tap_taste_binary = case_when(
    tap_taste_satisfied == "Very satisfied" ~ 1,
    tap_taste_satisfied == "Satisfied" ~ 1,
    tap_taste_satisfied == "Neither satisfied nor dissatisfied" ~ 0,
    tap_taste_satisfied == "Dissatisfied" ~ 0,
    tap_taste_satisfied == "Very dissatisfied" ~ 0,
    tap_taste_satisfied == "Don't know" ~ 0 
  ))
r1 <- r1%>%
  mutate(tap_future_binary = case_when(
    tap_use_future == "Very likely" ~ 1,
    tap_use_future == "Somewhat likely" ~ 1,
    tap_use_future == "Neither likely nore unlikely" ~ 0,
    tap_use_future == "Somewhat unlikely" ~ 0,
    tap_use_future == "Very unlikely" ~ 0,
    tap_use_future == "Don't know" ~ 0 
  ))




#Updating water treatment binary variable
r1 <- r1%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))

#Setting JJM use variable
r1 <- r1%>%
  mutate(jjm_drinking = case_when(
    tap_use_drinking_yesno == "Yes" ~ 1,
    tap_use_drinking_yesno == "No" ~ 0))


#Checking median stored water time
r1 <- r1%>%
  mutate(stored_water_time = case_when(bag_stored_time_unit == "Hours" ~ bag_stored_time,
                                           bag_stored_time_unit == "Days" ~ bag_stored_time*24
  ))



#Updating IDs to be characters instead of numeric types
r1$unique_id <- as.character(r1$unique_id)








#---------------------------Follow Up R2 Data Cleaning--------------------


#Filtering out test data from training, based on village IDs
r2 <- r2%>%
  filter(!(R_FU2_unique_id_1 == 88888 |
             R_FU2_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r2 data key variables for WQ testing
#r2 <- r2%>%
 # dplyr::select(R_FU2_unique_id_1, R_FU2_unique_id_2, R_FU2_unique_id_3,
  #              unique_id_num, R_FU2_r_cen_village_name_str, R_FU2_consent, 
   #             R_FU2_water_source_prim, R_FU2_primary_water_label, R_FU2_water_qual_test,
    #            R_FU2_wq_stored_bag, R_FU2_stored_bag_source, R_FU2_sample_ID_stored,
     #           R_FU2_bag_ID_stored, R_FU2_fc_stored, R_FU2_wq_chlorine_storedfc_again,
      #          R_FU2_tc_stored, R_FU2_wq_chlorine_storedtc_again, R_FU2_sample_ID_tap,
       #         R_FU2_bag_ID_tap, R_FU2_fc_tap, R_FU2_wq_tap_fc_again, R_FU2_tc_tap,
        #        R_FU2_wq_tap_tc_again, R_FU2_instancename)

#Assigning more meaningful variable names
r2 <- r2%>%
  rename_all(~stringr::str_replace(.,"R_FU2_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r2$village_ID <- as.character(r2$village_ID)
r2 <- left_join(r2, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r2 <- r2%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)

#Correcting sample IDs in r2 dataset? Need to check
#for(i in (1:length(r2$unique_id))){
# if(r2$unique_id[i] == 50301106013){
#  r2$sample_ID_stored[i] = 20290
#  }
#}

#Renamed control vs treatment assignment
r2$assignment <- factor(r2$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")

#classifying panchayat village
r2 <- r2%>%
  mutate(panchayat_village = `Panchat village`)

#Using labelmaker function to change variable answer labels
r2 <- labelmaker(r2)

#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
# xx <- r2%>%
#   filter(fc_stored > 2.0 |
#            fc_stored_2 > 2.0 |
#            fc_tap > 2.0 |
#            fc_tap_2 > 2.0 |
#            tc_stored > 2.0 |
#            tc_stored_2 > 2.0 |
#            tc_tap > 2.0 |
#            tc_tap_2 > 2.0)
r2 <- r2 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))

#Averaging chlorine data across two tests
r2 <- r2%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r2, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r2, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r2, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r2, starts_with("tc_tap")), na.rm = TRUE))

r2$fc_stored_avg <- round(r2$fc_stored_avg, digits = 3)
r2$fc_tap_avg <- round(r2$fc_tap_avg, digits = 3)
r2$tc_stored_avg <- round(r2$tc_stored_avg, digits = 3)
r2$tc_tap_avg <- round(r2$tc_tap_avg, digits = 3)

#

#Adding presence/absence variable for chlorine
r2 <- r2%>%
  mutate(fc_tap_pa = case_when(
    fc_tap_avg >= 0.10 ~ "Presence",
    fc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_tap_pa = case_when(
    tc_tap_avg >= 0.10 ~ "Presence",
    tc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(fc_stored_pa = case_when(
    fc_stored_avg >= 0.10 ~ "Presence",
    fc_stored_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_stored_pa = case_when(
    tc_stored_avg >= 0.10 ~ "Presence",
    tc_stored_avg < 0.10 ~ 'Absence'))


#Adding presence/absence variable
r2 <- r2%>%
  mutate(fc_tap_binary = case_when(
    fc_tap_avg >= 0.10 ~ 1,
    fc_tap_avg < 0.10 ~ 0))%>%
  mutate(tc_tap_binary = case_when(
    tc_tap_avg >= 0.10 ~ 1,
    tc_tap_avg < 0.10 ~ 0))%>%
  mutate(fc_stored_binary = case_when(
    fc_stored_avg >= 0.10 ~ 1,
    fc_stored_avg < 0.10 ~ 0))%>%
  mutate(tc_stored_binary = case_when(
    tc_stored_avg >= 0.10 ~ 1,
    tc_stored_avg < 0.10 ~ 0))





#Changing primary source labels
r2 <- r2%>%
  mutate(prim_source = NA)
r2$prim_source <- r2$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")

#Setting primary source binary variable
r2 <- r2%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
r2 <- r2%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type JJM
r2 <- r2%>%
  mutate(sec_source_jjm = case_when(
    water_source_sec_1 == 1 ~ 1,
    water_source_sec_1 == 0 ~ 0
  ))

#Updating stored bag water quality testing sources
r2$stored_bag_source <- r2$stored_bag_source%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Government-provided Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Government-provided Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Government-provided Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other (please specify)"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")


#Updating satisfaction and confidence questions to be binary
r2 <- r2%>%
  mutate(tap_trust_binary = case_when(
    tap_trust == "Very confident" ~ 1,
    tap_trust == "Somewhat confident" ~ 1,
    tap_trust == "Neither confident or not confident" ~ 0,
    tap_trust == "Somewhat not confident" ~ 0,
    tap_trust == "Not confident at all" ~ 0
  ))

r2 <- r2%>%
  mutate(tap_taste_binary = case_when(
    tap_taste_satisfied == "Very satisfied" ~ 1,
    tap_taste_satisfied == "Satisfied" ~ 1,
    tap_taste_satisfied == "Neither satisfied nor dissatisfied" ~ 0,
    tap_taste_satisfied == "Dissatisfied" ~ 0,
    tap_taste_satisfied == "Very dissatisfied" ~ 0,
    tap_taste_satisfied == "Don't know" ~ 0 
  ))
r2 <- r2%>%
  mutate(tap_future_binary = case_when(
    tap_use_future == "Very likely" ~ 1,
    tap_use_future == "Somewhat likely" ~ 1,
    tap_use_future == "Neither likely nore unlikely" ~ 0,
    tap_use_future == "Somewhat unlikely" ~ 0,
    tap_use_future == "Very unlikely" ~ 0,
    tap_use_future == "Don't know" ~ 0 
  ))




#Updating water treatment binary variable
r2 <- r2%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))

#Setting JJM use variable
r2 <- r2%>%
  mutate(jjm_drinking = case_when(
    tap_use_drinking_yesno == "Yes" ~ 1,
    tap_use_drinking_yesno == "No" ~ 0))


#Checking median stored water time
r2 <- r2%>%
  mutate(stored_water_time = case_when(bag_stored_time_unit == "Hours" ~ bag_stored_time,
                                       bag_stored_time_unit == "Days" ~ bag_stored_time*24
  ))



#---------------------------Follow Up R3 Data Cleaning--------------------




## Followup R3 Data Cleaning


#Filtering out test data from training, based on village IDs
r3 <- r3%>%
  filter(!(R_FU3_unique_id_1 == 88888 |
             R_FU3_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r3 data key variables for WQ testing
#r3 <- r3%>%
 # dplyr::select(R_FU3_unique_id_1, R_FU3_unique_id_2, R_FU3_unique_id_3, unique_id_num, R_FU3_r_cen_village_name_str, submission_date, R_FU3_consent, R_FU3_water_source_prim, R_FU3_primary_water_label, R_FU3_water_qual_test, R_FU3_wq_stored_bag, R_FU3_stored_bag_source, R_FU3_sample_ID_stored, R_FU3_bag_ID_stored, R_FU3_fc_stored, R_FU3_wq_chlorine_storedfc_again, R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again, R_FU3_sample_ID_tap, R_FU3_bag_ID_tap, R_FU3_fc_tap, R_FU3_wq_tap_fc_again, R_FU3_tc_tap, R_FU3_wq_tap_tc_again, R_FU3_instancename)

#Assigning more meaningful variable names
r3 <- r3%>%
  rename_all(~stringr::str_replace(.,"R_FU3_",""))%>%
  rename(village = "r_cen_village_name_str")%>%
  rename(village_ID = "unique_id_1")%>%
  rename(unique_id = "unique_id_num")%>%
  rename(tc_stored_2 = "wq_chlorine_storedtc_again")%>%
  rename(fc_stored_2 = "wq_chlorine_storedfc_again")%>%
  rename(fc_tap_2 = "wq_tap_fc_again")%>%
  rename(tc_tap_2 = "wq_tap_tc_again")

#Pairing village information
r3$village_ID <- as.character(r3$village_ID)
r3 <- left_join(r3, village_details, by = "village_ID")


#Filtering out HHs that did not consent
r3 <- r3%>%
  filter(is.na(consent) == FALSE)

#Other way:
#rename(fc_stored = R_FU_fc_stored)%>%
#rename(tc_stored = R_FU_tc_stored)%>%
#rename(fc_tap = R_FU_fc_tap)%>%
#rename(tc_tap = R_FU_tc_tap)%>%
#rename(sample_ID_stored = R_FU_sample_ID_stored)


#Renamed control vs treatment assignment
r3$assignment <- factor(r3$assignment)%>%
  fct_recode("Control" = "C",
             "Treatment" = "T")


#classifying panchayat village
r3 <- r3%>%
  mutate(panchayat_village = `Panchat village`)

#Using labelmaker function to change variable answer labels
r3 <- labelmaker(r3)

#Removing cases of "999" being reported in a measurement. Replacing with NA values for now.
# xx <- r3%>%
#   filter(fc_stored > 2.0 |
#            fc_stored_2 > 2.0 |
#            fc_tap > 2.0 |
#            fc_tap_2 > 2.0 |
#            tc_stored > 2.0 |
#            tc_stored_2 > 2.0 |
#            tc_tap > 2.0 |
#            tc_tap_2 > 2.0)
r3 <- r3 %>%
  mutate_at(vars(fc_stored_2, tc_stored, fc_tap, tc_tap, tc_tap_2), ~ifelse(. > 100, 0, .))

#Averaging chlorine data across two tests
r3 <- r3%>%
  mutate(fc_stored_avg = rowMeans(dplyr::select(r3, starts_with("fc_stored")), na.rm = TRUE))%>%
  mutate(fc_tap_avg = rowMeans(dplyr::select(r3, starts_with("fc_tap")), na.rm = TRUE))%>%
  mutate(tc_stored_avg = rowMeans(dplyr::select(r3, starts_with("tc_stored")), na.rm = TRUE))%>%
  mutate(tc_tap_avg = rowMeans(dplyr::select(r3, starts_with("tc_tap")), na.rm = TRUE))

r3$fc_stored_avg <- round(r3$fc_stored_avg, digits = 3)
r3$fc_tap_avg <- round(r3$fc_tap_avg, digits = 3)
r3$tc_stored_avg <- round(r3$tc_stored_avg, digits = 3)
r3$tc_tap_avg <- round(r3$tc_tap_avg, digits = 3)

#
#Adding presence/absence variable
r3 <- r3%>%
  mutate(fc_tap_pa = case_when(
    fc_tap_avg >= 0.10 ~ "Presence",
    fc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_tap_pa = case_when(
    tc_tap_avg >= 0.10 ~ "Presence",
    tc_tap_avg < 0.10 ~ 'Absence'))%>%
  mutate(fc_stored_pa = case_when(
    fc_stored_avg >= 0.10 ~ "Presence",
    fc_stored_avg < 0.10 ~ 'Absence'))%>%
  mutate(tc_stored_pa = case_when(
    tc_stored_avg >= 0.10 ~ "Presence",
    tc_stored_avg < 0.10 ~ 'Absence'))


#Adding presence/absence variable
r3 <- r3%>%
  mutate(fc_tap_binary = case_when(
    fc_tap_avg >= 0.10 ~ 1,
    fc_tap_avg < 0.10 ~ 0))%>%
  mutate(tc_tap_binary = case_when(
    tc_tap_avg >= 0.10 ~ 1,
    tc_tap_avg < 0.10 ~ 0))%>%
  mutate(fc_stored_binary = case_when(
    fc_stored_avg >= 0.10 ~ 1,
    fc_stored_avg < 0.10 ~ 0))%>%
  mutate(tc_stored_binary = case_when(
    tc_stored_avg >= 0.10 ~ 1,
    tc_stored_avg < 0.10 ~ 0))




#Changing primary source labels
r3 <- r3%>%
  mutate(prim_source = NA)
r3$prim_source <- r3$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")

#Setting primary source binary variable
r3 <- r3%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
r3 <- r3%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type JJM
r3 <- r3%>%
  mutate(sec_source_jjm = case_when(
    water_source_sec_1 == 1 ~ 1,
    water_source_sec_1 == 0 ~ 0
  ))



#Updating stored bag water quality testing sources
r3$stored_bag_source <- r3$stored_bag_source%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Government-provided Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Government-provided Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Government-provided Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other (please specify)"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")

#Updating satisfaction and confidence questions to be binary
r3 <- r3%>%
  mutate(tap_trust_binary = case_when(
    tap_trust == "Very confident" ~ 1,
    tap_trust == "Somewhat confident" ~ 1,
    tap_trust == "Neither confident or not confident" ~ 0,
    tap_trust == "Somewhat not confident" ~ 0,
    tap_trust == "Not confident at all" ~ 0
  ))

r3 <- r3%>%
  mutate(tap_taste_binary = case_when(
    tap_taste_satisfied == "Very satisfied" ~ 1,
    tap_taste_satisfied == "Satisfied" ~ 1,
    tap_taste_satisfied == "Neither satisfied nor dissatisfied" ~ 0,
    tap_taste_satisfied == "Dissatisfied" ~ 0,
    tap_taste_satisfied == "Very dissatisfied" ~ 0,
    tap_taste_satisfied == "Don't know" ~ 0 
  ))
r3 <- r3%>%
  mutate(tap_future_binary = case_when(
    tap_use_future == "Very likely" ~ 1,
    tap_use_future == "Somewhat likely" ~ 1,
    tap_use_future == "Neither likely nore unlikely" ~ 0,
    tap_use_future == "Somewhat unlikely" ~ 0,
    tap_use_future == "Very unlikely" ~ 0,
    tap_use_future == "Don't know" ~ 0 
  ))




#Updating water treatment binary variable
r3 <- r3%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))

#Setting JJM use variable
r3 <- r3%>%
  mutate(jjm_drinking = case_when(
    tap_use_drinking_yesno == "Yes" ~ 1,
    tap_use_drinking_yesno == "No" ~ 0))

#Checking median stored water time
r3 <- r3%>%
  mutate(stored_water_time = case_when(bag_stored_time_unit == "Hours" ~ bag_stored_time,
                                       bag_stored_time_unit == "Days" ~ bag_stored_time*24
  ))



#------------------------Combining HH Survey Data----------------------------


#Subsetting datasets with key variables
bl_tab <- bl%>%
  dplyr::select(assignment, unique_id, sample_ID_tap, sample_ID_stored, 
                village, village_code, block, panchayat_village,
                prim_source, prim_source_jjm, sec_source, jjm_drinking, stored_water_time, water_treat_binary,
                tap_trust_binary, tap_taste_binary, tap_future_binary, 
                fc_tap_avg, fc_stored_avg, fc_tap_binary, fc_stored_binary,
                tc_tap_avg, tc_stored_avg, tc_tap_binary, tc_stored_binary,
                stored_bag_source)%>%
  mutate(data_round = "BL")%>%
  mutate(available_jjm = NA)

r1_tab <- r1%>%
  dplyr::select(assignment, unique_id, sample_ID_tap, sample_ID_stored, 
                village, village_code, block, panchayat_village,
                prim_source, prim_source_jjm, sec_source, jjm_drinking, stored_water_time, water_treat_binary,
                tap_trust_binary, tap_taste_binary, tap_future_binary, 
                fc_tap_avg, fc_stored_avg, fc_tap_binary, fc_stored_binary,
                tc_tap_avg, tc_stored_avg, tc_tap_binary, tc_stored_binary,
                stored_bag_source, available_jjm)%>%
  mutate(data_round = "R1")

r2_tab <- r2%>%
  dplyr::select(assignment, unique_id, sample_ID_tap, sample_ID_stored, 
                village, village_code, block, panchayat_village,
                prim_source, prim_source_jjm, sec_source, jjm_drinking, stored_water_time, water_treat_binary,
                tap_trust_binary, tap_taste_binary, tap_future_binary, 
                fc_tap_avg, fc_stored_avg, fc_tap_binary, fc_stored_binary,
                tc_tap_avg, tc_stored_avg, tc_tap_binary, tc_stored_binary, 
                stored_bag_source, available_jjm)%>%
  mutate(data_round = "R2")

r3_tab <- r3%>%
  dplyr::select(assignment, unique_id, sample_ID_tap, sample_ID_stored, 
                village, village_code, block, panchayat_village,
                prim_source, prim_source_jjm, sec_source, jjm_drinking, stored_water_time, water_treat_binary,
                tap_trust_binary, tap_taste_binary, tap_future_binary, 
                fc_tap_avg, fc_stored_avg, fc_tap_binary, fc_stored_binary,
                tc_tap_avg, tc_stored_avg, tc_tap_binary, tc_stored_binary,
                stored_bag_source, available_jjm)%>%
  mutate(data_round = "R3")

#Combining Datasets
all_rounds <- rbind(bl_tab, r1_tab, r2_tab, r3_tab)




#---------------------------Endline Census Data Cleaning---------------------



#Keep consented cases
el <- el%>%
  filter(R_E_consent == 1)


#Renaming all variables to remove prefixes
el <- el%>%
  rename_all(~stringr::str_replace(.,"R_E_",""))%>%
  rename(village_name = "village_name_str")


#Updating village name vs village ID
el <- el%>%
  mutate(village_ID = village)%>%
  mutate(village = village_name)

#Adding/Updating block names and panchayat status
el$village_ID <- as.character(el$village_ID)
x <- village_details%>%
  dplyr::select(village_ID, block, assignment, `Panchat village`)%>%
  rename(panchayat_village = `Panchat village`)
el <- left_join(el, x, by = "village_ID")


# Assign the correct treatment to villages-#

#Setting treatment vs control assignment
el <- el %>% mutate(assignment = ifelse(village_name %in% c("Birnarayanpur","Nathma", "Badabangi","Naira", "Bichikote", "Karnapadu","Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada"), "Treatment", "Control"))





#-Changing specific variables--#

#Using labelmaker to make transfer labels for the whole dataset
el <- labelmaker(el)



#Pairing village information
#el$village_name <- as.character(el$village_name)
#el <- left_join(el, village_details, by = "village_name")



#create a date variable
el$datetime <- strptime(el$starttime, format = "%Y-%m-%d %H:%M:%S")
el$date <- as_date(el$datetime) 
el$End_date <- as_date(el$End_date)


#Recoding factor levels for water_source_prim
el <- el%>%
  mutate(prim_source = NA)
el$prim_source <- el$water_source_prim%>%
  fct_recode(
    "Government-provided Tap" = "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM",
    "Community Tap" = "Household tap connections not connected to RWSS/Basudha/JJM tank",
    "Community Tap" = "Government provided community standpipe (connected to piped system, through Vasu",
    "Community Tap" = "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
    "Surface Water"  = "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c",
    "Surface Water" = "Private Surface well",
    "Surface Water" = "Uncovered dug well",
    "Borehole"  = "Borewell operated by electric pump",
    "Covered Dug Well" = "Covered dug well",
    "Borehole" = "Manual handpump",
    "Other" = "Other"
  )%>%
  fct_relevel("Government-provided Tap", "Community Tap", "Surface Water", 
              "Borehole", "Covered Dug Well", "Other")


#Setting primary source binary variable
el <- el%>%
  mutate(prim_source_jjm = case_when(
    prim_source == "Government-provided Tap" ~ 1,
    prim_source != "Government-provided Tap" ~ 0
  ))

#Secondary source variable cleaning
el <- el%>%
  mutate(sec_source = case_when(
    water_sec_yn == "Yes" ~ 1,
    water_sec_yn == "No" ~ 0
  ))

#Secondary source type JJM
el <- el%>%
  mutate(sec_source_jjm = case_when(
    water_source_sec_1 == 1 ~ 1,
    water_source_sec_1 == 0 ~ 0
  ))



#Updating water treatment binary variable
el <- el%>%
  mutate(water_treat_binary = case_when(
    water_treat == "Yes" ~ 1,
    water_treat == "No" ~ 0
  ))

#Setting JJM use variable
el <- el%>%
  mutate(jjm_drinking_yn = jjm_drinking)%>%
  mutate(jjm_drinking = case_when(
    jjm_drinking == "Yes" ~ 1,
    jjm_drinking == "No" ~ 0))

#Creating variable for complaints about taste and smell
el <- el%>%
  mutate(tap_issues_taste = ifelse(tap_issues_type_1 == 1, 2, 1))
el$tap_issues_taste <- el$tap_issues_taste%>%
  replace_na(replace = 1)





#--------------------------------Paired Census Data--------------------------


#Adding EL classification to the variables in the endline dataset
el_pair <- el%>%
  rename_with(~ paste0(., "_EL"))%>%
  rename(unique_id = "unique_id_EL")


paired <- inner_join(cen, el_pair, by = "unique_id")


#---------------------------------BL IDEXX-----------------------------------



#---------------------------------R1 IDEXX-----------------------------------




#---------------------------------R2 IDEXX-----------------------------------




#---------------------------------R3 IDEXX-----------------------------------





#-------------------------------Gram Vikas Data-------------------------------





#creating test date
gv <- gv%>%
  filter(is.na(Village) == FALSE)%>%
  mutate(test_date = as_date(`valve_open (Time Answered)`))%>%
  mutate(visit_date_alt = as_date(`Drafted On`))%>%
  mutate(visit_date = as_date(`Date:`))

#Replacing missing date values
gv <- gv%>%
  mutate(visit_date = coalesce(visit_date, visit_date_alt))


#Processing refill data
gv <- gv%>%
  mutate(refill = `Did you/the pump operator refill chlorine tablets since the last visit?`)%>%
  mutate(ilc_device = `What device is installed?`)%>%
  mutate(purall_cartridge_1 = `Did you provide a new PurAll chlorine cartridge? (1)`)


#Selecting refill data
gv_refill <- gv%>%
  filter(refill == "Yes")

#Creating refill check dates - date-based method
#We ultimately want to get to a place where we can estimate tablet decay rate in each village
gv_refill <- gv_refill%>%
  mutate(refill_date_1 = visit_date + 14)%>%
  mutate(refill_date_2 = visit_date + 18)%>%
  mutate(refill_date_3 = visit_date + 20)%>%
  mutate(refill_date_0 = visit_date)
#Selecting dates
gv_refill <- gv_refill%>%
  dplyr::select(Village, refill_date_0, refill_date_1, refill_date_2, refill_date_3)
#making this dataset compatible with the plot below
gv_refill <- gv_refill%>%
  mutate(village_name = Village)%>%
  mutate(village_name = ifelse(village_name == "Gopikankubadi", "GopiKankubadi", village_name))



#Weekly Chlorine Monitoring Data------------------------------------------------

#Selecting for chlorine data
mon <- mon%>%
  dplyr::select(test_date, village_name, nearest_tap_fc, farthest_tap_fc, nearest_stored_fc, farthest_stored_fc)%>%
  pivot_longer(names_to = "chlorine_test", values_to = "chlorine_concentration",
               cols = c(nearest_tap_fc, farthest_tap_fc, nearest_stored_fc, farthest_stored_fc))





mon_summary <- mon%>%
  group_by(test_date, chlorine_test)%>%
  summarise("chlorine_concentration" = mean(chlorine_concentration),
            "village" = village_name)

#Filtering for dates after April 5th for readability
mon <- mon%>%
  filter(test_date > "2024-04-05")%>%
  filter(village_name != "Karnapadu")%>% #and removing karnapadu
  filter(is.na(chlorine_concentration) == FALSE)


#Recoding chlorine concentration sample types
mon$chlorine_test <- factor(mon$chlorine_test)
mon$chlorine_test <- fct_recode(mon$chlorine_test,
                                "Nearest Tap" = "nearest_tap_fc",
                                "Nearest Stored" = "nearest_stored_fc",
                                "Farthest Tap" = "farthest_tap_fc",
                                "Farthest Stored" = "farthest_stored_fc")


#Recoding chlorine concentration sample types
mon_summary$chlorine_test <- factor(mon_summary$chlorine_test)
mon_summary$chlorine_test <- fct_recode(mon_summary$chlorine_test,
                                        "Nearest Tap" = "nearest_tap_fc",
                                        "Nearest Stored" = "nearest_stored_fc",
                                        "Farthest Tap" = "farthest_tap_fc",
                                        "Farthest Stored" = "farthest_stored_fc")

#Selecting data after February 13, the last date of modification
mon_summary <- mon_summary%>%
  filter(test_date > "2024-02-13")%>%
  filter(village != "Karnapadu")%>% #and removing karnapadu
  filter(is.na(chlorine_concentration) == FALSE)

#Making presence/absence variable for the summary data
mon_summary <- mon_summary%>%
  mutate(cl_pa = case_when(chlorine_concentration >= 0.1 ~ 1,
                           chlorine_concentration < 0.1 ~ 0
  ))

#Summarizing data on a weekly basis for taps only
# Create a week variable
mon_summary_weekly <- mon_summary %>%
  filter(chlorine_test == "Nearest Tap" | chlorine_test == "Farthest Tap")%>%
  mutate(test_week = floor_date(test_date, unit = "week"))

# Group by week and calculate the average concentration
mon_summary_weekly <- mon_summary_weekly%>%
  group_by(test_week)%>% #To add back in nearest vs farthest tap, add in "chlorine_test" variable here
  summarise(avg_concentration = mean(chlorine_concentration, na.rm = TRUE),
            se_concentration = sd(chlorine_concentration, na.rm = TRUE) / sqrt(n()),
            lower_ci = avg_concentration - qt(0.975, df = n() - 1) * se_concentration,
            upper_ci = avg_concentration + qt(0.975, df = n() - 1) * se_concentration,
            cl_presence = round((sum(cl_pa == 1) / n()) * 100, 1),
            lower_ci_pa = (sum(cl_pa == 1) / n()) * 100 -
              (qt(0.975, n() - 1) * sd(cl_pa*100)/sqrt(n())), #Can I use a 95% CI on presence/absence data?
            upper_ci_pa = (sum(cl_pa == 1) / n()) * 100 +
              (qt(0.975, n() - 1) * sd(cl_pa*100)/sqrt(n()))
            )%>%
  # Correcting negative lower CI values to be 0 instead
  mutate(lower_ci_pa = case_when(lower_ci_pa < 0 ~ 0,
                                     lower_ci_pa >= 0 ~ lower_ci_pa))%>%
  mutate(upper_ci_pa = case_when(upper_ci_pa > 100 ~ 100,
                                     upper_ci_pa <= 100 ~ upper_ci_pa))%>%
  mutate(lower_ci = ifelse(lower_ci < 0, 0, lower_ci))

#Summarizing percentage of samples that are positive for chlorine
#by village
mon_summary_percent_1 <- mon_summary%>%
  group_by(village, chlorine_test) %>%
  summarise(
    "Number of Samples" = n(),
    "% Positive for Free Chlorine" = round((sum(cl_pa == 1) / n()) * 100, 1))
#aggregate
mon_summary_percent_2 <- mon_summary%>%
  group_by(chlorine_test) %>%
  summarise(
    "Number of Samples" = n(),
    "% Positive for Free Chlorine" = round((sum(cl_pa == 1) / n()) * 100, 1))

