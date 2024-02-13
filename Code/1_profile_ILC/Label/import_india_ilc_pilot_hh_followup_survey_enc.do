* import_india_ilc_pilot_hh_followup_survey_enc.do
*
* 	Imports and aggregates "HH follow up survey" (ID: india_ilc_pilot_hh_followup_survey_enc) data.
*
*	Inputs:  "HH follow up survey_WIDE.csv"
*	Outputs: "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/HH follow up survey.dta"
*
*	Output by SurveyCTO February 11, 2024 9:18 AM.

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
local csvfile "HH follow up survey_WIDE.csv"
local dtafile "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/HH follow up survey.dta"
local corrfile "HH follow up survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5"
local text_fields3 "r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17"
local text_fields4 "r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11"
local text_fields5 "cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4"
local text_fields6 "cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16"
local text_fields7 "cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 info_update reason_replacement_oth replacement_id_3_digit replacement_id enum_name_label duration_locatehh reasons_no_consent"
local text_fields8 "no_consent_oth duration_consent water_prim_oth primary_water_label water_source_sec water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count water_sec_index_* water_sec_value_*"
local text_fields9 "water_sec_label_* water_sec_labels water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label collect_resp"
local text_fields10 "people_prim_water num_people_prim people_prim_list_count people_prim_index_* people_prim_value_* people_prim_label_* people_prim_labels people_prim1 people_prim2 people_prim3 people_prim4 people_prim5"
local text_fields11 "people_prim6 people_prim7 people_prim8 people_prim9 people_prim10 people_prim11 people_prim12 people_prim13 people_prim14 people_prim15 people_prim16 people_prim17 people_prim18 people_prim19"
local text_fields12 "people_prim20 liter_estimation_count container_nmbr_* source_container_* source_container_oth_* water_treat_when water_treat_when_oth water_treat_type water_treat_type_oth treat_resp num_treat_resp"
local text_fields13 "treat_resp_list_count treat_resp_index_* treat_resp_value_* treat_resp_label_* treat_resp_labels treat_resp1 treat_resp2 treat_resp3 treat_resp4 treat_resp5 treat_resp6 treat_resp7 treat_resp8"
local text_fields14 "treat_resp9 treat_resp10 treat_resp11 treat_resp12 treat_resp13 treat_resp14 treat_resp15 treat_resp16 treat_resp17 treat_resp18 treat_resp19 treat_resp20 duration_seca tap_supply_freq_oth"
local text_fields15 "tap_function_noreason tap_function_reason_oth tap_use tap_use_oth cooking_issue_reason cooking_issue_reason_oth tap_function_reason tap_function_oth tap_use_future_oth duration_secb tap_taste_desc"
local text_fields16 "tap_taste_desc_oth tap_smell tap_smell_oth tap_color tap_color_oth tap_trust_fu tap_trust_oth duration_secc no_test_reason unique_id_3_digit_wt no_stored_bag stored_bag_source_oth tap_barcode_stored"
local text_fields17 "no_chlorine_stored no_running_bag tap_barcode_running no_tap_reason error_types_count calc_error_nmbr_* testing_comment duration_sece time_stored_running overall_comment duration_end"
local text_fields18 "survey_member_names_count surveynumber_* instanceid instancename"
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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_name_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round: \${R_Cen_a1_resp_name} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Saahi: \${R_Cen_saahi_name} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
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

	label variable reason_replacement "What was the reason for the replacement?"
	note reason_replacement: "What was the reason for the replacement?"
	label define reason_replacement 1 "No one is the household is available for a long period, even after confirming wi" 2 "Household said they would be available later, but weren’t available" 3 "Household refused" -77 "Other"
	label values reason_replacement reason_replacement

	label variable reason_replacement_oth "Please specify other"
	note reason_replacement_oth: "Please specify other"

	label variable enum_name "Enumerator name: Please select from the drop-down list"
	note enum_name: "Enumerator name: Please select from the drop-down list"
	label define enum_name 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani"
	label values enum_name enum_name

	label variable resp_available "Did you find a household to interview?"
	note resp_available: "Did you find a household to interview?"
	label define resp_available 1 "Household available for interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable reasons_no_consent "B1) Can you tell me why you do not want to participate in the survey?"
	note reasons_no_consent: "B1) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "B1.1) Please specify other"
	note no_consent_oth: "B1.1) Please specify other"

	label variable water_source_prim "W1) In the past month, which water source did you primarily use for drinking?"
	note water_source_prim: "W1) In the past month, which water source did you primarily use for drinking?"
	label define water_source_prim 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM " 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
	label values water_source_prim water_source_prim

	label variable water_prim_oth "W1.1) Please specify other"
	note water_prim_oth: "W1.1) Please specify other"

	label variable water_sec_yn "W2) In the past month, did your household use any sources of water for drinking "
	note water_sec_yn: "W2) In the past month, did your household use any sources of water for drinking besides \${primary_water_label}?"
	label define water_sec_yn 1 "Yes" 0 "No" 999 "Don't know"
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

	label variable collect_resp "W4) Who in your household is responsible for collecting drinking water from your"
	note collect_resp: "W4) Who in your household is responsible for collecting drinking water from your primary drinking water source: (\${primary_water_label})?"

	label variable prim_collect_resp "W5) Who usually goes to this source to collect the water from your primary sourc"
	note prim_collect_resp: "W5) Who usually goes to this source to collect the water from your primary source for your household: (\${primary_water_label})? This is the person who primarily collects water in the household."
	label define prim_collect_resp 1 "\${people_prim1}" 2 "\${people_prim2}" 3 "\${people_prim3}" 4 "\${people_prim4}" 5 "\${people_prim5}" 6 "\${people_prim6}" 7 "\${people_prim7}" 8 "\${people_prim8}" 9 "\${people_prim9}" 10 "\${people_prim10}" 11 "\${people_prim11}" 12 "\${people_prim12}" 13 "\${people_prim13}" 14 "\${people_prim14}" 15 "\${people_prim15}" 16 "\${people_prim16}" 17 "\${people_prim17}" 18 "\${people_prim18}" 19 "\${people_prim19}" 20 "\${people_prim20}"
	label values prim_collect_resp prim_collect_resp

	label variable where_prim_locate "W6) Where is your primary drinking water source (\${primary_water_label}) locate"
	note where_prim_locate: "W6) Where is your primary drinking water source (\${primary_water_label}) located?"
	label define where_prim_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate where_prim_locate

	label variable collect_time "W7) When you collect water from your primary drinking water source (\${primary_w"
	note collect_time: "W7) When you collect water from your primary drinking water source (\${primary_water_label}), how much time does it take to walk to your primary water point, collect drinking water, and return home? (in minutes)"

	label variable collect_prim_freq "W8) In the past week, how many times did you collect drinking water from your pr"
	note collect_prim_freq: "W8) In the past week, how many times did you collect drinking water from your primary water source (\${primary_water_label}) ?"

	label variable collect_sec_time "W9) When you collect water, how much time does it take to walk to your secondary"
	note collect_sec_time: "W9) When you collect water, how much time does it take to walk to your secondary water point (\${secondary_main_water_label}), collect water, and return home? (in minutes)"

	label variable collect_sec_freq "W10) In the past week, how many times did you collect drinking water from your s"
	note collect_sec_freq: "W10) In the past week, how many times did you collect drinking water from your secondary water point (\${secondary_main_water_label}) over the week?"

	label variable where_sec_locate "W11) Where is your secondary drinking water source (\${secondary_main_water_labe"
	note where_sec_locate: "W11) Where is your secondary drinking water source (\${secondary_main_water_label}) located?"
	label define where_sec_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_sec_locate where_sec_locate

	label variable quant_containers "W12) Yesterday, how many containers do you collect drinking water in?"
	note quant_containers: "W12) Yesterday, how many containers do you collect drinking water in?"

	label variable water_treat "W16) In the last one month, did your household do anything extra to the drinking"
	note water_treat: "W16) In the last one month, did your household do anything extra to the drinking water (\${primary_water_label} ) to make it safe before drinking it?"
	label define water_treat 1 "Yes" 0 "No" 999 "Don't know"
	label values water_treat water_treat

	label variable water_treat_when "W17) When do you make the water from your primary drinking water source (\${prim"
	note water_treat_when: "W17) When do you make the water from your primary drinking water source (\${primary_water_label} ) safe before drinking it?"

	label variable water_treat_when_oth "W17.1) Please specify other:"
	note water_treat_when_oth: "W17.1) Please specify other:"

	label variable water_stored "W18) For the water that is currently stored in the household, did you do anythin"
	note water_stored: "W18) For the water that is currently stored in the household, did you do anything extra to the drinking water to make it safe for drinking treated?"
	label define water_stored 1 "Yes" 0 "No" 999 "Don't know"
	label values water_stored water_stored

	label variable water_treat_type "W19) What did your household do to the water to make it safe for drinking?"
	note water_treat_type: "W19) What did your household do to the water to make it safe for drinking?"

	label variable water_treat_type_oth "W19.1) Please specify other"
	note water_treat_type_oth: "W19.1) Please specify other"

	label variable treat_resp "W20) Who is responsible for treating water before drinking in your household?"
	note treat_resp: "W20) Who is responsible for treating water before drinking in your household?"

	label variable treat_primresp "W21) Who usually treats the drinking water for your household?"
	note treat_primresp: "W21) Who usually treats the drinking water for your household?"
	label define treat_primresp 1 "\${treat_resp1}" 2 "\${treat_resp2}" 3 "\${treat_resp3}" 4 "\${treat_resp4}" 5 "\${treat_resp5}" 6 "\${treat_resp6}" 7 "\${treat_resp7}" 8 "\${treat_resp8}" 9 "\${treat_resp9}" 10 "\${treat_resp10}" 11 "\${treat_resp11}" 12 "\${treat_resp12}" 13 "\${treat_resp13}" 14 "\${treat_resp14}" 15 "\${treat_resp15}" 16 "\${treat_resp16}" 17 "\${treat_resp17}" 18 "\${treat_resp18}" 19 "\${treat_resp19}" 20 "\${treat_resp20}"
	label values treat_primresp treat_primresp

	label variable treat_time "W22) When you/ someone else make your drinking water safe, how much time does it"
	note treat_time: "W22) When you/ someone else make your drinking water safe, how much time does it take to complete the process? (in minutes)"

	label variable treat_freq "W23) How many times in a week does your household treat your drinking water? (pe"
	note treat_freq: "W23) How many times in a week does your household treat your drinking water? (per week)"

	label variable collect_treat_difficult "W24) How difficult is it to treat your drinking water?"
	note collect_treat_difficult: "W24) How difficult is it to treat your drinking water?"
	label define collect_treat_difficult 1 "Very difficult" 2 "Somewhat difficult" 3 "Neither difficult nor easy" 4 "Somewhat easy" 5 "Very easy" 999 "Don’t know"
	label values collect_treat_difficult collect_treat_difficult

	label variable tap_supply_freq "G1) How often is water supplied from the government provided tap/ supply paani?"
	note tap_supply_freq: "G1) How often is water supplied from the government provided tap/ supply paani?"
	label define tap_supply_freq 1 "Daily" 2 "Few days in a week" 3 "Once a week" 4 "Few times in a month" 5 "Once a month" 6 "No fixed schedule" -77 "Other" 999 "Don’t know" -98 "Refused to answer"
	label values tap_supply_freq tap_supply_freq

	label variable tap_supply_freq_oth "G1.1) Please specify other"
	note tap_supply_freq_oth: "G1.1) Please specify other"

	label variable tap_supply_daily "G2) In a day, how many times is water supplied from the government provided hous"
	note tap_supply_daily: "G2) In a day, how many times is water supplied from the government provided household tap/ supply paani?"

	label variable tap_use_drinking_yesno "G3)Do you use the government provided household tap for drinking?"
	note tap_use_drinking_yesno: "G3)Do you use the government provided household tap for drinking?"
	label define tap_use_drinking_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values tap_use_drinking_yesno tap_use_drinking_yesno

	label variable tap_function_noreason "G4) What is the reason for not using this household tap for drinking?"
	note tap_function_noreason: "G4) What is the reason for not using this household tap for drinking?"

	label variable tap_function_reason_oth "G4.1) Please specify other"
	note tap_function_reason_oth: "G4.1) Please specify other"

	label variable tap_use_oth_yesno "G5) Do you use water collected from the government provided household taps / sup"
	note tap_use_oth_yesno: "G5) Do you use water collected from the government provided household taps / supply paani for any other purposes (other than drinking)?"
	label define tap_use_oth_yesno 1 "Yes" 0 "No"
	label values tap_use_oth_yesno tap_use_oth_yesno

	label variable tap_use "G6) For what purposes do you use water collected from the government provided ho"
	note tap_use: "G6) For what purposes do you use water collected from the government provided household taps/ supply paani?"

	label variable tap_use_oth "G6.1) Please specify other"
	note tap_use_oth: "G6.1) Please specify other"

	label variable cooking_issue "G7) In the last one month, has your household faced any issues in using governem"
	note cooking_issue: "G7) In the last one month, has your household faced any issues in using governement provided tap water/ supply paani for cooking?"
	label define cooking_issue 1 "Yes" 0 "No"
	label values cooking_issue cooking_issue

	label variable cooking_issue_reason "G8) What are the issues you faced while cooking?"
	note cooking_issue_reason: "G8) What are the issues you faced while cooking?"

	label variable cooking_issue_reason_oth "G8.1) Please specify other"
	note cooking_issue_reason_oth: "G8.1) Please specify other"

	label variable tap_use_drinking "G9) When was the last time you collected water from the government provided hous"
	note tap_use_drinking: "G9) When was the last time you collected water from the government provided household taps/ supply paani for drinking purposes?"
	label define tap_use_drinking 1 "Today" 2 "Yesterday" 3 "Earlier this week" 4 "Earlier this month" -77 "Other"
	label values tap_use_drinking tap_use_drinking

	label variable tap_function "G10) In the last two weeks, have you tried to collect water from the government "
	note tap_function: "G10) In the last two weeks, have you tried to collect water from the government provided household tap but the tap/supply pani was not working?"
	label define tap_function 1 "Yes" 0 "No" 999 "Don't know"
	label values tap_function tap_function

	label variable tap_function_reason "G11) Why was the government provided household tap/ supply paani not working?"
	note tap_function_reason: "G11) Why was the government provided household tap/ supply paani not working?"

	label variable tap_function_oth "G11.1) Please specify other"
	note tap_function_oth: "G11.1) Please specify other"

	label variable tap_use_future "G12) How likely are you to use/continue using the government provided household "
	note tap_use_future: "G12) How likely are you to use/continue using the government provided household tap/ supply paani for drinking in the future?"
	label define tap_use_future 1 "Very likely" 2 "Somewhat likely" 3 "Neither likely nor unlikely" 4 "Somewhat Unlikely" 5 "Very unlikely" 999 "Don’t know"
	label values tap_use_future tap_use_future

	label variable tap_use_discontinue "G13) Can you provide any reasons for why you would not continue using the govern"
	note tap_use_discontinue: "G13) Can you provide any reasons for why you would not continue using the government provided household tap/ supply paani in the future?"
	label define tap_use_discontinue 1 "Water supply is not regular" 2 "Water supply is not sufficient" 3 "Water is muddy/ silty" 4 "Water smells or has unpleasant tastes" -77 "Other" 999 "Don’t know"
	label values tap_use_discontinue tap_use_discontinue

	label variable tap_use_future_oth "G13.1) Please specify other."
	note tap_use_future_oth: "G13.1) Please specify other."

	label variable tap_taste_satisfied "C2) How satisfied are you with the taste of water from the government provided h"
	note tap_taste_satisfied: "C2) How satisfied are you with the taste of water from the government provided household tap/ supply paani?"
	label define tap_taste_satisfied 1 "Very satisfied" 2 "Satisfied" 3 "Neither satisfied nor dissatisfied" 4 "Dissatisfied" 5 "Very dissatisfied" 999 "Don’t know"
	label values tap_taste_satisfied tap_taste_satisfied

	label variable tap_taste_desc "C3) How would you describe the taste of the water from the government provided h"
	note tap_taste_desc: "C3) How would you describe the taste of the water from the government provided household tap/ supply paani?"

	label variable tap_taste_desc_oth "C3.1) Please specify other"
	note tap_taste_desc_oth: "C3.1) Please specify other"

	label variable tap_smell "C4) How would you describe the smell of the water from the government provided h"
	note tap_smell: "C4) How would you describe the smell of the water from the government provided household tap/ supply paani?"

	label variable tap_smell_oth "C4.1) Please specify other"
	note tap_smell_oth: "C4.1) Please specify other"

	label variable tap_color "C5) How do you find the color or look of the water from the government provided "
	note tap_color: "C5) How do you find the color or look of the water from the government provided household tap / supply paani?"

	label variable tap_color_oth "C5.1) Please specify other"
	note tap_color_oth: "C5.1) Please specify other"

	label variable tap_trust "C6) How confident are you that the water from the government provided household "
	note tap_trust: "C6) How confident are you that the water from the government provided household tap / supply paani is safe to drink?"
	label define tap_trust 1 "Very confident" 2 "Somewhat confident" 3 "Neither confident or not confident" 4 "Somewhat not confident" 5 "Not confident at all" 999 "Don’t know"
	label values tap_trust tap_trust

	label variable tap_trust_fu "C6.1) Why are you not confident the water is safe to drink?"
	note tap_trust_fu: "C6.1) Why are you not confident the water is safe to drink?"

	label variable tap_trust_oth "C6.2) Please specify other"
	note tap_trust_oth: "C6.2) Please specify other"

	label variable chlorine_yesno "C7) Has your household ever applied chlorine or bleaching powder as a method for"
	note chlorine_yesno: "C7) Has your household ever applied chlorine or bleaching powder as a method for treating drinking water, after fetching water/getting water?"
	label define chlorine_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_yesno chlorine_yesno

	label variable chlorine_drank_yesno "C8) Have you ever drank water treated with chlorine or bleaching powder?"
	note chlorine_drank_yesno: "C8) Have you ever drank water treated with chlorine or bleaching powder?"
	label define chlorine_drank_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_drank_yesno chlorine_drank_yesno

	label variable unique_id_1_wt "Record the first 5 digit"
	note unique_id_1_wt: "Record the first 5 digit"

	label variable unique_id_2_wt "Record the middle 3 digit"
	note unique_id_2_wt: "Record the middle 3 digit"

	label variable unique_id_3_wt "Record the last 3 digit"
	note unique_id_3_wt: "Record the last 3 digit"

	label variable ecoli_yn "Is this household assigned for e-coli water sample collection?"
	note ecoli_yn: "Is this household assigned for e-coli water sample collection?"
	label define ecoli_yn 1 "Yes" 0 "No"
	label values ecoli_yn ecoli_yn

	label variable available_jjm "Are the stored water and running water from JJM tap/ Govt provided household tap"
	note available_jjm: "Are the stored water and running water from JJM tap/ Govt provided household tap?"
	label define available_jjm 1 "Both stored and running water are from JJM" 2 "Only running water is from JJM" 3 "Only stored water is from JJM" 4 "Both stored and running are not from JJM"
	label values available_jjm available_jjm

	label variable water_qual_test "A0) Are you able to conduct the test?"
	note water_qual_test: "A0) Are you able to conduct the test?"
	label define water_qual_test 1 "Yes" 0 "No"
	label values water_qual_test water_qual_test

	label variable no_test_reason "A0.1) Reason for NO TEST"
	note no_test_reason: "A0.1) Reason for NO TEST"

	label variable colorimeter_id "What is the ID of your colorimeter?"
	note colorimeter_id: "What is the ID of your colorimeter?"
	label define colorimeter_id 1 "001" 2 "002" 3 "003" 4 "004" 5 "005" 6 "006" 7 "007" 8 "008" 9 "009" 10 "010" 11 "011" 12 "012" 13 "013" 14 "014"
	label values colorimeter_id colorimeter_id

	label variable colorimeter_type "Which type of meter are you using?"
	note colorimeter_type: "Which type of meter are you using?"
	label define colorimeter_type 1 "LR/HR" 2 "MR/HR"
	label values colorimeter_type colorimeter_type

	label variable wq_stored_bag "A1) Are you able to collect a water sample from the stored water for bag?"
	note wq_stored_bag: "A1) Are you able to collect a water sample from the stored water for bag?"
	label define wq_stored_bag 1 "Yes" 0 "No"
	label values wq_stored_bag wq_stored_bag

	label variable no_stored_bag "A2.4) Why are you not able to collect a stored water sample?"
	note no_stored_bag: "A2.4) Why are you not able to collect a stored water sample?"

	label variable stored_bag_source "A2) What is the source of water for this stored sample?"
	note stored_bag_source: "A2) What is the source of water for this stored sample?"
	label define stored_bag_source 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM " 2 "Government provided community standpipe (connected to piped system, through Vasu" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 7 "Uncovered dug well" 8 "Private surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other (please specify)"
	label values stored_bag_source stored_bag_source

	label variable stored_bag_source_oth "A2.1) Please specify other"
	note stored_bag_source_oth: "A2.1) Please specify other"

	label variable bag_stored_time "A2.2) How long has this water been stored for?"
	note bag_stored_time: "A2.2) How long has this water been stored for?"

	label variable bag_stored_time_unit "A2.3) Unit"
	note bag_stored_time_unit: "A2.3) Unit"
	label define bag_stored_time_unit 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks"
	label values bag_stored_time_unit bag_stored_time_unit

	label variable tap_bag_id_stored "Please prepare a sample collection bag and scan the sample ID barcode, and label"
	note tap_bag_id_stored: "Please prepare a sample collection bag and scan the sample ID barcode, and label them as stored water sample. For stored water, sample ID is in form '20001' or '20002' or so on.."

	label variable tap_barcode_stored "Please click a picture of sample ID barcode."
	note tap_barcode_stored: "Please click a picture of sample ID barcode."

	label variable tap_bag_id_stored_typed "A3) Please enter the sample ID (For stored water: 2_ _ _ _)"
	note tap_bag_id_stored_typed: "A3) Please enter the sample ID (For stored water: 2_ _ _ _)"

	label variable tap_bag_id_stored_again "A3.1) Please enter the sample ID (For stored water: 2_ _ _ _) AGAIN!"
	note tap_bag_id_stored_again: "A3.1) Please enter the sample ID (For stored water: 2_ _ _ _) AGAIN!"

	label variable tap_bag_stored_id "A4) Please enter the bag ID (9 _ _ _ _ )"
	note tap_bag_stored_id: "A4) Please enter the bag ID (9 _ _ _ _ )"

	label variable wq_chlorine_stored "A5) Are you able to collect the stored water samples from the household?"
	note wq_chlorine_stored: "A5) Are you able to collect the stored water samples from the household?"
	label define wq_chlorine_stored 1 "Yes" 0 "No"
	label values wq_chlorine_stored wq_chlorine_stored

	label variable no_chlorine_stored "A5.1) Why are you not able to collect the stored tap water samples?"
	note no_chlorine_stored: "A5.1) Why are you not able to collect the stored tap water samples?"

	label variable stor_time_hours "A5.1.a) Record the time stamp for the stored water collected (hours)"
	note stor_time_hours: "A5.1.a) Record the time stamp for the stored water collected (hours)"

	label variable stor_time_mins "A5.1.b) Record the time stamp for the stored water collected (mins)"
	note stor_time_mins: "A5.1.b) Record the time stamp for the stored water collected (mins)"

	label variable wq_chlorine_storedfc "A5.2) What is the free chlorine reading from the stored sample?"
	note wq_chlorine_storedfc: "A5.2) What is the free chlorine reading from the stored sample?"

	label variable wq_chlorine_storedfc_again "A5.2.2) What is the free chlorine reading from the stored sample?"
	note wq_chlorine_storedfc_again: "A5.2.2) What is the free chlorine reading from the stored sample?"

	label variable wq_chlorine_storedtc "A5.3) What is the total chlorine reading from the stored sample?"
	note wq_chlorine_storedtc: "A5.3) What is the total chlorine reading from the stored sample?"

	label variable wq_chlorine_storedtc_again "A5.3.2) What is the total chlorine reading from the stored sample?"
	note wq_chlorine_storedtc_again: "A5.3.2) What is the total chlorine reading from the stored sample?"

	label variable wq_running_bag "A6) Are you able to collect a running water sample for bag?"
	note wq_running_bag: "A6) Are you able to collect a running water sample for bag?"
	label define wq_running_bag 1 "Yes" 0 "No"
	label values wq_running_bag wq_running_bag

	label variable no_running_bag "A6.1) Why are you not able to collect a running water sample?"
	note no_running_bag: "A6.1) Why are you not able to collect a running water sample?"

	label variable tap_bag_id_running "Please prepare a sample collection bag and scan the sample ID barcode, and label"
	note tap_bag_id_running: "Please prepare a sample collection bag and scan the sample ID barcode, and label them as running water sample. For running water, sample ID is in form '10001' or '10002' or so on.."

	label variable tap_barcode_running "Please click a picture of sample ID barcode."
	note tap_barcode_running: "Please click a picture of sample ID barcode."

	label variable tap_bag_id_running_typed "A7) Please enter the sample ID (For running water: 1_ _ _ _)"
	note tap_bag_id_running_typed: "A7) Please enter the sample ID (For running water: 1_ _ _ _)"

	label variable tap_bag_id_running_again "A7.1) Please enter the sample ID (For running water: 1_ _ _ _) AGAIN!"
	note tap_bag_id_running_again: "A7.1) Please enter the sample ID (For running water: 1_ _ _ _) AGAIN!"

	label variable tap_bag_running_id "A8) Please enter the bag ID (9 _ _ _ _ )"
	note tap_bag_running_id: "A8) Please enter the bag ID (9 _ _ _ _ )"

	label variable wq_chlorine_running "A9) Are you able to collect a running water sample from the tap connection?"
	note wq_chlorine_running: "A9) Are you able to collect a running water sample from the tap connection?"
	label define wq_chlorine_running 1 "Yes" 0 "No"
	label values wq_chlorine_running wq_chlorine_running

	label variable no_tap_reason "A9.1) Why are you not able to collect a running tap water sample?"
	note no_tap_reason: "A9.1) Why are you not able to collect a running tap water sample?"

	label variable run_time_hours "A9.1.a) Record the time stamp for the running water collected (hours)"
	note run_time_hours: "A9.1.a) Record the time stamp for the running water collected (hours)"

	label variable run_time_mins "A9.1.b) Record the time stamp for the running water collected (mins)"
	note run_time_mins: "A9.1.b) Record the time stamp for the running water collected (mins)"

	label variable wq_tap_fc "A10) What is the free chlorine reading from the Government provided household ta"
	note wq_tap_fc: "A10) What is the free chlorine reading from the Government provided household tap?"

	label variable wq_tap_fc_again "A10.2) What is the free chlorine reading from the Government provided household "
	note wq_tap_fc_again: "A10.2) What is the free chlorine reading from the Government provided household tap?"

	label variable wq_tap_tc "A11) What is the total chlorine reading from the Government provided household t"
	note wq_tap_tc: "A11) What is the total chlorine reading from the Government provided household tap?"

	label variable wq_tap_tc_again "A11.2) What is the total chlorine reading from the Government provided household"
	note wq_tap_tc_again: "A11.2) What is the total chlorine reading from the Government provided household tap?"

	label variable high_fc_reading "A12) Record the high range FREE chlorine concentration"
	note high_fc_reading: "A12) Record the high range FREE chlorine concentration"

	label variable high_tc_reading "A13) Record the high range TOTAL chlorine concentration"
	note high_tc_reading: "A13) Record the high range TOTAL chlorine concentration"

	label variable error_yesno "A14) Did you receive any error messages from the colorimeter when conducting thi"
	note error_yesno: "A14) Did you receive any error messages from the colorimeter when conducting this testing?"
	label define error_yesno 1 "Yes" 0 "No"
	label values error_yesno error_yesno

	label variable error_how_many "A14.1) How many error messages did you receive?"
	note error_how_many: "A14.1) How many error messages did you receive?"

	label variable testing_comment "A16) Do you have any comments regarding the testing?"
	note testing_comment: "A16) Do you have any comments regarding the testing?"

	label variable overall_comment "For enumerator : Please add any additional comments about this survey"
	note overall_comment: "For enumerator : Please add any additional comments about this survey"

	label variable survey_accompany_num "Please record the number of people who attended or accompanied this interview as"
	note survey_accompany_num: "Please record the number of people who attended or accompanied this interview aside from yourself or household member you are interviewing"



	capture {
		foreach rgvar of varlist size_container_* {
			label variable `rgvar' "W13) What is the size of container \${container_nmbr} that you use to collect dr"
			note `rgvar': "W13) What is the size of container \${container_nmbr} that you use to collect drinking water yesterday?"
			label define `rgvar' 1 "< 5 Liters" 2 "5-9 Liters" 3 "10-14 Liters" 4 "15-19 Liters" 5 ">= 20 Liters"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist source_container_* {
			label variable `rgvar' "W14) What is the source of the drinking water for this container \${container_nm"
			note `rgvar': "W14) What is the source of the drinking water for this container \${container_nmbr}?"
		}
	}

	capture {
		foreach rgvar of varlist source_container_oth_* {
			label variable `rgvar' "W14.1) Please specify other"
			note `rgvar': "W14.1) Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist time_container_* {
			label variable `rgvar' "W15) How many times did you fill this container yesterday?"
			note `rgvar': "W15) How many times did you fill this container yesterday?"
		}
	}

	capture {
		foreach rgvar of varlist error_num_* {
			label variable `rgvar' "A15) What was the number of the error \${calc_error_nmbr} message?"
			note `rgvar': "A15) What was the number of the error \${calc_error_nmbr} message?"
		}
	}

	capture {
		foreach rgvar of varlist survey_member_role_* {
			label variable `rgvar' "What is the role of person number \${surveynumber}?"
			note `rgvar': "What is the role of person number \${surveynumber}?"
			label define `rgvar' 1 "DIL staff" 2 "J-PAL supervisor" 3 "J-PAL enumerator" 4 "J-PAL monitor" 5 "J-PAL PA" 6 "Other J-PAL staff" 7 "Gram Vikas staff"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist survey_member_gender_* {
			label variable `rgvar' "What is the gender of person number \${surveynumber}?"
			note `rgvar': "What is the gender of person number \${surveynumber}?"
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
*   Corrections file path and filename:  HH follow up survey_corrections.csv
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
