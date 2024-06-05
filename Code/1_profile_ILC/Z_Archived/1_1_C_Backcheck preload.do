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
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
replace R_Cen_village_name=50601 if R_Cen_village_name==30101
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

keep if  R_Cen_village_name==30601 | R_Cen_village_name==30701 

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
clear
import excel "${DataPre}Backcheck_preload_17Nov23.xlsx", firstrow
tempfile completed_ids
save `completed_ids', replace

start_from_clean_file_Population
merge 1:1 unique_id using `completed_ids', force
drop if _merge==3
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"


***********************************************************************
* Step 2: Selecting households for BC survey based on random numbers *
***********************************************************************

//Conduct stratification
keep R_Cen_village_name unique_id Merge_C_F R_Cen_enum_name R_Cen_enum_code Merge_consented

keep if Merge_consented==3
label define label 1 "HH survey and census" 0 "only census"
label values Merge_C_F label

egen strata= group(R_Cen_enum_code) 
*egen strata1=group(R_Cen_enum_name) if Merge_C_F==1  //only HH survey obs
*egen strata2=group(R_Cen_enum_name) if Merge_C_F==0  //census obs excluding HH survey


//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_Cen_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.25*total
replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata Merge_C_F unique_id
set seed 75824
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) if Merge_C_F==1	
bys strata (unique_id): gen strata_random_census= runiform(0,1) if Merge_C_F==0


//Sampling 60% of census-only and 40% of HHsurvey observations for each enumerator
gen census_only_perc_byenum= 0.6* ten_perc_per_enum
gen hhsurvey_perc_byenum= 0.4* ten_perc_per_enum
replace census_only_perc_byenum = round(census_only_perc_byenum)
replace hhsurvey_perc_byenum= round(hhsurvey_perc_byenum)


//selecting observations based on sampling criteria
sort strata strata_random_hhsurvey
bys R_Cen_enum_name: generate selected_hhsurvey = _n <= hhsurvey_perc_byenum 
sort strata strata_random_census
bys R_Cen_enum_name: generate selected_onlycensus = _n <= census_only_perc_byenum 

//Final selection variable
gen selected= 1 if selected_hhsurvey==1 | selected_onlycensus==1
tab R_Cen_enum_name selected


//generating replacements for those selected for BC survey
gsort  strata -strata_random_hhsurvey 
bys R_Cen_enum_name: generate selected_hhsurvey_repl = _n <= hhsurvey_perc_byenum  

gsort  strata -strata_random_census 
bys R_Cen_enum_name: generate selected_onlycensus_repl = _n <= census_only_perc_byenum 

gen selected_replacementBC= 1 if selected_hhsurvey_repl==1 | selected_onlycensus_repl==1

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

start_from_clean_file_Population
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
export excel unique_id R_Cen_village_name_str R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2  R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* R_Cen_female_above12 R_Cen_num_femaleabove12 R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12  using "${DataPre}Backcheck_preload_20Nov23.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



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
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   using "${pilot}Supervisor_BC_Tracker_checking.xlsx" if selected==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt



sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark using "${pilot}Supervisor_BC_Tracker_checking_repl.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   using "${pilot}Supervisor_data quality_Tracker_25 Oct 2023.xlsx" if data_quality_check==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

******************************************************************************
* Step 5: Checking which observations were selected for backcheck until 1st Nov *
******************************************************************************

//using backcheck_preload uploaded onto surveycto before Michelle went on leave
clear
import delimited using "${pilot}backcheck_preload.csv",  stringc(_all)
tempfile one
save `one', replace

clear
import delimited using "${pilot}1_raw/Baseline Backcheck_WIDE.csv",  stringc(_all)
duplicates report unique_id
duplicates tag unique_id, gen(new)
//keeping the observation where more data is observed
drop if new==1 & enum_name=="120"
merge 1:1 unique_id using `one'
drop if _merge==1


tempfile remaining_IDs_BC
save `remaining_IDs_BC', replace

//So, backcheck completed for 122 IDs until 1st Nov. 91 IDs still remaining.

//adding more IDs to the 91 remaining
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
replace R_Cen_village_name=50601 if R_Cen_village_name==30101
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1


label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end




//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
keep if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile part_1
save `part_1', replace

//Removing IDs that are chosen for data quality
clear
import excel using "${pilot}Data_quality.xlsx", sheet("JJM_drink_noprimsec") firstrow allstring
tempfile one
save `one', replace

clear
import excel using "${pilot}Data_quality.xlsx", sheet("Other prim source") firstrow allstring
tempfile two
save `two', replace


clear
import excel using "${pilot}Data_quality.xlsx", sheet("Other cases") firstrow allstring
append using `one'
append using `two'

duplicates report unique_id
duplicates drop unique_id, force
tempfile three
save `three', replace

clear
import delimited using "${pilot}1_raw/ILC_Data_Quality_survey_WIDE.csv",  stringc(_all)
duplicates report unique_id
duplicates tag unique_id, gen(new)
duplicates drop unique_id, force
//keeping the observation where more data is observed
merge 1:1 unique_id using `three'
drop if _merge==1 & starttime==""



tempfile part_2
save `part_2', replace
append using `part_1', force
duplicates report unique_id
duplicates tag unique_id, gen(duptag)
drop if duptag>0 & R_Cen_enum_name==""
save `part_2', replace
append using `remaining_IDs_BC'
duplicates report unique_id
duplicates drop unique_id, force
save `part_2', replace

start_from_clean_file_Population
merge 1:1 unique_id using `part_2', force gen(new_merge)
drop if new_merge==3| new_merge==2



//Conduct stratification again for additional BCs
keep R_Cen_village_name unique_id Merge_C_F R_Cen_enum_name R_Cen_enum_code Merge_consented

keep if Merge_consented==3
label define label 1 "HH survey and census" 0 "only census"
label values Merge_C_F label

egen strata= group(R_Cen_enum_code) 
*egen strata1=group(R_Cen_enum_name) if Merge_C_F==1  //only HH survey obs
*egen strata2=group(R_Cen_enum_name) if Merge_C_F==0  //census obs excluding HH survey


//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_Cen_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata Merge_C_F unique_id
set seed 75826
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) if Merge_C_F==1	
bys strata (unique_id): gen strata_random_census= runiform(0,1) if Merge_C_F==0


//Sampling 60% of census-only and 40% of HHsurvey observations for each enumerator
gen census_only_perc_byenum= 0.6* ten_perc_per_enum
gen hhsurvey_perc_byenum= 0.4* ten_perc_per_enum
replace census_only_perc_byenum = round(census_only_perc_byenum)
replace hhsurvey_perc_byenum= round(hhsurvey_perc_byenum)


//selecting observations based on sampling criteria
sort strata strata_random_hhsurvey
bys R_Cen_enum_name: generate selected_hhsurvey = _n <= hhsurvey_perc_byenum 
sort strata strata_random_census
bys R_Cen_enum_name: generate selected_onlycensus = _n <= census_only_perc_byenum 

//Final selection variable
gen selected= 1 if selected_hhsurvey==1 | selected_onlycensus==1
tab R_Cen_enum_name selected


//generating replacements for those selected for BC survey
gsort  strata -strata_random_hhsurvey 
bys R_Cen_enum_name: generate selected_hhsurvey_repl = _n <= hhsurvey_perc_byenum  

gsort  strata -strata_random_census 
bys R_Cen_enum_name: generate selected_onlycensus_repl = _n <= census_only_perc_byenum 

gen selected_replacementBC= 1 if selected_hhsurvey_repl==1 | selected_onlycensus_repl==1

keep if selected==1 | selected_replacementBC==1
tempfile selected_for_BC
save `selected_for_BC', replace

use `remaining_IDs_BC', clear
keep if _merge==2
append using `selected_for_BC'
save `selected_for_BC', replace

***********************************************************************
* Step 3: Generating preload list for BC survey *
***********************************************************************
use `selected_for_BC', clear
tempfile working
save `working', replace

start_from_clean_file_Population
merge 1:1 unique_id using `working', gen(merge_BC_select)
keep if merge_BC_select==3

//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}


decode R_Cen_village_name, gen(R_Cen_village_name_str)

sort R_Cen_village_name_str
export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* R_Cen_female_above12 R_Cen_num_femaleabove12 R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12 R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label using "${DataPre}Backcheck_preload_additional.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



clear
import delimited using "${pilot}backcheck_preload.csv",  stringc(_all)
tempfile one
save `one', replace


clear
import excel using "${DataPre}Backcheck_preload_additional.xlsx", sheet("Sheet1") firstrow allstring
merge 1:1 unique_id using `one'
