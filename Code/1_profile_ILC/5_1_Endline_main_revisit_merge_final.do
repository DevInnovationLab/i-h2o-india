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
Individual dataset types : Child, women, census roster, new roster 
Wide dataset: Household level 
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


/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

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

//specify what long is here and specify the unit 
 * RV_ID 23 (The dataset below contains enteris for combined child enteries i.e. the nams in the preload) 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_child_followup.dta", clear

RV_key_creation //we have already defined this function above 

foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}

gen comb_type = "comb" 
//If the comb_type is comb that means this is the combined entry of Cen_ and N_ entry that is getting formatted. (Remember these are the preloaded child names that comes from the revisit preload) 
gen C_entry_type = "RV" 
 //this variable shows that this is revisit child entry and if it has the comb prefix it means this is entry from preload from the main endline census 
drop if comb_child_caregiver_present == .
drop if comb_child_comb_name_label == ""

save "${DataTemp}temp.dta", replace

rename key R_E_key //we are renaming this because that is the renaming convention that we have been using for endline datasets 

/*🥹 -  WHERE AND WHY?
where does this dataset comes from? Refer to this cleaning file: "GitHub\i-h2o-india\Code\1_profile_ILC\1_9_A_Endline_Revisit_cleaning.do"
Why- We are merging this over R_E_key because this is the only identifier to connect both of them and we want some other identifiers like UID, Village, enum label to use this dataset for basic cleaning and stats. That is why we are getting these variables from Endline_Revisit_Cleaned dataset
*/

//we are merging this with wide dataset 
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

//Finding duplicates can be done in two ways 

1. Way 1: Finding duplicates by bysorting by key and then wherever keys are repeated manually check if child names are same  (Most Preferred and most accurate)

2. Way 2:  Finding duplicates using key and child name. If they are no duplicats that means at each key, we have unique child names. 


*/
*****************************************************************************************************************************************************
use "${Intermediate}1_2_Endline_Revisit_U5_Child_23_24.dta", clear   
cap drop _merge
/*//we must rename these variables because these variables are present in the main endline census child level dataset too so we need these 2 variables for verification and . V prefix stands for verification here. */

//please note that there are two caregiver name variables- one is this comb_child_comb_caregiver_label and other one is comb_main_caregiver_label. The only difference between the two is for revisit survey we wanted to capture who is the caregiver answering questions for the child currently and there was also a preloaded variable (comb_main_caregiver_label) guiding enum that this is the caregiver we found in the main endline census so they should make sure they talk to the same person but in case they are not able to they can talk to a different caregiver but record their name and the variable for this was (comb_child_comb_caregiver_label) that is why comb_main_caregiver_label (in revisit survey) and comb_child_comb_caregiver_label (main endline survey) are literally the same thing becaus ethey are actual caregiver of the children. (I will rename this while combing the datasets but for comparsion purpose we need to rename them here)
rename comb_main_caregiver_label Vcomb_child_comb_caregiver_label
rename comb_child_caregiver_present Vcomb_child_caregiver_present
cap drop dup_HHID
//WAY 2
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
br comb_child_comb_name_label dup_UID if dup_UID != 0

drop dup_UID 
//we haven't dound any duplicates in the child dataset 

save "${DataTemp}1_2_Endline_Revisit_U5_Child_23_24_temp1.dta", replace


/*******************************************************************************************

Creating a combined child dataset from main endline census 

**********************************************************************************************/
 
 * ID 23
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_child_followup.dta", clear
tab cen_child_caregiver_present
tab cen_child_act_age

M_key_creation
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=4
gen C_entry_type = "BC" //this variable shows that this is old child entry and was already present in the baseline census 
drop if comb_child_caregiver_present == . 
drop if comb_child_comb_name_label == ""
save "${DataTemp}temp.dta", replace

* ID 24
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_child_followup.dta", clear
M_key_creation


foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=5
gen C_entry_type = "N"  //this variable shows that this is new child entry and wasn't already present in the baseline census 
//drop comb_child_care_pres_oth
tostring  comb_child_care_pres_oth, replace
drop if comb_child_caregiver_present == . 
drop if comb_child_comb_name_label == ""
//Archi to Akito - It is better to not drop it 
append using "${DataTemp}temp.dta"
//drop if comb_child_caregiver_present==.
//Archi - I commented this out because we still need names of the unavailable children 
rename key R_E_key
/*merge m:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", keepusing(unique_id R_E_enum_name_label End_date R_E_village_name_res) keep(3) nogen*/

//Archi - In the command above we are merging this data with consented values but if we want to survey unavailable respondents too we have to merge it with "${DataPre}1_8_Endline_XXX.dta"
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_enum_name_label End_date R_E_village_name_str) keep(3) nogen

rename R_E_key  key
//we should not touch the original village variable
clonevar Village = R_E_village_name_str

* Village
//replace Village="Bhujabala" if Village=="Bhujbal"
* Gopi Kankubadi: 30701 (Is this T or C is this Kolnara? Is this panchayatta?)
//save "${DataTemp}U5_Child_Endline_Census.dta", replace

//stop_it
//getting treatment status and stuff
merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)

drop if comb_child_comb_name_label == ""
//there are these empty entries because the loop in survey cto also takes in null values and if it is null it moves to the next value but the observation still gets created so need to worry just drop it

cap drop dup_HHID

save "${DataTemp}U5_Child_23_24_part1.dta", replace

use "${DataTemp}U5_Child_23_24_part1.dta", clear
//checking if this combinarion is unique or not. If its not, then we won't be able to perform 1:1 merge. Please note that we can't perform this 1:1 merge over keys because they are different in both the datasets 
//WAY 2
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID


// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
br unique_id comb_child_comb_name_label dup_UID if dup_UID != 0

/*

IMP NOTE: ONE DUPLICATE FOUND 

What does 111 prefix mean before the name? 
 Write 111- Name of the member if during baseline they were excluded from the criteria by writing the incorrect gender and age i.e. they should come in the criteria but they are not coming because either age or gender are wrongly recorded. 
 
 Additional instructions given to the enum for this:
 ********************************************************
 
 For eg- if in the baseline census women age was recorded as 40 but her gender is recorded as "Male" in this situation she is an eligible member so she should be included in the criteria so please add her in the new member roster and in the question "What is the name of household member?" please write 111- Name for eg if the name of the woman in census was kamla devi and she is 40 years old but her gender was marked as Male in this situation when you fill the roster for her when writing her name don't just write Kamla instead write 111-Kamla devi
111 would be now a code for any old census member you are adding in the new member roster because gender or age of the old census member was incorrect please note that this would be done only when the is coming in our criteria (either an U5 child, pregnant mother, child bearing women)
Only though this 111 we would get to know that this is an old member from the roster otherwise we won't know this. Please fill this carefully


 Please note that for this ID enum by mistake included  this child named "Ranbir/Ranveer Sabar" because this child no longer falls in the criteria and enum were supposed to re-enter names in the new roster using 111- only when these entries should have been included in the women or child loops but they weren't included because of wrong gender or age  so it was not required to re-enter this child because already in the child loop enum had shown that this child no longer falls in the criteria. Consult with Jeremy and Akito about how to go about dropping this case/ 

unique_id	comb_child_comb_name_label
20201111076	111-Ranbir sabar
20201111076	Ranveer sabar

*/
//merging the main child level dataset with the endline level child dataset on UID and child name. I am retaining some of the variables from using dataset for comparison as explained earlier 
cap drop _merge
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
cap drop _merge
drop if comb_child_caregiver_present == .
save "${Intermediate}Endline_Child_level_merged_dataset_final.dta", replace 



/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 2
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/


/**********************************************************************************
ROSTER MEMBERS DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
**********************************************************************************/

/*

OVERALL OBJECTIVE: 

We have 3 types of dataset here: 

1.  Type 1: "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta"

This dataset contains information for new roster members that were inlcuded in the main endline census.  

2. Type 2: 
"${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta"

This dataset contains information about the census roster members that were inlcuded in the main endline census. The roster for this is different because we wren't collecting all the identifiers like age, sex, etc. for baseline census members we were just asking 2 questions that is if they are still a member or not and  Since September 2023 how many DAYS has ${name_from_earlier_HH} spent away from this village?

3. Type 3:  "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.dta"

This dataset contains information about the revisit dataset where those baseline census members were revisited whose information we were not able to get in the main endline census and since this was a section only for census members that s why there is no comb_ type variable here 

Our goal is to merge these 3 datasets and create a combined roster dataset 

*/

* ID 26 (N=322) All new household members in the main endline census 

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
///This dataset is created in the "GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2.do"

M_key_creation 
drop if n_hhmember_name == ""
ds namenumber namefromearlier current_year current_month age_years age_months age_years_final age_months_final age_decimal 
foreach var of varlist `r(varlist)' {
rename `var' n_`var'
}
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_instruction) 

//there are around 16 keys that don't match with cleaned endline census data and that is because these are practise entries observations from endline census so in the long dataset unless we manually drop it it would still be present so we should just keep _mereg == 3
keep if _merge == 3
drop _merge

gen C_entry_type = "N" 
drop if R_E_instruction == .
save "${DataTemp}temp2.dta", replace

save "${Intermediate}Endline_New_member_roster_dataset_final.dta", replace 

********************************************************************************************************************************



* ID 25
//census roster in the main endline census dataset 
///This dataset is created in the "GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2.do"
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
M_key_creation 
drop if name_from_earlier_hh == ""
ds hh_index name_from_earlier_hh
foreach var of varlist `r(varlist)' {
rename `var' cen_`var'
}

foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
rename key R_E_key
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_instruction )

//296 entries that are just in master are all the practise entreis 
keep if _merge == 3
drop _merge 
gen C_entry_type = "BC" 

//check for unique entries on which the merge has to happen 

// WAY 1  (explained earlier) 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 


//WAY 2
bysort unique_id comb_name_from_earlier_hh: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

drop if  R_E_instruction == .

br unique_id comb_name_from_earlier_hh if dup_UID == 1
sort unique_id

save "${DataTemp}temp0.dta", replace

/*

DUPLICATES FOUND in the above dataset- Discuss with the team how to go about this 

unique_id	comb_name_from_earlier_hh
30202109013	Pinky Kandagari
30202109013	Pinky Kandagari
30602105049	Priya Koushalya
30602105049	Priya Koushalya

Some names that could cause confusion- 
unique_id	comb_name_from_earlier_hh
//these two kids - Kahna Misal and Kahnei Misal are different. Their ages are different as verified from basleine census but names are so similar for that reason I flagged it here 
10101108026	Kahna Misal
10101108026	Kahnei Misal


//these two cases had some issues. This needs to be reconciled with household level dataset and Niharika had pointd out the issue there. Will take this up during cleaning 
unique_id	comb_name_from_earlier_hh
40101111012	999
unique_id	comb_name_from_earlier_hh
40301108008	Gouri Gouda
unique_id	comb_name_from_earlier_hh
40301108013	Gouri Gouda

*/


/*

CREATING COMBINED ENDLINE REVISIT ROSTER DATASET SO THAT IT CAN BE MERGED WITH MAIN ENDLINE ROSTER DATASETS 

OBJECTIVE: 

By now, you might have noticed the appraoch- 
1. We firstly merge census and new sections from main endline census 
2. Then we merge endline revisit sections- comb, cen_, n_ into comb 
3. After that we merge these two merged datasets to create one final dataset that has both revisit entries and main endline census entries 

The counterpart reviist dataset for new census members didn't have any entries that is why we are not using that for merging purposes that is why we are jumping directly into endline cenusus roster. There is no comb here because it was strictly only for census members so it didn't make sense to create a combined variable capturing new member entries too 

Drop here means we would have to drop those rows from the main endline long roster dataset where respondent was unavailable here and data couldn't be collcted so we need to add rows in replacement for this from revisit endline roster level dataset 

This dataset is created in the "GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2_revisit.do"
*/
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.dta", clear
RV_key_creation
drop if name_from_earlier_hh == ""

ds hh_index name_from_earlier_hh
foreach var of varlist `r(varlist)' {
rename `var' cen_`var'
}

foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
gen comb_type = "Cen" 
gen C_entry_type = "RV" 

rename key R_E_key
//firstly merging it with endline HH level dataset to get which HH were done

merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_instruction)

//using entries are 99 because using has a lot more entries as compared to the census roster as only selective housheolds were asked this quetsion so we need not worry if this ain't a perfect merge 

keep if _merge == 3
drop _merge

//check for unique entries on which the merge has to happen 

// WAY 1  (explained earlier) 
//cond(_N == 1, 0, _n) assigns a value of 0 if the unique_id appears only once. If there are duplicates, it assigns a sequential number (_n) to each occurrence.
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID 

//WAY 2
bysort unique_id comb_name_from_earlier_hh: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

//doing a manual check
br unique_id comb_name_from_earlier_hh dup_UID if dup_UID > 0
//no duplicates found! --> we can treat this as a unqiue idnetifier


// please note that we are temporarily creating a clone variable this because we will use this to decide which entries should be dropped. This variable will help us in understanding which are the main endline census that need to be dropped because they were unavailable and which need to be replaced with revisit entries. Only those entries would be replaced where main endline census entry was unavailable and revisit entry was available. This variable shows the availability of the main respondent to whom this section was administered that is why it makes sense to verify entries using this variable  

clonevar V_R_E_instruction  = R_E_instruction 

foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

save "${DataTemp}temp3.dta",  replace


//using main endline census roster dataset for census members only (created above- please check)
use "${DataTemp}temp0.dta", clear
/*as flagged earlier  these 2 IDs have duplicats: 
unique_id	comb_name_from_earlier_hh
30202109013	Pinky Kandagari
30202109013	Pinky Kandagari
30602105049	Priya Koushalya
30602105049	Priya Koushalya
Since we are creating a unqiue identifier using these two variables - unique_id  comb_name_from_earlier_hh so for merge purposes we need to make these two cases unique so that merge can happen.  For now, I am replacing one of the two names with _prefix and later on after consulting with Jeremy and Akito we can see how to go about this 
*/

//temporary replacement 
replace comb_name_from_earlier_hh  = "_Pinky Kandagari" if comb_name_from_earlier_hh == "Pinky Kandagari" & unique_id == "30202109013" & comb_days_num_residence == 2  & comb_hh_index == "1"

replace comb_name_from_earlier_hh  = "_Priya Koushalya" if comb_name_from_earlier_hh == "Priya Koushalya" & unique_id == "30602105049" & comb_days_num_residence == 8  &  comb_hh_index == "8"


preserve
merge 1:1 unique_id  comb_name_from_earlier_hh   using "${DataTemp}temp3.dta", keepusing(unique_id comb_name_from_earlier_hh V_R_E_instruction ) 

/*WHY IS THE A FULLY IMPERFECT MERGE : 

The reason there are 0 matches is because this is a conditional section which means this section gets asked to the main respondent only when main respondent is available to answer this. So, in the temp0 dataset which is the main endline roster dataset it had only those entries where main respondent was available because in the cases where main respondent wasn't available there would be an empty entry that would be generated which we have already dropped ( check drop if name_from_earlier_hh == "") and the same logic applies for the revisit dataset for that reason when we merge these two datasets we get 0 matches so we don't need to worry as exactly this should happen.  To, the merged dataset has the entries where unavailable cases in main census were available and availabile cases from the main endline census 

Conclusion: No drop is required 
*/
restore

//appending with revisit ccensus roster dataset
append using "${DataTemp}temp3.dta"

drop V_R_E_instruction  //this was created only for verification purposes so can drop this 

save "${Intermediate}Endline_census_roster_merged_dataset_final.dta", replace 


/***********************************************************************************

CREATING A COMBINED ROSTER FOR NEW MEMBERS AND CENSUS MEMBERS 

************************************************************************************/
use "${Intermediate}Endline_census_roster_merged_dataset_final.dta", clear

append using "${Intermediate}Endline_New_member_roster_dataset_final.dta"

save "${Intermediate}Endline_roster_merged_census_New_final.dta", replace



/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

/*****************************************************************
WOMEN LEVEL DATASETS MERGE BETWEEN MAIN ENDLINE AND REVISIT
*****************************************************************/

* ID 21
//census women data from main endline census 
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
drop if comb_resp_avail_comb == .  //these are irrelevant entries so we can drop it 
rename key R_E_key	 

merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str) 

//there are 104 IDs from master that don't match the reason is because these are practise entries from the endline census and 31 that don't match from using are not applicable for this so that is why there are 135 unmatched IDs and it is okay to have this imperfect match 

keep if _merge == 3
drop _merge 

cap drop dup_HHID

//finding duplicates 

// WAY 1  (explained earlier) 
//cond(_N == 1, 0, _n) assigns a value of 0 if the unique_id appears only once. If there are duplicates, it assigns a sequential number (_n) to each occurrence.
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID 
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_UID> 0


//WAY 2
bysort unique_id comb_name_comb_woman_earlier: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_HHID > 0


/*
One duplicate found !

How to identify which duplicate to drop? 
*********************************************
//also did the manual check and this is the only duplicate found
//here we find that on UID - 30202109013  there are two women with the same name that is "Pinky Khandagiri" but they are different people so we have to rename one women so in this case I am renaming unmarried Pinky Khandagrii by adding a suffix underscore in her name 
we need to make sure that the replacement is consistent with the replacement done in the roster dataset and the only way to identify this is by the index number. The command in the roster section is -
replace comb_name_from_earlier_hh  = "_Pinky Kandagari" if comb_name_from_earlier_hh == "Pinky Kandagari" & unique_id == "30202109013" & comb_days_num_residence == 2  & comb_hh_index == 1
Here you will see that index number of _Pinky is 1 that means her index number in women section should also be 1 and the variable comb_preg_index reflects index in this dataset so since that is 1 too we will replace this Pinky with _Pinky 
*/
replace comb_name_comb_woman_earlier  = "_Pinky Kandagari" if comb_name_comb_woman_earlier == "Pinky Kandagari" & unique_id == "30202109013"   & comb_preg_index == "1"
gen C_entry_type = "BC" 
save "${DataTemp}temp1.dta", replace


 //using new women data from main endline census 
 * ID 22
//new women
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
M_key_creation
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
drop if comb_resp_avail_comb == .  //these are irrelevant entries so we can drop it 

	 
rename key R_E_key	 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str) 

//there are 730 unmatched: 16 from master and 714 from using so this is absolutely okay because this is not supposed to have perfect merge 
keep if _merge == 3
drop _merge


//finding duplicates 

// WAY 1  (explained earlier) 
//cond(_N == 1, 0, _n) assigns a value of 0 if the unique_id appears only once. If there are duplicates, it assigns a sequential number (_n) to each occurrence.
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID 
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_UID> 0

/*unique_id	comb_name_comb_woman_earlier
30301104006	111(Ambi praska)
unique_id	comb_name_comb_woman_earlier
40202113033	111 Simadri Manbik
unique_id	comb_name_comb_woman_earlier
40301113016	111 Triveni gouda*/


//WAY 2
bysort unique_id comb_name_comb_woman_earlier: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_HHID > 0

	 
gen C_entry_type = "N" 
 
save "${DataTemp}temp2.dta", replace

use "${DataTemp}temp1.dta", clear
append using "${DataTemp}temp2.dta"
unique R_E_key key3
unique unique_id comb_name_comb_woman_earlier
isid unique_id comb_name_comb_woman_earlier

cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

save "${Intermediate}CBW_merge_Endline_census.dta", replace

 

 /*please know that counterpart section for new women has empty data which is this because we didn't any new women in ednline revisit:  use"${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_CBW_followup.dta", clear
 That is why we are using only comb dataset */
  
 
 //women data from endline revisit survey (only comb section) 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_CBW_followup.dta", clear
RV_key_creation

foreach var of varlist *_cbw* {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
	 
drop if comb_name_comb_woman_earlier == ""
drop if comb_resp_avail_comb == .
gen C_entry_type = "RV" 
gen comb_type = "comb"
 
 rename key R_E_key
 
 merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_village_name_str) keep(3) nogen
 
 unique unique_id comb_name_comb_woman_earlier
 
 //////////////////////////////////////////////////
 //finding duplicates 
////////////////////////////////////////////////////

// WAY 1  (explained earlier) 
//cond(_N == 1, 0, _n) assigns a value of 0 if the unique_id appears only once. If there are duplicates, it assigns a sequential number (_n) to each occurrence.
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID 
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_UID> 0

//WAY 2
bysort unique_id comb_name_comb_woman_earlier: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
sort unique_id 
br unique_id comb_name_comb_woman_earlier if dup_HHID > 0

/* why replicate this variable? 
Approach: As explained earlier, to do this merge we need to first replicate availability variable from endline women dataset because we will drop only those rows from main endline census women data where the entry was unavailable and replace it with the women revisit data where that specific entry was available and completed but for that we need to do one-on-one comparison that is why we need to rename this availability variable ( comb_resp_avail_comb) from the revisit dataset
*/
clonevar Vcomb_resp_avail_comb = comb_resp_avail_comb 

foreach i in parent_key key_original R_E_key key2 key3{
rename `i' Revisit_`i'
}

 save "${Intermediate}comb_women_endline_revisit.dta", replace
 



/*************************************************************
DOING THE MERGE WITH CENSUS WOMEN

*************************************************************/
//importing combined women data from endline main census 
use "${Intermediate}CBW_merge_Endline_census.dta", clear
cap drop _merge
merge 1:1 unique_id comb_name_comb_woman_earlier using "${Intermediate}comb_women_endline_revisit.dta", keepusing(unique_id Vcomb_resp_avail_comb) 

//finding the entries where entry from main endline census women dataset is unavailable and the similar entry is available in revisit data 
br unique_id comb_preg_index comb_name_comb_woman_earlier comb_resp_avail_comb Vcomb_resp_avail_comb _merge if _merge == 3 & Vcomb_resp_avail_comb == 1

//dropping such entries where entry from main endline census women dataset is unavailable and the similar entry is available in revisit data  because we have valid data for such entries from revisit data 
gen to_drop = .
replace to_drop = 1 if _merge == 3 & Vcomb_resp_avail_comb == 1 & comb_resp_avail_comb ! = 1

drop if to_drop == 1

preserve 
use "${Intermediate}comb_women_endline_revisit.dta", clear
drop if comb_resp_avail_comb != 1
drop Vcomb_resp_avail_comb
save "${DataTemp}comb_women_endline_revisit_t.dta", replace
restore

append using "${DataTemp}comb_women_endline_revisit_t.dta"
cap drop _merge
cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

save "${Intermediate}Endline_CBW_level_merged_dataset_final.dta", replace 



/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 4
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

/*****************************************************************************
CREATING A SEPARATE MORTALITY DATASET ONLY USING ENDLINE DATASETS
******************************************************************************/

use"${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", clear

use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_start_5_years_pregnant-comb_child_died_repeat.dta", clear



/* ---------------------------------------------------------------------------
* ID 19 and 20: Mortality info
 ---------------------------------------------------------------------------*/
 * ID 19
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta", clear
key_creation 
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=3
save "${DataTemp}temp.dta", replace

* ID 20
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", clear
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
     }
gen Cen_Type=2
append using "${DataTemp}temp.dta"
save "${DataFinal}1_1_Endline_Mortality_19_20.dta", replace



/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 5
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

  /*****************************************************************
 1. CLEANING COMBINED CHILD DATASET FIRST 
*****************************************************************/

use "${Intermediate}Endline_Child_level_merged_dataset_final.dta", clear

*Duplicates check 
//the only unqiue identifier in the child dataset is these two variables 
isid unique_id comb_child_comb_name_label

*Manual corrections from Github issues page- https://github.com/DevInnovationLab/i-h2o-india/issues


/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 6
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/


  /*****************************************************************
 COMBINING ALL INDIVIDUAL DATASETS 
*****************************************************************/

use "${Intermediate}Endline_Child_level_merged_dataset_final.dta", clear
gen C_dataset_type = "Child"
append using "${Intermediate}Endline_roster_merged_census_New_final.dta"
replace C_dataset_type = "Roster" if  comb_name_from_earlier_hh != "" |  comb_hhmember_name != ""
append using "${Intermediate}Endline_CBW_level_merged_dataset_final.dta"
replace C_dataset_type = "CBW" if  comb_name_comb_woman_earlier != ""

//Please tabulate this variable: C_dataset_type  to get the breakdown of each type of dataset present in this master dataset 
order C_dataset_type 

save "${DataFinal}Master_Individual_data_endline_census.dta", replace





/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 7
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

  /*****************************************************************
 Data creation of the consented indiviudal datasets 
*****************************************************************/

//Creating consented child dataset for analysis 
use "${DataFinal}Master_Individual_data_endline_census.dta", clear
keep if C_dataset_type  == "Child" 
ds // list all variables
foreach var of varlist * {
    // Calculate the number of non-missing values for the variable
    count if !missing(`var')
    // Drop the variable if all values are missing
    if r(N) == 0 {
        drop `var'
    }
}
keep if comb_child_caregiver_present == 1
cap drop Vcomb_resp_avail_comb //keeping only available and consented ones 
save "${DataFinal}Child_consented_individual_endline_census.dta", replace

//creating consented women dataset for analysis 
use "${DataFinal}Master_Individual_data_endline_census.dta", clear
keep if C_dataset_type  == "CBW" 
ds // list all variables
foreach var of varlist * {
    // Calculate the number of non-missing values for the variable
    count if !missing(`var')
    // Drop the variable if all values are missing
    if r(N) == 0 {
        drop `var'
    }
}
keep if comb_resp_avail_comb == 1 //keeping only available and consented ones 
cap drop Vcomb_resp_avail_comb
save "${DataFinal}CBW_consented_individual_endline_census.dta", replace


//creating consented roster dataset for analysis 
use "${DataFinal}Master_Individual_data_endline_census.dta", clear
keep if C_dataset_type  == "Roster" 
ds // list all variables
foreach var of varlist * {
    // Calculate the number of non-missing values for the variable
    count if !missing(`var')
    // Drop the variable if all values are missing
    if r(N) == 0 {
        drop `var'
    }
}
keep if R_E_instruction == 1 //keeping only available and consented ones 
cap drop Vcomb_resp_avail_comb
save "${DataFinal}Roster_consented_individual_endline_census.dta", replace












/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 8
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/
  
  /*****************************************************************
 AVAILABILITY STATS 
*****************************************************************/

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

use "${Intermediate}Endline_Child_level_merged_dataset_final.dta", clear

drop if comb_child_comb_name_label== ""
drop if comb_child_caregiver_present == .
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








//unique ID creation 
/*sort the people by age 
drop it in the cleaning
gen a variable using UID and sequential numbers
assign in the raw dataset itself */











