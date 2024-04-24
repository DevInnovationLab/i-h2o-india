* import_India_ILC_Endline_Census-Household_available-Cen_CBW_followup.do
*
* 	Imports and aggregates "Endline Census-Household_available-Cen_CBW_followup" (ID: India_ILC_Endline_Census) data.
*
*	Inputs:  "Endline Census-Household_available-Cen_CBW_followup.csv"
*	Outputs: "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Endline Census-Household_available-Cen_CBW_followup.dta"
*
*	Output by SurveyCTO April 23, 2024 3:03 PM.

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
local csvfile "Endline Census-Household_available-Cen_CBW_followup.csv"
local dtafile "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Endline Census-Household_available-Cen_CBW_followup.dta"
local corrfile "Endline Census-Household_available-Cen_CBW_followup_corrections.csv"
local note_fields1 ""
local text_fields1 "cen_preg_index cen_name_cbw_woman_earlier cen_name_cbw_preg cen_no_consent_reason cen_no_consent_oth cen_no_consent_comment cen_preg_hus cen_preg_current_village_oth cen_preg_rch_id"
local text_fields2 "cen_preg_rch_id_inc cen_anti_preg_purpose cen_anti_preg_purpose_oth cen_num_living_null cen_num_notliving_null cen_num_stillborn_null cen_num_less24_null cen_num_more24_null"
local text_fields3 "cen_child_died_lessmore_24_num cen_child_died_u5_count cen_child_died_repeat_count cen_med_symp_cbw cen_med_symp_oth_cbw cen_med_where_cbw cen_med_where_oth_cbw cen_med_out_home_cbw"
local text_fields4 "cen_med_out_oth_cbw cen_prvdrs_exp_loop_cbw_count cen_med_work_who_cbw"
local date_fields1 ""
local datetime_fields1 ""

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



	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable cen_resp_avail_cbw "C2) Did you find \${Cen_name_CBW_woman_earlier} to interview?"
	note cen_resp_avail_cbw: "C2) Did you find \${Cen_name_CBW_woman_earlier} to interview?"
	label define cen_resp_avail_cbw 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 7 "Respondent died or is no longer a member of the household" 8 "Respondent no longer falls in the criteria (15-49 years)"
	label values cen_resp_avail_cbw cen_resp_avail_cbw

	label variable cen_resp_age_v_cbw "Did you verify \${Cen_name_CBW_woman_earlier} age with adhaar card or any other "
	note cen_resp_age_v_cbw: "Did you verify \${Cen_name_CBW_woman_earlier} age with adhaar card or any other official identity document ?"
	label define cen_resp_age_v_cbw 1 "Yes" 0 "No"
	label values cen_resp_age_v_cbw cen_resp_age_v_cbw

	label variable cen_resp_age_cbw "What is the actual age of \${Cen_name_CBW_woman_earlier}?"
	note cen_resp_age_cbw: "What is the actual age of \${Cen_name_CBW_woman_earlier}?"

	label variable cen_cbw_consent "C3)Do I have your permission to proceed with the interview?"
	note cen_cbw_consent: "C3)Do I have your permission to proceed with the interview?"
	label define cen_cbw_consent 1 "Yes" 0 "No"
	label values cen_cbw_consent cen_cbw_consent

	label variable cen_no_consent_reason "C4) Can you tell me why you do not want to participate in the survey?"
	note cen_no_consent_reason: "C4) Can you tell me why you do not want to participate in the survey?"

	label variable cen_no_consent_oth "C4.1) Please specify other"
	note cen_no_consent_oth: "C4.1) Please specify other"

	label variable cen_no_consent_comment "C4.2) Record any relevant notes if the respondent refused the interview"
	note cen_no_consent_comment: "C4.2) Record any relevant notes if the respondent refused the interview"

	label variable cen_preg_status "Is \${Cen_name_CBW_woman_earlier} pregnant?"
	note cen_preg_status: "Is \${Cen_name_CBW_woman_earlier} pregnant?"
	label define cen_preg_status 1 "Yes" 0 "No"
	label values cen_preg_status cen_preg_status

	label variable cen_not_curr_preg "Was \${Cen_name_CBW_woman_earlier} pregnant in the last 7 months?"
	note cen_not_curr_preg: "Was \${Cen_name_CBW_woman_earlier} pregnant in the last 7 months?"
	label define cen_not_curr_preg 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_not_curr_preg cen_not_curr_preg

	label variable cen_preg_month "Which month of \${Cen_name_CBW_woman_earlier}'s pregnancy is this?"
	note cen_preg_month: "Which month of \${Cen_name_CBW_woman_earlier}'s pregnancy is this?"

	label variable cen_preg_delivery "What is the expected month of delivery of \${Cen_name_CBW_woman_earlier}? (Write"
	note cen_preg_delivery: "What is the expected month of delivery of \${Cen_name_CBW_woman_earlier}? (Write no. of the calender month)"

	label variable cen_preg_hus "What is the name of \${Cen_name_CBW_woman_earlier}'s husband?"
	note cen_preg_hus: "What is the name of \${Cen_name_CBW_woman_earlier}'s husband?"

	label variable cen_preg_residence "Is this \${Cen_name_CBW_woman_earlier}'s usual residence?"
	note cen_preg_residence: "Is this \${Cen_name_CBW_woman_earlier}'s usual residence?"
	label define cen_preg_residence 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_preg_residence cen_preg_residence

	label variable cen_preg_stay "C7) How long is \${Cen_name_CBW_woman_earlier} planning to stay here (at the hou"
	note cen_preg_stay: "C7) How long is \${Cen_name_CBW_woman_earlier} planning to stay here (at the house where the survey is being conducted) ?"
	label define cen_preg_stay 1 "Months" 2 "Days" 999 "Don't know"
	label values cen_preg_stay cen_preg_stay

	label variable cen_preg_stay_days "Record in Days"
	note cen_preg_stay_days: "Record in Days"

	label variable cen_preg_stay_months "Record in Months"
	note cen_preg_stay_months: "Record in Months"

	label variable cen_preg_current_village "C6) Which village is \${Cen_name_CBW_woman_earlier} ’s current permanent residen"
	note cen_preg_current_village: "C6) Which village is \${Cen_name_CBW_woman_earlier} ’s current permanent residence in?"
	label define cen_preg_current_village 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30601 "Hatikhamba" 30602 "Mukundpur" 30701 "Gopi Kankubadi" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 50601 "Badaalubadi" -77 "Other"
	label values cen_preg_current_village cen_preg_current_village

	label variable cen_preg_current_village_oth "C6.1) Please specify other"
	note cen_preg_current_village_oth: "C6.1) Please specify other"

	label variable cen_vill_residence "C8) Was \${village_name_res}\${Cen_name_CBW_woman_earlier}'s permanent residence"
	note cen_vill_residence: "C8) Was \${village_name_res}\${Cen_name_CBW_woman_earlier}'s permanent residence at any time in the last 5 years?"
	label define cen_vill_residence 1 "Yes" 0 "No"
	label values cen_vill_residence cen_vill_residence

	label variable cen_preg_get_rch "Did \${Cen_name_CBW_woman_earlier} register the pregnancy with the ASHA and get "
	note cen_preg_get_rch: "Did \${Cen_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a registration card/number (RCH ID)?"
	label define cen_preg_get_rch 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_preg_get_rch cen_preg_get_rch

	label variable cen_preg_get_rch_confirm "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${"
	note cen_preg_get_rch_confirm: "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${Cen_name_CBW_woman_earlier} has received an RCH ID?"
	label define cen_preg_get_rch_confirm 1 "Yes" 0 "No"
	label values cen_preg_get_rch_confirm cen_preg_get_rch_confirm

	label variable cen_preg_rch_id "Please note down RCH ID no. of \${Cen_name_CBW_woman_earlier}"
	note cen_preg_rch_id: "Please note down RCH ID no. of \${Cen_name_CBW_woman_earlier}"

	label variable cen_preg_rch_id_inc "Please note down RCH ID no. of \${Cen_name_CBW_woman_earlier}. Write the RCH ID "
	note cen_preg_rch_id_inc: "Please note down RCH ID no. of \${Cen_name_CBW_woman_earlier}. Write the RCH ID here only if some of the digits are missing or extra from the booklet shown by the respondent. The correct RCH ID will have exactly 12 digits so if that is not the case with this ID mention here."

	label variable cen_wom_vomit_day "A22) Did \${Cen_name_CBW_woman_earlier} vomit today or yesterday?"
	note cen_wom_vomit_day: "A22) Did \${Cen_name_CBW_woman_earlier} vomit today or yesterday?"
	label define cen_wom_vomit_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_vomit_day cen_wom_vomit_day

	label variable cen_wom_vomit_wk "A22.1) Did \${Cen_name_CBW_woman_earlier} vomit in the last 7 days?"
	note cen_wom_vomit_wk: "A22.1) Did \${Cen_name_CBW_woman_earlier} vomit in the last 7 days?"
	label define cen_wom_vomit_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_vomit_wk cen_wom_vomit_wk

	label variable cen_wom_vomit_2wk "A22.2) Did \${Cen_name_CBW_woman_earlier} vomit in the past 2 weeks?"
	note cen_wom_vomit_2wk: "A22.2) Did \${Cen_name_CBW_woman_earlier} vomit in the past 2 weeks?"
	label define cen_wom_vomit_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_vomit_2wk cen_wom_vomit_2wk

	label variable cen_wom_diarr_day "A23) Did \${Cen_name_CBW_woman_earlier} have diarrhea today or yesterday?"
	note cen_wom_diarr_day: "A23) Did \${Cen_name_CBW_woman_earlier} have diarrhea today or yesterday?"
	label define cen_wom_diarr_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_diarr_day cen_wom_diarr_day

	label variable cen_wom_diarr_wk "A23.1) Did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
	note cen_wom_diarr_wk: "A23.1) Did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
	label define cen_wom_diarr_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_diarr_wk cen_wom_diarr_wk

	label variable cen_wom_diarr_2wk "A23.2) Did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
	note cen_wom_diarr_2wk: "A23.2) Did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
	label define cen_wom_diarr_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_diarr_2wk cen_wom_diarr_2wk

	label variable cen_wom_diarr_num_wk "A24.1) How many days did \${Cen_name_CBW_woman_earlier} have diarrhea in the pas"
	note cen_wom_diarr_num_wk: "A24.1) How many days did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 7 days?"

	label variable cen_wom_diarr_num_2wks "A24.2) How many days did \${Cen_name_CBW_woman_earlier} have diarrhea in the pas"
	note cen_wom_diarr_num_2wks: "A24.2) How many days did \${Cen_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"

	label variable cen_wom_stool_24h "A25) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools wi"
	note cen_wom_stool_24h: "A25) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools within the last 24 hours?"
	label define cen_wom_stool_24h 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_stool_24h cen_wom_stool_24h

	label variable cen_wom_stool_yest "A25.1) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools "
	note cen_wom_stool_yest: "A25.1) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools yesterday?"
	label define cen_wom_stool_yest 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_stool_yest cen_wom_stool_yest

	label variable cen_wom_stool_wk "A25.2) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools "
	note cen_wom_stool_wk: "A25.2) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the the past 7 days?"
	label define cen_wom_stool_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_stool_wk cen_wom_stool_wk

	label variable cen_wom_stool_2wk "A25.3) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools "
	note cen_wom_stool_2wk: "A25.3) Did \${Cen_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the past 2 weeks?"
	label define cen_wom_stool_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_stool_2wk cen_wom_stool_2wk

	label variable cen_wom_blood_day "A26) Did \${Cen_name_CBW_woman_earlier} have blood in her stool today or yesterd"
	note cen_wom_blood_day: "A26) Did \${Cen_name_CBW_woman_earlier} have blood in her stool today or yesterday?"
	label define cen_wom_blood_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_blood_day cen_wom_blood_day

	label variable cen_wom_blood_wk "A26.1) Did \${Cen_name_CBW_woman_earlier} have blood in her stool in the past 7 "
	note cen_wom_blood_wk: "A26.1) Did \${Cen_name_CBW_woman_earlier} have blood in her stool in the past 7 days?"
	label define cen_wom_blood_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_blood_wk cen_wom_blood_wk

	label variable cen_wom_blood_2wk "A26.2) Did \${Cen_name_CBW_woman_earlier} have blood in her stool in the past 2 "
	note cen_wom_blood_2wk: "A26.2) Did \${Cen_name_CBW_woman_earlier} have blood in her stool in the past 2 weeks?"
	label define cen_wom_blood_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_blood_2wk cen_wom_blood_2wk

	label variable cen_wom_cuts_day "A21) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts toda"
	note cen_wom_cuts_day: "A21) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today or yesterday?"
	label define cen_wom_cuts_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_cuts_day cen_wom_cuts_day

	label variable cen_wom_cuts_wk "A21.1) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in"
	note cen_wom_cuts_wk: "A21.1) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the last 7 days?"
	label define cen_wom_cuts_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_cuts_wk cen_wom_cuts_wk

	label variable cen_wom_cuts_2wk "A21.2) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in"
	note cen_wom_cuts_2wk: "A21.2) Did \${Cen_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the past 2 weeks?"
	label define cen_wom_cuts_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_wom_cuts_2wk cen_wom_cuts_2wk

	label variable cen_anti_preg_wk "In the last week, has \${Cen_name_CBW_woman_earlier} taken antibiotics?"
	note cen_anti_preg_wk: "In the last week, has \${Cen_name_CBW_woman_earlier} taken antibiotics?"
	label define cen_anti_preg_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_anti_preg_wk cen_anti_preg_wk

	label variable cen_anti_preg_days "In the last week, How many days ago did \${Cen_name_CBW_woman_earlier} take anti"
	note cen_anti_preg_days: "In the last week, How many days ago did \${Cen_name_CBW_woman_earlier} take antibiotics?"

	label variable cen_anti_preg_last "How long ago did \${Cen_name_CBW_woman_earlier} last take antibiotics?"
	note cen_anti_preg_last: "How long ago did \${Cen_name_CBW_woman_earlier} last take antibiotics?"
	label define cen_anti_preg_last 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
	label values cen_anti_preg_last cen_anti_preg_last

	label variable cen_anti_preg_last_months "Please specify in months"
	note cen_anti_preg_last_months: "Please specify in months"

	label variable cen_anti_preg_last_days "Please specify in days"
	note cen_anti_preg_last_days: "Please specify in days"

	label variable cen_anti_preg_purpose "For what purpose did you take antibiotics?"
	note cen_anti_preg_purpose: "For what purpose did you take antibiotics?"

	label variable cen_anti_preg_purpose_oth "Please specify others"
	note cen_anti_preg_purpose_oth: "Please specify others"

	label variable cen_last_5_years_pregnant "C9)Has \${Cen_name_CBW_woman_earlier} ever been pregnant in the last 5 years sin"
	note cen_last_5_years_pregnant: "C9)Has \${Cen_name_CBW_woman_earlier} ever been pregnant in the last 5 years since January 1, 2019?"
	label define cen_last_5_years_pregnant 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_last_5_years_pregnant cen_last_5_years_pregnant

	label variable cen_child_living "C10) Do you have any children under 5 years of age to whom you have given birth "
	note cen_child_living: "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
	label define cen_child_living 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_child_living cen_child_living

	label variable cen_child_living_num "C11) How many children born since January 1, 2019 live with you?"
	note cen_child_living_num: "C11) How many children born since January 1, 2019 live with you?"

	label variable cen_child_notliving "C12) Do you have any children born since January 1, 2019 to whom you have given "
	note cen_child_notliving: "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
	label define cen_child_notliving 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_child_notliving cen_child_notliving

	label variable cen_child_notliving_num "C13) How many children born since January 1, 2019 are alive but do not live with"
	note cen_child_notliving_num: "C13) How many children born since January 1, 2019 are alive but do not live with you?"

	label variable cen_child_stillborn "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
	note cen_child_stillborn: "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
	label define cen_child_stillborn 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_child_stillborn cen_child_stillborn

	label variable cen_child_stillborn_num "C15) How many children born since January 1, 2019 were stillborn?"
	note cen_child_stillborn_num: "C15) How many children born since January 1, 2019 were stillborn?"

	label variable cen_child_alive_died_less24 "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
	note cen_child_alive_died_less24: "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
	label define cen_child_alive_died_less24 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_child_alive_died_less24 cen_child_alive_died_less24

	label variable cen_child_alive_died_less24_num "C17) How many children born since January 1, 2019 have died within 24 hours?"
	note cen_child_alive_died_less24_num: "C17) How many children born since January 1, 2019 have died within 24 hours?"

	label variable cen_child_alive_died_more24 "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
	note cen_child_alive_died_more24: "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
	label define cen_child_alive_died_more24 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_child_alive_died_more24 cen_child_alive_died_more24

	label variable cen_child_alive_died_more24_num "C19) How many children born since January 1, 2019 have died after 24 hours from "
	note cen_child_alive_died_more24_num: "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"

	label variable cen_confirm "Please confirm that \${Cen_name_CBW_woman_earlier} had \${Cen_child_living_num} "
	note cen_confirm: "Please confirm that \${Cen_name_CBW_woman_earlier} had \${Cen_child_living_num} children who were born since 1 January 2019 and living with them, \${Cen_child_stillborn_num} still births and \${Cen_child_died_lessmore_24_num} children who were born but later died. Is this information complete and correct?"
	label define cen_confirm 1 "Yes" 0 "No"
	label values cen_confirm cen_confirm

	label variable cen_miscarriage "C28)Did you have a miscarriage during the pregnancy?"
	note cen_miscarriage: "C28)Did you have a miscarriage during the pregnancy?"
	label define cen_miscarriage 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_miscarriage cen_miscarriage

	label variable cen_correct "C29)Have you corrected respondent's details if they were incorrect earlier?"
	note cen_correct: "C29)Have you corrected respondent's details if they were incorrect earlier?"
	label define cen_correct 1 "Yes" 0 "No"
	label values cen_correct cen_correct

	label variable cen_med_seek_care_cbw "In the past one month, did \${Cen_name_CBW_woman_earlier} seek medical care?"
	note cen_med_seek_care_cbw: "In the past one month, did \${Cen_name_CBW_woman_earlier} seek medical care?"
	label define cen_med_seek_care_cbw 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_med_seek_care_cbw cen_med_seek_care_cbw

	label variable cen_med_diarrhea_cbw "Previously \${Cen_name_CBW_woman_earlier} said that she has diarrhea, and if \${"
	note cen_med_diarrhea_cbw: "Previously \${Cen_name_CBW_woman_earlier} said that she has diarrhea, and if \${Cen_name_CBW_woman_earlier} did not mention that she took medical care for it. Please ask politely 'If \${Cen_name_CBW_woman_earlier} had diarrhea in the last one month, then why she did not take medical care for it?'"
	label define cen_med_diarrhea_cbw 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
	label values cen_med_diarrhea_cbw cen_med_diarrhea_cbw

	label variable cen_med_visits_cbw "How many visits \${Cen_name_CBW_woman_earlier} did in the last one month to seek"
	note cen_med_visits_cbw: "How many visits \${Cen_name_CBW_woman_earlier} did in the last one month to seek medical care?"

	label variable cen_med_symp_cbw "What was the symptom, or what was the reason for medical care?"
	note cen_med_symp_cbw: "What was the symptom, or what was the reason for medical care?"

	label variable cen_med_symp_oth_cbw "Other"
	note cen_med_symp_oth_cbw: "Other"

	label variable cen_med_where_cbw "Where did \${Cen_name_CBW_woman_earlier} seek care?"
	note cen_med_where_cbw: "Where did \${Cen_name_CBW_woman_earlier} seek care?"

	label variable cen_med_where_oth_cbw "Other"
	note cen_med_where_oth_cbw: "Other"

	label variable cen_med_nights_cbw "How many nights did \${Cen_name_CBW_woman_earlier} spend in the hospital?"
	note cen_med_nights_cbw: "How many nights did \${Cen_name_CBW_woman_earlier} spend in the hospital?"

	label variable cen_med_out_home_cbw "Where did \${Cen_name_CBW_woman_earlier} seek care?"
	note cen_med_out_home_cbw: "Where did \${Cen_name_CBW_woman_earlier} seek care?"

	label variable cen_med_out_oth_cbw "Other"
	note cen_med_out_oth_cbw: "Other"

	label variable cen_med_t_exp_cbw "In the last one month, what was the total expenditure \${Cen_name_CBW_woman_earl"
	note cen_med_t_exp_cbw: "In the last one month, what was the total expenditure \${Cen_name_CBW_woman_earlier} did on medical care?"

	label variable cen_med_work_cbw "Did anyone in your household, including you, change their work/housework routing"
	note cen_med_work_cbw: "Did anyone in your household, including you, change their work/housework routing to take care of \${Cen_name_CBW_woman_earlier} ?"
	label define cen_med_work_cbw 1 "Yes" 0 "No" 999 "Don't know"
	label values cen_med_work_cbw cen_med_work_cbw

	label variable cen_med_work_who_cbw "Who adjusted their schedule to take care of \${Cen_name_CBW_woman_earlier}?"
	note cen_med_work_who_cbw: "Who adjusted their schedule to take care of \${Cen_name_CBW_woman_earlier}?"

	label variable cen_med_days_caretaking_cbw "How many days have this person taken caretaking \${Cen_name_CBW_woman_earlier} ("
	note cen_med_days_caretaking_cbw: "How many days have this person taken caretaking \${Cen_name_CBW_woman_earlier} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"

	label variable cen_translator "C30)Was a translator used in the survey?"
	note cen_translator: "C30)Was a translator used in the survey?"
	label define cen_translator 1 "Yes" 0 "No"
	label values cen_translator cen_translator






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
*   Corrections file path and filename:  Endline Census-Household_available-Cen_CBW_followup_corrections.csv
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
