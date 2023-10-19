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

drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"


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
gen ten_perc_per_enum= 0.1*total
replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
sort strata Merge_C_F
bys strata: gen strata_random_hhsurvey= runiform(0,1) if Merge_C_F==1	
bys strata: gen strata_random_census= runiform(0,1) if Merge_C_F==0
sort strata Merge_C_F


//Oversampling IDs that appear in census and HH survey
gen selected_hhsurvey= 1 if strata_random_hhsurvey<=0.2
bys R_Cen_enum_name: egen total_select_hhsurvey= total(selected_hhsurvey)


//number of surveys left in 10% BCs will be sampled from census_only IDs
gen diff= ten_perc_per_enum-total_select_hhsurvey
bys R_Cen_enum_name: generate selected_onlycensus = _n <= diff if Merge_C_F==0 & strata_random_census!=.


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 | selected_onlycensus==1
tab R_Cen_enum_name selected


//generating replacements for those selected for BC survey- all from HH survey
bys R_Cen_enum_name: generate selected_replacementBC = (_N - _n) <= ten_perc_per_enum if selected!=1 


keep if selected==1 | selected_replacementBC==1
tempfile selected_for_BC
save `selected_for_BC', replace


***********************************************************************
* Step 3: Generating preload list for BC survey *
***********************************************************************
start_from_clean_file_Population
merge 1:1 unique_id using `selected_for_BC', gen(merge_BC_select)
keep if merge_BC_select==3

//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}


decode R_Cen_village_name, gen(R_Cen_village_name_str)

sort R_Cen_village_name_str
export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* R_Cen_female_above12 R_Cen_num_femaleabove12 R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12 using "${DataPre}Backcheck_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



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
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   using "${pilot}Supervisor_BC_Tracker_19 Oct 2023.xlsx" if selected==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt



sort R_Cen_village_name_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark using "${pilot}Supervisor_BC_Tracker_19 Oct 2023_Replacement list.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

