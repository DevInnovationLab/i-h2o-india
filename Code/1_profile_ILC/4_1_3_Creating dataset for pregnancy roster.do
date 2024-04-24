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

* Keeping relevant variables from Baseline Census dataset
keep R_Cen_district_name R_Cen_block_name R_Cen_gp_name R_Cen_village_name R_Cen_hamlet_name R_Cen_saahi_name R_Cen_enum_name R_Cen_enum_code R_Cen_hh_code R_Cen_hh_repeat_code R_Cen_hh_code_format R_Cen_landmark R_Cen_address R_Cen_resp_available R_Cen_screen_u5child R_Cen_screen_preg R_Cen_instruction R_Cen_visit_num R_Cen_intro_dur_end R_Cen_enum_name_label R_Cen_consent R_Cen_a2_hhmember_count R_Cen_a3_hhmember_name* R_Cen_a4_hhmember_gender* R_Cen_a5_hhmember_relation* R_Cen_a6_hhmember_age* R_Cen_a6_age_confirm2* R_Cen_a5_autoage* R_Cen_a6_u1age* R_Cen_unit_age* R_Cen_correct_age* R_Cen_a7_pregnant* R_Cen_a7_pregnant_month* R_Cen_a7_pregnant_hh* R_Cen_a7_pregnant_leave* R_Cen_a8_u5mother* R_Cen_u5mother_name* R_Cen_a9_school* R_Cen_a9_school_level*  R_Cen_a9_school_current* R_Cen_a9_read_write* unique_id


* Converting this in long form for each member of the household
reshape long R_Cen_a3_hhmember_name_ R_Cen_a4_hhmember_gender_ R_Cen_a5_hhmember_relation_ R_Cen_a6_hhmember_age_ R_Cen_a6_age_confirm2_ R_Cen_a5_autoage_ R_Cen_a6_u1age_ R_Cen_unit_age_ R_Cen_correct_age_ R_Cen_a7_pregnant_ R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_ R_Cen_a8_u5mother_ R_Cen_u5mother_name_ R_Cen_a9_school_ R_Cen_a9_school_level_  R_Cen_a9_school_current_ R_Cen_a9_read_write_ , i(unique_id) j(num)



* Create dataset of women who are in the eligible category
preserve 

keep if R_Cen_a4_hhmember_gender_ == 2 & R_Cen_a6_hhmember_age_ >= 15 & R_Cen_a6_hhmember_age_ <= 49
rename  (R_Cen_a3_hhmember_name_ R_Cen_a6_hhmember_age_  R_Cen_a6_age_confirm2_  R_Cen_village_name R_Cen_a7_pregnant_ ) (name_woman age_woman  confirmed_age  village_woman is_last_preg )

gen Mother_Name =  name_woman
tempfile eligible_women_census
save `eligible_women_census'
restore

* Assigning mother name to each child (right not it is only the index of the household member)
gen mother = ""
forval i = 1/17{ 
	bys unique_id: replace mother = R_Cen_a3_hhmember_name_[`i'] if R_Cen_u5mother_name_ == `i'
}

* Create dataset of mothers with atleast one child u3  - why under 3, because the admin data on pregnancy listing goes back till 2022 as expected date of delivery
preserve 

keep if  R_Cen_a6_hhmember_age_ <= 1 
gen Mother_Name =  mother
tempfile child_u5_census
duplicates drop unique_id Mother_Name, force
drop if Mother_Name == ""
tempfile child_u1_census
save `child_u1_census' 
restore

* Also adding variables for whenever we found a woman with a child u3 by merging child_u3_census data with eligible_women_census data

use "`eligible_women_census'", clear
drop if Mother_Name == "Pinky Kandagari" & age_woman == 22 
merge 1:1 unique_id  Mother_Name using `child_u1_census'
keep if _merge == 3
tempfile women_with_childu1_census
save `women_with_childu1_census'
* out of 1617 women in eligible category, 782 don't have a child u3, but 834 have a child u3 

* Also save the cases where the woman was pregnant during the Baseline Census
use "`eligible_women_census'", clear
keep if is_last_preg == 1
gen id_woman = _n
tempfile preg_woman_census
replace Mother_Name = lower(Mother_Name)
save `preg_woman_census' 
* Contains 147 woman who were pregnant at baseline

/*------------------------------------------------------------------------------
	2 Mortality data preparations
------------------------------------------------------------------------------*/

* This file contains two important data information for only 3 villages
* 1. Household rosters for when we didn't do roster during Census - need to create both eligible women and child under 5 rosters from this 
* 2. Mortality data of all the sample, both census roster women and mortality roster women, need to create a separate data to capture the birth and death information of all these eligible women's children - separate dataset

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

decode village_resp, gen(village)
drop village_resp
rename village village_resp

gen Mother_Name =  name_woman
tempfile eligible_women_mortality
save `eligible_women_mortality'

restore
 
 
* Using the eligible women data from mortality, also create a match of women who had/ have a child u5, or were pregnant in last 5 yrs

use "`eligible_women_mortality'", clear
keep if is_last_5yrs_preg == "1" 
tempfile women_with_childu5_mor
save `women_with_childu5_mor'
* 36 woman 


* Now create data of children under 5 from the roster done during Mortality survey 

use "${DataPre}1_1_Mortality_cleaned.dta", clear
keep if R_mor_check_scenario == 0 

keep R_mor_block_name R_mor_village_name  R_mor_a1_resp_name  R_mor_a2_hhmember_count R_mor_a3_hhmember_name_* R_mor_a4_hhmember_gender_* R_mor_a5_hhmember_relation_*  R_mor_a6_hhmember_age_* R_mor_age_accurate_* R_mor_a5_autoage_* R_mor_marital_* R_mor_a7_pregnant_* unique_id_num 

reshape long R_mor_a3_hhmember_name_ R_mor_a4_hhmember_gender_ R_mor_a5_hhmember_relation_ R_mor_a6_hhmember_age_ R_mor_age_accurate_ R_mor_a5_autoage_   R_mor_marital_ R_mor_a7_pregnant_ R_mor_a7_pregnant_month_   R_Cen_a8_u3mother_       , i(unique_id_num) j(num)


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
gen Mother_Name =  mother
tempfile child_u5_mortality
save `child_u5_mortality'

restore

/*------------------------------------------------------------------------------
	3 Full roster of eligible women and for woman who had/ have a child u3
------------------------------------------------------------------------------*/

* First, full sample of eligible women between 15 and 49 years of age: 
* to combine Census and Mortality rosters in one dataset

use "`eligible_women_census'", clear
destring unique_id, replace
destring confirmed_age, replace

decode village_woman, gen(village_resp)
drop village_woman
gen village_woman = village_resp
append using "`eligible_women_mortality'" 
gen id_woman = _n

keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name village_woman  name_woman age_woman confirmed_age R_Cen_a5_autoage_ is_last_preg R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_ R_mor_block_name village_resp is_last_5yrs_preg age_resp auto_age id_woman Mother_Name

tempfile final_eligible_women


save `final_eligible_women'

* this contains 1870 women of eligible age group across the census and mortality data

* First, full sample of  women who had children u3 in eligible age between 15 and 49 years of age: 
* to combine Census and Mortality rosters in one dataset

use "`women_with_childu1_census'", clear
destring unique_id, replace
destring confirmed_age, replace

decode village_woman, gen(village_resp)
drop village_woman
gen village_woman = village_resp
*append using "`women_with_childu5_mor'" 
gen id_woman = _n

keep unique_id R_Cen_district_name R_Cen_block_name R_Cen_gp_name village_woman  name_woman age_woman confirmed_age R_Cen_a5_autoage_ is_last_preg R_Cen_a7_pregnant_month_ R_Cen_a7_pregnant_hh_ R_Cen_a7_pregnant_leave_  village_resp    id_woman Mother_Name

replace Mother_Name = lower(Mother_Name)
tempfile final_women_u1_cen
save `final_women_u1_cen'
* this contains 834 women from census and 36 from mortality survey, so total 870

/*
* Also add to this woman who were preg during baseline census 
use "`preg_woman_census'", clear
destring unique_id, replace
destring confirmed_age, replace

decode village_woman, gen(village_resp)
drop village_woman
gen village_woman = village_resp
append using "`final_women_childu3'"
*/

/*------------------------------------------------------------------------------
	4 Admin Data
------------------------------------------------------------------------------*/


* Cleaning the Child Line listing data 
clear
import excel "${box}4_Admin data/rch_genderwise child report_master_2023-now.xlsx", sheet("Sheet1") firstrow

keep Block_Name Facility_Name Facility_Type RCH_ID New_Born_Name Gender Father_Name Mother_Name  Mobile_No DOB Address ANM_Name ASHA_Name Registration_Date Child_Death 
egen parents = concat(Mother_Name Father_Name), punct(_)

* remove duplicates in mother and father name 
duplicates drop Mother_Name Father_Name, force
tempfile cll
save `cll'

clear
import excel "${box}4_Admin data/rch listing_pw_master 2022-2023.xlsx", sheet("Sheet1") firstrow
keep Health_Block Health_Facility Health_SubFacility Village RCHID CaseNo MotherName HusbandName Mobileof MobileNo MotherAge BankName Address ANM_Name ASHA_Name RegistrationDate LMP Med_PastIllness EDD ANC1 ANC2 ANC3 ANC4 TT1 TT2 TTB ANC_IFA PNC_IFA IFA Delivery PNC1 PNC2 PNC3 PNC4 PNC5 PNC6 PNC7 HighRisk1stVisit HighRisk2ndVisit HighRisk3rdVisit HighRisk4thVisit HBLevel1stVisit HBLevel2ndVisit HBLevel3rdVisit HBLevel4thVisit MaternalDeath abortion_Present JSY_Beneficiary Death_Date Death_Reason

rename MotherName Mother_Name
egen parents = concat(Mother_Name HusbandName), punct(_)
duplicates drop Mother_Name HusbandName, force

tempfile pll
save `pll'

merge m:m parents   using "`cll'"
duplicates drop parents, force

* Saving non match cases, = 
preserve 

keep if _merge == 1 | _merge == 2
tempfile not_match
save `not_match'

restore


* manual check of these merged cases
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

drop if dob_edd > 90 | dob_edd < -90 | dob_del > 90 | dob_del < -90

*ANM and ASHA name and DOB, missing in mobile number

*
generate str2 lmpda1= substr(LMP,1,2)
generate str2 lmpmo1 = substr(LMP,4,5)
generate str4 lmpyr1 = substr(LMP,7,10)

destring lmp*, replace
gen lmp_date = mdy(lmpmo1, lmpda1, lmpyr1)


// Total match is 3786 between preg woman listing and child line listing

drop _merge 
replace Mother_Name = lower(Mother_Name)
gen id_pwl_cl = _n
tempfile pwl_cl
save `pwl_cl'



/*------------------------------------------------------------------------------
	5 Fuzzy Match with Survey Data
------------------------------------------------------------------------------*/

* Fuzzy match with the matched pregnancy listing and child listing data from the admin


* 1. Match cases where there is a child u3 with pregnancy and child listing data (denominator 870 from survey data)

use "`pwl_cl'", clear
keep if  (eddmo1 >= 9 & eddyr1 == 2022) | (eddmo1 <= 11 & eddyr1 == 2023) // to keep children u1
tempfile pwl_cl_u1
save `pwl_cl_u1'


set seed 3859
reclink Mother_Name  using `final_women_u1_cen', idm(id_pwl_cl) idu(id_woman) gen(myscore)


keep Mother_Name UMother_Name age_woman MotherAge myscore unique_id village_resp village_woman Village
gen diff_age = MotherAge - age_woman
keep if myscore  > .99 & myscore != . & (diff_age <= 5 & diff_age >= -5) 
tempfile match_woman_pw_cl
save `match_woman_pw_cl'

use "`match_woman_pw_cl'", clear
duplicates tag unique_id Mother_Name, gen(dup)
tab dup
*keep if dup == 0 & diff_age == 0 & Mother_Name == UMother_Name

*262 matches that make sense with more than 99% match score, however only 154 cases where there are no duplicates and difference between survey age and admin age being only 5
* Somewhat imperfect match rate of 17.7% (154/870)
* There are a few cases where duplicates might make sense, but this needs better NLP methods to find the correct match 


* 2. Match cases where there is a child u3 with pregnancy listing data only (denominator 147 from survey data)

* Fuzzy match with the matched pregnancy listing only data (that didn't match with child listing) from the admin

*restrict the years - in this case, since we are 


use "`pll'", clear

generate str2 eddda1= substr(EDD,1,2)
generate str2 eddmo1 = substr(EDD,4,5)
generate str4 eddyr1 = substr(EDD,7,10)

destring edd*, replace
gen exp_del_date = mdy(eddmo1, eddda1, eddyr1)


*also restrict the years, as pregnant woman from census are only recorded for about early 2023 till 2024 
keep if eddyr1 == 2023 & eddmo1 <= 11
gen id_pwl = _n
replace Mother_Name = lower(Mother_Name)
set seed 3859
reclink Mother_Name using `preg_woman_census', idm(id_pwl) idu(id_woman) gen(myscore)

keep Mother_Name UMother_Name age_woman MotherAge myscore unique_id
gen diff_age = MotherAge - age_woman
keep if myscore  > .99 & myscore != . & (diff_age <= 5 & diff_age >= -5) 
duplicates tag unique_id Mother_Name, gen(dup)
tempfile match_woman_pw
save `match_woman_pw'

* out of 147 women, only 14 were found with the criteria that the match score was higher than 99% and difference in age is only upto 5 yrs and manually, they seem to have the correct name = 9.5% - Note this is subject to year selection, as we had survey data on pregnancy for only a few months, while the admin data is bigger. 




* 3. Match cases where there is a child u3 with child listing data (870 denominator)


* Fuzzy match with the matched child listing only data from the admin

*restrict the years

use "`cll'", clear

gen id_cl = _n
generate str2 dobda1= substr(DOB,1,2)
generate str2 dobmo1 = substr(DOB,4,5)
generate str4 dobyr1 = substr(DOB,7,10)

destring dob*, replace
gen date_of_birth = mdy(dobmo1, dobda1, dobyr1)

replace Mother_Name = lower(Mother_Name)
keep if  (dobmo1 >= 9 & dobyr1 == 2022) | (dobmo1 <= 11 & dobyr1 == 2023) // to keep children u1

set seed 3859
reclink Mother_Name using `final_women_u1_cen', idm(id_cl) idu(id_woman) gen(myscore)
keep Mother_Name UMother_Name age_woman MotherAge myscore unique_id
keep if myscore  > .99 & myscore != . 
duplicates tag unique_id Mother_Name, gen(dup)


 
* since we don't have mother's age in the child listing, one way to check is no longer available. 
* There are 34 perfect matches, while 124 matches with match score greater than 99% and 0 duplicates in unique ID and Mother Name = 128/870 = 14.7%



* Adding spouse name of women in survey data for section: woman in eligible category, would greatly increase match rate
* Make sure we ask is pregnant in last 5 years 






