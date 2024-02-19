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

*replace R_FU1_r_cen_village_name=50601 if R_Cen_village_name==30101
*gen     C_Census=1
*merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
*          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
*recode Merge_C_F 1=0 3=1

*keep if  R_Cen_village_name==30601 | R_Cen_village_name==30701 

*label var C_Screened  "Screened"
*	label variable R_Cen_consent "Census consent"
	label variable R_FU1_consent "HH survey consent"
*	label var Non_R_Cen_consent "Refused"
*	label var C_HH_not_available "Respondent not available"

*end

/*

//Remove HHIDs with differences between census and HH survey
clear
import excel "${DataPre}Backcheck_preload_17Nov23.xlsx", firstrow
tempfile completed_ids
save `completed_ids', replace

start_from_clean_file_Population
merge 1:1 unique_id using `completed_ids', force
drop if _merge==3
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

*/
clonevar unique_id = unique_id_num
format  unique_id %15.0gc
***********************************************************************
* Step 2: Selecting households for BC survey based on random numbers *
***********************************************************************

//Conduct stratification
keep R_FU1_r_cen_village_name_str unique_id  R_FU1_enum_name  



egen strata= group(R_FU1_enum_name) 
*egen strata1=group(R_Cen_enum_name) if Merge_C_F==1  //only HH survey obs
*egen strata2=group(R_Cen_enum_name) if Merge_C_F==0  //census obs excluding HH survey


//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_FU1_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.25*total
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

/*
//also adding IDs that need to be checked for data quality
start_from_clean_file_Population
*keep if unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"
gen data_quality_check=1
tempfile data_quality_ID
save `data_quality_ID', replace
*/
***********************************************************************
* Step 3: Generating preload list for BC survey *
***********************************************************************
use `selected_for_BC', clear
*append using `data_quality_ID'
tempfile working
save `working', replace

use "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
merge 1:1 unique_id using `working', gen(merge_BC_select)
keep if merge_BC_select==3

//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}


decode R_Cen_village_name, gen(R_Cen_village_name_str)
replace R_Cen_village_name_str= "Haathikambha" if R_Cen_village_name_str==""

sort R_Cen_village_name_str R_Cen_enum_name_label
export excel unique_id R_Cen_village_name_str R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2  R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a12_water_source_prim         using "${DataPre}Backcheck_FU1_preload_19Feb24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



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
	label variable R_Cen_village_name_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	


sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   using "${pilot}Supervisor_BC_FU1_Tracker_checking.xlsx" if selected==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt



sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark using "${pilot}Supervisor_BC_FU1_Tracker_checking_repl.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   using "${pilot}Supervisor_FU1_data quality_Tracker_25 Oct 2023.xlsx" if data_quality_check==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

