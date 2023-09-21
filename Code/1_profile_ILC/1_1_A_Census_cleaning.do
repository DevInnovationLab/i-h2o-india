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

* Test sample
drop if key=="uuid:fc38045e-4420-4a36-989f-8125d8f594ce"
drop if key=="uuid:1fec8e62-6c12-4aa8-9dfc-d661c9022ef5"
drop if key=="uuid:5f1075bd-086a-4b67-a1fd-1990cba47fc6"

drop fam_name*
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/
* rename a5_hhmember_relation_other_1  a5_hhm_rel_other_1 
* rename a12_water_source_prim_other  a12_ws_prim_other 
* rename water_prim_source_kids_other wp_source_kids_other
rename (consented1hh_member_names1a6_age consented1a36_caste consented1a37_castename consented1a38_tribename consented1hh_member_names2a6_age consented1hh_member_names3a6_age consented1hh_member_names4a6_age consented1water_treatment1water_) (c1hh_member_names1a6_age c1a36_caste c1a37_castename c1a38_tribename c1hh_member_names2a6_age c1hh_member_names3a6_age c1hh_member_names4a6_age c1water_treatment1water_)
rename consented1a19_reason_nodrink c1a19_reason_nodrink

foreach x of var * { 
	rename `x' R_Cen_`x' 
} 

* Variable cuts across will not have prefix
rename R_Cen_unique_id unique_id

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
* Consider other variables to include
capture export excel unique_id using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Census") firstrow(var) cell(A1) sheetreplace
drop unique_id_Unique

* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force

* Change as we finalzie the treatment village
gen     Census=1
gen     Treatment=runiform(0,1)
recode Treatment 0/0.2=0 0.2/1=1
* replace Treatment=0 if R_Cen_village_name==11211 
* replace Treatment=1 if R_Cen_village_name==11211
fre R_Cen_village_name if Treatment==.
save "${DataPre}1_1_Census_cleaned.dta", replace
savesome using "${DataPre}1_1_Census_cleaned_consented.dta" if R_Cen_consent==1, replace

** Drop ID information

save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
