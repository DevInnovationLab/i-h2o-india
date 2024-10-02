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
//FLAG- check again - m:m should not be used (Archi)
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
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str) keep(3) nogen

cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

//here we find that on UID - 30202109013  there are two women with the same name that is "Pinky Khandagiri" but they are different people so we have to rename one women so in this case I am renaming unmarried Pinky Khandagrii by adding a suffix underscore in her name 

replace comb_name_comb_woman_earlier = "Pinky Kandagari_" if  unique_id == "30202109013" & comb_preg_hus == "444" & comb_name_comb_woman_earlier == "Pinky Kandagari" 

gen Var_type = "C"
	 
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
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str) keep(3) nogen
	 
gen Var_type = "N"
 
 
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
save "${DataTemp}CBW_merge_Endline_census.dta", replace
 
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
 
gen Var_type = "R"
 
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

//please note that we can get rid of these cases where  comb_resp_avail_comb == . because these are all the non applicable cases for women since the loop for new women section use to take all roster members name ito account so non applicable nams like new baby and all used to come as a result these entries are present in the dataset so if we want a filtered data of just applicable women we can drop such entries  
drop if   comb_resp_avail_comb == .
save "${DataFinal}Endline_CBW_level_merged_dataset_final_applicable_cases.dta", replace 

 
 
 
 ////////////////////////////////////
 
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
 
 clear matrix
 
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

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"

//rename _merge HH_lock

gen HH_revisit_for_lock = .
replace HH_revisit_for_lock = 1 if _merge == 3
replace HH_revisit_for_lock = 0 if _merge == 1


//recoding instruction variable 
clonevar R_E_C_instruction = R_E_instruction

//this was a non consnet case so I recoded it as a refused case 
replace R_E_C_instruction = "-98" if unique_id == "10101113002" & R_E_key == "uuid:15a2cff6-4db0-4d6b-80bc-f09e35fb0eaa" & R_E_instruction == "1"

//this also needs to be replaced as we are already tackling this non consneted case above
clonevar R_E_C_consent = R_E_consent
replace R_E_C_consent = "" if unique_id == "10101113002" & R_E_key == "uuid:15a2cff6-4db0-4d6b-80bc-f09e35fb0eaa" & R_E_instruction == "1"

//case of UID - 50101115006
//here enum chose other to write the reason for unavailability but there is already a separate option for unavailability so we don't need to show this in others
replace R_E_C_instruction = "6" if unique_id == "50101115006" & R_E_key == "uuid:131dfecd-cf82-497f-a815-22c0d16c7d34" & R_E_instruction_oth == "Main respondent Maika geyehai kab ayegi pata nehi ghar me un ki husband ko pani ke baremay patanehi un ki sasu maa ko sunai nehi dete" 

clonevar R_E_C_instruction_oth = R_E_instruction_oth
replace R_E_C_instruction_oth = "" if R_E_instruction_oth == "Main respondent Maika geyehai kab ayegi pata nehi ghar me un ki husband ko pani ke baremay patanehi un ki sasu maa ko sunai nehi dete" 



cap drop _merge


*.........................................................
//IMP VARIABLES FOR TABULATION
*...........................................................

//Archi to Akito: To find out the consented main respondents plz tab this 

/*******************************************************
//MAIN RESPONDENT STATS 
*******************************************************/


//this is a recoded variable
tab R_E_C_instruction


//TReatment and control wise consented main respondents 
gen R_E_C_instruction_TvsC = .
bysort Treat_V: replace R_E_C_instruction_TvsC = 1 if R_E_C_instruction == "1"
tab Treat_V R_E_C_instruction_TvsC


//to get refusals only for main respondent and not for full HH  to check for -98 
tab R_E_C_instruction

//to get unavailable numbers only for main respondent and not for full HH ( check for codes 4 and 6)
tab R_E_C_instruction


//to find the available HH plz tab this look for code 1 
tab R_E_resp_available



/*******************************************************
//HH STATS 
*******************************************************/

//to find the available HH plz tab this look for code 1 
//Archi to Akito - 2 code here refers to permannet migration so when you tab this number would make full sense
tab R_E_resp_available


/*******************************************************
//To get U5 child status whether they are from baseline or endline
*******************************************************/


use "${DataTemp}U5_Child_Endline_Census.dta", clear
drop if comb_child_comb_name_label== ""
keep comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label unique_id Cen_Type

split comb_child_comb_name_label, generate(common_u5_names) parse("111")
replace comb_child_comb_name_label = common_u5_names2 if common_u5_names2 != ""

*** Manual corrections
*Dropping observations 
//the following respondent is not a member of HH for which she was the main respondent (main respondent is the sister in law of the target respondent and does not stay in the same HH)
drop if unique_id=="30501107052"   


//dropping the obs as it was submitted before the start date of the survey. This is a baseline census ID 
drop if unique_id=="10101101001" 


//here CEn_Type = 5 means these are entries from new rosters and Cen_Type = 4 means children name from baseline census 
tab Cen_Type
/*tab Cen_Type

	Cen_Type	Freq.	Percent	Cum.
				
	4	976	76.19	76.19
	5	305	23.81	100.00
				
	Total	1,281	100.00 */



save "${DataFinal}Endline_HH_level_merged_dataset_final_part2.dta", replace




















