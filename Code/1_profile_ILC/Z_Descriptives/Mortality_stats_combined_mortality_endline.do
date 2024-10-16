


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


//Mortality tables start



/*-------------------------------------------------------------------------------------------------------------------------
MORTALITY STATS CONTINUATION USING ENDLINE SURVEYS
**************************************************************

OVERALL APPROACH- Since mortality survey dataset from Jan/Dec is yet to be merged successfully with endline dataset module we have to deal with these datasets separately to create one big table 

Mortality survey in Jan/Dec was only conducted in 4 villages that are as follows-  
"BK Padar" , "Nathma" , "Gopi Kankubadi" , "Kuljing"

so we have to use mortality survey numbers for these 4 villages and append it to the one created using endline dataset mortality module 

---------------------------------------------------------------------------------------------------------------------------*/ 


//child died repeat loop {This dataset has information about the children that died in the endline census so it has their identifiers. Please note that this gets created in the  } 


//this dataset gets created in "1_8_A_Endline_cleaning_HFC_Data_creation" This dataset only contains main endline census data like no revisit observations 
//IMP NOTE: Please note that there is no need to combine revisit dataset with main endline census data here because there were no child deaths found in revisit as a result long datasets for child death is empty 
use "${DataFinal}1_1_Endline_Mortality_19_20.dta", clear

rename key R_E_key

//this step is being done to get valid unique IDs and village name 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str R_E_enum_name_label R_E_resp_available R_E_instruction) 

drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to 

//there are 4 IDs which are in master (mortality dataset) but not in using(main endline dataset) so the explanation for this is below- 
/*
These are all the training IDs of badaalubadi
so we can drop _merge == 1
br if key == "uuid:100f2352-5a9f-430c-bbc2-a12a2deb845b - training ID"
R_E_key
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //training ID 
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //training ID //
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //traaining ID
*/
//

keep if _merge == 3

drop _merge



//EXPLANNATION AS TO WHY THIS NEEDS TO BE DROPPED 

//Archi to investigate this case further Issue is that woman said that no child died but the question still asked for information of the dead child whhc shouldn't be the case. This was a miscarriage case that is why we need to drop it

//Explanation to why this might have happened: 
//miscarriage question was added later due to which two enums thpught miscarriage and stillborn is the same thing which is not that is why this question was added so they went back in the form and changed the stillborn answer to 0 but the loop for child death had started alreaday that is  despite of the constraint this loop still started because they while editing the form they skipped to this section

//that is why you will see that in the women dataset use "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear child dead for these 2 IDs is 0 but still these questions for asked


drop if unique_id== "40301113022" & R_E_key == "uuid:29e4bbf5-a3f2-48a2-93e6-e32c751d834e" 

drop if unique_id== "40301110002" & R_E_key == "uuuid:b9836516-0c12-4043-92e9-36d3d1215961" 




//we want to find the number of kids that are stillborn and they need to be removed from this data so I am attching this variable with wide endline dataset 

preserve

//We are using final merged dataset between main endline census and revisit dataset
//this gets created in the do file - "5_1_Endline_main_revisit_merge_final" 
use "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear

//we are dropping these entries because they are not applicable for child bearing women  
drop if comb_resp_avail_comb == .

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated


//since this dataset also contains revisit data observations so we need to create a nother variable that has keys from both types of observations- one that was main endline census and other that was revisit dataset
gen  merged_key  =  parent_key
replace merged_key  = Revisit_parent_key if merged_key == ""

keep unique_id R_E_village_name_str comb_name_comb_woman_earlier comb_resp_avail_comb comb_child_stillborn_num

bys unique_id: gen Num=_n

//reshaping because we wnat to avoid m:m merge at any cost 
reshape wide  comb_name_comb_woman_earlier comb_resp_avail_comb comb_child_stillborn_num, i(unique_id) j(Num)

save "${DataTemp}Reshaped_wide_CBW_data.dta", replace


//merging these two wide datasets 
use "${DataFinal}Endline_HH_level_merged_dataset_final.dta", clear 


merge 1:1 unique_id using "${DataTemp}Reshaped_wide_CBW_data.dta"

keep if _merge == 3

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated

egen temp_group = group(unique_id)
egen total_stillborn_UID_wise = rowtotal(comb_child_stillborn_num*)

keep unique_id R_E_village_name_str total_stillborn_UID_wise R_E_key comb_name_comb_woman_earlier*

save "${DataTemp}HH_level_stillborn.dta", replace

restore


merge m:1 unique_id using "${DataTemp}HH_level_stillborn.dta"

keep if  _merge == 3

drop _merge

bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


/*comb_name_child_earlier	comb_age_child	comb_unit_child_days	comb_unit_child_months	comb_unit_child_years	comb_dob_date_comb	comb_dob_month_comb	comb_dob_year_comb	comb_dod_date_comb	comb_dod_month_comb	comb_dod_year_comb	comb_cause_death	comb_cause_death_diagnosed	comb_cause_death_str	unique_id	R_E_village_name_str	R_E_enum_name_label	comb_name_comb_woman_earlier1	comb_name_comb_woman_earlier2	comb_name_comb_woman_earlier3	comb_name_comb_woman_earlier4	comb_name_comb_woman_earlier5	comb_name_comb_woman_earlier6	comb_name_comb_woman_earlier7	comb_name_comb_woman_earlier8	comb_name_comb_woman_earlier9	comb_name_comb_woman_earlier10
O	Days	0			8	3	2023	8	3	2023	3	Yes	Pila peta bhitaru mori jaithila	50501109021	Nathma	Jitendra Bagh	Lachhi Nachhika	New baby	Sane Nachhika							


br comb_name_child_earlier comb_age_child comb_unit_child_days comb_unit_child_months comb_unit_child_years comb_dob_date_comb comb_dob_month_comb comb_dob_year_comb comb_dod_date_comb comb_dod_month_comb comb_dod_year_comb comb_cause_death comb_cause_death_diagnosed comb_cause_death_str unique_id R_E_village_name_str R_E_enum_name_label comb_name_comb_woman_earlier* if comb_name_comb_woman_earlier1 == "Anita Pidika" |comb_name_comb_woman_earlier1 == "Lachhi Nachhika"

unique_id
50501109016
50501109021
*/

//br comb_name_comb_woman_earlier Revisit_R_E_key if unique_id == "50501109016" | unique_id == "50501109021"

//br comb_age_child comb_unit_child_days comb_unit_child_months comb_unit_child_years comb_dob_date_comb  comb_dob_month_comb comb_dob_year_comb comb_dod_date_comb comb_dod_month_comb comb_dod_year_comb comb_dod_concat_comb comb_dob_concat_comb comb_dod_autoage comb_year_comb comb_curr_year_comb comb_curr_mon_comb  comb_age_years_comb comb_age_mon_comb comb_age_years_f_comb comb_age_months_f_comb comb_age_decimal_comb 

//br comb_age_child comb_unit_child_days comb_unit_child_months comb_unit_child_years


//drop if comb_cause_death_3 == 1

//this variable gives them the unit
gen deaths_under_one_month = .
replace deaths_under_one_month = 1 if comb_age_child == 1 & comb_unit_child_days <= 30
replace deaths_under_one_month = 1 if comb_age_child == 2 & comb_unit_child_months <= 1


gen deaths_from_1st_2nd_month = .
replace deaths_from_1st_2nd_month = 1 if comb_age_child == 1 & comb_unit_child_days > 30 & comb_unit_child_days <= 60
replace deaths_from_1st_2nd_month = 1 if comb_age_child == 2 & comb_unit_child_months > 1 & comb_unit_child_months <= 2


gen deaths_from_2nd_3rd_month = .
replace deaths_from_2nd_3rd_month = 1 if comb_age_child == 1 & comb_unit_child_days > 60 & comb_unit_child_days <= 90
replace deaths_from_2nd_3rd_month = 1 if comb_age_child == 2 & comb_unit_child_months > 2 & comb_unit_child_months <= 3



gen deaths_from_3rd_4th_month = .
replace deaths_from_3rd_4th_month = 1 if comb_age_child == 1 & comb_unit_child_days > 90 & comb_unit_child_days <= 120
replace  deaths_from_3rd_4th_month  = 1 if comb_age_child == 2 & comb_unit_child_months > 3 & comb_unit_child_months <= 4



gen deaths_from_4th_5th_month = .
replace deaths_from_4th_5th_month = 1 if comb_age_child == 1 & comb_unit_child_days > 120 & comb_unit_child_days <= 150
replace  deaths_from_4th_5th_month  = 1 if comb_age_child == 2 & comb_unit_child_months > 4 & comb_unit_child_months <= 5


gen deaths_from_5th_6th_month = .
replace deaths_from_5th_6th_month = 1 if comb_age_child == 1 & comb_unit_child_days > 150 & comb_unit_child_days <= 180
replace  deaths_from_5th_6th_month  = 1 if comb_age_child == 2 & comb_unit_child_months > 5 & comb_unit_child_months <= 6


gen deaths_from_6th_7th_month = .
replace deaths_from_6th_7th_month = 1 if comb_age_child == 1 & comb_unit_child_days > 180 & comb_unit_child_days <= 210
replace  deaths_from_6th_7th_month  = 1 if comb_age_child == 2 & comb_unit_child_months > 6 & comb_unit_child_months <= 7


gen deaths_from_7th_8th_month = .
replace deaths_from_7th_8th_month = 1 if comb_age_child == 1 & comb_unit_child_days > 210 & comb_unit_child_days <= 240
replace  deaths_from_7th_8th_month  = 1 if comb_age_child == 2 & comb_unit_child_months > 7 & comb_unit_child_months <= 8


gen deaths_from_1_2_year = . 
replace deaths_from_1_2_year = 1 if comb_unit_child_years >=1 & comb_unit_child_years <= 2


gen deaths_from_2_3_year = . 
replace deaths_from_2_3_year = 1 if comb_unit_child_years > 2 & comb_unit_child_years <= 3

gen deaths_from_3_4_year = . 
replace deaths_from_3_4_year = 1 if comb_unit_child_years > 3 & comb_unit_child_years <= 4


gen deaths_from_4_5_year = . 
replace deaths_from_4_5_year = 1 if comb_unit_child_years > 4 & comb_unit_child_years < 5

//stop

//Objective: while merging it replicates the value of variable for eg if the UID = 434433 is coming twice in the master dataset in this case in the child death dataset while matching it with the wide dataset UID it will replicate the value of varaible in the using dataset based on the number of observations in the master for eg if UID = 434433 has two chuld names in master but for that UID in the using no. of stillborn kids is 1 it repeats stillbron value twice so that leads to double couting so we want to avoid that at any cost 
sort unique_id
duplicates tag unique_id, gen(dup_tag)
bysort unique_id (dup_tag): replace total_stillborn_UID_wise = . if _n > 1


preserve
//drop if total_stillborn_UID_wise > 0 
collapse (sum) comb_cause_death_1 comb_cause_death_2 comb_cause_death_3 comb_cause_death_4 comb_cause_death_5 comb_cause_death_6 comb_cause_death_7 comb_cause_death_8 comb_cause_death_9 comb_cause_death_10 comb_cause_death_11 comb_cause_death_12 comb_cause_death_13 comb_cause_death_14 comb_cause_death_15 comb_cause_death_16 comb_cause_death_17 comb_cause_death_18 comb_cause_death__77 comb_cause_death_999 comb_cause_death__98

label variable comb_cause_death_1 "Pneumonia" 
label variable comb_cause_death_2 "Other_respiratory infections (like excessive cough, etc)"
label variable comb_cause_death_3 "Birth complications (premature, stillborn, etc)" 
label variable comb_cause_death_4 "Dengue"
label variable comb_cause_death_5 "Diarrheal illness"
label variable comb_cause_death_6 "Injury/accident"
label variable comb_cause_death_7 "Malaria"
label variable comb_cause_death_8 "Tuberculosis"
label variable comb_cause_death_9 "Malnutrition and other nutritional deficiencies"
label variable comb_cause_death_10 "Anemia"
label variable comb_cause_death_11 "Bacterial meningitis"
label variable comb_cause_death_12 "Birth asphyxia"
label variable comb_cause_death_13 "Jaundice"
label variable comb_cause_death_14 "Low birth weight"
label variable comb_cause_death_15 "Measles"
label variable comb_cause_death_16 "Septicemia"
label variable comb_cause_death_17 "Other bleeding disorders"
label variable comb_cause_death_18 "Other congenital malformations"
label variable comb_cause_death__77 "Other"
label variable comb_cause_death_999 "Don't know" 
label variable comb_cause_death__98 "Refused to answer" 


xpose, clear varname

rename _varname categories
rename v1 numbers 

order categories numbers

replace categories = "Pneumonia" if categories == "comb_cause_death_1"
replace categories =  "Other_respiratory infections (like excessive cough, etc)" if categories == "comb_cause_death_2"
replace categories =  "Birth complications (premature, stillborn, etc)" if categories == "comb_cause_death_3"
replace categories =  "Dengue" if categories == "comb_cause_death_4"
replace categories =  "Diarrheal illness" if categories == "comb_cause_death_5"
replace categories =  "Injury/accident" if categories == "comb_cause_death_6"
replace categories =  "Malaria" if categories == "comb_cause_death_7"
replace categories =  "Tuberculosis" if categories == "comb_cause_death_8"
replace categories =  "Malnutrition and other nutritional deficiencies" if categories == "comb_cause_death_9"
replace categories =  "Anemia" if categories == "comb_cause_death_10"
replace categories =  "Bacterial meningitis" if categories == "comb_cause_death_11"
replace categories =  "Birth asphyxia" if categories == "comb_cause_death_12"
replace categories =  "Jaundice" if categories == "comb_cause_death_13"
replace categories =  "Low birth weight" if categories == "comb_cause_death_14"
replace categories =  "Measles" if categories == "comb_cause_death_15"
replace categories =  "Septicemia" if categories == "comb_cause_death_16"
replace categories =  "Other bleeding disorders" if categories == "comb_cause_death_17"
replace categories =  "Other congenital malformations" if categories == "comb_cause_death_18"
replace categories =  "Other" if categories == "comb_cause_death__77"
replace categories =  "Don't know" if categories == "comb_cause_death_999"
replace categories =  "Refused to answer" if categories == "comb_cause_death__98"


restore

//putting some checks for DOB and DOD


collapse (sum) deaths_under_one_month deaths_from_1st_2nd_month deaths_from_2nd_3rd_month deaths_from_3rd_4th_month deaths_from_4th_5th_month deaths_from_5th_6th_month deaths_from_6th_7th_month deaths_from_7th_8th_month deaths_from_1_2_year deaths_from_2_3_year deaths_from_3_4_year deaths_from_4_5_year total_stillborn_UID_wise, by( R_E_village_name_str)
egen temp_group = group( R_E_village_name_str )
egen total_deaths = rowtotal( deaths_* )
drop temp_group
br R_E_village_name_str total_deaths

//the variable below removes stillborn cases 
gen new_deaths_under_one_month  = deaths_under_one_month 
replace new_deaths_under_one_month = deaths_under_one_month - total_stillborn_UID_wise

drop deaths_under_one_month   total_deaths
egen temp_group = group( R_E_village_name_str )
egen new_total_deaths = rowtotal( deaths_* new_deaths_under_one_month )
drop temp_group

//remove stillborn from this

//bada bhujbal

rename R_E_village_name_str village

drop if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"

save "${DataTemp}age_at_death_endline_census.dta", replace






/*************************************************************
// IMPORTING ENDLINE CENSUS DATA 

Objective: 
1. Endline dataset will give us number of housheholds present in the respective village alongwith housheolds available to provide answers 

2. For this purpose, we can use endline merged dataset only (that is main endline census and revisit dataset to get this number)

**************************************************************/



//Archi - This dataset gets created in the R script- "i-h2o-india\Code\1_profile_ILC\3_1_Endline_datasets_merge.R"

use "${DataFinal}Endline_HH_level_merged_dataset_final.dta", clear 

//Archi- Please note that these observations have also been removed in main endline and baseline datasets so we must drop here 

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated

gen total_households = 1

gen total_avail_households = .
replace total_avail_households = 1 if R_E_resp_available == "1"
replace total_avail_households = 0 if total_avail_households == . 

drop village
rename R_E_village_name_str village
keep village total_households total_avail_households

//this excel sheet is going to be merged later that is why we are epxorting it

export excel village total_households total_avail_households using "${DataTemp}Mortality_quality_all_villages.xlsx", sheet("EL_HH_stats") sheetreplace firstrow(varlabels)



/*************************************************************
// IMPORTING BASELINE CENSUS DATA TO GET SCREEND IDS

Objective: Please note that mortality survey in Dec/Jan was adminsitered to all the housheolds in the village but in endline census mortality module was administered to only screened households.

Definition of Screened hosueholds: 

Screened households are those where in baseline census pergnant women or U5 children were present so in endline census we conducted surveys only in these households 
**************************************************************/

//to find screened IDs
use  "${DataPre}1_1_Census_cleaned.dta", clear

 drop if R_Cen_consent != 1
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to 

rename R_Cen_village_str village

keep C_Screened village

collapse(sum) C_Screened, by (village)

save "${DataTemp}BL_Mortality_qualityscreened_dta.dta", replace

//Archi- Please read the overall approach paragrpah tp understand why are we creating a separate datasets for these 4 villages 

keep if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"

save "${DataTemp}BL_Mortality_qualityscreened_4_vill.dta", replace



/*************************************************************
// IMPORTING AVAILBILITY AND SCREENED DATA FOR ALL VILLAGES

Objective: We want to create an appended file containing availability stats of villages and their screend IDs
**************************************************************/


import excel "${DataTemp}Mortality_quality_all_villages.xlsx", sheet("EL_HH_stats") firstrow clear


collapse (sum) total_households total_avail_households, by (village)

merge 1:1 village using "${DataTemp}BL_Mortality_qualityscreened_dta.dta"


//these villages are dropped because these are extras and we aren't dealing with this anymore 
drop if village == "Badaalubadi" | village == "Hatikhamba" 

drop _merge

save "${DataTemp}Mortality_BL_EL_HH_stats.dta", replace




/****************************************************
AGE DISTRIBUTION OF THE CHILDREN WHO ARE ALIVE

Ojective: We need to get the number of kids present in every age group who are under 5 

**********************************************************/

//this gets created in the file - "GitHub\i-h2o-india\Code\1_profile_ILC\Z_preload\Endline_census_Preload.do"

import excel "${DataPre}Endline_census_u5child_preload.xlsx", sheet("Sheet1") firstrow clear


//dropping it as it is empty
drop R_Cen_u5_child_pre_1


//creating a long dataset 
reshape long R_Cen_u5_child_pre_ R_Cen_a6_hhmember_age_ , i(unique_id) j(reshaped)

drop if R_Cen_u5_child_pre_ == "" //this step makes sure that we are only keeping names of the U5 child


//OBJECTIVE of the step below: we need to exclude those children from baseline census who no longer fall in the criteria. This is denoted by variable comb_child_caregiver_present. This variable has an option 8 which asks enum to mark those entries where the kid no longer falls in the U5 criteria. So, we are creating the dataset containing these entries to merge with the preload dataset above to drop such entries from getting counted
 
preserve
//this dataset gets created in the file- "GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning_HFC_Data creation.do"
use "${DataTemp}U5_Child_23_24_part1.dta", clear
drop if comb_child_comb_name_label == ""
br comb_child_breastfeeding comb_child_breastfed_num comb_child_age unique_id comb_child_comb_name_label  if comb_child_age > 5 & comb_child_age != .
*TROUBLESHOOTING
//Archi to do - after browsing I found this one case where child name "Krish Gouda" is marked as 6 years of age but in the variable comb_child_breastfed_num  (A45.1) Up to which months was ${N_child_u5_name_label} exclusively breastfed?) enum has marked the option - 888 (Child is still being breastfed) so this has to be corrected. 

replace comb_child_age = 0.5 if comb_child_comb_name_label == "Krish Gouda" & comb_child_breastfed_num == 888 & comb_child_age == 6 & unique_id == "40301108016" & parent_key == "uuid:dbf4f7ec-4c08-49b9-a147-41798f285168" 

keep if comb_child_caregiver_present == 8
rename comb_child_comb_name_label  R_Cen_u5_child_pre_ 
keep unique_id comb_child_caregiver_present R_Cen_u5_child_pre_

bys unique_id: gen Num=_n

//reshaping because we wnat to avoid m:m merge at any cost 
reshape wide  R_Cen_u5_child_pre_ comb_child_caregiver_present, i(unique_id) j(Num)

rename R_Cen_u5_child_pre_1 R_Cen_u5_child_pre_ 
rename  comb_child_caregiver_present1 comb_child_caregiver_present
save "${DataTemp}U5_cases_to_be_excluded.dta", replace
restore 

//I am doing m:m merge with 2 variables as key unique_id R_Cen_u5_child_pre_ since this is a long dataset so we need to make sure that only eligible names are dropped and unecessary values aren't dropped
merge m:1 unique_id R_Cen_u5_child_pre_  using"${DataTemp}U5_cases_to_be_excluded.dta", gen (match) keepusing(unique_id R_Cen_u5_child_pre_ comb_child_caregiver_present )


//we have to drop these matched entries because these are the cases where U5 child is now no longer in the criteria
drop if match == 3

drop match

//importing new member roster to get ages of new child 
preserve
use "${DataFinal}Endline_New_member_roster_dataset_final.dta", clear
keep if comb_hhmember_age < 5
keep unique_id comb_hhmember_name comb_hhmember_age 
rename comb_hhmember_name R_Cen_u5_child_pre_
rename comb_hhmember_age R_Cen_a6_hhmember_age_ 
save "${DataTemp}New_U5_cases_for_append.dta", replace
restore

//we need to append new child data into this to get list of all kids
append using "${DataTemp}New_U5_cases_for_append.dta"


//mergingto get village names 
merge m:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", gen(vill_m) keepusing(R_E_village_name_str)

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated


keep if R_Cen_u5_child_pre_ != ""

keep if vill_m == 3

drop vill_m


*Generating indicator variables for each unique value of variables specified in the loop
foreach v in R_Cen_a6_hhmember_age_ {
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

collapse (sum) R_Cen_a6_hhmember_age__0 R_Cen_a6_hhmember_age__1 R_Cen_a6_hhmember_age__2 R_Cen_a6_hhmember_age__3 R_Cen_a6_hhmember_age__4, by( R_E_village_name_str)

rename R_E_village_name_str village


preserve
//creating a separate dataset for 4 villages that were surveyed in dec/jan
keep if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"
save "${DataTemp}total_U5_BL_EL_ages_breakdown_only4vill.dta", replace
restore

drop if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"


save "${DataTemp}total_U5_BL_EL_ages_breakdown.dta", replace





/****************************************************
NUMBER OF U5 ALIVE U5 CHILDREN 

Ojective: Since those housheolds in endline census where HH was unavailable that entry variable for U5 child would be empty from basleine census (R_E_cen_num_childbelow5 ) as it would be marked as missing irrespective of the caregiver of U5 child presnet here that's why we need to get the correct estimate of U5 presnet that is why we need to import the preload and match it on UID to get exact number of U5 for each UID 


**********************************************************/

//this gets created in the file - "GitHub\i-h2o-india\Code\1_profile_ILC\Z_preload\Endline_census_Preload.do"


import excel "${DataPre}Endline_census_u5child_preload.xlsx", sheet("Sheet1") firstrow clear


//dropping it as it is empty
drop R_Cen_u5_child_pre_1



merge 1:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", gen(match) keepusing(R_E_village_name_str R_E_cen_num_childbelow5 R_E_child_u5_list_preload R_E_n_children_below5 R_E_n_num_childbelow5 R_E_resp_available R_E_instruction)


drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to 


/*Archi these are the variables notifying to us the absoulte numbers of U5:  

R_E_cen_num_childbelow5 - shows number of U5 child from baseline census 
R_E_n_num_childbelow5 - shows number of new U5 added in endline census new roster 

The dataset "${DataFinal}1_8_Endline_Census_cleaned.dta" is created in "GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning.do"

*/


/*OBJECTIVE : 

We are creating a combined variable showing number of U5 that are presnet at every ID. Variables with these prefix R_Cen_u5_child_pre_* have exact names of the U5 at every ID but for calculations we need to work with numeric variables si that is why we are creating numeric variable with n_ prefix which assigns 1 wherever a string entry is presnet this way we are tracking at every ID how ,many U5 are presnet. We have to do this as this is a wide dataset  
*/

egen temp_group = group(unique_id)

ds R_Cen_u5_child_pre_*
foreach var of varlist `r(varlist)'{
gen n_`var' = 0
replace n_`var' = 1 if `var' != ""
}
egen total_U5_BL = rowtotal(n_R_Cen_u5_child_pre_*)
drop temp_group

//currently this variable total_U5_BL  only has information about baseline census U5 but we also need to add new U5 that we found in endline census to have consistent numbers 

destring R_E_n_num_childbelow5, replace
replace R_E_n_num_childbelow5 = 0 if R_E_n_num_childbelow5 == .

egen total_U5_BL_EL = rowtotal(total_U5_BL R_E_n_num_childbelow5)


keep unique_id R_E_cen_num_childbelow5 R_E_n_num_childbelow5 total_U5_BL_EL R_E_resp_available R_E_instruction R_E_village_name_str

collapse (sum) total_U5_BL_EL, by (R_E_village_name_str)

rename R_E_village_name_str village

save "${DataTemp}total_U5_BL_EL.dta", replace



/*************************************************************
//merging this dataset with long endline dataset that has U5 infor 

OBJECTIVE: In endline census module we have an opion to mark those U5 child from baseline census as "U5 child no longer falls in the criteria (less than 5 years)" if their age was incorrectly recorded in baseline census so in that case we didn't survey those U5 child so we must remove them from our final numbers. To identidy such women we need to look at the variable comb_child_caregiver_present. If this is equal to 8 then that means these U5 kids are outside of eligibility criteria  
****************************************************************/

//this dataset gets created in "i-h2o-india\Code\1_profile_ILC\5_1_Endline_main_revisit_merge_final.do"

//We are using final merged dataset between main endline census and revisit dataset
use "${DataFinal}Endline_Child_level_merged_dataset_final.dta", clear


gen exclude_U5_BL = 0
replace exclude_U5_BL = 1 if comb_child_caregiver_present == 8
drop village
rename Village village

replace village = "Bhujbal"  if village == "Bhujabala" 

collapse (sum) exclude_U5_BL, by (village)

//merging this with dataet created earlier that shows total number of U5 child everywere 


merge 1:1 village using "${DataTemp}total_U5_BL_EL.dta"

gen final_U5_BL_EL = total_U5_BL_EL

replace final_U5_BL_EL  = total_U5_BL_EL - exclude_U5_BL if  exclude_U5_BL != 0

drop _merge


preserve
//creating a separate dataset for 4 villages that were surveyed in dec/jan
keep if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"
keep village final_U5_BL_EL
rename final_U5_BL_EL Total_U5
save "${DataTemp}adjusted_total_U5_BL_EL_only4vill.dta", replace
restore

drop if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"

keep village final_U5_BL_EL

rename final_U5_BL_EL Total_U5

save "${DataTemp}adjusted_total_U5_BL_EL.dta", replace






/********************************************************************************************************
// IMPORTING MORTALITY SURVEY DATA 

Objective: We need to extract variables  for those 4 villages where survey was conducted in dec-jan to be able to append this to the endline census dataset villages  
*******************************************************************************************************/


//getting respondent wise unavailability stats from mortality survey 

//This directory is personal- You can find the path to this in ILC India directory file 

import excel "${Personal}Mortality_quality.xlsx", sheet("Resp_wise_unavail") firstrow clear

rename Totalavailableeligiblewomen total_avail_CBW
rename EnumeratortofillupVillageN village

keep village total_avail_CBW

save "${DataTemp}Mortality_4_vill_CBW_avail.dta", replace


//this sheet has main mortality numebrs 
import excel "${Personal}Mortality_quality.xlsx", sheet("last_5_preg") firstrow clear


rename Totalchildbearingwomen Total_CBW

keep Total_CBW EnumeratortofillupVillageN Totalwomenpregnantinthelast Totalnoofchildrenwhoareli Totalnoofchildrenwhoareal TotalBirthsinthevillage Totalnoofstillbornchildren Totalnoofchildrendiedwithi Totalnoofchildrendiedafter Totaldeathsinthevillage Totalnoofmiscarriages 

rename Totalwomenpregnantinthelast total_last5preg_CBW


rename EnumeratortofillupVillageN village
rename Totalnoofchildrenwhoareli child_living_num
rename Totalnoofchildrenwhoareal child_notliving_num
rename  TotalBirthsinthevillage total_live_births
rename  Totalnoofstillbornchildren child_stillborn_num
rename Totalnoofchildrendiedwithi child_alive_died_less24_num
rename Totalnoofchildrendiedafter child_alive_died_more24_num
rename Totaldeathsinthevillage total_deaths


save "${DataTemp}Mortality_quality_last_5_preg.dta", replace


//importing in HH availability infor for mortality survey 
import excel "${Personal}Mortality_quality.xlsx", sheet("HH_availability_status") firstrow clear

keep EnumeratortofillupVillageN Totalhouseholdspresent Totalnoofavailablehousehold

rename Totalhouseholdspresent total_households
rename Totalnoofavailablehousehold total_avail_households
rename EnumeratortofillupVillageN village

keep village total_households total_avail_households
save "${DataTemp}Mortality_quality_HH_avail.dta", replace

merge 1:1 village using "${DataTemp}Mortality_quality_last_5_preg.dta"

drop _merge


merge 1:1 village using "${DataTemp}BL_Mortality_qualityscreened_4_vill.dta"

drop _merge

merge 1:1 village using "${DataTemp}Mortality_4_vill_CBW_avail.dta"

drop _merge

merge 1:1 village using "${DataTemp}adjusted_total_U5_BL_EL_only4vill.dta" 

drop _merge

merge 1:1 village using "${DataTemp}total_U5_BL_EL_ages_breakdown_only4vill.dta"

drop _merge
//this is the file that contains all the variables needed for it to be appended with endline census dataset villages

merge 1:1 village using"${DataTemp}age_at_death_mortality_Dec_jan.dta"


save "${DataTemp}Mortality_CBW_HH_avail.dta", replace



/*************************************************************
// IMPORTING ENDLINE CENSUS PRELOAD AND FINDING TOTAL CBW

Ojective: 
Since those housheolds in endline census where HH was unavailable that entry variable for eligible women would be empty from basleine census (R_E_null_cen_num_female_15to49 ) as it would be marked as missing irrespective of the eligible women presnet here that's why we need to get the correct estimate of CBW presnet that is why we need to import the preload and match it on UID to get exact number fo CBW for each UID 
**************************************************************/


//this gets created in the file - "GitHub\i-h2o-india\Code\1_profile_ILC\Z_preload\Endline_census_Preload.do"
import excel "${DataPre}Endline_census_eligiblewomen_preload.xlsx", sheet("Sheet1") firstrow clear

/*Archi these are the variables notifying to us the absoulte numbers of child bearing women:  

R_E_null_cen_num_female_15to49 - shows number of CBW from baseline census 
R_E_null_n_num_female_15to49 - shows number of new CBW added in endline census mortality module 

The dataset "${DataFinal}1_8_Endline_Census_cleaned.dta" is created in "GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning.do"

*/


merge 1:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", gen(match) keepusing(R_E_village_name_str R_E_null_cen_num_female_15to49 R_E_null_n_num_female_15to49 R_E_resp_available R_E_instruction)

drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to 

/*OBJECTIVE : 

We are creating a combined variable showing number of child bearing women that are presnet at every ID. Variables with these prefix R_Cen_eligible_women_pre_* have exact names of the women at every ID but for calculations we need to work with numeric variables si that is why we are creating numeric variable with n_ prefix which assigns 1 wherever a string entry is presnet this way we are tracking at every ID how ,many women are presnet. We have to do this as this is a wide dataset  
*/


egen temp_group = group(unique_id)
//dropping them both as they are empty
drop R_Cen_eligible_women_pre_14 R_Cen_eligible_women_pre_17

ds R_Cen_eligible_women_pre_*
foreach var of varlist `r(varlist)'{
gen n_`var' = 0
replace n_`var' = 1 if `var' != ""
}
egen total_CBW_BL = rowtotal(n_R_Cen_eligible_women_pre_*)
drop temp_group

//currently this variable total_CBW_BL  only has information about baseline census CBW but we also need to add new women that we found in endline census to have consistent numbers 

destring R_E_null_n_num_female_15to49, replace
replace R_E_null_n_num_female_15to49 = 0 if R_E_null_n_num_female_15to49 == .

egen total_CBW_BL_EL = rowtotal(total_CBW_BL R_E_null_n_num_female_15to49)


keep unique_id R_E_null_cen_num_female_15to49 R_E_null_n_num_female_15to49 total_CBW_BL total_CBW_BL_EL R_E_resp_available R_E_instruction R_E_village_name_str

collapse (sum) total_CBW_BL_EL, by (R_E_village_name_str)

rename R_E_village_name_str village

save "${DataTemp}total_CBW_BL_EL.dta", replace


/*************************************************************
//merging this dataset with long endline dataset that has CBW infor 

OBJECTIVE: In endline census module we have an opion to mark those women from baseline census as "No longer eligible" if their age or gender was incorrectly recorded in baselinr census so in that case we didn't survey those women so we must remove them from our final numbers. To identidy such women we need to look at the variable comb_resp_avail_comb. If this is equal to 8 then that means these women are outside of eligibility criteria  
****************************************************************/

//this dataset gets created in "i-h2o-india\Code\1_profile_ILC\5_1_Endline_main_revisit_merge_final.do"

//We are using final merged dataset between main endline census and revisit dataset
use "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear
drop if comb_resp_avail_comb == .


gen exclude_CBW_BL = 0
replace exclude_CBW_BL = 1 if comb_resp_avail_comb == 8

rename R_E_village_name_str village

collapse (sum) exclude_CBW_BL, by (village)

//merging this with dataet created earlier that shows nuber of eligible women everywere 

merge 1:1 village using "${DataTemp}total_CBW_BL_EL.dta"


gen final_CBW_BL_EL = total_CBW_BL_EL

replace final_CBW_BL_EL  = total_CBW_BL_EL - exclude_CBW_BL if exclude_CBW_BL != 0

drop _merge

drop if village == "BK Padar" | village == "Nathma" | village ==   "Gopi Kankubadi" | village == "Kuljing"

keep village final_CBW_BL_EL

rename final_CBW_BL_EL Total_CBW

save "${DataTemp}adjusted_total_CBW_BL_EL.dta", replace

/**************************************************
IMPORTING ENDLINE LONG DATASET FOR CHILD BEARING WOMEN 
**************************************************/
//endline dataset (with revisit data)

//this dataset gets created in "i-h2o-india\Code\1_profile_ILC\5_1_Endline_main_revisit_merge_final.do"

//We are using final merged dataset between main endline census and revisit dataset
use "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear

drop if comb_resp_avail_comb == .

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated

 
ds comb_child_living_num comb_child_notliving_num comb_child_stillborn_num comb_child_alive_died_less24_num comb_child_alive_died_more24_num comb_num_living_null comb_num_notliving_null comb_num_stillborn_null comb_num_less24_null comb_num_more24_null comb_child_died_lessmore_24_num comb_child_died_u5_count

foreach var of varlist `r(varlist)'{
destring `var', replace
}


//since we will be appedning this dataset seprately so we can drop these villages for now
drop if R_E_village_name_str == "BK Padar" | R_E_village_name_str == "Nathma" | R_E_village_name_str ==   "Gopi Kankubadi" | R_E_village_name_str == "Kuljing"

gen total_avail_CBW = .
replace total_avail_CBW = 1 if comb_resp_avail_comb == 1
replace total_avail_CBW = 0 if total_avail_CBW != 1 & comb_resp_avail_comb  != .


gen  total_last5preg_CBW = 0
replace total_last5preg_CBW = 1 if comb_last_5_years_pregnant == 1



//breakdown of deaths in terms of months of child death 

//Village wise


collapse (sum)  comb_child_living_num comb_child_notliving_num comb_child_stillborn_num comb_child_alive_died_less24_num comb_child_alive_died_more24_num total_avail_CBW total_last5preg_CBW , by(R_E_village_name_str)


egen total_live_births = rowtotal(comb_child_living_num comb_child_notliving_num comb_child_alive_died_less24_num comb_child_alive_died_more24_num)

egen total_deaths = rowtotal(comb_child_alive_died_less24_num comb_child_alive_died_more24_num)


label variable total_live_births "Total Births in the village"
label variable total_deaths "Total deaths in the village"

renpfix comb_

rename R_E_village_name_str  village


//firstly merging with this dataset to get housheold availability stats 
merge 1:1 village using "${DataTemp}Mortality_BL_EL_HH_stats.dta"

drop if _merge == 2

rename _merge BL_EL 

//merging to get number of child bearing women 
merge 1:1 village using "${DataTemp}adjusted_total_CBW_BL_EL.dta"

drop _merge

//merging with child level variables to get age breakdown 
merge 1:1 village using "${DataTemp}total_U5_BL_EL_ages_breakdown.dta"

drop if _merge == 2
drop _merge

//merging with child level data to get no. of U5 child 
merge 1:1 village using "${DataTemp}adjusted_total_U5_BL_EL.dta"

drop _merge BL_EL


//merging to get breakdown of child died in different age intervals
merge 1:1 village using  "${DataTemp}age_at_death_endline_census.dta"

drop _merge

//appending with the data of other 4 villages
append using "${DataTemp}Mortality_CBW_HH_avail.dta"

ds deaths_from_* 

foreach var of varlist `r(varlist)'{
replace `var' = 0 if `var' == .
}

//stop

//finding village wise mortality rate

*******************************************************
preserve

keep village total_last5preg_CBW total_live_births total_deaths
gen U5_crude_mortality_rate = (total_deaths/total_live_births)*1000

label variable total_live_births "Total live births in the village\textsuperscript{2}"
label variable total_deaths "Total U5 deaths in the village\textsuperscript{3}"
label variable U5_crude_mortality_rate "U5 child deaths per 1000 live births\textsuperscript{4}"
label variable total_last5preg_CBW "Total eligible women pregnant in the last 5 years\textsuperscript{1}"
label variable village "Village"

foreach var in total_last5preg_CBW total_live_births total_deaths U5_crude_mortality_rate{
replace `var' = round(`var', 0.01)
}


global Variables village total_last5preg_CBW total_live_births total_deaths U5_crude_mortality_rate

//		hlines (10) ///
// 		align(|l|c|c|c|c|) ///



/*replace village = subinstr(village,"Nathma","Nathma*",1)
replace village = subinstr(village,"BK Padar","BK Padar*",1)
replace village = subinstr(village,"Gopi Kankubadi","Gopi Kankubadi*",1)
replace village = subinstr(village,"Kuljing","Kuljing*",1)*/

/*label variable total_live_births "total_live_births\textsuperscript{1}"

label variable total_deaths"total_live_births\textsuperscript{2}"

label variable total_deaths"total_live_births\textsuperscript{2}"*/



texsave $Variables using "${Table}Mortality_Numbers_village_wise.tex", ///
        title("Village-Wise Child Mortality and Birth Statistics") autonumber ///
		footnote(\addlinespace "1: Eligible women or respondents refer to women of childbearing age (15-49 years) \newline 2: Total live births include U5 kids living with respondent, U5 kids alive but not living with the respondent, U5 kids died in less than 24 hours, U5 kids died between 24 hours and the age of 5 years. \newline 3: Total deaths include U5 kids died in less than 24 hours, U5 kids died between 24 hours and at the age 5 years. \newline 4: U5 child deaths per 1000= (Total U5 deaths/Total live births)*1000") replace varlabels frag location(htbp) label(tab:villagewise) 
		
		

export excel using "${Personal}Mortality_quality.xlsx", sheet("aggregate_numbers_village_wise") sheetreplace firstrow(varlabels)

restore


//generating aggregate numbers 
preserve

//gen distribution_of_births = ""

collapse (sum) total_households total_avail_households C_Screened Total_CBW total_avail_CBW total_last5preg_CBW   child_living_num child_notliving_num child_stillborn_num child_alive_died_less24_num child_alive_died_more24_num Total_U5 R_Cen_a6_hhmember_age__0 R_Cen_a6_hhmember_age__1 R_Cen_a6_hhmember_age__2 R_Cen_a6_hhmember_age__3 R_Cen_a6_hhmember_age__4 new_deaths_under_one_month deaths_from_1st_2nd_month deaths_from_2nd_3rd_month deaths_from_3rd_4th_month deaths_from_4th_5th_month deaths_from_5th_6th_month deaths_from_6th_7th_month deaths_from_7th_8th_month deaths_from_1_2_year deaths_from_2_3_year deaths_from_3_4_year deaths_from_4_5_year 


egen total_live_births = rowtotal(child_living_num child_notliving_num child_alive_died_less24_num child_alive_died_more24_num)

egen total_deaths = rowtotal(child_alive_died_less24_num child_alive_died_more24_num)

gen U5_crude_mortality_rate = (total_deaths/total_live_births)*1000

drop child_stillborn_num

//combining categories

gen deaths_from_1st_4th_month =  deaths_from_1st_2nd_month + deaths_from_2nd_3rd_month + deaths_from_3rd_4th_month

gen deaths_under_2_months = new_deaths_under_one_month + deaths_from_1st_2nd_month

gen U2_mortality_rate = (deaths_under_2_months/total_live_births)*1000


order total_households total_avail_households C_Screened Total_CBW total_avail_CBW total_last5preg_CBW child_living_num child_notliving_num  child_alive_died_less24_num child_alive_died_more24_num Total_U5 R_Cen_a6_hhmember_age__0 R_Cen_a6_hhmember_age__1 R_Cen_a6_hhmember_age__2 R_Cen_a6_hhmember_age__3 R_Cen_a6_hhmember_age__4 new_deaths_under_one_month deaths_from_1st_4th_month  deaths_from_1_2_year  total_live_births total_deaths U5_crude_mortality_rate U2_mortality_rate 



drop deaths_from_4th_5th_month deaths_from_5th_6th_month deaths_from_6th_7th_month deaths_from_7th_8th_month deaths_from_2_3_year deaths_from_3_4_year deaths_from_4_5_year deaths_from_1st_2nd_month deaths_from_2nd_3rd_month deaths_from_3rd_4th_month deaths_under_2_months 



/*label variable total_live_births "Total Births in the village"
label variable total_deaths "Total deaths in the village"
label variable U5_crude_mortality_rate "U5 child deaths per 1000 live births"
label variable child_living_num "No. of U5 kids living with the respondent currently"
label variable child_notliving_num "No. of alive U5 kids not living with the respondent currently"
label variable child_stillborn_num "No. of stillborn U5 kids"
label variable child_alive_died_less24_num "No. of kids that died in less than 24 hours"
label variable child_alive_died_more24_num "No. of kids that died after 24 hours"
label variable total_avail_CBW "Total eligible women avaialble to give survey"
label variable Total_CBW "Total child bearing women present"
label variable C_Screened "Screened houseolds"
label variable total_last5preg_CBW "Total eligible women pregnant in the last 5 years"
label variable total_live_births "Total live births"
label variable total_deaths "Total deaths"
label variable U5_crude_mortality_rate "U5 Mortality rate"*/




xpose, clear varname

rename _varname categories
rename v1 numbers 

order categories numbers

replace categories = "Total live births in the village(2)" if categories == "total_live_births"
replace categories = "Total U5 children deaths in the village(3)" if categories == "total_deaths"
replace categories = "U5 children deaths per 1000 live births(4)" if categories == "U5_crude_mortality_rate"
replace categories = "No. of alive U5 children living with the respondent currently" if categories == "child_living_num"
replace categories = "No. of alive U5 children not living with the respondent currently" if categories == "child_notliving_num"
//replace categories = "No. of stillborn U5 kids" if categories == "child_stillborn_num"
replace categories = "No. of children that died in less than 24 hours" if categories == "child_alive_died_less24_num"
replace categories = "No. of children that died after 24 hours" if categories == "child_alive_died_more24_num"
replace categories = "Total eligible women available to give survey" if categories == "total_avail_CBW"
replace categories = "Total eligible women present**" if categories == "Total_CBW"
replace categories = "Total eligible women pregnant in the last 5 years" if categories == "total_last5preg_CBW"

replace categories = "Total screened households" + char(185) if categories == "C_Screened"

replace categories = "Total housheholds present" if categories == "total_households"
replace categories = "Total housheholds available for survey" if categories == "total_avail_households"
replace categories = "No. of alive children of less than 1 year of age" if categories == "R_Cen_a6_hhmember_age__0"
replace categories = "No. of alive children of 1 year of age" if categories == "R_Cen_a6_hhmember_age__1"
replace categories = "No. of alive children of 2 years of age" if categories == "R_Cen_a6_hhmember_age__2"
replace categories = "No. of alive children of 3 years of age" if categories == "R_Cen_a6_hhmember_age__3"
replace categories = "No. of alive children of 4 years of age" if categories == "R_Cen_a6_hhmember_age__4"

replace categories = "No. of children died between 1 year and 2 years of age" if categories == "deaths_from_1_2_year"

replace categories = "U2 months children deaths per 1000 live births" if categories == "U2_mortality_rate" 

//replace categories = "Child died between 1 month and 2 months of age" if categories == "deaths_from_1st_2nd_month"
/*replace categories = "Child died between 2 years and 3 years of age" if categories == "deaths_from_2_3_year"
replace categories = "Child died between 3 years and 4 years of age" if categories == "deaths_from_3_4_year"
replace categories = "Child died between 4 years and 5 years of age" if categories == "deaths_from_4_5_year"*/

//replace categories = "Child died between 2 months and 3 months of age" if categories == "deaths_from_2nd_3rd_month"
//replace categories = "Child died between 3 months and 4 months of age" if categories == "deaths_from_3rd_4th_month"
/*replace categories = "Child died between 4 months and 5 months of age" if categories == "deaths_from_4th_5th_month"
replace categories = "Child died between 5 months and 6 months of age" if categories == "deaths_from_5th_6th_month"
replace categories = "Child died between 6 months and 7 months of age" if categories == "deaths_from_6th_7th_month"
replace categories = "Child died between 7 months and 8 months of age" if categories == "deaths_from_7th_8th_month"*/
replace categories = "No. of children died within 1 month of age" if categories == "new_deaths_under_one_month"

replace categories = "No. of children died between after 1 month and within 4 months of age" if categories == "deaths_from_1st_4th_month" 

replace categories = "Total alive U5 children present" if categories == "Total_U5"

replace numbers = round(numbers, 0.01)


	
global Variables categories numbers
texsave $Variables using "${Table}Mortality_Numbers_all_villages.tex", ///
        hlines (3 6 10  16 19) autonumber ///
        title("Aggregate Mortality numbers")  footnote (\addlinespace "Notes: The table is autocreated by 2_7_Checks_Mortality_survey.do. \newline ** : Eligible women or respondents refer to women of childbearing age (15-49 years). \newline 1: Screened households refer to those where pregnant women or U5 kids are present. This screening was done in baseline census (Sept-Oct 2023). \newline 2: Total live births include U5 kids living with respondent, U5 kids alive but not living with the respondent, U5 kids died in less than 24 hours, U5 kids died between 24 hours and the age of 5 years. \newline 3: Total U5 deaths include U5 kids died in less than 24 hours, U5 kids died between 24 hours and at the age 5 years. \newline 4: U5 child deaths per 1000= (Total U5 deaths/Total live births)*1000 \newline 5: Total no. of stillborn kids = 16")replace varlabels frag location(htbp) headlines() headerlines("&\multicolumn{8}{c}{Categories}") 





export excel using "${Personal}Mortality_quality.xlsx", sheet("aggregate_numbers") sheetreplace firstrow(varlabels)


restore

//correct Rashmita's case of 40301108016
