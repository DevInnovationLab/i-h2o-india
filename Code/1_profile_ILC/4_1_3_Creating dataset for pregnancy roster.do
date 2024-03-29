*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: DIL
****** Used by:  DIL
****** Input data : Census cleaned and Mortality cleaned dataset
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file creates one dataset for displaying the women who have had a child in our sample in the past 5 years. 

/*------------------------------------------------------------------------------
	1 Census data preparations
------------------------------------------------------------------------------*/

use "${DataPre}1_1_Census_cleaned_consented.dta", clear


keep R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_hamlet_name R_Cen_saahi_name R_Cen_enum_name R_Cen_enum_code R_Cen_hh_code R_Cen_hh_repeat_code R_Cen_hh_code_format R_Cen_landmark R_Cen_address R_Cen_resp_available R_Cen_screen_u5child R_Cen_screen_preg R_Cen_instruction R_Cen_visit_num R_Cen_intro_dur_end R_Cen_enum_name_label R_Cen_consent R_Cen_a2_hhmember_count R_Cen_a3_hhmember_name* R_Cen_a4_hhmember_gender* R_Cen_a5_hhmember_relation* R_Cen_a6_hhmember_age* R_Cen_a6_age_confirm2* R_Cen_a5_autoage* R_Cen_a6_u1age* R_Cen_unit_age* R_Cen_correct_age* R_Cen_a7_pregnant* R_Cen_a7_pregnant_month* R_Cen_a7_pregnant_hh* R_Cen_a7_pregnant_leave* R_Cen_a8_u5mother* R_Cen_u5mother_name* R_Cen_a9_school* R_Cen_a9_school_level*  R_Cen_a9_school_current* R_Cen_a9_read_write* unique_id


reshape long R_Cen_a3_hhmember_name_ R_Cen_a4_hhmember_gender_ R_Cen_a5_hhmember_relation_ R_Cen_a6_hhmember_age_ R_Cen_a6_age_confirm2_ R_Cen_a5_autoage_ R_Cen_a6_u1age_ R_Cen_unit_age_ R_Cen_correct_age_ R_Cen_a7_pregnant_ R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_ R_Cen_a8_u5mother_ R_Cen_u5mother_name_ R_Cen_a9_school_ R_Cen_a9_school_level_  R_Cen_a9_school_current_ R_Cen_a9_read_write_ , i(unique_id) j(num)



* Create dataset of women who are in the eligible category
preserve 

keep if R_Cen_a4_hhmember_gender_ == 2 & R_Cen_a6_hhmember_age_ >= 15 & R_Cen_a6_hhmember_age_ <= 49
rename  (R_Cen_a3_hhmember_name_ R_Cen_a6_hhmember_age_  R_Cen_a6_age_confirm2_  R_Cen_village_name R_Cen_a7_pregnant_ ) (name_woman age_woman  confirmed_age  village_woman is_last_preg )

tempfile eligible_women_census
save `eligible_women_census'

restore

* Assigning mother name to each child (right not it is only the index of the household member)
gen mother = ""
forval i = 1/17{ 
	bys unique_id: replace mother = R_Cen_a3_hhmember_name_[`i'] if R_Cen_u5mother_name_ == `i'
}

* Create dataset of children under 5 with their mothers' name 
preserve 

keep if  R_Cen_a6_hhmember_age_ <= 5 
tempfile child_u5_census
save `child_u5_census'

restore


/*------------------------------------------------------------------------------
	2 Mortality data preparations
------------------------------------------------------------------------------*/

* This file contains two important data information for only 3 villages
* 1. Household rosters for when we didn't do roster during Census - need to create both eligible women and child under 5 rosters from this 
* 2. Mortality data of all the sample, both census roster women and mortality roster women, need to create a separate data to capture the birth and death information of all these eligible women - separate dataset

use "${DataRaw}Mortality survey_cleaned vars.dta", clear

drop if unique_id_new ==  "30701-503-009" & new_woman_name_1 == "TULASI MAHANANDIA and 15 years"

keep unique_id_new new_* 
rename unique_id_new unique_id


drop if unique_id==""
duplicates report unique_id
duplicates tag unique_id, gen(dup)
tab dup

drop if unique_id == "-77-519-001"

destring unique_id, gen(unique_id_num) ignore(-)  
format unique_id_num %15.0gc


//dropping irrelavent vars
drop new_cause_death_child_1_1_1 new_cause_death_child_2_1_1 new_cause_death_child_3_1_1 new_cause_death_child_4_1_1 new_cause_death_child_5_1_1 new_cause_death_child_6_1_1 new_cause_death_child_7_1_1 new_cause_death_child_8_1_1 new_cause_death_child_9_1_1 new_cause_death_child_10_1_1 new_cause_death_child_11_1_1 new_cause_death_child_12_1_1 new_cause_death_child_13_1_1 new_cause_death_child_14_1_1 new_cause_death_child_15_1_1 new_cause_death_child_16_1_1 new_cause_death_child_17_1_1 new_cause_death_child_18_1_1 new_cause_death_child__77_1_1 new_cause_death_child_999_1_1 new_cause_death_child_98_1_1 new_cause_death_child_1_2_1 new_cause_death_child_2_2_1 new_cause_death_child_3_2_1 new_cause_death_child_4_2_1 new_cause_death_child_5_2_1 new_cause_death_child_6_2_1 new_cause_death_child_7_2_1 new_cause_death_child_8_2_1 new_cause_death_child_9_2_1 new_cause_death_child_10_2_1 new_cause_death_child_11_2_1 new_cause_death_child_12_2_1 new_cause_death_child_13_2_1 new_cause_death_child_14_2_1 new_cause_death_child_15_2_1 new_cause_death_child_16_2_1 new_cause_death_child_17_2_1 new_cause_death_child_18_2_1 new_cause_death_child__77_2_1 new_cause_death_child_999_2_1 new_cause_death_child_98_2_1 new_cause_death_child_1_3_1 new_cause_death_child_2_3_1 new_cause_death_child_3_3_1 new_cause_death_child_4_3_1 new_cause_death_child_5_3_1 new_cause_death_child_6_3_1 new_cause_death_child_7_3_1 new_cause_death_child_8_3_1 new_cause_death_child_9_3_1 new_cause_death_child_10_3_1 new_cause_death_child_11_3_1 new_cause_death_child_12_3_1 new_cause_death_child_13_3_1 new_cause_death_child_14_3_1 new_cause_death_child_15_3_1 new_cause_death_child_16_3_1 new_cause_death_child_17_3_1 new_cause_death_child_18_3_1 new_cause_death_child__77_3_1 new_cause_death_child_999_3_1 new_cause_death_child_98_3_1 new_cause_death_child_1_4_1 new_cause_death_child_2_4_1 new_cause_death_child_3_4_1 new_cause_death_child_4_4_1 new_cause_death_child_5_4_1 new_cause_death_child_6_4_1 new_cause_death_child_7_4_1 new_cause_death_child_8_4_1 new_cause_death_child_9_4_1 new_cause_death_child_10_4_1 new_cause_death_child_11_4_1 new_cause_death_child_12_4_1 new_cause_death_child_13_4_1 new_cause_death_child_14_4_1 new_cause_death_child_15_4_1 new_cause_death_child_16_4_1 new_cause_death_child_17_4_1 new_cause_death_child_18_4_1 new_cause_death_child__77_4_1 new_cause_death_child_999_4_1 new_cause_death_child_98_4_1



drop new_no_consent_reason_1_1 new_no_consent_reason_2_1 new_no_consent_reason__77_1 new_no_consent_reason_1_2 new_no_consent_reason_2_2 new_no_consent_reason__77_2 new_no_consent_reason_1_3 new_no_consent_reason_2_3 new_no_consent_reason__77_3

drop new_vill_woman_oth_1  new_vill_woman_oth_2  new_vill_woman_oth_3  new_vill_woman_oth_4  new_vill_woman_oth_sc_1  new_vill_woman_oth_sc_2  new_vill_woman_oth_sc_3  new_vill_woman_oth_sc_4  new_vill_woman_oth_sc_5 new_vill_woman_oth_sc_6  new_woman_name_oth_1 new_consent_woman_oth_1 new_no_consent_reason_oth_1 new_no_consent_reason_oth_1_1 new_no_consent_reason_oth_2_1 new_no_consent_reason_oth__77_1 new_residence_yesno_oth_1 new_vill_woman_oth_add_1 new_vill_woman_oth_oth_1 new_last_5yrs_preg_oth_1 new_child_living_yn_oth_1 new_child_living_num_oth_1 new_child_away_yn_oth_1 new_child_away_num_oth_1 new_child_still_yn_oth_1 new_child_still_num_oth_1 new_child_died_yn_less24_oth_1 new_child_died_num_less24_oth_1 new_child_died_yn_more24_oth_1 new_child_died_num_more24_oth_1 new_miscarriage_yn_oth_1 new_woman_name_oth_2 new_consent_woman_oth_2 new_no_consent_reason_oth_2 new_no_consent_reason_oth_1_2 new_no_consent_reason_oth_2_2 new_no_consent_reason_oth__77_2 new_residence_yesno_oth_2 new_vill_woman_oth_add_2 new_vill_woman_oth_oth_2 new_last_5yrs_preg_oth_2 new_child_living_yn_oth_2 new_child_living_num_oth_2 new_child_away_yn_oth_2 new_child_away_num_oth_2 new_child_still_yn_oth_2 new_child_still_num_oth_2 new_child_died_yn_less24_oth_2 new_child_died_num_less24_oth_2 new_child_died_yn_more24_oth_2 new_child_died_num_more24_oth_2 new_miscarriage_yn_oth_2

drop new_no_consent_reason_1_4 new_no_consent_reason_2_4 new_no_consent_reason__77_4 new_cause_death_child_str_sc_1_1 new_cause_death_child_str_sc_1_2 new_cause_death_child_str_sc_2_1 new_cause_death_child_str_sc_2_2 new_cause_death_child_str_sc_3_1 new_cause_death_child_str_sc_3_2 new_cause_death_child_str_sc_4_1 new_cause_death_child_str_sc_4_2 new_cause_death_child_str_sc_5_1 new_cause_death_child_str_sc_5_2 new_cause_death_child_str_sc_6_1 new_cause_death_child_str_sc_6_2 dup

tempfile mortality

save `mortality'
use "${DataPre}1_1_Mortality_cleaned.dta", clear
keep if R_mor_check_scenario == 0 


keep R_mor_block_name R_mor_village_name  R_mor_a1_resp_name  R_mor_a2_hhmember_count R_mor_a3_hhmember_name_* R_mor_a4_hhmember_gender_* R_mor_a5_hhmember_relation_*  R_mor_a6_hhmember_age_* R_mor_age_accurate_* R_mor_a5_autoage_* R_mor_marital_* R_mor_a7_pregnant_* unique_id_num 


merge 1:1 unique_id_num using "`mortality'"
rename  unique_id unique_id_str
rename unique_id_num unique_id
//reshaping at woman level
reshape long new_woman_name_ new_consent_woman_ new_no_consent_reason_ new_residence_yesno_ new_vill_woman_ new_last_5yrs_preg_ new_child_living_num_ new_child_away_num_ new_child_away_yn_ new_child_living_yn_ new_child_still_num_ new_child_still_yn_ new_child_died_yn_less24_ new_child_died_yn_more24_ new_child_died_num_more24_ new_child_died_num_less24_ new_name_child_ new_age_child_ new_unit_child_age_ new_date_birth_child_ new_date_death_child_ new_cause_death_diag_yn_ new_cause_death_child_ new_cause_death_oth_ new_miscarriage_yn_ R_mor_a3_hhmember_name_ R_mor_a4_hhmember_gender_ R_mor_a5_hhmember_relation_ R_mor_a6_hhmember_age_ R_mor_age_accurate_ R_mor_a5_autoage_   R_mor_marital_ R_mor_a7_pregnant_ R_mor_a7_pregnant_month_, i(unique_id) j(num)

drop if new_woman_name_==""


// separating out name and age

gen name_new_woman = trim(substr(new_woman_name_, 1, strpos(new_woman_name_, " and") - 1))
gen location  = strpos(new_woman_name_, " and") + 4
gen age_new_woman = substr(new_woman_name_, location,  3)
destring age_new_woman, replace force
drop if name_new_woman==""

keep unique_id num name_new_woman age_new_woman new_consent_woman_ new_no_consent_reason_ new_residence_yesno_ new_vill_woman_ new_last_5yrs_preg_  R_mor_block_name R_mor_village_name  R_mor_a1_resp_name  R_mor_a2_hhmember_count R_mor_a3_hhmember_name_* R_mor_a4_hhmember_gender_ R_mor_a5_hhmember_relation_  R_mor_a6_hhmember_age_ R_mor_age_accurate_ R_mor_a5_autoage_ R_mor_marital_ R_mor_a7_pregnant_  


//further cleaning- handling duplicates

*duplicates report unique_id name_new_woman
duplicates tag unique_id name_new_woman, gen(dup)
tab dup
drop if dup>0 & new_consent_woman_==""

* Create dataset of women who are in the eligible category
preserve 

keep if R_mor_a4_hhmember_gender_ == 2 & R_mor_a6_hhmember_age_ >= 15 & R_mor_a6_hhmember_age_ <= 49
rename  (R_mor_a3_hhmember_name_ R_mor_a6_hhmember_age_   R_mor_age_accurate_ R_mor_a5_autoage_ R_mor_village_name R_mor_a7_pregnant_ ) (name_resp age_resp  confirmed_age auto_age village_resp is_last_preg )
rename  (name_new_woman age_new_woman   new_residence_yesno_ new_vill_woman_ new_last_5yrs_preg_ ) (name_woman age_woman residence_yesno village_woman is_last_5yrs_preg )

tempfile eligible_women_mortality
save `eligible_women_mortality'

restore
 
 
 

* Now create data of children under 5 from the roster done during Mortality survey 

use "${DataPre}1_1_Mortality_cleaned.dta", clear
keep if R_mor_check_scenario == 0 

keep R_mor_block_name R_mor_village_name  R_mor_a1_resp_name  R_mor_a2_hhmember_count R_mor_a3_hhmember_name_* R_mor_a4_hhmember_gender_* R_mor_a5_hhmember_relation_*  R_mor_a6_hhmember_age_* R_mor_age_accurate_* R_mor_a5_autoage_* R_mor_marital_* R_mor_a7_pregnant_* unique_id_num 

reshape long R_mor_a3_hhmember_name_ R_mor_a4_hhmember_gender_ R_mor_a5_hhmember_relation_ R_mor_a6_hhmember_age_ R_mor_age_accurate_ R_mor_a5_autoage_   R_mor_marital_ R_mor_a7_pregnant_ R_mor_a7_pregnant_month_   R_Cen_a8_u5mother_       , i(unique_id_num) j(num)


* Assigning mother name to each child (right not it is only the index of the household member)
gen mother = R_mor_a1_resp_name if R_mor_a1_resp_name == R_mor_a3_hhmember_name_ &  R_mor_a4_hhmember_gender_ == 2
bys unique_id_num: replace mother = mother[1] 
forval i = 1/12{ 
	
	bys unique_id_num: replace mother = "" if  R_mor_a5_hhmember_relation_ != 3 
}
rename unique_id_num unique_id
* Create dataset of children under 5 with their mothers' name 
preserve 

keep if  R_mor_a6_hhmember_age_ < 5 
tempfile child_u5_mortality
save `child_u5_mortality'

restore

/*------------------------------------------------------------------------------
	3 Full roster of eligible women and childU5
------------------------------------------------------------------------------*/

* Next step would be to combine Census and Mortality rosters in one dataset, so we have household ID of all the hhs in the village with their roster info. 

use "`eligible_women_census'", clear
destring unique_id, replace
destring confirmed_age, replace
gen village = tostring(village_woman) 
drop village_woman
rename village village_woman
append using "`eligible_women_mortality'" 

tempfile final_eligible_women

save `final_eligible_women'

/*------------------------------------------------------------------------------
	4 Pregnancy history 
------------------------------------------------------------------------------*/

* Now we should merge mortality/ death data of eligible women to this roster. 




/*------------------------------------------------------------------------------
	5 Admin Data
------------------------------------------------------------------------------*/


* Cleaning the Child Line listing data 
clear
import excel "${box}4_Admin data/rch_genderwise child report_master_2023-now.xlsx", sheet("Sheet1") firstrow

keep Block_Name Facility_Name Facility_Type RCH_ID New_Born_Name Gender Father_Name Mother_Name  Mobile_No DOB Address ANM_Name ASHA_Name Registration_Date Child_Death 
egen parents = concat(Mother_Name Father_Name), punct(_)

tempfile cll
save `cll'

clear
import excel "${box}4_Admin data/rch listing_pw_master 2022-2023.xlsx", sheet("Sheet1") firstrow
keep Health_Block Health_Facility Health_SubFacility Village RCHID CaseNo MotherName HusbandName Mobileof MobileNo MotherAge BankName Address ANM_Name ASHA_Name RegistrationDate LMP Med_PastIllness EDD ANC1 ANC2 ANC3 ANC4 TT1 TT2 TTB ANC_IFA PNC_IFA IFA Delivery PNC1 PNC2 PNC3 PNC4 PNC5 PNC6 PNC7 HighRisk1stVisit HighRisk2ndVisit HighRisk3rdVisit HighRisk4thVisit HBLevel1stVisit HBLevel2ndVisit HBLevel3rdVisit HBLevel4thVisit MaternalDeath abortion_Present JSY_Beneficiary Death_Date Death_Reason

rename MotherName Mother_Name
egen parents = concat(Mother_Name HusbandName), punct(_)

tempfile pll
save `pll'

merge m:m parents   using "`cll'"


* manual check of 
keep if _merge == 3 


* creating a series of checks: 

*1. check to see if the block names are same: 
gen check1 = 1 if  Health_Block == Block_Name

*2. check to see if mobile number matches
gen check2 = 1 if  Mobile_No == MobileNo

replace check1 = 1 if check1 != 1 & check2 == 1 // this also affirms the cases where mobile number is same, however the block names could be different 


*3. check if DOB is within a threshold of EDD and LMP
gen check3 = 1 if DOB == Delivery | DOB == EDD // absolute check

*convert dates to date format to be able to check the time passed between EDD and DOB and Delivery date and DOB


generate str2 dobda1= substr(DOB,1,2)
generate str2 dobmo1 = substr(DOB,4,5)
generate str4 dobyr1 = substr(DOB,7,10)

destring dob*, replace
gen date_of_birth = mdy(dobmo1, dobda1, dobyr1)


generate str2 eddda1= substr(EDD,1,2)
generate str2 eddmo1 = substr(EDD,4,5)
generate str4 eddyr1 = substr(EDD,7,10)

destring edd*, replace
gen exp_del_date = mdy(eddmo1, eddda1, eddyr1)


generate str2 delda1= substr(Delivery,1,2)
generate str2 delmo1 = substr(Delivery,4,5)
generate str4 delyr1 = substr(Delivery,7,10)

destring del*, replace
gen del_date = mdy(delmo1, delda1, delyr1)

gen dob_edd = date_of_birth - exp_del_date

gen dob_del = date_of_birth - del_date

*ANM and ASHA name and DOB, missing in mobile number

*
generate str2 lmpda1= substr(LMP,1,2)
generate str2 lmpmo1 = substr(LMP,4,5)
generate str4 lmpyr1 = substr(LMP,7,10)

destring lmp*, replace
gen del_date = mdy(lmpmo1, lmpda1, lmpyr1)







