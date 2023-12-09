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
	(1) This do file exports the preload data for mortality survey 
	(2) Also exports tracking sheets for supervisors for mortality survey ------ */

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


************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 

gen scenario = 0 
replace scenario = 3 if Merge_consented == 1 
replace scenario = 4 if Merge_consented == 3

gen scenario_label = scenario
label define scen 2 "Census, not available" 3 "Census, screened out" 4 "Census, screened in" 0 "Error"
label values scenario_label scen

decode  scenario_label, gen(scenario_str)

//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}


decode R_Cen_village_name, gen(R_Cen_village_name_str)

/*
local fam_age R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 R_Cen_a6_hhmember_age_18 R_Cen_a6_hhmember_age_19 R_Cen_a6_hhmember_age_20
*/

forvalues i = 1/17 {
	destring R_Cen_a6_hhmember_age_`i', gen(Cen_fam_age`i')
    local ++i
}

/*
local fam_gender R_Cen_a4_hhmember_gender_1 R_Cen_a4_hhmember_gender_2 R_Cen_a4_hhmember_gender_3 R_Cen_a4_hhmember_gender_4 R_Cen_a4_hhmember_gender_5 R_Cen_a4_hhmember_gender_6 R_Cen_a4_hhmember_gender_7 R_Cen_a4_hhmember_gender_8 R_Cen_a4_hhmember_gender_9 R_Cen_a4_hhmember_gender_10 R_Cen_a4_hhmember_gender_11 R_Cen_a4_hhmember_gender_12 R_Cen_a4_hhmember_gender_13 R_Cen_a4_hhmember_gender_14 R_Cen_a4_hhmember_gender_15 R_Cen_a4_hhmember_gender_16 R_Cen_a4_hhmember_gender_17 R_Cen_a4_hhmember_gender_18 R_Cen_a4_hhmember_gender_19 R_Cen_a4_hhmember_gender_20
*/
forvalues i = 1/17 {
	destring R_Cen_a4_hhmember_gender_`i', gen(Cen_fam_gender`i')
    local ++i
}

sort R_Cen_village_name_str
export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20  R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* R_Cen_female_above12 R_Cen_num_femaleabove12 R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12 R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label scenario scenario_str using "${DataPre}Mortality_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)



***********************************************************************
* Step 4: Generating tracking list for supervisors for Mortality survey *
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
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark  scenario scenario_str using "${pilot}Supervisor_Mortality_Tracker_checking.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt


