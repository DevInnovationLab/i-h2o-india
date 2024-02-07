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

use "${DataRaw}1_5_Followup_R1.dta", clear
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/

capture drop consented1burden_of_water_collec consented1chlorination_perceptio consented1water_quality_testing1 v*

** Drop ID information

drop r_cen_a1_resp_name  r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_a11_oldmale_name r_cen_address r_cen_saahi_name

foreach x of var * { 
	rename `x' R_FU1_`x' 
} 
drop R_FU1_unique_id_1_check R_FU1_unique_id_3_check R_FU1_unique_id_2_check

* Variable cuts across will not have prefix
* R_FU_hh_code
rename R_FU1_unique_id unique_id_num
destring unique_id_num, replace
format   unique_id_num %15.0gc


*rename certain wate quality test variables
rename R_FU1_tap_bag_id_stored_typed  R_FU1_sample_ID_stored
rename R_FU1_tap_bag_id_running_typed R_FU1_sample_ID_tap
rename R_FU1_tap_bag_running_id R_FU1_bag_ID_tap
rename R_FU1_tap_bag_stored_id R_FU1_bag_ID_stored
rename R_FU1_wq_tap_fc R_FU1_fc_tap
rename R_FU1_wq_chlorine_storedfc R_FU1_fc_stored
rename R_FU1_wq_tap_tc R_FU1_tc_tap
rename R_FU1_wq_chlorine_storedtc R_FU1_tc_stored

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/


  * Formatting dates
    gen FU1_day = day(dofc(R_FU1_starttime))
	gen FU1_month_num = month(dofc(R_FU1_starttime))
	gen FU1_month = word("`c(Mons)'", FU1_month_num)
    
	//to change once survey date is fixed - TODO
	 *keep if (FU_day >19 & FU_month_num >=9)  
     egen FU1_date = concat(FU1_day FU1_month)
	 gen FU1_starthour = hh(R_FU1_starttime) 
	 gen FU1_startmin= mm(R_FU1_starttime)
  
/*------------------------------------------------------------------------------
	3 Keep relevant entries (2.1 aaa)
------------------------------------------------------------------------------*/
  
  // remove the test data once we have actual data coming in  - TODO
     drop if R_FU1_unique_id_1 == 99999 

	
	
// Capturing  section-wise duration

destring R_FU1_duration_locatehh R_FU1_duration_consent R_FU1_duration_seca R_FU1_duration_secb R_FU1_duration_secc ///
R_FU1_duration_sece R_FU1_duration_end, replace


gen FU1_locatehh_dur= R_FU1_duration_locatehh
gen FU1_consent_dur= R_FU1_duration_consent-R_FU1_duration_locatehh
gen FU1_secA_dur= R_FU1_duration_seca-R_FU1_duration_consent
gen FU1_secB_dur= R_FU1_duration_secb-R_FU1_duration_seca
gen FU1_secC_dur= R_FU1_duration_secc-R_FU1_duration_secb
gen FU1_secE_dur= R_FU1_duration_sece-R_FU1_duration_secc
gen FU1_end_dur= R_FU1_duration_end-R_FU1_duration_sece

local duration FU1_locatehh_dur  FU1_consent_dur FU1_secA_dur FU1_secB_dur FU1_secC_dur  FU1_secE_dur FU1_end_dur 
foreach x of local duration  {
	replace `x'= `x'/60
	rename `x' `x'_min
}

drop R_FU1_duration_locatehh R_FU1_duration_consent R_FU1_duration_seca R_FU1_duration_secb R_FU1_duration_secc  R_FU1_duration_sece 

	
gen FU1_duration_min = FU1_locatehh_dur_min + FU1_consent_dur_min + FU1_secA_dur_min + FU1_secB_dur_min + FU1_secC_dur_min  +  FU1_secE_dur_min + FU1_end_dur_min

/*------------------------------------------------------------------------------
	4 Manual correction in data - need to discuss with Akito and Jeremy
------------------------------------------------------------------------------*/

* Correcting the issue of incorrect sample IDs for stored water
 

 * Correcting the issue of incorrect sample IDs for tap/running water
  
 * Correcting the issue of incorrect bag IDs for 
  

 * Correcting a coding issue 
 
/*------------------------------------------------------------------------------
	5 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}

 
 foreach i in unique_id_num {
bys `i': gen `i'_NUnique=_N
}
capture export excel unique_id_num using "${pilot}Data_quality_R1.xlsx" if unique_id_num_NUnique!=1, sheet("Dup_ID_Follow_R1") firstrow(var) cell(A1) sheetreplace
* keep only complete cases
 
 
 
* In case of replacement households, check if the OG id is not the same as the unique_id
  gen str3 FU1_replacement_id_3  = string(R_FU1_replacement_id_3, "%03.0f")
  egen replace_id = concat(R_FU1_replacement_id_1 R_FU1_replacement_id_2 FU1_replacement_id_3)
  destring replace_id, replace force
  gen replace_og_id_err = 0 
  replace replace_og_id_err = 1 if replace_id == unique_id_num
capture export excel replace_id unique_id_num using "${pilot}Data_quality_R1.xlsx" if replace_og_id_err ==1, sheet("Replacement_ID_Follow") firstrow(var) cell(A1) sheetreplace

* to decide what we do when error in entering replacement's OG id? 


* bag ID duplicates for running water sample
foreach i in R_FU1_bag_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU1_bag_ID_tap unique_id_num using "${pilot}Data_quality_R1.xlsx" if R_FU1_bag_ID_tap_Unique!=1, sheet("Dup_bag_ID_tap") firstrow(var) cell(A1) sheetreplace

* bag ID duplicates for stored water sample
foreach i in R_FU1_bag_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU1_bag_ID_stored unique_id_num using "${pilot}Data_quality_R1.xlsx" if R_FU1_bag_ID_stored_Unique!=1, sheet("Dup_bag_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for stored water sample
foreach i in R_FU1_sample_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU1_sample_ID_stored_ID_stored unique_id_num using "${pilot}Data_quality_R1.xlsx" if R_FU1_sample_ID_stored_Unique!=1, sheet("Dup_sample_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for running water sample
foreach i in R_FU1_sample_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU1_sample_ID_tap unique_id_num using "${pilot}Data_quality_R1.xlsx" if R_FU1_sample_ID_tap_Unique!=1, sheet("Dup_sample_ID_tap") firstrow(var) cell(A1) sheetreplace

* Akito->Astha This code I added should be removed, but please properly ensure that the unique ID is unique at the end of the code. 
duplicates drop unique_id_num, force

* Create a variable for cases when Water Quality test didn't happen
save "${DataDeid}1_5_Followup_R1_cleaned.dta", replace
