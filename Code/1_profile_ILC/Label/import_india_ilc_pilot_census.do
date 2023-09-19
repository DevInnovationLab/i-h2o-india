* import_india_ilc_pilot_census.do
*
* 	Imports and aggregates "Baseline Census" (ID: india_ilc_pilot_census) data.
*
*	Inputs:  "Baseline Census_WIDE.csv"
*	Outputs: "Baseline Census.dta"
*
*	Output by SurveyCTO September 19, 2023 7:26 AM.

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
local csvfile "Baseline Census_WIDE.csv"
local dtafile "Baseline Census.dta"
local corrfile "Baseline Census_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum intro_duration hh_code_format unique_id hamlet_name landmark address intro_dur_end consent_duration enum_name_label no_consent_reason no_consent_oth"
local text_fields2 "no_consent_comment consent_dur_end sectionb_duration a1_resp_name hh_member_names_count namenumber_* a3_hhmember_name_* namefromearlier_* a5_hhmember_relation_* a5_hhmember_relation_other_*"
local text_fields3 "a5_autoage_* fam_name1_* fam_name2_* fam_name3_* fam_name4_* fam_name5_* fam_name6_* fam_name7_* fam_name8_* fam_name9_* fam_name10_* fam_name11_* fam_name12_* fam_name13_* fam_name14_* fam_name15_*"
local text_fields4 "fam_name16_* fam_name17_* fam_name18_* fam_name19_* fam_name20_* a10_hhhead a11_oldmale_name sectionb_dur_end a12_water_source_prim a12_water_source_prim_other water_prim_oth primary_water_label"
local text_fields5 "a13_water_source_sec a13_water_sec_oth a14_sec_source_reason sec_source_reason_oth a15_water_sec_freq_oth a16_water_treat_type a16_water_treat_type_other a16_water_treat_freq"
local text_fields6 "a16_water_treat_freq_other water_prim_source_kids water_prim_source_kids_other a17_water_treat_kids a17_water_treat_kids_other a18_jjm_use a18_jjm_use_oth a19_reason_nodrink a19_reason_nodrink_other"
local text_fields7 "pregnant_followup_count pregnant_index_* get_pregnant_status_* pregwoman_* child_followup_count child_index_* get_u5_status_* u5child_* livestock_oth a37_castename a38_tribename a39_phone_num"
local text_fields8 "a41_end_comments a42_survey_accompany instanceid instancename"
local date_fields1 "a6_dob_*"
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


	label variable district_name "Enumerator to fill up: District Name"
	note district_name: "Enumerator to fill up: District Name"
	label define district_name 11 "Rayagada"
	label values district_name district_name

	label variable block_name "Enumerator to fill up: Block Name"
	note block_name: "Enumerator to fill up: Block Name"
	label define block_name 111 "Kolnara" 112 "Rayagada" 113 "Ramanguda" 114 "Padmapur"
	label values block_name block_name

	label variable gp_name "Enumerator to fill up: Gram Panchayat Name"
	note gp_name: "Enumerator to fill up: Gram Panchayat Name"
	label define gp_name 1111 "B.K.Padar" 1112 "Dumuriguda" 1113 "Dunduli" 1114 "Katikana" 1115 "Kolanara" 1116 "Mukundupur" 1141 "Gudiabandha" 1142 "Jatili" 1143 "Kamapadara" 1144 "Khilapadar" 1145 "Naira" 1131 "Gulumunda" 1132 "Ukkamba" 1133 "Bhamini" 1121 "Dangalodi" 1122 "Gajigaon" 1123 "Halua" 1124 "Karlakana" 1125 "Kothapeta" 1126 "Meerabali" 1127 "Pipalaguda" 1128 "Tadma"
	label values gp_name gp_name

	label variable village_name "Enumerator to fill up: Village Name"
	note village_name: "Enumerator to fill up: Village Name"
	label define village_name 11111 "Aribi" 11121 "Gopikankubadi" 11131 "Rengalpadu" 11141 "Panichhatra" 11151 "Bhujabala" 11161 "Mukundapur" 11411 "Bichikote" 11412 "Gudiabandha" 11421 "Jatili" 11431 "Mariguda" 11441 "Lachiamanaguda" 11451 "Naira" 11311 "Gulumunda" 11321 "Amiti" 11211 "Penikana" 11331 "Khilingira" 11221 "Gajigaon" 11231 "Barijhola" 11241 "Karlakana" 11251 "Biranarayanpur" 11252 "Kuljing" 11261 "Meerabali" 11271 "Pipalguda" 11281 "Nathma"
	label values village_name village_name

	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Jeremy Lowe" 102 "Vaishnavi Prathap" 103 "Akanksha Saletore" 104 "Astha Vohra" 105 "Shashank Patil" 106 "Michelle Cherian"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 102 "102" 103 "103" 104 "104" 105 "105" 106 "106"
	label values enum_code enum_code

	label variable hh_code "NEW: Assign a number to the household you are visiting based on how many you hav"
	note hh_code: "NEW: Assign a number to the household you are visiting based on how many you have visited in this village. If you are working in the same village as the previous day, use sequential numbers."

	label variable hh_repeat_code "Repeat the number of the household you are visiting"
	note hh_repeat_code: "Repeat the number of the household you are visiting"

	label variable hamlet_name "Enumerator to fill up: Hamlet Name"
	note hamlet_name: "Enumerator to fill up: Hamlet Name"

	label variable landmark "Can you provide a landmark or description of the house so it can be located late"
	note landmark: "Can you provide a landmark or description of the house so it can be located later?"

	label variable address "What is your address?"
	note address: "What is your address?"

	label variable resp_available "Enumerator to record after knocking at the door of a house: Did you find a house"
	note resp_available: "Enumerator to record after knocking at the door of a house: Did you find a household to interview?"
	label define resp_available 1 "Household available for interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 2nd visit: The family is temporarily unavailable."
	label values resp_available resp_available

	label variable screen_u5child "S1) Are there any children under the age of 5 years in this household?"
	note screen_u5child: "S1) Are there any children under the age of 5 years in this household?"
	label define screen_u5child 1 "Yes" 0 "No"
	label values screen_u5child screen_u5child

	label variable screen_preg "S2) Are there currently any pregnant women in this household?"
	note screen_preg: "S2) Are there currently any pregnant women in this household?"
	label define screen_preg 1 "Yes" 0 "No"
	label values screen_preg screen_preg

	label variable instruction "Instructions for Enumerator to identify the primary respondent: 1. The primary r"
	note instruction: "Instructions for Enumerator to identify the primary respondent: 1. The primary respondent will be the pregnant woman or the mother of the child whose age is below 5 years. 2. After the screening question, request to speak to the pregnant woman or the mother of the U5 child, if you are already not speaking with her. 3. If the primary respondent is not available, ask to speak to the female head of the house or any other member of the household who could provide information about the pregnant women or young children in the house. 4. If there are multiple pregnant women or mothers with children under the age of 5, request to speak to one of them for the main survey but ensure that the interview for every pregnant women is conducted for the respondent health section, and that each of the mothers of U5 report on their respective child's health. 5. If no pregnant woman or mother/ caregiver of a child below 5 years is available to be surveyed now but is available later, enumerator to revisit the household. Enumerator: Is the pregnant woman or mother/ caregiver of the child under 5 available to continue the survey with?"
	label define instruction 1 "Yes" 0 "No"
	label values instruction instruction

	label variable visit_num "Is this your 1st visit, or 2nd visit?"
	note visit_num: "Is this your 1st visit, or 2nd visit?"
	label define visit_num 1 "1st visit" 2 "2nd visit"
	label values visit_num visit_num

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable no_consent_reason "B1) Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason: "B1) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "B1.1) Please specify other"
	note no_consent_oth: "B1.1) Please specify other"

	label variable no_consent_comment "Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "Record any relevant notes if the respondent refused the interview"

	label variable a1_resp_name "A1) What is your name?"
	note a1_resp_name: "A1) What is your name?"

	label variable a2_hhmember_count "A2) How many people live in this household including you?"
	note a2_hhmember_count: "A2) How many people live in this household including you?"

	label variable a10_hhhead "A10) What is the name of the head of household?"
	note a10_hhhead: "A10) What is the name of the head of household?"

	label variable a10_hhhead_gender "A10.1) What is the gender of the household head?"
	note a10_hhhead_gender: "A10.1) What is the gender of the household head?"
	label define a10_hhhead_gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values a10_hhhead_gender a10_hhhead_gender

	label variable a11_oldmale "A11) Is there an older male in the household?"
	note a11_oldmale: "A11) Is there an older male in the household?"
	label define a11_oldmale 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a11_oldmale a11_oldmale

	label variable a11_oldmale_name "A11.1) What is their name?"
	note a11_oldmale_name: "A11.1) What is their name?"

	label variable a12_water_source_prim "A12) In the past month, which water source did your household primarily use for "
	note a12_water_source_prim: "A12) In the past month, which water source did your household primarily use for drinking?"

	label variable a12_water_source_prim_other "Specify other."
	note a12_water_source_prim_other: "Specify other."

	label variable water_prim_oth "A12.1) If Other, please specify"
	note water_prim_oth: "A12.1) If Other, please specify"

	label variable a13_water_sec_yn "A13) In the past month, did your household use any sources of water besides the "
	note a13_water_sec_yn: "A13) In the past month, did your household use any sources of water besides the one you already mentioned?"
	label define a13_water_sec_yn 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a13_water_sec_yn a13_water_sec_yn

	label variable a13_water_source_sec "A13.1) In the past month, what other water sources have you used for drinking?"
	note a13_water_source_sec: "A13.1) In the past month, what other water sources have you used for drinking?"

	label variable a13_water_sec_oth "A13.2) If Other, please specify"
	note a13_water_sec_oth: "A13.2) If Other, please specify"

	label variable a14_sec_source_reason "A14) In what circumstances do you collect drinking water from these other water "
	note a14_sec_source_reason: "A14) In what circumstances do you collect drinking water from these other water sources?"

	label variable sec_source_reason_oth "A14.1) If Other, please specify"
	note sec_source_reason_oth: "A14.1) If Other, please specify"

	label variable a15_water_sec_freq "A15) How often do you collect water for drinking from these other water sources?"
	note a15_water_sec_freq: "A15) How often do you collect water for drinking from these other water sources?"
	label define a15_water_sec_freq 1 "Daily" 2 "Every 2-3 days in a week" 3 "Once a week" 4 "Once every two weeks" 5 "Once a month" 6 "Once every few months" 7 "Once a year" 8 "No fixed schedule" -99 "Don't know"
	label values a15_water_sec_freq a15_water_sec_freq

	label variable a15_water_sec_freq_oth "A15.1) If Other, please specify"
	note a15_water_sec_freq_oth: "A15.1) If Other, please specify"

	label variable a16_water_treat "A16) Do you ever do anything to the water from the primary source (\${primary_wa"
	note a16_water_treat: "A16) Do you ever do anything to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"
	label define a16_water_treat 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a16_water_treat a16_water_treat

	label variable a16_water_treat_type "A16.1) What do you do to the water from the primary source (\${primary_water_lab"
	note a16_water_treat_type: "A16.1) What do you do to the water from the primary source (\${primary_water_label}) to make it safe for drinking?"

	label variable a16_water_treat_type_other "Specify other."
	note a16_water_treat_type_other: "Specify other."

	label variable a16_water_treat_freq "A16.2) When do you treat the water from your primary drinking water source (\${p"
	note a16_water_treat_freq: "A16.2) When do you treat the water from your primary drinking water source (\${primary_water_label} ) before drinking it?"

	label variable a16_water_treat_freq_other "Specify other."
	note a16_water_treat_freq_other: "Specify other."

	label variable a17_water_source_kids "A17) Do your youngest children drink from the same water source as the household"
	note a17_water_source_kids: "A17) Do your youngest children drink from the same water source as the household's primary drinking water source i.e (\${primary_water_label}) ?"
	label define a17_water_source_kids 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a17_water_source_kids a17_water_source_kids

	label variable water_prim_source_kids "A17.1) What is the primary drinking water source for your youngest children?"
	note water_prim_source_kids: "A17.1) What is the primary drinking water source for your youngest children?"

	label variable water_prim_source_kids_other "Specify other."
	note water_prim_source_kids_other: "Specify other."

	label variable a17_water_treat_kids "A17.2) What do you do to the water for your youngest children to make it safe fo"
	note a17_water_treat_kids: "A17.2) What do you do to the water for your youngest children to make it safe for drinking?"

	label variable a17_water_treat_kids_other "Specify other."
	note a17_water_treat_kids_other: "Specify other."

	label variable a18_jjm_use "A18) For what purposes do you use water collected from the government provided h"
	note a18_jjm_use: "A18) For what purposes do you use water collected from the government provided household taps?"

	label variable a18_jjm_use_oth "A18.1) If Other, please specify"
	note a18_jjm_use_oth: "A18.1) If Other, please specify"

	label variable a19_jjm_drinking "A19) Do you use the government provided household tap for drinking?"
	note a19_jjm_drinking: "A19) Do you use the government provided household tap for drinking?"
	label define a19_jjm_drinking 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a19_jjm_drinking a19_jjm_drinking

	label variable a19_reason_nodrink "A19.1) what is the reason for not using this household tap for drinking?"
	note a19_reason_nodrink: "A19.1) what is the reason for not using this household tap for drinking?"

	label variable a19_reason_nodrink_other "Specify other."
	note a19_reason_nodrink_other: "Specify other."

	label variable a20_jjm_stored "A20) Is any water from the Government provided household tap stored in your hous"
	note a20_jjm_stored: "A20) Is any water from the Government provided household tap stored in your house currently or was stored in the last 24 hours?"
	label define a20_jjm_stored 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a20_jjm_stored a20_jjm_stored

	label variable labels "A33) Does your household have (check NFHS)"
	note labels: "A33) Does your household have (check NFHS)"
	label define labels 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values labels labels

	label variable a33_electricity "Electricity?"
	note a33_electricity: "Electricity?"
	label define a33_electricity 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_electricity a33_electricity

	label variable a33_mattress "A mattress?"
	note a33_mattress: "A mattress?"
	label define a33_mattress 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_mattress a33_mattress

	label variable a33_pressurecooker "A pressure cooker?"
	note a33_pressurecooker: "A pressure cooker?"
	label define a33_pressurecooker 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_pressurecooker a33_pressurecooker

	label variable a33_chair "A chair?"
	note a33_chair: "A chair?"
	label define a33_chair 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_chair a33_chair

	label variable a33_cotbed "A cot or bed?"
	note a33_cotbed: "A cot or bed?"
	label define a33_cotbed 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_cotbed a33_cotbed

	label variable a33_table "A table?"
	note a33_table: "A table?"
	label define a33_table 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_table a33_table

	label variable a33_electricfan "An electric fan?"
	note a33_electricfan: "An electric fan?"
	label define a33_electricfan 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_electricfan a33_electricfan

	label variable a33_radiotransistor "A radio or transistor?"
	note a33_radiotransistor: "A radio or transistor?"
	label define a33_radiotransistor 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_radiotransistor a33_radiotransistor

	label variable a33_bwtv "A black and white television?"
	note a33_bwtv: "A black and white television?"
	label define a33_bwtv 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_bwtv a33_bwtv

	label variable a33_colourtv "A colour television?"
	note a33_colourtv: "A colour television?"
	label define a33_colourtv 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_colourtv a33_colourtv

	label variable a33_sewingmachine "A sewing machine?"
	note a33_sewingmachine: "A sewing machine?"
	label define a33_sewingmachine 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_sewingmachine a33_sewingmachine

	label variable a33_mobile "A mobile telephone?"
	note a33_mobile: "A mobile telephone?"
	label define a33_mobile 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_mobile a33_mobile

	label variable a33_landline "A landline?"
	note a33_landline: "A landline?"
	label define a33_landline 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_landline a33_landline

	label variable a33_internet "Internet?"
	note a33_internet: "Internet?"
	label define a33_internet 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_internet a33_internet

	label variable a33_computer "A computer?"
	note a33_computer: "A computer?"
	label define a33_computer 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_computer a33_computer

	label variable a33_fridge "A refrigerator?"
	note a33_fridge: "A refrigerator?"
	label define a33_fridge 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_fridge a33_fridge

	label variable a33_ac "An air conditioning (AC) unit?"
	note a33_ac: "An air conditioning (AC) unit?"
	label define a33_ac 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_ac a33_ac

	label variable a33_washingmachine "A washing machine?"
	note a33_washingmachine: "A washing machine?"
	label define a33_washingmachine 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_washingmachine a33_washingmachine

	label variable a33_watchclock "A watch or clock?"
	note a33_watchclock: "A watch or clock?"
	label define a33_watchclock 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_watchclock a33_watchclock

	label variable a33_bicycle "A bicycle?"
	note a33_bicycle: "A bicycle?"
	label define a33_bicycle 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_bicycle a33_bicycle

	label variable a33_motorcycle "A motorcycle or scooter?"
	note a33_motorcycle: "A motorcycle or scooter?"
	label define a33_motorcycle 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_motorcycle a33_motorcycle

	label variable a33_cart "An animal-drawn cart?"
	note a33_cart: "An animal-drawn cart?"
	label define a33_cart 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_cart a33_cart

	label variable a33_car "A car?"
	note a33_car: "A car?"
	label define a33_car 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_car a33_car

	label variable a33_waterpump "A water pump?"
	note a33_waterpump: "A water pump?"
	label define a33_waterpump 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_waterpump a33_waterpump

	label variable a33_thresher "A thresher?"
	note a33_thresher: "A thresher?"
	label define a33_thresher 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_thresher a33_thresher

	label variable a33_tractor "A tractor?"
	note a33_tractor: "A tractor?"
	label define a33_tractor 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a33_tractor a33_tractor

	label variable a34_roof "A34) Do you have a pucca roof on the house?"
	note a34_roof: "A34) Do you have a pucca roof on the house?"
	label define a34_roof 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a34_roof a34_roof

	label variable labels2 "Does your household have any livestock?"
	note labels2: "Does your household have any livestock?"
	label define labels2 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values labels2 labels2

	label variable a35_cattle "Cattle?"
	note a35_cattle: "Cattle?"
	label define a35_cattle 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a35_cattle a35_cattle

	label variable a35_sheep "Sheep?"
	note a35_sheep: "Sheep?"
	label define a35_sheep 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a35_sheep a35_sheep

	label variable a35_goats "Goats?"
	note a35_goats: "Goats?"
	label define a35_goats 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a35_goats a35_goats

	label variable a35_chicken "Chicken?"
	note a35_chicken: "Chicken?"
	label define a35_chicken 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a35_chicken a35_chicken

	label variable a35_poultry "Other poultry?"
	note a35_poultry: "Other poultry?"
	label define a35_poultry 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a35_poultry a35_poultry

	label variable livestock_oth "A35.1) If Other, please specify"
	note livestock_oth: "A35.1) If Other, please specify"

	label variable a36_caste "A36) Do you belong to a scheduled caste, scheduled tribe, or other backward clas"
	note a36_caste: "A36) Do you belong to a scheduled caste, scheduled tribe, or other backward class, or none of these?"
	label define a36_caste 1 "Scheduled caste" 2 "Scheduled tribe" 3 "Other backward caste" 4 "None of the above"
	label values a36_caste a36_caste

	label variable a37_castename "A37) Please provide the name of your caste"
	note a37_castename: "A37) Please provide the name of your caste"

	label variable a38_tribename "A38) Please provide the name of your tribe"
	note a38_tribename: "A38) Please provide the name of your tribe"

	label variable a39_phone_num "A39) What is your phone number?"
	note a39_phone_num: "A39) What is your phone number?"

	label variable a40_gps_autolatitude "Auto GPS (latitude)"
	note a40_gps_autolatitude: "Auto GPS (latitude)"

	label variable a40_gps_autolongitude "Auto GPS (longitude)"
	note a40_gps_autolongitude: "Auto GPS (longitude)"

	label variable a40_gps_autoaltitude "Auto GPS (altitude)"
	note a40_gps_autoaltitude: "Auto GPS (altitude)"

	label variable a40_gps_autoaccuracy "Auto GPS (accuracy)"
	note a40_gps_autoaccuracy: "Auto GPS (accuracy)"

	label variable a40_gps_manuallatitude "A40.1) Please record the GPS location of this household (latitude)"
	note a40_gps_manuallatitude: "A40.1) Please record the GPS location of this household (latitude)"

	label variable a40_gps_manuallongitude "A40.1) Please record the GPS location of this household (longitude)"
	note a40_gps_manuallongitude: "A40.1) Please record the GPS location of this household (longitude)"

	label variable a40_gps_manualaltitude "A40.1) Please record the GPS location of this household (altitude)"
	note a40_gps_manualaltitude: "A40.1) Please record the GPS location of this household (altitude)"

	label variable a40_gps_manualaccuracy "A40.1) Please record the GPS location of this household (accuracy)"
	note a40_gps_manualaccuracy: "A40.1) Please record the GPS location of this household (accuracy)"

	label variable a41_end_comments "A41) Please add any additional comments about this survey."
	note a41_end_comments: "A41) Please add any additional comments about this survey."

	label variable a42_survey_accompany "A42) Please record who attended or accompanied this interview."
	note a42_survey_accompany: "A42) Please record who attended or accompanied this interview."



	capture {
		foreach rgvar of varlist a3_hhmember_name_* {
			label variable `rgvar' "A3) What is the name of household member \${namenumber}?"
			note `rgvar': "A3) What is the name of household member \${namenumber}?"
		}
	}

	capture {
		foreach rgvar of varlist a4_hhmember_gender_* {
			label variable `rgvar' "A4) What is the gender of \${namefromearlier}?"
			note `rgvar': "A4) What is the gender of \${namefromearlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a5_hhmember_relation_* {
			label variable `rgvar' "A5) What is your relationship with \${namefromearlier}?"
			note `rgvar': "A5) What is your relationship with \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist a5_hhmember_relation_other_* {
			label variable `rgvar' "Specify other."
			note `rgvar': "Specify other."
		}
	}

	capture {
		foreach rgvar of varlist a6_hhmember_age_* {
			label variable `rgvar' "A6) How old is \${namefromearlier} in years?"
			note `rgvar': "A6) How old is \${namefromearlier} in years?"
		}
	}

	capture {
		foreach rgvar of varlist a6_age_confirm_* {
			label variable `rgvar' "Enumerator to fill in: Is \${namefromearlier} younger than 5 years?"
			note `rgvar': "Enumerator to fill in: Is \${namefromearlier} younger than 5 years?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a6_dob_* {
			label variable `rgvar' "A6.1) What is the date of birth for \${namefromearlier}?"
			note `rgvar': "A6.1) What is the date of birth for \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist a6_u1age_month_* {
			label variable `rgvar' "A6.2) How old is \${namefromearlier} in months?"
			note `rgvar': "A6.2) How old is \${namefromearlier} in months?"
		}
	}

	capture {
		foreach rgvar of varlist a6_u1age_days_* {
			label variable `rgvar' "A6.3) How old is \${namefromearlier} in days?"
			note `rgvar': "A6.3) How old is \${namefromearlier} in days?"
		}
	}

	capture {
		foreach rgvar of varlist correct_age_* {
			label variable `rgvar' "Enumerator to note if the above age for the child U5 was accurate (i.e verified "
			note `rgvar': "Enumerator to note if the above age for the child U5 was accurate (i.e verified from a birth certificate) or imputed/guessed"
			label define `rgvar' 1 "Age for U5 child accurate" 2 "Age for U5 child imputed/guessed"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_* {
			label variable `rgvar' "A7) Is \${namefromearlier} pregnant?"
			note `rgvar': "A7) Is \${namefromearlier} pregnant?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_month_* {
			label variable `rgvar' "A7.1) How many months pregnant is \${namefromearlier}?"
			note `rgvar': "A7.1) How many months pregnant is \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_hh_* {
			label variable `rgvar' "A7.2) Is this \${namefromearlier}'s usual residence?"
			note `rgvar': "A7.2) Is this \${namefromearlier}'s usual residence?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a7_pregnant_leave_* {
			label variable `rgvar' "A7.3) When does \${namefromearlier} plan to leave (record in months)?"
			note `rgvar': "A7.3) When does \${namefromearlier} plan to leave (record in months)?"
		}
	}

	capture {
		foreach rgvar of varlist a8_u5mother_* {
			label variable `rgvar' "A8) Does the mother of \${namefromearlier} live in this household?"
			note `rgvar': "A8) Does the mother of \${namefromearlier} live in this household?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist u5mother_name_* {
			label variable `rgvar' "A8.1) What is the name of \${namefromearlier}'s mother?"
			note `rgvar': "A8.1) What is the name of \${namefromearlier}'s mother?"
			label define `rgvar' 1 "\${fam_name1}" 2 "\${fam_name2}" 3 "\${fam_name3}" 4 "\${fam_name4}" 5 "\${fam_name5}" 6 "\${fam_name6}" 7 "\${fam_name7}" 8 "\${fam_name8}" 9 "\${fam_name9}" 10 "\${fam_name10}" 11 "\${fam_name11}" 12 "\${fam_name12}" 13 "\${fam_name13}" 14 "\${fam_name14}" 15 "\${fam_name15}" 16 "\${fam_name16}" 17 "\${fam_name17}" 18 "\${fam_name18}" 19 "\${fam_name19}" 20 "\${fam_name20}"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a9_school_* {
			label variable `rgvar' "A9) Has \${namefromearlier} ever attended school?"
			note `rgvar': "A9) Has \${namefromearlier} ever attended school?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a9_school_level_* {
			label variable `rgvar' "A9.1) What is the highest level of schooling that \${namefromearlier} has comple"
			note `rgvar': "A9.1) What is the highest level of schooling that \${namefromearlier} has completed?"
			label define `rgvar' 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (8th grade not completed)" 4 "Complete primary (8th grade completed)" 5 "Incomplete secondary (12th grade not completed)" 6 "Complete secondary (12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" -99 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a9_read_write_* {
			label variable `rgvar' "A9.2) Can \${namefromearlier} read and write with understanding in any language?"
			note `rgvar': "A9.2) Can \${namefromearlier} read and write with understanding in any language?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_wom_cuts_day_* {
			label variable `rgvar' "A21) Did \${pregwoman} have any bruising, scrapes, or cuts today or yesterday?"
			note `rgvar': "A21) Did \${pregwoman} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_wom_cuts_week_* {
			label variable `rgvar' "A21.1) Did \${pregwoman} have any bruising, scrapes, or cuts in the last 7 days?"
			note `rgvar': "A21.1) Did \${pregwoman} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a21_wom_cuts_2week_* {
			label variable `rgvar' "A21.2) Did \${pregwoman} have any bruising, scrapes, or cuts in the past 2 weeks"
			note `rgvar': "A21.2) Did \${pregwoman} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a22_wom_vomit_day_* {
			label variable `rgvar' "A22) Did \${pregwoman} vomit today or yesterday?"
			note `rgvar': "A22) Did \${pregwoman} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a22_wom_vomit_week_* {
			label variable `rgvar' "A22.1) Did \${pregwoman} vomit in the last 7 days?"
			note `rgvar': "A22.1) Did \${pregwoman} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a22_wom_vomit_2week_* {
			label variable `rgvar' "A22.2) Did \${pregwoman} vomit in the past 2 weeks?"
			note `rgvar': "A22.2) Did \${pregwoman} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a23_wom_diarr_day_* {
			label variable `rgvar' "A23) Did \${pregwoman} have diarrhea today or yesterday?"
			note `rgvar': "A23) Did \${pregwoman} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a23_wom_diarr_week_* {
			label variable `rgvar' "A23.1) Did \${pregwoman} have diarrhea in the past 7 days?"
			note `rgvar': "A23.1) Did \${pregwoman} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a23_wom_diarr_2week_* {
			label variable `rgvar' "A23.2) Did \${pregwoman} have diarrhea in the past 2 weeks?"
			note `rgvar': "A23.2) Did \${pregwoman} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a24_wom_diarr_num_* {
			label variable `rgvar' "A24) How many days did {\${pregwoman} have diarrhea?"
			note `rgvar': "A24) How many days did {\${pregwoman} have diarrhea?"
		}
	}

	capture {
		foreach rgvar of varlist a25_wom_stool_24h_* {
			label variable `rgvar' "A25) Did \${pregwoman} have 3 or more loose or watery stools within the last 24 "
			note `rgvar': "A25) Did \${pregwoman} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a25_wom_stool_yest_* {
			label variable `rgvar' "A25.1) Did \${pregwoman} have 3 or more loose or watery stools yesterday?"
			note `rgvar': "A25.1) Did \${pregwoman} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a25_wom_stool_week_* {
			label variable `rgvar' "A25.2) Did \${pregwoman} have 3 or more loose or watery stools in the past 7 day"
			note `rgvar': "A25.2) Did \${pregwoman} have 3 or more loose or watery stools in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a25_wom_stool_2week_* {
			label variable `rgvar' "A25.3) Did \${pregwoman} have 3 or more loose or watery stools in the past 2 wee"
			note `rgvar': "A25.3) Did \${pregwoman} have 3 or more loose or watery stools in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a26_wom_blood_day_* {
			label variable `rgvar' "A26) Did \${pregwoman} have blood in her stool today or yesterday?"
			note `rgvar': "A26) Did \${pregwoman} have blood in her stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a26_wom_blood_week_* {
			label variable `rgvar' "A26.1) Did \${pregwoman} have blood in her stool in the past 7 days?"
			note `rgvar': "A26.1) Did \${pregwoman} have blood in her stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a26_wom_blood_2week_* {
			label variable `rgvar' "A26.2) Did \${pregwoman} have blood in her stool in the past 2 weeks?"
			note `rgvar': "A26.2) Did \${pregwoman} have blood in her stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a27_child_cuts_day_* {
			label variable `rgvar' "A27) Did \${U5child} have any bruising, scrapes, or cuts today or yesterday?"
			note `rgvar': "A27) Did \${U5child} have any bruising, scrapes, or cuts today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a27_child_cuts_week_* {
			label variable `rgvar' "A27.1) Did \${U5child} have any bruising, scrapes, or cuts in the last 7 days?"
			note `rgvar': "A27.1) Did \${U5child} have any bruising, scrapes, or cuts in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a27_child_cuts_2week_* {
			label variable `rgvar' "A21.2) Did \${U5child} have any bruising, scrapes, or cuts in the past 2 weeks?"
			note `rgvar': "A21.2) Did \${U5child} have any bruising, scrapes, or cuts in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a28_child_vomit_day_* {
			label variable `rgvar' "A28) Did \${U5child} vomit today or yesterday?"
			note `rgvar': "A28) Did \${U5child} vomit today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a28_child_vomit_week_* {
			label variable `rgvar' "A28.1) Did \${U5child} vomit in the last 7 days?"
			note `rgvar': "A28.1) Did \${U5child} vomit in the last 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a28_child_vomit_2week_* {
			label variable `rgvar' "A28.2) Did \${U5child} vomit in the past 2 weeks?"
			note `rgvar': "A28.2) Did \${U5child} vomit in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_child_diarr_day_* {
			label variable `rgvar' "A29) Did \${U5child} have diarrhea today or yesterday?"
			note `rgvar': "A29) Did \${U5child} have diarrhea today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_child_diarr_week_* {
			label variable `rgvar' "A29.1) Did \${U5child} have diarrhea in the past 7 days?"
			note `rgvar': "A29.1) Did \${U5child} have diarrhea in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a29_child_diarr_2week_* {
			label variable `rgvar' "A29.2) Did \${U5child} have diarrhea in the past 2 weeks?"
			note `rgvar': "A29.2) Did \${U5child} have diarrhea in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a30_child_diarr_num_* {
			label variable `rgvar' "A30) How many days did \${U5child} have diarrhea?"
			note `rgvar': "A30) How many days did \${U5child} have diarrhea?"
		}
	}

	capture {
		foreach rgvar of varlist a30_child_diarr_freq_* {
			label variable `rgvar' "A30.1) What was the highest number of stools in a 24-hour period?"
			note `rgvar': "A30.1) What was the highest number of stools in a 24-hour period?"
		}
	}

	capture {
		foreach rgvar of varlist a31_child_stool_24h_* {
			label variable `rgvar' "A31) Did \${U5child} have 3 or more loose or watery stools within the last 24 ho"
			note `rgvar': "A31) Did \${U5child} have 3 or more loose or watery stools within the last 24 hours?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a31_child_stool_yest_* {
			label variable `rgvar' "A31.1) Did \${U5child} have 3 or more loose or watery stools yesterday?"
			note `rgvar': "A31.1) Did \${U5child} have 3 or more loose or watery stools yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a31_child_stool_week_* {
			label variable `rgvar' "A31.2) Did \${U5child} have 3 or more loose or watery stools in the past 7 days?"
			note `rgvar': "A31.2) Did \${U5child} have 3 or more loose or watery stools in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a31_child_stool_2week_* {
			label variable `rgvar' "A31.3) Did \${U5child} have 3 or more loose or watery stools in the past 2 weeks"
			note `rgvar': "A31.3) Did \${U5child} have 3 or more loose or watery stools in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a32_child_blood_day_* {
			label variable `rgvar' "A32) Did \${U5child} have blood in the stool today or yesterday?"
			note `rgvar': "A32) Did \${U5child} have blood in the stool today or yesterday?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a32_child_blood_week_* {
			label variable `rgvar' "A32.1) Did \${U5child} have blood in the stool in the past 7 days?"
			note `rgvar': "A32.1) Did \${U5child} have blood in the stool in the past 7 days?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a32_child_blood_2week_* {
			label variable `rgvar' "A32.2) Did \${U5child} have blood in the stool in the past 2 weeks?"
			note `rgvar': "A32.2) Did \${U5child} have blood in the stool in the past 2 weeks?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
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
*   Corrections file path and filename:  Baseline Census_corrections.csv
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
