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
** In this do file: 
	* This do file exports.....

use "${DataRaw}1_2_Followup.dta", clear
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/

capture drop consented1burden_of_water_collec consented1chlorination_perceptio consented1water_quality_testing1


foreach x of var * { 
	rename `x' R_FU_`x' 
} 
* Variable cuts across will not have prefix
* R_FU_hh_code
rename R_FU_unique_id unique_id_num
destring unique_id_num, replace
format   unique_id_num %15.0gc

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/


  * Formatting dates
    gen FU_day = day(dofc(R_FU_starttime))
	gen FU_month_num = month(dofc(R_FU_starttime))
	gen FU_month = word("`c(Mons)'", FU_month_num)
    egen FU_date = concat(day_fu " " FU_month)
	//to change once survey date is fixed - TODO
	* keep if (day_fu >19 & month_num_fu >=9)  

  // remove the test data once we have actual data coming in  - TODO
    * drop if R_FU_unique_id_1 == 99999

	
	/* DROP THESE

  * Keep only consented cases and report non consent frequency in descriptive stats
    preserve 
	gen non_consent = 1 
	replace non_consent = 0 if R_FU_consent == 1
    tempfile non_consent_tab
	save `non_consent_tab'
	restore 
	
	drop if R_FU_consent != 1
	
 * Keep only cases when "Household available for interview and opened the door" 
     preserve 
	gen resp_available = 1 
	replace resp_available = 0 if R_FU_resp_available != 1
    tempfile resp_available
	save `resp_available'
	restore 
	
    keep if R_FU_resp_available == 1
	*/
	
	
/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}
capture export excel unique_id_num using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Follow") firstrow(var) cell(A1) sheetreplace
drop if unique_id_num_Unique!=1
drop unique_id_num_Unique

* In case of replacement households, check if the OG id is not the same as the unique_id
egen replace_id = concat(R_FU_replacement_id_1 R_FU_replacement_id_2 R_FU_replacement_id_3)
gen replace_og_id_err = 0 
replace replace_og_id_err = 1 if replace_id == unique_id_num
* to decide what we do when error in entering replacement's OG id? 


save "${DataDeid}1_2_Followup_cleaned.dta", replace



