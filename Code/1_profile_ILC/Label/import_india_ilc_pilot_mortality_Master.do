* import_india_ilc_pilot_mortality_Master.do
*
* 	Imports and aggregates "Mortality Survey" (ID: india_ilc_pilot_mortality_Master) data.
*
*	Inputs:  "Mortality Survey_WIDE.csv"
*	Outputs: "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Mortality Survey.dta"
*
*	Output by SurveyCTO December 18, 2023 10:36 AM.

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
local csvfile "Mortality Survey_WIDE.csv"
local dtafile "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Mortality Survey.dta"
local corrfile "Mortality Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5"
local text_fields3 "r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17"
local text_fields4 "r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11"
local text_fields5 "cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4"
local text_fields6 "cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16"
local text_fields7 "cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 r_cen_a12_water_source_prim cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12"
local text_fields8 "cen_children_below12 cen_num_childbelow12 child_bearing_list_preload scenario info_update enum_name_label_sc block_name_oth gp_name_oth village_name_oth hamlet_name saahi_name hh_code_format_sc1"
local text_fields9 "unique_id_sc1 landmark address enum_name_label no_consent_reason no_consent_oth no_consent_comment consent_dur_end a1_resp_name otherhous_address hh_member_names_count namenumber_* a3_hhmember_name_*"
local text_fields10 "namefromearlier_* a5_relation_oth_* a5_autoage_* fam_name1 fam_name2 fam_name3 fam_name4 fam_name5 fam_name6 fam_name7 fam_name8 fam_name9 fam_name10 fam_name11 fam_name12 fam_name13 fam_name14"
local text_fields11 "fam_name15 fam_name16 fam_name17 fam_name18 fam_name19 fam_name20 fam_age1 fam_age2 fam_age3 fam_age4 fam_age5 fam_age6 fam_age7 fam_age8 fam_age9 fam_age10 fam_age11 fam_age12 fam_age13 fam_age14"
local text_fields12 "fam_age15 fam_age16 fam_age17 fam_age18 fam_age19 fam_age20 female_above12 female_15to49 num_female_15to49 adults_hh_above12 num_adultsabove12 children_below12 num_childbelow12 sectionb_dur_end"
local text_fields13 "child_bearing_list otherhous_address_screened a12_prim_source_oth primary_source_label oth_previous_primary previous_primary_source_label change_reason_primary_source oth_change_primary_source"
local text_fields14 "a13_water_source_sec a13_water_sec_oth oth_previous_secondary previous_sec_source_label change_reason_secondary a13_change_reason_secondary reason_yes_jjm oth_reason_yes_jjm reason_no_jjm"
local text_fields15 "oth_reason_no_jjm women_child_bearing_count child_bearing_index_* name_pc_earlier_* no_consent_reason_pc_* no_consent_pc_oth_* no_consent_pc_comment_* vill_pc_oth_* village_name_res_*"
local text_fields16 "child_died_u5_count_* child_died_repeat_count_* name_child_* name_child_earlier_* cause_death_* cause_death_oth_* cause_death_str_* women_child_bearing_sc_count child_bearing_index_sc_*"
local text_fields17 "name_pc_earlier_sc_* no_consent_reason_pc_sc_* no_consent_pc_oth_sc_* no_consent_pc_comment_sc_* vill_pc_oth_sc_* village_name_res_sc_* num_stillborn_null_* num_less24_null_* num_more24_null_*"
local text_fields18 "child_died_u5_count_sc_null_* child_died_repeat_sc_count_* name_child_sc_* name_child_earlier_sc_* cause_death_sc_* cause_death_oth_sc_* cause_death_str_sc_* women_child_bearing_oth_count"
local text_fields19 "child_bearing_index_oth_* name_pc_oth_* name_pc_earlier_oth_* no_consent_reason_pc_oth_* no_consent_pc_oth_oth_* no_consent_pc_comment_oth_* vill_pc_oth_oth_* num_stillborn_null_oth_*"
local text_fields20 "num_less24_null_oth_* num_more24_null_oth_* child_died_u5_count_sc_null_oth_* child_died_repeat_oth_count_* name_child_oth_* name_child_earlier_oth_* cause_death_oth_add_* cause_death_oth_oth_*"
local text_fields21 "cause_death_str_oth_* survey_member_names_count_* surveynumber_* a41_end_comments instanceid instancename"
local date_fields1 "a6_dob_* date_birth_* date_death_* date_birth_sc_* date_death_sc_* date_birth_oth_* date_death_oth_*"
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


	label variable check_scenario "Was this a household that was surveyed before? In order to check this, ask the m"
	note check_scenario: "Was this a household that was surveyed before? In order to check this, ask the member whether someone has surveyed them in the past two months."
	label define check_scenario 1 "Yes" 0 "No"
	label values check_scenario check_scenario

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

	label variable enum_name_sc "Enumerator to fill up: Enumerator Name"
	note enum_name_sc: "Enumerator to fill up: Enumerator Name"
	label define enum_name_sc 501 "Sanjay Naik" 503 "Rajib Panda" 505 "Bibhar Pankaj" 510 "Sarita Bhatra" 519 "Pramodini Gahir" 521 "Ishadatta Pani"
	label values enum_name_sc enum_name_sc

	label variable enum_code_sc "Enumerator to fill up: Enumerator Code"
	note enum_code_sc: "Enumerator to fill up: Enumerator Code"
	label define enum_code_sc 501 "501" 503 "503" 505 "505" 510 "510" 519 "519" 521 "521"
	label values enum_code_sc enum_code_sc

	label variable district_name "Enumerator to fill up: District Name"
	note district_name: "Enumerator to fill up: District Name"
	label define district_name 11 "Rayagada"
	label values district_name district_name

	label variable block_name "Enumerator to fill up: Block Name"
	note block_name: "Enumerator to fill up: Block Name"
	label define block_name 3 "Kolnara" 5 "Rayagada" -77 "Other"
	label values block_name block_name

	label variable block_name_oth "Other(specify)"
	note block_name_oth: "Other(specify)"

	label variable gp_name "Enumerator to fill up: Gram Panchayat Name"
	note gp_name: "Enumerator to fill up: Gram Panchayat Name"
	label define gp_name 302 "BK Padar" 307 "Dumbiriguda" 505 "Tadma" 504 "Kothapeta" -77 "Other"
	label values gp_name gp_name

	label variable gp_name_oth "Other(specify)"
	note gp_name_oth: "Other(specify)"

	label variable village_name "Enumerator to fill up: Village Name"
	note village_name: "Enumerator to fill up: Village Name"
	label define village_name 30202 "BK Padar" 30701 "Gopi Kankubadi" 50501 "Nathma" 50402 "Kuljing" -77 "Other"
	label values village_name village_name

	label variable village_name_oth "Other(specify)"
	note village_name_oth: "Other(specify)"

	label variable hamlet_name "Enumerator to fill up: Hamlet Name"
	note hamlet_name: "Enumerator to fill up: Hamlet Name"

	label variable saahi_name "Enumerator to fill up: Saahi/Street Name"
	note saahi_name: "Enumerator to fill up: Saahi/Street Name"

	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 501 "Sanjay Naik" 503 "Rajib Panda" 505 "Bibhar Pankaj" 510 "Sarita Bhatra" 519 "Pramodini Gahir" 521 "Ishadatta Pani"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 501 "501" 503 "503" 505 "505" 510 "510" 519 "519" 521 "521"
	label values enum_code enum_code

	label variable hh_code "Assign a number to the household you are visiting for the first time based on ho"
	note hh_code: "Assign a number to the household you are visiting for the first time based on how many you have visited in this village for the first time today. If you are working in the same village as the previous day, use sequential numbers."

	label variable hh_repeat_code "Repeat the number of the household you are visiting"
	note hh_repeat_code: "Repeat the number of the household you are visiting"

	label variable landmark "Can you provide a landmark or description of the house so it can be located late"
	note landmark: "Can you provide a landmark or description of the house so it can be located later?"

	label variable address "Enumerator to ask respondent for address and enter the address"
	note address: "Enumerator to ask respondent for address and enter the address"

	label variable gpslatitude "GPS coordinates (latitude)"
	note gpslatitude: "GPS coordinates (latitude)"

	label variable gpslongitude "GPS coordinates (longitude)"
	note gpslongitude: "GPS coordinates (longitude)"

	label variable gpsaltitude "GPS coordinates (altitude)"
	note gpsaltitude: "GPS coordinates (altitude)"

	label variable gpsaccuracy "GPS coordinates (accuracy)"
	note gpsaccuracy: "GPS coordinates (accuracy)"

	label variable resp_available "Did you find a household to interview?"
	note resp_available: "Did you find a household to interview?"
	label define resp_available 1 "Household available for an interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The family is temporarily unavailable but might be avai" 6 "This is my 3rd re-visit: The revisit within two days is not possible (e.g. all t" 7 "This is my 3rd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable consent "A1) Do I have your permission to proceed with the interview?"
	note consent: "A1) Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable no_consent_reason "A2)Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason: "A2)Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "A2.1) Please specify other"
	note no_consent_oth: "A2.1) Please specify other"

	label variable no_consent_comment "A3) Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "A3) Record any relevant notes if the respondent refused the interview"

	label variable a1_resp_name "A 4) What is your name?"
	note a1_resp_name: "A 4) What is your name?"

	label variable a2_hhmember_count "A5) How many people live in this household including you?"
	note a2_hhmember_count: "A5) How many people live in this household including you?"

	label variable own "A5.1) Do you own any other house excluding the one where you are residing curren"
	note own: "A5.1) Do you own any other house excluding the one where you are residing currently in the village?"
	label define own 1 "Yes" 0 "No"
	label values own own

	label variable otherhous_address "Please tell the address Hamlet name, Saahi name, landmark, House no., village na"
	note otherhous_address: "Please tell the address Hamlet name, Saahi name, landmark, House no., village name)"

	label variable own_screened "A5.1) Do you own any other house excluding the one where you are residing curren"
	note own_screened: "A5.1) Do you own any other house excluding the one where you are residing currently in the village?"
	label define own_screened 1 "Yes" 0 "No"
	label values own_screened own_screened

	label variable otherhous_address_screened "Please tell the address Hamlet name, Saahi name, landmark, House no., village na"
	note otherhous_address_screened: "Please tell the address Hamlet name, Saahi name, landmark, House no., village name)"

	label variable a12_water_source_prim "B1)In the past month, which water source did your household primarily use for dr"
	note a12_water_source_prim: "B1)In the past month, which water source did your household primarily use for drinking and you are currently using it?"
	label define a12_water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" 9 "Borewell operated by electricity/pump" 10 "Household tap connections excluding JJM ( like Swajaldhara, Gram Vikas etc)" -77 "Other"
	label values a12_water_source_prim a12_water_source_prim

	label variable a12_prim_source_oth "B1.1)If Other, please specify:"
	note a12_prim_source_oth: "B1.1)If Other, please specify:"

	label variable change_primary_source "B2)In the past month, did your household change your primary source of drinking "
	note change_primary_source: "B2)In the past month, did your household change your primary source of drinking water?"
	label define change_primary_source 1 "Yes" 0 "No"
	label values change_primary_source change_primary_source

	label variable previous_primary "B3)What was your previous primary source of drinking water?"
	note previous_primary: "B3)What was your previous primary source of drinking water?"
	label define previous_primary 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" 9 "Borewell operated by electricity/pump" 10 "Household tap connections excluding JJM ( like Swajaldhara, Gram Vikas etc)" -77 "Other"
	label values previous_primary previous_primary

	label variable oth_previous_primary "B3.1)If Other, please specify:"
	note oth_previous_primary: "B3.1)If Other, please specify:"

	label variable change_reason_primary_source "B4)Please tell the reason for changing from \${previous_Primary_source_label} to"
	note change_reason_primary_source: "B4)Please tell the reason for changing from \${previous_Primary_source_label} to \${Primary_source_label} in the last one month?"

	label variable oth_change_primary_source "B4.1)If Other, please specify:"
	note oth_change_primary_source: "B4.1)If Other, please specify:"

	label variable a13_water_sec_yn "In the past month, did your household use any sources of drinking water besides "
	note a13_water_sec_yn: "In the past month, did your household use any sources of drinking water besides \${Primary_source_label}?"
	label define a13_water_sec_yn 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values a13_water_sec_yn a13_water_sec_yn

	label variable a13_water_source_sec "B5)In the past month, what other water sources have you used for drinking which "
	note a13_water_source_sec: "B5)In the past month, what other water sources have you used for drinking which you are also using currently?"

	label variable a13_water_sec_oth "B5.1)If Other, please specify:"
	note a13_water_sec_oth: "B5.1)If Other, please specify:"

	label variable change_secondary_source "B6)In the past month, did your household change your secondary source of drinkin"
	note change_secondary_source: "B6)In the past month, did your household change your secondary source of drinking water?"
	label define change_secondary_source 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values change_secondary_source change_secondary_source

	label variable previous_secondary "B7)What was your previous secondary source of drinking water?"
	note previous_secondary: "B7)What was your previous secondary source of drinking water?"
	label define previous_secondary 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" 9 "Borewell operated by electricity/pump" 10 "Household tap connections excluding JJM ( like Swajaldhara, Gram Vikas etc)" -77 "Other"
	label values previous_secondary previous_secondary

	label variable oth_previous_secondary "B7.1)If Other, please specify:"
	note oth_previous_secondary: "B7.1)If Other, please specify:"

	label variable change_reason_secondary "B8)Please tell the reason for changing from \${previous_sec_source_label} to cur"
	note change_reason_secondary: "B8)Please tell the reason for changing from \${previous_sec_source_label} to current sources in the last one month?"

	label variable a13_change_reason_secondary "B8.1)If Other, please specify:"
	note a13_change_reason_secondary: "B8.1)If Other, please specify:"

	label variable a18_jjm_drinking "B9)Generally in the past month, did you use the government provided household ta"
	note a18_jjm_drinking: "B9)Generally in the past month, did you use the government provided household tap (JJM tap) for drinking?"
	label define a18_jjm_drinking 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values a18_jjm_drinking a18_jjm_drinking

	label variable reason_yes_jjm "B10)Why are you using the government provided household tap for drinking purpose"
	note reason_yes_jjm: "B10)Why are you using the government provided household tap for drinking purpose?"

	label variable oth_reason_yes_jjm "B10.1)If Other, please specify:"
	note oth_reason_yes_jjm: "B10.1)If Other, please specify:"

	label variable reason_no_jjm "B11)Why are you not using the government provided household tap for drinking pur"
	note reason_no_jjm: "B11)Why are you not using the government provided household tap for drinking purpose?"

	label variable oth_reason_no_jjm "B11.1)If Other, please specify:"
	note oth_reason_no_jjm: "B11.1)If Other, please specify:"

	label variable any_oth "Is/ Are there any other women of child bearing age in the household that didn't "
	note any_oth: "Is/ Are there any other women of child bearing age in the household that didn't appear in the list above? (between 15-49) years?"
	label define any_oth 1 "Yes" 0 "No"
	label values any_oth any_oth

	label variable how_many_oth "How many such women are in the house?"
	note how_many_oth: "How many such women are in the house?"

	label variable a41_end_comments "A38) Please add any additional comments about this survey."
	note a41_end_comments: "A38) Please add any additional comments about this survey."

	label variable a43_revisit "A43) Please record the following about your visit"
	note a43_revisit: "A43) Please record the following about your visit"
	label define a43_revisit 1 "This is my first visit" 2 "This is my second visit (1st REVISIT)" 3 "This is my third visit (2nd REVISIT)" 4 "This is my 4th visit (3rd REVISIT)"
	label values a43_revisit a43_revisit



	capture {
		foreach rgvar of varlist a3_hhmember_name_* {
			label variable `rgvar' "A6) What is the name of household member \${namenumber}?"
			note `rgvar': "A6) What is the name of household member \${namenumber}?"
		}
	}

	capture {
		foreach rgvar of varlist a4_hhmember_gender_* {
			label variable `rgvar' "A7) What is the gender of \${namefromearlier}?"
			note `rgvar': "A7) What is the gender of \${namefromearlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" 98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a5_hhmember_relation_* {
			label variable `rgvar' "A8) Who is \${namefromearlier} to you ?"
			note `rgvar': "A8) Who is \${namefromearlier} to you ?"
			label define `rgvar' 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" -77 "Other" 999 "Don’t know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a5_relation_oth_* {
			label variable `rgvar' "A9.1) If Other, please specify:"
			note `rgvar': "A9.1) If Other, please specify:"
		}
	}

	capture {
		foreach rgvar of varlist a6_hhmember_age_* {
			label variable `rgvar' "A10) How old is \${namefromearlier} in years?"
			note `rgvar': "A10) How old is \${namefromearlier} in years?"
		}
	}

	capture {
		foreach rgvar of varlist a6_dob_* {
			label variable `rgvar' "A11) What is the date of birth for \${namefromearlier}?"
			note `rgvar': "A11) What is the date of birth for \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist age_accurate_* {
			label variable `rgvar' "A11.1) Is this age imputed or accurate?"
			note `rgvar': "A11.1) Is this age imputed or accurate?"
			label define `rgvar' 1 "Accurate" 2 "Imputed"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist marital_* {
			label variable `rgvar' "Is \${namefromearlier} married?"
			note `rgvar': "Is \${namefromearlier} married?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_* {
			label variable `rgvar' "A12) Is \${namefromearlier} pregnant?"
			note `rgvar': "A12) Is \${namefromearlier} pregnant?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_month_* {
			label variable `rgvar' "A12) How many months pregnant is \${namefromearlier}?"
			note `rgvar': "A12) How many months pregnant is \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist name_pc_* {
			label variable `rgvar' "C1) What is respondent’s name?"
			note `rgvar': "C1) What is respondent’s name?"
			label define `rgvar' 1 "\${fam_name1} and \${fam_age1} years" 2 "\${fam_name2} and \${fam_age2} years" 3 "\${fam_name3} and \${fam_age3} years" 4 "\${fam_name4} and \${fam_age4} years" 5 "\${fam_name5} and \${fam_age5} years" 6 "\${fam_name6} and \${fam_age6} years" 7 "\${fam_name7} and \${fam_age7} years" 8 "\${fam_name8} and \${fam_age8} years" 9 "\${fam_name9} and \${fam_age9} years" 10 "\${fam_name10} and \${fam_age10} years" 11 "\${fam_name11} and \${fam_age11} years" 12 "\${fam_name12} and \${fam_age12} years" 13 "\${fam_name13} and \${fam_age13} years" 14 "\${fam_name14} and \${fam_age14} years" 15 "\${fam_name15} and \${fam_age15} years" 16 "\${fam_name16} and \${fam_age16} years" 17 "\${fam_name17} and \${fam_age17} years" 18 "\${fam_name18} and \${fam_age18} years" 19 "\${fam_name19} and \${fam_age19} years" 20 "\${fam_name20} and \${fam_age20} years"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist resp_avail_pc_* {
			label variable `rgvar' "C2) Did you find \${name_pc_earlier} to interview?"
			note `rgvar': "C2) Did you find \${name_pc_earlier} to interview?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Family has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: The respondent is temporarily unavailable but might be " 5 "This is my 2nd re-visit: The respondent is temporarily unavailable but might be " 6 "This is my 3rd re-visit: The revisit within two days is not possible (e.g. all t" 7 "This is my 3rd re-visit: The respondent is temporarily unavailable (Please leave"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist consent_pc_* {
			label variable `rgvar' "C3)Do I have your permission to proceed with the interview?"
			note `rgvar': "C3)Do I have your permission to proceed with the interview?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist no_consent_reason_pc_* {
			label variable `rgvar' "C4) Can you tell me why you do not want to participate in the survey?"
			note `rgvar': "C4) Can you tell me why you do not want to participate in the survey?"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_oth_* {
			label variable `rgvar' "C4.1) Please specify other"
			note `rgvar': "C4.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_comment_* {
			label variable `rgvar' "C4.2) Record any relevant notes if the respondent refused the interview"
			note `rgvar': "C4.2) Record any relevant notes if the respondent refused the interview"
		}
	}

	capture {
		foreach rgvar of varlist residence_yesno_pc_* {
			label variable `rgvar' "C5) Is this \${name_pc_earlier} ’s usual residence?"
			note `rgvar': "C5) Is this \${name_pc_earlier} ’s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_* {
			label variable `rgvar' "C6) Which village is \${name_pc_earlier} ’s current permanent residence in?"
			note `rgvar': "C6) Which village is \${name_pc_earlier} ’s current permanent residence in?"
			label define `rgvar' 30202 "BK Padar" 30701 "Gopi Kankubadi" 50501 "Nathma" 50402 "Kuljing" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_oth_* {
			label variable `rgvar' "C6.1) Please specify other"
			note `rgvar': "C6.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_* {
			label variable `rgvar' "C7) How long is \${name_pc_earlier} planning to stay here (at the house where th"
			note `rgvar': "C7) How long is \${name_pc_earlier} planning to stay here (at the house where the survey is being conducted) ? Please enter in months"
			label define `rgvar' 1 "Days" 2 "Months"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_days_* {
			label variable `rgvar' "Record in Days"
			note `rgvar': "Record in Days"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_months_* {
			label variable `rgvar' "Record in Months"
			note `rgvar': "Record in Months"
		}
	}

	capture {
		foreach rgvar of varlist vill_residence_* {
			label variable `rgvar' "C8) Was \${village_name_res} your permanent residence at any time in the last 5 "
			note `rgvar': "C8) Was \${village_name_res} your permanent residence at any time in the last 5 years?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist last_5_years_pregnant_* {
			label variable `rgvar' "C9)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			note `rgvar': "C9)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_living_* {
			label variable `rgvar' "C10) Do you have any children under 5 years of age to whom you have given birth "
			note `rgvar': "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_living_num_* {
		    label drop `rgvar'
			label variable `rgvar' "C11) How many children born since January 1, 2019 live with you?"
			note `rgvar': "C11) How many children born since January 1, 2019 live with you?"
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_* {
			label variable `rgvar' "C12) Do you have any children born since January 1, 2019 to whom you have given "
			note `rgvar': "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_num_* {
			label drop `rgvar'
			label variable `rgvar' "C13) How many children born since January 1, 2019 are alive but do not live with"
			note `rgvar': "C13) How many children born since January 1, 2019 are alive but do not live with you?"
		}
	}

	capture {
		foreach rgvar of varlist child_stillborn_* {
			label variable `rgvar' "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
			note `rgvar': "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_stillborn_num_* {
			label drop `rgvar'
			label variable `rgvar' "C15) How many children born since January 1, 2019 were stillborn?"
			note `rgvar': "C15) How many children born since January 1, 2019 were stillborn?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_24_* {
			label variable `rgvar' "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
			note `rgvar': "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_* {
		    label drop `rgvar'
			label variable `rgvar' "C17) How many children born since January 1, 2019 have died within 24 hours?"
			note `rgvar': "C17) How many children born since January 1, 2019 have died within 24 hours?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_* {
			label variable `rgvar' "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
			note `rgvar': "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_more24_* {
			label drop `rgvar'
			label variable `rgvar' "C19) How many children born since January 1, 2019 have died after 24 hours from "
			note `rgvar': "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"
		}
	}

	capture {
		foreach rgvar of varlist name_child_* {
			label variable `rgvar' "C20) What is the full name of the child that died?"
			note `rgvar': "C20) What is the full name of the child that died?"
		}
	}

	capture {
		foreach rgvar of varlist age_child_* {
			label variable `rgvar' "C21) What was their age at the time of death? (select unit)"
			note `rgvar': "C21) What was their age at the time of death? (select unit)"
		}
	}

	capture {
		foreach rgvar of varlist unit_child_* {
			label variable `rgvar' "C22) Please select unit in days/ months/ years."
			note `rgvar': "C22) Please select unit in days/ months/ years."
			label define `rgvar' 1 "Months" 2 "Days" 3 "Years" 98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist date_birth_* {
			label variable `rgvar' "C23) What was their date of birth?"
			note `rgvar': "C23) What was their date of birth?"
		}
	}

	capture {
		foreach rgvar of varlist date_death_* {
			label variable `rgvar' "C24) What was the date of their death?"
			note `rgvar': "C24) What was the date of their death?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_* {
			label variable `rgvar' "C25) What did \${name_child_earlier} die from?"
			note `rgvar': "C25) What did \${name_child_earlier} die from?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_oth_* {
			label variable `rgvar' "C25.1) Please specify other"
			note `rgvar': "C25.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_diagnosed_* {
			label variable `rgvar' "C26) Was this cause of death diagonsed by any health official?"
			note `rgvar': "C26) Was this cause of death diagonsed by any health official?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cause_death_str_* {
			label variable `rgvar' "C27) In your own words, can you describe what was the cause of death?"
			note `rgvar': "C27) In your own words, can you describe what was the cause of death?"
		}
	}

	capture {
		foreach rgvar of varlist confirm_* {
			label variable `rgvar' "Please confirm that \${name_pc_earlier} had \${child_living_num} children who we"
			note `rgvar': "Please confirm that \${name_pc_earlier} had \${child_living_num} children who were born since 1 January 2019 and living with them, \${child_stillborn_num} still births and \${child_died_num} children who were born but later died. Is this information complete and correct?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist correct_* {
			label variable `rgvar' "C28)Have you corrected respondent's details if they were incorrect earlier?"
			note `rgvar': "C28)Have you corrected respondent's details if they were incorrect earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist translator_* {
			label variable `rgvar' "C29)Was a translator used in the survey?"
			note `rgvar': "C29)Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist name_pc_sc_* {
			label variable `rgvar' "C30) What is respondent’s name?"
			note `rgvar': "C30) What is respondent’s name?"
			label define `rgvar' 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist resp_avail_pc_sc_* {
			label variable `rgvar' "C31) Did you find \${name_pc_earlier_sc} to interview?"
			note `rgvar': "C31) Did you find \${name_pc_earlier_sc} to interview?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Family has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: The respondent is temporarily unavailable but might be " 5 "This is my 2nd re-visit: The respondent is temporarily unavailable but might be " 6 "This is my 3rd re-visit: The revisit within two days is not possible (e.g. all t" 7 "This is my 3rd re-visit: The respondent is temporarily unavailable (Please leave"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist consent_pc_sc_* {
			label variable `rgvar' "C32)Do I have your permission to proceed with the interview?"
			note `rgvar': "C32)Do I have your permission to proceed with the interview?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist no_consent_reason_pc_sc_* {
			label variable `rgvar' "C33) Can you tell me why you do not want to participate in the survey?"
			note `rgvar': "C33) Can you tell me why you do not want to participate in the survey?"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_oth_sc_* {
			label variable `rgvar' "C33.1) Please specify other"
			note `rgvar': "C33.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_comment_sc_* {
			label variable `rgvar' "C33.2) Record any relevant notes if the respondent refused the interview"
			note `rgvar': "C33.2) Record any relevant notes if the respondent refused the interview"
		}
	}

	capture {
		foreach rgvar of varlist residence_yesno_pc_sc_* {
			label variable `rgvar' "C34) Is this \${name_pc_earlier_sc} ’s usual residence?"
			note `rgvar': "C34) Is this \${name_pc_earlier_sc} ’s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_sc_* {
			label variable `rgvar' "C35) Which village is \${name_pc_earlier_sc} ’s current permanent residence in?"
			note `rgvar': "C35) Which village is \${name_pc_earlier_sc} ’s current permanent residence in?"
			label define `rgvar' 30202 "BK Padar" 30701 "Gopi Kankubadi" 50501 "Nathma" 50402 "Kuljing" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_oth_sc_* {
			label variable `rgvar' "C35.1) Please specify other"
			note `rgvar': "C35.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_sc_* {
			label variable `rgvar' "C36) How long is \${name_pc_earlier_sc} planning to stay here (at the house wher"
			note `rgvar': "C36) How long is \${name_pc_earlier_sc} planning to stay here (at the house where the survey is being conducted) ? Please enter in months"
			label define `rgvar' 1 "Days" 2 "Months"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_days_sc_* {
			label variable `rgvar' "Record in Days"
			note `rgvar': "Record in Days"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_months_sc_* {
			label variable `rgvar' "Record in Months"
			note `rgvar': "Record in Months"
		}
	}

	capture {
		foreach rgvar of varlist vill_residence_sc_* {
			label variable `rgvar' "C37) Was \${village_name_res_sc} your permanent residence at any time in the las"
			note `rgvar': "C37) Was \${village_name_res_sc} your permanent residence at any time in the last 5 years?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist last_5_years_pregnant_sc_* {
			label variable `rgvar' "C38)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			note `rgvar': "C38)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_living_sc_* {
			label variable `rgvar' "P9) Do you have any children under 5 years of age to whom you have given birth s"
			note `rgvar': "P9) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
			
		}
	}

	capture {
		foreach rgvar of varlist child_living_num_sc_* {
		    label drop `rgvar'
			label variable `rgvar' "P10) How many children born since January 1, 2019 live with you?"
			note `rgvar': "P10) How many children born since January 1, 2019 live with you?"
			
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_sc_* {
			label variable `rgvar' "P11) Do you have any children born since January 1, 2019 to whom you have given "
			note `rgvar': "P11) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_num_sc_* {
		    label drop `rgvar'
			label variable `rgvar' "P12) How many children born since January 1, 2019 are alive but do not live with"
			note `rgvar': "P12) How many children born since January 1, 2019 are alive but do not live with you?"
			
		}
	}


	capture {
		foreach rgvar of varlist child_stillborn_sc_* {
			label variable `rgvar' "P13) Have you given birth to a child who was stillborn since January 1, 2019? I "
			note `rgvar': "P13) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_stillborn_num_sc_* {
		    label drop `rgvar'
			label variable `rgvar' "P14) How many children born since January 1, 2019 were stillborn?"
			note `rgvar': "P14) How many children born since January 1, 2019 were stillborn?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_24_sc_* {
			label variable `rgvar' "P15) Have you given birth to a child since January 1, 2019 who was born alive bu"
			note `rgvar': "P15) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_sc_* {
		    label drop `rgvar'
			label variable `rgvar' "P16) How many children born since January 1, 2019 have died within 24 hours?"
			note `rgvar': "P16) How many children born since January 1, 2019 have died within 24 hours?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_sc_* {
			label variable `rgvar' "P16.1) Are there any children born since January 1, 2019 who have died after 24 "
			note `rgvar': "P16.1) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_more24_sc_* {
	       	label drop `rgvar'
			label variable `rgvar' "P16.2) How many children born since January 1, 2019 have died after 24 hours fro"
			note `rgvar': "P16.2) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"
		}
	}

	capture {
		foreach rgvar of varlist name_child_sc_* {
			label variable `rgvar' "P17) What is the full name of the child that died?"
			note `rgvar': "P17) What is the full name of the child that died?"
		}
	}

	capture {
		foreach rgvar of varlist age_child_sc_* {
			label variable `rgvar' "P18) What was their age at the time of death? (select unit)"
			note `rgvar': "P18) What was their age at the time of death? (select unit)"
		}
	}

	capture {
		foreach rgvar of varlist unit_child_sc_* {
			label variable `rgvar' "P18.1) Please select unit in days/ months/ years."
			note `rgvar': "P18.1) Please select unit in days/ months/ years."
			label define `rgvar' 1 "Months" 2 "Days" 3 "Years" 98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist date_birth_sc_* {
			label variable `rgvar' "P19) What was their date of birth?"
			note `rgvar': "P19) What was their date of birth?"
		}
	}

	capture {
		foreach rgvar of varlist date_death_sc_* {
			label variable `rgvar' "P20) What was the date of their death?"
			note `rgvar': "P20) What was the date of their death?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_sc_* {
			label variable `rgvar' "P21) What did \${name_child_earlier_sc} die from?"
			note `rgvar': "P21) What did \${name_child_earlier_sc} die from?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_oth_sc_* {
			label variable `rgvar' "P21.1) Please specify other"
			note `rgvar': "P21.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_diagnosed_sc_* {
			label variable `rgvar' "P21.2) Was this cause of death diagonsed by any health official?"
			note `rgvar': "P21.2) Was this cause of death diagonsed by any health official?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cause_death_str_sc_* {
			label variable `rgvar' "P22) In your own words, can you describe what was the cause of death?"
			note `rgvar': "P22) In your own words, can you describe what was the cause of death?"
		}
	}

	capture {
		foreach rgvar of varlist confirm_sc_* {
			label variable `rgvar' "P23) Please confirm that \${name_pc_earlier_sc} had \${child_living_num_sc} chil"
			note `rgvar': "P23) Please confirm that \${name_pc_earlier_sc} had \${child_living_num_sc} children who were born since 1 January 2019 and living with them, \${child_stillborn_num_sc} still births and \${child_died_num_sc} children who were born but later died. Is this information complete and correct?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist correct_sc_* {
			label variable `rgvar' "Have you corrected respondent's details if they were incorrect earlier?"
			note `rgvar': "Have you corrected respondent's details if they were incorrect earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist translator_sc_* {
			label variable `rgvar' "Was a translator used in the survey?"
			note `rgvar': "Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist name_pc_oth_* {
			label variable `rgvar' "C30) What is respondent’s name?"
			note `rgvar': "C30) What is respondent’s name?"
		}
	}

	capture {
		foreach rgvar of varlist resp_avail_pc_oth_* {
			label variable `rgvar' "C31) Did you find \${name_pc_earlier_oth} to interview?"
			note `rgvar': "C31) Did you find \${name_pc_earlier_oth} to interview?"
			label define `rgvar' 1 "Respondent available for an interview" 2 "Family has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: The respondent is temporarily unavailable but might be " 5 "This is my 2nd re-visit: The respondent is temporarily unavailable but might be " 6 "This is my 3rd re-visit: The revisit within two days is not possible (e.g. all t" 7 "This is my 3rd re-visit: The respondent is temporarily unavailable (Please leave"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist consent_pc_oth_* {
			label variable `rgvar' "C32)Do I have your permission to proceed with the interview?"
			note `rgvar': "C32)Do I have your permission to proceed with the interview?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist no_consent_reason_pc_oth_* {
			label variable `rgvar' "C33) Can you tell me why you do not want to participate in the survey?"
			note `rgvar': "C33) Can you tell me why you do not want to participate in the survey?"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_oth_oth_* {
			label variable `rgvar' "C33.1) Please specify other"
			note `rgvar': "C33.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist no_consent_pc_comment_oth_* {
			label variable `rgvar' "C33.2) Record any relevant notes if the respondent refused the interview"
			note `rgvar': "C33.2) Record any relevant notes if the respondent refused the interview"
		}
	}

	capture {
		foreach rgvar of varlist residence_yesno_pc_oth_* {
			label variable `rgvar' "C34) Is this \${name_pc_earlier_oth} ’s usual residence?"
			note `rgvar': "C34) Is this \${name_pc_earlier_oth} ’s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_oth_add_* {
			label variable `rgvar' "C35) Which village is \${name_pc_earlier_oth} ’s current permanent residence in?"
			note `rgvar': "C35) Which village is \${name_pc_earlier_oth} ’s current permanent residence in?"
			label define `rgvar' 30202 "BK Padar" 30701 "Gopi Kankubadi" 50501 "Nathma" 50402 "Kuljing" -77 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_pc_oth_oth_* {
			label variable `rgvar' "C35.1) Please specify other"
			note `rgvar': "C35.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_oth_* {
			label variable `rgvar' "C36) How long is \${name_pc_earlier_oth} planning to stay here (at the house whe"
			note `rgvar': "C36) How long is \${name_pc_earlier_oth} planning to stay here (at the house where the survey is being conducted) ? Please enter in months"
			label define `rgvar' 1 "Days" 2 "Months"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_days_oth_* {
			label variable `rgvar' "Record in Days"
			note `rgvar': "Record in Days"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_months_oth_* {
			label variable `rgvar' "Record in Months"
			note `rgvar': "Record in Months"
		}
	}

	capture {
		foreach rgvar of varlist last_5_years_pregnant_oth_* {
			label variable `rgvar' "C38)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			note `rgvar': "C38)Have you ever been pregnant in the last 5 years since January 1, 2019?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_living_oth_* {
			label variable `rgvar' "P9) Do you have any children under 5 years of age to whom you have given birth s"
			note `rgvar': "P9) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_living_num_oth_* {
			label variable `rgvar' "P10) How many children born since January 1, 2019 live with you?"
			note `rgvar': "P10) How many children born since January 1, 2019 live with you?"
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_oth_* {
			label variable `rgvar' "P11) Do you have any children born since January 1, 2019 to whom you have given "
			note `rgvar': "P11) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_notliving_num_oth_* {
			label variable `rgvar' "P12) How many children born since January 1, 2019 are alive but do not live with"
			note `rgvar': "P12) How many children born since January 1, 2019 are alive but do not live with you?"
		}
	}

	capture {
		foreach rgvar of varlist child_stillborn_oth_* {
			label variable `rgvar' "P13) Have you given birth to a child who was stillborn since January 1, 2019? I "
			note `rgvar': "P13) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_stillborn_num_oth_* {
			label variable `rgvar' "P14) How many children born since January 1, 2019 were stillborn?"
			note `rgvar': "P14) How many children born since January 1, 2019 were stillborn?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_24_oth_* {
			label variable `rgvar' "P15) Have you given birth to a child since January 1, 2019 who was born alive bu"
			note `rgvar': "P15) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_oth_* {
			label variable `rgvar' "P16) How many children born since January 1, 2019 have died within 24 hours?"
			note `rgvar': "P16) How many children born since January 1, 2019 have died within 24 hours?"
		}
	}

	capture {
		foreach rgvar of varlist child_alive_died_oth_* {
			label variable `rgvar' "P16.1) Are there any children born since January 1, 2019 who have died after 24 "
			note `rgvar': "P16.1) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist child_died_num_more24_oth_* {
			label variable `rgvar' "P16.2) How many children born since January 1, 2019 have died after 24 hours fro"
			note `rgvar': "P16.2) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"
		}
	}

	capture {
		foreach rgvar of varlist name_child_oth_* {
			label variable `rgvar' "P17) What is the full name of the child that died?"
			note `rgvar': "P17) What is the full name of the child that died?"
		}
	}

	capture {
		foreach rgvar of varlist age_child_oth_* {
			label variable `rgvar' "P18) What was their age at the time of death? (select unit)"
			note `rgvar': "P18) What was their age at the time of death? (select unit)"
		}
	}

	capture {
		foreach rgvar of varlist unit_child_oth_* {
			label variable `rgvar' "P18.1) Please select unit in days/ months/ years."
			note `rgvar': "P18.1) Please select unit in days/ months/ years."
			label define `rgvar' 1 "Months" 2 "Days" 3 "Years" 98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist date_birth_oth_* {
			label variable `rgvar' "P19) What was their date of birth?"
			note `rgvar': "P19) What was their date of birth?"
		}
	}

	capture {
		foreach rgvar of varlist date_death_oth_* {
			label variable `rgvar' "P20) What was the date of their death?"
			note `rgvar': "P20) What was the date of their death?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_oth_add_* {
			label variable `rgvar' "P21) What did \${name_child_earlier_oth} die from?"
			note `rgvar': "P21) What did \${name_child_earlier_oth} die from?"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_oth_oth_* {
			label variable `rgvar' "P21.1) Please specify other"
			note `rgvar': "P21.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist cause_death_diagnosed_oth_* {
			label variable `rgvar' "P21.2) Was this cause of death diagonsed by any health official?"
			note `rgvar': "P21.2) Was this cause of death diagonsed by any health official?"
			label define `rgvar' 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist cause_death_str_oth_* {
			label variable `rgvar' "P22) In your own words, can you describe what was the cause of death?"
			note `rgvar': "P22) In your own words, can you describe what was the cause of death?"
		}
	}

	capture {
		foreach rgvar of varlist confirm_oth_* {
			label variable `rgvar' "P23) Please confirm that \${name_pc_earlier_oth} had \${child_living_num_oth} ch"
			note `rgvar': "P23) Please confirm that \${name_pc_earlier_oth} had \${child_living_num_oth} children who were born since 1 January 2019 and living with them, \${child_stillborn_num_oth} still births and \${child_died_num_oth} children who were born but later died. Is this information complete and correct?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist correct_oth_* {
			label variable `rgvar' "Have you corrected respondent's details if they were incorrect earlier?"
			note `rgvar': "Have you corrected respondent's details if they were incorrect earlier?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_auto_2latitude_* {
			label variable `rgvar' "Record GPS (latitude)"
			note `rgvar': "Record GPS (latitude)"
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_auto_2longitude_* {
			label variable `rgvar' "Record GPS (longitude)"
			note `rgvar': "Record GPS (longitude)"
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_auto_2altitude_* {
			label variable `rgvar' "Record GPS (altitude)"
			note `rgvar': "Record GPS (altitude)"
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_auto_2accuracy_* {
			label variable `rgvar' "Record GPS (accuracy)"
			note `rgvar': "Record GPS (accuracy)"
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_handlongitude_* {
			label variable `rgvar' "Please put the longitude of the household location"
			note `rgvar': "Please put the longitude of the household location"
		}
	}

	capture {
		foreach rgvar of varlist a40_gps_handlatitude_* {
			label variable `rgvar' "Please put the latitude of the household location"
			note `rgvar': "Please put the latitude of the household location"
		}
	}

	capture {
		foreach rgvar of varlist a42_survey_accompany_num_* {
			label variable `rgvar' "A42) Please record the number of people who attended or accompanied this intervi"
			note `rgvar': "A42) Please record the number of people who attended or accompanied this interview aside from yourself or household member you are interviewing"
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
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" 98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist translator_oth_* {
			label variable `rgvar' "Was a translator used in the survey?"
			note `rgvar': "Was a translator used in the survey?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist incentive_* {
			label variable `rgvar' "Has the incentive been given or not?"
			note `rgvar': "Has the incentive been given or not?"
			label define `rgvar' 1 "Yes" 0 "No"
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
*   Corrections file path and filename:  Mortality Survey_corrections.csv
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
