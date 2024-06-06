* import_India_ILC_Endline_Census_Revisit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.do
*
* 	Imports and aggregates "Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.dta"
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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5_corrections.csv"
local note_fields1 ""
local text_fields1 "comb_out_ind2_u5 comb_out_val2_u5 comb_out_names_u5 comb_med_treat_type_u5 comb_med_treat_oth_u5 comb_med_trans_u5 comb_med_scheme_u5 comb_med_illness_other_u5 comb_tests_exp_loop_u5_count"
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


	label variable comb_med_treat_type_u5 "What was the nature of treatment at \${comb_out_names_U5} that \${comb_child_u5_"
	note comb_med_treat_type_u5: "What was the nature of treatment at \${comb_out_names_U5} that \${comb_child_u5_name_label} took?"

	label variable comb_med_treat_oth_u5 "Other"
	note comb_med_treat_oth_u5: "Other"

	label variable comb_med_trans_u5 "What was the mode of transportation taken by \${comb_child_u5_name_label} to tra"
	note comb_med_trans_u5: "What was the mode of transportation taken by \${comb_child_u5_name_label} to travel to \${comb_out_names_U5}?"

	label variable comb_med_time_u5 "How much time did \${comb_child_u5_name_label} to travel to \${comb_out_names_U5"
	note comb_med_time_u5: "How much time did \${comb_child_u5_name_label} to travel to \${comb_out_names_U5} to receive care?"
	label define comb_med_time_u5 1 "Minutes" 2 "Hours" 999 "Don't know"
	label values comb_med_time_u5 comb_med_time_u5

	label variable comb_med_time_mins_u5 "Minutes"
	note comb_med_time_mins_u5: "Minutes"

	label variable comb_med_time_hrs_u5 "Hours"
	note comb_med_time_hrs_u5: "Hours"

	label variable comb_med_pay_trans_u5 "What did \${comb_child_u5_name_label} pay for the transportation to travel to \$"
	note comb_med_pay_trans_u5: "What did \${comb_child_u5_name_label} pay for the transportation to travel to \${comb_out_names_U5}?"

	label variable comb_med_scheme_u5 "Was \${comb_child_u5_name_label} covered by any scheme for health expenditure su"
	note comb_med_scheme_u5: "Was \${comb_child_u5_name_label} covered by any scheme for health expenditure support for the expenditure incurred at \${comb_out_names_U5}?"

	label variable comb_med_doctor_fees_u5 "What did \${comb_child_u5_name_label} pay for the consultation/treatment (doctor"
	note comb_med_doctor_fees_u5: "What did \${comb_child_u5_name_label} pay for the consultation/treatment (doctor fees) at \${comb_out_names_U5}?"

	label variable comb_med_illness_u5 "Did \${comb_child_u5_name_label} pay for anything else for this illness at \${co"
	note comb_med_illness_u5: "Did \${comb_child_u5_name_label} pay for anything else for this illness at \${comb_out_names_U5}?"
	label define comb_med_illness_u5 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values comb_med_illness_u5 comb_med_illness_u5

	label variable comb_med_illness_other_u5 "What did \${comb_child_u5_name_label} pay for at \${comb_out_names_U5}?"
	note comb_med_illness_other_u5: "What did \${comb_child_u5_name_label} pay for at \${comb_out_names_U5}?"






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5_corrections.csv
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
