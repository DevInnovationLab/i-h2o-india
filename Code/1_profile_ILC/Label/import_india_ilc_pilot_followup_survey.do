* import_india_ilc_pilot_followup_survey.do
*
* 	Imports and aggregates "india_ilc_pilot_followup_survey" (ID: india_ilc_pilot_followup_survey) data.
*
*	Inputs:  "india_ilc_pilot_followup_survey_WIDE.csv"
*	Outputs: "india_ilc_pilot_followup_survey.dta"
*
*	Output by SurveyCTO August 3, 2023 9:39 PM.

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
local csvfile "india_ilc_pilot_followup_survey_WIDE.csv"
local dtafile "india_ilc_pilot_followup_survey.dta"
local corrfile "india_ilc_pilot_followup_survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum hamlet_name enum_name_label reasons_no_consent no_consent_oth no_consent_comment no_test_reason no_tap_sample no_stored_sample stored_sample_source"
local text_fields2 "water_prim_oth water_source_sec water_sec_other primary_water_label water_sec_circumstances water_sec_circumstances_oth water_sec_freq_oth secondary_water_label water_treat_freq water_treat_type"
local text_fields3 "tap_install_oth tap_supply_oth tap_supply_freq_oth tap_use tap_use_oth tap_use_future_oth tap_taste_desc_oth tap_smell_oth tap_color_oth tap_trust_fu tap_trust_oth collect_resp treat_resp"
local text_fields4 "overall_comment instanceid instancename"
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

	label variable hamlet_name "Enumerator to fill up : Hamlet Name"
	note hamlet_name: "Enumerator to fill up : Hamlet Name"

	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Jeremy Lowe" 102 "Vaishnavi Prathap" 103 "Akanksha Saletore" 104 "Astha Vohra" 105 "Shashank Patil" 106 "Michelle Cherian"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 102 "102" 103 "103" 104 "104" 105 "105" 106 "106"
	label values enum_code enum_code

	label variable hh_code "Record the unique ID (VVVV-EID-HH) provided to you by the field manager for this"
	note hh_code: "Record the unique ID (VVVV-EID-HH) provided to you by the field manager for this household"
	label define hh_code 10010101 "10010101" 10010102 "10010102" 10010103 "10010103" 10010104 "10010104" 10010105 "10010105" 10010106 "10010106" 10010107 "10010107" 10010108 "10010108" 10010109 "10010109" 10010110 "10010110" 10010111 "10010111" 10010112 "10010112" 10010113 "10010113" 10010114 "10010114" 10010115 "10010115" 10010116 "10010116" 10010117 "10010117" 10010118 "10010118" 10010119 "10010119" 10010120 "10010120" 10010121 "10010121" 10010122 "10010122" 10010123 "10010123" 10010124 "10010124" 10010125 "10010125" 10010126 "10010126" 10010127 "10010127" 10010128 "10010128" 10010129 "10010129"
	label values hh_code hh_code

	label variable hh_code_repeat "Select the same ID (VVVV-EID-HH) from the dropdown menu"
	note hh_code_repeat: "Select the same ID (VVVV-EID-HH) from the dropdown menu"
	label define hh_code_repeat 10010101 "10010101" 10010102 "10010102" 10010103 "10010103" 10010104 "10010104" 10010105 "10010105" 10010106 "10010106" 10010107 "10010107" 10010108 "10010108" 10010109 "10010109" 10010110 "10010110" 10010111 "10010111" 10010112 "10010112" 10010113 "10010113" 10010114 "10010114" 10010115 "10010115" 10010116 "10010116" 10010117 "10010117" 10010118 "10010118" 10010119 "10010119" 10010120 "10010120" 10010121 "10010121" 10010122 "10010122" 10010123 "10010123" 10010124 "10010124" 10010125 "10010125" 10010126 "10010126" 10010127 "10010127" 10010128 "10010128" 10010129 "10010129"
	label values hh_code_repeat hh_code_repeat

	label variable consent "Do I have your permission to proceed with the interview?"
	note consent: "Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No" -99 "Don't know"
	label values consent consent

	label variable reasons_no_consent "Can you tell me why you do not want to participate in the survey?"
	note reasons_no_consent: "Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "Please specify other"
	note no_consent_oth: "Please specify other"

	label variable no_consent_followup "Can I speak to the person who makes decisions regarding your household's study p"
	note no_consent_followup: "Can I speak to the person who makes decisions regarding your household's study participation?"
	label define no_consent_followup 1 "Yes" 0 "No" -99 "Don't know"
	label values no_consent_followup no_consent_followup

	label variable followup_consent "Do I have your permission to proceed with the interview?"
	note followup_consent: "Do I have your permission to proceed with the interview?"
	label define followup_consent 1 "Yes" 0 "No" -99 "Don't know"
	label values followup_consent followup_consent

	label variable no_consent_comment "Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "Record any relevant notes if the respondent refused the interview"

	label variable wq_tests "A28. What water quality tests will you conduct?"
	note wq_tests: "A28. What water quality tests will you conduct?"
	label define wq_tests 0 "No test" 1 "Free and total chlorine only" 2 "Sample collection and free/total chlorine"
	label values wq_tests wq_tests

	label variable no_test_reason "A28.1. Why are you not testing the water at this household tap?"
	note no_test_reason: "A28.1. Why are you not testing the water at this household tap?"

	label variable wq_tap_fc "A29. What is the free chlorine reading from the JJM tap?"
	note wq_tap_fc: "A29. What is the free chlorine reading from the JJM tap?"

	label variable wq_tap_tc "A30. What is the total chlorine reading from the JJM tap?"
	note wq_tap_tc: "A30. What is the total chlorine reading from the JJM tap?"

	label variable wq_tap_sample "A32. Are you able to collect a water sample from the tap connection?"
	note wq_tap_sample: "A32. Are you able to collect a water sample from the tap connection?"
	label define wq_tap_sample 1 "Yes" 0 "No" -99 "Don't know"
	label values wq_tap_sample wq_tap_sample

	label variable no_tap_sample "Why are you not able to collect a tap water sample?"
	note no_tap_sample: "Why are you not able to collect a tap water sample?"

	label variable tap_sample_id "A32.1 Please prepare a sample collection bag and scan the sample ID barcode"
	note tap_sample_id: "A32.1 Please prepare a sample collection bag and scan the sample ID barcode"

	label variable tap_sample_id_typed "A32.2 Please enter the sample ID"
	note tap_sample_id_typed: "A32.2 Please enter the sample ID"

	label variable tap_bag_id "A32.3 Please enter the bag ID"
	note tap_bag_id: "A32.3 Please enter the bag ID"

	label variable wq_stored_sample "A33. Are you able to collect a stored water sample?"
	note wq_stored_sample: "A33. Are you able to collect a stored water sample?"
	label define wq_stored_sample 1 "Yes" 0 "No" -99 "Don't know"
	label values wq_stored_sample wq_stored_sample

	label variable no_stored_sample "A33.1 Why are you not able to collect a stored water sample?"
	note no_stored_sample: "A33.1 Why are you not able to collect a stored water sample?"

	label variable stored_sample_source "A35. What is the source of water for this stored sample?"
	note stored_sample_source: "A35. What is the source of water for this stored sample?"

	label variable sample_time "A36.1 How long has this water been stored for?"
	note sample_time: "A36.1 How long has this water been stored for?"

	label variable sample_time_unit "Unit"
	note sample_time_unit: "Unit"
	label define sample_time_unit 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks"
	label values sample_time_unit sample_time_unit

	label variable wq_stored_fc "A29. What is the free chlorine reading from the sample?"
	note wq_stored_fc: "A29. What is the free chlorine reading from the sample?"

	label variable wq_stored_tc "A30. What is the total chlorine reading from the sample?"
	note wq_stored_tc: "A30. What is the total chlorine reading from the sample?"

	label variable stored_sample_id "A37. Please prepare a sample collection bag and scan the sample ID barcode"
	note stored_sample_id: "A37. Please prepare a sample collection bag and scan the sample ID barcode"

	label variable stored_sample_id_typed "A38. Please enter the sample ID"
	note stored_sample_id_typed: "A38. Please enter the sample ID"

	label variable stored_bag_id "A39. Please enter the bag ID"
	note stored_bag_id: "A39. Please enter the bag ID"

	label variable water_source_prim "A1. Which water source do you primarily use for drinking?"
	note water_source_prim: "A1. Which water source do you primarily use for drinking?"
	label define water_source_prim 1 "JJM Taps" 2 "Community standpipe" 3 "Manual handpump" 4 "Private well" -98 "Other"
	label values water_source_prim water_source_prim

	label variable water_prim_oth "Please specify other"
	note water_prim_oth: "Please specify other"

	label variable water_source_sec "A2.What other water sources have you used for drinking in the past month?"
	note water_source_sec: "A2.What other water sources have you used for drinking in the past month?"

	label variable water_sec_other "Please specify other"
	note water_sec_other: "Please specify other"

	label variable water_sec_circumstances "A2.1 In what circumstances do you collect drinking water from these other water "
	note water_sec_circumstances: "A2.1 In what circumstances do you collect drinking water from these other water sources?"

	label variable water_sec_circumstances_oth "Please specify other"
	note water_sec_circumstances_oth: "Please specify other"

	label variable water_sec_freq "A2.2 How often do you collect water for drinking from these other water sources?"
	note water_sec_freq: "A2.2 How often do you collect water for drinking from these other water sources?"
	label define water_sec_freq 1 "Daily" 2 "Every 2-3 days in a week" 3 "Once a week" 4 "Once a week" 5 "Once a month" 6 "No fixed schedule" -98 "Other" -99 "Don’t know"
	label values water_sec_freq water_sec_freq

	label variable water_sec_freq_oth "Please specify other"
	note water_sec_freq_oth: "Please specify other"

	label variable liters "How many liters of water do you have stored in your house right now?"
	note liters: "How many liters of water do you have stored in your house right now?"

	label variable liters_prim "How many liters come from \${primary_water_label}?"
	note liters_prim: "How many liters come from \${primary_water_label}?"

	label variable liters_sec_jjm "JJM tap:"
	note liters_sec_jjm: "JJM tap:"

	label variable liters_sec_ct "Community standpipe:"
	note liters_sec_ct: "Community standpipe:"

	label variable liters_sec_handpump "Manual handpump:"
	note liters_sec_handpump: "Manual handpump:"

	label variable liters_sec_well "Private well:"
	note liters_sec_well: "Private well:"

	label variable water_treat "Do you ever treat the water from your primary drinking water source (\${primary_"
	note water_treat: "Do you ever treat the water from your primary drinking water source (\${primary_water_label} ) before drinking it?"
	label define water_treat 1 "Yes" 0 "No" -99 "Don't know"
	label values water_treat water_treat

	label variable water_treat_freq "When do you treat the water from your primary drinking water source (\${primary_"
	note water_treat_freq: "When do you treat the water from your primary drinking water source (\${primary_water_label} ) before drinking it?"

	label variable water_treat_type "How do you treat the water from your primary drinking water source (\${primary_w"
	note water_treat_type: "How do you treat the water from your primary drinking water source (\${primary_water_label})?"

	label variable chlorine_consumption "If your drinking water is treated with chlorine, do you drink it?"
	note chlorine_consumption: "If your drinking water is treated with chlorine, do you drink it?"
	label define chlorine_consumption 1 "Yes" 2 "No" 3 "Drinking water is not chlorinated" -99 "Don’t know"
	label values chlorine_consumption chlorine_consumption

	label variable tap_install "A8. When was the tap installed outside your house?"
	note tap_install: "A8. When was the tap installed outside your house?"
	label define tap_install 1 "1-7 Days ago" 2 "1-4 Weeks ago" 3 "1-6 Months ago" 4 "7-12 Months ago" 5 "Over a year ago" -98 "Other" -99 "Don’t know"
	label values tap_install tap_install

	label variable tap_install_oth "Please specify other"
	note tap_install_oth: "Please specify other"

	label variable tap_supply "A9. When did the water supply from the tap begin?"
	note tap_supply: "A9. When did the water supply from the tap begin?"
	label define tap_supply 1 "1-7 Days ago" 2 "1-4 Weeks ago" 3 "1-6 Months ago" 4 "7-12 Months ago" 5 "Over a year ago" -98 "Other" -99 "Don’t know"
	label values tap_supply tap_supply

	label variable tap_supply_oth "Please specify other"
	note tap_supply_oth: "Please specify other"

	label variable tap_supply_freq "A10. How often is water supplied from the JJM tap?"
	note tap_supply_freq: "A10. How often is water supplied from the JJM tap?"
	label define tap_supply_freq 1 "Daily" 2 "2-3 days in a week" 3 "Once a week" 4 "Less than once a week" 5 "2-3 times in a month" 6 "Once a month" 7 "Less than once a month" 8 "No fixed schedule" -98 "Other" -99 "Don’t know"
	label values tap_supply_freq tap_supply_freq

	label variable tap_supply_freq_oth "Please specify other"
	note tap_supply_freq_oth: "Please specify other"

	label variable tap_supply_daily "A11. How many times in a day is water supplied from the JJM tap?"
	note tap_supply_daily: "A11. How many times in a day is water supplied from the JJM tap?"

	label variable tap_use "A12. For what purposes do you use water collected from the JJM taps?"
	note tap_use: "A12. For what purposes do you use water collected from the JJM taps?"

	label variable tap_use_oth "Please specify other"
	note tap_use_oth: "Please specify other"

	label variable tap_use_drinking "A12.2 When was the last time you collected water from the JJM taps for drinking "
	note tap_use_drinking: "A12.2 When was the last time you collected water from the JJM taps for drinking purposes? Not used for drinking Today Yesterday Earlier this week Earlier this month"
	label define tap_use_drinking 1 "Today" 2 "Yesterday" 3 "Earlier this week" 4 "Earlier this month"
	label values tap_use_drinking tap_use_drinking

	label variable tap_function "A13. In the last two weeks, have you tried to collect water from the JJM tap and"
	note tap_function: "A13. In the last two weeks, have you tried to collect water from the JJM tap and it has not worked?"
	label define tap_function 1 "Yes" 0 "No" -99 "Don't know"
	label values tap_function tap_function

	label variable tap_function_reason "A13.1 Why was the JJM tap not working?"
	note tap_function_reason: "A13.1 Why was the JJM tap not working?"
	label define tap_function_reason 1 "Pump operator did not turn on the water flow" 2 "Water was not flowing due to an issue in the storage tank or distribution system" 3 "Water was not flowing due to an issue with the JJM tap itself (broken valve/pipe" 4 "JJM tap was not functioning for a different reason" -99 "Don’t know"
	label values tap_function_reason tap_function_reason

	label variable tap_use_future "A14. How likely are you to use/continue using the JJM tap for drinking in the fu"
	note tap_use_future: "A14. How likely are you to use/continue using the JJM tap for drinking in the future?"
	label define tap_use_future 1 "Very likely" 2 "Somewhat likely" 3 "Neither likely nor unlikely" 4 "Somewhat Unlikely" 5 "Very unlikely"
	label values tap_use_future tap_use_future

	label variable tap_use_discontinue "A14.1 Can you provide any reasons for why you would not continue using the JJM t"
	note tap_use_discontinue: "A14.1 Can you provide any reasons for why you would not continue using the JJM tap in the future?"
	label define tap_use_discontinue 1 "Water supply is not regular" 2 "Water supply is not sufficient" 3 "Water is muddy/ silty" 4 "Water smells or tastes of bleach" -98 "Other" -99 "Don’t know"
	label values tap_use_discontinue tap_use_discontinue

	label variable tap_use_future_oth "Please specify other"
	note tap_use_future_oth: "Please specify other"

	label variable tap_taste_satisfied "A15. How satisfied are you with the taste of water from the JJM tap?"
	note tap_taste_satisfied: "A15. How satisfied are you with the taste of water from the JJM tap?"
	label define tap_taste_satisfied 1 "Very satisfied" 2 "Satisfied" 3 "Neither satisfied nor dissatisfied" 4 "Dissatisfied" 5 "Very dissatisfied"
	label values tap_taste_satisfied tap_taste_satisfied

	label variable tap_taste_desc "A16. How would you describe the taste of the water from the JJM tap?"
	note tap_taste_desc: "A16. How would you describe the taste of the water from the JJM tap?"
	label define tap_taste_desc 1 "Good" 2 "Medicine or chemical" 3 "Metal" 4 "Salty" 5 "Bleach/chlorine (includes WaterGuard)" -98 "Others"
	label values tap_taste_desc tap_taste_desc

	label variable tap_taste_desc_oth "Please specify other"
	note tap_taste_desc_oth: "Please specify other"

	label variable tap_smell "A17. How would you describe the smell of the water from the JJM tap?"
	note tap_smell: "A17. How would you describe the smell of the water from the JJM tap?"
	label define tap_smell 1 "Good" 2 "Medicine or chemical" 3 "Metal" 4 "Salty" 5 "Bleach/chlorine (includes WaterGuard)" -98 "Other"
	label values tap_smell tap_smell

	label variable tap_smell_oth "Please specify other"
	note tap_smell_oth: "Please specify other"

	label variable tap_color "A18. How do you find the color or look of the water from the JJM tap?"
	note tap_color: "A18. How do you find the color or look of the water from the JJM tap?"
	label define tap_color 1 "No problems with the color or look" 2 "Muddy/ sandy water" 3 "Yellow-ish or reddish water (from iron)" -98 "Other" -99 "Don’t know"
	label values tap_color tap_color

	label variable tap_color_oth "Please specify other"
	note tap_color_oth: "Please specify other"

	label variable tap_trust "A19. How confident are you that the water from the JJM tap is safe to drink?"
	note tap_trust: "A19. How confident are you that the water from the JJM tap is safe to drink?"
	label define tap_trust 1 "Very confident" 2 "Somewhat confident" 3 "Neither confident or not confident" 4 "Somewhat not confident" 5 "Not confident at all"
	label values tap_trust tap_trust

	label variable tap_trust_fu "A19.1. Why are you not confident the water is safe to drink?"
	note tap_trust_fu: "A19.1. Why are you not confident the water is safe to drink?"

	label variable tap_trust_oth "Please specify other"
	note tap_trust_oth: "Please specify other"

	label variable collect_resp "A20. Who in your household is responsible for collecting drinking water?"
	note collect_resp: "A20. Who in your household is responsible for collecting drinking water?"

	label variable collect_time "A21. When you collect water, how much time does it take to walk to your primary "
	note collect_time: "A21. When you collect water, how much time does it take to walk to your primary water point, collect water, and return home?"
	label define collect_time 1 "Water point is on-premises" 2 "< 5 minutes" 3 "5-15 minutes" 4 "15-30 minutes" 5 "30-60 minutes" 6 "> 60 minutes"
	label values collect_time collect_time

	label variable collect_freq "A22. How many times in a week do you collect water?"
	note collect_freq: "A22. How many times in a week do you collect water?"

	label variable treat_resp "A23. Who is responsible for treating water before drinking in your household?"
	note treat_resp: "A23. Who is responsible for treating water before drinking in your household?"

	label variable treat_time "A24. How much time does it take to treat your drinking water each time you treat"
	note treat_time: "A24. How much time does it take to treat your drinking water each time you treat it?"
	label define treat_time 1 "No treatment is used" 2 "< 5 minutes" 3 "5-15 minutes" 4 "15-30 minutes" 5 "30-60 minutes" 6 "> 60 minutes"
	label values treat_time treat_time

	label variable treat_freq "A25. How many times in a week do you treat your drinking water?"
	note treat_freq: "A25. How many times in a week do you treat your drinking water?"

	label variable collect_treat_difficult "A26. How difficult is it to collect and treat your drinking water?"
	note collect_treat_difficult: "A26. How difficult is it to collect and treat your drinking water?"
	label define collect_treat_difficult 1 "Very difficult" 2 "Somewhat difficult" 3 "Neither difficult nor easy" 4 "Somewhat easy" 5 "Very easy"
	label values collect_treat_difficult collect_treat_difficult

	label variable tap_benefit "A27. Has the installation of the JJM taps saved you time when collecting or trea"
	note tap_benefit: "A27. Has the installation of the JJM taps saved you time when collecting or treating drinking water?"
	label define tap_benefit 1 "No difference in time saved" 2 "Little" 3 "Somewhat" 4 "Much" 5 "A great amount of time"
	label values tap_benefit tap_benefit

	label variable comment_opt "For enumerator : Do you wish to add any additional comments about this survey?"
	note comment_opt: "For enumerator : Do you wish to add any additional comments about this survey?"
	label define comment_opt 1 "Yes" 0 "No" -99 "Don't know"
	label values comment_opt comment_opt

	label variable overall_comment "For enumerator : Please add any additional comments about this survey"
	note overall_comment: "For enumerator : Please add any additional comments about this survey"






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
*   Corrections file path and filename:  india_ilc_pilot_followup_survey_corrections.csv
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
