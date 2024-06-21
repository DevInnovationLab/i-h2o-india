clear
set seed 758235657 // Just in case

cap program drop M_key_creation
program define   M_key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_E_`x'
	}	

end


cap program drop RV_key_creation
program define   RV_key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_E_`x'
	}	

end


//child levle dataset merge 
use "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_part1.dta", clear

rename comb_child_comb_caregiver_label Vcomb_child_comb_caregiver_label 

rename comb_child_caregiver_present Vcomb_child_caregiver_present

save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", replace

use "${DataTemp}U5_Child_23_24_part1.dta", clear
merge m:m unique_id comb_child_comb_name_label using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", keepusing(unique_id comb_child_comb_name_label Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present  ) 


br unique_id comb_combchild_index comb_combchild_status comb_child_comb_name_label comb_child_caregiver_present comb_child_comb_caregiver_label Vcomb_child_caregiver_present Vcomb_child_comb_caregiver_label _merge if _merge == 3 & Vcomb_child_caregiver_present == 1
gen to_drop = 1 if Vcomb_child_caregiver_present == 1 & _merge == 3


drop if to_drop == 1

preserve
use "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_part1.dta", clear

keep if comb_child_caregiver_present == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

 
save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta", replace
restore

append using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta"

br unique_id comb_child_comb_name_label comb_main_caregiver_label comb_child_caregiver_present comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_month comb_child_breastfed_days comb_child_care_dia_day if unique_id == "30301109053"

save "${DataFinal}Endline_Child_level_merged_dataset_final.dta", replace 


/*****************************************************************
//women and roster members level merge 
*****************************************************************/



/* ---------------------------------------------------------------------------
* Long indivual data from Main Endline census 
 ---------------------------------------------------------------------------*/
* ID 26 (N=322) All new household members
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
M_key_creation 
keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name ///
      key key3 n_hhmember_name n_u5mother_name_oth n_u5father_name_oth n_relation_oth ///
	  n_dob_date n_dob_month n_dob_year ///
	  n_cbw_age n_all_age 
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen
save "${DataTemp}temp2.dta", replace

********************************************************************************************************************************

//PERFORMING THE DROP AND MERGE HERE  FOR ID 25


* ID 25
//census roster 
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
M_key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen

save "${DataTemp}temp0.dta", replace


//////////////////////////////////////////////////
/*For ID 25 part 2, Endline revisit data is available so we would neeed to perform the drop and merge here*/
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.dta", clear
RV_key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
gen comb_type = 0
save "${DataTemp}temp3.dta", replace


use "${DataTemp}temp3.dta",  clear

rename key R_E_key
//firstly merging it with endline HH level dataset to get which HH were done

merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_instruction) keep(3)
 

rename R_E_instruction V_R_E_instruction
save "${DataTemp}temp3_merged.dta",  replace


use "${DataTemp}temp0.dta", clear
cap drop _merge
append using "${DataTemp}temp2.dta"



/////////////////////////////
preserve
cap drop _merge
merge m:m unique_id using "${DataTemp}temp3_merged.dta", keepusing(unique_id V_R_E_instruction   ) 
//ther merge above tells us that there are no common UIDs between the two which is okay because temp0 dataset has all the available UIDS data and temp3_merged has the data for unavailable UIDs that were re-visited later 
restore
preserve
use "${DataTemp}temp3_merged.dta", clear

keep if V_R_E_instruction == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

 
save "${DataTemp}temp3_merged_final.dta", replace
restore

append using "${DataTemp}temp3_merged_final.dta"


save "${Datatemp}Endline_Main_revisit_Census_roster_merge.dta", replace 

save "${DataFinal}Endline_roster_merged_dataset_final.dta", replace 

//using census women data now  from main endline census 

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
M_key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
	 
rename key R_E_key	 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen
	 
 save "${DataTemp}temp1.dta", replace


 //using new women data from main endline census 
 
 * ID 22
//new women
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
M_key_creation 
//drop if n_resp_avail_cbw==.
//Archi - I commente dthis out because we want all the values
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
rename key R_E_key	 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen
	 
 save "${DataTemp}temp2.dta", replace

use "${DataTemp}temp1.dta", clear
append using "${DataTemp}temp2.dta"
unique R_E_key key3
save "${DataTemp}temp3.dta", replace

 
 //women data from endline revisit survey 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_CBW_followup.dta", clear
RV_key_creation

foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
 gen comb_type = 1
 
 rename key R_E_key
 merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_village_name_str) keep(3) nogen

 save "${DataTemp}temp_women_revisit.dta", replace
 


/*************************************************************
DOING THE MERGE WITH CENSUS WOMEN
*************************************************************/


use "${DataTemp}temp_women_revisit.dta", clear


rename comb_resp_avail_comb Vcomb_resp_avail_comb

save "${DataTemp}temp_women_revisit_part1.dta", replace

use "${DataTemp}temp3.dta", clear
cap drop _merge
merge m:m unique_id comb_name_comb_woman_earlier using "${DataTemp}temp_women_revisit_part1.dta", keepusing(unique_id Vcomb_resp_avail_comb) 


br unique_id comb_preg_index comb_name_comb_woman_earlier comb_resp_avail_comb Vcomb_resp_avail_comb _merge if _merge == 3 & Vcomb_resp_avail_comb == 1

gen to_drop = .
replace to_drop = 1 if _merge == 3 & Vcomb_resp_avail_comb == 1

drop if to_drop == 1

preserve
use "${DataTemp}temp_women_revisit.dta", clear

save "${DataTemp}temp_women_revisit_part2.dta", replace

keep if comb_resp_avail_comb == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}
 
save "${DataTemp}temp_women_revisit_part3.dta", replace
restore

append using "${DataTemp}temp_women_revisit_part3.dta"
drop _merge

save "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", replace 
 
 
 
 
 
 
 
 
