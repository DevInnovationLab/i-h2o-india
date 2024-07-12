clear
set seed 758235657 // Just in case

//Doing key creation for main endline census datasets. Here M_key_creation refers to the main endline datasets key creation
cap program drop M_key_creation
program define   M_key_creation

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

//Doing key creation for revisit endline census datasets

cap program drop RV_key_creation
program define   RV_key_creation

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



/***************************************************************
CHILD LEVEL DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
****************************************************************/

//this is the revisit endline long child level dataset. This dataset is created in the file - 1_9_A_Endline_revisit_cleaning_HFC_Data_creation  
use "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_part1.dta", clear

//we must rename these variables because these variables are present in the main endline census child level dataset too so we need these 2 variables for verification and compariosn  
rename comb_child_comb_caregiver_label Vcomb_child_comb_caregiver_label 

rename comb_child_caregiver_present Vcomb_child_caregiver_present

cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", replace

//this is the main endline long child level dataset. This dataset is created in the file "1_8_A_Endline_cleaning_HFC_Data creation.do"
use "${DataTemp}U5_Child_23_24_part1.dta", clear
drop if comb_child_comb_name_label == ""
cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


//merging the main child level dataset with the endline level child dataset on UID and child name. I am retaining some of the variables from using dataset for comparison which I will explain later 
merge 1:1 unique_id comb_child_comb_name_label using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", keepusing(unique_id comb_child_comb_name_label Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present  ) 

/*
.........................................................
Objective of the exercise below: 
.........................................................
Instead of doing the replacement of the rows from the revisit data with the main dataset we are dropping the rows from the main dataset where that specific children was unavailable earlier but was revisited in the revisit round and was surveyed so can append that data from the revisit dataset to the main dataset and remove the entry for this specific child from the main census dataset to avoid having duplicates 

Here the _merge == 3 entry of the matched entry indicates that this entry is also available in the using dataset but this is not enough to help us in deciding whether we want to drop this row or not from the main endline datatset that is why we use another variable called  Vcomb_child_caregiver_present that will tell us whether this survey was actually completed in the revisit or not. If Vcomb_child_caregiver_present is qual to 1 then that means that child became available later so we can add this data that was available to our main dataset and drop the unavailable child entry from the main dataset 

*/


br unique_id comb_combchild_index comb_combchild_status comb_child_comb_name_label comb_child_caregiver_present comb_child_comb_caregiver_label Vcomb_child_caregiver_present Vcomb_child_comb_caregiver_label _merge if _merge == 3 & Vcomb_child_caregiver_present == 1

//whatever entries have the value 1 here that entry needs to be dropped from the main child dataset as we will add rows for such children from the revisit dataset to create a complete datatset 
gen to_drop = .

replace to_drop = 1  if Vcomb_child_caregiver_present == 1 & _merge == 3


drop if to_drop == 1

//we are importing endline child level dataset again to now prepare it for the actual append with the main child dataset so we would need to retain the keys of using child revisit dataset and give it diff prefix so here I am giving the prefix Revisit to the keys to differnetiate from the main endline census keys 
preserve
use "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_part1.dta", clear
drop if comb_child_comb_name_label == ""
keep if comb_child_caregiver_present == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}
save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta", replace
restore

append using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta"

//checking for duplicates UID and child name wise. It is imp that there are no duplicates. This shows the append was succseful 
cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID



br unique_id comb_child_comb_name_label comb_main_caregiver_label comb_child_caregiver_present comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_month comb_child_breastfed_days comb_child_care_dia_day if unique_id == "30301109053"

save "${DataFinal}Endline_Child_level_merged_dataset_final.dta", replace 


/*****************************************************************
ROSTER MEMBERS DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
*****************************************************************/


//this is the main endline long new roster member dataset. This dataset is created in the file "1_8_A_Endline_cleaning_HFC_Data creation.do"

* ID 26 (N=322) All new household members in the main endline census 

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
M_key_creation 
drop if n_hhmember_name == ""
keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name ///
      key key3 n_hhmember_name n_u5mother_name_oth n_u5father_name_oth n_relation_oth ///
	  n_dob_date n_dob_month n_dob_year ///
	  n_cbw_age n_all_age 
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) 

//there are around 16 keys that don't match with cleaned endline census data and that is because these are practise entries observations from endline census so in the long dataset unless we manually drop it it would still be present so we should just keep _mereg == 3
keep if _merge == 3
drop _merge
save "${DataTemp}temp2.dta", replace

save "${DataFinal}Endline_New_member_roster_dataset_final.dta", replace 

********************************************************************************************************************************

//PERFORMING THE DROP AND MERGE HERE  FOR ID 25

//this is the main endline long new roster member dataset. This dataset is created in the file "1_8_A_Endline_cleaning_HFC_Data creation.do"

* ID 25
//census roster in the main endline census dataset 
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
M_key_creation 

drop if name_from_earlier_hh == ""
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id)

//296 entries that are just in master are all the practise entreis 
keep if _merge == 3
drop _merge 
save "${DataTemp}temp0.dta", replace


//////////////////////////////////////////////////
/*

OBJECTIVE: 
There was no new entry for a roster member in the revisit survey that is why we don't need to use that dataset in merge. 
For ID 25 part 2, Endline revisit data is available so we would neeed to perform the drop and merge here.
Drop here means we would have to drop those rows from the main endline long roster dataset where respondent was unavailable here and data couldn't be collcted so we need to add rows in replacement for this from revisit endline roster level dataset 

This dataset is created in the "GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2_revisit.do"
*/
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.dta", clear
RV_key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
gen comb_type = 0

rename key R_E_key
//firstly merging it with endline HH level dataset to get which HH were done

merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_instruction) keep(3) nogen 

rename R_E_instruction V_R_E_instruction
save "${DataTemp}temp3_merged.dta",  replace



//we need to merge main endline census roster dataset with the using main endline census roster dataset to create a combined main endline roster and after that is done only then we can merge it with revisit dataset 

/*
Archi to Akito- 
Ok so I think we should not be merging main endline census roster with new memeber roster because the variables are different altogethre that is we aren't even asking the same information. So, it is advisable to keep new member roster as different dataset altogether
*/

//using census roster here 
use "${DataTemp}temp0.dta", clear

/////////////////////////////

//importing temp3 which endline revisit census roster dataset here to create a combined census level dataset
preserve
cap drop _merge
merge m:m unique_id using "${DataTemp}temp3_merged.dta", keepusing(unique_id V_R_E_instruction   ) 
//ther merge above tells us that there are no common UIDs between the two which is okay because temp0 dataset has all the available UIDS data and temp3_merged has the data for unavailable UIDs that were re-visited later 
restore
preserve
use "${DataTemp}temp3_merged.dta", clear

keep if V_R_E_instruction == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

 
save "${DataTemp}temp3_merged_final.dta", replace
restore

//we can do a simple append here because the var names are the same 
append using "${DataTemp}temp3_merged_final.dta"


save "${Datatemp}Endline_Main_revisit_Census_roster_merge.dta", replace 

save "${DataFinal}Endline_census_roster_merged_dataset_final.dta", replace 


/*****************************************************************
WOMEN LEVEL DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
*****************************************************************/

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
M_key_creation 

foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
drop if  comb_name_comb_woman_earlier == ""
	 
rename key R_E_key	 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen

cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

//here we find that on UID - 30202109013  there are two women with the same name that is "Pinky Khandagiri" but they are different people so we have to rename one women so in this case I am renaming unmarried Pinky Khandagrii by adding a suffix underscore in her name 

replace comb_name_comb_woman_earlier = "Pinky Kandagari_" if  unique_id == "30202109013" & comb_preg_hus == "444" & comb_name_comb_woman_earlier == "Pinky Kandagari" 
	 
save "${DataTemp}temp1.dta", replace


 //using new women data from main endline census 
 
 * ID 22
//new women
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
M_key_creation
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
	 
rename key R_E_key	 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id) keep(3) nogen
	 
 save "${DataTemp}temp2.dta", replace

use "${DataTemp}temp1.dta", clear
append using "${DataTemp}temp2.dta"
unique R_E_key key3
unique unique_id comb_name_comb_woman_earlier

cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

save "${DataTemp}temp3.dta", replace

 
 //women data from endline revisit survey 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_CBW_followup.dta", clear
RV_key_creation

foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
	 
drop if comb_name_comb_woman_earlier == ""
 gen comb_type = 1
 
 rename key R_E_key
 merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_village_name_str) keep(3) nogen
 
 unique unique_id comb_name_comb_woman_earlier
 
 cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID



 save "${DataTemp}temp_women_revisit.dta", replace
 


/*************************************************************
DOING THE MERGE WITH CENSUS WOMEN
*************************************************************/


use "${DataTemp}temp_women_revisit.dta", clear
drop if  comb_name_comb_woman_earlier == ""
rename comb_resp_avail_comb Vcomb_resp_avail_comb

save "${DataTemp}temp_women_revisit_part1.dta", replace

//importing combined women data from endline main census 
use "${DataTemp}temp3.dta", clear
cap drop _merge
merge 1:1 unique_id comb_name_comb_woman_earlier using "${DataTemp}temp_women_revisit_part1.dta", keepusing(unique_id Vcomb_resp_avail_comb) 


br unique_id comb_preg_index comb_name_comb_woman_earlier comb_resp_avail_comb Vcomb_resp_avail_comb _merge if _merge == 3 & Vcomb_resp_avail_comb == 1

gen to_drop = .
replace to_drop = 1 if _merge == 3 & Vcomb_resp_avail_comb == 1

drop if to_drop == 1

preserve
use "${DataTemp}temp_women_revisit.dta", clear


keep if comb_resp_avail_comb == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}
 
save "${DataTemp}temp_women_revisit_part3.dta", replace
restore

append using "${DataTemp}temp_women_revisit_part3.dta"
drop _merge

 cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


save "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", replace 
 
 
 
 //common IDs
import excel "${DataTemp}JPAL HH level tracker for Endline Census.xlsx", sheet("Main_Updated_endline_revisit_co") firstrow clear

drop if UniqueID == ""
isid UniqueID

save "${DataTemp}Temp_R0.dta", replace

//HH lock IDs 
import excel "${DataTemp}JPAL HH level tracker for Endline Census.xlsx", sheet("Main_Supervisor_Endline_House l") firstrow clear

drop if UniqueID == ""

isid UniqueID

save "${DataTemp}Temp_R1.dta", replace




 //importing HH level data
 
 clear
 
 set maxvar 20000
 
use "${DataFinal}Endline_HH_level_merged_dataset_final.dta", clear
 
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3

rename ID UniqueID

destring R_E_day, replace
destring R_E_month_num , replace
destring R_E_yr_num, replace
drop End_date 
gen End_date = mdy(R_E_month_num, R_E_day, R_E_yr_num)


merge 1:1 UniqueID using "${DataTemp}Temp_R0.dta", keepusing(UniqueID Do_child_section Do_woman_section Do_main_resp_section match_CBW_U5_child WASH_applicable match_CBW_main)

rename _merge common_IDs

//105 common IDs were revisited 

merge 1:1 UniqueID using "${DataTemp}Temp_R1.dta", keepusing( UniqueID)

rename _merge HH_lock


cap drop _merge

merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_temp\Temp_R3.dta", keepusing(instruction resp_available comb_resp_avail_cbw_1 comb_resp_avail_cbw_2 comb_resp_avail_cbw_3 comb_resp_avail_cbw_4 comb_child_caregiver_present_1 comb_child_caregiver_present_2)


//RV represents here the revisit HH 
rename  instruction RV_instruction
rename resp_available RV_resp_available
rename comb_resp_avail_cbw_1 RV_comb_resp_avail_cbw_1
rename comb_resp_avail_cbw_2 RV_comb_resp_avail_cbw_2
rename comb_resp_avail_cbw_3 RV_comb_resp_avail_cbw_3
rename comb_resp_avail_cbw_4 RV_comb_resp_avail_cbw_4
rename comb_child_caregiver_present_1 RV_comb_child_caregiver_pre_1
rename comb_child_caregiver_present_2 RV_comb_child_caregiver_pre_2

//status of HH lock Ids 
preserve
keep if HH_lock == 3
tab R_E_resp_available
restore

//status of main resp 
preserve
keep if WASH_applicable == 1
tab R_E_instruction
restore


/*
(HH revisited for child, women or main respondent survey) 
tab RV_resp_available 

Enumerator to record after knocking at	
the door of a house: Did you find a	
house	Freq.	Percent	Cum.
			
Household available for an interview an	101	96.19	96.19
This is my 2nd re-visit: The revisit wi	2	1.90	98.10
This is my 2nd re-visit: The family is	2	1.90	100.00
			
Total	105	100.00*/

****************************************************************

/*tab RV_instruction

(Out of 105, 7 HH were re-visited for main resp survey 

Instructions for Enumerator to identify	
the primary respondent: 1. The	
primary/t	Freq.	Percent	Cum.
			
Respondent available for an interview	7	100.00	100.00
			
Total	7	100.00*/

****************************************************************



/*

ID WISE DISTRIBUTION OF RE-VISITS 


Out of 105 IDs, 93 HH were visited for Child bearing women 
Out of 105, 53 HH were visited for U5 child 
Out of 105, 7 were re-visited for main resp 

tab RV_comb_resp_avail_cbw_1



C2) Did you find	
${comb_name_CBW_woman_earlier} to	
interview?	Freq.	Percent	Cum.
			
Refused to answer	2	2.20	2.20
Other, please specify	25	27.47	29.67
Respondent available for an interview	37	40.66	70.33
Respondent has left the house permanent	5	5.49	75.82
This is my 2rd re-visit (3rd visit): Th	7	7.69	83.52
This is my 2rd re-visit (3rd visit): Th	13	14.29	97.80
Respondent no longer falls in the crite	1	1.10	98.90
Respondent is a visitor and is not avai	1	1.10	100.00
			
Total	91	100.00

. tab RV_comb_resp_avail_cbw_2

comb_resp_a 
vail_CBW_2       Freq.     Percent	Cum.
	
98           1        4.76	4.76
77           4       19.05	23.81
1           7       33.33	57.14
2           1        4.76	61.90
5           3       14.29	76.19
6           3       14.29	90.48
9           2        9.52	100.00
	
Total          21      100.00

. tab RV_comb_resp_avail_cbw_3

comb_resp_a 
vail_CBW_3       Freq.     Percent	Cum.
	
1           2       66.67	66.67
5           1       33.33	100.00
	
Total           3      100.00

. tab RV_comb_resp_avail_cbw_4

comb_resp_a 
vail_CBW_4       Freq.     Percent	Cum.
	
77           1       50.00	50.00
1           1       50.00	100.00
	
Total           2      100.00

*/


use "${DataTemp}U5_Child_23_24_part1.dta", clear

rename unique_id  UniqueID

cap drop _merge 

merge m:1 UniqueID using "${DataTemp}Temp_R1.dta", keepusing( UniqueID)

rename _merge HH_lock
























***********************************************************


