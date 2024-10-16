/*=========================================================================
Project information at: https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: To assess the impact of clean drinking water initiatives.
****** Created by: Development Innovation Lab (DIL)
****** Used by: Development Innovation Lab (DIL)
****** Input data:
	•	Medical_expenditure_person.dta
	•	1_8_Endline/1_8_Endline_Census_cleaned_consented.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta
	•	1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-Cen_child_followup.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-N_child_followup.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta
	•	1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta
	•	1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta
	•	1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta
	•	1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_all.dta
	•	1_8_Endline/1_8_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta
	•	1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta
	•	1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta
	•	1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta
	•	India ILC_Pilot_Rayagada Village Tracking_clean.dta
	•	1_8_Endline/1_8_Endline_Census_cleaned_consented.dta
	
****** Output data:
	•	Medical_expenditure_person_HH.dta
	•	Mortality_19_20.dta
	•	U5_Child_23_24_part1.dta : Check with Archi. Is this used for pre-loading?
	•	U5_Child_23_24.dta
	•	Morbidity_23_24.dta
	•	Medical_expenditure_person.dta
	•	Endline_Long_Indiv_analysis.dta
	•	Medical_expenditure_person_case.dta
	•	Medical_expenditure_person_clean.dta
	•	Medical_expenditure_person_case_clean.dta
****** Language: English
****** Date: [Insert Date]
****** Version: 1.0

=========================================================================
** In this do file: This do file exports cleaned data for the Endline survey.
Steps:
	1.	Import raw survey data.
	2.	Clean and preprocess the data.
	3.	Generate summary statistics.
	4.	Export the cleaned data for further analysis.
=========================================================================
*/

/*Questions for Akito- 

Before ${DataTemp}U5_Child_23_24.dta gets created merge is happening using merge m:m parent_key key3 using "${DataTemp}Requested_long_backcheck1.dta", keepusing(comb_hhmember_age) keep(1 3) nogen

I chnaged it to m:m because this is along dataset and this earlier was 1:1 so why did we use 1:1 I could be wrong that is why I wnat to confirm with you 

*/


clear all               
set seed 758235657 // Just in case

cap program drop key_creation
program define   key_creation

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

* Variable label
* Cen_Typel 1 "n_all" 2 "n_cbw" 3 "cen_cbw" 4 "cen_u5" 5 "n_u5" 6 "cen_all", modify


* This is the general population
use "${DataTemp}Medical_expenditure_person.dta", clear
 keep key comb_med_seek_val_comb
 gen flag=1
 collapse  (sum) flag, by(key)
 save "${DataTemp}Medical_expenditure_person_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", clear
split R_E_cen_resp_label, p(" and ")
keep R_E_r_cen_a1_resp_name R_E_cen_resp_label1
gen Name_Same=0
replace Name_Same=1 if R_E_r_cen_a1_resp_name==R_E_cen_resp_label1

use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", clear
* Available for intervew
* HH is 392
foreach var of varlist R_E_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "R_E_", "", 1)
    rename `var' `newname'
}

gen     Any_seek=1
replace Any_seek=0 if (cen_med_seek_all=="" | cen_med_seek_all=="21") & (n_med_seek_all=="" | n_med_seek_all=="21")
keep Any_seek cen_med_seek_all cen_med_seek_all key
merge 1:1 key using "${DataTemp}Medical_expenditure_person_HH.dta", gen(Merge_MasterSick)
tab Merge_MasterSick Any_seek,m
replace Any_seek=2 if Any_seek==0 & Merge_MasterSick==3
tab Any_seek

* This is the general population
 
 use "${DataTemp}Medical_expenditure_5_11.dta", clear
 keep key key3 comb_med_out_home_comb_1 comb_med_out_home_comb_2 comb_med_out_home_comb_3 comb_med_out_home_comb_4 comb_med_out_home_comb_5 comb_med_out_home_comb_6 comb_med_out_home_comb_7 comb_med_out_home_comb_8 comb_med_out_home_comb_9 comb_med_out_home_comb_999 comb_med_out_home_comb__77 key
 duplicates drop key key3, force
 rename comb_med_out_home_comb__77 comb_med_out_home_comb_77
reshape long comb_med_out_home_comb_, i(key key3) j(Num) 
keep if comb_med_out_home_comb_==1

/* ---------------------------------------------------------------------------
* ID 19 and 20: Mortality info
 ---------------------------------------------------------------------------*/
 * ID 19
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta", clear
key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=3
save "${DataTemp}temp.dta", replace

* ID 20
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", clear
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=2
append using "${DataTemp}temp.dta"
save "${DataFinal}1_1_Endline_Mortality_19_20.dta", replace


/* ---------------------------------------------------------------------------
* ID 19B and 20B: Child death and birth info
 ---------------------------------------------------------------------------*/
 * ID 19B


use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=3
gen C_entry_type = "BC" 
drop if  comb_name_comb_woman_earlier == ""

save "${DataTemp}temp.dta", replace

* ID 20B
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=2
append using "${DataTemp}temp.dta"
save "${DataFinal}1_1_Endline_Mortality_19B_20B_part2.dta", replace



/* ---------------------------------------------------------------------------
* Long indivual data from the roster
 ---------------------------------------------------------------------------*/
* ID 26 (N=322) All new household members
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
key_creation 
******************************************************************************************
/*
REASON FOR COMMENTING OUT THE KEEP COMMAND BELOW- 
Archi- We should keep all the variables here so that people can selectively drop whatever they don't need. If we keep only specific variables here then if someone else is using this in the future they will face issues  if they want a variable that we didn't keep and they will have to come again to run this. For that reason I am commenting out the command below.*/
**********************************************************************************************
/*keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name ///
      key key3 n_hhmember_name n_u5mother_name_oth n_u5father_name_oth n_relation_oth ///
	  n_dob_date n_dob_month n_dob_year ///
	  n_cbw_age n_all_age */
	  
// List all variables starting with "n_" and if some variables don't have n_ prefix we should attach this prefix as these are all new members so they should be treated with n_ prefix itself. It is fine if keys dont have n_prefix because they are same across the datasets and they will be used as identifiers  
drop if n_hhmember_name == ""
ds namenumber namefromearlier current_year current_month age_years age_months age_years_final age_months_final age_decimal 
foreach var of varlist `r(varlist)' {
rename `var' n_`var'
}
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
save "${DataTemp}temp0.dta", replace

* ID 22 
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
key_creation 
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
	 
drop if  comb_name_comb_woman_earlier == ""
	 
save "${DataTemp}temp1.dta", replace

* New hosuehold member
use "${DataTemp}temp0.dta", clear
merge 1:1 key key3 using "${DataTemp}temp1.dta"
//only missing values dont match
gen Cen_Type=2
* N=141
unique key key3
cap drop _merge
clonevar R_E_key = key 
//after investigating we find that keys that 16 keys that haven't matched in master are the keys that are no longer valid eg- they were training submissions so that is why it is okay if there are mismatches in this. We should just keep _merge == 3 cases
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing (unique_id)  
keep if _merge == 3
drop R_E_key
drop _merge
save "${DataTemp}Requested_long_backcheck1.dta", replace
//stop
* ID 25
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
save "${DataTemp}temp0.dta", replace

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
 key_creation 
//drop if  cen_name_cbw_woman_earlier==""
//Archi - I am commenting this out
 // List all variables starting with "n_"
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
 save "${DataTemp}temp1.dta", replace
 
 * Archi: For some reason 48 women cannot be merged back to the loop
 use "${DataTemp}temp0.dta", clear
 merge 1:1 key key3 using "${DataTemp}temp1.dta", keep(1 3)
unique key key3
gen Cen_Type=3
save "${DataTemp}Requested_long_backcheck2.dta", replace

use "${DataTemp}Requested_long_backcheck1.dta", clear
tab comb_resp_avail_comb_oth
tostring comb_resp_avail_comb_oth, replace
append using "${DataTemp}Requested_long_backcheck2.dta"
* Adding unique ID
rename key R_E_key
/*merge m:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code) keep(3) nogen*/

//Archi - we have to merge this on "${DataPre}1_8_Endline_XXX.dta",

merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code) keep(3) nogen


save  "${DataTemp}Endline_Long_Indiv_analysis.dta", replace

* New hosuehold member
* "${DataTemp}Requested_long_backcheck1.dta"
* Baseline hosuehold member
* "${DataTemp}Requested_long_backcheck2.dta"

/* ---------------------------------------------------------------------------
* ID 21, 22, 23 and 24: List of U5 and Morbidity for U5 children
 ---------------------------------------------------------------------------*/
 //Archi: Comment for myself - You need to change name of the dataset used in Akito's file and drop entreies where child was unavailable because Akito is using that file for analysis and since we are creating only one version of each dataset we need to make sure whosoever is using that dataset it gets chnaged in their file too 
 
 //PLEASE NOTE THAT THE DATASET  "${DataTemp}U5_Child_23_24_part1.dta" is now being created in 5_1_Endline_main_revisit_merge_final do file. To avoid duplication, I am commenting it out here 

 /*
 * ID 23
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_child_followup.dta", clear
* Respondent available for an interview 
* Discuss
//Archi to Akito - I commented this out so that all values are included 
//Akito to Archi - Do you still wnat to keep this? I want to remove the entry of non-itnerview for analysis, so I want to remove this from dataset. We can create the dataset that includes this if needed (but different data set name)

*keep if cen_child_caregiver_present==1
//Archi to Akito- I am commenting this out again
tab cen_child_caregiver_present
tab cen_child_act_age

key_creation
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=4
gen C_entry_type = "BC" //this variable shows that this is old child entry and was already present in the baseline census 

save "${DataTemp}temp.dta", replace

* ID 24
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_child_followup.dta", clear
key_creation
* Same as above
*keep if n_child_caregiver_present==1
//Archi to Akito- I am commenting this out again

* Add age varible
//Archi - ok adding the AGE variable 
/*merge 1:1 parent_key key3 using "${DataTemp}Requested_long_backcheck1.dta", keepusing(comb_hhmember_age) keep(1 3) nogen*/

foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=5
gen C_entry_type = "N"  //this variable shows that this is new child entry and wasn't already present in the baseline census 
//drop comb_child_care_pres_oth
tostring  comb_child_care_pres_oth, replace
//Archi to Akito - It is better to not drop it 
append using "${DataTemp}temp.dta"
//drop if comb_child_caregiver_present==.
//Archi - I commented this out because we still need names of the unavailable children 
rename key R_E_key
/*merge m:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", keepusing(unique_id R_E_enum_name_label End_date R_E_village_name_res) keep(3) nogen*/

//Archi - In the command above we are merging this data with consented values but if we want to survey unavailable respondents too we have to merge it with "${DataPre}1_8_Endline_XXX.dta"
merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(unique_id R_E_enum_name_label End_date R_E_village_name_str) keep(3) nogen

rename R_E_key  key
//we should not touch the original village variable
clonevar Village = R_E_village_name_str

* Village
//replace Village="Bhujabala" if Village=="Bhujbal"
* Gopi Kankubadi: 30701 (Is this T or C is this Kolnara? Is this panchayatta?)
//save "${DataTemp}U5_Child_Endline_Census.dta", replace

//stop_it
//getting treatment status and stuff
merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)


save "${DataTemp}U5_Child_23_24_part1.dta", replace



/*
*************************************************************************************************
WHY I AM COMMENTING OUT THIS WHOLE PART BELOW ?  😺
************************************************************************************************
Earlier we had created two versions of these datasets because Akito and ARchi were using these appended datasets for different purposes. 
- Akito was using this for analysis 
- Archi was using this for preload creation of revisit 

Issue- For analysis, we want only those observations where child was available and data is present but for preload you need only those child names where the entry was unavailable because only those cases would be re-visited right so these two purposes are opposite so Akito and Archi agreed upon on creating two versions for their uses but now we are done with all these processes so we should make sure there is only 1 version of these datasets so that people don't get confused which one to use for that reason Archi will drop unavailable cases from Akito's do file by using only one version of dataset and replace the name of the dataset wherever required 

Archi will make changes to Akito's file- "GitHub\i-h2o-india\Code\1_profile_ILC\3_5_Descriptive_Endline.do"

----Commented out code starts from here ---------
-------------------------------------------------------
* Respondent available for an interview 
keep if comb_child_caregiver_present==1
//Archi to Akito- I think you want to perform the merge below for analaysis purposes but I am creating another dataset so that any value doesn't get missed out so I am gonna use ${DataTemp}U5_Child_23_24_part1 for re-visit purpose 

//Archi - ok adding the AGE variable 
//Archi to Akito- This dataset Requested_long_backcheck1 should be created long before so if we need age variable we should shift indivudual datset before this 
merge m:m parent_key key3 using "${DataTemp}Requested_long_backcheck1.dta", keepusing(comb_hhmember_age) keep(1 3) nogen

merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)
br unique_id Village if _merge==1

//Archi to Akito- creating a cleaned dataset for you which can be used for data analysis 
keep if comb_child_caregiver_present == 1
save "${DataFinal}1_1_Endline_U5_Child_23_24.dta", replace
savesome using "${DataFinal}1_1_Endline_Morbidity_23_24.dta" if comb_med_out_home_comb!="", replace


*/

*/


/* ---------------------------------------------------------------------------
* ID of the data 5 and 11, 21 and 22
* Out of the 105 HHH 134 sample shows records of  medical care in the past months
* Unit: This is medical care incidence level
* Cen/N and all/CBW
 ---------------------------------------------------------------------------*/
* ID 22 
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
//drop if n_resp_avail_cbw==.
//Archi - I am commenting this out 
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
    }
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=2
save "${DataTemp}temp1.dta", replace

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
*drop if  cen_name_cbw_woman_earlier==""
 key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
    }
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=3
save "${DataTemp}temp2.dta", replace

* ID 5
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta", clear
key_creation
drop if cen_med_seek_val_all==""
// List all variables starting with "cen"
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all* {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=6
save "${DataTemp}temp3.dta", replace

* ID 11
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta", clear
key_creation
drop if n_med_seek_val_all==""
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all* {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=1
append using "${DataTemp}temp1.dta"
tostring comb_resp_avail_comb_oth, replace //AG: made it string 
append using "${DataTemp}temp2.dta"
append using "${DataTemp}temp3.dta"
drop comb_med_seek_ind_comb
unique key
save "${DataTemp}Medical_expenditure_5_11_21_22.dta", replace

use           "${DataTemp}Medical_expenditure_5_11_21_22.dta", clear
append using  "${DataTemp}Morbidity_23_24.dta"
rename key R_E_key
merge m:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", keepusing(unique_id R_E_enum_name_label End_date) keep(3) nogen
rename R_E_key  key
save "${DataTemp}Medical_expenditure_person.dta", replace
erase "${DataTemp}Medical_expenditure_5_11_21_22.dta"

 /* ---------------------------------------------------------------------------
* ID of the data 6 15
* Unit: What amount did ${N_med_name_all} pay for ${N_other_exp_all} at ${N_out_names_all} ?
* At the level of "other" expenses 
 ---------------------------------------------------------------------------*/
* ID 6
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", clear
key_creation

foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
drop if comb_tests_val_comb==""

gen Cen_Type=6
save "${DataTemp}temp.dta", replace

* ID 15
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", clear
key_creation
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
drop if comb_tests_val_comb==""

gen Cen_Type=2
append using "${DataTemp}temp.dta"

drop comb_tests_ind_comb
drop key7 key8 key2 key5 key4
unique key Cen_Type key3 key6 key9
order key Cen_Type key3 key6 key9, first
* This is the item wise
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse (sum) comb_med_otherpay_comb, by(key Cen_Type key3 key6) 
* Now it is collapsed at incidence wise: 71 incidence
save "${DataTemp}Medical_expenditure_6_15.dta", replace

/* ---------------------------------------------------------------------------
* ID 8, 10,  13, and 17
* Unit: Payment for each facility: What amount did ${Cen_med_name_all} pay for ${Cen_other_exp_all} at ${Cen_out_names_all} ?
* Finally I made it to the incidence of sickness level
* U5 and CBW (Both cen and New member)
 ---------------------------------------------------------------------------*/
* ID 17
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.dta", clear 
 drop if n_tests_val_u5==""
key_creation
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)

gen Cen_Type=5
save "${DataTemp}temp1.dta", replace

* ID 10
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta", clear 
drop if cen_tests_val_u5==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)

gen Cen_Type=4
save "${DataTemp}temp1.dta", replace

* ID 8
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.dta", clear
drop if cen_tests_val_cbw==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)
gen Cen_Type=3
save "${DataTemp}temp.dta", replace

* ID 13
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta.dta", clear
drop if n_tests_val_all==""
key_creation

foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}

drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)
gen Cen_Type=1
append using "${DataTemp}temp.dta"
append using "${DataTemp}temp1.dta"
save "${DataTemp}Medical_expenditure_8_10_13_17.dta", replace


/* ---------------------------------------------------------------------------
* ID of the data 4 and 7and 12 and 14 and 18
* Unit: Numeber of individual experienced medical care times Location that they seeked care
 ---------------------------------------------------------------------------*/
* ID 18
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.dta", clear 
drop if n_out_val2_u5==""
drop if n_out_names_u5==""
key_creation
unique key
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=5
save "${DataTemp}temp4.dta", replace

 * ID 9
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta", clear
drop if cen_out_val2_u5==""
key_creation
unique key
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=4
save "${DataTemp}temp3.dta", replace

* ID 7
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta", clear
drop if cen_out_val2_cbw==""
key_creation
unique key
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=3
save "${DataTemp}temp2.dta", replace

 * ID 14
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", clear
drop if n_out_val2_cbw==""
* 5 HH
key_creation
unique key
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=2
save "${DataTemp}temp1.dta", replace

* ID 4
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", clear
drop if cen_out_val2_all==""
key_creation
* 100 HH
unique key
unique parent_key
duplicates tag parent_key, gen(Dup)
// List all variables starting with "cen"
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=6
save "${DataTemp}temp.dta", replace

* ID 12
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", clear
key_creation
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=1

append using "${DataTemp}temp.dta"
append using "${DataTemp}temp1.dta"
append using "${DataTemp}temp2.dta"
append using "${DataTemp}temp3.dta"
append using "${DataTemp}temp4.dta"

	label define Cen_Typel 1 "n_all" 2 "n_cbw" 3 "cen_cbw" 4 "cen_u5" 5 "n_u5" 6 "cen_all", modify
	label values Cen_Type Cen_Typel

 * Create Dummy
	foreach v in comb_med_time_comb {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
	gen comb_med_time=.
replace comb_med_time=comb_med_time_mins_comb if comb_med_time_comb==1
replace comb_med_time=comb_med_time_hrs_comb if comb_med_time_comb==2
replace comb_med_time=. if comb_med_time_comb==999
drop key2 key4 key5
save "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", replace

/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
* Final data creation at the incidence level and indivdual level
 ---------------------------------------------------------------------------*/
 ---------------------------------------------------------------------------*/
  ---------------------------------------------------------------------------*/
 ---------------------------------------------------------------------------*/
use "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", clear
drop if mi(comb_med_illness_other_comb)  // Drop if 'comb_med_illness_other_all' is missing
keep key Cen_Type key3 key6 key_original
merge 1:1 key_original using "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", keep(2 3)

* Come back
duplicates drop key Cen_Type key3 key6,force
* Come back here: There are some _merge==2
merge 1:1 key Cen_Type key3 key6 using "${DataTemp}Medical_expenditure_6_15.dta", gen(Merge_othermed1)
drop if Merge_othermed1==2
* Come back
duplicates drop key Cen_Type key3 key6,force
merge 1:1 key Cen_Type key3 key6 using "${DataTemp}Medical_expenditure_8_10_13_17.dta", gen(Merge_othermed2)
drop if Merge_othermed2==2
rename key R_E_key
merge m:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", keepusing(unique_id R_E_enum_name End_date) keep(3) nogen
rename R_E_key  key
* N=148: Number of incidnce times Location they seeked care

label var comb_med_trans_comb_1 "Walking"
label var comb_med_trans_comb_2 "Bus"
label var comb_med_trans_comb_3 "Car"
label var comb_med_trans_comb_4 "Auto"
label var comb_med_trans_comb_5 "Motorbike"

savesome using "${DataTemp}Medical_expenditure_person_case.dta" if comb_out_val2_comb!="", replace
collapse comb_med_time_comb_3 (sum) comb_med_time, by(key Cen_Type key3)
unique  key key3
* N=134: Number of incidnce for the general population
* Come back
tab Cen_Type,m
merge m:1 key Cen_Type key3 using "${DataTemp}Medical_expenditure_person.dta", gen(Merge_Person_Case) keep(3)


* Create Dummy
	foreach v in Cen_Type {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
label var comb_med_symp_comb_1 "Fever"
label var comb_med_symp_comb_3 "Coughing/respiratory illness"
label var comb_med_symp_comb_12 "Body pain/ache"
label var comb_med_symp_comb_13 "Diarrhea"
label var comb_med_symp_comb__77 "Other"
label var comb_med_where_comb_1 "Home"
label var comb_med_where_comb_2 "Outside of home"

label var comb_med_out_home_comb_1 "Chemist"
label var comb_med_out_home_comb_5 "Community Health Workers"
label var comb_med_out_home_comb_6 "PHC/dispensary/CHC/mobile medical unit"
label var comb_med_out_home_comb_7 "public hospital"
label var comb_med_out_home_comb_8 "private doctor/clinic"

label var comb_med_work_comb "Anyone changed the work/housework"

save "${DataTemp}Medical_expenditure_person_clean.dta", replace

merge 1:m key Cen_Type key3 using "${DataTemp}Medical_expenditure_person_case.dta", nogen

replace comb_med_time_comb=3   if comb_med_where_comb=="1" & (comb_med_time_comb==999 | comb_med_time_comb==.)
replace comb_med_time_comb_999=0 if comb_med_time_comb==3
replace comb_med_time_comb_3=1 if comb_med_time_comb==3
replace comb_med_time=. if comb_med_time_comb==3
replace comb_med_time=. if comb_med_time_comb==999
mdesc comb_med_time_comb_3

label var comb_med_time "Travel time to seek care (mins)" 
label var comb_med_time_comb_3 "Missing (treatment only at home)" 
label var comb_med_treat_type_comb_1 "Treat: Allopathy (english medicines)"
label var comb_med_treat_type_comb_2 "Treat: Indian system of medicine"
label var comb_med_treat_type_comb_3 "Treat: Homoeopathy"
label var comb_med_treat_type_comb_4 "Treat: Yoga and Naturopathy"
label var comb_med_treat_type_comb__77 "Treat: Other"
label var comb_med_treat_type_comb_999 "Treat: Do not know"

label var comb_med_scheme_comb_1 "Expenditure sch: Gov funded insurance"
label var comb_med_scheme_comb_4 "Expenditure sch: Not covered"
label var comb_med_scheme_comb_999 "Expenditure sch: Do not know"

label var comb_med_doctor_fees_comb "doctor fees all: What did .... This is how much?"

save "${DataTemp}Medical_expenditure_person_case_clean.dta", replace

erase "${DataTemp}Medical_expenditure_6_15.dta"
erase "${DataTemp}Medical_expenditure_8_10_13_17.dta"
erase "${DataTemp}Medical_expenditure_4_7_12_14_18.dta"




