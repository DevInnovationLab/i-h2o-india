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

capture drop consented1burden_of_water_collec consented1chlorination_perceptio consented1water_quality_testing1 v*

** Drop ID information

drop r_cen_a1_resp_name  r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_a11_oldmale_name	


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
    
	//to change once survey date is fixed - TODO
	 keep if (FU_day >19 & FU_month_num >=9)  
     egen FU_date = concat(FU_day FU_month)
	 gen FU_starthour = hh(R_FU_starttime) 
	 gen FU_startmin= mm(R_FU_starttime)
  
/*------------------------------------------------------------------------------
	3 Keep relevant entries (2.1 aaa)
------------------------------------------------------------------------------*/
  
  // remove the test data once we have actual data coming in  - TODO
     drop if R_FU_unique_id_1 == 99999 
	 drop if R_FU_unique_id_1 == 88888 

	
	
// Capturing  section-wise duration

destring R_FU_duration_locatehh R_FU_duration_consent R_FU_duration_seca R_FU_duration_secb R_FU_duration_secc R_FU_duration_secd ///
R_FU_duration_sece R_FU_duration_end, replace


gen FU_locatehh_dur= R_FU_duration_locatehh
gen FU_consent_dur= R_FU_duration_consent-R_FU_duration_locatehh
gen FU_secA_dur= R_FU_duration_seca-R_FU_duration_consent
gen FU_secB_dur= R_FU_duration_secb-R_FU_duration_seca
gen FU_secC_dur= R_FU_duration_secc-R_FU_duration_secb
gen FU_secD_dur= R_FU_duration_secd-R_FU_duration_secc
gen FU_secE_dur= R_FU_duration_sece-R_FU_duration_secd
gen FU_end_dur= R_FU_duration_end-R_FU_duration_sece

local duration FU_locatehh_dur  FU_consent_dur FU_secA_dur FU_secB_dur FU_secC_dur FU_secD_dur FU_secE_dur FU_end_dur 
foreach x of local duration  {
	replace `x'= `x'/60
	rename `x' `x'_min
}

drop R_FU_duration_locatehh R_FU_duration_consent R_FU_duration_seca R_FU_duration_secb R_FU_duration_secc R_FU_duration_secd ///
R_FU_duration_sece R_FU_duration_end

	
gen FU_duration_min = FU_locatehh_dur_min + FU_consent_dur_min + FU_secA_dur_min + FU_secB_dur_min + FU_secC_dur_min +  FU_secD_dur_min +  FU_secE_dur_min + FU_end_dur_min

	
/*------------------------------------------------------------------------------
	4 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}
capture export excel unique_id_num using "${pilot}Data_quality_FU.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Follow") firstrow(var) cell(A1) sheetreplace
*drop if unique_id_num_Unique!=1
*drop unique_id_num_Unique

* In case of replacement households, check if the OG id is not the same as the unique_id
  egen replace_id = concat(R_FU_replacement_id_1 R_FU_replacement_id_2 R_FU_replacement_id_3)
  gen replace_og_id_err = 0 
  replace replace_og_id_err = 1 if replace_id == unique_id_num
capture export excel replace_id unique_id_num using "${pilot}Data_quality_FU.xlsx" if replace_og_id_err ==1, sheet("Replacement_ID_Follow") firstrow(var) cell(A1) sheetreplace

* to decide what we do when error in entering replacement's OG id? 


/*------------------------------------------------------------------------------
	5 Manual correction in data - need to discuss with Akito and Jeremy
------------------------------------------------------------------------------*/



* Create a variable for cases when Water Quality test didn't happen
save "${DataDeid}1_2_Followup_cleaned.dta", replace



