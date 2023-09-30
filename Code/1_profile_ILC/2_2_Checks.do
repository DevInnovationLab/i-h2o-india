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
	
use "${DataFinal}Final_HH_Odisha.dta", clear
***Change date prior to running
local date "29Sept2023"

/*--------------------------------------- Census quality check ---------------------------------------*/

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

	
//3. Checking if primary water source is not repeated as secondary water source
gen prim_sec_same=.
forvalues i = 1/8 {
	count if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
	replace prim_sec_same= 1  if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
}

preserve
keep if prim_sec_same== 1
keep unique_id R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* prim_sec_same
order unique_id R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* prim_sec_same
export excel using "${pilot}Data_quality_`date'.xlsx" if prim_sec_same==1, sheet("prim_sec_source") firstrow(var) sheetreplace
restore




* High frequnecy chekc
