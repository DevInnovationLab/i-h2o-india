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

/*------ In this do file: 
	(1) This do file exports the preload data for backcheck survey 
	(2) Also exports tracking sheets for supervisors for backchecks ------ */

*------------------------------------------------------------------- -------------------------------------------------------------------*


***************************************************
* Step 1: Cleaning  *
***************************************************
*cap program drop start_from_clean_file_Population
*program define   start_from_clean_file_Population
  * Open clean file
use  "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent == 1

	label variable R_FU1_consent "HH survey consent"
clonevar unique_id = unique_id_num
format  unique_id %15.0gc
***********************************************************************
* Step 2: Selecting households for BC survey based on random numbers *
***********************************************************************

//Conduct stratification
keep R_FU1_r_cen_village_name_str unique_id  R_FU1_enum_name  



egen strata= group(R_FU1_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_FU1_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata  unique_id
set seed 75824
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata strata_random_hhsurvey
bys R_FU1_enum_name: generate selected_hhsurvey = _n <= ten_perc_per_enum 

* To add a unique Id where we found an issue in HFC, to do a backcheck for this
replace selected_hhsurvey = 1 if unique_id == 50301117030


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
tab R_FU1_enum_name selected


//generating replacements for those selected for BC survey
gsort  strata -strata_random_hhsurvey 
bys R_FU1_enum_name: generate selected_hhsurvey_repl = _n <= ten_perc_per_enum  


gen selected_replacementBC= 1 if selected_hhsurvey_repl==1 

keep if selected==1 | selected_replacementBC==1

tempfile selected_for_BC
save `selected_for_BC', replace
save "${DataPr}selected_for_BC.dta", replace


***********************************************************************
* Step 3: Generating preload list for BC survey *
***********************************************************************
use `selected_for_BC', clear
*append using `data_quality_ID'
tempfile working
save `working', replace

use "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
clonevar unique_id = unique_id_num
format  unique_id %15.0gc
merge 1:1 unique_id using "${DataPr}selected_for_BC.dta", gen(merge_BC_select)
keep if merge_BC_select==3

//Cleaning the name of the household head

sort R_FU1_r_cen_village_name_str R_FU1_enum_name_label 
export excel unique_id R_FU1_r_cen_village_name_str R_FU1_enum_name R_FU1_enum_name_label R_FU1_r_cen_a10_hhhead R_FU1_r_cen_a1_resp_name R_FU1_r_cen_a39_phone_name_1 R_FU1_r_cen_a39_phone_num_1 R_FU1_r_cen_a39_phone_name_2 R_FU1_r_cen_a39_phone_num_2 R_FU1_r_cen_landmark R_FU1_r_cen_address R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_a11_oldmale_name R_FU1_r_cen_fam_name1 R_FU1_r_cen_fam_name2 R_FU1_r_cen_fam_name3 R_FU1_r_cen_fam_name4 R_FU1_r_cen_fam_name5 R_FU1_r_cen_fam_name6 R_FU1_r_cen_fam_name7 R_FU1_r_cen_fam_name8 R_FU1_r_cen_fam_name9 R_FU1_r_cen_fam_name10 R_FU1_r_cen_fam_name11 R_FU1_r_cen_fam_name12 R_FU1_r_cen_fam_name13 R_FU1_r_cen_fam_name14 R_FU1_r_cen_fam_name15 R_FU1_r_cen_fam_name16 R_FU1_r_cen_fam_name17 R_FU1_r_cen_fam_name18 R_FU1_r_cen_fam_name19 R_FU1_r_cen_fam_name20 R_FU1_water_source_prim using "${DataPre}Backcheck_FU1_preload_20Feb24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



***********************************************************************
* Step 4: Generating tracking list for supervisors for BC survey *
***********************************************************************

tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3


//Changing labels 
	label variable ID "Unique ID"
	label variable R_FU1_r_cen_village_name_str "Village Name"
	label variable R_FU1_r_cen_hamlet_name "Hamlet name"
	label variable R_FU1_r_cen_saahi_name"Saahi name"
	label variable R_FU1_r_cen_landmark "Landmark"
	label variable R_FU1_enum_name "Enumerator name"
	


sort R_FU1_r_cen_village_name_str R_FU1_enum_name  
export excel ID R_FU1_enum_name R_FU1_r_cen_village_name_str R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_landmark   using "${pilot}Supervisor_BC_FU1_Tracker_checking.xlsx" if selected==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


sort R_FU1_r_cen_village_name_str R_FU1_enum_name 
export excel ID R_FU1_enum_name R_FU1_r_cen_village_name_str R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_landmark using "${pilot}Supervisor_BC_FU1_Tracker_checking_repl.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 
