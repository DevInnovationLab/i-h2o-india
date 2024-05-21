*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey

clear all               
set seed 758235657 // Just in case

cap program drop key_creation
program define   key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_E_`x'
	}	

end


* Master
use "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", clear
rename cen_malesabove15_list_preload cen_malesabove15_lp
keep key  cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12 ///
          cen_children_below12 cen_num_childbelow12 cen_num_childbelow5 cen_num_malesabove15 cen_malesabove15_lp ///
		  cen_num_hhmembers cen_num_noncri resp_available instruction instruction_oth
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_r_`x'  
	}
	rename R_E_r_key R_E_key
	
save "${DataTemp}1_8_Endline_Census_additional_pre.dta", replace


* ID 25
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
* Key creation
key_creation
* ID 26
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear

/*------------------------------------------------------------------------------
	1_8_Endline_21_22.dta
------------------------------------------------------------------------------*/
* ID 22
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
* Key creation
key_creation
*keep if n_cbw_consent==1
keep key n_name_cbw_woman_earlier n_preg_status n_not_curr_preg n_preg_residence n_preg_hus n_resp_avail_cbw n_resp_avail_cbw_oth
bys key: gen Num=_n
reshape wide  n_name_cbw_woman_earlier n_preg_hus n_preg_status n_not_curr_preg n_preg_residence n_resp_avail_cbw n_resp_avail_cbw_oth, i(key) j(Num)
prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-N_CBW_followup_HH.dta", replace

* ID 21
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
drop if cen_name_cbw_woman_earlier==""
* Key creation
key_creation
save "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long1.dta", replace

*keep if cen_cbw_consent==1
save "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long2.dta", replace
keep key cen_preg_index cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_resp_avail_cbw_oth 
destring cen_preg_index, replace

bys key: gen Num=_n
reshape wide cen_preg_index cen_preg_status cen_preg_residence cen_not_curr_preg cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_resp_avail_cbw_oth, i(key) j(Num)
prefix_rename


* Bit strange with _merge==2 for N=1
use "${DataTemp}1_8_Endline_Census-Household_available-Cen_CBW_followup_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-N_CBW_followup_HH.dta", nogen
save "${DataFinal}1_8_Endline_21_22.dta", replace

/*N=0?
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", clear
* Key creation
key_creation

global keepvar n_med_otherpay_all
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW_HH.dta", replace

*/

/*------------------------------------------------------------------------------
	ID: 1_8_Endline_11_13.dta
------------------------------------------------------------------------------*/


* ID 15
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", clear
key_creation

global keepvar n_med_otherpay_cbw
keep key $keepvar
collapse (sum) $keepvar, by(key)
prefix_rename
save "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW_HH.dta", replace


/*------------------------------------------------------------------------------
	1_8_Endline_11_13.dta
------------------------------------------------------------------------------*/

* ID 13
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta.dta", clear
* Key creation
key_creation

global keepvar n_med_otherpay_all
keep key $keepvar
collapse (sum) $keepvar, by(key)
prefix_rename
save "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", clear
* Key creation
key_creation

global keepvar n_med_trans_all_*
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta", clear
key_creation
drop if n_med_seek_val_all==""

global keepvar n_med_work_who_all_*
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta", replace


use "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta", nogen
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta", nogen
save "${DataFinal}1_8_Endline_11_13.dta", replace

erase "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta"
erase "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_9_10.dta
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta", clear
key_creation
drop if cen_tests_val_u5==""

global keepvar cen_med_otherpay_u5
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta", clear
key_creation
drop if cen_out_val2_u5==""

global keepvar cen_med_treat_type_u5_*
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta"
save "${DataFinal}1_8_Endline_9_10.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_7_8.dta
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.dta", clear
key_creation
drop if cen_tests_val_cbw==""
drop setofcen_tests_exp_loop_cbw
rename *cen_med* *cm* 

gen     DK_cen_other_exp_cbw=0
replace DK_cen_other_exp_cbw=1 if cm_otherpay_cbw==999
replace cm_otherpay_cbw=. if    cm_otherpay_cbw==999

global keepvar cm_otherpay_cbw
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta", replace

* N=42
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta", clear
key_creation
rename *cen_med* *cm* 
rename *illness* *ill*

global keepvar cm_treat_type_cbw_* cm_trans_cbw_* cm_scheme_cbw_* cm_ill_other_cbw_*
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cm_treat_type_cbw_ cm_trans_cbw_ cm_scheme_cbw_ cm_ill_other_cbw_ {
	rename `i'* Count_`i'*
}

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta", clear
merge  1:1 R_E_key using  "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta", keep(2 3) nogen

save "${DataFinal}1_8_Endline_7_8.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_4_6.dta
------------------------------------------------------------------------------*/

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", clear
key_creation
collapse (sum) cen_med_otherpay_all  , by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta", replace


use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta", clear
drop if cen_med_seek_val_all==""
key_creation
global keepvar cen_med_work_who_all_* cen_med_where_all_* cen_med_symp_all_* cen_med_out_home_all_*

* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cen_med_work_who_all_ cen_med_where_all_ cen_med_symp_all_ cen_med_out_home_all_ {
	rename `i'* Count_`i'*
}

rename *cen_med* *cm* 
prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", clear
key_creation
* Parent key does not match with the one in the master data unelss we process in the following way
global keepvar cen_med_treat_type_all_* cen_med_trans_all_*
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cen_med_treat_type_all_ cen_med_trans_all_ {
	rename `i'* Count_`i'*
}

rename *cen_med* *cm* 
prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta", keep(2 3) nogen
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta", keep(2 3) nogen
save "${DataFinal}1_8_Endline_4_6.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta"

/*------------------------------------------------------------------------------
	1 Merging with cleaned 1_8_Endline_Census
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned.dta", clear
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_4_6.dta", nogen 
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_7_8.dta", nogen
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_9_10.dta", nogen
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_11_13.dta", nogen
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_21_22.dta", nogen

/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

*******Final variable creation for clean data

* Sarita Bhatra (unique ID: 20201108018) - This is the training
drop if unique_id=="20201108018"

drop if unique_id=="20201108018"

*renaming some duration vars becuase their names were slightly off and was not in accordance with the section in surveycto
rename R_E_intro_dur_end       R_E_final_consent_duration
rename R_E_consent_duration    R_E_final_intro_dur_end
rename R_E_roster_duration     R_E_census_roster_duration
rename R_E_roster_end_duration R_E_new_roster_duration

drop R_E_wash_duration

rename R_E_healthcare_duration  R_E_wash_duration
rename R_E_resp_health_duration R_E_noncri_health_duration
rename R_E_resp_health_new_duration R_E_CenCBW_health_duration
rename R_E_child_census_duration R_E_NewCBW_health_duration
rename R_E_child_new_duration R_E_CenU5_health_duration
rename R_E_sectiong_dur_end R_E_NewU5_health_duration

foreach  var in  R_E_final_intro_dur_end R_E_final_consent_duration R_E_census_roster_duration R_E_new_roster_duration R_E_wash_duration R_E_noncri_health_duration R_E_CenCBW_health_duration R_E_NewCBW_health_duration R_E_CenU5_health_duration R_E_NewU5_health_duration R_E_survey_end_duration {
destring `var', replace
gen `var'_s = `var'/60
sum `var'_s
}

* Commenting off for Archi
* cap gen diff_minutes_orig = clockdiff(R_E_starttime, R_E_endtime, "minute")
* gen diff_hours=diff_minutes/60
* sum diff_hours,de

gen R_E_Dur_final_consent_duration=R_E_final_consent_duration/60
gen R_E_Dur_census_roster_duration=(R_E_census_roster_duration-R_E_final_consent_duration)/60
gen R_E_Dur_new_roster_duration=(R_E_new_roster_duration-R_E_census_roster_duration)/60
gen R_E_Dur_wash_duration=(R_E_wash_duration-R_E_new_roster_duration)/60
gen R_E_Dur_noncri_health_duration=(R_E_noncri_health_duration-R_E_wash_duration)/60
gen R_E_Dur_CenCBW_health_duration=(R_E_CenCBW_health_duration-R_E_noncri_health_duration)/60
gen R_E_Dur_NewCBW_health_duration=(R_E_NewCBW_health_duration-R_E_CenCBW_health_duration)/60
gen R_E_Dur_CenU5_health_duration=(R_E_CenU5_health_duration-R_E_NewCBW_health_duration)/60
gen R_E_Dur_NewU5_health_duration=(R_E_NewU5_health_duration-R_E_CenU5_health_duration)/60
gen R_E_Dur_survey_end_duration=(R_E_survey_end_duration-R_E_NewU5_health_duration)/60
* R_E_Dur_survey_end_duration: It is okay that this is extremely short: (R_E_NewU5_health_duration: Line 1176 and R_E_survey_end_duration: Line 1178 in SurveyCTO)
 
 * Replacing the value of negative value since they are most likely gone back
 foreach i in R_E_Dur_noncri_health_duration R_E_Dur_NewCBW_health_duration R_E_Dur_CenU5_health_duration R_E_Dur_NewU5_health_duration R_E_Dur_survey_end_duration {
 replace `i'=. if `i'<0	
 }
 
 gen Total_time= R_E_Dur_final_consent_duration+R_E_Dur_census_roster_duration+R_E_Dur_new_roster_duration+ ///
                R_E_Dur_wash_duration+R_E_Dur_noncri_health_duration+R_E_Dur_CenCBW_health_duration+ ///
				R_E_Dur_NewCBW_health_duration+R_E_Dur_CenU5_health_duration+R_E_Dur_NewU5_health_duration+ ///
				R_E_Dur_survey_end_duration

//Renaming vars with prefix R_E
foreach x in cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 ///
	   cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 ///
	   cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 ///
	   cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 ///
		{
	rename R_E_`x'  `x'
	rename `x' R_E_r_`x'  
	}	
	
merge 1:1 R_E_key using "${DataTemp}1_8_Endline_Census_additional_pre.dta", keep(1 3) nogen

save "${DataPre}1_8_Endline_XXX.dta", replace
savesome using "${DataPre}1_1_Endline_XXX_consented.dta" if R_E_consent==1, replace


foreach i in 1_8_Endline_4_6.dta 1_8_Endline_7_8.dta 1_8_Endline_9_10.dta 1_8_Endline_11_13.dta {
		erase "${DataFinal}`i'"
}


/* ---------------------------------------------------------------------------
* Adding pre-loading info requested
* 2024/05/07
 ---------------------------------------------------------------------------*/



/* ---------------------------------------------------------------------------
* ID 26
 ---------------------------------------------------------------------------*/
* New household members
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
key_creation 
keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name key key3 n_hhmember_name namenumber

br if key=="uuid:0b09e54d-a47a-414a-8c3c-ba16ed4d9db9"
save "${DataTemp}temp0.dta", replace


/* ---------------------------------------------------------------------------
* ID 22
 ---------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
key_creation 
drop if n_resp_avail_cbw==.
keep n_not_curr_preg key key3
save "${DataTemp}temp1.dta", replace

use "${DataTemp}temp0.dta", clear
merge 1:1 key key3 using "${DataTemp}temp1.dta"
* N=141
gen Type=1
save "${DataTemp}Requested_long_backcheck1.dta", replace


/* ---------------------------------------------------------------------------
* ID 25
 ---------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
key_creation 
keep cen_still_a_member key key3 name_from_earlier_hh
br if key=="uuid:00241596-007f-45dd-9698-12b5c418e3e7"
save "${DataTemp}temp0.dta", replace

/* ---------------------------------------------------------------------------
* ID 21
 ---------------------------------------------------------------------------*/
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
 key_creation 
 drop if  cen_name_cbw_woman_earlier==""
 * keep if cen_resp_avail_cbw==1
 keep cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence key key3
 save "${DataTemp}temp1.dta", replace
 
 use "${DataTemp}temp0.dta", clear
 merge 1:1 key key3 using "${DataTemp}temp1.dta"
gen Type=2
save "${DataTemp}Requested_long_backcheck2.dta", replace

use "${DataTemp}Requested_long_backcheck1.dta", clear
append using "${DataTemp}Requested_long_backcheck2.dta"

merge m:1 key using "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", keepusing(unique_id) keep(3) nogen
bys unique_id: gen Num=_n

drop  _merge Type  key key3
reshape wide namenumber n_hhmember_name n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother n_u5mother_name n_u5father_name n_not_curr_preg name_from_earlier_hh cen_still_a_member cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence, i(unique_id) j(Num)
sort cen_name_cbw_woman_earlier1
save  "${DataTemp}Requested_wide_backcheck.dta", replace

erase "${DataTemp}Requested_long_backcheck1.dta"
erase "${DataTemp}Requested_long_backcheck2.dta"








//////////////////////////////////////////////
////////////////////////////////////////////

*CREATING PRELOAD FOR RE-VISIT (HH LEVEL)

use "${DataPre}1_8_Endline_XXX.dta", clear

//we will not re-visit those cases where HH has left permannetly 
drop if R_E_resp_available == . 
// I am creating this as HH level preload so I am not exporting those cases where HH was available for survey 
drop if R_E_resp_available == 1 | R_E_resp_available == 2

* HH unavailable for re-visits 

//checking for duplicates 
duplicates list unique_id

//merging it with the main census file 
keep unique_id

save "${DataPre}Endline_HH_level_revisit_merge.dta", replace

clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////


merge 1:1 unique_id using "${DataPre}Endline_HH_level_revisit_merge.dta"

keep if _merge == 3



tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3



//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	

//59 IDs
sort R_Cen_village_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 




//////////////////////////////////////////////
////////////////////////////////////////////

*CREATING PRELOAD FOR RE-VISIT (MAIN RESPONDENT LEVEL)


use "${DataPre}1_8_Endline_XXX.dta", clear

//we will not re-visit those cases where HH has left permannetly 
drop if R_E_resp_available == . 

keep if R_E_resp_available == 1

replace R_E_instruction = 6 if R_E_instruction == 7

tab R_E_instruction

keep if R_E_instruction != 1

duplicates list unique_id

//merging it with the main census file 
keep unique_id

save "${DataPre}Endline_Main_Resp_level_revisit_merge.dta", replace

clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////


merge 1:1 unique_id using "${DataPre}Endline_Main_Resp_level_revisit_merge.dta"

keep if _merge == 3

//preload for main resp
export excel unique_id R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${DataPre}Endline_Revisit_Preload_Main_resp_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


//Supervisor tracking sheet
tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3



//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	

sort R_Cen_village_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_Main_resp_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


//////////////////////////////////////////////
////////////////////////////////////////////


/***************************************************************
INDIVIDUAL LEVEL DATASETS 
****************************************************************/


*CREATING PRELOAD FOR RE-VISIT (U5 LEVEL)
use "${DataTemp}U5_Child_23_24.dta", clear
tab comb_child_caregiver_present


drop if comb_child_caregiver_present == . | comb_child_caregiver_present == 2 | comb_child_caregiver_present == 1


duplicates list unique_id

bys unique_id: gen Num=_n


keep comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label unique_id Num

reshape wide comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label, i(unique_id) j(Num)

duplicates list unique_id


save "${DataPre}Endline_U5_level_revisit_merge.dta", replace

clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////


merge 1:1 unique_id using "${DataPre}Endline_U5_level_revisit_merge.dta"

keep if _merge == 3


keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_enum_name R_Cen_enum_code R_Cen_landmark R_Cen_address R_Cen_enum_name_label R_Cen_a1_resp_name R_Cen_a11_oldmale R_Cen_a11_oldmale_name R_Cen_a10_hhhead R_Cen_a10_hhhead_gender comb_combchild_index* comb_combchild_status* comb_child_comb_name_label* comb_child_caregiver_present* comb_child_care_pres_oth* comb_child_caregiver_name* comb_child_residence* comb_child_comb_caregiver_label* 



bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0



export excel using "${DataPre}Endline_Revisit_Preload_U5_Child_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


//supervisor tracking sheet

gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3



//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	

sort R_Cen_village_str R_Cen_enum_name_label 


//add enum names of endline enums 

export excel ID R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_address R_Cen_a10_hhhead R_Cen_a10_hhhead_gender R_Cen_a11_oldmale_name comb_child_comb_name_label1 comb_child_comb_caregiver_label1 comb_child_residence1 comb_child_comb_name_label2 comb_child_comb_caregiver_label2 comb_child_residence2 comb_child_comb_name_label3 comb_child_comb_caregiver_label3 comb_child_residence3  using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_U5_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 






/***************************************************************

*CREATING PRELOAD FOR RE-VISIT (Child bearing women LEVEL)

***************************************************************/

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
drop if n_resp_avail_cbw==.
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
    }
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=2
save "${DataTemp}temp1.dta", replace

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
 drop if  cen_name_cbw_woman_earlier==""
 key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
    }
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=3
save "${DataTemp}temp2.dta", replace

append using "${DataTemp}temp1.dta"
drop if comb_resp_avail_comb == . 

/////////////////////////////////////////////////

use "${DataTemp}Medical_expenditure_person.dta", clear

tab comb_resp_avail_comb

label define comb_resp_avail_comb_ex 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "Respondent died or is no longer a member of the HH" 8 "Respondent no longer falls in the criteria (15-49 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_resp_avail_comb comb_resp_avail_comb_ex


drop if comb_resp_avail_comb == . | comb_resp_avail_comb == 2 | comb_resp_avail_comb == 1 | comb_resp_avail_comb == 7 | comb_resp_avail_comb == 8 | comb_resp_avail_comb == -98 | comb_resp_avail_comb == 9

drop if unique_id == "" //Akito to clarify this

bys unique_id: gen Num=_n

duplicates list unique_id



keep comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label unique_id Num

reshape wide comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label, i(unique_id) j(Num)

duplicates list unique_id


save "${DataPre}Endline_U5_level_revisit_merge.dta", replace

clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////


merge 1:1 unique_id using "${DataPre}Endline_U5_level_revisit_merge.dta"

keep if _merge == 3


keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_enum_name R_Cen_enum_code R_Cen_landmark R_Cen_address R_Cen_enum_name_label R_Cen_a1_resp_name R_Cen_a11_oldmale R_Cen_a11_oldmale_name R_Cen_a10_hhhead R_Cen_a10_hhhead_gender comb_combchild_index* comb_combchild_status* comb_child_comb_name_label* comb_child_caregiver_present* comb_child_care_pres_oth* comb_child_caregiver_name* comb_child_residence* comb_child_comb_caregiver_label* 



bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0



export excel using "${DataPre}Endline_Revisit_Preload_U5_Child_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


//supervisor tracking sheet

gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3



//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	

sort R_Cen_village_str R_Cen_enum_name_label 


//add enum names of endline enums 

export excel ID R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_address R_Cen_a10_hhhead R_Cen_a10_hhhead_gender R_Cen_a11_oldmale_name comb_child_comb_name_label1 comb_child_comb_caregiver_label1 comb_child_residence1 comb_child_comb_name_label2 comb_child_comb_caregiver_label2 comb_child_residence2 comb_child_comb_name_label3 comb_child_comb_caregiver_label3 comb_child_residence3  using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_U5_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


















