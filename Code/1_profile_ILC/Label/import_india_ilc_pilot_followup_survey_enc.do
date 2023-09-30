* import_india_ilc_pilot_followup_survey_enc.do
*
* 	Imports and aggregates "Baseline follow up survey" (ID: india_ilc_pilot_followup_survey_enc) data.
*
*	Inputs:  "Baseline follow up survey_WIDE.csv"
*	Outputs: "Baseline follow up survey.dta"
*

*	Output by SurveyCTO September 29, 2023 6:16 PM.


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
local csvfile "Baseline follow up survey_WIDE.csv"
local dtafile "Baseline follow up survey.dta"
local corrfile "Baseline follow up survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 s_blwq r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name info_update enum_name_label duration_locatehh reasons_no_consent no_consent_oth"
local text_fields3 "duration_consent water_prim_oth primary_water_label liter_estimation_count container_nmbr_* water_treat_type water_treat_when water_treat_when_oth water_stored_freq_oth duration_seca"
local text_fields4 "tap_supply_freq_oth tap_use tap_use_oth tap_function_reason tap_function_reason_oth tap_use_future_oth duration_secb tap_taste_desc_oth tap_smell_oth tap_color_oth tap_trust_fu tap_trust_oth"
local text_fields5 "duration_secc collect_resp treat_resp duration_secd unique_id_3_digit_wt stored_bag_source_oth no_stored_bag no_chlorine_stored no_running_bag no_tap_reason duration_sece overall_comment duration_end"
local text_fields6 "instanceid instancename"
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
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
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
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_name_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round: \${R_Cen_a1_resp_name} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
	label define noteconf1 1 "I am visiting the correct household and the information is correct" 2 "I am visiting the correct household but the information needs to be updated" 3 "The household I am visiting does not corresponds to the confirmation info."
	label values noteconf1 noteconf1

	label variable info_update "Please describe the information need to be updated here."
	note info_update: "Please describe the information need to be updated here."

	label variable replacement "Is this a replacement household?"
	note replacement: "Is this a replacement household?"
	label define replacement 1 "Yes" 0 "No"
	label values replacement replacement

	label variable replacement_id_1 "Record the first 5 digit"
	note replacement_id_1: "Record the first 5 digit"

	label variable replacement_id_2 "Record the middle 3 digit"
	note replacement_id_2: "Record the middle 3 digit"

	label variable replacement_id_3 "Record the last 3 digit"
	note replacement_id_3: "Record the last 3 digit"

	label variable enum_name "Enumerator name: Please select from the drop-down list"
	note enum_name: "Enumerator name: Please select from the drop-down list"
	label define enum_name 101 "Sanjay Naik" 102 "Susanta Kumar Mahanta" 103 "Rajib Panda" 104 "Santosh Kumar Das" 105 "Bibhar Pankaj" 106 "Madhusmita Samal" 107 "Rekha Behera" 108 "Sanjukta Chichuan" 109 "Swagatika Behera" 110 "Sarita Bhatra" 111 "Abhishek Rath" 112 "Binod Kumar Mohanandia" 113 "Mangulu Bagh" 114 "Padman Bhatra" 115 "Kuna Charan Naik" 116 "Sushil Kumar Pani" 117 "Jitendra Bagh" 118 "Rajeswar Digal" 119 "Pramodini Gahir" 120 "Manas Ranjan Parida" 121 "Ishadatta Pani"
	label values enum_name enum_name

	label variable resp_available "Did you find a household to interview?"
	note resp_available: "Did you find a household to interview?"
	label define resp_available 1 "Household available for interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible (e.g. all t" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable reasons_no_consent "B1) Can you tell me why you do not want to participate in the survey?"
	note reasons_no_consent: "B1) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "B1.1) Please specify other"
	note no_consent_oth: "B1.1) Please specify other"

	label variable water_source_prim "W1) Which water source do you primarily use for drinking?"
	note water_source_prim: "W1) Which water source do you primarily use for drinking?"
	label define water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private Surface well" -77 "Other"
	label values water_source_prim water_source_prim

	label variable water_prim_oth "W1.2) Please specify other"
	note water_prim_oth: "W1.2) Please specify other"

	label variable water_sec_yn "W2) In the past month, did your household use any sources of water for drinking "
	note water_sec_yn: "W2) In the past month, did your household use any sources of water for drinking besides the one you already mentioned?"
	label define water_sec_yn 1 "Yes" 0 "No" 999 "Don't know"
	label values water_sec_yn water_sec_yn

	label variable quant "W2) How much of your drinking water in the past one week came from your primary "
	note quant: "W2) How much of your drinking water in the past one week came from your primary drinking water source: (\${primary_water_label})?"

	label define quant 1 "All of it" 2 "Most of it" 3 "Half of it" 4 "Little of it" 5 "None of it" 999 "Don’t know"

	label values quant quant

	label variable quant_containers "W3) How many containers do you collect drinking water in"
	note quant_containers: "W3) How many containers do you collect drinking water in"

	label variable water_treat "W6) Do you ever do anything to the water from your primary drinking water source"
	note water_treat: "W6) Do you ever do anything to the water from your primary drinking water source (\${primary_water_label} ) to make it safe before drinking it?"
	label define water_treat 1 "Yes" 0 "No" 999 "Don't know"
	label values water_treat water_treat

	label variable water_stored "W7) Is the water stored currently in the house treated?"
	note water_stored: "W7) Is the water stored currently in the house treated?"
	label define water_stored 1 "Yes" 2 "No" 3 "No stored water currently" 999 "Don't Know"
	label values water_stored water_stored

	label variable water_treat_type "W8) What do you do to the water to make it safe for drinking?"
	note water_treat_type: "W8) What do you do to the water to make it safe for drinking?"

	label variable water_treat_when "W9) When do you make the water from your primary drinking water source (\${prima"
	note water_treat_when: "W9) When do you make the water from your primary drinking water source (\${primary_water_label} ) safe before drinking it?"

	label variable water_treat_when_oth "W9.1) Please specify other:"
	note water_treat_when_oth: "W9.1) Please specify other:"

	label variable water_stored_freq "W10) How often do you make the water currently stored at home safe for drinking?"
	note water_stored_freq: "W10) How often do you make the water currently stored at home safe for drinking?"
	label define water_stored_freq 1 "Once at the time of storing" 2 "Every time the stored water is used" 3 "When the water looks smelly or dirty" 4 "When kids/old people fall sick" 5 "In the monsoons" 6 "In the summers" 7 "In the winters" -77 "Others"
	label values water_stored_freq water_stored_freq

	label variable water_stored_freq_oth "W10.1) Please specify other:"
	note water_stored_freq_oth: "W10.1) Please specify other:"

	label variable tap_supply_freq "G1) How often is water supplied from the government provided tap?"
	note tap_supply_freq: "G1) How often is water supplied from the government provided tap?"
	label define tap_supply_freq 1 "Daily" 2 "Few days in a week" 3 "Once a week" 4 "Few times in a month" 5 "Once a month" 6 "No fixed schedule" -77 "Other" 999 "Don't know" -98 "Refused to answer"
	label values tap_supply_freq tap_supply_freq

	label variable tap_supply_freq_oth "G1.1) Please specify other"
	note tap_supply_freq_oth: "G1.1) Please specify other"

	label variable tap_supply_daily "G2) How many times in a day is water supplied from the government provided house"
	note tap_supply_daily: "G2) How many times in a day is water supplied from the government provided household tap (on days that the water is supplied from the taps)?"

	label variable tap_use "G3) For what purposes do you use water collected from the government provided ho"
	note tap_use: "G3) For what purposes do you use water collected from the government provided household taps?"

	label variable tap_use_oth "G3.1) Please specify other"
	note tap_use_oth: "G3.1) Please specify other"

	label variable tap_use_drinking "G4) When was the last time you collected water from the government provided hous"
	note tap_use_drinking: "G4) When was the last time you collected water from the government provided household taps for drinking purposes?"
	label define tap_use_drinking 1 "Today" 2 "Yesterday" 3 "Earlier this week" 4 "Earlier this month" 5 "Not used for drinking" -77 "Other"
	label values tap_use_drinking tap_use_drinking

	label variable tap_function "G5) In the last two weeks, have you tried to collect water from the government p"
	note tap_function: "G5) In the last two weeks, have you tried to collect water from the government provided household tap and it has not worked?"
	label define tap_function 1 "Yes" 0 "No" 999 "Don't know"
	label values tap_function tap_function

	label variable tap_function_reason "G6) Why was the government provided household tap not working?"
	note tap_function_reason: "G6) Why was the government provided household tap not working?"

	label variable tap_function_reason_oth "G6.1) Please specify other"
	note tap_function_reason_oth: "G6.1) Please specify other"

	label variable tap_use_future "G7) How likely are you to use/continue using the government provided household t"
	note tap_use_future: "G7) How likely are you to use/continue using the government provided household tap for drinking in the future?"
	label define tap_use_future 1 "Very likely" 2 "Somewhat likely" 3 "Neither likely nor unlikely" 4 "Somewhat Unlikely" 5 "Very unlikely"
	label values tap_use_future tap_use_future

	label variable tap_use_discontinue "G8) Can you provide any reasons for why you would not continue using the governm"
	note tap_use_discontinue: "G8) Can you provide any reasons for why you would not continue using the government provided household tap in the future?"
	label define tap_use_discontinue 1 "Water supply is not regular" 2 "Water supply is not sufficient" 3 "Water is muddy/ silty" 4 "Water smells or tastes of bleach" -77 "Other" 999 "Don't know"
	label values tap_use_discontinue tap_use_discontinue

	label variable tap_use_future_oth "G8.1) Please specify other"
	note tap_use_future_oth: "G8.1) Please specify other"

	label variable tap_taste_satisfied "C2) How satisfied are you with the taste of water from the government provided h"
	note tap_taste_satisfied: "C2) How satisfied are you with the taste of water from the government provided household tap?"
	label define tap_taste_satisfied 1 "Very satisfied" 2 "Satisfied" 3 "Neither satisfied nor dissatisfied" 4 "Dissatisfied" 5 "Very dissatisfied" 999 "Don't know"
	label values tap_taste_satisfied tap_taste_satisfied

	label variable tap_taste_desc "C3) How would you describe the taste of the water from the government provided h"
	note tap_taste_desc: "C3) How would you describe the taste of the water from the government provided household tap?"
	label define tap_taste_desc 1 "Good" 2 "Medicine or chemical" 3 "Metal" 4 "Salty" 5 "Bleach/chlorine (includes WaterGuard)" 999 "Don't know" -77 "Other"
	label values tap_taste_desc tap_taste_desc

	label variable tap_taste_desc_oth "C3.1) Please specify other"
	note tap_taste_desc_oth: "C3.1) Please specify other"

	label variable tap_smell "C4) How would you describe the smell of the water from the government provided h"
	note tap_smell: "C4) How would you describe the smell of the water from the government provided household tap?"
	label define tap_smell 1 "Good" 2 "Medicine or chemical" 3 "Metal" 4 "Salty" 5 "Bleach/chlorine (includes WaterGuard)" 999 "Don't know" -77 "Other"
	label values tap_smell tap_smell

	label variable tap_smell_oth "C4.1) Please specify other"
	note tap_smell_oth: "C4.1) Please specify other"

	label variable tap_color "C5) How do you find the color or look of the water from the government provided "
	note tap_color: "C5) How do you find the color or look of the water from the government provided household tap?"
	label define tap_color 1 "No problems with the color or look" 2 "Muddy/ sandy water" 3 "Yellow-ish or reddish water (from iron)" 999 "Don't know" -77 "Other"
	label values tap_color tap_color

	label variable tap_color_oth "C5.1) Please specify other"
	note tap_color_oth: "C5.1) Please specify other"

	label variable tap_trust "C6) How confident are you that the water from the government provided household "
	note tap_trust: "C6) How confident are you that the water from the government provided household tap is safe to drink on its own?"
	label define tap_trust 1 "Very confident" 2 "Somewhat confident" 3 "Neither confident or not confident" 4 "Somewhat not confident" 5 "Not confident at all"
	label values tap_trust tap_trust

	label variable tap_trust_fu "C6.1) Why are you not confident the water from the government provided household"
	note tap_trust_fu: "C6.1) Why are you not confident the water from the government provided household tap is safe to drink?"

	label variable tap_trust_oth "C6.2) Please specify other"
	note tap_trust_oth: "C6.2) Please specify other"

	label variable chlorine_yesno "C7) Have you ever used chlorine as a method for treating drinking water?"
	note chlorine_yesno: "C7) Have you ever used chlorine as a method for treating drinking water?"
	label define chlorine_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_yesno chlorine_yesno

	label variable chlorine_drank_yesno "C8) Have you ever drank water treated with chlorine?"
	note chlorine_drank_yesno: "C8) Have you ever drank water treated with chlorine?"
	label define chlorine_drank_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_drank_yesno chlorine_drank_yesno

	label variable collect_resp "T1) Who in your household is responsible for collecting drinking water?"
	note collect_resp: "T1) Who in your household is responsible for collecting drinking water?"

	label variable collect_time "T2) When you collect drinking water, how much time does it take to walk to your "
	note collect_time: "T2) When you collect drinking water, how much time does it take to walk to your primary water point (\${primary_water_label}), collect water, and return home?"
	label define collect_time 1 "Water point is on-premises" 2 "< 5 minutes" 3 "5-14 minutes" 4 "15-29 minutes" 5 "30-59 minutes" 6 ">= 60 minutes"
	label values collect_time collect_time

	label variable collect_prim_freq "T3) How many times in a week do you collect drinking water from your primary wat"
	note collect_prim_freq: "T3) How many times in a week do you collect drinking water from your primary water source (\${primary_water_label}) ?"

	label variable collect_sec_time "T4) When you collect water, how much time does it take to walk to your secondary"
	note collect_sec_time: "T4) When you collect water, how much time does it take to walk to your secondary water point, collect water, and return home?"
	label define collect_sec_time 1 "Water point is on-premises" 2 "< 5 minutes" 3 "5-14 minutes" 4 "15-29 minutes" 5 "30-59 minutes" 6 ">= 60 minutes"
	label values collect_sec_time collect_sec_time

	label variable collect_sec_freq "T5) How many times in a week do you collect drinking water from your secondary w"
	note collect_sec_freq: "T5) How many times in a week do you collect drinking water from your secondary water point over the week?"

	label variable treat_water_before "T6) Do you treat the water before drinking in your household?"
	note treat_water_before: "T6) Do you treat the water before drinking in your household?"
	label define treat_water_before 1 "Yes" 0 "No" 999 "Don't know"
	label values treat_water_before treat_water_before

	label variable treat_resp "T6.1) Who is responsible for treating water before drinking in your household?"
	note treat_resp: "T6.1) Who is responsible for treating water before drinking in your household?"

	label variable treat_time "T6.2) When you make your drinking water safe, how much time does it take to comp"
	note treat_time: "T6.2) When you make your drinking water safe, how much time does it take to complete the process?"
	label define treat_time 1 "< 5 minutes" 2 "5-15 minutes" 3 "15-30 minutes" 4 "30-60 minutes" 5 "> 60 minutes"
	label values treat_time treat_time

	label variable treat_freq "T6.3) How many times in a week do you treat your drinking water?"
	note treat_freq: "T6.3) How many times in a week do you treat your drinking water?"

	label variable collect_treat_difficult "T7) How difficult is it to collect and treat your drinking water?"
	note collect_treat_difficult: "T7) How difficult is it to collect and treat your drinking water?"
	label define collect_treat_difficult 1 "Very difficult" 2 "Somewhat difficult" 3 "Neither difficult nor easy" 4 "Somewhat easy" 5 "Very easy"
	label values collect_treat_difficult collect_treat_difficult

	label variable unique_id_1_wt "Record the first 5 digit"
	note unique_id_1_wt: "Record the first 5 digit"

	label variable unique_id_2_wt "Record the middle 3 digit"
	note unique_id_2_wt: "Record the middle 3 digit"

	label variable unique_id_3_wt "Record the last 3 digit"
	note unique_id_3_wt: "Record the last 3 digit"

	label variable wq_stored_bag "A1) Are you able to collect a water sample from the stored water for bag?"
	note wq_stored_bag: "A1) Are you able to collect a water sample from the stored water for bag?"
	label define wq_stored_bag 1 "Yes" 0 "No"
	label values wq_stored_bag wq_stored_bag

	label variable stored_bag_source "A2) What is the source of water for this stored sample?"
	note stored_bag_source: "A2) What is the source of water for this stored sample?"
	label define stored_bag_source 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private surface well" -77 "Other (please specify)"
	label values stored_bag_source stored_bag_source

	label variable stored_bag_source_oth "A2.1) Please specify other"
	note stored_bag_source_oth: "A2.1) Please specify other"

	label variable bag_stored_time "A2.2) How long has this water been stored for?"
	note bag_stored_time: "A2.2) How long has this water been stored for?"

	label variable bag_stored_time_unit "A2.3) Unit"
	note bag_stored_time_unit: "A2.3) Unit"
	label define bag_stored_time_unit 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks"
	label values bag_stored_time_unit bag_stored_time_unit

	label variable no_stored_bag "A2.4) Why are you not able to collect a stored water sample?"
	note no_stored_bag: "A2.4) Why are you not able to collect a stored water sample?"

	label variable tap_bag_id_stored "Please prepare a sample collection bag and scan the sample ID barcode, and label"
	note tap_bag_id_stored: "Please prepare a sample collection bag and scan the sample ID barcode, and label them as running water and stored water sample"

	label variable tap_bag_id_stored_typed "A3) Please enter the sample ID (For stored water: 2_ _ _ _)"
	note tap_bag_id_stored_typed: "A3) Please enter the sample ID (For stored water: 2_ _ _ _)"

	label variable tap_bag_stored_id "A4) Please enter the bag ID (9 _ _ _ _)"
	note tap_bag_stored_id: "A4) Please enter the bag ID (9 _ _ _ _)"

	label variable wq_chlorine_stored "A5) Are you able to collect the stored water samples from the household?"
	note wq_chlorine_stored: "A5) Are you able to collect the stored water samples from the household?"
	label define wq_chlorine_stored 1 "Yes" 0 "No"
	label values wq_chlorine_stored wq_chlorine_stored

	label variable no_chlorine_stored "A5.1) Why are you not able to collect the stored tap water samples?"
	note no_chlorine_stored: "A5.1) Why are you not able to collect the stored tap water samples?"

	label variable wq_chlorine_storedfc "A5.2) What is the free chlorine reading from the stored sample?"
	note wq_chlorine_storedfc: "A5.2) What is the free chlorine reading from the stored sample?"

	label variable wq_chlorine_storedtc "A5.3) What is the total chlorine reading from the stored sample?"
	note wq_chlorine_storedtc: "A5.3) What is the total chlorine reading from the stored sample?"

	label variable wq_running_bag "A6) Are you able to collect a running water sample for bag?"
	note wq_running_bag: "A6) Are you able to collect a running water sample for bag?"
	label define wq_running_bag 1 "Yes" 0 "No"
	label values wq_running_bag wq_running_bag

	label variable no_running_bag "A6.1) Why are you not able to collect a running water sample?"
	note no_running_bag: "A6.1) Why are you not able to collect a running water sample?"

	label variable tap_bag_id_running "Please prepare a sample collection bag and scan the sample ID barcode, and label"
	note tap_bag_id_running: "Please prepare a sample collection bag and scan the sample ID barcode, and label them as running water and stored water sample"

	label variable tap_bag_id_running_typed "A7) Please enter the sample ID (For running water: 1_ _ _ _)"
	note tap_bag_id_running_typed: "A7) Please enter the sample ID (For running water: 1_ _ _ _)"

	label variable tap_bag_running_id "A8) Please enter the bag ID (9 _ _ _ _)"
	note tap_bag_running_id: "A8) Please enter the bag ID (9 _ _ _ _)"

	label variable wq_chlorine_running "A9) Are you able to collect a running water sample from the tap connection?"
	note wq_chlorine_running: "A9) Are you able to collect a running water sample from the tap connection?"
	label define wq_chlorine_running 1 "Yes" 0 "No"
	label values wq_chlorine_running wq_chlorine_running

	label variable no_tap_reason "A9.1) Why are you not able to collect a running tap water sample?"
	note no_tap_reason: "A9.1) Why are you not able to collect a running tap water sample?"

	label variable wq_tap_fc "A10) What is the free chlorine reading from the Government provided household ta"
	note wq_tap_fc: "A10) What is the free chlorine reading from the Government provided household tap?"

	label variable wq_tap_tc "A11) What is the total chlorine reading from the Government provided household t"
	note wq_tap_tc: "A11) What is the total chlorine reading from the Government provided household tap?"

	label variable overall_comment "For enumerator : Please add any additional comments about this survey"
	note overall_comment: "For enumerator : Please add any additional comments about this survey"



	capture {
		foreach rgvar of varlist size_container_* {
			label variable `rgvar' "W4) What is the size of container \${container_nmbr} that you use to collect dri"
			note `rgvar': "W4) What is the size of container \${container_nmbr} that you use to collect drinking water?"
			label define `rgvar' 1 "< 5 Liters" 2 "5-9 Liters" 3 "10-14 Liters" 4 "15-19 Liters" 5 ">= 20 Liters"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist source_container_* {
			label variable `rgvar' "W5) What is the source of the drinking water for this container \${container_nmb"
			note `rgvar': "W5) What is the source of the drinking water for this container \${container_nmbr} ?"
			label define `rgvar' 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private surface well" -77 "Other (please specify)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist time_container_* {
			label variable `rgvar' "W5.1) How many times do you fill this container in a day?"
			note `rgvar': "W5.1) How many times do you fill this container in a day?"
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'", force
		
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
*   Corrections file path and filename:  Baseline follow up survey_corrections.csv
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
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
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
