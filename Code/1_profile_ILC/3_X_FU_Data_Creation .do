
/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creation of final version of merged endline and baseline census dataset (HH Level) and merging it with Final FU dataset 
****** Created by: DIL
****** Last modified by: Niharika Bhagavatula
****** Used by:  DIL
****** Input data : 

****** Output data : 
	
****** Do file to run before this do file


****** Language: English
****** Note on Prefixes used: C_FU: Coded/New Baseline HH Variable; C_FU1: Coded/New Follow up R1 Variable; C_FU2: Coded/New Follow up R2 Variable; C_FU3: Coded/New Follow up R3 Variable; R_FU_: Baseline HH Variable; R_FU1_: Follow up R1 Variable; R_FU2_: Follow up R2 Variable; R_FU3_: Follow up R3 Variable; C_: Coded/New variable common across surveys 


****** Relevant Code files: 
Baseline FU: 1_2_A_Followup_cleaning.do (basic cleaning; Output: ${Intermediate}1_2_Followup.dta) + 2_3_Checks_Follow_Up.R (checks file)
FU R1: 1_5_A_Followup_R1_cleaning.do (basic cleaning; Output: ${Intermediate}1_5_Followup_R1.dta) + 2_3_Checks_Follow_Up_R1.R (checks file)
FU R2: 1_6_A_Followup_R2_cleaning.do (basic cleaning; Output: ${Intermediate}1_6_Followup_R2.dta) + 2_5_Checks_Follow_Up_R2.R (checks file)
FU R3: 1_7_A_Followup_R3_cleaning.do (basic cleaning; Output: ${Intermediate}1_7_Followup_R3.dta) + 2_6_Checks_Follow_Up_R3.R (checks file)

Cleaning done in the above files:
1. Check for duplicates, rename few variables, generating date and month vairables, few manual corrections, quality checks 
*/


/* Unique ID Variables in Follow up datasets:  (Dropped all id variables except unique_id and unique_id_num)
1. UID of Original HH: unique_id_1 unique_id_2 unique_id_3 
2. UID of HH after adjusting the IDs of HHs replaced due to unavailbility of original HH: unique_id
3. UID of Replaced HH: replacement_id_1 replacement_id_2 replacement_id_3 replacement_id
4. UID of Original HH entered for Water testing (not consistent with unique_id, due to SCTO error): unique_id_1_wt unique_id_2_wt unique_id_3_wt
*/

/*Other key variables
village: Name of village
village_id: Id of the village 
*/
*------------------------------------------------------------------------------*-------------------------------------------------------------------*
* Follow Up Round 3 dataset 

********************************************************************************
*** Loading the dataset 
********************************************************************************

*** FU R3 data (Follow up Round 3)
use "${Intermediate}1_7_Followup_R3.dta", clear 

********************************************************************************
*** General changes 
********************************************************************************

* Keeping only obs where respondent was available for survey
keep if R_FU3_resp_available==1 
//21 observations dropped

* Changing the storage type of unqiue ID for consistency 
tostring unique_id_num, gen(unique_id) format(%17.0g)

* Checking for duplicates in unique_id
isid unique_id
//no duplicates 

* Adding variable to identify the round of followup survey 
gen Round=""
replace Round="R_FU3_" 
label var Round "Round of Survey"


********************************************************************************
*** Manual changes 
********************************************************************************

// *** Replacing unique_id with replacement id in cases where HH was replaced due to unavailability of original HH
// //following UIDs were unavailable for survey and were replaced with an alternative HH whose ID was mentioned in var "replacemnt_id"; original UID still stored in unique_id_1 unique_id_2 unique_id_3
// replace unique_id=R_FU3_replacement_id if R_FU3_reason_replacement!=. 
// //20 changes made 
//
// *** Generating new variable for unique_id identifying water testing samples with replacement id in cases where HH was replaced
// //Due to error in survey form, enumerators were unable to enter the ID of replaced HH in replacement_id_1 replacement_id_2 replacement_id_3 
// gen unique_id_wt=unique_id

*** Removing prefix to be able to append data
renpfix R_FU3_

********************************************************************************
*** Recoding and labelling variables for consistency across FU rounds and EL
********************************************************************************

** Primary water source 
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7" in FUs and  Endline; value assigned to "Directly fetched by surface water" changed from "7" in Baseline to "6" in FUs and Endline 
recode water_source_prim (6=11)  //recoding value of option 6 to a placeholder 
recode water_source_prim (7=6) (11=7) //recoding to values consistent with baseline

* Secondary water source
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" chnaged from "7" in Baseline to "6" in Endline 
replace water_source_sec="6" if water_source_sec=="7"

//Renaming the relevant variables to reflect the changes in values  
rename water_source_sec_6 water_source_sec_temp
rename water_source_sec_7 water_source_sec_6
rename water_source_sec_temp water_source_sec_7

** Is the stored water treated
//"No" coded as 2 in follow up surveys & as 0 in endline and baseline; "No stored water" coded as 3 in follow ups & as 2 in endline and baseline
recode water_stored (2=0) (3=2)

** Use of JJM tap for purposes other than drinking 
//values of answer options changes across follow up rounds (variable tap_use is a string var given respondents were allowed to choose multyiple responses. Changing the binary variables created from this string variable instead of the string itself)
rename tap_use_2 tap_use_1
label var tap_use_1 "Use JJM for Cooking"
label define tap_use_1 1 "Yes" 0 "No"
label values tap_use_1 tap_use_1

rename tap_use_3 tap_use_2
label var tap_use_2 "Use JJM for Washing utensils"
label define tap_use_2 1 "Yes" 0 "No"
label values tap_use_2 tap_use_2

rename tap_use_4 tap_use_3
label var tap_use_3 "Use JJM for Washing clothes"
label define tap_use_3 1 "Yes" 0 "No"
label values tap_use_3 tap_use_3

rename tap_use_5 tap_use_4
replace tap_use_4=1 if tap_use_11==1 //including those using jjm water for construction in "cleaning and other hh activities" category
drop tap_use_11 //dropping the var after incorporating responses into "cleaning and other hh activities" category
label var tap_use_4 "Use JJM for Cleaning and other HH activites"
label define tap_use_4 1 "Yes" 0 "No"
label values tap_use_4 tap_use_4

rename tap_use_6 tap_use_5
replace tap_use_5=1 if tap_use_12==1 //including those using jjm water for washroom/toilet in "hygiene and sanitation purposes" category
drop tap_use_12 //dropping the var after incorporating responses into "hygiene and sanitation purposes" category
label var tap_use_5 "Use JJM for Hygiene and Sanitation purposes"
label define tap_use_5 1 "Yes" 0 "No"
label values tap_use_5 tap_use_5 

rename tap_use_7 tap_use_6
label var tap_use_6 "Use JJM for drinking water for animals"
label define tap_use_6 1 "Yes" 0 "No"
label values tap_use_6 tap_use_6

rename tap_use_8 tap_use_7
label var tap_use_7 "Use JJM for Irrigation and Gardening"
label define tap_use_7 1 "Yes" 0 "No"
label values tap_use_7 tap_use_7

rename tap_use_10 tap_use_8
label var tap_use_8 "Use JJM for Puja/Worship"
label define tap_use_8 1 "Yes" 0 "No"
label values tap_use_8 tap_use_8

label var tap_use__77 "Use JJM for Other Purposes"
label define tap_use__77 1 "Yes" 0 "No"
label values tap_use__77 tap_use__77

label var tap_use_999 "Don't know"
label define tap_use_999 1 "Yes" 0 "No"
label values tap_use_999 tap_use_999


** Types of issues with tap water
//Follow up rounds 2 and 3 only had 3 options (cooking related issues, skin related issues and both) but endline had 6 options (including "Other"); recoding the values of options for consistency
recode types_of_issues (1=4) (2=5) (3=6)
label drop types_of_issues
label var types_of_issues "Issues with tap water"
label define types_of_issues 4 "Cooking related" 5 "Skin related" 6 "Both cooking and skin related"
label values types_of_issues types_of_issues

** Reason for not drinking JJM water
//Answer option "(5) Water from Government provided household tap does not taste good", included in FU rounds but not present in Endline and Baseline; recoding to option (7) for consistency with Endline and Baseline data and created new option category in Endline and Baseline data as well 
*recoding the variable 
replace tap_function_noreason="4 7" if tap_function_noreason=="4 5"
replace tap_function_noreason="7" if tap_function_noreason=="5"

*changing the name of binary variable for consistency
rename tap_function_noreason_5 tap_function_noreason_7

*Generating categories for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank  + those who dont drink jjm water because they fetch drinking water from other private water source for consistency with endline dataset
gen tap_function_noreason_5=.
replace tap_function_noreason_5=0 if tap_function_noreason!=""

gen tap_function_noreason_6=.
replace tap_function_noreason_6=0 if tap_function_noreason!=""

*Labelling the variables
label var tap_function_noreason_1 "Tap is broken and doesn't supply water"
label define tap_function_noreason_1 1 "Yes" 0 "No"
label values tap_function_noreason_1 tap_function_noreason_1

label var tap_function_noreason_2 "Water supply is inadequate"
label define tap_function_noreason_2 1 "Yes" 0 "No"
label values tap_function_noreason_2 tap_function_noreason_2

label var tap_function_noreason_3 "Water supply is intermittent"
label define tap_function_noreason_3 1 "Yes" 0 "No"
label values tap_function_noreason_3 tap_function_noreason_3

label var tap_function_noreason_4 "Water is smelly or muddy"
label define tap_function_noreason_4 1 "Yes" 0 "No"
label values tap_function_noreason_4 tap_function_noreason_4

label var tap_function_noreason_5 "Don't have a JJM tap connection"
label define tap_function_noreason_5 1 "Yes" 0 "No"
label values tap_function_noreason_5 tap_function_noreason_5

label var tap_function_noreason_6 "Have other private drinking water source "
label define tap_function_noreason_6 1 "Yes" 0 "No"
label values tap_function_noreason_6 tap_function_noreason_6

label var tap_function_noreason_7 "Water from Government provided household tap does not taste good"
label define tap_function_noreason_7 1 "Yes" 0 "No"
label values tap_function_noreason_7 tap_function_noreason_7





********************************************************************************
*** Renaming variables for consistency across FU rounds and EL
********************************************************************************

rename tap_function_reason_oth reason_nodrink_oth
rename water_treat_when water_treat_freq
rename water_treat_when_1 water_treat_freq_1
rename water_treat_when_2 water_treat_freq_2
rename water_treat_when_3 water_treat_freq_3
rename water_treat_when_4 water_treat_freq_4
rename water_treat_when_5 water_treat_freq_5
rename water_treat_when_6 water_treat_freq_6
rename water_treat_when__77 water_treat_freq__77
rename water_treat_when_oth water_treat_freq_oth
rename tap_function_oth tap_function_reason_oth 
rename tap_use_drinking_yesno jjm_drinking 
rename tap_function_noreason reason_nodrink  
rename tap_use_oth_yesno jjm_yes
rename tap_use jjm_use
rename tap_use_oth jjm_use_oth 
rename general_issue tap_issues
rename types_of_issues tap_issues_type
rename a40_gps_manualaccuracy gps_manualaccuracy
rename a40_gps_manualaltitude gps_manualaltitude 
rename a40_gps_manuallatitude gps_manuallatitude
rename a40_gps_manuallongitude gps_manuallongitude
rename a40_gps_handlatitude gps_handlatitude
rename a40_gps_handlongitude gps_handlongitude
rename water_prim_oth water_source_prim_oth 
rename tap_use__77 jjm_use__77
rename tap_function_noreason__77 reason_nodrink__77

forvalues i=1/999{
	cap rename tap_use_`i' jjm_use_`i'
}

forvalues i=1/999{
	cap rename tap_function_noreason_`i' reason_nodrink_`i'
}


*** Dropping vars not required and generated for quality checks 
drop  FU3_replacement_id_3 replacement_id_3_digit unique_id_3_digit replace_og_id_err replace_id FU3_replacement_id_3 unique_id_num_NUnique unique_id_num_Unique unique_id_3_digit_wt replacement_id_3_digit

*** Removing prefix to be able to append data
renpfix FU3_

*** changing storage type for consistency 
destring source_container_1_*, replace
destring source_container_2_*, replace
destring source_container_3_*, replace
destring source_container_4_*, replace
destring source_container_5_*, replace
destring source_container_6_*, replace
destring source_container_7_*, replace
destring source_container_8_*, replace
destring source_container_9_*, replace
destring source_container_10_*, replace
destring source_container__77_*, replace
destring survey_member_names_count, replace 
destring surveynumber_1, replace 
tostring replacement_id, replace format(%17.0g)

********************************************************************************
*** Saving the intermediate dataset to be used for appending 
********************************************************************************
save "${Intermediate}1_7_Followup_R3_tempclean.dta", replace 






*------------------------------------------------------------------------------*-------------------------------------------------------------------*
* Follow Up Round 2 dataset 

********************************************************************************
*** Loading the dataset 
********************************************************************************

*** FU R2 data (Follow up Round 2)
use "${Intermediate}1_6_Followup_R2.dta", clear 

********************************************************************************
*** General changes 
********************************************************************************

* Keeping only obs where respondent was available for survey
keep if R_FU2_resp_available==1 
//39 observations dropped

* Changing the storage type of unqiue ID for consistency 
tostring unique_id_num, gen(unique_id) format(%17.0g)

* Checking for duplicates in unique_id
isid unique_id
//no duplicates 

* Adding variable to identify the round of followup survey 
gen Round=""
replace Round="R_FU2_" 
label var Round "Round of Survey"


********************************************************************************
*** Manual changes 
********************************************************************************

// * Replacing the unique_id with the replacement id
// //the following UIDs were unavailable for survey and were replaced with an alternative HH whose ID was mentioned in var "replacemnt_id"; original UID still stored in unique_id_num
// replace unique_id=R_FU2_replacement_id if R_FU2_replacement==1 
// //32 changes made 
//
// *** Generating new variable for unique_id identifying water testing samples with replacement id in cases where HH was replaced
// //Due to error in survey form, enumerators were unable to enter the ID of replaced HH in replacement_id_1 replacement_id_2 replacement_id_3 
// gen unique_id_wt=unique_id

*** Removing prefix to be able to append data
renpfix R_FU2_

********************************************************************************
*** Recoding and labelling variables for consistency across FU rounds and EL
********************************************************************************

** Primary water source 
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7" in FUs and  Endline; value assigned to "Directly fetched by surface water" changed from "7" in Baseline to "6" in FUs and Endline 
recode water_source_prim (6=11)  //recoding value of option 6 to a placeholder 
recode water_source_prim (7=6) (11=7) //recoding to values consistent with baseline

* Secondary water source
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" chnaged from "7" in Baseline to "6" in Endline 
replace water_source_sec="6" if water_source_sec=="7"

//Renaming the relevant variables to reflect the changes in values  
rename water_source_sec_6 water_source_sec_temp
rename water_source_sec_7 water_source_sec_6
rename water_source_sec_temp water_source_sec_7

** Is the stored water treated
//"No" coded as 2 in follow up surveys & as 0 in endline and baseline; "No stored water" coded as 3 in follow ups & as 2 in endline and baseline
recode water_stored (2=0) (3=2)

** Use of JJM tap for purposes other than drinking 
//values of answer options changes across follow up rounds (variable tap_use is a string var given respondents were allowed to choose multyiple responses. Changing the binary variables created from this string variable instead of the string itself)
rename tap_use_2 tap_use_1
label var tap_use_1 "Use JJM for Cooking"
label define tap_use_1 1 "Yes" 0 "No"
label values tap_use_1 tap_use_1

rename tap_use_3 tap_use_2
label var tap_use_2 "Use JJM for Washing utensils"
label define tap_use_2 1 "Yes" 0 "No"
label values tap_use_2 tap_use_2

rename tap_use_4 tap_use_3
label var tap_use_3 "Use JJM for Washing clothes"
label define tap_use_3 1 "Yes" 0 "No"
label values tap_use_3 tap_use_3

rename tap_use_5 tap_use_4
replace tap_use_4=1 if tap_use_11==1 //including those using jjm water for construction in "cleaning and other hh activities" category
drop tap_use_11 //dropping the var after incorporating responses into "cleaning and other hh activities" category
label var tap_use_4 "Use JJM for Cleaning and other HH activites"
label define tap_use_4 1 "Yes" 0 "No"
label values tap_use_4 tap_use_4

rename tap_use_6 tap_use_5
replace tap_use_5=1 if tap_use_12==1 //including those using jjm water for washroom/toilet in "hygiene and sanitation purposes" category
drop tap_use_12 //dropping the var after incorporating responses into "hygiene and sanitation purposes" category
label var tap_use_5 "Use JJM for Hygiene and Sanitation purposes"
label define tap_use_5 1 "Yes" 0 "No"
label values tap_use_5 tap_use_5 

rename tap_use_7 tap_use_6
label var tap_use_6 "Use JJM for drinking water for animals"
label define tap_use_6 1 "Yes" 0 "No"
label values tap_use_6 tap_use_6

rename tap_use_8 tap_use_7
label var tap_use_7 "Use JJM for Irrigation and Gardening"
label define tap_use_7 1 "Yes" 0 "No"
label values tap_use_7 tap_use_7

rename tap_use_10 tap_use_8
label var tap_use_8 "Use JJM for Puja/Worship"
label define tap_use_8 1 "Yes" 0 "No"
label values tap_use_8 tap_use_8

label var tap_use__77 "Use JJM for Other Purposes"
label define tap_use__77 1 "Yes" 0 "No"
label values tap_use__77 tap_use__77

label var tap_use_999 "Don't know"
label define tap_use_999 1 "Yes" 0 "No"
label values tap_use_999 tap_use_999


** Types of issues with tap water
//Follow up rounds 2 and 3 only had 3 options (cooking related issues, skin related issues and both) but endline had 6 options (including "Other"); recoding the values of options for consistency
recode types_of_issues (1=4) (2=5) (3=6)
label drop types_of_issues
label var types_of_issues "Issues with tap water"
label define types_of_issues 4 "Cooking related" 5 "Skin related" 6 "Both cooking and skin related"
label values types_of_issues types_of_issues

** Reason for drinking JJM water
//Answer option "(5) Water from Government provided household tap does not taste good", included in FU rounds but not present in Endline and Baseline; recoding to option (7) for consistency with Endline and Baseline data and created new option category in Endline and Baseline data as well 
*recoding the variable 
replace tap_function_noreason="4 7" if tap_function_noreason=="4 5"

*changing the name of binary variable for consistency
rename tap_function_noreason_5 tap_function_noreason_7

*Generating categories for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank  + those who dont drink jjm water because they fetch drinking water from other private water source for consistency with endline dataset
gen tap_function_noreason_5=.
replace tap_function_noreason_5=0 if tap_function_noreason!=""

gen tap_function_noreason_6=.
replace tap_function_noreason_6=0 if tap_function_noreason!=""


*Labelling the variables
label var tap_function_noreason_1 "Tap is broken and doesn't supply water"
label define tap_function_noreason_1 1 "Yes" 0 "No"
label values tap_function_noreason_1 tap_function_noreason_1

label var tap_function_noreason_2 "Water supply is inadequate"
label define tap_function_noreason_2 1 "Yes" 0 "No"
label values tap_function_noreason_2 tap_function_noreason_2

label var tap_function_noreason_3 "Water supply is intermittent"
label define tap_function_noreason_3 1 "Yes" 0 "No"
label values tap_function_noreason_3 tap_function_noreason_3

label var tap_function_noreason_4 "Water is smelly or muddy"
label define tap_function_noreason_4 1 "Yes" 0 "No"
label values tap_function_noreason_4 tap_function_noreason_4

label var tap_function_noreason_5 "Don't have a JJM tap connection"
label define tap_function_noreason_5 1 "Yes" 0 "No"
label values tap_function_noreason_5 tap_function_noreason_5

label var tap_function_noreason_6 "Have other private drinking water source "
label define tap_function_noreason_6 1 "Yes" 0 "No"
label values tap_function_noreason_6 tap_function_noreason_6

label var tap_function_noreason_7 "Water from Government provided household tap does not taste good"
label define tap_function_noreason_7 1 "Yes" 0 "No"
label values tap_function_noreason_7 tap_function_noreason_7


********************************************************************************
*** Renaming variables for consistency across FU rounds and EL
********************************************************************************

rename tap_function_reason_oth reason_nodrink_oth
rename water_treat_when water_treat_freq
rename water_treat_when_1 water_treat_freq_1
rename water_treat_when_2 water_treat_freq_2
rename water_treat_when_3 water_treat_freq_3
rename water_treat_when_4 water_treat_freq_4
rename water_treat_when_5 water_treat_freq_5
rename water_treat_when_6 water_treat_freq_6
rename water_treat_when__77 water_treat_freq__77
rename water_treat_when_oth water_treat_freq_oth
rename tap_function_oth tap_function_reason_oth 
rename tap_use_drinking_yesno jjm_drinking 
rename tap_function_noreason reason_nodrink  
rename tap_use_oth_yesno jjm_yes
rename tap_use jjm_use
rename tap_use_oth jjm_use_oth 
rename general_issue tap_issues
rename types_of_issues tap_issues_type
rename a40_gps_manualaccuracy gps_manualaccuracy
rename a40_gps_manualaltitude gps_manualaltitude 
rename a40_gps_manuallatitude gps_manuallatitude
rename a40_gps_manuallongitude gps_manuallongitude
rename a40_gps_handlatitude gps_handlatitude
rename a40_gps_handlongitude gps_handlongitude
rename water_prim_oth water_source_prim_oth 
rename tap_use__77 jjm_use__77
rename tap_function_noreason__77 reason_nodrink__77

forvalues i=1/999{
	cap rename tap_use_`i' jjm_use_`i'
}

forvalues i=1/999{
	cap rename tap_function_noreason_`i' reason_nodrink_`i'
}

*** Dropping vars not required and generated for quality checks 
drop    FU2_replacement_id_3 replacement_id_3_digit unique_id_3_digit replace_id replace_og_id_err unique_id_num_NUnique unique_id_num_Unique  

*** Removing prefix to be able to append data
renpfix FU2_

*** changing storage type for consistency 
destring source_container_1_*, replace
destring source_container_2_*, replace
destring source_container_3_*, replace
destring source_container_4_*, replace
destring source_container_5_*, replace
destring source_container_6_*, replace
destring source_container_7_*, replace
destring source_container_8_*, replace
destring source_container_9_*, replace
destring source_container_10_*, replace
destring source_container__77_*, replace
destring survey_member_names_count, replace 
destring surveynumber_1 surveynumber_2, replace 
tostring replacement_id, replace format(%17.0g)
tostring tap_use_drinking_oth, replace 
replace tap_use_drinking_oth="" if tap_use_drinking_oth=="." //replacing the missing string value to consistent format 
 
********************************************************************************
*** Saving the intermediate dataset to be used for appending 
********************************************************************************
save "${Intermediate}1_6_Followup_R2_tempclean.dta", replace 





*------------------------------------------------------------------------------*-------------------------------------------------------------------*
* Follow Up Round 1 dataset 

********************************************************************************
*** Loading the dataset 
********************************************************************************

*** FU R1 data (Follow up Round 1)
use "${Intermediate}1_5_Followup_R1.dta", clear 

********************************************************************************
*** General changes 
********************************************************************************

* Keeping only obs where respondent was available for survey
keep if R_FU1_resp_available==1 
//15 observations dropped

* Changing the storage type of unqiue ID for consistency 
tostring unique_id_num, gen(unique_id) format(%17.0g)

* Checking for duplicates in unique_id
isid unique_id
//no duplicates 

* Adding variable to identify the round of followup survey 
gen Round=""
replace Round="R_FU1_" 
label var Round "Round of Survey"


********************************************************************************
*** Manual changes 
********************************************************************************

// * Replacing the unique_id with the replacement id
// //the following UIDs were unavailable for survey and were replaced with an alternative HH whose ID was mentioned in var "replacemnt_id"
// replace unique_id=R_FU1_replacement_id if R_FU1_replacement==1 
// //15 changes made 
//
// *** Generating new variable for unique_id identifying water testing samples with replacement id in cases where HH was replaced
// //Due to error in survey form, enumerators were unable to enter the ID of replaced HH in replacement_id_1 replacement_id_2 replacement_id_3 
// gen unique_id_wt=unique_id

*** Removing prefix to be able to append data
renpfix R_FU1_

********************************************************************************
*** Recoding and labelling variables for consistency across FU rounds and EL
********************************************************************************

** Primary water source 
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7" in FUs and  Endline; value assigned to "Directly fetched by surface water" changed from "7" in Baseline to "6" in FUs and Endline 
recode water_source_prim (6=11)  //recoding value of option 6 to a placeholder 
recode water_source_prim (7=6) (11=7) //recoding to values consistent with baseline

* Secondary water source
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" chnaged from "7" in Baseline to "6" in Endline 
replace water_source_sec="6" if water_source_sec=="7"

//Renaming the relevant variables to reflect the changes in values  
rename water_source_sec_6 water_source_sec_temp
rename water_source_sec_7 water_source_sec_6
rename water_source_sec_temp water_source_sec_7


** Use of JJM tap for purposes other than drinking 
//values of answer options changes across follow up rounds (variable tap_use is a string var given respondents were allowed to choose multyiple responses. Changing the binary variables created from this string variable instead of the string itself)
rename tap_use_2 tap_use_1
label var tap_use_1 "Use JJM for Cooking"
label define tap_use_1 1 "Yes" 0 "No"
label values tap_use_1 tap_use_1

rename tap_use_3 tap_use_2
label var tap_use_2 "Use JJM for Washing utensils"
label define tap_use_2 1 "Yes" 0 "No"
label values tap_use_2 tap_use_2

rename tap_use_4 tap_use_3
label var tap_use_3 "Use JJM for Washing clothes"
label define tap_use_3 1 "Yes" 0 "No"
label values tap_use_3 tap_use_3

rename tap_use_5 tap_use_4
replace tap_use_4=1 if tap_use_11==1 //including those using jjm water for construction in "cleaning and other hh activities" category
drop tap_use_11 //dropping the var after incorporating responses into "cleaning and other hh activities" category
label var tap_use_4 "Use JJM for Cleaning and other HH activites"
label define tap_use_4 1 "Yes" 0 "No"
label values tap_use_4 tap_use_4

rename tap_use_6 tap_use_5
replace tap_use_5=1 if tap_use_12==1 //including those using jjm water for washroom/toilet in "hygiene and sanitation purposes" category
drop tap_use_12 //dropping the var after incorporating responses into "hygiene and sanitation purposes" category
label var tap_use_5 "Use JJM for Hygiene and Sanitation purposes"
label define tap_use_5 1 "Yes" 0 "No"
label values tap_use_5 tap_use_5 

rename tap_use_7 tap_use_6
label var tap_use_6 "Use JJM as drinking water for animals"
label define tap_use_6 1 "Yes" 0 "No"
label values tap_use_6 tap_use_6

rename tap_use_8 tap_use_7
label var tap_use_7 "Use JJM for Irrigation and Gardening"
label define tap_use_7 1 "Yes" 0 "No"
label values tap_use_7 tap_use_7

rename tap_use_10 tap_use_8
label var tap_use_8 "Use JJM for Puja/Worship"
label define tap_use_8 1 "Yes" 0 "No"
label values tap_use_8 tap_use_8

label var tap_use__77 "Use JJM for Other Purposes"
label define tap_use__77 1 "Yes" 0 "No"
label values tap_use__77 tap_use__77

label var tap_use_999 "Don't know"
label define tap_use_999 1 "Yes" 0 "No"
label values tap_use_999 tap_use_999

** Does HH have cooking related issues? 
//(Ask AK and JL --> Should i create a variable tap_issues consistent with EL, and other FUs and replace it with "Yes" for those who said "Yes" to cooking relatd issues + create variable tap_issues_type with one option: cooking? this would allow conistency in var names but will be misleading as well )
//In Endline, FU3, FU2, respondents were asked whether they were facing any issues iwth the tap water and if yes, the type of issues they were facing (one of the options was cooking related issues). In FU1, only the question on whether HH was facing cooking related issues was asked


** Reason for drinking JJM water
//Answer option "(5) Water from Government provided household tap does not taste good", included in FU rounds but not present in Endline and Baseline; recoding to option (7) for consistency with Endline and Baseline data and created new option category in Endline and Baseline data as well 
*changing the name of binary variable for consistency
rename tap_function_noreason_5 tap_function_noreason_7

*Generating categories for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank  + those who dont drink jjm water because they fetch drinking water from other private water source for consistency with endline dataset
gen tap_function_noreason_5=.
replace tap_function_noreason_5=0 if tap_function_noreason!=""

gen tap_function_noreason_6=.
replace tap_function_noreason_6=0 if tap_function_noreason!=""

*Labelling the variables
label var tap_function_noreason_1 "Tap is broken and doesn't supply water"
label define tap_function_noreason_1 1 "Yes" 0 "No"
label values tap_function_noreason_1 tap_function_noreason_1

label var tap_function_noreason_2 "Water supply is inadequate"
label define tap_function_noreason_2 1 "Yes" 0 "No"
label values tap_function_noreason_2 tap_function_noreason_2

label var tap_function_noreason_3 "Water supply is intermittent"
label define tap_function_noreason_3 1 "Yes" 0 "No"
label values tap_function_noreason_3 tap_function_noreason_3

label var tap_function_noreason_4 "Water is smelly or muddy"
label define tap_function_noreason_4 1 "Yes" 0 "No"
label values tap_function_noreason_4 tap_function_noreason_4

label var tap_function_noreason_5 "Don't have a JJM tap connection"
label define tap_function_noreason_5 1 "Yes" 0 "No"
label values tap_function_noreason_5 tap_function_noreason_5

label var tap_function_noreason_6 "Have other private drinking water source "
label define tap_function_noreason_6 1 "Yes" 0 "No"
label values tap_function_noreason_6 tap_function_noreason_6

label var tap_function_noreason_7 "Water from Government provided household tap does not taste good"
label define tap_function_noreason_7 1 "Yes" 0 "No"
label values tap_function_noreason_7 tap_function_noreason_7

********************************************************************************
*** Renaming variables for consistency across FU rounds and EL
********************************************************************************

rename tap_function_reason_oth reason_nodrink_oth
rename water_treat_when water_treat_freq
rename water_treat_when_1 water_treat_freq_1
rename water_treat_when_2 water_treat_freq_2
rename water_treat_when_3 water_treat_freq_3
rename water_treat_when_4 water_treat_freq_4
rename water_treat_when_5 water_treat_freq_5
rename water_treat_when_6 water_treat_freq_6
rename water_treat_when__77 water_treat_freq__77
rename water_treat_when_oth water_treat_freq_oth
rename tap_function_oth tap_function_reason_oth 
rename tap_use_drinking_yesno jjm_drinking 
rename tap_function_noreason reason_nodrink  
rename tap_use_oth_yesno jjm_yes
rename tap_use jjm_use
rename tap_use_oth jjm_use_oth 
rename water_prim_oth water_source_prim_oth 
rename tap_use__77 jjm_use__77
rename tap_function_noreason__77 reason_nodrink__77

forvalues i=1/999{
	cap rename tap_use_`i' jjm_use_`i'
}

forvalues i=1/999{
	cap rename tap_function_noreason_`i' reason_nodrink_`i'
}


*** Dropping vars not required and generated for quality checks 
drop  unique_id_3_digit_wt unique_id_3_digit sample_ID_tap_Unique replacement_id_3_digit replace_og_id_err replace_id FU1_replacement_id_3 unique_id_num_NUnique unique_id_num_Unique  v797  meta1instancename

*** Removing prefix to be able to append data
renpfix FU1_

*** changing storage type for consistency 
destring source_container_1_*, replace
destring source_container_2_*, replace
destring source_container_3_*, replace
destring source_container_4_*, replace
destring source_container_5_*, replace
destring source_container_6_*, replace
destring source_container_7_*, replace
destring source_container_8_*, replace
destring source_container_9_*, replace
destring source_container_10_*, replace
destring source_container__77_*, replace
destring survey_member_names_count, replace 
destring surveynumber_1 surveynumber_2 surveynumber_3 surveynumber_4, replace 
tostring replacement_id, replace format(%17.0g)

********************************************************************************
*** Saving the intermediate dataset to be used for appending 
********************************************************************************
save "${Intermediate}1_5_Followup_R1_tempclean.dta", replace 





*------------------------------------------------------------------------------*-------------------------------------------------------------------*
* Baseline HH Survey/Follow Up Round dataset 

********************************************************************************
*** Loading the dataset 
********************************************************************************

*** Baseline Follow up data (Baseline HH survey)
use "${Intermediate}1_2_Followup.dta", clear 

********************************************************************************
*** General changes 
********************************************************************************

* Keeping only obs where respondent was available for survey
keep if R_FU_resp_available==1 
//15 observations dropped

* Drop responses from back up villages
drop if R_FU_r_cen_village_name_str=="Haathikambha" | R_FU_r_cen_village_name_str=="Badaalubadi"
//20 obs dropped 

* Changing the storage type of unqiue ID for consistency 
tostring unique_id_num, gen(unique_id) format(%17.0g)

* Checking for duplicates in unique_id
isid unique_id
//no duplicates 

* Adding variable to identify the round of followup survey 
gen Round=""
replace Round="R_FU_" 
label var Round "Round of Survey"


// *** Generating new variable for unique_id identifying water testing samples with replacement id in cases where HH was replaced
// //Due to error in survey form, enumerators were unable to enter the ID of replaced HH in replacement_id_1 replacement_id_2 replacement_id_3 
// gen unique_id_wt=unique_id

********************************************************************************
*** Manual Corrections
********************************************************************************

*** Removing prefix to be able to append data
renpfix R_FU_

*** Replacing priamry water source of one respondent (GitHub issue #67 1st point)
//respondent mentioned using commuhnity standpipe as primary water source but there isn't a community standpipe in the village
replace water_source_prim=1 if unique_id=="40201113010"
//1 change made 

*** Flagging false postive observations for chlorine testing section (#GitHub Issue 82)
//Chlorine levels of more than 0.1mg/L were detected in the samples of tap and/or stored water tested for FC/TC in the following cases - flagging these false positive cases in a new variable
//survey_issues=1 : Issues with survey administration; survey_issues=2: False positive results 
gen survey_issues=.
replace survey_issues=2 if unique_id=="20201113046" | unique_id=="40401110005" | unique_id=="30202119003" | unique_id=="30202119038" | unique_id=="30301119022" | unique_id=="50201115018" | unique_id=="50501115027" | unique_id=="10101113030" | unique_id=="30602119010" | unique_id=="40201111012" | unique_id=="10101113017"

label var survey_issues "Issues with survey administration"
label define survey_issues 1 "Some survey sections not administered" 2 "False positive results"
label values survey_issues survey_issues

********************************************************************************
*** Recoding and labelling variables for consistency across FU rounds and EL
********************************************************************************

** Secondary water source
//Data for this variable is not present in data as the question was disabled in SCTO form - Coding error 
//Data present in Baseline Census survey for this var - data for Baseline census collected a few days before Baseline HH survey was launched

** Quantity of Water that came out of primary water source in past week
//The text of the answer options changed across surveys: Baseline HH survey: (1)All of it; (2)Most of it; (3)Half of it; (4)Little of it; (5)None of it; (999)Don't know. FU1, 2, 3 and Endline: (1)All of it (100%); (2)More than half of it; (3)Half of it (50%); (4)Less than half of it; (5)None of it (0%); (999)Don't know
//Adjusting labels for consistency 
label drop quant
label var quant "Quantity of water collected from primary water source in past week"
label define quant 1 "All of it (100%)" 2 "More than half of it" 3 "Half of it (50%)" 4 "Less than half of it" 5 "None of it (0%)" 999 "Don't know"
label values quant quant 


** Is the stored water treated
//"No" coded as 2 in follow up surveys & as 0 in endline and baseline census; "No stored water" coded as 3 in follow ups & as 2 in endline and baseline
recode water_stored (2=0) (3=2)


** How often is stored water treated? (Baseline Census and Baseline HH survey)
//Options changed from Baseline census to Baseline HH survey; Need to adjust the options for consistency? 
//Baseline census: (0) Once at the time of storing; (1) Every time the stored water is used; (2) Daily; (3) 2-3 times a day; (4) Every 2-3 days in a week; (5) No fixed schedule; (-77)Other. 
//Baseline HH Survey: (0)Once at the time of storing; (1)Every time the stored water is used; (2)When the water looks smelly or dirty; (3)When kids/old people fall sick; (4)In the monsoons; (5)In the summers; (6)In the winters; (-77)Others

//water_stored_freq


** Usage of JJM water for purposes other than drinking 
//In follow up surveys and endline census survey, question on whether HH drinks water from JJM tap was included (jjm_drinking), followed by question on other uses of JJM water (jjm_use)
//In baseline hh survey, the question on whether HH drinks water from JJM tap was not included (jjm_drinking); question on uses of JJM tap water included "Drinking" as an option in tap_use (later renamed as jjm_use).   
* Renaming binary variable storing information on if HH drinks from JJM tap into a new variable 
rename tap_use_1 jjm_drinking  
label var jjm_drinking "Drink JJM water"
label define jjm_drinking 1 "Yes" 0 "No"
label values jjm_drinking jjm_drinking 

* Creating new variable on if HH uses JJM water for othe reasons based on responses to tap_use
gen jjm_yes=.
replace jjm_yes=0 if tap_use_9==1 | tap_use=="1" //Use JJM water for nothing OR only for drinking 
replace jjm_yes=1 if tap_use!="1" //Uses JJM AND for purposes other than drinking alone 

label var jjm_yes "Uses JJM water for purposes other than drinking"
label define jjm_yes 1 "Yes" 0 "No"
label values jjm_yes jjm_yes

*Recoding other binary variables created from tap_use to reflect changes in answer options for consistency (not changing the original string variable: tap_use) 
//Answer options in Baseline, Endline and other follow up rounds: (1) Cooking, (2) Washing utensils, (3) Washing clothes, (4) Cleaning and other HH activities, (5) Hygiene and Sanitation, (6) As drinking water for animals, (7) Irrigation and Gardening, (-77) Other, (999) Don't know
//Original Answer options in Baseline HH Survey: (1)Drinking; (2)Cooking; (3)Washing utensils; (4)Washing clothes; (5)Cleaning the house; (6)Bathing; (7)As drinking water for animals; (8)For irrigation; (9)Nothing; (-77)Other; (999)Don't know

rename tap_use_2 tap_use_1
replace tap_use_1=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_1 "Use JJM for Cooking"
label define tap_use_1 1 "Yes" 0 "No"
label values tap_use_1 tap_use_1

rename tap_use_3 tap_use_2
replace tap_use_2=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_2 "Use JJM for Washing utensils"
label define tap_use_2 1 "Yes" 0 "No"
label values tap_use_2 tap_use_2

rename tap_use_4 tap_use_3
replace tap_use_3=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_3 "Use JJM for Washing clothes"
label define tap_use_3 1 "Yes" 0 "No"
label values tap_use_3 tap_use_3

rename tap_use_5 tap_use_4
replace tap_use_4=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_4 "Use JJM for Cleaning and other HH activites"
label define tap_use_4 1 "Yes" 0 "No"
label values tap_use_4 tap_use_4

rename tap_use_6 tap_use_5
replace tap_use_5=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_5 "Use JJM for Hygiene and Sanitation purposes"
label define tap_use_5 1 "Yes" 0 "No"
label values tap_use_5 tap_use_5 

rename tap_use_7 tap_use_6
replace tap_use_6=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_6 "Use JJM for drinking water for animals"
label define tap_use_6 1 "Yes" 0 "No"
label values tap_use_6 tap_use_6

rename tap_use_8 tap_use_7
replace tap_use_7=. if jjm_yes==0  //repalcing with 0 if HH uses JJM water only for drinking or doesn't use it at all 
label var tap_use_7 "Use JJM for Irrigation and Gardening"
label define tap_use_7 1 "Yes" 0 "No"
label values tap_use_7 tap_use_7

*Creating new category for those who use JJM water in Worship (for consistency with other rounds of survey data)
gen tap_use_8=.
replace tap_use_8=0 if tap_use!="" //if tap use is not missing 
replace tap_use_8=. if jjm_yes==0 
label var tap_use_8 "Use JJM for Puja/Worship"
label define tap_use_8 1 "Yes" 0 "No"
label values tap_use_8 tap_use_8

rename tap_use_9 tap_use_0 
replace tap_use_0=. if jjm_yes==0 
label var tap_use_0 "Doesn't use JJM at all"
label define tap_use_0 1 "Yes" 0 "No"
label values tap_use_0 tap_use_0

replace tap_use__77=. if jjm_yes==0 
label var tap_use__77 "Use JJM for Other Purposes"
label define tap_use__77 1 "Yes" 0 "No"
label values tap_use__77 tap_use__77

replace tap_use_999=. if jjm_yes==0 
label var tap_use_999 "Don't know"
label define tap_use_999 1 "Yes" 0 "No"
label values tap_use_999 tap_use_999


********************************************************************************
*** Renaming variables for consistency across FU rounds and EL
********************************************************************************

rename water_treat_when water_treat_freq
rename water_treat_when_1 water_treat_freq_1
rename water_treat_when_2 water_treat_freq_2
rename water_treat_when_3 water_treat_freq_3
rename water_treat_when_4 water_treat_freq_4
rename water_treat_when_5 water_treat_freq_5
rename water_treat_when_6 water_treat_freq_6
rename water_treat_when__77 water_treat_freq__77
rename water_treat_when_oth water_treat_freq_oth
rename tap_use jjm_use
rename tap_use_oth jjm_use_oth 
rename water_prim_oth water_source_prim_oth 
rename tap_use__77 jjm_use__77

forvalues i=0/999{
	cap rename tap_use_`i' jjm_use_`i'
}


//Below two variables store information on how often the HH treats stored water; similar variable in Baseline census had completely differnet options. Given options to this in Basleine HH survey suggest the condiytions in which water is treated, renmaing it to avoid confusion and allow us to treat them as two seperate variables 
rename water_stored_freq stored_treat_condition
rename water_stored_freq_oth stored_treat_condition_oth 

//Below variables store information on how much time HH takes to collect and treat water. In Baseline HH survey, options were presented to respondents for various categories and in other FU surveys, responses were open ended. Renaming them for consistency across surveys.
rename collect_time collect_time_category
rename collect_sec_time collect_sec_time_category
rename treat_time treat_time_category


*** Dropping vars not required and generated for quality checks 
drop unique_id_3_digit replace_og_id_err replace_id FU_replacement_id_3 unique_id_num_NUnique unique_id_num_Unique unique_id_3_digit_wt

*** Removing prefix to be able to append data
renpfix FU_

*** Changing storage type for consistency before appending the data
tostring source_container_*, replace

tostring source_container_1 , gen (source_container_temp)
drop source_container_1
rename source_container_temp source_container_1

tostring tap_taste_desc, gen (tap_taste_desc_temp)
drop tap_taste_desc
rename tap_taste_desc_temp tap_taste_desc

tostring tap_smell, gen (tap_smell_temp) 
drop tap_smell
rename tap_smell_temp tap_smell

tostring tap_color, gen (tap_color_temp) 
drop tap_color
rename tap_color_temp tap_color
 
********************************************************************************
*** Saving the intermediate dataset to be used for appending 
********************************************************************************
save "${Intermediate}1_2_Followup_tempclean.dta", replace 



*------------------------------------------------------------------------------*------------------------------------------------------------------*
********************************************************************************
*** Appending all follow up rounds for recategorisation and additional cleaning
********************************************************************************

use "${Intermediate}1_2_Followup_tempclean.dta", clear 

append using "${Intermediate}1_5_Followup_R1_tempclean.dta", gen (FU_FU1)
append using "${Intermediate}1_6_Followup_R2_tempclean.dta", gen (FU_FU1_FU2)
append using "${Intermediate}1_7_Followup_R3_tempclean.dta", gen (FU_FU1_FU2_FU3)

********************************************************************************
*** General checks and changes
********************************************************************************

*** Checking the number of UIDs being repeated across surveys
bysort unique_id: gen count = _N
ta count 

//       count |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           1 |        270       33.75       33.75
//           2 |        338       42.25       76.00
//           3 |        144       18.00       94.00
//           4 |         48        6.00      100.00
// ------------+-----------------------------------
//count =1 : IDs with single occurance; count =2: IDs across 2 survey rounds; and so on 

*** Manual corrections
** Generating a variable to identify residents of Bapuji Nagar in Karlakana
gen resident_bapujinagar = .
replace resident_bapujinagar=1 if r_cen_village_name_str=="Karlakana" & r_cen_saahi_name=="Bapuji nagar" 
label var resident_bapujinagar "Resident of Bapuji Nagar, Karlakana"

**Replacing 'primary source of water' to "Govt tap other than jjm/basudha/rwss" if HH is a resident of Bapuji Nagar (Karlakana) 
//these HHs get water from a non-JJM Govt provided HH tap 
replace water_source_prim=10 if r_cen_village_name_str=="Karlakana" &  resident_bapujinagar==1 & water_source_prim==1 

********************************************************************************
*** Categorizing the text responses (other category responses)
//Creating similar categories across all FUs, baseline and endline for consistency) 
********************************************************************************

*** water_source_prim_oth: Follow up question for "water_source_prim: In the past month, which water source did you primarily use for drinking?" original options include 11 categories in FUs and 9 categories in Baseline HH survey including "Other")
*Recategorising into existing categories 
//Option 9: Borewell operated by electric pump (category doesn't exist in baseline hh survey but is present in all other FU rounds, so creating it below for consistency)
replace  water_source_prim=9 if water_source_prim_oth=="Nija Borwell pani" | water_source_prim_oth=="Own Borwell" | water_source_prim_oth=="Bore well water" | water_source_prim_oth=="Nija Borwell pani piuchanti"

label drop water_source_prim
label var water_source_prim "Primary water source"
label define water_source_prim 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM tank" 2 "Government provided community standpipe (connected to piped system, through Vasudha tank)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel" 6 "Uncovered dug well" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
label values water_source_prim water_source_prim
//NOTE TO SELF: CHECK CODE IN LINE 268 AND 269 IN HH LEVEL FILE 


*** water_treat_freq_oth: follow up question to "water_treat_freq: When do you make the water from your primary drinking water source safe before drinking it?" which is asked to HHs who treat their water (stored or tap)
*Recategorisng into existing categories
//Optiom 1: Always treat water 
//Following responedents treat the water by cleaning their containers daily or before filling water; categorising them into "Always treat water"
replace water_treat_freq="1" if water_treat_freq_oth=="Container shap karke pani bharte hai" | water_treat_freq_oth=="Container r ko shap karke pani bharte hai" | water_treat_freq_oth=="Do din me ek bar container clean karte"

*Replacing the relevant binary variables as well 
replace water_treat_freq_1=1 if water_treat_freq_oth=="Container shap karke pani bharte hai" | water_treat_freq_oth=="Container r ko shap karke pani bharte hai" | water_treat_freq_oth=="Do din me ek bar container clean karte"

*Replacing the other category with zero after categoring the text responses
replace water_treat_freq__77=0 if water_treat_freq_oth=="Container shap karke pani bharte hai" | water_treat_freq_oth=="Container r ko shap karke pani bharte hai" | water_treat_freq_oth=="Do din me ek bar container clean karte"

/*Not categorised yet:
//This HH treats tap water byboiling it as per responses to other questions but mentioned that don't do anything in question on frequecy of water treatment.  Run code below to check responses to relevant variables: 
br Round water_treat water_stored water_treat_type water_treat_type_oth water_treat_freq water_treat_freq_oth if water_treat_freq_oth=="Kichi karunahanti"
"Kichi karunahanti" //Does nothing 
*/


*** water_treat_type_oth: follow up question to "water_treat_type: What do you do to the water to make it safe for drinking?" which was asked to HHs who treat tap or stored water ("water_treat" or "water_stored")
*Recoding existing categories for consistency
//Two additional options : (5)Aqua filter and (6)Purchase filtered bottle added to FU1, FU2, and FU3; Recoding them to change order of answer options and for consistency with endline and baseline census data (same categoires generated in endline and baseline for consistency as well)
rename water_treat_type_5 water_treat_type_7
replace water_treat_type_7=0 if water_treat_type!="" //replacing emoty values for obs where this option was not given in Baseline HH

label var water_treat_type_7 "Aqua filter"
label define water_treat_type_7 1 "Yes" 0 "No"
label values water_treat_type_7 water_treat_type_7 

rename water_treat_type_6 water_treat_type_8
replace water_treat_type_8=0 if water_treat_type!="" //replacing emoty values for obs where this option was not given in Baseline HH

label var water_treat_type_8 "Purchase filtered bottle"
label define water_treat_type_8 1 "Yes" 0 "No"
label values  water_treat_type_8 water_treat_type_8 

*Creating new category for those who clean the storage containers
gen water_treat_type_5=.
replace water_treat_type_5=0 if water_treat_type!=""
replace water_treat_type_5=1 if water_treat_type_oth=="Bartan saaf karte hai" | water_treat_type_oth=="Clean containers" | water_treat_type_oth=="Clean continers" | water_treat_type_oth=="Clean tha container" | water_treat_type_oth== "Clean the container" | water_treat_type_oth=="Clear conteners" | water_treat_type_oth=="Container ko shap karke pani bharte hai" | water_treat_type_oth=="Container saaf karte hain" | water_treat_type_oth=="Container shap karke pani bharte hai" | water_treat_type_oth=="Clean tha container, cover the container" | water_treat_type_oth=="Clean the container,cover the container" | water_treat_type_oth=="Cover the container, clean tha container" | water_treat_type_oth=="Cover the water, clean tha container" | water_treat_type_oth=="Handi wash Kara hauchhi, store water ku plate ghadeiki rakhuchanti"

label var water_treat_type_5 "Clean the storage containers"
label define water_treat_type_5 1 "Yes" 0 "No"
label values water_treat_type_5 water_treat_type_5 

*Creating new category for those who cover the storage containers
gen water_treat_type_6=.
replace water_treat_type_6=0 if water_treat_type!=""
replace water_treat_type_6=1 if water_treat_type_oth=="Cover tha container" | water_treat_type_oth=="Cover tha water" | water_treat_type_oth=="Cover the container" | water_treat_type_oth=="Cover the water" | water_treat_type_oth=="Covered the containers" | water_treat_type_oth=="Covered the plate" | water_treat_type_oth=="Ghodei Kari rakha hauchhi" | water_treat_type_oth=="Ghodeiki rakhanti" | water_treat_type_oth=="Store water ko dhak ke rakte hai" | water_treat_type_oth=="Clean tha container, cover the container" | water_treat_type_oth=="Clean the container,cover the container" | water_treat_type_oth=="Cover the container, clean tha container" | water_treat_type_oth=="Cover the water, clean tha container" | water_treat_type_oth=="Handi wash Kara hauchhi, store water ku plate ghadeiki rakhuchanti"

label var water_treat_type_6 "Cover the storage containers"
label define water_treat_type_6 1 "Yes" 0 "No"
label values water_treat_type_6 water_treat_type_6 

*Replacing the other category with zero after categoring the text responses
replace water_treat_type__77=0 if water_treat_type_oth=="Bartan saaf karte hai" | water_treat_type_oth=="Clean containers" | water_treat_type_oth=="Clean continers" | water_treat_type_oth=="Clean tha container" |  water_treat_type_oth=="Clean the container" | water_treat_type_oth=="Clear conteners" | water_treat_type_oth=="Container ko shap karke pani bharte hai" | water_treat_type_oth=="Container saaf karte hain" | water_treat_type_oth=="Container shap karke pani bharte hai" | water_treat_type_oth=="Clean tha container, cover the container" | water_treat_type_oth=="Clean the container,cover the container" | water_treat_type_oth=="Cover the container, clean tha container" | water_treat_type_oth=="Cover the water, clean tha container" | water_treat_type_oth=="Handi wash Kara hauchhi, store water ku plate ghadeiki rakhuchanti" | water_treat_type_oth=="Cover tha container" | water_treat_type_oth=="Cover tha water" | water_treat_type_oth=="Cover the container" | water_treat_type_oth=="Cover the water" | water_treat_type_oth=="Covered the containers" | water_treat_type_oth=="Covered the plate" | water_treat_type_oth=="Ghodei Kari rakha hauchhi" | water_treat_type_oth=="Ghodeiki rakhanti" | water_treat_type_oth=="Store water ko dhak ke rakte hai"


*** tap_function_reason_oth: 4 obs: Follow up question to "tap_function_reason: Why was the government provided household tap not working?" which in turn was conditional on HH responding that tap was not working (tap_function)
*Recategorising into existing categories
//Option 4: Electricty/Current issue
replace tap_function_reason_4=1 if tap_function_reason_oth=="Current no thile" | tap_function_reason_oth=="Current problem"

//Option 5: Pump issue
replace tap_function_reason_5=1 if tap_function_reason_oth=="Miter kharap thila" 

*Replacing the other category with zero after categoring the text responses
replace tap_function_reason__77=0 if tap_function_reason_oth=="Current no thile" | tap_function_reason_oth=="Current problem" | tap_function_reason_oth=="Miter kharap thila" 

/*Not categorised yet:
"Respondent khud he late kiye to pani band hogeyatha" //water ran out by the time respondent turned on the tap
*/


*** jjm_use_oth: 7 obs; Follow up question for "jjm_use: What other purposes do you use JJM water for"
*Recategorising into existing categories
//Option 4: Cleaning the house (Expanding it to include Cleaning and other activities around the household like washing vehicles, construction related activites, etc., and relabelling it)
replace jjm_use_4=1 if jjm_use_oth=="Gadi wash" | jjm_use_oth=="Ghara tiaari kam" | jjm_use_oth=="Chaula Dhaiba"

//Option 5: Bathing (Expanding it to include use for hygiene and sanitation purposes and relabelling it)
replace jjm_use_5=1 if jjm_use_oth=="Latin" | jjm_use_oth=="Latrine"  

//Option 8: Worship 
replace jjm_use_8=1 if jjm_use_oth=="Puja kariba"

*Replacing the other category with zero after categoring the text responses
replace jjm_use__77=0 if jjm_use_oth=="Gadi wash" | jjm_use_oth=="Ghara tiaari kam" | jjm_use_oth=="Chaula Dhaiba" | jjm_use_oth=="Puja kariba" | jjm_use_oth=="Latin" | jjm_use_oth=="Latrine" 

/*Not categorised yet:
Govt tap water not used
*/


*** tap_use_drinking_oth: 6 obs + 600 missing obs as question only present in FU2 and FU3: Follow up question to "tap_use_drinking: When was the last time you collected water from the government provided household taps for drinking purposes?" 

*Replacing missing values properly
replace tap_use_drinking_oth="" if tap_use_drinking_oth=="."

*Recategorising into existing categories: 
//Option 5: JJM water Not used for drinking (option present only in Baseline FU; standardiseing across all FU rounds)
replace tap_use_drinking=5 if tap_use_drinking_oth=="They didn't use this water for long time" | tap_use_drinking_oth=="Respondent kebe bi pieba pain Jjm pani collect Kari nahanti." | tap_use_drinking_oth=="2 years hogeya pani use nehi kartehe pinekeliye"

//783 Obs for tap_use_drinking: only HHs who use JJM for drinking were asked this question in Baseline HH Survey (17 HHs who dont drink JJM water were not asked this question in Baseline HH)
*Replacing variable with tap_use_drinking=5 for HHs who weren't asked this question in Baseline HH as they dont drink JJM water for consistency 
replace tap_use_drinking=5 if jjm_drinking==0 & Round=="R_FU_" 

*Creating a new category for those who havent used jjm water for more than a month
replace tap_use_drinking=6 if tap_use_drinking_oth=="One month aagaru" | tap_use_drinking_oth=="2month" | tap_use_drinking_oth=="2"

*Recoding to change the order of the options
recode tap_use_drinking (5=7) (6=5) (7=6)

*Labelling the option values
label drop tap_use_drinking
label var tap_use_drinking "When was the last time JJM water was used for drinking"
label define tap_use_drinking 1 "Today" 2 "Yesterday" 3 "Earlier this week" 4 "Earlier this month" 5 "More than a month back" 6 "Don't use JJM for drinking" -77 "Other"
label values tap_use_drinking tap_use_drinking


*** tap_trust_oth: 4 obs: Follow up question to "tap_trust_fu: Why are you not confident the water is safe to drink?" which in turn is conditional upon saying they aren't confident to drink tap water in question "tap_trust: How confident are you that the water from the government provided household tap / supply paani is safe to drink?"
*Recategorising into existing categories
//Option 2: The water looks muddy or like it has particles in it
replace tap_trust_fu="2" if tap_trust_oth=="Panire chuti , siuli palei asuchi"
replace tap_trust_fu_2=1 if tap_trust_oth=="Panire chuti , siuli palei asuchi"

*Replacing the other category with zero after categoring the text responses
replace tap_trust_fu__77=0 if tap_trust_oth=="Panire chuti , siuli palei asuchi"

/*Not categorised yet:
//Can be categorised into Option 4: "Concerned about bacterial contamination"
"Tanki sapha karunahantibali" //tank not cleaned
"Govt tap water not used" //don't use tap water 

//Translation required:
"Telus lage"
*/


*** reason_nodrink_oth: 3 obs:  Conditional upon whether they drink water from JJM tap or not. If they don't, "reason_nodrink: reason for not drinking tap water" is asked  (question not included in Baseline HH survey)
*Recategorising into existing categories 
//Option 5: those who dont drink jjm water because they fetch drinking water from other private water source 
replace reason_nodrink_6=1 if reason_nodrink_oth=="Nija ghare motor borewell achhi seithipain" | reason_nodrink_oth=="Agaru solar pani piuchanti sethi pae ebe b piuchanti"

*Replacing the other category with zero after categoring the text responses
replace reason_nodrink__77=0 if reason_nodrink_oth=="Nija ghare motor borewell achhi seithipain" | reason_nodrink_oth=="Agaru solar pani piuchanti sethi pae ebe b piuchanti"

/* Not categorised yet:
//Can be categorised in to "Option 4: Water from Government provided household tap is muddy or smelly" or to "fetch drinking water from other private water source"?:
"Tanki saffa rahuni" //tank is not cleaned
*/


*** cooking_issue_reason_oth: 1 obs Question present only in FU1 
*Recategorisng into existing categories
//Option 3: Bad taste or smell of the water or prepared food
replace cooking_issue_reason="3" if cooking_issue_reason_oth=="KUCH BHI BANANE SE KHANA SMELL HORAHAHE"
replace cooking_issue_reason_3=1 if cooking_issue_reason_oth=="KUCH BHI BANANE SE KHANA SMELL HORAHAHE"

*Replacing the other category with zero after categoring the text responses
replace cooking_issue_reason__77=0 if cooking_issue_reason_oth=="KUCH BHI BANANE SE KHANA SMELL HORAHAHE"


*** tap_supply_freq_oth: 1 obs: Follow up question to "tap_supply_freq: Generally, when is water supplied from the government provided tap/ supply paani?" 
//In endline census, this question was applicable only for HHs using jjm water for drinking: can replace this variable as missing for HHs in follow up survey who dont use jjm water for drinking for consistency 
/*Not categorised yet: 
Ehi family tankara firm house re ruhanti morning 6 ru 10 rati jai sethipai tap water used karunahanti tanka firm house re bore well pani used karuchanti //doesn't use tap water but uses a borewell instead
*/


*** stored_treat_condition_oth : 1 obs; Follow up question to "stored_treat_condition: How often do you make the water currently stored at home safe for drinking?" --  present only in Baseline HH survey; original options inlcude 6 categories including "Other" - given the options refer to under what conditions water is treated, chnaged the var name)  

/* Not categorised yet:
//Not sure 
" 3 thara" //3 times 
*/
 
 
*** tap_taste_desc_oth: 6 observations: Follow up question to "tap_taste_desc: How would you describe the taste of the water from the government provided household tap?"

/*Not categorised yet:
//Do not fit into existing categories: Good; medicine; Metal; Salty; bleach or chlorine
"Bele bele alia asuchi" // dirty water
"Water thoda oily arahahe" //water is oily?
"Mitha" //sweet water
"Dhuli bhali lage" //muddy
"Govt tap water not used"

//translation required:
"Patala lagiba" 
*/


*** tap_smell_oth: 3 observations: Follow up question to "tap_smell: How would you describe the smell of the water from the government provided household tap?"

/*Not categorised yet:
//Do not fit into existing categories: Good; medicine; Metal; Salty; bleach or chlorine
"Govt tap water not used"
"Plastic smell"

//Translation required:
"Pita laguchi" 
*/


*** tap_color_oth: 4 observations: Follow up question to "tap_color: How do you find the color or look of the water from the government provided household tap?"

/*Not categorised yet: 
//Do not fit into existing categories: No problems with the color or look; Muddy/ sandy water; Yellow-ish or reddish water:
"Govt tap water not used" 
"Oily"

//Translations required: 
"Pani badheiki 2 days rakhidele pani upare phena baharuchhi" 
"Teluaa" //Foam??
*/


*** tap_supply_freq_oth: 1 obs: Follow up question to "tap_supply_freq: Generally, when is water supplied from the government provided tap/ supply paani?" 
/*Not categorised yet: 
"Ehi family tankara firm house re ruhanti morning 6 ru 10 rati jai sethipai tap water used karunahanti tanka firm house re bore well pani used karuchanti"
*/


*** tap_use_future_oth: no obs; Follow up question to "tap_use_discontinue: why you would not continue using government provided household tap in the future?" which in turn was asked only to those who are less likely to continue using tap water 
//Only 783 obs present for tap_use_future: 17 missing obs as only HHs using JJM for drinking were asked this question in Baseline HH survey 


*** water_source_sec_oth: no obs:  Follow up question for "water_source_sec: In the past month, what other water sources has your household used for drinking? 



// Recategorisation 
//Source_container_oth ???? —>keep it for the last depending upon the number of containers: oth category includes obs only till _4; need to decide how to treat the variables given that in FU0 the question was a select one questiuon and in other rounds it was select multiple


********************************************************************************
*** Generating new variables 
********************************************************************************

*** Water supply frequecny on the days water is supplied regularly
gen C_water_supply_freq=.
replace C_water_supply_freq=1 if tap_supply_daily==555
replace C_water_supply_freq=2 if tap_supply_daily==1
replace C_water_supply_freq=3 if tap_supply_daily==2
replace C_water_supply_freq=4 if tap_supply_daily==7 | tap_supply_daily==14

label var C_water_supply_freq "Frequency of Water supply"
label define C_water_supply_freq 1 "Supplied 24/7" 2 "Supplied once a day" 3 "Supplied twice a day" 4 "Supplied more than twice a day"
label values C_water_supply_freq C_water_supply_freq


*** Generating a new variable to store the main source of secodnary water
//Changing storage types
destring water_sec_value_*, replace

gen water_source_main_sec_new=.
forvalues i=1/3 {
replace water_source_main_sec_new=water_sec_value_`i' if water_source_main_sec==`i'
}

drop water_source_main_sec 
rename water_source_main_sec_new water_source_main_sec 

label drop water_source_main_sec
label var water_source_main_sec "Main souce of secondayr source"
label define water_source_main_sec 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM tank" 2 "Government provided community standpipe (connected to piped system, through Vasudha tank)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel"  8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
label values water_source_main_sec water_source_main_sec


*** Variables related to Water collection burden - age and gender of person primarily responsible
//In Baseline HH survey the question on who is primarily responsible was not included; the following vars are only for FU rounds
* Changing storage type of pre-load variables 
forval i=1/17 {
replace cen_fam_gender`i'="1" if cen_fam_gender`i'=="Male"
replace cen_fam_gender`i'="2" if cen_fam_gender`i'=="Female"
}
destring cen_fam_age* cen_fam_gender*, replace 

** Generate variables to store the age and gender of the person actually responsible for collecting water (Stored in "prim_collect_resp")
* Create variables for storing age and gender of the water collector
gen C_primcollector_age = .
gen C_primcollector_gender = .
* Create a variable to store the selected index in "collect_resp"
gen C_selected_index = .
* Create a new variable to hold the correct index from collect_resp
destring collect_resp_*, replace
forvalues i = 1/20 {
    * Check if resp`i' matches prim_collect_resp and assign the corresponding index
    qui replace C_selected_index = collect_resp_`i' if `i' == prim_collect_resp
}
* Extract age and gender based on selected_index
forval i=1/20 {
replace C_primcollector_age = cen_fam_age`i' if C_selected_index==`i' 
replace C_primcollector_gender = cen_fam_gender`i' if C_selected_index==`i'
}

label var C_primcollector_age "Age of person responsible for collecting water"
label var C_primcollector_gender "Gender of person responsible for collecting water"
label define C_primcollector_gender 1 "Male" 2 "Female"
label values C_primcollector_gender C_primcollector_gender

** Generating variables to store the Age and gender of the person actually responsible for treating water(Stored in "treat_primresp")
* Create variables for storing age and gender of the person who treats water
gen C_primtreat_age = .
gen C_primtreat_gender = .
* Create a variable to store the selected index in "treat_resp"
gen C_selected_index_treat = .
* Create a new variable to hold the correct index from treat_resp
destring treat_resp_*, replace
forvalues i = 1/20 {
    * Check if resp`i' matches treat_primresp and assign the corresponding index
    qui replace C_selected_index_treat = treat_resp_`i' if `i' == treat_primresp
}
* Extract age and gender based on selected_index
forval i=1/20 {
replace C_primtreat_age = cen_fam_age`i' if C_selected_index_treat==`i' 
replace C_primtreat_gender = cen_fam_gender`i' if C_selected_index_treat==`i'
}

label var C_primtreat_age "Age of person person responsible for treating water"
label var C_primtreat_gender "Gender of person responsible for treating water"
label define C_primtreat_gender 1 "Male" 2 "Female" 0 "HH Does not treat water"
label values C_primtreat_gender C_primtreat_gender


********************************************************************************
*** Dropping the PII and other variables not required  
********************************************************************************

*** Dropping PII and individual level information 
drop r_cen_hamlet_name r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2 r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5 r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17 r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 resident_bapujinagar

*** Dropping variables created by SCTO calculate fields //contain PII or not required for analysis 
drop  treat_resp1 treat_resp2 treat_resp4 treat_resp3 treat_resp5 treat_resp7 treat_resp6 treat_resp8 treat_resp9 treat_resp10 treat_resp11 treat_resp12 treat_resp13 treat_resp14 treat_resp15 treat_resp16 treat_resp17 treat_resp18 treat_resp19 treat_resp20 treat_resp_index_5 treat_resp_value_5 treat_resp_label_5 treat_resp_labels treat_resp_label_4 treat_resp_value_4 treat_resp_index_4 treat_resp_label_3 treat_resp_value_3 treat_resp_index_3 treat_resp_label_2 treat_resp_value_2 treat_resp_index_2 treat_resp_label_1 treat_resp_value_1 treat_resp_index_1 treat_resp_list_count num_treat_resp num_people_prim people_prim_list_count people_prim_water people_prim_index_1 people_prim_value_1 people_prim_label_1 people_prim_index_2 people_prim_value_2 people_prim_label_2 people_prim_index_3 people_prim_value_3 people_prim_label_3 people_prim_index_4 people_prim_value_4 people_prim_label_4 people_prim_index_5 people_prim_value_5 people_prim_label_5 people_prim_index_6 people_prim_value_6 people_prim_label_6 people_prim_index_7 people_prim_value_7 people_prim_label_7 people_prim_index_8 people_prim_value_8 people_prim_label_8 people_prim_labels people_prim1 people_prim2 people_prim3 people_prim4 people_prim5 people_prim6 people_prim7 people_prim8 people_prim9 people_prim10 people_prim11 people_prim12 people_prim13 people_prim14 people_prim15 people_prim16 people_prim17 people_prim18 people_prim19 people_prim20 water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 num_water_sec water_sec_list_count water_sec_index_1 water_sec_value_1 water_sec_label_1 water_sec_index_2 water_sec_value_2 water_sec_label_2 water_sec_index_3 water_sec_value_3 water_sec_label_3 water_sec_labels water_sec_label_1 water_sec_label_2 water_sec_label_3 water_sec_labels primary_water_label secondary_water_label FU_FU1 num_water_sec water_sec_list_count water_sec_index_1 water_sec_value_1 water_sec_index_2 water_sec_value_2 water_sec_index_3 water_sec_value_3 water_sec1 water_sec2 water_sec3 water_sec4 water_sec5 water_sec6 water_sec7 water_sec8 water_sec9 water_sec10 secondary_main_water_label people_prim_water num_people_prim people_prim_list_count people_prim_index_1 people_prim_value_1 people_prim_label_1 people_prim_index_2  people_prim_value_2 people_prim_label_2 people_prim_index_3 people_prim_value_3 people_prim_label_3 people_prim_index_4 people_prim_value_4 people_prim_label_4 people_prim_index_5 people_prim_value_5 people_prim_label_5 people_prim_index_6 people_prim_value_6 people_prim_label_6 people_prim_index_7 people_prim_value_7 people_prim_label_7 people_prim_index_8 people_prim_value_8 people_prim_label_8 people_prim_labels people_prim1 people_prim2 people_prim3 people_prim4 people_prim5 people_prim6 people_prim7 people_prim8 people_prim9 people_prim10 people_prim11 people_prim12 people_prim13 people_prim14 people_prim15 people_prim16 people_prim17 people_prim18 people_prim19 people_prim20 num_treat_resp treat_resp_list_count treat_resp_index_1 treat_resp_value_1 treat_resp_label_1 treat_resp_index_2 treat_resp_value_2 treat_resp_label_2 treat_resp_index_3 treat_resp_value_3 treat_resp_label_3 treat_resp_index_4 treat_resp_value_4 treat_resp_label_4 treat_resp_labels treat_resp1 treat_resp2 treat_resp3 treat_resp4 treat_resp5 treat_resp6 treat_resp7 treat_resp8 treat_resp9 treat_resp10 treat_resp11 treat_resp12 treat_resp13 treat_resp14 treat_resp15 treat_resp16 treat_resp17 treat_resp18 treat_resp19 treat_resp20 FU_FU1_FU2 main_respondent FU_FU1_FU2_FU3 intro1s_blwq intro1enum_code meta1instancename

*** Dropping ID variables not required for analysis 
drop  unique_id_1_wt unique_id_2 unique_id_2_wt unique_id_3 unique_id_3_wt replacement_id replacement_id_1 replacement_id_2 replacement_id_3 unique_id_3_digit_wt  

*** Dropping variables related to water quality testing (not required or included in the idexx dataset)
// drop wq_stored_bag wq_chlorine_stored wq_chlorine_storedfc_again wq_chlorine_storedtc_again wq_running_bag wq_chlorine_running wq_tap_fc_again wq_tap_tc_again intro1s_blwq consented_wq_testing1 bag_ID_tap_Unique bag_ID_stored_Unique sample_ID_stored_Unique sample_ID_tap_Unique tc_tap fc_tap bag_ID_tap tap_bag_id_running_again sample_ID_tap tap_bag_id_running tap_barcode_running  tc_stored fc_stored  bag_ID_stored tap_bag_id_stored_again sample_ID_stored tap_bag_id_stored tap_barcode_stored n stored_bag_source stored_bag_source_oth 

*** Renaming ID variables
rename r_cen_village_name_str village
rename unique_id_1 village_id

********************************************************************************
*** Saving the long format dataset 
********************************************************************************

save "${Intermediate}1_13_Followup_clean_long.dta", replace
// save "${DataFinal}1_13_Followup_clean_long.dta", replace 

********************************************************************************
*** Changes to the cleaned IDEXX datasets
********************************************************************************
//IDEXX testing done for 2 samples in 4 out of 10 HHs survyed in each village (total villages: 20): Sample size should be 160 for IDEXX per round 

*** IDEXX dataset 
* Loading the dataset 
clear
insheet using "${DataFinal}POOLED_idexx_master_cleaned.csv", clear
//1121 obs

// * Dropping observations 
drop if data_round=="R4" | data_round=="R5" | data_round=="R6" //dropping monsoon rounds (other than FU rounds)
//480 obs dropped, 641 obs left 

* Generating new variable :String version of UID variable
gen unique_id_str=unique_id
tostring unique_id_str, replace format(%17.0g)
rename unique_id unique_id_num
rename unique_id_str unique_id 
//
* Generating new variable to identify the round and dropping existing variable
gen Round=""
replace Round="R_FU_" if data_round=="BL"
replace Round="R_FU1_" if data_round=="R1"
replace Round="R_FU2_" if data_round=="R2"
replace Round="R_FU3_" if data_round=="R3"
//160 observations per round and 161 in FU1

* Reshaping the data to ensure all observations for one HH are there in one row within the same round 
//dropping vars not required
drop  village block panchayat_village /*unique_id_num*/


//Create a counter for the duplicates (2 obs per HH in one round)
bysort unique_id_num Round: gen hh_id = _n

* Now reshape the dataset
reshape wide assignment sample_id bag_id_tap bag_id_stored sample_type cf_mpn ec_mpn cf_95hi cf_95lo ec_95hi ec_95lo cf_pa_binary ec_pa_binary cf_pa ec_pa cf_log ec_log ec_risk fc_tap_avg fc_stored_avg, i(unique_id_num Round) j( hh_id)  

* Save the dataset
save "${Intermediate}1_13_IDEXX_FUrounds.dta", replace 

// // *** ABR dataset 
// // clear
// // insheet using "${DataFinal}POOLED_idexx_ABR_master_cleaned.csv", clear
//
********************************************************************************
*** Merging the FU data with IDEXX data
********************************************************************************

use "${Intermediate}1_13_Followup_clean_long.dta", clear 
merge 1:1  Round unique_id_num using "${Intermediate}1_13_IDEXX_FUrounds.dta", gen(Merge_IDEXX_FU) 


********************************************************************************
*** Saving individual FU round datasets
********************************************************************************

*** Baseline HH Survey
preserve
drop if Round != "R_FU_" // Correct the operator for comparison
ds // Get the list of variables
local vars `r(varlist)'
local exclude_vars unique_id Round village village_id // Define the variables to exclude from renaming
local rename_vars "" // Create a local macro for the variables to rename, excluding the specified variables
foreach var of local vars {
    // Check if the variable is not in the exclusion list
    if "`var'" != "unique_id" & "`var'" != "Round" & "`var'" != "village" & "`var'" != "village_id" {
        local rename_vars `rename_vars' `var'
    }
}
// Rename the remaining variables
foreach var of local rename_vars {
    rename `var' R_FU_`var'
}
// Drop the Round variable
drop Round 
//Drop other variables (empty variables)
drop R_FU_subscriberid R_FU_simid R_FU_devicephonenum R_FU_info_update R_FU_reasons_no_consent R_FU_reasons_no_consent_*  R_FU_C_selected_index_treat R_FU_C_primtreat_gender R_FU_C_primtreat_age R_FU_C_selected_index R_FU_C_primcollector_gender R_FU_C_primcollector_age R_FU_water_source_main_sec R_FU_audio_consent  R_FU_audio_audit R_FU_error_num_1 R_FU_high_fc_reading R_FU_high_tc_reading R_FU_error_yesno R_FU_error_how_many R_FU_testing_comment  R_FU_run_time_hours R_FU_run_time_mins R_FU_stor_time_hours R_FU_stor_time_mins R_FU_colorimeter_id R_FU_colorimeter_type R_FU_ecoli_yn R_FU_available_jjm  R_FU_cooking_issue R_FU_cooking_issue_reason R_FU_cooking_issue_reason_1 R_FU_cooking_issue_reason_2 R_FU_cooking_issue_reason_3 R_FU_cooking_issue_reason_4 R_FU_cooking_issue_reason_5 R_FU_cooking_issue_reason__77 R_FU_cooking_issue_reason_oth R_FU_skin_issues_before R_FU_skin_treat R_FU_skin_treat_type R_FU_skin_treat_type_1 R_FU_skin_treat_type_2 R_FU_skin_treat_type_3 R_FU_skin_treat_type_4 R_FU_skin_treat_type_5 R_FU_skin_treat_type_6 R_FU_skin_treat_type_7 R_FU_skin_treat_type_8 R_FU_skin_treat_type__77  R_FU_reason_nodrink  R_FU_reason_nodrink_*  R_FU_tap_use_drinking_oth R_FU_prim_collect_resp R_FU_where_prim_locate R_FU_where_sec_locate R_FU_treat_primresp R_FU_source_container_1_* R_FU_source_container_2_* R_FU_source_container_3_* R_FU_source_container_4_* R_FU_water_source_sec_1 R_FU_water_source_sec_oth R_FU_water_source_main_sec R_FU_source_container_5_* R_FU_source_container_6_* R_FU_source_container_7_* R_FU_source_container_8_* R_FU_source_container_9_* R_FU_source_container_10_* R_FU_source_container__77_*
//Renaming variables for consistency with Endline dataset
rename R_FU_C_water_supply_freq C_FU_water_supply_freq
rename R_FU_survey_issues C_survey_issues 
save "${DataFinal}1_2_BL_HH_clean_final.dta", replace 
restore


*** Follow-up Round 1
preserve
drop if Round != "R_FU1_" 
ds 
local vars `r(varlist)'
local exclude_vars unique_id Round village village_id 
local rename_vars "" 
foreach var of local vars {
    if "`var'" != "unique_id" & "`var'" != "Round" & "`var'" != "village" & "`var'" != "village_id" {
        local rename_vars `rename_vars' `var'
    }
}
// Rename the remaining variables
foreach var of local rename_vars {
    rename `var' R_FU1_`var'
}
// Drop the Round variable
drop Round 
//Drop other variables (empty variables)
drop R_FU1_simid R_FU1_subscriberid R_FU1_info_update R_FU1_treat_water_before R_FU1_reasons_no_consent R_FU1_reasons_no_consent_* R_FU1_tap_use_drinking_oth R_FU1_skin_treat R_FU1_skin_treat_type R_FU1_skin_treat_type_1 R_FU1_skin_treat_type_2 R_FU1_skin_treat_type_3 R_FU1_skin_treat_type_4 R_FU1_skin_treat_type_5 R_FU1_skin_treat_type_6 R_FU1_skin_treat_type_7 R_FU1_skin_treat_type_8 R_FU1_skin_treat_type__77 R_FU1_skin_issues_before R_FU1_tap_issues R_FU1_tap_issues_type
//Renaming variables for consistency with Endline dataset
rename R_FU1_C_water_supply_freq C_FU1_water_supply_freq
rename R_FU1_C_primcollector_age C_FU1_primcollector_age
rename R_FU1_C_primcollector_gender C_FU1_primcollector_gender
rename R_FU1_C_selected_index C_FU1_selected_index
rename R_FU1_C_primtreat_age C_FU1_primtreat_age
rename R_FU1_C_primtreat_gender C_FU1_primtreat_gender
rename R_FU1_C_selected_index_treat C_FU1_selected_index_treat
rename R_FU1_survey_issues C_survey_issues 
// Save the dataset
save "${DataFinal}1_5_FU_R1_clean_final.dta", replace 
restore


*** Follow-up Round 2
preserve
drop if Round != "R_FU2_" 
ds 
local vars `r(varlist)'
local exclude_vars unique_id Round village village_id 
local rename_vars "" 
foreach var of local vars {
    if "`var'" != "unique_id" & "`var'" != "Round" & "`var'" != "village" & "`var'" != "village_id" {
        local rename_vars `rename_vars' `var'
    }
}
// Rename the remaining variables
foreach var of local rename_vars {
    rename `var' R_FU2_`var'
}
// Drop the Round variable
drop Round 
//Drop other variables (empty variables)
drop R_FU2_subscriberid R_FU2_simid R_FU2_info_update R_FU2_reasons_no_consent R_FU2_reasons_no_consent_* R_FU2_treat_water_before R_FU2_cooking_issue R_FU2_cooking_issue_reason_oth
rename R_FU2_C_water_supply_freq C_FU2_water_supply_freq
rename R_FU2_C_primcollector_age C_FU2_primcollector_age
rename R_FU2_C_primcollector_gender C_FU2_primcollector_gender
rename R_FU2_C_selected_index C_FU2_selected_index
rename R_FU2_C_primtreat_age C_FU2_primtreat_age
rename R_FU2_C_primtreat_gender C_FU2_primtreat_gender
rename R_FU2_C_selected_index_treat C_FU2_selected_index_treat
rename R_FU2_survey_issues C_survey_issues 
// Save the dataset
save "${DataFinal}1_6_FU_R2_clean_final.dta", replace 
restore


*** Follow-up Round 3
preserve
drop if Round != "R_FU3_" 
ds 
local vars `r(varlist)'
local exclude_vars unique_id Round village village_id 
local rename_vars "" 
foreach var of local vars {
    if "`var'" != "unique_id" & "`var'" != "Round" & "`var'" != "village" & "`var'" != "village_id" {
        local rename_vars `rename_vars' `var'
    }
}
// Rename the remaining variables
foreach var of local rename_vars {
    rename `var' R_FU3_`var'
}
// Drop the Round variable
drop Round 
//Drop other variables (empty variables)
drop R_FU3_subscriberid R_FU3_simid R_FU3_devicephonenum R_FU3_info_update R_FU3_reasons_no_consent R_FU3_reasons_no_consent_* R_FU3_treat_water_before R_FU3_cooking_issue R_FU3_cooking_issue_reason_oth
rename R_FU3_C_water_supply_freq C_FU3_water_supply_freq
rename R_FU3_C_primcollector_age C_FU3_primcollector_age
rename R_FU3_C_primcollector_gender C_FU3_primcollector_gender
rename R_FU3_C_selected_index C_FU3_selected_index
rename R_FU3_C_primtreat_age C_FU3_primtreat_age
rename R_FU3_C_primtreat_gender C_FU3_primtreat_gender
rename R_FU3_C_selected_index_treat C_FU3_selected_index_treat
rename R_FU3_survey_issues C_survey_issues 
// Save the dataset
save "${DataFinal}1_7_FU_R3_clean_final.dta", replace 
restore

/*Reshape the dataset, excluding the Round variable
// reshape wide @deviceid @subscriberid @simid @devicephonenum @village @noteconf1 @info_update @replacement @enum_name @enum_name_label @resp_available @consent @reasons_no_consent @reasons_no_consent_1 @reasons_no_consent_2 @reasons_no_consent__77 @reasons_no_consent_3 @no_consent_oth @water_source_prim @water_source_prim_oth @water_sec_yn quant @quant_containers @liter_estimation_count  @container_nmbr_1 @size_container_1 @container_nmbr_2 @size_container_2 @container_nmbr_3 @size_container_3 @container_nmbr_4 @size_container_4 @container_nmbr_5 @size_container_5 @container_nmbr_6 @size_container_6 @container_nmbr_7 @size_container_7 @container_nmbr_8 @size_container_8 @container_nmbr_9 @size_container_9 @container_nmbr_10 @size_container_10 @container_nmbr_11 @size_container_11 @container_nmbr_12 @size_container_12 @container_nmbr_13 @size_container_13 @container_nmbr_14 @size_container_14 @container_nmbr_15 @size_container_15 @container_nmbr_16 @size_container_16 @container_nmbr_17 @size_container_17 @container_nmbr_18 @size_container_18 @container_nmbr_19 @size_container_19 @container_nmbr_20 @size_container_20 @container_nmbr_21 @size_container_21 @container_nmbr_22 @size_container_22 @container_nmbr_23 @size_container_23 @container_nmbr_24 @size_container_24 @container_nmbr_25 @size_container_25 @source_container_* @time_container_* @water_treat @water_stored @water_treat_type @water_treat_type_* @water_treat_freq @water_treat_freq_*  @stored_treat_condition @stored_treat_condition_oth @tap_supply_freq @tap_supply_freq_oth @tap_supply_daily @jjm_use @jjm_drinking @jjm_use_*  @tap_use_drinking @tap_function @tap_function_reason @tap_function_reason_*  @tap_use_future @tap_use_discontinue @tap_use_future_oth @tap_taste_satisfied @tap_taste_desc  @tap_smell  @tap_color  @tap_trust @tap_trust_fu @tap_trust_fu_*  @tap_trust_oth @chlorine_yesno @chlorine_drank_yesno @collect_resp @collect_resp_* @collect_time_category @collect_prim_freq @collect_sec_time_category @collect_sec_freq @treat_water_before @treat_resp treat_resp_* @treat_time_category @treat_freq @collect_treat_difficult @survey_accompany_num @survey_member_names_count @surveynumber_* @survey_member_role_* @survey_member_gender_* @instancename @formdef_version @key @isvalidated @submissiondate @starttime @endtime @day @month_num @month date @starthour @startmin @locatehh_dur_min @consent_dur_min @secA_dur_min @secB_dur_min @secC_dur_min @secD_dur_min @secE_dur_min @end_dur_min @duration_min @bag_ID_tap_Unique @bag_ID_stored_Unique @sample_ID_stored_Unique @sample_ID_tap_Unique @survey_issues @jjm_yes @reason_replacement @reason_replacement_oth @water_source_sec @water_source_sec_*  @overall_comment @duration_end @C_selected_index_treat @C_primtreat_gender @C_primtreat_age @C_selected_index @C_primcollector_gender @C_primcollector_age @water_source_main_sec @C_water_supply_freq   @count @submission_date @audio_audit @audio_consent @error_num_1 @calc_error_nmbr_1 @gps_* @tap_use_drinking_oth @skin_issues_before  @skin_treat_type_* @skin_treat_type @skin_treat @tap_issues_type @tap_issues    @consented_wq_testing1 @time_stored_running @testing_comment @error_types_count @error_how_many @error_yesno @high_tc_reading @high_fc_reading @run_time_mins @run_time_hours @stor_time_mins @stor_time_hours @colorimeter_type @colorimeter_id @available_jjm @ecoli_yn  @tap_color_*  @tap_smell_*  @tap_taste_desc_* @cooking_issue_reason_*  @cooking_issue_reason @cooking_issue @reason_nodrink_*   @reason_nodrink @treat_time @treat_primresp  @where_sec_locate @collect_sec_time @collect_time @where_prim_locate @prim_collect_resp  @water_qual_test @no_test_reason @wq_stored_bag @stored_bag_source @stored_bag_source_oth @bag_stored_time @bag_stored_time_unit @no_stored_bag @tap_bag_id_stored @tap_barcode_stored @sample_ID_stored @tap_bag_id_stored_again @bag_ID_stored @wq_chlorine_stored @no_chlorine_stored @fc_stored wq_chlorine_storedfc_again @tc_stored wq_chlorine_storedtc_again @wq_running_bag @no_running_bag @tap_bag_id_running @tap_barcode_running @sample_ID_tap @tap_bag_id_running_again @bag_ID_tap @wq_chlorine_running @no_tap_reason @fc_tap wq_tap_fc_again @tc_tap wq_tap_tc_again , i(unique_id) j(Round) string
*/


********************************************************************************
** Merging FU datasets to get wide format dataset for all FU rounds
********************************************************************************

*** Loading the master dataset 
use "${DataFinal}1_7_FU_R3_clean_final.dta", clear 

*** Merging the dataset 
merge 1:1 unique_id using  "${DataFinal}1_6_FU_R2_clean_final.dta", gen (Merge_FU3_FU2)
merge 1:1 unique_id using  "${DataFinal}1_5_FU_R1_clean_final.dta", gen (Merge_FU3_FU2_FU1)
merge 1:1 unique_id using  "${DataFinal}1_2_BL_HH_clean_final.dta", gen (Merge_FU3_FU2_FU1_BL_HH)
//total 499 unique obs 

isid unique_id 

*** Dropping varieables not required for analysis 
drop R_FU3_deviceid R_FU2_deviceid R_FU2_devicephonenum R_FU1_deviceid R_FU1_devicephonenum R_FU_deviceid Merge_FU3_FU2 Merge_FU3_FU2_FU1 Merge_FU3_FU2_FU1_BL_HH

*** Saving the cleaned dataset for Follow up surveys 
save "${DataFinal}1_13_Followup_clean_wide.dta", replace 

