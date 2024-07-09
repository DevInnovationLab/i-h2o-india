* import_india_ilc_pump_operator_survey.do
*
* 	Imports and aggregates "pump_operator_survey" (ID: india_ilc_pump_operator_survey) data.
*
*	Inputs:  "pump_operator_survey_WIDE.csv"
*	Outputs: "pump_operator_survey.dta"
*
*	Output by SurveyCTO July 8, 2024 11:38 AM.

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
local csvfile "${DataRaw}1_10_Pump_Operator_Survey/pump_operator_survey_WIDE.csv"
local dtafile "${DataRaw}1_10_Pump_Operator_Survey/1_10_Pump_Operator_Survey.dta"
local corrfile "pump_operator_survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum username caseid district_id district_name block_id block_name gp_id gp_name village_id village_name info_update enum_name_label unique_id unique_id_label"
local text_fields2 "noconsent_reason_oth consent_duration resp_name phone_num phone_num_re job_duration_units_label job_duration_oth appoint_salary_addtlduties duties_po duties_po_oth appointment_po_person_oth"
local text_fields3 "training_po upcoming_training_n_oth tenure_duration_unit_label tenure_duration_oth next_po_appoint_oth other_work_type other_work_oth time_spent_oth salary salary_freq_oth reason_irregular_salary"
local text_fields4 "salary_payer_oth salary_source no_salary_reason addtl_duties addtl_duties_no addtl_duties_no_oth interaction_freq_oth interaction_issues interaction_issues_oth comments_background background_duration"
local text_fields5 "water_supply_reason water_supply_reason_oth notsolve_oth cleaning_tank_freq_oth bleaching_powder_freq_oth other_treatment_method operation_valves_who_oth operation_valves_who_label operation_ilc_other"
local text_fields6 "comments_water_infra water_infra_duration ilc_install_support ilc_install_support_oth ilc_install_challenge ilc_install_challenge_oth ilc_monitor_type ilc_monitor_label num_ilc_monitor"
local text_fields7 "ilc_monitor_list_count ilc_monitor_index_* ilc_monitor_value_* ilc_monitor_label_2_* ilc_monitor_labels ilc_monitor1 ilc_monitor2 ilc_monitor3 ilc_monitor4 ilc_monitor5 ilc_monitor6 ilc_monitor7"
local text_fields8 "ilc_monitor8 ilc_monitor9 select_ilc_monitor_type ilc_monitor_type_oth ilc_monitor_freq_daily select_ilc_monitor_freq_daily ilc_refill_unit_label reason_chlorination reason_chlorination_other"
local text_fields9 "comments_ilc_install_maintain ilc_install_maintain_duration ilc_satisfied_po ilc_satisfied_po_oth ilc_unsatisfied_po ilc_unsatisfied_po_oth ilc_satisfied_village ilc_satisfied_village_oth"
local text_fields10 "ilc_unsatisfied_village ilc_unsatisfied_village_oth hh_issues_audio hh_issues_type hh_issues_type_other hh_issues_detail hh_issues_response hh_issues_response_oth hh_issues_response_detail"
local text_fields11 "hh_issues_training turnoff_duration_unit_label turnoff_report turnoff_report_oth oth_turnoff_report oth_turnoff_report_oth contacted_issues_type maint_issues maint_issues_oth maint_improvements"
local text_fields12 "maint_notes comments_ilc_perceptions ilc_perceptions_duration comment instanceid instancename"
local date_fields1 "date_bleaching_powder_tank_23"
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


	label variable note_conf "note_conf Please confirm that the following information is correct: District Nam"
	note note_conf: "note_conf Please confirm that the following information is correct: District Name: \${district_name} Block Name: \${block_name} Gram Panchayat Name: \${gp_name} Village Name: \${village_name}"
	label define note_conf 1 "Yes" 0 "No"
	label values note_conf note_conf

	label variable info_update "info_update Please enter the information that is not correct and needs to be upd"
	note info_update: "info_update Please enter the information that is not correct and needs to be updated."

	label variable enum_name "enum_name Enumerator to fill up: Enumerator Name"
	note enum_name: "enum_name Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Sanjay Naik" 103 "Rajib Panda"
	label values enum_name enum_name

	label variable enum_code "enum_code Enumerator to fill up: Enumerator Code"
	note enum_code: "enum_code Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 103 "103"
	label values enum_code enum_code

	label variable pop_availability "pop_availability Did you find a pump operator to interview? Note: It is importan"
	note pop_availability: "pop_availability Did you find a pump operator to interview? Note: It is important to conduct all interviews. If you are unable to locate a respondent, please inform Prasanta"
	label define pop_availability 1 "Pump operator available for an interview" 2 "Pump operator has left the village permanently [This would end the survey]" 3 "This is my first visit: The pump operator is temporarily unavailable but will re" 4 "This is my 1st re-visit: The pump operator is temporarily unavailable but might " 5 "This is my 2nd re-visit: The pump operator is temporarily unavailable (Please le"
	label values pop_availability pop_availability

	label variable visit "visit Which visit is this?"
	note visit: "visit Which visit is this?"
	label define visit 1 "1st Visit" 2 "2nd Visit [1st Revisit]" 3 "3rd Visit [2nd Revisit]"
	label values visit visit

	label variable consent "consent Do I have your permission to proceed with the interview?"
	note consent: "consent Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable audio_consent "audio_consent Do I have your permission to record a few parts of the interview?"
	note audio_consent: "audio_consent Do I have your permission to record a few parts of the interview?"
	label define audio_consent 1 "Yes" 0 "No"
	label values audio_consent audio_consent

	label variable noconsent_reason "noconsent_reason Can you tell me why you don’t want to participate in the survey"
	note noconsent_reason: "noconsent_reason Can you tell me why you don’t want to participate in the survey?"
	label define noconsent_reason 1 "Lack of time" 2 "Topic is not interesting to me" 3 "I don’t control the operation of the pump and/or don’t make decisions regarding " -77 "Others"
	label values noconsent_reason noconsent_reason

	label variable noconsent_reason_oth "noconsent_reason_oth Please specify other. Thank you for your time."
	note noconsent_reason_oth: "noconsent_reason_oth Please specify other. Thank you for your time."

	label variable resp_name "resp_name Background 1.1 What is your name?"
	note resp_name: "resp_name Background 1.1 What is your name?"

	label variable phone_num "phone_num 1.2 What is your phone number?"
	note phone_num: "phone_num 1.2 What is your phone number?"

	label variable phone_num_re "phone_num_re 1.3 Please enter the phone number again."
	note phone_num_re: "phone_num_re 1.3 Please enter the phone number again."

	label variable gender "gender 1.4 What is your gender?"
	note gender: "gender 1.4 What is your gender?"
	label define gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values gender gender

	label variable resp_age "resp_age 1.5 How old are you?"
	note resp_age: "resp_age 1.5 How old are you?"

	label variable school_level "school_level 1.6 What is the highest level of schooling that you have completed?"
	note school_level: "school_level 1.6 What is the highest level of schooling that you have completed?"
	label define school_level 1 "Incomplete primary (8th grade not completed)" 2 "Complete primary (8th grade completed)" 3 "Incomplete secondary (12th grade not completed)" 4 "Complete secondary (12th grade completed)" 5 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" 999 "Don’t know" -98 "Refused to answer"
	label values school_level school_level

	label variable job_duration "job_duration 1.7 How long have you been the pump operator for this village?"
	note job_duration: "job_duration 1.7 How long have you been the pump operator for this village?"

	label variable job_duration_units "job_duration_units 1.8 Enumerator to select the duration unit"
	note job_duration_units: "job_duration_units 1.8 Enumerator to select the duration unit"
	label define job_duration_units 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" -77 "Other" 999 "Don’t know"
	label values job_duration_units job_duration_units

	label variable job_duration_oth "job_duration_oth 1.9 Please specify other"
	note job_duration_oth: "job_duration_oth 1.9 Please specify other"

	label variable duties_po "duties_po 1.10 What are your current duties as the pump operator?"
	note duties_po: "duties_po 1.10 What are your current duties as the pump operator?"

	label variable duties_po_oth "duties_po_oth 1.11 Please specify other"
	note duties_po_oth: "duties_po_oth 1.11 Please specify other"

	label variable appointment_po_person "appointment_po_person 1.12 Who appointed you as the pump operator?"
	note appointment_po_person: "appointment_po_person 1.12 Who appointed you as the pump operator?"
	label define appointment_po_person 1 "Appointed by Gram Panchayat leadership" 2 "Appointed by RWSS" 3 "Appointed by village leadership" -77 "Other"
	label values appointment_po_person appointment_po_person

	label variable appointment_po_person_oth "appointment_po_person_oth 1.13 Please specify other"
	note appointment_po_person_oth: "appointment_po_person_oth 1.13 Please specify other"

	label variable training_po "training_po 1.14 How were you trained in the duties of the pump operator?"
	note training_po: "training_po 1.14 How were you trained in the duties of the pump operator?"

	label variable upcoming_training "upcoming_training 1.15 Would you be willing to attend any training conducted by "
	note upcoming_training: "upcoming_training 1.15 Would you be willing to attend any training conducted by RWSS on managing water supply for the village?"
	label define upcoming_training 1 "Yes" 0 "No"
	label values upcoming_training upcoming_training

	label variable upcoming_training_n "upcoming_training_N 1.16 Why would you not be willing to attend such training?"
	note upcoming_training_n: "upcoming_training_N 1.16 Why would you not be willing to attend such training?"
	label define upcoming_training_n 1 "I don’t need any additional training" 2 "Don’t have time - Training would interfere with my other work" 3 "I am not interested in this work" 4 "No compensation for extra training" -77 "Other"
	label values upcoming_training_n upcoming_training_n

	label variable upcoming_training_n_oth "upcoming_training_N_oth 1.17 Please specify other"
	note upcoming_training_n_oth: "upcoming_training_N_oth 1.17 Please specify other"

	label variable tenure "tenure 1.18 Is there a fixed tenure for your position as the pump operator?"
	note tenure: "tenure 1.18 Is there a fixed tenure for your position as the pump operator?"
	label define tenure 1 "Yes" 0 "No" 999 "Don't know"
	label values tenure tenure

	label variable tenure_duration "tenure_duration 1.19 What is the total duration for which you will be the pump o"
	note tenure_duration: "tenure_duration 1.19 What is the total duration for which you will be the pump operator?"

	label variable tenure_duration_unit "tenure_duration_unit 1.20 Enumerator to select the duration unit"
	note tenure_duration_unit: "tenure_duration_unit 1.20 Enumerator to select the duration unit"
	label define tenure_duration_unit 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" -77 "Other" 999 "Don’t know"
	label values tenure_duration_unit tenure_duration_unit

	label variable tenure_duration_oth "tenure_duration_oth 1.21 Please specify other"
	note tenure_duration_oth: "tenure_duration_oth 1.21 Please specify other"

	label variable next_po_appointment "next_po_appointment 1.22 Do you know how the next pump operator will be appointe"
	note next_po_appointment: "next_po_appointment 1.22 Do you know how the next pump operator will be appointed?"
	label define next_po_appointment 1 "Appointed by the Gram Panchayat after elections" 2 "Appointed by RWSS after election" 3 "Appointed on a fixed schedule" 4 "Appointed indefinitely or no fixed schedule" 5 "When volunteers change" 999 "Don’t know" -77 "Other"
	label values next_po_appointment next_po_appointment

	label variable next_po_appoint_oth "next_po_appoint_oth 1.23 Please specify other"
	note next_po_appoint_oth: "next_po_appoint_oth 1.23 Please specify other"

	label variable other_work "other_work 1.24 Do you do any work other than your work as the pump operator?"
	note other_work: "other_work 1.24 Do you do any work other than your work as the pump operator?"
	label define other_work 1 "Yes" 0 "No"
	label values other_work other_work

	label variable other_work_type "other_work_type 1.25 What other work do you do?"
	note other_work_type: "other_work_type 1.25 What other work do you do?"

	label variable other_work_oth "other_work_oth 1.26 Please specify other"
	note other_work_oth: "other_work_oth 1.26 Please specify other"

	label variable time_spent "time_spent 1.27 How much time do you spend in a day on your duties as the pump o"
	note time_spent: "time_spent 1.27 How much time do you spend in a day on your duties as the pump operator?"
	label define time_spent 1 "Less than 15 minutes" 2 "Between 15 minutes and 30 minutes" 3 "Between 30 minutes and 1 hour" 4 "Between 1 hour and 2 hours" 5 "More than 2 hours" -77 "Other"
	label values time_spent time_spent

	label variable time_spent_oth "time_spent_oth 1.28 Please specify other"
	note time_spent_oth: "time_spent_oth 1.28 Please specify other"

	label variable receive_salary "receive_salary 1.29 Are you supposed to receive any compensation for being the p"
	note receive_salary: "receive_salary 1.29 Are you supposed to receive any compensation for being the pump operator?"
	label define receive_salary 1 "Yes" 0 "No"
	label values receive_salary receive_salary

	label variable salary "salary 1.30 What is the monthly compensation for being the pump operator?"
	note salary: "salary 1.30 What is the monthly compensation for being the pump operator?"

	label variable salary_issue "salary_issue 1.31 Have you ever not received your compensation on time or at all"
	note salary_issue: "salary_issue 1.31 Have you ever not received your compensation on time or at all?"
	label define salary_issue 1 "Yes" 0 "No" 999 "Don't know"
	label values salary_issue salary_issue

	label variable salary_freq "salary_freq 1.32 In the last six months, how often did you receive your compensa"
	note salary_freq: "salary_freq 1.32 In the last six months, how often did you receive your compensation?"
	label define salary_freq 1 "4-5 months" 2 "Half the time (3 months)" 3 "1 or 2 months" 4 "Did not receieve at all" -77 "Other"
	label values salary_freq salary_freq

	label variable salary_freq_oth "salary_freq_oth 1.321 Please specify other."
	note salary_freq_oth: "salary_freq_oth 1.321 Please specify other."

	label variable reason_irregular_salary "reason_irregular_salary 1.33 What is the reason for these irregular salary payme"
	note reason_irregular_salary: "reason_irregular_salary 1.33 What is the reason for these irregular salary payments?"

	label variable salary_payer "salary_payer 1.34 Who pays your salary?"
	note salary_payer: "salary_payer 1.34 Who pays your salary?"
	label define salary_payer 1 "Gram Panchayat" 2 "RWSS or other government office" 3 "Village" -77 "Other" 999 "Don't know"
	label values salary_payer salary_payer

	label variable salary_payer_oth "salary_payer_oth 1.35 Please specify other"
	note salary_payer_oth: "salary_payer_oth 1.35 Please specify other"

	label variable salary_source "salary_source 1.36 How is your salary collected and paid to you?"
	note salary_source: "salary_source 1.36 How is your salary collected and paid to you?"

	label variable no_salary_expec "no_salary_expec 1.37 When you started working as the pump operator, were you inf"
	note no_salary_expec: "no_salary_expec 1.37 When you started working as the pump operator, were you informed of any payment for this role?"
	label define no_salary_expec 1 "Yes" 2 "No, but I expected some pay" 3 "No, I wasn't expecting any pay"
	label values no_salary_expec no_salary_expec

	label variable no_salary_reason "no_salary_reason 1.38 What is the reason that you are not receiving any compensa"
	note no_salary_reason: "no_salary_reason 1.38 What is the reason that you are not receiving any compensation even though you were informed about it?"

	label variable addtl_duties "addtl_duties 1.39 Which of the following additional responsibilities would you b"
	note addtl_duties: "addtl_duties 1.39 Which of the following additional responsibilities would you be willing to take up as pump operator to improve the quality of water in your village?"

	label variable addtl_duties_comp "addtl_duties_comp 1.40 Would you be willing to take up these additional responsi"
	note addtl_duties_comp: "addtl_duties_comp 1.40 Would you be willing to take up these additional responsibilities given your current compensation?"
	label define addtl_duties_comp 1 "Yes" 0 "No" 999 "Don't know"
	label values addtl_duties_comp addtl_duties_comp

	label variable addtl_duties_no "addtl_duties_no 1.41 Why do you not want to take up additional responsibilities?"
	note addtl_duties_no: "addtl_duties_no 1.41 Why do you not want to take up additional responsibilities?"

	label variable addtl_duties_no_oth "addtl_duties_no_oth 1.42 Please specify other"
	note addtl_duties_no_oth: "addtl_duties_no_oth 1.42 Please specify other"

	label variable interaction_gp "interaction_gp 1.43 Do you interact with the Gram Panchayat members, RWSS, or ot"
	note interaction_gp: "interaction_gp 1.43 Do you interact with the Gram Panchayat members, RWSS, or other government officials for issues related to your duties as pump operator?"
	label define interaction_gp 0 "No" 1 "Yes, only with Gram Panchayat members" 2 "Yes, only with RWSS members or other government officials" 3 "Yes, with both Gram Panchayat members and RWSS members"
	label values interaction_gp interaction_gp

	label variable interaction_freq "interaction_freq 1.44 How frequently do you interact with them?"
	note interaction_freq: "interaction_freq 1.44 How frequently do you interact with them?"
	label define interaction_freq 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Every 6 months" 5 "Annually" 6 "No fixed schedule" -77 "Other"
	label values interaction_freq interaction_freq

	label variable interaction_freq_oth "interaction_freq_oth 1.45 Please specify other"
	note interaction_freq_oth: "interaction_freq_oth 1.45 Please specify other"

	label variable interaction_issues "interaction_issues 1.46 What do you discuss with them during these interactions?"
	note interaction_issues: "interaction_issues 1.46 What do you discuss with them during these interactions?"

	label variable interaction_issues_oth "interaction_issues_oth 1.47 Please specify other"
	note interaction_issues_oth: "interaction_issues_oth 1.47 Please specify other"

	label variable comments_background "comments_background 1.48 Enumerator to fill: Do you have any additional comments"
	note comments_background: "comments_background 1.48 Enumerator to fill: Do you have any additional comments to mention? Note: Leave this empty in case of no additional comments"

	label variable tap_connection_nmbr "tap_connection_nmbr Drinking Water Infrastructure 2.1 How many households in thi"
	note tap_connection_nmbr: "tap_connection_nmbr Drinking Water Infrastructure 2.1 How many households in this village have tap connections?"

	label variable tap_connection_hamlet "tap_connection_hamlet 2.2 Do all the hamlets in this village have a tap connecti"
	note tap_connection_hamlet: "tap_connection_hamlet 2.2 Do all the hamlets in this village have a tap connection?"
	label define tap_connection_hamlet 1 "All hamlets" 2 "Most hamlets" 3 "Some hamlets" 999 "Don't know"
	label values tap_connection_hamlet tap_connection_hamlet

	label variable no_tap_connection_hamlet "no_tap_connection_hamlet 2.3 How many hamlets in this village do not have a tap "
	note no_tap_connection_hamlet: "no_tap_connection_hamlet 2.3 How many hamlets in this village do not have a tap connection?"

	label variable tap_connection_hhs "tap_connection_hhs 2.4 Do all the households in this village have a tap connecti"
	note tap_connection_hhs: "tap_connection_hhs 2.4 Do all the households in this village have a tap connection?"
	label define tap_connection_hhs 1 "All households" 2 "Most households" 3 "Some households" 999 "Don't know"
	label values tap_connection_hhs tap_connection_hhs

	label variable no_tap_connection_hhs "no_tap_connection_hhs 2.5 How many households in this village do not have a tap "
	note no_tap_connection_hhs: "no_tap_connection_hhs 2.5 How many households in this village do not have a tap connection?"

	label variable no_schools "no_schools 2.6 Number of schools"
	note no_schools: "no_schools 2.6 Number of schools"

	label variable no_anganwadis "no_anganwadis 2.7 Number of anganwadis"
	note no_anganwadis: "no_anganwadis 2.7 Number of anganwadis"

	label variable no_schools_tap "no_schools_tap 2.8 Number of schools with tap connection"
	note no_schools_tap: "no_schools_tap 2.8 Number of schools with tap connection"

	label variable no_anganwadis_tap "no_anganwadis_tap 2.9 Number of anganwadis with tap connection"
	note no_anganwadis_tap: "no_anganwadis_tap 2.9 Number of anganwadis with tap connection"

	label variable water_supply_freq "water_supply_freq 2.10 How many times do you supply water to the village each da"
	note water_supply_freq: "water_supply_freq 2.10 How many times do you supply water to the village each day?"

	label variable water_supply_hrs "water_supply_hrs 2.11 How many hours is water supplied each day?"
	note water_supply_hrs: "water_supply_hrs 2.11 How many hours is water supplied each day?"

	label variable water_supply_not_received "water_supply_not_received 2.12 In the last one month, have there been any days w"
	note water_supply_not_received: "water_supply_not_received 2.12 In the last one month, have there been any days where people have not received tap water at all?"
	label define water_supply_not_received 1 "Yes" 0 "No" 999 "Don't know"
	label values water_supply_not_received water_supply_not_received

	label variable water_supply_less "water_supply_less 2.13 In the last one month, have there been new problems where"
	note water_supply_less: "water_supply_less 2.13 In the last one month, have there been new problems where the quantity of water supplied was less than usual?"
	label define water_supply_less 1 "Yes" 0 "No" 999 "Don't know"
	label values water_supply_less water_supply_less

	label variable water_supply_reason "water_supply_reason 2.14 In the last one month, what was the reason for water no"
	note water_supply_reason: "water_supply_reason 2.14 In the last one month, what was the reason for water not being supplied or being supplied in less quantity?"

	label variable water_supply_reason_oth "water_supply_reason_oth 2.15 Please specify other"
	note water_supply_reason_oth: "water_supply_reason_oth 2.15 Please specify other"

	label variable no_of_hours "no_of_hours 2.16 How many hours was the electricity not working?"
	note no_of_hours: "no_of_hours 2.16 How many hours was the electricity not working?"

	label variable water_supply_spread "water_supply_spread 2.17 How spread out this water supply issue was?"
	note water_supply_spread: "water_supply_spread 2.17 How spread out this water supply issue was?"
	label define water_supply_spread 1 "All hamlets" 2 "Most hamlets" 3 "Some hamlets" 999 "Don't know"
	label values water_supply_spread water_supply_spread

	label variable water_supply_spread_ham "water_supply_spread_ham 2.18 Please select how spread out the issue was in the h"
	note water_supply_spread_ham: "water_supply_spread_ham 2.18 Please select how spread out the issue was in the hamlets?"
	label define water_supply_spread_ham 1 "All households in the hamlet" 2 "Most households in the hamlet" 3 "Some households in the hamlet" 999 "Don't know"
	label values water_supply_spread_ham water_supply_spread_ham

	label variable water_supply_issue "water_supply_issue 2.19 Did you or anyone else report the issue to the local Pan"
	note water_supply_issue: "water_supply_issue 2.19 Did you or anyone else report the issue to the local Panchayati Raj and Drinking Water/RWSS office?"
	label define water_supply_issue 1 "Yes" 0 "No" 999 "Don't know"
	label values water_supply_issue water_supply_issue

	label variable water_supply_issue_solve "water_supply_issue_solve 2.20 Is the issue resolved now?"
	note water_supply_issue_solve: "water_supply_issue_solve 2.20 Is the issue resolved now?"
	label define water_supply_issue_solve 1 "Yes" 0 "No" 999 "Don't know"
	label values water_supply_issue_solve water_supply_issue_solve

	label variable notsolve "notsolve 2.21 Why has the problem not been solved yet?"
	note notsolve: "notsolve 2.21 Why has the problem not been solved yet?"
	label define notsolve 1 "Nobody took the initiative to inform the Government (RWSS)" 2 "Unable to reach the Government office (RWSS)" 3 "Problem not significant enough to be escalated" 4 "No help from the government office (RWSS) even after informing" -77 "Other"
	label values notsolve notsolve

	label variable notsolve_oth "notsolve_oth 2.22 Please specify other"
	note notsolve_oth: "notsolve_oth 2.22 Please specify other"

	label variable tap_satisfaction "tap_satisfaction 2.23 How satisfied are the people in the village with their tap"
	note tap_satisfaction: "tap_satisfaction 2.23 How satisfied are the people in the village with their tap connections?"
	label define tap_satisfaction 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Neither satisfied nor unsatisfied" 4 "Somewhat unsatisfied" 5 "Very unsatisfied"
	label values tap_satisfaction tap_satisfaction

	label variable cleaning_tank_freq "cleaning_tank_freq 2.24 How often do you or anyone else clean the inside of the "
	note cleaning_tank_freq: "cleaning_tank_freq 2.24 How often do you or anyone else clean the inside of the tank?"
	label define cleaning_tank_freq 0 "Never clean the tank" 1 "Atleast once in a week" 2 "Few times a month" 3 "Once a month" 4 "Every 2-6 months" 5 "Every 6-12 months" 6 "Only during the monsoon" 7 "No fixed schedule" -77 "Other"
	label values cleaning_tank_freq cleaning_tank_freq

	label variable cleaning_tank_freq_oth "cleaning_tank_freq_oth 2.25 Please specify other"
	note cleaning_tank_freq_oth: "cleaning_tank_freq_oth 2.25 Please specify other"

	label variable bleaching_powder_added "bleaching_powder_added 2.26 Is bleaching powder ever added to the tank to clean "
	note bleaching_powder_added: "bleaching_powder_added 2.26 Is bleaching powder ever added to the tank to clean it?"
	label define bleaching_powder_added 1 "Yes" 0 "No" 999 "Don't know"
	label values bleaching_powder_added bleaching_powder_added

	label variable bleaching_powder_freq "bleaching_powder_freq 2.27 How often do you or anyone else add bleaching powder "
	note bleaching_powder_freq: "bleaching_powder_freq 2.27 How often do you or anyone else add bleaching powder to the tank?"
	label define bleaching_powder_freq 1 "Atleast once a week" 2 "Few times a month" 3 "Once a month" 4 "Every 2-6 months" 5 "Every 6-12 months" 6 "Only during the monsoon" 7 "No fixed schedule" -77 "Other"
	label values bleaching_powder_freq bleaching_powder_freq

	label variable bleaching_powder_freq_oth "bleaching_powder_freq_oth 2.28 Please specify other"
	note bleaching_powder_freq_oth: "bleaching_powder_freq_oth 2.28 Please specify other"

	label variable other_treatment "other_treatment 2.29 Do you or anyone else ever do anything else to clean the ta"
	note other_treatment: "other_treatment 2.29 Do you or anyone else ever do anything else to clean the tank or treat the drinking water?"
	label define other_treatment 1 "Yes" 0 "No" 999 "Don't know"
	label values other_treatment other_treatment

	label variable other_treatment_method "other_treatment_method 2.30 What do you do to clean the tank or treat drinking w"
	note other_treatment_method: "other_treatment_method 2.30 What do you do to clean the tank or treat drinking water?"

	label variable bleaching_powder_tank_23 "bleaching_powder_tank_23 2.31 Did you clean the tank or add bleaching powder to "
	note bleaching_powder_tank_23: "bleaching_powder_tank_23 2.31 Did you clean the tank or add bleaching powder to the tank when JPAL began working in your village?"
	label define bleaching_powder_tank_23 1 "Yes" 0 "No" 999 "Don't know"
	label values bleaching_powder_tank_23 bleaching_powder_tank_23

	label variable date_bleaching_powder_tank_23 "date_bleaching_powder_tank_23 2.32 Approximately what date did you clean the tan"
	note date_bleaching_powder_tank_23: "date_bleaching_powder_tank_23 2.32 Approximately what date did you clean the tank or add bleaching powder to it?"

	label variable operation_valves "operation_valves 2.33 Does anyone else in your family or the village know how to"
	note operation_valves: "operation_valves 2.33 Does anyone else in your family or the village know how to operate the pump or valves for water supply?"
	label define operation_valves 1 "Yes" 0 "No" 999 "Don't know"
	label values operation_valves operation_valves

	label variable operation_valves_who "operation_valves_who 2.34 Who else knows how to operate the pump or valves for w"
	note operation_valves_who: "operation_valves_who 2.34 Who else knows how to operate the pump or valves for water supply?"
	label define operation_valves_who 1 "Additional Pump operator" 2 "Someone in the family" 3 "Someone outside the family" -77 "Other"
	label values operation_valves_who operation_valves_who

	label variable operation_valves_who_oth "operation_valves_who_oth 2.341 Please specify other"
	note operation_valves_who_oth: "operation_valves_who_oth 2.341 Please specify other"

	label variable operation_ilc "operation_ilc 2.35 Does \${operation_valves_who_label} also know how to operate "
	note operation_ilc: "operation_ilc 2.35 Does \${operation_valves_who_label} also know how to operate the ILC device?"
	label define operation_ilc 1 "Yes" 0 "No" -77 "Other" 999 "Don't know"
	label values operation_ilc operation_ilc

	label variable operation_ilc_other "operation_ilc_other 2.36 Please specify other"
	note operation_ilc_other: "operation_ilc_other 2.36 Please specify other"

	label variable operation_valves_nmbr "operation_valves_nmbr 2.37 How many times in the past one month has someone else"
	note operation_valves_nmbr: "operation_valves_nmbr 2.37 How many times in the past one month has someone else turned on the water supply for the village?"

	label variable operation_ilc_lastmonth "operation_ilc_lastmonth 2.38 Has this person also turned on the ILC device durin"
	note operation_ilc_lastmonth: "operation_ilc_lastmonth 2.38 Has this person also turned on the ILC device during these instances?"
	label define operation_ilc_lastmonth 1 "Yes" 0 "No" 999 "Don't know"
	label values operation_ilc_lastmonth operation_ilc_lastmonth

	label variable comments_water_infra "comments_water_infra 2.39 Enumerator to fill: Do you have any additional comment"
	note comments_water_infra: "comments_water_infra 2.39 Enumerator to fill: Do you have any additional comments to mention?"

	label variable ilc_install "ilc_install ILC Device: Installation and Maintenance 3.1 Were you involved durin"
	note ilc_install: "ilc_install ILC Device: Installation and Maintenance 3.1 Were you involved during the installation of the device?"
	label define ilc_install 1 "Yes" 0 "No"
	label values ilc_install ilc_install

	label variable ilc_install_support "ilc_install_support 3.2 In what ways were you involved in the installation of th"
	note ilc_install_support: "ilc_install_support 3.2 In what ways were you involved in the installation of the device?"

	label variable ilc_install_support_oth "ilc_install_support_oth 3.3 Please specify other"
	note ilc_install_support_oth: "ilc_install_support_oth 3.3 Please specify other"

	label variable ilc_install_challenge "ilc_install_challenge 3.4 What do you think were some of the challenges associat"
	note ilc_install_challenge: "ilc_install_challenge 3.4 What do you think were some of the challenges associated with installing this device?"

	label variable ilc_install_challenge_oth "ilc_install_challenge_oth 3.5 Please specify other"
	note ilc_install_challenge_oth: "ilc_install_challenge_oth 3.5 Please specify other"

	label variable ilc_monitor "ilc_monitor 3.6 Do you operate or maintain the device?"
	note ilc_monitor: "ilc_monitor 3.6 Do you operate or maintain the device?"
	label define ilc_monitor 1 "Yes" 0 "No"
	label values ilc_monitor ilc_monitor

	label variable ilc_monitor_type "ilc_monitor_type 3.7 What do you need to do when operating or maintaining the de"
	note ilc_monitor_type: "ilc_monitor_type 3.7 What do you need to do when operating or maintaining the device?"

	label variable ilc_monitor_type_oth "ilc_monitor_type_oth 3.8 Please specify other"
	note ilc_monitor_type_oth: "ilc_monitor_type_oth 3.8 Please specify other"

	label variable ilc_monitor_freq_daily "ilc_monitor_freq_daily 3.9 Which of these tasks do you perform daily?"
	note ilc_monitor_freq_daily: "ilc_monitor_freq_daily 3.9 Which of these tasks do you perform daily?"

	label variable ilc_monitor_duration "ilc_monitor_duration 3.10 How much time does it take you to perform these tasks "
	note ilc_monitor_duration: "ilc_monitor_duration 3.10 How much time does it take you to perform these tasks daily?"

	label variable ilc_monitor_freq "ilc_monitor_freq 3.11 How often did you handle the other tasks for the device? ("
	note ilc_monitor_freq: "ilc_monitor_freq 3.11 How often did you handle the other tasks for the device? (tasks that you do not perform daily)"
	label define ilc_monitor_freq 1 "Few times a week" 2 "Once a week" 3 "Once every two weeks" 4 "Once a month" 5 "No fixed schedule" -77 "Other"
	label values ilc_monitor_freq ilc_monitor_freq

	label variable ilc_refill "ilc_refill 3.12 Do you provide refills to the chlorination device?"
	note ilc_refill: "ilc_refill 3.12 Do you provide refills to the chlorination device?"
	label define ilc_refill 1 "Yes" 0 "No"
	label values ilc_refill ilc_refill

	label variable ilc_refill_freq "ilc_refill_freq ILC Refill Frequency 3.13 How often did you need to provide a re"
	note ilc_refill_freq: "ilc_refill_freq ILC Refill Frequency 3.13 How often did you need to provide a refill to the chlorination device?"

	label variable ilc_refill_unit "ilc_refill_unit 3.14 Enumerator to select the duration unit"
	note ilc_refill_unit: "ilc_refill_unit 3.14 Enumerator to select the duration unit"
	label define ilc_refill_unit 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" -77 "Other" 999 "Don’t know"
	label values ilc_refill_unit ilc_refill_unit

	label variable reason_chlorination "reason_chlorination 3.15 Why is chlorine being added to the drinking water?"
	note reason_chlorination: "reason_chlorination 3.15 Why is chlorine being added to the drinking water?"

	label variable reason_chlorination_other "reason_chlorination_other 3.16 Please specify other"
	note reason_chlorination_other: "reason_chlorination_other 3.16 Please specify other"

	label variable comments_ilc_install_maintain "comments_ilc_install_maintain 3.17 Enumerator to fill: Do you have any additiona"
	note comments_ilc_install_maintain: "comments_ilc_install_maintain 3.17 Enumerator to fill: Do you have any additional comments to mention?"

	label variable ilc_satisfaction_po "ilc_satisfaction_po ILC Perceptions and Village Level Issues 4.1 How satisfied a"
	note ilc_satisfaction_po: "ilc_satisfaction_po ILC Perceptions and Village Level Issues 4.1 How satisfied are you with the chlorination device?"
	label define ilc_satisfaction_po 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Neither satisfied nor unsatisfied" 4 "Somewhat unsatisfied" 5 "Very unsatisfied"
	label values ilc_satisfaction_po ilc_satisfaction_po

	label variable ilc_satisfied_po "ilc_satisfied_po 4.2 Why are you satisfied with the chlorination device?"
	note ilc_satisfied_po: "ilc_satisfied_po 4.2 Why are you satisfied with the chlorination device?"

	label variable ilc_satisfied_po_oth "ilc_satisfied_po_oth 4.3 Please specify other"
	note ilc_satisfied_po_oth: "ilc_satisfied_po_oth 4.3 Please specify other"

	label variable ilc_unsatisfied_po "ilc_unsatisfied_po 4.4 Why are you unsatisfied with the chlorination device?"
	note ilc_unsatisfied_po: "ilc_unsatisfied_po 4.4 Why are you unsatisfied with the chlorination device?"

	label variable ilc_unsatisfied_po_oth "ilc_unsatisfied_po_oth 4.5 Please specify other"
	note ilc_unsatisfied_po_oth: "ilc_unsatisfied_po_oth 4.5 Please specify other"

	label variable ilc_satisfaction "ilc_satisfaction 4.6 How satisfied are people in the village with the chlorinati"
	note ilc_satisfaction: "ilc_satisfaction 4.6 How satisfied are people in the village with the chlorination device?"
	label define ilc_satisfaction 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Neither satisfied nor unsatisfied" 4 "Somewhat unsatisfied" 5 "Very unsatisfied"
	label values ilc_satisfaction ilc_satisfaction

	label variable ilc_satisfied_village "ilc_satisfied_village 4.7 Why do you think the people in the village are satisfi"
	note ilc_satisfied_village: "ilc_satisfied_village 4.7 Why do you think the people in the village are satisfied with the chlorination device?"

	label variable ilc_satisfied_village_oth "ilc_satisfied_village_oth 4.8 Please specify other"
	note ilc_satisfied_village_oth: "ilc_satisfied_village_oth 4.8 Please specify other"

	label variable ilc_unsatisfied_village "ilc_unsatisfied_village 4.9 Why do you think the people in the village are unsat"
	note ilc_unsatisfied_village: "ilc_unsatisfied_village 4.9 Why do you think the people in the village are unsatisfied with the device?"

	label variable ilc_unsatisfied_village_oth "ilc_unsatisfied_village_oth 4.10 Please specify other"
	note ilc_unsatisfied_village_oth: "ilc_unsatisfied_village_oth 4.10 Please specify other"

	label variable hh_issues "hh_issues 4.11 In the last month, has anyone reported issues about the chlorine "
	note hh_issues: "hh_issues 4.11 In the last month, has anyone reported issues about the chlorine water to you?"
	label define hh_issues 1 "Yes" 0 "No"
	label values hh_issues hh_issues

	label variable hh_issues_type "hh_issues_type 4.12 What issues with the tap water have the households reported "
	note hh_issues_type: "hh_issues_type 4.12 What issues with the tap water have the households reported to you?"

	label variable hh_issues_type_other "hh_issues_type_other 4.13 Please specify other"
	note hh_issues_type_other: "hh_issues_type_other 4.13 Please specify other"

	label variable hh_issues_percent "hh_issues_percent 4.14 How many households reported these issues to you?"
	note hh_issues_percent: "hh_issues_percent 4.14 How many households reported these issues to you?"
	label define hh_issues_percent 1 "All the households in the village (100%)" 2 "Most of the households in the village (75%)" 3 "Half of the households in the village (50%)" 4 "Some of the households in the village (25%)" 5 "Few households in the village (Less than 25%)"
	label values hh_issues_percent hh_issues_percent

	label variable hh_issues_detail "hh_issues_detail 4.15 Why do you think people have these issues with the tap wat"
	note hh_issues_detail: "hh_issues_detail 4.15 Why do you think people have these issues with the tap water?"

	label variable hh_issues_response "hh_issues_response 4.16 How did you respond to these issues?"
	note hh_issues_response: "hh_issues_response 4.16 How did you respond to these issues?"

	label variable hh_issues_response_oth "hh_issues_response_oth 4.17 Please specify other"
	note hh_issues_response_oth: "hh_issues_response_oth 4.17 Please specify other"

	label variable hh_issues_response_detail "hh_issues_response_detail 4.18 Why did you respond to these issues in this way?"
	note hh_issues_response_detail: "hh_issues_response_detail 4.18 Why did you respond to these issues in this way?"

	label variable hh_issues_training "hh_issues_training 4.19 What would help you better respond to these issues in th"
	note hh_issues_training: "hh_issues_training 4.19 What would help you better respond to these issues in the future?"

	label variable turnoff_device_villager "turnoff_device_villager 4.20 Did anyone in the village ever ask you to remove th"
	note turnoff_device_villager: "turnoff_device_villager 4.20 Did anyone in the village ever ask you to remove the chlorination device or turn it off?"
	label define turnoff_device_villager 1 "Yes" 0 "No" 999 "Don't know"
	label values turnoff_device_villager turnoff_device_villager

	label variable turnoff_device_pop "turnoff_device_pop 4.21 Have you ever turned off the device before in response t"
	note turnoff_device_pop: "turnoff_device_pop 4.21 Have you ever turned off the device before in response to any complaints?"
	label define turnoff_device_pop 1 "Yes" 0 "No" 999 "Don't know"
	label values turnoff_device_pop turnoff_device_pop

	label variable turnoff_device_freq "turnoff_device_freq 4.22 How many times have you turned off the device in respon"
	note turnoff_device_freq: "turnoff_device_freq 4.22 How many times have you turned off the device in response to complaints?"

	label variable turnoff_duration "turnoff_duration 4.23 How long did you leave the device turned off for?"
	note turnoff_duration: "turnoff_duration 4.23 How long did you leave the device turned off for?"

	label variable turnoff_duration_unit "turnoff_duration_unit 4.24 Enumerator to select the duration unit"
	note turnoff_duration_unit: "turnoff_duration_unit 4.24 Enumerator to select the duration unit"
	label define turnoff_duration_unit 1 "Hours" 2 "Days" 3 "Weeks" 4 "Months" -77 "Other" 999 "Don't know"
	label values turnoff_duration_unit turnoff_duration_unit

	label variable turnoff_report "turnoff_report 4.25 Did you report that you turned off the device to anyone?"
	note turnoff_report: "turnoff_report 4.25 Did you report that you turned off the device to anyone?"

	label variable turnoff_report_oth "turnoff_report_oth 4.26 Please specify other"
	note turnoff_report_oth: "turnoff_report_oth 4.26 Please specify other"

	label variable oth_turnoff_device "oth_turnoff_device 4.27 Has anyone else ever turned off the device before?"
	note oth_turnoff_device: "oth_turnoff_device 4.27 Has anyone else ever turned off the device before?"
	label define oth_turnoff_device 1 "Yes" 0 "No" 999 "Don't know"
	label values oth_turnoff_device oth_turnoff_device

	label variable oth_turnoff_report "oth_turnoff_report 4.28 Did you report that someone turned off the device to any"
	note oth_turnoff_report: "oth_turnoff_report 4.28 Did you report that someone turned off the device to anyone?"

	label variable oth_turnoff_report_oth "oth_turnoff_report_oth 4.29 Please specify other"
	note oth_turnoff_report_oth: "oth_turnoff_report_oth 4.29 Please specify other"

	label variable contact_no_issues "contact_no_issues 4.30 Were you provided with a contact number to call if you ar"
	note contact_no_issues: "contact_no_issues 4.30 Were you provided with a contact number to call if you are facing issues with the device?"
	label define contact_no_issues 1 "Yes" 0 "No" 999 "Don't know"
	label values contact_no_issues contact_no_issues

	label variable contacted_issues "contacted_issues 4.31 Have you ever reached out to someone on this contact numbe"
	note contacted_issues: "contacted_issues 4.31 Have you ever reached out to someone on this contact number to report any issues?"
	label define contacted_issues 1 "Yes" 0 "No"
	label values contacted_issues contacted_issues

	label variable contacted_issues_type "contacted_issues_type 4.32 What issues did you report?"
	note contacted_issues_type: "contacted_issues_type 4.32 What issues did you report?"

	label variable op_satisfaction "op_satisfaction 4.33 How satisfied are you with operating this device?"
	note op_satisfaction: "op_satisfaction 4.33 How satisfied are you with operating this device?"
	label define op_satisfaction 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Neither satisfied nor unsatisfied" 4 "Somewhat unsatisfied" 5 "Very unsatisfied"
	label values op_satisfaction op_satisfaction

	label variable maint_issues "maint_issues 4.34 Are there any challenges associated with maintaining this devi"
	note maint_issues: "maint_issues 4.34 Are there any challenges associated with maintaining this device and keeping it functional?"

	label variable maint_issues_oth "maint_issues_oth 4.35 Please specify other"
	note maint_issues_oth: "maint_issues_oth 4.35 Please specify other"

	label variable maint_improvements "maint_improvements 4.36 Do you have any ideas for how to improve the operation a"
	note maint_improvements: "maint_improvements 4.36 Do you have any ideas for how to improve the operation and maintenance for the ILC device?"

	label variable maint_notes "maint_notes 4.37 Is there any additional information or advice you would like to"
	note maint_notes: "maint_notes 4.37 Is there any additional information or advice you would like to share regarding the operation and maintenance of the ILC device?"

	label variable comments_ilc_perceptions "comments_ILC_perceptions 4.38 Enumerator to fill: Do you have any additional com"
	note comments_ilc_perceptions: "comments_ILC_perceptions 4.38 Enumerator to fill: Do you have any additional comments to mention?"

	label variable comment_opt "comment_opt For enumerator : Do you wish to add any additional comments about th"
	note comment_opt: "comment_opt For enumerator : Do you wish to add any additional comments about this survey?"
	label define comment_opt 1 "Yes" 0 "No"
	label values comment_opt comment_opt

	label variable comment "comment For enumerator : Please add any additional comments about this survey"
	note comment: "comment For enumerator : Please add any additional comments about this survey"






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
*   Corrections file path and filename:  pump_operator_survey_corrections.csv
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
