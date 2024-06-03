* import_India_ILC_Endline_Census_Revisit.do
*
* 	Imports and aggregates "Endline Census Re-visit" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit_WIDE.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit.dta"
*
*	Output by SurveyCTO May 30, 2024 7:37 AM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit_WIDE.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum start_dur unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1"
local text_fields2 "r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4"
local text_fields3 "r_cen_fam_name5 r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16"
local text_fields4 "r_cen_fam_name17 r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10"
local text_fields5 "cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3"
local text_fields6 "cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15"
local text_fields7 "cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 r_cen_a12_water_source_prim cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12"
local text_fields8 "cen_num_adultsabove12 cen_children_below12 cen_num_childbelow12 child_bearing_list_preload cen_num_childbelow5 child_u5_list_preload cen_num_malesabove15 cen_malesabove15_list_preload"
local text_fields9 "r_cen_non_cri_mem_1 r_cen_non_cri_mem_2 r_cen_non_cri_mem_3 r_cen_non_cri_mem_4 r_cen_non_cri_mem_5 r_cen_non_cri_mem_6 r_cen_non_cri_mem_7 r_cen_non_cri_mem_8 r_cen_non_cri_mem_9 r_cen_non_cri_mem_10"
local text_fields10 "r_cen_non_cri_mem_11 r_cen_non_cri_mem_12 r_cen_non_cri_mem_13 r_cen_non_cri_mem_14 r_cen_non_cri_mem_15 r_cen_non_cri_mem_16 r_cen_non_cri_mem_17 r_cen_non_cri_mem_18 r_cen_non_cri_mem_19"
local text_fields11 "r_cen_non_cri_mem_20 cen_num_hhmembers cen_num_noncri r_cen_noncri_elig_list village_name_res total_cbw_comb total_u5_child_comb wash_applicable comb_hhmember_name1 comb_hhmember_name2"
local text_fields12 "comb_hhmember_name3 comb_hhmember_name4 comb_hhmember_name5 comb_hhmember_name6 comb_hhmember_name7 comb_hhmember_age1 comb_hhmember_age2 comb_hhmember_age3 comb_hhmember_age4 comb_hhmember_age5"
local text_fields13 "comb_hhmember_age6 comb_hhmember_age7 comb_hhmember_gender1 comb_hhmember_gender2 comb_hhmember_gender3 comb_hhmember_gender4 comb_hhmember_gender5 comb_hhmember_gender6 comb_hhmember_gender7"
local text_fields14 "comb_name_comb_woman_earlier1 comb_name_comb_woman_earlier2 comb_name_comb_woman_earlier3 comb_name_comb_woman_earlier4 r_cen_main_resp_with_age info_update enum_name_label reason_hh_lock"
local text_fields15 "reason_hh_lock_oth instruction_oth intro_dur_end consent_dur_end no_consent_reason no_consent_oth no_consent_comment audio_audit cen_resp_label cen_resp_name_oth why_chng_main why_chng_main_oth"
local text_fields16 "cen_hh_member_names_loop_count hh_index_* name_from_earlier_hh_* census_roster_dur_end n_hh_member_names_loop_count namenumber_* n_hhmember_name_* namefromearlier_* n_relation_oth_* n_cbw_age_*"
local text_fields17 "n_all_age_* n_age_confirm2_* n_dob_concat_* n_autoage_* n_year_* current_year_* current_month_* age_years_* age_months_* age_years_final_* age_months_final_* age_decimal_* n_u5mother_name_oth_*"
local text_fields18 "n_u5father_name_oth_* roster_end_duration n_fam_name1 n_fam_name2 n_fam_name3 n_fam_name4 n_fam_name5 n_fam_name6 n_fam_name7 n_fam_name8 n_fam_name9 n_fam_name10 n_fam_name11 n_fam_name12"
local text_fields19 "n_fam_name13 n_fam_name14 n_fam_name15 n_fam_name16 n_fam_name17 n_fam_name18 n_fam_name19 n_fam_name20 n_fam_age1 n_fam_age2 n_fam_age3 n_fam_age4 n_fam_age5 n_fam_age6 n_fam_age7 n_fam_age8"
local text_fields20 "n_fam_age9 n_fam_age10 n_fam_age11 n_fam_age12 n_fam_age13 n_fam_age14 n_fam_age15 n_fam_age16 n_fam_age17 n_fam_age18 n_fam_age19 n_fam_age20 n_female_above12 n_num_femaleabove12 n_male_above12"
local text_fields21 "n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12 n_num_childbelow12 n_female_15to49 n_num_female_15to49 n_children_below5 n_num_childbelow5 n_allmembers_h"
local text_fields22 "n_num_allmembers_h new_roster_dur_end water_prim_oth primary_water_label water_source_sec water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count water_sec_index_*"
local text_fields23 "water_sec_value_* water_sec_label_* water_sec_labels water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label"
local text_fields24 "sec_source_reason sec_source_reason_oth water_sec_freq_oth collect_resp people_prim_water num_people_prim people_prim_list_count people_prim_index_* people_prim_value_* people_prim_label_*"
local text_fields25 "people_prim_labels people_prim1 people_prim2 people_prim3 people_prim4 people_prim5 people_prim6 people_prim7 people_prim8 people_prim9 people_prim10 people_prim11 people_prim12 people_prim13"
local text_fields26 "people_prim14 people_prim15 people_prim16 people_prim17 people_prim18 people_prim19 people_prim20 people_prim21 people_prim22 people_prim23 people_prim24 people_prim25 people_prim26 people_prim27"
local text_fields27 "people_prim28 people_prim29 people_prim30 people_prim31 people_prim32 people_prim33 people_prim34 people_prim35 people_prim36 people_prim37 people_prim38 people_prim39 people_prim40 water_treat_type"
local text_fields28 "water_treat_oth water_treat_freq treat_freq_oth treat_resp num_treat_resp treat_resp_list_count treat_resp_index_* treat_resp_value_* treat_resp_label_* treat_resp_labels treat_resp1 treat_resp2"
local text_fields29 "treat_resp3 treat_resp4 treat_resp5 treat_resp6 treat_resp7 treat_resp8 treat_resp9 treat_resp10 treat_resp11 treat_resp12 treat_resp13 treat_resp14 treat_resp15 treat_resp16 treat_resp17 treat_resp18"
local text_fields30 "treat_resp19 treat_resp20 treat_resp21 treat_resp22 treat_resp23 treat_resp24 treat_resp25 treat_resp26 treat_resp27 treat_resp28 treat_resp29 treat_resp30 treat_resp31 treat_resp32 treat_resp33"
local text_fields31 "treat_resp34 treat_resp35 treat_resp36 treat_resp37 treat_resp38 treat_resp39 treat_resp40 water_prim_kids_oth water_prim_preg_oth water_treat_kids_type water_treat_kids_oth treat_kids_freq"
local text_fields32 "treat_kids_freq_oth tap_supply_freq_oth reason_nodrink nodrink_water_treat_oth jjm_use jjm_use_oth tap_function_reason tap_function_oth tap_issues_type tap_issues_type_oth wash_dur_end"
local text_fields33 "audio_audit_noncri n_med_seek_all n_med_seek_lp_all_count n_med_seek_ind_all_* n_med_seek_val_all_* n_med_name_all_* n_med_symp_all_* n_med_symp_oth_all_* n_med_where_all_* n_med_where_oth_all_*"
local text_fields34 "n_med_out_home_all_* n_med_out_oth_all_* n_prvidr_exp_lp_all_count_* n_out_ind2_all_* n_out_val2_all_* n_out_names_all_* n_med_treat_type_all_* n_med_treat_oth_all_* n_med_trans_all_*"
local text_fields35 "n_med_scheme_all_* n_med_illness_other_all_* n_tests_exp_loop_all_count_* n_tests_ind_all_* n_tests_val_all_* n_other_exp_all_* n_med_work_who_all_* cen_med_seek_all cen_med_seek_lp_all_count"
local text_fields36 "cen_med_seek_ind_all_* cen_med_seek_val_all_* cen_med_name_all_* cen_med_symp_all_* cen_med_symp_oth_all_* cen_med_where_all_* cen_med_where_oth_all_* cen_med_out_home_all_* cen_med_out_oth_all_*"
local text_fields37 "cen_prvdrs_exp_lp_all_count_* cen_out_ind2_all_* cen_out_val2_all_* cen_out_names_all_* cen_med_treat_type_all_* cen_med_treat_oth_all_* cen_med_trans_all_* cen_med_scheme_all_*"
local text_fields38 "cen_med_illness_other_all_* cen_tests_exp_loop_all_count_* cen_tests_ind_all_* cen_tests_val_all_* cen_other_exp_all_* cen_med_work_who_all_* hh_member_section noncri_dur_end audio_audit_census_resp"
local text_fields39 "comb_cbw_followup_count comb_preg_index_* comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_oth_* comb_no_consent_reason_* comb_no_consent_oth_* comb_no_consent_comment_* comb_preg_hus_*"
local text_fields40 "comb_preg_current_village_oth_* comb_preg_rch_id_* comb_preg_rch_id_inc_* comb_anti_preg_purpose_* comb_anti_preg_purpose_oth_* comb_num_living_null_* comb_num_notliving_null_*"
local text_fields41 "comb_num_stillborn_null_* comb_num_less24_null_* comb_num_more24_null_* comb_child_died_lessmore_24_num_* comb_child_died_u5_count_* comb_child_died_repeat_count_* comb_name_child_*"
local text_fields42 "comb_name_child_earlier_* comb_fath_child_* comb_dod_concat_cbw_* comb_dod_autoage_* comb_year_cbw_* comb_curr_year_cbw_* comb_curr_mon_cbw_* comb_age_years_cbw_* comb_age_mon_cbw_*"
local text_fields43 "comb_age_years_f_cbw_* comb_age_months_f_cbw_* comb_age_decimal_cbw_* comb_cause_death_* comb_cause_death_oth_* comb_cause_death_str_* comb_med_symp_cbw_* comb_med_symp_oth_cbw_* comb_med_where_cbw_*"
local text_fields44 "comb_med_where_oth_cbw_* comb_med_out_home_cbw_* comb_med_out_oth_cbw_* comb_prvdrs_exp_loop_cbw_count_* comb_out_ind2_cbw_* comb_out_val2_cbw_* comb_out_names_cbw_* comb_med_treat_type_cbw_*"
local text_fields45 "comb_med_treat_oth_cbw_* comb_med_trans_cbw_* comb_med_scheme_cbw_* comb_med_illness_other_cbw_* comb_tests_exp_loop_cbw_count_* comb_tests_ind_cbw_* comb_tests_val_cbw_* comb_other_exp_cbw_*"
local text_fields46 "comb_med_work_who_cbw_* census_resp_health_dur_end audio_audit_new_resp n_cbw_followup_count n_cbw_ind_* n_cen_women_status_* n_name_cbw_woman_earlier_* n_resp_avail_cbw_oth_* n_no_consent_reason_*"
local text_fields47 "n_no_consent_oth_* n_no_consent_comment_* n_preg_hus_* n_preg_current_village_oth_* n_preg_rch_id_* n_preg_rch_id_inc_* n_anti_preg_purpose_* n_anti_preg_purpose_oth_* n_num_living_null_*"
local text_fields48 "n_num_notliving_null_* n_num_stillborn_null_* n_num_less24_null_* n_num_more24_null_* n_child_died_lessmore_24_num_* n_child_died_u5_count_* n_child_died_repeat_count_* n_name_child_*"
local text_fields49 "n_name_child_earlier_* n_fath_child_* n_dod_concat_cbw_* n_dob_concat_cbw_* n_dod_autoage_* n_year_cbw_* n_curr_year_cbw_* n_curr_mon_cbw_* n_age_years_cbw_* n_age_mon_cbw_* n_age_years_f_cbw_*"
local text_fields50 "n_age_months_f_cbw_* n_age_decimal_cbw_* n_cause_death_* n_cause_death_oth_* n_cause_death_str_* n_med_symp_cbw_* n_med_symp_oth_cbw_* n_med_where_cbw_* n_med_where_oth_cbw_* n_med_out_home_cbw_*"
local text_fields51 "n_med_out_oth_cbw_* n_prvdrs_exp_loop_cbw_count_* n_out_ind2_cbw_* n_out_val2_cbw_* n_out_names_cbw_* n_med_treat_type_cbw_* n_med_treat_oth_cbw_* n_med_trans_cbw_* n_med_scheme_cbw_*"
local text_fields52 "n_med_illness_other_cbw_* n_tests_exp_loop_cbw_count_* n_tests_ind_cbw_* n_tests_val_cbw_* n_other_exp_cbw_* n_med_work_who_cbw_* new_resp_health_dur_end audio_audit_cen_child"
local text_fields53 "comb_child_followup_count comb_child_ind_* comb_child_u5_name_label_* comb_main_caregiver_label_* comb_child_care_pres_oth_* comb_child_name_* comb_child_u5_caregiver_label_*"
local text_fields54 "comb_child_u5_relation_oth_* comb_anti_child_purpose_* comb_anti_child_purpose_oth_* comb_med_symp_u5_* comb_med_symp_oth_u5_* comb_med_where_u5_* comb_med_where_oth_u5_* comb_med_out_home_u5_*"
local text_fields55 "comb_med_out_oth_u5_* comb_prvdrs_exp_loop_u5_count_* comb_out_ind2_u5_* comb_out_val2_u5_* comb_out_names_u5_* comb_med_treat_type_u5_* comb_med_treat_oth_u5_* comb_med_trans_u5_*"
local text_fields56 "comb_med_scheme_u5_* comb_med_illness_other_u5_* comb_tests_exp_loop_u5_count_* comb_tests_ind_u5_* comb_tests_val_u5_* comb_other_exp_u5_* comb_med_work_who_u5_* census_u5_dur_end"
local text_fields57 "audio_audit_new_child n_child_followup_count n_u5child_index_* n_u5child_status_* n_child_u5_name_label_* n_child_care_pres_oth_* n_child_u5_caregiver_label_* n_child_u5_relation_oth_*"
local text_fields58 "n_anti_child_purpose_* n_anti_child_purpose_oth_* n_med_symp_u5_* n_med_symp_oth_u5_* n_med_where_u5_* n_med_where_oth_u5_* n_med_out_home_u5_* n_med_out_oth_u5_* n_prvdrs_exp_loop_u5_count_*"
local text_fields59 "n_out_index2_u5_* n_out_val2_u5_* n_out_names_u5_* n_med_treat_type_u5_* n_med_treat_oth_u5_* n_med_trans_u5_* n_med_scheme_u5_* n_med_illness_other_u5_* n_tests_exp_loop_u5_count_* n_tests_ind_u5_*"
local text_fields60 "n_tests_val_u5_* n_other_exp_u5_* n_med_work_who_u5_* new_u5_dur_end survey_end_duration a41_end_comments survey_member_names_count surveynumber_* instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable unique_id_1 "Record the first 5 digit"
	note unique_id_1: "Record the first 5 digit"

	label variable unique_id_2 "Record the middle 3 digit"
	note unique_id_2: "Record the middle 3 digit"

	label variable unique_id_3 "Record the last 3 digit"
	note unique_id_3: "Record the last 3 digit"

	label variable unique_id_1_check "Record the first 5 digit"
	note unique_id_1_check: "Record the first 5 digit"

	label variable unique_id_2_check "Record the middle 3 digit"
	note unique_id_2_check: "Record the middle 3 digit"

	label variable unique_id_3_check "Record the last 3 digit"
	note unique_id_3_check: "Record the last 3 digit"

	label variable noteconf1 "Please confirm the households that you are visiting correspond to the following "
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_name_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round (Target respondent): \${R_Cen_a1_resp_name} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Saahi: \${R_Cen_saahi_name} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
	label define noteconf1 1 "I am visiting the correct household and the information is correct" 2 "I am visiting the correct household but the information needs to be updated" 3 "The household I am visiting does not corresponds to the confirmation info."
	label values noteconf1 noteconf1

	label variable info_update "Please describe the information need to be updated here."
	note info_update: "Please describe the information need to be updated here."

	label variable enum_name "Enumerator name: Please select from the drop-down list"
	note enum_name: "Enumerator name: Please select from the drop-down list"
	label define enum_name 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 108 "Sanjukta Chichuan" 110 "Sarita Bhatra" 111 "Abhishek Rath" 113 "Mangulu Bagh" 117 "Jitendra Bagh" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 122 "Sasmita Panda" 123 "Madhusmita priyadarsini Deb" 124 "Pabitra Sahoo" 125 "Rasmita Barik" 126 "Lopamudra sahoo" 127 "Sumitra lakra" 128 "Sudehshna Biswal" 129 "Jasoda Munda" 130 "Ashok kumar kosolya" 131 "Nilamadhab Bariha" 132 "Jitan Mallik" 133 "Sadananda Swain" 134 "Basanta kousalya" 135 "Prasant Kumar Das" 136 "Ratikanta Swain" 137 "Nityananda Behera" 138 "Rosan Das"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 103 "103" 105 "105" 108 "108" 110 "110" 111 "111" 113 "113" 117 "117" 119 "119" 121 "121" 122 "122" 123 "123" 124 "124" 125 "125" 126 "126" 127 "127" 128 "128" 129 "129" 130 "130" 131 "131" 132 "132" 133 "133" 134 "134" 135 "135" 136 "136" 137 "137" 138 "138"
	label values enum_code enum_code

	label variable resp_available "Enumerator to record after knocking at the door of a house: Did you find a house"
	note resp_available: "Enumerator to record after knocking at the door of a house: Did you find a household to interview?"
	label define resp_available 1 "Household available for an interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible (e.g. all t" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the" -98 "Refused to answer"
	label values resp_available resp_available

	label variable reason_hh_lock "Why is household unavailable or locked?"
	note reason_hh_lock: "Why is household unavailable or locked?"

	label variable reason_hh_lock_oth "B1.1) Please specify other"
	note reason_hh_lock_oth: "B1.1) Please specify other"

	label variable instruction "Instructions for Enumerator to identify the primary respondent: 1. The primary/t"
	note instruction: "Instructions for Enumerator to identify the primary respondent: 1. The primary/target respondent for this survey would be the one whose name is mentioned in the preload as 'Target Respondent or respondents from the previous round'. Please note that if the respondent's name from the previous round i.e. Baseline census is male we would not survey them and find another female target respondent who knows about the housheold members and water usage and practices of the household 2. If the primary respondent (respondent from baseline census) is not available, ask to speak to the female head of the house or any other member of the household who could provide information about the family members and the water practices/usage/treatment of the household. Please note that only the family roster and WASH section have to be administered to the target respondent. Please prioritse a female respondent. All other sections would be administered to the respective pregnant mothers, mothers of U5 children, and childbearing women. You will not ask their questions to the target respondent. 4. Ensure that the interview for every pregnant women is conducted for the respondent health section, and that each of the mothers of U5 report on their respective child’s health. 5. If no pregnant woman or mother/ caregiver of a child below 5 years is available to be surveyed now but is available later, enumerator to revisit the household. Please confirm if the \${R_Cen_a1_resp_name} is the target respondent indeed or following the criteria above. If she is not, please make sure to survey the target respondent Is \${R_Cen_a1_resp_name} or some other target respondent in the Household available to give the survey?"
	label define instruction 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" -98 "Refused to answer" -77 "Other, please specify"
	label values instruction instruction

	label variable instruction_oth "B1.1) Please specify other"
	note instruction_oth: "B1.1) Please specify other"

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable no_consent_reason "B1) Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason: "B1) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "B1.1) Please specify other"
	note no_consent_oth: "B1.1) Please specify other"

	label variable no_consent_comment "B2) Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "B2) Record any relevant notes if the respondent refused the interview"

	label variable audio_consent "Do I have your permission to record the interview?"
	note audio_consent: "Do I have your permission to record the interview?"
	label define audio_consent 1 "Yes" 0 "No"
	label values audio_consent audio_consent

	label variable cen_resp_name "A1) What is the name of the current respondent?"
	note cen_resp_name: "A1) What is the name of the current respondent?"
	label define cen_resp_name 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" -77 "Other"
	label values cen_resp_name cen_resp_name

	label variable cen_resp_name_oth "B1.1) Please specify other"
	note cen_resp_name_oth: "B1.1) Please specify other"

	label variable why_chng_main "Why did you change the target respondent from \${R_Cen_main_resp_with_age} to \$"
	note why_chng_main: "Why did you change the target respondent from \${R_Cen_main_resp_with_age} to \${Cen_resp_label}?"

	label variable why_chng_main_oth "B1.1) Please specify other"
	note why_chng_main_oth: "B1.1) Please specify other"

	label variable n_new_members "Are there any new member(s) in the household who were not included earleir?"
	note n_new_members: "Are there any new member(s) in the household who were not included earleir?"
	label define n_new_members 1 "Yes" 0 "No"
	label values n_new_members n_new_members

	label variable n_new_members_verify "Are you sure that new members are not from the names below- \${R_Cen_fam_name1}/"
	note n_new_members_verify: "Are you sure that new members are not from the names below- \${R_Cen_fam_name1}/ \${R_Cen_fam_name2}/ \${R_Cen_fam_name3}/ \${R_Cen_fam_name4}/ \${R_Cen_fam_name5}/ \${R_Cen_fam_name6}/ \${R_Cen_fam_name7}/ \${R_Cen_fam_name8}/ \${R_Cen_fam_name9}/ \${R_Cen_fam_name10}/ \${R_Cen_fam_name11}/ \${R_Cen_fam_name12}/ \${R_Cen_fam_name13}/ \${R_Cen_fam_name14}/ \${R_Cen_fam_name15}/ \${R_Cen_fam_name16}/ \${R_Cen_fam_name17}"
	label define n_new_members_verify 1 "Yes" 0 "No"
	label values n_new_members_verify n_new_members_verify

	label variable n_hhmember_count "How many new members are in the household?"
	note n_hhmember_count: "How many new members are in the household?"

	label variable water_source_prim "W1) In the past month, which water source did you primarily use for drinking?"
	note water_source_prim: "W1) In the past month, which water source did you primarily use for drinking?"
	label define water_source_prim 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM " 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
	label values water_source_prim water_source_prim

	label variable water_prim_oth "W1.1) Please specify other"
	note water_prim_oth: "W1.1) Please specify other"

	label variable water_sec_yn "W2) In the past month, did your household use any sources of water for drinking "
	note water_sec_yn: "W2) In the past month, did your household use any sources of water for drinking besides \${primary_water_label}?"
	label define water_sec_yn 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values water_sec_yn water_sec_yn

	label variable water_source_sec "W2.1 )In the past month, what other water sources has your household used for dr"
	note water_source_sec: "W2.1 )In the past month, what other water sources has your household used for drinking?"

	label variable water_source_sec_oth "W2.1.1) Please specify other"
	note water_source_sec_oth: "W2.1.1) Please specify other"

	label variable water_source_main_sec "W2.2) What is the most used secondary water source among these sources for drink"
	note water_source_main_sec: "W2.2) What is the most used secondary water source among these sources for drinking purpose?"
	label define water_source_main_sec 1 "\${water_sec1}" 2 "\${water_sec2}" 3 "\${water_sec3}" 4 "\${water_sec4}" 5 "\${water_sec5}" 6 "\${water_sec6}" 7 "\${water_sec7}" 8 "\${water_sec8}" 9 "\${water_sec9}" 10 "\${water_sec10}"
	label values water_source_main_sec water_source_main_sec

	label variable quant "W3) In the past week, how much of your drinking watercame from your primary drin"
	note quant: "W3) In the past week, how much of your drinking watercame from your primary drinking water source: (\${primary_water_label})?"
	label define quant 1 "All of it (100%)" 2 "More than half of it" 3 "Half of it (50%)" 4 "Less than half of it" 5 "None of it (0%)" 999 "Don’t know"
	label values quant quant

	label variable sec_source_reason "In what circumstances do you collect drinking water from these other/secondary w"
	note sec_source_reason: "In what circumstances do you collect drinking water from these other/secondary water sources?"

	label variable sec_source_reason_oth "A14.1) If Other, please specify"
	note sec_source_reason_oth: "A14.1) If Other, please specify"

	label variable water_sec_freq "A15) Generally, when do you collect water for drinking from these other/secondar"
	note water_sec_freq: "A15) Generally, when do you collect water for drinking from these other/secondary water sources?"
	label define water_sec_freq 1 "Daily" 2 "Every 2-3 days in a week" 3 "Once a week" 4 "Once every two weeks" 5 "Once a month" 6 "Once every few months" 7 "Once a year" 8 "No fixed schedule" 999 "Don’t know"
	label values water_sec_freq water_sec_freq

	label variable water_sec_freq_oth "A15.1) If Other, please specify:"
	note water_sec_freq_oth: "A15.1) If Other, please specify:"

	label variable collect_resp "T1) Who in your household is responsible for collecting drinking water(primary o"
	note collect_resp: "T1) Who in your household is responsible for collecting drinking water(primary or secondary source)?"

	label variable prim_collect_resp "W5) Who usually goes to this source to collect the water from your primary sourc"
	note prim_collect_resp: "W5) Who usually goes to this source to collect the water from your primary source for your household: (\${primary_water_label})? This is the person who primarily collects water in the household."
	label define prim_collect_resp 1 "\${people_prim1}" 2 "\${people_prim2}" 3 "\${people_prim3}" 4 "\${people_prim4}" 5 "\${people_prim5}" 6 "\${people_prim6}" 7 "\${people_prim7}" 8 "\${people_prim8}" 9 "\${people_prim9}" 10 "\${people_prim10}" 11 "\${people_prim11}" 12 "\${people_prim12}" 13 "\${people_prim13}" 14 "\${people_prim14}" 15 "\${people_prim15}" 16 "\${people_prim16}" 17 "\${people_prim17}" 18 "\${people_prim18}" 19 "\${people_prim19}" 20 "\${people_prim20}" 21 "\${people_prim21}" 22 "\${people_prim22}" 23 "\${people_prim23}" 24 "\${people_prim24}" 25 "\${people_prim25}" 26 "\${people_prim26}" 27 "\${people_prim27}" 28 "\${people_prim28}" 29 "\${people_prim29}" 30 "\${people_prim30}" 31 "\${people_prim31}" 32 "\${people_prim32}" 33 "\${people_prim33}" 34 "\${people_prim34}" 35 "\${people_prim35}" 36 "\${people_prim36}" 37 "\${people_prim37}" 38 "\${people_prim38}" 39 "\${people_prim39}" 40 "\${people_prim40}"
	label values prim_collect_resp prim_collect_resp

	label variable where_prim_locate "W6) Where is your primary drinking water source (\${primary_water_label}) locate"
	note where_prim_locate: "W6) Where is your primary drinking water source (\${primary_water_label}) located?"
	label define where_prim_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate where_prim_locate

	label variable where_prim_locate_enum_obs "ENUMERATOR'S OBSERVATION- According to you where is the primary drinking water s"
	note where_prim_locate_enum_obs: "ENUMERATOR'S OBSERVATION- According to you where is the primary drinking water source (\${primary_water_label}) located? (Do not ask respondent)"
	label define where_prim_locate_enum_obs 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate_enum_obs where_prim_locate_enum_obs

	label variable collect_time "W7) When you collect water from your primary drinking water source (\${primary_w"
	note collect_time: "W7) When you collect water from your primary drinking water source (\${primary_water_label}), how much time does it take to walk to your primary water point, collect drinking water, and return home? (in minutes)"

	label variable collect_prim_freq "W8) In the past week, how many times did you collect drinking water from your pr"
	note collect_prim_freq: "W8) In the past week, how many times did you collect drinking water from your primary water source (\${primary_water_label}) ?"

	label variable water_treat "W16) In the last one month, did your household do anything extra to the drinking"
	note water_treat: "W16) In the last one month, did your household do anything extra to the drinking water (\${primary_water_label} ) to make it safe before drinking it?"
	label define water_treat 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values water_treat water_treat

	label variable water_stored "W18) For the water that is currently stored in the household, did you do anythin"
	note water_stored: "W18) For the water that is currently stored in the household, did you do anything extra to the drinking water to make it safe for drinking treated? (This is for both primary and secondary source)"
	label define water_stored 1 "Yes" 0 "No" 2 "No stored water currently but stored generally" 999 "Don't know"
	label values water_stored water_stored

	label variable water_treat_type "A16.1) What do you do to the water from the primary source (\${primary_water_lab"
	note water_treat_type: "A16.1) What do you do to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"

	label variable water_treat_oth "A16.2) If Other, please specify:"
	note water_treat_oth: "A16.2) If Other, please specify:"

	label variable water_treat_freq "A16.3) When do you make the water from your primary drinking water source (\${pr"
	note water_treat_freq: "A16.3) When do you make the water from your primary drinking water source (\${primary_water_label}) safe before drinking it?"

	label variable treat_freq_oth "A16.4) If Other, please specify:"
	note treat_freq_oth: "A16.4) If Other, please specify:"

	label variable not_treat_tim "In the past 2 weeks, have you ever decided not to treat your water because you d"
	note not_treat_tim: "In the past 2 weeks, have you ever decided not to treat your water because you didn’t have enough time?"
	label define not_treat_tim 1 "Yes" 0 "No"
	label values not_treat_tim not_treat_tim

	label variable treat_resp "W20) Who is responsible for treating water before drinking in your household? (T"
	note treat_resp: "W20) Who is responsible for treating water before drinking in your household? (This is for both primary and secondary source)"

	label variable treat_primresp "W21) Who usually treats the drinking water for your household?"
	note treat_primresp: "W21) Who usually treats the drinking water for your household?"
	label define treat_primresp 1 "\${treat_resp1}" 2 "\${treat_resp2}" 3 "\${treat_resp3}" 4 "\${treat_resp4}" 5 "\${treat_resp5}" 6 "\${treat_resp6}" 7 "\${treat_resp7}" 8 "\${treat_resp8}" 9 "\${treat_resp9}" 10 "\${treat_resp10}" 11 "\${treat_resp11}" 12 "\${treat_resp12}" 13 "\${treat_resp13}" 14 "\${treat_resp14}" 15 "\${treat_resp15}" 16 "\${treat_resp16}" 17 "\${treat_resp17}" 18 "\${treat_resp18}" 19 "\${treat_resp19}" 20 "\${treat_resp20}" 21 "\${treat_resp21}" 22 "\${treat_resp22}" 23 "\${treat_resp23}" 24 "\${treat_resp24}" 25 "\${treat_resp25}" 26 "\${treat_resp26}" 27 "\${treat_resp27}" 28 "\${treat_resp28}" 29 "\${treat_resp29}" 30 "\${treat_resp30}" 31 "\${treat_resp31}" 32 "\${treat_resp32}" 33 "\${treat_resp33}" 34 "\${treat_resp34}" 35 "\${treat_resp35}" 36 "\${treat_resp36}" 37 "\${treat_resp37}" 38 "\${treat_resp38}" 39 "\${treat_resp39}" 40 "\${treat_resp40}"
	label values treat_primresp treat_primresp

	label variable treat_time "W22) When you/ someone else make your drinking water safe, how much time does it"
	note treat_time: "W22) When you/ someone else make your drinking water safe, how much time does it take to complete the process? (in minutes)"

	label variable treat_freq "W23) How many times in a week does your household treat your drinking water? (pe"
	note treat_freq: "W23) How many times in a week does your household treat your drinking water? (per week)"

	label variable collect_treat_difficult "W24) How difficult is it to treat your drinking water? (This is for both primary"
	note collect_treat_difficult: "W24) How difficult is it to treat your drinking water? (This is for both primary or secondary source)"
	label define collect_treat_difficult 1 "Very difficult" 2 "Somewhat difficult" 3 "Neither difficult nor easy" 4 "Somewhat easy" 5 "Very easy" 999 "Don’t know"
	label values collect_treat_difficult collect_treat_difficult

	label variable clean_freq_containers "How many times per week do you clean your drinking water storage containers?"
	note clean_freq_containers: "How many times per week do you clean your drinking water storage containers?"

	label variable clean_time_containers "How much time does it take to clean your drinking water storage containers each "
	note clean_time_containers: "How much time does it take to clean your drinking water storage containers each time you do it? (in minutes)"

	label variable water_source_kids "A17) Do your youngest children drink from the same water source as the household"
	note water_source_kids: "A17) Do your youngest children drink from the same water source as the household’s primary drinking water source i.e (\${primary_water_label}) ?"
	label define water_source_kids 1 "Yes" 0 "No" 3 "No U5 child present in the HH" 4 "U5 child is being breastfed exclusively" 999 "Don't know" -98 "Refused to answer"
	label values water_source_kids water_source_kids

	label variable water_prim_source_kids "A17.1) What is the primary drinking water source for your youngest children?"
	note water_prim_source_kids: "A17.1) What is the primary drinking water source for your youngest children?"
	label define water_prim_source_kids 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM " 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
	label values water_prim_source_kids water_prim_source_kids

	label variable water_prim_kids_oth "A17.2) If Other, please specify:"
	note water_prim_kids_oth: "A17.2) If Other, please specify:"

	label variable water_source_preg "A17) Do pregnant women drink from the same water source as the household’s prima"
	note water_source_preg: "A17) Do pregnant women drink from the same water source as the household’s primary drinking water source i.e (\${primary_water_label}) ?"
	label define water_source_preg 1 "Yes" 0 "No" 3 "No Preg women present in the HH" 999 "Don't know" -98 "Refused to answer"
	label values water_source_preg water_source_preg

	label variable water_prim_source_preg "A17.1) What is the primary drinking water source for your pregnant women?"
	note water_prim_source_preg: "A17.1) What is the primary drinking water source for your pregnant women?"
	label define water_prim_source_preg 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM " 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
	label values water_prim_source_preg water_prim_source_preg

	label variable water_prim_preg_oth "A17.2) If Other, please specify:"
	note water_prim_preg_oth: "A17.2) If Other, please specify:"

	label variable water_treat_kids "A17.3) Do you ever do anything to the water for your youngest children to make i"
	note water_treat_kids: "A17.3) Do you ever do anything to the water for your youngest children to make it safe for drinking?"
	label define water_treat_kids 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values water_treat_kids water_treat_kids

	label variable water_treat_kids_type "A17.4) What do you do to the water for your youngest children (children under 5)"
	note water_treat_kids_type: "A17.4) What do you do to the water for your youngest children (children under 5) to make it safe for drinking?"

	label variable water_treat_kids_oth "A17.5) If Other, please specify:"
	note water_treat_kids_oth: "A17.5) If Other, please specify:"

	label variable treat_kids_freq "A17.6) For your youngest children, when do you make the water safe before they d"
	note treat_kids_freq: "A17.6) For your youngest children, when do you make the water safe before they drink it?"

	label variable treat_kids_freq_oth "A17.7) If Other, please specify:"
	note treat_kids_freq_oth: "A17.7) If Other, please specify:"

	label variable jjm_drinking "A18) Do you use the government provided household tap for drinking?"
	note jjm_drinking: "A18) Do you use the government provided household tap for drinking?"
	label define jjm_drinking 1 "Yes" 0 "No"
	label values jjm_drinking jjm_drinking

	label variable tap_supply_freq "G1) Generally, when is water supplied from the government provided tap/ supply p"
	note tap_supply_freq: "G1) Generally, when is water supplied from the government provided tap/ supply paani?"
	label define tap_supply_freq 1 "Daily" 2 "Few days in a week" 3 "Once a week" 4 "Few times in a month" 5 "Once a month" 6 "No fixed schedule" -77 "Other" 999 "Don’t know" -98 "Refused to answer"
	label values tap_supply_freq tap_supply_freq

	label variable tap_supply_freq_oth "G1.1) Please specify other"
	note tap_supply_freq_oth: "G1.1) Please specify other"

	label variable tap_supply_daily "G2) In a day, how many times is water supplied from the government provided hous"
	note tap_supply_daily: "G2) In a day, how many times is water supplied from the government provided household tap/ supply paani?"

	label variable reason_nodrink "A18.1) What is the reason for not using this household tap for drinking?"
	note reason_nodrink: "A18.1) What is the reason for not using this household tap for drinking?"

	label variable nodrink_water_treat_oth "A18.2) If Other, please specify:"
	note nodrink_water_treat_oth: "A18.2) If Other, please specify:"

	label variable jjm_stored "A19) Is any water from the Government provided household tap stored in your hous"
	note jjm_stored: "A19) Is any water from the Government provided household tap stored in your house currently or was stored today/ yesterday?"
	label define jjm_stored 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values jjm_stored jjm_stored

	label variable jjm_yes "A20) Do you use water collected from the government provided household taps for "
	note jjm_yes: "A20) Do you use water collected from the government provided household taps for any other purposes (other than drinking)?"
	label define jjm_yes 1 "Yes" 0 "No"
	label values jjm_yes jjm_yes

	label variable jjm_use "A20.1) For what purposes do you use water collected from the government provided"
	note jjm_use: "A20.1) For what purposes do you use water collected from the government provided household taps?"

	label variable jjm_use_oth "A20.2) If Other, please specify:"
	note jjm_use_oth: "A20.2) If Other, please specify:"

	label variable tap_function "G10) In the last two weeks, have you tried to collect water from the government "
	note tap_function: "G10) In the last two weeks, have you tried to collect water from the government provided household tap but the tap/supply pani was not working?"
	label define tap_function 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values tap_function tap_function

	label variable tap_function_reason "G11) Why was the government provided household tap/ supply paani not working?"
	note tap_function_reason: "G11) Why was the government provided household tap/ supply paani not working?"

	label variable tap_function_oth "G11.1) Please specify other"
	note tap_function_oth: "G11.1) Please specify other"

	label variable tap_issues "In the last two weeks, have you faced any issues with the water supplied from th"
	note tap_issues: "In the last two weeks, have you faced any issues with the water supplied from the government provided tap?"
	label define tap_issues 1 "Yes" 0 "No"
	label values tap_issues tap_issues

	label variable tap_issues_type "What issues have you faced?"
	note tap_issues_type: "What issues have you faced?"

	label variable tap_issues_type_oth "Please specify other"
	note tap_issues_type_oth: "Please specify other"

	label variable n_med_seek_all "Out of the members below, In the past one month, has anyone sought medical care?"
	note n_med_seek_all: "Out of the members below, In the past one month, has anyone sought medical care?"

	label variable cen_med_seek_all "Out of the members below, In the past one month, has anyone sought medical care?"
	note cen_med_seek_all: "Out of the members below, In the past one month, has anyone sought medical care?"

	label variable hh_member_present "Was any translator used or was there any household member (other than \${Cen_res"
	note hh_member_present: "Was any translator used or was there any household member (other than \${Cen_resp_label}) present during the survey?"
	label define hh_member_present 1 "Yes" 0 "No"
	label values hh_member_present hh_member_present

	label variable hh_member_section "For which sections translator or Household member was present?"
	note hh_member_section: "For which sections translator or Household member was present?"

	label variable visit_num "S4) Is this your 1st visit, 1st re-visit or 2nd re-visit?"
	note visit_num: "S4) Is this your 1st visit, 1st re-visit or 2nd re-visit?"
	label define visit_num 0 "1st visit" 1 "2nd visit (i.e. 1st revisit)" 2 "3rd visit (i.e. 2nd revisit)"
	label values visit_num visit_num

	label variable e_surveys_revisit "Are any of your surveys still kept for re-visit i.e. for pregnant women, U5 chil"
	note e_surveys_revisit: "Are any of your surveys still kept for re-visit i.e. for pregnant women, U5 child or child bearing women?"
	label define e_surveys_revisit 1 "Yes" 0 "No"
	label values e_surveys_revisit e_surveys_revisit

	label variable a40_gps_manuallatitude "A40.1) Please record the GPS location of this household (latitude)"
	note a40_gps_manuallatitude: "A40.1) Please record the GPS location of this household (latitude)"

	label variable a40_gps_manuallongitude "A40.1) Please record the GPS location of this household (longitude)"
	note a40_gps_manuallongitude: "A40.1) Please record the GPS location of this household (longitude)"

	label variable a40_gps_manualaltitude "A40.1) Please record the GPS location of this household (altitude)"
	note a40_gps_manualaltitude: "A40.1) Please record the GPS location of this household (altitude)"

	label variable a40_gps_manualaccuracy "A40.1) Please record the GPS location of this household (accuracy)"
	note a40_gps_manualaccuracy: "A40.1) Please record the GPS location of this household (accuracy)"

	label variable a40_gps_handlongitude "Please put the longitude of the household location"
	note a40_gps_handlongitude: "Please put the longitude of the household location"

	label variable a40_gps_handlatitude "Please put the latitude of the household location"
	note a40_gps_handlatitude: "Please put the latitude of the household location"

	label variable a41_end_comments "A41) Please add any additional comments about this survey."
	note a41_end_comments: "A41) Please add any additional comments about this survey."

	label variable a42_survey_accompany_num "A42) Please record the number of people who attended or accompanied this intervi"
	note a42_survey_accompany_num: "A42) Please record the number of people who attended or accompanied this interview aside from yourself or household member you are interviewing"



	capture {
		foreach rgvar of varlist cen_days_num_residence_* {
			label variable `rgvar' "Since September 2023 how many DAYS has \${name_from_earlier_HH} spent away from "
			note `rgvar': "Since September 2023 how many DAYS has \${name_from_earlier_HH} spent away from this village?"
		}
	}

	capture {
		foreach rgvar of varlist cen_still_a_member_* {
			label variable `rgvar' "Is \${name_from_earlier_HH} still a member of this household, as per the definit"
			note `rgvar': "Is \${name_from_earlier_HH} still a member of this household, as per the definition?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_hhmember_name_* {
			label variable `rgvar' "A3) What is the name of household member \${namenumber}?"
			note `rgvar': "A3) What is the name of household member \${namenumber}?"
		}
	}

	capture {
		foreach rgvar of varlist n_hhmember_gender_* {
			label variable `rgvar' "A4) What is the gender of \${namefromearlier}?"
			note `rgvar': "A4) What is the gender of \${namefromearlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_hhmember_relation_* {
			label variable `rgvar' "A5) Who is \${namefromearlier} to you ?"
			note `rgvar': "A5) Who is \${namefromearlier} to you ?"
			label define `rgvar' 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" 13 "Brother-in-law/sister-in-law" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_relation_oth_* {
			label variable `rgvar' "A5.1) If Other, please specify:"
			note `rgvar': "A5.1) If Other, please specify:"
		}
	}

	capture {
		foreach rgvar of varlist n_hhmember_age_* {
			label variable `rgvar' "A6) How old is \${namefromearlier} in years?"
			note `rgvar': "A6) How old is \${namefromearlier} in years?"
		}
	}

	capture {
		foreach rgvar of varlist n_dob_date_* {
			label variable `rgvar' "Please select the date of birth"
			note `rgvar': "Please select the date of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dob_month_* {
			label variable `rgvar' "Please select the month of birth"
			note `rgvar': "Please select the month of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dob_year_* {
			label variable `rgvar' "Please select the year of birth"
			note `rgvar': "Please select the year of birth"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_year_dob_correction_* {
			label variable `rgvar' "Note to Enumerator: The age calculated based on the date of birth- \${N_autoage}"
			note `rgvar': "Note to Enumerator: The age calculated based on the date of birth- \${N_autoage}- should match the age of the child given in years by the respondent. Please note that there cannot be a difference of more than a year in the estimated/imputed age. Go back to the question and confirm with respondent properly Did you confirm the age and date of birth properly?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_u1age_* {
			label variable `rgvar' "A6.3) How old is \${namefromearlier} in months/days?"
			note `rgvar': "A6.3) How old is \${namefromearlier} in months/days?"
			label define `rgvar' 1 "Months" 2 "Days" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_unit_age_months_* {
			label variable `rgvar' "Write in months"
			note `rgvar': "Write in months"
		}
	}

	capture {
		foreach rgvar of varlist n_unit_age_days_* {
			label variable `rgvar' "Write in days"
			note `rgvar': "Write in days"
		}
	}

	capture {
		foreach rgvar of varlist n_correct_age_* {
			label variable `rgvar' "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed"
			note `rgvar': "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed from birth certificate/ Anganwadi records) or imputed/guessed"
			label define `rgvar' 1 "Age for U5 child accurate" 2 "Age for U5 child imputed/guessed"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_u5mother_* {
			label variable `rgvar' "A8) Does the mother/ primary caregiver of \${namefromearlier} live in this house"
			note `rgvar': "A8) Does the mother/ primary caregiver of \${namefromearlier} live in this household currently?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_u5mother_name_* {
			label variable `rgvar' "A8.1) What is the name of \${namefromearlier}'s mother/ primary caregiver?"
			note `rgvar': "A8.1) What is the name of \${namefromearlier}'s mother/ primary caregiver?"
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${N_fam_name1} and \${N_fam_age1} years" 22 "\${N_fam_name2} and \${N_fam_age2} years" 23 "\${N_fam_name3} and \${N_fam_age3} years" 24 "\${N_fam_name4} and \${N_fam_age4} years" 25 "\${N_fam_name5} and \${N_fam_age5} years" 26 "\${N_fam_name6} and \${N_fam_age6} years" 27 "\${N_fam_name7} and \${N_fam_age7} years" 28 "\${N_fam_name8} and \${N_fam_age8} years" 29 "\${N_fam_name9} and \${N_fam_age9} years" 30 "\${N_fam_name10} and \${N_fam_age10} years" 31 "\${N_fam_name11} and \${N_fam_age11} years" 32 "\${N_fam_name12} and \${N_fam_age12} years" 33 "\${N_fam_name13} and \${N_fam_age13} years" 34 "\${N_fam_name14} and \${N_fam_age14} years" 35 "\${N_fam_name15} and \${N_fam_age15} years" 36 "\${N_fam_name16} and \${N_fam_age16} years" 37 "\${N_fam_name17} and \${N_fam_age17} years" 38 "\${N_fam_name18} and \${N_fam_age18} years" 39 "\${N_fam_name19} and \${N_fam_age19} years" 40 "\${N_fam_name20} and \${N_fam_age20} years"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_u5mother_name_oth_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_u5father_name_* {
			label variable `rgvar' "A8.1) What is the name of \${namefromearlier}'s father?"
			note `rgvar': "A8.1) What is the name of \${namefromearlier}'s father?"
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${N_fam_name1} and \${N_fam_age1} years" 22 "\${N_fam_name2} and \${N_fam_age2} years" 23 "\${N_fam_name3} and \${N_fam_age3} years" 24 "\${N_fam_name4} and \${N_fam_age4} years" 25 "\${N_fam_name5} and \${N_fam_age5} years" 26 "\${N_fam_name6} and \${N_fam_age6} years" 27 "\${N_fam_name7} and \${N_fam_age7} years" 28 "\${N_fam_name8} and \${N_fam_age8} years" 29 "\${N_fam_name9} and \${N_fam_age9} years" 30 "\${N_fam_name10} and \${N_fam_age10} years" 31 "\${N_fam_name11} and \${N_fam_age11} years" 32 "\${N_fam_name12} and \${N_fam_age12} years" 33 "\${N_fam_name13} and \${N_fam_age13} years" 34 "\${N_fam_name14} and \${N_fam_age14} years" 35 "\${N_fam_name15} and \${N_fam_age15} years" 36 "\${N_fam_name16} and \${N_fam_age16} years" 37 "\${N_fam_name17} and \${N_fam_age17} years" 38 "\${N_fam_name18} and \${N_fam_age18} years" 39 "\${N_fam_name19} and \${N_fam_age19} years" 40 "\${N_fam_name20} and \${N_fam_age20} years" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_u5father_name_oth_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_school_* {
			label variable `rgvar' "A9) Has \${namefromearlier} ever attended school?"
			note `rgvar': "A9) Has \${namefromearlier} ever attended school?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_school_level_* {
			label variable `rgvar' "A9.1) What is the highest level of schooling that \${namefromearlier} has comple"
			note `rgvar': "A9.1) What is the highest level of schooling that \${namefromearlier} has completed?"
			label define `rgvar' 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_school_current_* {
			label variable `rgvar' "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
			note `rgvar': "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_read_write_* {
			label variable `rgvar' "A9.3) Can \${namefromearlier} read or write?"
			note `rgvar': "A9.3) Can \${namefromearlier} read or write?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_visits_all_* {
			label variable `rgvar' "How many visits \${N_med_name_all} did in the last one month to seek medical car"
			note `rgvar': "How many visits \${N_med_name_all} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_all_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_all_* {
			label variable `rgvar' "Where did \${N_med_name_all} seek care?"
			note `rgvar': "Where did \${N_med_name_all} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_nights_all_* {
			label variable `rgvar' "How many nights did \${N_med_name_all} spend in the hospital?"
			note `rgvar': "How many nights did \${N_med_name_all} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_home_all_* {
			label variable `rgvar' "Where did \${N_med_name_all} seek care?"
			note `rgvar': "Where did \${N_med_name_all} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_type_all_* {
			label variable `rgvar' "What was the nature of treatment at \${N_out_names_all} that \${N_med_name_all} "
			note `rgvar': "What was the nature of treatment at \${N_out_names_all} that \${N_med_name_all} took?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_trans_all_* {
			label variable `rgvar' "What was the mode of transportation taken by \${N_med_name_all} to travel to \${"
			note `rgvar': "What was the mode of transportation taken by \${N_med_name_all} to travel to \${N_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_all_* {
			label variable `rgvar' "How much time did \${N_med_name_all} to travel to \${N_out_names_all} to receive"
			note `rgvar': "How much time did \${N_med_name_all} to travel to \${N_out_names_all} to receive care? (in minutes)"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_mins_all_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_hrs_all_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist n_med_pay_trans_all_* {
			label variable `rgvar' "What did \${N_med_name_all} pay for the transportation to travel to \${N_out_nam"
			note `rgvar': "What did \${N_med_name_all} pay for the transportation to travel to \${N_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_scheme_all_* {
			label variable `rgvar' "Was \${N_med_name_all} covered by any scheme for health expenditure support for "
			note `rgvar': "Was \${N_med_name_all} covered by any scheme for health expenditure support for the expenditure incurred at \${N_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_doctor_fees_all_* {
			label variable `rgvar' "What did \${N_med_name_all} pay for the consultation/treatment (doctor fees) at "
			note `rgvar': "What did \${N_med_name_all} pay for the consultation/treatment (doctor fees) at \${N_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_all_* {
			label variable `rgvar' "Did \${N_med_name_all} pay for anything else for this illness at \${N_out_names_"
			note `rgvar': "Did \${N_med_name_all} pay for anything else for this illness at \${N_out_names_all}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_other_all_* {
			label variable `rgvar' "What did \${N_med_name_all} pay for at \${N_out_names_all}?"
			note `rgvar': "What did \${N_med_name_all} pay for at \${N_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_otherpay_all_* {
			label variable `rgvar' "What amount did \${N_med_name_all} pay for \${N_other_exp_all} at \${N_out_names"
			note `rgvar': "What amount did \${N_med_name_all} pay for \${N_other_exp_all} at \${N_out_names_all} ?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_t_exp_all_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${N_med_name_all} did on "
			note `rgvar': "In the last one month, what was the total expenditure \${N_med_name_all} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_all_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${N_med_name_all} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_who_all_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${N_med_name_all}?"
			note `rgvar': "Who adjusted their schedule to take care of \${N_med_name_all}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_days_caretaking_all_* {
			label variable `rgvar' "How many days have this person taken caretaking \${N_med_name_all} (including th"
			note `rgvar': "How many days have this person taken caretaking \${N_med_name_all} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_visits_all_* {
			label variable `rgvar' "How many visits \${Cen_med_name_all} did in the last one month to seek medical c"
			note `rgvar': "How many visits \${Cen_med_name_all} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_symp_all_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_symp_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_where_all_* {
			label variable `rgvar' "Where did \${Cen_med_name_all} seek care?"
			note `rgvar': "Where did \${Cen_med_name_all} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_where_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_nights_all_* {
			label variable `rgvar' "How many nights did \${Cen_med_name_all} spend in the hospital?"
			note `rgvar': "How many nights did \${Cen_med_name_all} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_out_home_all_* {
			label variable `rgvar' "Where did \${Cen_med_name_all} seek care?"
			note `rgvar': "Where did \${Cen_med_name_all} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_out_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_treat_type_all_* {
			label variable `rgvar' "What was the nature of treatment at \${Cen_out_names_all} that \${Cen_med_name_a"
			note `rgvar': "What was the nature of treatment at \${Cen_out_names_all} that \${Cen_med_name_all} took?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_treat_oth_all_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_trans_all_* {
			label variable `rgvar' "What was the mode of transportation taken by \${Cen_med_name_all} to travel to \"
			note `rgvar': "What was the mode of transportation taken by \${Cen_med_name_all} to travel to \${Cen_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_time_all_* {
			label variable `rgvar' "How much time did \${Cen_med_name_all} to travel to \${Cen_out_names_all} to rec"
			note `rgvar': "How much time did \${Cen_med_name_all} to travel to \${Cen_out_names_all} to receive care? (in minutes)"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cen_med_time_mins_all_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_time_hrs_all_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_pay_trans_all_* {
			label variable `rgvar' "What did \${Cen_med_name_all} pay for the transportation to travel to \${Cen_out"
			note `rgvar': "What did \${Cen_med_name_all} pay for the transportation to travel to \${Cen_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_scheme_all_* {
			label variable `rgvar' "Was \${Cen_med_name_all} covered by any scheme for health expenditure support fo"
			note `rgvar': "Was \${Cen_med_name_all} covered by any scheme for health expenditure support for the expenditure incurred at \${Cen_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_doctor_fees_all_* {
			label variable `rgvar' "What did \${Cen_med_name_all} pay for the consultation/treatment (doctor fees) a"
			note `rgvar': "What did \${Cen_med_name_all} pay for the consultation/treatment (doctor fees) at \${Cen_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_illness_all_* {
			label variable `rgvar' "Did \${Cen_med_name_all} pay for anything else for this illness at \${Cen_out_na"
			note `rgvar': "Did \${Cen_med_name_all} pay for anything else for this illness at \${Cen_out_names_all}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cen_med_illness_other_all_* {
			label variable `rgvar' "What did \${Cen_med_name_all} pay for at \${Cen_out_names_all}?"
			note `rgvar': "What did \${Cen_med_name_all} pay for at \${Cen_out_names_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_otherpay_all_* {
			label variable `rgvar' "What amount did \${Cen_med_name_all} pay for \${Cen_other_exp_all} at \${Cen_out"
			note `rgvar': "What amount did \${Cen_med_name_all} pay for \${Cen_other_exp_all} at \${Cen_out_names_all} ?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_t_exp_all_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${Cen_med_name_all} did o"
			note `rgvar': "In the last one month, what was the total expenditure \${Cen_med_name_all} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_work_all_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${Cen_med_name_all} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cen_med_work_who_all_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${Cen_med_name_all}?"
			note `rgvar': "Who adjusted their schedule to take care of \${Cen_med_name_all}?"
		}
	}

	capture {
		foreach rgvar of varlist cen_med_days_caretaking_all_* {
			label variable `rgvar' "How many days have this person taken caretaking \${Cen_med_name_all} (including "
			note `rgvar': "How many days have this person taken caretaking \${Cen_med_name_all} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist comb_resp_avail_cbw_* {
			label variable `rgvar' "C2) Did you find \${comb_name_CBW_woman_earlier} to interview?"
			note `rgvar': "C2) Did you find \${comb_name_CBW_woman_earlier} to interview?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 7 "Respondent died or is no longer a member of the household" 8 "Respondent no longer falls in the criteria (15-49 years)" 9 "Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_resp_avail_cbw_oth_* {
			label variable `rgvar' "B1.1) Please specify other"
			note `rgvar': "B1.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist comb_resp_gen_v_cbw_* {
			label variable `rgvar' "Was gender of \${comb_name_CBW_woman_earlier} correct in the baseline census? (I"
			note `rgvar': "Was gender of \${comb_name_CBW_woman_earlier} correct in the baseline census? (If she is female and was recorded as female in the baseline please say 'Yes' and if they are male but was recorded as female in the baseline please say 'No')"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_age_ch_cbw_* {
			label variable `rgvar' "Was age of \${comb_name_CBW_woman_earlier} correct during baseline census? (If r"
			note `rgvar': "Was age of \${comb_name_CBW_woman_earlier} correct during baseline census? (If respondent's actual age is out of the criteria (15-49 years) in reality but during baseline census she was recorded in the criteria (15-49 years) please 'No'. If her age was correctly recorded please select 'Yes'"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_resp_age_v_cbw_* {
			label variable `rgvar' "Did you verify \${comb_name_CBW_woman_earlier} age with adhaar card or any other"
			note `rgvar': "Did you verify \${comb_name_CBW_woman_earlier} age with adhaar card or any other official identity document ?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_resp_age_cbw_* {
			label variable `rgvar' "What is the actual age of \${comb_name_CBW_woman_earlier}?"
			note `rgvar': "What is the actual age of \${comb_name_CBW_woman_earlier}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_cbw_consent_* {
			label variable `rgvar' "C3)Do I have your permission to proceed with the interview?"
			note `rgvar': "C3)Do I have your permission to proceed with the interview?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_no_consent_reason_* {
			label variable `rgvar' "C4) Can you tell me why you do not want to participate in the survey?"
			note `rgvar': "C4) Can you tell me why you do not want to participate in the survey?"
		}
	}

	capture {
		foreach rgvar of varlist comb_no_consent_oth_* {
			label variable `rgvar' "C4.1) Please specify other"
			note `rgvar': "C4.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist comb_no_consent_comment_* {
			label variable `rgvar' "C4.2) Record any relevant notes if the respondent refused the interview"
			note `rgvar': "C4.2) Record any relevant notes if the respondent refused the interview"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_status_* {
			label variable `rgvar' "Is \${comb_name_CBW_woman_earlier} pregnant?"
			note `rgvar': "Is \${comb_name_CBW_woman_earlier} pregnant?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_not_curr_preg_* {
			label variable `rgvar' "Was \${comb_name_CBW_woman_earlier} pregnant in the last 7 months?"
			note `rgvar': "Was \${comb_name_CBW_woman_earlier} pregnant in the last 7 months?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_month_* {
			label variable `rgvar' "Which month of \${comb_name_CBW_woman_earlier}'s pregnancy is this?"
			note `rgvar': "Which month of \${comb_name_CBW_woman_earlier}'s pregnancy is this?"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_delivery_* {
			label variable `rgvar' "What is the expected month of delivery of \${comb_name_CBW_woman_earlier}? (Writ"
			note `rgvar': "What is the expected month of delivery of \${comb_name_CBW_woman_earlier}? (Write no. of the calender month)"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_hus_* {
			label variable `rgvar' "What is the name of \${comb_name_CBW_woman_earlier}'s husband?"
			note `rgvar': "What is the name of \${comb_name_CBW_woman_earlier}'s husband?"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_residence_* {
			label variable `rgvar' "Is this \${comb_name_CBW_woman_earlier}'s usual residence?"
			note `rgvar': "Is this \${comb_name_CBW_woman_earlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_stay_* {
			label variable `rgvar' "C7) How long is \${comb_name_CBW_woman_earlier} planning to stay here (at the ho"
			note `rgvar': "C7) How long is \${comb_name_CBW_woman_earlier} planning to stay here (at the house where the survey is being conducted) ?"
			label define `rgvar' 1 "Months" 2 "Days" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_stay_days_* {
			label variable `rgvar' "Record in Days"
			note `rgvar': "Record in Days"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_stay_months_* {
			label variable `rgvar' "Record in Months"
			note `rgvar': "Record in Months"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_current_village_* {
			label variable `rgvar' "C6) Which village is \${comb_name_CBW_woman_earlier} ’s current permanent reside"
			note `rgvar': "C6) Which village is \${comb_name_CBW_woman_earlier} ’s current permanent residence in?"
			label define `rgvar' 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30601 "Hatikhamba" 30602 "Mukundpur" 30701 "Gopi Kankubadi" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 50601 "Badaalubadi" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_current_village_oth_* {
			label variable `rgvar' "C6.1) Please specify other"
			note `rgvar': "C6.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist comb_vill_residence_* {
			label variable `rgvar' "C8) Was \${village_name_res}\${comb_name_CBW_woman_earlier}'s permanent residenc"
			note `rgvar': "C8) Was \${village_name_res}\${comb_name_CBW_woman_earlier}'s permanent residence at any time in the last 5 years?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_get_rch_* {
			label variable `rgvar' "Did \${comb_name_CBW_woman_earlier} register the pregnancy with the ASHA and get"
			note `rgvar': "Did \${comb_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a registration card/number (RCH ID)?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_get_rch_confirm_* {
			label variable `rgvar' "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${"
			note `rgvar': "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${comb_name_CBW_woman_earlier} has received an RCH ID?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_rch_id_* {
			label variable `rgvar' "Please note down RCH ID no. of \${comb_name_CBW_woman_earlier}"
			note `rgvar': "Please note down RCH ID no. of \${comb_name_CBW_woman_earlier}"
		}
	}

	capture {
		foreach rgvar of varlist comb_preg_rch_id_inc_* {
			label variable `rgvar' "Please note down RCH ID no. of \${comb_name_CBW_woman_earlier}. Write the RCH ID"
			note `rgvar': "Please note down RCH ID no. of \${comb_name_CBW_woman_earlier}. Write the RCH ID here only if some of the digits are missing or extra from the booklet shown by the respondent. The correct RCH ID will have exactly 12 digits so if that is not the case with this ID mention here."
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_vomit_day_* {
			label variable `rgvar' "A22) Did \${comb_name_CBW_woman_earlier} vomit today or yesterday?"
			note `rgvar': "A22) Did \${comb_name_CBW_woman_earlier} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_vomit_wk_* {
			label variable `rgvar' "A22.1) Did \${comb_name_CBW_woman_earlier} vomit in the last 7 days?"
			note `rgvar': "A22.1) Did \${comb_name_CBW_woman_earlier} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_vomit_2wk_* {
			label variable `rgvar' "A22.2) Did \${comb_name_CBW_woman_earlier} vomit in the past 2 weeks?"
			note `rgvar': "A22.2) Did \${comb_name_CBW_woman_earlier} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_diarr_day_* {
			label variable `rgvar' "A23) Did \${comb_name_CBW_woman_earlier} have diarrhea today or yesterday?"
			note `rgvar': "A23) Did \${comb_name_CBW_woman_earlier} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_diarr_wk_* {
			label variable `rgvar' "A23.1) Did \${comb_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
			note `rgvar': "A23.1) Did \${comb_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_diarr_2wk_* {
			label variable `rgvar' "A23.2) Did \${comb_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
			note `rgvar': "A23.2) Did \${comb_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_diarr_num_wk_* {
			label variable `rgvar' "A24.1) How many days did \${comb_name_CBW_woman_earlier} have diarrhea in the pa"
			note `rgvar': "A24.1) How many days did \${comb_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_diarr_num_2wks_* {
			label variable `rgvar' "A24.2) How many days did \${comb_name_CBW_woman_earlier} have diarrhea in the pa"
			note `rgvar': "A24.2) How many days did \${comb_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_stool_24h_* {
			label variable `rgvar' "A25) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools w"
			note `rgvar': "A25) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_stool_yest_* {
			label variable `rgvar' "A25.1) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools"
			note `rgvar': "A25.1) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_stool_wk_* {
			label variable `rgvar' "A25.2) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools"
			note `rgvar': "A25.2) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_stool_2wk_* {
			label variable `rgvar' "A25.3) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools"
			note `rgvar': "A25.3) Did \${comb_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_blood_day_* {
			label variable `rgvar' "A26) Did \${comb_name_CBW_woman_earlier} have blood in her stool today or yester"
			note `rgvar': "A26) Did \${comb_name_CBW_woman_earlier} have blood in her stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_blood_wk_* {
			label variable `rgvar' "A26.1) Did \${comb_name_CBW_woman_earlier} have blood in her stool in the past 7"
			note `rgvar': "A26.1) Did \${comb_name_CBW_woman_earlier} have blood in her stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_blood_2wk_* {
			label variable `rgvar' "A26.2) Did \${comb_name_CBW_woman_earlier} have blood in her stool in the past 2"
			note `rgvar': "A26.2) Did \${comb_name_CBW_woman_earlier} have blood in her stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_cuts_day_* {
			label variable `rgvar' "A21) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts tod"
			note `rgvar': "A21) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_cuts_wk_* {
			label variable `rgvar' "A21.1) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts i"
			note `rgvar': "A21.1) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_wom_cuts_2wk_* {
			label variable `rgvar' "A21.2) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts i"
			note `rgvar': "A21.2) Did \${comb_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_wk_* {
			label variable `rgvar' "In the last week, has \${comb_name_CBW_woman_earlier} taken antibiotics?"
			note `rgvar': "In the last week, has \${comb_name_CBW_woman_earlier} taken antibiotics?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_days_* {
			label variable `rgvar' "In the last week, How many days ago did \${comb_name_CBW_woman_earlier} take ant"
			note `rgvar': "In the last week, How many days ago did \${comb_name_CBW_woman_earlier} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_last_* {
			label variable `rgvar' "How long ago did \${comb_name_CBW_woman_earlier} last take antibiotics?"
			note `rgvar': "How long ago did \${comb_name_CBW_woman_earlier} last take antibiotics?"
			label define `rgvar' 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_last_months_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_last_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_purpose_* {
			label variable `rgvar' "For what purpose did you take antibiotics?"
			note `rgvar': "For what purpose did you take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_preg_purpose_oth_* {
			label variable `rgvar' "Please specify others"
			note `rgvar': "Please specify others"
		}
	}

	capture {
		foreach rgvar of varlist comb_last_5_years_pregnant_* {
			label variable `rgvar' "C9)Has \${comb_name_CBW_woman_earlier} ever been pregnant in the last 5 years si"
			note `rgvar': "C9)Has \${comb_name_CBW_woman_earlier} ever been pregnant in the last 5 years since January 1, 2019?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_living_* {
			label variable `rgvar' "C10) Do you have any children under 5 years of age to whom you have given birth "
			note `rgvar': "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_living_num_* {
			label variable `rgvar' "C11) How many children born since January 1, 2019 live with you?"
			note `rgvar': "C11) How many children born since January 1, 2019 live with you?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_notliving_* {
			label variable `rgvar' "C12) Do you have any children born since January 1, 2019 to whom you have given "
			note `rgvar': "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_notliving_num_* {
			label variable `rgvar' "C13) How many children born since January 1, 2019 are alive but do not live with"
			note `rgvar': "C13) How many children born since January 1, 2019 are alive but do not live with you?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stillborn_* {
			label variable `rgvar' "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
			note `rgvar': "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stillborn_num_* {
			label variable `rgvar' "C15) How many children born since January 1, 2019 were stillborn?"
			note `rgvar': "C15) How many children born since January 1, 2019 were stillborn?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_alive_died_less24_* {
			label variable `rgvar' "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
			note `rgvar': "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_alive_died_less24_num_* {
			label variable `rgvar' "C17) How many children born since January 1, 2019 have died within 24 hours?"
			note `rgvar': "C17) How many children born since January 1, 2019 have died within 24 hours?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_alive_died_more24_* {
			label variable `rgvar' "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
			note `rgvar': "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_alive_died_more24_num_* {
			label variable `rgvar' "C19) How many children born since January 1, 2019 have died after 24 hours from "
			note `rgvar': "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"
		}
	}

	capture {
		foreach rgvar of varlist comb_name_child_* {
			label variable `rgvar' "C20) What is the full name of the child that died?"
			note `rgvar': "C20) What is the full name of the child that died?"
		}
	}

	capture {
		foreach rgvar of varlist comb_gen_child_* {
			label variable `rgvar' "What is the gender of the \${comb_name_child_earlier}?"
			note `rgvar': "What is the gender of the \${comb_name_child_earlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_fath_child_* {
			label variable `rgvar' "What is the name of \${comb_name_child_earlier}'s father?"
			note `rgvar': "What is the name of \${comb_name_child_earlier}'s father?"
		}
	}

	capture {
		foreach rgvar of varlist comb_age_child_* {
			label variable `rgvar' "C21) What was their age at the time of death? (select unit)"
			note `rgvar': "C21) What was their age at the time of death? (select unit)"
			label define `rgvar' 1 "Days" 2 "Months" 3 "Years" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_unit_child_days_* {
			label variable `rgvar' "Write in Days"
			note `rgvar': "Write in Days"
		}
	}

	capture {
		foreach rgvar of varlist comb_unit_child_months_* {
			label variable `rgvar' "Write in months"
			note `rgvar': "Write in months"
		}
	}

	capture {
		foreach rgvar of varlist comb_unit_child_years_* {
			label variable `rgvar' "Write in years"
			note `rgvar': "Write in years"
		}
	}

	capture {
		foreach rgvar of varlist comb_dob_date_cbw_* {
			label variable `rgvar' "Please select the date of birth"
			note `rgvar': "Please select the date of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_dob_month_cbw_* {
			label variable `rgvar' "Please select the month of birth"
			note `rgvar': "Please select the month of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_dob_year_cbw_* {
			label variable `rgvar' "Please select the year of birth"
			note `rgvar': "Please select the year of birth"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_dod_date_cbw_* {
			label variable `rgvar' "Please select the date of death"
			note `rgvar': "Please select the date of death"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_dod_month_cbw_* {
			label variable `rgvar' "Please select the month of death"
			note `rgvar': "Please select the month of death"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_dod_year_cbw_* {
			label variable `rgvar' "Please select the year of death"
			note `rgvar': "Please select the year of death"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_cause_death_* {
			label variable `rgvar' "C25) What did \${comb_name_child_earlier} die from?"
			note `rgvar': "C25) What did \${comb_name_child_earlier} die from?"
		}
	}

	capture {
		foreach rgvar of varlist comb_cause_death_oth_* {
			label variable `rgvar' "C25.1) Please specify other"
			note `rgvar': "C25.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist comb_cause_death_diagnosed_* {
			label variable `rgvar' "C26) Was this cause of death diagonsed by any health official?"
			note `rgvar': "C26) Was this cause of death diagonsed by any health official?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_cause_death_str_* {
			label variable `rgvar' "C27) In your own words, can you describe what was the cause of death?"
			note `rgvar': "C27) In your own words, can you describe what was the cause of death?"
		}
	}

	capture {
		foreach rgvar of varlist comb_confirm_* {
			label variable `rgvar' "Please confirm that \${comb_name_CBW_woman_earlier} had \${comb_child_living_num"
			note `rgvar': "Please confirm that \${comb_name_CBW_woman_earlier} had \${comb_child_living_num} children who were born since 1 January 2019 and living with them, \${comb_child_stillborn_num} still births and \${comb_child_died_lessmore_24_num} children who were born but later died. Is this information complete and correct?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_miscarriage_* {
			label variable `rgvar' "C28)Did you have a miscarriage during the pregnancy?"
			note `rgvar': "C28)Did you have a miscarriage during the pregnancy?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_correct_* {
			label variable `rgvar' "C29)Have you corrected respondent's details if they were incorrect earlier?"
			note `rgvar': "C29)Have you corrected respondent's details if they were incorrect earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_seek_care_cbw_* {
			label variable `rgvar' "In the past one month, did \${comb_name_CBW_woman_earlier} seek medical care?"
			note `rgvar': "In the past one month, did \${comb_name_CBW_woman_earlier} seek medical care?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_diarrhea_cbw_* {
			label variable `rgvar' "Previously \${comb_name_CBW_woman_earlier} said that she has diarrhea, and if \$"
			note `rgvar': "Previously \${comb_name_CBW_woman_earlier} said that she has diarrhea, and if \${comb_name_CBW_woman_earlier} did not mention that she took medical care for it. Please ask politely 'If \${comb_name_CBW_woman_earlier} had diarrhea in the last one month, then why she did not take medical care for it?'"
			label define `rgvar' 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_visits_cbw_* {
			label variable `rgvar' "How many visits \${comb_name_CBW_woman_earlier} did in the last one month to see"
			note `rgvar': "How many visits \${comb_name_CBW_woman_earlier} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_symp_cbw_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_symp_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_where_cbw_* {
			label variable `rgvar' "Where did \${comb_name_CBW_woman_earlier} seek care?"
			note `rgvar': "Where did \${comb_name_CBW_woman_earlier} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_where_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_nights_cbw_* {
			label variable `rgvar' "How many nights did \${comb_name_CBW_woman_earlier} spend in the hospital?"
			note `rgvar': "How many nights did \${comb_name_CBW_woman_earlier} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_out_home_cbw_* {
			label variable `rgvar' "Where did \${comb_name_CBW_woman_earlier} seek care?"
			note `rgvar': "Where did \${comb_name_CBW_woman_earlier} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_out_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_treat_type_cbw_* {
			label variable `rgvar' "What was the nature of treatment at \${comb_out_names_CBW} that \${comb_name_CBW"
			note `rgvar': "What was the nature of treatment at \${comb_out_names_CBW} that \${comb_name_CBW_woman_earlier} took?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_treat_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_trans_cbw_* {
			label variable `rgvar' "What was the mode of transportation taken by \${comb_name_CBW_woman_earlier} to "
			note `rgvar': "What was the mode of transportation taken by \${comb_name_CBW_woman_earlier} to travel to \${comb_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_cbw_* {
			label variable `rgvar' "How much time did \${comb_name_CBW_woman_earlier} to travel to \${comb_out_names"
			note `rgvar': "How much time did \${comb_name_CBW_woman_earlier} to travel to \${comb_out_names_CBW} to receive care?"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_mins_cbw_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_hrs_cbw_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_pay_trans_cbw_* {
			label variable `rgvar' "What did \${comb_name_CBW_woman_earlier} pay for the transportation to travel to"
			note `rgvar': "What did \${comb_name_CBW_woman_earlier} pay for the transportation to travel to \${comb_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_scheme_cbw_* {
			label variable `rgvar' "Was \${comb_name_CBW_woman_earlier} covered by any scheme for health expenditure"
			note `rgvar': "Was \${comb_name_CBW_woman_earlier} covered by any scheme for health expenditure support for the expenditure incurred at \${comb_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_doctor_fees_cbw_* {
			label variable `rgvar' "What did \${comb_name_CBW_woman_earlier} pay for the consultation/treatment (doc"
			note `rgvar': "What did \${comb_name_CBW_woman_earlier} pay for the consultation/treatment (doctor fees) at \${comb_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_illness_cbw_* {
			label variable `rgvar' "Did \${comb_name_CBW_woman_earlier} pay for anything else for this illness at \$"
			note `rgvar': "Did \${comb_name_CBW_woman_earlier} pay for anything else for this illness at \${comb_out_names_CBW}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_illness_other_cbw_* {
			label variable `rgvar' "What did \${comb_name_CBW_woman_earlier} pay for at \${comb_out_names_CBW}?"
			note `rgvar': "What did \${comb_name_CBW_woman_earlier} pay for at \${comb_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_otherpay_cbw_* {
			label variable `rgvar' "What amount did \${comb_name_CBW_woman_earlier} pay for \${comb_other_exp_CBW} a"
			note `rgvar': "What amount did \${comb_name_CBW_woman_earlier} pay for \${comb_other_exp_CBW} at \${comb_out_names_CBW} ?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_t_exp_cbw_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${comb_name_CBW_woman_ear"
			note `rgvar': "In the last one month, what was the total expenditure \${comb_name_CBW_woman_earlier} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_work_cbw_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${comb_name_CBW_woman_earlier} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_work_who_cbw_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${comb_name_CBW_woman_earlier}?"
			note `rgvar': "Who adjusted their schedule to take care of \${comb_name_CBW_woman_earlier}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_days_caretaking_cbw_* {
			label variable `rgvar' "How many days have this person taken caretaking \${comb_name_CBW_woman_earlier} "
			note `rgvar': "How many days have this person taken caretaking \${comb_name_CBW_woman_earlier} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist comb_translator_* {
			label variable `rgvar' "C30)Was a translator used in the survey?"
			note `rgvar': "C30)Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_hh_prsnt_* {
			label variable `rgvar' "Was there any Household member (other than the \${comb_name_CBW_woman_earlier}) "
			note `rgvar': "Was there any Household member (other than the \${comb_name_CBW_woman_earlier}) present during the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_resp_avail_cbw_* {
			label variable `rgvar' "C2) Did you find \${N_name_CBW_woman_earlier} to interview?"
			note `rgvar': "C2) Did you find \${N_name_CBW_woman_earlier} to interview?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 9 "Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_resp_avail_cbw_oth_* {
			label variable `rgvar' "B1.1) Please specify other"
			note `rgvar': "B1.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_cbw_consent_* {
			label variable `rgvar' "C3)Do I have your permission to proceed with the interview?"
			note `rgvar': "C3)Do I have your permission to proceed with the interview?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_no_consent_reason_* {
			label variable `rgvar' "C4) Can you tell me why you do not want to participate in the survey?"
			note `rgvar': "C4) Can you tell me why you do not want to participate in the survey?"
		}
	}

	capture {
		foreach rgvar of varlist n_no_consent_oth_* {
			label variable `rgvar' "C4.1) Please specify other"
			note `rgvar': "C4.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_no_consent_comment_* {
			label variable `rgvar' "C4.2) Record any relevant notes if the respondent refused the interview"
			note `rgvar': "C4.2) Record any relevant notes if the respondent refused the interview"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_status_* {
			label variable `rgvar' "Is \${N_name_CBW_woman_earlier} pregnant?"
			note `rgvar': "Is \${N_name_CBW_woman_earlier} pregnant?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_not_curr_preg_* {
			label variable `rgvar' "Was \${N_name_CBW_woman_earlier} pregnant in the last 7 months?"
			note `rgvar': "Was \${N_name_CBW_woman_earlier} pregnant in the last 7 months?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_month_* {
			label variable `rgvar' "Which month of \${N_name_CBW_woman_earlier}'s pregnancy is this?"
			note `rgvar': "Which month of \${N_name_CBW_woman_earlier}'s pregnancy is this?"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_delivery_* {
			label variable `rgvar' "What is the expected month of delivery of \${N_name_CBW_woman_earlier}?"
			note `rgvar': "What is the expected month of delivery of \${N_name_CBW_woman_earlier}?"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_hus_* {
			label variable `rgvar' "What is the name of \${N_name_CBW_woman_earlier}'s husband?"
			note `rgvar': "What is the name of \${N_name_CBW_woman_earlier}'s husband?"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_residence_* {
			label variable `rgvar' "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
			note `rgvar': "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_stay_* {
			label variable `rgvar' "How long is \${N_name_CBW_woman_earlier} planning to stay here (at the house whe"
			note `rgvar': "How long is \${N_name_CBW_woman_earlier} planning to stay here (at the house where the survey is being conducted) ?"
			label define `rgvar' 1 "Months" 2 "Days" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_stay_months_* {
			label variable `rgvar' "Record in months"
			note `rgvar': "Record in months"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_stay_days_* {
			label variable `rgvar' "Record in Days"
			note `rgvar': "Record in Days"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_current_village_* {
			label variable `rgvar' "Which village is \${N_name_CBW_woman_earlier} ’s current permanent residence in?"
			note `rgvar': "Which village is \${N_name_CBW_woman_earlier} ’s current permanent residence in?"
			label define `rgvar' 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30601 "Hatikhamba" 30602 "Mukundpur" 30701 "Gopi Kankubadi" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 50601 "Badaalubadi" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_current_village_oth_* {
			label variable `rgvar' "C6.1) Please specify other"
			note `rgvar': "C6.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_vill_residence_* {
			label variable `rgvar' "C8) Was \${village_name_res}\${N_name_CBW_woman_earlier}'s permanent residence a"
			note `rgvar': "C8) Was \${village_name_res}\${N_name_CBW_woman_earlier}'s permanent residence at any time in the last 5 years?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_get_rch_* {
			label variable `rgvar' "Did \${N_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a "
			note `rgvar': "Did \${N_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a registration card/number (RCH ID)?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_get_rch_confirm_* {
			label variable `rgvar' "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${"
			note `rgvar': "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${N_name_CBW_woman_earlier} has received an RCH ID?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_preg_rch_id_* {
			label variable `rgvar' "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}"
			note `rgvar': "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}"
		}
	}

	capture {
		foreach rgvar of varlist n_preg_rch_id_inc_* {
			label variable `rgvar' "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}. Write the RCH ID he"
			note `rgvar': "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}. Write the RCH ID here only if some of the digits are missing or extra from the booklet shown by the respondent. The correct RCH ID will have exactly 12 digits so if that is not the case with this ID mention here."
		}
	}

	capture {
		foreach rgvar of varlist n_wom_vomit_day_* {
			label variable `rgvar' "A22) Did \${N_name_CBW_woman_earlier} vomit today or yesterday?"
			note `rgvar': "A22) Did \${N_name_CBW_woman_earlier} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_vomit_wk_* {
			label variable `rgvar' "A22.1) Did \${N_name_CBW_woman_earlier} vomit in the last 7 days?"
			note `rgvar': "A22.1) Did \${N_name_CBW_woman_earlier} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_vomit_2wk_* {
			label variable `rgvar' "A22.2) Did \${N_name_CBW_woman_earlier} vomit in the past 2 weeks?"
			note `rgvar': "A22.2) Did \${N_name_CBW_woman_earlier} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_diarr_day_* {
			label variable `rgvar' "A23) Did \${N_name_CBW_woman_earlier} have diarrhea today or yesterday?"
			note `rgvar': "A23) Did \${N_name_CBW_woman_earlier} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_diarr_wk_* {
			label variable `rgvar' "A23.1) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
			note `rgvar': "A23.1) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_diarr_2wk_* {
			label variable `rgvar' "A23.2) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
			note `rgvar': "A23.2) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_diarr_num_wk_* {
			label variable `rgvar' "A24.1) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past "
			note `rgvar': "A24.1) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
		}
	}

	capture {
		foreach rgvar of varlist n_wom_diarr_num_2wks_* {
			label variable `rgvar' "A24.2) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past "
			note `rgvar': "A24.2) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
		}
	}

	capture {
		foreach rgvar of varlist n_wom_stool_24h_* {
			label variable `rgvar' "A25) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools with"
			note `rgvar': "A25) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_stool_yest_* {
			label variable `rgvar' "A25.1) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools ye"
			note `rgvar': "A25.1) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_stool_wk_* {
			label variable `rgvar' "A25.2) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in"
			note `rgvar': "A25.2) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_stool_2wk_* {
			label variable `rgvar' "A25.3) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in"
			note `rgvar': "A25.3) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_blood_day_* {
			label variable `rgvar' "A26) Did \${N_name_CBW_woman_earlier} have blood in her stool today or yesterday"
			note `rgvar': "A26) Did \${N_name_CBW_woman_earlier} have blood in her stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_blood_wk_* {
			label variable `rgvar' "A26.1) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 7 da"
			note `rgvar': "A26.1) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_blood_2wk_* {
			label variable `rgvar' "A26.2) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 2 we"
			note `rgvar': "A26.2) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_cuts_day_* {
			label variable `rgvar' "A21) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today "
			note `rgvar': "A21) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_cuts_wk_* {
			label variable `rgvar' "A21.1) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in t"
			note `rgvar': "A21.1) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_wom_cuts_2wk_* {
			label variable `rgvar' "A21.2) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in t"
			note `rgvar': "A21.2) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_wk_* {
			label variable `rgvar' "In the last week, has \${N_name_CBW_woman_earlier} taken antibiotics?"
			note `rgvar': "In the last week, has \${N_name_CBW_woman_earlier} taken antibiotics?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_days_* {
			label variable `rgvar' "How many days ago did \${N_name_CBW_woman_earlier} take antibiotics?"
			note `rgvar': "How many days ago did \${N_name_CBW_woman_earlier} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_last_* {
			label variable `rgvar' "How long ago did \${N_name_CBW_woman_earlier} last take antibiotics?"
			note `rgvar': "How long ago did \${N_name_CBW_woman_earlier} last take antibiotics?"
			label define `rgvar' 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_last_months_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_last_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_purpose_* {
			label variable `rgvar' "For what purpose did you take antibiotics?"
			note `rgvar': "For what purpose did you take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_preg_purpose_oth_* {
			label variable `rgvar' "Please specify others"
			note `rgvar': "Please specify others"
		}
	}

	capture {
		foreach rgvar of varlist n_last_5_years_pregnant_* {
			label variable `rgvar' "C9)Has \${N_name_CBW_woman_earlier} ever been pregnant in the last 5 years since"
			note `rgvar': "C9)Has \${N_name_CBW_woman_earlier} ever been pregnant in the last 5 years since January 1, 2019?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_living_* {
			label variable `rgvar' "C10) Do you have any children under 5 years of age to whom you have given birth "
			note `rgvar': "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_living_num_* {
			label variable `rgvar' "C11) How many children born since January 1, 2019 live with you?"
			note `rgvar': "C11) How many children born since January 1, 2019 live with you?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_notliving_* {
			label variable `rgvar' "C12) Do you have any children born since January 1, 2019 to whom you have given "
			note `rgvar': "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_notliving_num_* {
			label variable `rgvar' "C13) How many children born since January 1, 2019 are alive but do not live with"
			note `rgvar': "C13) How many children born since January 1, 2019 are alive but do not live with you?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_stillborn_* {
			label variable `rgvar' "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
			note `rgvar': "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_stillborn_num_* {
			label variable `rgvar' "C15) How many children born since January 1, 2019 were stillborn?"
			note `rgvar': "C15) How many children born since January 1, 2019 were stillborn?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_alive_died_less24_* {
			label variable `rgvar' "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
			note `rgvar': "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_alive_died_less24_num_* {
			label variable `rgvar' "C17) How many children born since January 1, 2019 have died within 24 hours?"
			note `rgvar': "C17) How many children born since January 1, 2019 have died within 24 hours?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_alive_died_more24_* {
			label variable `rgvar' "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
			note `rgvar': "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_alive_died_more24_num_* {
			label variable `rgvar' "C19) How many children born since January 1, 2019 have died after 24 hours from "
			note `rgvar': "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"
		}
	}

	capture {
		foreach rgvar of varlist n_name_child_* {
			label variable `rgvar' "C20) What is the full name of the child that died?"
			note `rgvar': "C20) What is the full name of the child that died?"
		}
	}

	capture {
		foreach rgvar of varlist n_gen_child_* {
			label variable `rgvar' "What is the gender of the \${N_name_child_earlier}?"
			note `rgvar': "What is the gender of the \${N_name_child_earlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_fath_child_* {
			label variable `rgvar' "What is the name of \${N_name_child_earlier}'s father?"
			note `rgvar': "What is the name of \${N_name_child_earlier}'s father?"
		}
	}

	capture {
		foreach rgvar of varlist n_age_child_* {
			label variable `rgvar' "C21) What was their age at the time of death? (select unit)"
			note `rgvar': "C21) What was their age at the time of death? (select unit)"
			label define `rgvar' 1 "Days" 2 "Months" 3 "Years" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_unit_child_days_* {
			label variable `rgvar' "Write in Days"
			note `rgvar': "Write in Days"
		}
	}

	capture {
		foreach rgvar of varlist n_unit_child_months_* {
			label variable `rgvar' "Write in months"
			note `rgvar': "Write in months"
		}
	}

	capture {
		foreach rgvar of varlist n_unit_child_years_* {
			label variable `rgvar' "Write in years"
			note `rgvar': "Write in years"
		}
	}

	capture {
		foreach rgvar of varlist n_dob_date_cbw_* {
			label variable `rgvar' "Please select the date of birth"
			note `rgvar': "Please select the date of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dob_month_cbw_* {
			label variable `rgvar' "Please select the month of birth"
			note `rgvar': "Please select the month of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dob_year_cbw_* {
			label variable `rgvar' "Please select the year of birth"
			note `rgvar': "Please select the year of birth"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dod_date_cbw_* {
			label variable `rgvar' "Please select the date of death"
			note `rgvar': "Please select the date of death"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dod_month_cbw_* {
			label variable `rgvar' "Please select the month of death"
			note `rgvar': "Please select the month of death"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_dod_year_cbw_* {
			label variable `rgvar' "Please select the year of death"
			note `rgvar': "Please select the year of death"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_cause_death_* {
			label variable `rgvar' "C25) What did \${N_name_child_earlier} die from?"
			note `rgvar': "C25) What did \${N_name_child_earlier} die from?"
		}
	}

	capture {
		foreach rgvar of varlist n_cause_death_oth_* {
			label variable `rgvar' "C25.1) Please specify other"
			note `rgvar': "C25.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_cause_death_diagnosed_* {
			label variable `rgvar' "C26) Was this cause of death diagonsed by any health official?"
			note `rgvar': "C26) Was this cause of death diagonsed by any health official?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_cause_death_str_* {
			label variable `rgvar' "C27) In your own words, can you describe what was the cause of death?"
			note `rgvar': "C27) In your own words, can you describe what was the cause of death?"
		}
	}

	capture {
		foreach rgvar of varlist n_confirm_* {
			label variable `rgvar' "Please confirm that \${N_name_CBW_woman_earlier} had \${N_child_living_num} chil"
			note `rgvar': "Please confirm that \${N_name_CBW_woman_earlier} had \${N_child_living_num} children who were born since 1 January 2019 and living with them, \${N_child_stillborn_num} still births and \${N_child_died_lessmore_24_num} children who were born but later died. Is this information complete and correct?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_miscarriage_* {
			label variable `rgvar' "Did you have a miscarriage during the pregnancy?"
			note `rgvar': "Did you have a miscarriage during the pregnancy?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_correct_* {
			label variable `rgvar' "C28)Have you corrected respondent's details if they were incorrect earlier?"
			note `rgvar': "C28)Have you corrected respondent's details if they were incorrect earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_seek_care_cbw_* {
			label variable `rgvar' "In the past one month, did \${N_name_CBW_woman_earlier} seek medical care?"
			note `rgvar': "In the past one month, did \${N_name_CBW_woman_earlier} seek medical care?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_diarrhea_cbw_* {
			label variable `rgvar' "Previously \${N_name_CBW_woman_earlier} said that she has diarrhea, and if \${N_"
			note `rgvar': "Previously \${N_name_CBW_woman_earlier} said that she has diarrhea, and if \${N_name_CBW_woman_earlier} did not mention that she took medical care for it. Please ask politely 'If \${N_name_CBW_woman_earlier} had diarrhea in the last one month, then why she did not take medical care for it?'"
			label define `rgvar' 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_visits_cbw_* {
			label variable `rgvar' "How many visits \${N_name_CBW_woman_earlier} did in the last one month to seek m"
			note `rgvar': "How many visits \${N_name_CBW_woman_earlier} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_cbw_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_cbw_* {
			label variable `rgvar' "Where did \${N_name_CBW_woman_earlier} seek care?"
			note `rgvar': "Where did \${N_name_CBW_woman_earlier} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_nights_cbw_* {
			label variable `rgvar' "How many nights did \${N_name_CBW_woman_earlier} spend in the hospital?"
			note `rgvar': "How many nights did \${N_name_CBW_woman_earlier} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_home_cbw_* {
			label variable `rgvar' "Where did \${N_name_CBW_woman_earlier} seek care?"
			note `rgvar': "Where did \${N_name_CBW_woman_earlier} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_type_cbw_* {
			label variable `rgvar' "What was the nature of treatment at \${N_out_names_CBW} that \${N_name_CBW_woman"
			note `rgvar': "What was the nature of treatment at \${N_out_names_CBW} that \${N_name_CBW_woman_earlier} took?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_oth_cbw_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_trans_cbw_* {
			label variable `rgvar' "What was the mode of transportation taken by \${N_name_CBW_woman_earlier} to tra"
			note `rgvar': "What was the mode of transportation taken by \${N_name_CBW_woman_earlier} to travel to \${N_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_cbw_* {
			label variable `rgvar' "How much time did \${N_name_CBW_woman_earlier} to travel to \${N_out_names_CBW} "
			note `rgvar': "How much time did \${N_name_CBW_woman_earlier} to travel to \${N_out_names_CBW} to receive care?"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_mins_cbw_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_hrs_cbw_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist n_med_pay_trans_cbw_* {
			label variable `rgvar' "What did \${N_name_CBW_woman_earlier} pay for the transportation to travel to \$"
			note `rgvar': "What did \${N_name_CBW_woman_earlier} pay for the transportation to travel to \${N_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_scheme_cbw_* {
			label variable `rgvar' "Was \${N_name_CBW_woman_earlier} covered by any scheme for health expenditure su"
			note `rgvar': "Was \${N_name_CBW_woman_earlier} covered by any scheme for health expenditure support for the expenditure incurred at \${N_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_doctor_fees_cbw_* {
			label variable `rgvar' "What did \${N_name_CBW_woman_earlier} pay for the consultation/treatment (doctor"
			note `rgvar': "What did \${N_name_CBW_woman_earlier} pay for the consultation/treatment (doctor fees) at \${N_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_cbw_* {
			label variable `rgvar' "Did \${N_name_CBW_woman_earlier} pay for anything else for this illness at \${N_"
			note `rgvar': "Did \${N_name_CBW_woman_earlier} pay for anything else for this illness at \${N_out_names_CBW}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_other_cbw_* {
			label variable `rgvar' "What did \${N_name_CBW_woman_earlier} pay for at \${N_out_names_CBW}?"
			note `rgvar': "What did \${N_name_CBW_woman_earlier} pay for at \${N_out_names_CBW}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_otherpay_cbw_* {
			label variable `rgvar' "What amount did \${N_name_CBW_woman_earlier} pay for \${N_other_exp_CBW} at \${N"
			note `rgvar': "What amount did \${N_name_CBW_woman_earlier} pay for \${N_other_exp_CBW} at \${N_out_names_CBW} ?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_t_exp_cbw_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${N_name_CBW_woman_earlie"
			note `rgvar': "In the last one month, what was the total expenditure \${N_name_CBW_woman_earlier} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_cbw_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${N_name_CBW_woman_earlier} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_who_cbw_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${N_name_CBW_woman_earlier}?"
			note `rgvar': "Who adjusted their schedule to take care of \${N_name_CBW_woman_earlier}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_days_caretaking_cbw_* {
			label variable `rgvar' "How many days have this person taken caretaking \${N_name_CBW_woman_earlier} (in"
			note `rgvar': "How many days have this person taken caretaking \${N_name_CBW_woman_earlier} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist n_translator_* {
			label variable `rgvar' "C29)Was a translator used in the survey?"
			note `rgvar': "C29)Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_hh_prsnt_* {
			label variable `rgvar' "Was there any Household member (other than the \${N_name_CBW_woman_earlier}) pre"
			note `rgvar': "Was there any Household member (other than the \${N_name_CBW_woman_earlier}) present during the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_caregiver_present_* {
			label variable `rgvar' "Is the caregiver/mother (\${comb_main_caregiver_label}) of \${comb_child_u5_name"
			note `rgvar': "Is the caregiver/mother (\${comb_main_caregiver_label}) of \${comb_child_u5_name_label} available ?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 7 "U5 died or is no longer a member of the household" 8 "U5 child no longer falls in the criteria (less than 5 years)" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_care_pres_oth_* {
			label variable `rgvar' "B1.1) Please specify other"
			note `rgvar': "B1.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_age_v_* {
			label variable `rgvar' "Did you verify \${comb_child_u5_name_label} age with adhaar card or any other of"
			note `rgvar': "Did you verify \${comb_child_u5_name_label} age with adhaar card or any other official identity document ?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_act_age_* {
			label variable `rgvar' "What is the actual age of \${comb_child_u5_name_label}?"
			note `rgvar': "What is the actual age of \${comb_child_u5_name_label}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_caregiver_name_* {
			label variable `rgvar' "Who is the caregiver/mother of \${comb_child_u5_name_label}?"
			note `rgvar': "Who is the caregiver/mother of \${comb_child_u5_name_label}?"
			label define `rgvar' 1 "\${R_Cen_fam_name1}" 2 "\${R_Cen_fam_name2}" 3 "\${R_Cen_fam_name3}" 4 "\${R_Cen_fam_name4}" 5 "\${R_Cen_fam_name5}" 6 "\${R_Cen_fam_name6}" 7 "\${R_Cen_fam_name7}" 8 "\${R_Cen_fam_name8}" 9 "\${R_Cen_fam_name9}" 10 "\${R_Cen_fam_name10}" 11 "\${R_Cen_fam_name11}" 12 "\${R_Cen_fam_name12}" 13 "\${R_Cen_fam_name13}" 14 "\${R_Cen_fam_name14}" 15 "\${R_Cen_fam_name15}" 16 "\${R_Cen_fam_name16}" 17 "\${R_Cen_fam_name17}" 18 "\${R_Cen_fam_name18}" 19 "\${R_Cen_fam_name19}" 20 "\${R_Cen_fam_name20}" 21 "\${comb_hhmember_name1}" 22 "\${comb_hhmember_name2}" 23 "\${comb_hhmember_name3}" 24 "\${comb_hhmember_name4}" 25 "\${comb_hhmember_name5}" 26 "\${comb_hhmember_name6}" 27 "\${comb_hhmember_name7}"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_residence_* {
			label variable `rgvar' "Is this \${comb_child_u5_name_label}'s usual residence?"
			note `rgvar': "Is this \${comb_child_u5_name_label}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_name_* {
			label variable `rgvar' "If \${comb_child_u5_name_label} is a new baby, please write their actual name."
			note `rgvar': "If \${comb_child_u5_name_label} is a new baby, please write their actual name."
		}
	}

	capture {
		foreach rgvar of varlist comb_child_u5_relation_* {
			label variable `rgvar' "What is \${comb_child_u5_caregiver_label}'s relationship with \${comb_child_u5_n"
			note `rgvar': "What is \${comb_child_u5_caregiver_label}'s relationship with \${comb_child_u5_name_label}?"
			label define `rgvar' 1 "Mother" 2 "Grandmother" 3 "Aunt" 4 "Uncle" 5 "Father" 6 "Grandfather" 7 "Sister" 8 "Brother" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_u5_relation_oth_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_care_dia_day_* {
			label variable `rgvar' "Did \${comb_child_u5_caregiver_label} have diarrhea today or yesterday?"
			note `rgvar': "Did \${comb_child_u5_caregiver_label} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_care_dia_wk_* {
			label variable `rgvar' "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 7 days?"
			note `rgvar': "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_care_dia_2wk_* {
			label variable `rgvar' "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
			note `rgvar': "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_age_* {
			label variable `rgvar' "What is \${comb_child_u5_name_label} age in years?"
			note `rgvar': "What is \${comb_child_u5_name_label} age in years?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_breastfeeding_* {
			label variable `rgvar' "Was OR Is \${comb_child_u5_name_label} (being) exclusively breastfed (not drinki"
			note `rgvar': "Was OR Is \${comb_child_u5_name_label} (being) exclusively breastfed (not drinking any water)?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_breastfed_num_* {
			label variable `rgvar' "A45.1) Up to which months was \${comb_child_u5_name_label} exclusively breastfed"
			note `rgvar': "A45.1) Up to which months was \${comb_child_u5_name_label} exclusively breastfed?"
			label define `rgvar' 1 "Months" 2 "Days" 888 "Child is still being breastfed (mother's milk)" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_breastfed_month_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_breastfed_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_vomit_day_* {
			label variable `rgvar' "A28) Did \${comb_child_u5_name_label} vomit today or yesterday?"
			note `rgvar': "A28) Did \${comb_child_u5_name_label} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_vomit_wk_* {
			label variable `rgvar' "A28.1) Did \${comb_child_u5_name_label} vomit in the last 7 days?"
			note `rgvar': "A28.1) Did \${comb_child_u5_name_label} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_vomit_2wk_* {
			label variable `rgvar' "A28.2) Did \${comb_child_u5_name_label} vomit in the past 2 weeks?"
			note `rgvar': "A28.2) Did \${comb_child_u5_name_label} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_day_* {
			label variable `rgvar' "A29) Did \${comb_child_u5_name_label} have diarrhea today or yesterday?"
			note `rgvar': "A29) Did \${comb_child_u5_name_label} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_wk_* {
			label variable `rgvar' "A29.1) Did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"
			note `rgvar': "A29.1) Did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_2wk_* {
			label variable `rgvar' "A29.2) Did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"
			note `rgvar': "A29.2) Did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_wk_num_* {
			label variable `rgvar' "A30.1) How many days did \${comb_child_u5_name_label} have diarrhea in the past "
			note `rgvar': "A30.1) How many days did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_2wk_num_* {
			label variable `rgvar' "A30.2) How many days did \${comb_child_u5_name_label} have diarrhea in the past "
			note `rgvar': "A30.2) How many days did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_diarr_freq_* {
			label variable `rgvar' "A30.3) What was the highest number of stools in a 24-hour period?"
			note `rgvar': "A30.3) What was the highest number of stools in a 24-hour period?"
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stool_24h_* {
			label variable `rgvar' "A31) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools with"
			note `rgvar': "A31) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stool_yest_* {
			label variable `rgvar' "A31.1) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools ye"
			note `rgvar': "A31.1) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stool_wk_* {
			label variable `rgvar' "A31.2) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in"
			note `rgvar': "A31.2) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in a 24-hour period in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_stool_2wk_* {
			label variable `rgvar' "A31.3) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in"
			note `rgvar': "A31.3) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in a 24 hour period in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_blood_day_* {
			label variable `rgvar' "A32) Did \${comb_child_u5_name_label} have blood in the stool today or yesterday"
			note `rgvar': "A32) Did \${comb_child_u5_name_label} have blood in the stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_blood_wk_* {
			label variable `rgvar' "A32.1) Did \${comb_child_u5_name_label} have blood in the stool in the past 7 da"
			note `rgvar': "A32.1) Did \${comb_child_u5_name_label} have blood in the stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_blood_2wk_* {
			label variable `rgvar' "A32.2) Did \${comb_child_u5_name_label} have blood in the stool in the past 2 we"
			note `rgvar': "A32.2) Did \${comb_child_u5_name_label} have blood in the stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_cuts_day_* {
			label variable `rgvar' "A27) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts today "
			note `rgvar': "A27) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_cuts_wk_* {
			label variable `rgvar' "A27.1) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in t"
			note `rgvar': "A27.1) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_child_cuts_2wk_* {
			label variable `rgvar' "A27.2) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in t"
			note `rgvar': "A27.2) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_wk_* {
			label variable `rgvar' "In the last week, has \${comb_child_u5_name_label} taken antibiotics?"
			note `rgvar': "In the last week, has \${comb_child_u5_name_label} taken antibiotics?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_days_* {
			label variable `rgvar' "In the last week, How many days ago did \${comb_child_u5_name_label} take antibi"
			note `rgvar': "In the last week, How many days ago did \${comb_child_u5_name_label} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_last_* {
			label variable `rgvar' "How long ago did \${comb_child_u5_name_label} last take antibiotics?"
			note `rgvar': "How long ago did \${comb_child_u5_name_label} last take antibiotics?"
			label define `rgvar' 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_last_months_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_last_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_purpose_* {
			label variable `rgvar' "For what purpose did \${comb_child_u5_name_label} take antibiotics?"
			note `rgvar': "For what purpose did \${comb_child_u5_name_label} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist comb_anti_child_purpose_oth_* {
			label variable `rgvar' "Please specify others"
			note `rgvar': "Please specify others"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_seek_care_u5_* {
			label variable `rgvar' "In the past one month, did \${comb_child_u5_name_label} seek medical care?"
			note `rgvar': "In the past one month, did \${comb_child_u5_name_label} seek medical care?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_diarrhea_u5_* {
			label variable `rgvar' "Previously \${comb_child_u5_name_label} said that she has diarrhea, and if \${co"
			note `rgvar': "Previously \${comb_child_u5_name_label} said that she has diarrhea, and if \${comb_child_u5_name_label} did not mention that she took medical care for it. Please ask politely 'If \${comb_child_u5_name_label} had diarrhea in the last one month, then why she did not take medical care for it?'"
			label define `rgvar' 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_visits_u5_* {
			label variable `rgvar' "How many visits \${comb_child_u5_name_label} did in the last one month to seek m"
			note `rgvar': "How many visits \${comb_child_u5_name_label} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_symp_u5_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_symp_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_where_u5_* {
			label variable `rgvar' "Where did \${comb_child_u5_name_label} seek care?"
			note `rgvar': "Where did \${comb_child_u5_name_label} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_where_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_nights_u5_* {
			label variable `rgvar' "How many nights did \${comb_child_u5_name_label} spend in the hospital?"
			note `rgvar': "How many nights did \${comb_child_u5_name_label} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_out_home_u5_* {
			label variable `rgvar' "Where did \${comb_child_u5_name_label} seek care?"
			note `rgvar': "Where did \${comb_child_u5_name_label} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_out_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_treat_type_u5_* {
			label variable `rgvar' "What was the nature of treatment at \${comb_out_names_U5} that \${comb_child_u5_"
			note `rgvar': "What was the nature of treatment at \${comb_out_names_U5} that \${comb_child_u5_name_label} took?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_treat_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_trans_u5_* {
			label variable `rgvar' "What was the mode of transportation taken by \${comb_child_u5_name_label} to tra"
			note `rgvar': "What was the mode of transportation taken by \${comb_child_u5_name_label} to travel to \${comb_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_u5_* {
			label variable `rgvar' "How much time did \${comb_child_u5_name_label} to travel to \${comb_out_names_U5"
			note `rgvar': "How much time did \${comb_child_u5_name_label} to travel to \${comb_out_names_U5} to receive care?"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_mins_u5_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_time_hrs_u5_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_pay_trans_u5_* {
			label variable `rgvar' "What did \${comb_child_u5_name_label} pay for the transportation to travel to \$"
			note `rgvar': "What did \${comb_child_u5_name_label} pay for the transportation to travel to \${comb_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_scheme_u5_* {
			label variable `rgvar' "Was \${comb_child_u5_name_label} covered by any scheme for health expenditure su"
			note `rgvar': "Was \${comb_child_u5_name_label} covered by any scheme for health expenditure support for the expenditure incurred at \${comb_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_doctor_fees_u5_* {
			label variable `rgvar' "What did \${comb_child_u5_name_label} pay for the consultation/treatment (doctor"
			note `rgvar': "What did \${comb_child_u5_name_label} pay for the consultation/treatment (doctor fees) at \${comb_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_illness_u5_* {
			label variable `rgvar' "Did \${comb_child_u5_name_label} pay for anything else for this illness at \${co"
			note `rgvar': "Did \${comb_child_u5_name_label} pay for anything else for this illness at \${comb_out_names_U5}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_illness_other_u5_* {
			label variable `rgvar' "What did \${comb_child_u5_name_label} pay for at \${comb_out_names_U5}?"
			note `rgvar': "What did \${comb_child_u5_name_label} pay for at \${comb_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_otherpay_u5_* {
			label variable `rgvar' "What amount did \${comb_child_u5_name_label} pay for \${comb_other_exp_U5} at \$"
			note `rgvar': "What amount did \${comb_child_u5_name_label} pay for \${comb_other_exp_U5} at \${comb_out_names_U5} ?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_t_exp_u5_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${comb_child_u5_name_labe"
			note `rgvar': "In the last one month, what was the total expenditure \${comb_child_u5_name_label} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_work_u5_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${comb_child_u5_name_label} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_med_work_who_u5_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${comb_child_u5_name_label}?"
			note `rgvar': "Who adjusted their schedule to take care of \${comb_child_u5_name_label}?"
		}
	}

	capture {
		foreach rgvar of varlist comb_med_days_caretaking_u5_* {
			label variable `rgvar' "How many days have this person taken caretaking \${comb_child_u5_name_label} (in"
			note `rgvar': "How many days have this person taken caretaking \${comb_child_u5_name_label} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist comb_translator_u5_* {
			label variable `rgvar' "C29)Was a translator used in the survey?"
			note `rgvar': "C29)Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist comb_hh_prsnt_u5_* {
			label variable `rgvar' "Was there any Household member (other than the \${comb_child_u5_name_label}) pre"
			note `rgvar': "Was there any Household member (other than the \${comb_child_u5_name_label}) present during the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_caregiver_present_* {
			label variable `rgvar' "Is the caregiver/mother of \${N_child_u5_name_label} available?"
			note `rgvar': "Is the caregiver/mother of \${N_child_u5_name_label} available?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 9 "Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_care_pres_oth_* {
			label variable `rgvar' "B1.1) Please specify other"
			note `rgvar': "B1.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist n_child_caregiver_name_* {
			label variable `rgvar' "Who is the caregiver/mother of \${N_child_u5_name_label}?"
			note `rgvar': "Who is the caregiver/mother of \${N_child_u5_name_label}?"
			label define `rgvar' 1 "\${R_Cen_fam_name1}" 2 "\${R_Cen_fam_name2}" 3 "\${R_Cen_fam_name3}" 4 "\${R_Cen_fam_name4}" 5 "\${R_Cen_fam_name5}" 6 "\${R_Cen_fam_name6}" 7 "\${R_Cen_fam_name7}" 8 "\${R_Cen_fam_name8}" 9 "\${R_Cen_fam_name9}" 10 "\${R_Cen_fam_name10}" 11 "\${R_Cen_fam_name11}" 12 "\${R_Cen_fam_name12}" 13 "\${R_Cen_fam_name13}" 14 "\${R_Cen_fam_name14}" 15 "\${R_Cen_fam_name15}" 16 "\${R_Cen_fam_name16}" 17 "\${R_Cen_fam_name17}" 18 "\${R_Cen_fam_name18}" 19 "\${R_Cen_fam_name19}" 20 "\${R_Cen_fam_name20}" 21 "\${N_fam_name1}" 22 "\${N_fam_name2}" 23 "\${N_fam_name3}" 24 "\${N_fam_name4}" 25 "\${N_fam_name5}" 26 "\${N_fam_name6}" 27 "\${N_fam_name7}" 28 "\${N_fam_name8}" 29 "\${N_fam_name9}" 30 "\${N_fam_name10}" 31 "\${N_fam_name11}" 32 "\${N_fam_name12}" 33 "\${N_fam_name13}" 34 "\${N_fam_name14}" 35 "\${N_fam_name15}" 36 "\${N_fam_name16}" 37 "\${N_fam_name17}" 38 "\${N_fam_name18}" 39 "\${N_fam_name19}" 40 "\${N_fam_name20}"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_residence_* {
			label variable `rgvar' "Is this \${N_child_u5_name_label}'s usual residence?"
			note `rgvar': "Is this \${N_child_u5_name_label}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_u5_relation_* {
			label variable `rgvar' "What is \${N_child_u5_caregiver_label}'s relationship with \${N_child_u5_name_la"
			note `rgvar': "What is \${N_child_u5_caregiver_label}'s relationship with \${N_child_u5_name_label}?"
			label define `rgvar' 1 "Mother" 2 "Grandmother" 3 "Aunt" 4 "Uncle" 5 "Father" 6 "Grandfather" 7 "Sister" 8 "Brother" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_u5_relation_oth_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_child_care_dia_day_* {
			label variable `rgvar' "Did \${N_child_u5_caregiver_label} have diarrhea today or yesterday?"
			note `rgvar': "Did \${N_child_u5_caregiver_label} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_care_dia_wk_* {
			label variable `rgvar' "Did \${N_child_u5_caregiver_label} have diarrhea in the past 7 days?"
			note `rgvar': "Did \${N_child_u5_caregiver_label} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_care_dia_2wk_* {
			label variable `rgvar' "Did \${N_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
			note `rgvar': "Did \${N_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_breastfeeding_* {
			label variable `rgvar' "Was OR Is \${N_child_u5_name_label} (being) exclusively breastfed (not drinking "
			note `rgvar': "Was OR Is \${N_child_u5_name_label} (being) exclusively breastfed (not drinking any water)?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_breastfed_num_* {
			label variable `rgvar' "A45.1) Up to which months was \${N_child_u5_name_label} exclusively breastfed?"
			note `rgvar': "A45.1) Up to which months was \${N_child_u5_name_label} exclusively breastfed?"
			label define `rgvar' 1 "Months" 2 "Days" 888 "Child is still being breastfed (mother's milk)" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_breastfed_month_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist n_child_breastfed_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist n_child_vomit_day_* {
			label variable `rgvar' "A28) Did \${N_child_u5_name_label} vomit today or yesterday?"
			note `rgvar': "A28) Did \${N_child_u5_name_label} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_vomit_wk_* {
			label variable `rgvar' "A28.1) Did \${N_child_u5_name_label} vomit in the last 7 days?"
			note `rgvar': "A28.1) Did \${N_child_u5_name_label} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_vomit_2wk_* {
			label variable `rgvar' "A28.2) Did \${N_child_u5_name_label} vomit in the past 2 weeks?"
			note `rgvar': "A28.2) Did \${N_child_u5_name_label} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_day_* {
			label variable `rgvar' "A29) Did \${N_child_u5_name_label} have diarrhea today or yesterday?"
			note `rgvar': "A29) Did \${N_child_u5_name_label} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_wk_* {
			label variable `rgvar' "A29.1) Did \${N_child_u5_name_label} have diarrhea in the past 7 days?"
			note `rgvar': "A29.1) Did \${N_child_u5_name_label} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_2wk_* {
			label variable `rgvar' "A29.2) Did \${N_child_u5_name_label} have diarrhea in the past 2 weeks?"
			note `rgvar': "A29.2) Did \${N_child_u5_name_label} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_wk_num_* {
			label variable `rgvar' "A30.1) How many days did \${N_child_u5_name_label} have diarrhea in the past 7 d"
			note `rgvar': "A30.1) How many days did \${N_child_u5_name_label} have diarrhea in the past 7 days?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_2wk_num_* {
			label variable `rgvar' "A30.2) How many days did \${N_child_u5_name_label} have diarrhea in the past 2 w"
			note `rgvar': "A30.2) How many days did \${N_child_u5_name_label} have diarrhea in the past 2 weeks?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_diarr_freq_* {
			label variable `rgvar' "A30.3) What was the highest number of stools in a 24-hour period?"
			note `rgvar': "A30.3) What was the highest number of stools in a 24-hour period?"
		}
	}

	capture {
		foreach rgvar of varlist n_child_stool_24h_* {
			label variable `rgvar' "A31) Did \${N_child_u5_name_label} have 3 or more loose or watery stools within "
			note `rgvar': "A31) Did \${N_child_u5_name_label} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_stool_yest_* {
			label variable `rgvar' "A31.1) Did \${N_child_u5_name_label} have 3 or more loose or watery stools yeste"
			note `rgvar': "A31.1) Did \${N_child_u5_name_label} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_stool_wk_* {
			label variable `rgvar' "A31.2) Did \${N_child_u5_name_label} have 3 or more loose or watery stools in a "
			note `rgvar': "A31.2) Did \${N_child_u5_name_label} have 3 or more loose or watery stools in a 24-hour period in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_stool_2wk_* {
			label variable `rgvar' "A31.3) Did \${N_child_u5_name_label} have 3 or more loose or watery stools in a "
			note `rgvar': "A31.3) Did \${N_child_u5_name_label} have 3 or more loose or watery stools in a 24 hour period in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_blood_day_* {
			label variable `rgvar' "A32) Did \${N_child_u5_name_label} have blood in the stool today or yesterday?"
			note `rgvar': "A32) Did \${N_child_u5_name_label} have blood in the stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_blood_wk_* {
			label variable `rgvar' "A32.1) Did \${N_child_u5_name_label} have blood in the stool in the past 7 days?"
			note `rgvar': "A32.1) Did \${N_child_u5_name_label} have blood in the stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_blood_2wk_* {
			label variable `rgvar' "A32.2) Did \${N_child_u5_name_label} have blood in the stool in the past 2 weeks"
			note `rgvar': "A32.2) Did \${N_child_u5_name_label} have blood in the stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_cuts_day_* {
			label variable `rgvar' "A27) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts today or "
			note `rgvar': "A27) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_cuts_wk_* {
			label variable `rgvar' "A27.1) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts in the "
			note `rgvar': "A27.1) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_child_cuts_2wk_* {
			label variable `rgvar' "A27.2) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts in the "
			note `rgvar': "A27.2) Did \${N_child_u5_name_label} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_wk_* {
			label variable `rgvar' "In the last week, has \${N_child_u5_name_label} taken antibiotics?"
			note `rgvar': "In the last week, has \${N_child_u5_name_label} taken antibiotics?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_days_* {
			label variable `rgvar' "In the last week, How many days ago did \${N_child_u5_name_label} take antibioti"
			note `rgvar': "In the last week, How many days ago did \${N_child_u5_name_label} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_last_* {
			label variable `rgvar' "How long ago did \${N_child_u5_name_label} last take antibiotics?"
			note `rgvar': "How long ago did \${N_child_u5_name_label} last take antibiotics?"
			label define `rgvar' 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_last_months_* {
			label variable `rgvar' "Please specify in months"
			note `rgvar': "Please specify in months"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_last_days_* {
			label variable `rgvar' "Please specify in days"
			note `rgvar': "Please specify in days"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_purpose_* {
			label variable `rgvar' "For what purpose did \${N_child_u5_name_label} take antibiotics?"
			note `rgvar': "For what purpose did \${N_child_u5_name_label} take antibiotics?"
		}
	}

	capture {
		foreach rgvar of varlist n_anti_child_purpose_oth_* {
			label variable `rgvar' "Please specify others"
			note `rgvar': "Please specify others"
		}
	}

	capture {
		foreach rgvar of varlist n_med_seek_care_u5_* {
			label variable `rgvar' "In the past one month, did \${N_child_u5_name_label} seek medical care?"
			note `rgvar': "In the past one month, did \${N_child_u5_name_label} seek medical care?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_diarrhea_u5_* {
			label variable `rgvar' "Previously \${N_child_u5_name_label} said that she has diarrhea, and if \${N_chi"
			note `rgvar': "Previously \${N_child_u5_name_label} said that she has diarrhea, and if \${N_child_u5_name_label} did not mention that she took medical care for it. Please ask politely 'If \${N_child_u5_name_label} had diarrhea in the last one month, then why she did not take medical care for it?'"
			label define `rgvar' 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_visits_u5_* {
			label variable `rgvar' "How many visits \${N_child_u5_name_label} did in the last one month to seek medi"
			note `rgvar': "How many visits \${N_child_u5_name_label} did in the last one month to seek medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_u5_* {
			label variable `rgvar' "What was the symptom, or what was the reason for medical care?"
			note `rgvar': "What was the symptom, or what was the reason for medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_symp_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_u5_* {
			label variable `rgvar' "Where did \${N_child_u5_name_label} seek care?"
			note `rgvar': "Where did \${N_child_u5_name_label} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_where_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_nights_u5_* {
			label variable `rgvar' "How many nights did \${N_child_u5_name_label} spend in the hospital?"
			note `rgvar': "How many nights did \${N_child_u5_name_label} spend in the hospital?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_home_u5_* {
			label variable `rgvar' "Where did \${N_child_u5_name_label} seek care?"
			note `rgvar': "Where did \${N_child_u5_name_label} seek care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_out_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_type_u5_* {
			label variable `rgvar' "What was the nature of treatment at \${N_out_names_U5} that \${N_child_u5_name_l"
			note `rgvar': "What was the nature of treatment at \${N_out_names_U5} that \${N_child_u5_name_label} took?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_treat_oth_u5_* {
			label variable `rgvar' "Other"
			note `rgvar': "Other"
		}
	}

	capture {
		foreach rgvar of varlist n_med_trans_u5_* {
			label variable `rgvar' "What was the mode of transportation taken by \${N_child_u5_name_label} to travel"
			note `rgvar': "What was the mode of transportation taken by \${N_child_u5_name_label} to travel to \${N_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_u5_* {
			label variable `rgvar' "How much time did \${N_child_u5_name_label} to travel to \${N_out_names_U5} to r"
			note `rgvar': "How much time did \${N_child_u5_name_label} to travel to \${N_out_names_U5} to receive care?"
			label define `rgvar' 1 "Minutes" 2 "Hours" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_mins_u5_* {
			label variable `rgvar' "Minutes"
			note `rgvar': "Minutes"
		}
	}

	capture {
		foreach rgvar of varlist n_med_time_hrs_u5_* {
			label variable `rgvar' "Hours"
			note `rgvar': "Hours"
		}
	}

	capture {
		foreach rgvar of varlist n_med_pay_trans_u5_* {
			label variable `rgvar' "What did \${N_child_u5_name_label} pay for the transportation to travel to \${N_"
			note `rgvar': "What did \${N_child_u5_name_label} pay for the transportation to travel to \${N_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_scheme_u5_* {
			label variable `rgvar' "Was \${N_child_u5_name_label} covered by any scheme for health expenditure suppo"
			note `rgvar': "Was \${N_child_u5_name_label} covered by any scheme for health expenditure support for the expenditure incurred at \${N_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_doctor_fees_u5_* {
			label variable `rgvar' "What did \${N_child_u5_name_label} pay for the consultation/treatment (doctor fe"
			note `rgvar': "What did \${N_child_u5_name_label} pay for the consultation/treatment (doctor fees) at \${N_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_u5_* {
			label variable `rgvar' "Did \${N_child_u5_name_label} pay for anything else for this illness at \${N_out"
			note `rgvar': "Did \${N_child_u5_name_label} pay for anything else for this illness at \${N_out_names_U5}?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_illness_other_u5_* {
			label variable `rgvar' "What did \${N_child_u5_name_label} pay for at \${N_out_names_U5}?"
			note `rgvar': "What did \${N_child_u5_name_label} pay for at \${N_out_names_U5}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_otherpay_u5_* {
			label variable `rgvar' "What amount did \${N_child_u5_name_label} pay for \${N_other_exp_U5} at \${N_out"
			note `rgvar': "What amount did \${N_child_u5_name_label} pay for \${N_other_exp_U5} at \${N_out_names_U5} ?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_t_exp_u5_* {
			label variable `rgvar' "In the last one month, what was the total expenditure \${N_child_u5_name_label} "
			note `rgvar': "In the last one month, what was the total expenditure \${N_child_u5_name_label} did on medical care?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_u5_* {
			label variable `rgvar' "Did anyone in your household, including you, change their work/housework routing"
			note `rgvar': "Did anyone in your household, including you, change their work/housework routing to take care of \${N_child_u5_name_label} ?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_med_work_who_u5_* {
			label variable `rgvar' "Who adjusted their schedule to take care of \${N_child_u5_name_label}?"
			note `rgvar': "Who adjusted their schedule to take care of \${N_child_u5_name_label}?"
		}
	}

	capture {
		foreach rgvar of varlist n_med_days_caretaking_u5_* {
			label variable `rgvar' "How many days have this person taken caretaking \${N_child_u5_name_label} (inclu"
			note `rgvar': "How many days have this person taken caretaking \${N_child_u5_name_label} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"
		}
	}

	capture {
		foreach rgvar of varlist n_translator_u5_* {
			label variable `rgvar' "C29)Was a translator used in the survey?"
			note `rgvar': "C29)Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_hh_prsnt_u5_* {
			label variable `rgvar' "Was there any Household member (other than the \${N_child_u5_name_label}) presen"
			note `rgvar': "Was there any Household member (other than the \${N_child_u5_name_label}) present during the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist survey_member_role_* {
			label variable `rgvar' "A42.1) What is the role of person number \${surveynumber}?"
			note `rgvar': "A42.1) What is the role of person number \${surveynumber}?"
			label define `rgvar' 1 "DIL staff" 2 "J-PAL supervisor" 3 "J-PAL enumerator" 4 "J-PAL monitor" 5 "J-PAL PA" 6 "Other J-PAL staff" 7 "Gram Vikas staff"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist survey_member_gender_* {
			label variable `rgvar' "A42.2) What is the gender of person number \${surveynumber}?"
			note `rgvar': "A42.2) What is the gender of person number \${surveynumber}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}


save "${DataPre}1_9_Endline_revisit_final.dta", replace
