* import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.do
*
* 	Imports and aggregates "Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop" (ID: India_ILC_Endline_Census_Revisit) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.dta"
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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop_corrections.csv"
local note_fields1 ""
local text_fields1 "namenumber n_hhmember_name namefromearlier n_relation_oth n_cbw_age n_all_age n_age_confirm2 n_dob_concat n_autoage n_year current_year current_month age_years age_months age_years_final"
local text_fields2 "age_months_final age_decimal n_u5mother_name_oth n_u5father_name_oth"
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


	label variable n_hhmember_name "A3) What is the name of household member \${namenumber}?"
	note n_hhmember_name: "A3) What is the name of household member \${namenumber}?"

	label variable n_hhmember_gender "A4) What is the gender of \${namefromearlier}?"
	note n_hhmember_gender: "A4) What is the gender of \${namefromearlier}?"
	label define n_hhmember_gender 1 "Male" 2 "Female" 3 "Other" -98 "Refused"
	label values n_hhmember_gender n_hhmember_gender

	label variable n_hhmember_relation "A5) Who is \${namefromearlier} to you ?"
	note n_hhmember_relation: "A5) Who is \${namefromearlier} to you ?"
	label define n_hhmember_relation 1 "Self" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Son-In-Law/ Daughter-In-Law" 5 "Grandchild" 6 "Parent" 7 "Parent-In-Law" 8 "Brother/Sister" 9 "Nephew/niece" 11 "Adopted/Foster/step child" 12 "Not related" 13 "Brother-in-law/sister-in-law" -77 "Other" 999 "Don’t know"
	label values n_hhmember_relation n_hhmember_relation

	label variable n_relation_oth "A5.1) If Other, please specify:"
	note n_relation_oth: "A5.1) If Other, please specify:"

	label variable n_hhmember_age "A6) How old is \${namefromearlier} in years?"
	note n_hhmember_age: "A6) How old is \${namefromearlier} in years?"

	label variable n_dob_date "Please select the date of birth"
	note n_dob_date: "Please select the date of birth"
	label define n_dob_date 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13" 14 "14" 15 "15" 16 "16" 17 "17" 18 "18" 19 "19" 20 "20" 21 "21" 22 "22" 23 "23" 24 "24" 25 "25" 26 "26" 27 "27" 28 "28" 29 "29" 30 "30" 31 "31" 999 "Don’t know"
	label values n_dob_date n_dob_date

	label variable n_dob_month "Please select the month of birth"
	note n_dob_month: "Please select the month of birth"
	label define n_dob_month 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 999 "Don’t know"
	label values n_dob_month n_dob_month

	label variable n_dob_year "Please select the year of birth"
	note n_dob_year: "Please select the year of birth"
	label define n_dob_year 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024"
	label values n_dob_year n_dob_year

	label variable n_year_dob_correction "Note to Enumerator: The age calculated based on the date of birth- \${N_autoage}"
	note n_year_dob_correction: "Note to Enumerator: The age calculated based on the date of birth- \${N_autoage}- should match the age of the child given in years by the respondent. Please note that there cannot be a difference of more than a year in the estimated/imputed age. Go back to the question and confirm with respondent properly Did you confirm the age and date of birth properly?"
	label define n_year_dob_correction 1 "Yes" 0 "No"
	label values n_year_dob_correction n_year_dob_correction

	label variable n_u1age "A6.3) How old is \${namefromearlier} in months/days?"
	note n_u1age: "A6.3) How old is \${namefromearlier} in months/days?"
	label define n_u1age 1 "Months" 2 "Days" 999 "Don't know"
	label values n_u1age n_u1age

	label variable n_unit_age_months "Write in months"
	note n_unit_age_months: "Write in months"

	label variable n_unit_age_days "Write in days"
	note n_unit_age_days: "Write in days"

	label variable n_correct_age "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed"
	note n_correct_age: "Enumerator to note if the above age for the child U5 was accurate (i.e confirmed from birth certificate/ Anganwadi records) or imputed/guessed"
	label define n_correct_age 1 "Age for U5 child accurate" 2 "Age for U5 child imputed/guessed"
	label values n_correct_age n_correct_age

	label variable n_u5mother "A8) Does the mother/ primary caregiver of \${namefromearlier} live in this house"
	note n_u5mother: "A8) Does the mother/ primary caregiver of \${namefromearlier} live in this household currently?"
	label define n_u5mother 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_u5mother n_u5mother

	label variable n_u5mother_name "A8.1) What is the name of \${namefromearlier}'s mother/ primary caregiver?"
	note n_u5mother_name: "A8.1) What is the name of \${namefromearlier}'s mother/ primary caregiver?"
	label define n_u5mother_name 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${N_fam_name1} and \${N_fam_age1} years" 22 "\${N_fam_name2} and \${N_fam_age2} years" 23 "\${N_fam_name3} and \${N_fam_age3} years" 24 "\${N_fam_name4} and \${N_fam_age4} years" 25 "\${N_fam_name5} and \${N_fam_age5} years" 26 "\${N_fam_name6} and \${N_fam_age6} years" 27 "\${N_fam_name7} and \${N_fam_age7} years" 28 "\${N_fam_name8} and \${N_fam_age8} years" 29 "\${N_fam_name9} and \${N_fam_age9} years" 30 "\${N_fam_name10} and \${N_fam_age10} years" 31 "\${N_fam_name11} and \${N_fam_age11} years" 32 "\${N_fam_name12} and \${N_fam_age12} years" 33 "\${N_fam_name13} and \${N_fam_age13} years" 34 "\${N_fam_name14} and \${N_fam_age14} years" 35 "\${N_fam_name15} and \${N_fam_age15} years" 36 "\${N_fam_name16} and \${N_fam_age16} years" 37 "\${N_fam_name17} and \${N_fam_age17} years" 38 "\${N_fam_name18} and \${N_fam_age18} years" 39 "\${N_fam_name19} and \${N_fam_age19} years" 40 "\${N_fam_name20} and \${N_fam_age20} years"
	label values n_u5mother_name n_u5mother_name

	label variable n_u5mother_name_oth "Please specify other"
	note n_u5mother_name_oth: "Please specify other"

	label variable n_u5father_name "A8.1) What is the name of \${namefromearlier}'s father?"
	note n_u5father_name: "A8.1) What is the name of \${namefromearlier}'s father?"
	label define n_u5father_name 1 "\${R_Cen_fam_name1} and \${Cen_fam_age1} years" 2 "\${R_Cen_fam_name2} and \${Cen_fam_age2} years" 3 "\${R_Cen_fam_name3} and \${Cen_fam_age3} years" 4 "\${R_Cen_fam_name4} and \${Cen_fam_age4} years" 5 "\${R_Cen_fam_name5} and \${Cen_fam_age5} years" 6 "\${R_Cen_fam_name6} and \${Cen_fam_age6} years" 7 "\${R_Cen_fam_name7} and \${Cen_fam_age7} years" 8 "\${R_Cen_fam_name8} and \${Cen_fam_age8} years" 9 "\${R_Cen_fam_name9} and \${Cen_fam_age9} years" 10 "\${R_Cen_fam_name10} and \${Cen_fam_age10} years" 11 "\${R_Cen_fam_name11} and \${Cen_fam_age11} years" 12 "\${R_Cen_fam_name12} and \${Cen_fam_age12} years" 13 "\${R_Cen_fam_name13} and \${Cen_fam_age13} years" 14 "\${R_Cen_fam_name14} and \${Cen_fam_age14} years" 15 "\${R_Cen_fam_name15} and \${Cen_fam_age15} years" 16 "\${R_Cen_fam_name16} and \${Cen_fam_age16} years" 17 "\${R_Cen_fam_name17} and \${Cen_fam_age17} years" 18 "\${R_Cen_fam_name18} and \${Cen_fam_age18} years" 19 "\${R_Cen_fam_name19} and \${Cen_fam_age19} years" 20 "\${R_Cen_fam_name20} and \${Cen_fam_age20} years" 21 "\${N_fam_name1} and \${N_fam_age1} years" 22 "\${N_fam_name2} and \${N_fam_age2} years" 23 "\${N_fam_name3} and \${N_fam_age3} years" 24 "\${N_fam_name4} and \${N_fam_age4} years" 25 "\${N_fam_name5} and \${N_fam_age5} years" 26 "\${N_fam_name6} and \${N_fam_age6} years" 27 "\${N_fam_name7} and \${N_fam_age7} years" 28 "\${N_fam_name8} and \${N_fam_age8} years" 29 "\${N_fam_name9} and \${N_fam_age9} years" 30 "\${N_fam_name10} and \${N_fam_age10} years" 31 "\${N_fam_name11} and \${N_fam_age11} years" 32 "\${N_fam_name12} and \${N_fam_age12} years" 33 "\${N_fam_name13} and \${N_fam_age13} years" 34 "\${N_fam_name14} and \${N_fam_age14} years" 35 "\${N_fam_name15} and \${N_fam_age15} years" 36 "\${N_fam_name16} and \${N_fam_age16} years" 37 "\${N_fam_name17} and \${N_fam_age17} years" 38 "\${N_fam_name18} and \${N_fam_age18} years" 39 "\${N_fam_name19} and \${N_fam_age19} years" 40 "\${N_fam_name20} and \${N_fam_age20} years" -77 "Other"
	label values n_u5father_name n_u5father_name

	label variable n_u5father_name_oth "Please specify other"
	note n_u5father_name_oth: "Please specify other"

	label variable n_school "A9) Has \${namefromearlier} ever attended school?"
	note n_school: "A9) Has \${namefromearlier} ever attended school?"
	label define n_school 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_school n_school

	label variable n_school_level "A9.1) What is the highest level of schooling that \${namefromearlier} has comple"
	note n_school_level: "A9.1) What is the highest level of schooling that \${namefromearlier} has completed?"
	label define n_school_level 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
	label values n_school_level n_school_level

	label variable n_school_current "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
	note n_school_current: "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
	label define n_school_current 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_school_current n_school_current

	label variable n_read_write "A9.3) Can \${namefromearlier} read or write?"
	note n_read_write: "A9.3) Can \${namefromearlier} read or write?"
	label define n_read_write 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer"
	label values n_read_write n_read_write






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Endline Census Re-visit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop_corrections.csv
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
