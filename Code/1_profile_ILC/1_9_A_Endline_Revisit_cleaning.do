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
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey

clear
set maxvar 30000	
clear all               
set seed 758235657 // Just in case

/***************************************************************HH LEVEL ENDLINE REVISIT DATA 
***************************************************************/

*do "${Do_lab}import_India_ILC_Endline_Census_Revisit.do"

use "${DataPre}1_9_Endline_revisit_final.dta", clear



bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

sort unique_id submissiondate 
br submissiondate unique_id key enum_name_label resp_available instruction if dup_HHID > 0


br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_child_u5_name_label_* comb_child_caregiver_present_* comb_main_caregiver_label_* comb_preg_index_1 comb_preg_index_2 comb_preg_index_3 comb_preg_index_4 comb_child_ind_1 comb_child_ind_2 if dup_HHID > 0



/* 
//create a spare key 

APPROACH USED FOR DEALING WITH DUPLICATES 

ISSUE WITH PRELOAD: Preload for this survey was updated becuse some child names weren't appearing in the form so the instruction to the surveyors was they have to copy this data into new version and then delete the old version and submit the new version data where applicable child names were comimg for that respective UID

OBJECTIVE: I want to drop those IDs which were done on old version becasue all applicable child names weren't appearing for that respective UID in old version but after preload was updated all applicable child names were coming

ACTION TAKEN: It is not very starightforward to drop old version IDs becasue some enums made a mistake by sending their old versions where women surveys were already done so they couldn't copy that data into new version and there was also no possibility to go back to these women and survey them so they just marked these women as unavailable with child data when submitting new version. So, basically the problm is i the old version submissions women data has been done on some IDs but child names wreen't even appearing so there is no way to identify if children data was to be done on that ID or not 

TYPES OF DUPLICATES: 

TYPE 1: 
Old version data was sent where women data was done as women were available but applicable child names weren't appearing for that respective UID and then enum also submitted new version where all women and child names were appearing but here the child data wasn't done and child was marked as unavailable 
So, to deal with this we will replace applicable child variables in old version data to reflect that these children belong to this ID but their data wasn't done because of their unvailability 
 
TYPE 2: 
Old version data was sent where women data was done as women were available but applicable child names weren't appearing for that respective UID and then enum also submitted new version where all women and child names were appearing but here the child data was done and child was marked as available and full survey was administered 
So, to deal with this we can't do normal replace we will have to merge child and women data on the UID to create a one observation where all sections pertaining to that ID are appearing 

TYPE 3: 
Old version data was sent where women data was not done as women were unavailable but applicable child names weren't appearing for that respective UID and then enum also submitted new version where all women and child names were appearing but but here the child data wasn't done and child was marked as unavailable 
So, to deal with this we can just drop the observation where child names weren't appearing that is old version obs as nrew version also has the unavailable status for women so no data is being lost


TYPE 4: 
Old version data was sent where women data was not done as women were unavailable but applicable child names weren't appearing for that respective UID and then enum also submitted new version where all women and child names were appearing and here the child data was done and child was marked as available
So, to deal with this we will replace applicable child variables in new version data to reflect that these children and women belong to this ID but women data wasn't done because of their unvailability


TYPE 5: 
both old version and new versions are sent but enum had alreday copied the data into new version so no replace,ent or merge is required we can just drop old version data because new version alreday has all the applicable cases 




If replacements are being administered as a solution which variables get replaced: 

Mandaory replace- 

comb_child_ind
comb_child_u5_name_label
comb_main_caregiver_label
comb_child_caregiver_present

Situational replace- (replaced only if applicable) 

comb_child_care_pres_oth
comb_child_age_V
comb_child_act_age
comb_child_caregiver_name
comb_child_residence
comb_child_name
comb_child_u5_caregiver_label


If women replacements are being done then : 

Mandatory replace- 

comb_preg_index
comb_name_CBW_woman_earlier
comb_resp_avail_CBW
comb_resp_avail_CBW_oth

Situational replace- (replaced only if applicable) 

comb_resp_gen_V_CBW
comb_age_ch_CBW
comb_resp_age_V_CBW
comb_resp_age_CBW

NOTE: Replacements are only done if either women or child data was unavailable otherwise you can't replace each variable 

If replacements are not aplicable we do merge by UID (this must be done at the end) 

*/



//drop duplicates 
//Explanation: Preload for this survey was updated becuse some child names weren't appearing in the form so the instruction to the surveyors was they have to copy this data into new version and then delete the old version and submit the new version data where applicable child names were comimg for that respective UID but this enum sent the old version too so I dropped the old version data 

//CASE OF ID - "30301109053"
//TYPE 5 DUPLICATE 

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "30301109053"

drop if key == "uuid:20270a02-5941-47a7-b53f-7194404e8b30" & unique_id == "30301109053"



//CASE OF ID - "30701119030"

/*Main respondent survey was applicable and child survey but in old version child names weren't appearing so only main respondent data was done and child names weren't even coming so we need to drop the new version submission because main resp survey was marjked as unavailable there and child data was unavailable so replacements for child variable need to be done in the old version */


br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "30701119030"

replace comb_child_u5_name_label_1 = "Labesha Hikaka" if key == "uuid:0aa3d0a7-f32f-49cb-857c-dc828c4034fb"  & unique_id == "30701119030" 

replace comb_main_caregiver_label_1 = "Indra mani Hikaka" if key == "uuid:0aa3d0a7-f32f-49cb-857c-dc828c4034fb" & unique_id == "30701119030" 

replace comb_child_caregiver_present_1 = -77 if key == "uuid:0aa3d0a7-f32f-49cb-857c-dc828c4034fb" & unique_id == "30701119030" 

replace comb_child_ind_1 = "1" if key == "uuid:0aa3d0a7-f32f-49cb-857c-dc828c4034fb" & unique_id == "30701119030" 

replace comb_child_care_pres_oth_1 = "Maa ke sath dusre village gaye hai kob ayege pata nehi" if key == "uuid:0aa3d0a7-f32f-49cb-857c-dc828c4034fb" & unique_id == "30701119030" 

drop if key == "uuid:832d0cdd-82d9-4fa8-ac3c-f0d4274faf3d" & unique_id == "30701119030" 


//CASE for ID - "40202108030"

/*TYPE 1 DUPLICATE (PLEASE READ DESCRIPTION ABOVE)
Replacements are being made in the old version submission because it has complete women data*/

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "40202108030"

replace comb_child_u5_name_label_1 = "Pihu Pradhan" if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 

replace comb_main_caregiver_label_1 = "Banita Raouta" if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 


replace comb_child_caregiver_present_1 = 5 if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 


replace comb_child_ind_1 = "1" if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 

replace comb_child_caregiver_name_1 = 5 if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 

replace comb_child_residence_1 = 1 if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 

replace comb_child_name_1 = "988" if key == "uuid:7c9ec07b-1869-47a6-a0d6-edd9ee70d341"  & unique_id == "40202108030" 


drop if key == "uuid:e6d04108-7221-4f6d-be77-7fc19092e8c0" & & unique_id == "40202108030" 



//Case of UID- 40202108039

//Here enum did the women survey again because she had sent old version survey as well where women survey was done but child names weren't appearing that's why child surveys weren't done but this enum on the new version did women survey again and child survey again and sent it so we should drop old version data because new version has no missing data 

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "40202108039"

br submissiondate  unique_id  key comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_not_curr_preg_* comb_child_u5_name_label_* comb_child_ind_* comb_main_caregiver_label_* comb_child_caregiver_present_* if unique_id == "40202108039"


drop if key == "uuid:b638f0cc-1ad0-446c-86ce-3b4bc5aa567e" & & unique_id == "40202108039" 

//case of UID - 40202110037

//TYPE 1 DUPLICATE (PLease refer to description above)

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "40202110037"


replace comb_child_u5_name_label_1 = "New baby" if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 

replace comb_main_caregiver_label_1 = "Goutami Ladi" if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 


replace comb_child_caregiver_present_1 = 5 if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 


replace comb_child_ind_1 = "1" if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 

replace comb_child_caregiver_name_1 = 1 if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 

replace comb_child_residence_1 = 1 if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 

replace comb_child_name_1 = "988" if key == "uuid:90c042fa-51b5-4565-a990-a3fecd5b5cc2"  & unique_id == "40202110037" 


drop if key == "uuid:a6d45213-5337-44c7-951f-b5b51c631065" & & unique_id == "40202110037" 


//case of UID - 40301108013

//Here enum did the women survey again because she had sent old version survey as well where women survey was done but child names weren't appearing that's why child surveys weren't done but this enum on the new version did women survey again and child survey again and sent it so we should drop old version data because new version has no missing data 


br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "40301108013"

drop if key == "uuid:1dfdb694-9d40-4476-aaab-321e9c62028d" & unique_id == "40301108013" 


//case of UID = 40301113025

//TYPE 1 DUPLICATE 

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_* comb_resp_gen_v_cbw_* comb_age_ch_cbw_* comb_resp_age_v_cbw_* comb_resp_age_cbw_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "40301113025"

replace comb_resp_avail_cbw_1 = 2 if key == "uuid:e19f6abd-e053-4c3c-8fe1-fa63214826ab" & unique_id == "40301113025" & comb_name_cbw_woman_earlier_1== "Sonali gouda" 


replace comb_resp_avail_cbw_2 = 2 if key == "uuid:e19f6abd-e053-4c3c-8fe1-fa63214826ab" & unique_id == "40301113025" & comb_name_cbw_woman_earlier_2 == "Mamali gouda"

drop if key == "uuid:62db341b-de7e-45cf-a983-0ab650e964f6" & unique_id == "40301113025" 


//case of UID = 50201109021

/* I dropped new version ID because the whole HH was unavailable so enum marked HH unavailable that measn no survey was administered so I did replacements in the old version submission to refelct the applicable child names on that ID. I referred to revisit preload to identify the child names applicable on this ID */

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50201109021"


replace comb_child_u5_name_label_1 = "Milan Kandagari"  if key == "uuid:7ce48c56-4d02-4234-9e41-414a3567d55b" & unique_id == "50201109021" 

replace comb_child_caregiver_present_1 = 5  if key == "uuid:7ce48c56-4d02-4234-9e41-414a3567d55b" & unique_id == "50201109021" 

replace comb_child_ind_1 = "1" if key == "uuid:7ce48c56-4d02-4234-9e41-414a3567d55b" & unique_id == "50201109021" 

replace comb_main_caregiver_label_1 = "Minati Kandagari" if key == "uuid:7ce48c56-4d02-4234-9e41-414a3567d55b" & unique_id == "50201109021" 


drop if key == "uuid:297b27f2-4101-4181-bf18-af6175f04797" & unique_id == "50201109021" 


//Case of UID = 50201115026

/* I dropped new version ID because the whole HH was unavailable so enum marked HH unavailable that measn no survey was administered so I did replacements in the old version submission to refelct the applicable child names on that ID. I referred to revisit preload to identify the child names applicable on this ID */


br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50201115026"


replace comb_child_u5_name_label_1 = "Lishima Bidika"  if key == "uuid:5537cede-5e90-4d1e-a6d0-3b6c0503a684" & unique_id == "50201115026" 

replace comb_child_caregiver_present_1 = 5  if key == "uuid:5537cede-5e90-4d1e-a6d0-3b6c0503a684" & unique_id == "50201115026" 

replace comb_child_ind_1 = "1" if key == "uuid:5537cede-5e90-4d1e-a6d0-3b6c0503a684" & unique_id == "50201115026" 

replace comb_main_caregiver_label_1 = "Kasu Mandangi" if key == "uuid:5537cede-5e90-4d1e-a6d0-3b6c0503a684" & unique_id == "50201115026" 


drop if key == "uuid:59b8b051-e779-4467-a649-f2b49ef54e1b" & unique_id == "50201115026" 


//case of UID - 50201115043

/* I dropped new version ID because the whole HH was unavailable so enum marked HH unavailable that measn no survey was administered so I did replacements in the old version submission to refelct the applicable child names on that ID. I referred to revisit preload to identify the child names applicable on this ID */

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50201115043"


replace comb_child_u5_name_label_1 = "Debashmita Bidika"  if key == "uuid:30eab718-52aa-42a6-9ebb-0733095a68f5" & unique_id == "50201115043" 

replace comb_child_caregiver_present_1 = 5  if key == "uuid:30eab718-52aa-42a6-9ebb-0733095a68f5" & unique_id == "50201115043" 

replace comb_child_ind_1 = "1" if key == "uuid:30eab718-52aa-42a6-9ebb-0733095a68f5" & unique_id == "50201115043" 

replace comb_main_caregiver_label_1 = "Jyoshna Rani Pradhan" if key == "uuid:30eab718-52aa-42a6-9ebb-0733095a68f5" & unique_id == "50201115043" 


drop if key == "uuid:b38a369a-521c-4d59-a243-46895bc109da" & unique_id == "50201115043" 



//case of UID - 50301105008

//TYPE 3 DUPLICATE 

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50301105008"

drop if key == "uuid:9418ebad-ede3-4780-b275-a84b1b077f46" & unique_id == "50301105008" 


//case of UID = 50301117008

//TYPE 3 DUPLICATE 

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50301117008"

drop if key == "uuid:be4aefc3-cfc2-4b7a-87f7-06b8285b9dac" & unique_id == "50301117008" 

//case of UID - 50301117064

/* There are 4 eligible women on this ID and all 4 women surveys were marked as unavailable earlier but in the new version 2 out 4 women were surveyed and child survey was also done on new version so it makes sense to drop the old version ID.

I do minor replacements in women variables to make the reason of unavailability of uniform across */

br submissiondate r_cen_village_name_str unique_id key enum_name_label resp_available instruction wash_applicable comb_name_cbw_woman_earlier_* comb_resp_avail_cbw_* comb_resp_avail_cbw_oth_*  comb_child_u5_name_label_1 comb_main_caregiver_label_1 comb_child_caregiver_present_1 comb_child_ind_1 comb_child_care_pres_oth_1 comb_child_caregiver_name_1 comb_child_residence_1 comb_child_name_1 comb_child_u5_name_label_2 comb_main_caregiver_label_2 comb_child_caregiver_present_2 comb_child_ind_2 comb_child_care_pres_oth_2 comb_child_caregiver_name_2 comb_child_residence_2 comb_child_name_2 if unique_id == "50301117064"


replace comb_resp_avail_cbw_1 = 5 if key == "uuid:738387e0-f484-4c7b-b2f4-722d3b6c324e" & unique_id == "50301117064"


replace comb_resp_avail_cbw_2 = 5 if key == "uuid:738387e0-f484-4c7b-b2f4-722d3b6c324e" & unique_id == "50301117064"


drop if key == "uuid:b893a36b-1e5b-4087-8cc6-2425c05be489" & unique_id == "50301117064"

drop dup_HHID
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

isid unique_id

*save "${DataTemp}Endline_Revisit_for_merge.dta", replace

keep  unique_id wash_applicable comb_hhmember_name* comb_hhmember_age* comb_hhmember_gender* r_cen_main_resp_with_age total_u5_child_comb total_cbw_comb wash_applicable  r_cen_a1_resp_name r_cen_a10_hhhead   r_cen_landmark r_cen_address r_cen_saahi_name r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2  r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name     r_cen_fam_name*  cen_fam_age* cen_fam_gender* r_cen_a12_water_source_prim  cen_num_hhmembers cen_num_noncri r_cen_noncri_elig_list village_name_res noteconf1 info_update enum_name enum_code enum_name_label resp_available instruction consent  no_consent_reason no_consent_reason_1 no_consent_reason_2 no_consent_reason__77 no_consent_oth no_consent_comment  cen_resp_name cen_resp_label cen_resp_name_oth  n_new_members n_new_members_verify n_hhmember_count  n_fam_name* n_fam_age*  n_female_above12 n_num_femaleabove12 n_male_above12 n_num_maleabove12 n_adults_hh_above12 n_num_adultsabove12 n_children_below12 n_num_childbelow12 n_female_15to49 n_num_female_15to49 n_children_below5 n_num_childbelow5 n_allmembers_h n_num_allmembers_h water_source_prim water_prim_oth  water_sec_yn water_source_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 water_source_sec_oth secondary_water_label num_water_sec water_sec_list_count water_sec_labels water_source_main_sec secondary_main_water_label quant sec_source_reason sec_source_reason_1 sec_source_reason_2 sec_source_reason_3 sec_source_reason_4 sec_source_reason_5 sec_source_reason_6 sec_source_reason_7 sec_source_reason__77 sec_source_reason_999 sec_source_reason_oth water_sec_freq water_sec_freq_oth collect_resp  people_prim_water num_people_prim people_prim_list_count people_prim_labels  prim_collect_resp where_prim_locate where_prim_locate_enum_obs collect_time collect_prim_freq water_treat water_stored water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_oth water_treat_freq water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 treat_freq_oth not_treat_tim treat_resp  num_treat_resp treat_resp_list_count treat_resp_labels treat_primresp treat_time treat_freq collect_treat_difficult clean_freq_containers clean_time_containers water_source_kids water_prim_source_kids water_prim_kids_oth water_source_preg water_prim_source_preg water_prim_preg_oth water_treat_kids water_treat_kids_type water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999 water_treat_kids_oth treat_kids_freq treat_kids_freq_1 treat_kids_freq_2 treat_kids_freq_3 treat_kids_freq_4 treat_kids_freq_5 treat_kids_freq_6 treat_kids_freq__77 treat_kids_freq_oth jjm_drinking tap_supply_freq tap_supply_freq_oth tap_supply_daily reason_nodrink reason_nodrink_1 reason_nodrink_2 reason_nodrink_3 reason_nodrink_4 reason_nodrink_999 reason_nodrink__77 nodrink_water_treat_oth jjm_stored jjm_yes jjm_use jjm_use_1 jjm_use_2 jjm_use_3 jjm_use_4 jjm_use_5 jjm_use_6 jjm_use_7 jjm_use__77 jjm_use_999 jjm_use_oth tap_function tap_function_reason tap_function_reason_1 tap_function_reason_2 tap_function_reason_3 tap_function_reason_4 tap_function_reason_5 tap_function_reason_999 tap_function_reason__77 tap_function_oth tap_issues tap_issues_type tap_issues_type_1 tap_issues_type_2 tap_issues_type_3 tap_issues_type_4 tap_issues_type_5 tap_issues_type__77 tap_issues_type_oth  n_med_seek_all n_med_seek_all_1 n_med_seek_all_2 n_med_seek_all_3 n_med_seek_all_4 n_med_seek_all_5 n_med_seek_all_6 n_med_seek_all_7 n_med_seek_all_8 n_med_seek_all_9 n_med_seek_all_10 n_med_seek_all_11 n_med_seek_all_12 n_med_seek_all_13 n_med_seek_all_14 n_med_seek_all_15 n_med_seek_all_16 n_med_seek_all_17 n_med_seek_all_18 n_med_seek_all_19 n_med_seek_all_20 n_med_seek_all_21 n_med_seek_lp_all_count cen_med_seek_all cen_med_seek_all_1 cen_med_seek_all_2 cen_med_seek_all_3 cen_med_seek_all_4 cen_med_seek_all_5 cen_med_seek_all_6 cen_med_seek_all_7 cen_med_seek_all_8 cen_med_seek_all_9 cen_med_seek_all_10 cen_med_seek_all_11 cen_med_seek_all_12 cen_med_seek_all_13 cen_med_seek_all_14 cen_med_seek_all_15 cen_med_seek_all_16 cen_med_seek_all_17 cen_med_seek_all_18 cen_med_seek_all_19 cen_med_seek_all_20 cen_med_seek_all_21    a40_gps_manuallatitude a40_gps_manuallongitude a40_gps_manualaltitude a40_gps_manualaccuracy a40_gps_handlongitude a40_gps_handlatitude a41_end_comments a42_survey_accompany_num survey_member_names_count cen_num_childbelow5  instancename formdef_version key submissiondate starttime endtime 


clonevar Revisit_key = key

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

*drop if date_final < mdy(4,21,2024)

* Optionally, drop the intermediate variables if not needed

    /*drop if End_date < mdy(4,21,2024)
	format End_date  %d*/



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



merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V Village Panchatvillage BlockCode) keep(1 3)

save "${DataFinal}1_9_Endline_revisit_final_cleaned.dta", replace


savesome using "${DataFinal}1_9_Endline_revisit_cleaned_consented.dta" if R_E_consent==1, replace

/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
