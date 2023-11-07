* import_india_ilc_pilot_backcheck_Master.do
*
* 	Imports and aggregates "Baseline Backcheck" (ID: india_ilc_pilot_backcheck_Master) data.
*
*	Inputs:  "Baseline Backcheck_WIDE.csv"
*	Outputs: "Baseline Backcheck.dta"
*
*	Output by SurveyCTO November 1, 2023 5:50 AM.

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
local csvfile "Baseline Backcheck_WIDE.csv"
local dtafile "Baseline Backcheck.dta"
local corrfile "Baseline Backcheck_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5"
local text_fields3 "r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17"
local text_fields4 "r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 r_cen_pregwoman_1 r_cen_pregwoman_2 r_cen_pregwoman_3 r_cen_pregwoman_4 r_cen_pregwoman_5 r_cen_pregwoman_6 r_cen_pregwoman_7 r_cen_pregwoman_8"
local text_fields5 "r_cen_pregwoman_9 r_cen_pregwoman_10 r_cen_pregwoman_11 r_cen_pregwoman_12 r_cen_pregwoman_13 r_cen_pregwoman_14 r_cen_pregwoman_15 r_cen_pregwoman_16 r_cen_pregwoman_17 r_cen_pregwoman_18"
local text_fields6 "r_cen_pregwoman_19 r_cen_pregwoman_20 r_cen_u5child_1 r_cen_u5child_2 r_cen_u5child_3 r_cen_u5child_4 r_cen_u5child_5 r_cen_u5child_6 r_cen_u5child_7 r_cen_u5child_8 r_cen_u5child_9 r_cen_u5child_10"
local text_fields7 "r_cen_u5child_11 r_cen_u5child_12 r_cen_u5child_13 r_cen_u5child_14 r_cen_u5child_15 r_cen_u5child_16 r_cen_u5child_17 r_cen_u5child_18 r_cen_u5child_19 r_cen_u5child_20 r_cen_a12_water_source_prim"
local text_fields8 "female_above12 num_femaleabove12 adults_hh_above12 num_adultsabove12 children_below12 num_childbelow12 info_update enum_name_label who_interviwed_before missing_household_member_name no_consent_reason"
local text_fields9 "no_consent_oth no_consent_comment consent_dur_end a7_resp_name preg_member_names_count namenumber_* a16_preg_woman_name_oth_* namefromearlier2_* a18_pregwoman_relation_oth_* child_names_count"
local text_fields10 "namenumber2_* a24_child_name_oth_* namefromearlier3_* a25_child_relation_oth_* a26_autoage_* a11_oldmale_name a12_prim_source_oth primary_water_label a16_water_treat_type a16_water_treat_oth"
local text_fields11 "a16_water_treat_freq a16_treat_freq_oth stored_treat_freq_oth water_prim_kids_oth water_treat_kids_type water_treat_kids_oth a17_treat_kids_freq treat_kids_freq_oth a41_end_comments instanceid"
local text_fields12 "instancename"
local date_fields1 "a26_dob_*"
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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_name_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round: \${R_Cen_a1_resp_name} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Saahi: \${R_Cen_saahi_name} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
	label define noteconf1 1 "I am visiting the correct household and the information is correct" 2 "I am visiting the correct household but the information needs to be updated" 3 "The household I am visiting does not corresponds to the confirmation info."
	label values noteconf1 noteconf1

	label variable info_update "Please describe the information need to be updated here."
	note info_update: "Please describe the information need to be updated here."

	label variable enum_name "Enumerator name: Please select from the drop-down list"
	note enum_name: "Enumerator name: Please select from the drop-down list"
	label define enum_name 101 "Sanjay Naik" 102 "Susanta Kumar Mahanta" 103 "Rajib Panda" 104 "Santosh Kumar Das" 105 "Bibhar Pankaj" 106 "Madhusmita Samal" 107 "Rekha Behera" 108 "Sanjukta Chichuan" 109 "Swagatika Behera" 110 "Sarita Bhatra" 111 "Abhishek Rath" 112 "Binod Kumar Mohanandia" 113 "Mangulu Bagh" 114 "Padman Bhatra" 115 "Kuna Charan Naik" 116 "Sushil Kumar Pani" 117 "Jitendra Bagh" 118 "Rajeswar Digal" 119 "Pramodini Gahir" 120 "Manas Ranjan Parida" 121 "Ishadatta Pani"
	label values enum_name enum_name

	label variable resp_available "Did you find a household to interview?"
	note resp_available: "Did you find a household to interview?"
	label define resp_available 1 "Household available for an interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible (e.g. all t" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable interviewed_before "Enumerator: Ask the person who ever opens the door if this household was intervi"
	note interviewed_before: "Enumerator: Ask the person who ever opens the door if this household was interviewed before?"
	label define interviewed_before 1 "Yes" 0 "No"
	label values interviewed_before interviewed_before

	label variable who_interviwed_before "A1) who among the household members was interviewed before?"
	note who_interviwed_before: "A1) who among the household members was interviewed before?"

	label variable missing_household_member_name "A1.1) Please enter the other household member that don’t exist in the list provi"
	note missing_household_member_name: "A1.1) Please enter the other household member that don’t exist in the list provided"

	label variable fivemin_interview "A2) Is the respondent available for a five minute interview?"
	note fivemin_interview: "A2) Is the respondent available for a five minute interview?"
	label define fivemin_interview 1 "Yes" 0 "No"
	label values fivemin_interview fivemin_interview

	label variable consent "A3) Do I have your permission to proceed with the interview?"
	note consent: "A3) Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable no_consent_reason "A4) Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason: "A4) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "A4.1) Please specify other"
	note no_consent_oth: "A4.1) Please specify other"

	label variable no_consent_comment "A6) Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "A6) Record any relevant notes if the respondent refused the interview"

	label variable a7_resp_name "A7) What is your name?"
	note a7_resp_name: "A7) What is your name?"

	label variable a12_resp_school "A8) Have you ever attended school?"
	note a12_resp_school: "A8) Have you ever attended school?"
	label define a12_resp_school 1 "Yes" 0 "No"
	label values a12_resp_school a12_resp_school

	label variable a13_resp_school_level "A9) What is the highest level of schooling that you have completed?"
	note a13_resp_school_level: "A9) What is the highest level of schooling that you have completed?"
	label define a13_resp_school_level 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
	label values a13_resp_school_level a13_resp_school_level

	label variable a14_resp_read_write "A10) Can you read or write?"
	note a14_resp_read_write: "A10) Can you read or write?"
	label define a14_resp_read_write 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a14_resp_read_write a14_resp_read_write

	label variable a15_hhmember_count "A11) How many people live in this household including you?"
	note a15_hhmember_count: "A11) How many people live in this household including you?"

	label variable screen_u5child "A12) Are there any children under the age of 5 years in this household?"
	note screen_u5child: "A12) Are there any children under the age of 5 years in this household?"
	label define screen_u5child 1 "Yes" 0 "No"
	label values screen_u5child screen_u5child

	label variable no_of_u5child "A13) How many children under the age of 5 years are there in this household?"
	note no_of_u5child: "A13) How many children under the age of 5 years are there in this household?"

	label variable screen_preg "A14) Are there currently any pregnant women in this household?"
	note screen_preg: "A14) Are there currently any pregnant women in this household?"
	label define screen_preg 1 "Yes" 0 "No"
	label values screen_preg screen_preg

	label variable no_of_preg "A11)How many pregnant women are there in this household?"
	note no_of_preg: "A11)How many pregnant women are there in this household?"

	label variable a10_hhhead "A22) What is the name of the head of household? (Household head can be either ma"
	note a10_hhhead: "A22) What is the name of the head of household? (Household head can be either male or female)"
	label define a10_hhhead 1 "\${R_Cen_fam_name1}" 2 "\${R_Cen_fam_name2}" 3 "\${R_Cen_fam_name3}" 4 "\${R_Cen_fam_name4}" 5 "\${R_Cen_fam_name5}" 6 "\${R_Cen_fam_name6}" 7 "\${R_Cen_fam_name7}" 8 "\${R_Cen_fam_name8}" 9 "\${R_Cen_fam_name9}" 10 "\${R_Cen_fam_name10}" 11 "\${R_Cen_fam_name11}" 12 "\${R_Cen_fam_name12}" 13 "\${R_Cen_fam_name13}" 14 "\${R_Cen_fam_name14}" 15 "\${R_Cen_fam_name15}" 16 "\${R_Cen_fam_name16}" 17 "\${R_Cen_fam_name17}" 18 "\${R_Cen_fam_name18}" 19 "\${R_Cen_fam_name19}" 20 "\${R_Cen_fam_name20}"
	label values a10_hhhead a10_hhhead

	label variable a10_hhhead_gender "A23) What is the gender of the household head?"
	note a10_hhhead_gender: "A23) What is the gender of the household head?"
	label define a10_hhhead_gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values a10_hhhead_gender a10_hhhead_gender

	label variable a11_oldmale "A24) Is there an older male in the household?"
	note a11_oldmale: "A24) Is there an older male in the household?"
	label define a11_oldmale 1 "Yes" 0 "No"
	label values a11_oldmale a11_oldmale

	label variable a11_oldmale_name "A25) What is their name?"
	note a11_oldmale_name: "A25) What is their name?"

	label variable bc_water_source_prim "A26) In the past month, which water source did your household primarily use for "
	note bc_water_source_prim: "A26) In the past month, which water source did your household primarily use for drinking?"
	label define bc_water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" -77 "Other"
	label values bc_water_source_prim bc_water_source_prim

	label variable a12_prim_source_oth "A12.1) If Other, please specify:"
	note a12_prim_source_oth: "A12.1) If Other, please specify:"

	label variable change_primary_source "A26.1) Has there been a change in your primary drinking water source in the last"
	note change_primary_source: "A26.1) Has there been a change in your primary drinking water source in the last one month?"
	label define change_primary_source 1 "Yes" 0 "No"
	label values change_primary_source change_primary_source

	label variable a16_water_treat "A27) Do you ever do anything to the water from the primary source (\${primary_wa"
	note a16_water_treat: "A27) Do you ever do anything to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"
	label define a16_water_treat 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a16_water_treat a16_water_treat

	label variable a16_stored_treat "A28) Did you do anything to the water currently stored in your house to make it "
	note a16_stored_treat: "A28) Did you do anything to the water currently stored in your house to make it safe for drinking?"
	label define a16_stored_treat 1 "Yes" 0 "No" 2 "No stored water currently but stored generally" -99 "Don't know"
	label values a16_stored_treat a16_stored_treat

	label variable a16_water_treat_type "A29) What do you do to the water from the primary source (\${primary_water_label"
	note a16_water_treat_type: "A29) What do you do to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"

	label variable a16_water_treat_oth "A29.1) If Other, please specify:"
	note a16_water_treat_oth: "A29.1) If Other, please specify:"

	label variable a16_water_treat_freq "A30) When do you make the water from your primary drinking water source (\${prim"
	note a16_water_treat_freq: "A30) When do you make the water from your primary drinking water source (\${primary_water_label}) safe before drinking it?"

	label variable a16_treat_freq_oth "A30.1) If Other, please specify:"
	note a16_treat_freq_oth: "A30.1) If Other, please specify:"

	label variable a16_stored_treat_freq "A31) How often do you make the water currently stored at home safe for drinking?"
	note a16_stored_treat_freq: "A31) How often do you make the water currently stored at home safe for drinking?"
	label define a16_stored_treat_freq 1 "Every time the stored water is used" 0 "Once at the time of storing" 2 "Daily" 3 "2-3 times a day" 4 "Every 2-3 days in a week" 5 "No fixed schedule" -77 "Other"
	label values a16_stored_treat_freq a16_stored_treat_freq

	label variable stored_treat_freq_oth "A31.1) If Other, please specify:"
	note stored_treat_freq_oth: "A31.1) If Other, please specify:"

	label variable a17_water_source_kids "A32) Do your youngest children drink from the same water source as the household"
	note a17_water_source_kids: "A32) Do your youngest children drink from the same water source as the household’s primary drinking water source i.e (\${primary_water_label}) ?"
	label define a17_water_source_kids 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a17_water_source_kids a17_water_source_kids

	label variable water_prim_source_kids "A32) What is the primary drinking water source for your youngest children?"
	note water_prim_source_kids: "A32) What is the primary drinking water source for your youngest children?"
	label define water_prim_source_kids 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" -77 "Other"
	label values water_prim_source_kids water_prim_source_kids

	label variable water_prim_kids_oth "A32.1) If Other, please specify:"
	note water_prim_kids_oth: "A32.1) If Other, please specify:"

	label variable a17_water_treat_kids "A33) Do you ever do anything to the water for your youngest children to make it "
	note a17_water_treat_kids: "A33) Do you ever do anything to the water for your youngest children to make it safe for drinking?"
	label define a17_water_treat_kids 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a17_water_treat_kids a17_water_treat_kids

	label variable water_treat_kids_type "A34) What do you do to the water for your youngest children to make it safe for "
	note water_treat_kids_type: "A34) What do you do to the water for your youngest children to make it safe for drinking?"

	label variable water_treat_kids_oth "A34.1) If Other, please specify:"
	note water_treat_kids_oth: "A34.1) If Other, please specify:"

	label variable a17_treat_kids_freq "A35) For your youngest children, when do you make the water safe before they dri"
	note a17_treat_kids_freq: "A35) For your youngest children, when do you make the water safe before they drink it?"

	label variable treat_kids_freq_oth "A35.1) If Other, please specify:"
	note treat_kids_freq_oth: "A35.1) If Other, please specify:"

	label variable a18_jjm_drinking "A36) Do you use the government provided household tap for drinking?"
	note a18_jjm_drinking: "A36) Do you use the government provided household tap for drinking?"
	label define a18_jjm_drinking 0 "No" 1 "Yes" 2 "Do not have a government tap connection"
	label values a18_jjm_drinking a18_jjm_drinking

	label variable labels "A36) Does your household have:"
	note labels: "A36) Does your household have:"
	label define labels 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values labels labels

	label variable a33_cotbed "A cot or bed?"
	note a33_cotbed: "A cot or bed?"
	label define a33_cotbed 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_cotbed a33_cotbed

	label variable a33_electricfan "An electric fan?"
	note a33_electricfan: "An electric fan?"
	label define a33_electricfan 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_electricfan a33_electricfan

	label variable a33_colourtv "A colour television?"
	note a33_colourtv: "A colour television?"
	label define a33_colourtv 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_colourtv a33_colourtv

	label variable a33_mobile "A mobile telephone?"
	note a33_mobile: "A mobile telephone?"
	label define a33_mobile 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_mobile a33_mobile

	label variable a33_internet "Internet?"
	note a33_internet: "Internet?"
	label define a33_internet 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_internet a33_internet

	label variable a33_motorcycle "A motorcycle or scooter?"
	note a33_motorcycle: "A motorcycle or scooter?"
	label define a33_motorcycle 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_motorcycle a33_motorcycle

	label variable a34_roof "A37) Do you have a pucca (solid or permanent, made from stone, brick, cement, co"
	note a34_roof: "A37) Do you have a pucca (solid or permanent, made from stone, brick, cement, concrete, or timber) roof on the house?"
	label define a34_roof 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a34_roof a34_roof

	label variable a41_end_comments "A38) Please add any additional comments about this survey."
	note a41_end_comments: "A38) Please add any additional comments about this survey."

	label variable a43_revisit "A43) Please record the following about your visit"
	note a43_revisit: "A43) Please record the following about your visit"
	label define a43_revisit 1 "This is my first visit" 2 "This is my second visit (1st REVISIT)" 3 "This is my third visit (2nd REVISIT)"
	label values a43_revisit a43_revisit



	capture {
		foreach rgvar of varlist a16_preg_woman_name_* {
			label variable `rgvar' "A16) What is the name of pregnant woman \${namenumber}?"
			note `rgvar': "A16) What is the name of pregnant woman \${namenumber}?"
			label define `rgvar' 1 "\${R_Cen_pregwoman_1}" 2 "\${R_Cen_pregwoman_2}" 3 "\${R_Cen_pregwoman_3}" 4 "\${R_Cen_pregwoman_4}" 5 "\${R_Cen_pregwoman_5}" 6 "\${R_Cen_pregwoman_6}" 7 "\${R_Cen_pregwoman_7}" 8 "\${R_Cen_pregwoman_8}" 9 "\${R_Cen_pregwoman_9}" 10 "\${R_Cen_pregwoman_10}" 11 "\${R_Cen_pregwoman_11}" 12 "\${R_Cen_pregwoman_12}" 13 "\${R_Cen_pregwoman_13}" 14 "\${R_Cen_pregwoman_14}" 15 "\${R_Cen_pregwoman_15}" 16 "\${R_Cen_pregwoman_16}" 17 "\${R_Cen_pregwoman_17}" 18 "\${R_Cen_pregwoman_18}" 19 "\${R_Cen_pregwoman_19}" 20 "\${R_Cen_pregwoman_20}" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a16_preg_woman_name_oth_* {
			label variable `rgvar' "A16.1) Note to enumerator: If there are other pregnant women not part of the dro"
			note `rgvar': "A16.1) Note to enumerator: If there are other pregnant women not part of the dropdown list in the previous question, specify their name"
		}
	}

	capture {
		foreach rgvar of varlist a16_preg_woman_name_final_* {
			label variable `rgvar' "A16.2) Note to enumerator: Which woman from the list are you filling the details"
			note `rgvar': "A16.2) Note to enumerator: Which woman from the list are you filling the details for?"
			label define `rgvar' 1 "\${R_Cen_pregwoman_1}" 2 "\${R_Cen_pregwoman_2}" 3 "\${R_Cen_pregwoman_3}" 4 "\${R_Cen_pregwoman_4}" 5 "\${R_Cen_pregwoman_5}" 6 "\${R_Cen_pregwoman_6}" 7 "\${R_Cen_pregwoman_7}" 8 "\${R_Cen_pregwoman_8}" 9 "\${R_Cen_pregwoman_9}" 10 "\${R_Cen_pregwoman_10}" 11 "\${R_Cen_pregwoman_11}" 12 "\${R_Cen_pregwoman_12}" 13 "\${R_Cen_pregwoman_13}" 14 "\${R_Cen_pregwoman_14}" 15 "\${R_Cen_pregwoman_15}" 16 "\${R_Cen_pregwoman_16}" 17 "\${R_Cen_pregwoman_17}" 18 "\${R_Cen_pregwoman_18}" 19 "\${R_Cen_pregwoman_19}" 20 "\${R_Cen_pregwoman_20}" -77 "\${A16_preg_woman_name_oth}"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a17_pregwoman_relation_* {
			label variable `rgvar' "A17) Who is \${namefromearlier2} to you ?"
			note `rgvar': "A17) Who is \${namefromearlier2} to you ?"
			label define `rgvar' 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a18_pregwoman_relation_oth_* {
			label variable `rgvar' "A18) If Other, please specify:"
			note `rgvar': "A18) If Other, please specify:"
		}
	}

	capture {
		foreach rgvar of varlist a6_pregwoman_age_* {
			label variable `rgvar' "A19) How old is \${namefromearlier2} in years?"
			note `rgvar': "A19) How old is \${namefromearlier2} in years?"
		}
	}

	capture {
		foreach rgvar of varlist a20_pregnant_month_* {
			label variable `rgvar' "A20) How many months pregnant is \${namefromearlier2}?"
			note `rgvar': "A20) How many months pregnant is \${namefromearlier2}?"
		}
	}

	capture {
		foreach rgvar of varlist preg_earlier_* {
			label variable `rgvar' "A20.1) Was \${namefromearlier2} pregnant earlier?"
			note `rgvar': "A20.1) Was \${namefromearlier2} pregnant earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist when_delivered_* {
			label variable `rgvar' "A20.2) How many days ago \${namefromearlier2} delivered the baby?"
			note `rgvar': "A20.2) How many days ago \${namefromearlier2} delivered the baby?"
		}
	}

	capture {
		foreach rgvar of varlist a21_pregnant_hh_* {
			label variable `rgvar' "A21) Is this \${namefromearlier2}'s usual residence?"
			note `rgvar': "A21) Is this \${namefromearlier2}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_pregnant_arrive_* {
			label variable `rgvar' "A21.0) When did \${namefromearlier2} arrive? (enter in days)"
			note `rgvar': "A21.0) When did \${namefromearlier2} arrive? (enter in days)"
		}
	}

	capture {
		foreach rgvar of varlist a21_pregnant_leave_* {
			label variable `rgvar' "A21.1) How long is \${namefromearlier2} planning to stay in the house (record in"
			note `rgvar': "A21.1) How long is \${namefromearlier2} planning to stay in the house (record in months)?"
		}
	}

	capture {
		foreach rgvar of varlist a21_pregnant_leave_days_* {
			label variable `rgvar' "A21.2) How long is \${namefromearlier2} planning to stay in the house (days)?"
			note `rgvar': "A21.2) How long is \${namefromearlier2} planning to stay in the house (days)?"
		}
	}

	capture {
		foreach rgvar of varlist a22_school_pregwoman_* {
			label variable `rgvar' "A22) Has \${namefromearlier2} ever attended school?"
			note `rgvar': "A22) Has \${namefromearlier2} ever attended school?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a22_school_level_pregwoman_* {
			label variable `rgvar' "A22.1) What is the highest level of schooling that \${namefromearlier2} has comp"
			note `rgvar': "A22.1) What is the highest level of schooling that \${namefromearlier2} has completed?"
			label define `rgvar' 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a23_read_write_pregwoman_* {
			label variable `rgvar' "A23) Can \${namefromearlier2} read or write?"
			note `rgvar': "A23) Can \${namefromearlier2} read or write?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a24_child_name_* {
			label variable `rgvar' "A24) What is the name of the child \${namenumber2}?"
			note `rgvar': "A24) What is the name of the child \${namenumber2}?"
			label define `rgvar' 1 "\${R_Cen_u5child_1}" 2 "\${R_Cen_u5child_2}" 3 "\${R_Cen_u5child_3}" 4 "\${R_Cen_u5child_4}" 5 "\${R_Cen_u5child_5}" 6 "\${R_Cen_u5child_6}" 7 "\${R_Cen_u5child_7}" 8 "\${R_Cen_u5child_8}" 9 "\${R_Cen_u5child_9}" 10 "\${R_Cen_u5child_10}" 11 "\${R_Cen_u5child_11}" 12 "\${R_Cen_u5child_12}" 13 "\${R_Cen_u5child_13}" 14 "\${R_Cen_u5child_14}" 15 "\${R_Cen_u5child_15}" 16 "\${R_Cen_u5child_16}" 17 "\${R_Cen_u5child_17}" 18 "\${R_Cen_u5child_18}" 19 "\${R_Cen_u5child_19}" 20 "\${R_Cen_u5child_20}" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a24_child_name_oth_* {
			label variable `rgvar' "A24.1) Note to enumerator: If there are other U5 children not part of the dropdo"
			note `rgvar': "A24.1) Note to enumerator: If there are other U5 children not part of the dropdown list in the previous question, specify their name"
		}
	}

	capture {
		foreach rgvar of varlist a24_child_name_final_* {
			label variable `rgvar' "A24.2) Note to enumerator: Which child from the list are you filling the details"
			note `rgvar': "A24.2) Note to enumerator: Which child from the list are you filling the details for?"
			label define `rgvar' 1 "\${R_Cen_u5child_1}" 2 "\${R_Cen_u5child_2}" 3 "\${R_Cen_u5child_3}" 4 "\${R_Cen_u5child_4}" 5 "\${R_Cen_u5child_5}" 6 "\${R_Cen_u5child_6}" 7 "\${R_Cen_u5child_7}" 8 "\${R_Cen_u5child_8}" 9 "\${R_Cen_u5child_9}" 10 "\${R_Cen_u5child_10}" 11 "\${R_Cen_u5child_11}" 12 "\${R_Cen_u5child_12}" 13 "\${R_Cen_u5child_13}" 14 "\${R_Cen_u5child_14}" 15 "\${R_Cen_u5child_15}" 16 "\${R_Cen_u5child_16}" 17 "\${R_Cen_u5child_17}" 18 "\${R_Cen_u5child_18}" 19 "\${R_Cen_u5child_19}" 20 "\${R_Cen_u5child_20}" -77 "\${A24_child_name_oth}"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a25_child_relation_* {
			label variable `rgvar' "A25) Who is \${namefromearlier3} to you ?"
			note `rgvar': "A25) Who is \${namefromearlier3} to you ?"
			label define `rgvar' 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a25_child_relation_oth_* {
			label variable `rgvar' "A25.1) If Other, please specify:"
			note `rgvar': "A25.1) If Other, please specify:"
		}
	}

	capture {
		foreach rgvar of varlist a26_child_age_* {
			label variable `rgvar' "A26) How old is \${namefromearlier3} in years?"
			note `rgvar': "A26) How old is \${namefromearlier3} in years?"
		}
	}

	capture {
		foreach rgvar of varlist a26_dob_* {
			label variable `rgvar' "A26.1) What is the date of birth for \${namefromearlier3}?"
			note `rgvar': "A26.1) What is the date of birth for \${namefromearlier3}?"
		}
	}

	capture {
		foreach rgvar of varlist a27_u1age_* {
			label variable `rgvar' "A27) How old is \${namefromearlier3} in months/days?"
			note `rgvar': "A27) How old is \${namefromearlier3} in months/days?"
		}
	}

	capture {
		foreach rgvar of varlist a27_unit_age_* {
			label variable `rgvar' "Select the unit:"
			note `rgvar': "Select the unit:"
			label define `rgvar' 1 "Months" 2 "Days"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a28_correct_age_* {
			label variable `rgvar' "A28) Enumerator to note if the above age for the child U5 was accurate (i.e conf"
			note `rgvar': "A28) Enumerator to note if the above age for the child U5 was accurate (i.e confirmed from birth certificate/ Anganwadi records) or imputed/guessed"
			label define `rgvar' 1 "Age for U5 child accurate" 2 "Age for U5 child imputed/guessed"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_school_child_* {
			label variable `rgvar' "A29) Has \${namefromearlier3} ever attended school?"
			note `rgvar': "A29) Has \${namefromearlier3} ever attended school?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_school_level_child_* {
			label variable `rgvar' "A29.1) What is the highest level of schooling that \${namefromearlier3} has comp"
			note `rgvar': "A29.1) What is the highest level of schooling that \${namefromearlier3} has completed?"
			label define `rgvar' 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_school_current_* {
			label variable `rgvar' "A29.2) [For children u5] Is \${namefromearlier3} currently going to school/angan"
			note `rgvar': "A29.2) [For children u5] Is \${namefromearlier3} currently going to school/anganwaadi center? ("
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a30_read_write_child_* {
			label variable `rgvar' "A30) Can \${namefromearlier3} read or write?"
			note `rgvar': "A30) Can \${namefromearlier3} read or write?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_breastfeeding_* {
			label variable `rgvar' "A21.4) Was OR Is U5 child exclusively breasfed (not drinking any water)?"
			note `rgvar': "A21.4) Was OR Is U5 child exclusively breasfed (not drinking any water)?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_child_hh_* {
			label variable `rgvar' "A21.5) Is this \${namefromearlier3}'s usual residence?"
			note `rgvar': "A21.5) Is this \${namefromearlier3}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_child_arrive_* {
			label variable `rgvar' "A21.6) When did \${namefromearlier3} arrive? (enter in days)"
			note `rgvar': "A21.6) When did \${namefromearlier3} arrive? (enter in days)"
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
*   Corrections file path and filename:  Baseline Backcheck_corrections.csv
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
