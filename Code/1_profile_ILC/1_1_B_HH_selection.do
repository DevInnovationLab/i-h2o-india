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
*****************************************
* Step 1: Cleaning and sample selection *
*****************************************
use "${DataPre}1_1_Census_cleaned.dta", clear
    local Village_R 11321
    keep if R_Cen_village_name==`Village_R'	

keep R_Cen_village_name unique_id
* Keep only the village where you want to conduct the randomization
global Var_Select S_BLS S_BLWQ 

* Conduct randomization
foreach i in $Var_Select {
	gen `i'=. 
	gen `i'_random=runiform(0,1)	
}

*** Astha
* What kind of HH do we choose? 
* HH with small children: Which variable?
* HH who are using the JJM tap: Which variable?

***********************************************************************
* Step 2: Assign 1 for households selected based on random numbers *
***********************************************************************
* Baseline
local   BLS_num  1 // This has to be 10. Change once we have enough sample to run the code
local   BLWQ_num 1 // This has to be 4(?). Change once we have enough sample to run the code

sort      S_BLS_random
replace S_BLS=1 if [_n]<=`BLS_num' 
replace S_BLS=0 if [_n]>`BLS_num' 

* Sort among household visited 
gsort    -S_BLS S_BLWQ_random
replace S_BLWQ=1 if [_n]<=`BLWQ_num' 
replace S_BLS=0  if [_n]>`BLWQ_num' & S_BLS==1

save "${DataPre}Selected_`Village_R'_$S_DATE.dta", replace

***********************************************************************
* Step 3: Carefully integrate back to the master list 
* Only the village where we complete the randomization should be included in the merge list
***********************************************************************
use   "${DataPre}1_1_Census_cleaned.dta", clear
merge 1:1 unique_id using "${DataPre}Selected_11321_13 Sep 2023.dta", gen(Merge_Selection) keep(matched)

***********************************************************************
* Step 4: Creating the data for pre-load
***********************************************************************
decode R_Cen_village_name, gen(R_Cen_village_name_str)
gen Concat_info="You are in visiting the household of " + R_Cen_a1_resp_name +". The household is located in the " + R_Cen_village_name_str + "." 

keep unique_id $Var_Select Concat_info
export excel using "${pilot}Followup_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)

*------------------------------------------------------------------- Follow up -------------------------------------------------------------------*


/*
END
global Var_Select S_F1S S_F1Q S_F2S S_F2Q S_F3S S_F3Q

* Follow up 1-3
foreach i in 1 2 3 {
local   S_F`i'S_num 1 // This has to be 4?
local   S_F`i'Q_num 1 // This has to be 4(?). Change once we have enough sample to run the code

sort    S_F`i'S_random
replace S_F`i'S=1 if [_n]<=`S_F`i'S_num 1' 
replace S_F`i'S=0 if [_n]> `S_F`i'S_num 1' 

* Sort among household visited 
gsort  -S_F`i'S S_F`i'Q_random
replace S_F`i'Q=1 if [_n]<=`S_F`i'Q_num' 
replace S_F`i'Q=0 if [_n]> `S_F`i'Q_num' & S_F`i'S==1
}
