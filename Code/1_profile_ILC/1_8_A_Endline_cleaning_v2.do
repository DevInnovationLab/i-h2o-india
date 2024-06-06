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

clear all               
set seed 758235657 // Just in case

cap program drop key_creation
program define   key_creation

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


* Master
use "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", clear


rename cen_malesabove15_list_preload cen_malesabove15_lp
keep key  cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12 ///
          cen_children_below12 cen_num_childbelow12 cen_num_childbelow5 cen_num_malesabove15 cen_malesabove15_lp ///
		  cen_num_hhmembers cen_num_noncri resp_available instruction instruction_oth  
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_r_`x'  
	}
	rename R_E_r_key R_E_key
	


/*******************************************************************

#Dropping duplicates 

********************************************************************/

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 

//unique_id == "10101108009"
drop if R_E_key == "uuid:cf2d7db0-db8f-427d-a77a-87fd0264f94c" 


//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
// unique_id == "10101108026"
drop if R_E_key == "uuid:30d0381d-8076-46bc-86ce-fde616ccb3b6" 

//enum submitted this twice and both of these are unavailable IDs so keeping only one such case
// unique_id == "30501117006"
drop if R_E_key == "uuid:4d9381e8-e356-4ae2-be61-8d57322ef40a" 

//enum submitted this twice and both of these are unavailable IDs so keeping only one such case
//unique_id == "40201111005"
drop if R_E_key == "uuid:20fdbfce-ef3e-46c9-ad31-c464a7e1c1bb" 

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
// unique_id == "40201113010"
drop if R_E_key == "uuid:975636db-d2ae-4837-8fef-e2ea1186ede3" 

//enum submitted this twice so removing the case which was marked as unavailable or locked because they were found after and a complete survey was submitted later for them 
//unique_id == "40202113050"
drop if R_E_key == "uuid:77e94cac-755c-4bc1-a852-8bd4bb859ae3" 


//one was a practise entry that is why we dropped it 
// unique_id == "20201108018"
drop if R_E_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 

//this ID was attempted later on
// unique_id == "10101113031"
drop if R_E_key == "uuid:cc7d0330-7241-4bdd-a46b-97e16ed56e60" 

//this ID was attempted later on
//unique_id == "20201108047"
drop if R_E_key == "uuid:611e4cfa-aef2-4bfd-a40e-6ee647e317d4" 

//this ID was attempted later on
// unique_id == "20201110016"
drop if R_E_key == "uuid:4967324b-4832-42ba-8d5b-e4a57876dfbe" 

//all the IDs below were given as re-visits as these are house lock IDs so surveyors were asked to submit attempted HH lock IDs on the main endline census form that is why those IDs that were later found I have dropped their previous date entry that was marked as unavailable and for HH lock IDs that are still locked I have dropped IDs with an earlier date 
//unique_id == "20201113045"
drop if R_E_key == "uuid:4c7fd5ae-0a6b-4c95-a40a-d6d8376ff1eb" 

//unique_id == "20201113081"
drop if R_E_key == "uuid:52af03bb-2287-4a07-a4b3-59867ba792a2" 

//unique_id == "30202109011"
drop if R_E_key == "uuid:ee472a73-3548-4e04-a89d-91fac2ad60ee" 

//unique_id == "30301119063"
drop if R_E_key == "uuid:78f11df1-c342-479a-a616-87087137624d" 

//unique_id == "30501117040"
drop if R_E_key == "uuid:ea7326e8-3a8a-49a9-a152-3ee4ab05c803" 

//unique_id == "30602105059"
drop if R_E_key == "uuid:32bfbced-d7c4-4ef2-98a7-4a67d7e6d478" 

// unique_id == "30701105023"
drop if R_E_key == "uuid:f94eef7a-0908-4b74-a7d7-6f36fd1c312b" 

//unique_id == "30701112022"
drop if R_E_key == "uuid:d7b0d915-1d36-43d8-9d6d-8a2962f8d6ad" 

//unique_id == "40101111026"
drop if R_E_key == "uuid:a9968d3e-2969-4459-8823-3c87eed84057" 

//unique_id == "40101111033"
drop if R_E_key == "uuid:274cd721-064e-4892-98dc-1e2476cf8c09" 

//unique_id == "40202108062"
drop if R_E_key == "uuid:67226e44-3dcf-4b7b-a29b-99c5be2285a1" 

// unique_id == "40202113009"
drop if R_E_key == "uuid:3f0c8021-bec8-4da1-ad86-213379450f98" 

//unique_id == "40301108014"
drop if R_E_key == "uuid:c7c5f66d-6a2d-400f-842c-526956b02a17" 

//unique_id == "40301108018"
drop if R_E_key == "uuid:5befa7a4-e547-4f75-bc2c-7d4c1de617a9" 

//unique_id == "40301108026"
drop if R_E_key == "uuid:1f5a83f4-193b-4a5a-8696-bf9b8c145384" 

//unique_id == "40301113002"
drop if R_E_key == "uuid:f1ea1ecc-51cd-4749-9013-95c5c5bbb6f4" 

//unique_id == "40401108066"
drop if R_E_key == "uuid:fdc9757f-5c52-4fcf-9dca-9389dfb84a4b" 

//unique_id == "40401111028"
drop if R_E_key == "uuid:151ebafd-91a4-4f2a-896f-26ab6a663af0" 

//unique_id == "40401113001"
drop if R_E_key == "uuid:e500a8b7-879e-49c3-a2c5-6b9d97e56c13" 

//unique_id == "50101119016"
drop if R_E_key == "uuid:cdc34462-b535-47b7-b777-3bfda2378c05" 

//unique_id == "50201104008"
drop if R_E_key == "uuid:b04274f3-d920-4c2e-a773-b75263801eef" 

//unique_id == "50201104009"
drop if R_E_key == "uuid:1c8d5fa5-5bc7-4317-ba2b-e981f139925e" 

//unique_id == "50201109003"
drop if R_E_key == "uuid:e671b025-fb01-484e-9d1c-dd97de89a5bc" 

//unique_id == "50201109035"
drop if R_E_key == "uuid:7114b0da-5af1-4000-898f-2d1e58c707a2" 

//unique_id == "50201119022"
drop if R_E_key == "uuid:899eee2b-efb9-4022-a142-97187c027f80" 

//unique_id == "50201119042"
drop if R_E_key == "uuid:56feac43-7e90-4f66-91f0-5f0d6cfa6d1c" 

//unique_id == "50201119044"
drop if R_E_key == "uuid:da5b0b89-ed38-4e22-80c1-3e36f18d94bb" 

//unique_id == "50301105005"
drop if R_E_key == "uuid:4672d4b8-040d-4397-9bc1-3ce62d9466f3" 

//& unique_id == "50301106006"
drop if R_E_key == "uuid:5bbcc0c5-a6b6-454e-972d-b54408909622" 

//& unique_id == "50301106013"
drop if R_E_key == "uuid:29da7271-93cd-4cda-89d0-008a6cc0ece8" 

//& unique_id == "50301106014"
drop if R_E_key == "uuid:47c1db5e-d49c-4ac8-88e6-ee9f34b8cf57" 

//& unique_id == "50301106035"
drop if R_E_key == "uuid:4f07d6bb-a863-450c-9d20-a4bf7ea5ee2d" 

//unique_id == "50301107003"
drop if R_E_key == "uuid:7bd7b4e0-994f-4d98-a311-306f38779738" 

//& unique_id == "50301107014"
drop if R_E_key == "uuid:1f6dc4bc-3148-47f4-a66d-a66ce89f54da" 

//& unique_id == "50301107025"
drop if R_E_key == "uuid:33b7c651-d400-4eea-b56b-6b01c4f360bb" 

//& unique_id == "50301117034"
drop if R_E_key == "uuid:caaa46fe-ba0d-4822-aa2f-ea7f080f41e4" 

//& unique_id == "50401106024"
drop if R_E_key == "uuid:972d3059-537c-475d-809a-d198a160d021" 

//& unique_id == "50401106054"
drop if R_E_key == "uuid:555ef21b-a498-47da-9350-f7e455d67c92" 

//& unique_id == "50401107033"
drop if R_E_key == "uuid:e3e37787-7b7c-4072-85e6-267f95d7cacf" 

//unique_id == "50401107059"
drop if R_E_key == "uuid:22b65692-176f-4586-81ac-04b3de6258c5" 

//unique_id == "50401107066"
drop if R_E_key == "uuid:54952409-2f3e-4fe9-8f88-78b7c24057ea" 

//unique_id == "50402106050"
drop if R_E_key == "uuid:d5b10d89-ba3e-4da2-9397-19515333c6d5" 

//unique_id == "50402107010"
drop if R_E_key == "uuid:daf69f4b-65ed-4934-8495-278dbfe5a324" 

//unique_id == "50402107043"
drop if R_E_key == "uuid:4ee0dbf4-a7b9-466f-be10-ec409c6aa8b3" 

//unique_id == "50402107049"
drop if R_E_key == "uuid:a1221224-7ccf-4a77-9537-574298a2f6a3" 

//unique_id == "50402117026"
drop if R_E_key == "uuid:a8d7ea95-d112-4316-a1a7-36cbed0cce18" 

//unique_id == "50501104007"
drop if R_E_key == "uuid:9f7a0610-b7ff-4920-ac1d-2cb49c06cd90" 

//unique_id == "50501104011"
drop if R_E_key == "uuid:5f28da33-eb86-455c-9e4b-5d3297e9e041" 

//unique_id == "20101108027"
drop if R_E_key == "uuid:52a4d7a5-4121-4ebd-9793-9a49f91890f1" 

//unique_id == "20201108043"
drop if R_E_key == "uuid:cd2002a5-04f7-4655-bd6c-e30f28f2918d" 

//unique_id == "20201113046"
drop if R_E_key == "uuid:587a59e3-ec78-4343-b82d-3da878c2ea4a" 

//unique_id == "30301109002"
drop if R_E_key == "uuid:154a71f5-8410-4a45-a451-b8d44b5f2015" 

//unique_id == "30301119062"
drop if R_E_key == "uuid:e37fbb15-5044-4e65-aeba-9382971590bc" 

//unique_id == "30602106023"
drop if R_E_key == "uuid:e2b0bf67-16af-4e0d-935d-e4566d28dc3b" 

//unique_id == "30602106030"
drop if R_E_key == "uuid:e3671011-8b5f-4dee-bf09-ab815f14efda" 

//unique_id == "30602117014"
drop if R_E_key == "uuid:40774fa6-689c-4654-a5dd-23e8664c831d" 

//unique_id == "30602117025"
drop if R_E_key == "uuid:030d441b-2fbf-47b5-a7db-aabed4650aa9" 

//unique_id == "30701112023"
drop if R_E_key == "uuid:0a9ec852-7e87-42c8-926b-98186c96a755" 

//unique_id == "40101108003"
drop if R_E_key == "uuid:5ee5348f-4a96-46db-afc6-bb189028ca35" 

//unique_id == "40101111024"
drop if R_E_key == "uuid:185719a4-c609-4613-bf1a-527465395310" 

//unique_id == "40201110014"
drop if R_E_key == "uuid:4e6cbffa-401c-451d-a555-0ed0e0c529e3" 

//unique_id == "40201111005"
drop if R_E_key == "uuid:592cccd7-2e30-4c84-bfa7-071480954469" 

//unique_id == "50101104006"
drop if R_E_key == "uuid:f5f693ec-8c46-4080-a4b8-f25f4060cd25" 

//unique_id == "50101115003"
drop if R_E_key == "uuid:a8db3950-3a53-4ed3-965b-717658d02fd9" 

//unique_id == "50101115006"
drop if R_E_key == "uuid:b2348752-54a4-49f7-a0fa-45b98fe703f3" 

//unique_id == "50101115011"
drop if R_E_key == "uuid:385f9b49-e64f-4d46-8f3f-1c92edc13f9b" 

//unique_id == "50401105034"
drop if R_E_key == "uuid:c9a34fdd-d23c-4568-bb37-55795865f0ed" 

//unique_id == "50401105039"
drop if R_E_key == "uuid:bfc18a3d-b5fb-4ae1-b949-a57d241bbf9c" 

//unique_id == "50401106029"
drop if R_E_key == "uuid:1afef2c7-32fd-4ee3-bf38-d955c7eaa3ab" 

//unique_id == "50401107005"
drop if R_E_key == "uuid:4165680b-67b3-4193-aba0-04fb6086deac" 

//unique_id == "50401107010"
drop if R_E_key == "uuid:ac531f0b-084e-426c-a1e2-917e3d8a213e" 

//unique_id == "50501104003"
drop if R_E_key == "uuid:08cb3fc2-bab4-47d7-b0d8-edd9b94dcdac" 

// unique_id == "50301106006"
drop if R_E_key == "uuid:0bba28b6-f6d3-4a5d-80b8-8632c28c4a86" 

//unique_id == "50301106014"
drop if R_E_key == "uuid:7581b00a-2cca-4115-9c6d-35b5e082a083" 

//unique_id == "50301106035"
drop if R_E_key == "uuid:345ecae7-bfbe-4f01-82fa-c47ad9b036ed" 

//unique_id == "50301117034"
drop if R_E_key == "uuid:fed059d7-fc79-4a06-bad8-438b71634456" 
	
	
save "${DataTemp}1_8_Endline_Census_additional_pre.dta", replace


* ID 25
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
* Key creation
key_creation


* ID 26
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear

/*------------------------------------------------------------------------------
	1_8_Endline_21_22.dta
------------------------------------------------------------------------------*/
* ID 22
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
* Key creation
key_creation
*keep if n_cbw_consent==1 //Akito to apply this later 
keep key n_name_cbw_woman_earlier n_preg_status n_not_curr_preg n_preg_residence n_preg_hus n_resp_avail_cbw n_resp_avail_cbw_oth 
drop if n_name_cbw_woman_earlier  == ""
//Archi to Akito- replaced n_resp_avail_cbw with n_name_cbw_woman_earlier in the command above
bys key: gen Num=_n
reshape wide  n_name_cbw_woman_earlier n_preg_hus n_preg_status n_not_curr_preg n_preg_residence n_resp_avail_cbw n_resp_avail_cbw_oth , i(key) j(Num)
prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-N_CBW_followup_HH.dta", replace


* ID 21
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
drop if cen_name_cbw_woman_earlier==""
* Key creation
key_creation
save "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long1.dta", replace

*keep if cen_cbw_consent==1
//AG - Commented this out (Akito to incorporate)
save "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long2.dta", replace
keep key cen_preg_index cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_resp_avail_cbw_oth 
destring cen_preg_index, replace

//AG: added cen_resp_avail_cbw cen_resp_avail_cbw_oth  above
bys key: gen Num=_n
reshape wide cen_preg_index cen_preg_status cen_preg_residence cen_not_curr_preg cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_resp_avail_cbw_oth, i(key) j(Num)
prefix_rename


* Bit strange with _merge==2 for N=1
use "${DataTemp}1_8_Endline_Census-Household_available-Cen_CBW_followup_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-N_CBW_followup_HH.dta", nogen
merge 1:1 R_E_key using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned.dta", nogen keep(3) keepusing(R_E_key)
save "${DataFinal}1_8_Endline_21_22.dta", replace

/*N=0?
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", clear
* Key creation
key_creation

global keepvar n_med_otherpay_all
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW_HH.dta", replace

*/

/*------------------------------------------------------------------------------
	ID: 1_8_Endline_11_13.dta
------------------------------------------------------------------------------*/


* ID 15
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", clear
key_creation

global keepvar n_med_otherpay_cbw
keep key $keepvar
collapse (sum) $keepvar, by(key)
prefix_rename
save "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW_HH.dta", replace


/*------------------------------------------------------------------------------
	1_8_Endline_11_13.dta
------------------------------------------------------------------------------*/

* ID 13
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta.dta", clear
* Key creation
key_creation

global keepvar n_med_otherpay_all
keep key $keepvar
collapse (sum) $keepvar, by(key)
prefix_rename
save "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", clear
* Key creation
key_creation

global keepvar n_med_trans_all_*
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta", clear
key_creation
drop if n_med_seek_val_all==""

global keepvar n_med_work_who_all_*
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta", replace


use "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta", nogen
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta", nogen
save "${DataFinal}1_8_Endline_11_13.dta", replace

erase "${DataTemp}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta_HH.dta"
erase "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_9_10.dta
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta", clear
key_creation
drop if cen_tests_val_u5==""

global keepvar cen_med_otherpay_u5
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta", clear
key_creation
drop if cen_out_val2_u5==""

global keepvar cen_med_treat_type_u5_*
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta"
save "${DataFinal}1_8_Endline_9_10.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_7_8.dta
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.dta", clear
key_creation
drop if cen_tests_val_cbw==""
drop setofcen_tests_exp_loop_cbw
rename *cen_med* *cm* 

gen     DK_cen_other_exp_cbw=0
replace DK_cen_other_exp_cbw=1 if cm_otherpay_cbw==999
replace cm_otherpay_cbw=. if    cm_otherpay_cbw==999

global keepvar cm_otherpay_cbw
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta", replace

* N=42
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta", clear
key_creation
rename *cen_med* *cm* 
rename *illness* *ill*

global keepvar cm_treat_type_cbw_* cm_trans_cbw_* cm_scheme_cbw_* cm_ill_other_cbw_*
keep key $keepvar
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cm_treat_type_cbw_ cm_trans_cbw_ cm_scheme_cbw_ cm_ill_other_cbw_ {
	rename `i'* Count_`i'*
}

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta", clear
merge  1:1 R_E_key using  "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta", keep(2 3) nogen

save "${DataFinal}1_8_Endline_7_8.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW_HH.dta"

/*------------------------------------------------------------------------------
	1_8_Endline_4_6.dta
------------------------------------------------------------------------------*/

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", clear
key_creation
collapse (sum) cen_med_otherpay_all  , by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta", replace


use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta", clear
drop if cen_med_seek_val_all==""
key_creation
global keepvar cen_med_work_who_all_* cen_med_where_all_* cen_med_symp_all_* cen_med_out_home_all_*

* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cen_med_work_who_all_ cen_med_where_all_ cen_med_symp_all_ cen_med_out_home_all_ {
	rename `i'* Count_`i'*
}

rename *cen_med* *cm* 
prefix_rename
save "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta", replace

use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", clear
key_creation
* Parent key does not match with the one in the master data unelss we process in the following way
global keepvar cen_med_treat_type_all_* cen_med_trans_all_*
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cen_med_treat_type_all_ cen_med_trans_all_ {
	rename `i'* Count_`i'*
}

rename *cen_med* *cm* 
prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta", replace

use "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta", clear
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta", keep(2 3) nogen
merge  1:1 R_E_key using "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta", keep(2 3) nogen
save "${DataFinal}1_8_Endline_4_6.dta", replace

erase "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all_HH.dta"
erase "${DataTemp}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all_HH.dta"

/*------------------------------------------------------------------------------
	1 Merging with cleaned 1_8_Endline_Census
------------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned.dta", clear
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_4_6.dta", nogen keep(1 3)
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_7_8.dta", nogen keep(1 3)
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_9_10.dta", nogen keep(1 3)
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_11_13.dta", nogen keep(1 3)
merge  1:1 R_E_key using "${DataFinal}1_8_Endline_21_22.dta", nogen keep(1 3)

/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

*******Final variable creation for clean data

* Sarita Bhatra (unique ID: 20201108018) - This is the training
//drop if unique_id=="20201108018" (we should have dropped the key because it dropped the actual valid entry)

//drop if unique_id=="20201108018"

*renaming some duration vars becuase their names were slightly off and was not in accordance with the section in surveycto
rename R_E_intro_dur_end       R_E_final_consent_duration
rename R_E_consent_duration    R_E_final_intro_dur_end
rename R_E_roster_duration     R_E_census_roster_duration
rename R_E_roster_end_duration R_E_new_roster_duration

drop R_E_wash_duration

rename R_E_healthcare_duration  R_E_wash_duration
rename R_E_resp_health_duration R_E_noncri_health_duration
rename R_E_resp_health_new_duration R_E_CenCBW_health_duration
rename R_E_child_census_duration R_E_NewCBW_health_duration
rename R_E_child_new_duration R_E_CenU5_health_duration
rename R_E_sectiong_dur_end R_E_NewU5_health_duration

foreach  var in  R_E_final_intro_dur_end R_E_final_consent_duration R_E_census_roster_duration R_E_new_roster_duration R_E_wash_duration R_E_noncri_health_duration R_E_CenCBW_health_duration R_E_NewCBW_health_duration R_E_CenU5_health_duration R_E_NewU5_health_duration R_E_survey_end_duration {
destring `var', replace
gen `var'_s = `var'/60
sum `var'_s
}

* Commenting off for Archi
* cap gen diff_minutes_orig = clockdiff(R_E_starttime, R_E_endtime, "minute")
* gen diff_hours=diff_minutes/60
* sum diff_hours,de

gen R_E_Dur_final_consent_duration=R_E_final_consent_duration/60
gen R_E_Dur_census_roster_duration=(R_E_census_roster_duration-R_E_final_consent_duration)/60
gen R_E_Dur_new_roster_duration=(R_E_new_roster_duration-R_E_census_roster_duration)/60
gen R_E_Dur_wash_duration=(R_E_wash_duration-R_E_new_roster_duration)/60
gen R_E_Dur_noncri_health_duration=(R_E_noncri_health_duration-R_E_wash_duration)/60
gen R_E_Dur_CenCBW_health_duration=(R_E_CenCBW_health_duration-R_E_noncri_health_duration)/60
gen R_E_Dur_NewCBW_health_duration=(R_E_NewCBW_health_duration-R_E_CenCBW_health_duration)/60
gen R_E_Dur_CenU5_health_duration=(R_E_CenU5_health_duration-R_E_NewCBW_health_duration)/60
gen R_E_Dur_NewU5_health_duration=(R_E_NewU5_health_duration-R_E_CenU5_health_duration)/60
gen R_E_Dur_survey_end_duration=(R_E_survey_end_duration-R_E_NewU5_health_duration)/60
* R_E_Dur_survey_end_duration: It is okay that this is extremely short: (R_E_NewU5_health_duration: Line 1176 and R_E_survey_end_duration: Line 1178 in SurveyCTO)
 
 * Replacing the value of negative value since they are most likely gone back
 foreach i in R_E_Dur_noncri_health_duration R_E_Dur_NewCBW_health_duration R_E_Dur_CenU5_health_duration R_E_Dur_NewU5_health_duration R_E_Dur_survey_end_duration {
 replace `i'=. if `i'<0	
 }
 
 gen Total_time= R_E_Dur_final_consent_duration+R_E_Dur_census_roster_duration+R_E_Dur_new_roster_duration+ ///
                R_E_Dur_wash_duration+R_E_Dur_noncri_health_duration+R_E_Dur_CenCBW_health_duration+ ///
				R_E_Dur_NewCBW_health_duration+R_E_Dur_CenU5_health_duration+R_E_Dur_NewU5_health_duration+ ///
				R_E_Dur_survey_end_duration

//Renaming vars with prefix R_E
foreach x in cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 ///
	   cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 ///
	   cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 ///
	   cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 ///
		{
	rename R_E_`x'  `x'
	rename `x' R_E_r_`x'  
	}	
	
merge 1:1 R_E_key using "${DataTemp}1_8_Endline_Census_additional_pre.dta", keep(1 3) nogen



bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

sort unique_id R_E_submissiondate

br R_E_submissiondate unique_id R_E_key R_E_resp_available R_E_enum_name_label R_E_instruction R_E_r_cen_a1_resp_name if dup_HHID > 0

save "${DataPre}1_8_Endline_XXX.dta", replace


savesome using "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented" if R_E_consent==1, replace


foreach i in 1_8_Endline_4_6.dta 1_8_Endline_7_8.dta 1_8_Endline_9_10.dta 1_8_Endline_11_13.dta {
		erase "${DataFinal}`i'"
}


/* ---------------------------------------------------------------------------
* Adding pre-loading info requested
* 2024/05/07
 ---------------------------------------------------------------------------*/



/* ---------------------------------------------------------------------------
* ID 26
 ---------------------------------------------------------------------------*/
* New household members
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
key_creation 
keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name key key3 n_hhmember_name namenumber

br if key=="uuid:0b09e54d-a47a-414a-8c3c-ba16ed4d9db9"
save "${DataTemp}temp0.dta", replace


/* ---------------------------------------------------------------------------
* ID 22
 ---------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
key_creation 
drop if n_resp_avail_cbw==.
keep n_not_curr_preg key key3
save "${DataTemp}temp1.dta", replace

use "${DataTemp}temp0.dta", clear
merge 1:1 key key3 using "${DataTemp}temp1.dta"
* N=141
gen Type=1
save "${DataTemp}Requested_long_backcheck1.dta", replace


/* ---------------------------------------------------------------------------
* ID 25
 ---------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
key_creation 
keep cen_still_a_member key key3 name_from_earlier_hh
br if key=="uuid:00241596-007f-45dd-9698-12b5c418e3e7"
save "${DataTemp}temp0.dta", replace

/* ---------------------------------------------------------------------------
* ID 21
 ---------------------------------------------------------------------------*/
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
 key_creation 
 drop if  cen_name_cbw_woman_earlier==""
 keep cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence key key3
 save "${DataTemp}temp1.dta", replace
 
 use "${DataTemp}temp0.dta", clear
 merge 1:1 key key3 using "${DataTemp}temp1.dta"
gen Type=2
save "${DataTemp}Requested_long_backcheck2.dta", replace

use "${DataTemp}Requested_long_backcheck1.dta", clear
append using "${DataTemp}Requested_long_backcheck2.dta"

merge m:1 key using "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", keepusing(unique_id) keep(3) nogen
bys unique_id: gen Num=_n

drop  _merge Type  key key3
reshape wide namenumber n_hhmember_name n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother n_u5mother_name n_u5father_name n_not_curr_preg name_from_earlier_hh cen_still_a_member cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence, i(unique_id) j(Num)
sort cen_name_cbw_woman_earlier1
* Creating data before dropping the case for Revisit: Archi
save  "${DataTemp}Requested_wide_backcheck_preload.dta", replace
* Creating data after dropping the case for Backcheck: Archi
*keep if cen_resp_avail_cbw ==1
save  "${DataTemp}Requested_wide_backcheck.dta", replace

erase "${DataTemp}Requested_long_backcheck1.dta"
erase "${DataTemp}Requested_long_backcheck2.dta"



/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
