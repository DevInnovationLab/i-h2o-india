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

use "${DataRaw}1_7_Followup_R3.dta", clear
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/


** Drop ID information

*drop   r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_a11_oldmale_name r_cen_address r_cen_saahi_name

foreach x of var * { 
	rename `x' R_FU3_`x' 
} 
drop R_FU3_unique_id_1_check R_FU3_unique_id_3_check R_FU3_unique_id_2_check

* Variable cuts across will not have prefix
* R_FU_hh_code
rename R_FU3_unique_id unique_id_num
destring unique_id_num, replace
format   unique_id_num %15.0gc


*rename certain wate quality test variables
rename R_FU3_tap_bag_id_stored_typed  R_FU3_sample_ID_stored
rename R_FU3_tap_bag_id_running_typed R_FU3_sample_ID_tap
rename R_FU3_tap_bag_running_id R_FU3_bag_ID_tap
rename R_FU3_tap_bag_stored_id R_FU3_bag_ID_stored
rename R_FU3_wq_tap_fc R_FU3_fc_tap
rename R_FU3_wq_chlorine_storedfc R_FU3_fc_stored
rename R_FU3_wq_tap_tc R_FU3_tc_tap
rename R_FU3_wq_chlorine_storedtc R_FU3_tc_stored

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/


  * Formatting dates
    gen FU3_day = day(dofc(R_FU3_starttime))
	gen FU3_month_num = month(dofc(R_FU3_starttime))
	gen FU3_month = word("`c(Mons)'", FU3_month_num)
	gen submission_date = dofc(R_FU3_submissiondate)
	format submission_date  %td
    
	//to change once survey date is fixed - TODO
	
	drop if  submission_date <= mdy(4,5,2024)
	 *keep if (FU3_day >5 & FU3_month_num >=4)  
     egen FU3_date = concat(FU3_day FU3_month)
	 gen FU3_starthour = hh(R_FU3_starttime) 
	 gen FU3_startmin= mm(R_FU3_starttime)
  
     
/*------------------------------------------------------------------------------
	3 Keep relevant entries (2.1 aaa)
------------------------------------------------------------------------------*/
  
  // remove the test data once we have actual data coming in  - TODO
     drop if R_FU3_unique_id_1 == 99999 

	
	
// Capturing  section-wise duration

destring R_FU3_duration_locatehh R_FU3_duration_consent R_FU3_duration_seca R_FU3_duration_secb R_FU3_duration_secc ///
R_FU3_duration_sece R_FU3_duration_end, replace


gen FU3_locatehh_dur= R_FU3_duration_locatehh
gen FU3_consent_dur= R_FU3_duration_consent-R_FU3_duration_locatehh
gen FU3_secA_dur= R_FU3_duration_seca-R_FU3_duration_consent
gen FU3_secB_dur= R_FU3_duration_secb-R_FU3_duration_seca
gen FU3_secC_dur= R_FU3_duration_secc-R_FU3_duration_secb
gen FU3_secE_dur= R_FU3_duration_sece-R_FU3_duration_secc
gen FU3_end_dur= R_FU3_duration_end-R_FU3_duration_sece

local duration FU3_locatehh_dur  FU3_consent_dur FU3_secA_dur FU3_secB_dur FU3_secC_dur  FU3_secE_dur FU3_end_dur 
foreach x of local duration  {
	replace `x'= `x'/60
	rename `x' `x'_min
}

drop R_FU3_duration_locatehh R_FU3_duration_consent R_FU3_duration_seca R_FU3_duration_secb R_FU3_duration_secc  R_FU3_duration_sece 

	
gen FU3_duration_min = FU3_locatehh_dur_min + FU3_consent_dur_min + FU3_secA_dur_min + FU3_secB_dur_min + FU3_secC_dur_min  +  FU3_secE_dur_min + FU3_end_dur_min

/*------------------------------------------------------------------------------
	4 Manual correction in data
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
capture export excel unique_id_num using "${pilot}Data_quality_R3.xlsx" if unique_id_num_NUnique!=1, sheet("Dup_ID_Follow_R3") firstrow(var) cell(A1) sheetreplace
* keep only complete cases
 
 
 
* In case of replacement households, check if the OG id is not the same as the unique_id
  gen str3 FU3_replacement_id_3  = string(R_FU3_replacement_id_3, "%03.0f")
  egen replace_id = concat(R_FU3_replacement_id_1 R_FU3_replacement_id_2 FU3_replacement_id_3)
  destring replace_id, replace force
  gen replace_og_id_err = 0 
  replace replace_og_id_err = 1 if replace_id == unique_id_num
capture export excel replace_id unique_id_num using "${pilot}Data_quality_R3.xlsx" if replace_og_id_err ==1, sheet("Replacement_ID_Follow") firstrow(var) cell(A1) sheetreplace

* to decide what we do when error in entering replacement's OG id? 


* bag ID duplicates for running water sample
foreach i in R_FU3_bag_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU3_bag_ID_tap unique_id_num using "${pilot}Data_quality_R3.xlsx" if R_FU3_bag_ID_tap_Unique!=1, sheet("Dup_bag_ID_tap") firstrow(var) cell(A1) sheetreplace

* bag ID duplicates for stored water sample
foreach i in R_FU3_bag_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU3_bag_ID_stored unique_id_num using "${pilot}Data_quality_R3.xlsx" if R_FU3_bag_ID_stored_Unique!=1, sheet("Dup_bag_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for stored water sample
foreach i in R_FU3_sample_ID_stored {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU3_sample_ID_stored_ID_stored unique_id_num using "${pilot}Data_quality_R1.xlsx" if R_FU3_sample_ID_stored_Unique!=1, sheet("Dup_sample_ID_stored") firstrow(var) cell(A1) sheetreplace

* sample ID duplicates for running water sample
foreach i in R_FU3_sample_ID_tap {
bys `i': gen `i'_Unique=_N
}
capture export excel R_FU3_sample_ID_tap unique_id_num using "${pilot}Data_quality_R3.xlsx" if R_FU3_sample_ID_tap_Unique!=1, sheet("Dup_sample_ID_tap") firstrow(var) cell(A1) sheetreplace

* Akito->Astha This code I added should be removed, but please properly ensure that the unique ID is unique at the end of the code. 
duplicates drop unique_id_num, force

* Create a variable for cases when Water Quality test didn't happen
save "${DataFinal}1_7_Followup_R3_cleaned.dta", replace
