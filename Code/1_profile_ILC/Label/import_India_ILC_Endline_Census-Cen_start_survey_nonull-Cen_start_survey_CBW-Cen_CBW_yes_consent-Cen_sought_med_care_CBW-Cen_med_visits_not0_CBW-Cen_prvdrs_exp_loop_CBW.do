* import_India_ILC_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.do
*
* 	Imports and aggregates "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW" (ID: India_ILC_Endline_Census) data.
*
*	Inputs:  "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.csv"
*	Outputs: "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/1_profile_ILC/Label/Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta"
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
local csvfile "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.csv"
local dtafile "${DataRaw}1_8_Endline/Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta"
local corrfile "Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_corrections.csv"
local note_fields1 ""
local text_fields1 "cen_out_ind2_cbw cen_out_val2_cbw cen_out_names_cbw cen_med_treat_type_cbw cen_med_treat_oth_cbw cen_med_trans_cbw cen_med_scheme_cbw cen_med_illness_other_cbw cen_tests_exp_loop_cbw_count"
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


	label variable cen_med_treat_type_cbw "What was the nature of treatment at \${Cen_out_names_CBW} that \${Cen_name_CBW_w"
	note cen_med_treat_type_cbw: "What was the nature of treatment at \${Cen_out_names_CBW} that \${Cen_name_CBW_woman_earlier} took?"

	label variable cen_med_treat_oth_cbw "Other"
	note cen_med_treat_oth_cbw: "Other"

	label variable cen_med_trans_cbw "What was the mode of transportation taken by \${Cen_name_CBW_woman_earlier} to t"
	note cen_med_trans_cbw: "What was the mode of transportation taken by \${Cen_name_CBW_woman_earlier} to travel to \${Cen_out_names_CBW}?"

	label variable cen_med_time_cbw "How much time did \${Cen_name_CBW_woman_earlier} to travel to \${Cen_out_names_C"
	note cen_med_time_cbw: "How much time did \${Cen_name_CBW_woman_earlier} to travel to \${Cen_out_names_CBW} to receive care?"
	label define cen_med_time_cbw 1 "Minutes" 2 "Hours" 999 "Don't know"
	label values cen_med_time_cbw cen_med_time_cbw

	label variable cen_med_time_mins_cbw "Minutes"
	note cen_med_time_mins_cbw: "Minutes"

	label variable cen_med_time_hrs_cbw "Hours"
	note cen_med_time_hrs_cbw: "Hours"

	label variable cen_med_pay_trans_cbw "What did \${Cen_name_CBW_woman_earlier} pay for the transportation to travel to "
	note cen_med_pay_trans_cbw: "What did \${Cen_name_CBW_woman_earlier} pay for the transportation to travel to \${Cen_out_names_CBW}?"

	label variable cen_med_scheme_cbw "Was \${Cen_name_CBW_woman_earlier} covered by any scheme for health expenditure "
	note cen_med_scheme_cbw: "Was \${Cen_name_CBW_woman_earlier} covered by any scheme for health expenditure support for the expenditure incurred at \${Cen_out_names_CBW}?"

	label variable cen_med_doctor_fees_cbw "What did \${Cen_name_CBW_woman_earlier} pay for the consultation/treatment (doct"
	note cen_med_doctor_fees_cbw: "What did \${Cen_name_CBW_woman_earlier} pay for the consultation/treatment (doctor fees) at \${Cen_out_names_CBW}?"

	label variable cen_med_illness_cbw "Did \${Cen_name_CBW_woman_earlier} pay for anything else for this illness at \${"
	note cen_med_illness_cbw: "Did \${Cen_name_CBW_woman_earlier} pay for anything else for this illness at \${Cen_out_names_CBW}?"
	label define cen_med_illness_cbw 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values cen_med_illness_cbw cen_med_illness_cbw

	label variable cen_med_illness_other_cbw "What did \${Cen_name_CBW_woman_earlier} pay for at \${Cen_out_names_CBW}?"
	note cen_med_illness_other_cbw: "What did \${Cen_name_CBW_woman_earlier} pay for at \${Cen_out_names_CBW}?"






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
*   Corrections file path and filename:  Endline Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_corrections.csv
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
