

do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2.do"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning.do"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning_v2.do"

use "${DataPre}1_1_Endline_XXX_consented.dta", clear

*renaming some duration vars becuase their names were slightly off and was not in accordance with the section in surveycto

rename R_E_intro_dur_end R_E_final_consent_duration

rename R_E_consent_duration R_E_final_intro_dur_end

rename R_E_roster_duration R_E_census_roster_duration

rename R_E_roster_end_duration R_E_new_roster_duration


drop R_E_wash_duration

rename R_E_healthcare_duration R_E_wash_duration


rename R_E_resp_health_duration R_E_noncri_health_duration

rename R_E_resp_health_new_duration R_E_CenCBW_health_duration

rename R_E_child_census_duration R_E_NewCBW_health_duration

rename R_E_child_new_duration R_E_CenU5_health_duration

rename R_E_sectiong_dur_end R_E_NewU5_health_duration

foreach  var in R_E_final_intro_dur_end R_E_final_consent_duration R_E_census_roster_duration R_E_new_roster_duration R_E_wash_duration R_E_noncri_health_duration R_E_CenCBW_health_duration R_E_NewCBW_health_duration R_E_CenU5_health_duration R_E_NewU5_health_duration R_E_survey_end_duration {
destring `var', replace
gen `var'_s = `var'/60
sum `var'_s
}


*no of households = 179
destring R_E_cen_num_hhmembers, replace
*avg HH members per HH
sum R_E_cen_num_hhmembers
*avg HH new members added per HH
sum R_E_n_hhmember_count


//NON CRITERIA MEMBERS LOOP

*No of times loop ran for NEW non-criteria members 
split R_E_n_med_seek_all, generate(R_E_n_med_seek_all)

foreach var in R_E_n_med_seek_all1 R_E_n_med_seek_all2{
destring `var', replace
} 

foreach var in R_E_n_med_seek_all1 R_E_n_med_seek_all2{
gen NMA_`var' = 1 if `var' != . & `var' != 21
}

egen temp_group = group(unique_id_num)
egen tota_NMA = rowtotal(NMA_*)
drop temp_group

rename tota_NMA Total_Med_New_noncri

sum Total_Med_New_noncri

gen Num_Med_New_noncri = r(mean)


*No of times loop ran for Census non-criteria members 


split R_E_cen_med_seek_all, generate(R_E_cen_med_seek_all)

foreach var in R_E_cen_med_seek_all1 R_E_cen_med_seek_all2 R_E_cen_med_seek_all3 R_E_cen_med_seek_all4{
destring `var', replace
} 

foreach var in R_E_cen_med_seek_all1 R_E_cen_med_seek_all2 R_E_cen_med_seek_all3 R_E_cen_med_seek_all4{
gen NC_`var' = 1 if `var' != . & `var' != 21
}

egen temp_group = group(unique_id_num)
egen T_NC = rowtotal(NC_*)
drop temp_group

rename T_NC Total_Med_Cen_noncri

sum Total_Med_Cen_noncri

gen Num_Med_Cen_noncri = r(mean)


*Avg non criteria members for medical care (Census + New) 

gen AVG_Med_all_noncri = Num_Med_Cen_noncri + Num_Med_New_noncri

//CHILD BEARING WOMEN

*num of census child bearing women
destring R_E_r_cen_num_female_15to49, replace
*avg of census child bearing women
sum R_E_r_cen_num_female_15to49
gen num_cen_CBW = r(mean)

*num of NEW child bearing women
destring R_E_n_num_female_15to49, replace
*avg of NEW child bearing women
sum  R_E_n_num_female_15to49
gen num_new_CBW = r(mean)


*avg census child bearing women (Census + new)
gen AVG_CBW_all = num_cen_CBW + num_new_CBW




//U5 CHILD 

*num of U5 CHILD
destring R_E_cen_num_childbelow5, replace
*avg of census U5 CHILD
sum R_E_cen_num_childbelow5
gen num_cen_U5 = r(mean)

*num of NEW U5 CHILD
destring R_E_n_num_childbelow5, replace
*avg of NEW U5 CHILD 
sum  R_E_n_num_childbelow5
gen num_new_U5 = r(mean)


*avg census U5 Child (Census + new)
gen AVG_U5_all = num_cen_U5 + num_new_U5


//TOTAL UNAVAILABLE SUVEYS PER HHID & PER SURVEYOR

preserve
do "${Do_lab}import_India_ILC_Endline_Census-Household_available-Cen_CBW_followup.do"
save "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", replace


drop if parent_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 


tab cen_resp_avail_cbw











gen treat = 1 
replace treat = 0 if inlist(R_E_r_cen_village_name_str, "Barijhola" ,  "Dangalodi" , "Kuljing")

