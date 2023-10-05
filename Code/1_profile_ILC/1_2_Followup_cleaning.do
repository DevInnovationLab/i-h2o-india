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
drop R_FU_unique_id_1_check R_FU_unique_id_3_check R_FU_unique_id_2_check

* Variable cuts across will not have prefix
* R_FU_hh_code
rename R_FU_unique_id unique_id_num
destring unique_id_num, replace
format   unique_id_num %15.0gc


*rename certain wate quality test variables
rename R_FU_tap_bag_id_stored_typed  R_FU_sample_ID_stored
rename R_FU_tap_bag_id_running_typed R_FU_sample_ID_tap
rename R_FU_tap_bag_running_id R_FU_bag_ID_tap
rename R_FU_tap_bag_stored_id R_FU_bag_ID_stored
rename R_FU_wq_tap_fc R_FU_fc_tap
rename R_FU_wq_chlorine_storedfc R_FU_fc_stored
rename R_FU_wq_tap_tc R_FU_tc_tap
rename R_FU_wq_chlorine_storedtc R_FU_tc_stored

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/


  * Formatting dates
    gen FU_day = day(dofc(R_FU_starttime))
	gen FU_month_num = month(dofc(R_FU_starttime))
	gen FU_month = word("`c(Mons)'", FU_month_num)
    
	//to change once survey date is fixed - TODO
	 *keep if (FU_day >19 & FU_month_num >=9)  
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

drop R_FU_duration_locatehh R_FU_duration_consent R_FU_duration_seca R_FU_duration_secb R_FU_duration_secc R_FU_duration_secd R_FU_duration_sece R_FU_duration_end

	
gen FU_duration_min = FU_locatehh_dur_min + FU_consent_dur_min + FU_secA_dur_min + FU_secB_dur_min + FU_secC_dur_min +  FU_secD_dur_min +  FU_secE_dur_min + FU_end_dur_min

/*------------------------------------------------------------------------------
	4 Manual correction in data - need to discuss with Akito and Jeremy
------------------------------------------------------------------------------*/

* Correcting the issue of incorrect sample IDs for stored water
 
 replace R_FU_sample_ID_stored = 20299 if unique_id_num == 50501115026 
 replace R_FU_sample_ID_stored = 20300 if unique_id_num == 50501119004 
 replace R_FU_sample_ID_stored = 20297 if unique_id_num == 50501104011 
 replace R_FU_sample_ID_stored = 20298 if unique_id_num == 50501115027
 

 * Correcting the issue of incorrect sample IDs for tap/running water
  replace R_FU_sample_ID_tap = 10238 if unique_id_num == 50501115026 
  replace R_FU_sample_ID_tap = 10239 if unique_id_num == 50501119004 
  replace R_FU_sample_ID_tap = 10236 if unique_id_num == 50501104011 
  replace R_FU_sample_ID_tap = 10237 if unique_id_num == 50501115027 
  replace R_FU_sample_ID_tap = 10001 if unique_id_num == 40201113018 

 * Correcting the issue of incorrect bag IDs for 
  replace R_FU_bag_ID_tap = 90051 if unique_id_num == 50501104011 
  replace R_FU_bag_ID_tap = 90007 if unique_id_num == 40201113010 


 * Correcting a coding issue 
 replace R_FU_wq_chlorine_running = 1 if R_FU_wq_chlorine_running == . 
 replace R_FU_wq_chlorine_stored = 1 if R_FU_wq_chlorine_stored == . 
	
/*------------------------------------------------------------------------------
	5 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}
capture export excel unique_id_num using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Follow") firstrow(var) cell(A1) sheetreplace
*drop if unique_id_num_Unique!=1
*drop unique_id_num_Unique

* In case of replacement households, check if the OG id is not the same as the unique_id
  egen replace_id = concat(R_FU_replacement_id_1 R_FU_replacement_id_2 R_FU_replacement_id_3)
  destring replace_id, replace force
  gen replace_og_id_err = 0 
  replace replace_og_id_err = 1 if replace_id == unique_id_num
capture export excel replace_id unique_id_num using "${pilot}Data_quality.xlsx" if replace_og_id_err ==1, sheet("Replacement_ID_Follow") firstrow(var) cell(A1) sheetreplace

* to decide what we do when error in entering replacement's OG id? 


* bag ID duplicates for running water sample
foreach i in R_FU_bag_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU_bag_ID_tap unique_id_num using "${pilot}Data_quality.xlsx" if R_FU_bag_ID_tap_Unique!=1, sheet("Dup_bag_ID_tap") firstrow(var) cell(A1) sheetreplace

* bag ID duplicates for stored water sample
foreach i in R_FU_bag_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU_bag_ID_stored unique_id_num using "${pilot}Data_quality.xlsx" if R_FU_bag_ID_stored_Unique!=1, sheet("Dup_bag_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for stored water sample
foreach i in R_FU_sample_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU_sample_ID_stored_ID_stored unique_id_num using "${pilot}Data_quality.xlsx" if R_FU_sample_ID_stored_Unique!=1, sheet("Dup_sample_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for running water sample
foreach i in R_FU_sample_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU_sample_ID_tap unique_id_num using "${pilot}Data_quality.xlsx" if R_FU_sample_ID_tap_Unique!=1, sheet("Dup_sample_ID_tap") firstrow(var) cell(A1) sheetreplace

* Akito->Astha This code I added should be removed, but please properly ensure that the unique ID is unique at the end of the code. 
duplicates drop unique_id_num, force

* Create a variable for cases when Water Quality test didn't happen
save "${DataDeid}1_2_Followup_cleaned.dta", replace
