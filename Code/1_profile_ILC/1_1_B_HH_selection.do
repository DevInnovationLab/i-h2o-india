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
    local Village_R 88888
    keep if village==`Village_R'	

keep village unique_id R_Cen_a18_jjm_drinking
* Keep only the village where you want to conduct the randomization
global Var_Select S_BLS S_BLWQ 

* Conduct randomization
foreach i in $Var_Select {
	gen `i'=. 
	gen `i'_random=runiform(0,1)	
}

* Household selection, all the HH consented are
keep if R_Cen_a18_jjm_drinking==1 // They drink water from the JJM tap

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
gen     ID_BLWQ=_n
replace S_BLWQ=1 if ID_BLWQ<=4
replace S_BLWQ=0 if S_BLWQ==.
recode S_BLS 0=0 1=2 2=1

save "${DataPre}Selected_`Village_R'_$S_DATE.dta", replace



*******************************************************
* Step 3: Carefully integrate back to the master list *
*******************************************************
* You need to understand each line to work on this do file
* Only the village where we complete the randomization should be included in the merge list

use   "${DataPre}1_1_Census_cleaned_consented.dta", clear
* Merge_WS==1 means they do not drink water from the JJM tap
merge 1:1 unique_id using "${DataPre}Selected_88888_26 Sep 2023.dta", keep(master matched) gen(Merge_WS)


label define S_BLWQl 0 "No" 1 "Water sample", modify
label values S_BLWQ S_BLWQl

rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}

***********************************************************************
* Step 4: Creating the data for pre-load
***********************************************************************
decode village, gen(R_Cen_village_name_str)
Adding_Ram

export excel unique_id $Var_Select R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_a11_oldmale_name using "${DataPre}Followup_preload.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)
drop if unique_id==99999999999

***********************************************************************
* Step 5: Data to be uploaded for google sheet
***********************************************************************
gen Date_Random="$S_DATE"
format   unique_id %15.0gc
tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3
export excel ID Block R_Cen_village_name_str R_Cen_hamlet_name Date_Random S_BLWQ Pointgeolocationlat1 Pointgeolocationlon1 using "${pilot}Supervisor_HH_Tracker_Baseline.xlsx" if S_BLS==1, sheet("Sheet1", replace) firstrow(var) cell(A1) keepcellfmt

*------------------------------------------------------------------- Follow up -------------------------------------------------------------------*
/*
Enumerator to confirm the remaining 
Enumerator: District Name
Enumerator: Block Name
Enumerator: Gram Panchayat Name
Enumerator: Village Name
"Enumerator to fill up : Hamlet Name 
If unknown, please enter 999"
*/

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
