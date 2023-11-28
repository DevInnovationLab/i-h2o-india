
* import_ILC_Data_Quality_survey.do
*
* 	Imports and aggregates "ILC_Data_Quality_survey" (ID: ILC_Data_Quality_survey) data.
*
*	Inputs:  "ILC_Data_Quality_survey_WIDE.csv"
*	Outputs: "ILC_Data_Quality_survey.dta"
*
*	Output by SurveyCTO November 8, 2023 8:24 AM.

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
local csvfile "ILC_Data_Quality_survey_WIDE.csv"
local dtafile "ILC_Data_Quality_survey.dta"
local corrfile "ILC_Data_Quality_survey_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum unique_id_3_digit unique_id r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1"
local text_fields2 "r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_village_str r_cen_hamlet_name r_cen_a11_oldmale_name info_update a7_resp_name a10_hhhead a11_oldmale_name a12_prim_source_oth primary_water_label"
local text_fields3 "a13_water_source_sec a13_water_sec_oth a41_end_comments instanceid"
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


	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Sanjay Naik" 102 "Susanta Kumar Mahanta" 103 "Rajib Panda" 104 "Santosh Kumar Das" 105 "Bibhar Pankaj" 106 "Madhusmita Samal" 107 "Rekha Behera" 108 "Sanjukta Chichuan" 109 "Swagatika Behera" 110 "Sarita Bhatra" 111 "Abhishek Rath" 112 "Binod Kumar Mohanandia" 113 "Mangulu Bagh" 114 "Padman Bhatra" 115 "Kuna Charan Naik" 116 "Sushil Kumar Pani" 117 "Jitendra Bagh" 118 "Rajeswar Digal" 119 "Pramodini Gahir" 120 "Manas Ranjan Parida" 121 "Ishadatta Pani"
	label values enum_name enum_name

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
	note noteconf1: "Please confirm the households that you are visiting correspond to the following information. Village: \${R_Cen_village_str} Hamlet: \${R_Cen_hamlet_name} Household head name: \${R_Cen_a10_hhhead} Respondent name from the previous round: \${R_Cen_a1_resp_name} Any male household head (if any): \${R_Cen_a11_oldmale_name} Address: \${R_Cen_address} Landmark: \${R_Cen_landmark} Saahi: \${R_Cen_saahi_name} Phone 1: \${R_Cen_a39_phone_name_1} (\${R_Cen_a39_phone_num_1}) Phone 2: \${R_Cen_a39_phone_name_2} (\${R_Cen_a39_phone_num_2})"
	label define noteconf1 1 "I am visiting the correct household and the information is correct" 2 "I am visiting the correct household but the information needs to be updated" 3 "The household I am visiting does not corresponds to the confirmation info."
	label values noteconf1 noteconf1

	label variable info_update "Please describe the information need to be updated here."
	note info_update: "Please describe the information need to be updated here."

	label variable a7_resp_name "A7) What is your name?"
	note a7_resp_name: "A7) What is your name?"

	label variable a10_hhhead "A10) What is the name of the head of household? (Household head can be either ma"
	note a10_hhhead: "A10) What is the name of the head of household? (Household head can be either male or female)"

	label variable a11_oldmale "A11) Is there an older male in the household?"
	note a11_oldmale: "A11) Is there an older male in the household?"
	label define a11_oldmale 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a11_oldmale a11_oldmale

	label variable a11_oldmale_name "A11.1) What is their name?"
	note a11_oldmale_name: "A11.1) What is their name?"

	label variable a12_water_source_prim "A12) In the past month, which water source did your household primarily use for "
	note a12_water_source_prim: "A12) In the past month, which water source did your household primarily use for drinking?"
	label define a12_water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation c" 8 "Private Surface well" -77 "Other"
	label values a12_water_source_prim a12_water_source_prim

	label variable a12_prim_source_oth "A12.1) If Other, please specify:"
	note a12_prim_source_oth: "A12.1) If Other, please specify:"

	label variable a13_water_sec_yn "A13) In the past month, did your household use any sources of water for drinking"
	note a13_water_sec_yn: "A13) In the past month, did your household use any sources of water for drinking purposes besides the one you already mentioned?"
	label define a13_water_sec_yn 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
	label values a13_water_sec_yn a13_water_sec_yn

	label variable a13_water_source_sec "A13.1) In the past month, what other water sources have you used for drinking?"
	note a13_water_source_sec: "A13.1) In the past month, what other water sources have you used for drinking?"

	label variable a13_water_sec_oth "A13.2) If Other, please specify:"
	note a13_water_sec_oth: "A13.2) If Other, please specify:"

	label variable a18_jjm_drinking "A18) Do you use the government provided household tap for drinking?"
	note a18_jjm_drinking: "A18) Do you use the government provided household tap for drinking?"
	label define a18_jjm_drinking 0 "No" 1 "Yes" 2 "Do not have a government tap connection"
	label values a18_jjm_drinking a18_jjm_drinking

	label variable change_primary_source "A26.1) Has there been a change in your primary drinking water source in the last"
	note change_primary_source: "A26.1) Has there been a change in your primary drinking water source in the last one month?"
	label define change_primary_source 1 "Yes" 0 "No"
	label values change_primary_source change_primary_source

	label variable a41_end_comments "A41) Please add any additional comments about this survey."
	note a41_end_comments: "A41) Please add any additional comments about this survey."






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
*   Corrections file path and filename:  ILC_Data_Quality_survey_corrections.csv
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
