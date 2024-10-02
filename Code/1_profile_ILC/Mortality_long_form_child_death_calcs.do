


//importing long child datasets 


clear all               
set seed 758235657 // Just in case

cap program drop Mor_key_creation
program define   Mor_key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_Mor_`x'
	}	

end








/* ---------------------------------------------------------------------------
* ID M1 and M2: AGE OF CHILD INFOR 
 ---------------------------------------------------------------------------*/
 * ID M1

//this has screened child death infor

use "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey_sc-consented_pc_sc-start_5_years_pregnant_sc-child_died_repeat_sc.dta", clear

 
Mor_key_creation 

foreach var of varlist *_sc {
    local newname = "sc_" + substr("`var'", 1, length("`var'") - 3)
    rename `var' `newname'
}

foreach var of varlist *_sc_* {
    local newname = "sc_" + subinstr("`var'", "_sc_", "_", .)
    rename `var' `newname'
}

foreach var of varlist sc_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "sc_", "comb_", 1)
    rename `var' `newname'
}

gen Scenario_Type= "Screened"
save "${DataTemp}Mor_temp_childage_screened.dta", replace


 * ID M2

//this has non screened child death infor

use "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey-consented_pc-start_5_years_pregnant-child_died_repeat.dta", clear

Mor_key_creation 

ds name_child name_child_earlier age_child unit_child cause_death* setofchild_died_repeat date_birth date_death

foreach var of varlist `r(varlist)'{
rename `var' comb_`var'
}

gen Scenario_Type= "Non-Screened"
save "${DataTemp}Mor_temp_childage_nonscreened.dta", replace

append using "${DataTemp}Mor_temp_childage_screened.dta"
save "${DataFinal}1_10_Mortality_survey_Dec-Jan_M1_M2.dta", replace

rename key R_mor_key

//get village uniuqe_id stillborn status 

merge m:1 R_mor_key using "${DataFinal}1_1_Mortality_cleaned.dta", keepusing(unique_id_num R_mor_village R_mor_child_stillborn_num_oth_1 R_mor_child_stillborn_num_oth_2 R_mor_child_stillborn_num_1_f R_mor_child_stillborn_num_2_f R_mor_child_stillborn_num_3_f R_mor_child_stillborn_num_4_f R_mor_child_stillborn_num_5_f R_mor_child_stillborn_num_6_f) 



// 2. Manual data

**HHID- 30701119003
**There was an error in the form due to which survey wasn't showing death section for the child if the death has occured and form was already in the edit saved so we had to ask the enum to submit the form without doing death section as it was in edit saved and any update from our side couldn't be incorporated in the edit saved form. We asked them to collect details for death section on a piece of paper which was destroyed later. Form error has been fixed now
replace comb_name_child = "New baby" if comb_name_child == "" & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"


replace comb_name_child_earlier = "New baby" if comb_name_child_earlier == "" & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

replace comb_age_child = 4 if comb_age_child == . & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

replace comb_unit_child = 2 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

replace comb_date_birth = date("24/02/2019", "DMY") if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"


replace comb_date_death = date("27/02/2019", "DMY")  if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"


replace comb_cause_death_999 = 1 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

replace comb_cause_death_diagnosed = 0 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

replace comb_cause_death_str  = "It was a normal delivery and ASHA took the lady to the hospital but child died in the hospital, she wasn't informed about the issue and she could not find that out on her own" if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

**HHID- 30701505008
**There was an error in the form due to which survey wasn't showing death section for the child if the death has occured and form was already in the edit saved so we had to ask the enum to submit the form without doing death section as it was in edit saved and any update from our side couldn't be incorporated in the edit saved form. We asked them to collect details for death section on a piece of paper which was destroyed later. Form error has been fixed now

replace comb_name_child = "New baby" if comb_name_child == "" & unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"


replace comb_name_child_earlier = "New baby" if comb_name_child_earlier == "" & unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"


replace comb_age_child = 1 if comb_age_child == . & unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"


replace comb_unit_child = 2 if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace comb_date_birth = date("10/11/2020", "DMY") if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace comb_date_death = date("10/11/2020", "DMY")  if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace comb_cause_death_999= 1 if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace comb_cause_death_diagnosed = 999 if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace comb_cause_death_str = "Delivery was done in the hospital and child died in the hospital, she wasn't informed about the issue and she could not find that out on her own" if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"



replace _merge  = 3 if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"

replace _merge  = 3 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

keep if _merge == 3

//br if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"


//removing stillborn numbers from it


**Number of total stillborn child
/*egen temp_group = group(unique_id_num)
ds R_mor_child_stillborn_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group*/

bysort unique_id_num : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


egen temp_group = group(unique_id_num)
egen total_stillborn_UID_wise = rowtotal(R_mor_child_stillborn_num_*)


sort unique_id_num 
duplicates tag unique_id_num, gen(dup_tag)
bysort unique_id_num (dup_tag): replace total_stillborn_UID_wise = . if _n > 1



gen deaths_under_one_month = .
replace deaths_under_one_month = 1 if comb_unit_child == 2 & comb_age_child <= 30
replace deaths_under_one_month = 1 if comb_unit_child == 1 & comb_age_child <= 1


gen deaths_from_1st_2nd_month = .
replace deaths_from_1st_2nd_month = 1 if comb_unit_child == 2 & comb_age_child > 30 & comb_age_child <= 60
replace deaths_from_1st_2nd_month = 1 if comb_unit_child == 1 & comb_age_child > 1 & comb_age_child <= 2


gen deaths_from_2nd_3rd_month = .
replace deaths_from_2nd_3rd_month = 1 if comb_unit_child == 2 & comb_age_child > 60 & comb_age_child <= 90
replace deaths_from_2nd_3rd_month = 1 if comb_unit_child == 1 & comb_age_child > 2 & comb_age_child <= 3



gen deaths_from_3rd_4th_month = .
replace deaths_from_3rd_4th_month = 1 if comb_unit_child == 2 & comb_age_child > 90 & comb_age_child <= 120
replace  deaths_from_3rd_4th_month  = 1 if comb_unit_child == 1 & comb_age_child > 3 & comb_age_child <= 4



gen deaths_from_4th_5th_month = .
replace deaths_from_4th_5th_month = 1 if comb_unit_child == 2 & comb_age_child > 120 & comb_age_child <= 150
replace  deaths_from_4th_5th_month  = 1 if comb_unit_child == 1 & comb_age_child > 4 & comb_age_child <= 5


gen deaths_from_5th_6th_month = .
replace deaths_from_5th_6th_month = 1 if comb_unit_child == 2 & comb_age_child > 150 & comb_age_child <= 180
replace  deaths_from_5th_6th_month  = 1 if comb_unit_child == 1 & comb_age_child > 5 & comb_age_child <= 6



gen deaths_from_6th_7th_month = .
replace deaths_from_6th_7th_month = 1 if comb_unit_child == 2 & comb_age_child > 180 & comb_age_child <= 210
replace  deaths_from_6th_7th_month  = 1 if comb_unit_child == 1 & comb_age_child > 6 & comb_age_child <= 7


gen deaths_from_7th_8th_month = .
replace deaths_from_7th_8th_month = 1 if comb_unit_child == 2 & comb_age_child > 210 & comb_age_child <= 240
replace  deaths_from_7th_8th_month  = 1 if comb_unit_child == 1 & comb_age_child > 7 & comb_age_child <= 8


gen deaths_from_1_2_year = . 
replace deaths_from_1_2_year = 1 if comb_unit_child == 3 & comb_age_child >= 1 & comb_age_child <= 2 


gen deaths_from_2_3_year = . 
replace deaths_from_2_3_year = 1 if comb_unit_child == 3 & comb_age_child > 2 & comb_age_child <= 3 

gen deaths_from_3_4_year = . 
replace deaths_from_3_4_year = 1 if comb_unit_child == 3 & comb_age_child > 3 & comb_age_child <= 4


gen deaths_from_4_5_year = . 
replace deaths_from_4_5_year = 1 if comb_unit_child == 3 & comb_age_child > 4 & comb_age_child < 5



collapse (sum) deaths_under_one_month deaths_from_1st_2nd_month deaths_from_2nd_3rd_month deaths_from_3rd_4th_month deaths_from_4th_5th_month deaths_from_5th_6th_month deaths_from_6th_7th_month deaths_from_7th_8th_month deaths_from_1_2_year deaths_from_2_3_year deaths_from_3_4_year deaths_from_4_5_year  total_stillborn_UID_wise, by(R_mor_village)

egen temp_group = group( R_mor_village )
egen total_deaths = rowtotal( deaths_* )
drop temp_group

gen new_deaths_under_one_month  = deaths_under_one_month 
replace new_deaths_under_one_month = deaths_under_one_month - total_stillborn_UID_wise

drop deaths_under_one_month   total_deaths
egen temp_group = group( R_mor_village )
egen new_total_deaths = rowtotal( deaths_* new_deaths_under_one_month )
drop temp_group

rename R_mor_village village

save "${DataTemp}age_at_death_mortality_Dec_jan.dta", replace
