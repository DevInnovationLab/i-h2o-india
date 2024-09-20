* import_india_ilc_pilot_mortality_Master-consented-preg_child_hist-women_child_bearing.do
*
* 	Imports and aggregates "Mortality Survey-consented-preg_child_hist-women_child_bearing" (ID: india_ilc_pilot_mortality_Master) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing.dta"
*
*	Output by SurveyCTO September 20, 2024 8:28 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing_corrections.csv"
local note_fields1 ""
local text_fields1 "child_bearing_index name_pc_earlier no_consent_reason_pc no_consent_pc_oth no_consent_pc_comment vill_pc_oth village_name_res num_living_null_ num_notliving_null_ num_stillborn_null_nsc"
local text_fields2 "num_less24_null_nsc num_more24_null_nsc child_died_u5_count_null child_died_repeat_count"
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


	label variable name_pc "C1) What is respondent’s name?"
	note name_pc: "C1) What is respondent’s name?"
	label define name_pc 1 "\${fam_name1} and \${fam_age1} years" 2 "\${fam_name2} and \${fam_age2} years" 3 "\${fam_name3} and \${fam_age3} years" 4 "\${fam_name4} and \${fam_age4} years" 5 "\${fam_name5} and \${fam_age5} years" 6 "\${fam_name6} and \${fam_age6} years" 7 "\${fam_name7} and \${fam_age7} years" 8 "\${fam_name8} and \${fam_age8} years" 9 "\${fam_name9} and \${fam_age9} years" 10 "\${fam_name10} and \${fam_age10} years" 11 "\${fam_name11} and \${fam_age11} years" 12 "\${fam_name12} and \${fam_age12} years" 13 "\${fam_name13} and \${fam_age13} years" 14 "\${fam_name14} and \${fam_age14} years" 15 "\${fam_name15} and \${fam_age15} years" 16 "\${fam_name16} and \${fam_age16} years" 17 "\${fam_name17} and \${fam_age17} years" 18 "\${fam_name18} and \${fam_age18} years" 19 "\${fam_name19} and \${fam_age19} years" 20 "\${fam_name20} and \${fam_age20} years"
	label values name_pc name_pc

	label variable resp_avail_pc "C2) Did you find \${name_pc_earlier} to interview?"
	note resp_avail_pc: "C2) Did you find \${name_pc_earlier} to interview?"
	label define resp_avail_pc 1 "Respondent available for an interview" 2 "Family has left the house permanently" 3 "This is my first visit: The respondent is temporarily unavailable but might be a" 4 "This is my 1st re-visit: The respondent is temporarily unavailable but might be " 5 "This is my 2nd re-visit: The respondent is temporarily unavailable but might be " 6 "This is my 3rd re-visit: The revisit within two days is not possible (e.g. all t" 7 "This is my 3rd re-visit: The respondent is temporarily unavailable (Please leave"
	label values resp_avail_pc resp_avail_pc

	label variable consent_pc "C3)Do I have your permission to proceed with the interview?"
	note consent_pc: "C3)Do I have your permission to proceed with the interview?"
	label define consent_pc 1 "Yes" 0 "No"
	label values consent_pc consent_pc

	label variable no_consent_reason_pc "C4) Can you tell me why you do not want to participate in the survey?"
	note no_consent_reason_pc: "C4) Can you tell me why you do not want to participate in the survey?"

	label variable no_consent_pc_oth "C4.1) Please specify other"
	note no_consent_pc_oth: "C4.1) Please specify other"

	label variable no_consent_pc_comment "C4.2) Record any relevant notes if the respondent refused the interview"
	note no_consent_pc_comment: "C4.2) Record any relevant notes if the respondent refused the interview"

	label variable residence_yesno_pc "C5) Is this \${name_pc_earlier} ’s usual residence?"
	note residence_yesno_pc: "C5) Is this \${name_pc_earlier} ’s usual residence?"
	label define residence_yesno_pc 1 "Yes" 0 "No"
	label values residence_yesno_pc residence_yesno_pc

	label variable vill_pc "C6) Which village is \${name_pc_earlier} ’s current permanent residence in?"
	note vill_pc: "C6) Which village is \${name_pc_earlier} ’s current permanent residence in?"
	label define vill_pc 30202 "BK Padar" 30701 "Gopi Kankubadi" 50501 "Nathma" 50402 "Kuljing" -77 "Other"
	label values vill_pc vill_pc

	label variable vill_pc_oth "C6.1) Please specify other"
	note vill_pc_oth: "C6.1) Please specify other"

	label variable a7_pregnant_leave "C7) How long is \${name_pc_earlier} planning to stay here (at the house where th"
	note a7_pregnant_leave: "C7) How long is \${name_pc_earlier} planning to stay here (at the house where the survey is being conducted) ? Please enter in months"
	label define a7_pregnant_leave 1 "Days" 2 "Months"
	label values a7_pregnant_leave a7_pregnant_leave

	label variable a7_pregnant_leave_days "Record in Days"
	note a7_pregnant_leave_days: "Record in Days"

	label variable a7_pregnant_leave_months "Record in Months"
	note a7_pregnant_leave_months: "Record in Months"

	label variable vill_residence "C8) Was \${village_name_res} your permanent residence at any time in the last 5 "
	note vill_residence: "C8) Was \${village_name_res} your permanent residence at any time in the last 5 years?"
	label define vill_residence 1 "Yes" 0 "No"
	label values vill_residence vill_residence

	label variable last_5_years_pregnant "C9)Have you ever been pregnant in the last 5 years since January 1, 2019?"
	note last_5_years_pregnant: "C9)Have you ever been pregnant in the last 5 years since January 1, 2019?"
	label define last_5_years_pregnant 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values last_5_years_pregnant last_5_years_pregnant

	label variable child_living "C10) Do you have any children under 5 years of age to whom you have given birth "
	note child_living: "C10) Do you have any children under 5 years of age to whom you have given birth since January 1, 2019 who are now living with you?"
	label define child_living 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values child_living child_living

	label variable child_living_num "C11) How many children born since January 1, 2019 live with you?"
	note child_living_num: "C11) How many children born since January 1, 2019 live with you?"

	label variable child_notliving "C12) Do you have any children born since January 1, 2019 to whom you have given "
	note child_notliving: "C12) Do you have any children born since January 1, 2019 to whom you have given birth who are alive but do not live with you?"
	label define child_notliving 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values child_notliving child_notliving

	label variable child_notliving_num "C13) How many children born since January 1, 2019 are alive but do not live with"
	note child_notliving_num: "C13) How many children born since January 1, 2019 are alive but do not live with you?"

	label variable child_stillborn "C14) Have you given birth to a child who was stillborn since January 1, 2019? I "
	note child_stillborn: "C14) Have you given birth to a child who was stillborn since January 1, 2019? I mean, to a child who never breathed or cried or showed other signs of life."
	label define child_stillborn 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values child_stillborn child_stillborn

	label variable child_stillborn_num "C15) How many children born since January 1, 2019 were stillborn?"
	note child_stillborn_num: "C15) How many children born since January 1, 2019 were stillborn?"

	label variable child_alive_died_24 "C16) Have you given birth to a child since January 1, 2019 who was born alive bu"
	note child_alive_died_24: "C16) Have you given birth to a child since January 1, 2019 who was born alive but later died (include only those cases where child was alive for less than 24 hours) ? I mean, breathed or cried or showed other signs of life – even if he or she lived only a few minutes or hours?"
	label define child_alive_died_24 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values child_alive_died_24 child_alive_died_24

	label variable child_died_num "C17) How many children born since January 1, 2019 have died within 24 hours?"
	note child_died_num: "C17) How many children born since January 1, 2019 have died within 24 hours?"

	label variable child_alive_died "C18) Are there any children born since January 1, 2019 who have died after 24 ho"
	note child_alive_died: "C18) Are there any children born since January 1, 2019 who have died after 24 hours from birth till the age of 5 years?"
	label define child_alive_died 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values child_alive_died child_alive_died

	label variable child_died_num_more24 "C19) How many children born since January 1, 2019 have died after 24 hours from "
	note child_died_num_more24: "C19) How many children born since January 1, 2019 have died after 24 hours from birth till the age of 5 years ?"

	label variable confirm "Please confirm that \${name_pc_earlier} had \${child_living_num} children who we"
	note confirm: "Please confirm that \${name_pc_earlier} had \${child_living_num} children who were born since 1 January 2019 and living with them, \${child_stillborn_num} still births and \${child_died_num} children who were born but later died. Is this information complete and correct?"
	label define confirm 1 "Yes" 0 "No"
	label values confirm confirm

	label variable miscarriage "Did you have a miscarriage during the pregnancy?"
	note miscarriage: "Did you have a miscarriage during the pregnancy?"
	label define miscarriage 1 "Yes" 0 "No" 999 "Don't know" 98 "Refused to answer"
	label values miscarriage miscarriage

	label variable correct "C28)Have you corrected respondent's details if they were incorrect earlier?"
	note correct: "C28)Have you corrected respondent's details if they were incorrect earlier?"
	label define correct 1 "Yes" 0 "No"
	label values correct correct

	label variable translator "C29)Was a translator used in the survey?"
	note translator: "C29)Was a translator used in the survey?"
	label define translator 1 "Yes" 0 "No"
	label values translator translator






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Mortality Survey-consented-preg_child_hist-women_child_bearing_corrections.csv
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
