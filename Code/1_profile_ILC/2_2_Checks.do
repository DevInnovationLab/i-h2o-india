*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports.....
	
use "${DataPre}1_1_Census_cleaned.dta", clear

***Change date prior to running


/*--------------------------------------- Census quality check ---------------------------------------*/
/*
//1. Checking if respondent is the first member of the household in the roster 

count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1
br R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 R_Cen_enum_name if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1

	*checking if the respondent name appears among other names in the roster
	preserve
	keep if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1
	reshape long R_Cen_a3_hhmember_name_, i(unique_id_num) j(num)
	count if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	br R_Cen_a3_hhmember_name_ R_Cen_a1_resp_name if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	* This means that the respondent exists in the roster but is not the first respondent so those cases don't need any change
	gen no_change= 1 if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name

	keep if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	keep R_Cen_a1_resp_name no_change unique_id_num
	tempfile resp_names
	save `resp_names', replace

	restore 

	
	* Fuzzy matching and then Manually fixing the remaining cases
	use `resp_names', clear
	merge 1:1 unique_id_num using "${DataPre}1_1_Census_cleaned_consented.dta"
	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1
	matchit R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 
	br R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 similscore if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)
	replace R_Cen_a1_resp_name=R_Cen_a3_hhmember_name_1 if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)
	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1

	*/
//2. Checking if primary water source is not repeated as secondary water source
gen prim_sec_same=.
forvalues i = 1/8 {
	count if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
	replace prim_sec_same= 1  if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
}

preserve
keep if prim_sec_same== 1
keep unique_id R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* prim_sec_same
order unique_id R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* prim_sec_same
export excel using "${pilot}Data_quality.xlsx" if prim_sec_same==1, sheet("prim_sec_source") firstrow(var) sheetreplace
restore


//3. Checking if consent time is too low and for which enumerators
start_from_clean_file_Population
sum R_Cen_consent_duration
local consent_time `r(mean)'
keep if R_Cen_consent_duration< `consent_time'
keep unique_id R_Cen_village_str R_Cen_enum_name R_Cen_consent_duration
export excel using "${pilot}Data_quality.xlsx", sheet("Consent time low") firstrow(var) sheetreplace

/*
//4. Checking if date recorded is wrong
start_from_clean_file_Population

gen date= dofc(R_Cen_starttime)
format date %td

keep if month_day=="  2023"
keep unique_id R_Cen_village_str date R_Cen_enum_name

export excel using "${pilot}Data_quality.xlsx", sheet("Dates to check") firstrow(var) sheetreplace
*/

//4. Checking reason for unavailable respondents village-wise
start_from_clean_file_Population
gen date= dofc(R_Cen_starttime)
format date %td

keep if R_Cen_resp_available!=1
keep unique_id R_Cen_village_str R_Cen_resp_available R_Cen_enum_name R_Cen_a41_end_comments
sort R_Cen_resp_available
export excel using "${pilot}Data_quality.xlsx", sheet("Census unavailable") firstrow(var) sheetreplace


//5. Checking reason for refusals village-wise
start_from_clean_file_Population
gen date= dofc(R_Cen_starttime)
format date %td

keep if Non_R_Cen_consent==1
label define R_Cen_no_consent_reasonl 1 "Lack of time" 2 "Topic not interesting to me" -77 "Other"
destring R_Cen_no_consent_reason, replace
label values R_Cen_no_consent_reason R_Cen_no_consent_reasonl

keep unique_id date R_Cen_village_str R_Cen_no_consent_reason R_Cen_no_consent_comment R_Cen_enum_name
sort R_Cen_no_consent_reason
export excel using "${pilot}Data_quality.xlsx", sheet("Census refused") firstrow(var) sheetreplace



