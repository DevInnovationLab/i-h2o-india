#India ILC Pilot - Data Cleaning Script
#Author: Jeremy Lowe
#Date: 6/5/24


#-----------------------------Introduction----------------------------------#


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



#--------------------------Baseline Census Data Cleaning-------------------#



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
  rename_all(~stringr::str_replace(.,"a24_",""))
#rename_all(~stringr::str_replace(.,"a25_",""))


#create a date variable
cen$datetime <- strptime(cen$starttime, format = "%Y-%m-%d %H:%M:%S")
cen$date <- as_date(cen$datetime) 



#Keep consented cases
cen <- cen%>%
  filter(consent == 1)


#--Assign the correct treatment to villages---#

cen <- cen %>% mutate(assignment = ifelse(village_str %in%
                                            c("Birnarayanpur","Nathma", "Badabangi","Naira", "Bichikote", "Karnapadu","Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada"), "Treatment", "Control"))

#Changing village variable name
cen <- cen%>%
  mutate(village_name = village_str)


#Using labelmaker to make transfer labels for the whole dataset
cen <- labelmaker(cen)

#Filtering out backup villages
cen <- cen%>%
  filter(village_name != "Badaalubadi")%>%
  filter(village_name != "Hatikhamba")





#---Cleaning specific variables---#

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
  )

#recoding secondary source
cen$water_sec_yn <- cen$water_sec_yn%>%
  fct_recode(
    "No" = "SWS: No secondary water source",
    "Yes" = "SWS: Yes"
  )









#---------------------------Baseline Survey Data Cleaning-----------------#


#Filtering out test data from training, based on village IDs
bl <- bl%>%
  filter(!(R_FU_unique_id_1 == 88888 |
             R_FU_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting bl data key variables for WQ testing
bl <- bl%>%
  dplyr::select(R_FU_unique_id_1, R_FU_unique_id_2, R_FU_unique_id_3, unique_id_num,
                R_FU_r_cen_village_name_str, R_FU_consent, R_FU_water_source_prim, 
                R_FU_primary_water_label, R_FU_water_qual_test, R_FU_wq_stored_bag,
                R_FU_stored_bag_source, R_FU_sample_ID_stored, R_FU_bag_ID_stored, 
                R_FU_fc_stored, R_FU_wq_chlorine_storedfc_again, R_FU_tc_stored,
                R_FU_wq_chlorine_storedtc_again, R_FU_sample_ID_tap, R_FU_bag_ID_tap,
                R_FU_fc_tap, R_FU_wq_tap_fc_again, R_FU_tc_tap, R_FU_wq_tap_tc_again,
                R_FU_instancename)

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


#Renaming assignment names
bl$assignment <- factor(bl$assignment)
bl$assignment <- fct_recode(bl$assignment,
                            "Control" = "C", 
                            "Treatment" = "T")


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








#---------------------------Follow Up R1 Data Cleaning--------------------#


#Filtering out test data from training, based on village IDs
r1 <- r1%>%
  filter(!(R_FU1_unique_id_1 == 88888 |
             R_FU1_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r1 data key variables for WQ testing
r1 <- r1%>%
  dplyr::select(R_FU1_unique_id_1, R_FU1_unique_id_2, R_FU1_unique_id_3, unique_id_num, R_FU1_r_cen_village_name_str, R_FU1_consent, R_FU1_water_source_prim, R_FU1_primary_water_label, R_FU1_water_qual_test, R_FU1_wq_stored_bag, R_FU1_stored_bag_source, R_FU1_sample_ID_stored, R_FU1_bag_ID_stored, R_FU1_fc_stored, R_FU1_wq_chlorine_storedfc_again, R_FU1_tc_stored, R_FU1_wq_chlorine_storedtc_again, R_FU1_sample_ID_tap, R_FU1_bag_ID_tap, R_FU1_fc_tap, R_FU1_wq_tap_fc_again, R_FU1_tc_tap, R_FU1_wq_tap_tc_again, R_FU1_instancename)

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










#---------------------------Follow Up R2 Data Cleaning--------------------#


#Filtering out test data from training, based on village IDs
r2 <- r2%>%
  filter(!(R_FU2_unique_id_1 == 88888 |
             R_FU2_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r2 data key variables for WQ testing
r2 <- r2%>%
  dplyr::select(R_FU2_unique_id_1, R_FU2_unique_id_2, R_FU2_unique_id_3,
                unique_id_num, R_FU2_r_cen_village_name_str, R_FU2_consent, 
                R_FU2_water_source_prim, R_FU2_primary_water_label, R_FU2_water_qual_test,
                R_FU2_wq_stored_bag, R_FU2_stored_bag_source, R_FU2_sample_ID_stored,
                R_FU2_bag_ID_stored, R_FU2_fc_stored, R_FU2_wq_chlorine_storedfc_again,
                R_FU2_tc_stored, R_FU2_wq_chlorine_storedtc_again, R_FU2_sample_ID_tap,
                R_FU2_bag_ID_tap, R_FU2_fc_tap, R_FU2_wq_tap_fc_again, R_FU2_tc_tap,
                R_FU2_wq_tap_tc_again, R_FU2_instancename)

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









#---------------------------Follow Up R3 Data Cleaning--------------------#




## Followup R3 Data Cleaning


#Filtering out test data from training, based on village IDs
r3 <- r3%>%
  filter(!(R_FU3_unique_id_1 == 88888 |
             R_FU3_unique_id_1 == 99999)) # Clean data doesn't require this step


#Selecting r3 data key variables for WQ testing
r3 <- r3%>%
  dplyr::select(R_FU3_unique_id_1, R_FU3_unique_id_2, R_FU3_unique_id_3, unique_id_num, R_FU3_r_cen_village_name_str, submission_date, R_FU3_consent, R_FU3_water_source_prim, R_FU3_primary_water_label, R_FU3_water_qual_test, R_FU3_wq_stored_bag, R_FU3_stored_bag_source, R_FU3_sample_ID_stored, R_FU3_bag_ID_stored, R_FU3_fc_stored, R_FU3_wq_chlorine_storedfc_again, R_FU3_tc_stored, R_FU3_wq_chlorine_storedtc_again, R_FU3_sample_ID_tap, R_FU3_bag_ID_tap, R_FU3_fc_tap, R_FU3_wq_tap_fc_again, R_FU3_tc_tap, R_FU3_wq_tap_tc_again, R_FU3_instancename)

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








#---------------------------Endline Census Data Cleaning------------------#



#Keep consented cases
el <- el%>%
  filter(R_E_consent == 1)


#Renaming all variables to remove prefixes
el <- el%>%
  rename_all(~stringr::str_replace(.,"R_E_",""))%>%
  rename(village_name = "village_name_str")


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





#---------------------------------BL IDEXX-----------------------------------#

#Removing NA result
idexx <- idexx%>%
  filter(is.na(ec_mpn) == FALSE)

#Renaming assignment names
idexx$assignment <- factor(idexx$assignment)
idexx$assignment <- fct_recode(idexx$assignment,
                               "Control" = "C", 
                               "Treatment" = "T")

idexx <- idexx%>%
  filter(is.na(assignment) == FALSE) #Removing results from Hathikamba




