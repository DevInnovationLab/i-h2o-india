* import_india_ilc_pilot_census_enc.do
*
* 	Imports and aggregates "india_ilc_pilot_census_enc" (ID: india_ilc_pilot_census_enc) data.
*
*	Inputs:  "india_ilc_pilot_census_enc_WIDE.csv"
*	Outputs: "india_ilc_pilot_census_enc.dta"
*
*	Output by SurveyCTO August 22, 2023 10:49 AM.

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
local csvfile "india_ilc_pilot_census_enc_WIDE.csv"
local dtafile "india_ilc_pilot_census_enc.dta"
local corrfile "india_ilc_pilot_census_enc_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum hamlet_name unique_id enum_name_label reasons_no_consent no_consent_oth no_consent_comment a1_resp_name a3_femhead_name a3_malehead_name a4_oldmale_name"
local text_fields2 "a6_phone_num a7_phone_oth a8_address a9_landmark hh_member_names_count namenumber_* a14_hhmember_name_* hh_member_gender_count_* namefromearlier_* hh_member_age_count_* pregnant_oth_status_count"
local text_fields3 "num_preg_oth_* pregnant_oth_name_* water_prim_oth primary_water_label a23_water_source_sec a23_water_sec_oth a24_sec_source_reason sec_source_reason_oth a25_water_sec_freq_oth a26_water_treat_freq"
local text_fields4 "a26_water_treat_type a28_jjm_use a28_jjm_use_oth comment instanceid instancename"
local date_fields1 "a5_age"
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

	label variable hamlet_name "Enumerator to fill up: Hamlet Name"
	note hamlet_name: "Enumerator to fill up: Hamlet Name"

	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Jeremy Lowe" 102 "Vaishnavi Prathap" 103 "Akanksha Saletore" 104 "Astha Vohra" 105 "Shashank Patil" 106 "Michelle Cherian"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 102 "102" 103 "103" 104 "104" 105 "105" 106 "106"
	label values enum_code enum_code

	label variable hh_code "Assign a number to the household you are visiting based on how many you have vis"
	note hh_code: "Assign a number to the household you are visiting based on how many you have visited today"

	label variable hh_repeat_code "Repeat the same number of the household you are visiting based on how many you h"
	note hh_repeat_code: "Repeat the same number of the household you are visiting based on how many you have visited today"

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values consent consent

	label variable reasons_no_consent "B1) Can you tell me why you do not want to participate in the survey?"
	note reasons_no_consent: "B1) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "B1.1) Please specify other"
	note no_consent_oth: "B1.1) Please specify other"

	label variable no_consent_followup "B1.2) Can I speak to the person who makes decisions regarding your household's s"
	note no_consent_followup: "B1.2) Can I speak to the person who makes decisions regarding your household's study participation?"
	label define no_consent_followup 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values no_consent_followup no_consent_followup

	label variable followup_consent "B1.3) Do I have your permission to proceed with the interview?"
	note followup_consent: "B1.3) Do I have your permission to proceed with the interview?"
	label define followup_consent 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values followup_consent followup_consent

	label variable no_consent_comment "Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "Record any relevant notes if the respondent refused the interview"

	label variable a1_resp_name "A1) What is your name?"
	note a1_resp_name: "A1) What is your name?"

	label variable a2_gender "A2) What is your gender?"
	note a2_gender: "A2) What is your gender?"
	label define a2_gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values a2_gender a2_gender

	label variable a3_femhead "A3.1) Is there a female head of household?"
	note a3_femhead: "A3.1) Is there a female head of household?"
	label define a3_femhead 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a3_femhead a3_femhead

	label variable a3_femhead_name "A3.1.1) What is the female household head's name?"
	note a3_femhead_name: "A3.1.1) What is the female household head's name?"

	label variable a3_malehead "A3.2) Is there a male head of household?"
	note a3_malehead: "A3.2) Is there a male head of household?"
	label define a3_malehead 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a3_malehead a3_malehead

	label variable a3_malehead_name "A3.2.1) What is the male household head's name?"
	note a3_malehead_name: "A3.2.1) What is the male household head's name?"

	label variable a4_oldmale "A4) Is there an older male in the household?"
	note a4_oldmale: "A4) Is there an older male in the household?"
	label define a4_oldmale 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a4_oldmale a4_oldmale

	label variable a4_oldmale_name "A4.1) What is their name?"
	note a4_oldmale_name: "A4.1) What is their name?"

	label variable a5_age "A5) What is your date of birth?"
	note a5_age: "A5) What is your date of birth?"

	label variable a6_phone_num "A6) What is your phone number?"
	note a6_phone_num: "A6) What is your phone number?"

	label variable a7_phone_oth "A7) What is the phone number of the other head of household?"
	note a7_phone_oth: "A7) What is the phone number of the other head of household?"

	label variable a8_address "A8) What is your address?"
	note a8_address: "A8) What is your address?"

	label variable a9_landmark "A9) Can you provide a landmark or description of the house so it can be located "
	note a9_landmark: "A9) Can you provide a landmark or description of the house so it can be located later?"

	label variable a9_gpslatitude "A9.1) Please record the GPS location of this household (latitude)"
	note a9_gpslatitude: "A9.1) Please record the GPS location of this household (latitude)"

	label variable a9_gpslongitude "A9.1) Please record the GPS location of this household (longitude)"
	note a9_gpslongitude: "A9.1) Please record the GPS location of this household (longitude)"

	label variable a9_gpsaltitude "A9.1) Please record the GPS location of this household (altitude)"
	note a9_gpsaltitude: "A9.1) Please record the GPS location of this household (altitude)"

	label variable a9_gpsaccuracy "A9.1) Please record the GPS location of this household (accuracy)"
	note a9_gpsaccuracy: "A9.1) Please record the GPS location of this household (accuracy)"

	label variable a10_head_hh "A10) Is this a female headed household?"
	note a10_head_hh: "A10) Is this a female headed household?"
	label define a10_head_hh 1 "Yes, female headed" 2 "No, male headed" 3 "No, child-headed household"
	label values a10_head_hh a10_head_hh

	label variable a11_school "A11) Have you ever attended school?"
	note a11_school: "A11) Have you ever attended school?"
	label define a11_school 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a11_school a11_school

	label variable a12_school_level "A12) What is the highest level of schooling that you have completed?"
	note a12_school_level: "A12) What is the highest level of schooling that you have completed?"
	label define a12_school_level 1 "Incomplete primary (8th grade not completed)" 2 "Complete primary (8th grade completed)" 3 "Incomplete secondary (12th grade not completed)" 4 "Complete secondary (12th grade not completed)" 5 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Don't know/refused."
	label values a12_school_level a12_school_level

	label variable a13_read_write "A13) Can you read and write with understanding in any language?"
	note a13_read_write: "A13) Can you read and write with understanding in any language?"
	label define a13_read_write 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a13_read_write a13_read_write

	label variable a14_hh_member_count "A14) How many people live in this household besides you?"
	note a14_hh_member_count: "A14) How many people live in this household besides you?"

	label variable a17_pregnant "A17) Are you currently pregnant?"
	note a17_pregnant: "A17) Are you currently pregnant?"
	label define a17_pregnant 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a17_pregnant a17_pregnant

	label variable a18_pregnant_freq "A18) How many months pregnant are you?"
	note a18_pregnant_freq: "A18) How many months pregnant are you?"

	label variable a19_pregnant_oth "A19) Are there any (other) pregnant women in this household?"
	note a19_pregnant_oth: "A19) Are there any (other) pregnant women in this household?"
	label define a19_pregnant_oth 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a19_pregnant_oth a19_pregnant_oth

	label variable a19_pregnant_freq_oth "A19.1) How many (other) pregnant women are in this household?"
	note a19_pregnant_freq_oth: "A19.1) How many (other) pregnant women are in this household?"

	label variable a20_caste "A20) Do you belong to a scheduled caste, scheduled tribe, or other backward clas"
	note a20_caste: "A20) Do you belong to a scheduled caste, scheduled tribe, or other backward class, or none of these?"
	label define a20_caste 1 "Scheduled caste" 2 "Scheduled tribe" 3 "Other backward caste" 4 "None of the above"
	label values a20_caste a20_caste

	label variable labels "A21) Does your household have:"
	note labels: "A21) Does your household have:"
	label define labels 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values labels labels

	label variable a21_electricity "Electricity?"
	note a21_electricity: "Electricity?"
	label define a21_electricity 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_electricity a21_electricity

	label variable a21_mattress "A mattress?"
	note a21_mattress: "A mattress?"
	label define a21_mattress 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_mattress a21_mattress

	label variable a21_pressurecooker "A pressure cooker?"
	note a21_pressurecooker: "A pressure cooker?"
	label define a21_pressurecooker 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_pressurecooker a21_pressurecooker

	label variable a21_chair "A chair?"
	note a21_chair: "A chair?"
	label define a21_chair 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_chair a21_chair

	label variable a21_cotbed "A cot or bed?"
	note a21_cotbed: "A cot or bed?"
	label define a21_cotbed 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_cotbed a21_cotbed

	label variable a21_table "A table?"
	note a21_table: "A table?"
	label define a21_table 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_table a21_table

	label variable a21_electricfan "An electric fan?"
	note a21_electricfan: "An electric fan?"
	label define a21_electricfan 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_electricfan a21_electricfan

	label variable a21_radiotransistor "A radio or transistor?"
	note a21_radiotransistor: "A radio or transistor?"
	label define a21_radiotransistor 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_radiotransistor a21_radiotransistor

	label variable a21_bwtv "A black and white television?"
	note a21_bwtv: "A black and white television?"
	label define a21_bwtv 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_bwtv a21_bwtv

	label variable a21_colourtv "A colour television?"
	note a21_colourtv: "A colour television?"
	label define a21_colourtv 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_colourtv a21_colourtv

	label variable a21_sewingmachine "A sewing machine?"
	note a21_sewingmachine: "A sewing machine?"
	label define a21_sewingmachine 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_sewingmachine a21_sewingmachine

	label variable a21_mobile "A mobile telephone?"
	note a21_mobile: "A mobile telephone?"
	label define a21_mobile 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_mobile a21_mobile

	label variable a21_landline "A landline?"
	note a21_landline: "A landline?"
	label define a21_landline 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_landline a21_landline

	label variable a21_internet "Internet?"
	note a21_internet: "Internet?"
	label define a21_internet 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_internet a21_internet

	label variable a21_computer "A computer?"
	note a21_computer: "A computer?"
	label define a21_computer 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_computer a21_computer

	label variable a21_fridge "A refrigerator?"
	note a21_fridge: "A refrigerator?"
	label define a21_fridge 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_fridge a21_fridge

	label variable a21_ac "An air conditioning (AC) unit?"
	note a21_ac: "An air conditioning (AC) unit?"
	label define a21_ac 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_ac a21_ac

	label variable a21_washingmachine "A washing machine?"
	note a21_washingmachine: "A washing machine?"
	label define a21_washingmachine 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_washingmachine a21_washingmachine

	label variable a21_watchclock "A watch or clock?"
	note a21_watchclock: "A watch or clock?"
	label define a21_watchclock 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_watchclock a21_watchclock

	label variable a21_bicycle "A bicycle?"
	note a21_bicycle: "A bicycle?"
	label define a21_bicycle 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_bicycle a21_bicycle

	label variable a21_motorcycle "A motorcycle or scooter?"
	note a21_motorcycle: "A motorcycle or scooter?"
	label define a21_motorcycle 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_motorcycle a21_motorcycle

	label variable a21_cart "An animal-drawn cart?"
	note a21_cart: "An animal-drawn cart?"
	label define a21_cart 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_cart a21_cart

	label variable a21_car "A car?"
	note a21_car: "A car?"
	label define a21_car 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_car a21_car

	label variable a21_waterpump "A water pump?"
	note a21_waterpump: "A water pump?"
	label define a21_waterpump 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_waterpump a21_waterpump

	label variable a21_thresher "A thresher?"
	note a21_thresher: "A thresher?"
	label define a21_thresher 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_thresher a21_thresher

	label variable a21_tractor "A tractor?"
	note a21_tractor: "A tractor?"
	label define a21_tractor 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a21_tractor a21_tractor

	label variable a22_water_source_prim "A22) Which water source do you primarily use for drinking?"
	note a22_water_source_prim: "A22) Which water source do you primarily use for drinking?"
	label define a22_water_source_prim 1 "JJM Taps" 2 "Community standpipe" 3 "Manual handpump" 4 "Private well" -98 "Other"
	label values a22_water_source_prim a22_water_source_prim

	label variable water_prim_oth "A22.1) If Other, please specify"
	note water_prim_oth: "A22.1) If Other, please specify"

	label variable a230_water_sec_yn "A23.0) Do you use any sources of water besides the one you already mentioned ove"
	note a230_water_sec_yn: "A23.0) Do you use any sources of water besides the one you already mentioned over the past year?"
	label define a230_water_sec_yn 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a230_water_sec_yn a230_water_sec_yn

	label variable a23_water_source_sec "A23.1) What other water sources have you used for drinking in the past year?"
	note a23_water_source_sec: "A23.1) What other water sources have you used for drinking in the past year?"

	label variable a23_water_sec_oth "A23.2) If Other, please specify"
	note a23_water_sec_oth: "A23.2) If Other, please specify"

	label variable a24_sec_source_reason "A24) In what circumstances do you collect drinking water from these other water "
	note a24_sec_source_reason: "A24) In what circumstances do you collect drinking water from these other water sources?"

	label variable sec_source_reason_oth "A24.1) If Other, please specify"
	note sec_source_reason_oth: "A24.1) If Other, please specify"

	label variable a25_water_sec_freq "A25) How often do you collect water for drinking from these other water sources?"
	note a25_water_sec_freq: "A25) How often do you collect water for drinking from these other water sources?"
	label define a25_water_sec_freq 1 "Daily" 2 "Every 2-3 days in a week" 3 "Once a week" 4 "Once every two weeks" 5 "Once a month" 6 "Once every few months" 7 "Once a year" 8 "No fixed schedule" -98 "Other" -99 "Don't know"
	label values a25_water_sec_freq a25_water_sec_freq

	label variable a25_water_sec_freq_oth "A25.1) If Other, please specify"
	note a25_water_sec_freq_oth: "A25.1) If Other, please specify"

	label variable a26_water_treat "A26) Do you ever treat the water from your primary drinking water source (\${pri"
	note a26_water_treat: "A26) Do you ever treat the water from your primary drinking water source (\${primary_water_label} ) before drinking it?"
	label define a26_water_treat 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values a26_water_treat a26_water_treat

	label variable a26_water_treat_freq "A26.1) When do you treat the water from your primary drinking water source (\${p"
	note a26_water_treat_freq: "A26.1) When do you treat the water from your primary drinking water source (\${primary_water_label} ) before drinking it?"

	label variable a26_water_treat_type "A26.2) How do you treat the water from your primary drinking water source (\${pr"
	note a26_water_treat_type: "A26.2) How do you treat the water from your primary drinking water source (\${primary_water_label})?"

	label variable a28_jjm_use "A28) For what purposes do you use water collected from the JJM taps?"
	note a28_jjm_use: "A28) For what purposes do you use water collected from the JJM taps?"

	label variable a28_jjm_use_oth "A28.1) If Other, please specify"
	note a28_jjm_use_oth: "A28.1) If Other, please specify"

	label variable comment_opt "For enumerator : Do you wish to add any additional comments about this survey?"
	note comment_opt: "For enumerator : Do you wish to add any additional comments about this survey?"
	label define comment_opt 1 "Yes" 0 "No" -98 "Don't know/refused"
	label values comment_opt comment_opt

	label variable comment "For enumerator : Please add any additional comments about this survey"
	note comment: "For enumerator : Please add any additional comments about this survey"



	capture {
		foreach rgvar of varlist a14_hhmember_name_* {
			label variable `rgvar' "A14.1) What is the name of household member #\${namenumber}?"
			note `rgvar': "A14.1) What is the name of household member #\${namenumber}?"
		}
	}

	capture {
		foreach rgvar of varlist a15_hhmember_gender_* {
			label variable `rgvar' "A15) What is the gender of \${namefromearlier}?"
			note `rgvar': "A15) What is the gender of \${namefromearlier}?"
			label define `rgvar' 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist a16_hhmember_age_* {
			label variable `rgvar' "A16) How old is \${namefromearlier}?"
			note `rgvar': "A16) How old is \${namefromearlier}?"
		}
	}

	capture {
		foreach rgvar of varlist pregnant_oth_name_* {
			label variable `rgvar' "A19.2) What is the name of woman #\${num_preg_oth}?"
			note `rgvar': "A19.2) What is the name of woman #\${num_preg_oth}?"
		}
	}

	capture {
		foreach rgvar of varlist pregnant_oth_month_* {
			label variable `rgvar' "A19.3) How many months pregnant is woman #\${num_preg_oth}?"
			note `rgvar': "A19.3) How many months pregnant is woman #\${num_preg_oth}?"
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
*   Corrections file path and filename:  india_ilc_pilot_census_enc_corrections.csv
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
