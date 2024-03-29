* import_e.coli_results_follow_up_R2.do
*
* 	Imports and aggregates "E. Coli Results for Follow Up Round 2" (ID: e.coli_results_follow_up_R2) data.
*
*	Inputs:  "E. Coli Results for Follow Up Round 2_WIDE.csv"
*	Outputs: "E. Coli Results for Follow Up Round 2.dta"
*
*	Output by SurveyCTO March 28, 2024 7:58 AM.

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
local csvfile "E. Coli Results for Follow Up Round 2_WIDE.csv"
local dtafile "E. Coli Results for Follow Up Round 2.dta"
local corrfile "E. Coli Results for Follow Up Round 2_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum end_comments instanceid"
local date_fields1 "date_processed date_counted"
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


	label variable date_processed "Enter: Date Processed"
	note date_processed: "Enter: Date Processed"

	label variable who_processed "Select: Process reviewed by"
	note who_processed: "Select: Process reviewed by"
	label define who_processed 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values who_processed who_processed

	label variable date_counted "Enter: Date Counted"
	note date_counted: "Enter: Date Counted"

	label variable who_counted "Select: Tray Count Reviewed by"
	note who_counted: "Select: Tray Count Reviewed by"
	label define who_counted 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values who_counted who_counted

	label variable village "Select: Village"
	note village: "Select: Village"
	label define village 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30602 "Mukundpur" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 50601 "Badaalubadi" 30701 "Gopi Kankubadi"
	label values village village

	label variable unique_sample_id "Record the 5 digits"
	note unique_sample_id: "Record the 5 digits"

	label variable unique_sample_id_check "Record the 5 digits"
	note unique_sample_id_check: "Record the 5 digits"

	label variable unique_bag_id "Record the 5 digits"
	note unique_bag_id: "Record the 5 digits"

	label variable unique_bag_id_check "Record the 5 digits"
	note unique_bag_id_check: "Record the 5 digits"

	label variable process "Enter: Process by"
	note process: "Enter: Process by"
	label define process 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values process process

	label variable large_c_yellow "Enter: Large"
	note large_c_yellow: "Enter: Large"

	label variable small_c_yellow "Enter: Small"
	note small_c_yellow: "Enter: Small"

	label variable large_c_flurosce "Enter: Large"
	note large_c_flurosce: "Enter: Large"

	label variable small_c_flurosce "Enter: Small"
	note small_c_flurosce: "Enter: Small"

	label variable trays_counted "Enter: Trays counted by"
	note trays_counted: "Enter: Trays counted by"
	label define trays_counted 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values trays_counted trays_counted

	label variable reviewed_by "Enter: Reviewed by"
	note reviewed_by: "Enter: Reviewed by"
	label define reviewed_by 122 "Hemant Bagh" 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 110 "Sarita Bhatra" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 123 "Manas Ranjan"
	label values reviewed_by reviewed_by

	label variable end_comments "Please add any comments"
	note end_comments: "Please add any comments"






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
*   Corrections file path and filename:  E. Coli Results for Follow Up Round 2_corrections.csv
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
