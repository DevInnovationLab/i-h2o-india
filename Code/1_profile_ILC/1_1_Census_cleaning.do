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
	
* Seed
clear all               
set seed 758235657 // Just in case

use "${DataRaw}1_1_Census.dta", clear
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/
rename (consented1hh_member_names1hh_mem consented1hh_member_names2hh_mem consented1hh_member_names3hh_mem) (consented1hh_member_names1 consented1hh_member_names2 consented1hh_member_names3)
foreach x of var * { 
	rename `x' R_Cen_`x' 
} 

* Variable cuts across will not have prefix
rename  R_Cen_unique_id unique_id
* replace unique_id = subinstr(unique_id, "-", "",.)
destring unique_id, replace ignore(-)
format   unique_id %10.0fc

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}
capture export excel unique_id using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Census") firstrow(var) cell(A1) sheetreplace
drop unique_id_Unique

* Make sure that unique ID is consective (no jumping)

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force


* Change as we finalzie the treatment village
gen Census=1
gen     Treatment=.
replace Treatment=0 if R_Cen_village_name==11231 | R_Cen_village_name==11111 | R_Cen_village_name==11241
replace Treatment=1 if R_Cen_village_name==11321 | R_Cen_village_name==11221 | R_Cen_village_name==11311
fre R_Cen_village_name if Treatment==.
save "${DataDeid}1_1_Census_cleaned.dta", replace

gen Concat_info=R_Cen_a1_resp_name
export excel unique_id Concat_info using "${pilot}Followup_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)
