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

	drop key
	unique parent_key
	split parent_key, p("/" "[" "]")
	rename parent_key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_E_`x'
	}	

end

/*------------------------------------------------------------------------------
	1_8_Endline_11_13.dta
------------------------------------------------------------------------------*/

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
use "${DataPre}1_8_Endline/1_8_Endline_Census_cleaned.dta", clear
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_4_6.dta", nogen 
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_7_8.dta", nogen
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_9_10.dta", nogen
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_11_13.dta", nogen

END
/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

*******Final variable creation for clean data

save "${DataPre}1_8_Endline_XXX.dta", replace
savesome using "${DataPre}1_1_Endline_XXX_consented.dta" if R_E_consent==1, replace

/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
