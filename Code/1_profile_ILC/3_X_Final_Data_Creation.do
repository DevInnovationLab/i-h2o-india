/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: This do file conduct descriptive statistics using endline survey
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
	- "${DataTemp}Baseline_ChildLevel.dta", clear
	- "${DataTemp}U5_Child_23_24_clean.dta"
****** Output data : 
	- "${DataTemp}U5_Child_Diarrhea_data.dta"
	
****** Do file to run before this do file
	- 2_1_Final_data.do (start_from_clean_file_ChildLevel)

****** Language: English
*=========================================================================*/
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey
	
  
 /*--------------------------------------------
    Section A: HH level data
 --------------------------------------------*/  
 //baseline data
cap program drop start_from_clean_BL_final
program define   start_from_clean_BL_final
  * Open clean file
 * baseline clean
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
* There are 3,848 households: 915 sample goes to the: Final_HH_Odisha_consented_Full
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
start_from_clean_BL_final
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 
list if unique_id == ""
isid unique_id

///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////
* 40 household were not followed in the endline
merge 1:1 unique_id using  "${DataFinal}1_8_Endline_Census_cleaned_consented", gen(Merge_Baseline_Endline)
* keep if Merge_Baseline_Endline==3
* drop Merge_Baseline_Endline




***** Generating new variables
* Combined variable for Number of HH members (both BL and EL including the new members)
//changing the storage type of the no of HH members from baseline census
destring R_Cen_hh_member_names_count, gen(R_Cen_hhmember_count_new) 

egen total_hhmembers=rowtotal(R_Cen_hhmember_count_new R_E_n_hhmember_count) 
label var total_hhmembers "Number of HH members"


* Number of U5 Children
//Generating new binary variable if age of HH member is <5
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen Cen_U5child_`i' =1 if R_Cen_a6_hhmember_age_`i'<5 
}
forvalues i=1/20{ //loop for all new members in Endline Census
	gen E_n_U5child_`i'=1 if  R_E_n_fam_age`i'<5
}
//Generating variable for total no of U5 children in Baseline and Endline
egen total_U5children= rowtotal(Cen_U5child_* E_n_U5child_*)
label var total_U5children "Number of U5 Children"


* Number of pregnant women
//Generating new binary variable if HH member is pregnant 
forvalues i = 1/17 { //loop for all HH memebers in Baseline Census
	gen Cen_total_pregnant_`i'= 1 if R_Cen_a7_pregnant_`i'==1
}
//Generating variable for total no of pregnant women in Baseline and Endline 
egen total_pregnant= rowtotal(R_E_cen_preg_status* R_E_n_preg_status* Cen_total_pregnant_* )
label var total_pregnant "Number of pregnant women" 
	
	
* Number of Women of Child Bearing Age
egen total_CBW= rowtotal(R_E_n_num_female_15to49 R_E_r_cen_num_female_15to49)
label var total_CBW "Number of Women of Child Bearing Age"


* Number of Other Members in the HH 
//Generating binary variable if HH member is neither CBW nor U5
forvalues i=1/17{ //loop for all HH members in Baseline
	gen Cen_noncri_members_`i'=1 if (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a4_hhmember_gender_`i'==1) | (R_Cen_a6_hhmember_age_`i'>49 & R_Cen_a4_hhmember_gender_`i'==2) | (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a6_hhmember_age_`i'<15 & R_Cen_a4_hhmember_gender_`i'==2)
}
//Generating vairable for total no of non criteria/Other members in Baseline and Endline 
egen total_noncri_members=rowtotal(Cen_noncri_members_* R_E_n_num_allmembers_h)
label total_noncri_members "Number of Other Members"

* Index of the HH Head (to ascertain which HH member is the head)
//Extracting the index from name of HH Head
gen hh_head_index =.
replace hh_head_index=R_Cen_a10_hhhead
label var hh_head_index "Househols Head's index"

* Age of the HH head
gen hh_head_age = .
forval i = 1/17 { 
    replace hh_head_age = R_Cen_a6_hhmember_age_`i' if hh_head_index== `i'
}
label var hh_head_age "Age of the HH Head"


// * Education Level of the HH Head
// gen hh_head_edu = .
// forval i = 1/17 {
//     replace hh_head_edu = R_Cen_a9_school_level_`i' if hh_head_index== `i'
// }
// label var hh_head_edu "Level of Education of HH Head"
// label define hh_head_edu 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" ///
// 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" ///
// 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" ///
// 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
// label values hh_head_edu hh_head_edu






drop R_E_r_cen_*
* Village info is not complete. Deleting the redundant info
replace village=R_Cen_village_name if village==.
drop R_Cen_village_name R_Cen_block_name Treat_V
merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V Panchatvillage BlockCode) keep(1 3) nogen

save "${DataFinal}0_Master_HHLevel.dta", replace








  
 /*--------------------------------------------
    Section B: Child level data
 --------------------------------------------*/
* N=1,002 
use "${DataFinal}Baseline_ChildLevel.dta", clear
* Cen_Type is the type existed from the baseline
gen Cen_Type=4
* Renaming baseline variable with B_ prefix
foreach i in C_diarr* C_loose* C_cuts_* {
	rename `i' B_`i'
}
drop Treat_V Panchatvillage BlockCode
merge 1:1 unique_id num Cen_Type using "${DataTemp}U5_Child_23_24_clean.dta", gen(Merge_Baseline_CL) keepusing(C_diarrhea* C_loose* C_cuts_* village End_date comb_child_age) update
tab Merge_Baseline_CL Cen_Type,m

/* Archi to check more
. tab Merge_Baseline_CL Cen_Type,m

 Matching result from |       Cen_Type
                merge |         4          5 |     Total
----------------------+----------------------+----------
      Master only (1) |       155          0 |       155 
       Using only (2) |         4        116 |       120 
          Matched (3) |       847          0 |       847 
----------------------+----------------------+----------
                Total |     1,006        116 |     1,122 

*/
merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V Panchatvillage BlockCode) keep(1 3)
tab _merge
br if _merge==1
label var Treat_V "Treatment"
label var B_C_diarrhea_comb_U5_1day "Baseline"
label var B_C_diarrhea_prev_child_1day "Baseline"
label var B_C_loosestool_child_1day "Baseline"
label var B_C_cuts_child_1day "Baseline"

save "${DataFinal}0_Master_ChildLevel.dta", replace

 
 
 