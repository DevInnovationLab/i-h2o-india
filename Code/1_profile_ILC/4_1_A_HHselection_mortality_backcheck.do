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

********************************************************************
* Cleaning and selecting random observations for backcheck sample *
********************************************************************
cap program drop start_from_file_mortalitysurvey
program define   start_from_file_mortalitysurvey
  * Open clean file
  clear
use "${DataPre}1_1_Mortality_cleaned.dta", clear

end

start_from_file_mortalitysurvey

//Update village code every time this code is run for a new village
keep if R_mor_village_name_str_f== "Gopi Kankubadi"


*Step 1:Identifying child death cases
egen U5child_death = rowtotal(R_mor_child_died_num*)

preserve
keep if U5child_death>0
tempfile child_death_cases
save `child_death_cases', replace
restore

drop if U5child_death>0

//generating compiled unique_if variable for screened in and screened out cases
gen R_mor_unique_id_f= R_mor_unique_id_sc if R_mor_check_scenario==0
replace R_mor_unique_id_f= R_mor_unique_id if R_mor_check_scenario==1


*Step 2: Total number of BC surveys needed per enumerator - 10%
set seed 1234


* Step 3: Randomly Select 10% of Completed IDs for Each Enumerator
gen count=1
bysort R_mor_enum_name_f: egen total_completed = total(count)
by R_mor_enum_name_f: gen select_count = ceil(0.1 * total_completed)

by R_mor_enum_name_f: sample 2, count // Randomly select 10% of completed IDs for each enumerator

* Step 4: Further Random Selection Based on Census Status
sort R_mor_enum_name_f R_mor_unique_id_f
by R_mor_enum_name_f: gen selected_order = _n  // Generate an order for the selected IDs
by R_mor_enum_name_f: gen selected_count = _N  // Count the selected IDs

by R_mor_enum_name_f: egen census_not_conducted = total(R_mor_check_scenario == 0 & selected_order <= 0.8 * selected_count)
by R_mor_enum_name_f: gen selected_for_sample = (R_mor_check_scenario == 0 & selected_order <= 0.8 * selected_count) | (R_mor_check_scenario == 1 & selected_order <= 0.2 * selected_count)




/*

bys R_mor_enum_name_f: egen total_surveys= total(count)
bys R_mor_enum_name_f: gen ten_perc_per_enum= 0.10*total_surveys
replace ten_perc_per_enum= round(ten_perc_per_enum)


bys R_mor_enum_name_f (R_mor_unique_id_f): gen random_sc_in= runiform(0,1) if R_mor_check_scenario==1	
bys R_mor_enum_name_f (R_mor_unique_id_f): gen random_sc_out= runiform(0,1) if R_mor_check_scenario==0


* Step 3: Ensure 70% are IDs where census was not conducted previously and 30% are IDs where census was conducted previously within the selected sample
gen sc_in_perc_byenum= 0.3* ten_perc_per_enum
gen sc_out_perc_byenum= 0.7* ten_perc_per_enum
replace sc_in_perc_byenum = round(sc_in_perc_byenum)
replace sc_out_perc_byenum= round(sc_out_perc_byenum)


* Step 4: Selecting observations based on sampling criteria
sort R_mor_enum_name_f random_sc_in
bys R_mor_enum_name_f: generate selected_sc_in = _n <= sc_in_perc_byenum 
sort R_mor_enum_name_f random_sc_out
bys R_mor_enum_name_f: generate selected_sc_out = _n <= sc_out_perc_byenum 
*/


* Final selection variable
tab R_mor_check_scenario  //check if you have the 70-30 ratio
tab R_mor_enum_name_f selected_for_sample

append using `child_death_cases'

//final correction to unique_id variable to include all cases
replace R_mor_unique_id_f= R_mor_unique_id_sc if R_mor_check_scenario==0
replace R_mor_unique_id_f= R_mor_unique_id if R_mor_check_scenario==1

gen selected_new= 1
tab R_mor_enum_name_f selected_new


***********************************************************************
* Generating tracking list for supervisors for BC survey *
***********************************************************************

gen newvar1 = substr(R_mor_unique_id_f, 1, 5)
gen newvar2 = substr(R_mor_unique_id_f, 6, 3)
gen newvar3 = substr(R_mor_unique_id_f, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3


//Changing labels 
	label variable ID "Unique ID"
	label variable R_mor_village_name_str_f "Village Name"
	
	replace R_mor_block_name = R_mor_block_name[_n-1] if missing(R_mor_block_name)
	label variable R_mor_block_name "Block name"
	label variable R_mor_hamlet_name_f "Hamlet name"
	label variable R_mor_saahi_name_f "Saahi name"
	label variable R_mor_landmark_f "Landmark"
	label variable R_mor_enum_name_f "Enumerator name"
	

//To be changed each time this code is run for a new village
local village 30701

sort R_mor_village_name_str_f R_mor_enum_name_f  
export excel ID R_mor_enum_name_f R_mor_block_name R_mor_village_name_str_f R_mor_hamlet_name_f R_mor_saahi_name_f R_mor_landmark_f  using "${pilot}Supervisor_Mortality_BC_Tracker_`village'.xlsx" if selected_new==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt



***********************************************************************
* Generating preload for BC survey *
***********************************************************************

clear
import excel "${pilot}Supervisor_Mortality_BC_Tracker_30701.xlsx", firstrow
rename UniqueID R_mor_unique_id_f
gen newvar1 = substr(R_mor_unique_id_f, 1, 5)
gen newvar2 = substr(R_mor_unique_id_f, 7, 3)
gen newvar3 = substr(R_mor_unique_id_f, 11, 3)
replace R_mor_unique_id_f= newvar1 + newvar2 + newvar3
tempfile main
save `main', replace

use "${DataPre}1_1_Mortality_cleaned.dta", clear
keep if R_mor_village_name_str_f== "Gopi Kankubadi"
gen R_mor_unique_id_f= R_mor_unique_id_sc if R_mor_check_scenario==0
replace R_mor_unique_id_f= R_mor_unique_id if R_mor_check_scenario==1
merge 1:1 R_mor_unique_id_f using `main'
keep if _merge==3


//cleaning hh head names
gen R_mor_a10_hhhead_f=""
forvalues i= 1/20 {
	
	replace R_mor_a10_hhhead_f = R_mor_fam_name`i'_f if R_mor_a10_hhhead==`i'
	
}

replace R_mor_a10_hhhead_f= R_mor_r_cen_a10_hhhead if R_mor_r_cen_a10_hhhead!=""
replace R_mor_a10_hhhead_f = subinstr(R_mor_a10_hhhead_f, ".", "",.) 

//generating preload
keep R_mor_unique_id_f R_mor_enum_name_f R_mor_fam_name1_f R_mor_fam_name2_f R_mor_fam_name3_f R_mor_fam_name4_f R_mor_fam_name5_f R_mor_fam_name6_f R_mor_fam_name7_f R_mor_fam_name8_f R_mor_fam_name9_f R_mor_fam_name10_f R_mor_fam_name11_f R_mor_fam_name12_f R_mor_fam_name13_f R_mor_fam_name14_f R_mor_fam_name15_f R_mor_fam_name16_f R_mor_fam_name17_f R_mor_fam_name18_f R_mor_fam_name19_f R_mor_fam_name20_f R_mor_block_name R_mor_hamlet_name_f R_mor_saahi_name_f R_mor_landmark_f  R_mor_village_name_str_f R_mor_a10_hhhead_f R_mor_address_f
 
order R_mor_unique_id_f R_mor_enum_name_f R_mor_village_name_str_f R_mor_block_name R_mor_hamlet_name_f R_mor_saahi_name_f R_mor_address_f R_mor_landmark_f R_mor_a10_hhhead_f R_mor_fam_name1_f R_mor_fam_name2_f R_mor_fam_name3_f R_mor_fam_name4_f R_mor_fam_name5_f R_mor_fam_name6_f R_mor_fam_name7_f R_mor_fam_name8_f R_mor_fam_name9_f R_mor_fam_name10_f R_mor_fam_name11_f R_mor_fam_name12_f R_mor_fam_name13_f R_mor_fam_name14_f R_mor_fam_name15_f R_mor_fam_name16_f R_mor_fam_name17_f R_mor_fam_name18_f R_mor_fam_name19_f R_mor_fam_name20_f

rename R_mor_unique_id_f unique_id

export excel "${DataPre}BC_Mortality_preload.xlsx", firstrow(var) replace


