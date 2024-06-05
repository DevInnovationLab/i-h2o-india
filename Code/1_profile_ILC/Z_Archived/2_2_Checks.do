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


//6. Checking reason for primary and secondary water source not being JJM but people drinking JJM water
use "${DataPre}1_1_Census_cleaned.dta", clear
gen date= dofc(R_Cen_starttime)
format date %td

tab R_Cen_village_name if R_Cen_a12_water_source_prim!=1 & R_Cen_a18_jjm_drinking==1 & R_Cen_a13_water_source_sec_1!=1
keep if (R_Cen_a12_water_source_prim!=1 & R_Cen_a18_jjm_drinking==1 & R_Cen_a13_water_source_sec_1!=1) | (R_Cen_a12_water_source_prim == 2 & R_Cen_a18_jjm_drinking==0) | (R_Cen_a12_water_source_prim == 3 & R_Cen_a18_jjm_drinking==1)
keep unique_id date R_Cen_village_str R_Cen_enum_name R_Cen_a12_water_source_prim R_Cen_a18_jjm_drinking R_Cen_a13_water_sec_yn R_Cen_a13_water_source_sec

export excel using "${pilot}Data_quality.xlsx", sheet("JJM_drink_noprimsec") firstrow(var) sheetreplace


	//6a. 
	use "${DataPre}1_1_Census_cleaned.dta", clear
	count if R_Cen_a12_water_source_prim == 3 & R_Cen_a18_jjm_drinking==1
	tab R_Cen_village_name if R_Cen_a12_water_source_prim == 3 & R_Cen_a18_jjm_drinking==1
	
	count if R_Cen_a12_water_source_prim == 2 & R_Cen_a18_jjm_drinking==0
	tab R_Cen_village_name if R_Cen_a12_water_source_prim == 2 & R_Cen_a18_jjm_drinking==0


//7. Checking if "Other" primary water source can be clubbed in one of the existing categories 
use "${DataPre}1_1_Census_cleaned.dta", clear
gen date= dofc(R_Cen_starttime)
format date %td
tab R_Cen_a12_prim_source_oth if R_Cen_a12_water_source_prim== -77 
keep if R_Cen_a12_water_source_prim== -77 
keep unique_id date R_Cen_village_str R_Cen_enum_name R_Cen_a12_water_source_prim R_Cen_a12_prim_source_oth 
export excel using "${pilot}Data_quality.xlsx", sheet("Other prim source") firstrow(var) sheetreplace

/*
//8. Additional cases to check for data quality
use "${DataPre}1_1_Census_cleaned.dta", clear
gen date= dofc(R_Cen_starttime)
format date %td
keep if unique_id == "50201115019" | unique_id == "50201109027" | /// 
unique_id == "50501109021" | /// 
unique_id == "50501109022" | unique_id == "50501115003" | unique_id == "40202111022" | unique_id == "40202113033"| ///
unique_id == "40202113049"
tostring R_Cen_village_name, gen(R_Cen_village_name_str)
keep unique_id date R_Cen_village_str R_Cen_enum_name R_Cen_a12_water_source_prim R_Cen_a12_prim_source_oth R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark 



export excel using "${pilot}Data_quality.xlsx", sheet("Other cases") firstrow(var) sheetreplace

*/



//generating preload for data quality 
use "${DataPre}1_1_Census_cleaned.dta", clear
keep if  R_Cen_village_name==30601 | R_Cen_village_name==30701 

keep if R_Cen_a12_water_source_prim == -77 | (R_Cen_a12_water_source_prim == 2 & R_Cen_a18_jjm_drinking==0) | (R_Cen_a12_water_source_prim ==3 & R_Cen_a18_jjm_drinking==1) | (R_Cen_a12_water_source_prim != 1 & R_Cen_a18_jjm_drinking==1 & R_Cen_a13_water_source_sec_1!=1) 
*tostring R_Cen_village_name, gen(R_Cen_village_name_str)


//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}

replace R_Cen_village_str= "Haathikambha" if R_Cen_village_str==""

keep unique_id R_Cen_village_str R_Cen_enum_name_label R_Cen_landmark R_Cen_address R_Cen_saahi_name R_Cen_a1_resp_name R_Cen_a10_hhhead R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_a11_oldmale_name R_Cen_hamlet_name R_Cen_a12_water_source_prim R_Cen_a12_prim_source_oth R_Cen_a13_water_sec_yn R_Cen_a13_water_source_sec_1 R_Cen_a13_water_source_sec_2 R_Cen_a13_water_source_sec_3 R_Cen_a13_water_source_sec_4 R_Cen_a13_water_source_sec_5 R_Cen_a13_water_source_sec_6 R_Cen_a13_water_source_sec_7 R_Cen_a13_water_source_sec_8 R_Cen_a13_water_source_sec__77 R_Cen_a13_water_sec_oth R_Cen_a18_jjm_drinking


export excel using "${DataPre}DataQuality_preload_17Nov23.xlsx",  firstrow(var) sheetreplace
    
	label variable R_Cen_a13_water_source_sec_1 "Sec-source-JJM tap"
	label variable R_Cen_a13_water_source_sec_2 "Sec-source-Govt. provided community standpipe"
	label variable R_Cen_a13_water_source_sec_3 "Sec-source-GP/Other community standpipe"
	label variable R_Cen_a13_water_source_sec_4 "Sec-source-Manual handpump"
	label variable R_Cen_a13_water_source_sec_5 "Sec-source-Covered dug well"
	label variable R_Cen_a13_water_source_sec_6 "Sec-source-Uncovered dug well"
	label variable R_Cen_a13_water_source_sec_7 "Sec-source-Surface water"
	label variable R_Cen_a13_water_source_sec_8 "Sec-source-Private surface well"
	label variable R_Cen_a13_water_source_sec__77 "Sec-source-Other"
	label var R_Cen_village_str "Village"
	label var R_Cen_a12_water_source_prim "Primary drinking water source"
	label var R_Cen_a12_prim_source_oth "Other prim source-name"
	label var R_Cen_landmark "Landmark"
	label var R_Cen_enum_name_label "Enumerator name"
	label var R_Cen_address "Address"
	label var R_Cen_saahi_name "Saahi"
	label var R_Cen_a11_oldmale_name "Old male name"
	label var R_Cen_a10_hhhead "Household head name"
	label var R_Cen_a1_resp_name "Respondent name"
	label var R_Cen_hamlet_name "Hamlet name"
	label var R_Cen_a39_phone_name_1 "Phone no. 1 name"
	label var R_Cen_a39_phone_name_2 "Phone no. 2 name"
	label var R_Cen_a13_water_sec_yn "Secondary source_yes_no"
	label var R_Cen_a13_water_sec_oth "Other sec source-name" 
	label var R_Cen_a18_jjm_drinking "Drink JJM yes_no"
	
export excel using "${DataPre}DataQuality_preload_labelled_17Nov23.xlsx" ,  firstrow(varlabels) sheetreplace


// Adding enumerator names to Archi's Backcheck allotment sheet
clear all
import excel "${pilot}/BC_IDs for allotment.xls", sheet("Sheet1") firstrow allstring
drop if R_Cen_village_name_str==""
tempfile BC_IDs
save `BC_IDs', replace

use "${DataPre}1_1_Census_cleaned.dta"
keep unique_id R_Cen_enum_name R_Cen_enum_code
merge 1:1 unique_id using `BC_IDs'
keep if _merge==3

export excel using "${pilot}/BC_IDs for allotment.xls", firstrow(var) cell(A1) sheetreplace
