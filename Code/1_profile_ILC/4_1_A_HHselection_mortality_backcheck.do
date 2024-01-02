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
gen count= 1
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


* Final selection variable
gen selected= 1 if selected_sc_in==1 | selected_sc_out==1 
tab R_mor_enum_name_f selected
br if selected== 1

keep if selected== 1
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
