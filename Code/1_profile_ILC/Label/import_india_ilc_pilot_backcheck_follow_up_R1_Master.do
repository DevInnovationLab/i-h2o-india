* import_india_ilc_pilot_backcheck_follow_up_R1_Master.do
*
* 	Imports and aggregates "Baseline Follow Up R1 Backcheck" (ID: india_ilc_pilot_backcheck_follow_up_R1_Master) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck_WIDE.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck.dta"
*
*	Output by SurveyCTO March 4, 2024 5:27 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck_WIDE.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_fu1_r_cen_landmark r_fu1_r_cen_address r_fu1_r_cen_saahi_name r_fu1_r_cen_a1_resp_name r_fu1_r_cen_a10_hhhead"
local text_fields2 "r_fu1_r_cen_a39_phone_name_1 r_fu1_r_cen_a39_phone_num_1 r_fu1_r_cen_a39_phone_name_2 r_fu1_r_cen_a39_phone_num_2 r_fu1_r_cen_village_name_str r_fu1_r_cen_hamlet_name r_fu1_r_cen_a11_oldmale_name"
local text_fields3 "r_fu1_r_cen_fam_name1 r_fu1_r_cen_fam_name2 r_fu1_r_cen_fam_name3 r_fu1_r_cen_fam_name4 r_fu1_r_cen_fam_name5 r_fu1_r_cen_fam_name6 r_fu1_r_cen_fam_name7 r_fu1_r_cen_fam_name8 r_fu1_r_cen_fam_name9"
local text_fields4 "r_fu1_r_cen_fam_name10 r_fu1_r_cen_fam_name11 r_fu1_r_cen_fam_name12 r_fu1_r_cen_fam_name13 r_fu1_r_cen_fam_name14 r_fu1_r_cen_fam_name15 r_fu1_r_cen_fam_name16 r_fu1_r_cen_fam_name17"
local text_fields5 "r_fu1_r_cen_fam_name18 r_fu1_r_cen_fam_name19 r_fu1_r_cen_fam_name20 r_fu1_water_source_prim info_update enum_name_label who_interviwed_before missing_household_member_name no_consent_reason"
local text_fields6 "no_consent_oth no_consent_comment consent_dur_end water_prim_oth primary_water_label water_source_sec water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count water_sec_index_*"
local text_fields7 "water_sec_value_* water_sec_label_* water_sec_labels water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label"
local text_fields8 "water_treat_when water_treat_when_oth water_treat_type a41_end_comments instanceid instancename"
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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_FU1_r_cen_village_name_str} Hamlet: \${R_FU1_r_cen_hamlet_name} Household head name: \${R_FU1_r_cen_a10_hhhead} Respondent name from the previous round: \${R_FU1_r_cen_a1_resp_name} Any male household head (if any): \${R_FU1_r_cen_a11_oldmale_name} Address: \${R_FU1_r_cen_address} Landmark: \${R_FU1_r_cen_landmark} Saahi: \${R_FU1_r_cen_saahi_name} Phone 1: \${R_FU1_r_cen_a39_phone_name_1} (\${R_FU1_r_cen_a39_phone_num_1}) Phone 2: \${R_FU1_r_cen_a39_phone_name_2} (\${R_FU1_r_cen_a39_phone_num_2})"
	label define noteconf1 1 "I am visiting the correct household and the information is correct" 2 "I am visiting the correct household but the information needs to be updated" 3 "The household I am visiting does not corresponds to the confirmation info."
	label values noteconf1 noteconf1

	label variable info_update "Please describe the information need to be updated here."
	note info_update: "Please describe the information need to be updated here."

	label variable enum_name "Enumerator name: Please select from the drop-down list"
	note enum_name: "Enumerator name: Please select from the drop-down list"
	label define enum_name 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values enum_name enum_name

	label variable resp_available "Did you find a household to interview?"
	note resp_available: "Did you find a household to interview?"
	label define resp_available 1 "Household available for interview and opened the door" 2 "Family has left the house permanently" 3 "This is my first visit: The family is temporarily unavailable but might be avail" 4 "This is my 1st re-visit: The family is temporarily unavailable but might be avai" 5 "This is my 2nd re-visit: The revisit within two days is not possible" 6 "This is my 2nd re-visit: The family is temporarily unavailable (Please leave the"
	label values resp_available resp_available

	label variable interviewed_before "Enumerator: Ask the person who ever opens the door if this household was intervi"
	note interviewed_before: "Enumerator: Ask the person who ever opens the door if this household was interviewed before?"
	label define interviewed_before 1 "Yes" 0 "No"
	label values interviewed_before interviewed_before

	label variable who_interviwed_before "A1) who among the household members was interviewed before?"
	note who_interviwed_before: "A1) who among the household members was interviewed before?"

	label variable missing_household_member_name "A1.1) Please enter the other household member that don’t exist in the list provi"
	note missing_household_member_name: "A1.1) Please enter the other household member that don’t exist in the list provided"

	label variable fivemin_interview "A2) Is the respondent available for a five minute interview?"
	note fivemin_interview: "A2) Is the respondent available for a five minute interview?"
	label define fivemin_interview 1 "Yes" 0 "No"
	label values fivemin_interview fivemin_interview

	label variable consent "A3) Do I have your permission to proceed with the interview?"
	note consent: "A3) Do I have your permission to proceed with the interview?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable no_consent_reason "A4) Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason: "A4) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_oth "A4.1) Please specify other"
	note no_consent_oth: "A4.1) Please specify other"

	label variable no_consent_comment "A6) Record any relevant notes if the respondent refused the interview"
	note no_consent_comment: "A6) Record any relevant notes if the respondent refused the interview"

	label variable water_source_prim "W1) In the past one month, which water source did you primarily use for drinking"
	note water_source_prim: "W1) In the past one month, which water source did you primarily use for drinking?"
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

	label variable where_prim_locate "W6) Where is your primary drinking water source (\${primary_water_label}) locate"
	note where_prim_locate: "W6) Where is your primary drinking water source (\${primary_water_label}) located?"
	label define where_prim_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_prim_locate where_prim_locate

	label variable where_sec_locate "W11) Where is your secondary drinking water source (\${secondary_main_water_labe"
	note where_sec_locate: "W11) Where is your secondary drinking water source (\${secondary_main_water_label}) located?"
	label define where_sec_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
	label values where_sec_locate where_sec_locate

	label variable water_treat "W16) In the last one month, did your household do anything extra to the drinking"
	note water_treat: "W16) In the last one month, did your household do anything extra to the drinking water (\${primary_water_label} ) to make it safe before drinking it?"
	label define water_treat 1 "Yes" 0 "No" 999 "Don't know"
	label values water_treat water_treat

	label variable water_treat_when "W17) When do you make the water from your primary drinking water source (\${prim"
	note water_treat_when: "W17) When do you make the water from your primary drinking water source (\${primary_water_label} ) safe before drinking it?"

	label variable water_treat_when_oth "W17.1) Please specify other:"
	note water_treat_when_oth: "W17.1) Please specify other:"

	label variable water_treat_type "W19.2) What did your household do to the water to make it safe for drinking?"
	note water_treat_type: "W19.2) What did your household do to the water to make it safe for drinking?"

	label variable tap_use_drinking_yesno "G3)Do you use the government provided household tap for drinking?"
	note tap_use_drinking_yesno: "G3)Do you use the government provided household tap for drinking?"
	label define tap_use_drinking_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values tap_use_drinking_yesno tap_use_drinking_yesno

	label variable chlorine_yesno "C7) Has your household ever applied chlorine or bleaching powder as a method for"
	note chlorine_yesno: "C7) Has your household ever applied chlorine or bleaching powder as a method for treating drinking water, after fetching water/getting water?"
	label define chlorine_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_yesno chlorine_yesno

	label variable chlorine_drank_yesno "C8) Have you ever drank water treated with chlorine or bleaching powder?"
	note chlorine_drank_yesno: "C8) Have you ever drank water treated with chlorine or bleaching powder?"
	label define chlorine_drank_yesno 1 "Yes" 0 "No" 999 "Don't know"
	label values chlorine_drank_yesno chlorine_drank_yesno

	label variable a41_end_comments "A38) Please add any additional comments about this survey."
	note a41_end_comments: "A38) Please add any additional comments about this survey."






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Baseline Follow Up R1 Backcheck_corrections.csv
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
