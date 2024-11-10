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
*******Files that were run to get these datasets - 
"GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2.do" to create indiviudual main endline census datasets 
"GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2_revisit.do" to create individual revisit endline census datasets 
"GitHub\i-h2o-india\Code\1_profile_ILC\1_8_A_Endline_cleaning.do" to get HH level clean main endline census dataset 
"GitHub\i-h2o-india\Code\1_profile_ILC\1_9_A_Endline_Revisit_cleaning.do" to get HH level clean revisit endline census dataset

****** Note on Prefixes used: R_Cen_: Raw Baseline Census Variable; R_E_cen_: Raw Endline Census Variable (census members); R_E_n_: Raw Endline Census Variable (new members); comb_: ; C_Cen_: Coded/New Baseline Census Variable; C_E_: Coded/New Endline Census Variable; C_: Coded/New variables for both Basleine and Endline Census


Dataset prefix Explanation- 
1_8_ : Main endline census 
1_9_ : Revisit endline census 
1_10_ : Merged main and revisit endline census data
1_10_Cl_ : Cleaned Merged main and revisit endline census data
0_Master_10_ : Master combined endline individual datasets
1_11_ : Clean and consented Merged main and revisit endline census data
1_1_ : Baseline census data 
1_12_Cl_ : Combined baseline and endline cleaned dataset
0_Master_12_ : Master combined baseline-endline individual level dataset
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
Census Data Prefix System Explanation
-----------------------------------------------
In the main endline census, prefixes are used to distinguish between existing and new entries:

-->>N_ prefix: Identifies new entries not present in the baseline census.
-->>Cen_ prefix: Marks entries that originated from the baseline census.
~The comb_ prefix indicates a combined dataset that merges entries from the main endline census and new additions. This combined dataset is created in the file 1_8_A_Endline_cleaning_HFC_Data_creation.

For the endline revisit census, the comb_ prefix includes:
-->>Individuals from the main endline census who were listed in the baseline (Cen_ prefix).
-->>New individuals recorded in the main endline census who were not part of the baseline.

_________________________________________________________________________________
Rationale for Using the comb_ Prefix in Endline Revisit Census
__________________________________________________________________________________
The comb_ prefix was applied to ensure consistency in data organization by combining entries marked Cen_ (from the baseline) and N_ (new entries) in the main endline census. This approach avoided several potential issues:

###Avoiding Duplicate New Entries:
Using N_ for revisit cases would create confusion by mixing new entries from the main census with new names recorded in the revisit. For instance, if a new entry was added in the revisit due to an initial unavailability, distinguishing between these and main census new entries would be challenging without the comb_ prefix. This prefix helped clarify which entries were from the main endline versus the revisit, avoiding redundant processing steps.

###Simplifying Survey CTO Coding:
The comb_ prefix also streamlined coding in Survey CTO by keeping loops separate for preloaded names (comb_) and new entries, ensuring easier data import and analysis. Mixing entries without this distinction would have increased complexity in analysis and data handling.

Thus, the comb_ prefix unified the data, simplifying both data consistency and processing across different stages.

####################################
💀 Variables with N_ prefix 
####################################

By now you would know, what does N_ mean. These are new entries from endline revisit census that means they were not recorded anywhere nor in the main endline census becasue they are just revisit level new. 
	
Conclusion: That is why you see two prefix in the revisit form: comb_ and N_ 
*/

/*****************************************************
Why are we creating dated versions of the dataset?
******************************************************/
//We use date suffixes (e.g., "24oct24") in dataset names to ensure consistency in unique ID generation, even if datasets are updated later. Since unique IDs are generated from raw datasets, any updates could alter the ID assignments. By saving dated versions, we retain consistency across versions. These versions are created manually by copying the main raw dataset and adding the date suffix—no automated script is used for this process.
 
 //////////////////////////////////////////////////////////////////////////////
**objective of the next steps

/* We are firstly combining revisit long datasets into one. So, we are combining entries with comb_ and N_ into comb_ to keep it consistent with main endline census. */
////////////////////////////////////////////////////////////////////////////

 * RV_ID 24 ( Don't get confused by these numbers..this is just a way to notify the dataset). Focus more on what that dataset contains! )
 
//no data in the dataset below because no new member included. This being empty means there were no new children included in the revisit form so our work gets easier.
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_child_followup.dta", clear

//specify what long is here and specify the unit 
 * RV_ID 23 (The dataset below contains enteris for combined child enteries i.e. the nams in the preload) 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_child_followup_24oct24.dta", clear
  
 //generating unique_id 
 *sorting child names alphabetically
 sort comb_child_u5_name_label 
 gen UID_1 = _n
 
  //checking if child name is unique for every key 
 bysort key comb_child_u5_name_label : gen dup_key = cond(_N==1,0,_n)
count if dup_key > 0 
tab dup_key
drop dup_key
*JL: What exactly is getting dropped above? How many duplicate cases? Or is it 0? 

RV_key_creation //we have already defined this function above 

foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
// to make variable structure uniform across revisit and main dataset comb_child_u5_name_label comb_main_caregiver_label comb_child_caregiver_present comb_child_care_pres_oth comb_child_act_age comb_med_symp_u5 comb_med_symp_u5_1 comb_med_symp_u5_2 comb_med_symp_u5_3

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

//concatnating unique_id with UID_1 to generate a unique identifier for children
tostring UID_1, replace
gen IN_unique_id = unique_id + UID_1
isid IN_unique_id  //this is our unique_id variable for child level dataset 

//Now sometimes you don't need unavailable entries for analysis so we can just keep relevant variables.  So, if you don't wnat to use unavailable cases in analysis feel free to keep only the available ones by using this variable 
* Respondent available for an interview 
/*keep if comb_child_caregiver_present==1
*/

//wohoo we have got our combined revisit child dataset
save "${Intermediate}1_9_Endline_Revisit_U5_Child_23_24.dta", replace   


/* _______________________________________________________________________________________________
Dropping Rows from the Main Endline Child Dataset Using Revisit Data
____________________________________________________________________________________________________

To integrate revisit data into the main endline child dataset, certain rows in the main dataset need to be identified and dropped. Here’s the structured approach, with an example for clarity.

*********Steps to Integrate Revisit Data into the Main Dataset**********

1) Rename Key Variables in Revisit Data
Rename variables (comb_main_caregiver_label and comb_child_caregiver_present) in the revisit dataset. This helps distinguish entries from the main dataset and identify which to keep or replace. 

2) Merge Datasets for Comparison
Merge the revisit and main datasets using unique identifiers (e.g., unique ID and child name). This 1:1 merge helps identify which entry to retain based on data completeness.
#Example: For UID - 1234567 and child name - Sukesh, suppose Sukesh was unavailable in the main census but included in the revisit data. If we now have good data for Sukesh in the revisit, we’ll drop Sukesh’s entry from the main dataset and retain the revisit entry. Without the 1:1 merge and comparison using unique ID and comb_child_comb_name_label, we wouldn’t be able to perform this replacement accurately. Verify uniqueness with:
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1, 0, _n)
count if dup_HHID > 0
tab dup_HHID
Tabulating this would tell us how many duplicate pairs are there. In our case, there are none so we are good to go!!! 🚗 🚗 🚗 So, that is why we are renamining variables: comb_main_caregiver_label and  comb_child_caregiver_present because they are going to be used for verification if we are actually droppping the right entry or not! 

3) Flag Unavailable Entries in Main Dataset
After merging, flag entries where the child was marked unavailable in the main dataset (using comb_child_caregiver_present). Only unavailable IDs from the main endline census were included in the revisit, so we ensure we don’t drop valid main dataset observations.

4) Verify Data Consistency
Conduct a manual check to confirm entries in both datasets match exactly for consistency in fields like caregiver names. for eg - it shouldn't be the case that Sukesh's caregiver names are different! After you have done some manual comparison that you are actually looking at the smame UID and child name you go to step 5

5) Mark and Drop Rows for Replacement
Create a variable to_drop to mark rows to be removed from the main dataset. Set to_drop = 1 if Vcomb_child_caregiver_present == 1 and _merge == 3, which indicates an unavailable entry in the main dataset that has a valid entry in the revisit. Execute:
drop if to_drop == 1
Explanation: In Sukesh’s case, if Vcomb_child_caregiver_present == 1 indicates Sukesh was surveyed in the revisit, we can safely drop Sukesh’s entry from the main dataset and retain the revisit data as the updated entry.

6) Check for Duplicates
To confirm there are no unintended duplicates, use either:
#Method 1: Sort by key variables and manually verify that repeated keys have consistent child names (most accurate).
#Method 2: Check key and child name pairs to confirm unique entries.
*/
*****************************************************************************************************************************************************
use "${Intermediate}1_9_Endline_Revisit_U5_Child_23_24.dta", clear   
cap drop _merge
/*//we must rename these variables because these variables are present in the main endline census child level dataset too so we need these 2 variables for verification and . V prefix stands for verification here. */

/* 
Caregiver Name Variables in Revisit Survey
_____________________________________________________

There are two caregiver name variables:

1) comb_child_comb_caregiver_label: Used in the revisit survey to record the current caregiver answering questions for the child, especially if they differ from the initial caregiver.
2) comb_main_caregiver_label: Preloaded from the main endline survey to guide enumerators to the originally identified caregiver. However, if the original caregiver is unavailable, the new caregiver’s name is recorded in comb_child_comb_caregiver_label.
that is why comb_main_caregiver_label (in revisit survey) and comb_child_comb_caregiver_label (main endline survey) are literally the same thing becaus ethey are actual caregiver of the children. (I will rename this while combing the datasets but for comparsion purpose we need to rename them here) */
rename comb_main_caregiver_label Vcomb_child_comb_caregiver_label
rename comb_child_caregiver_present Vcomb_child_caregiver_present
rename IN_unique_id VIN_unique_id //renaming this to check if correct UIDs are being preserved 
cap drop dup_HHID
//WAY 2
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
br comb_child_comb_name_label dup_UID if dup_UID != 0

drop dup_UID 
//we haven't found any duplicates in the child dataset 

save "${DataTemp}1_9_Endline_Revisit_U5_Child_23_24_temp1.dta", replace


/*******************************************************************************************

Creating a combined child dataset from main endline census 

**********************************************************************************************/
 
 * ID 23
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_child_followup_24oct24.dta", clear

 //generating unique_id 
 *sorting child names alphabetically
 sort cen_child_u5_name_label
 gen UID_1 = _n  //function that gives serial numbers  //use the same digits for the number of serial number 
 * JL: What is happening above here? Need more comments?
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
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_child_followup_24oct24.dta", clear
 //generating unique_id 
 *sorting child names alphabetically
 sort n_child_u5_name_label
 gen UID_1 = _n
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

//concatnating unique_id with UID_1 to generate a unique identifier for children
* JL: What is the unique ID format for pairing the children? Can you type out an example here?
tostring UID_1, replace
gen IN_unique_id = unique_id + UID_1
isid IN_unique_id  //this is our unique_id variable for child level dataset 


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

save "${Intermediate}1_8_Endline_U5_Child_23_24.dta", replace
/*This dataset has to be renamed everywhere especially in the files that Akito and Archi's files used  
save "${DataTemp}U5_Child_23_24_part1.dta", replace*/

use "${Intermediate}1_8_Endline_U5_Child_23_24.dta", clear
//checking if this combination is unique or not. If its not, then we won't be able to perform 1:1 merge. Please note that we can't perform this 1:1 merge over keys because they are different in both the datasets 
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

SOLUTION: How was this duplicate treated?
I dropped the entries where comb_child_caregiver_present == .  was empty because 111-Ranbir sabar and  Ranveer sabar
 is the same child and enum entered his name again to write the correct age but he still falls oit of our criteria so we this entry gets dropped when we drop comb_child_caregiver_present == . 
*/

//merging the main child level dataset with the endline level child dataset on UID and child name. I am retaining some of the variables from using dataset for comparison as explained earlier 
cap drop _merge
merge 1:1 unique_id comb_child_comb_name_label  using "${DataTemp}1_9_Endline_Revisit_U5_Child_23_24_temp1.dta", keepusing(unique_id comb_child_comb_name_label Vcomb_child_caregiver_present Vcomb_child_comb_caregiver_label VIN_unique_id ) 

//we can just browse and check fi there is any unique ID and child combination where main caregiver doens't matches because these are the preloaded names so they should all match. After doing this you will find that there are 0 mismatches 😁
br comb_child_comb_name_label comb_child_caregiver_present comb_child_comb_caregiver_label Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present if comb_child_comb_caregiver_label != Vcomb_child_comb_caregiver_label & _merge == 3

/*
.........................................................................................................................................................
Objective of the exercise below: 🐻‍❄️
.........................................................................................................................................................

*****Replacing Child Records from Revisit Survey in Main Dataset******

Instead of directly replacing rows from the revisit survey in the main dataset, we remove rows in the main dataset where a child (indicated by a unique ID) was initially unavailable but later surveyed during the revisit round. Here’s the process:
1) Identify Unavailable Entries: Use the variable comb_child_caregiver_present to confirm if a child was unavailable in the main dataset but revisited and surveyed.

2) Avoid m:m Merge Complications: Instead of merging (which complicates with m
matches), we append the revisited data to the main dataset. This method minimizes discrepancies.

3) Check _merge == 3: A _merge == 3 match indicates the entry is in both datasets. However, this alone isn’t enough to decide whether to keep or drop it.

4) Confirm Availability with Vcomb_child_caregiver_present: If Vcomb_child_caregiver_present equals 1, it means the child was revisited and surveyed. We then add this revisited data to the main dataset and drop the original unavailable entry to avoid duplicates.

All other matched entries from the main dataset can be retained if they were also unavailable during the revisit, as replacing them would add unnecessary effort without new data.
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
use "${Intermediate}1_9_Endline_Revisit_U5_Child_23_24.dta", clear  
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

/*Why the steps below? 
In the endline revisit, prefix comb signifies that it contains both census or new entries from main endline census, so we also need to know whatever comb variables we have in our revisit dataset how many are census entries and how many are new entries from the main endline census. For that purpose, we need to do a 1:1 merge between revisit and main dataset to get what each entry belongs to 
*/
//renaming this temporarily because this is a common var in main and revisit dataset so to do one on one comparsion they need to have different names 
rename C_entry_type RV_C_entry_type
//C_entry_type gives the categorisation of whther that entry was a Census or new entry 
merge 1:1 unique_id comb_child_comb_name_label  using "${Intermediate}1_8_Endline_U5_Child_23_24.dta" , keepusing(unique_id comb_child_comb_name_label C_entry_type) 
keep if _merge == 3
//creating another variable that signifies the breakdown of revisit entries like whether they were new or census from the main endline census 
clonevar C_RV_entry_type = C_entry_type 
//dropping this as we are done comparing
drop C_entry_type 
//renaming it again to make the variable consistent after we are done wit manual comaprison
rename RV_C_entry_type C_entry_type
//we will use the following dataset for append 
save "${DataTemp}1_9_Endline_Revisit_U5_Child_23_24_temp.dta", replace
restore

append using "${DataTemp}1_9_Endline_Revisit_U5_Child_23_24_temp.dta"

//checking for duplicates UID and child name wise. It is imp that there are no duplicates. This shows the append was successul. You will also see the number of observations hasn't changed
cap drop dup_HHID
bysort unique_id comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

/*IMP NEXT STEP : We need to check if the variable names are similar throughout these long datasets if not, we must make it similar 🤠
Lets drop variables with V prefix because we just created them for comparsion purpose. I have already renamed caregiver label so fret not!
There doens't seem to be any extra variables that need renaming so lets move on
*/
drop Vcomb_child_comb_caregiver_label Vcomb_child_caregiver_present VIN_unique_id 

//br unique_id comb_child_comb_name_label comb_main_caregiver_label comb_child_caregiver_present comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_month comb_child_breastfed_days comb_child_care_dia_day if unique_id == "30301109053"
cap drop _merge
drop if comb_child_caregiver_present == .
save "${Intermediate}1_10_Endline_Child_level_merged_dataset_final.dta", replace 

//unique_id	comb_child_comb_name_label
//40202113033	111 Simadri Manbik

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

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop_24oct24.dta", clear
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
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_instruction R_E_village_name_str R_E_enum_name_label) 

//there are around 16 keys that don't match with cleaned endline census data and that is because these are practise entries observations from endline census so in the long dataset unless we manually drop it it would still be present so we should just keep _mereg == 3
keep if _merge == 3
drop _merge

gen C_entry_type = "N" 
drop if R_E_instruction == .


//check for unique entries on which the merge has to happen 

// WAY 1  (explained earlier) 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 


//WAY 2
bysort unique_id comb_namefromearlier: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

//no duplicates found 

save "${DataTemp}temp2.dta", replace

save "${Intermediate}1_8_Endline_New_member_roster_dataset_final.dta", replace 

********************************************************************************************************************************



* ID 25
//census roster in the main endline census dataset 
///This dataset is created in the "GitHub\i-h2o-india\Code\1_profile_ILC\0_Preparation_V2.do"
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop_24oct24.dta", clear
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
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_instruction R_E_village_name_str R_E_enum_name_label  )

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
use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop_24oct24.dta", clear
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

merge m:1 R_E_key using "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", keepusing(unique_id R_E_instruction R_E_village_name_str R_E_enum_name_label)

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
//we also want to know what kind of revisit value it is, since in this case these are census entries from the preload we will just replace the values with BC 
gen C_RV_entry_type = "BC" 
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

//manual replacement
replace comb_name_from_earlier_hh  = "_Pinky Kandagari" if comb_name_from_earlier_hh == "Pinky Kandagari" & unique_id == "30202109013" & comb_days_num_residence == 2  & comb_hh_index == "1"

replace comb_name_from_earlier_hh  = "_Priya Koushalya" if comb_name_from_earlier_hh == "Priya Koushalya" & unique_id == "30602105049" & comb_days_num_residence == 8  &  comb_hh_index == "8"


preserve
merge 1:1 unique_id  comb_name_from_earlier_hh   using "${DataTemp}temp3.dta", keepusing(unique_id comb_name_from_earlier_hh V_R_E_instruction ) 

/*WHY IS THE A FULLY IMPERFECT MERGE : 

*********No Matches Found During Dataset Merge: Explanation and Conclusion********

When merging the main endline roster dataset (temp0) with the revisit dataset, you may observe zero matches. Here’s why this occurs and why no further action is needed:

##Reason for Zero Matches
1) Conditional Section Only for Available Respondents
 --->Main Endline Roster (temp0): Contains only entries where the main respondent was available. Entries with unavailable main respondents have been removed using:
drop if name_from_earlier_hh == ""
--->Revisit Dataset: Similarly, includes only entries where the main respondent was available and revisited.

###No Overlapping Entries
---> Since both datasets exclusively contain entries with available main respondents, there are no common values between them. Thus, merging results in zero matches, which is the expected outcome.

###Master Dataset Clarification
---> Master Dataset: Refers solely to the main census roster, not the appended version that includes new entries.
---> New Roster: Only includes entries where the main respondent was available. Cases with unavailable main respondents are excluded, ensuring no common entries with the revisit dataset.

###Conclusion
---> No Rows to Drop: The absence of matches confirms that the datasets are correctly segregated. Unavailable cases have been appropriately excluded, and available cases are uniquely present in their respective datasets.
---> Data Integrity Maintained: This ensures there are no duplicate or conflicting entries, maintaining the integrity and accuracy of the final dataset.

By understanding this process, you can be confident that the dataset merge behaves as intended, with no unnecessary rows to drop.Conclusion: No drop is required 
*/
restore

//appending with revisit ccensus roster dataset
append using "${DataTemp}temp3.dta"

drop V_R_E_instruction  //this was created only for verification purposes so can drop this 

save "${Intermediate}1_10_Endline_census_roster_merged_dataset_final.dta", replace 


/***********************************************************************************

CREATING A COMBINED ROSTER FOR NEW MEMBERS AND CENSUS MEMBERS 

************************************************************************************/
use "${Intermediate}1_10_Endline_census_roster_merged_dataset_final.dta", clear
append using "${Intermediate}1_8_Endline_New_member_roster_dataset_final.dta"
clonevar Village = R_E_village_name_str 
merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)
save "${Intermediate}1_10_Endline_roster_merged_census_New_final.dta", replace


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
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup_24oct24.dta", clear
  //generating unique_id 
 *sorting women names alphabetically
sort cen_name_cbw_woman_earlier
gen UID_1 = _n
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

//concatnating unique_id with UID_1 to generate a unique identifier for women
tostring UID_1, replace
gen IN_unique_id = unique_id + UID_1
isid IN_unique_id  //this is our unique_id variable for women level dataset 

save "${DataTemp}temp1.dta", replace


 //using new women data from main endline census 
 * ID 22
//new women
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup_24oct24.dta", clear
  //generating unique_id 
 *sorting women names alphabetically
sort n_name_cbw_woman_earlier
gen UID_1 = _n
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
//concatnating unique_id with UID_1 to generate a unique identifier for women
tostring UID_1, replace
gen IN_unique_id = unique_id + UID_1
isid IN_unique_id  //this is our unique_id variable for women level dataset 
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

save "${Intermediate}1_8_Endline_census_CBW_merge.dta", replace

 

 /*please know that counterpart section for new women has empty data which is this because we didn't any new women in ednline revisit:  use"${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_CBW_followup.dta", clear
 That is why we are using only comb dataset */
  
 
 //women data from endline revisit survey (only comb section) 
 use "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_CBW_followup_24oct24.dta", clear
 sort comb_name_cbw_woman_earlier
gen UID_1 = _n
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
//concatnating unique_id with UID_1 to generate a unique identifier for women
tostring UID_1, replace
gen IN_unique_id = unique_id + UID_1
isid IN_unique_id  //this is our unique_id variable for women level dataset 
 save "${Intermediate}1_9_endline_revisit_CBW_merge.dta", replace
 



/*************************************************************
DOING THE MERGE WITH CENSUS WOMEN

*************************************************************/
//importing combined women data from endline main census 
use "${Intermediate}1_8_Endline_census_CBW_merge.dta", clear
cap drop _merge
merge 1:1 unique_id comb_name_comb_woman_earlier using "${Intermediate}1_9_endline_revisit_CBW_merge.dta", keepusing(unique_id Vcomb_resp_avail_comb) 

//finding the entries where entry from main endline census women dataset is unavailable and the similar entry is available in revisit data 
br unique_id comb_preg_index comb_name_comb_woman_earlier comb_resp_avail_comb Vcomb_resp_avail_comb _merge if _merge == 3 & Vcomb_resp_avail_comb == 1

//dropping such entries where entry from main endline census women dataset is unavailable and the similar entry is available in revisit data  because we have valid data for such entries from revisit data 
gen to_drop = .
replace to_drop = 1 if _merge == 3 & Vcomb_resp_avail_comb == 1 & comb_resp_avail_comb ! = 1

drop if to_drop == 1

preserve 
use "${Intermediate}1_9_endline_revisit_CBW_merge.dta", clear
drop if comb_resp_avail_comb != 1
drop Vcomb_resp_avail_comb
/*Why the steps below? 
In the endline revisit, prefix comb signifies that it contains both census or new entries from main endline census, so we also need to know whatever comb variables we have in our revisit dataset how many are census entries and how many are new entries from the main endline census. For that purpose, we need to do a 1:1 merge between revisit and main dataset to get what each entry belongs to 
*/
//renaming this temporarily because this is a common var in main and revisit dataset so to do one on one comparsion they need to have different names 
rename C_entry_type RV_C_entry_type
//C_entry_type gives the categorisation of whther that entry was a Census or new entry 
merge 1:1 unique_id comb_name_comb_woman_earlier   using "${Intermediate}1_8_Endline_census_CBW_merge.dta" , keepusing(unique_id comb_name_comb_woman_earlier  C_entry_type) 
keep if _merge == 3
//creating another variable that signifies the breakdown of revisit entries like whether they were new or census from the main endline census 
clonevar C_RV_entry_type = C_entry_type 
//dropping this as we are done comparing
drop C_entry_type 
//renaming it again to make the variable consistent after we are done wit manual comaprison
rename RV_C_entry_type C_entry_type
save "${DataTemp}comb_women_endline_revisit_t.dta", replace
restore

append using "${DataTemp}comb_women_endline_revisit_t.dta"
cap drop _merge
cap drop dup_HHID
bysort unique_id comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

clonevar Village = R_E_village_name_str 
merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)

save "${Intermediate}1_10_Endline_CBW_level_merged_dataset_final.dta", replace 


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

//Both the datasets above are empty but we are still importing it to explain why revisit mortality datasets are not being used to create master dataset 

/* ---------------------------------------------------------------------------
* ID 19 and 20: Mortality info
 ---------------------------------------------------------------------------*/
 * ID 19
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat_24oct24.dta", clear
M_key_creation 
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
gen C_entry_type = "BC" 
save "${DataTemp}temp.dta", replace

* ID 20
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat_24oct24.dta", clear
M_key_creation 
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
gen C_entry_type = "N" 
append using "${DataTemp}temp.dta"
rename key R_E_key

//this step is being done to get valid unique IDs and village name 
merge m:1 R_E_key using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing(unique_id R_E_village_name_str R_E_enum_name_label R_E_resp_available R_E_instruction) 

drop if unique_id=="30501107052"

//dropping the obs as it was submitted before the start date of the survey 
drop if unique_id=="10101101001" //need to move it to 

//there are 4 IDs which are in master (mortality dataset) but not in using(main endline dataset) so the explanation for this is below- 
/*
These are all the training IDs of badaalubadi
so we can drop _merge == 1
br if key == "uuid:100f2352-5a9f-430c-bbc2-a12a2deb845b - training ID"
R_E_key
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //training ID 
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //training ID //
uuid:a5994f35-1c8e-4ab9-9687-ad4a7f838140 //traaining ID
*/
//

keep if _merge == 3

drop _merge

/*EXPLANNATION AS TO WHY THESE 2 IDs NEED TO BE DROPPED 

ISSUE: further Issue is that woman said that no child died in the women dataset but the question still asked for information of the dead child which shouldn't be the case. This was a miscarriage case that is why we need to drop it

Explanation to why this might have happened: 
miscarriage question was added later due to which two enums thought miscarriage and stillborn is the same thing which is not that is why this question was added so they went back in the form and changed the stillborn answer to 0 but the loop for child death had started alreaday that is  despite of the constraint this loop still started because they while editing the form they skipped to this section and that is when the child dead quetsion came they entered details but this is not relevant for us in calculating mortality 

that is why you will see that in the women dataset use "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear child dead for these 2 IDs is 0 but still these questions for asked*/

//miscarriage
drop if unique_id== "40301113022" & R_E_key == "uuid:29e4bbf5-a3f2-48a2-93e6-e32c751d834e" 

//miscarriage
drop if unique_id== "40301110002" & R_E_key == "uuid:b9836516-0c12-4043-92e9-36d3d1215961" 

// The option to write father name and gender of the child wasn't getting displayed as a result enum couldn't write it so for this ID I manually entered the values. Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/120
replace comb_fath_child = "Muna himirika" if unique_id == "50401117009" & R_E_key == "uuid:66fe3583-0e49-481a-98da-31393275ceca" 
replace comb_gen_child = 1 if unique_id == "50401117009" & R_E_key == "uuid:66fe3583-0e49-481a-98da-31393275ceca" 

clonevar Village = R_E_village_name_str 
merge m:1 Village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V village Panchatvillage BlockCode) keep(1 3)

save "${DataFinal}1_10_Endline_Mortality_final_cleaned.dta", replace  

/*save "${DataFinal}1_1_Endline_Mortality_19_20.dta", replace
change the name of this dataset in Akito' s and Archi's files
*/

/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 5
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/


********************************************************************************
  /*****************************************************************
 1. CLEANING COMBINED ROSTER DATASET 
*****************************************************************/
********************************************************************************


use "${Intermediate}1_10_Endline_roster_merged_census_New_final.dta", clear
//need to verify if the mid refusal needs to be dropped for the rsoter dataset because we do have applicable data for roster


/*---------------------------------------------------------------------------
Manual corrections 
-----------------------------------------------------------------------------*/

//replacing names with correct surnames - replacing Jilaka with Jilakar. Also chnage this in the baseline census data - Check with Niharika 
replace comb_name_from_earlier_hh = "Pauni Jilakar" if comb_name_from_earlier_hh == "Pauni Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 

replace comb_name_from_earlier_hh = "Raja Jilakar" if comb_name_from_earlier_hh == "Raja Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 

replace comb_name_from_earlier_hh = "Sabitri Jilakar" if comb_name_from_earlier_hh == "Sabitri Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 

replace comb_name_from_earlier_hh = "Mangu Jilakar" if comb_name_from_earlier_hh == "Mangu Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 


/*correcting the village names for the UID (Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/138) 
We found 2 UIDs for which the village name were inter-changed so that's why we need to make the manual replacements for it across all the datasets*/
*replacing bhujbal with tandipur for this ID
replace R_E_village_name_str = "Tandipur"  if  R_E_village_name_str ==  "Bhujbal" & unique_id == "30501119006"
replace Village = "Tandipur"  if Village == "Bhujbal" & unique_id == "30501119006"
replace village = 30301  if village == 30501 & unique_id == "30501119006"
*replacing  tandipur with bhujbal for this ID
replace R_E_village_name_str = "Bhujbal" if  R_E_village_name_str == "Tandipur" & unique_id == "30301119027"
replace Village = "Bhujbal" if Village == "Tandipur"  & unique_id == "30301119027"
replace village = 30501 if village == 30301 & unique_id == "30301119027"

br R_E_village_name_str unique_id R_E_enum_name_label comb_hhmember_age comb_name_from_earlier_hh comb_namefromearlier  if unique_id == "40101111012" //need to get the correct name of the woman here as one of the memebers is written as 999 
//after verification we found that here 999 respondent name is Sabitri kadraka so this needs to be replaced everywhere including baseline census 
replace comb_name_from_earlier_hh = "Sabitri kadraka" if comb_name_from_earlier_hh == "999" & unique_id == "40101111012"

//generating a combined name variable using both census, RV, new entries 
clonevar C_hhmember_name = comb_name_from_earlier_hh
replace C_hhmember_name  =  comb_namefromearlier if C_hhmember_name  == ""

//checking if unique identifier is still intact
isid unique_id C_hhmember_name
sort unique_id

/*---------------------------------------------------------------------------
Outliers  
-----------------------------------------------------------------------------*/

ds  comb_days_num_residence comb_hhmember_age comb_unit_age_months comb_unit_age_days
foreach var of varlist `r(varlist)'{
destring `var', replace
}
ds comb_days_num_residence comb_hhmember_age comb_unit_age_months comb_unit_age_days
foreach var of varlist `r(varlist)'{
summarize `var' if `var' != 888 & `var' != 999 & `var' != 666 & !missing(`var'), detail
gen o`var' = 0
replace o`var' = 1 if `var' != 888 & `var' != 999 & `var' != 666 & !missing(`var') & abs(`var' - r(mean)) > 3*r(sd)
//graph box `var' if `var' != 999 & `var' != 888 & `var' != 666
//graph export "${Figure}endline_outliers_`var'.png", as(png) replace
quietly count if `var' != 0 & !missing(`var')  //Counts the number of non-zero values in the current variable.
    if r(N) == 0 {   //Checks if the count of non-zero values is zero.
        drop o`var'
    }
}

//no concerning outliers found
drop o* 


/*---------------------------------------------------------------------------
Checking consistency of codes for Don't know, others etc
-----------------------------------------------------------------------------*/
ds, has (type numeric)
foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 | `var' == -99 
replace `var' = -98  if `var' == 98 
replace `var' = -77 if `var' == 77
}

//variables labeling
label variable C_entry_type "Does observation belong to baseline census or was a new entry recorded in endline census?"
label variable C_RV_entry_type "What type of revisit entry is it for eg. comb type variables in revisit were both preloaded from main endline census so does the combined entry belong to New or baseline census?"
label variable C_hhmember_name "Combined names of the new or census children" 

/*---------------------------------------------------------------------------
Renaming Variables
-----------------------------------------------------------------------------*/
//giving R_E prefix to all the variables that don't have it already
renpfix R_E_
rename Revisit_R_E_key Revisit_key
//renaming certain variables because they are too long 
rename setofcen_hh_member_names_loop  setofcen_hh_mem_names_loop 
ds
foreach var of varlist `r(varlist)'{
rename `var' R_E_`var'
}
rename R_E_unique_id  unique_id


//Making naming of new generated variables consistent across endline individual and HH level dataset
rename R_E_C_entry_type C_E_entry_type
rename R_E_C_RV_entry_type C_E_RV_entry_type
rename R_E_C_hhmember_name C_E_hhmember_name
drop    R_E_dup_UID R_E_dup_HHID R_E_dup_HHID R_E__merge R_E_comb_type //dropping unecessary variables that were created for temporary calcs

merge m:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing( R_E_resp_available R_E_instruction) nogen  keep(1 3)

save "${Intermediate}1_10_Cl_Endline_roster_merged_census_New_final_cleaned.dta", replace



********************************************************************************
  /*****************************************************************
2. CLEANING COMBINED CHILD DATASET FIRST 
*****************************************************************/
********************************************************************************
use "${Intermediate}1_10_Endline_Child_level_merged_dataset_final.dta", clear
rename  key R_E_key 
*Duplicates check 
//the only unqiue identifier in the child dataset is these two variables 
isid unique_id comb_child_comb_name_label
isid IN_unique_id

/*---------------------------------------------------------------------------
Dropping IDs
-----------------------------------------------------------------------------*/

**Link of the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/139. This is a mid survey refusal so whatever data has been entered after WASH section is not applicable and needs to be dropped 
drop if unique_id == "40202113033"

/*---------------------------------------------------------------------------
Manual corrections 
-----------------------------------------------------------------------------*/
//replacing names with correct surnames - replacing Jilaka with Jilakar. Also chnage this in the baseline census data - Check with Niharika 
replace comb_child_comb_name_label = "Pauni Jilakar" if comb_child_comb_name_label == "Pauni Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 

replace comb_child_comb_name_label = "Raja Jilakar" if comb_child_comb_name_label == "Raja Jilaka" & unique_id == "30602107007" & R_E_key == "uuid:490f0142-4473-4073-8e32-9afd5ffe2e36" 

//enums had entered incorrect code. 666 had to be entered as the code if the HH member has died in the past few months and this was applicable for roster. 988 should be entered in the child section if the child name is already given to you and has not been renamed. This question  comb_child_name  was specifically for new child in case they have been named enums could highlight it here for others they could put 988 
replace comb_child_name  = "988" if  comb_child_name  == "666" 


//unusal case of breastfeeding- the child was breastfed till the age of 1.5 years that is 18 months so this needs to be reflected here as due to constrint enums couldn't reflect 18 in the answer that is why I am doing manual replacements here. Github issue no- https://github.com/DevInnovationLab/i-h2o-india/issues/124 
replace comb_child_breastfed_month = 18 if comb_child_breastfed_month == 11 & unique_id == "40202111029" & R_E_key == "uuid:f97cdef1-a14d-46b3-83b0-2a4ba8cb0a2b" & comb_child_comb_name_label == "Dharmananda sabar" 

//doing multiple replacements for Bhumika Kadraka because enum had reflected 1.5 years in days that is 356 and it was not allowed to add more days so to make it consistent I am chnaging it to 18 months 
replace comb_child_breastfed_month = 18 if comb_child_breastfed_month == . & unique_id == "50201109029" & R_E_key == "uuid:687e106c-5908-4d83-9f30-0fb343ca24ff" & comb_child_comb_name_label == "Bhumika Kadraka" 

replace comb_child_breastfed_days = . if comb_child_breastfed_days == 365 & unique_id == "50201109029" & R_E_key == "uuid:687e106c-5908-4d83-9f30-0fb343ca24ff" & comb_child_comb_name_label == "Bhumika Kadraka" 

replace comb_child_breastfed_num = 1  if comb_child_breastfed_num == 2 & unique_id == "50201109029" & R_E_key == "uuid:687e106c-5908-4d83-9f30-0fb343ca24ff" & comb_child_comb_name_label == "Bhumika Kadraka" 

//correcting breastfeeidng error. The child is still being breastfed and in such cases enum have to write 888 but enum was not able to in this case so she entered 365 days but this needs to be changed to 888 (Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/112) 
replace comb_child_breastfed_num = 888 if comb_child_comb_name_label == "Gurucharan wataka" & unique_id == "50401105012" & R_E_key == "uuid:e3e7c93c-6623-450d-8f26-1d3ecc6abd72" 
replace comb_child_breastfed_days = . if comb_child_breastfed_days == 365 & comb_child_comb_name_label == "Gurucharan wataka" & unique_id == "50401105012" & R_E_key == "uuid:e3e7c93c-6623-450d-8f26-1d3ecc6abd72" 

/*correcting the village names for the UID (Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/138) 
We found 2 UIDs for which the village name were inter-changed so that's why we need to make the manual replacements for it across all the datasets*/
*replacing bhujbal with tandipur for this ID
replace R_E_village_name_str = "Tandipur"  if  R_E_village_name_str ==  "Bhujbal" & unique_id == "30501119006"
replace Village = "Tandipur"  if Village == "Bhujbal" & unique_id == "30501119006"
replace village = 30301  if village == 30501 & unique_id == "30501119006"
*replacing  tandipur with bhujbal for this ID
replace R_E_village_name_str = "Bhujbal" if  R_E_village_name_str == "Tandipur" & unique_id == "30301119027"
replace Village = "Bhujbal" if Village == "Tandipur"  & unique_id == "30301119027"
replace village = 30501 if village == 30301 & unique_id == "30301119027"

/*Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/126
For the variable - comb_med_symp_comb_13 we will find a lot of missing values because Diarrhea was added as an option in the question "What was the symptom, or what was the reason for medical care?" in the health Expenditure module much later. Change was implemented on 4th May 2024 so surveyors started seeing Diarrhea as a separate option from 4th May 2024 onwards*/
//Doing manual replacements for Diarrhea-
replace comb_med_symp_comb_13 = 1 if comb_med_symp_oth_comb == "Diarrhoea" | comb_med_symp_oth_comb == "Diarrher" | comb_med_symp_oth_comb == "Diarrhea,bomiting." | comb_med_symp_oth_comb == "Diarrhea"

/*---------------------------------------------------------------------------
Outliers  
-----------------------------------------------------------------------------*/
ds  comb_child_act_age comb_child_age comb_child_breastfed_month comb_child_breastfed_days comb_child_diarr_wk_num comb_child_diarr_2wk_num comb_child_diarr_freq comb_anti_child_days comb_anti_child_last_months comb_anti_child_last_days comb_med_visits_comb comb_med_nights_comb comb_med_days_caretaking_comb comb_med_t_exp_comb
foreach var of varlist `r(varlist)'{
destring `var', replace
}
ds  comb_child_act_age comb_child_age comb_child_breastfed_month comb_child_breastfed_days comb_child_diarr_wk_num comb_child_diarr_2wk_num comb_child_diarr_freq comb_anti_child_days comb_anti_child_last_months comb_anti_child_last_days comb_med_visits_comb comb_med_nights_comb comb_med_days_caretaking_comb comb_med_t_exp_comb
foreach var of varlist `r(varlist)'{
summarize `var' if `var' != 888 & `var' != 999 & !missing(`var'), detail
gen o`var' = 0
replace o`var' = 1 if `var' != 888 & `var' != 999 & !missing(`var') & abs(`var' - r(mean)) > 3*r(sd)
//graph box `var' if `var' != 999 & `var' != 888
//graph export "${Figure}endline_outliers_`var'.png", as(png) replace
quietly count if `var' != 0  //Counts the number of non-zero values in the current variable.
    if r(N) == 0 {   //Checks if the count of non-zero values is zero.
        drop o`var'
    }
}

//have found 9 cases where the child was breastfed only for a month. To see how to go about this 
br comb_child_breastfed_month ocomb_child_breastfed_month if ocomb_child_breastfed_month != 0
drop o*

/*---------------------------------------------------------------------------
Checking consistency of codes for Don't know, others etc
-----------------------------------------------------------------------------*/
ds comb_child_caregiver_present comb_child_age_v comb_child_residence comb_child_comb_relation comb_child_care_dia_day comb_child_care_dia_wk comb_child_care_dia_2wk comb_child_breastfeeding comb_child_vomit_day comb_child_vomit_wk comb_child_vomit_2wk comb_child_diarr_day comb_child_diarr_wk comb_child_diarr_2wk comb_child_stool_24h comb_child_stool_yest comb_child_stool_wk comb_child_stool_2wk comb_child_blood_day comb_child_blood_wk comb_child_blood_2wk comb_child_cuts_day comb_child_cuts_wk comb_child_cuts_2wk comb_anti_child_wk comb_anti_child_last comb_med_seek_care_comb comb_med_diarrhea_comb comb_translator_comb comb_hh_prsnt_comb
foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 | `var' == -99 
replace `var' = -98  if `var' == 98 
replace `var' = -77 if `var' == 77
}

/*---------------------------------------------------------------------------
Labeling important categories
-----------------------------------------------------------------------------*/
label define comb_child_caregiver_present_x 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "U5 died or is no longer a member of the household" 8 "U5 child no longer falls in the criteria (less than 5 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_child_caregiver_present comb_child_caregiver_present_x

//variables labeling
label variable C_entry_type "Does observation belong to baseline census or was a new entry recorded in endline census?"
label variable C_RV_entry_type "What type of revisit entry is it for eg. comb type variables in revisit were both preloaded from main endline census so does the combined entry belong to New or baseline census?"

/*---------------------------------------------------------------------------
Missing values
-----------------------------------------------------------------------------*/
foreach var of varlist _all {
    quietly count if missing(`var')
    if r(N) > 0 {
        // Action to take if `var` contains missing values
        display "`var' contains missing values"
        // You can replace the above display command with any action you want to take
    }
}

/*---------------------------------------------------------------------------
Renaming Variables
-----------------------------------------------------------------------------*/
//giving R_E prefix to all the variables that don't have it already
renpfix R_E_
rename Revisit_R_E_key Revisit_key
//renaming certain variables because they are too long 
rename comb_child_comb_caregiver_label comb_child_comb_care_label
rename comb_prvdrs_exp_loop_comb_count comb_prvdrs_comb_count
rename comb_med_days_caretaking_comb comb_med_days_care_comb
rename setofcen_prvdrs_exp_loop_comb setofcen_prvdrs_comb
drop RV_comb_child_caregiver_label
rename setofcomb_prvdrs_exp_loop_comb setofcomb_prvdrs_comb 
ds
foreach var of varlist `r(varlist)'{
rename `var' R_E_`var'
}
rename R_E_unique_id  unique_id
rename R_E_IN_unique_id IN_unique_id

//Making naming of new generated variables consistent across endline individual and HH level dataset
rename R_E_C_entry_type C_E_entry_type
rename R_E_C_RV_entry_type C_E_RV_entry_type
drop R_E_dup_HHID R_E_dup_UID R_E_to_drop R_E_Cen_Type R_E_comb_type   R_E_UID_1 //dropping unecessary variables that were created for temporary calcs

/*---------------------------------------------------------------------------
Getting important variables for analysis from other datasets
-----------------------------------------------------------------------------*/
rename R_E_comb_child_comb_name_label C_E_hhmember_name  //renaming this variable so that merge can be done easily 
merge 1:1 unique_id C_E_hhmember_name using "${Intermediate}1_10_Cl_Endline_roster_merged_census_New_final_cleaned.dta", keepusing (unique_id C_E_hhmember_name R_E_comb_hhmember_age R_E_comb_hhmember_gender) gen (match) keep (1 3)
rename C_E_hhmember_name R_E_comb_child_comb_name_label //reverting it to its original name 
drop match
save "${Intermediate}1_10_Cl_Endline_Child_level_merged_dataset_final_cleaned.dta", replace  //Cl notifies clean here 

********************************************************************************
  /*****************************************************************
 3. CLEANING COMBINED CBW/WOMEN DATASET 
*****************************************************************/
********************************************************************************

use "${Intermediate}1_10_Endline_CBW_level_merged_dataset_final.dta", clear 
isid unique_id comb_name_comb_woman_earlier
isid IN_unique_id

/*---------------------------------------------------------------------------
Manual corrections 
-----------------------------------------------------------------------------*/

//Miscarriage question was added later that is why 2 enums couldn't reflect it in the survey for these 2 women. It is important to do this manual replacement because in the mortality dataset enum entered details for these 2 miscarriage cases which is not applicable to the mortality dataset so in mortality dataset these 2 IDs are being dropped. This github issue can be found at- https://github.com/DevInnovationLab/i-h2o-india/issues/141 

//miscariage case
replace comb_miscarriage = 1 if unique_id== "40301113022" & R_E_key == "uuid:29e4bbf5-a3f2-48a2-93e6-e32c751d834e" & comb_name_comb_woman_earlier == "Lija sabara" 

//miscarriage
replace comb_miscarriage = 1 if  unique_id== "40301110002" & R_E_key == "uuid:b9836516-0c12-4043-92e9-36d3d1215961" & comb_name_comb_woman_earlier == "Birajaini Sabara" 


**RCH ID corrections 
//correcting RCH ID because the constraint was for 12 digits but this respondent had only 11 didgits  - Github issue https://github.com/DevInnovationLab/i-h2o-india/issues/114. For Sone Nachika, I can't do any replacements because enum didn't provide RCH ID 

//Damayanti miniaka
replace  comb_preg_rch_id = "12100128602" if comb_preg_rch_id == "121001286020" & unique_id == "50501119018" & comb_name_comb_woman_earlier == "Damayanti miniaka" 

//Jena pidika (Github issue link - https://github.com/DevInnovationLab/i-h2o-india/issues/112)
replace  comb_preg_rch_id = "12100128603" if comb_preg_rch_id == "121001286030" & unique_id == "50501119004" & comb_name_comb_woman_earlier == "Jena pidika" 


/*correcting the village names for the UID (Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/138) 
We found 2 UIDs for which the village name were inter-changed so that's why we need to make the manual replacements for it across all the datasets*/
*replacing bhujbal with tandipur for this ID
replace R_E_village_name_str = "Tandipur"  if  R_E_village_name_str ==  "Bhujbal" & unique_id == "30501119006"
replace Village = "Tandipur"  if Village == "Bhujbal" & unique_id == "30501119006"
replace village = 30301  if village == 30501 & unique_id == "30501119006"
*replacing  tandipur with bhujbal for this ID
replace R_E_village_name_str = "Bhujbal" if  R_E_village_name_str == "Tandipur" & unique_id == "30301119027"
replace Village = "Bhujbal" if Village == "Tandipur"  & unique_id == "30301119027"
replace village = 30501 if village == 30301 & unique_id == "30301119027"

/*Link to the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/126
For the variable - comb_med_symp_comb_13 we will find a lot of missing values because Diarrhea was added as an option in the question "What was the symptom, or what was the reason for medical care?" in the health Expenditure module much later. Change was implemented on 4th May 2024 so surveyors started seeing Diarrhea as a separate option from 4th May 2024 onwards*/
//Doing manual replacements for Diarrhea-
replace comb_med_symp_comb_13 = 1 if comb_med_symp_oth_comb == "Dairia" | comb_med_symp_oth_comb == "Dairria" 




*******************************************************************************************
//correcting names with 111- prefix to match with their baseline names
********************************************************************************************
/* Head to github for a detailed explanation for why 111 prefix was used- https://github.com/DevInnovationLab/i-h2o-india/issues/116 

Brief Explanation of Why "111" Was Used:
1. Incorrect Age/Gender Recording: In the baseline survey, some respondents' ages or genders were recorded incorrectly. This resulted in their being marked ineligible for certain sections, such as the women and child sections.
2. Re-entry in New Roster: To correct this, enumerators re-entered these respondents in a new roster with their accurate ages and genders. This allowed them to participate in the appropriate sections for which they were actually eligible.
3. Name Consistency Across Datasets: To ensure consistency in names between the baseline and endline women’s datasets, we need to replace these re-entered names with their original baseline names. This adjustment is crucial for a perfect merge between the two datasets.
4. Manual Name Replacements: As a result, we are making manual replacements in the names to achieve a consistent, accurate merge.

In summary, "111" was used as a placeholder to manage these manual replacements and ensure accurate matching across baseline and endline datasets.
unique_id	        R_E_comb_name_comb_woman_earlier  baseline_names
10101108026	111 Radharani Misal                                  Radharani Misal
30301104006	111(Ambi praska)                                       Ambi Praska
30501111018	111 Monisha korsolibansha                      Monisha korsolibansa
30501111021	111padma sunabansa                                Padma sunabansa
40301113007	111 manjusha Sabar                                   Manjusa sabara
40301113016	111 Triveni gouda                                       Tribeni gouda
50201115043	111Palai bidika                                             Palai Bidika
50301105008	111-sunadei praska                                      Sundei Praska
*/

//splitting 111 from their names 
split comb_name_comb_woman_earlier, generate(women_with_111_names) parse("111")
//doing manual corrections in name to match it with baseline
sort comb_name_comb_woman_earlier
replace comb_name_comb_woman_earlier = "Monisha korsolibansa" if unique_id == "30501111018" &    comb_name_comb_woman_earlier == "111 Monisha korsolibansha"
replace comb_name_comb_woman_earlier = "Radharani Misal" if unique_id == "10101108026" &    comb_name_comb_woman_earlier == "111 Radharani Misal"
replace comb_name_comb_woman_earlier = "Tribeni gouda" if unique_id == "40301113016" &    comb_name_comb_woman_earlier == "111 Triveni gouda"
replace comb_name_comb_woman_earlier = "Manjusa sabara" if unique_id == "40301113007" &    comb_name_comb_woman_earlier == "111 manjusha Sabar"
replace comb_name_comb_woman_earlier = "Ambi Praska" if unique_id == "30301104006" &    comb_name_comb_woman_earlier == "111(Ambi praska)"
replace comb_name_comb_woman_earlier = "Sundei Praska" if unique_id == "50301105008" &    comb_name_comb_woman_earlier == "111-sunadei praska"
replace comb_name_comb_woman_earlier = "Palai Bidika" if unique_id == "50201115043" &    comb_name_comb_woman_earlier == "111Palai bidika"
replace comb_name_comb_woman_earlier = "Padma sunabansa" if unique_id == "30501111021" &    comb_name_comb_woman_earlier == "111padma sunabansa"

drop women_with_111_names1
rename women_with_111_names2  C_re_entered_women_names

/*---------------------------------------------------------------------------
Dropping IDs
-----------------------------------------------------------------------------*/

**Link of the Github issue- https://github.com/DevInnovationLab/i-h2o-india/issues/139. This is a mid survey refusal so whatever data has been entered after WASH section is not applicable and needs to be dropped 
drop if unique_id == "40202113033"


/*---------------------------------------------------------------------------
Outliers  
-----------------------------------------------------------------------------*/

//creating clones for some variables for which variable names are too big to perform this check
clonevar child_died_less24 = comb_child_alive_died_less24_num 
clonevar child_died_more24 = comb_child_alive_died_more24_num

ds  comb_preg_month comb_preg_delivery comb_resp_age_comb comb_preg_stay_days comb_preg_stay_months comb_wom_diarr_num_wk comb_wom_diarr_num_2wks comb_anti_preg_days comb_anti_preg_last_months comb_anti_preg_last_days comb_child_living_num comb_child_notliving_num comb_child_stillborn_num child_died_less24 child_died_more24   comb_med_visits_comb comb_med_nights_comb comb_med_t_exp_comb comb_med_days_caretaking_comb
foreach var of varlist `r(varlist)'{
destring `var', replace
}
ds comb_preg_month comb_preg_delivery comb_resp_age_comb comb_preg_stay_days comb_preg_stay_months comb_wom_diarr_num_wk comb_wom_diarr_num_2wks comb_anti_preg_days comb_anti_preg_last_months comb_anti_preg_last_days comb_child_living_num comb_child_notliving_num comb_child_stillborn_num  child_died_less24 child_died_more24 comb_med_visits_comb comb_med_nights_comb comb_med_t_exp_comb comb_med_days_caretaking_comb
foreach var of varlist `r(varlist)'{
summarize `var' if `var' != 888 & `var' != 999 & !missing(`var'), detail
gen o`var' = 0
replace o`var' = 1 if `var' != 888 & `var' != 999 & !missing(`var') & abs(`var' - r(mean)) > 3*r(sd)
//graph box `var' if `var' != 999 & `var' != 888
//graph export "${Figure}endline_outliers_`var'.png", as(png) replace
quietly count if `var' != 0 & !missing(`var')  //Counts the number of non-zero values in the current variable.
    if r(N) == 0 {   //Checks if the count of non-zero values is zero.
        drop o`var'
    }
}

//found one case for this where respondent age was 13 but as mentioned in the comb_resp_avail_comb she no longer falls in the criteria so this is fine 
br ocomb_resp_age_comb comb_resp_age_comb if ocomb_resp_age_comb != 0
//This was the only case all other outliers are fine. Additionally, you will see some major outliers in medical expenditure so these are not mistakes so no need to worry about this 
drop o* 

/*---------------------------------------------------------------------------
Labeling important categories
-----------------------------------------------------------------------------*/

label define comb_resp_avail_comb_ex 1 "Respondent available for an interview" 2 "Respondent has left the house permanently" 3	"This is my first visit: The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" ///
4 "This is my 1st re-visit: (2nd visit) The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)" 5	"This is my 2rd re-visit (3rd visit): The revisit within two days is not possible (e.g. all the female respondents who can provide the survey information are not available in the next two days)" 6 "This is my 2rd re-visit (3rd visit): The respondent is temporarily unavailable (Please leave the reasons as you finalize the survey in the later pages)"  7 "Respondent died or is no longer a member of the HH" 8 "Respondent no longer falls in the criteria (15-49 years)" 9	"Respondent is a visitor and is not available right now" -98 "Refused to answer" -77 "Other"  
 
label values comb_resp_avail_comb comb_resp_avail_comb_ex

//variables labeling
label variable C_entry_type "Does observation belong to baseline census or was a new entry recorded in endline census?"
label variable C_RV_entry_type "What type of revisit entry is it for eg. comb type variables in revisit were both preloaded from main endline census so does the combined entry belong to New or baseline census?"
label variable C_re_entered_women_names "Women that were included in the new roster because they were found to be eligible" 


/*---------------------------------------------------------------------------
Checking consistency of codes for Don't know, others etc
-----------------------------------------------------------------------------*/
ds, has(type numeric)
foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 | `var' == -99 
replace `var' = -98  if `var' == 98 
replace `var' = -77 if `var' == 77
}

/*---------------------------------------------------------------------------
Renaming Variables
-----------------------------------------------------------------------------*/
//giving R_E prefix to all the variables that don't have it already
renpfix R_E_
rename Revisit_R_E_key Revisit_key
//renaming certain variables because they are too long 
rename comb_preg_current_village_oth comb_preg_curr_vill_oth
rename comb_child_alive_died_less24_num comb_child_died_less24_num
rename comb_child_alive_died_more24_num comb_child_died_more24_num
rename comb_child_died_lessmore_24_num comb_child_died_lm_24_num
rename comb_prvdrs_exp_loop_comb_count comb_prvdrs_comb_count
rename setofcen_prvdrs_exp_loop_comb setofcen_prvdrs_comb
rename comb_med_days_caretaking_comb  comb_med_days_care_comb 
rename setofcomb_prvdrs_exp_loop_comb  setofcomb_prvdrs_comb 
ds
foreach var of varlist `r(varlist)'{
rename `var' R_E_`var'
}
rename R_E_unique_id  unique_id
rename R_E_IN_unique_id IN_unique_id



//Making naming of new generated variables consistent across endline individual and HH level dataset
rename R_E_C_entry_type C_E_entry_type
rename R_E_C_RV_entry_type C_E_RV_entry_type
rename R_E_C_re_entered_women_names C_E_re_entered_women_names
drop R_E_dup_HHID R_E_dup_UID R_E_Vcomb_resp_avail_comb R_E_to_drop R_E_comb_type R_E__merge  R_E_UID_1  //dropping unecessary variables that were created for temporary calcs

/*---------------------------------------------------------------------------
Getting important variables for analysis from other datasets
-----------------------------------------------------------------------------*/
rename R_E_comb_name_comb_woman_earlier C_E_hhmember_name  //renaming this variable so that merge can be done easily 
merge 1:1 unique_id C_E_hhmember_name using "${Intermediate}1_10_Cl_Endline_roster_merged_census_New_final_cleaned.dta", keepusing (unique_id C_E_hhmember_name R_E_comb_hhmember_age R_E_comb_hhmember_gender) gen (match) keep(1 3) 
rename C_E_hhmember_name R_E_comb_name_comb_woman_earlier //reverting it to its original name 
drop match

save "${Intermediate}1_10_Cl_Endline_CBW_level_merged_dataset_final_cleaned.dta", replace


/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 6
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/


  /*****************************************************************
 COMBINING ALL INDIVIDUAL DATASETS 
*****************************************************************/

use "${Intermediate}1_10_Cl_Endline_Child_level_merged_dataset_final_cleaned.dta", clear
gen C_E_dataset_type = "Child"
append using "${Intermediate}1_10_Cl_Endline_roster_merged_census_New_final_cleaned.dta"
replace C_E_dataset_type = "Roster" if  R_E_comb_name_from_earlier_hh != "" |  R_E_comb_hhmember_name != ""
append using "${Intermediate}1_10_Cl_Endline_CBW_level_merged_dataset_final_cleaned.dta"
replace C_E_dataset_type = "CBW" if  R_E_comb_name_comb_woman_earlier != ""

//Please tabulate this variable: C_dataset_type  to get the breakdown of each type of dataset present in this master dataset 
order C_E_dataset_type 
label variable C_E_dataset_type "Type of Individual dataset"
save "${DataFinal}0_Master_10_Individual_data_endline_census.dta", replace //Cl means cleaned

/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 7
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

  /*****************************************************************
 Data creation of the consented indiviudal datasets 
*****************************************************************/

//Creating consented child dataset for analysis 
use "${DataFinal}0_Master_10_Individual_data_endline_census.dta", clear
keep if C_E_dataset_type  == "Child" 
ds // list all variables
foreach var of varlist * {
    // Calculate the number of non-missing values for the variable
    count if !missing(`var')
    // Drop the variable if all values are missing
    if r(N) == 0 {
        drop `var'
    }
}
keep if R_E_comb_child_caregiver_present == 1
save "${DataFinal}1_11_Endline_Census_Child_consented_individual.dta", replace

//creating consented women dataset for analysis 
use "${DataFinal}0_Master_10_Individual_data_endline_census.dta", clear
keep if C_E_dataset_type  == "CBW" 
ds // list all variables
foreach var of varlist * {
    // Calculate the number of non-missing values for the variable
    count if !missing(`var')
    // Drop the variable if all values are missing
    if r(N) == 0 {
        drop `var'
    }
}
keep if R_E_comb_resp_avail_comb == 1 //keeping only available and consented ones 
cap drop Vcomb_resp_avail_comb
save "${DataFinal}1_11_Endline_Census_CBW_consented_individual.dta", replace


//creating consented roster dataset for analysis 
use "${DataFinal}0_Master_10_Individual_data_endline_census.dta", clear
keep if C_E_dataset_type  == "Roster" 
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
save "${DataFinal}1_11_Endline_Census_Roster_consented_individual.dta", replace


/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 8
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

  /*****************************************************************
 Reshaping Baseline census dataset
*****************************************************************/

/*---------------------------------------------------------------------------
Women level dataset
-----------------------------------------------------------------------------*/
*This dataset gets created in "GitHub\i-h2o-india\Code\1_profile_ILC\3_X_Final_Data_Creation.do"
use "${DataFinal}1_1_Baseline_Census_HH_clean_consented.dta", clear
//creating women dataset first 
keep unique_id R_Cen_key R_Cen_village_str R_Cen_hh_member_names_count R_Cen_namefromearlier_* R_Cen_a4_hhmember_gender_* R_Cen_a6_hhmember_age_* R_Cen_a7_pregnant_* R_Cen_a7_pregnant_month_* R_Cen_a7_pregnant_hh_* R_Cen_a7_pregnant_leave_*  R_Cen_pregnant_followup_count R_Cen_pregnant_index_* R_Cen_get_pregnant_status_* R_Cen_pregwoman_* R_Cen_a21_wom_cuts_day_* R_Cen_a21_wom_cuts_week_* R_Cen_a21_wom_cuts_2week_* R_Cen_a22_wom_vomit_day_* R_Cen_a22_wom_vomit_week_* R_Cen_a22_wom_vomit_2week_* R_Cen_a23_wom_diarr_day_* R_Cen_a23_wom_diarr_week_* R_Cen_a23_wom_diarr_2week_* R_Cen_wom_diarr_num_week_* R_Cen_wom_diarr_num_2weeks_* R_Cen_a25_wom_stool_24h_* R_Cen_a25_wom_stool_yest_* R_Cen_a25_wom_stool_week_* R_Cen_a25_wom_stool_2week_* R_Cen_a26_wom_blood_day_* R_Cen_a26_wom_blood_week_* R_Cen_a26_wom_blood_2week_* 

isid unique_id

//wide to long
reshape long R_Cen_namefromearlier_ R_Cen_a4_hhmember_gender_  R_Cen_a6_hhmember_age_  R_Cen_a7_pregnant_ R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_  R_Cen_pregnant_index_ R_Cen_get_pregnant_status_ R_Cen_pregwoman_ R_Cen_a21_wom_cuts_day_ R_Cen_a21_wom_cuts_week_ R_Cen_a21_wom_cuts_2week_ R_Cen_a22_wom_vomit_day_ R_Cen_a22_wom_vomit_week_ R_Cen_a22_wom_vomit_2week_ R_Cen_a23_wom_diarr_day_ R_Cen_a23_wom_diarr_week_ R_Cen_a23_wom_diarr_2week_ R_Cen_wom_diarr_num_week_ R_Cen_wom_diarr_num_2weeks_ R_Cen_a25_wom_stool_24h_ R_Cen_a25_wom_stool_yest_ R_Cen_a25_wom_stool_week_ R_Cen_a25_wom_stool_2week_ R_Cen_a26_wom_blood_day_ R_Cen_a26_wom_blood_week_ R_Cen_a26_wom_blood_2week_ , i(unique_id) j(C_Cen_reshape)
drop if R_Cen_namefromearlier_ == ""
keep if R_Cen_a4_hhmember_gender_ == 2  //keepi ng only women in the dataset
order unique_id R_Cen_pregwoman_ R_Cen_namefromearlier_ //we are keeping non-pregnant women too to maintain consistency because the endline women dataset have all the women from 15-49 years including non-pregnant ones 

//finding perfect unique identifiers
// WAY 1 
bysort  unique_id R_Cen_namefromearlier_ : gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
br unique_id R_Cen_namefromearlier_  C_Cen_reshape R_Cen_a6_hhmember_age_ R_Cen_a7_pregnant_ dup_UID if dup_UID != 0
tab dup_UID
//MANUAL CORRECTIONS 
/*
Case of Pinky- 
Please note that for Pinky we need to make sure that the replacement is coherent with the endline replacement so if you take a look at endline manual replacements you will see that index of the woman was 1 that means she was first to appear in the roster so since those are preloaded names taken from baseline census. In baseline too, Pinky with index 1 would be same as Pinky with index 1 in endline so here the index no. is shown by reshape variable that is why reshape == 1 is used as a condition fo replacement 

Case of Priya-
Please note that for Priya we need to make sure that the replacement is coherent with the endline replacement so if you take a look at endline manual replacements you will see that index of the two Priyas were respectively 1 and 8 and in endline we made chnages to the Priya with index 8 that is she was the 8th to appear on the roster since this is a preloaded variable the index of Priya is going to be same in baseline census too and here reshape variable shows that index that is why we are using this for manual replacement 
*/

*2 Duplicates found. Please note that this was also flagged earlier 
replace R_Cen_namefromearlier_  = "_Pinky Kandagari" if R_Cen_namefromearlier_ == "Pinky Kandagari" & unique_id == "30202109013" &  C_Cen_reshape == 1 & R_Cen_a6_hhmember_age_ == 22 

replace R_Cen_namefromearlier_  = "_Priya Koushalya" if R_Cen_namefromearlier_ == "Priya Koushalya" & unique_id == "30602105049" & R_Cen_a6_hhmember_age_ ==12   &  C_Cen_reshape == 8

//replacing names with correct surnames - replacing Jilaka with Jilakar. We found the correct surname in endline census. So, the replacement has already been made in the endline data 
replace R_Cen_namefromearlier_ = "Pauni Jilakar" if R_Cen_namefromearlier_ == "Pauni Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_ = "Sabitri Jilakar" if R_Cen_namefromearlier_ == "Sabitri Jilaka" & unique_id == "30602107007" 

//after verification we found that here 999 respondent name is Sabitri kadraka so this needs to be replaced everywhere including baseline census. The respondent during baseline was daughetr-in-law and in some cultures it is not allowed to take mother-in-law's name that is why there was 999 here but we verified this during endline and found it to be Sabitri kadraka  
replace R_Cen_namefromearlier_  = "Sabitri kadraka" if R_Cen_namefromearlier_  == "999" & unique_id == "40101111012"

//WAY 2 (Doing manual checks )
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
sort unique_id 
br unique_id R_Cen_namefromearlier_  if dup_HHID > 0 
drop dup_UID dup_HHID
**Labeling important categories
label define R_Cen_a4_hhmember_gender_x 1 "Male" 2 "Female" 3 "Other" -98 "Refused"  
label values R_Cen_a4_hhmember_gender_ R_Cen_a4_hhmember_gender_x

**we are creating two datasets because one is going to contain all entries because it is going to help us in matching it with the endline women dataset to see if there are any names that are matching but shouldn't be. 
save "${DataTemp}1_1_Baseline_Census_CBW_Individual_level_for_merge.dta", replace
//keeping only women in the dataset for any analysis for baseline
keep if R_Cen_a6_hhmember_age_ >= 15 & R_Cen_a6_hhmember_age_ >= 49 & R_Cen_a4_hhmember_gender_ == 2
save "${Intermediate}1_1_Baseline_Census_CBW_Individual_level.dta", replace

/*---------------------------------------------------------------------------
Child level dataset
-----------------------------------------------------------------------------*/
*This dataset gets created in "GitHub\i-h2o-india\Code\1_profile_ILC\3_X_Final_Data_Creation.do"
use "${DataFinal}1_1_Baseline_Census_HH_clean_consented.dta", clear
keep unique_id R_Cen_key  R_Cen_village_str R_Cen_hh_member_names_count R_Cen_namefromearlier_* R_Cen_a4_hhmember_gender_* R_Cen_a6_hhmember_age_* R_Cen_a6_age_confirm2_* R_Cen_a6_dob_* R_Cen_a5_autoage_* R_Cen_a6_u1age_* R_Cen_unit_age_* R_Cen_correct_age_* R_Cen_a8_u5mother_* R_Cen_u5mother_name_* R_Cen_child_index_* R_Cen_get_u5_status_* R_Cen_u5child_* R_Cen_child_caregiver_present_* R_Cen_child_breastfeeding_* R_Cen_child_breastfed_num_* R_Cen_a27_child_cuts_day_* R_Cen_a27_child_cuts_week_* R_Cen_a27_child_cuts_2week_* R_Cen_a28_child_vomit_day_* R_Cen_a28_child_vomit_week_* R_Cen_a28_child_vomit_2week_* R_Cen_a29_child_diarr_day_* R_Cen_a29_child_diarr_week_* R_Cen_a29_child_diarr_2week_* R_Cen_child_diarr_week_num_* R_Cen_child_diarr_2week_num_* R_Cen_a30_child_diarr_freq_* R_Cen_a31_child_stool_24h_* R_Cen_a31_child_stool_yest_* R_Cen_a31_child_stool_week_* R_Cen_a31_child_stool_2week_* R_Cen_a32_child_blood_day_* R_Cen_a32_child_blood_week_* R_Cen_a32_child_blood_2week_* 

isid unique_id

//wide to long
reshape long R_Cen_namefromearlier_ R_Cen_a4_hhmember_gender_ R_Cen_a6_hhmember_age_ R_Cen_a6_age_confirm2_ R_Cen_a6_dob_ R_Cen_a5_autoage_ R_Cen_a6_u1age_ R_Cen_unit_age_ R_Cen_correct_age_ R_Cen_a8_u5mother_ R_Cen_u5mother_name_ R_Cen_child_index_ R_Cen_get_u5_status_ R_Cen_u5child_ R_Cen_child_caregiver_present_ R_Cen_child_breastfeeding_ R_Cen_child_breastfed_num_ R_Cen_a27_child_cuts_day_ R_Cen_a27_child_cuts_week_ R_Cen_a27_child_cuts_2week_ R_Cen_a28_child_vomit_day_ R_Cen_a28_child_vomit_week_ R_Cen_a28_child_vomit_2week_ R_Cen_a29_child_diarr_day_ R_Cen_a29_child_diarr_week_ R_Cen_a29_child_diarr_2week_ R_Cen_child_diarr_week_num_ R_Cen_child_diarr_2week_num_ R_Cen_a30_child_diarr_freq_ R_Cen_a31_child_stool_24h_ R_Cen_a31_child_stool_yest_ R_Cen_a31_child_stool_week_ R_Cen_a31_child_stool_2week_ R_Cen_a32_child_blood_day_ R_Cen_a32_child_blood_week_ R_Cen_a32_child_blood_2week_  , i(unique_id) j(C_Cen_reshape)
drop if R_Cen_namefromearlier_ == ""
drop if R_Cen_u5child_ == ""   //dropping ineligible entries 
order unique_id R_Cen_u5child_ R_Cen_a6_hhmember_age_ R_Cen_namefromearlier_

***manual corrections****
//replacing names with correct surnames - replacing Jilaka with Jilakar. We found the correct surname in endline census. So, the replacement has already been made in the endline data 
replace R_Cen_u5child_= "Pauni Jilakar" if R_Cen_u5child_ == "Pauni Jilaka" & unique_id == "30602107007" 
replace R_Cen_u5child_ = "Raja Jilakar" if R_Cen_u5child_ == "Raja Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_= "Pauni Jilakar" if R_Cen_namefromearlier_ == "Pauni Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_ = "Raja Jilakar" if R_Cen_namefromearlier_ == "Raja Jilaka" & unique_id == "30602107007" 

//finding perfect unique identifiers
// WAY 1 
bysort  unique_id R_Cen_u5child_ : gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID
//WAY 2 (Doing manual checks )
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
br unique_id R_Cen_u5child_ R_Cen_a6_hhmember_age_ R_Cen_namefromearlier_ if dup_HHID > 0
sort unique_id 
//all child names are unique 
drop dup_UID dup_HHID
**Labeling important categories
label define R_Cen_a4_hhmember_gender_x 1 "Male" 2 "Female" 3 "Other" -98 "Refused"  
label values R_Cen_a4_hhmember_gender_ R_Cen_a4_hhmember_gender_x

**we are creating two datasets because one is going to contain all entries because it is going to help us in matching it with the endline children dataset to see if there are any names that are matching but shouldn't be. 
save "${DataTemp}1_1_Baseline_Census_U5_Individual_level_for_merge.dta", replace
//keeping only U5 child in the dataset for any analysis for baseline
keep if R_Cen_a6_hhmember_age_ < 5  //keeping only U5 child in the dataset 
save "${Intermediate}1_1_Baseline_Census_U5_Individual_level.dta", replace

/*---------------------------------------------------------------------------
Roster level dataset
-----------------------------------------------------------------------------*/
*This dataset gets created in "GitHub\i-h2o-india\Code\1_profile_ILC\3_X_Final_Data_Creation.do"
use "${DataFinal}1_1_Baseline_Census_HH_clean_consented.dta", clear
keep unique_id  R_Cen_key R_Cen_village_str R_Cen_resp_available R_Cen_instruction R_Cen_a1_resp_name R_Cen_hhmember_count R_Cen_namenumber_* R_Cen_a3_hhmember_name_* R_Cen_namefromearlier_* R_Cen_a4_hhmember_gender_* R_Cen_a5_hhmember_relation_* R_Cen_a5_relation_oth_* R_Cen_a6_hhmember_age_* R_Cen_a6_age_confirm2_* R_Cen_a6_dob_* R_Cen_a5_autoage_* R_Cen_a6_u1age_* R_Cen_unit_age_* R_Cen_correct_age_* R_Cen_a7_pregnant_* R_Cen_a7_pregnant_month_* R_Cen_a7_pregnant_hh_* R_Cen_a7_pregnant_leave_* R_Cen_a8_u5mother_* R_Cen_u5mother_name_* R_Cen_a9_school_* R_Cen_a9_school_level_* R_Cen_a9_school_current_* R_Cen_a9_read_write_* R_Cen_female_above12 R_Cen_num_femaleabove12 R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12

isid unique_id

//wide to long
reshape long R_Cen_namenumber_ R_Cen_a3_hhmember_name_ R_Cen_namefromearlier_ R_Cen_a4_hhmember_gender_ R_Cen_a5_hhmember_relation_  R_Cen_a5_relation_oth_ R_Cen_a6_hhmember_age_ R_Cen_a6_age_confirm2_ R_Cen_a6_dob_ R_Cen_a5_autoage_ R_Cen_a6_u1age_ R_Cen_unit_age_ R_Cen_correct_age_ R_Cen_a7_pregnant_ R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_ R_Cen_a8_u5mother_ R_Cen_u5mother_name_ R_Cen_a9_school_ R_Cen_a9_school_level_ R_Cen_a9_school_current_ R_Cen_a9_read_write_  , i(unique_id) j(C_Cen_reshape)
drop if R_Cen_namefromearlier_ == ""
//finding perfect unique identifiers
// WAY 1 
bysort  unique_id R_Cen_a3_hhmember_name_ : gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id 
tab dup_UID
br unique_id C_Cen_reshape R_Cen_a6_hhmember_age_ R_Cen_a3_hhmember_name_ if  dup_UID > 0
//WAY 2 (Doing manual checks )
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
br unique_id  R_Cen_a3_hhmember_name_ if  dup_HHID > 0
//MANUAL CORRECTIONS 
/*
Case of Pinky- 
Please note that for Pinky we need to make sure that the replacement is coherent with the endline replacement so if you take a look at endline manual replacements you will see that index of the woman was 1 that means she was first to appear in the roster so since those are preloaded names taken from baseline census. In baseline too, Pinky with index 1 would be same as Pinky with index 1 in endline so here the index no. is shown by reshape variable that is why reshape == 1 is used as a condition fo replacement 

Case of Priya-
Please note that for Priya we need to make sure that the replacement is coherent with the endline replacement so if you take a look at endline manual replacements you will see that index of the two Priyas were respectively 1 and 8 and in endline we made chnages to the Priya with index 8 that is she was the 8th to appear on the roster since this is a preloaded variable the index of Priya is going to be same in baseline census too and here reshape variable shows that index that is why we are using this for manual replacement 
*/

*2 Duplicates found. Please note that this was also flagged earlier 
replace R_Cen_a3_hhmember_name_ = "_Pinky Kandagari" if R_Cen_a3_hhmember_name_ == "Pinky Kandagari" & unique_id == "30202109013" &  C_Cen_reshape == 1 & R_Cen_a6_hhmember_age_ == 22 

replace R_Cen_a3_hhmember_name_ = "_Priya Koushalya" if R_Cen_a3_hhmember_name_ == "Priya Koushalya" & unique_id == "30602105049" & R_Cen_a6_hhmember_age_ ==12   &  C_Cen_reshape == 8
//also cleaning in the other variable
replace R_Cen_namefromearlier_ = "_Pinky Kandagari" if R_Cen_namefromearlier_ == "Pinky Kandagari" & unique_id == "30202109013" &  C_Cen_reshape == 1 & R_Cen_a6_hhmember_age_ == 22 
replace R_Cen_namefromearlier_ = "_Priya Koushalya" if R_Cen_namefromearlier_ == "Priya Koushalya" & unique_id == "30602105049" & R_Cen_a6_hhmember_age_ ==12   &  C_Cen_reshape == 8


//replacing names with correct surnames - replacing Jilaka with Jilakar. We found the correct surname in endline census. So, the replacement has already been made in the endline data 
replace R_Cen_a3_hhmember_name_= "Pauni Jilakar" if R_Cen_a3_hhmember_name_ == "Pauni Jilaka" & unique_id == "30602107007" 
replace R_Cen_a3_hhmember_name_= "Raja Jilakar" if R_Cen_a3_hhmember_name_ == "Raja Jilaka" & unique_id == "30602107007" 
replace R_Cen_a3_hhmember_name_= "Mangu Jilakar" if R_Cen_a3_hhmember_name_ == "Mangu Jilaka" & unique_id == "30602107007" 
replace R_Cen_a3_hhmember_name_= "Sabitri Jilakar" if R_Cen_a3_hhmember_name_ == "Sabitri Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_= "Pauni Jilakar" if R_Cen_namefromearlier_ == "Pauni Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_ = "Raja Jilakar" if R_Cen_namefromearlier_ == "Raja Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_= "Mangu Jilakar" if R_Cen_namefromearlier_ == "Mangu Jilaka" & unique_id == "30602107007" 
replace R_Cen_namefromearlier_ = "Sabitri Jilakar" if R_Cen_namefromearlier_ == "Sabitri Jilaka" & unique_id == "30602107007" 

//after verification we found that here 999 respondent name is Sabitri kadraka so this needs to be replaced everywhere including baseline census. The respondent during baseline was daughetr-in-law and in some cultures it is not allowed to take mother-in-law's name that is why there was 999 here but we verified this during endline and found it to be Sabitri kadraka  
replace R_Cen_namefromearlier_  = "Sabitri kadraka" if R_Cen_namefromearlier_  == "999" & unique_id == "40101111012"
replace R_Cen_a3_hhmember_name_ = "Sabitri kadraka" if  R_Cen_a3_hhmember_name_  == "999" & unique_id == "40101111012"

drop dup_UID dup_HHID
**Labeling important categories
label define R_Cen_a4_hhmember_gender_x 1 "Male" 2 "Female" 3 "Other" -98 "Refused"  
label values R_Cen_a4_hhmember_gender_ R_Cen_a4_hhmember_gender_x

save "${Intermediate}1_1_Baseline_Census_Roster_Individual_level.dta", replace

/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 9
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/

  /******************************************************************************
Merging baseline census individual datasets with endline individual datasets 
******************************************************************************/

/***************************************************************************************
-----------------------------------------------------------------------------------------
 Section 9.1- Women level dataset 
 ---------------------------------------------------------------------------------------
****************************************************************************************/
//baseline
use "${DataTemp}1_1_Baseline_Census_CBW_Individual_level_for_merge.dta", clear
clonevar R_E_comb_name_comb_woman_earlier = R_Cen_namefromearlier_  //cloning it so that can find a common variable for merge
//merging it with endline dataset
merge 1:1 unique_id R_E_comb_name_comb_woman_earlier using "${Intermediate}1_10_Cl_Endline_CBW_level_merged_dataset_final_cleaned.dta"
br R_E_comb_name_comb_woman_earlier C_E_entry_type C_E_RV_entry_type R_E_comb_resp_avail_comb unique_id if _merge == 2
/*
Important Note:

There are approximately 5 cases in this merge where women were found to be ineligible when approached during the endline census. Here’s the breakdown:
1. Reason for No Match: These women are only present in the endline dataset because they were determined ineligible at endline, and thus no match exists for them in earlier data.
2. Presence in Endline Preload: Initially, these women were included in the endline preload, which is why their names appeared in the endline records.
3. Age Correction: Their actual ages were corrected in the 3_X_HH_Data_Creation file, reflecting their true age.
4. Effect of Age Condition: After applying the age condition—keep if R_Cen_a6_hhmember_age_ >= 15 & R_Cen_a6_hhmember_age_ <= 49—these women no longer appear in the dataset because they fall outside this age range.
In summary, these cases are found only in the endline dataset due to ineligibility and age adjustments, which removed them from the final merged dataset.

Names of these women are as follows: 
R_E_comb_name_comb_woman_earlier
Suranti Sabara
Amarabati Pradhan
Krishnabeni Patra
R_E_comb_name_comb_woman_earlier
Jhansirani Mandangi
Jhiama Kadraka
*/

//generating a variable for entries from baseline which do not not belong in the eligible category (by eligible I mean- a woman of age between 15 to 49 years inclusive). This is only for entries belonging to the baseline census dataset 
gen irrelevant = .
replace irrelevant = 1 if  (R_Cen_a6_hhmember_age_  <  15 | R_Cen_a6_hhmember_age_  > 49)  & _merge == 1 
//separating those entries where woman was eligible but still her name is not being shown in the endline i.e. _merge == 1 only present in master (baseline census)
replace irrelevant  = 0 if R_Cen_a6_hhmember_age_  >=  15 & R_Cen_a6_hhmember_age_  <= 49 &  R_Cen_a4_hhmember_gender_ == 2 &  _merge == 1 

br unique_id R_E_comb_name_comb_woman_earlier R_Cen_a6_hhmember_age_ R_Cen_a4_hhmember_gender_ irrelevant if _merge == 1 & irrelevant  == 0
/*
*****************************************************************************
Why are some eligible women names absent from endline census?
*******************************************************************************
there are around 46 observations where the woman is eligible from baseline but her name is  not present in endline. We need to investigate if this because these households were unavailable during endline census. 

unique_id	R_E_comb_name_comb_woman_earlier	R_Cen_a6_hhmember_age_	R_Cen_a4_hhmember_gender_	C_irrelevant
10101108015	Chinuma Kadraka	23	Female	0
20201110016	Debasmita Gamanga	30	Female	0
20201113045	Ranjita cham	28	Female	0
20201113081	Archita ganta	20	Female	0
20201113081	Gitanjali satpati	43	Female	0
30202109011	Relo Hikaka	40	Female	0
30202109011	Runi Hikaka	19	Female	0
30202109011	Srimati Hikaka	16	Female	0
30301109002	Anusaya Senapati	35	Female	0
30301109002	Jina Sahu	35	Female	0
30301119062	Meghamala Mohanti	33	Female	0
30501107054	Gudia Pardi	26	Female	0
30501117006	Pushpa sutar	42	Female	0
30501117006	Sonali altur sultar	25	Female	0
30602106023	Chuchitra Palaka	46	Female	0
30602106023	Sarita Bag	22	Female	0
30602106030	Rambha Hial	20	Female	0
30602117014	Mini pidika	17	Female	0
30602117014	Ranjita Himirika	30	Female	0
30602117035	Sumitra Heprika	30	Female	0
30602119007	Basanti bebhar	30	Female	0
30701112022	Malati Mahanandia	23	Female	0
40101111033	Aika lalita	20	Female	0
40101111033	Renuka Aika	35	Female	0
40202108012	Pinki Das	34	Female	0
40202108012	Sandhyarani Das	26	Female	0
40202113033	Ladi saipriya	25	Female	0
40202113041	Sunita ori chety	22	Female	0
40202113041	Vobani sety	24	Female	0
40301108014	Bobita Sabara	33	Female	0
40301113002	Hiramani sabara	25	Female	0
40401111028	Anita Mohapatra	27	Female	0
40401113001	Ratna sabara	35	Female	0
50101119006	Rukmani katabansa	40	Female	0
50201104009	Ambika Bidika	27	Female	0
50201109035	Gayatri Wataka	20	Female	0
50201109035	Uma Wataka	18	Female	0
50301106014	Jati Bidika	17	Female	0
50301106014	Malati Bidika	35	Female	0
50301106014	Oni Bidika	20	Female	0
50301106014	Sabi Bidika	20	Female	0
50301106014	Wano Bidika	27	Female	0
50301117034	Priyanka Kumari	26	Female	0
50401106054	Dhanamani Saraka	35	Female	0
50401106054	Renuka Saraka	20	Female	0
50501115015	Jayanti Pidika	22	Female	0 */

//getting availability status of the household for these IDs from the endline housheold survey  data 
merge m:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing( R_E_resp_available) gen(match) keep(1 3)
//after doing the verification from browse we see that all these entries were not merged because these households were unavailable during endline
br unique_id R_E_comb_name_comb_woman_earlier R_Cen_a6_hhmember_age_ R_Cen_a4_hhmember_gender_ irrelevant  R_E_resp_available if _merge == 1 & irrelevant  == 0 

/*
-----------------------------------------------------------------------------------------
Reasons for mismatch in the merge between women baseline census and endline census
------------------------------------------------------------------------------------------
1. Using entries- 75 : These are all the new entries recorded in endline census that is why they are not present in baseline census. You can browse C_E_entry_type C_E_RV_entry_type if _merge == 2 to verify this. 
2. Master entries- 1407: Out of these 1407 entries, 46 entries are those where women were eligible and they were visited in endline but the household was locked as can be seen by browsing the variable R_E_resp_available. Out of 1407, 1361 observations are those that are non-eligible entries that is they don't follow these 3 conditions- age>= 15 & age<= 49 & gender == female. So, we can drop these 1361 entries
3. 
*/
drop if _merge == 1 & irrelevant  == 1  //dropping the entries from baseline census which are non-eligible for women section
tab _merge 

/*
-----------------------------------------------------------------------------------------
Finding duplicates
------------------------------------------------------------------------------------------*/
//WAY 2
bysort unique_id R_E_comb_name_comb_woman_earlier : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id
br unique_id R_E_comb_name_comb_woman_earlier dup_UID if dup_UID != 0
/*-----------------------------------------------------------------------------------------
Creating a combined variable 
------------------------------------------------------------------------------------------*/
**creating combined name variable 
gen C_women_names = R_E_comb_name_comb_woman_earlier
label variable C_women_names "Combined names of endline and baseline women"
**creating combined age variable 
gen C_women_age =  R_E_comb_hhmember_age
replace C_women_age =  R_Cen_a6_hhmember_age_ if  C_women_age == .
*8combined gendre variable 
gen C_women_gender = R_E_comb_hhmember_gender
replace C_women_gender = R_Cen_a4_hhmember_gender_ if C_women_gender == .

/*-----------------------------------------------------------------------------------------
Renaming variables for consistency 
------------------------------------------------------------------------------------------*/
//Note: Our preferance would be to rename baseline variable to make it similar to endline variable because endline ones have been used elsewhere for analysis.

**name of the eligible women (15-49 years)
rename R_Cen_namefromearlier_  R_Cen_comb_name_comb_CBW_earlier
rename R_E_comb_name_comb_woman_earlier R_E_comb_name_comb_CBW_earlier   //we also had to rename endline one here because just renaming baseline was exceeding stata limit so to make them both consistent we renamed both

**Pregnancy status
rename  R_Cen_get_pregnant_status_  R_Cen_comb_preg_status  //renaming the variable for baseline 

**renaming bruises and cuts variables 
rename R_Cen_a21_wom_cuts_day_  R_Cen_comb_wom_cuts_day
rename R_Cen_a21_wom_cuts_week_  R_Cen_comb_wom_cuts_wk
rename R_Cen_a21_wom_cuts_2week_  R_Cen_comb_wom_cuts_2wk

**renaming vomit variables 
rename R_Cen_a22_wom_vomit_day_  R_Cen_comb_wom_vomit_day
rename R_Cen_a22_wom_vomit_week_  R_Cen_comb_wom_vomit_wk
rename R_Cen_a22_wom_vomit_2week_  R_Cen_comb_wom_vomit_2wk

**renaming diarrhea variables
rename R_Cen_a23_wom_diarr_day_  R_Cen_comb_wom_diarr_day
rename R_Cen_a23_wom_diarr_week_   R_Cen_comb_wom_diarr_wk 
rename R_Cen_a23_wom_diarr_2week_  R_Cen_comb_wom_diarr_2wk
rename R_Cen_wom_diarr_num_week_  R_Cen_comb_wom_diarr_num_wk
rename R_Cen_wom_diarr_num_2weeks_ R_Cen_comb_wom_diarr_num_2wks 

**renaming stool variables 
rename  R_Cen_a25_wom_stool_24h_  R_Cen_comb_wom_stool_24h
rename R_Cen_a25_wom_stool_yest_   R_Cen_comb_wom_stool_yest
rename R_Cen_a25_wom_stool_week_  R_Cen_comb_wom_stool_wk
rename R_Cen_a25_wom_stool_2week_  R_Cen_comb_wom_stool_2wk

 **renaming blood variables 
 rename R_Cen_a26_wom_blood_day_   R_Cen_comb_wom_blood_day
 rename R_Cen_a26_wom_blood_week_  R_Cen_comb_wom_blood_wk
 rename R_Cen_a26_wom_blood_2week_  R_Cen_comb_wom_blood_2wk
 
 **renaming village variables
rename R_Cen_village_str  R_Cen_village_name_str
rename R_E_village R_E_village_code

**renaming age and gender variables 
rename  R_Cen_a4_hhmember_gender_  R_Cen_comb_hhmember_gender
rename R_Cen_a6_hhmember_age_  R_Cen_comb_hhmember_age

**renaming pregnancy variables
rename R_Cen_a7_pregnant_month_  R_Cen_comb_preg_month
rename R_Cen_a7_pregnant_hh_  R_Cen_comb_preg_residence
rename  R_Cen_a7_pregnant_leave_  R_Cen_comb_preg_stay
 
  /*-----------------------------------------------------------------------------------------
Labeling variables for consistency 
------------------------------------------------------------------------------------------*/
label var R_Cen_pregwoman_ "Women pregnant at the time of the survey"
label var R_Cen_comb_name_comb_CBW_earlier "Eligible women between the age 15-49 years" 
label var R_E_comb_name_comb_CBW_earlier "Eligible women between the age 15-49 years" 
label var R_Cen_comb_preg_status "Women pregnant at the time of the survey"
label var R_Cen_comb_preg_month "Which month of woman's pregnancy is this?"
label var R_Cen_comb_preg_residence "Is this woman's usual residence?"
label var R_Cen_comb_preg_stay "How long is woman planning to stay here?"

  /*-----------------------------------------------------------------------------------------
Recategorising answer choices for better comparison
------------------------------------------------------------------------------------------*/
**recoding -99 or 99 to 999; 98 to -98; 77 to -77; No- 0 and Yes - 1

//Treating categorical variables 
ds R_Cen_comb_wom_cuts_day R_Cen_comb_wom_cuts_wk R_Cen_comb_wom_cuts_2wk R_E_comb_wom_cuts_day R_E_comb_wom_cuts_wk R_E_comb_wom_cuts_2wk R_Cen_comb_wom_vomit_day R_Cen_comb_wom_vomit_wk R_Cen_comb_wom_vomit_2wk R_E_comb_wom_vomit_day R_E_comb_wom_vomit_wk R_E_comb_wom_vomit_2wk  R_Cen_comb_wom_diarr_day R_Cen_comb_wom_diarr_wk  R_Cen_comb_wom_diarr_2wk  R_E_comb_wom_diarr_day R_E_comb_wom_diarr_wk R_E_comb_wom_diarr_2wk R_Cen_comb_wom_stool_24h R_Cen_comb_wom_stool_yest R_Cen_comb_wom_stool_wk R_Cen_comb_wom_stool_2wk R_E_comb_wom_stool_24h R_E_comb_wom_stool_yest R_E_comb_wom_stool_wk R_E_comb_wom_stool_2wk R_Cen_comb_wom_blood_day R_Cen_comb_wom_blood_wk R_Cen_comb_wom_blood_2wk R_E_comb_wom_blood_day R_E_comb_wom_blood_wk R_E_comb_wom_blood_2wk R_Cen_a7_pregnant_  R_Cen_comb_preg_residence 

foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 |  `var' == -99
replace `var' = -98 if `var' == 98 
replace `var' = -77 if `var' == 77
**defining label for options
label define `var'_x 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer" -77 "Other"
label values `var' `var'_x
}

//Treating numeric variables 
ds R_Cen_comb_wom_diarr_num_wk R_Cen_comb_wom_diarr_num_2wks  R_E_comb_wom_diarr_num_wk R_E_comb_wom_diarr_num_2wks R_Cen_comb_hhmember_age  R_Cen_hh_member_names_count  R_Cen_comb_preg_month R_Cen_comb_preg_stay
foreach var of varlist `r(varlist)'{
destring `var', replace
replace `var' = 999 if `var' == 99 |  `var' == -99
replace `var' = -98 if `var' == 98 
replace `var' = -77 if `var' == 77
}

/*-----------------------------------------------------------------------------------------
Dropping unecesary variables 
------------------------------------------------------------------------------------------*/
drop _merge irrelevant dup_HHID dup_UID match R_Cen_hh_member_names_count R_E_Village

save "${DataFinal}1_12_Cl_Census_Baseline_Endline_CBW.dta", replace



/***************************************************************************************
-----------------------------------------------------------------------------------------
 Section 9.2- Child level dataset 
 ---------------------------------------------------------------------------------------
****************************************************************************************/
use "${DataTemp}1_1_Baseline_Census_U5_Individual_level_for_merge.dta", clear
clonevar R_E_comb_child_comb_name_label =  R_Cen_namefromearlier_ //cloning it so that can find a common variable for merge
//merging it with endline dataset
merge 1:1 unique_id R_E_comb_child_comb_name_label using "${Intermediate}1_10_Cl_Endline_Child_level_merged_dataset_final_cleaned.dta"
br unique_id R_Cen_namefromearlier_ R_Cen_a6_hhmember_age_ if _merge == 1
/*
*****************************************************************************
Why are some eligible child names from baseline that are absent from endline census?
*******************************************************************************
There are around 32 entries from baseline where child is eligible but the name isn't matcing with endline so we need to check if this is because if the house was unavailable to visit in the endline becaus ethat is the only reaosn why these child names could be absent from endline data. This can be brosed to get such entries- br unique_id R_Cen_namefromearlier_ R_Cen_a6_hhmember_age_ if _merge == 1

unique_id	R_Cen_namefromearlier_	R_Cen_a6_hhmember_age_
10101108015	Krishna Kadraka	1
10101108015	Tukuna Kadraka	3
20201110016	Anjana kingal	3
20201113045	Arpana kumar chhinchani	0
20201113081	Alsha satpati	1
30301109002	Ganesh Senapati	0
30301119062	Pratik kumar Mohanti	3
30501107054	Ritika Pardi	2
30501107054	Sibanya Pardi	4
30501117006	Janbi sutar	3
30501117006	Veeren sutar	4
30602106023	Dinesh Bag	0
30602106030	Jabesh Hial	0
30602117014	Madhusmita Himirika	4
30602117035	Chinmahi Ulaka	1
30602119007	Ithan nayak	2
30701112022	Naitik Mahanandia	3
40202108012	Rutvik Das	3
40202113033	Simadri harshini	4
40202113041	Akhil sety	3
40202113041	Gitika ori chety	1
40301108014	Bhomesh Sabara	4
40301108014	Bikash Sabara	1
40301113002	Donesh sabara	1
40401111028	Tanushree Mishra	3
40401113001	Bobby sabara	3
50201104009	Hasni Das	3
50301106014	Kabya Bidika	3
50301106014	Lasita Bidika	3
50301117034	Baiswabi kumari	4
50401106054	Tanuja Saraka	1
50501115015	Kasturi Pidika	1
*/

//getting availability status of the household for these IDs from the endline housheold survey  data 
merge m:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing( R_E_resp_available) gen(match) keep(1 3)
br unique_id R_Cen_namefromearlier_ R_Cen_a6_hhmember_age_ R_E_resp_available if _merge == 1
//after verification we find that all these 32 cases are those where the housheold was unavailable during endline so as a result these children names aren't present in the endline child dataset

/*-----------------------------------------------------------------------------------------
Reasons for mismatch in the merge between women baseline census and endline census
------------------------------------------------------------------------------------------
1. Using- 125 entries (endline): These are all the entries of new children found in endline survey that is why they aren't present in the baseline dataset. This can be verified by- br unique_id R_E_comb_child_comb_name_label C_E_entry_type C_E_RV_entry_type if _merge == 2
2. Master- 32 entries(baseline): These are all entries that are only present in baseline becasue in endline these housheolds were not availabl. This has been verified above*/

/*
-----------------------------------------------------------------------------------------
Finding duplicates
------------------------------------------------------------------------------------------*/
//WAY 2
bysort unique_id R_E_comb_child_comb_name_label : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id
br unique_id R_E_comb_child_comb_name_label dup_UID if dup_UID != 0
/*-----------------------------------------------------------------------------------------
Creating a combined variable 
------------------------------------------------------------------------------------------*/
**creating combined name variable 
gen C_U5_names = R_E_comb_child_comb_name_label
label variable C_U5_names "Combined names of endline and baseline U5 Children"
**creating combined age variable 
gen C_U5_child_age =  R_E_comb_hhmember_age
replace C_U5_child_age =  R_Cen_a6_hhmember_age_ if  C_U5_child_age == .
**combined variable for gender of the kid 
gen C_U5_child_gender = R_E_comb_hhmember_gender
replace  C_U5_child_gender = R_Cen_a4_hhmember_gender_ if  C_U5_child_gender == .
/*-----------------------------------------------------------------------------------------
Renaming variables for consistency 
------------------------------------------------------------------------------------------*/
//Note: Our preferance would be to rename baseline variable to make it similar to endline variable because endline ones have been used elsewhere for analysis.

**child name variable 
rename R_Cen_namefromearlier_  R_Cen_comb_child_comb_name_label  //there is one more child name variable - R_Cen_u5child_  they are exactly the same 

**renaming age and gender variables 
rename  R_Cen_a4_hhmember_gender_  R_Cen_comb_hhmember_gender
rename R_Cen_a6_hhmember_age_  R_Cen_comb_hhmember_age

**renaming index and status
rename R_Cen_child_index_   R_Cen_comb_combchild_index
rename R_Cen_get_u5_status_  R_Cen_comb_combchild_status

**renaming availability variable 
rename R_Cen_child_caregiver_present_ R_Cen_comb_child_careg_present
rename R_E_comb_child_caregiver_present R_E_comb_child_careg_present

**renaming breatsfeeding variables
rename R_Cen_child_breastfeeding_ R_Cen_comb_child_breastfeeding
rename R_Cen_child_breastfed_num_ R_Cen_comb_child_breastfed_num

**renaming cuts and bruises variables 
rename R_Cen_a27_child_cuts_day_   R_Cen_comb_child_cuts_day
rename  R_Cen_a27_child_cuts_week_  R_Cen_comb_child_cuts_wk
rename  R_Cen_a27_child_cuts_2week_  R_Cen_comb_child_cuts_2wk

**renaming vomitting variables 
rename  R_Cen_a28_child_vomit_day_   R_Cen_comb_child_vomit_day
rename  R_Cen_a28_child_vomit_week_  R_Cen_comb_child_vomit_wk
rename  R_Cen_a28_child_vomit_2week_  R_Cen_comb_child_vomit_2wk

**renaming diarrhea variables 
rename R_Cen_a29_child_diarr_day_  R_Cen_comb_child_care_dia_day
rename  R_Cen_a29_child_diarr_week_  R_Cen_comb_child_care_dia_wk
rename  R_Cen_a29_child_diarr_2week_  R_Cen_comb_child_care_dia_2wk
rename  R_Cen_child_diarr_week_num_   R_Cen_comb_child_diarr_wk_num
rename R_Cen_child_diarr_2week_num_   R_Cen_comb_child_diarr_2wk_num
rename R_Cen_a30_child_diarr_freq_  R_Cen_comb_child_diarr_freq

**renaming stool variables 
rename R_Cen_a31_child_stool_24h_  R_Cen_comb_child_stool_24h
rename  R_Cen_a31_child_stool_yest_  R_Cen_comb_child_stool_yest
rename  R_Cen_a31_child_stool_week_  R_Cen_comb_child_stool_wk
rename R_Cen_a31_child_stool_2week_ R_Cen_comb_child_stool_2wk

**renaming blood variables 
rename R_Cen_a32_child_blood_day_  R_Cen_comb_child_blood_day
rename R_Cen_a32_child_blood_week_  R_Cen_comb_child_blood_wk
rename R_Cen_a32_child_blood_2week_  R_Cen_comb_child_blood_2wk

 **renaming village variables
rename R_Cen_village_str  R_Cen_village_name_str
rename R_E_village R_E_village_code

**renaming caregiver name 
rename R_Cen_u5mother_name_  R_Cen_comb_child_comb_care_label

  /*-----------------------------------------------------------------------------------------
Recategorising answer choices for better comparison
------------------------------------------------------------------------------------------*/
**recoding -99 or 99 to 999; 98 to -98; 77 to -77; No- 0 and Yes - 1

//Treating categorical variables 
ds R_Cen_comb_child_breastfeeding R_E_comb_child_breastfeeding R_Cen_comb_child_cuts_day R_Cen_comb_child_cuts_wk R_Cen_comb_child_cuts_2wk R_E_comb_child_cuts_day R_E_comb_child_cuts_wk R_E_comb_child_cuts_2wk R_Cen_comb_child_vomit_day R_Cen_comb_child_vomit_wk R_Cen_comb_child_vomit_2wk R_E_comb_child_vomit_day R_E_comb_child_vomit_wk R_E_comb_child_vomit_2wk R_Cen_comb_child_care_dia_day R_Cen_comb_child_care_dia_wk R_Cen_comb_child_care_dia_2wk R_E_comb_child_care_dia_day R_E_comb_child_care_dia_wk R_E_comb_child_care_dia_2wk R_E_comb_child_diarr_day R_E_comb_child_diarr_wk R_E_comb_child_diarr_2wk R_Cen_comb_child_stool_24h R_Cen_comb_child_stool_yest R_Cen_comb_child_stool_wk R_Cen_comb_child_stool_2wk R_Cen_comb_child_blood_day R_Cen_comb_child_blood_wk R_Cen_comb_child_blood_2wk R_E_comb_child_stool_24h R_E_comb_child_stool_yest R_E_comb_child_stool_wk R_E_comb_child_stool_2wk R_E_comb_child_blood_day R_E_comb_child_blood_wk R_E_comb_child_blood_2wk

foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 |  `var' == -99
replace `var' = -98 if `var' == 98 
replace `var' = -77 if `var' == 77
**defining label for options
label define `var'_x 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer" -77 "Other"
label values `var' `var'_x
}

//treating numerical variables now 
ds R_Cen_comb_hhmember_age R_Cen_hh_member_names_count R_Cen_comb_child_breastfed_num 
foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 |  `var' == -99
replace `var' = -98 if `var' == 98 
replace `var' = -77 if `var' == 77
}
 
//Here 888 represents - Child is still being breastfed (mother's milk) but we are replacing 888 with 889 because 888 was also used as a code for permanent filter in WASH section so to avoid any confusion, I am replacing 888 with 889 for this option 
replace R_Cen_comb_child_breastfed_num  = 889 if R_Cen_comb_child_breastfed_num == 888 
replace R_E_comb_child_breastfed_num = 889 if  R_E_comb_child_breastfed_num == 888
**we are only re-labeling this because in baseline, this variable was an integer and in endline this is a categorical variable. 
label define R_E_comb_child_breastfed_num_x 1 "Months" 2 "Days" 889 "Child is still being breastfed (mother's milk)" 999 "Don't know"
label values R_E_comb_child_breastfed_num  R_E_comb_child_breastfed_num_x


/*-----------------------------------------------------------------------------------------
Dropping unecesary variables 
------------------------------------------------------------------------------------------*/
drop _merge dup_HHID dup_UID match R_Cen_hh_member_names_count R_E_Village
save "${DataFinal}1_12_Cl_Census_Baseline_Endline_U5_Child.dta", replace



/***************************************************************************************
-----------------------------------------------------------------------------------------
 Section 9.3- Roster level dataset 
 ---------------------------------------------------------------------------------------
****************************************************************************************/
use "${Intermediate}1_1_Baseline_Census_Roster_Individual_level.dta", clear
clonevar  C_E_hhmember_name = R_Cen_namefromearlier_
merge 1:1 unique_id C_E_hhmember_name using  "${Intermediate}1_10_Cl_Endline_roster_merged_census_New_final_cleaned.dta"
br C_E_hhmember_name C_E_entry_type C_E_RV_entry_type if _merge == 2
br unique_id R_Cen_a3_hhmember_name_ if _merge == 1
/*
*****************************************************************************
Why are some household member names from baseline that are absent from endline census?
*******************************************************************************
There are 167 names that are only present in master i.e. baseline so we need to check if this is because these houseolds were unavailable in endline as that is the only reason these entries could be missing from roster dataset
unique_id	R_Cen_a3_hhmember_name_
10101108015	Chinuma Kadraka
10101108015	Himat Kadraka
10101108015	Krishna Kadraka
10101108015	Palabi Kadraka
10101108015	Tukuna Kadraka
10101113002	Arabinda behera
10101113002	Pramila behera
10101113002	Punyabati behera
10101113002	Purandar nayak
10101113002	Sahadeva nayak
10101113002	Tirupati behera
10101113031	Arati behera
10101113031	Bisekha behera
10101113031	Dhanbith behera
10101113031	Dukha behera
10101113031	Minati behera
20201108047	Amai Sabara
20201108047	Dhanush Sabara
20201108047	Kundira Sabara
20201108047	Taleng Sabara
20201108047	Washa Sabara
20201110016	Anjana kingal
20201110016	Debasmita Gamanga
20201110016	Rajukishore Kingal
20201113045	Akshay Kumar chhinchani
20201113045	Arpana kumar chhinchani
20201113045	Ranjita cham
20201113081	Alsha satpati
20201113081	Archita ganta
20201113081	Gitanjali satpati
20201113081	Shontash satpati
30202109011	Bishnu Hikaka
30202109011	Ramasingh Hikaka
30202109011	Relo Hikaka
30202109011	Runi Hikaka
30202109011	Srikrishna Hikaka
30202109011	Srimati Hikaka
30301109002	Anusaya Senapati
30301109002	Chinmayee Sahu
30301109002	Ganesh Senapati
30301109002	Jina Sahu
30301109002	Murari Sahu
30301109002	Tankesh Sahu
30301109002	Uttam Sahu
30301119062	Babyasachi Mohanti
30301119062	Brahmani Mohanti
30301119062	Meghamala Mohanti
30301119062	Pradipta Mohanti
30301119062	Pratik kumar Mohanti
30301119062	Sukanta chandra Mohanti
30301119063	Asharani chaudhari
30301119063	Bhanubati Senapati
30301119063	Damodara senapati
30301119063	Divyansh Senapati
30301119063	Ishant senapati
30301119063	Manoj senapati
30501107054	Gudia Pardi
30501107054	Khana Pardi
30501107054	Ritika Pardi
30501107054	Sibanya Pardi
30501107054	Silu Pardi
30501117006	Janbi sutar
30501117006	Pushpa sutar
30501117006	Sonali altur sultar
30501117006	Suresh sultar
30501117006	Veeren sutar
30602106023	Chuchitra Palaka
30602106023	Dinesh Bag
30602106023	Nakula Palaka
30602106023	Sarita Bag
30602106030	Jabesh Hial
30602106030	Jalandhar Hial
30602106030	Rambha Hial
30602117014	Madhusmita Himirika
30602117014	Mini pidika
30602117014	Pramod Himirika
30602117014	Ranjita Himirika
30602117035	Biswanath Ulaka
30602117035	Chinmahi Ulaka
30602117035	Sumitra Heprika
30602117035	Tushar ranjan Ulaka
30602119007	Basanti bebhar
30602119007	Ithan nayak
30701101005	Babita mahanandia
30701112022	Malati Mahanandia
30701112022	Naitik Mahanandia
30701112022	Sushanta Mahanandia
40101111033	Aika lalita
40101111033	Dhabaleswar Aika
40101111033	Purushottam aika
40101111033	Renuka Aika
40101111033	Sadananda Aika
40202108012	Bhagirathi Das
40202108012	Chnmayee Panda
40202108012	Pinki Das
40202108012	Pramad kumar Das
40202108012	Rutvik Das
40202108012	Sandhyarani Das
40202113041	Akhil sety
40202113041	Balakrishna sety
40202113041	Gitika ori chety
40202113041	Pramila sabara
40202113041	Prasanta sety
40202113041	Srikanta ori chety
40202113041	Sunita ori chety
40202113041	Sushanta ori sety
40202113041	Vobani sety
40301108014	Bhomesh Sabara
40301108014	Bikash Sabara
40301108014	Bobita Sabara
40301108014	Khirod Kumar Sabara
40301113002	Donesh sabara
40301113002	Gobardhana sabara
40301113002	Hiramani sabara
40401111028	Anita Mohapatra
40401111028	Pramila Mohapatra
40401111028	Santunu Mishra
40401111028	Tanushree Mishra
40401113001	Bobby sabara
40401113001	Jagannatha sabara
40401113001	Joty sabara
40401113001	Ratna sabara
50101115006	Jamuna Nagabansha
50101115006	Nilama Nagabansha
50101115006	Pankaj Nagabansha
50101115006	Pradee Pati Nagabansha
50101115006	Prafulla Nagabansha
50101115006	Punalu Nagabansha
50201104009	Ambika Bidika
50201104009	Apala Narshima Das
50201104009	Hasni Das
50201104009	Manani Das
50201104009	Ram Das
50201109035	Aruna Wataka
50201109035	Gayatri Wataka
50201109035	Kami Wataka
50201109035	Prafulla Wataka
50201109035	Sonu Wataka
50201109035	Uma Wataka
50301106014	Bino  Bidika
50301106014	Jati Bidika
50301106014	Kabya Bidika
50301106014	Lasita Bidika
50301106014	Malati Bidika
50301106014	Nilai Bidika
50301106014	Oni Bidika
50301106014	Sabi Bidika
50301106014	Santosh Bidika
50301106014	Sidhu Bidika
50301106014	Somit Bidika
50301106014	Wano Bidika
50301117034	Baiswabi kumari
50301117034	Priyanka Kumari
50401106047	Amit Miniaka
50401106047	Baisi Miniaka
50401106047	Basudev Miniaka
50401106047	Niharika Miniaka
50401106047	Nile Miniaka
50401106047	Singari Miniaka
50401106054	Dhanamani Saraka
50401106054	Kausili Saraka
50401106054	Renuka Saraka
50401106054	Tanuja Saraka
50501115015	Gundu Pidika
50501115015	Jayanti Pidika
50501115015	Kasturi Pidika
50501115015	Saami Pidika */

//getting availability status of the household for these IDs from the endline housheold survey  data 
drop R_E_instruction  R_E_resp_available //dropping this temporarily to get the status again
merge m:1 unique_id using "${DataFinal}1_8_Endline_Census_cleaned.dta", keepusing( R_E_resp_available R_E_instruction R_E_cen_resp_label ) gen(match) keep(1 3)
br unique_id R_Cen_a3_hhmember_name_ R_E_resp_available R_E_instruction if _merge == 1
br unique_id R_Cen_a3_hhmember_name_ R_E_resp_available R_E_instruction if _merge == 1 & R_E_resp_available == 1 &  R_E_instruction == 1

/*-----------------------------------------------------------------------------------------
Reasons for mismatch in the merge between women baseline census and endline census
------------------------------------------------------------------------------------------
######################
1. Master 167 entries (baseline): 
#######################
Out of 167 entries, 166 are cases where the target respondent was unavailable, resulting in the roster section not being administered. However, the household was available, allowing other sections (like child and women sections) to proceed with their respective respondents.

To verify, please refer to these specific variables:

R_E_resp_available: Indicates household availability.
R_E_instruction: Indicates target respondent availability.
When _merge == 1, you’ll find that in these 166 entries, the target respondent was consistently unavailable.
******************************************************************************************
Summary of one Issue out of 167 : Missing Data for Household Member Babita Mahanandia from endline census roster
******************************************************************************************
Upon verification, we identified an issue involving one household member, Babita Mahanandia (UID: 30701101005). Her information was not fully recorded in the census roster due to the following:
1. Preload Issue: Her name was not present in the preload data.
2. Surveyor Oversight: The surveyor did not report this discrepancy, resulting in missed information for two specific questions in the census roster.
////Missed Questions/////
                  Question 1: "Since September 2023, how many days has ${name_from_earlier_HH}  spent away from residence ?" (var name- R_E_comb_days_num_residence)
                  Question 2: "Is ${name_from_earlier_HH} still a member of this household, as per the definition?" (var name- R_E_comb_still_a_member)
While Babita’s name appears elsewhere in the survey, it is critical to flag this entry because it is the only instance (out of 167 entries) where:
     a. The household and target respondent were both available for the survey.
     b. These two census-related questions were not asked.
3. Impact: This omission creates a mismatch between endline and baseline data for Babita Mahanandia.
######################
2. Using 305 entries (endline): 
#######################
If you browse this: br C_E_hhmember_name C_E_entry_type C_E_RV_entry_type if _merge == 2
, you will know that all these 305 entries are the new members added in the endline that is why there is no match between this and baseline. Bt out of these 15 entries are those which are actually duplicates so we need to treat these. These duplicates can be recognized with the prefix 111 
*/

***********************************************************************************************
//Treating the entries where 111 prefix is there from only using merge dataset (endline) (_merge == 2)
***********************************************************************************************
**IMPORTANT NOTE: Out of these 305 entries, there are around 15 entries which have prefix 111 as explained previously these are the repeated entries from baseline census and they were entered to get their correct gender and age. So, the command below will help in identifying what exactly are these entries
br unique_id C_E_hhmember_name if _merge == 2 & C_E_entry_type == "N"
sort C_E_hhmember_name

*STEP 1----------->>>>> generating a variable to browse the IDs and do manual checks to see if their ages and genders have been correctly replaced in th file 3_X_HH_Data_Creation do-file
gen check = .

* Define the list of unique IDs where checks are required
local id_list unique_id "10101108026" "20201108055" "20201110019" "20201110035" "20201111076" "30301104006" "30501111018" "30501111021" "30602106057" "30602106063" "40202113033" "40301113007" "40301113016" "50201115043" "50301105008"
* Loop through each ID in the list and make the necessary changes to your variable
foreach id in `id_list' {
    replace check = 1 if unique_id == "`id'"
}
sort  unique_id
br  unique_id C_E_hhmember_name R_Cen_namefromearlier_  R_Cen_a6_hhmember_age_ R_Cen_a4_hhmember_gender_ R_E_comb_hhmember_age R_E_comb_hhmember_gender if check == 1   //after doing the verification we find that all the replacements are correctly made 


*STEP 2----------->>>>> Removing Duplicate Entries (only prefix 111 entries)

/****explanation of the approach******
---------------------------------------------
Since all entries have been correctly updated in the 3_X_HH_Data_Creation file, we can safely drop certain endline entries to avoid duplicates. This can be verified in step 1. Here’s the approach:

###Duplicate Handling: For example, if a household member named Simadri Manbik had an incorrect age of 12 in the baseline, but their age was corrected to 1 in the endline, the enumerator was asked to re-enter this information in the new roster with a prefix "111" in the name. As a result, Simadri Manbik now appears both in the new roster (corrected entry) and in the census roster (endline census roster).

###Endline Census Questions: During endline, two specific census questions were asked for household members:
a) R_E_comb_still_a_member: Confirming if the person is still a household member.
b) R_E_comb_days_num_residence: Checking the number of days the member has been away since September 2023.

###Duplication Issue: Since Manbik appears twice in the endline dataset (once in the census roster and once in the new roster), one of these entries may remain unmatched when merging with baseline data, causing duplication.

###Resolution: As all age and gender updates are now correctly reflected in the baseline census file, we can drop the new roster entries with the "111" prefix to prevent duplication. This ensures data consistency without duplicate entries.
*/
 
//Define the list of unique IDs where drops are required
local id_list unique_id "10101108026" "20201108055" "20201110019" "20201110035" "20201111076" "30301104006" "30501111018" "30501111021" "30602106057" "30602106063" "40202113033" "40301113007" "40301113016" "50201115043" "50301105008"

//splitting 111 from it so that we can target specific IDs
split  C_E_hhmember_name, generate(to_be_dropped) parse("111")

//Loop through each ID in the list and make the necessary changes to your variable
foreach id in `id_list' {
	drop if to_be_dropped2 != "" 
//we have used to_be_dropped2 here instead of to_be_dropped1 because split happens like this: 111-Simadri Manbik ---> ""   "Simadri Manbik" so to_be_dropped1 is empty and to_be_dropped2 contains the actual name
}
br C_E_hhmember_name C_E_entry_type C_E_RV_entry_type if _merge == 2

/*-----------------------------------------------------------------------------------------
Finding duplicates
------------------------------------------------------------------------------------------*/
//WAY 2
bysort unique_id C_E_hhmember_name : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
// WAY 1 
bysort  unique_id: gen dup_UID = cond(_N ==1,0,_n)	
sort unique_id
br unique_id C_E_hhmember_name dup_UID _merge C_E_entry_type if dup_UID != 0
//no duplicates found 

/*-----------------------------------------------------------------------------------------
Creating a combined variable 
------------------------------------------------------------------------------------------*/
**creating combined name variable 
gen C_roster_names = C_E_hhmember_name
label variable C_roster_names "Combined names of endline and baseline Roster members"
**creating combined age variable 
gen C_roster_age =  R_E_comb_hhmember_age
replace C_roster_age =  R_Cen_a6_hhmember_age_ if  C_roster_age == .
label variable C_roster_age "Combined ages of endline and baseline Roster members"
**combined variable for gender 
gen C_roster_gender = R_E_comb_hhmember_gender
replace  C_roster_gender = R_Cen_a4_hhmember_gender_ if  C_roster_gender == .
label variable C_roster_gender "Combined gender of endline and baseline Roster members"

/*-----------------------------------------------------------------------------------------
Renaming variables for consistency 
------------------------------------------------------------------------------------------*/
//Note: Our preferance would be to rename baseline variable to make it similar to endline variable because endline ones have been used elsewhere for analysis.

**renaming target resp name 
rename R_Cen_a1_resp_name R_Cen_cen_resp_label 

**renaming household roster vars
rename  R_Cen_namenumber_  R_Cen_comb_hh_index
rename R_Cen_namefromearlier_   R_Cen_comb_name_from_earlier_hh
rename R_Cen_a4_hhmember_gender_  R_Cen_comb_hhmember_gender
rename R_Cen_a5_hhmember_relation_  R_Cen_comb_hhmember_relation
rename R_Cen_a5_relation_oth_   R_Cen_comb_relation_oth
rename R_Cen_a6_hhmember_age_   R_Cen_comb_hhmember_age
//age variable of U1 kid is tricky because in baseline the pattern was slightly different than endline. In baseline, we would ask- Age of the child then whether it is in months or days but in endline we would first ask enum if she is telling the age in months or days and then we wiuld record ages in the respective age and months variables 
rename  R_E_comb_u1age  R_E_unit_age_  //renaming this to match baseline pattern because that is easier to understand. In endline it was different only because it was easy to detect outliers in that pattern. We are renaming it to make it equivalent to unit variable in baseline 
rename  R_Cen_a6_u1age_ R_Cen_comb_u1age   
rename  R_Cen_a8_u5mother_  R_Cen_comb_u5mother
rename R_Cen_u5mother_name_  R_Cen_comb_u5mother_name
rename R_Cen_a6_dob_   R_Cen_comb_dob_concat
  
 **renaming school variables 
rename  R_Cen_a9_school_  R_Cen_comb_school
rename  R_Cen_a9_school_level_   R_Cen_comb_school_level
rename  R_Cen_a9_school_current_  R_Cen_comb_school_current
rename  R_Cen_a9_read_write_ R_Cen_comb_read_write

 **renaming village variables
rename R_Cen_village_str  R_Cen_village_name_str
rename R_E_village R_E_village_code

**renaming pregnancy variables
rename R_Cen_a7_pregnant_month_  R_Cen_comb_preg_month
rename R_Cen_a7_pregnant_hh_  R_Cen_comb_preg_residence
rename  R_Cen_a7_pregnant_leave_  R_Cen_comb_preg_stay


  /*-----------------------------------------------------------------------------------------
Recategorising answer choices for better comparison
------------------------------------------------------------------------------------------*/
**recoding -99 or 99 to 999; 98 to -98; 77 to -77; No- 0 and Yes - 1

clonevar C_E_comb_hhmember_relation = R_E_comb_hhmember_relation
replace C_E_comb_hhmember_relation = -77 if  C_E_comb_hhmember_relation == 13

//creating a recoded variable for age. Creating anew coded variables of U1 age to match baseline pattern. This should be used for analysis  
clonevar  C_E_comb_u1age  = R_E_comb_unit_age_months 
replace  C_E_comb_u1age = R_E_comb_unit_age_days if  C_E_comb_u1age == .


//Treating categorical variables 
/*ds R_Cen_comb_child_breastfeeding R_E_comb_child_breastfeeding R_Cen_comb_child_cuts_day R_Cen_comb_child_cuts_wk R_Cen_comb_child_cuts_2wk R_E_comb_child_cuts_day R_E_comb_child_cuts_wk R_E_comb_child_cuts_2wk R_Cen_comb_child_vomit_day R_Cen_comb_child_vomit_wk R_Cen_comb_child_vomit_2wk R_E_comb_child_vomit_day R_E_comb_child_vomit_wk R_E_comb_child_vomit_2wk R_Cen_comb_child_care_dia_day R_Cen_comb_child_care_dia_wk R_Cen_comb_child_care_dia_2wk R_E_comb_child_care_dia_day R_E_comb_child_care_dia_wk R_E_comb_child_care_dia_2wk R_E_comb_child_diarr_day R_E_comb_child_diarr_wk R_E_comb_child_diarr_2wk R_Cen_comb_child_stool_24h R_Cen_comb_child_stool_yest R_Cen_comb_child_stool_wk R_Cen_comb_child_stool_2wk R_Cen_comb_child_blood_day R_Cen_comb_child_blood_wk R_Cen_comb_child_blood_2wk R_E_comb_child_stool_24h R_E_comb_child_stool_yest R_E_comb_child_stool_wk R_E_comb_child_stool_2wk R_E_comb_child_blood_day R_E_comb_child_blood_wk R_E_comb_child_blood_2wk

foreach var of varlist `r(varlist)'{
replace `var' = 999 if `var' == 99 |  `var' == -99
replace `var' = -98 if `var' == 98 
replace `var' = -77 if `var' == 77
**defining label for options
label define `var'_x 1 "Yes" 0 "No" 999 "Don't know" -98 "Refused to answer" -77 "Other"
label values `var' `var'_x
} */

  /*-----------------------------------------------------------------------------------------
Labeling variables for consistency 
------------------------------------------------------------------------------------------*/
label var R_E_comb_dob_concat "Date of birth"
label var R_Cen_comb_u1age  "How old is Under 1 year old child in months/days?"
label var C_E_comb_u1age  "How old is Under 1 year old child in months/days?"
label var  R_Cen_comb_u5mother  "A8) Does the mother/ primary caregiver of ${namefromearlier} live in this household currently?"
label var  R_E_Treat_V "Treatment status of the village"
label var R_E_comb_autoage "Age automatically calculated from date of birth of the child"
label var R_Cen_comb_preg_month "Which month of woman's pregnancy is this?"
label var R_Cen_comb_preg_residence "Is this woman's usual residence?"
label var R_Cen_comb_preg_stay "How long is woman planning to stay here?"
 

order C_E_comb_u1age R_E_unit_age_, after(R_E_comb_hhmember_age)  //these are teh final age variables for U1 years child 


/*-----------------------------------------------------------------------------------------
Dropping unecesary variables 
------------------------------------------------------------------------------------------*/
drop match check to_be_dropped1 to_be_dropped2 dup_HHID dup_UID _merge R_E_comb_unit_age_months R_E_comb_unit_age_days R_E_comb_cbw_age R_E_comb_all_age R_E_comb_age_confirm2 R_E_comb_year  R_E_comb_current_year R_E_comb_current_month  R_E_comb_age_years R_E_comb_age_months  R_E_comb_age_years_final R_E_comb_age_months_final  R_E_comb_year_dob_correction
save "${DataFinal}1_12_Cl_Census_Baseline_Endline_Roster.dta", replace


/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 10
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*************************************************************************************************************************************************************************************/


  /*****************************************************************
 COMBINING ALL BASELINE AND ENDLINE MERGED INDIVIDUAL DATASETS 
*****************************************************************/

use "${DataFinal}1_12_Cl_Census_Baseline_Endline_U5_Child.dta", clear
gen C_dataset_type = "Child"
append using "${DataFinal}1_12_Cl_Census_Baseline_Endline_Roster.dta"
replace C_dataset_type = "Roster" if  C_roster_names != ""
append using "${DataFinal}1_12_Cl_Census_Baseline_Endline_CBW.dta"
replace C_dataset_type = "CBW" if  C_women_names != ""

//Please tabulate this variable: C_dataset_type  to get the breakdown of each type of dataset present in this master dataset 
order C_dataset_type 
label variable C_dataset_type "Type of  combined baseline-endline Individual dataset"
save "${DataFinal}0_Master_12_Individual_data_baseline_endline_census.dta", replace


/*POINTS TO DISCUSS WITH AKITO AND JEREMY
1. Should we also create UID for women from baseline dataset who we were unable to visit in endline ? We can't use raw dataset for that purpose 
2. Ask Niharika to re-run her file - 3_X_HH_data creation
3. chnage the name of one resp from 999 to actual name
4. mention about 111 cases that I am dropping this only from merged roster data
5. Ask Niharika to chnage permanent filter code from 888 to something else as 888 is being used for if the child is being still breatsfed 
**how to treat this variable- Is the caregiver/mother of  ${Cen_child_u5_name_label} available ? (options have been changed signitificantly) 
7 use a dated version later also for baseline census 
8 //not able to understand how to recode these variables- R_Cen_resp_available R_Cen_instruction R_E_resp_available R_E_instruction


*/

















/*************************************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SECTION 11
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
*JL: We may want to keep this observation depending on the context. If she was staying there a long time and knows the   


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






** The case that was corrected in Niharika's do file 
/*unique_id	C_E_hhmember_name	R_Cen_namefromearlier_	R_Cen_a6_hhmember_age_	R_Cen_a4_hhmember_gender_	R_E_comb_hhmember_age	R_E_comb_hhmember_gender
40202113033	Simadri manbik	Simadri manbik	12	Male		
40202113033	111 Simadri Manbik				1	Male*/





