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
 
 
 STOP 
 ////////////////////////
 
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

format %td End_date

//merging with common IDs to get how many IDs were given for revisit for common IDs
merge 1:1 UniqueID using "${DataTemp}Temp_R0.dta", keepusing(UniqueID Do_child_section Do_woman_section Do_main_resp_section match_CBW_U5_child WASH_applicable match_CBW_main)

rename _merge common_IDs


//merging with HH lock IDs 
merge 1:1 UniqueID using "${DataTemp}Temp_R1.dta", keepusing( UniqueID)

isid  unique_id

drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  


//rename _merge HH_lock

gen HH_revisit_for_lock = .
replace HH_revisit_for_lock = 1 if _merge == 3
replace HH_revisit_for_lock = 0 if _merge == 1


//recoding instruction variable 
clonevar R_E_C_instruction = R_E_instruction

//this was a non consnet case so I recoded it as a refused case 
replace R_E_C_instruction = "-98" if unique_id == "10101113002" & R_E_key == "uuid:15a2cff6-4db0-4d6b-80bc-f09e35fb0eaa" & R_E_instruction == "1"


cap drop _merge


*.........................................................
//IMP VARIABLES FOR TABULATION
*...........................................................

//Archi to Akito: To find out the consented main respondents plz tab this 
tab R_E_C_instruction

//to find the available HH plz tab this 
tab R_E_resp_available


//TReatment and control wise consented main respondents 
gen R_E_C_instruction_TvsC = .
bysort Treat_V: replace R_E_C_instruction_TvsC = 1 if R_E_C_instruction == "1"
tab Treat_V R_E_C_instruction_TvsC



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





















************************************************************


***********************************************************

clear all               
set seed 758235657 // Just in case


use "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", clear
 
 keep  unique_id  instruction_oth  r_cen_a1_resp_name r_cen_a10_hhhead   r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2  r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name     r_cen_fam_name*  cen_fam_age* cen_fam_gender* r_cen_a12_water_source_prim  cen_num_hhmembers cen_num_noncri r_cen_noncri_elig_list village_name_res noteconf1 info_update enum_name enum_code enum_name_label resp_available instruction consent_duration consent intro_dur_end no_consent_reason no_consent_reason_1 no_consent_reason_2 no_consent_reason__77 no_consent_oth no_consent_comment audio_consent audio_audit cen_resp_name cen_resp_label cen_resp_name_oth roster_duration   n_new_members n_new_members_verify n_hhmember_count   roster_end_duration n_fam_name* n_fam_age*  n_female_above12 n_num_femaleabove12 n_male_above12 n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12 n_num_childbelow12 n_female_15to49 n_num_female_15to49 n_children_below5 n_num_childbelow5 n_allmembers_h n_num_allmembers_h wash_duration water_source_prim water_prim_oth  water_sec_yn water_source_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count setofwater_sec_list water_sec_labels water_source_main_sec secondary_main_water_label quant sec_source_reason sec_source_reason_1 sec_source_reason_2 sec_source_reason_3 sec_source_reason_4 sec_source_reason_5 sec_source_reason_6 sec_source_reason_7 sec_source_reason__77 sec_source_reason_999 sec_source_reason_oth water_sec_freq water_sec_freq_oth collect_resp  people_prim_water num_people_prim people_prim_list_count setofpeople_prim_list people_prim_labels  prim_collect_resp where_prim_locate where_prim_locate_enum_obs collect_time collect_prim_freq water_treat water_stored water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_oth water_treat_freq water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 treat_freq_oth not_treat_tim treat_resp  num_treat_resp treat_resp_list_count setoftreat_resp_list treat_resp_labels treat_primresp treat_time treat_freq collect_treat_difficult clean_freq_containers clean_time_containers water_source_kids water_prim_source_kids water_prim_kids_oth water_source_preg water_prim_source_preg water_prim_preg_oth water_treat_kids water_treat_kids_type water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999 water_treat_kids_oth treat_kids_freq treat_kids_freq_1 treat_kids_freq_2 treat_kids_freq_3 treat_kids_freq_4 treat_kids_freq_5 treat_kids_freq_6 treat_kids_freq__77 treat_kids_freq_oth jjm_drinking tap_supply_freq tap_supply_freq_oth tap_supply_daily reason_nodrink reason_nodrink_1 reason_nodrink_2 reason_nodrink_3 reason_nodrink_4 reason_nodrink_999 reason_nodrink__77 nodrink_water_treat_oth jjm_stored jjm_yes jjm_use jjm_use_1 jjm_use_2 jjm_use_3 jjm_use_4 jjm_use_5 jjm_use_6 jjm_use_7 jjm_use__77 jjm_use_999 jjm_use_oth tap_function tap_function_reason tap_function_reason_1 tap_function_reason_2 tap_function_reason_3 tap_function_reason_4 tap_function_reason_5 tap_function_reason_999 tap_function_reason__77 tap_function_oth tap_issues tap_issues_type tap_issues_type_1 tap_issues_type_2 tap_issues_type_3 tap_issues_type_4 tap_issues_type_5 tap_issues_type__77 tap_issues_type_oth healthcare_duration n_med_seek_all n_med_seek_all_1 n_med_seek_all_2 n_med_seek_all_3 n_med_seek_all_4 n_med_seek_all_5 n_med_seek_all_6 n_med_seek_all_7 n_med_seek_all_8 n_med_seek_all_9 n_med_seek_all_10 n_med_seek_all_11 n_med_seek_all_12 n_med_seek_all_13 n_med_seek_all_14 n_med_seek_all_15 n_med_seek_all_16 n_med_seek_all_17 n_med_seek_all_18 n_med_seek_all_19 n_med_seek_all_20 n_med_seek_all_21 n_med_seek_lp_all_count setofn_med_seek_lp_all cen_med_seek_all cen_med_seek_all_1 cen_med_seek_all_2 cen_med_seek_all_3 cen_med_seek_all_4 cen_med_seek_all_5 cen_med_seek_all_6 cen_med_seek_all_7 cen_med_seek_all_8 cen_med_seek_all_9 cen_med_seek_all_10 cen_med_seek_all_11 cen_med_seek_all_12 cen_med_seek_all_13 cen_med_seek_all_14 cen_med_seek_all_15 cen_med_seek_all_16 cen_med_seek_all_17 cen_med_seek_all_18 cen_med_seek_all_19 cen_med_seek_all_20 cen_med_seek_all_21   resp_health_duration    resp_health_new_duration    child_census_duration   child_new_duration   sectiong_dur_end survey_end_duration visit_num e_surveys_revisit a40_gps_manuallatitude a40_gps_manuallongitude a40_gps_manualaltitude a40_gps_manualaccuracy a40_gps_handlongitude a40_gps_handlatitude a41_end_comments a42_survey_accompany_num survey_member_names_count cen_num_childbelow5 setofsurvey_member_names instancename formdef_version key submissiondate starttime endtime 
 * Some variable names are too long, shortening them to be able to add a R_E prefix later





 

*drop consented1child_followup5child_h
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_`x'
}



* This variable has to be named consistently across data set
rename R_E_unique_id unique_id
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	gen R_E_day = day(dofc(R_E_starttime))
	gen R_E_month_num = month(dofc(R_E_starttime))
	gen R_E_yr_num = year(dofc(R_E_starttime))
    gen End_date = mdy(R_E_month_num, R_E_day, R_E_yr_num)

	
	generate C_starthour = hh(R_E_starttime) 
	gen C_startmin= mm(R_E_starttime)
	cap gen diff_minutes = clockdiff(R_E_starttime, R_E_endtime, "minute")
    
//just a check to see if only valid dates are being dropped 
	
	
	* First, convert the numeric date to a string format
gen date_string = string(R_E_starttime, "%tc")

* Then, extract only the date part from the string
gen date_only = substr(date_string, 1, 9)

* Now, format the date_only variable as a date
gen date_final = date(date_only, "DMY")

format date_final %td

drop if date_final < mdy(4,21,2024)

* Optionally, drop the intermediate variables if not needed

    drop if End_date < mdy(4,21,2024)
	format End_date  %d



/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

//1. dropping irrelevant entries , Archi to replace with == "Badaalubadi"
count if R_E_r_cen_village_name_str=="88888"
tab R_E_day if R_E_r_cen_village_name_str=="88888"
drop if  R_E_r_cen_village_name_str=="88888"

//2. dropping duplicate case based on field team feedback, in case of any incorrect entry, enter the exact key
*drop if R_E_key== " "

*Note: also resolve duplicates here 



//3. Cleaning the GPS data 
// Keeping the most reliable entry of GPS

* Manual
foreach i in R_E_a40_gps_handlatitude R_E_a40_gps_handlongitude   {
	replace `i'=. if R_E_a40_gps_handlatitude>25  | R_E_a40_gps_handlatitude<15
    replace `i'=. if R_E_a40_gps_handlongitude>85 | R_E_a40_gps_handlongitude<80
}

* Auto
foreach i in R_E_a40_gps_manuallatitude R_E_a40_gps_manuallongitude  R_E_a40_gps_manualaccuracy {
	replace `i'=. if R_E_a40_gps_manuallatitude>25  | R_E_a40_gps_manuallatitude<15
    replace `i'=. if R_E_a40_gps_manuallongitude>85 | R_E_a40_gps_manuallongitude<80
}

* Final GPS
foreach i in latitude longitude {
	gen     R_E_a40_gps_`i'=R_E_a40_gps_manual`i'
	replace R_E_a40_gps_`i'=R_E_a40_gps_hand`i' if R_E_a40_gps_`i'==.
	* Add manual
	drop R_E_a40_gps_manual`i' R_E_a40_gps_hand`i'
}
* Reconsider puting back back but with less confusing variable name
drop R_E_a40_gps_manualaltitude  R_E_a40_gps_manualaccuracy    


//4. Capturing correct section-wise duration

*drop R_E_consent_duration R_E_intro_duration R_E_sectionb_duration //old vars
*destring R_E_survey_duration R_E_intro_duR_E R_E_consent_duR_E R_E_sectionb_duR_E R_E_sectionc_duR_E ///
*R_E_sectiond_duR_E R_E_sectione_duR_E R_E_sectionf_duR_E R_E_sectiong_duR_E R_E_sectionh_duR_E, replace

*drop R_E_intro_duR_E R_E_consent_duR_E R_E_sectionb_duR_E R_E_sectionc_duR_E ///
*R_E_sectiond_duR_E R_E_sectione_duR_E R_E_sectionf_duR_E R_E_sectiong_duR_E R_E_sectionh_duR_E



/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}

tempfile working
save `working', replace

/**[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates

Respondent Names are recorded only after consent so they should be the same for one unique ID

There can be three types of cases:
1) Where ID is same and in one case respondent name is present but in others it is missing for the same day
2) Where ID is same and name is missing. This could be because respondent wasn't available or was screened out or consent was not given.
3) Where ID is same and names are different
//check if the data is coming from same enumerator? or different enumerators?
//check if village and enumerator are matched correctly; remove consistencies

Case 1 shouldn't exist because for the same HH, we will have only one form => Field team to check
Case 2 also shouldn't exist because for the same HH, we will submit just one form =>  Field team to check
Case 3 can exist due to data entry issues. This will be fixed below 

*/

/*
preserve
keep if unique_id_Unique!=1 //for ease of observation and analysis

duplicates tag unique_id R_E_cen_resp_name , gen(dup)


//keeping instance for IDs where consent was obtained
replace R_E_consent= 0 if R_E_consent==.
bys unique_id (R_E_consent): gen E_dup_by_consent= _n if R_E_consent[_n]!=R_E_consent[_n+1]
br unique_id_hyphen R_E_consent E_dup_by_consent
drop if R_E_consent==0 & E_dup_by_consent[_n]== 1 

//sorting and marking duplicate number by submission time 
bys unique_id (R_E_starttime): gen E_dup_tag= _n if R_E_consent==0

//Case 1-
gen E_new1= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]!=R_E_cen_resp_name[_n+1] & R_E_cen_resp_name[_n]==.

//Case 2-
gen E_new2= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]==R_E_cen_resp_name[_n+1] 

//Case 3- 
gen E_new3= 1 if unique_id[_n]==unique_id[_n+1] & R_E_cen_resp_name[_n]!=R_E_cen_resp_name[_n+1] & R_E_cen_resp_name[_n]!=.

tempfile dups
save `dups', replace

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
//submission time to be added Bys unique_id (submissiontime): gen
keep if E_new1==1 | E_new2==1 | E_new3==1
 capture export excel unique_id R_E_enum_name R_E_r_cen_village_name_str R_E_submissiondate using "${pilot}Data_quality_endline.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Endsus") ///
 firstrow(var) cell(A1) sheetreplace

***** Step 3: Creating new IDs for obvious duplicates; keeping the first ID based on the starttime and consent and changing the IDs of the remaining

use `dups', clear
keep if E_dup_by_consent==2 & R_E_consent==1
tempfile dups_part1
save `dups_part1', replace

use `dups', clear
keep if E_dup_tag==1
tempfile dups_part2
save `dups_part2', replace


//Using sequential numbers starting from 500 for remaining duplicate ID cases because we wouldn't encounter so many pregnant women/children U5 in a village
use `dups', clear
keep if E_dup_tag>1 & R_E_consent!=1
bys unique_id :gen E_seq=_n
replace E_seq= E_seq + 500
egen unique_id_new= concat (R_E_r_cen_village_name_str R_E_enum_code E_seq)
replace unique_id= unique_id_new 

tempfile dups_part3
save `dups_part3', replace

}
restore

****Step 4: Appending files with unqiue IDs
use `working', clear
drop if unique_id_Unique!=1
append using `dups_part1', force
append using `dups_part2', force
append using `dups_part3', force
//also append file that comes corrected from the field

duplicates report unique_id //final check
drop unique_id_hyphen unique_id_num
drop unique_id_Unique 
* Recreating the unique variable after solving the duplicates
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc 
gen unique_id_hyphen = substr(unique_id, 1,5) + "-"+ substr(unique_id, 6,3) + "-"+ substr(unique_id, 9,3)

*/
*******Final variable creation for clean data

gen      E_HH_not_available=0
replace E_HH_not_available=1 if R_E_resp_available!=1
tempfile main
save `main', replace
replace R_E_village_name_res=R_E_r_cen_village_name_str if R_E_village_name_res==""
rename R_E_r_cen_village_name_str R_E_village_name_str
drop R_E_village_name_res
gen village=.
replace village=10101 if R_E_village_name_str=="Asada"
replace village=10201 if R_E_village_name_str=="Sanagortha"
replace village=20101 if R_E_village_name_str=="Badabangi"
replace village=20201 if R_E_village_name_str=="Jaltar"
replace village=30202 if R_E_village_name_str=="BK Padar"
replace village=30301 if R_E_village_name_str=="Tandipur"
replace village=30501 if R_E_village_name_str=="Bhujbal"
replace village=30602 if R_E_village_name_str=="Mukundpur"
replace village=30701 if R_E_village_name_str=="Gopi Kankubadi"
replace village=40101 if R_E_village_name_str=="Karnapadu"
replace village=40201 if R_E_village_name_str=="Bichikote"
replace village=40202 if R_E_village_name_str=="Gudiabandh"
replace village=40301 if R_E_village_name_str=="Mariguda"
replace village=40401 if R_E_village_name_str=="Naira"
* replace village=30101 if R_E_village_name_str=="Badaalubadi"
replace village=50101 if R_E_village_name_str=="Dangalodi"
replace village=50201 if R_E_village_name_str=="Barijhola"
replace village=50301 if R_E_village_name_str=="Karlakana"
replace village=50401 if R_E_village_name_str=="Birnarayanpur"
replace village=50402 if R_E_village_name_str=="Kuljing"
replace village=50501 if R_E_village_name_str=="Nathma"



/*******************************************************************

#Dropping duplicates 

********************************************************************/

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
drop if R_E_key == "uuid:cf2d7db0-db8f-427d-a77a-87fd0264f94c" & unique_id == "10101108009"


//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
drop if R_E_key == "uuid:30d0381d-8076-46bc-86ce-fde616ccb3b6" & unique_id == "10101108026"

//enum submitted this twice and both of these are unavailable IDs so keeping only one such case
drop if R_E_key == "uuid:4d9381e8-e356-4ae2-be61-8d57322ef40a" & unique_id == "30501117006"

//enum submitted this twice and both of these are unavailable IDs so keeping only one such case
drop if R_E_key == "uuid:20fdbfce-ef3e-46c9-ad31-c464a7e1c1bb" & unique_id == "40201111005"

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
drop if R_E_key == "uuid:975636db-d2ae-4837-8fef-e2ea1186ede3" & unique_id == "40201113010"

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
drop if R_E_key == "uuid:77e94cac-755c-4bc1-a852-8bd4bb859ae3" & unique_id == "40202113050"


//one was a practise entry that is why we dropped it 
drop if R_E_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" & unique_id == "20201108018"

//this ID was attempted later on
drop if R_E_key == "uuid:cc7d0330-7241-4bdd-a46b-97e16ed56e60" & unique_id == "10101113031"

//this ID was attempted later on
drop if R_E_key == "uuid:611e4cfa-aef2-4bfd-a40e-6ee647e317d4" & unique_id == "20201108047"

//this ID was attempted later on
drop if R_E_key == "uuid:4967324b-4832-42ba-8d5b-e4a57876dfbe" & unique_id == "20201110016"

//all the IDs below were given as re-visits as these are house lock IDs so surveyors were asked to submit attempted HH lock IDs on the main endline census form that is why those IDs that were later found I have dropped their previous date entry that was marked as unavailable and for HH lock IDs that are still locked I have dropped IDs with an earlier date 
drop if R_E_key == "uuid:4c7fd5ae-0a6b-4c95-a40a-d6d8376ff1eb" & unique_id == "20201113045"

drop if R_E_key == "uuid:52af03bb-2287-4a07-a4b3-59867ba792a2" & unique_id == "20201113081"

drop if R_E_key == "uuid:ee472a73-3548-4e04-a89d-91fac2ad60ee" & unique_id == "30202109011"

drop if R_E_key == "uuid:78f11df1-c342-479a-a616-87087137624d" & unique_id == "30301119063"

drop if R_E_key == "uuid:ea7326e8-3a8a-49a9-a152-3ee4ab05c803" & unique_id == "30501117040"

drop if R_E_key == "uuid:32bfbced-d7c4-4ef2-98a7-4a67d7e6d478" & unique_id == "30602105059"

drop if R_E_key == "uuid:f94eef7a-0908-4b74-a7d7-6f36fd1c312b" & unique_id == "30701105023"

drop if R_E_key == "uuid:d7b0d915-1d36-43d8-9d6d-8a2962f8d6ad" & unique_id == "30701112022"

drop if R_E_key == "uuid:a9968d3e-2969-4459-8823-3c87eed84057" & unique_id == "40101111026"

drop if R_E_key == "uuid:274cd721-064e-4892-98dc-1e2476cf8c09" & unique_id == "40101111033"

drop if R_E_key == "uuid:67226e44-3dcf-4b7b-a29b-99c5be2285a1" & unique_id == "40202108062"

drop if R_E_key == "uuid:3f0c8021-bec8-4da1-ad86-213379450f98" & unique_id == "40202113009"

drop if R_E_key == "uuid:c7c5f66d-6a2d-400f-842c-526956b02a17" & unique_id == "40301108014"

drop if R_E_key == "uuid:5befa7a4-e547-4f75-bc2c-7d4c1de617a9" & unique_id == "40301108018"

drop if R_E_key == "uuid:1f5a83f4-193b-4a5a-8696-bf9b8c145384" & unique_id == "40301108026"

drop if R_E_key == "uuid:f1ea1ecc-51cd-4749-9013-95c5c5bbb6f4" & unique_id == "40301113002"

drop if R_E_key == "uuid:fdc9757f-5c52-4fcf-9dca-9389dfb84a4b" & unique_id == "40401108066"

drop if R_E_key == "uuid:151ebafd-91a4-4f2a-896f-26ab6a663af0" & unique_id == "40401111028"

drop if R_E_key == "uuid:e500a8b7-879e-49c3-a2c5-6b9d97e56c13" & unique_id == "40401113001"

drop if R_E_key == "uuid:cdc34462-b535-47b7-b777-3bfda2378c05" & unique_id == "50101119016"

drop if R_E_key == "uuid:b04274f3-d920-4c2e-a773-b75263801eef" & unique_id == "50201104008"

drop if R_E_key == "uuid:1c8d5fa5-5bc7-4317-ba2b-e981f139925e" & unique_id == "50201104009"

drop if R_E_key == "uuid:e671b025-fb01-484e-9d1c-dd97de89a5bc" & unique_id == "50201109003"

drop if R_E_key == "uuid:7114b0da-5af1-4000-898f-2d1e58c707a2" & unique_id == "50201109035"

drop if R_E_key == "uuid:899eee2b-efb9-4022-a142-97187c027f80" & unique_id == "50201119022"

drop if R_E_key == "uuid:56feac43-7e90-4f66-91f0-5f0d6cfa6d1c" & unique_id == "50201119042"

drop if R_E_key == "uuid:da5b0b89-ed38-4e22-80c1-3e36f18d94bb" & unique_id == "50201119044"

drop if R_E_key == "uuid:4672d4b8-040d-4397-9bc1-3ce62d9466f3" & unique_id == "50301105005"

drop if R_E_key == "uuid:5bbcc0c5-a6b6-454e-972d-b54408909622" & unique_id == "50301106006"

drop if R_E_key == "uuid:29da7271-93cd-4cda-89d0-008a6cc0ece8" & unique_id == "50301106013"

drop if R_E_key == "uuid:47c1db5e-d49c-4ac8-88e6-ee9f34b8cf57" & unique_id == "50301106014"

drop if R_E_key == "uuid:4f07d6bb-a863-450c-9d20-a4bf7ea5ee2d" & unique_id == "50301106035"

drop if R_E_key == "uuid:7bd7b4e0-994f-4d98-a311-306f38779738" & unique_id == "50301107003"

drop if R_E_key == "uuid:1f6dc4bc-3148-47f4-a66d-a66ce89f54da" & unique_id == "50301107014"

drop if R_E_key == "uuid:33b7c651-d400-4eea-b56b-6b01c4f360bb" & unique_id == "50301107025"

drop if R_E_key == "uuid:caaa46fe-ba0d-4822-aa2f-ea7f080f41e4" & unique_id == "50301117034"

drop if R_E_key == "uuid:972d3059-537c-475d-809a-d198a160d021" & unique_id == "50401106024"

drop if R_E_key == "uuid:555ef21b-a498-47da-9350-f7e455d67c92" & unique_id == "50401106054"

drop if R_E_key == "uuid:e3e37787-7b7c-4072-85e6-267f95d7cacf" & unique_id == "50401107033"

drop if R_E_key == "uuid:22b65692-176f-4586-81ac-04b3de6258c5" & unique_id == "50401107059"

drop if R_E_key == "uuid:54952409-2f3e-4fe9-8f88-78b7c24057ea" & unique_id == "50401107066"

drop if R_E_key == "uuid:d5b10d89-ba3e-4da2-9397-19515333c6d5" & unique_id == "50402106050"

drop if R_E_key == "uuid:daf69f4b-65ed-4934-8495-278dbfe5a324" & unique_id == "50402107010"

drop if R_E_key == "uuid:4ee0dbf4-a7b9-466f-be10-ec409c6aa8b3" & unique_id == "50402107043"

drop if R_E_key == "uuid:a1221224-7ccf-4a77-9537-574298a2f6a3" & unique_id == "50402107049"

drop if R_E_key == "uuid:a8d7ea95-d112-4316-a1a7-36cbed0cce18" & unique_id == "50402117026"

drop if R_E_key == "uuid:9f7a0610-b7ff-4920-ac1d-2cb49c06cd90" & unique_id == "50501104007"

drop if R_E_key == "uuid:5f28da33-eb86-455c-9e4b-5d3297e9e041" & unique_id == "50501104011"

drop if R_E_key == "uuid:52a4d7a5-4121-4ebd-9793-9a49f91890f1" & unique_id == "20101108027"


drop if R_E_key == "uuid:cd2002a5-04f7-4655-bd6c-e30f28f2918d" & unique_id == "20201108043"


drop if R_E_key == "uuid:587a59e3-ec78-4343-b82d-3da878c2ea4a" & unique_id == "20201113046"

drop if R_E_key == "uuid:154a71f5-8410-4a45-a451-b8d44b5f2015" & unique_id == "30301109002"

drop if R_E_key == "uuid:e37fbb15-5044-4e65-aeba-9382971590bc" & unique_id == "30301119062"

drop if R_E_key == "uuid:e2b0bf67-16af-4e0d-935d-e4566d28dc3b" & unique_id == "30602106023"

drop if R_E_key == "uuid:e3671011-8b5f-4dee-bf09-ab815f14efda" & unique_id == "30602106030"

drop if R_E_key == "uuid:40774fa6-689c-4654-a5dd-23e8664c831d" & unique_id == "30602117014"

drop if R_E_key == "uuid:030d441b-2fbf-47b5-a7db-aabed4650aa9" & unique_id == "30602117025"

drop if R_E_key == "uuid:0a9ec852-7e87-42c8-926b-98186c96a755" & unique_id == "30701112023"

drop if R_E_key == "uuid:5ee5348f-4a96-46db-afc6-bb189028ca35" & unique_id == "40101108003"

drop if R_E_key == "uuid:185719a4-c609-4613-bf1a-527465395310" & unique_id == "40101111024"

drop if R_E_key == "uuid:4e6cbffa-401c-451d-a555-0ed0e0c529e3" & unique_id == "40201110014"


drop if R_E_key == "uuid:592cccd7-2e30-4c84-bfa7-071480954469" & unique_id == "40201111005"

drop if R_E_key == "uuid:f5f693ec-8c46-4080-a4b8-f25f4060cd25" & unique_id == "50101104006"

drop if R_E_key == "uuid:a8db3950-3a53-4ed3-965b-717658d02fd9" & unique_id == "50101115003"

drop if R_E_key == "uuid:b2348752-54a4-49f7-a0fa-45b98fe703f3" & unique_id == "50101115006"

drop if R_E_key == "uuid:385f9b49-e64f-4d46-8f3f-1c92edc13f9b" & unique_id == "50101115011"

drop if R_E_key == "uuid:c9a34fdd-d23c-4568-bb37-55795865f0ed" & unique_id == "50401105034"

drop if R_E_key == "uuid:bfc18a3d-b5fb-4ae1-b949-a57d241bbf9c" & unique_id == "50401105039"

drop if R_E_key == "uuid:1afef2c7-32fd-4ee3-bf38-d955c7eaa3ab" & unique_id == "50401106029"

drop if R_E_key == "uuid:4165680b-67b3-4193-aba0-04fb6086deac" & unique_id == "50401107005"

drop if R_E_key == "uuid:ac531f0b-084e-426c-a1e2-917e3d8a213e" & unique_id == "50401107010"

drop if R_E_key == "uuid:08cb3fc2-bab4-47d7-b0d8-edd9b94dcdac" & unique_id == "50501104003"

drop if R_E_key == "uuid:0bba28b6-f6d3-4a5d-80b8-8632c28c4a86" & unique_id == "50301106006"

drop if R_E_key == "uuid:7581b00a-2cca-4115-9c6d-35b5e082a083" & unique_id == "50301106014"

drop if R_E_key == "uuid:345ecae7-bfbe-4f01-82fa-c47ad9b036ed" & unique_id == "50301106035"

drop if R_E_key == "uuid:fed059d7-fc79-4a06-bad8-438b71634456" & unique_id == "50301117034"


save "${DataTemp}U5_Child_23_24_part1.dta", replace
