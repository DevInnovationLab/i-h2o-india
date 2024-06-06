* import_India_ILC_Endline_Census_Revisit.do
*
* 	Imports and aggregates "Endline Census Re-visit" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit.dta"
*
*	Output by SurveyCTO June 6, 2024 11:41 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit.csv"
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
local text_fields16 "cen_hh_member_names_loop_count census_roster_dur_end n_hh_member_names_loop_count roster_end_duration n_fam_name1 n_fam_name2 n_fam_name3 n_fam_name4 n_fam_name5 n_fam_name6 n_fam_name7 n_fam_name8"
local text_fields17 "n_fam_name9 n_fam_name10 n_fam_name11 n_fam_name12 n_fam_name13 n_fam_name14 n_fam_name15 n_fam_name16 n_fam_name17 n_fam_name18 n_fam_name19 n_fam_name20 n_fam_age1 n_fam_age2 n_fam_age3 n_fam_age4"
local text_fields18 "n_fam_age5 n_fam_age6 n_fam_age7 n_fam_age8 n_fam_age9 n_fam_age10 n_fam_age11 n_fam_age12 n_fam_age13 n_fam_age14 n_fam_age15 n_fam_age16 n_fam_age17 n_fam_age18 n_fam_age19 n_fam_age20"
local text_fields19 "n_female_above12 n_num_femaleabove12 n_male_above12 n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12 n_num_childbelow12 n_female_15to49 n_num_female_15to49"
local text_fields20 "n_children_below5 n_num_childbelow5 n_allmembers_h n_num_allmembers_h new_roster_dur_end water_prim_oth primary_water_label water_source_sec water_source_sec_oth secondary_water_label num_water_sec"
local text_fields21 "water_sec_list_count water_sec_labels water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label sec_source_reason"
local text_fields22 "sec_source_reason_oth water_sec_freq_oth collect_resp people_prim_water num_people_prim people_prim_list_count people_prim_labels people_prim1 people_prim2 people_prim3 people_prim4 people_prim5"
local text_fields23 "people_prim6 people_prim7 people_prim8 people_prim9 people_prim10 people_prim11 people_prim12 people_prim13 people_prim14 people_prim15 people_prim16 people_prim17 people_prim18 people_prim19"
local text_fields24 "people_prim20 people_prim21 people_prim22 people_prim23 people_prim24 people_prim25 people_prim26 people_prim27 people_prim28 people_prim29 people_prim30 people_prim31 people_prim32 people_prim33"
local text_fields25 "people_prim34 people_prim35 people_prim36 people_prim37 people_prim38 people_prim39 people_prim40 water_treat_type water_treat_oth water_treat_freq treat_freq_oth treat_resp num_treat_resp"
local text_fields26 "treat_resp_list_count treat_resp_labels treat_resp1 treat_resp2 treat_resp3 treat_resp4 treat_resp5 treat_resp6 treat_resp7 treat_resp8 treat_resp9 treat_resp10 treat_resp11 treat_resp12 treat_resp13"
local text_fields27 "treat_resp14 treat_resp15 treat_resp16 treat_resp17 treat_resp18 treat_resp19 treat_resp20 treat_resp21 treat_resp22 treat_resp23 treat_resp24 treat_resp25 treat_resp26 treat_resp27 treat_resp28"
local text_fields28 "treat_resp29 treat_resp30 treat_resp31 treat_resp32 treat_resp33 treat_resp34 treat_resp35 treat_resp36 treat_resp37 treat_resp38 treat_resp39 treat_resp40 water_prim_kids_oth water_prim_preg_oth"
local text_fields29 "water_treat_kids_type water_treat_kids_oth treat_kids_freq treat_kids_freq_oth tap_supply_freq_oth reason_nodrink nodrink_water_treat_oth jjm_use jjm_use_oth tap_function_reason tap_function_oth"
local text_fields30 "tap_issues_type tap_issues_type_oth wash_dur_end audio_audit_noncri n_med_seek_all n_med_seek_lp_all_count cen_med_seek_all cen_med_seek_lp_all_count hh_member_section noncri_dur_end"
local text_fields31 "audio_audit_census_resp comb_cbw_followup_count census_resp_health_dur_end audio_audit_new_resp n_cbw_followup_count new_resp_health_dur_end audio_audit_cen_child comb_child_followup_count"
local text_fields32 "census_u5_dur_end audio_audit_new_child n_child_followup_count new_u5_dur_end survey_end_duration a41_end_comments survey_member_names_count instanceid instancename"
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


* launch .do files to process repeat groups

cd "${Do_lab}"
do "import_India_ILC_Endline_Census_Revisit-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.do"
do "import_India_ILC_Endline_Census_Revisit-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-N_CBW_followup.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-N_child_followup.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-Cen_med_seek_lp_all.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-N_med_seek_lp_all.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-burden_of_water_collection_and_treatment-people_prim_list.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_sources-water_sec_list.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_treatment-treat_resp_list.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-comb_CBW_followup.do"
do "import_India_ILC_Endline_Census_Revisit-Household_available-comb_child_followup.do"
do "import_India_ILC_Endline_Census_Revisit-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.do"
do "import_India_ILC_Endline_Census_Revisit-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.do"
do "import_India_ILC_Endline_Census_Revisit-N_med_notnull_all-N_prvidr_exp_lp_all.do"
do "import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.do"
do "import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.do"
do "import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_all-N_tests_exp_loop_all.do"
do "import_India_ILC_Endline_Census_Revisit-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.do"
do "import_India_ILC_Endline_Census_Revisit-accompaniment-survey_member_names.do"
do "import_India_ILC_Endline_Census_Revisit-comb_prvdrs_notnull_CBW-comb_tests_exp_loop_CBW.do"
do "import_India_ILC_Endline_Census_Revisit-comb_prvdrs_notnull_U5-comb_tests_exp_loop_U5.do"

cap do "import_India_ILC_Endline_Census_Revisit-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_sought_med_care_CBW-comb_med_visits_not0_CBW-comb_prvdrs_exp_loop_CBW.do"

cap do "C:\Users\Archi Gupta\Documents\GitHub\I-H2O-~1\Code\1_PROF~1\Label\IM198F~1.DO"


do "import_India_ILC_Endline_Census_Revisit-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_start_5_years_pregnant-comb_child_died_repeat.do"
do "import_India_ILC_Endline_Census_Revisit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.do"
