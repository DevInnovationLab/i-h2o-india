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


use "${DataRaw}1_8_Endline.dta", clear
 
 
* Some variable names are too long, shortening them to be able to add a R_E prefix later
rename (cen_malesabove15_list_preload cen_hh_member_names_loop_count cen_preg_current_village* cen_child_alive_died_less24* cen_child_alive_died_more24* cen_child_died_lessmore_24* cen_child_died_repeat_count* cen_cause_death_diagnosed* cen_prvdrs_exp_loop_cbw_count* cen_med_days_caretaking* cen_name_cbw_woman_earlier* n_child_alive_died_less24* n_child_alive_died_more24* n_child_died_lessmore_24* n_prvdrs_exp_loop_cbw_count* cen_child_caregiver_present* cen_child_u5_caregiver_label*  cen_prvdrs_exp_loop_u5_count* cen_anti_child_last_months*  cen_anti_child_purpose* survey_start1consented1n_med_see  cen_cbw_followup* cen_child_followup* target_resp_available1survey_sta target_resp_available1cen_cbw_fo target_resp_available1cen_child_ target_resp_available1n_cbw_foll household_available1survey_start household_available1cen_cbw_foll household_available1n_cbw_follow household_available1cen_child_fo  household_available1n_child_foll n_child_followup*n_u5child_start survey_start1consented1cen_med_s ) (cen_malesabove15_preload cen_hh_member_names_ct  cen_preg_current_vil* cen_chld_alv_died_lss24* cen_chld_alve_died_mr24*  cen_chld_died_lssmr_24* cen_chld_died_repeat_ct* cen_cause_death_diag* cen_prvdrs_exp_lp_cbw_ct* cen_med_dys_care* cen_name_cbw_wmn_earl* n_chld_alv_died_lss24* n_chld_alve_died_mr24* n_chld_died_lssmr_24* n_prvdrs_exp_lp_cbw_ct* cen_chld_caregvr_prsnt* cen_chld_u5_caregvr_lbl* cen_prvdrs_exp_lp_u5_ct* cen_anti_chld_last_mnths* cen_anti_chld_prpse* srvy_start1cnsntd1n_med_see cen_cbw_fu* cen_chld_fu*   trgt_rsp_avail1survey_sta trgt_rsp_avail1cen_cbw_foll trgt_resp_avail1cen_chld_ trgt_resp_avail1n_cbw_foll hh_avail1srvy_start hh_avail1cen_cbw_foll hh_avail1n_cbw_foll hh_availh1cen_child_foll hh_avail1n_child_foll n_chld_fu*n_u5chld_start srvy_start1cnsntd1cen_med_s ) 



 

*drop consented1child_followup5child_h
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_`x'
}



* This variable has to be named consistently across data set
rename R_E_unique_id unique_id_hyphen
gen unique_id = subinstr(unique_id_hyphen, "-", "",.) 
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	*gen date = dofc(starttime)
	*format date %td
	gen R_E_day = day(dofc(R_E_starttime))
	gen R_E_month_num = month(dofc(R_E_starttime))
	//to change once survey date is fixed
	drop if (R_E_day==23 & R_E_month_num==9)
	
	 generate C_starthour = hh(R_E_starttime) 
	 gen C_startmin= mm(R_E_starttime)

	gen diff_minutes = clockdiff(R_E_starttime, R_E_endtime, "minute")
	

    gen R_E_yr_num = year(dofc(R_E_starttime))

	
    
    gen End_date = mdy(R_E_month_num, R_E_day, R_E_yr_num)

	format End_date  %d


/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

//1. dropping irrelevant entries , Archi to replace with == "Badaalubadi"
count if R_E_r_cen_village_name_str=="88888"
tab R_E_day if R_E_r_cen_village_name_str=="88888"
drop if  R_E_r_cen_village_name_str=="88888"

//2. dropping duplicate case based on field team feedback, in case of any incorrect entry, enter the exact key
*drop if R_E_key== " "

*Note: also resolve duplicates here 


//3. Cleaning the GPS data 
// Keeping the most reliable entry of GPS

* Auto
foreach i in R_E_a40_gps_autolatitude R_E_a40_gps_autolongitude R_E_a40_gps_autoaltitude R_E_a40_gps_autoaccuracy {
	replace `i'=. if R_E_a40_gps_autolatitude>25  | R_E_a40_gps_autolatitude<15
    replace `i'=. if R_E_a40_gps_autolongitude>85 | R_E_a40_gps_autolongitude<80
}

* Manual
foreach i in R_E_a40_gps_manuallatitude R_E_a40_gps_manuallongitude R_E_a40_gps_manualaltitude R_E_a40_gps_manualaccuracy {
	replace `i'=. if R_E_a40_gps_manuallatitude>25  | R_E_a40_gps_manuallatitude<15
    replace `i'=. if R_E_a40_gps_manuallongitude>85 | R_E_a40_gps_manuallongitude<80
}

* Final GPS
foreach i in latitude longitude {
	gen     R_E_a40_gps_`i'=R_E_a40_gps_auto`i'
	replace R_E_a40_gps_`i'=R_E_a40_gps_manual`i' if R_E_a40_gps_`i'==.
	* Add manual
	drop R_E_a40_gps_auto`i' R_E_a40_gps_manual`i'
}
* Reconsider puting back back but with less confusing variable name
drop R_E_a40_gps_autoaltitude R_E_a40_gps_manualaltitude
drop R_E_a40_gps_autoaccuracy R_E_a40_gps_manualaccuracy R_E_a40_gps_handlongitude R_E_a40_gps_handlatitude


//4. Capturing correct section-wise duration

*drop R_E_consent_duration R_E_intro_duration R_E_sectionb_duration //old vars
*destring R_E_survey_duration R_E_intro_duR_E R_E_consent_duR_E R_E_sectionb_duR_E R_E_sectionc_duR_E ///
*R_E_sectiond_duR_E R_E_sectione_duR_E R_E_sectionf_duR_E R_E_sectiong_duR_E R_E_sectionh_duR_E, replace

*drop R_E_intro_duR_E R_E_consent_duR_E R_E_sectionb_duR_E R_E_sectionc_duR_E ///
*R_E_sectiond_duR_E R_E_sectione_duR_E R_E_sectionf_duR_E R_E_sectiong_duR_E R_E_sectionh_duR_E



/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}

tempfile working
save `working', replace

/**[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates

Respondent Names are recorded only after consent so they should be the same for one unique ID

There can be three types of cases:
1) Where ID is same and in one case respondent name is present but in others it is missing for the same day
2) Where ID is same and name is missing. This could be because respondent wasn't available or was screened out or consent was not given.
3) Where ID is same and names are different
//check if the data is coming from same enumerator? or different enumerators?
//check if village and enumerator are matched correctly; remove consistencies

Case 1 shouldn't exist because for the same HH, we will have only one form => Field team to check
Case 2 also shouldn't exist because for the same HH, we will submit just one form =>  Field team to check
Case 3 can exist due to data entry issues. This will be fixed below 

*/

preserve
keep if unique_id_Unique!=1 //for ease of observation and analysis
duplicates report unique_id R_E_cen_resp_name


//keeping instance for IDs where consent was obtained
replace R_E_consent= 0 if R_E_consent==.
bys unique_id (R_E_consent): gen E_dup_by_consent= _n if R_E_consent[_n]!=R_E_consent[_n+1]
br unique_id_hyphen R_E_consent E_dup_by_consent
drop if R_E_consent==0 & E_dup_by_consent[_n]== 1 

//sorting and marking duplicate number by submission time 
bys unique_id (R_E_starttime): gen E_dup_tag= _n if R_E_consent==0

//Case 1-
gen E_new1= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]!=R_E_cen_resp_name[_n+1] & R_E_cen_resp_name[_n]==.

//Case 2-
gen E_new2= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]==R_E_cen_resp_name[_n+1] 

//Case 3- 
gen E_new3= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]!=R_E_cen_resp_name[_n+1] & R_E_cen_resp_name[_n]!=.

tempfile dups
save `dups', replace

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
//submission time to be added Bys unique_id (submissiontime): gen
keep if E_new1==1 | E_new2==1 | E_new3==1
 capture export excel unique_id R_E_enum_name R_E_r_cen_village_name_str R_E_submissiondate using "${pilot}Data_quality_endline.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Endsus") ///
 firstrow(var) cell(A1) sheetreplace

***** Step 3: Creating new IDs for obvious duplicates; keeping the first ID based on the starttime and consent and changing the IDs of the remaining

use `dups', clear
keep if E_dup_by_consent==2 & R_E_consent==1
tempfile dups_part1
save `dups_part1', replace

use `dups', clear
keep if E_dup_tag==1
tempfile dups_part2
save `dups_part2', replace


//Using sequential numbers starting from 500 for remaining duplicate ID cases because we wouldn't encounter so many pregnant women/children U5 in a village
use `dups', clear
keep if E_dup_tag>1 & R_E_consent!=1
bys unique_id :gen E_seq=_n
replace E_seq= E_seq + 500
egen unique_id_new= concat (R_E_r_cen_village_name_str R_E_enum_code E_seq)
replace unique_id= unique_id_new 

tempfile dups_part3
save `dups_part3', replace


restore

****Step 4: Appending files with unqiue IDs
use `working', clear
drop if unique_id_Unique!=1
append using `dups_part1', force
append using `dups_part2', force
append using `dups_part3', force
//also append file that comes corrected from the field

duplicates report unique_id //final check
drop unique_id_hyphen unique_id_num
drop unique_id_Unique 
* Recreating the unique variable after solving the duplicates
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc 
gen unique_id_hyphen = substr(unique_id, 1,5) + "-"+ substr(unique_id, 6,3) + "-"+ substr(unique_id, 9,3)



/*
clear all
//Ensuring we have correct observations from all form versions
import excel "${DataRaw}Baseline Endsus_WIDE.xlsx", sheet("data") firstrow
gen unique_id = subinstr(unique_ID, "-", "",.) 
merge m:1 unique_id using `main'
*/
/*
* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)- not sure this is needed as long as ID is unique

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force
*/


*******Final variable creation for clean data

gen      E_HH_not_available=0
replace E_HH_not_available=1 if R_E_hh_avail1srvy_start!=1
tempfile main
save `main', replace


save "${DataPre}1_1_Endline_cleaned.dta", replace
savesome using "${DataPre}1_1_Endline_cleaned_consented.dta" if R_E_consent==1, replace

/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
