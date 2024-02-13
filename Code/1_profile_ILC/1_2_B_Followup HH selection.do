*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: Michelle (DIL)
****** Used by:  DIL
****** Date created: 31 Jan 2024 
****** Date revised: -- 
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
**# Bookmark #1
replace R_Cen_a39_phone_num_2="1234567890" in `observation'
replace R_Cen_hamlet_name="Bollywood"  in `observation'
replace S_BLS=1  in `observation'
replace S_BLWQ=1  in `observation'
 
end
*****************************************
* Step 1: Cleaning and sample selection *
*****************************************
use "${DataPre}1_1_Census_cleaned_consented.dta", clear
//1. Put the village code of the village for randomization. Use villages one by one

levelsof R_Cen_village_name
foreach value in `r(levels)' {

preserve
    *local Village_R 
    keep if R_Cen_village_name==`value'	
	
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


	save "${DataPre}Selected_`value'_31 Jan 2024.dta", replace





*******************************************************
* Step 3: Carefully integrate back to the master list *
*******************************************************
* Only the village where we complete the randomization should be included in the merge list
use "${DataPre}Selected_`value'_31 Jan 2024.dta", clear
*append using "${DataPre}Selected_30501_20 Oct 2023.dta"
*append using "${DataPre}Selected_30202_20 Oct 2023.dta"
save "${DataPre}Selected_HHs_HH survey_water_testing_R1.dta", replace


use   "${DataPre}1_1_Census_cleaned_consented.dta", clear
* Merge_WS==1 means they do not drink water from the JJM tap
merge 1:1 unique_id using "${DataPre}Selected_HHs_HH survey_water_testing_R1.dta", keep(master matched) gen(Merge_WS)

label define S_BLWQl 1 "Water sample : Yes" 2 "Water sample : Yes" 3 "Water sample : Yes" 4 "Water sample : Yes" 5 "Water sample : Yes" 6 "Water sample backup: 1" 7 "Water sample backup: 2" 8 "Water sample backup: 3" 9 "Water sample backup: 4" 10 "Water sample backup: 5" 20 "Replacement HH" 0 "No visit" , modify
label values S_BLWQ S_BLWQl


* Drop households not using JJM for drinking
drop if Merge_WS==1
* Dropping househods not selected for the revisit
drop if S_BLWQ==0 
decode R_Cen_village_name, gen(R_Cen_village_name_str)
replace R_Cen_village_name_str= R_Cen_village_str if R_Cen_village_name_str==""




levelsof R_Cen_village_str
local vill `r(levels)'


***********************************************************************
* Step 4: Data to be uploaded for google sheet
***********************************************************************
gen Date_Random="$S_DATE"
tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3
gen Enumerator_Assigned= ""
replace R_Cen_village_name_str= R_Cen_village_str if R_Cen_village_name_str==""

//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_name_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_time_availability "Respondent time availability"
	label variable Enumerator_Assigned "Enumerator Assigned"
	label variable S_BLWQ "Water Sample collection"




sort R_Cen_village_name_str S_BLWQ
export excel ID R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_time_availability Enumerator_Assigned S_BLWQ  using "${pilot}Supervisor_HH_Tracker_Baseline_`vill'_31 Jan 2024.xlsx" if S_BLS==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

sort R_Cen_village_name_str S_BLWQ
export excel ID R_Cen_block_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_time_availability Enumerator_Assigned S_BLWQ  using "${pilot}Supervisor_HH_Tracker_Baseline_`vill'_31 Jan 2024_Replacement list.xlsx" if S_BLS==2, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) keepcellfmt

restore

}


***********************************************************************
* Step 5: Creating the data for pre-load
***********************************************************************

local mylist 10101 10201 20201 30202 30301 30501 30601 30602 30701 ///
 40101 40201 40202 40301 40401 50101 50201 50301 50401 50402 50501 50601

foreach i of local mylist {
	
use "${DataPre}Selected_`i'_31 Jan 2024.dta", clear

tempfile vill_`i'
save `vill_`i'', replace

use   "${DataPre}1_1_Census_cleaned_consented.dta", clear
merge 1:1 unique_id using `vill_`i'', keep(master matched) gen(Merge_WS)

drop if Merge_WS==1

save `vill_`i'', replace

}

local mylist2 10101 10201 20201 30202 30301 30501 30601 30602 ///
 30701 40101 40201 40202 40301 40401 50101 50201 50301 50401 50402 50501 
 
 use `vill_50601', clear
foreach j of local mylist2 {
	
	append using `vill_`j''
	
}

* Drop households not using JJM for drinking
drop if Merge_WS==1
* Dropping househods not selected for the revisit
drop if S_BLWQ==0 


//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/17 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}



//renaming vars

	forvalues i = 1/17 {
		rename R_Cen_a4_hhmember_gender_`i' Cen_fam_gender`i'
		
	}

	forvalues i = 1/17 {
		rename R_Cen_a6_hhmember_age_`i' Cen_fam_age`i'
		
	}
	
	
	

sort  S_BLS S_BLWQ
export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 Cen_fam_gender1 Cen_fam_age1 Cen_fam_gender2 Cen_fam_age2 Cen_fam_gender3 Cen_fam_age3 Cen_fam_gender4 Cen_fam_age4 Cen_fam_gender5 Cen_fam_age5 Cen_fam_gender6 Cen_fam_age6 Cen_fam_gender7 Cen_fam_age7 Cen_fam_gender8 Cen_fam_age8 Cen_fam_gender9 Cen_fam_age9 Cen_fam_gender10 Cen_fam_age10 Cen_fam_gender11 Cen_fam_age11 Cen_fam_gender12 Cen_fam_age12 Cen_fam_gender13 Cen_fam_age13 Cen_fam_gender14 Cen_fam_age14 Cen_fam_gender15 Cen_fam_age15 Cen_fam_gender16 Cen_fam_age16 Cen_fam_gender17 Cen_fam_age17 R_Cen_enum_name_label R_Cen_enum_code using "${DataPre}Followup_preload_31 Jan 2024.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)

export excel unique_id R_Cen_a12_water_source_prim R_Cen_a13_water_sec_yn R_Cen_a13_water_source_sec R_Cen_a18_jjm_drinking using "${DataPre}Followup_watersource_31 Jan 2024.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)

