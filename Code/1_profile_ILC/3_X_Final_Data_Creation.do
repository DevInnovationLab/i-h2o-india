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
****** Language: English
*=========================================================================*/
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey
  
 /*--------------------------------------------
    Section A: HH level data
 --------------------------------------------*/
 
 

  
 /*--------------------------------------------
    Section B: Child level data
 --------------------------------------------*/
 
 /*--------------------------------------------
    Recreating baseline child level data: 
	Needed to run if any change happen to the baselind data
	
* N=1,123 
start_from_clean_file_ChildLevel
save "${DataTemp}Baseline_ChildLevel.dta", replace
  --------------------------------------------*/

use "${DataTemp}Baseline_ChildLevel.dta", clear
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

 
 
 //HH level merge between baseline and endline 
 
 use "${DataPre}1_8_Endline_XXX.dta", clear
 drop dup_HHID 
 save "${DataPre}1_8_Endline_XXX.dta", replace
 
 //baseline data
 cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
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

merge 1:1 unique_id using "${DataPre}1_8_Endline_XXX.dta", keep(3) nogen

