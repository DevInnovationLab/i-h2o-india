W*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: ARCHI
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey


//////////////////////////////////////////////
////////////////////////////////////////////
do "${github}0_Preparation_V2.do"
do "${github}1_8_A_Endline_cleaning.do"
do "${github}1_8_A_Endline_cleaning_v2.do"

* CREATING PRELOAD FOR RE-VISIT (HH LEVEL)

br R_E_submissiondate

*Assigned to Archi- Drop duplicates: DONE 

bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
br unique_id R_E_key R_E_enum_name R_E_r_cen_a1_resp_name R_E_resp_available if dup_HHID > 0

* This is zero case
drop if R_E_resp_available == . 
// we will not re-visit those cases where HH has left permannetly 
br if unique_id == ""
// I am creating this as HH level preload so I am not exporting those cases where HH was available for survey 
tab R_E_resp_available
drop if R_E_resp_available == 1 | R_E_resp_available == 2

* HH unavailable for re-visits 

//checking unique ID is unique
isid unique_id

//merging it with the main census file 
keep unique_id R_E_enum_name_label

save "${DataPre}Endline_HH_level_revisit_merge.dta", replace


cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
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

merge 1:1 unique_id using "${DataPre}Endline_HH_level_revisit_merge.dta", keep(3)

export excel using "${DataPre}Endline_Revisit_Preload_U5_Child_level.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 

tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_E_enum_name_label "Endline_Enum_name"
	label variable R_Cen_a1_resp_name "Baseline Respondent name"
	
	
* Akito to Archi: Just add description of how this data is used.
*Archi- This data is used to assign HH IDs to enums. Supervisors assign this data before starting the survey  
sort R_Cen_village_str R_E_enum_name_label  
export excel ID R_E_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 

//////////////////////////////////////////////
////////////////////////////////////////////

* CREATING PRELOAD FOR RE-VISIT (MAIN RESPONDENT LEVEL)
use "${DataPre}1_8_Endline_XXX.dta", clear

* We are selecting the case where houehold was visited (R_E_resp_available), BUT the main respondent was not found
keep if R_E_resp_available == 1
tab R_E_instruction
replace R_E_instruction = 6 if R_E_instruction == 7
//removuing cases where main resp survey has been done already or where main resp has permanently left
keep if R_E_instruction != 1 & R_E_instruction != 2

isid unique_id

//merging it with the main census file 
keep unique_id R_E_enum_name_label

save "${DataPre}Endline_Main_Resp_level_revisit_merge.dta", replace

clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
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


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////
merge 1:1 unique_id using "${DataPre}Endline_Main_Resp_level_revisit_merge.dta", keep(3)

gen WASH_applicable = 1

//preload for main resp
export excel unique_id R_E_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name WASH_applicable using "${DataPre}Endline_Revisit_Preload_Main_resp_level.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 


//Supervisor tracking sheet
tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_E_enum_name_label "Endline_Enum_name"
	label variable R_Cen_a1_resp_name "Baseline Respondent name"
	
sort R_Cen_village_str R_E_enum_name_label  
export excel ID R_E_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_Main_resp_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


//////////////////////////////////////////////
////////////////////////////////////////////


/***************************************************************
	INDIVIDUAL LEVEL DATASETS 
****************************************************************/


*CREATING PRELOAD FOR RE-VISIT (U5 LEVEL)
use "${DataTemp}U5_Child_23_24_part1.dta", clear
tab comb_child_caregiver_present
drop if comb_child_comb_name_label == ""

label define comb_child_caregiver_present_x 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "U5 died or is no longer a member of the household" 8 "U5 child no longer falls in the criteria (less than 5 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_child_caregiver_present comb_child_caregiver_present_x

list if comb_child_comb_name_label == ""

//Archi - why the check below is really important? 
//Archi - It ensures that if at all there are any missing values in comb_child_caregiver_present it is not because question was not mandatory or got skipped or child was elgible but then also questions were not asked. You will also notice that missing values in comb_child_caregiver_present are present only at those places where comb_combchild_status is 0 because before running the loop for new child section in this variable  N_u5child_status ensures that loop is run only for eligible new children i.e. any non U5 children is not aske dthis questions so if status is 0 that means that new person was not eleihible for U5 questions as a resyult there is a missing value 
br if comb_child_caregiver_present == . & comb_combchild_status != "0"
//Archi- there are 0 value sin the command above so we are safe to go

//dropping cases where survey was done already conducted, U5 child has permanently left or value is missing
drop if comb_child_caregiver_present == 2 | comb_child_caregiver_present == 1 | comb_child_caregiver_present == -77 | comb_child_caregiver_present == 7 | comb_child_caregiver_present == 8 | comb_child_caregiver_present == .

duplicates list unique_id
*isid unique_id

* Akito to Archi: This data is already wide for me: Why are we making this reshaped? It seems you have 2nd child (Is this because you have more updated data?)
*Archi to Akito: This  is not wide. Discuss more with Akito
bys unique_id: gen Num=_n
//these are the required vars for preload 
keep comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label unique_id Num R_E_enum_name_label

//reshaping 
reshape wide comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label, i(unique_id) j(Num)

duplicates list unique_id

//I wish to merge this with baseline census dataset to get additional identifiers 
save "${DataPre}Endline_U5_level_revisit_merge.dta", replace

//importing baseline data 
clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace


// keeing only screend cases  
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 

///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////

//merging with U5 wide dataset created 
merge 1:1 unique_id using "${DataPre}Endline_U5_level_revisit_merge.dta", keep(3)

keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_E_enum_name_label R_Cen_enum_code R_Cen_landmark R_Cen_address R_Cen_enum_name_label  R_Cen_a1_resp_name R_Cen_a11_oldmale R_Cen_a11_oldmale_name R_Cen_a10_hhhead R_Cen_a10_hhhead_gender comb_combchild_index* comb_combchild_status* comb_child_comb_name_label* comb_child_caregiver_present* comb_child_care_pres_oth* comb_child_caregiver_name* comb_child_residence* comb_child_comb_caregiver_label* 

//check for duplicates: Akito to Archi: Can we simply use this command? "isid unique_id" Yes
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0

//finding some total values 
egen temp_group = group(unique_id) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen
ds comb_child_comb_name_label*
foreach var of varlist `r(varlist)'{
replace `var' = "" if `var' == "999"
replace `var' = "" if `var' == "-98"
}

ds comb_child_comb_name_label*
foreach var of varlist `r(varlist)'{
gen num_`var' = 1 if `var' != ""
}

forvalues i = 1/6{
cap rename num_comb_child_comb_name_label`i' num_child_comb`i'
}


egen total_U5_Child_comb = rowtotal(num_child_comb*)
drop temp_group

//merging it with endline XXX data to check if missing values in child availability is coming only because that HH was locked 
preserve
use "${DataPre}1_8_Endline_XXX.dta", clear

*Assigned to Archi- Drop duplicates: DONE 

bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
br unique_id R_E_key R_E_enum_name R_E_r_cen_a1_resp_name R_E_resp_available if dup_HHID > 0

keep unique_id R_E_resp_available R_E_instruction

save "${DataTemp}Endline_XXX_data_for_merge.dta", replace 

restore

merge 1:1 unique_id using "${DataTemp}Endline_XXX_data_for_merge.dta"

keep if _merge == 3
drop _merge

//creating preload
export excel using "${DataPre}Endline_Revisit_Preload_U5_Child_level.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 

//supervisor tracking sheet
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3


//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_E_enum_name_label "Endline_Enum_name"
	label variable R_Cen_a1_resp_name "Baseline Respondent name"

sort R_Cen_village_str  
//add enum names of endline enums 

//AG: Now it is not showing any values in label 2 ? How come? (investigate more)

export excel ID R_E_enum_name_label R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_address R_Cen_a10_hhhead R_Cen_a10_hhhead_gender R_Cen_a11_oldmale_name comb_child_comb_name_label1 comb_child_comb_caregiver_label1 comb_child_residence1 comb_child_comb_name_label2 comb_child_comb_caregiver_label2 comb_child_residence2   using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_U5_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


/***************************************************************

*CREATING PRELOAD FOR RE-VISIT (Child bearing women LEVEL)

***************************************************************/

/////////////////////////////////////////////////
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear

tab comb_resp_avail_comb
tab comb_resp_avail_comb,m
label define comb_resp_avail_comb_ex 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "Respondent died or is no longer a member of the HH" 8 "Respondent no longer falls in the criteria (15-49 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_resp_avail_comb comb_resp_avail_comb_ex

//droppinh cases that won't be re-visited 
* Akito to Archi: Most of the case is missing. Can you describe what those are? They are simply data from non-main respondent?

tab comb_resp_avail_comb
drop if comb_resp_avail_comb == . | comb_resp_avail_comb == 2 | comb_resp_avail_comb == 1 | comb_resp_avail_comb == 7 | comb_resp_avail_comb == 8 | comb_resp_avail_comb == -98 | comb_resp_avail_comb == 9 | comb_resp_avail_comb == -77 

bys unique_id: gen Num=_n
duplicates list unique_id

drop if comb_name_comb_woman_earlier == ""

//keeping only relevant vars 
keep comb_resp_avail_comb comb_resp_avail_comb_oth comb_name_comb_woman_earlier unique_id Num R_E_enum_name_label

reshape wide comb_resp_avail_comb comb_resp_avail_comb_oth comb_name_comb_woman_earlier, i(unique_id) j(Num)

duplicates list unique_id

//creating a dataset to be merged with baselin ecnsus one 
save "${DataPre}Endline_CBW_level_revisit_merge.dta", replace

//importing baseline census data 
clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

//keeping only screend cases 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 


///////////////////////////////////////////////////////////////
/***************************************************************
PERFORMING THE MAIN MERGE WITH THE ENDLINE DATASET FOR HH LEVEL IDs
****************************************************************/
////////////////////////////////////////////////////////////////

merge 1:1 unique_id using "${DataPre}Endline_CBW_level_revisit_merge.dta", keep(3)

keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_enum_name R_Cen_enum_code R_Cen_landmark R_Cen_address R_E_enum_name_label R_Cen_a1_resp_name R_Cen_a11_oldmale R_Cen_a11_oldmale_name R_Cen_a10_hhhead R_Cen_a10_hhhead_gender comb_resp_avail_comb* comb_resp_avail_comb_oth* comb_name_comb_woman_earlier* 

* Akito to Archi: Can we simply replace the following code to "isid unique_id"?
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0


//finding some total values 
egen temp_group = group(unique_id) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen
ds comb_name_comb_woman_earlier*
foreach var of varlist `r(varlist)'{
replace `var' = "" if `var' == "999"
replace `var' = "" if `var' == "-98"
}

forvalues i = 1/4{
cap rename comb_name_comb_woman_earlier`i' comb_name_CBW`i'
}

ds comb_name_CBW*
foreach var of varlist `r(varlist)'{
gen num_`var' = 1 if `var' != ""
}



egen total_CBW_comb = rowtotal(num_comb_name_CBW*)
drop temp_group


//creating preload
export excel using "${DataPre}Endline_Revisit_Preload_CBW_level.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 

//supervisor tracking sheet
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_E_enum_name_label "Endline_Enum_name"

sort R_Cen_village_str 


//add enum names of endline enums 

export excel ID R_E_enum_name_label R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_address R_Cen_a10_hhhead R_Cen_a10_hhhead_gender R_Cen_a11_oldmale_name comb_name_CBW1 comb_resp_avail_comb1 comb_name_CBW2 comb_resp_avail_comb2 comb_name_CBW3 comb_resp_avail_comb3 comb_name_CBW4 comb_resp_avail_comb4  using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_CBW_level.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 

/***************************************************************
//comining all the preloads 
*****************************************************************/

//main resp preload 
import excel "${DataPre}Endline_Revisit_Preload_Main_resp_level.xlsx", sheet("Sheet1") firstrow clear
keep unique_id R_E_enum_name_label R_Cen_a1_resp_name WASH_applicable R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark
isid unique_id
list if R_E_enum_name_label == ""
list if unique_id == ""
save "${DataPre}stata_Endline_revisit_main_resp.dta", replace

//U5 preload
import excel "${DataPre}Endline_Revisit_Preload_U5_Child_level.xlsx", sheet("Sheet1") firstrow clear
keep unique_id R_E_enum_name_label comb_child_comb_name_label* comb_child_caregiver_present* comb_child_caregiver_name* comb_child_residence* comb_child_comb_caregiver_label* total_U5_Child_comb R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark
isid unique_id
list if R_E_enum_name_label == ""
save "${DataPre}stata_Endline_revisit_U5_child.dta", replace


//CBW preload 
import excel "${DataPre}Endline_Revisit_Preload_CBW_level.xlsx", sheet("Sheet1") firstrow clear
isid unique_id
list if R_E_enum_name_label == ""

merge 1:1 unique_id  using "${DataPre}stata_Endline_revisit_U5_child.dta"
gen match_CBW_U5_child = ""
replace match_CBW_U5_child = "CBW and U5" if _merge == 3
replace match_CBW_U5_child = "only U5" if _merge == 2
replace match_CBW_U5_child = "only CBW" if _merge == 1
*drop _merge
rename _merge CBW_U5_merge
merge 1:1 unique_id using "${DataPre}stata_Endline_revisit_main_resp.dta"
gen match_CBW_main = ""
replace match_CBW_main = "CBW and Main" if _merge == 3
replace match_CBW_main = "Only main" if _merge == 2
replace match_CBW_main = "Only CBW" if _merge == 1
rename _merge CBW_Main_merge


*** merge type 1
replace match_CBW_main = "CBW and U5" if match_CBW_U5_child == "CBW and U5" & CBW_Main_merge == 1
replace match_CBW_main = "Only U5" if match_CBW_U5_child == "only U5" & CBW_Main_merge == 1
replace match_CBW_main = "Only CBW" if match_CBW_U5_child == "only CBW" & CBW_Main_merge == 1

***merge type 3 
replace match_CBW_main = "CBW U5 Main" if match_CBW_U5_child == "CBW and U5" & CBW_Main_merge == 3
replace match_CBW_main = "CBW Main" if match_CBW_U5_child == "only CBW" & CBW_Main_merge == 3
replace match_CBW_main = "U5 Main" if match_CBW_U5_child == "only U5" & CBW_Main_merge == 3



keep unique_id R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_E_enum_name_label R_Cen_a1_resp_name comb_name_CBW* comb_name_CBW* comb_name_CBW* total_CBW_comb comb_child_comb_name_label* total_U5_Child_comb WASH_applicable match_CBW_U5_child match_CBW_main

forvalues i= 1/5{
cap rename comb_name_CBW`i' Woman_name`i'
}

forvalues i= 1/4{
cap rename comb_child_comb_name_label`i' Child_name`i'
}

gen Do_child_section = ""
gen Do_woman_section = ""
gen Do_main_resp_section = ""

replace Do_child_section = "Yes" if match_CBW_U5_child == "CBW and U5" | match_CBW_U5_child == "only U5" | match_CBW_main == "CBW and U5" | match_CBW_main == "Only U5" | match_CBW_main == "U5 Main"

replace Do_child_section = "No" if Do_child_section == ""

replace Do_woman_section = "Yes" if match_CBW_U5_child == "CBW and U5" | match_CBW_U5_child == "Only CBW" | match_CBW_main == "CBW and U5" | match_CBW_main == "Only CBW" | match_CBW_main == "CBW Main"

replace Do_woman_section = "No" if Do_woman_section == ""

replace Do_main_resp_section = "Yes" if  match_CBW_main == "Only main" | match_CBW_main == "CBW Main" | match_CBW_main == "U5 Main"

replace Do_main_resp_section = "No" if Do_main_resp_section == ""

//supervisor tracking sheet
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_E_enum_name_label "Endline_Enum_name"
    label variable total_U5_Child_comb "Total U5 child for revisit"
	    label variable total_CBW_comb "Total CBW women for revisit"
	    label variable R_Cen_a1_resp_name "Baseline resp name"


sort R_Cen_village_str 



isid  unique_id

preserve
use "${DataPre}1_8_Endline_XXX.dta", clear
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
br if dup_HHID > 0
isid unique_id

* This is zero case
drop if R_E_resp_available == . 
keep unique_id R_E_enum_name_label R_E_cen_resp_label
save "${DataPre}stata_Endline_revisit_main_filtered.dta", replace
restore

merge 1:1 unique_id using "${DataPre}stata_Endline_revisit_main_filtered.dta"

keep if _merge == 3

label variable R_E_cen_resp_label "Endline resp name"

label variable Woman_name1 "Woman_name1"
label variable Woman_name2 "Woman_name2"
label variable Woman_name3 "Woman_name3"
label variable Woman_name4 "Woman_name4"
label variable total_CBW_comb  "Total CBW re-visit"
label variable Child_name1  "Child_name1"
label variable Child_name2  "Child_name2"
label variable total_U5_Child_comb  "Total U5 re-visit"


export excel ID R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark  R_Cen_a1_resp_name R_E_cen_resp_label R_E_enum_name_label Woman_name1 Woman_name2 Woman_name3 Woman_name4 total_CBW_comb Child_name1 Child_name2 total_U5_Child_comb Do_child_section Do_woman_section Do_main_resp_section match_CBW_U5_child WASH_applicable match_CBW_main using "${DataPre}Endline_Revisit_common_IDs.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 

isid unique_id

/***************************************************************


Finding out if any IDs got left from being surveyed because of the change in the preload 

****************************************************************/


import excel "${DataTemp}SDWCH End-line Survey details productivity Tracker(Supervisiors).xlsx", sheet("Team-1 (Jitan Mallik)") firstrow clear

keep UniqueID

drop if UniqueID == ""

rename UniqueID unique_id

isid unique_id

save "${DataTemp}excel_Endline_JPAL_sheet1.dta", replace


import excel "${DataTemp}SDWCH End-line Survey details productivity Tracker(Supervisiors).xlsx", sheet("Team - 2(Sadananda)") firstrow clear

keep UniqueID

drop if UniqueID == ""

rename UniqueID unique_id

isid unique_id

save "${DataTemp}excel_Endline_JPAL_sheet2.dta", replace


import excel "${DataTemp}SDWCH End-line Survey details productivity Tracker(Supervisiors).xlsx", sheet("Team -3 (Nityananda)") firstrow clear

keep UniqueID

drop if UniqueID == ""

rename UniqueID unique_id

isid unique_id

save "${DataTemp}excel_Endline_JPAL_sheet3.dta", replace


import excel "${DataTemp}SDWCH End-line Survey details productivity Tracker(Supervisiors).xlsx", sheet("Team -4 (Rajib)") firstrow clear


keep UniqueID

drop if UniqueID == ""

rename UniqueID unique_id

isid unique_id

save "${DataTemp}excel_Endline_JPAL_sheet4.dta", replace

append using "${DataTemp}excel_Endline_JPAL_sheet1.dta"
append using "${DataTemp}excel_Endline_JPAL_sheet2.dta"
append using "${DataTemp}excel_Endline_JPAL_sheet3.dta"
isid unique_id

rename unique_id unique_id_hyphen
save "${DataTemp}Endline_JPAL_tracker_all_IDs.dta", replace


//importing baseline census data 
clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

//keeping only screend cases 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 

keep unique_id unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_a1_resp_name

merge 1:1 unique_id_hyphen using "${DataTemp}Endline_JPAL_tracker_all_IDs.dta"


//Changing labels 
	label variable unique_id_hyphen "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	label variable R_Cen_a1_resp_name "Baseline Respondent name"
	
	
sort R_Cen_village_str  
export excel unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx" if _merge == 1, sheet("remaining IDs", replace) firstrow(varlabels) cell(A1) 


/*******************************************************************

PRELOAD FOR NEW MEMBERS TO BE DISPLAYED AS A DROPDOWN

*********************************************************************/

//The dataset below has infor for all new members from endline census

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


use "${DataTemp}Requested_long_backcheck1.dta", clear

rename key R_E_key

//merging it with endline census dataset 
*merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code) keep(3) nogen

//to continue
merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code) keep(3) nogen


drop if comb_name_comb_woman_earlier == ""
drop if comb_resp_avail_comb == .

//firstly the preload for only  child bearing women 

keep comb_name_comb_woman_earlier unique_id comb_hhmember_age


//we have to make sure that women that have prefix 111- in their names are not repeated in the preload list because their names are alreday in census list 
split comb_name_comb_woman_earlier, generate(common_cbw_names) parse("111")
replace comb_name_comb_woman_earlier = common_cbw_names2 if common_cbw_names2 != ""

drop common_cbw_names1 
drop common_cbw_names2

drop if comb_name_comb_woman_earlier == ""

drop if unique_id == ""

bys unique_id: gen Num=_n
duplicates list unique_id

reshape wide comb_name_comb_woman_earlier comb_hhmember_age, i(unique_id) j(Num)

isid  unique_id

export excel using "${DataPre}Endline_Revisit_new_CBW.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 


/********************************************************

exporting all the new fam names 

********************************************************/
use "${DataTemp}Requested_long_backcheck1.dta", clear

rename key R_E_key

//merging it with endline census dataset 

merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code) keep(3) nogen

//firstly the preload for all members 
drop if comb_hhmember_name == ""

keep comb_hhmember_name comb_hhmember_gender comb_hhmember_age unique_id 


//we have to make sure that women that have prefix 111- in their names are not repeated in the preload list because their names are alreday in census list 
split comb_hhmember_name, generate(common_names) parse("111")
replace comb_hhmember_name = common_names2 if common_names2 != ""

drop common_names1 
drop common_names2

drop if comb_hhmember_name == ""

drop if unique_id == ""

bys unique_id: gen Num=_n
duplicates list unique_id

reshape wide comb_hhmember_name comb_hhmember_gender comb_hhmember_age, i(unique_id) j(Num)

duplicates list unique_id

export excel using "${DataPre}Endline_Revisit_all_new_members.xlsx" , sheet("Sheet1", replace) firstrow(variables) cell(A1) 




/***************************************************************
WHY IDs submitted are less than preload IDs - ask prasant ji
****************************************************************/

use "${DataPre}1_8_Endline_XXX.dta", clear
keep unique_id
save "${DataTemp}1_8_Endline_full_data_merge.dta", replace

//importing baseline census data 
clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

//keeping only screend cases 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 

keep unique_id unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_a1_resp_name


merge 1:1 unique_id using "${DataTemp}1_8_Endline_full_data_merge.dta"


//Changing labels 
	label variable unique_id_hyphen "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	label variable R_Cen_a1_resp_name "Baseline Respondent name"
	
	
sort R_Cen_village_str  
export excel unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx" if _merge == 1, sheet("IDs with no subimssions", replace) firstrow(varlabels) cell(A1) 



/***************************************************************CHECKING IF ALL IDs are there which JPAL tracker has
***************************************************************/


import excel "${DataTemp}SDWCH End-line Survey details productivity Tracker(Supervisiors).xlsx", sheet("Supervisor_Endline_House lock_T") firstrow clear

keep UniqueID

drop if UniqueID == ""

isid UniqueID

save "${DataTemp}excel_Endline_JPAL_revisit_IDs.dta", replace

import excel "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx", sheet("Sheet1") firstrow clear

merge 1:1 UniqueID using "${DataTemp}excel_Endline_JPAL_revisit_IDs.dta"

	
export excel UniqueID Endline_Enum_name Blockname VillageName Hamletname Saahiname Landmark BaselineRespondentname _merge using "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx" if _merge != 3, sheet("IDs no match jpal", replace) firstrow(varlabels) cell(A1) 


/***************************************************************COMPARING OLD VERSION OF COMMON IDs sheet with new one 
***************************************************************/

import excel "${DataTemp}Endline_Revisit_common_IDs_old_version.xlsx", sheet("Sheet1") firstrow clear

keep UniqueID 
*Woman_name1 Woman_name2 Woman_name3 Woman_name4 TotalCBWrevisit Child_name1 TotalU5revisit
save "${DataTemp}stata_endline_common_IDs_old_version.dta", replace


import excel "${DataPre}Endline_Revisit_common_IDs.xlsx", sheet("Sheet1") firstrow clear

merge 1:1 UniqueID using "${DataTemp}stata_endline_common_IDs_old_version.dta"

isid UniqueID


gen match = ""

replace match = "matched" if _merge == 3
replace match = "new ID" if _merge == 1

save "${DataTemp}stata_endline_common_IDs_old_new_match.dta", replace


/***************************************************************COMPARING women and children that have happened because of old version of common IDs 
***************************************************************/


import excel "${DataTemp}Endline_Revisit_common_IDs_old_version.xlsx", sheet("Sheet1") firstrow clear

ds `r(varlist)'
foreach var of varlist `r(varlist)'{
rename `var' O_`var'
}

rename O_UniqueID  UniqueID 
save "${DataTemp}stata_endline_common_IDs_old_version.dta", replace


import excel "${DataPre}Endline_Revisit_common_IDs.xlsx", sheet("Sheet1") firstrow clear

merge 1:1 UniqueID using "${DataTemp}stata_endline_common_IDs_old_version.dta"


gen mismatch_CBW  = 1 if O_TotalCBWrevisit != TotalCBWrevisit

gen mismatch_U5  = 1 if O_TotalU5revisit != TotalU5revisit

gen mismatch_Main = 1 if WASH_applicable !=  O_WASH_applicable

gen match = ""
replace match = "matched" if _merge == 3
replace match = "new ID" if _merge == 1


forvalues i = 1/2{
cap gen mismatch_U5_`i' = 1 if Child_name`i' != O_Child_name`i'
}
br Child_name1 Child_name2 TotalU5revisit O_Child_name1  O_TotalU5revisit mismatch_U5 mismatch_U5_1 if mismatch_U5 == 1

//there is no mismatch in women dataset 
forvalues i = 1/4{
 gen mismatch_CBW_`i' = 1 if O_Woman_name`i' != Woman_name`i'
}

isid UniqueID

rename O_Child_name1 Old_Child_name1
rename O_TotalU5revisit Old_total_U5_revisit

//Changing labels 
	label variable UniqueID "Unique ID"
	label variable VillageName "Village Name"
	label variable Blockname "Block name"
	label variable Hamletname "Hamlet name"
	label variable Saahiname "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable Baselinerespname "Baseline Respondent name"
	label variable Endlinerespname "Baseline Respondent name"
	label variable match "match_ID"
	label variable Old_Child_name1 "Old child name"
	label variable Old_total_U5_revisit "old total U5 revisit"

	
sort VillageName 

export excel UniqueID Blockname VillageName Hamletname Saahiname R_Cen_landmark Baselinerespname Endlinerespname Endline_Enum_name Woman_name1 Woman_name2 Woman_name3 Woman_name4 TotalCBWrevisit Child_name1 Child_name2 TotalU5revisit Do_child_section Do_woman_section Do_main_resp_section match_CBW_U5_child WASH_applicable match_CBW_main Old_Child_name1 Old_total_U5_revisit mismatch_U5 match using "${DataPre}Endline_Revisit_common_IDs_new_version.xlsx", sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


/***************************************************************COMPARING new and old HH lock tracking sheet
***************************************************************/

import excel "${DataTemp}Supervisor_Endline_Revisit_Tracker_checking_HH_level_old_ver.xlsx", sheet("Sheet1") firstrow clear

keep UniqueID

save "${DataTemp}stata_endline_HH_lock_old_match.dta", replace

import excel "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx", sheet("Sheet1") firstrow clear

merge 1:1 UniqueID using "${DataTemp}stata_endline_HH_lock_old_match.dta"







/***************************************************************MATCHING WOMEN  AND U5 FROM BASELINE CENSUS TO SEE HOW MANY ARE DONE 
***************************************************************/

import excel "${DataPre}Endline_census_eligiblewomen_preload.xlsx", sheet("Sheet1") firstrow clear


drop R_Cen_a7_pregnant_*
ds `r(varlist)' 
foreach var of varlist `r(varlist)'{
tostring `var', replace
}



//reshape long R_Cen_eligible_women_pre_, i(unique_id) j(Women)

//sort R_Cen_eligible_women_pre_

save "${DataTemp}reshaped_long_baseline_CBW.dta", replace


use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear

tab comb_resp_avail_comb
tab comb_resp_avail_comb,m
label define comb_resp_avail_comb_ex 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "Respondent died or is no longer a member of the HH" 8 "Respondent no longer falls in the criteria (15-49 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_resp_avail_comb comb_resp_avail_comb_ex

//droppinh cases that won't be re-visited 
* Akito to Archi: Most of the case is missing. Can you describe what those are? They are simply data from non-main respondent?

tab comb_resp_avail_comb


keep unique_id comb_name_comb_woman_earlier comb_name_comb_preg comb_resp_avail_comb comb_resp_avail_comb_oth comb_preg_index comb_cen_women_status

bys unique_id: gen Num=_n

reshape wide comb_name_comb_woman_earlier comb_name_comb_preg comb_resp_avail_comb comb_resp_avail_comb_oth comb_preg_index comb_cen_women_status, i(unique_id) j(Num)

merge m:m unique_id using "${DataTemp}reshaped_long_baseline_CBW.dta"


/***************************************************************MERGING SUBMITTED ENDLINE DATA TO SEE IF ANY FORMS HAVE BEEN LEFT FROM GETTING SUBMITTED
***************************************************************/

use "${DataPre}1_8_Endline_XXX.dta", clear

isid unique_id

save "${DataTemp}1_8_Endline_XXX_for_merge.dta", replace


clear
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use  "${DataPre}1_1_Census_cleaned.dta", clear
drop if R_Cen_village_str  == "Badaalubadi" | R_Cen_village_str  == "Hatikhamba"
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim Treat_V)
recode Merge_C_F 1=0 3=1

*drop if  R_Cen_village_name==30501

label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"

end


//Remove HHIDs with differences between census and HH survey
start_from_clean_file_Population
//why do we drop this?
*drop if unique_id=="40201113010" | unique_id=="50401105039" | unique_id=="50402106019" | unique_id=="50402106007"

tempfile new
save `new', replace

//keeping only screend cases 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 

keep unique_id unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_a1_resp_name

merge 1:1 unique_id using "${DataTemp}1_8_Endline_XXX_for_merge.dta", keepusing(unique_id)


br unique_id unique_id_hyphen R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_a1_resp_name if _merge != 3


/***************************************************************MERGING SUBMITTED ENDLINE HH LOCK DATA WITH PRELOAD FOR HH LOCK CASES
***************************************************************/

use "${DataPre}1_8_Endline_XXX.dta", clear

isid unique_id

keep unique_id R_E_resp_available R_E_enum_name_label

gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

rename ID UniqueID

save "${DataTemp}1_8_Endline_XXX_for_merge.dta", replace


import excel "${pilot}Supervisor_Endline_Revisit_Tracker_checking_HH_level.xlsx", sheet("Sheet1") firstrow clear


merge 1:1 UniqueID using "C:\Users\Archi Gupta\Box\Data\99_temp\1_8_Endline_XXX_for_merge.dta"


/***************************************************************MERGING SUBMITTED ENDLINE REVISIT DATA WITH PRELOAD TO SEE HOW MANY ENTRIES HAVE COME 
***************************************************************/
clear
set maxvar 30000

import delimited "${DataRaw}Endline Census Re-visit_WIDE.csv", bindquote(strict) clear

