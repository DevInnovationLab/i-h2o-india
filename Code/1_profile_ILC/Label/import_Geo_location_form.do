* import_Geo_location_form.do
*
* 	Imports and aggregates "Geo location form" (ID: Geo_location_form) data.
*
*	Inputs:  "Geo location form_WIDE.csv"
*	Outputs: "Geo location form.dta"
*
*	Output by SurveyCTO October 1, 2023 7:17 AM.

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
local csvfile "Geo location form_WIDE.csv"
local dtafile "Geo location form.dta"
local corrfile "Geo location form_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum other_specify awc_name awc_phone_num asha_name asha_phone_num anm_name anm_phone_num image_tank comment instanceid instancename"
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
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
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
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
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


	label variable supervisor "Please choose your name."
	note supervisor: "Please choose your name."
	label define supervisor 1 "Susanta Kumar Mahanta" 2 "Rajib Panda" 3 "Binod Kumar Mohanandia" 4 "Sanjay Naik" 5 "Manas Ranjan Parida"
	label values supervisor supervisor

	label variable block_name "Block Name"
	note block_name: "Block Name"
	label define block_name 1 "Gudari" 2 "Gunupur" 3 "Kolnara" 4 "Padmapur" 5 "Rayagada" 888 "Pilot"
	label values block_name block_name

	label variable gp_name "Gram Panchayat Name"
	note gp_name: "Gram Panchayat Name"
	label define gp_name 101 "Asada" 102 "Khariguda" 201 "G Gurumunda" 202 "Jaltar" 301 "Badaalubadi" 302 "BK Padar" 303 "Dunduli" 305 "Kolnara" 306 "Mukundpur" 401 "Derigam" 402 "Gudiabandh" 403 "Kamapadara" 404 "Naira" 501 "Dangalodi" 502 "Halua" 503 "Karlakana" 504 "Kothapeta" 505 "Tadma" 888 "Pilot"
	label values gp_name gp_name

	label variable village_name "Village Name"
	note village_name: "Village Name"
	label define village_name 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30101 "Badaalubadi" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30602 "Mukundpur" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 88888 "Pilot"
	label values village_name village_name

	label variable landmark "List of landmarks"
	note landmark: "List of landmarks"
	label define landmark 1 "Tank" 2 "Anganwadi center" 3 "School" 4 "Solar Tank" 5 "Panchayat office" 6 "Health center" 7 "Hospital" 8 "Temple" -77 "Other"
	label values landmark landmark

	label variable other_specify "If other, specify :"
	note other_specify: "If other, specify :"

	label variable awc_connect_basudha "A1.1) Is the AWC connected to the basudha tank?"
	note awc_connect_basudha: "A1.1) Is the AWC connected to the basudha tank?"
	label define awc_connect_basudha 1 "Yes" 0 "No" -99 "Don't know"
	label values awc_connect_basudha awc_connect_basudha

	label variable awc_name "A2.1) Name of the AWC worker"
	note awc_name: "A2.1) Name of the AWC worker"

	label variable awc_phone_num "A2.2) Phone number of AWC:"
	note awc_phone_num: "A2.2) Phone number of AWC:"

	label variable asha_name "A2.3) Name of the ASHA worker"
	note asha_name: "A2.3) Name of the ASHA worker"

	label variable asha_phone_num "A2.4) Phone number of ASHA"
	note asha_phone_num: "A2.4) Phone number of ASHA"

	label variable anm_name "A2.5) Name of the ANM (Auxiliary Nurse Midwife)"
	note anm_name: "A2.5) Name of the ANM (Auxiliary Nurse Midwife)"

	label variable anm_phone_num "A2.6) Phone number of ANM"
	note anm_phone_num: "A2.6) Phone number of ANM"

	label variable school_connect_basudha "A2.7) Is the school connected to the basudha tank?"
	note school_connect_basudha: "A2.7) Is the school connected to the basudha tank?"
	label define school_connect_basudha 1 "Yes" 0 "No" -99 "Don't know"
	label values school_connect_basudha school_connect_basudha

	label variable gps_manuallatitude "A2.8) Please record the GPS location of the landmark (latitude)"
	note gps_manuallatitude: "A2.8) Please record the GPS location of the landmark (latitude)"

	label variable gps_manuallongitude "A2.8) Please record the GPS location of the landmark (longitude)"
	note gps_manuallongitude: "A2.8) Please record the GPS location of the landmark (longitude)"

	label variable gps_manualaltitude "A2.8) Please record the GPS location of the landmark (altitude)"
	note gps_manualaltitude: "A2.8) Please record the GPS location of the landmark (altitude)"

	label variable gps_manualaccuracy "A2.8) Please record the GPS location of the landmark (accuracy)"
	note gps_manualaccuracy: "A2.8) Please record the GPS location of the landmark (accuracy)"

	label variable image_tank "Please click the image of the landmark"
	note image_tank: "Please click the image of the landmark"

	label variable a40_gps_handlongitude "Please put the longitude of the location"
	note a40_gps_handlongitude: "Please put the longitude of the location"

	label variable a40_gps_handlatitude "Please put the latitude of the location"
	note a40_gps_handlatitude: "Please put the latitude of the location"

	label variable comment "Please add comments, if any"
	note comment: "Please add comments, if any"






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
*   Corrections file path and filename:  Geo location form_corrections.csv
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
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
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
