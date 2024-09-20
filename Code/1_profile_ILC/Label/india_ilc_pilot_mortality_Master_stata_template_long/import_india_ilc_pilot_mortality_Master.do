* import_india_ilc_pilot_mortality_Master.do
*
* 	Imports and aggregates "Mortality Survey" (ID: india_ilc_pilot_mortality_Master) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey.dta"
*
*	Output by SurveyCTO September 20, 2024 8:28 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5"
local text_fields3 "r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17"
local text_fields4 "r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11"
local text_fields5 "cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4"
local text_fields6 "cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16"
local text_fields7 "cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 r_cen_a12_water_source_prim cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12"
local text_fields8 "cen_children_below12 cen_num_childbelow12 child_bearing_list_preload scenario info_update enum_name_label_sc block_name_oth gp_name_oth village_name_oth hamlet_name saahi_name hh_code_format_sc1"
local text_fields9 "unique_id_sc1 landmark address enum_name_label no_consent_reason no_consent_oth no_consent_comment consent_dur_end a1_resp_name otherhous_address hh_member_names_count fam_name1 fam_name2 fam_name3"
local text_fields10 "fam_name4 fam_name5 fam_name6 fam_name7 fam_name8 fam_name9 fam_name10 fam_name11 fam_name12 fam_name13 fam_name14 fam_name15 fam_name16 fam_name17 fam_name18 fam_name19 fam_name20 fam_age1 fam_age2"
local text_fields11 "fam_age3 fam_age4 fam_age5 fam_age6 fam_age7 fam_age8 fam_age9 fam_age10 fam_age11 fam_age12 fam_age13 fam_age14 fam_age15 fam_age16 fam_age17 fam_age18 fam_age19 fam_age20 female_above12"
local text_fields12 "female_15to49 num_female_15to49 adults_hh_above12 num_adultsabove12 children_below12 num_childbelow12 sectionb_dur_end child_bearing_list otherhous_address_screened a12_prim_source_oth"
local text_fields13 "primary_source_label oth_previous_primary previous_primary_source_label change_reason_primary_source oth_change_primary_source a13_water_source_sec a13_water_sec_oth oth_previous_secondary"
local text_fields14 "previous_sec_source_label change_reason_secondary a13_change_reason_secondary reason_yes_jjm oth_reason_yes_jjm reason_no_jjm oth_reason_no_jjm women_child_bearing_count women_child_bearing_sc_count"
local text_fields15 "women_child_bearing_oth_count a41_end_comments instanceid instancename"
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

	label variable a10_hhhead "A10) What is the name of the head of household? (Household head can be either ma"
	note a10_hhhead: "A10) What is the name of the head of household? (Household head can be either male or female)"
	label define a10_hhhead 1 "\${fam_name1}" 2 "\${fam_name2}" 3 "\${fam_name3}" 4 "\${fam_name4}" 5 "\${fam_name5}" 6 "\${fam_name6}" 7 "\${fam_name7}" 8 "\${fam_name8}" 9 "\${fam_name9}" 10 "\${fam_name10}" 11 "\${fam_name11}" 12 "\${fam_name12}" 13 "\${fam_name13}" 14 "\${fam_name14}" 15 "\${fam_name15}" 16 "\${fam_name16}" 17 "\${fam_name17}" 18 "\${fam_name18}" 19 "\${fam_name19}" 20 "\${fam_name20}"
	label values a10_hhhead a10_hhhead

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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey_corrections.csv
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

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist-women_child_bearing.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist_oth-women_child_bearing_oth.do"

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist_sc-women_child_bearing_sc.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-roster_sc_1_2_3-HH_member_names.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey-consented_pc-start_5_years_pregnant-child_died_repeat.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-child_died_repeat_oth.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-survey_member_names.do"
do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_sc-consented_pc_sc-start_5_years_pregnant_sc-child_died_repeat_sc.do"
