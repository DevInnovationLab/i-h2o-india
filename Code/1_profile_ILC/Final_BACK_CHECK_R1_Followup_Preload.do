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
  
set seed 75823
  
use  "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent == 1

	label variable R_FU1_consent "HH survey consent"
clonevar unique_id = unique_id_num
format  unique_id %15.0gc
replace R_FU1_r_cen_village_name_str = "Gopi_Kankubadi" if R_FU1_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_FU1_r_cen_village_name_str = "BK_Padar" if R_FU1_r_cen_village_name_str == "BK Padar" 
 
***********************************************************************
* Step 2: Selecting households for BC survey based on random numbers *
***********************************************************************

local mylist1 Asada Badabangi Barijhola Bichikote Dangalodi Gopi_Kankubadi Gudiabandh Karlakana Karnapadu Mariguda

foreach j of local mylist1 {

preserve

keep R_FU1_r_cen_village_name_str unique_id  R_FU1_enum_name 	
keep if R_FU1_r_cen_village_name_str== "`j'"	


*keep if selected==1 
tostring R_FU1_enum_name, generate(R_FU1_enum_name_)

egen strata= group(R_FU1_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_FU1_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
*replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata  unique_id
set seed 75824
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata_random_hhsurvey
bys R_FU1_enum_name: generate selected_hhsurvey = _n <= 2
cap replace selected_hhsurvey = 1 if unique_id == 50301117030


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
tab R_FU1_enum_name selected

*Sarita = 110
*Rajib = 103
*Pramodini = 119
replace selected = 0 if R_FU1_enum_name_ == "110" | R_FU1_enum_name_ == "103" | R_FU1_enum_name_ == "119" 

//generating replacements for those selected for BC survey
gsort -strata_random_hhsurvey
generate selected_hhsurvey_repl = _n  == 1 if selected != 1   
gen selected_replacementBC= 1 if selected_hhsurvey_repl==1
keep if selected == 1 | selected_replacementBC== 1  
gsort -selected 
gen rank = _n

save "${DataPr}selected_`j'_28thfeb2024_for_FollowupBC.dta", replace

restore
}


local mylist2 BK_Padar Bhujbal Birnarayanpur Jaltar Mukundpur Naira Nathma Tandipur Sanagortha Kuljing 

foreach j of local mylist2 {

preserve
keep R_FU1_r_cen_village_name_str unique_id  R_FU1_enum_name 	
keep if R_FU1_r_cen_village_name_str== "`j'"	


*keep if selected==1 
tostring R_FU1_enum_name, generate(R_FU1_enum_name_)

egen strata= group(R_FU1_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_FU1_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
*replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata  unique_id
set seed 75824
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata_random_hhsurvey
bys R_FU1_enum_name: generate selected_hhsurvey = _n == 1
cap replace selected_hhsurvey = 1 if unique_id == 50301117030


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
tab R_FU1_enum_name selected




*keep if selected==1 

keep if selected==1
set seed 75824
gen final_strata_random_hhsurvey= runiform(0,1)
sort strata_random_hhsurvey
generate final_selected_hhsurvey = _n == 1
gen final_selected = 1 if final_selected_hhsurvey == 1


//generating replacements for those selected for BC survey
gsort -strata_random_hhsurvey
generate selected_hhsurvey_repl = _n  <= 2  if final_selected != 1
gen selected_replacementBC= 1 if selected_hhsurvey_repl==1
keep if final_selected == 1 | selected_replacementBC== 1 
gsort -final_selected
gen rank = _n
drop selected selected_hhsurvey
rename final_selected selected 
rename final_selected_hhsurvey  selected_hhsurvey 
 

save "${DataPr}selected_`j'_28thfeb2024_for_FollowupBC.dta", replace

restore
}

preserve
clear
use "${DataPr}selected_Tandipur_28thfeb2024_for_FollowupBC.dta"
append using "C:\Users\Archi Gupta\Box\Data\1_raw\selected_Sanagortha_28thfeb2024_for_FollowupBC.dta"
local mylist Asada BK_Padar Badabangi Barijhola Bhujbal Bichikote Birnarayanpur Dangalodi Gopi_Kankubadi Gudiabandh Jaltar Karlakana Karnapadu Kuljing Mariguda Mukundpur Naira Nathma
foreach j of local mylist{
append using "${DataPr}selected_`j'_28thfeb2024_for_FollowupBC.dta"
}
drop R_FU1_enum_name_


*plz shift this at the top after verification is done
//////////////////////////////////////////
preserve
*compare with BC submitted 
import delimited "${DataRaw}Baseline Follow Up R1 Backcheck_WIDE.csv", bindquote(strict) clear
clonevar unique_id_num = unique_id
format  unique_id %15.0gc
keep unique_id
save "${DataRaw}BC_Followup_Matching.dta", replace 
restore
merge 1:1 unique_id using "${DataRaw}BC_Followup_Matching.dta", gen(merge_BC_match)
keep if merge_BC_match == 1
//////////////////////////////////////////////////////

save "${DataPr}selected_for_BC.dta", replace
restore

* To add a unique Id where we found an issue in HFC, to do a backcheck for this


***********************************************************************
* Step 3: Generating preload list for BC survey *
***********************************************************************
merge 1:1 unique_id using "${DataPr}selected_for_BC.dta", gen(merge_BC_select)
keep if merge_BC_select==3

//Cleaning the name of the household head

sort R_FU1_r_cen_village_name_str R_FU1_enum_name_label 
export excel unique_id R_FU1_r_cen_village_name_str R_FU1_enum_name R_FU1_enum_name_label R_FU1_r_cen_a10_hhhead R_FU1_r_cen_a1_resp_name R_FU1_r_cen_a39_phone_name_1 R_FU1_r_cen_a39_phone_num_1 R_FU1_r_cen_a39_phone_name_2 R_FU1_r_cen_a39_phone_num_2 R_FU1_r_cen_landmark R_FU1_r_cen_address R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_a11_oldmale_name R_FU1_r_cen_fam_name1 R_FU1_r_cen_fam_name2 R_FU1_r_cen_fam_name3 R_FU1_r_cen_fam_name4 R_FU1_r_cen_fam_name5 R_FU1_r_cen_fam_name6 R_FU1_r_cen_fam_name7 R_FU1_r_cen_fam_name8 R_FU1_r_cen_fam_name9 R_FU1_r_cen_fam_name10 R_FU1_r_cen_fam_name11 R_FU1_r_cen_fam_name12 R_FU1_r_cen_fam_name13 R_FU1_r_cen_fam_name14 R_FU1_r_cen_fam_name15 R_FU1_r_cen_fam_name16 R_FU1_r_cen_fam_name17 R_FU1_r_cen_fam_name18 R_FU1_r_cen_fam_name19 R_FU1_r_cen_fam_name20 R_FU1_water_source_prim using "${DataPre}Backcheck_FU1_preload_28Feb24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)


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
	

*sort R_FU1_r_cen_village_name_str R_FU1_enum_name 
*export excel ID R_FU1_enum_name R_FU1_r_cen_village_name_str R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_landmark rank using "${pilot}Supervisor_BC_FU1_Tracker_checking_repl.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


sort R_FU1_r_cen_village_name_str R_FU1_enum_name  
export excel ID R_FU1_enum_name R_FU1_r_cen_village_name_str R_FU1_r_cen_hamlet_name R_FU1_r_cen_saahi_name R_FU1_r_cen_landmark rank  using "${pilot}Supervisor_BC_FU1_Tracker_checking.xlsx" if (selected==1 | selected_replacementBC==1) & merge_BC_match == 1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


*for check
*drop unique_id
*rename unique_id_num unique_id 
*merge 1:1 unique_id using "${DataRaw}BC_Followup_Matching.dta", gen(merge_BC_match2)
