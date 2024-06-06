* import_India_ILC_Endline_Census_Revisit-Household_available-comb_child_followup.do
*
* 	Imports and aggregates "Endline Census Re-visit-Household_available-comb_child_followup" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup.dta"
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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup_corrections.csv"
local note_fields1 ""
local text_fields1 "comb_child_ind comb_child_u5_name_label comb_main_caregiver_label comb_child_care_pres_oth comb_child_name comb_child_u5_caregiver_label comb_child_u5_relation_oth comb_anti_child_purpose"
local text_fields2 "comb_anti_child_purpose_oth comb_med_symp_u5 comb_med_symp_oth_u5 comb_med_where_u5 comb_med_where_oth_u5 comb_med_out_home_u5 comb_med_out_oth_u5 comb_prvdrs_exp_loop_u5_count comb_med_work_who_u5"
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


	label variable comb_child_caregiver_present "Is the caregiver/mother (\${comb_main_caregiver_label}) of \${comb_child_u5_name"
	note comb_child_caregiver_present: "Is the caregiver/mother (\${comb_main_caregiver_label}) of \${comb_child_u5_name_label} available ?"
	label define comb_child_caregiver_present 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable b" 5 "This is my 2rd re-visit (3rd visit): The revisit within two days is not possible" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (" 7 "U5 died or is no longer a member of the household" 8 "U5 child no longer falls in the criteria (less than 5 years)" -98 "Refused to answer" -77 "Other, please specify"
	label values comb_child_caregiver_present comb_child_caregiver_present

	label variable comb_child_care_pres_oth "B1.1) Please specify other"
	note comb_child_care_pres_oth: "B1.1) Please specify other"

	label variable comb_child_age_v "Did you verify \${comb_child_u5_name_label} age with adhaar card or any other of"
	note comb_child_age_v: "Did you verify \${comb_child_u5_name_label} age with adhaar card or any other official identity document ?"
	label define comb_child_age_v 1 "Yes" 0 "No"
	label values comb_child_age_v comb_child_age_v

	label variable comb_child_act_age "What is the actual age of \${comb_child_u5_name_label}?"
	note comb_child_act_age: "What is the actual age of \${comb_child_u5_name_label}?"

	label variable comb_child_caregiver_name "Who is the caregiver/mother of \${comb_child_u5_name_label}?"
	note comb_child_caregiver_name: "Who is the caregiver/mother of \${comb_child_u5_name_label}?"
	label define comb_child_caregiver_name 1 "\${R_Cen_fam_name1}" 2 "\${R_Cen_fam_name2}" 3 "\${R_Cen_fam_name3}" 4 "\${R_Cen_fam_name4}" 5 "\${R_Cen_fam_name5}" 6 "\${R_Cen_fam_name6}" 7 "\${R_Cen_fam_name7}" 8 "\${R_Cen_fam_name8}" 9 "\${R_Cen_fam_name9}" 10 "\${R_Cen_fam_name10}" 11 "\${R_Cen_fam_name11}" 12 "\${R_Cen_fam_name12}" 13 "\${R_Cen_fam_name13}" 14 "\${R_Cen_fam_name14}" 15 "\${R_Cen_fam_name15}" 16 "\${R_Cen_fam_name16}" 17 "\${R_Cen_fam_name17}" 18 "\${R_Cen_fam_name18}" 19 "\${R_Cen_fam_name19}" 20 "\${R_Cen_fam_name20}" 21 "\${comb_hhmember_name1}" 22 "\${comb_hhmember_name2}" 23 "\${comb_hhmember_name3}" 24 "\${comb_hhmember_name4}" 25 "\${comb_hhmember_name5}" 26 "\${comb_hhmember_name6}" 27 "\${comb_hhmember_name7}"
	label values comb_child_caregiver_name comb_child_caregiver_name

	label variable comb_child_residence "Is this \${comb_child_u5_name_label}'s usual residence?"
	note comb_child_residence: "Is this \${comb_child_u5_name_label}'s usual residence?"
	label define comb_child_residence 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_residence comb_child_residence

	label variable comb_child_name "If \${comb_child_u5_name_label} is a new baby, please write their actual name."
	note comb_child_name: "If \${comb_child_u5_name_label} is a new baby, please write their actual name."

	label variable comb_child_u5_relation "What is \${comb_child_u5_caregiver_label}'s relationship with \${comb_child_u5_n"
	note comb_child_u5_relation: "What is \${comb_child_u5_caregiver_label}'s relationship with \${comb_child_u5_name_label}?"
	label define comb_child_u5_relation 1 "Mother" 2 "Grandmother" 3 "Aunt" 4 "Uncle" 5 "Father" 6 "Grandfather" 7 "Sister" 8 "Brother" -77 "Other" 999 "Don’t know"
	label values comb_child_u5_relation comb_child_u5_relation

	label variable comb_child_u5_relation_oth "Other"
	note comb_child_u5_relation_oth: "Other"

	label variable comb_child_care_dia_day "Did \${comb_child_u5_caregiver_label} have diarrhea today or yesterday?"
	note comb_child_care_dia_day: "Did \${comb_child_u5_caregiver_label} have diarrhea today or yesterday?"
	label define comb_child_care_dia_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_care_dia_day comb_child_care_dia_day

	label variable comb_child_care_dia_wk "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 7 days?"
	note comb_child_care_dia_wk: "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 7 days?"
	label define comb_child_care_dia_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_care_dia_wk comb_child_care_dia_wk

	label variable comb_child_care_dia_2wk "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
	note comb_child_care_dia_2wk: "Did \${comb_child_u5_caregiver_label} have diarrhea in the past 2 weeks?"
	label define comb_child_care_dia_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_care_dia_2wk comb_child_care_dia_2wk

	label variable comb_child_age "What is \${comb_child_u5_name_label} age in years?"
	note comb_child_age: "What is \${comb_child_u5_name_label} age in years?"

	label variable comb_child_breastfeeding "Was OR Is \${comb_child_u5_name_label} (being) exclusively breastfed (not drinki"
	note comb_child_breastfeeding: "Was OR Is \${comb_child_u5_name_label} (being) exclusively breastfed (not drinking any water)?"
	label define comb_child_breastfeeding 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_breastfeeding comb_child_breastfeeding

	label variable comb_child_breastfed_num "A45.1) Up to which months was \${comb_child_u5_name_label} exclusively breastfed"
	note comb_child_breastfed_num: "A45.1) Up to which months was \${comb_child_u5_name_label} exclusively breastfed?"
	label define comb_child_breastfed_num 1 "Months" 2 "Days" 888 "Child is still being breastfed (mother's milk)" 999 "Don't know"
	label values comb_child_breastfed_num comb_child_breastfed_num

	label variable comb_child_breastfed_month "Please specify in months"
	note comb_child_breastfed_month: "Please specify in months"

	label variable comb_child_breastfed_days "Please specify in days"
	note comb_child_breastfed_days: "Please specify in days"

	label variable comb_child_vomit_day "A28) Did \${comb_child_u5_name_label} vomit today or yesterday?"
	note comb_child_vomit_day: "A28) Did \${comb_child_u5_name_label} vomit today or yesterday?"
	label define comb_child_vomit_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_vomit_day comb_child_vomit_day

	label variable comb_child_vomit_wk "A28.1) Did \${comb_child_u5_name_label} vomit in the last 7 days?"
	note comb_child_vomit_wk: "A28.1) Did \${comb_child_u5_name_label} vomit in the last 7 days?"
	label define comb_child_vomit_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_vomit_wk comb_child_vomit_wk

	label variable comb_child_vomit_2wk "A28.2) Did \${comb_child_u5_name_label} vomit in the past 2 weeks?"
	note comb_child_vomit_2wk: "A28.2) Did \${comb_child_u5_name_label} vomit in the past 2 weeks?"
	label define comb_child_vomit_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_vomit_2wk comb_child_vomit_2wk

	label variable comb_child_diarr_day "A29) Did \${comb_child_u5_name_label} have diarrhea today or yesterday?"
	note comb_child_diarr_day: "A29) Did \${comb_child_u5_name_label} have diarrhea today or yesterday?"
	label define comb_child_diarr_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_diarr_day comb_child_diarr_day

	label variable comb_child_diarr_wk "A29.1) Did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"
	note comb_child_diarr_wk: "A29.1) Did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"
	label define comb_child_diarr_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_diarr_wk comb_child_diarr_wk

	label variable comb_child_diarr_2wk "A29.2) Did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"
	note comb_child_diarr_2wk: "A29.2) Did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"
	label define comb_child_diarr_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_diarr_2wk comb_child_diarr_2wk

	label variable comb_child_diarr_wk_num "A30.1) How many days did \${comb_child_u5_name_label} have diarrhea in the past "
	note comb_child_diarr_wk_num: "A30.1) How many days did \${comb_child_u5_name_label} have diarrhea in the past 7 days?"

	label variable comb_child_diarr_2wk_num "A30.2) How many days did \${comb_child_u5_name_label} have diarrhea in the past "
	note comb_child_diarr_2wk_num: "A30.2) How many days did \${comb_child_u5_name_label} have diarrhea in the past 2 weeks?"

	label variable comb_child_diarr_freq "A30.3) What was the highest number of stools in a 24-hour period?"
	note comb_child_diarr_freq: "A30.3) What was the highest number of stools in a 24-hour period?"

	label variable comb_child_stool_24h "A31) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools with"
	note comb_child_stool_24h: "A31) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools within the last 24 hours?"
	label define comb_child_stool_24h 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_stool_24h comb_child_stool_24h

	label variable comb_child_stool_yest "A31.1) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools ye"
	note comb_child_stool_yest: "A31.1) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools yesterday?"
	label define comb_child_stool_yest 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_stool_yest comb_child_stool_yest

	label variable comb_child_stool_wk "A31.2) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in"
	note comb_child_stool_wk: "A31.2) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in a 24-hour period in the past 7 days?"
	label define comb_child_stool_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_stool_wk comb_child_stool_wk

	label variable comb_child_stool_2wk "A31.3) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in"
	note comb_child_stool_2wk: "A31.3) Did \${comb_child_u5_name_label} have 3 or more loose or watery stools in a 24 hour period in the past 2 weeks?"
	label define comb_child_stool_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_stool_2wk comb_child_stool_2wk

	label variable comb_child_blood_day "A32) Did \${comb_child_u5_name_label} have blood in the stool today or yesterday"
	note comb_child_blood_day: "A32) Did \${comb_child_u5_name_label} have blood in the stool today or yesterday?"
	label define comb_child_blood_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_blood_day comb_child_blood_day

	label variable comb_child_blood_wk "A32.1) Did \${comb_child_u5_name_label} have blood in the stool in the past 7 da"
	note comb_child_blood_wk: "A32.1) Did \${comb_child_u5_name_label} have blood in the stool in the past 7 days?"
	label define comb_child_blood_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_blood_wk comb_child_blood_wk

	label variable comb_child_blood_2wk "A32.2) Did \${comb_child_u5_name_label} have blood in the stool in the past 2 we"
	note comb_child_blood_2wk: "A32.2) Did \${comb_child_u5_name_label} have blood in the stool in the past 2 weeks?"
	label define comb_child_blood_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_blood_2wk comb_child_blood_2wk

	label variable comb_child_cuts_day "A27) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts today "
	note comb_child_cuts_day: "A27) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts today or yesterday?"
	label define comb_child_cuts_day 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_cuts_day comb_child_cuts_day

	label variable comb_child_cuts_wk "A27.1) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in t"
	note comb_child_cuts_wk: "A27.1) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in the last 7 days?"
	label define comb_child_cuts_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_cuts_wk comb_child_cuts_wk

	label variable comb_child_cuts_2wk "A27.2) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in t"
	note comb_child_cuts_2wk: "A27.2) Did \${comb_child_u5_name_label} have any bruising, scrapes, or cuts in the past 2 weeks?"
	label define comb_child_cuts_2wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_child_cuts_2wk comb_child_cuts_2wk

	label variable comb_anti_child_wk "In the last week, has \${comb_child_u5_name_label} taken antibiotics?"
	note comb_anti_child_wk: "In the last week, has \${comb_child_u5_name_label} taken antibiotics?"
	label define comb_anti_child_wk 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_anti_child_wk comb_anti_child_wk

	label variable comb_anti_child_days "In the last week, How many days ago did \${comb_child_u5_name_label} take antibi"
	note comb_anti_child_days: "In the last week, How many days ago did \${comb_child_u5_name_label} take antibiotics?"

	label variable comb_anti_child_last "How long ago did \${comb_child_u5_name_label} last take antibiotics?"
	note comb_anti_child_last: "How long ago did \${comb_child_u5_name_label} last take antibiotics?"
	label define comb_anti_child_last 1 "Months" 2 "Days" 3 "Not taken ever" 999 "Don't know"
	label values comb_anti_child_last comb_anti_child_last

	label variable comb_anti_child_last_months "Please specify in months"
	note comb_anti_child_last_months: "Please specify in months"

	label variable comb_anti_child_last_days "Please specify in days"
	note comb_anti_child_last_days: "Please specify in days"

	label variable comb_anti_child_purpose "For what purpose did \${comb_child_u5_name_label} take antibiotics?"
	note comb_anti_child_purpose: "For what purpose did \${comb_child_u5_name_label} take antibiotics?"

	label variable comb_anti_child_purpose_oth "Please specify others"
	note comb_anti_child_purpose_oth: "Please specify others"

	label variable comb_med_seek_care_u5 "In the past one month, did \${comb_child_u5_name_label} seek medical care?"
	note comb_med_seek_care_u5: "In the past one month, did \${comb_child_u5_name_label} seek medical care?"
	label define comb_med_seek_care_u5 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_med_seek_care_u5 comb_med_seek_care_u5

	label variable comb_med_diarrhea_u5 "Previously \${comb_child_u5_name_label} said that she has diarrhea, and if \${co"
	note comb_med_diarrhea_u5: "Previously \${comb_child_u5_name_label} said that she has diarrhea, and if \${comb_child_u5_name_label} did not mention that she took medical care for it. Please ask politely 'If \${comb_child_u5_name_label} had diarrhea in the last one month, then why she did not take medical care for it?'"
	label define comb_med_diarrhea_u5 1 "Treated at home" 2 "Didn’t get the time to visit the facility/provider" -98 "Refused to answer" -77 "Other, please specify"
	label values comb_med_diarrhea_u5 comb_med_diarrhea_u5

	label variable comb_med_visits_u5 "How many visits \${comb_child_u5_name_label} did in the last one month to seek m"
	note comb_med_visits_u5: "How many visits \${comb_child_u5_name_label} did in the last one month to seek medical care?"

	label variable comb_med_symp_u5 "What was the symptom, or what was the reason for medical care?"
	note comb_med_symp_u5: "What was the symptom, or what was the reason for medical care?"

	label variable comb_med_symp_oth_u5 "Other"
	note comb_med_symp_oth_u5: "Other"

	label variable comb_med_where_u5 "Where did \${comb_child_u5_name_label} seek care?"
	note comb_med_where_u5: "Where did \${comb_child_u5_name_label} seek care?"

	label variable comb_med_where_oth_u5 "Other"
	note comb_med_where_oth_u5: "Other"

	label variable comb_med_nights_u5 "How many nights did \${comb_child_u5_name_label} spend in the hospital?"
	note comb_med_nights_u5: "How many nights did \${comb_child_u5_name_label} spend in the hospital?"

	label variable comb_med_out_home_u5 "Where did \${comb_child_u5_name_label} seek care?"
	note comb_med_out_home_u5: "Where did \${comb_child_u5_name_label} seek care?"

	label variable comb_med_out_oth_u5 "Other"
	note comb_med_out_oth_u5: "Other"

	label variable comb_med_t_exp_u5 "In the last one month, what was the total expenditure \${comb_child_u5_name_labe"
	note comb_med_t_exp_u5: "In the last one month, what was the total expenditure \${comb_child_u5_name_label} did on medical care?"

	label variable comb_med_work_u5 "Did anyone in your household, including you, change their work/housework routing"
	note comb_med_work_u5: "Did anyone in your household, including you, change their work/housework routing to take care of \${comb_child_u5_name_label} ?"
	label define comb_med_work_u5 1 "Yes" 0 "No" 999 "Don't know"
	label values comb_med_work_u5 comb_med_work_u5

	label variable comb_med_work_who_u5 "Who adjusted their schedule to take care of \${comb_child_u5_name_label}?"
	note comb_med_work_who_u5: "Who adjusted their schedule to take care of \${comb_child_u5_name_label}?"

	label variable comb_med_days_caretaking_u5 "How many days have this person taken caretaking \${comb_child_u5_name_label} (in"
	note comb_med_days_caretaking_u5: "How many days have this person taken caretaking \${comb_child_u5_name_label} (including the time taken to visit/stay at a hospital clinic/including the time taken to visit a hospital clinic)?"

	label variable comb_translator_u5 "C29)Was a translator used in the survey?"
	note comb_translator_u5: "C29)Was a translator used in the survey?"
	label define comb_translator_u5 1 "Yes" 0 "No"
	label values comb_translator_u5 comb_translator_u5

	label variable comb_hh_prsnt_u5 "Was there any Household member (other than the \${comb_child_u5_name_label}) pre"
	note comb_hh_prsnt_u5: "Was there any Household member (other than the \${comb_child_u5_name_label}) present during the survey?"
	label define comb_hh_prsnt_u5 1 "Yes" 0 "No"
	label values comb_hh_prsnt_u5 comb_hh_prsnt_u5






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-comb_child_followup_corrections.csv
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
