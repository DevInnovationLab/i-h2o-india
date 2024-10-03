/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: This do file creates final version of  endline indvidual datasets
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
	
****** Do file to run before this do file

****** Language: English
****** Note on Prefixes used: R_Cen_: Raw Baseline Census Variable; R_E_cen_: Raw Endline Census Variable (census members); R_E_n_: Raw Endline Census Variable (new members); comb_: ; C_Cen_: Coded/New Baseline Census Variable; C_E_: Coded/New Endline Census Variable; C_: Coded/New variables for both Basleine and Endline Census

*=========================================================================*/

/***************************************************************************************
MAIN OBJECTIVE OF THIS DO FILE 🤓

We are merging/appending main endline census long datasets with revisit endline census long datasets. Majorly we have 4 long datasets- Child, Women, Census Roster, New roster. So, after we are done making their appended versions. We will create one master individual dataset which will have these variables so this will serve two purposes: combined cleaning and analysis. Based on our conveninece we can drop the set that we don't want.  

****************************************************************************************/

clear
set seed 758235657 // Just in case

//Doing key creation for main endline census datasets. Here M_key_creation refers to the main endline datasets key creation
cap program drop M_key_creation
program define   M_key_creation

	split  key, p("/" "[" "]")  //Step 1: Split the 'key' variable into parts using '/' '[' and ']' as delimiters. This will create new variables: key1, key2, etc.
	rename key key_original  //Step 2: Rename the original 'key' variable to 'key_original' to preserve its full value.
	
	rename key1 key //Step 3: Rename 'key1' (the first part of the split) to 'key', essentially replacing the original 'key' with the first portion of the split value.
	
end


//Doing key creation for revisit endline census datasets

cap program drop RV_key_creation
program define   RV_key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end



/***************************************************************
CHILD LEVEL DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT ENDLINE
****************************************************************/

/* APPROACH FOR MERGING DATASETS: 

/////////////////////////////////////////
**Basic Explanation about prefixes
//////////////////////////////////////////

😇 Welcome to the toughest part of these datasets. If you are here that means you have come a long way. Let us dive into this! 

Revisit Endline census sections were divided into two types: 

####################################
💀 Variables with comb_ prefix 
######################################
comb_ signifies that this section would appear only for those cases which had imported names of children or women from the preload. This preload was created from the main endline census wherever survey of child or women was pending. 


😵‍💫Now, you might ask, Why is the meaning of this prefix different for main endline census? 
***********************************************************************
 So, main endline census also had the prefix system where N_ was used for new entries, it means not present already in the baseline census and Cen_ was used for entries which were from baseline census so the idea of comb_ comes from there. comb_ was a combined prefix which denoted that this is the combined data of the census and new entries. This process of combination was done in the file - 1_8_A_Endline_cleaning_HFC_Data_creation file. 
---> In case of endline revisit census, comb_ prefix includes both the cases from main endline census where name of the person was taken from baseline (i.e. with the cen prefix) and those people who are new and were not recorded in the baseline but their names were recorded in the main endline census. 


BUT.....WHY WAS THIS DONE? 

In endline revisit census, comb_ prefix was used to reflect cases of both Cen_ and N_ from main endline census because we wanted to ensure consistency as comb_ reflects the final form of the variable and dataset in general. If this was not done, then it would have created problems like-

i) Double new entries for eg- If we had used N_ to reflect those names from the revisit preload where where child or women was a case was new entry but they were re-visited again because they were unavailable in the main round of survey but thier names were recorded from the main respondent so we wanted to make sure we also revisit these new cases now lets say we would have used prefix N_ to reflect these entries this would have confused the person working on data because they would not have been able to differentiate between which are the new entries from main endline census and which are the entries from revisit endline census because hey we also wanted new entries data never recorded previosuly in the revisit too....(I know crazy) so differentiation had to be made which is new entry from main endline census and revisit endline census. Additionally, you would have to follow additional steps in bringing it to the comb_ form because ultimately this is the final form right?

ii) The survey CTO coding would become more complex becasue loop in survey cto runs separately for new member sections and comb_ sections because comb_ ones are the preloaded names so you need to import csv to get those names so if you had mixed this up it would have been extremely difficult to analyse. 

So, the most sensible choice was to use comb_ to represent both Cen_ and N_ entries for revisit census ( Now...that is a lot of knowledge dump right? More coming your way 🤪)

####################################
💀 Variables with N_ prefix 
####################################

By now you would know, what does N_ mean. These are new entries from endline revisit census that means they were not recorded anywhere nor in the main endline census becasue they are just revisit level new. 
	
Conclusion: That is why you see two prefix in the revisit form: comb_ and N_ 
*/
 
 
 //////////////////////////////////////////////////////////////////////////////
**objective of the next steps

/* We are firstly combining revisit long datasets into one. So, we are combining entries with comb_ and N_ into comb_ to keep it consistent with main endline census. */
////////////////////////////////////////////////////////////////////////////

 * RV_ID 24 ( Don't get confused by these numbers..this is just a way to notify the dataset). Focus more on what that dataset contains! )
 
//no data in the dataset below because no new member included. This being empty means there were no new children included in the revisit form so our work gets easier.
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_child_followup.dta", clear


 * RV_ID 23 (The dataset below contains enteris for combined child enteries i.e. the nams in the preload) 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_child_followup.dta", clear

RV_key_creation //we have already defined this function above 

foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen comb_type = "comb" //If the comb_type is comb that means this is the combined entry of Cen_ and N_ entry that is getting formatted. (Remember these are the preloaded child names that comes from the revisit preload) 

save "${DataTemp}temp.dta", replace

rename key R_E_key //we are renaming this because that is the renaming convention that we have been using for endline datasets 

/*🥹 -  WHERE AND WHY?
where does this dataset comes from? Refer to this cleaning file: "GitHub\i-h2o-india\Code\1_profile_ILC\1_9_A_Endline_Revisit_cleaning.do"
Why- We are merging this over R_E_key because this is the only identifier to connect both of them and we want some other identifiers like UID, Village, enum label to use this dataset for basic cleaning and stats. That is why we are getting these variables from Endline_Revisit_Cleaned dataset
*/

merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_enum_name_label R_E_enum_code R_E_village_name_str) 

/* 😏Why are there some unmatched keys? 
**********************************************
always always investigate why there are some cases that are not matched. The reason for this lies in the fact that endline revisit cleaned doesn't have those keys that were not appliacble for eg that ID could be a duplicate that is why the whole observation and key was dropped or this could be a training entry. The approach to investigate this would be to open the do file that creates 1_9_A_Endline_Revisit_cleaning dataset.

keys where _merge ==1 you will see that these keys are straight away getting dropped from 1_9_A_Endline_Revisit_cleaning.do

keys where _merge == 2 are also fine because the main dataset will always have more observations than a subset of the dataset in this case child dataset because not every housheold will have U5 children right so move on...... you are good to go!   */

keep if _merge == 3
drop _merge 

//we are cloning village variable to match it with the Village tracking sheet to get extra identifiers like treat ment status, Panchayat, etc
clonevar Village = R_E_village_name_str

merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) 
keep if _merge == 3
drop _merge


//Now sometimes you don't need unavailable entries for analysis so we can just keep relevant variables.  So, if you don't wnat to use unavailable cases in analysis feel free to keep only the available ones by using this variable 
* Respondent available for an interview 
/*keep if comb_child_caregiver_present==1
*/

//wohoo we have got our combined revisit child dataset
save "${Intermediate}1_2_Endline_Revisit_U5_Child_23_24.dta", replace   



********************************************************************************************************************************************************
/* NEXT WE NEED TO DROP ROWS FROM MAIN ENDLINE CHILD DATASET

What does this mean? 😱 😱 😱

See the purpose of collecting revisit data was to actually use these observations in our main dataset right ? So, how would we know which observations to keep and which to drop from both the datasets. The approach here would be to follow the following steps-

A) Rename the variables (comb_main_caregiver_label and  comb_child_caregiver_present) in the endline child revisit dataset. The logic behind this step would get  clearer. If these two varaibles are not re-named we won't able to identify the entry that we have to keep. 

B) After renaming these variables in the child revisit dataset we are going to merge this with main endline child dataset to see for eg Unique ID and child name which entry needs to be kept from main child dataset or revisit data. For ge- for the UID - 1234567 and the child name - Sukesh if in the main endline census dataset this child was unavailable and we have gotten good data for Sukesh in the revisit data we would need to remove Sukesh's entry from main child dataset and replace it with revisit entry but you won't be able to identify without 1:1 merge that is why we are comparing using 2 key variables - unique ID and child name variable (comb_child_comb_name_label) because if we don't use these two key varaibles we won't be able to perform 1:1 merge and how would you verify if this is actually unqiue across the two datasets? To verify that we are using the command- 
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
Tabulating this would tell us how many duplicate pairs are there. In our case, there are none so we are good to go!!! 🚗 🚗 🚗
So, that is why we are renamining variables: comb_main_caregiver_label and  comb_child_caregiver_present because they are going to be used for verification if we are actually droppping the right entry or not! 

C) After you are done with merging, Flag the rows where in the main child dataset a particular entry of that specific unique ID alongwith the child name were unavailable because remember only unavailable IDs from the main endline census was given for revisit so we have no business in dropping actual valid observations where child was available in the main endline census so after you have flagged the observatiosn where child name and UID was unavailable you move to the next step (the variable to look for availability would be comb_child_caregiver_present)

D) After we have flagged these observations, we check if they are actually identical for eg - it shouldn't be the case that Sukesh's caregiver names are different! After you have done some manual comparison that you are actually looking at the smame UID and child name you go to step E

E) You generate a variable called gen to_drop = . and you then replace to_drop = 1  if Vcomb_child_caregiver_present == 1 & _merge == 3 (This means this is the entry where Sukesh's was marked as unavailable in the main endline child dataset but we have a valid entry for this in the revisit child dataset because 1 in the Vcomb_child_caregiver_present == 1 means that child was available in revisit and surveyed.) T
drop if to_drop == 1
That is the reason we are good to drop this entry from the main child dataset. We will see later how replacement with revisit data is done. 

*/
*****************************************************************************************************************************************************
use "${Intermediate}1_2_Endline_Revisit_U5_Child_23_24.dta", clear   
/*//we must rename these variables because these variables are present in the main endline census child level dataset too so we need these 2 variables for verification and . V prefix stands for verification here. */

//please note that there are two caregiver name variables- one is this comb_child_comb_caregiver_label and other one is comb_main_caregiver_label. The only difference between the two is for revisit survey we wanted to capture who is the caregiver answering questions for the child currently and there was also a preloaded variable (comb_main_caregiver_label) guiding enum that this is the caregiver we found in the main endline census so they should make sure they talk to the same person but in case they are not able to they can talk to a different caregiver but record their name and the variable for this was (comb_child_comb_caregiver_label) that is why comb_main_caregiver_label (in revisit survey) and comb_child_comb_caregiver_label (main endline survey) are literally the same thing becaus ethey are actual caregiver of the children. (I will rename this while combing the datasets but for comparsion purpose we need to rename them here)
rename comb_main_caregiver_label Vcomb_child_comb_caregiver_label
rename comb_child_caregiver_present Vcomb_child_caregiver_present
cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", replace

//this is the main endline long child level dataset. This dataset is created in the file "1_8_A_Endline_cleaning_HFC_Data creation.do"
use "${DataTemp}U5_Child_23_24_part1.dta", clear
//there are these empty entries because the loop in survey cto also takes in null values and if it is null it moves to the next value but the observation still gets created so need to worry just drop it
drop if comb_child_comb_name_label == ""
cap drop dup_HHID
//checking if this combinarion is unique or not. If its not, then we won't be able to perform 1:1 merge. Please note that we can't perform this 1:1 merge over keys because they are different in both the datasets 
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


//merging the main child level dataset with the endline level child dataset on UID and child name. I am retaining some of the variables from using dataset for comparison as explained earlier 
merge 1:1 unique_id comb_child_comb_name_label  using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", keepusing(unique_id comb_child_comb_name_label Vcomb_child_caregiver_present Vcomb_child_comb_caregiver_label  ) 

//we can just browse and check fi there is any unique ID and child combination where main caregiver doens't matches because these are the preloaded names so they should all match. After doing this you will find that there are 0 mismatches 😁
br comb_child_comb_name_label comb_child_caregiver_present comb_child_comb_caregiver_label Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present if comb_child_comb_caregiver_label != Vcomb_child_comb_caregiver_label & _merge == 3

/*
.........................................................................................................................................................
Objective of the exercise below: 🐻‍❄️
.........................................................................................................................................................
Instead of doing the replacement of the rows from the revisit data with the main dataset we are dropping the rows from the main dataset where that specific children on that Unique ID was unavailable (to check for unavailability look at this variable- comb_child_caregiver_present)  earlier but was revisited in the revisit round and was surveyed. We are avoid doing replacement of rows by using merge because m:m results in a lot of complication as a result we want to append it so that we can minimise discrepancies so we would append that data from the revisit dataset to the main dataset and remove the entry from the main census dataset to avoid having duplicates for such children where _merge == 3 that means they got matched with revisit data and they were unavailable in the main round 

Here the _merge == 3 entry of the matched entry indicates that this entry is also available in the using dataset (revisit dataset) but this is not enough to help us in deciding whether we want to drop this row or not from the main endline datatset that is why we use another variable called  Vcomb_child_caregiver_present that will tell us whether this survey was actually completed in the revisit or not. If Vcomb_child_caregiver_present is qual to 1 then that means that child became available later so we can add this data that was available to our main dataset and drop the unavailable child entry from the main dataset. We can keep all other matched entries from the main dataset because if they were also unavailable during revisit then it doens't make any sense to put in time and efforts to replace other entries.  

*/

//the browse gives us around 22 observations that we need to drop. Make sure to not drop values where Vcomb_child_caregiver_present  is anything other than 1 because there is no point of replacing if we don't have that data 
br unique_id comb_combchild_index comb_combchild_status comb_child_comb_name_label comb_child_caregiver_present comb_child_comb_caregiver_label Vcomb_child_caregiver_present Vcomb_child_comb_caregiver_label _merge if _merge == 3 & Vcomb_child_caregiver_present == 1

//whatever entries have the value 1 here that entry needs to be dropped from the main child dataset as we will add rows for such children from the revisit dataset to create a complete datatset so we are creating to_drop variable for the same reason
gen to_drop = .

replace to_drop = 1  if Vcomb_child_caregiver_present == 1 & _merge == 3
replace to_drop = 0 if Vcomb_child_caregiver_present != 1 & _merge == 3

//we have dropped all the entreis where revisit data will be replacing these rows
drop if to_drop == 1 

//we are importing endline child level dataset again to now prepare it for the actual append with the main child dataset so we would need to retain the keys of using child revisit dataset and give it diff prefix so here I am giving the prefix Revisit to the keys to differentiate from the main endline census keys 
preserve
//please note that we are using intermediate dataset here because we want variable names to be same if we are appending
use "${Intermediate}1_2_Endline_Revisit_U5_Child_23_24.dta", clear  
drop if comb_child_comb_name_label == ""
//we are keeping only these observations here where comb_child_caregiver_present == 1 because these are the only entries that have been droppped from main endline child dataset. If we don't drop it we will have the problems of duplicates
keep if comb_child_caregiver_present == 1
foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

/*
WHY RENAME THIS?  😭
We are renaming the two varaibles below because this variable in endline revisit  comb_child_comb_caregiver_label was for the current caregiver who gave surveys to us about that child in case the main caregiver wasn't present so we need to make sure while appending main caregiver labels are at one places and those who gave us surveys in revisit as caregivers are recorded differently so here I am using the prefix RV_ for this this highlights that this is the Revisit set variable 
*/
rename comb_child_comb_caregiver_label RV_comb_child_caregiver_label
rename comb_main_caregiver_label  comb_child_comb_caregiver_label

//we will use the following dataset for append 
save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta", replace
restore

append using "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp.dta"

//checking for duplicates UID and child name wise. It is imp that there are no duplicates. This shows the append was successul. You will also see the number of observations hasn't changed
cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

/*IMP NEXT STEP : We need to check if the variable names are similar throughout these long datasets if not, we must make it similar 🤠
Lets drop variables with V prefix because we just created them for comparsion purpose. I have already renamed caregiver label so fret not!
There doens't seem to be any extra variables that need renaming so lets move on
*/
drop Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present

//br unique_id comb_child_comb_name_label comb_main_caregiver_label comb_child_caregiver_present comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_month comb_child_breastfed_days comb_child_care_dia_day if unique_id == "30301109053"

save "${DataFinal}Endline_Child_level_merged_dataset_final.dta", replace 


/**********************************************************************************
ROSTER MEMBERS DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
**********************************************************************************/


//this is the main endline long new roster member dataset. This dataset is created in the file "1_8_A_Endline_cleaning_HFC_Data creation.do". 

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




















