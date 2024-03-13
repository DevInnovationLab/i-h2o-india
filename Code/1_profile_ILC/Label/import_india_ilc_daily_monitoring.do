* import_india_ilc_daily_monitoring.do
*
* 	Imports and aggregates "Daily Chlorine Monitoring Form" (ID: india_ilc_daily_monitoring) data.
*
*	Inputs:  "C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form_WIDE.csv"
*	Outputs: "C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form.dta"
*
*	Output by SurveyCTO March 6, 2024 6:31 AM.

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
local csvfile "C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form_WIDE.csv"
local dtafile "C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form.dta"
local corrfile "C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum hamlet_name valve_closed image_chlorine_doser nearest_tap_comments stored_water_comments farthest_tap_comments far_stored_water_comments overall_comments"
local text_fields2 "ilc_device_issue_comments ilc_device_image instanceid instancename"
local date_fields1 ""
local datetime_fields1 "submissiondate starttime endtime valve_open_time valve_closed_time"

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


	label variable district_name "Enumerator to fill up: District Name"
	note district_name: "Enumerator to fill up: District Name"
	label define district_name 11 "Rayagada"
	label values district_name district_name

	label variable block_name "Enumerator to fill up: Block Name"
	note block_name: "Enumerator to fill up: Block Name"
	label define block_name 1 "Gudari" 2 "Gunupur" 3 "Kolnara" 4 "Padmapur" 5 "Rayagada" 888 "Pilot"
	label values block_name block_name

	label variable gp_name "Enumerator to fill up: Gram Panchayat Name"
	note gp_name: "Enumerator to fill up: Gram Panchayat Name"
	label define gp_name 101 "Asada" 102 "Khariguda" 201 "G Gurumunda" 202 "Jaltar" 301 "Badaalubadi" 302 "BK Padar" 303 "Dunduli" 305 "Kolnara" 306 "Mukundpur" 307 "Dumbiriguda" 401 "Derigam" 402 "Gudiabandh" 403 "Kamapadara" 404 "Naira" 501 "Dangalodi" 502 "Halua" 503 "Karlakana" 504 "Kothapeta" 505 "Tadma" 888 "Pilot"
	label values gp_name gp_name

	label variable village_name "Enumerator to fill up: Village Name"
	note village_name: "Enumerator to fill up: Village Name"
	label define village_name 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30101 "Badaalubadi" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30601 "Hatikhamba" 30602 "Mukundpur" 30701 "Gopi Kankubadi" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 88888 "Pilot"
	label values village_name village_name

	label variable hamlet_name "Enumerator to fill up: Hamlet Name where ILC device is installed"
	note hamlet_name: "Enumerator to fill up: Hamlet Name where ILC device is installed"

	label variable enum_name "Enumerator to fill up: Enumerator Name"
	note enum_name: "Enumerator to fill up: Enumerator Name"
	label define enum_name 101 "Sanjay Naik" 103 "Rajib Panda" 105 "Bibhar Pankaj" 119 "Pramodini Gahir" 121 "Ishadatta Pani" 110 "Sarita Bhatra" 122 "Hemant Bagh" 123 "Manas Ranjan"
	label values enum_name enum_name

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 103 "103" 105 "105" 119 "119" 121 "121" 110 "110" 122 "122" 123 "123"
	label values enum_code enum_code

	label variable valve_open "5.0)Was the pump operator able to turn the water flow on?"
	note valve_open: "5.0)Was the pump operator able to turn the water flow on?"
	label define valve_open 1 "Yes" 0 "No"
	label values valve_open valve_open

	label variable valve_closed "5.1)Please record the reason the pump operator was not able to turn the water fl"
	note valve_closed: "5.1)Please record the reason the pump operator was not able to turn the water flow on."

	label variable valve_open_time "5.2) Record the time when pump operator switches on the pump."
	note valve_open_time: "5.2) Record the time when pump operator switches on the pump."

	label variable image_chlorine_doser "5.3)Please take a photo of the chlorine tablet doser valves."
	note image_chlorine_doser: "5.3)Please take a photo of the chlorine tablet doser valves."

	label variable nearest_tap_sample "5.4)Are you able to collect a running water sample directly from the nearest tap"
	note nearest_tap_sample: "5.4)Are you able to collect a running water sample directly from the nearest tap connection?"
	label define nearest_tap_sample 1 "Yes" 0 "No"
	label values nearest_tap_sample nearest_tap_sample

	label variable nearest_tap_sample_r "5.5) Record the time stamp for the sample collection for running water collected"
	note nearest_tap_sample_r: "5.5) Record the time stamp for the sample collection for running water collected from the nearest tap"

	label variable first_nearest_tap_fc "5.7)Record the first FREE chlorine concentration."
	note first_nearest_tap_fc: "5.7)Record the first FREE chlorine concentration."

	label variable second_nearest_tap_fc "5.8)Record the second FREE chlorine concentration."
	note second_nearest_tap_fc: "5.8)Record the second FREE chlorine concentration."

	label variable first_nearest_tap_tc "5.9)Record the first TOTAL chlorine concentration."
	note first_nearest_tap_tc: "5.9)Record the first TOTAL chlorine concentration."

	label variable second_nearest_tap_tc "5.10Record the second TOTAL chlorine concentration."
	note second_nearest_tap_tc: "5.10Record the second TOTAL chlorine concentration."

	label variable colorimeter_running_nearest "5.11)Which colorimeter you used to do the previous tests?"
	note colorimeter_running_nearest: "5.11)Which colorimeter you used to do the previous tests?"
	label define colorimeter_running_nearest 1 "Low Range" 2 "Medium range" 3 "High range"
	label values colorimeter_running_nearest colorimeter_running_nearest

	label variable hr_nearest_tap_fc "5.12.1)Record the high range FREE chlorine concentration"
	note hr_nearest_tap_fc: "5.12.1)Record the high range FREE chlorine concentration"

	label variable hr_nearest_tap_tc "5.14)Record the first TOTAL chlorine concentration."
	note hr_nearest_tap_tc: "5.14)Record the first TOTAL chlorine concentration."

	label variable nearest_tap_comments "5.17)Do you have any comments regarding this test?"
	note nearest_tap_comments: "5.17)Do you have any comments regarding this test?"

	label variable error_nearesttap "5.17.a) Did you receive any error messages from the colorimeter when conducting "
	note error_nearesttap: "5.17.a) Did you receive any error messages from the colorimeter when conducting this testing?"
	label define error_nearesttap 1 "Yes" 0 "No"
	label values error_nearesttap error_nearesttap

	label variable error_num_nearesttap "5.17.b) What was the number of the error message?"
	note error_num_nearesttap: "5.17.b) What was the number of the error message?"

	label variable stored_water_sample "5.18)Are you able to collect a stored water sample?"
	note stored_water_sample: "5.18)Are you able to collect a stored water sample?"
	label define stored_water_sample 1 "Yes" 0 "No"
	label values stored_water_sample stored_water_sample

	label variable stored_water_tap "5.18. a) Is this stored water sample originally from a tap connection?"
	note stored_water_tap: "5.18. a) Is this stored water sample originally from a tap connection?"
	label define stored_water_tap 1 "Yes" 0 "No"
	label values stored_water_tap stored_water_tap

	label variable nearest_tap_sample_s "5.18.b) Record the time stamp for the sample collection for stored water collect"
	note nearest_tap_sample_s: "5.18.b) Record the time stamp for the sample collection for stored water collected from the nearest tap"

	label variable first_stored_water_fc "5.20)Record the first FREE chlorine concentration."
	note first_stored_water_fc: "5.20)Record the first FREE chlorine concentration."

	label variable second_stored_water_fc "5.21)Record the second FREE chlorine concentration."
	note second_stored_water_fc: "5.21)Record the second FREE chlorine concentration."

	label variable first_stored_water_tc "5.22)Record the first TOTAL chlorine concentration."
	note first_stored_water_tc: "5.22)Record the first TOTAL chlorine concentration."

	label variable second_stored_water_tc "5.23)Record the second TOTAL chlorine concentration."
	note second_stored_water_tc: "5.23)Record the second TOTAL chlorine concentration."

	label variable colorimeter_stored_nearest "5.24)Which colorimeter you used to do the previous tests?"
	note colorimeter_stored_nearest: "5.24)Which colorimeter you used to do the previous tests?"
	label define colorimeter_stored_nearest 1 "Low Range" 2 "Medium range" 3 "High range"
	label values colorimeter_stored_nearest colorimeter_stored_nearest

	label variable hr_neareststored_tap_fc "5.26)Record the high range FREE chlorine concentration"
	note hr_neareststored_tap_fc: "5.26)Record the high range FREE chlorine concentration"

	label variable hr_neareststored_tap_tc "5.28)Record the first TOTAL chlorine concentration."
	note hr_neareststored_tap_tc: "5.28)Record the first TOTAL chlorine concentration."

	label variable stored_water_comments "5.30)Do you have any comments regarding this test?"
	note stored_water_comments: "5.30)Do you have any comments regarding this test?"

	label variable error_neareststored "5.30.a) Did you receive any error messages from the colorimeter when conducting "
	note error_neareststored: "5.30.a) Did you receive any error messages from the colorimeter when conducting this testing?"
	label define error_neareststored 1 "Yes" 0 "No"
	label values error_neareststored error_neareststored

	label variable error_num_neareststored "5.31.b) What was the number of the error message?"
	note error_num_neareststored: "5.31.b) What was the number of the error message?"

	label variable farthest_tap_sample "5.37)Are you able to collect a water sample directly from the farthest tap conne"
	note farthest_tap_sample: "5.37)Are you able to collect a water sample directly from the farthest tap connection?"
	label define farthest_tap_sample 1 "Yes" 0 "No"
	label values farthest_tap_sample farthest_tap_sample

	label variable farthest_tap_sample_r "5.37.a) Record the time stamp for the sample collection for running water collec"
	note farthest_tap_sample_r: "5.37.a) Record the time stamp for the sample collection for running water collected from the farthest tap"

	label variable first_farthest_tap_fc "5.39)Record the first FREE chlorine concentration."
	note first_farthest_tap_fc: "5.39)Record the first FREE chlorine concentration."

	label variable second_farthest_tap_fc "5.40)Record the second FREE chlorine concentration."
	note second_farthest_tap_fc: "5.40)Record the second FREE chlorine concentration."

	label variable first_farthest_tap_tc "5.41)Record the the TOTAL chlorine concentration."
	note first_farthest_tap_tc: "5.41)Record the the TOTAL chlorine concentration."

	label variable second_farthest_tap_tc "5.42)Record the second TOTAL chlorine concentration."
	note second_farthest_tap_tc: "5.42)Record the second TOTAL chlorine concentration."

	label variable colorimeter_farthest_running "5.44)Which colorimeter you used to do the tests above?"
	note colorimeter_farthest_running: "5.44)Which colorimeter you used to do the tests above?"
	label define colorimeter_farthest_running 1 "Low Range" 2 "Medium range" 3 "High range"
	label values colorimeter_farthest_running colorimeter_farthest_running

	label variable hr_farthest_nearest_tap_fc "5.46)Record the high range FREE chlorine concentration"
	note hr_farthest_nearest_tap_fc: "5.46)Record the high range FREE chlorine concentration"

	label variable hr_farthest_tap_tc "5.48)Record the first TOTAL chlorine concentration."
	note hr_farthest_tap_tc: "5.48)Record the first TOTAL chlorine concentration."

	label variable farthest_tap_comments "5.50)Do you have any comments regarding this test?"
	note farthest_tap_comments: "5.50)Do you have any comments regarding this test?"

	label variable error_farthesttap "5.50.a) Did you receive any error messages from the colorimeter when conducting "
	note error_farthesttap: "5.50.a) Did you receive any error messages from the colorimeter when conducting this testing?"
	label define error_farthesttap 1 "Yes" 0 "No"
	label values error_farthesttap error_farthesttap

	label variable error_num_farthesttap "5.50.b) What was the number of the error message?"
	note error_num_farthesttap: "5.50.b) What was the number of the error message?"

	label variable farthest_stored_water_sample "5.51)Are you able to collect a stored water sample from the farthest tap connect"
	note farthest_stored_water_sample: "5.51)Are you able to collect a stored water sample from the farthest tap connection?"
	label define farthest_stored_water_sample 1 "Yes" 0 "No"
	label values farthest_stored_water_sample farthest_stored_water_sample

	label variable farthest_stored_water_tap "I5.52)s this stored water sample originally from a tap connection?"
	note farthest_stored_water_tap: "I5.52)s this stored water sample originally from a tap connection?"
	label define farthest_stored_water_tap 1 "Yes" 0 "No"
	label values farthest_stored_water_tap farthest_stored_water_tap

	label variable farthest_tap_sample_s "5.52.a) Record the time stamp for the sample collection for stored water collect"
	note farthest_tap_sample_s: "5.52.a) Record the time stamp for the sample collection for stored water collected from the farthest tap"

	label variable far_first_stored_water_fc "5.54)Record the first FREE chlorine concentration."
	note far_first_stored_water_fc: "5.54)Record the first FREE chlorine concentration."

	label variable far_second_stored_water_fc "5.55)Record the second FREE chlorine concentration."
	note far_second_stored_water_fc: "5.55)Record the second FREE chlorine concentration."

	label variable far_first_stored_water_tc "5.56)Record the first TOTAL chlorine concentration."
	note far_first_stored_water_tc: "5.56)Record the first TOTAL chlorine concentration."

	label variable far_second_stored_water_tc "5.57)Record the second TOTAL chlorine concentration."
	note far_second_stored_water_tc: "5.57)Record the second TOTAL chlorine concentration."

	label variable colorimeter_farhthest_stored "5.58)Which colorimeter you used to do the tests above?"
	note colorimeter_farhthest_stored: "5.58)Which colorimeter you used to do the tests above?"
	label define colorimeter_farhthest_stored 1 "Low Range" 2 "Medium range" 3 "High range"
	label values colorimeter_farhthest_stored colorimeter_farhthest_stored

	label variable hr_fartheststored_tap_fc "5.60)Record the high range FREE chlorine concentration"
	note hr_fartheststored_tap_fc: "5.60)Record the high range FREE chlorine concentration"

	label variable hr_fartheststored_tap_tc "5.62)Record the first TOTAL chlorine concentration."
	note hr_fartheststored_tap_tc: "5.62)Record the first TOTAL chlorine concentration."

	label variable far_stored_water_comments "5.64)Do you have any comments regarding this test?"
	note far_stored_water_comments: "5.64)Do you have any comments regarding this test?"

	label variable error_fartheststored "5.64.a) Did you receive any error messages from the colorimeter when conducting "
	note error_fartheststored: "5.64.a) Did you receive any error messages from the colorimeter when conducting this testing?"
	label define error_fartheststored 1 "Yes" 0 "No"
	label values error_fartheststored error_fartheststored

	label variable error_num_fartheststored "5.64.b) What was the number of the error message?"
	note error_num_fartheststored: "5.64.b) What was the number of the error message?"

	label variable gps_farlatitude "5.65)Please record the GPS location of the farthest household (latitude)"
	note gps_farlatitude: "5.65)Please record the GPS location of the farthest household (latitude)"

	label variable gps_farlongitude "5.65)Please record the GPS location of the farthest household (longitude)"
	note gps_farlongitude: "5.65)Please record the GPS location of the farthest household (longitude)"

	label variable gps_faraltitude "5.65)Please record the GPS location of the farthest household (altitude)"
	note gps_faraltitude: "5.65)Please record the GPS location of the farthest household (altitude)"

	label variable gps_faraccuracy "5.65)Please record the GPS location of the farthest household (accuracy)"
	note gps_faraccuracy: "5.65)Please record the GPS location of the farthest household (accuracy)"

	label variable a40_gps_handlongitude_farthest "5.66)Please put the longitude of the area where farthest household is"
	note a40_gps_handlongitude_farthest: "5.66)Please put the longitude of the area where farthest household is"

	label variable a40_gps_handlatitude_farthest "5.67)Please put the latitude of the area where the farthest household is"
	note a40_gps_handlatitude_farthest: "5.67)Please put the latitude of the area where the farthest household is"

	label variable valve_closed_time "5.69)Please record the time the pump operator has closed the outlet control valv"
	note valve_closed_time: "5.69)Please record the time the pump operator has closed the outlet control valve."

	label variable chlorine_high "5.70)Were any of the chlorine tests conducted today in high range? ( > 2.00 mg/L"
	note chlorine_high: "5.70)Were any of the chlorine tests conducted today in high range? ( > 2.00 mg/L)"
	label define chlorine_high 1 "Yes" 0 "No"
	label values chlorine_high chlorine_high

	label variable overall_comments "5.71)Please record any remaining comments related to the chlorine testing, ILC d"
	note overall_comments: "5.71)Please record any remaining comments related to the chlorine testing, ILC device, or site."

	label variable ilc_device_issue "5.71)Were there any issues related to the site's installation or chlorine testin"
	note ilc_device_issue: "5.71)Were there any issues related to the site's installation or chlorine testing?"
	label define ilc_device_issue 1 "Yes" 0 "No"
	label values ilc_device_issue ilc_device_issue

	label variable ilc_device_issue_comments "Please detail the issues here."
	note ilc_device_issue_comments: "Please detail the issues here."

	label variable ilc_device_image "5.72)If there are any issues related to this site's installation or chlorine tes"
	note ilc_device_image: "5.72)If there are any issues related to this site's installation or chlorine testing, please take a relevant photo of the issue here."






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
*   Corrections file path and filename:  C:/Users/Archi Gupta/Box/Data/1_raw/Daily Chlorine Monitoring Form_corrections.csv
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
