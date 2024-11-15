/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creation of final version of merged endline and baseline census dataset (HH Level) and merging it with Final FU dataset 
****** Created by: DIL
****** Last modified by: Niharika Bhagavatula
****** Used by:  DIL
****** Input data : 
	- "${DataFinal}Endline_CBW_level_merged_dataset_final.dta"
	- "${DataTemp}U5_Child_Endline_Census.dta"
	- "${DataFinal}Endline_New_member_roster_dataset_final"
	- "${Intermediate}0_Master_HHLevel.dta" //HH Level dataset Created in "3_X_Final_Data_Creation.do"
	- "${Final}1_13_Followup_clean_wide.dta" //FU dataset Created in 3_X_FU_Data_Creation.do 
****** Output data : 
	- "${DataFinal}0_Master_HHLevel.dta"
	- "${DataFinal}0_Master_HHLevel_FU_Census.dta"
	
****** Do file to run before this do file
	- 3_X_FU_Data_Creation 

****** Language: English
****** Note on Prefixes used: R_Cen_: Raw Baseline Census Variable; R_E_cen_: Raw Endline Census Variable (census members); R_E_n_: Raw Endline Census Variable (new members); comb_: ; C_Cen_: Coded/New Baseline Census Variable; C_E_: Coded/New Endline Census Variable; C_: Coded/New variables for both Basleine and Endline Census; C_FU: Coded/New Baseline HH Variable; C_FU1: Coded/New Follow up R1 Variable; C_FU2: Coded/New Follow up R2 Variable; C_FU3: Coded/New Follow up R3 Variable; R_FU_: Baseline HH Variable; R_FU1_: Follow up R1 Variable; R_FU2_: Follow up R2 Variable; R_FU3_: Follow up R3 Variable

*=========================================================================*/

/* Keys and UIDs
1. unique_id
2. village (village_name)
3. village_id
*/

//making changes to the storage type of the variables in the endline dataset
use "${Intermediate}1_10_Endline_HH_level_merged_dataset.dta", clear  //Users/uchicago/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/8_Intermediate Datasets/1_10_Endline_HH_level_merged_dataset.dta
destring unique_id_num Treat_V, replace
format unique_id_num %20.0g
save "${Intermediate}1_10_Endline_HH_level_merged_dataset.dta", replace 

 /*--------------------------------------------
    Section A: HH level data
 --------------------------------------------*/  
 
 //baseline data
cap program drop start_from_clean_BL_final
program define   start_from_clean_BL_final
  * Open clean file
 * baseline clean
use  "${DataFinal}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
* There are 3,848 households: 915 sample goes to the:  (Original dataset)
// merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
//           keepusing(unique_id   R_FU_consent Merge_C_F R_Cen_survey_time R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_a12_ws_prim Treat_V)
// recode Merge_C_F 1=0 3=1

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
// 	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"
	
end

//Remove HHIDs with differences between census and HH survey
start_from_clean_BL_final
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 
list if unique_id == ""
isid unique_id

///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////
// * 40 household were not followed in the endline
// * Endline_HH_level_merged_dataset_final
// merge 1:1 unique_id using  "${DataFinal}1_8_Endline_Census_cleaned_consented", gen(Merge_Baseline_Endline)
// * keep if Merge_Baseline_Endline==3
// * drop Merge_Baseline_Endline

** changing the storage type of variables to be able to merge 
tostring C_starthour C_startmin, replace 

 
merge 1:1 unique_id using  "${Intermediate}1_10_Endline_HH_level_merged_dataset.dta", gen(Merge_Baseline_Endline)


*** Relabelling the variables
//the following variables were not properly labelled through surveycto do file : all variables have the same labels and value labels; changing it below (lines 694 to 718: import_india_ilc_pilot_census.do)

*Whether HH members have attended school 
	capture{
		foreach rgvar of varlist R_Cen_a9_school_* {
			label variable `rgvar' "A9) Has \${namefromearlier} ever attended school?"
			note `rgvar': "A9) Has \${namefromearlier} ever attended school?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}

*Highest level of schooling of HH members
    capture{
		foreach rgvar of varlist R_Cen_a9_school_level_* {
			label drop `rgvar' //dropping the value labels assigned in line 83 before relabelling 
			label variable `rgvar' "A9.1) What is the highest level of schooling that \${namefromearlier} has comple"
			note `rgvar': "A9.1) What is the highest level of schooling that \${namefromearlier} has completed?"
			label define `rgvar' 1 "Incomplete pre-school (pre-primary or Anganwadi schooling)" 2 "Completed pre-school (pre-primary or Anganwadi schooling)" 3 "Incomplete primary (1st-8th grade not completed)" 4 "Complete primary (1st-8th grade completed)" 5 "Incomplete secondary (9th-12th grade not completed)" 6 "Complete secondary (9th-12th grade not completed)" 7 "Post-secondary (completed education after 12th grade, eg. BA, BSc etc.)" -98 "Refused" 999 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

*Whether HH members currently attend school
	capture {
		foreach rgvar of varlist R_Cen_a9_school_current_* {
			label drop `rgvar' //dropping the value labels assigned in line 83 before relabelling
			label variable `rgvar' "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
			note `rgvar': "A9.2) Is \${namefromearlier} currently going to school/anganwaadi center?"
			label define `rgvar' 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
			label values `rgvar' `rgvar'
		}
	}


*** Recoding the variables 
*Relation with the HH member
replace R_Cen_a5_hhmember_relation_1=1 if unique_id=="30301109034" //selected the relation with HH member as "Wife/Husband" although respondent herself was the HH member in question

* Age of the HH member
replace R_Cen_a6_hhmember_age_2=. if unique_id=="40201111025" //the age of the HH member is coded as 99 as the respondent didn't know the age; replacing it with missing value

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to the do file where the endline dataset is generated

drop R_E_r_cen_*
* Village info is not complete. Deleting the redundant info
destring village BlockCode Panchatvillage , replace
replace village=R_Cen_village_name if village==.
drop R_Cen_village_name R_Cen_block_name Treat_V
merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V Panchatvillage BlockCode) keep(1 3) nogen

save "${Intermediate}0_Master_HHLevel.dta", replace



********************************************************************************
*** Using Women level dataset to get the pregnancy status variable for Endline
********************************************************************************
clear 
use  "${Intermediate}1_10_Endline_final_CBW_level_merged_dataset_cleaned.dta", clear //includes revisit data
gen R_E_key_final= R_E_key
replace R_E_key_final= R_E_Revisit_key if R_E_key_final==""
preserve 
keep R_E_comb_preg_status R_E_key R_E_Revisit_key R_E_key_final unique_id
bys unique_id: gen Num=_n
drop R_E_key R_E_Revisit_key R_E_key_final
reshape wide  R_E_comb_preg_status , i(unique_id) j(Num)
save "${DataTemp}Endline_Preg_status_wide.dta", replace
restore 

********************************************************************************
*** Using Child level dataset to get number of children in each HH for endline
********************************************************************************
clear
use  "${Intermediate}1_10_Endline_final_Child_level_merged_dataset_cleaned.dta", clear
drop if R_E_comb_child_comb_name_label== ""
keep R_E_comb_child_comb_name_label R_E_comb_combchild_status R_E_comb_combchild_index R_E_comb_child_caregiver_present R_E_comb_child_care_pres_oth R_E_comb_child_caregiver_name R_E_comb_child_residence R_E_comb_child_comb_care_label unique_id C_E_entry_type 

//Archi: the variable R_E_Cen_Type is replaced with C_E_entry_type 


*Archi - This step can be skipped because in the updated dataset there are no such cases of prefix 111 
/*split R_E_comb_child_comb_name_label, generate(common_u5_names) parse("111")
replace R_E_comb_child_comb_name_label = common_u5_names2 if common_u5_names2 != ""*/

gen total_U5_kids = 1
bys unique_id: gen Num=_n
//drop common_u5_names1 common_u5_names2

rename R_E_comb_child_comb_name_label U5_Child_label
rename R_E_comb_child_comb_care_label U5_caregiver_label
rename  R_E_comb_child_caregiver_present  R_E_comb_child_care_pres
reshape wide U5_Child_label R_E_comb_combchild_status R_E_comb_combchild_index R_E_comb_child_care_pres R_E_comb_child_care_pres_oth R_E_comb_child_caregiver_name R_E_comb_child_residence U5_caregiver_label C_E_entry_type, i(unique_id) j(Num)
// drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  
save "${DataTemp}U5_Child_Endline_Census_for_merge.dta", replace

********************************************************************************
*** Using new member roster data for age, count & gender of new members 
********************************************************************************
clear 
use "${Intermediate}1_10_Endline_final_roster_merged_census_New_cleaned.dta", clear 
preserve 
gen keep_N = .   //creating a variable to keep only new roster members
replace keep_N = 1 if C_E_entry_type == "N" | C_E_RV_entry_type == "N" 
keep if keep_N == 1
keep  R_E_comb_hhmember_gender R_E_comb_hhmember_age unique_id R_E_key
bysort R_E_key: gen num=_n
reshape wide R_E_comb_hhmember_gender R_E_comb_hhmember_age, i(R_E_key) j(num)
save "${DataTemp}Endline_New_member_gender_wide.dta", replace
restore 



********************************************************************************
*** Merging and loading the dataset
********************************************************************************
clear 
use "${Intermediate}0_Master_HHLevel.dta", clear
merge 1:1 unique_id using "${DataTemp}U5_Child_Endline_Census_for_merge.dta",  gen(merge_num_child)
//879 obs matched (35 out of 36 unmatched obs: ; 1 extra obs is empty obs for UID 30501107052 which was dropped in Master HH level data, dropping that below in line 83)


merge 1:1 unique_id using "${DataTemp}Endline_Preg_status_wide.dta", gen(merge_preg_status)
//885 obs matched (30 unmatched obs: resp not available; 1 matched obs is for UID 30501107052 which was dropped in the Master HH level data, dropping that below in line 83)

//Archi- these are empty variables 
//Niharika to approve this 
drop R_E_comb_hhmember_gender1 R_E_comb_hhmember_gender2 R_E_comb_hhmember_gender3 R_E_comb_hhmember_gender4 R_E_comb_hhmember_gender5 R_E_comb_hhmember_gender6 R_E_comb_hhmember_gender7 R_E_comb_hhmember_age1 R_E_comb_hhmember_age2 R_E_comb_hhmember_age3 R_E_comb_hhmember_age4 R_E_comb_hhmember_age5 R_E_comb_hhmember_age6 R_E_comb_hhmember_age7
merge 1:1 unique_id using "${DataTemp}Endline_New_member_gender_wide.dta", gen(merge_newmem_gender)
//201 obs matched (1 matched obs is for UID 30501107052 which was dropped in the Master HH level data, dropping that below in line 83)
//drop R_E_comb_hhmember_gender* R_E_comb_hhmember_age* //dropping empty variables for gender of new roster members (the variables already presnet in Endline dataset are empty and had to include these variables from the NEw member roster dtaaset - CHECK WITH ARCHI WHY THESE WERE EMPTY)
//Archi- dropped this earlier and replaced with correct ones 


*** Dropping observations
drop if unique_id=="30501107052" //dropping the empty obs as the respondent in this case is not a member of HH; already dropped from Master data
//1 obs dropped

//Total number of observations in the dataset: 914 

********************************************************************************
*** General Checks and changes
********************************************************************************

*** Checking for Duplicates
isid unique_id
isid R_Cen_key
isid R_E_key
// isid R_E_Revisit_key //missing for some observations as key is present only for the revisit cases and not all observations


*** Checking for Outliers 
// * Preserve the original dataset
// preserve
//
// * Checking the number of outliers for the variables and exporting the results 
// local varlist /*list of vars where outliers need to be checked*/
// ipacheckoutliers `varlist', id(unique_id) enumerator(R_Cen_enum_name) ///	
// 		date(enddate) outfile("${DataTemp}/Outliers_MasterHHLevelData.xlsx") 	///
// 			outsheet("Outliers") ///
// 			sheetreplace
//
// * Restoring the original dataset
// restore 
//

*** Changing the storage type of variables for consistency and ease 
foreach var in R_Cen_hh_member_names_count R_E_n_hhmember_count R_E_n_num_female_15to49 R_E_n_num_allmembers_h R_E_jjm_drinking R_E_jjm_yes R_E_tap_supply_freq R_E_tap_supply_daily R_E_tap_function R_E_tap_function_reason R_E_tap_function_reason_1 R_E_tap_function_reason_2 R_E_tap_function_reason_3 R_E_tap_function_reason_4 R_E_tap_function_reason_5 R_E_tap_function_reason_999 R_E_tap_function_reason__77 R_E_tap_issues R_E_tap_issues_type R_E_tap_issues_type_1 R_E_tap_issues_type_2 R_E_tap_issues_type_3 R_E_tap_issues_type_4 R_E_tap_issues_type_5 R_E_tap_issues_type__77 R_E_consent R_E_jjm_use R_E_jjm_use_1 R_E_jjm_use_2 R_E_jjm_use_3 R_E_jjm_use_4 R_E_jjm_use_5 R_E_jjm_use_6 R_E_jjm_use_7 R_E_jjm_use__77 R_E_jjm_use_999 R_E_reason_nodrink R_E_reason_nodrink_1 R_E_reason_nodrink_2 R_E_reason_nodrink_3 R_E_reason_nodrink_4 R_E_reason_nodrink_999 R_E_reason_nodrink__77 R_E_treat_freq R_E_treat_time R_E_collect_treat_difficult R_E_water_stored R_E_water_treat R_E_treat_primresp R_E_where_prim_locate R_E_collect_time R_E_collect_prim_freq R_E_prim_collect_resp R_E_cen_fam_age* R_E_cen_fam_gender* R_E_n_fam_age* R_E_clean_freq_containers R_E_clean_time_containers R_E_treat_kids_freq_1 R_E_treat_kids_freq_2 R_E_treat_kids_freq_3 R_E_treat_kids_freq_4 R_E_treat_kids_freq_5 R_E_treat_kids_freq_6 R_E_treat_kids_freq__77 R_E_water_treat_kids R_E_water_treat_kids_type_1 R_E_water_treat_kids_type_3 R_E_water_treat_kids_type_2 R_E_water_treat_kids_type_4 R_E_water_treat_kids_type__77 R_E_water_treat_kids_type_999 R_Cen_phone_number_count R_E_water_source_sec_* R_E_sec_source_reason_* R_E_water_sec_freq R_E_water_treat_freq_* R_E_water_treat_kids_type_* R_E_treat_kids_freq_* R_E_water_source_prim R_E_water_treat_type_* R_E_water_prim_source_kids R_E_water_sec_yn R_E_no_consent_reason_* R_E_water_source_kids R_E_jjm_stored {
	destring `var', replace
}


********************************************************************************
*** Manual Corrections
********************************************************************************

*** Changing the number of phone numbers received from hh if one or both of the numbers given were placeholderss (9999999999)
replace R_Cen_phone_number_count=1 if R_Cen_a39_phone_num_1=="9999999999" | R_Cen_a39_phone_num_2== "9999999999"
replace R_Cen_phone_number_count=0 if R_Cen_a39_phone_num_1=="9999999999" & R_Cen_a39_phone_num_2== "9999999999"


*** Generating a variable to identify residents of Bapuji Nagar in Karlakana
gen resident_bapujinagar = .
replace resident_bapujinagar = 1 if village == 50301 & (R_Cen_hamlet_name == "Bapuji Nagar" | R_Cen_hamlet_name == "Bapuji nagar" | R_Cen_hamlet_name == "Karlakana Bapuji nagar" | R_Cen_hamlet_name == "Bapuji nagar" | R_Cen_hamlet_name == "Karlakana, Bapuji nagar" | R_Cen_hamlet_name == "Karlakana Babuji nagar" | R_Cen_hamlet_name == "Karlakana (bapuji nagar)" | R_Cen_hamlet_name == "Bapujinagar ward no 4" | R_Cen_hamlet_name == "Karlakana(Bapuji nagar)" | R_Cen_hamlet_name == "Babuji nagar" | R_Cen_hamlet_name == "Karlakana,Bapuji nagar" | R_Cen_hamlet_name == "Bapujinagar ward no 4," | R_Cen_hamlet_name == "Karlakana Babuji nagar right side house")
* Replacing 'primary source of water' to "Govt tap other than jjm/basudha/rwss" if HH is a resident of Bapuji Nagar (Karlakana) 
//these HHs get water from a non-JJM Govt provided HH tap 
replace R_E_water_source_prim = 10 if village == 50301 & resident_bapujinagar == 1 & R_E_water_source_prim == 1 
replace R_Cen_a12_water_source_prim= 10 if village == 50301 & resident_bapujinagar == 1 & R_Cen_a12_water_source_prim == 1 

*** Correcting the errors in responses (Enumerator errors and SCTO errors) : Endline Variables  
**Enumerator incorrectly mentioned that HH treats water in "R_E_water_treat" when the HH doesn't; replacing the ressponses to reflect non-treatment of water by the HH
replace R_E_water_treat=0 if unique_id=="50401117020"

//replacing responses to all follow-up questions with a missing value
foreach var in R_E_collect_treat_difficult R_E_treat_freq R_E_treat_time R_E_treat_primresp R_E_water_treat_type_1 R_E_water_treat_type_2 R_E_water_treat_type_3 R_E_water_treat_type_4 R_E_water_treat_type__77 R_E_water_treat_type_999    { //numeric variables
replace `var'=. if unique_id=="50401117020"
}

foreach var in R_E_water_treat_type R_E_treat_resp { //string variables
replace `var'="" if unique_id=="50401117020"
}


*** Correcting the errors in responses (Enumerator errors and SCTO errors) : Baseline  Variables 
**Enumerator incorrectly mentioned that HH treats water in "R_Cen_a16_water_treat" and "R_Cen_a17_water_treat_kids" when the HH doesn't; replacing the responses to reflect non-treatment of water by the HH
replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "Kichi karunahanti" 
replace R_Cen_a17_water_treat_kids = 0 if R_Cen_water_treat_kids_oth == "Kichi karunahanti"

//replacing responses to all follow-up questions of "R_Cen_a16_water_treat" with a missing value
ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_* 
foreach var of varlist `r(varlist)'{
replace `var' = . if unique_id == "20201113035" | unique_id=="40201113009" | unique_id=="50301105017" //numeric variables
}

ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
foreach var of varlist `r(varlist)'{
replace `var' = "" if unique_id == "20201113035" | unique_id=="40201113009" | unique_id=="50301105017"  //string variables
}

/*Not sure : Can't say if the HH has a pvt tank and cleans it regulary or is referring to the village tank
//finding the case of baseline for same variable 

//The IDs are below all those cases where treatment actually wans't performed but surveyor still went ahead and said yes to the screening variable 

//10101111021
// replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "For 1month tank cleaning"
//
// ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_*
// 
// foreach var of varlist `r(varlist)'{
// replace `var' = . if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021" 
// }
//
// ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
// foreach var of varlist `r(varlist)'{
// replace `var' = "" if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021" 
// }
//
// replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021"  

*/

//replacing responses to all follow-up questions of "R_Cen_a17_water_treat_kids" with a missing value
ds R_Cen_a17_water_treat_kids  R_Cen_water_treat_kids_type_*  R_Cen_a17_treat_kids_freq_*
foreach var of varlist `r(varlist)'{
replace `var' = . if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti" //numeric variables
}

ds R_Cen_water_treat_kids_type R_Cen_a17_treat_kids_freq
foreach var of varlist `r(varlist)'{
replace `var' = "" if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti" //string variables
}


**Enumerator selected that U5 child in the family has a different source of water than rest of HH but selected same source (JJM tap)for both HH and U5Child
//replacing the value of variable "R_Cen_a17_water_source_kids" to reflect that same water source is used by HH and U5 children 
replace R_Cen_a17_water_source_kids = 1 if  R_Cen_water_prim_source_kids == 1 & R_Cen_a12_water_source_prim == 1 & R_Cen_a17_water_source_kids == 0


**In following cases, both primary and secondary sources of water were selected as JJM given the SCTO constraint was not working; given all HHs selected multiple secondary sources, retaining only the sec sources other than JJM in the responses for these cases: 
br unique_id R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec R_Cen_a13_water_source_sec_1 R_Cen_a13_water_source_sec_2 R_Cen_a20_jjm_use R_Cen_a18_jjm_drinking R_Cen_a20_jjm_yes R_E_jjm_use R_E_jjm_yes R_E_jjm_drinking if R_Cen_a13_water_source_sec_1==0 & R_Cen_a13_water_source_sec_2==0 & R_Cen_a12_water_source_prim!=1 & R_Cen_a12_water_source_prim!=2

// Replacing the source of secondary water to make sure both priamry and secondary sources are not JJM
//Replacing the "R_Cen_a13_water_source_sec" variable to reflect only the alternative secondary source selected
replace R_Cen_a13_water_source_sec = "2" if unique_id == "50301117004" 
replace R_Cen_a13_water_source_sec = "4" if unique_id == "50401117012" | unique_id == "50401117020" | unique_id == "50401117021" | unique_id == "50402117018" | unique_id == "50402117034" | unique_id == "50402117026" | unique_id == "50402117041" | unique_id == "50402117043" 
replace R_Cen_a13_water_source_sec = "3 4" if unique_id == "50402117019" | unique_id == "50402117028" 
replace R_Cen_a13_water_source_sec = "3" if unique_id == "50402117042" 

//Replacing the "R_Cen_a13_water_source_sec_1" variable to zero to indicate that the secondary source is not JJM 
replace R_Cen_a13_water_source_sec_1 = 0 if unique_id == "50301117004" | unique_id == "50401117012" | unique_id == "50401117020" | unique_id == "50401117021" | unique_id == "50402117018" | unique_id == "50402117019" | unique_id == "50402117026" | unique_id == "50402117028" | unique_id == "50402117034" | unique_id == "50402117041" | unique_id == "50402117042" | unique_id == "50402117043" 


**In following cases, HHs do not use govt/JJM tap water as their primary or secondary source of water (source used by them recorded under "Other" in  "A12_prim_source_oth"); Given the jjm section is applicable only for HHs using govt/JJM tap as prim/sec source in Baseline, replacing responses to all questions in this section to missing (GitHub issue #81)
//Recoding variables in the jjm section (usage of govt tap) to missing 
foreach var in R_Cen_a18_reason_nodrink_1 R_Cen_a18_reason_nodrink_2 R_Cen_a18_reason_nodrink_3 R_Cen_a18_reason_nodrink_4 R_Cen_a18_reason_nodrink_999 R_Cen_a18_reason_nodrink__77 R_Cen_a18_jjm_drinking R_Cen_a20_jjm_yes R_Cen_a20_jjm_use_1 R_Cen_a20_jjm_use_2 R_Cen_a20_jjm_use_3 R_Cen_a20_jjm_use_4 R_Cen_a20_jjm_use_5 R_Cen_a20_jjm_use_6 R_Cen_a20_jjm_use_7 R_Cen_a20_jjm_use_999 R_Cen_a20_jjm_use__77 { //numeric variables
	replace `var'=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
}

foreach var in R_Cen_a18_reason_nodrink R_Cen_a18_water_treat_oth R_Cen_a20_jjm_use R_Cen_a20_jjm_use_oth { //string variables 
	replace `var'="" if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
}


**In the following cases (15 in total) either the age or gender of respondent or hh members was incorrectly noted during baselins, such cases were identified in endline and listed under new members with relevant changes; (Github issue #116)

*cases where a change in age is recorded in endline by one year
replace R_Cen_a6_hhmember_age_5=R_E_n_fam_age1 if unique_id=="10101108026" //age mentioned as 14 in baseline and 15 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="20201111076" //age mentioned as 4 in baseline and 5 in endline 
replace R_Cen_a6_hhmember_age_5=R_E_n_fam_age1 if unique_id=="40301113007" //age mentioned as 14 in baseline and 15 in endline 

*other cases where age was incorrectly mentioned in baseline
replace R_Cen_a6_hhmember_age_1=R_E_n_fam_age1 if unique_id=="50301105008" //age mentioned as 50 in Baseline and 43 in Endline
replace R_Cen_a6_hhmember_age_8=R_E_n_fam_age2 if unique_id=="40202113033" //age mentioned as 12 in Baseline and 1 in Endline
replace R_Cen_a6_hhmember_age_5=R_E_n_fam_age1 if unique_id=="50201115043" //age mentioned as 30 in baseline and 39 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="20201108055" //age mentioned as 40 in baseline and 67 in endline 
replace R_Cen_a6_hhmember_age_4=R_E_n_fam_age1 if unique_id=="20201110019" //age mentioned as 45 in baseline and 52 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="20201110035" //age mentioned as 42 in baseline and 57 in endline 
replace R_Cen_a6_hhmember_age_4=R_E_n_fam_age2 if unique_id=="30301104006" //age mentioned as 30 in baseline and 39 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="30501111018" //age mentioned as 14 in baseline and 16 in endline 
replace R_Cen_a6_hhmember_age_7=R_E_n_fam_age1 if unique_id=="30501111021" //age mentioned as 50 in baseline and 42 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="30602106057" //age mentioned as 17 in baseline and 13 in endline 
replace R_Cen_a6_hhmember_age_2=R_E_n_fam_age1 if unique_id=="30602106063" //age mentioned as 48 in baseline and 53 in endline 
replace R_Cen_a6_hhmember_age_3=R_E_n_fam_age1 if unique_id=="40301113016" //age mentioned as 50 in baseline and 44 in endline 

*cases where the gender was incorrectly mentioned in baseline
replace R_Cen_a4_hhmember_gender_5=2 if unique_id=="50201115043" //gender mentioned as male in baseline and female in endline
replace R_Cen_a4_hhmember_gender_4=2 if unique_id=="30301104006" //gender mentioned as male in baseline and female in endline

*Changing the values of variables storing information gender and age of new memebers for these observations to missing (given their details have been changed in the baseline variables, chnaging the new member roster variables to missing would avoid double counting of these members)
//replacing the age variable in new member roster with information on new members in endline census and endline revisit
replace R_E_comb_hhmember_age1=. if unique_id=="50301105008" | unique_id=="50201115043" | unique_id=="20201108055" | unique_id=="20201110019" | unique_id=="20201110035" | unique_id=="30501111018" | unique_id=="30501111021" | unique_id=="30602106057" | unique_id=="30602106063" | unique_id=="40301113016" 
replace R_E_comb_hhmember_age2=. if unique_id=="40202113033" | unique_id=="30301104006" 

//replacing the gender variable in new member roster with information on new members in endline census and endline revisit
replace R_E_comb_hhmember_gender1=. if unique_id=="50201115043" 
replace R_E_comb_hhmember_gender2=. if unique_id=="30301104006" 

//replacing the age variable in new member roster with information on new members in endline census only
replace R_E_n_fam_age1=. if unique_id=="50301105008" | unique_id=="50201115043" | unique_id=="20201108055" | unique_id=="20201110019" | unique_id=="20201110035" | unique_id=="30501111018" | unique_id=="30501111021" | unique_id=="30602106057" | unique_id=="30602106063" | unique_id=="40301113016" 
replace R_E_n_fam_age2=. if unique_id=="40202113033" | unique_id=="30301104006" 
 
*Changing the "R_E_n_hhmember_count" variable in these cases to ensure that these members are not counted as new members
replace R_E_n_hhmember_count=(R_E_n_hhmember_count-1) if unique_id=="50301105008" | unique_id=="40202113033" | unique_id=="50201115043" | unique_id=="20201108055" | unique_id=="20201110019" | unique_id=="20201110035" | unique_id=="30301104006" | unique_id=="30501111018" | unique_id=="30501111021" | unique_id=="30602106057" | unique_id=="30602106063" | unique_id=="40301113016" |  unique_id=="10101108026" | unique_id=="20201111076" | unique_id=="40301113007"

*Changing the "R_E_n_female_15to49" and "R_E_n_num_female_15to49" variables in these cases (wherever applicable) to ensure that the members are not counted twice as female members of the family and the count of total female members is not changed
replace R_E_n_female_15to49="" if unique_id=="50201115043" //respondent's gender mentioned as male in baseline and female in endlien but baseline gender changed in line 246 above; to avoid double counting in total number of females aged 15 to 49, replacing the value to 0 from 1

replace R_E_n_num_female_15to49=0 if unique_id=="50201115043" //respondent's gender mentioned as male in baseline and female in endlien but baseline gender changed in line 246 above; to avoid double counting in total number of females aged 15 to 49, replacing the value to 0 from 1

replace R_E_n_female_15to49="1" if unique_id=="30301104006" //respondent's gender mentioned as male in baseline and female in endlien but baseline gender changed in line 246 above; to avoid double counting in total number of females aged 15 to 49, replacing the value to 1 from 2 (two new members entered in roster: one to register change in gender and another to fill entire roster)

*Below respondent was listed as Male in Baseline Census but is actually a female - replacing the gender variable to reflect the same 
/*Note:
Given she was listed as Male, the respondent's details for the CBW Women section were not collected. Flagged the same in the Individual level data as well
*/
replace R_Cen_a4_hhmember_gender_3=2 if unique_id=="50101119006" & R_Cen_namefromearlier_3=="Rukmani katabansa"


**Correcting the name of the village (GitHub Issue: #138)
//The Village ID and name for the following observations were incorrectly enetered, repalcing the village names - change implemented in individual level datasets as well. 
//HH is a resident of Tandipur but was listed as resident of Bhujbal
replace R_E_village_name_str = "Tandipur"  if  R_E_village_name_str ==  "Bhujbal" & unique_id == "30501119006"
replace Village = "Tandipur"  if Village == "Bhujbal" & unique_id == "30501119006"
replace village = 30301  if village == 30501 & unique_id == "30501119006"

//HH is a resident of Bhujbal but was listed as resident of Tandipur
replace R_E_village_name_str = "Bhujbal" if  R_E_village_name_str == "Tandipur" & unique_id == "30301119027"
replace Village = "Bhujbal" if Village == "Tandipur"  & unique_id == "30301119027"
replace village = 30501 if village == 30301 & unique_id == "30301119027"


**Creating new variable to flag if Survey not administered to the respondents (GitHub Issue #136)
//In the following cases, certain sections of Endline survey not administered to certain members of HH; the same is mentioned in two cases in "end comments"; creating a new variable to flag the same
gen survey_issues=0
replace survey_issues=1 if unique_id=="30501107008" //respondent can't hear properly: U5 and CBW sections not administered
replace survey_issues=1 if unique_id=="30501117025" //respondent only speaks telugu: U5 kids section and CBW section not administered
replace survey_issues=1 if unique_id=="50301117008" //main respondnet was unavailabel (mentioned in comments); another new member (CBW) couldn't speak: sections of endline survey not admisnitered to both of them
replace survey_issues=1 if unique_id=="50101119006" //respondent listed as male in baseline: CBW section didn't appear in Endlline and was not adminsitered

label var survey_issues "Issues with survey administration"
label define survey_issues 1 "Some survey sections not administered" 2 "False positive results"
label values survey_issues survey_issues


********************************************************************************
*** Categorizing the text responses (other category responses): BASELINE
********************************************************************************
//Creating similar categories for both baseline and endline for consistency) 
				  
*** R_Cen_a16_water_treat_oth: "What else do you do to the water from the primary source (${primary_water_label}) to make it safe for drinking? (follow up question for those who select "Other" in R_Cen_a16_water_treat_type. Orginal responses include 4 main categories + other + don't know)

*Creating new category for those using Aqua filter (for consistency with FU rounds)
gen R_Cen_water_treat_type_7=.
replace R_Cen_water_treat_type_7=0 if R_Cen_a16_water_treat_type!=""
replace R_Cen_water_treat_type_7=1 if R_Cen_a16_water_treat_type=="Aquaguard" | R_Cen_a16_water_treat_type=="Kent Ro" | R_Cen_a16_water_treat_type=="Filter"

label var R_Cen_water_treat_type_7 "Aqua filter"
label define R_Cen_water_treat_type_7 1 "Yes" 0 "No"
label values R_Cen_water_treat_type_7 R_Cen_water_treat_type_7 

*Creating new category for those Purchasing bottled water (for consistency with FU rounds)
gen R_Cen_water_treat_type_8=.
replace R_Cen_water_treat_type_8=0 if R_Cen_a16_water_treat_type!=""

label var R_Cen_water_treat_type_8 "Purchase filtered bottle"
label define R_Cen_water_treat_type_8 1 "Yes" 0 "No"
label values R_Cen_water_treat_type_8 R_Cen_water_treat_type_8 

*Creating a new category for those who clean their containers
gen R_Cen_water_treat_type_5=. 
replace R_Cen_water_treat_type_5=0 if R_Cen_a16_water_treat_type!=""
// replace R_Cen_water_treat_type_5=1 if 

*Creating a new category for those who cover their containers to keep the water safe 
gen R_Cen_water_treat_type_6=. 
replace R_Cen_water_treat_type_6=0 if R_Cen_a16_water_treat_type!=""
replace R_Cen_water_treat_type_6=1 if R_Cen_a16_water_treat_oth ==  "Ghodeiki rakhuchnti"

*Recategorising into existing categories 
//Filter the water through a cloth or sieve
replace R_Cen_a16_water_treat_type_1=1 if R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" 

*Replacing the other category with zero after categoring the text responses
replace R_Cen_a16_water_treat_type__77=0 if R_Cen_a16_water_treat_oth ==  "Ghodeiki rakhuchnti" | R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" | R_Cen_a16_water_treat_type=="Aquaguard" | R_Cen_a16_water_treat_type=="Kent Ro" | R_Cen_a16_water_treat_type=="Filter"

/*Not categorised yet:
For 1month tank cleaning 
First pani ku chhadiki, pani clear asila pare badeiki anuchanti
Jane kebala chuna miseike pihanti au baki samastye semiti pianti
*/

*** Reasons for not drinking JJM tap water: Baseline
*Recategorizing into existing categories 
//Option 4: Reason for not drinking: Water is smelly or muddy 
replace R_Cen_a18_reason_nodrink_4=1 if  R_Cen_a18_water_treat_oth=="Luha luha gandhuchi & dost asuchi" | ///
R_Cen_a18_water_treat_oth=="Supply pani piu nahanti kintu anya kama re lagauchhnti , gadheiba, basana dhaiba, luga dhaiba" 

/*
//Option 3: Reason for not drinking: Water supply is intermittent 
replace R_Cen_a18_reason_nodrink_3=1 if R_Cen_a18_water_treat_oth==

//Option 2: Reason for not drinking: Water supply is inadequate
replace R_Cen_a18_reason_nodrink_2=1 if R_Cen_a18_water_treat_oth==
*/

//Option 1: Reason for not drinking: Tap is broken and doesn't supply water 
replace R_Cen_a18_reason_nodrink_1=1 if R_Cen_a18_water_treat_oth=="Tap bhangi jaichhi" //tap is broken 

*Creating a new category for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank  
gen R_Cen_a18_reason_nodrink_5=.
replace R_Cen_a18_reason_nodrink_5=0 if R_Cen_a18_reason_nodrink!=""
replace R_Cen_a18_reason_nodrink_5=1 if R_Cen_a18_jjm_drinking==2 
replace R_Cen_a18_reason_nodrink_5=1 if R_Cen_a18_water_treat_oth=="Paipe connection heinai" | ///
R_Cen_a18_water_treat_oth=="Paip connection nahi" | R_Cen_a18_water_treat_oth=="Tape connection nahi" | ///
R_Cen_a18_water_treat_oth=="Tap aasi nahi" | R_Cen_a18_water_treat_oth=="Tap Nehni Mila" | ///
R_Cen_a18_water_treat_oth=="Tap pani lagi nahi" | R_Cen_a18_water_treat_oth=="FHTC Tap Not contacting this house hold." | ///
R_Cen_a18_water_treat_oth=="Tap connection dia heini" | R_Cen_a18_water_treat_oth=="Government pani tap connection heini" | ///
R_Cen_a18_water_treat_oth=="Respondent doesn't have personal household Tap water connection provided by government" | ///
R_Cen_a18_water_treat_oth=="Don't have government supply tap" | R_Cen_a18_water_treat_oth=="Government don't supply house hold taps" | ///
R_Cen_a18_water_treat_oth=="Tape conektion nahi" | R_Cen_a18_water_treat_oth=="Gharme government tap nehni laga hai" 



*Creating a new category for those who dont drink jjm water because they fetch drinking water from other private water source
gen R_Cen_a18_reason_nodrink_6=.
replace R_Cen_a18_reason_nodrink_6=0 if R_Cen_a18_reason_nodrink!=""
replace R_Cen_a18_reason_nodrink_6=1 if R_Cen_a18_water_treat_oth=="Jehetu Nijara kua achi se government pani ku use karantini," | ///
R_Cen_a18_water_treat_oth=="Jehetu nija Borwell achi se government tap pani piunahanti" | ///
R_Cen_a18_water_treat_oth=="Nija ghare bore water achi Sethi pai aame supply pani bebahara karunahanti" | ///
R_Cen_a18_water_treat_oth=="Ghare motor achi Sethi pae" | R_Cen_a18_water_treat_oth=="Pani pahanchi parunathila sethipai nija Borwell kholilu" | ///
R_Cen_a18_water_treat_oth=="Government tap pare diahela sethipai nijara Borwell kholeiki piuchu"

*Creating a new category for those who dont drink jjm water as the Water from Government provided household tap does not taste good for consistency with follow up rounds 
gen R_Cen_a18_reason_nodrink_7=.
replace R_Cen_a18_reason_nodrink_7=0 if R_Cen_a18_reason_nodrink!=""

*Replacing the other category with zero after categoring the text responses
replace R_Cen_a18_reason_nodrink__77=0 if R_Cen_a18_water_treat_oth=="Paipe connection heinai" | ///
R_Cen_a18_water_treat_oth=="Paip connection nahi" | R_Cen_a18_water_treat_oth=="Tape connection nahi" | ///
R_Cen_a18_water_treat_oth=="Tap aasi nahi" | R_Cen_a18_water_treat_oth=="Tap Nehni Mila" | ///
R_Cen_a18_water_treat_oth=="Tap pani lagi nahi" | R_Cen_a18_water_treat_oth=="FHTC Tap Not contacting this house hold." | ///
R_Cen_a18_water_treat_oth=="Tap connection dia heini" | R_Cen_a18_water_treat_oth=="Government pani tap connection heini" | ///
R_Cen_a18_water_treat_oth=="Respondent doesn't have personal household Tap water connection provided by government" | ///
R_Cen_a18_water_treat_oth=="Don't have government supply tap" | R_Cen_a18_water_treat_oth=="Government don't supply house hold taps" | ///
R_Cen_a18_water_treat_oth=="Tape conektion nahi" | R_Cen_a18_water_treat_oth=="Gharme government tap nehni laga hai" | ///
R_Cen_a18_water_treat_oth=="Luha luha gandhuchi & dost asuchi" | R_Cen_a18_water_treat_oth=="Tap bhangi jaichhi" | ///
R_Cen_a18_water_treat_oth=="Supply pani piu nahanti kintu anya kama re lagauchhnti , gadheiba, basana dhaiba, luga dhaiba" | ///
R_Cen_a18_water_treat_oth=="Jehetu Nijara kua achi se government pani ku use karantini," | ///
R_Cen_a18_water_treat_oth=="Jehetu nija Borwell achi se government tap pani piunahanti" | ///
R_Cen_a18_water_treat_oth=="Nija ghare bore water achi Sethi pai aame supply pani bebahara karunahanti" | ///
R_Cen_a18_water_treat_oth=="Ghare motor achi Sethi pae" | R_Cen_a18_water_treat_oth=="Pani pahanchi parunathila sethipai nija Borwell kholilu" | ///
R_Cen_a18_water_treat_oth=="Government tap pare diahela sethipai nijara Borwell kholeiki piuchu" 

*Replacing the missing observations for "0" where R_Cen_a18_reason_nodrink==2 
//(In Baseline, question on reason for not drinking jjm water was skipped for HHs who said they "do not have a tap connection" in the question on "whether HH uses jjm". In endline, the option of "do not have a tap connection" was not given and HHs mentioned this in  "reasons for not using jjm". Given the baseline response has been recoded into a new category/reason for not drinking jjm water in line 312, replacing the values for followup questions for consistnency)
foreach var in R_Cen_a18_reason_nodrink_1 R_Cen_a18_reason_nodrink_2 R_Cen_a18_reason_nodrink_3 R_Cen_a18_reason_nodrink_4 R_Cen_a18_reason_nodrink_6 R_Cen_a18_reason_nodrink_7 R_Cen_a18_reason_nodrink__77 R_Cen_a18_reason_nodrink_999 {
	replace `var'=0 if R_Cen_a18_jjm_drinking==2
}


/** Responses not catergorised yet:  R_Cen_a18_water_treat_oth 
//Not sure about the category:

//Does the hh not get water from the tap (to be categorised into R_Cen_a18_reason_nodrink_1) or does the hh not have a tap connection (to be categorised into reason_nodrink_5_bl): 
"Government doesn't provide house hold tap water"
"No government supply tap water"
"No government supply tap water for household"
"No government supply tap water"
"No supply govt tap water in this Home" 

//the person selected JJM tap water as primary source of water; not sure if this is the case where water is not being supplied or the HH doesn't have a tap connection
"No direct supply water tap" 


//Vague
"Not interested"
"Supply Pani bhala lagunagi" //dont like tap water - should we categorize it into muddy/silty? - R_Cen_a18_reason_nodrink_4
"Pani aasunahi" //water supply related issue - should we categorize it into "intermittent water supply" or "tap is broken and doesn't supply water"



//Translations required: 
"Jane asi pani chek kari kahithile pani kharap achhi" //someone came to check the water and said it's bad?
"Supply pani timing re dia jaunahi Sethi pai tanka bore water used karunahanti" // water not supplied at a fixed time? (irregular supply)
"Nijara bor pani 1st ru piba pain byabahara karichhanti sethipain" 
"Agaru  handpump paniobhayas heichu Sethi pae  tap Pani piunu" 
"Tankara bore water achi Sethi pai tap Pani used karunahanti"
"Ghare morar achi Sethi pae suffly Pani piunahnti"
"Nija ra  electrical motar pani achi Sethi pae piunahi"
"Ye hamlet me jo nichewala hissa he usko hi pani atahe khud ki tap he lekin pani nehi atahe wo dusre gharse latehe."
"Ehi ghara ra sakaranka jogaidiajaithiba gharei tap uchha jagare achhi tenu pani  totally asuni sethipain se podishi Gharara sarakaranka jogaithiba ghorei tap ru pani piba pain anuchhanti"
"Agaru abhayas heichanti to ghorai tap pani piunahanti" 
"Pani stock rahithibaru , bacteria thiba boli pintini"
"Sarakara nka tarafaru pani jogai dia jainahni"
"Tube well pani peibara abhyasa hoijaichhi sethipai sarakari tap pani pieunahu"
"Thanda kasa haba boli tap pani peunahanti"
"Pani aani ki ghare rakhile tela bhalia hoi hauchi au gadheile dehare phutuka hoi jauchi"
"Pakhare Manual Hand pump achhi" 
*/

*Recategorising obs where respondents said they don't drink jjm water as they dont have a tap connection in "R_Cen_jjm_drinking" to "No" given a new option has been created in "R_Cen_reason_nodrink" (for consistency with Endline)
replace R_Cen_a18_jjm_drinking=0 if R_Cen_a18_jjm_drinking==2

*** R_Cen_a20_jjm_use_oth: "or what other purposes do you use water collected from the government provided household taps?" (options include 7 categories, other and dont know)
*Recategorising into existing categories
//Option 4: Cleaning the house (Expanding it to include Cleaning and other activities around the household like washing vehicles, construction related activites, etc., and relabelling it)
replace R_Cen_a20_jjm_use_4=1 if R_Cen_a20_jjm_use_oth=="Gadi dhuahua" | R_Cen_a20_jjm_use_oth=="Phuka gachhare pani deu" | R_Cen_a20_jjm_use_oth=="Ghara kamare byabaara karajauchhi"

label var R_E_jjm_use_4 "Cleaning and other HH activites"
label define R_E_jjm_use_4 1 "Yes" 0 "No"
label values R_E_jjm_use_4 R_E_jjm_use_4 


//Option 5: Bathing (Expanding it to include use for hygiene and sanitation purposes and relabelling it)
replace R_Cen_a20_jjm_use_5=1 if R_Cen_a20_jjm_use_oth=="Hata dhoiba" | R_Cen_a20_jjm_use_oth=="Hata goda dhoiba pai" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Bathroom" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrin bathroom use" | R_Cen_a20_jjm_use_oth=="Latin Pai" | R_Cen_a20_jjm_use_oth=="Toilet pai" | R_Cen_a20_jjm_use_oth=="Toilet" | R_Cen_a20_jjm_use_oth=="Hata dhaiba" | R_Cen_a20_jjm_use_oth=="Toilet wash" | R_Cen_a20_jjm_use_oth=="Jehetu kam pani asuchi se khali Hata goda dhuanti" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Katrine" | R_Cen_a20_jjm_use_oth=="Bathroom use" 

label var R_E_jjm_use_5 "Hygiene and Sanitation purposes"
label define R_E_jjm_use_5 1 "Yes" 0 "No"
label values R_E_jjm_use_5 R_E_jjm_use_5 


//Option 7: Irrigation (Expanding it to include gardening as well and relabelling it)
replace R_Cen_a20_jjm_use_7=1 if R_Cen_a20_jjm_use_oth=="Gachhare deuchhanti"

label var R_E_jjm_use_7 "Irrigation and Gardening"
label define R_E_jjm_use_7 1 "Yes" 0 "No"
label values R_E_jjm_use_7 R_E_jjm_use_7 


*Creating new category for those who use it for worship (for consistency with follow up rounds)
gen R_Cen_a20_jjm_use_8=.
replace R_Cen_a20_jjm_use_8=0 if R_Cen_a20_jjm_use!=""
replace R_Cen_a20_jjm_use_8=1 if R_Cen_a20_jjm_use_oth=="Puja karanti"

label var R_Cen_a20_jjm_use_8 "Puja/Worship"
label define R_Cen_a20_jjm_use_8 1 "Yes" 0 "No"
label values R_Cen_a20_jjm_use_8 R_Cen_a20_jjm_use_8


/*Not categorised yet: hhs who use it for use in own enterprises : can be categorised into Cleaning and related HH activities
Dokan kama re use koruchu //use it in the shop (owned by hh)
*/

*Replacing the other category with zero after categoring the text responses
replace R_Cen_a20_jjm_use__77=0 if R_Cen_a20_jjm_use_oth=="Hata dhoiba" | R_Cen_a20_jjm_use_oth=="Hata goda dhoiba pai" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Bathroom" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrin bathroom use" | R_Cen_a20_jjm_use_oth=="Latin Pai" | R_Cen_a20_jjm_use_oth=="Toilet pai" | R_Cen_a20_jjm_use_oth=="Toilet" | R_Cen_a20_jjm_use_oth=="Hata dhaiba" | R_Cen_a20_jjm_use_oth=="Toilet wash" | R_Cen_a20_jjm_use_oth=="Jehetu kam pani asuchi se khali Hata goda dhuanti" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Latrine" | R_Cen_a20_jjm_use_oth=="Katrine" | R_Cen_a20_jjm_use_oth=="Bathroom use" | R_Cen_a20_jjm_use_oth=="Gachhare deuchhanti" | R_Cen_a20_jjm_use_oth=="Gadi dhuahua" | R_Cen_a20_jjm_use_oth=="Phuka gachhare pani deu" | R_Cen_a20_jjm_use_oth=="Ghara kamare byabaara karajauchhi" | R_Cen_a20_jjm_use_oth=="Puja karanti"



*** R_Cen_a12_prim_source_oth: "In the past month, which other water source did you primarily use for drinking?" (Options include 8 options and other)
*Recategorising into existing categories
//Option 3: Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank) 
replace R_Cen_a12_water_source_prim=3 if R_Cen_a12_prim_source_oth=="Sajaldhara scheme"

*Creating new category for those who use Borewell operated by electric pump 
replace R_Cen_a12_water_source_prim=9 if R_Cen_a12_prim_source_oth=="Nijara bor pani" | R_Cen_a12_prim_source_oth=="Borewell" | R_Cen_a12_prim_source_oth=="Borewell" | R_Cen_a12_prim_source_oth=="Nija Borwell pani" | R_Cen_a12_prim_source_oth=="Nija Borwell pani piuchanti" | R_Cen_a12_prim_source_oth=="Borewell" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Nijara bor pane" | R_Cen_a12_prim_source_oth=="Motor achi" | R_Cen_a12_prim_source_oth=="Motor achi" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Borwell" |  R_Cen_a12_prim_source_oth=="Personal Borring" | R_Cen_a12_prim_source_oth=="Barwel" | R_Cen_a12_prim_source_oth=="Baewal" | R_Cen_a12_prim_source_oth=="Own borewell" | R_Cen_a12_prim_source_oth=="Own borewell" | R_Cen_a12_prim_source_oth=="Own borewell" | R_Cen_a12_prim_source_oth=="Padosi kn borewell pani" | R_Cen_a12_prim_source_oth=="Padosi kn borewell pani" | R_Cen_a12_prim_source_oth=="Own Borwell" | R_Cen_a12_prim_source_oth=="Own Borwell" | R_Cen_a12_prim_source_oth=="Borewell" | R_Cen_a12_prim_source_oth=="Padisa ghara Borwell ru masaku 300 tanka ra kiniki anuchanti" |  R_Cen_a12_prim_source_oth=="Own borewell" | R_Cen_a12_prim_source_oth=="Own borewell" | R_Cen_a12_prim_source_oth=="Own Borwell" | R_Cen_a12_prim_source_oth=="Own Borwell" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Motar Pani" | R_Cen_a12_prim_source_oth=="Borwell water" | R_Cen_a12_prim_source_oth=="Borwell" | R_Cen_a12_prim_source_oth=="Electrical motar nija Ghare achi" | R_Cen_a12_prim_source_oth=="Motor borewell" | R_Cen_a12_prim_source_oth=="Other Person borewell water" | R_Cen_a12_prim_source_oth=="Othe person Personal Borewell" | R_Cen_a12_prim_source_oth=="Burwell" | R_Cen_a12_prim_source_oth=="Burwell" | R_Cen_a12_prim_source_oth=="Own Burwell" | R_Cen_a12_prim_source_oth=="Other person Borwell cello" | R_Cen_a12_prim_source_oth=="Nijara Borwell achi" | R_Cen_a12_prim_source_oth=="Other Person Boring cello" | R_Cen_a12_prim_source_oth=="Other person boring cello" | R_Cen_a12_prim_source_oth=="Other person boring cello" | R_Cen_a12_prim_source_oth=="Other person boring cello"

/*Not categorised yet:
Public tube well //public source other than tap/borewell/community standpipe
Gunupurru supply battal water piuchanti //bottled water supplied from gunupur
Padosi se Kharid ke pitehne //buy it from a neighbor 
Padosi ghar se kharid ke latehne //buy it from a neighbor 
*/


*** R_E_sec_source_reason_oth: "In what other circumstances do you collect drinking water from these other/secondary water sources?" (Options include 7 options, other and dont know)
*Recategorisng into existing options
//Option 1: Primary source is not working eg. pump is broken
replace R_E_sec_source_reason_1=1 if R_E_sec_source_reason_oth=="Current nathile" | R_E_sec_source_reason_oth=="Current nehi tha ishliye pani nehi ayatha" | R_E_sec_source_reason_oth=="Current nhi tha" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Power cut" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Current no thila" | R_E_sec_source_reason_oth=="Motor problem" | R_E_sec_source_reason_oth=="Current nothila" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Motor issue" | R_E_sec_source_reason_oth=="Motor problem" | R_E_sec_source_reason_oth=="Light na thile" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Current nathila" | R_E_sec_source_reason_oth=="Current nehi he to hum mannual handpump se pani pitehe" | R_E_sec_source_reason_oth=="Current nehi he to hum mannual handpump se pani pitehe" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problems" | R_E_sec_source_reason_oth=="Electricity" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Due to Current issue not supply water" | R_E_sec_source_reason_oth=="Current nhi tha isliye pani nhi aya" | R_E_sec_source_reason_oth=="Power cut" | R_E_sec_source_reason_oth=="Due to current issue not supply water" 

//Option 4: Primary water source is muddy or smelly
replace R_E_sec_source_reason_4=1 if R_E_sec_source_reason_oth=="Adhika khara re hau Rina garam thhae sedina nala kupa pani piu" | R_E_sec_source_reason_oth=="Smell and taste issues" | R_E_sec_source_reason_oth=="Smell" 

*Creating a new category
*Replacing other category with zero after categorisng 
replace R_E_sec_source_reason__77=0 if R_E_sec_source_reason_oth=="Adhika khara re hau Rina garam thhae sedina nala kupa pani piu" | R_E_sec_source_reason_oth=="Smell and taste issues" | R_E_sec_source_reason_oth=="Smell" | R_E_sec_source_reason_oth=="Current nathile" | R_E_sec_source_reason_oth=="Current nehi tha ishliye pani nehi ayatha" | R_E_sec_source_reason_oth=="Current nhi tha" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Power cut" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Current no thila" | R_E_sec_source_reason_oth=="Motor problem" | R_E_sec_source_reason_oth=="Current nothila" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Motor issue" | R_E_sec_source_reason_oth=="Motor problem" | R_E_sec_source_reason_oth=="Light na thile" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electrical problems" | R_E_sec_source_reason_oth=="Current nathila" | R_E_sec_source_reason_oth=="Current nehi he to hum mannual handpump se pani pitehe" | R_E_sec_source_reason_oth=="Current nehi he to hum mannual handpump se pani pitehe" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Current problems" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Electric problem" | R_E_sec_source_reason_oth=="Electricity problem" | R_E_sec_source_reason_oth=="Electric problems" | R_E_sec_source_reason_oth=="Electricity" | R_E_sec_source_reason_oth=="Current issue" | R_E_sec_source_reason_oth=="Due to Current issue not supply water" | R_E_sec_source_reason_oth=="Current nhi tha isliye pani nhi aya" | R_E_sec_source_reason_oth=="Power cut" | R_E_sec_source_reason_oth=="Due to current issue not supply water" 

/*Not categorised yet: 
Aaniba pain kehi na thibajagu
Ucha re ghara thibaru bele bele Pani na aasile //can be categorised into Option 2: Primary source does not give adequate water
Morning re time houni kamare jauchu to tap ru pani dhari nahi
Ghare no thile to tap pani dhori na thile sethi pae kuon ru piethile
Secondary sources ke Pani kabhi kabhar smell hota ha is liye wo jyada primary source se late hain 
Pani chhodne time ghar pe nehi the
Solar battery charging problems
Barsa heithila ,solar pani aasu nathila
*/
 
 
*** R_Cen_a13_water_sec_oth: "In the past month, what other water sources have you used for drinking?" (Options include 8 options and other)
*Recategorising into existing options
//Option 3: Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank) 
replace R_Cen_a13_water_source_sec_3=1 if R_Cen_a13_water_sec_oth=="Solar tank" | R_Cen_a13_water_sec_oth=="Solar Tank"

*Creating a new category for those using a Borewell operated by electric pump 
gen R_Cen_a13_water_source_sec_9=.
replace R_Cen_a13_water_source_sec_9=0 if R_Cen_a13_water_source_sec!=""
replace R_Cen_a13_water_source_sec_9=1 if R_Cen_a13_water_sec_oth=="Borwell se pani pitehne" | R_Cen_a13_water_sec_oth=="Anya jananka Burwell ru pani kiniki anithile" | R_Cen_a13_water_sec_oth=="Own motor pump" | R_Cen_a13_water_sec_oth=="Mill ra Borwell pani" | R_Cen_a13_water_sec_oth=="Borewell" | R_Cen_a13_water_sec_oth=="Neighborhood borewell water" | R_Cen_a13_water_sec_oth=="Borewell of neighbours" | R_Cen_a13_water_sec_oth=="Nijara boor pani" | R_Cen_a13_water_sec_oth=="Other Person personal borewell" | R_Cen_a13_water_sec_oth=="Own Borwell" | R_Cen_a13_water_sec_oth=="Own pump water" | R_Cen_a13_water_sec_oth=="Pesonal borewell" | R_Cen_a13_water_sec_oth=="Personal pump water of another house" | R_Cen_a13_water_sec_oth=="Personal pump water of another house" | R_Cen_a13_water_sec_oth=="Barwal" | R_Cen_a13_water_sec_oth=="Borwell" | R_Cen_a13_water_sec_oth=="Nija Borwell pani piuchanti"

*Replacing other category responses with zero after categorizing them
replace R_Cen_a13_water_source_sec__77=0 if R_Cen_a13_water_sec_oth=="Solar tank" | R_Cen_a13_water_sec_oth=="Solar Tank" | R_Cen_a13_water_sec_oth=="Borwell se pani pitehne" | R_Cen_a13_water_sec_oth=="Anya jananka Burwell ru pani kiniki anithile" | R_Cen_a13_water_sec_oth=="Own motor pump" | R_Cen_a13_water_sec_oth=="Mill ra Borwell pani" | R_Cen_a13_water_sec_oth=="Borewell" | R_Cen_a13_water_sec_oth=="Neighborhood borewell water" | R_Cen_a13_water_sec_oth=="Borewell of neighbours" | R_Cen_a13_water_sec_oth=="Nijara boor pani" | R_Cen_a13_water_sec_oth=="Other Person personal borewell" | R_Cen_a13_water_sec_oth=="Own Borwell" | R_Cen_a13_water_sec_oth=="Own pump water" | R_Cen_a13_water_sec_oth=="Pesonal borewell" | R_Cen_a13_water_sec_oth=="Personal pump water of another house" | R_Cen_a13_water_sec_oth=="Personal pump water of another house" | R_Cen_a13_water_sec_oth=="Barwal" | R_Cen_a13_water_sec_oth=="Borwell" | R_Cen_a13_water_sec_oth=="Nija Borwell pani piuchanti"

/*Not categorised yet:
//Not sure: 
Govt tube well //can be categorised into Borewell operated by electric pump?
Podasi ghara Pani ani pithile //fetches water from neighbor's house: not sure if neighbor collects water from JJm or has own borewell

//Translations required:
Samparkyia ghararu 
Padisa gharu magiki anithile 
Bali,mati,poka baharuchi
*/


*** R_Cen_sec_source_reason_oth: "In what other circumstances do you collect drinking water from these other water sources?" (Original options include 7 options, other and dont know)
*Recategorising into existing options
//Option 1: Primary source is not working eg. pump is broken
replace R_Cen_a14_sec_source_reason_1=1 if R_Cen_sec_source_reason_oth=="Karent gale" | R_Cen_sec_source_reason_oth=="Current ra asubidhathile" | R_Cen_sec_source_reason_oth=="Jai Dina light na thiba" | R_Cen_sec_source_reason_oth=="Current nathilaru" | R_Cen_sec_source_reason_oth=="Pani nehi aa raha thaa" | R_Cen_sec_source_reason_oth=="Pipe joined khuli jaaethila" | R_Cen_sec_source_reason_oth=="Tanki kharap thila" | R_Cen_sec_source_reason_oth=="Pipe phati jaithila" | R_Cen_sec_source_reason_oth=="Light na thile jaudina pani aasibani" | R_Cen_sec_source_reason_oth=="Current nathile government tap pani pianti" | R_Cen_sec_source_reason_oth=="Current nothile, power cut hele" | R_Cen_sec_source_reason_oth=="Motor problem" | R_Cen_sec_source_reason_oth=="Jadi light na thiba" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Right na thibaru" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Electric na thila" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Electry problem" | R_Cen_sec_source_reason_oth=="Corent nathibaru" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Current nathile" | R_Cen_sec_source_reason_oth=="Tank kharap thila" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Manual Hand pump kharap hele" | R_Cen_sec_source_reason_oth=="Electri nathila" | R_Cen_sec_source_reason_oth=="Current na asile" | R_Cen_sec_source_reason_oth=="Current nathila" | R_Cen_sec_source_reason_oth=="Current nathie" | R_Cen_sec_source_reason_oth=="Current jis din nehi rehai ta tha usi din solar se pani late thai" | R_Cen_sec_source_reason_oth=="Current nehi tha iss liye solar tank se pani liye thai" | R_Cen_sec_source_reason_oth=="Current nehi haa iss liye solar tank se pani ka kar pe ta hoon" | R_Cen_sec_source_reason_oth=="Current problem hai" | R_Cen_sec_source_reason_oth=="Current Problem" | R_Cen_sec_source_reason_oth=="Current problem" | R_Cen_sec_source_reason_oth=="Current nathile" | R_Cen_sec_source_reason_oth=="Current nathula aanithile" | R_Cen_sec_source_reason_oth=="Jadi light nathiba" 

*Replacing the other category with zero after categorising responses 
replace R_Cen_a14_sec_source_reason__77=0 if R_Cen_sec_source_reason_oth=="Karent gale" | R_Cen_sec_source_reason_oth=="Current ra asubidhathile" | R_Cen_sec_source_reason_oth=="Jai Dina light na thiba" | R_Cen_sec_source_reason_oth=="Current nathilaru" | R_Cen_sec_source_reason_oth=="Pani nehi aa raha thaa" | R_Cen_sec_source_reason_oth=="Pipe joined khuli jaaethila" | R_Cen_sec_source_reason_oth=="Tanki kharap thila" | R_Cen_sec_source_reason_oth=="Pipe phati jaithila" | R_Cen_sec_source_reason_oth=="Light na thile jaudina pani aasibani" | R_Cen_sec_source_reason_oth=="Current nathile government tap pani pianti" | R_Cen_sec_source_reason_oth=="Current nothile, power cut hele" | R_Cen_sec_source_reason_oth=="Motor problem" | R_Cen_sec_source_reason_oth=="Jadi light na thiba" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Right na thibaru" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Electric na thila" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Electry problem" | R_Cen_sec_source_reason_oth=="Corent nathibaru" | R_Cen_sec_source_reason_oth=="Light na thile" | R_Cen_sec_source_reason_oth=="Current nathile" | R_Cen_sec_source_reason_oth=="Tank kharap thila" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Current no thile" | R_Cen_sec_source_reason_oth=="Manual Hand pump kharap hele" | R_Cen_sec_source_reason_oth=="Electri nathila" | R_Cen_sec_source_reason_oth=="Current na asile" | R_Cen_sec_source_reason_oth=="Current nathila" | R_Cen_sec_source_reason_oth=="Current nathie" | R_Cen_sec_source_reason_oth=="Current jis din nehi rehai ta tha usi din solar se pani late thai" | R_Cen_sec_source_reason_oth=="Current nehi tha iss liye solar tank se pani liye thai" | R_Cen_sec_source_reason_oth=="Current nehi haa iss liye solar tank se pani ka kar pe ta hoon" | R_Cen_sec_source_reason_oth=="Current problem hai" | R_Cen_sec_source_reason_oth=="Current Problem" | R_Cen_sec_source_reason_oth=="Current problem" | R_Cen_sec_source_reason_oth=="Current nathile" | R_Cen_sec_source_reason_oth=="Current nathula aanithile" | R_Cen_sec_source_reason_oth=="Jadi light nathiba"

/*Not categorised yet: 
//Not sure: 
Bliching pakeithile boli hand pump ru pani aanithilu //drink water from handpump due to chlroine smell (to be categorised into Option 4: Primary water source is muddy or smelly?)
Tanki pani aasunahi bhalase //Water is intermittent or primary source not working 
Test vala nahni //taste issues? 
Tank wash time

//translations required:
Pani asiba time re Ghare no thile Sethi pae podasi ghara Pani piele fhtc ru
Bele bele chhotia chhotia luha Kanika baharile ame sarakari tap pani piu.
Ehi family morning 6am re tanakra firm house ku jahanti au Sethi tankara bore water used karanti sethi tankara rosei hue puni night 9 pm re ghara soiba pai jahanti
Jetebele pani na ase
Echa hoi thibaru
Bali mati poka baharuchi
*/


*** R_Cen_a16_treat_freq_oth:
*Recategorising into existing category/reason
//Option 1: Always treat the water
replace R_Cen_a16_water_treat_freq_1=1 if R_Cen_a16_treat_freq_oth=="Garam sabubele karanti" 

*Replacing other category with zero after recategorising 
replace R_Cen_a16_water_treat_freq__77=0 if R_Cen_a16_treat_freq_oth=="Garam sabubele karanti" 

/*Not translated yet: 
"No" // resoondennt doesnt the freq of water treatment or the type of treatment 
"Casual y" //no fixed schedule?
"Kebebi biswadhana karu nahanti" //translation required
*/


*** R_Cen_treat_kids_freq_oth: Follow up question to "For your youngest children, when do you make the water safe before they drink it?" (Original options include 6 options and other)
*Recategorising into existing options: 
//Option : Treat the water when kids/ old people fall sick
replace R_Cen_a17_treat_kids_freq_5=1 if R_Cen_treat_kids_freq_oth=="Jarahele pani garama kari deuchanti"

*Replacing other category with zero after categorising 
replace R_Cen_a17_treat_kids_freq__77=1 if R_Cen_treat_kids_freq_oth=="Jarahele pani garama kari deuchanti"

/*Not categorised yet:
Ketebelebi kichi karunahanti //occasional treatment 
*/


*** R_Cen_water_prim_kids_oth:
/*Not categorised as the kids are too young and dont drink water:
//Can create a new category for R_Cen_water_source_kids to include option "Too young to drink water" with existing yes/no/dont know options
R_Cen_water_prim_kids_oth
3 masara choto sisu achanti tanku panidiaheinai Aou Anya choto sisu nahanti sethipai piunahanti
Child only drink mother milk
Bartaman choto sisunku panideunahanti
Chhua ku pani dia heuni
Child doesn't drink water
Mor Abe gute jhia haechhi sia pani peni
No
New baby 3 masa chaluchi sethipai pani pia hauni
Chota chua pani piini
Chota pila pani piini
Child age under one mont he can not drink water
Pani dia hoini ebe jai
1 month ra chua Pani piunahi
4 month ra chuaa Pani piunahi
5 month ra baby Pani pibaku dounahanti
Chhua ku e jai pani dia hoini
4 month ra baby ku Pani diahouni
1 month ra baby Pani pibaku dounahanti
Chhoto chhua ku ebe jai dia hoini
Chhua ku pani ebe jai dia hoini
Chhua ku pani   jai dia hoini
ChildDidn't drink water
Choto sisu ku pani diaheinai ki aou anyapila nahanti
Choto sisu ku pani diaheinai
2 month ka chota bachahe unko paninehi diahe bo panipina start nehi kiahe
Chota bacha pani nehni pita
Chota pila pani piani
Now not water drink
*/


*** R_Cen_a15_water_sec_freq_oth: No observations  

*** R_Cen_stored_treat_freq_oth: No observations  

********************************************************************************
*** Categorizing the text responses (other category responses): ENDLINE
********************************************************************************

*** R_E_water_treat_oth: "What else do you do to the water from the primary source (${primary_water_label}) to make it safe for drinking? (follow up question for those who select "Other" in R_E_water_treat_type. Orginal responses include 4 main categories + other + don't know)

*Creating new category for those using Aqua filter (for consistency with FU rounds)
gen R_E_water_treat_type_7=.
replace R_E_water_treat_type_7=0 if R_E_water_treat_type!=""
label var R_E_water_treat_type_7 "Aqua filter"
label define R_E_water_treat_type_7 1 "Yes" 0 "No"
label values R_E_water_treat_type_7 R_E_water_treat_type_7 

*Creating new category for those Purchasing bottled water (for consistency with FU rounds)
gen R_E_water_treat_type_8=.
replace R_E_water_treat_type_8=0 if R_E_water_treat_type!=""
label var R_E_water_treat_type_8 "Purchase filtered bottle"
label define R_E_water_treat_type_8 1 "Yes" 0 "No"
label values R_E_water_treat_type_8 R_E_water_treat_type_8 

*Creating a new category for those who clean their containers
gen R_E_water_treat_type_5=. 
replace R_E_water_treat_type_5=0 if R_E_water_treat_type!=""
replace R_E_water_treat_type_5=1 if R_E_water_treat_oth == "Balti dho kar rakte he." | R_E_water_treat_oth == "Bartan Saf" | R_E_water_treat_oth == "Bartan saf" | R_E_water_treat_oth == "Bartan saph" | R_E_water_treat_oth == "Basana sapha" | R_E_water_treat_oth == "Botol saf" | R_E_water_treat_oth == "Botoll saf" | R_E_water_treat_oth == "Bottal clean" | R_E_water_treat_oth == "Bottal safa karte hai" | R_E_water_treat_oth == "Bottal, Handi safa karte hai" | R_E_water_treat_oth == "Bottle saf karte hai" | R_E_water_treat_oth == "Bottle saf karte hain" | R_E_water_treat_oth == "Clean  tha container" | R_E_water_treat_oth == "Clean  untensil" | R_E_water_treat_oth == "Clean containers" | R_E_water_treat_oth == "Clean tha container" | R_E_water_treat_oth == "Wash the container" | R_E_water_treat_oth == "Wash container" | R_E_water_treat_oth == "Patra saf karte hen" | R_E_water_treat_oth == "Patra saf karke rakhate hen" | R_E_water_treat_oth == "Clean the container" | R_E_water_treat_oth == "Patra Saf karke rakhate hen" | R_E_water_treat_oth == "Handi, bottal safa karte hai" | R_E_water_treat_oth == "Handi safkarte he." | R_E_water_treat_oth == "Handi safkarke rakte he." | R_E_water_treat_oth == "Handi safa karte hai" | R_E_water_treat_oth == "Handi saf karte hein" | R_E_water_treat_oth == "Clean untensil" | R_E_water_treat_oth == "Cleaning Utensils" | R_E_water_treat_oth == "Cleaning utensils" | R_E_water_treat_oth == "Cleansing the container" | R_E_water_treat_oth == "Clin contenor" | R_E_water_treat_oth == "Clin the contenor" | R_E_water_treat_oth == "Dabba dhote hai" | R_E_water_treat_oth == "Handi saf karte hei" | R_E_water_treat_oth == "Handi saf karte hain" | R_E_water_treat_oth == "Handi saf karte hain" | R_E_water_treat_oth == "Handi saf karte hai" | R_E_water_treat_oth == "Handi ku dhoiki rakhuchanti" | R_E_water_treat_oth == "Handi ko saf karte hei" | R_E_water_treat_oth == "Handi ko dhak ke rakhte hein" | R_E_water_treat_oth == "Handi ko dhak ke rakhte hei" | R_E_water_treat_oth == "Handi ko dhak kar rakhte hein" | R_E_water_treat_oth == "Handi dhote he." | R_E_water_treat_oth == "Handi dhokar rakte te." | R_E_water_treat_oth == "Handi dhokar pani rakta he." | R_E_water_treat_oth == "Handi clean karke rakh rhe hai" | R_E_water_treat_oth == "Handi Dhote he." | R_E_water_treat_oth == "Dhokar kar dhaka rakte he." | R_E_water_treat_oth == "Dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhakrak rakte he." | R_E_water_treat_oth == "Dhakkar rakte he." | R_E_water_treat_oth == "Dhakkar rakte he" | R_E_water_treat_oth == "Cleansing the vessel's before drinking" | R_E_water_treat_oth == "Cleansing the vessel's before collecting water" | R_E_water_treat_oth == "Cleansing the container before collecting water" | R_E_water_treat_oth == "Wash water container before storage water." | R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hei" | R_E_water_treat_oth == "Wash container before storage water." | R_E_water_treat_oth == "Wash water container before storage water" | R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hai" | R_E_water_treat_oth == "Bottal ,Handi safa,or cover karte hai," | R_E_water_treat_oth == "Clean containers and cover the contai.." | R_E_water_treat_oth == "Clean tha containe, cover the container" | R_E_water_treat_oth == "Clean tha container cover the container" | R_E_water_treat_oth == "Wash container,pani ghorei rakhanti" | R_E_water_treat_oth == "Safkarke cover karke rakhaten hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhete hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhate hen" | R_E_water_treat_oth == "Handi safa karte cover karte hai" | R_E_water_treat_oth == "Handi safa karte Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi safa cover karte hai" | R_E_water_treat_oth == "Handi safa ,cover karte hai" | R_E_water_treat_oth == "Cover  and clean the container," | R_E_water_treat_oth == "Cover and clean the container" | R_E_water_treat_oth == "Cover the container clean the container" | R_E_water_treat_oth == "Handi saf karte hai,dhak k rakhte hei" | R_E_water_treat_oth == "Handi dhote he or dhak ke rakte he." | R_E_water_treat_oth == "Handi dhote he or dhak kar rakte he." | R_E_water_treat_oth == "Handi dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_oth == "Dhak ke rakhte hai and wash container" | R_E_water_treat_oth == "Handi saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Paniku ghorei rakhanti, wash container" | R_E_water_treat_oth == "Clean containers and cover the container" | R_E_water_treat_oth == "Clean tha container, cover the container" | R_E_water_treat_oth == "Wash and cover water container before storage water." | R_E_water_treat_oth == "Cover the container, clean the container" | R_E_water_treat_oth == "Patra saf karke cover karke rakhaten hen" | R_E_water_treat_oth == "Handi safa karte hai Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi ko saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Cover the container, clean tha container" |  R_E_water_treat_oth == "Cleansing the vessel's before collecting water and cover the container" | R_E_water_treat_oth == "Wash container,pani ki ghoreiki rakhuchhanti" | R_E_water_treat_oth == "Patra saf karke cover karke rakheten hen"

*Creating a new category for those who cover their containers to keep the water safe 
gen R_E_water_treat_type_6=.
replace R_E_water_treat_type_6=0 if R_E_water_treat_type!=""
replace R_E_water_treat_type_6=1 if R_E_water_treat_oth == "Patra ko cover karke rakhaten hen" | R_E_water_treat_oth == "Patra cover karke rakhaten hen" | R_E_water_treat_oth == "Pani ko Dhankte hai" | R_E_water_treat_oth == "Pani dhankte hai" | R_E_water_treat_oth == "Pani Ko dhankte" | R_E_water_treat_oth == "Pani Ko dhak kar rekte he." | R_E_water_treat_oth == "Pani Ko cover karke  rakte hai" | R_E_water_treat_oth == "Cover karke rakhaten hen" | R_E_water_treat_oth == "Cover karke rakhaten hen Patra ko" |  R_E_water_treat_oth == "Cover the container" | R_E_water_treat_oth == "Covered the container" | R_E_water_treat_oth == "Covered the pot" | R_E_water_treat_oth == "Covered the water pot" | R_E_water_treat_oth == "Dhak kar rakte he" | R_E_water_treat_oth == "Dhak kar rakte he." | R_E_water_treat_oth == "Dhak kar raktehe." | R_E_water_treat_oth == "Dhak ke rakhte hai" | R_E_water_treat_oth == "Handi ko dhak k rakhte hei" | R_E_water_treat_oth == "Handi ko dhak k rakhte hai" | R_E_water_treat_oth == "Handi dhak k rakhte hei" |R_E_water_treat_oth == "Wo pani main kuch nehin jaye is liye odh ke rakhte hain" | R_E_water_treat_oth == "Cover the container , bleaching" | R_E_water_treat_oth == "Bottal ,Handi safa,or cover karte hai," | R_E_water_treat_oth == "Clean containers and cover the contai.." | R_E_water_treat_oth == "Clean tha containe, cover the container" | R_E_water_treat_oth == "Clean tha container cover the container" | R_E_water_treat_oth == "Wash container,pani ghorei rakhanti" | R_E_water_treat_oth == "Safkarke cover karke rakhaten hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhete hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhate hen" | R_E_water_treat_oth == "Handi safa karte cover karte hai" | R_E_water_treat_oth == "Handi safa karte Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi safa cover karte hai" | R_E_water_treat_oth == "Handi safa ,cover karte hai" | R_E_water_treat_oth == "Cover  and clean the container," | R_E_water_treat_oth == "Cover and clean the container" | R_E_water_treat_oth == "Cover the container clean the container" | R_E_water_treat_oth == "Handi saf karte hai,dhak k rakhte hei" | R_E_water_treat_oth == "Handi dhote he or dhak ke rakte he." | R_E_water_treat_oth == "Handi dhote he or dhak kar rakte he." | R_E_water_treat_oth == "Handi dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_oth == "Dhak ke rakhte hai and wash container" | R_E_water_treat_oth == "Handi saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Paniku ghorei rakhanti, wash container" | R_E_water_treat_oth == "Clean containers and cover the container" | R_E_water_treat_oth == "Clean tha container, cover the container" | R_E_water_treat_oth == "Wash and cover water container before storage water." | R_E_water_treat_oth == "Cover the container, clean the container" | R_E_water_treat_oth == "Patra saf karke cover karke rakhaten hen" | R_E_water_treat_oth == "Handi safa karte hai Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi ko saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Cover the container, clean tha container" |  R_E_water_treat_oth == "Cleansing the vessel's before collecting water and cover the container" | R_E_water_treat_oth == "Wash container,pani ki ghoreiki rakhuchhanti" | R_E_water_treat_oth == "Patra saf karke cover karke rakheten hen"
 
// *Creating a new category for those who clean and cover their containers to keep the water safe 
// gen R_E_water_treat_type_7=.
// replace R_E_water_treat_type_7=0 if R_E_water_treat_type!=""
// replace R_E_water_treat_type_7=1 if R_E_water_treat_oth == "Bottal ,Handi safa,or cover karte hai," | R_E_water_treat_oth == "Clean containers and cover the contai.." | R_E_water_treat_oth == "Clean tha containe, cover the container" | R_E_water_treat_oth == "Clean tha container cover the container" | R_E_water_treat_oth == "Wash container,pani ghorei rakhanti" | R_E_water_treat_oth == "Safkarke cover karke rakhaten hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhete hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhate hen" | R_E_water_treat_oth == "Handi safa karte cover karte hai" | R_E_water_treat_oth == "Handi safa karte Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi safa cover karte hai" | R_E_water_treat_oth == "Handi safa ,cover karte hai" | R_E_water_treat_oth == "Cover  and clean the container," | R_E_water_treat_oth == "Cover and clean the container" | R_E_water_treat_oth == "Cover the container clean the container" | R_E_water_treat_oth == "Handi saf karte hai,dhak k rakhte hei" | R_E_water_treat_oth == "Handi dhote he or dhak ke rakte he." | R_E_water_treat_oth == "Handi dhote he or dhak kar rakte he." | R_E_water_treat_oth == "Handi dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_oth == "Dhak ke rakhte hai and wash container" | R_E_water_treat_oth == "Handi saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Paniku ghorei rakhanti, wash container" | R_E_water_treat_oth == "Clean containers and cover the container" | R_E_water_treat_oth == "Clean tha container, cover the container" | R_E_water_treat_oth == "Wash and cover water container before storage water." | R_E_water_treat_oth == "Cover the container, clean the container" | R_E_water_treat_oth == "Patra saf karke cover karke rakhaten hen" | R_E_water_treat_oth == "Handi safa karte hai Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi ko saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Cover the container, clean tha container" |  R_E_water_treat_oth == "Cleansing the vessel's before collecting water and cover the container" | R_E_water_treat_oth == "Wash container,pani ki ghoreiki rakhuchhanti" | R_E_water_treat_oth == "Patra saf karke cover karke rakheten hen"


*Recategorising into existing categories 
//Add chlorine/ bleaching powder to the water
replace R_E_water_treat_type_4=1 if R_E_water_treat_oth == "Cover the container , bleaching"

*Replacing the other category with zero after categoring the text responses
replace R_E_water_treat_type__77=0 if R_E_water_treat_oth == "Bottal ,Handi safa,or cover karte hai," | R_E_water_treat_oth == "Clean containers and cover the contai.." | R_E_water_treat_oth == "Clean tha containe, cover the container" | R_E_water_treat_oth == "Clean tha container cover the container" | R_E_water_treat_oth == "Wash container,pani ghorei rakhanti" | R_E_water_treat_oth == "Safkarke cover karke rakhaten hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhete hen" | R_E_water_treat_oth == "Patra saf karke cover karke rakhate hen" | R_E_water_treat_oth == "Handi safa karte cover karte hai" | R_E_water_treat_oth == "Handi safa karte Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi safa cover karte hai" | R_E_water_treat_oth == "Handi safa ,cover karte hai" | R_E_water_treat_oth == "Cover  and clean the container," | R_E_water_treat_oth == "Cover and clean the container" | R_E_water_treat_oth == "Cover the container clean the container" | R_E_water_treat_oth == "Handi saf karte hai,dhak k rakhte hei" | R_E_water_treat_oth == "Handi dhote he or dhak ke rakte he." | R_E_water_treat_oth == "Handi dhote he or dhak kar rakte he." | R_E_water_treat_oth == "Handi dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_oth == "Dhak ke rakhte hai and wash container" | R_E_water_treat_oth == "Handi saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Paniku ghorei rakhanti, wash container" | R_E_water_treat_oth == "Clean containers and cover the container" | R_E_water_treat_oth == "Clean tha container, cover the container" | R_E_water_treat_oth == "Wash and cover water container before storage water." | R_E_water_treat_oth == "Cover the container, clean the container" | R_E_water_treat_oth == "Patra saf karke cover karke rakhaten hen" | R_E_water_treat_oth == "Handi safa karte hai Pani Ko dhankte hai" | R_E_water_treat_oth == "Handi ko saf karte hei,dhak k rakhte hei" | R_E_water_treat_oth == "Cover the container, clean tha container" |  R_E_water_treat_oth == "Cleansing the vessel's before collecting water and cover the container" | R_E_water_treat_oth == "Wash container,pani ki ghoreiki rakhuchhanti" | R_E_water_treat_oth == "Patra saf karke cover karke rakheten hen"| R_E_water_treat_oth == "Cover the container , bleaching" | R_E_water_treat_oth == "Patra ko cover karke rakhaten hen" | R_E_water_treat_oth == "Patra cover karke rakhaten hen" | R_E_water_treat_oth == "Pani ko Dhankte hai" | R_E_water_treat_oth == "Pani dhankte hai" | R_E_water_treat_oth == "Pani Ko dhankte" | R_E_water_treat_oth == "Pani Ko dhak kar rekte he." | R_E_water_treat_oth == "Pani Ko cover karke  rakte hai" | R_E_water_treat_oth == "Cover karke rakhaten hen" | R_E_water_treat_oth == "Cover karke rakhaten hen Patra ko" |  R_E_water_treat_oth == "Cover the container" | R_E_water_treat_oth == "Covered the container" | R_E_water_treat_oth == "Covered the pot" | R_E_water_treat_oth == "Covered the water pot" | R_E_water_treat_oth == "Dhak kar rakte he" | R_E_water_treat_oth == "Dhak kar rakte he." | R_E_water_treat_oth == "Dhak kar raktehe." | R_E_water_treat_oth == "Dhak ke rakhte hai" | R_E_water_treat_oth == "Handi ko dhak k rakhte hei" | R_E_water_treat_oth == "Handi ko dhak k rakhte hai" | R_E_water_treat_oth == "Handi dhak k rakhte hei" |R_E_water_treat_oth == "Wo pani main kuch nehin jaye is liye odh ke rakhte hain" | R_E_water_treat_oth == "Balti dho kar rakte he." | R_E_water_treat_oth == "Bartan Saf" | R_E_water_treat_oth == "Bartan saf" | R_E_water_treat_oth == "Bartan saph" | R_E_water_treat_oth == "Basana sapha" | R_E_water_treat_oth == "Botol saf" | R_E_water_treat_oth == "Botoll saf" | R_E_water_treat_oth == "Bottal clean" | R_E_water_treat_oth == "Bottal safa karte hai" | R_E_water_treat_oth == "Bottal, Handi safa karte hai" | R_E_water_treat_oth == "Bottle saf karte hai" | R_E_water_treat_oth == "Bottle saf karte hain" | R_E_water_treat_oth == "Clean  tha container" | R_E_water_treat_oth == "Clean  untensil" | R_E_water_treat_oth == "Clean containers" | R_E_water_treat_oth == "Clean tha container" | R_E_water_treat_oth == "Wash the container" | R_E_water_treat_oth == "Wash container" | R_E_water_treat_oth == "Patra saf karte hen" | R_E_water_treat_oth == "Patra saf karke rakhate hen" | R_E_water_treat_oth == "Clean the container" | R_E_water_treat_oth == "Patra Saf karke rakhate hen" | R_E_water_treat_oth == "Handi, bottal safa karte hai" | R_E_water_treat_oth == "Handi safkarte he." | R_E_water_treat_oth == "Handi safkarke rakte he." | R_E_water_treat_oth == "Handi safa karte hai" | R_E_water_treat_oth == "Handi saf karte hein" | R_E_water_treat_oth == "Clean untensil" | R_E_water_treat_oth == "Cleaning Utensils" | R_E_water_treat_oth == "Cleaning utensils" | R_E_water_treat_oth == "Cleansing the container" | R_E_water_treat_oth == "Clin contenor" | R_E_water_treat_oth == "Clin the contenor" | R_E_water_treat_oth == "Dabba dhote hai" | R_E_water_treat_oth == "Handi saf karte hei" | R_E_water_treat_oth == "Handi saf karte hain" | R_E_water_treat_oth == "Handi saf karte hain" | R_E_water_treat_oth == "Handi saf karte hai" | R_E_water_treat_oth == "Handi ku dhoiki rakhuchanti" | R_E_water_treat_oth == "Handi ko saf karte hei" | R_E_water_treat_oth == "Handi ko dhak ke rakhte hein" | R_E_water_treat_oth == "Handi ko dhak ke rakhte hei" | R_E_water_treat_oth == "Handi ko dhak kar rakhte hein" | R_E_water_treat_oth == "Handi dhote he." | R_E_water_treat_oth == "Handi dhokar rakte te." | R_E_water_treat_oth == "Handi dhokar pani rakta he." | R_E_water_treat_oth == "Handi clean karke rakh rhe hai" | R_E_water_treat_oth == "Handi Dhote he." | R_E_water_treat_oth == "Dhokar kar dhaka rakte he." | R_E_water_treat_oth == "Dhokar dhak kar rakte he." | R_E_water_treat_oth == "Dhakrak rakte he." | R_E_water_treat_oth == "Dhakkar rakte he." | R_E_water_treat_oth == "Dhakkar rakte he" | R_E_water_treat_oth == "Cleansing the vessel's before drinking" | R_E_water_treat_oth == "Cleansing the vessel's before collecting water" | R_E_water_treat_oth == "Cleansing the container before collecting water" | R_E_water_treat_oth == "Wash water container before storage water." | R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hei" | R_E_water_treat_oth == "Wash container before storage water." | R_E_water_treat_oth == "Wash water container before storage water" | R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hai"

/* Can't say if the HH has a pvt tank and cleans it regulary or is referring to the village tank 
// //tank cleaning is not an applicable treatment method
// replace R_E_water_treat_type = "3" if R_E_water_treat_oth == "Tank cleaning" & R_E_water_treat_type == "3 -77"
//
// //tank cleaning is not an applicable treatment method
// replace R_E_water_treat_type = "4" if R_E_water_treat_oth == "Tanki wash" & R_E_water_treat_type == "4 -77"
//
// //replacing the variable on whether hh treats running water in some way with zero if hh mentioned cleaning the tank 
// replace R_E_water_treat=0 if R_E_water_treat_oth == "Tanki wash" | R_E_water_treat_oth == "Tank cleaning" 
*/


*** R_E_water_treat_kids_oth: What else do you do to the water for your youngest children (children under 5) to make it safe for drinking? (followup question for those selecting "Other" in R_E_water_treat_kids_type. Original options include 4 main categories, other and dont know)
*Creating a new category for those who clean their containers
gen R_E_water_treat_kids_type_5=. 
replace R_E_water_treat_kids_type_5=0 if R_E_water_treat_kids_type!=""
replace R_E_water_treat_kids_type_5=1 if R_E_water_treat_kids_oth == "Balti,handi safa karte hai" | R_E_water_treat_kids_oth == "Wash container" | R_E_water_treat_kids_oth == "Bartan safa karte hai" |  R_E_water_treat_kids_oth == "Bottal pe bharte he" | R_E_water_treat_kids_oth == "Bottal saf karte he." | R_E_water_treat_kids_oth == "Bottal safa karte hai" | R_E_water_treat_kids_oth == "Bottal,glass saf karke pani dete hai" | R_E_water_treat_kids_oth == "Bottle dho kar dete he." | R_E_water_treat_kids_oth == "Bottle dhokar dete he" | R_E_water_treat_kids_oth == "Bottle dhokar rakte he." | R_E_water_treat_kids_oth == "Bottle dhote he pani bhar ke dete he." | R_E_water_treat_kids_oth == "Bottle saf kar ke dete he." | R_E_water_treat_kids_oth == "Bottle saf karke dete he." | R_E_water_treat_kids_oth == "Bottle saf karte hai" | R_E_water_treat_kids_oth == "Bottle saf karte hain" | R_E_water_treat_kids_oth == "Bottle saf karte hei" | R_E_water_treat_kids_oth == "Bottol dhote he." | R_E_water_treat_kids_oth == "Bottol pe saf karke pani rakte he." | R_E_water_treat_kids_oth == "Bottotle saf kar ke dete he." | R_E_water_treat_kids_oth == "Clean tha container" | R_E_water_treat_kids_oth == "Clean the container" | R_E_water_treat_kids_oth == "Clean untensil" | R_E_water_treat_kids_oth == "Cleaning Utensils" | R_E_water_treat_kids_oth == "Cleansing her water bottle" | R_E_water_treat_kids_oth == "Cleansing the water bottle" | R_E_water_treat_kids_oth == "Clin contenor" | R_E_water_treat_kids_oth == "Glash saf kartehe." | R_E_water_treat_kids_oth == "Glass clean"  | R_E_water_treat_kids_oth == "Glass dhote he." | R_E_water_treat_kids_oth == "Glass dhote he." | R_E_water_treat_kids_oth == "Glass saf arke pani dete hai" | R_E_water_treat_kids_oth == "Glass saf karke dete he." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai" | R_E_water_treat_kids_oth == "Glass saf karte hei" | R_E_water_treat_kids_oth == "Glass, bottle saf karte hai" | R_E_water_treat_kids_oth == "Handi dhokar rakte he." | R_E_water_treat_kids_oth == "Handi dhote he" | R_E_water_treat_kids_oth == "Handi dhote he." | R_E_water_treat_kids_oth == "Handi saf kar ke rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei" | R_E_water_treat_kids_oth == "Handi safa" | R_E_water_treat_kids_oth == "Handi safa karte hai" | R_E_water_treat_kids_oth == "Patra saf karke rakhate hen" | R_E_water_treat_kids_oth == "Patra saf karte hen" | R_E_water_treat_kids_oth == "Wash the container" | R_E_water_treat_kids_oth == "Wash water bottle before storage water." | R_E_water_treat_kids_oth == "Wash water container before storage." | R_E_water_treat_kids_oth == "Wash water container before storage water." | R_E_water_treat_kids_oth == "Wash water container before storage water" | R_E_water_treat_kids_oth == "Wash water container before storage water" | R_E_water_treat_kids_oth == "Handi saf karte hei , bottle saf karte hai" | R_E_water_treat_kids_oth == "Cleansing the vessel's before collecting water" | R_E_water_treat_kids_oth == "Bottle saf karte hain, glass saf karte hai" | R_E_water_treat_kids_oth == "Handi saf karte hain"  | R_E_water_treat_kids_oth == "Clean tha container,cover the container" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_kids_oth == "Handi ko dho kar dhak kar rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei, dhan k rakhte hei" | R_E_water_treat_kids_oth == "Handi safa cover karte hai" | R_E_water_treat_kids_oth == "Pani ghorauchhanti,wash container" | R_E_water_treat_kids_oth == "Wash container and Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Wash and cover water container before storage water." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai pani ko dhankte" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container before storage water."

*Creating a new category for those who cover their containers to keep the water safe 
gen R_E_water_treat_kids_type_6=. 
replace R_E_water_treat_kids_type_6=0 if R_E_water_treat_kids_type!=""
replace R_E_water_treat_kids_type_6=1 if R_E_water_treat_kids_oth == "Cover karke rakhete hen" | R_E_water_treat_kids_oth == "Cover the container" | R_E_water_treat_kids_oth == "Cover water odh ke rakhte hain pani ko" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Dhakkan laga ke rakhte hain" | R_E_water_treat_kids_oth == "Dhakkar rakte he." | R_E_water_treat_kids_oth == "Handi dhak k rakhte hei" | R_E_water_treat_kids_oth == "Pani ko Dhankte hai" | R_E_water_treat_kids_oth == "Clean tha container,cover the container" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_kids_oth == "Handi ko dho kar dhak kar rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei, dhan k rakhte hei" | R_E_water_treat_kids_oth == "Handi safa cover karte hai" | R_E_water_treat_kids_oth == "Pani ghorauchhanti,wash container" | R_E_water_treat_kids_oth == "Wash container and Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Wash and cover water container before storage water." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai pani ko dhankte" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container before storage water."

// *Creating a new category for those who clean and cover their containers to keep the water safe 
// gen R_E_water_treat_kids_type_7=. 
// replace R_E_water_treat_kids_type_7=0 if R_E_water_treat_kids_type!=""
// replace R_E_water_treat_kids_type_7=1 if R_E_water_treat_kids_oth == "Clean tha container,cover the container" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_kids_oth == "Handi ko dho kar dhak kar rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei, dhan k rakhte hei" | R_E_water_treat_kids_oth == "Handi safa cover karte hai" | R_E_water_treat_kids_oth == "Pani ghorauchhanti,wash container" | R_E_water_treat_kids_oth == "Wash container and Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Wash and cover water container before storage water." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai pani ko dhankte" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container before storage water."

*Recategorising into existing categories 

*Replacing the other category with zero after categoring the text responses
replace R_E_water_treat_kids_type__77=0 if R_E_water_treat_kids_oth == "Clean tha container,cover the container" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai, wash container" | R_E_water_treat_kids_oth == "Handi ko dho kar dhak kar rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei, dhan k rakhte hei" | R_E_water_treat_kids_oth == "Handi safa cover karte hai" | R_E_water_treat_kids_oth == "Pani ghorauchhanti,wash container" | R_E_water_treat_kids_oth == "Wash container and Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Wash and cover water container before storage water." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai pani ko dhankte" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Cover the container, clean tha container" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai" | R_E_water_treat_kids_oth == "Wash container before storage water." | R_E_water_treat_kids_oth == "Cover karke rakhete hen" | R_E_water_treat_kids_oth == "Cover the container" | R_E_water_treat_kids_oth == "Cover water odh ke rakhte hain pani ko" | R_E_water_treat_kids_oth == "Dhak ke rakhte hai" | R_E_water_treat_kids_oth == "Dhakkan laga ke rakhte hain" | R_E_water_treat_kids_oth == "Dhakkar rakte he." | R_E_water_treat_kids_oth == "Handi dhak k rakhte hei" | R_E_water_treat_kids_oth == "Pani ko Dhankte hai" | R_E_water_treat_kids_oth == "Balti,handi safa karte hai" | R_E_water_treat_kids_oth == "Wash container" | R_E_water_treat_kids_oth == "Bartan safa karte hai" |  R_E_water_treat_kids_oth == "Bottal pe bharte he" | R_E_water_treat_kids_oth == "Bottal saf karte he." | R_E_water_treat_kids_oth == "Bottal safa karte hai" | R_E_water_treat_kids_oth == "Bottal,glass saf karke pani dete hai" | R_E_water_treat_kids_oth == "Bottle dho kar dete he." | R_E_water_treat_kids_oth == "Bottle dhokar dete he" | R_E_water_treat_kids_oth == "Bottle dhokar rakte he." | R_E_water_treat_kids_oth == "Bottle dhote he pani bhar ke dete he." | R_E_water_treat_kids_oth == "Bottle saf kar ke dete he." | R_E_water_treat_kids_oth == "Bottle saf karke dete he." | R_E_water_treat_kids_oth == "Bottle saf karte hai" | R_E_water_treat_kids_oth == "Bottle saf karte hain" | R_E_water_treat_kids_oth == "Bottle saf karte hei" | R_E_water_treat_kids_oth == "Bottol dhote he." | R_E_water_treat_kids_oth == "Bottol pe saf karke pani rakte he." | R_E_water_treat_kids_oth == "Bottotle saf kar ke dete he." | R_E_water_treat_kids_oth == "Clean tha container" | R_E_water_treat_kids_oth == "Clean the container" | R_E_water_treat_kids_oth == "Clean untensil" | R_E_water_treat_kids_oth == "Cleaning Utensils" | R_E_water_treat_kids_oth == "Cleansing her water bottle" | R_E_water_treat_kids_oth == "Cleansing the water bottle" | R_E_water_treat_kids_oth == "Clin contenor" | R_E_water_treat_kids_oth == "Glash saf kartehe." | R_E_water_treat_kids_oth == "Glass clean"  | R_E_water_treat_kids_oth == "Glass dhote he." | R_E_water_treat_kids_oth == "Glass dhote he." | R_E_water_treat_kids_oth == "Glass saf arke pani dete hai" | R_E_water_treat_kids_oth == "Glass saf karke dete he." | R_E_water_treat_kids_oth == "Glass saf karke pani dete hai" | R_E_water_treat_kids_oth == "Glass saf karte hei" | R_E_water_treat_kids_oth == "Glass, bottle saf karte hai" | R_E_water_treat_kids_oth == "Handi dhokar rakte he." | R_E_water_treat_kids_oth == "Handi dhote he" | R_E_water_treat_kids_oth == "Handi dhote he." | R_E_water_treat_kids_oth == "Handi saf kar ke rakte he." | R_E_water_treat_kids_oth == "Handi saf karte hei" | R_E_water_treat_kids_oth == "Handi safa" | R_E_water_treat_kids_oth == "Handi safa karte hai" | R_E_water_treat_kids_oth == "Patra saf karke rakhate hen" | R_E_water_treat_kids_oth == "Patra saf karte hen" | R_E_water_treat_kids_oth == "Wash the container" | R_E_water_treat_kids_oth == "Wash water bottle before storage water." | R_E_water_treat_kids_oth == "Wash water container before storage." | R_E_water_treat_kids_oth == "Wash water container before storage water." | R_E_water_treat_kids_oth == "Wash water container before storage water" | R_E_water_treat_kids_oth == "Wash water container before storage water" | R_E_water_treat_kids_oth == "Handi saf karte hei , bottle saf karte hai" | R_E_water_treat_kids_oth == "Cleansing the vessel's before collecting water" | R_E_water_treat_kids_oth == "Bottle saf karte hain, glass saf karte hai" | R_E_water_treat_kids_oth == "Handi saf karte hain" 

*** R_E_sec_source_reason_oth: In what other circumstances do you collect drinking water from these other/secondary water sources? (follow-up question to R_E_sec_source_reason; original options include 7 categories, others and dont know)

* Recategorising into existing category: 
//Option 1: Primary source isn't working (based on GitHub issue #131)
replace R_E_sec_source_reason_1=1 if R_E_sec_source_reason_oth ==   "Electric problem" | R_E_sec_source_reason_oth ==   "Electricity problem" | R_E_sec_source_reason_oth ==   "Current issue" | R_E_sec_source_reason_oth ==   "Power cut" | R_E_sec_source_reason_oth ==   "Electrical problems" | R_E_sec_source_reason_oth ==   "Electric problems" | R_E_sec_source_reason_oth ==   "Current problems"

*Replacing the other category with zero after categoring the text responses
replace R_E_sec_source_reason__77=0 if R_E_sec_source_reason_oth ==   "Electric problem" | R_E_sec_source_reason_oth ==   "Electricity problem" | R_E_sec_source_reason_oth ==   "Current issue" | R_E_sec_source_reason_oth ==   "Power cut" | R_E_sec_source_reason_oth ==   "Electrical problems" | R_E_sec_source_reason_oth ==   "Electric problems" | R_E_sec_source_reason_oth ==   "Current problems"


*** Supply schedule of JJM tap water
*Recategorising into existing category: "Daily"
replace R_E_tap_supply_freq=1 if R_E_tap_supply_freq==-77 //recoding the other category into "Daily" category given that water is supplied daily but the quantity is less

*** Reason that the jjm tap was not functional
*Recategorising into existing categories
//Option 1: Pump operator did not turn on the water flow
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" //PO didnt turn on water as he didn't get his salary
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Pump opertator Not in village"

//Option 2: Water was not flowing due to an issue in the storage tank or distribution system (including elevation)
replace R_E_tap_function_reason_2=1 if R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | ///
R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | ///
R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | ///
R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" //tap or the house is at the end or at an elevation

//Option 4: Electricty / Current issue
replace R_E_tap_function_reason_4=1 if R_E_tap_function_oth=="Electricity problem" 

*Replacing the other category with zero after categoring the text responses
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" | R_E_tap_function_oth=="Pump opertator Not in village" | R_E_tap_function_oth=="Electricity problem" | R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" 

/**Responses Not categorised yet: R_E_tap_function_oth

"Late re uthi thibaru Pani banda hoi gala"
"Alpa samaya pain pani chhadi thile"

*/

*** Issues with tap water 
*Creating a new category for those who report supply related issues 
//the variable R_E_tap_issues_type (select multiple) has 7 categories including dont know and other; creating new variable to recategorise some of the other category responses 
gen R_E_tap_issues_type_6=.
replace R_E_tap_issues_type_6=0 if R_E_tap_issues==1
replace R_E_tap_issues_type_6=1 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" 

*Recategorising into existing categories
//Option 1: Smell issues
replace R_E_tap_issues_type_1=1 if R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" 
//Option 3: Water is muddy/silty
replace R_E_tap_issues_type_3=1 if R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 

*Replacing the other category with zero after categoring the text responses
replace R_E_tap_issues_type__77=0 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" | R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" | ///
R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 

/**Responses Not categorised yet: R_E_tap_issues_type_oth
Pani re siuli aasuchhi
Cold
Handire pani rakhile cement rakhila vali hei jauchhi
//two blank responses also present
*/


*** Reasons for not drinking JJM tap water
*Recategorising into existing categories

//Option 3: Reason for not drinking: Water supply is intermittent 
replace R_E_reason_nodrink_3=1 if R_E_nodrink_water_treat_oth=="Ise mahine me time pe pani nahi aya esliye wo pani nahi piye hein"  

/*
//Option 4: Reason for not drinking: Water is silty or muddy 
// replace R_E_reason_nodrink_4=1 if R_E_nodrink_water_treat_oth==

//Option 2: Reason for not drinking: Water supply is inadequate
replace R_E_reason_nodrink_2=1 if R_E_nodrink_water_treat_oth==

//Option 1: Reason for not drinking: Tap is broken and doesn't supply water 
replace R_E_reason_nodrink_1=1 if R_E_nodrink_water_treat_oth==
*/

*Creating a new category for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank 
gen R_E_reason_nodrink_5=.
replace R_E_reason_nodrink_5=0 if R_E_reason_nodrink!=""
replace R_E_reason_nodrink_5=1 if R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | ///
R_E_nodrink_water_treat_oth=="Hh not connected to jjm" | R_E_nodrink_water_treat_oth=="Sarakari tap nai dia hua hai is sahi me" | ///
R_E_nodrink_water_treat_oth=="Sarakari tap idhara nai dia hua hai" | R_E_nodrink_water_treat_oth=="Tap lagi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm hh tap" | R_E_nodrink_water_treat_oth=="Tap nahi diya hua hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hain" | R_E_nodrink_water_treat_oth=="Tap nahi deyegaye hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi diye gaye hai" | R_E_nodrink_water_treat_oth=="Connection nhi hai" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hai" | R_E_nodrink_water_treat_oth=="Tap connection dia heini" | ///
R_E_nodrink_water_treat_oth=="Tap connection nahi" | R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Basudha  connection nehi hai  Annya logo ka jaga se hokar pipe hokar anatha bo log manakarnese pani ka connection nehi hua." | ///
R_E_nodrink_water_treat_oth=="Unki ghar me JJm tap nehi he." | R_E_nodrink_water_treat_oth=="JJm ,Basudha connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="JJm Basudha connection nehi hua hai" | R_E_nodrink_water_treat_oth=="Dia hoi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | R_E_nodrink_water_treat_oth=="Not connected" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="No connection" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tap" | R_E_nodrink_water_treat_oth=="Govt tap no connection" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM  tab connection nehi hua hai." | ///
R_E_nodrink_water_treat_oth=="Isi household meJJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household ka basudha ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hei isi bajase wo tap pani nahin pite hei" | ///
R_E_nodrink_water_treat_oth=="Is household JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Is family me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply water not connected in this house hold" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Not connected to jjm tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hei" | R_E_nodrink_water_treat_oth=="Not connected to JJM tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Government tap nahi." | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply not connected this house hold" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap ka connection nahi hai" 



*Creating a new category for those who dont drink jjm water because they fetch drinking water from other private water source
gen R_E_reason_nodrink_6=.
replace R_E_reason_nodrink_6=0 if R_E_reason_nodrink!=""
replace R_E_reason_nodrink_6=1 if R_E_nodrink_water_treat_oth=="Khud ka baruel hai" | ///
R_E_nodrink_water_treat_oth=="Unke ghara me khudka surakhita kuan hai," | ///
R_E_nodrink_water_treat_oth=="Khud ka boruel hai" | R_E_nodrink_water_treat_oth=="Khudka bore laga hai isliye use nhi karte hain" | ///
R_E_nodrink_water_treat_oth=="Khudka bore hai isliye" | R_E_nodrink_water_treat_oth=="Electrical Borwell achi to use korunahanti" |  ///
R_E_nodrink_water_treat_oth=="Khudka borewell hei isiliye JJM tap ka pani nahi pite hei" | ///
R_E_nodrink_water_treat_oth=="Don't need inke ghar main already Borewell hain electricity wala" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use karunahanti kohile" | ///
R_E_nodrink_water_treat_oth=="Electricity pump boring available that's and" | ///
R_E_nodrink_water_treat_oth=="Nija ghare Borwell pani achi to tap pani use korunahanti" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use koruchu" | R_E_nodrink_water_treat_oth=="Borwell achi to use karunu" | ///
R_E_nodrink_water_treat_oth=="Apna khudka borwell he ishliye tape pani pinekeliye byabahar nehikartehe" | ///
R_E_nodrink_water_treat_oth=="No connection" 

*Creating a new category for those who dont drink jjm water as the Water from Government provided household tap does not taste good for consistency with follow up rounds 
gen R_E_reason_nodrink_7=.
replace R_E_reason_nodrink_7=0 if R_E_reason_nodrink!=""


*Replacing the other category with zero after categoring the text responses
replace R_E_reason_nodrink__77=0 if R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | ///
R_E_nodrink_water_treat_oth=="Hh not connected to jjm" | R_E_nodrink_water_treat_oth=="Sarakari tap nai dia hua hai is sahi me" | ///
R_E_nodrink_water_treat_oth=="Sarakari tap idhara nai dia hua hai" | R_E_nodrink_water_treat_oth=="Tap lagi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm hh tap" | R_E_nodrink_water_treat_oth=="Tap nahi diya hua hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hain" | R_E_nodrink_water_treat_oth=="Tap nahi deyegaye hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi diye gaye hai" | R_E_nodrink_water_treat_oth=="Connection nhi hai" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hai" | R_E_nodrink_water_treat_oth=="Tap connection dia heini" | ///
R_E_nodrink_water_treat_oth=="Tap connection nahi" | R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Basudha  connection nehi hai  Annya logo ka jaga se hokar pipe hokar anatha bo log manakarnese pani ka connection nehi hua." | ///
R_E_nodrink_water_treat_oth=="Unki ghar me JJm tap nehi he." | R_E_nodrink_water_treat_oth=="JJm ,Basudha connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="JJm Basudha connection nehi hua hai" | R_E_nodrink_water_treat_oth=="Dia hoi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | R_E_nodrink_water_treat_oth=="Not connected" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="No connection" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tap" | R_E_nodrink_water_treat_oth=="Govt tap no connection" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM  tab connection nehi hua hai." | ///
R_E_nodrink_water_treat_oth=="Isi household meJJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household ka basudha ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hei isi bajase wo tap pani nahin pite hei" | ///
R_E_nodrink_water_treat_oth=="Is household JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Is family me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply water not connected in this house hold" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Not connected to jjm tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hei" | R_E_nodrink_water_treat_oth=="Not connected to JJM tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Government tap nahi." | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply not connected this house hold" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap ka connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Khud ka baruel hai" | ///
R_E_nodrink_water_treat_oth=="Unke ghara me khudka surakhita kuan hai," | ///
R_E_nodrink_water_treat_oth=="Khud ka boruel hai" | R_E_nodrink_water_treat_oth=="Khudka bore laga hai isliye use nhi karte hain" | ///
R_E_nodrink_water_treat_oth=="Khudka bore hai isliye" | R_E_nodrink_water_treat_oth=="Electrical Borwell achi to use korunahanti" |  ///
R_E_nodrink_water_treat_oth=="Khudka borewell hei isiliye JJM tap ka pani nahi pite hei" | ///
R_E_nodrink_water_treat_oth=="Don't need inke ghar main already Borewell hain electricity wala" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use karunahanti kohile" | ///
R_E_nodrink_water_treat_oth=="Electricity pump boring available that's and" | ///
R_E_nodrink_water_treat_oth=="Nija ghare Borwell pani achi to tap pani use korunahanti" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use koruchu" | R_E_nodrink_water_treat_oth=="Borwell achi to use karunu" | ///
R_E_nodrink_water_treat_oth=="Apna khudka borwell he ishliye tape pani pinekeliye byabahar nehikartehe" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="Ise mahine me time pe pani nahi aya esliye wo pani nahi piye hein"


/** Responses not categorised yet:  R_E_nodrink_water_treat_oth 
//Translations required
"Pani ru dhulli gunda baharuchhi" 
"Alga jagare rahuchacnti Sethi TAP conection deinahanti"
"Aagaru khola kua ra Pani  abhiyasa hoi jaichi boli tap Pani piu nahanti"
"Kasa haijauthiba ru piunahanti"
"Nijara achhi bali"
"3 month hogeya supply pani khud bandha kardiya hai  kunki manual Handpump ka pani unko achche lagta hai" //turned off the tap themselves or the water hasn't been supplied in three months??
"Ghare available panira subidha achi"
"Ghare available achi boli"
"Ghare pani achi to use koruchu, tap connection nahi"
"Panire poka ,machhi baharuchhi"
"Gharki borki pani agar mortar chalunehi hone se pite he."
"Handire pani rakhile siment lagila pari hauchhi"

//Unsure about the right category
"Abhi tak supply pani nehi a raha hea." //water hasnt been supplied yet (can be categorised into 1 or 3?)
"Pehele se manual handpump kapanipiyehe ishliye tap pani achanehi lagtahe ishliye manual handpump kapanipitehe" //used to drinking water from handpump and dont like tap water (can be clubbed with reason_nodrink_6_el?)
"Time houni morning utiki dhariba ku Sethi pae jjm tap use korunu" //dont have the time in the morning to fill water from JJM tap 
"Tap ru bhala Pani aasu nahi" // tap water isn't good? (can be categorised as muddy or silty???)
"Tanki saf nahin karne bajase Pani nahin pite hai" //don't drink tap water as tank is not clean (new category or muddy and silty?)
"Tanki ko saf nahi karne bajase Pani nahin pite hain" //don't drink tap water as tank is not clean (new category or muddy and silty?)
"Unki Basudha tap jo hei unki dusre jaga pe hei distance bajase pani nahin pite hei" //their basudha tap is at a diff location 
"Pani ka test achha nhi lag raha hai" //dont like the taste (can be clubbed with silty and muddy?)
"Supply watreTank nehi he ish village pe" //no water tank in the village???? - probably means no water supply 
"Ish Hamlet pe supply water nehi he" //water not supplied to this hamlet 
"Ish Hamlet pe supply water nehi he" //water not supplied to this hamlet 
"Jjm not supply in this area"
"Jjm water not supply in this hamlet"
"Paip  nehihe" //dont have a pipe
"Tap bohot distance me hai isilie" //tap is placed far from the house

//taste and smell?
"Pani ka test achha nhi lag raha hai" //dont like the taste (can be clubbed with silty and muddy?)
"Basna bohut jada hora hai" 
"Chlorine smell pain" 
"Bliching smell" 
"blinchi poudar ka smell ara hai isilie ni pura he" 

//vague
"No specific problem"
"Not safety according to Respondent"
"Not suplay to govt water"
*/



*** R_E_jjm_use_oth: "or what other purposes do you use water collected from the government provided household taps?" (options include 7 categories, other and dont know)
*Recategorising into existing categories
//Option 4: Cleaning the house (Expanding it to include Cleaning and other activities around the household like washing vehicles, construction related activites, etc., and relabelling it)
replace R_E_jjm_use_4=1 if R_E_jjm_use_oth=="Gadi dhoiba" | R_E_jjm_use_oth=="Ghara tiari" | R_E_jjm_use_oth=="House build" | R_E_jjm_use_oth=="Construction house" | R_E_jjm_use_oth=="Bike safa karte hai" | R_E_jjm_use_oth=="Gadi dhoiba" | R_E_jjm_use_oth=="Ghara tiari kama" | R_E_jjm_use_oth=="Bike saf karnekelia use karte hen" | R_E_jjm_use_oth=="Baike wash" | R_E_jjm_use_oth=="Construction house to Sperry water" | R_E_jjm_use_oth=="Construction kam" | R_E_jjm_use_oth=="Construction kam, toilet jane ke liye" | R_E_jjm_use_oth=="Puja ,cooler fan may use karte hai" | R_E_jjm_use_oth=="Cooling House sometimes" | R_E_jjm_use_oth=="Puja ,Cooler may pani use karte hai"

label var R_E_jjm_use_4 "Cleaning and other HH activites"
// label define R_E_jjm_use_4 1 "Yes" 0 "No"
// label values R_E_jjm_use_4 R_E_jjm_use_4 


//Option 5: Bathing (Expanding it to include use for hygiene and sanitation purposes and relabelling it)
replace R_E_jjm_use_5=1 if R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Warship,toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Used in construction work" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet used" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Construction kam, toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jiba" | R_E_jjm_use_oth=="Toilet jane ke lie use karte hai" | R_E_jjm_use_oth=="Toilet" 

label var R_E_jjm_use_5 "Hygiene and Sanitation purposes"
// label define R_E_jjm_use_5 1 "Yes" 0 "No"
// label values R_E_jjm_use_5 R_E_jjm_use_5 


//Option 7: Irrigation (Expanding it to include gardening as well and relabelling it)
replace R_E_jjm_use_7=1 if R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Puja karanti , kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Gardening" | R_E_jjm_use_oth=="Kitchen garden" 

label var R_E_jjm_use_7 "Irrigation and Gardening"
// label define R_E_jjm_use_7 1 "Yes" 0 "No"
// label values R_E_jjm_use_7 R_E_jjm_use_7 


*Creating new category for those who use it for worship
gen R_E_jjm_use_8=.
replace R_E_jjm_use_8=0 if R_E_jjm_use!=""
replace R_E_jjm_use_8=1 if R_E_jjm_use_oth=="Puja karanti" | R_E_jjm_use_oth=="Pooja" | R_E_jjm_use_oth=="Puja keliye" | R_E_jjm_use_oth=="Puja ,cooler fan may use karte hai" | R_E_jjm_use_oth=="Warship,toilet" | R_E_jjm_use_oth=="Puja karte hai" | R_E_jjm_use_oth=="Puja karanti , kitchen garden" | R_E_jjm_use_oth=="Bhagbanko puja karne kelia use karte hen" | R_E_jjm_use_oth=="Puja ,Cooler may pani use karte hai" | R_E_jjm_use_oth=="Puja kerneke liye bhi used karte he." 

label var R_E_jjm_use_8 "Puja/Worship"
label define R_E_jjm_use_8 1 "Yes" 0 "No"
label values R_E_jjm_use_8 R_E_jjm_use_8


*Replacing the other category with zero after categoring the text responses
replace R_E_jjm_use__77=0 if R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Warship,toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Used in construction work" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Washroom" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Toilet used" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Bathroom" | R_E_jjm_use_oth=="Toilet jane ke liye" | R_E_jjm_use_oth=="Construction kam, toilet jane ke liye" | R_E_jjm_use_oth=="Toilet jiba" | R_E_jjm_use_oth=="Toilet jane ke lie use karte hai" | R_E_jjm_use_oth=="Toilet" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Puja karanti , kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Gardening" | R_E_jjm_use_oth=="Kitchen garden" | R_E_jjm_use_oth=="Gadi dhoiba" | R_E_jjm_use_oth=="Ghara tiari" | R_E_jjm_use_oth=="House build" | R_E_jjm_use_oth=="Construction house" | R_E_jjm_use_oth=="Bike safa karte hai" | R_E_jjm_use_oth=="Gadi dhoiba" | R_E_jjm_use_oth=="Ghara tiari kama" | R_E_jjm_use_oth=="Bike saf karnekelia use karte hen" | R_E_jjm_use_oth=="Baike wash" | R_E_jjm_use_oth=="Construction house to Sperry water" | R_E_jjm_use_oth=="Construction kam" | R_E_jjm_use_oth=="Construction kam, toilet jane ke liye" | R_E_jjm_use_oth=="Puja karanti" | R_E_jjm_use_oth=="Pooja" | R_E_jjm_use_oth=="Puja keliye" | R_E_jjm_use_oth=="Puja ,cooler fan may use karte hai" | R_E_jjm_use_oth=="Warship,toilet" | R_E_jjm_use_oth=="Puja karte hai" | R_E_jjm_use_oth=="Puja karanti , kitchen garden" | R_E_jjm_use_oth=="Bhagbanko puja karne kelia use karte hen" | R_E_jjm_use_oth=="Puja ,Cooler may pani use karte hai" | R_E_jjm_use_oth=="Puja kerneke liye bhi used karte he." | R_E_jjm_use_oth=="Cooling House sometimes"



*** R_E_water_prim_oth: "In the past month, which other water source did you primarily use for drinking?" (Options include 10 options and other)
/*Not categorised yet:
Purchase water , Bottle water Ayurplus Water //bottled water
*/


*** R_E_water_source_sec_oth: "In the past month, what other water sources has your household used for drinking?" (Options include 10 options and other)

/*Not Categorised yet:
Purchase bottle water //bottled water 
Railway station se pani laethe //bottled water purchased from railway station
*/


*** R_E_treat_kids_freq_oth: Follow up question to: "For your youngest children, when do you make the water safe before they drink it?"
/*Not categorised yet:
//No fixed schedule: depending on avaialbility of time: can create a new category but is it required for 3 obs?
Jab man kia tabhi detahun pani garam karke bache ko deti hun
Time ho to karti hen nehi to nehi karte hen
Jab jab time mile pani garam karte he ,nirdhist time nehi he
*/


*** R_E_water_prim_kids_oth 
/*Not categorised yet:
Pani nehi pilate, millet pilate he //child too young to be fed water
*/


*** R_E_treat_freq_oth 
/*Not categorised yet:
//Treat water occasionally: can create a new category but is it required for 3 obs?
1 month ku thare
Kebe kebe
Kabhi kbhi karte hai
*/


*** R_E_water_sec_freq_oth: no obs 

*** R_E_water_prim_preg_oth: No observations


********************************************************************************
*** Recoding the variables for consistency 
********************************************************************************

* Primary water source 
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" changed from "7" in Baseline to "6" in Endline 
recode R_E_water_source_prim (6=11)  //recoding value of option 6 to a placeholder 
recode R_E_water_source_prim (7=6) (11=7) //recoding to values consistent with baseline

* Secondary water source
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" chnaged from "7" in Baseline to "6" in Endline 
//recode R_E_water_source_sec (6=11)  //recoding value of option 6 to a placeholder 
//recode R_E_water_source_sec (7=6) (11=7) //recoding to values consistent with baseline 
replace R_E_water_source_sec="1 7" if R_E_water_source_sec=="1 6"
replace R_E_water_source_sec="4 7" if R_E_water_source_sec=="4 6"
replace R_E_water_source_sec="7" if R_E_water_source_sec=="6"
replace R_E_water_source_sec="6" if R_E_water_source_sec=="7"


//Renaming the relevant variables to reflect the changes in values  
rename R_E_water_source_sec_6 R_E_water_source_sec_temp
rename R_E_water_source_sec_7 R_E_water_source_sec_6
rename R_E_water_source_sec_temp R_E_water_source_sec_7

* Primary water source for the children 
//Value assigned to "Uncovered dug well" changed from "6" in Baseline to "7 in Endline; value assigned to "Directly fetched by surface water" chnaged from "7" in Baseline to "6" in Endline 
recode R_E_water_prim_source_kids (6=11)  //recoding value of option 6 to a placeholder 
recode R_E_water_prim_source_kids (7=6) (11=7) //recoding to values consistent with baseline 

*Recoding the value of Dont know to 999
//For following variables, value assigned to option "Don't know" was -99 in Baseline and changed to 999 in Endline; coding it to -99 for consistency
foreach i in R_Cen_a17_water_source_kids R_Cen_a13_water_sec_yn R_Cen_a16_water_treat R_Cen_a16_stored_treat R_Cen_a17_water_treat_kids R_Cen_a19_jjm_stored {
	replace `i'=999 if `i'==-99
}

********************************************************************************
*** Renaming the variables for consistency 
********************************************************************************

forvalues i = 1/9{
cap rename R_Cen_a13_water_source_sec_`i' R_Cen_water_source_sec_`i'
}

forvalues i = 1/999{
cap rename R_Cen_a14_sec_source_reason_`i' R_Cen_sec_source_reason_`i'
}

forvalues i = 1/999{
cap rename R_Cen_a16_water_treat_type_`i' R_Cen_water_treat_type_`i'
}

forvalues i = 1/6{
cap rename R_Cen_a16_water_treat_freq_`i' R_Cen_water_treat_freq_`i'
}

forvalues i = 1/6{
cap rename R_Cen_a17_treat_kids_freq_`i' R_Cen_treat_kids_freq_`i'
}

forvalues i=1/999{
	cap rename R_Cen_a18_reason_nodrink_`i' R_Cen_reason_nodrink_`i'
}

forvalues i=1/999{
	cap rename R_Cen_a20_jjm_use_`i' R_Cen_jjm_use_`i'
}

// forvalues i=1/17{
// 	cap rename R_Cen_a4_hhmember_gender_`i' R_Cen_a4_hhmember_gender_`i'
// }

// forvalues i=1/17{
// 	cap rename R_Cen_a6_hhmember_age_`i' R_Cen_a6_hhmember_age_`i'
// }
rename R_Cen_a12_water_source_prim R_Cen_water_source_prim
rename R_Cen_a13_water_sec_yn R_Cen_water_sec_yn
rename R_Cen_a13_water_source_sec R_Cen_water_source_sec
rename R_Cen_a13_water_source_sec__77 R_Cen_water_source_sec__77 
rename R_Cen_a14_sec_source_reason R_Cen_sec_source_reason
rename R_Cen_a14_sec_source_reason__77 R_Cen_sec_source_reason__77
rename R_Cen_a15_water_sec_freq R_Cen_water_sec_freq
rename R_Cen_a16_water_treat_type__77 R_Cen_water_treat_type__77
rename R_Cen_a16_water_treat_freq R_Cen_water_treat_freq
rename R_Cen_a16_water_treat R_Cen_water_treat
rename R_Cen_a16_water_treat_type R_Cen_water_treat_type
rename R_Cen_a16_water_treat_freq__77 R_Cen_water_treat_freq__77
rename R_Cen_a17_treat_kids_freq__77 R_Cen_treat_kids_freq__77
rename R_Cen_a17_water_treat_kids R_Cen_water_treat_kids
rename R_Cen_a17_treat_kids_freq R_Cen_treat_kids_freq
rename R_Cen_a17_water_source_kids R_Cen_water_source_kids
rename R_Cen_a18_jjm_drinking R_Cen_jjm_drinking
rename R_Cen_a18_reason_nodrink R_Cen_reason_nodrink
rename R_Cen_a19_jjm_stored R_Cen_jjm_stored
rename R_Cen_a20_jjm_yes R_Cen_jjm_yes
rename R_Cen_a20_jjm_use R_Cen_jjm_use
rename R_Cen_a20_jjm_use_oth R_Cen_jjm_use_oth
rename R_Cen_a33_bicycle R_Cen_bicycle 
rename R_Cen_a33_bwtv R_Cen_bwtv 
rename R_Cen_a33_car R_Cen_car 
rename R_Cen_a33_colourtv R_Cen_colourtv 
rename R_Cen_a33_chair R_Cen_chair 
rename R_Cen_a33_computer R_Cen_computer 
rename R_Cen_a33_cotbed R_Cen_cotbed 
rename R_Cen_a33_landline R_Cen_landline
rename R_Cen_a33_mattress R_Cen_mattress 
rename R_Cen_a33_mobile R_Cen_mobile 
rename R_Cen_a33_motorcycle R_Cen_motorcycle
rename R_Cen_a33_pressurecooker R_Cen_pressurecooker
rename R_Cen_a33_radiotransistor R_Cen_radiotransistor
rename R_Cen_a33_fridge R_Cen_fridge 
rename R_Cen_a33_sewingmachine R_Cen_sewingmachine
rename R_Cen_a33_table R_Cen_table
rename R_Cen_a33_thresher R_Cen_thresher 
rename R_Cen_a33_tractor R_Cen_tractor 
rename R_Cen_a33_washingmachine R_Cen_washingmachine 
rename R_Cen_a33_watchclock R_Cen_watchclock
rename R_Cen_a33_waterpump R_Cen_waterpump 
rename R_Cen_a33_ac R_Cen_ac
rename R_Cen_a33_cart R_Cen_cart
rename R_Cen_a33_electricfan R_Cen_electricfan
rename R_Cen_a33_electricity R_Cen_electricity
rename R_Cen_a33_internet R_Cen_internet
rename R_Cen_a34_roof R_Cen_roof
rename R_Cen_a35_poultry R_Cen_poultry
rename R_Cen_a36_castename R_Cen_castename
rename R_Cen_a37_caste R_Cen_caste
rename R_Cen_a41_end_comments R_Cen_end_comments
rename R_Cen_a42_survey_accompany_num R_Cen_survey_accompany_num

rename R_Cen_a40_gps_latitude R_Cen_gps_latitude
rename R_Cen_a40_gps_longitude R_Cen_gps_longitude
rename R_Cen_a10_hhhead R_Cen_hhhead
rename R_Cen_a10_hhhead_gender R_Cen_hhhead_gender
rename R_Cen_a11_oldmale R_Cen_oldmale
//rename R_Cen_a12_ws_prim R_Cen_ws_prim 
rename R_Cen_a15_water_sec_freq_oth R_Cen_water_sec_freq_oth
rename R_Cen_a16_treat_freq_oth R_Cen_water_treat_freq_oth
rename R_Cen_a16_stored_treat_freq R_Cen_stored_treat_freq
rename R_Cen_a18_reason_nodrink__77  R_Cen_reason_nodrink__77
rename R_Cen_a20_jjm_use__77 R_Cen_jjm_use__77
rename R_Cen_a43_revisit R_Cen_revisit
rename R_Cen_a35_chicken R_Cen_chicken 
rename R_Cen_a35_cattle R_Cen_cattle 
rename R_Cen_a35_goats R_Cen_goats 
rename R_Cen_a35_sheep R_Cen_sheep

//renaming for consistency across EL and BL
rename R_Cen_a12_prim_source_oth R_Cen_water_source_prim_oth
rename R_E_water_prim_oth R_E_water_source_prim_oth 
rename R_Cen_a13_water_sec_oth R_Cen_water_source_sec_oth
rename R_Cen_a16_stored_treat R_Cen_water_stored
rename R_Cen_a2_hhmember_count R_Cen_hhmember_count
//renaming for easier identification of variable
rename R_E_nodrink_water_treat_oth R_E_reason_nodrink_oth
rename R_Cen_a18_water_treat_oth R_Cen_reason_nodrink_oth
rename R_Cen_a16_water_treat_oth R_Cen_water_treat_type_oth
rename R_E_water_treat_oth R_E_water_treat_type_oth
rename R_E_tap_function_oth R_E_tap_function_reason_oth 
rename R_E_treat_freq_oth R_E_water_treat_freq_oth

               
********************************************************************************
*** Generating new variables 
********************************************************************************

//GitHub Issue #121: Surveycto calculate fields capturing the number of members in different age groups might not reflect actual numbers, generating new variables 
*** Creating a variable for total number of HH members (Baseline census, Endline new members - recorded in both census and revisit)
* Creating a variable for number of new members in endline - census and roster
egen C_E_n_hhmember_count= rownonmiss(R_E_comb_hhmember_age1 R_E_comb_hhmember_age2 R_E_comb_hhmember_age3 R_E_comb_hhmember_age4 R_E_comb_hhmember_age5 R_E_comb_hhmember_age6 R_E_comb_hhmember_age7) //counting non missing values of age to get number of new members
* Combined variable for Number of HH members (both Baseline and new members in Endline)
egen C_total_hhmembers=rowtotal(R_Cen_hhmember_count C_E_n_hhmember_count) 
//labelling the variables
label var R_Cen_hhmember_count "Number of HH members in Baseline"
label var C_E_n_hhmember_count "Number of New HH members in Endline"
label var C_total_hhmembers "Total number of HH members: Baseline and Endline"


* Number of U5 Children
//Generating new binary variable if age of HH member is <5
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen C_Cen_U5child_`i' =1 if R_Cen_a6_hhmember_age_`i'<5 
}
forvalues i=1/7 { //loop for all new members in Endline Census
	gen C_E_n_U5child_`i'=1 if  R_E_comb_hhmember_age`i'<5
}
//Generating variable for total no of U5 children in Baseline and Endline
egen C_total_U5children= rowtotal(C_Cen_U5child_* C_E_n_U5child_*)
label var C_total_U5children "Total number of U5 children: Baseline and Endline"
//Generating variable for total no of U5 children in Baseline
egen C_Cen_U5children= rowtotal(C_Cen_U5child_*)
label var C_Cen_U5children "Total number of U5 children: Baseline"
//Generating variable for total no of U5 children in Endline
egen C_E_n_U5children= rowtotal(C_E_n_U5child_*)
label var C_E_n_U5children "Total number of U5 children: Endline"


* Number of pregnant women
// Generating variable for total no of pregnant women in Endline 
egen C_E_total_pregnant= rowtotal(R_E_comb_preg_status*)
label var C_E_total_pregnant "Total number of Pregnant women in Endline"
	
	
* Number of Women of Child Bearing Age (15 to 49)
//Generating new binary variable if the baseline member is a woman of Child bearing age 
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen C_Cen_female_15to49_`i'=1 if R_Cen_a6_hhmember_age_`i'>=15 & R_Cen_a6_hhmember_age_`i'<=49 & R_Cen_a4_hhmember_gender_`i'==2
}
//Generating new binary variable if the new member in Endline is a woman of Child bearing age 
forvalues i=1/7 { //loop for all family members in New roster of endline 
	gen C_E_n_female_15to49_`i'=1 if R_Cen_a6_hhmember_age_`i'>=15 & R_Cen_a6_hhmember_age_`i'<=49 & R_Cen_a4_hhmember_gender_`i'==2
}
//Generating vairable for total no of CBW in Baseline and Endline
egen C_total_CBW= rowtotal(C_E_n_female_15to49_* C_Cen_female_15to49_*)
label var C_total_CBW "Total number women of child bearing age: Baseline and Endline"
//Generating vairable for total no of CBW in Baseline
egen C_Cen_CBW= rowtotal(C_Cen_female_15to49_*)
label var C_Cen_CBW "Total number of women of child bearing age: Baseline"
//Generating vairable for total no of CBW in Endline
egen C_E_n_CBW= rowtotal(C_E_n_female_15to49_*)
label var C_E_n_CBW "Total number of women of child bearing age: Endline"


* Number of Other Members in the HH 
//Generating binary variable if HH member is neither CBW nor U5: Baseline Members
forvalues i=1/17{ //loop for all HH members in Baseline
	gen C_Cen_noncri_members_`i'=1 if (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a4_hhmember_gender_`i'==1) | (R_Cen_a6_hhmember_age_`i'>49 & R_Cen_a4_hhmember_gender_`i'==2) | (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a6_hhmember_age_`i'<15 & R_Cen_a4_hhmember_gender_`i'==2)
}
//Generating binary variable if HH member is neither CBW nor U5: New members in Endline 
forvalues i=1/7{ //loop for all HH members in New roster in endline 
	gen C_E_n_noncri_members_`i'=1 if (R_E_comb_hhmember_age`i'>=5 & R_E_comb_hhmember_gender`i'==1) | (R_E_comb_hhmember_age`i'>49 & R_E_comb_hhmember_gender`i'==2) | (R_E_comb_hhmember_age`i'>=5 & R_E_comb_hhmember_age`i'<15 & R_E_comb_hhmember_gender`i'==2)
}
//Generating vairable for total no of non criteria/Other members in Baseline and Endline
egen C_total_noncri_members=rowtotal(C_Cen_noncri_members_* C_E_n_noncri_members_*)
label var C_total_noncri_members "Total number of non-criteria members: Baseline and Endline"
//Generating vairable for total no of non criteria/Other members in Baseline 
egen C_Cen_noncri_members=rowtotal(C_Cen_noncri_members_*)
label var C_Cen_noncri_members "Total number of non-criteria members: Baseline"
//Generating vairable for total no of non criteria/Other members in Endline
egen C_E_n_noncri_members=rowtotal(C_E_n_noncri_members_*)
label var C_E_n_noncri_members "Total number of non-criteria members: Endline"


* Number of Females above 12 years of age in the HH
//Generating new binary variable if the baseline member is a female above 12 years 
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen C_Cen_female_above12_`i'=1 if R_Cen_a6_hhmember_age_`i'>12 & R_Cen_a4_hhmember_gender_`i'==2
}
//Generating new binary variable if the new member in Endline is a female above 12 years 
forvalues i=1/7 { //loop for all family members in New roster of endline 
	gen C_E_n_female_above12_`i'=1 if R_E_comb_hhmember_age`i'>12 & R_E_comb_hhmember_gender`i'==2
}
//Generating variable for total no of females above 12 yrs in Baseline and Endline
egen C_total_female_above12= rowtotal(C_Cen_female_above12_* C_E_n_female_above12_*)
label var C_total_female_above12 "Total number of females above 12 years: Baseline and Endline"
//Generating variable for total no of females above 12 yrs in Baseline
egen C_Cen_female_above12= rowtotal(C_Cen_female_above12_*)
label var C_Cen_female_above12 "Total number of females above 12 years: Baseline"
//Generating variable for total no of females above 12 yrs in Endline
egen C_E_n_female_above12= rowtotal(C_E_n_female_above12_*)
label var C_E_n_female_above12 "Total number of females above 12 years: Endline"


* Number of males above 12 years of age in the HH
//Generating new binary variable if the baseline member is a male above 12 years 
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen C_Cen_male_above12_`i'=1 if R_Cen_a6_hhmember_age_`i'>12 & R_Cen_a4_hhmember_gender_`i'==1
}
//Generating new binary variable if the new member in Endline is a male above 12 years 
forvalues i=1/7 { //loop for all family members in New roster of endline 
	gen C_E_n_male_above12_`i'=1 if R_E_comb_hhmember_age`i'>12 &  R_E_comb_hhmember_gender`i'==1
}
//Generating variable for total no of males above 12 yrs in Baseline and Endline
egen C_total_male_above12= rowtotal(C_Cen_male_above12_* C_E_n_male_above12_*)
label var C_total_male_above12 "Total number of males above 12 years: Baseline and Endline"
//Generating variable for total no of males above 12 yrs in Baseline
egen C_Cen_male_above12= rowtotal(C_Cen_male_above12_*)
label var C_Cen_male_above12 "Total number of males above 12 years: Baseline"
//Generating variable for total no of males above 12 yrs in Endline
egen C_E_n_male_above12= rowtotal(C_E_n_male_above12_*)
label var C_E_n_male_above12 "Total number of males above 12 years: Endline"


* Total Number of HH members above 12 years of age 
//Generating variable for total no of members above 12 yrs in Baseline and Endline
egen C_total_members_above12= rowtotal(C_total_male_above12 C_total_female_above12)
label var C_total_members_above12 "Total HH members above 12 years: Baseline and Endline"
//Generating variable for total no of members above 12 yrs in Baseline 
egen C_Cen_members_above12= rowtotal(C_Cen_male_above12 C_Cen_female_above12)
label var C_Cen_members_above12 "Total HH members above 12 years: Baseline"
//Generating variable for total no of members above 12 yrs in Endline
egen C_E_n_members_above12= rowtotal(C_E_n_male_above12 C_E_n_female_above12)
label var C_E_n_members_above12 "Total HH members above 12 years: Endline"


* total Number of HH members below 12 years of age 
//Generating variable for total no of members above 12 yrs in Baseline and Endline
gen C_total_members_below12= C_total_hhmembers-C_total_members_above12
label var C_total_members_below12 "Total HH members below 12 years: Baseline and Endline"
//Generating variable for total no of members above 12 yrs in Baseline 
gen C_Cen_members_below12= R_Cen_hhmember_count-C_Cen_members_above12
label var C_Cen_members_below12 "Total HH members below 12 years: Baseline"
//Generating variable for total no of members above 12 yrs in Endline
gen C_E_n_members_below12= C_E_n_hhmember_count-C_E_n_members_above12
label var C_E_n_members_below12 "Total HH members below 12 years: Endline"

 
// *** Number of U5 kids in baseline 
// ds R_E_Cen_Type*
// foreach var of varlist `r(varlist)'{
// clonevar Cl_`var' = `var'
// }
// egen temp_group = group(unique_id)
//
// ds Cl_*
// foreach var of varlist `r(varlist)'{
// replace `var' = 1 if `var' == 4
// replace `var' = 0 if `var' == 5
// }
// egen C_Cen_u5_kids_total = rowtotal(Cl_R_E_Cen_Type*)
//
// *** Number of U5 kids in Endline
// //dropping temporary variables 
// drop Cl_*
// drop temp_group
//
// ds R_E_Cen_Type*
// foreach var of varlist `r(varlist)'{
// clonevar Cl_`var' = `var'
// }
// egen temp_group = group(unique_id)
//
// ds Cl_*
// foreach var of varlist `r(varlist)'{
// replace `var' = 1 if `var' == 5
// replace `var' = 0 if `var' == 4
// }
// egen C_E_u5_kids_total = rowtotal(Cl_R_E_Cen_Type*)
//
// *** Number of HHs with U5 kids in Baseline  
// gen C_Cen_HH_level_U5 = .
// replace C_Cen_HH_level_U5 = 1 if C_Cen_u5_kids_total != 0
// label var C_Cen_HH_level_U5 "Number of HHs with U5 children: Baseline"
//
// *** Number of HHs with U5 kids in Endline  
// gen C_E_HH_level_U5 = .
// replace C_E_HH_level_U5 = 1 if C_E_u5_kids_total != 0
// //given all Baseline U5 kids were included in Endline sample, replacing Endline var with 1 in case Baseline var is 1
// replace C_E_HH_level_U5 = 1 if C_Cen_HH_level_U5 == 1
// label var C_E_HH_level_U5 "Number of HHs with U5 children: Endline"
//


*** Index of the HH Head (to ascertain which HH member is the head)
//Extracting the index from name of HH Head
gen C_Cen_hh_head_index =.
replace C_Cen_hh_head_index=R_Cen_hhhead

*** Age of the HH head
gen C_Cen_hh_head_age = .
forval i = 1/17 { 
    replace C_Cen_hh_head_age = R_Cen_a6_hhmember_age_`i' if C_Cen_hh_head_index== `i'
}

// * Whether HH head ever attended school
// gen hh_head_attend_school=.
// forval i = 1/17 {
//     replace hh_head_attend_school = R_Cen_a9_school_`i' if hh_head_index== `i'
// }
// label var hh_head_attend_school "HH head attended school"
// label define hh_head_attend_school 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
// label values hh_head_attend_school hh_head_attend_school

*** Education Level of the HH Head
gen C_Cen_hh_head_edu = .
forval i = 1/17 {
    replace C_Cen_hh_head_edu = R_Cen_a9_school_level_`i' if C_Cen_hh_head_index== `i'
	replace C_Cen_hh_head_edu = 0 if R_Cen_a9_school_level_`i'==. & C_Cen_hh_head_index== `i'
}

*** Age of the Respondent
gen C_Cen_respondent_age = .
replace C_Cen_respondent_age = R_Cen_a6_hhmember_age_1
// replace respondent_age=. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 

*** Gender of the Respondent
gen C_Cen_respondent_gender = .
replace C_Cen_respondent_gender =R_Cen_a4_hhmember_gender_1
// replace respondent_gender =. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 

// * Whether respondent ever attended school
// gen resp_attend_school=.
// forval i = 1/17 {
//     replace resp_attend_school = R_Cen_a9_school_`i' if hh_head_index== `i'
// }
// label var resp_attend_school "Respondent attended school"
// label define resp_attend_school 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
// label values resp_attend_school resp_attend_school

*** Education Level of the Respondent
gen C_Cen_respondent_edu = .
replace C_Cen_respondent_edu = R_Cen_a9_school_level_1
replace C_Cen_respondent_edu = 0 if R_Cen_a9_school_level_1==. //replcaing the missing values (in case respondent never attended school) with 0
// replace respondent_edu =. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 

*** Asset index
local assets R_Cen_ac R_Cen_bicycle R_Cen_bwtv R_Cen_car R_Cen_cart R_Cen_chair R_Cen_colourtv R_Cen_computer R_Cen_cotbed R_Cen_electricfan R_Cen_electricity R_Cen_fridge R_Cen_internet R_Cen_landline R_Cen_mattress R_Cen_mobile R_Cen_motorcycle R_Cen_pressurecooker R_Cen_radiotransistor R_Cen_sewingmachine R_Cen_table R_Cen_thresher R_Cen_tractor R_Cen_washingmachine R_Cen_watchclock R_Cen_waterpump R_Cen_labels
 foreach i in `assets' {
    replace `i'=. if `i'==-99 | `i'==-98 //if respondent didn't know or refused to answer, recoding as missing value
   }
egen C_Cen_asset_index=rowtotal(R_Cen_ac R_Cen_bicycle R_Cen_bwtv R_Cen_car R_Cen_cart R_Cen_chair R_Cen_colourtv R_Cen_computer R_Cen_cotbed R_Cen_electricfan R_Cen_electricity R_Cen_fridge R_Cen_internet R_Cen_landline R_Cen_mattress R_Cen_mobile R_Cen_motorcycle R_Cen_pressurecooker R_Cen_radiotransistor R_Cen_sewingmachine R_Cen_table R_Cen_thresher R_Cen_tractor R_Cen_washingmachine R_Cen_watchclock R_Cen_waterpump ) //total of 26 assets

*** Asset Quintiles
egen C_Cen_asset_rank = rank(C_Cen_asset_index)
//ssc install egenmore //installing user package
egen C_Cen_asset_quintile = xtile(C_Cen_asset_rank), nq(5)
drop C_Cen_asset_rank //dropping the var that is not required 


*** Water supply frequecny on the days water is supplied regularly
gen C_E_water_supply_freq=.
replace C_E_water_supply_freq=1 if R_E_tap_supply_daily==555
replace C_E_water_supply_freq=2 if R_E_tap_supply_daily==1
replace C_E_water_supply_freq=3 if R_E_tap_supply_daily==2
replace C_E_water_supply_freq=4 if R_E_tap_supply_daily==7 | R_E_tap_supply_daily==14


*** Variables related to Water collection burden 
** Split the R_E_collect_resp string into separate variables
split R_E_collect_resp, parse(" ") generate(C_E_collect_resp)

** Generate variables to store the age and gender of the person actually responsible for collecting water (Stored in "R_E_prim_collect_resp")
* Create variables for storing age and gender of the water collector
gen C_E_primcollector_age = .
gen C_E_primcollector_gender = .

* Create a variable to store the selected index in "R_E_collect_resp"
gen C_E_selected_index = .

* Create a new variable to hold the correct index from collect_resp
destring C_E_collect_resp*, replace
forvalues i = 1/6 {
    * Check if resp`i' matches prim_collect_resp and assign the corresponding index
    qui replace C_E_selected_index = C_E_collect_resp`i' if `i' == R_E_prim_collect_resp
}

* Extract age and gender based on selected_index
/* Determining if selected_index refers to a Census or new member:

* If C_E_selected_index <= 20: it's a Census member
* If C_E_selected_index > 20: it's a new member
*/
// For census members
forval i=1/20 {
replace C_E_primcollector_age = R_E_cen_fam_age`i' if C_E_selected_index==`i' 
replace C_E_primcollector_gender = R_E_cen_fam_gender`i' if C_E_selected_index==`i'
}

// For new members (selected_index: max value is 23)
replace C_E_primcollector_age = R_E_comb_hhmember_age1 if C_E_selected_index==21
replace C_E_primcollector_age = R_E_comb_hhmember_age2 if C_E_selected_index==22
replace C_E_primcollector_age = R_E_comb_hhmember_age3 if C_E_selected_index==23

replace C_E_primcollector_gender = R_E_comb_hhmember_gender1 if C_E_selected_index==21 
replace C_E_primcollector_gender = R_E_comb_hhmember_gender2 if C_E_selected_index==22 
replace C_E_primcollector_gender = R_E_comb_hhmember_gender3 if C_E_selected_index==23 

** Generating variables to store the Age and gender of the person actually responsible for treating water(Stored in "R_E_treat_primresp")
* Split the R_E_treat_resp string into separate variables
split R_E_treat_resp, parse(" ") generate(C_E_treat_resp)

* Create variables for storing age and gender of the person who treats water
gen C_E_primtreat_age = .
gen C_E_primtreat_gender = . //1 ob missing as respondent selected that one person is responsible (treat_resp) but selected a missing obs in the person who actually treats water (treat_primresp) - should the details of the person who was selected in treat_resp be used here or should this be considered a case where the hh doesnot treat water : to check with Akito 

* Create a variable to store the selected index in "R_E_treat_resp"
gen C_E_selected_index_treat = .

* Create a new variable to hold the correct index from treat_resp
destring C_E_treat_resp*, replace
forvalues i = 1/6 {
    * Check if resp`i' matches R_E_treat_primresp and assign the corresponding index
    qui replace C_E_selected_index_treat = C_E_treat_resp`i' if `i' == R_E_treat_primresp
}

* Extract age and gender based on selected_index
/* Determining if selected_index refers to a Census or new member:

* If C_E_selected_index_treat <= 20: it's a Census member
* If C_E_selected_index_treat > 20: it's a new member
*/
// For census members
forval i=1/20 {
replace C_E_primtreat_age = R_E_cen_fam_age`i' if C_E_selected_index_treat==`i' 
replace C_E_primtreat_gender = R_E_cen_fam_gender`i' if C_E_selected_index_treat==`i'
}

// For new members (selected_index_treat: max value is 23)
replace C_E_primtreat_age = R_E_comb_hhmember_age1 if C_E_selected_index_treat==21
replace C_E_primtreat_age = R_E_comb_hhmember_age2 if C_E_selected_index_treat==22
replace C_E_primtreat_age = R_E_comb_hhmember_age3 if C_E_selected_index_treat==23

replace C_E_primtreat_gender = R_E_comb_hhmember_gender1 if C_E_selected_index_treat==21 
replace C_E_primtreat_gender = R_E_comb_hhmember_gender2 if C_E_selected_index_treat==22 
replace C_E_primtreat_gender = R_E_comb_hhmember_gender3 if C_E_selected_index_treat==23 
// replace treat_gender=0 if treats_water==0 //hh does not treat water 


*** Generating a new variable to store the main source of secodnary water
* Split the R_E_water_source_sec string into separate variables
split R_E_water_source_sec, parse(" ") generate(water_sec_value)

* Changing storage type of variables
destring water_sec_value* R_E_water_source_main_sec, replace

* Generating new var for main sec source of water
gen R_E_water_source_main_sec_new=.
forvalues i=1/2 {
replace R_E_water_source_main_sec_new=water_sec_value`i' if R_E_water_source_main_sec==`i'
}

* Dropping original variable and renaming for consistency 
drop R_E_water_source_main_sec 
rename R_E_water_source_main_sec_new R_E_water_source_main_sec 

* Labelling the variable
label var R_E_water_source_main_sec "Main souce of secondayr source"
label define R_E_water_source_main_sec 1 "Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM tank" 2 "Government provided community standpipe (connected to piped system, through Vasudha tank)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel"  8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
label values R_E_water_source_main_sec R_E_water_source_main_sec


// *** Generating new variable for time taken to collect water from primary source
// //In Baseline HH survey, the question was presented with asnwer options and in FU rounds, it was an open-ended question. Creating new variable for consistency with BAseline HH survey
// gen collect_time_category=. 
// replace collect_time_category=1 if where_prim_locate==1 | where_prim_locate==2 //If primary source is located in own yard or dwelling 
// replace collect_time_category=2 if collect_time>0 & collect_time<5
// replace collect_time_category=3 if collect_time>=5 & collect_time<=14
// replace collect_time_category=4 if collect_time>=15 & collect_time<=29
// replace collect_time_category=5 if collect_time>=30 & collect_time<=59
// replace collect_time_category=6 if collect_time>=60
//
// label var collect_time_category "Time taken to collect water from primary source"
// label define collect_time_category 1 "Water point is on-premises" 2 "< 5 minutes" 3 "5-14 minutes" 4 "15-29 minutes" 5 "30-59 minutes" 6 ">= 60 minutes"
// label values collect_time_category collect_time_category
//
// *** Generating new variable for time taken to collect water from secondary source
// //In Baseline HH survey, the question was presented with answer options and in FU rounds, it was an open-ended question. Creating new variable for consistency with Baseline HH survey
// gen collect_time_category=. 
// replace collect_sec_time_category=1 if where_sec_locate==1 | where_sec_locate==2 //If secondary source is located in own yard or dwelling 
// replace collect_sec_time_category=2 if collect_sec_time>0 & collect_sec_time<5
// replace collect_sec_time_category=3 if collect_sec_time>=5 & collect_sec_time<=14
// replace collect_sec_time_category=4 if collect_sec_time>=15 & collect_sec_time<=29
// replace collect_sec_time_category=5 if collect_sec_time>=30 & collect_sec_time<=59
// replace collect_sec_time_category=6 if collect_sec_time>=60
//
// label var collect_sec_time_category "Time taken to collect water from secondary source"
// label define collect_sec_time_category 1 "Water point is on-premises" 2 "< 5 minutes" 3 "5-14 minutes" 4 "15-29 minutes" 5 "30-59 minutes" 6 ">= 60 minutes"
// label values collect_sec_time_category collect_sec_time_category
//
// *** Generating new variable for time taken to treat water
// //In Baseline HH survey, the question was presented with answer options and in FU rounds, it was an open-ended question. Creating new variable for consistency with Baseline HH survey
// gen treat_time_category=. 
// replace treat_time_category=1 if treat_time>0 & treat_time<5
// replace treat_time_category=2 if treat_time>=5 & treat_time<=14
// replace treat_time_category=3 if treat_time>=15 & treat_time<=29
// replace treat_time_category=4 if treat_time>=30 & treat_time<=59
// replace treat_time_category=5 if treat_time>=60
//
// label var treat_time_category "Time taken to treat water"
// label define treat_time_category 2 "< 5 minutes" 3 "5-14 minutes" 4 "15-29 minutes" 5 "30-59 minutes" 6 ">= 60 minutes"
// label values treat_time_category treat_time_category

********************************************************************************
*** Labelling the new variables 
********************************************************************************

label var C_E_primtreat_age "Age of person person responsible for treating water"
label var C_E_primcollector_age "Age of person responsible for collecting water"
label var C_Cen_asset_index "Asset Index (total of 26 assets)"
label var C_Cen_respondent_age "Age of the Respondent"
label var C_Cen_hh_head_index "Household Head's index"
label var C_Cen_hh_head_age "Age of the HH Head"
//label var C_E_u5_kids_total "Number of U5 kids in Endline"
//label var C_Cen_u5_kids_total "Number of U5 kids in Baseline"

label var C_E_primtreat_gender "Gender of person responsible for treating water"
label define C_E_primtreat_gender 1 "Male" 2 "Female" 0 "HH Does not treat water"
label values C_E_primtreat_gender C_E_primtreat_gender

label var C_E_primcollector_gender "Gender of person responsible for collecting water"
label define C_E_primcollector_gender 1 "Male" 2 "Female"
label values C_E_primcollector_gender C_E_primcollector_gender

label var C_E_water_supply_freq "Frequency of Water supply"
label define C_E_water_supply_freq 1 "Supplied 24/7" 2 "Supplied once a day" 3 "Supplied twice a day" 4 "Supplied more than twice a day"
label values C_E_water_supply_freq C_E_water_supply_freq

label var C_Cen_asset_quintile "Asset Quintiles"
label define C_Cen_asset_quintile 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values C_Cen_asset_quintile C_Cen_asset_quintile

label var C_Cen_respondent_edu "Level of Education of Respondent"
label define C_Cen_respondent_edu 0 "Never Attended School" 1 "Incomplete Pre-school" 2 "Completed Pre-school" ///
3 "Incomplete Primary Education" 4 "Completed Primary Education" ///
5 "Incomplete Secondary Education" 6 "Completed Secondary Education" ///
7 "Post-secondary Education" -98 "Refused" 999 "Don't know"
label values C_Cen_respondent_edu C_Cen_respondent_edu

label var C_Cen_respondent_gender "Gender of the Respondent"
label define C_Cen_respondent_gender 1 "Male" 2 "Female" 3 "Other" 
label values C_Cen_respondent_gender C_Cen_respondent_gender

label var C_Cen_hh_head_edu "Level of Education of HH Head"
label define C_Cen_hh_head_edu 0 "Never Attended School" 1 "HH head: Incomplete Pre-school" 2 "HH head: Completed Pre-school" ///
3 "Incomplete Primary Education" 4 "Completed Primary Education" ///
5 "Incomplete Secondary Education" 6 "Completed Secondary Education" ///
7 "Post-secondary Education" -98 "Refused" 999 "Don't know"
label values C_Cen_hh_head_edu C_Cen_hh_head_edu

label var R_E_reason_nodrink_5 "Don't have a JJM tap connection"
label define R_E_reason_nodrink_5 1 "Yes" 0 "No"
label values R_E_reason_nodrink_5 R_E_reason_nodrink_5

label var R_E_reason_nodrink_6 "Have other private drinking water source "
label define R_E_reason_nodrink_6 1 "Yes" 0 "No"
label values R_E_reason_nodrink_6 R_E_reason_nodrink_6

label var R_Cen_reason_nodrink_5 "Don't have a JJM tap connection"
label define R_Cen_reason_nodrink_5 1 "Yes" 0 "No"
label values R_Cen_reason_nodrink_5 R_Cen_reason_nodrink_5

label var R_Cen_reason_nodrink_6 "Have other private drinking water source "
label define R_Cen_reason_nodrink_6 1 "Yes" 0 "No"
label values R_Cen_reason_nodrink_6 R_Cen_reason_nodrink_6

label var R_Cen_water_treat_type_5 "Clean the storage containers"
label define R_Cen_water_treat_type_5 1 "Yes" 0 "No"
label values R_Cen_water_treat_type_5 R_Cen_water_treat_type_5 

label var R_Cen_water_treat_type_6 "Cover the storage containers"
label define R_Cen_water_treat_type_6 1 "Yes" 0 "No"
label values R_Cen_water_treat_type_6 R_Cen_water_treat_type_6 

label drop R_Cen_reason_nodrink_5 R_Cen_reason_nodrink_6
label var R_Cen_reason_nodrink_5 "Don't have a JJM tap connection"
label define R_Cen_reason_nodrink_5 1 "Yes" 0 "No"
label values R_Cen_reason_nodrink_5 R_Cen_a18_reason_nodrink_5 

label var R_Cen_reason_nodrink_6 "Have other private drinking water source "
label define R_Cen_reason_nodrink_6 1 "Yes" 0 "No"
label values R_Cen_reason_nodrink_6 R_Cen_reason_nodrink_6 

label var R_Cen_reason_nodrink_7 "Water from Government provided household tap does not taste good"
label define R_Cen_reason_nodrink_7 1 "Yes" 0 "No"
label values R_Cen_reason_nodrink_7 R_Cen_reason_nodrink_7

label var R_E_reason_nodrink_7 "Water from Government provided household tap does not taste good"
label define R_E_reason_nodrink_7 1 "Yes" 0 "No"
label values R_E_reason_nodrink_7 R_E_reason_nodrink_7

label var R_Cen_water_source_sec_9 "Borewell operated by electric pump"
label define R_Cen_water_source_sec_9 1 "Yes" 0 "No"
label values R_Cen_water_source_sec_9 R_Cen_water_source_sec_9
 
label var R_E_tap_issues_type_6 "Supply related issues"
label define R_E_tap_issues_type_6 1 "Yes" 0 "No"
label values R_E_tap_issues_type_6 R_E_tap_issues_type_6

label var R_E_water_treat_type_5 "Clean the storage containers"
label define R_E_water_treat_type_5 1 "Yes" 0 "No"
label values R_E_water_treat_type_5 R_Cen_water_treat_type_5 

label var R_E_water_treat_type_6 "Cover the storage containers"
label define R_E_water_treat_type_6 1 "Yes" 0 "No"
label values R_E_water_treat_type_6 R_E_water_treat_type_6 

label var R_E_water_treat_kids_type_5 "Clean the storage containers"
label define R_E_water_treat_kids_type_5 1 "Yes" 0 "No"
label values R_E_water_treat_kids_type_5 R_E_water_treat_kids_type_5 

label var R_E_water_treat_kids_type_6 "Cover the storage containers"
label define R_E_water_treat_kids_type_6 1 "Yes" 0 "No"
label values R_E_water_treat_kids_type_6 R_E_water_treat_kids_type_6 

label var R_Cen_water_source_prim "Primary water source used by HH in past month"
label define R_Cen_water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (part of JJM taps)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel)" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
label values R_Cen_water_source_prim R_Cen_water_source_prim

label var R_E_water_source_prim "Primary water source used by HH in past month"
label define R_E_water_source_prim 1 "Government provided household Taps (supply paani)" 2 "Government provided community standpipe (part of JJM taps)" 3 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)" 4 "Manual handpump" 5 "Covered dug well" 6 "Uncovered dug well" 7 "Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel)" 8 "Private Surface well" 9 "Borewell operated by electric pump" 10 "Household tap connections not connected to RWSS/Basudha/JJM tank" -77 "Other"
label values R_E_water_source_prim R_E_water_source_prim

********************************************************************************
*** Creating a clean baseline census data for individual data processsing
********************************************************************************

preserve
drop R_E_*
save "${DataFinal}1_1_Baseline_Census_HH_clean_consented.dta", replace
restore

********************************************************************************
*** Creating a clean endline census data for individual data processsing
********************************************************************************

preserve
drop R_E_*
save "${DataFinal}1_10_Endline_Census_HH_clean_consented.dta", replace
restore

********************************************************************************
*** Dropping the variables
********************************************************************************

*** Dropping the PII (HHmember names and phone numbers)
drop R_Cen_a3_hhmember_name_7 R_Cen_a3_hhmember_name_8 R_Cen_a3_hhmember_name_9 R_Cen_a3_hhmember_name_6 R_Cen_a3_hhmember_name_5 R_Cen_a3_hhmember_name_4 R_Cen_a3_hhmember_name_10 R_Cen_a3_hhmember_name_11 R_Cen_a3_hhmember_name_17 R_Cen_a3_hhmember_name_16 R_Cen_a3_hhmember_name_12 R_Cen_a3_hhmember_name_3 R_Cen_a3_hhmember_name_2 R_Cen_a3_hhmember_name_15 R_Cen_a3_hhmember_name_13 R_Cen_a3_hhmember_name_1 R_Cen_a3_hhmember_name_14 R_Cen_a39_phone_name_2 R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_num_2 R_Cen_u5mother_name_9 R_Cen_u5mother_name_8 R_Cen_u5mother_name_4 R_Cen_u5mother_name_3 R_Cen_u5mother_name_15 R_Cen_u5mother_name_11 R_Cen_u5mother_name_12 R_Cen_u5mother_name_1 R_Cen_u5mother_name_7 R_Cen_u5mother_name_17 R_Cen_u5mother_name_14 R_Cen_u5mother_name_16 R_Cen_u5mother_name_2 R_Cen_u5mother_name_13 R_Cen_u5mother_name_5 R_Cen_u5mother_name_6 R_Cen_u5mother_name_10 R_E_cen_resp_name R_E_cen_resp_label R_E_cen_resp_name_oth R_Cen_namenumber_1 R_Cen_namefromearlier_1 R_Cen_namenumber_2 R_Cen_namefromearlier_2 R_Cen_namenumber_3 R_Cen_namefromearlier_3 R_Cen_namenumber_4 R_Cen_namefromearlier_4 R_Cen_namenumber_5 R_Cen_namefromearlier_5 R_E_comb_hhmember_name7 R_Cen_namefromearlier_5 R_E_comb_hhmember_name6 R_E_comb_hhmember_name5 R_E_comb_hhmember_name4 R_E_comb_hhmember_name3 R_E_comb_hhmember_name2 R_E_comb_hhmember_name1 R_Cen_namenumber_6 R_Cen_namefromearlier_6 R_Cen_namenumber_7 R_Cen_namefromearlier_7 R_Cen_namenumber_8 R_Cen_namefromearlier_8 R_Cen_namenumber_9 R_Cen_namefromearlier_9 R_Cen_namenumber_10 R_Cen_namefromearlier_10 R_Cen_namenumber_11 R_Cen_namefromearlier_11 R_Cen_namenumber_12 R_Cen_namefromearlier_12 R_Cen_namenumber_13 R_Cen_namefromearlier_13 R_Cen_namenumber_14 R_Cen_namefromearlier_14 R_Cen_namenumber_15 R_Cen_namefromearlier_15 R_Cen_namenumber_16 R_Cen_namefromearlier_16 R_Cen_namenumber_17 R_Cen_namefromearlier_17 R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_E_n_fam_name1 R_E_n_fam_name2 R_E_n_fam_name3 R_E_n_fam_name4 R_E_n_fam_name5 R_E_n_fam_name6 R_E_n_fam_name7 R_E_n_fam_name8 R_E_n_fam_name9 R_E_n_fam_name10 R_E_n_fam_name11 R_E_n_fam_name12 R_E_n_fam_name13 R_E_n_fam_name14 R_E_n_fam_name15 R_E_n_fam_name16 R_E_n_fam_name17 R_E_n_fam_name18 R_E_n_fam_name19 R_E_n_fam_name20 R_E_comb_child_caregiver_name1 R_E_comb_child_caregiver_name2 R_E_comb_child_caregiver_name3 R_E_comb_child_caregiver_name4 R_E_comb_child_caregiver_name5 R_Cen_a1_resp_name R_Cen_a11_oldmale_name R_Cen_address U5_Child_label* U5_caregiver_label* resident_bapujinagar

*** Dropping individual level variables 
drop  R_Cen_a21_wom_cuts_day_* R_Cen_a21_wom_cuts_week_* R_Cen_a21_wom_cuts_2week_* R_Cen_a22_wom_vomit_day_* R_Cen_a22_wom_vomit_week_* R_Cen_a22_wom_vomit_2week_* R_Cen_a23_wom_diarr_day_* R_Cen_a23_wom_diarr_week_* R_Cen_a23_wom_diarr_2week_* R_Cen_wom_diarr_num_week_* R_Cen_wom_diarr_num_2weeks_* R_Cen_a25_wom_stool_24h_* R_Cen_a25_wom_stool_yest_* R_Cen_a25_wom_stool_week_* R_Cen_a25_wom_stool_2week_* R_Cen_a26_wom_blood_day_* R_Cen_a27_child_cuts_day_* R_Cen_a27_child_cuts_week_* R_Cen_a27_child_cuts_2week_* R_Cen_a28_child_vomit_day_* R_Cen_a28_child_vomit_week_* R_Cen_a28_child_vomit_2week_* R_Cen_a29_child_diarr_day_* R_Cen_a29_child_diarr_week_* R_Cen_a29_child_diarr_2week_* R_Cen_child_diarr_week_num_*  R_Cen_child_diarr_2week_num_* R_Cen_a30_child_diarr_freq_* R_Cen_a31_child_stool_24h_* R_Cen_a31_child_stool_yest_* R_Cen_a31_child_stool_week_* R_Cen_a32_child_blood_day_* R_Cen_a32_child_blood_week_* R_Cen_child_caregiver_present_* R_Cen_child_breastfeeding_* R_Cen_child_breastfed_num_* R_Cen_a7_pregnant_* R_Cen_a7_pregnant_hh_* R_Cen_a7_pregnant_month_* R_Cen_a7_pregnant_leave_* R_Cen_a8_u5mother_* R_Cen_a9_school_* R_Cen_a9_school_level_* R_Cen_a9_school_current_* R_Cen_a9_read_write_* R_E_cen_med_seek_all_* R_E_setofn_med_seek_lp_all R_E_n_med_seek_lp_all_count R_E_n_med_seek_all_* R_E_n_med_seek_all R_Cen_a4_hhmember_gender_* R_E_comb_hhmember_gender* R_Cen_a5_hhmember_relation_* R_Cen_a6_hhmember_age_* R_E_cen_fam_age* R_E_cen_fam_gender* R_E_n_fam_age* R_Cen_a5_relation_oth_*  R_Cen_a5_autoage_* R_Cen_a6_u1age_* R_Cen_a6_age_confirm2_* R_Cen_correct_age_* R_Cen_unit_age_* R_Cen_a6_dob_* R_Cen_a26_wom_blood_week_* R_Cen_a26_wom_blood_2week_* R_Cen_a31_child_stool_2week_* R_Cen_a32_child_blood_2week_* R_Cen_child_index_* R_Cen_get_pregnant_status_* R_Cen_pregnant_index_* R_Cen_pregwoman_* R_Cen_hh_member_names_count R_E_comb_hhmember_age* R_E_comb_combchild_index* R_E_comb_combchild_status*  R_E_comb_child_care_pres* R_E_comb_child_care_pres_oth* R_E_comb_child_residence*  

*** Dropping temporary variables created for cleaning the datatset 
drop  R_E_num_treat_resp R_E_treat_resp_list_count R_E_setoftreat_resp_list R_E_treat_resp_labels  C_E_selected_index C_E_selected_index_treat C_Cen_U5child_* C_E_n_U5child_*    R_E_comb_preg_status* C_Cen_U5child_* C_E_n_U5child_* C_Cen_female_15to49_* C_E_n_female_15to49_* C_Cen_noncri_members_* C_E_n_noncri_members_* C_Cen_female_above12_* C_E_n_female_above12_* C_Cen_male_above12_* C_E_n_male_above12_*  total_U5_kids

*** Dropping other calculate field variables and ones not required for ananlysis 
drop R_Cen_primary_water_label R_E_secondary_water_label R_E_water_sec_labels R_E_people_prim_labels R_E_secondary_main_water_label water_sec_value1 water_sec_value2 R_E_num_people_prim 

drop R_Cen_landmark R_Cen_hh_code R_Cen_hh_repeat_code R_Cen_hh_code_format R_Cen_saahi_name R_Cen_hamlet_name R_Cen_gp_name R_Cen_district_name R_Cen_survey_duration R_Cen_devicephonenum R_Cen_simid R_Cen_subscriberid R_Cen_deviceid R_Cen_instruction R_Cen_enum_name_label R_Cen_no_consent_reason R_Cen_no_consent_reason_1 R_Cen_no_consent_reason_2 R_Cen_no_consent_reason__77 R_Cen_no_consent_comment R_Cen_no_consent_oth R_Cen_pregnant_followup_count R_Cen_child_followup_count R_Cen_get_u5_status_1 R_Cen_u5child_1 R_Cen_get_u5_status_2 R_Cen_u5child_2 R_Cen_get_u5_status_3 R_Cen_u5child_3 R_Cen_get_u5_status_4 R_Cen_u5child_4 R_Cen_get_u5_status_5 R_Cen_u5child_5 R_Cen_get_u5_status_6 R_Cen_u5child_6 R_Cen_get_u5_status_7 R_Cen_u5child_7 R_Cen_get_u5_status_8 R_Cen_u5child_8 R_Cen_u5child_9 R_Cen_get_u5_status_9 R_Cen_get_u5_status_10 R_Cen_u5child_10 R_Cen_get_u5_status_11 R_Cen_u5child_11 R_Cen_get_u5_status_12 R_Cen_u5child_12 R_Cen_get_u5_status_13 R_Cen_u5child_13 R_Cen_get_u5_status_14 R_Cen_u5child_14 R_Cen_get_u5_status_15 R_Cen_u5child_15 R_Cen_get_u5_status_16 R_Cen_u5child_16 R_Cen_get_u5_status_17 R_Cen_u5child_17 R_Cen_get_u5_status_18 R_Cen_u5child_18 R_Cen_labels R_Cen_survey_accompany_num R_Cen_survey_member_names_count R_Cen_surveynumber_1 R_Cen_survey_member_role_1 R_Cen_survey_member_gender_1 R_Cen_surveynumber_2 R_Cen_survey_member_role_2 R_Cen_survey_member_gender_2 R_Cen_surveynumber_3 R_Cen_survey_member_role_3 R_Cen_survey_member_gender_3 R_Cen_isvalidated R_Cen_meta1instancename unique_id_new unique_id_hyphen  R_E_noteconf1  R_Cen_village_str R_E_village_name_str     End_date date_string date_only date_final


*** Dropping calculated variables for Endline and BAseline respondents (these variables do not include the revisit data points and new variables have been created that include both revisit and census observations and all manual corrections) and other variables created for revisit form and created to store merge results
drop  R_Cen_num_femaleabove12 R_Cen_num_adultsabove12 R_Cen_num_childbelow12 R_E_cen_num_female_15to49 R_E_cen_num_childbelow5 R_E_child_u5_list_preload R_E_cen_num_hhmembers R_E_cen_num_noncri R_E_info_update R_E_enum_name_label R_E_instruction R_E_instruction_oth R_E_no_consent_reason R_E_no_consent_reason_1 R_E_no_consent_reason_2 R_E_no_consent_reason__77 R_E_no_consent_comment R_E_no_consent_oth R_E_n_hhmember_count R_E_n_female_above12 R_E_n_num_femaleabove12 R_E_n_male_above12 R_E_n_num_maleabove12 R_E_n_adults_hh_above12 R_E_n_children_below12 R_E_n_num_adultsabove12 R_E_n_num_childbelow12 R_E_n_female_15to49 R_E_n_num_female_15to49 R_E_n_children_below5 R_E_n_num_childbelow5 R_E_n_allmembers_h R_E_n_num_allmembers_h R_E_water_sec_list_count R_E_num_water_sec R_E_setofwater_sec_list R_E_null_cen_num_female_15to49 R_E_null_n_num_female_15to49 R_E_cen_med_seek_all R_E_survey_member_names_count R_E_setofsurvey_member_names R_E_hh_avail1n_cbw_foll R_E_tar_resp_avail1n_cbw_foll R_E_n_cbw_foll1n_cbw_ind R_E_n_cbw_folloup2n_cbw_ind unique_id_Unique R_E_total_cbw_comb R_E_total_u5_child_comb X_merge merge_num_child merge_preg_status merge_newmem_gender HH_lock_IDs dup_HHID E_HH_not_available R_E_wash_applicable R_E_n_new_members R_E_n_new_members_verify


*** Renaming variables for consistency with FU rounds 
rename village village_id
rename Village village 
rename R_E_a40_gps_latitude R_E_gps_latitude
rename R_E_a40_gps_longitude R_E_gps_longitude
rename survey_issues C_survey_issues 

********************************************************************************
*** Saving the cleaned HH Level dataset
********************************************************************************
save "${DataFinal}0_Master_HHLevel.dta", replace


********************************************************************************
*** Merging Follow up survey data with Merged Baseline and Endline data
********************************************************************************
* To run the FU data creation do file, run the following code 
// do "${Do_pilot}3_X_FU_Data_Creation.do"
merge 1:1 unique_id using "${DataFinal}1_13_Followup_clean_wide.dta", gen (Merge_FU_Census)
//499 obs matched
save "${DataFinal}0_Master_HHLevel_FU_Census.dta", replace 
