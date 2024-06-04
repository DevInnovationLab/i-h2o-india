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
foreach i in C_diarr* C_loose* {
	rename `i' B_`i'
}
drop Treat_V Panchatvillage BlockCode
merge 1:1 unique_id num Cen_Type using "${DataTemp}U5_Child_23_24_clean.dta", gen(Merge_Baseline_CL) keepusing(C_diarrhea* C_loose* village End_date comb_child_age) update
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
replace village=20101 if village==60101
merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)
tab _merge
br if _merge==1
label var Treat_V "Treatment"
label var B_C_diarrhea_comb_U5_1day "Baseline"
label var B_C_diarrhea_prev_child_1day "Baseline"
label var B_C_loosestool_child_1day "Baseline"

save "${DataTemp}U5_Child_Diarrhea_data.dta", replace

 