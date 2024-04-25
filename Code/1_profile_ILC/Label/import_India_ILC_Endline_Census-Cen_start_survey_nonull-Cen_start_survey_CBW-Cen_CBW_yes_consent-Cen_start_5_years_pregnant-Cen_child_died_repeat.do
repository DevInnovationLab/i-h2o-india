* import_India_ILC_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.do
*
* 	Imports and aggregates "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat" (ID: India_ILC_Endline_Census) data.
*
*	Inputs:  "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.csv"
*	Outputs: "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta"
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
local csvfile "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.csv"
local dtafile "${DataRaw}1_8_Endline/Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta"
local corrfile "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat_corrections.csv"
local note_fields1 ""
local text_fields1 "cen_name_child cen_name_child_earlier cen_fath_child cen_dod_concat_cbw cen_dod_autoage cen_year_cbw cen_curr_year_cbw cen_curr_mon_cbw cen_age_years_cbw cen_age_mon_cbw cen_age_years_f_cbw"
local text_fields2 "cen_age_months_f_cbw cen_age_decimal_cbw cen_cause_death cen_cause_death_oth cen_cause_death_str"
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


	label variable cen_name_child "C20) What is the full name of the child that died?"
	note cen_name_child: "C20) What is the full name of the child that died?"

	label variable cen_gen_child "What is the gender of the \${Cen_name_child_earlier}?"
	note cen_gen_child: "What is the gender of the \${Cen_name_child_earlier}?"
	label define cen_gen_child 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values cen_gen_child cen_gen_child

	label variable cen_fath_child "What is the name of \${Cen_name_child_earlier}'s father?"
	note cen_fath_child: "What is the name of \${Cen_name_child_earlier}'s father?"

	label variable cen_age_child "C21) What was their age at the time of death? (select unit)"
	note cen_age_child: "C21) What was their age at the time of death? (select unit)"
	label define cen_age_child 1 "Days" 2 "Months" 3 "Years" -98 "Refused" 999 "Don't know"
	label values cen_age_child cen_age_child

	label variable cen_unit_child_days "Write in Days"
	note cen_unit_child_days: "Write in Days"

	label variable cen_unit_child_months "Write in months"
	note cen_unit_child_months: "Write in months"

	label variable cen_unit_child_years "Write in years"
	note cen_unit_child_years: "Write in years"

	label variable cen_dob_date_cbw "Please select the date of birth"
	note cen_dob_date_cbw: "Please select the date of birth"
	label define cen_dob_date_cbw 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
	label values cen_dob_date_cbw cen_dob_date_cbw

	label variable cen_dob_month_cbw "Please select the month of birth"
	note cen_dob_month_cbw: "Please select the month of birth"
	label define cen_dob_month_cbw 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
	label values cen_dob_month_cbw cen_dob_month_cbw

	label variable cen_dob_year_cbw "Please select the year of birth"
	note cen_dob_year_cbw: "Please select the year of birth"
	label define cen_dob_year_cbw 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
	label values cen_dob_year_cbw cen_dob_year_cbw

	label variable cen_dod_date_cbw "Please select the date of death"
	note cen_dod_date_cbw: "Please select the date of death"
	label define cen_dod_date_cbw 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
	label values cen_dod_date_cbw cen_dod_date_cbw

	label variable cen_dod_month_cbw "Please select the month of death"
	note cen_dod_month_cbw: "Please select the month of death"
	label define cen_dod_month_cbw 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
	label values cen_dod_month_cbw cen_dod_month_cbw

	label variable cen_dod_year_cbw "Please select the year of death"
	note cen_dod_year_cbw: "Please select the year of death"
	label define cen_dod_year_cbw 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
	label values cen_dod_year_cbw cen_dod_year_cbw

	label variable cen_cause_death "C25) What did \${Cen_name_child_earlier} die from?"
	note cen_cause_death: "C25) What did \${Cen_name_child_earlier} die from?"

	label variable cen_cause_death_oth "C25.1) Please specify other"
	note cen_cause_death_oth: "C25.1) Please specify other"

	label variable cen_cause_death_diagnosed "C26) Was this cause of death diagonsed by any health official?"
	note cen_cause_death_diagnosed: "C26) Was this cause of death diagonsed by any health official?"
	label define cen_cause_death_diagnosed 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_cause_death_diagnosed cen_cause_death_diagnosed

	label variable cen_cause_death_str "C27) In your own words, can you describe what was the cause of death?"
	note cen_cause_death_str: "C27) In your own words, can you describe what was the cause of death?"






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
*   Corrections file path and filename:  Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat_corrections.csv
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
