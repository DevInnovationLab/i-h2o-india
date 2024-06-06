* import_India_ILC_Endline_Census_Revisit-Household_available-N_CBW_followup.do
*
* 	Imports and aggregates "Endline Census Re-visit-Household_available-N_CBW_followup" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup.dta"
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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup_corrections.csv"
local note_fields1 ""
local text_fields1 "n_cbw_ind n_cen_women_status n_name_cbw_woman_earlier n_resp_avail_cbw_oth n_no_consent_reason n_no_consent_oth n_no_consent_comment n_preg_hus n_preg_current_village_oth n_preg_rch_id"
local text_fields2 "n_preg_rch_id_inc n_anti_preg_purpose n_anti_preg_purpose_oth n_num_living_null n_num_notliving_null n_num_stillborn_null n_num_less24_null n_num_more24_null n_child_died_lessmore_24_num"
local text_fields3 "n_child_died_u5_count n_child_died_repeat_count n_med_symp_cbw n_med_symp_oth_cbw n_med_where_cbw n_med_where_oth_cbw n_med_out_home_cbw n_med_out_oth_cbw n_prvdrs_exp_loop_cbw_count"
local text_fields4 "n_med_work_who_cbw"
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


	label variable n_resp_avail_cbw "C2) Did you find \${N_name_CBW_woman_earlier} to interview?"
	note n_resp_avail_cbw: "C2) Did you find \${N_name_CBW_woman_earlier} to interview?"
	label define n_resp_avail_cbw 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 9 "Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other, please specify"
	label values n_resp_avail_cbw n_resp_avail_cbw

	label variable n_resp_avail_cbw_oth "B1.1) Please specify other"
	note n_resp_avail_cbw_oth: "B1.1) Please specify other"

	label variable n_cbw_consent "C3)Do I have your permission to proceed with the interview?"
	note n_cbw_consent: "C3)Do I have your permission to proceed with the interview?"
	label define n_cbw_consent 1 "Yes" 0 "No"
	label values n_cbw_consent n_cbw_consent

	label variable n_no_consent_reason "C4) Can you tell me why you do not want to participate in the survey?"
	note n_no_consent_reason: "C4) Can you tell me why you do not want to participate in the survey?"

	label variable n_no_consent_oth "C4.1) Please specify other"
	note n_no_consent_oth: "C4.1) Please specify other"

	label variable n_no_consent_comment "C4.2) Record any relevant notes if the respondent refused the interview"
	note n_no_consent_comment: "C4.2) Record any relevant notes if the respondent refused the interview"

	label variable n_preg_status "Is \${N_name_CBW_woman_earlier} pregnant?"
	note n_preg_status: "Is \${N_name_CBW_woman_earlier} pregnant?"
	label define n_preg_status 1 "Yes" 0 "No"
	label values n_preg_status n_preg_status

	label variable n_not_curr_preg "Was \${N_name_CBW_woman_earlier} pregnant in the last 7 months?"
	note n_not_curr_preg: "Was \${N_name_CBW_woman_earlier} pregnant in the last 7 months?"
	label define n_not_curr_preg 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_not_curr_preg n_not_curr_preg

	label variable n_preg_month "Which month of \${N_name_CBW_woman_earlier}'s pregnancy is this?"
	note n_preg_month: "Which month of \${N_name_CBW_woman_earlier}'s pregnancy is this?"

	label variable n_preg_delivery "What is the expected month of delivery of \${N_name_CBW_woman_earlier}?"
	note n_preg_delivery: "What is the expected month of delivery of \${N_name_CBW_woman_earlier}?"

	label variable n_preg_hus "What is the name of \${N_name_CBW_woman_earlier}'s husband?"
	note n_preg_hus: "What is the name of \${N_name_CBW_woman_earlier}'s husband?"

	label variable n_preg_residence "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
	note n_preg_residence: "Is this \${N_name_CBW_woman_earlier}'s usual residence?"
	label define n_preg_residence 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_preg_residence n_preg_residence

	label variable n_preg_stay "How long is \${N_name_CBW_woman_earlier} planning to stay here (at the house whe"
	note n_preg_stay: "How long is \${N_name_CBW_woman_earlier} planning to stay here (at the house where the survey is being conducted) ?"
	label define n_preg_stay 1 "Months" 2 "Days" 999 "Don't know"
	label values n_preg_stay n_preg_stay

	label variable n_preg_stay_months "Record in months"
	note n_preg_stay_months: "Record in months"

	label variable n_preg_stay_days "Record in Days"
	note n_preg_stay_days: "Record in Days"

	label variable n_preg_current_village "Which village is \${N_name_CBW_woman_earlier} ’s current permanent residence in?"
	note n_preg_current_village: "Which village is \${N_name_CBW_woman_earlier} ’s current permanent residence in?"
	label define n_preg_current_village 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30601 "Hatikhamba" 30602 "Mukundpur" 30701 "Gopi Kankubadi" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 50601 "Badaalubadi" -77 "Other"
	label values n_preg_current_village n_preg_current_village

	label variable n_preg_current_village_oth "C6.1) Please specify other"
	note n_preg_current_village_oth: "C6.1) Please specify other"

	label variable n_vill_residence "C8) Was \${village_name_res}\${N_name_CBW_woman_earlier}'s permanent residence a"
	note n_vill_residence: "C8) Was \${village_name_res}\${N_name_CBW_woman_earlier}'s permanent residence at any time in the last 5 years?"
	label define n_vill_residence 1 "Yes" 0 "No"
	label values n_vill_residence n_vill_residence

	label variable n_preg_get_rch "Did \${N_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a "
	note n_preg_get_rch: "Did \${N_name_CBW_woman_earlier} register the pregnancy with the ASHA and get a registration card/number (RCH ID)?"
	label define n_preg_get_rch 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_preg_get_rch n_preg_get_rch

	label variable n_preg_get_rch_confirm "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${"
	note n_preg_get_rch_confirm: "INVESTIGATOR OBSERVATION: Ask to see the card. Were you able to confirm that \${N_name_CBW_woman_earlier} has received an RCH ID?"
	label define n_preg_get_rch_confirm 1 "Yes" 0 "No"
	label values n_preg_get_rch_confirm n_preg_get_rch_confirm

	label variable n_preg_rch_id "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}"
	note n_preg_rch_id: "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}"

	label variable n_preg_rch_id_inc "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}. Write the RCH ID he"
	note n_preg_rch_id_inc: "Please note down RCH ID no. of \${N_name_CBW_woman_earlier}. Write the RCH ID here only if some of the digits are missing or extra from the booklet shown by the respondent. The correct RCH ID will have exactly 12 digits so if that is not the case with this ID mention here."

	label variable n_wom_vomit_day "A22) Did \${N_name_CBW_woman_earlier} vomit today or yesterday?"
	note n_wom_vomit_day: "A22) Did \${N_name_CBW_woman_earlier} vomit today or yesterday?"
	label define n_wom_vomit_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_vomit_day n_wom_vomit_day

	label variable n_wom_vomit_wk "A22.1) Did \${N_name_CBW_woman_earlier} vomit in the last 7 days?"
	note n_wom_vomit_wk: "A22.1) Did \${N_name_CBW_woman_earlier} vomit in the last 7 days?"
	label define n_wom_vomit_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_vomit_wk n_wom_vomit_wk

	label variable n_wom_vomit_2wk "A22.2) Did \${N_name_CBW_woman_earlier} vomit in the past 2 weeks?"
	note n_wom_vomit_2wk: "A22.2) Did \${N_name_CBW_woman_earlier} vomit in the past 2 weeks?"
	label define n_wom_vomit_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_vomit_2wk n_wom_vomit_2wk

	label variable n_wom_diarr_day "A23) Did \${N_name_CBW_woman_earlier} have diarrhea today or yesterday?"
	note n_wom_diarr_day: "A23) Did \${N_name_CBW_woman_earlier} have diarrhea today or yesterday?"
	label define n_wom_diarr_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_diarr_day n_wom_diarr_day

	label variable n_wom_diarr_wk "A23.1) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
	note n_wom_diarr_wk: "A23.1) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"
	label define n_wom_diarr_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_diarr_wk n_wom_diarr_wk

	label variable n_wom_diarr_2wk "A23.2) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
	note n_wom_diarr_2wk: "A23.2) Did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"
	label define n_wom_diarr_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_diarr_2wk n_wom_diarr_2wk

	label variable n_wom_diarr_num_wk "A24.1) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past "
	note n_wom_diarr_num_wk: "A24.1) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past 7 days?"

	label variable n_wom_diarr_num_2wks "A24.2) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past "
	note n_wom_diarr_num_2wks: "A24.2) How many days did \${N_name_CBW_woman_earlier} have diarrhea in the past 2 weeks?"

	label variable n_wom_stool_24h "A25) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools with"
	note n_wom_stool_24h: "A25) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools within the last 24 hours?"
	label define n_wom_stool_24h 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_stool_24h n_wom_stool_24h

	label variable n_wom_stool_yest "A25.1) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools ye"
	note n_wom_stool_yest: "A25.1) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools yesterday?"
	label define n_wom_stool_yest 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_stool_yest n_wom_stool_yest

	label variable n_wom_stool_wk "A25.2) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in"
	note n_wom_stool_wk: "A25.2) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the the past 7 days?"
	label define n_wom_stool_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_stool_wk n_wom_stool_wk

	label variable n_wom_stool_2wk "A25.3) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in"
	note n_wom_stool_2wk: "A25.3) Did \${N_name_CBW_woman_earlier} have 3 or more loose or watery stools in a 24-hour period in the past 2 weeks?"
	label define n_wom_stool_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_stool_2wk n_wom_stool_2wk

	label variable n_wom_blood_day "A26) Did \${N_name_CBW_woman_earlier} have blood in her stool today or yesterday"
	note n_wom_blood_day: "A26) Did \${N_name_CBW_woman_earlier} have blood in her stool today or yesterday?"
	label define n_wom_blood_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_blood_day n_wom_blood_day

	label variable n_wom_blood_wk "A26.1) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 7 da"
	note n_wom_blood_wk: "A26.1) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 7 days?"
	label define n_wom_blood_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_blood_wk n_wom_blood_wk

	label variable n_wom_blood_2wk "A26.2) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 2 we"
	note n_wom_blood_2wk: "A26.2) Did \${N_name_CBW_woman_earlier} have blood in her stool in the past 2 weeks?"
	label define n_wom_blood_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_blood_2wk n_wom_blood_2wk

	label variable n_wom_cuts_day "A21) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today "
	note n_wom_cuts_day: "A21) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts today or yesterday?"
	label define n_wom_cuts_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_cuts_day n_wom_cuts_day

	label variable n_wom_cuts_wk "A21.1) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in t"
	note n_wom_cuts_wk: "A21.1) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the last 7 days?"
	label define n_wom_cuts_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_cuts_wk n_wom_cuts_wk

	label variable n_wom_cuts_2wk "A21.2) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in t"
	note n_wom_cuts_2wk: "A21.2) Did \${N_name_CBW_woman_earlier} have any bruising, scrapes, or cuts in the past 2 weeks?"
	label define n_wom_cuts_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_wom_cuts_2wk n_wom_cuts_2wk

	label variable n_anti_preg_wk "In the last week, has \${N_name_CBW_woman_earlier} taken antibiotics?"
	note n_anti_preg_wk: "In the last week, has \${N_name_CBW_woman_earlier} taken antibiotics?"
	label define n_anti_preg_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_anti_preg_wk n_anti_preg_wk

	label variable n_anti_preg_days "How many days ago did \${N_name_CBW_woman_earlier} take antibiotics?"
	note n_anti_preg_days: "How many days ago did \${N_name_CBW_woman_earlier} take antibiotics?"

	label variable n_anti_preg_last "How long ago did \${N_name_CBW_woman_earlier} last take antibiotics?"
	note n_anti_preg_last: "How long ago did \${N_name_CBW_woman_earlier} last take antibiotics?"
	label define n_anti_preg_last 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
	label values n_anti_preg_last n_anti_preg_last

	label variable n_anti_preg_last_months "Please specify in months"
	note n_anti_preg_last_months: "Please specify in months"

	label variable n_anti_preg_last_days "Please specify in days"
	note n_anti_preg_last_days: "Please specify in days"

	label variable n_anti_preg_purpose "For what purpose did you take antibiotics?"
	note n_anti_preg_purpose: "For what purpose did you take antibiotics?"

	label variable n_anti_preg_purpose_oth "Please specify others"
	note n_anti_preg_purpose_oth: "Please specify others"

	label variable n_last_5_years_pregnant "C9)Has \${N_name_CBW_woman_earlier} ever been pregnant in the last 5 years since"
	note n_last_5_years_pregnant: "C9)Has \${N_name_CBW_woman_earlier} ever been pregnant in the last 5 years since January 1, 2019?"
	label define n_last_5_years_pregnant 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_last_5_years_pregnant n_last_5_years_pregnant

	label variable n_child_living "C10) Do you have any children under 5 years of age to whom you have given birth "
	note n_child_living: "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
	label define n_child_living 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_child_living n_child_living

	label variable n_child_living_num "C11) How many children born since January 1, 2019 live with you?"
	note n_child_living_num: "C11) How many children born since January 1, 2019 live with you?"

	label variable n_child_notliving "C12) Do you have any children born since January 1, 2019 to whom you have given "
	note n_child_notliving: "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
	label define n_child_notliving 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_child_notliving n_child_notliving

	label variable n_child_notliving_num "C13) How many children born since January 1, 2019 are alive but do not live with"
	note n_child_notliving_num: "C13) How many children born since January 1, 2019 are alive but do not live with you?"

	label variable n_child_stillborn "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
	note n_child_stillborn: "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
	label define n_child_stillborn 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_child_stillborn n_child_stillborn

	label variable n_child_stillborn_num "C15) How many children born since January 1, 2019 were stillborn?"
	note n_child_stillborn_num: "C15) How many children born since January 1, 2019 were stillborn?"

	label variable n_child_alive_died_less24 "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
	note n_child_alive_died_less24: "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
	label define n_child_alive_died_less24 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_child_alive_died_less24 n_child_alive_died_less24

	label variable n_child_alive_died_less24_num "C17) How many children born since January 1, 2019 have died within 24 hours?"
	note n_child_alive_died_less24_num: "C17) How many children born since January 1, 2019 have died within 24 hours?"

	label variable n_child_alive_died_more24 "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
	note n_child_alive_died_more24: "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
	label define n_child_alive_died_more24 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_child_alive_died_more24 n_child_alive_died_more24

	label variable n_child_alive_died_more24_num "C19) How many children born since January 1, 2019 have died after 24 hours from "
	note n_child_alive_died_more24_num: "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"

	label variable n_confirm "Please confirm that \${N_name_CBW_woman_earlier} had \${N_child_living_num} chil"
	note n_confirm: "Please confirm that \${N_name_CBW_woman_earlier} had \${N_child_living_num} children who were born since 1 January 2019 and living with them, \${N_child_stillborn_num} still births and \${N_child_died_lessmore_24_num} children who were born but later died. Is this information complete and correct?"
	label define n_confirm 1 "Yes" 0 "No"
	label values n_confirm n_confirm

	label variable n_miscarriage "Did you have a miscarriage during the pregnancy?"
	note n_miscarriage: "Did you have a miscarriage during the pregnancy?"
	label define n_miscarriage 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_miscarriage n_miscarriage

	label variable n_correct "C28)Have you corrected respondent's details if they were incorrect earlier?"
	note n_correct: "C28)Have you corrected respondent's details if they were incorrect earlier?"
	label define n_correct 1 "Yes" 0 "No"
	label values n_correct n_correct

	label variable n_med_seek_care_cbw "In the past one month, did \${N_name_CBW_woman_earlier} seek medical care?"
	note n_med_seek_care_cbw: "In the past one month, did \${N_name_CBW_woman_earlier} seek medical care?"
	label define n_med_seek_care_cbw 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_med_seek_care_cbw n_med_seek_care_cbw

	label variable n_med_diarrhea_cbw "Previously \${N_name_CBW_woman_earlier} said that she has diarrhea, and if \${N_"
	note n_med_diarrhea_cbw: "Previously \${N_name_CBW_woman_earlier} said that she has diarrhea, and if \${N_name_CBW_woman_earlier} did not mention that she took medical care for it. Please ask politely 'If \${N_name_CBW_woman_earlier} had diarrhea in the last one month, then why she did not take medical care for it?'"
	label define n_med_diarrhea_cbw 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
	label values n_med_diarrhea_cbw n_med_diarrhea_cbw

	label variable n_med_visits_cbw "How many visits \${N_name_CBW_woman_earlier} did in the last one month to seek m"
	note n_med_visits_cbw: "How many visits \${N_name_CBW_woman_earlier} did in the last one month to seek medical care?"

	label variable n_med_symp_cbw "What was the symptom, or what was the reason for medical care?"
	note n_med_symp_cbw: "What was the symptom, or what was the reason for medical care?"

	label variable n_med_symp_oth_cbw "Other"
	note n_med_symp_oth_cbw: "Other"

	label variable n_med_where_cbw "Where did \${N_name_CBW_woman_earlier} seek care?"
	note n_med_where_cbw: "Where did \${N_name_CBW_woman_earlier} seek care?"

	label variable n_med_where_oth_cbw "Other"
	note n_med_where_oth_cbw: "Other"

	label variable n_med_nights_cbw "How many nights did \${N_name_CBW_woman_earlier} spend in the hospital?"
	note n_med_nights_cbw: "How many nights did \${N_name_CBW_woman_earlier} spend in the hospital?"

	label variable n_med_out_home_cbw "Where did \${N_name_CBW_woman_earlier} seek care?"
	note n_med_out_home_cbw: "Where did \${N_name_CBW_woman_earlier} seek care?"

	label variable n_med_out_oth_cbw "Other"
	note n_med_out_oth_cbw: "Other"

	label variable n_med_t_exp_cbw "In the last one month, what was the total expenditure \${N_name_CBW_woman_earlie"
	note n_med_t_exp_cbw: "In the last one month, what was the total expenditure \${N_name_CBW_woman_earlier} did on medical care?"

	label variable n_med_work_cbw "Did anyone in your household, including you, change their work/housework routing"
	note n_med_work_cbw: "Did anyone in your household, including you, change their work/housework routing to take care of \${N_name_CBW_woman_earlier} ?"
	label define n_med_work_cbw 1 "Yes" 0 "No" 999 "Don't know"
	label values n_med_work_cbw n_med_work_cbw

	label variable n_med_work_who_cbw "Who adjusted their schedule to take care of \${N_name_CBW_woman_earlier}?"
	note n_med_work_who_cbw: "Who adjusted their schedule to take care of \${N_name_CBW_woman_earlier}?"

	label variable n_med_days_caretaking_cbw "How many days have this person taken caretaking \${N_name_CBW_woman_earlier} (in"
	note n_med_days_caretaking_cbw: "How many days have this person taken caretaking \${N_name_CBW_woman_earlier} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"

	label variable n_translator "C29)Was a translator used in the survey?"
	note n_translator: "C29)Was a translator used in the survey?"
	label define n_translator 1 "Yes" 0 "No"
	label values n_translator n_translator

	label variable n_hh_prsnt "Was there any Household member (other than the \${N_name_CBW_woman_earlier}) pre"
	note n_hh_prsnt: "Was there any Household member (other than the \${N_name_CBW_woman_earlier}) present during the survey?"
	label define n_hh_prsnt 1 "Yes" 0 "No"
	label values n_hh_prsnt n_hh_prsnt






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-N_CBW_followup_corrections.csv
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
