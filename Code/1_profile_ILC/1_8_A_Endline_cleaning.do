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


use "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", clear
 

 
 keep  unique_id    r_cen_a1_resp_name r_cen_a10_hhhead     r_cen_village_name_str   r_cen_fam_name*  cen_fam_age* cen_fam_gender* r_cen_a12_water_source_prim  cen_num_hhmembers cen_num_noncri r_cen_noncri_elig_list village_name_res noteconf1 info_update enum_name enum_code enum_name_label resp_available instruction consent_duration consent intro_dur_end no_consent_reason no_consent_reason_1 no_consent_reason_2 no_consent_reason__77 no_consent_oth no_consent_comment audio_consent audio_audit cen_resp_name cen_resp_label cen_resp_name_oth roster_duration   n_new_members n_new_members_verify n_hhmember_count   roster_end_duration n_fam_name* n_fam_age*  n_female_above12 n_num_femaleabove12 n_male_above12 n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12 n_num_childbelow12 n_female_15to49 n_num_female_15to49 n_children_below5 n_num_childbelow5 n_allmembers_h n_num_allmembers_h wash_duration water_source_prim water_prim_oth  water_sec_yn water_source_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count setofwater_sec_list water_sec_labels water_source_main_sec secondary_main_water_label quant sec_source_reason sec_source_reason_1 sec_source_reason_2 sec_source_reason_3 sec_source_reason_4 sec_source_reason_5 sec_source_reason_6 sec_source_reason_7 sec_source_reason__77 sec_source_reason_999 sec_source_reason_oth water_sec_freq water_sec_freq_oth collect_resp  people_prim_water num_people_prim people_prim_list_count setofpeople_prim_list people_prim_labels  prim_collect_resp where_prim_locate where_prim_locate_enum_obs collect_time collect_prim_freq water_treat water_stored water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_oth water_treat_freq water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 treat_freq_oth not_treat_tim treat_resp  num_treat_resp treat_resp_list_count setoftreat_resp_list treat_resp_labels treat_primresp treat_time treat_freq collect_treat_difficult clean_freq_containers clean_time_containers water_source_kids water_prim_source_kids water_prim_kids_oth water_source_preg water_prim_source_preg water_prim_preg_oth water_treat_kids water_treat_kids_type water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999 water_treat_kids_oth treat_kids_freq treat_kids_freq_1 treat_kids_freq_2 treat_kids_freq_3 treat_kids_freq_4 treat_kids_freq_5 treat_kids_freq_6 treat_kids_freq__77 treat_kids_freq_oth jjm_drinking tap_supply_freq tap_supply_freq_oth tap_supply_daily reason_nodrink reason_nodrink_1 reason_nodrink_2 reason_nodrink_3 reason_nodrink_4 reason_nodrink_999 reason_nodrink__77 nodrink_water_treat_oth jjm_stored jjm_yes jjm_use jjm_use_1 jjm_use_2 jjm_use_3 jjm_use_4 jjm_use_5 jjm_use_6 jjm_use_7 jjm_use__77 jjm_use_999 jjm_use_oth tap_function tap_function_reason tap_function_reason_1 tap_function_reason_2 tap_function_reason_3 tap_function_reason_4 tap_function_reason_5 tap_function_reason_999 tap_function_reason__77 tap_function_oth tap_issues tap_issues_type tap_issues_type_1 tap_issues_type_2 tap_issues_type_3 tap_issues_type_4 tap_issues_type_5 tap_issues_type__77 tap_issues_type_oth healthcare_duration n_med_seek_all n_med_seek_all_1 n_med_seek_all_2 n_med_seek_all_3 n_med_seek_all_4 n_med_seek_all_5 n_med_seek_all_6 n_med_seek_all_7 n_med_seek_all_8 n_med_seek_all_9 n_med_seek_all_10 n_med_seek_all_11 n_med_seek_all_12 n_med_seek_all_13 n_med_seek_all_14 n_med_seek_all_15 n_med_seek_all_16 n_med_seek_all_17 n_med_seek_all_18 n_med_seek_all_19 n_med_seek_all_20 n_med_seek_all_21 n_med_seek_lp_all_count setofn_med_seek_lp_all cen_med_seek_all cen_med_seek_all_1 cen_med_seek_all_2 cen_med_seek_all_3 cen_med_seek_all_4 cen_med_seek_all_5 cen_med_seek_all_6 cen_med_seek_all_7 cen_med_seek_all_8 cen_med_seek_all_9 cen_med_seek_all_10 cen_med_seek_all_11 cen_med_seek_all_12 cen_med_seek_all_13 cen_med_seek_all_14 cen_med_seek_all_15 cen_med_seek_all_16 cen_med_seek_all_17 cen_med_seek_all_18 cen_med_seek_all_19 cen_med_seek_all_20 cen_med_seek_all_21   resp_health_duration    resp_health_new_duration    child_census_duration   child_new_duration   sectiong_dur_end survey_end_duration visit_num e_surveys_revisit a40_gps_manuallatitude a40_gps_manuallongitude a40_gps_manualaltitude a40_gps_manualaccuracy a40_gps_handlongitude a40_gps_handlatitude a41_end_comments a42_survey_accompany_num survey_member_names_count setofsurvey_member_names instancename formdef_version key submissiondate starttime endtime
 * Some variable names are too long, shortening them to be able to add a R_E prefix later





 

*drop consented1child_followup5child_h
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_`x'
}



* This variable has to be named consistently across data set
rename R_E_unique_id unique_id
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	gen R_E_day = day(dofc(R_E_starttime))
	gen R_E_month_num = month(dofc(R_E_starttime))
	gen R_E_yr_num = year(dofc(R_E_starttime))
    gen End_date = mdy(R_E_month_num, R_E_day, R_E_yr_num)

	
	generate C_starthour = hh(R_E_starttime) 
	gen C_startmin= mm(R_E_starttime)
	cap gen diff_minutes = clockdiff(R_E_starttime, R_E_endtime, "minute")
    
    drop if End_date < mdy(4,21,2024)
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

* Manual
foreach i in R_E_a40_gps_handlatitude R_E_a40_gps_handlongitude   {
	replace `i'=. if R_E_a40_gps_handlatitude>25  | R_E_a40_gps_handlatitude<15
    replace `i'=. if R_E_a40_gps_handlongitude>85 | R_E_a40_gps_handlongitude<80
}

* Auto
foreach i in R_E_a40_gps_manuallatitude R_E_a40_gps_manuallongitude  R_E_a40_gps_manualaccuracy {
	replace `i'=. if R_E_a40_gps_manuallatitude>25  | R_E_a40_gps_manuallatitude<15
    replace `i'=. if R_E_a40_gps_manuallongitude>85 | R_E_a40_gps_manuallongitude<80
}

* Final GPS
foreach i in latitude longitude {
	gen     R_E_a40_gps_`i'=R_E_a40_gps_manual`i'
	replace R_E_a40_gps_`i'=R_E_a40_gps_hand`i' if R_E_a40_gps_`i'==.
	* Add manual
	drop R_E_a40_gps_manual`i' R_E_a40_gps_hand`i'
}
* Reconsider puting back back but with less confusing variable name
drop R_E_a40_gps_manualaltitude  R_E_a40_gps_manualaccuracy    


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

/*
preserve
keep if unique_id_Unique!=1 //for ease of observation and analysis

duplicates tag unique_id R_E_cen_resp_name , gen(dup)


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

}
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

*/
*******Final variable creation for clean data

gen      E_HH_not_available=0
replace E_HH_not_available=1 if R_E_resp_available!=1
tempfile main
save `main', replace


save "${DataPre}1_8_Endline/1_8_Endline_Census_cleaned.dta", replace
savesome using "${DataPre}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta" if R_E_consent==1, replace

/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
