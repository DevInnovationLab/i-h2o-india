* import_India_ILC_Endline_BackCheck_Census.do
*
* 	Imports and aggregates "Endline Census BackCheck" (ID: India_ILC_Endline_BackCheck_Census) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck_WIDE.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck.dta"
*
*	Output by SurveyCTO May 8, 2024 4:27 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck_WIDE.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5"
local text_fields3 "r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17"
local text_fields4 "r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11"
local text_fields5 "cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4"
local text_fields6 "cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16"
local text_fields7 "cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 r_cen_a12_water_source_prim cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12"
local text_fields8 "cen_children_below12 cen_num_childbelow12 child_bearing_list_preload cen_num_childbelow5 child_u5_list_preload cen_num_malesabove15 cen_malesabove15_list_preload r_cen_non_cri_mem_1"
local text_fields9 "r_cen_non_cri_mem_2 r_cen_non_cri_mem_3 r_cen_non_cri_mem_4 r_cen_non_cri_mem_5 r_cen_non_cri_mem_6 r_cen_non_cri_mem_7 r_cen_non_cri_mem_8 r_cen_non_cri_mem_9 r_cen_non_cri_mem_10"
local text_fields10 "r_cen_non_cri_mem_11 r_cen_non_cri_mem_12 r_cen_non_cri_mem_13 r_cen_non_cri_mem_14 r_cen_non_cri_mem_15 r_cen_non_cri_mem_16 r_cen_non_cri_mem_17 r_cen_non_cri_mem_18 r_cen_non_cri_mem_19"
local text_fields11 "r_cen_non_cri_mem_20 cen_num_hhmembers cen_num_noncri r_cen_noncri_elig_list village_name_res e_new_mem_count r_e_n_fam_name1 r_e_n_fam_name2 r_e_n_fam_name3 r_e_n_fam_name4 r_e_n_fam_name5"
local text_fields12 "r_e_n_fam_name6 r_e_n_fam_name7 r_e_n_fam_name8 r_e_n_fam_name9 r_e_n_fam_name10 r_e_n_fam_name11 r_e_n_fam_name12 r_e_n_fam_name13 r_e_n_fam_name14 r_e_n_fam_name15 r_e_n_fam_name16 r_e_n_fam_name17"
local text_fields13 "r_e_n_fam_name18 r_e_n_fam_name19 r_e_n_fam_name20 r_e_n_fam_age1 r_e_n_fam_age2 r_e_n_fam_age3 r_e_n_fam_age4 r_e_n_fam_age5 r_e_n_fam_age6 r_e_n_fam_age7 r_e_n_fam_age8 r_e_n_fam_age9"
local text_fields14 "r_e_n_fam_age10 r_e_n_fam_age11 r_e_n_fam_age12 r_e_n_fam_age13 r_e_n_fam_age14 r_e_n_fam_age15 r_e_n_fam_age16 r_e_n_fam_age17 r_e_n_fam_age18 r_e_n_fam_age19 r_e_n_fam_age20 r_e_cen_resp_name"
local text_fields15 "r_e_cen_name_cbw_woman_earlier1 r_e_cen_name_cbw_woman_earlier2 r_e_cen_name_cbw_woman_earlier3 r_e_cen_name_cbw_woman_earlier4 r_e_cen_preg_status1 r_e_cen_preg_status2 r_e_cen_preg_status3"
local text_fields16 "r_e_cen_preg_status4 r_e_cen_not_curr_preg1 r_e_cen_not_curr_preg2 r_e_cen_not_curr_preg3 r_e_cen_not_curr_preg4 r_e_cen_preg_residence1 r_e_cen_preg_residence2 r_e_cen_preg_residence3"
local text_fields17 "r_e_cen_preg_residence4 r_e_n_name_cbw_woman_earlier1 r_e_n_preg_residence1 e_n_num_cbw previous_respondent info_update enum_name_label cen_resp_name_oth bc_cen_resp_name_lab interview_before_label"
local text_fields18 "missing_household_member_name why_not_base_resp why_not_base_resp_oth interview_before_crit_no intro_dur_end no_consent_reason no_consent_oth no_consent_comment cen_hh_member_names_loop_count"
local text_fields19 "hh_index_* name_from_earlier_hh_* n_prv_mem_loop_count namenumber_* namefromearlier_* n_relation_oth_* n_cbw_age_* n_all_age_* n_age_confirm2_* n_u5mother_name_oth_* n_u5father_name_oth_*"
local text_fields20 "roster_end_duration n_fam_age1 n_fam_age2 n_fam_age3 n_fam_age4 n_fam_age5 n_fam_age6 n_fam_age7 n_fam_age8 n_fam_age9 n_fam_age10 n_fam_age11 n_fam_age12 n_fam_age13 n_fam_age14 n_fam_age15"
local text_fields21 "n_fam_age16 n_fam_age17 n_fam_age18 n_fam_age19 n_fam_age20 n_female_above12 n_num_femaleabove12 n_male_above12 n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12"
local text_fields22 "n_num_childbelow12 n_female_15to49 n_num_female_15to49 n_children_below5 n_num_childbelow5 n_allmembers_h n_num_allmembers_h b_hh_member_names_loop_count b_namenumber_* b_hhmember_name_*"
local text_fields23 "b_namefromearlier_* b_relation_oth_* b_cbw_age_* b_all_age_* b_age_confirm2_* b_dob_concat_* b_autoage_* b_year_* current_year_* current_month_* age_years_* age_months_* age_years_final_*"
local text_fields24 "age_months_final_* age_decimal_* b_u5mother_name_oth_* b_u5father_name_oth_* b_fam_name1 b_fam_name2 b_fam_name3 b_fam_name4 b_fam_name5 b_fam_name6 b_fam_name7 b_fam_name8 b_fam_name9 b_fam_name10"
local text_fields25 "b_fam_name11 b_fam_name12 b_fam_name13 b_fam_name14 b_fam_name15 b_fam_name16 b_fam_name17 b_fam_name18 b_fam_name19 b_fam_name20 b_fam_age1 b_fam_age2 b_fam_age3 b_fam_age4 b_fam_age5 b_fam_age6"
local text_fields26 "b_fam_age7 b_fam_age8 b_fam_age9 b_fam_age10 b_fam_age11 b_fam_age12 b_fam_age13 b_fam_age14 b_fam_age15 b_fam_age16 b_fam_age17 b_fam_age18 b_fam_age19 b_fam_age20 b_female_above12"
local text_fields27 "b_num_femaleabove12 b_male_above12 b_num_maleabove12 b_adults_hh_above12 b_num_adultsabove12 b_children_below12 b_num_childbelow12 b_female_15to49 b_num_female_15to49 b_children_below5"
local text_fields28 "b_num_childbelow5 b_allmembers_h b_num_allmembers_h water_prim_oth primary_water_label water_source_sec water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count water_sec_index_*"
local text_fields29 "water_sec_value_* water_sec_label_* water_sec_labels water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label"
local text_fields30 "water_treat_type water_treat_oth water_treat_freq treat_freq_oth tap_supply_freq_oth null_cen_num_female_15to49 cen_cbw_followup_count cen_preg_index_* cen_name_cbw_woman_earlier_* cen_name_cbw_preg_*"
local text_fields31 "null_n_num_female_15to49 n_cbw_followup_count n_cbw_ind_* n_name_cbw_woman_earlier_* instanceid instancename"
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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_name_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round (Target respondent): \${previous_Respondent} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Saahi: \${R_Cen_saahi_name} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
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
	label define resp_available 1 "Household available for an interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible (e.g. all t" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable interviewed_before "Enumerator: Ask the person who ever opens the door if this household was intervi"
	note interviewed_before: "Enumerator: Ask the person who ever opens the door if this household was interviewed before?"
	label define interviewed_before 1 "Yes" 0 "No"
	label values interviewed_before interviewed_before

	label variable cen_resp_name "Who is current respondent?"
	note cen_resp_name: "Who is current respondent?"
	label define cen_resp_name 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
	label values cen_resp_name cen_resp_name

	label variable cen_resp_name_oth "B1.1) Please specify other"
	note cen_resp_name_oth: "B1.1) Please specify other"

	label variable who_interviwed_before "A1) who among the household members was interviewed before?"
	note who_interviwed_before: "A1) who among the household members was interviewed before?"
	label define who_interviwed_before 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
	label values who_interviwed_before who_interviwed_before

	label variable missing_household_member_name "A1.1) Please enter the other household member that don’t exist in the list provi"
	note missing_household_member_name: "A1.1) Please enter the other household member that don’t exist in the list provided"

	label variable why_not_base_resp "Baseline Census respondent was \${R_Cen_a1_resp_name}. Could you please ask the "
	note why_not_base_resp: "Baseline Census respondent was \${R_Cen_a1_resp_name}. Could you please ask the current respondent why \${interview_before_label} was surveyed instead of \${R_Cen_a1_resp_name}."

	label variable why_not_base_resp_oth "B1.1) Please specify other"
	note why_not_base_resp_oth: "B1.1) Please specify other"

	label variable interview_before_gender "Please record gender of the \${interview_before_label}"
	note interview_before_gender: "Please record gender of the \${interview_before_label}"
	label define interview_before_gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values interview_before_gender interview_before_gender

	label variable interview_before__residence "Is this \${interview_before_label}'s current residence?"
	note interview_before__residence: "Is this \${interview_before_label}'s current residence?"
	label define interview_before__residence 1 "Yes" 0 "No"
	label values interview_before__residence interview_before__residence

	label variable interview_before_crit "Is \${interview_before_label} following all the conditions for being the target "
	note interview_before_crit: "Is \${interview_before_label} following all the conditions for being the target respondent?"
	label define interview_before_crit 1 "Yes" 0 "No"
	label values interview_before_crit interview_before_crit

	label variable interview_before_crit_no "Which conditions are not being fulfilled by \${interview_before_label}?"
	note interview_before_crit_no: "Which conditions are not being fulfilled by \${interview_before_label}?"

	label variable fivemin_interview "Is the \${BC_Cen_resp_name_lab} available for a five minute interview?"
	note fivemin_interview: "Is the \${BC_Cen_resp_name_lab} available for a five minute interview?"
	label define fivemin_interview 1 "Yes" 0 "No"
	label values fivemin_interview fivemin_interview

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

	label variable b_new_members "Are there any new member(s) in the household who were not included earlier? (Do "
	note b_new_members: "Are there any new member(s) in the household who were not included earlier? (Do not record any visitors)"
	label define b_new_members 1 "Yes" 0 "No"
	label values b_new_members b_new_members

	label variable b_new_members_verify "Are you sure that these new members are not from the list below? \${R_Cen_fam_na"
	note b_new_members_verify: "Are you sure that these new members are not from the list below? \${R_Cen_fam_name1}/ \${R_Cen_fam_name2}/ \${R_Cen_fam_name3}/ \${R_Cen_fam_name4}/ \${R_Cen_fam_name5}/ \${R_Cen_fam_name6}/ \${R_Cen_fam_name7}/ \${R_Cen_fam_name8}/ \${R_Cen_fam_name9}/ \${R_Cen_fam_name10}/ \${R_Cen_fam_name11}/ \${R_Cen_fam_name12}/ \${R_Cen_fam_name13}/ \${R_Cen_fam_name14}/ \${R_Cen_fam_name15}/ \${R_Cen_fam_name16}/ \${R_Cen_fam_name17}/ \${R_E_n_fam_name1}/ \${R_E_n_fam_name2}/ \${R_E_n_fam_name3}/ \${R_E_n_fam_name4}/ \${R_E_n_fam_name5}/ \${R_E_n_fam_name6}/ \${R_E_n_fam_name7}/ \${R_E_n_fam_name8}/ \${R_E_n_fam_name9}/ \${R_E_n_fam_name10}/ \${R_E_n_fam_name11}/ \${R_E_n_fam_name12}/ \${R_E_n_fam_name13}/ \${R_E_n_fam_name14}/ \${R_E_n_fam_name15}/ \${R_E_n_fam_name16}/ \${R_E_n_fam_name17}/ \${R_E_n_fam_name18}/ \${R_E_n_fam_name19}/ \${R_E_n_fam_name20}"
	label define b_new_members_verify 1 "Yes" 0 "No"
	label values b_new_members_verify b_new_members_verify

	label variable b_hhmember_count "How many new members are in the household?"
	note b_hhmember_count: "How many new members are in the household?"

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

	label variable sec_source_days_ago "How many days ago household used secondary/other sources for drinking purpose ?"
	note sec_source_days_ago: "How many days ago household used secondary/other sources for drinking purpose ?"

	label variable where_prim_locate "W6) Where is your primary drinking water source (\${primary_water_label}) locate"
	note where_prim_locate: "W6) Where is your primary drinking water source (\${primary_water_label}) located?"
	label define where_prim_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate where_prim_locate

	label variable where_prim_locate_enum_obs "ENUMERATOR'S OBSERVATION- According to you where is the primary drinking water s"
	note where_prim_locate_enum_obs: "ENUMERATOR'S OBSERVATION- According to you where is the primary drinking water source (\${primary_water_label}) located? (Do not ask respondent)"
	label define where_prim_locate_enum_obs 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate_enum_obs where_prim_locate_enum_obs

	label variable water_treat "W16) In the last one month, did your household do anything extra to the drinking"
	note water_treat: "W16) In the last one month, did your household do anything extra to the drinking water (\${primary_water_label} ) to make it safe before drinking it?"
	label define water_treat 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values water_treat water_treat

	label variable water_treat_type "A16.1) What do you do to the water from the primary source (\${primary_water_lab"
	note water_treat_type: "A16.1) What do you do to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"

	label variable water_treat_oth "A16.2) If Other, please specify:"
	note water_treat_oth: "A16.2) If Other, please specify:"

	label variable water_treat_freq "A16.3) When do you make the water from your primary drinking water source (\${pr"
	note water_treat_freq: "A16.3) When do you make the water from your primary drinking water source (\${primary_water_label}) safe before drinking it?"

	label variable treat_freq_oth "A16.4) If Other, please specify:"
	note treat_freq_oth: "A16.4) If Other, please specify:"

	label variable treat_days_ago "How many days ago household did anything additional to their \${primary_water_la"
	note treat_days_ago: "How many days ago household did anything additional to their \${primary_water_label} to make it safe for drinking purpose ?"

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



	capture {
		foreach rgvar of varlist cen_still_a_member_* {
			label variable `rgvar' "Is \${name_from_earlier_HH} still a member of this household, as per the definit"
			note `rgvar': "Is \${name_from_earlier_HH} still a member of this household, as per the definition?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist n_hhmember_residence_* {
			label variable `rgvar' "Is this \${namefromearlier}'s usual residence?"
			note `rgvar': "Is this \${namefromearlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
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
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
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
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
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
		foreach rgvar of varlist b_hhmember_name_* {
			label variable `rgvar' "A3) What is the name of household member \${B_namenumber}?"
			note `rgvar': "A3) What is the name of household member \${B_namenumber}?"
		}
	}

	capture {
		foreach rgvar of varlist b_hhmember_gender_* {
			label variable `rgvar' "A4) What is the gender of \${B_namefromearlier}?"
			note `rgvar': "A4) What is the gender of \${B_namefromearlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_hhmember_relation_* {
			label variable `rgvar' "A5) Who is \${B_namefromearlier} to you ?"
			note `rgvar': "A5) Who is \${B_namefromearlier} to you ?"
			label define `rgvar' 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" 13 "Brother-in-law/sister-in-law" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_relation_oth_* {
			label variable `rgvar' "A5.1) If Other, please specify:"
			note `rgvar': "A5.1) If Other, please specify:"
		}
	}

	capture {
		foreach rgvar of varlist b_hhmember_age_* {
			label variable `rgvar' "A6) How old is \${B_namefromearlier} in years?"
			note `rgvar': "A6) How old is \${B_namefromearlier} in years?"
		}
	}

	capture {
		foreach rgvar of varlist b_dob_date_* {
			label variable `rgvar' "Please select the date of birth"
			note `rgvar': "Please select the date of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_dob_month_* {
			label variable `rgvar' "Please select the month of birth"
			note `rgvar': "Please select the month of birth"
			label define `rgvar' 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_dob_year_* {
			label variable `rgvar' "Please select the year of birth"
			note `rgvar': "Please select the year of birth"
			label define `rgvar' 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_year_dob_correction_* {
			label variable `rgvar' "Note to Enumerator: The age calculated based on the date of birth- \${B_autoage}"
			note `rgvar': "Note to Enumerator: The age calculated based on the date of birth- \${B_autoage}- should match the age of the child given in years by the respondent. Please note that there cannot be a difference of more than a year in the estimated/imputed age. Go back to the question and confirm with respondent properly Did you confirm the age and date of birth properly?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_u1age_* {
			label variable `rgvar' "A6.3) How old is \${B_namefromearlier} in months/days?"
			note `rgvar': "A6.3) How old is \${B_namefromearlier} in months/days?"
			label define `rgvar' 1 "Months" 2 "Days" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_unit_age_months_* {
			label variable `rgvar' "Write in months"
			note `rgvar': "Write in months"
		}
	}

	capture {
		foreach rgvar of varlist b_unit_age_days_* {
			label variable `rgvar' "Write in days"
			note `rgvar': "Write in days"
		}
	}

	capture {
		foreach rgvar of varlist b_correct_age_* {
			label variable `rgvar' "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed"
			note `rgvar': "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed from birth certificate/ Anganwadi records) or imputed/guessed"
			label define `rgvar' 1 "Age for U5 child accurate" 2 "Age for U5 child imputed/guessed"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_u5mother_* {
			label variable `rgvar' "A8) Does the mother/ primary caregiver of \${B_namefromearlier} live in this hou"
			note `rgvar': "A8) Does the mother/ primary caregiver of \${B_namefromearlier} live in this household currently?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_u5mother_name_* {
			label variable `rgvar' "A8.1) What is the name of \${B_namefromearlier}'s mother/ primary caregiver?"
			note `rgvar': "A8.1) What is the name of \${B_namefromearlier}'s mother/ primary caregiver?"
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_u5mother_name_oth_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist b_u5father_name_* {
			label variable `rgvar' "A8.1) What is the name of \${B_namefromearlier}'s father?"
			note `rgvar': "A8.1) What is the name of \${B_namefromearlier}'s father?"
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${R_E_n_fam_name1} and \${R_E_n_fam_age1} years" 22 "\${R_E_n_fam_name2} and \${R_E_n_fam_age2} years" 23 "\${R_E_n_fam_name3} and \${R_E_n_fam_age3} years" 24 "\${R_E_n_fam_name4} and \${R_E_n_fam_age4} years" 25 "\${R_E_n_fam_name5} and \${R_E_n_fam_age5} years" 26 "\${R_E_n_fam_name6} and \${R_E_n_fam_age6} years" 27 "\${R_E_n_fam_name7} and \${R_E_n_fam_age7} years" 28 "\${R_E_n_fam_name8} and \${R_E_n_fam_age8} years" 29 "\${R_E_n_fam_name9} and \${R_E_n_fam_age9} years" 30 "\${R_E_n_fam_name10} and \${R_E_n_fam_age10} years" 31 "\${R_E_n_fam_name11} and \${R_E_n_fam_age11} years" 32 "\${R_E_n_fam_name12} and \${R_E_n_fam_age12} years" 33 "\${R_E_n_fam_name13} and \${R_E_n_fam_age13} years" 34 "\${R_E_n_fam_name14} and \${R_E_n_fam_age14} years" 35 "\${R_E_n_fam_name15} and \${R_E_n_fam_age15} years" 36 "\${R_E_n_fam_name16} and \${R_E_n_fam_age16} years" 37 "\${R_E_n_fam_name17} and \${R_E_n_fam_age17} years" 38 "\${R_E_n_fam_name18} and \${R_E_n_fam_age18} years" 39 "\${R_E_n_fam_name19} and \${R_E_n_fam_age19} years" 40 "\${R_E_n_fam_name20} and \${R_E_n_fam_age20} years" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b_u5father_name_oth_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist cen_preg_status_* {
			label variable `rgvar' "Is \${Cen_name_CBW_woman_earlier} pregnant?"
			note `rgvar': "Is \${Cen_name_CBW_woman_earlier} pregnant?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cen_not_curr_preg_* {
			label variable `rgvar' "Was \${Cen_name_CBW_woman_earlier} pregnant in the last 7 months?"
			note `rgvar': "Was \${Cen_name_CBW_woman_earlier} pregnant in the last 7 months?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cen_preg_residence_* {
			label variable `rgvar' "Is this \${Cen_name_CBW_woman_earlier}'s usual residence?"
			note `rgvar': "Is this \${Cen_name_CBW_woman_earlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
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
		foreach rgvar of varlist n_preg_residence_* {
			label variable `rgvar' "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
			note `rgvar': "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census BackCheck_corrections.csv
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
