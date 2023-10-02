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

/*------ In this do file: 
	(1) This do file exports the list of hosuehold selected for the follow-up survey. The first part of the do file do random selection of baseline survey
	(2) To avoid running the randomization code multiple times, you will choose the village to be randomized at the first line of this do file. 
	(3) Once you run the randomization, you will "merge" the informtion of selected household into the master census list       ------ */

*------------------------------------------------------------------- Baseline -------------------------------------------------------------------*
set seed 75823

cap program drop Adding_Ram
program define   Adding_Ram

count
local observation = `r(N)'+1
set obs `observation'
replace unique_id=99999999999 in `observation'
replace R_Cen_a10_hhhead="Ram Charan" in `observation'
replace R_Cen_a1_resp_name="Alia Bhat" in `observation'
replace R_Cen_village_name_str="Bombay" in `observation'
replace R_Cen_address="111 Hollywood Ave" in `observation'
replace R_Cen_landmark="In front of actor school" in `observation'
replace R_Cen_a39_phone_name_1="Rajamouli" in `observation'
replace R_Cen_a39_phone_num_1="1234567890" in `observation'
replace R_Cen_a39_phone_name_2="Rama Rao" in `observation'
replace R_Cen_a39_phone_num_2="1234567890" in `observation'
replace R_Cen_hamlet_name="Bollywood"  in `observation'
replace S_BLS=1  in `observation'
replace S_BLWQ=1  in `observation'
 
end
*****************************************
* Step 1: Cleaning and sample selection *
*****************************************
use "${DataPre}1_1_Census_cleaned_consented.dta", clear
//1. Put the village code of the village for randomization
    local Village_R 50301 
    keep if R_Cen_village_name==`Village_R'	

keep R_Cen_village_name unique_id R_Cen_a18_jjm_drinking R_Cen_hamlet_name
* Keep only the village where you want to conduct the randomization
global Var_Select S_BLS S_BLWQ 

* Conduct randomization
gen S_BLS=.
foreach i in $Var_Select {
	gen `i'_random=runiform(0,1)	
}

* Household selection, all the HH consented are
keep if R_Cen_a18_jjm_drinking==1 // They drink water from the JJM tap
//Removing hamlets which have other tap schemes ongoing besides JJM
gen ineligible= strpos(R_Cen_hamlet_name, "Babu") | strpos(R_Cen_hamlet_name, "Bapu") | strpos(R_Cen_hamlet_name, "bapu")
keep if ineligible==0


***********************************************************************
* Step 2: Assign 1 for households selected based on random numbers *
***********************************************************************
* HH to be visited
sort    S_BLS_random
gen     ID_BLS=_n
replace S_BLS=2 if ID_BLS<=10
replace S_BLS=1 if 10<ID_BLS & ID_BLS<=15
replace S_BLS=0 if S_BLS==.
drop ID_BLS

* Sort among primary household
gsort    -S_BLS S_BLWQ_random
gen     S_BLWQ=_n
recode  S_BLWQ 11/15=20 16/99999=0
replace S_BLS=S_BLWQ
recode  S_BLS 1/10=1 20=2 0=0

label define S_BLSl 1 "Primary" 2 "Replacement" 0 "No visit", modify
label values S_BLS S_BLSl


save "${DataPre}Selected_`Village_R'_$S_DATE.dta", replace

*******************************************************
* Step 3: Carefully integrate back to the master list *
*******************************************************
* Only the village where we complete the randomization should be included in the merge list
use "${DataPre}Selected_50301_ 2 Oct 2023.dta", clear
*append using "${DataPre}Selected_40201_30 Sep 2023.dta"
save "${DataPre}Selected_HHs_HH survey_water_testing_R1.dta", replace


use   "${DataPre}1_1_Census_cleaned_consented.dta", clear
* Merge_WS==1 means they do not drink water from the JJM tap
merge 1:1 unique_id using "${DataPre}Selected_HHs_HH survey_water_testing_R1.dta", keep(master matched) gen(Merge_WS)

label define S_BLWQl 1 "Water sample : Yes" 2 "Water sample : Yes" 3 "Water sample : Yes" 4 "Water sample : Yes" 5 "Water sample backup: 1" 6 "Water sample backup: 2" 7 "Water sample backup: 3" 8 "Water sample backup: 4" 9 "Water sample backup: 5" 10 "Water sample backup: 6" 20 "Replacement HH" 0 "No visit" , modify
label values S_BLWQ S_BLWQl


//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}

***********************************************************************
* Step 4: Creating the data for pre-load
***********************************************************************
* Drop households not using JJM for drinking
drop if Merge_WS==1
* Dropping househods not selected for the revisit
drop if S_BLWQ==0 
decode R_Cen_village_name, gen(R_Cen_village_name_str)

* Adding_Ram
* Add Sahi later
sort  S_BLS S_BLWQ
export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name using "${DataPre}Followup_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)
* drop if unique_id==99999999999 (Drop if Ram: Commenting out since we do not want Ram in the actaul data collection)

***********************************************************************
* Step 5: Data to be uploaded for google sheet
***********************************************************************
gen Date_Random="$S_DATE"
tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3
gen Enumerator_Assigned= ""

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_time_availability "Respondent time availability"
	label variable Enumerator_Assigned "Enumerator Assigned"
	label variable S_BLWQ "Water Sample collection"




sort R_Cen_village_name_str S_BLWQ
export excel ID R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_time_availability Enumerator_Assigned S_BLWQ  using "${pilot}Supervisor_HH_Tracker_Baseline_2 Oct 2023.xlsx" if S_BLS==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

sort R_Cen_village_name_str S_BLWQ
export excel ID R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_time_availability Date_Random Enumerator_Assigned S_BLWQ  using "${pilot}Supervisor_HH_Tracker_Baseline_2 Oct 2023_Replacement list.xlsx" if S_BLS==2, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt
