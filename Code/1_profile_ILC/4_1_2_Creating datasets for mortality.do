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

/*------ In this do file: 
	(1) This do file exports the list of hosuehold selected for the follow-up survey. The first part of the do file do random selection of baseline survey
	(2) To avoid running the randomization code multiple times, you will choose the village to be randomized at the first line of this do file. 
	(3) Once you run the randomization, you will "merge" the informtion of selected household into the master census list       ------ */

*------------------------------------------------------------------- Baseline -------------------------------------------------------------------*



********************************************************************************
// STEP 1. Cleaning mortality survey raw data 
********************************************************************************


use "${DataRaw}Mortality Survey.dta", clear
drop name_child_earlier_* name_child_earlier_sc_*

keep name_pc_earlier_* consent_pc_* no_consent_reason_pc_* residence_yesno_pc_* ///
vill_pc_*  ///
last_5_years_pregnant_* child_living_num_* child_notliving_num_* child_notliving_* ///
child_living_* child_stillborn_num_* child_stillborn_* child_alive_died_24_* ///
child_died_num_* child_alive_died_* child_died_num_more24_* name_child_* ///
age_child_* unit_child_* date_birth_* date_death_* cause_death_* ///
cause_death_diagnosed_* miscarriage_* unique_id unique_id_sc1


//renaming vars
rename name_pc_earlier_sc_*   			screen_woman_name_*
rename name_pc_earlier_* 	  			new_woman_name_*
rename consent_pc_sc_* 		  			screen_consent_woman_*
rename consent_pc_* 		  			new_consent_woman_*
rename no_consent_reason_pc_sc_* 		screen_no_consent_reason_*
rename no_consent_reason_pc_* 			new_no_consent_reason_*
rename residence_yesno_pc_sc_* 			screen_residence_yesno_*
rename residence_yesno_pc_*				new_residence_yesno_*
rename vill_pc_sc_* 					screen_vill_woman_*
rename vill_pc_*						new_vill_woman_*

rename last_5_years_pregnant_sc_*		screen_last_5yrs_preg_* 
rename last_5_years_pregnant_* 			new_last_5yrs_preg_*
rename child_living_num_sc_*			screen_child_living_num_*
rename child_notliving_num_sc_*			screen_child_away_num_*
rename child_living_num_*				new_child_living_num_*
rename child_notliving_num_*			new_child_away_num_*
rename child_notliving_sc_*				screen_child_away_yn_*
rename child_notliving_*				new_child_away_yn_*
rename child_living_sc_*				screen_child_living_yn_*
rename child_living_*					new_child_living_yn_*
rename child_stillborn_num_sc_*			screen_child_still_num_*
rename child_stillborn_num_*			new_child_still_num_*
rename child_stillborn_sc_*				screen_child_still_yn_*
rename child_stillborn_*				new_child_still_yn_*
rename child_alive_died_24_sc_*			sc_child_died_yn_less24_*
rename child_alive_died_sc_*			sc_child_died_yn_more24_*
rename child_died_num_sc_*				sc_child_died_num_less24_*
rename child_died_num_more24_sc_*		sc_child_died_num_more24_*

rename child_alive_died_24_*			new_child_died_yn_less24_*
rename child_alive_died_*				new_child_died_yn_more24_*
rename child_died_num_more24_*			new_child_died_num_more24_*
rename child_died_num_*					new_child_died_num_less24_*

rename name_child_sc_*					screen_name_child_*
rename name_child_*						new_name_child_*
rename age_child_sc_*					screen_age_child_*
rename age_child_*						new_age_child_*
rename unit_child_sc_*					screen_unit_child_age_*
rename unit_child_*						new_unit_child_age_*
rename date_birth_sc_*					screen_date_birth_child_*
rename date_birth_*						new_date_birth_child_*
rename date_death_sc_*					screen_date_death_child_*
rename date_death_*						new_date_death_child_*
rename cause_death_sc_*					screen_cause_death_child_*
rename cause_death_diagnosed_sc_*		screen_cause_death_diag_yn_*
rename cause_death_diagnosed_*			new_cause_death_diag_yn_*
rename cause_death_*					new_cause_death_child_*
rename miscarriage_sc_*					screen_miscarriage_yn_*
rename miscarriage_*					new_miscarriage_yn_*
rename unique_id						unique_id_screen
rename unique_id_sc1					unique_id_new


//cleaning unique IDs
destring unique_id_screen, gen(unique_id_num)
format   unique_id_num %15.0gc 
gen unique_id_hyphen_screen = substr(unique_id_screen, 1,5) + "-"+ substr(unique_id_screen, 6,3) + "-"+ substr(unique_id_screen, 9,3)
drop unique_id_screen
rename unique_id_hyphen_screen unique_id_screen
replace  unique_id_screen= "" if unique_id_screen=="--"

save "${DataRaw}Mortality survey_cleaned vars.dta", replace


********************************************************************************
// STEP 2. Creating dataset for new women in the dataset
********************************************************************************
use "${DataRaw}Mortality survey_cleaned vars.dta", clear


keep unique_id_new new_* 
rename unique_id_new unique_id


drop if unique_id==""
duplicates report unique_id
duplicates tag unique_id, gen(dup)
tab dup
replace unique_id="30701-503-500" if new_woman_name_1=="KALABATI MAHANANDIA and 48 years"

//reshaping at woman level
reshape long new_woman_name_ new_consent_woman_ new_no_consent_reason_ new_residence_yesno_ new_vill_woman_ new_last_5yrs_preg_ new_child_living_num_ new_child_away_num_ new_child_away_yn_ new_child_living_yn_ new_child_still_num_ new_child_still_yn_ new_child_died_yn_less24_ new_child_died_yn_more24_ new_child_died_num_more24_ new_child_died_num_less24_ new_name_child_ new_age_child_ new_unit_child_age_ new_date_birth_child_ new_date_death_child_ new_cause_death_diag_yn_ new_cause_death_child_ new_miscarriage_yn_, i(unique_id) j(num)


drop new_cause_death_child_1_1_1 new_cause_death_child_2_1_1 new_cause_death_child_3_1_1 new_cause_death_child_4_1_1 new_cause_death_child_5_1_1 new_cause_death_child_6_1_1 new_cause_death_child_7_1_1 new_cause_death_child_8_1_1 new_cause_death_child_9_1_1 new_cause_death_child_10_1_1 new_cause_death_child_11_1_1 new_cause_death_child_12_1_1 new_cause_death_child_13_1_1 new_cause_death_child_14_1_1 new_cause_death_child_15_1_1 new_cause_death_child_16_1_1 new_cause_death_child_17_1_1 new_cause_death_child_18_1_1 new_cause_death_child__77_1_1 new_cause_death_child_999_1_1 new_cause_death_child_98_1_1 new_cause_death_child_1_2_1 new_cause_death_child_2_2_1 new_cause_death_child_3_2_1 new_cause_death_child_4_2_1 new_cause_death_child_5_2_1 new_cause_death_child_6_2_1 new_cause_death_child_7_2_1 new_cause_death_child_8_2_1 new_cause_death_child_9_2_1 new_cause_death_child_10_2_1 new_cause_death_child_11_2_1 new_cause_death_child_12_2_1 new_cause_death_child_13_2_1 new_cause_death_child_14_2_1 new_cause_death_child_15_2_1 new_cause_death_child_16_2_1 new_cause_death_child_17_2_1 new_cause_death_child_18_2_1 new_cause_death_child__77_2_1 new_cause_death_child_999_2_1 new_cause_death_child_98_2_1 new_cause_death_child_1_3_1 new_cause_death_child_2_3_1 new_cause_death_child_3_3_1 new_cause_death_child_4_3_1 new_cause_death_child_5_3_1 new_cause_death_child_6_3_1 new_cause_death_child_7_3_1 new_cause_death_child_8_3_1 new_cause_death_child_9_3_1 new_cause_death_child_10_3_1 new_cause_death_child_11_3_1 new_cause_death_child_12_3_1 new_cause_death_child_13_3_1 new_cause_death_child_14_3_1 new_cause_death_child_15_3_1 new_cause_death_child_16_3_1 new_cause_death_child_17_3_1 new_cause_death_child_18_3_1 new_cause_death_child__77_3_1 new_cause_death_child_999_3_1 new_cause_death_child_98_3_1 new_cause_death_child_1_4_1 new_cause_death_child_2_4_1 new_cause_death_child_3_4_1 new_cause_death_child_4_4_1 new_cause_death_child_5_4_1 new_cause_death_child_6_4_1 new_cause_death_child_7_4_1 new_cause_death_child_8_4_1 new_cause_death_child_9_4_1 new_cause_death_child_10_4_1 new_cause_death_child_11_4_1 new_cause_death_child_12_4_1 new_cause_death_child_13_4_1 new_cause_death_child_14_4_1 new_cause_death_child_15_4_1 new_cause_death_child_16_4_1 new_cause_death_child_17_4_1 new_cause_death_child_18_4_1 new_cause_death_child__77_4_1 new_cause_death_child_999_4_1 new_cause_death_child_98_4_1



drop new_no_consent_reason_1_1 new_no_consent_reason_2_1 new_no_consent_reason__77_1 new_no_consent_reason_1_2 new_no_consent_reason_2_2 new_no_consent_reason__77_2 new_no_consent_reason_1_3 new_no_consent_reason_2_3 new_no_consent_reason__77_3

drop new_vill_woman_oth_1 new_cause_death_child_oth_1_1 new_vill_woman_oth_2 new_cause_death_child_oth_2_1 new_vill_woman_oth_3 new_cause_death_child_oth_3_1 new_vill_woman_oth_4 new_cause_death_child_oth_4_1 new_vill_woman_oth_sc_1 new_cause_death_child_oth_sc_1_1 new_cause_death_child_oth_sc_1_2 new_vill_woman_oth_sc_2 new_cause_death_child_oth_sc_2_1 new_cause_death_child_oth_sc_2_2 new_vill_woman_oth_sc_3 new_cause_death_child_oth_sc_3_1 new_cause_death_child_oth_sc_3_2 new_vill_woman_oth_sc_4 new_cause_death_child_oth_sc_4_1 new_cause_death_child_oth_sc_4_2 new_vill_woman_oth_sc_5 new_cause_death_child_oth_sc_5_1 new_cause_death_child_oth_sc_5_2 new_vill_woman_oth_sc_6 new_cause_death_child_oth_sc_6_1 new_cause_death_child_oth_sc_6_2 new_woman_name_oth_1 new_consent_woman_oth_1 new_no_consent_reason_oth_1 new_no_consent_reason_oth_1_1 new_no_consent_reason_oth_2_1 new_no_consent_reason_oth__77_1 new_residence_yesno_oth_1 new_vill_woman_oth_add_1 new_vill_woman_oth_oth_1 new_last_5yrs_preg_oth_1 new_child_living_yn_oth_1 new_child_living_num_oth_1 new_child_away_yn_oth_1 new_child_away_num_oth_1 new_child_still_yn_oth_1 new_child_still_num_oth_1 new_child_died_yn_less24_oth_1 new_child_died_num_less24_oth_1 new_child_died_yn_more24_oth_1 new_child_died_num_more24_oth_1 new_miscarriage_yn_oth_1 new_woman_name_oth_2 new_consent_woman_oth_2 new_no_consent_reason_oth_2 new_no_consent_reason_oth_1_2 new_no_consent_reason_oth_2_2 new_no_consent_reason_oth__77_2 new_residence_yesno_oth_2 new_vill_woman_oth_add_2 new_vill_woman_oth_oth_2 new_last_5yrs_preg_oth_2 new_child_living_yn_oth_2 new_child_living_num_oth_2 new_child_away_yn_oth_2 new_child_away_num_oth_2 new_child_still_yn_oth_2 new_child_still_num_oth_2 new_child_died_yn_less24_oth_2 new_child_died_num_less24_oth_2 new_child_died_yn_more24_oth_2 new_child_died_num_more24_oth_2 new_miscarriage_yn_oth_2

drop new_no_consent_reason_1_4 new_no_consent_reason_2_4 new_no_consent_reason__77_4 new_cause_death_child_str_sc_1_1 new_cause_death_child_str_sc_1_2 new_cause_death_child_str_sc_2_1 new_cause_death_child_str_sc_2_2 new_cause_death_child_str_sc_3_1 new_cause_death_child_str_sc_3_2 new_cause_death_child_str_sc_4_1 new_cause_death_child_str_sc_4_2 new_cause_death_child_str_sc_5_1 new_cause_death_child_str_sc_5_2 new_cause_death_child_str_sc_6_1 new_cause_death_child_str_sc_6_2 dup new_name_child_ new_age_child_ new_unit_child_age_ new_date_birth_child_ new_date_death_child_ new_cause_death_diag_yn_ new_cause_death_child_

order unique_id num new_woman_name_ new_consent_woman_ new_no_consent_reason_ new_residence_yesno_ new_vill_woman_ new_last_5yrs_preg_ new_child_living_yn_ new_child_living_num_ new_child_away_yn_ new_child_away_num_ new_child_still_yn_ new_child_still_num_ new_child_died_yn_less24_ new_child_died_num_less24_ new_child_died_yn_more24_ new_child_died_num_more24_ new_name_child_1_1 new_age_child_1_1 new_unit_child_age_1_1 new_cause_death_child_1_1 new_cause_death_diag_yn_1_1 new_cause_death_child_str_1_1 new_date_birth_child_1_1 new_date_death_child_1_1 new_name_child_2_1 new_age_child_2_1 new_unit_child_age_2_1 new_cause_death_child_2_1 new_cause_death_diag_yn_2_1 new_cause_death_child_str_2_1 new_date_birth_child_2_1 new_date_death_child_2_1 new_name_child_3_1 new_age_child_3_1 new_unit_child_age_3_1 new_cause_death_child_3_1 new_cause_death_diag_yn_3_1 new_cause_death_child_str_3_1 new_date_birth_child_3_1 new_date_death_child_3_1 new_name_child_4_1 new_age_child_4_1 new_unit_child_age_4_1 new_cause_death_child_4_1 new_cause_death_diag_yn_4_1 new_cause_death_child_str_4_1 new_date_birth_child_4_1 new_date_death_child_4_1 new_miscarriage_yn_ 


//further cleaning- handling duplicates

duplicates report unique_id new_woman_name_
duplicates tag unique_id new_woman_name_, gen(dup)
tab dup
br if dup>0
drop if dup>0 & new_consent_woman_==.

duplicates report unique_id new_woman_name_
drop dup
duplicates tag unique_id new_woman_name_, gen(dup)
tab dup
br if dup>0
duplicates drop unique_id new_woman_name_, force

duplicates report unique_id new_woman_name_


//reshaping at child level
reshape long new_name_child_ new_age_child_ new_unit_child_age_ new_cause_death_child_ new_cause_death_diag_yn_ new_cause_death_child_str_ new_date_birth_child_ new_date_death_child_ , i(unique_id new_woman_name_) j(child_num) string

keep if screen_woman_name_!="" & screen_name_child_!=""


//adding village name for ease of matching later
gen village=""
gen village_code= substr(unique_id, 1, 5)
replace village= "B K Padar" if village_code=="30202"
replace village= "Kuljing" if village_code=="50402"

//download the renvars package
drop child_num num dup
renvars new_woman_name_-new_miscarriage_yn_, predrop(4)

save "${DataRaw}Mortality survey_cleaned vars_newwomen.dta", replace



********************************************************************************
// STEP 3. Creating dataset for screened women from census in the dataset
********************************************************************************

use "${DataRaw}Mortality survey_cleaned vars.dta", clear


keep unique_id_screen sc_* screen_* 
rename unique_id_screen unique_id

drop if unique_id==""
duplicates report unique_id
duplicates tag unique_id, gen(dup)
tab dup
br if dup>0
drop if dup>0


//dropping redudant vars

drop screen_cause_death_child_1_1_1 screen_cause_death_child_2_1_1 screen_cause_death_child_3_1_1 screen_cause_death_child_4_1_1 screen_cause_death_child_5_1_1 screen_cause_death_child_6_1_1 screen_cause_death_child_7_1_1 screen_cause_death_child_8_1_1 screen_cause_death_child_9_1_1 screen_cause_death_child_10_1_1 screen_cause_death_child_11_1_1 screen_cause_death_child_12_1_1 screen_cause_death_child_13_1_1 screen_cause_death_child_14_1_1 screen_cause_death_child_15_1_1 screen_cause_death_child_16_1_1 screen_cause_death_child_17_1_1 screen_cause_death_child_18_1_1 screen_cause_death_child__77_1_1 screen_cause_death_child_999_1_1 screen_cause_death_child_98_1_1 screen_cause_death_child_1_1_2 screen_cause_death_child_2_1_2 screen_cause_death_child_3_1_2 screen_cause_death_child_4_1_2 screen_cause_death_child_5_1_2 screen_cause_death_child_6_1_2 screen_cause_death_child_7_1_2 screen_cause_death_child_8_1_2 screen_cause_death_child_9_1_2 screen_cause_death_child_10_1_2 screen_cause_death_child_11_1_2 screen_cause_death_child_12_1_2 screen_cause_death_child_13_1_2 screen_cause_death_child_14_1_2 screen_cause_death_child_15_1_2 screen_cause_death_child_16_1_2 screen_cause_death_child_17_1_2 screen_cause_death_child_18_1_2 screen_cause_death_child__77_1_2 screen_cause_death_child_999_1_2 screen_cause_death_child_98_1_2 screen_cause_death_child_1_2_1 screen_cause_death_child_2_2_1 screen_cause_death_child_3_2_1 screen_cause_death_child_4_2_1 screen_cause_death_child_5_2_1 screen_cause_death_child_6_2_1 screen_cause_death_child_7_2_1 screen_cause_death_child_8_2_1 screen_cause_death_child_9_2_1 screen_cause_death_child_10_2_1 screen_cause_death_child_11_2_1 screen_cause_death_child_12_2_1 screen_cause_death_child_13_2_1 screen_cause_death_child_14_2_1 screen_cause_death_child_15_2_1 screen_cause_death_child_16_2_1 screen_cause_death_child_17_2_1 screen_cause_death_child_18_2_1 screen_cause_death_child__77_2_1 screen_cause_death_child_999_2_1 screen_cause_death_child_98_2_1 screen_cause_death_child_1_2_2 screen_cause_death_child_2_2_2 screen_cause_death_child_3_2_2 screen_cause_death_child_4_2_2 screen_cause_death_child_5_2_2 screen_cause_death_child_6_2_2 screen_cause_death_child_7_2_2 screen_cause_death_child_8_2_2 screen_cause_death_child_9_2_2 screen_cause_death_child_10_2_2 screen_cause_death_child_11_2_2 screen_cause_death_child_12_2_2 screen_cause_death_child_13_2_2 screen_cause_death_child_14_2_2 screen_cause_death_child_15_2_2 screen_cause_death_child_16_2_2 screen_cause_death_child_17_2_2 screen_cause_death_child_18_2_2 screen_cause_death_child__77_2_2 screen_cause_death_child_999_2_2 screen_cause_death_child_98_2_2 screen_cause_death_child_1_3_1 screen_cause_death_child_2_3_1 screen_cause_death_child_3_3_1 screen_cause_death_child_4_3_1 screen_cause_death_child_5_3_1 screen_cause_death_child_6_3_1 screen_cause_death_child_7_3_1 screen_cause_death_child_8_3_1 screen_cause_death_child_9_3_1 screen_cause_death_child_10_3_1 screen_cause_death_child_11_3_1 screen_cause_death_child_12_3_1 screen_cause_death_child_13_3_1 screen_cause_death_child_14_3_1 screen_cause_death_child_15_3_1 screen_cause_death_child_16_3_1 screen_cause_death_child_17_3_1 screen_cause_death_child_18_3_1 screen_cause_death_child__77_3_1 screen_cause_death_child_999_3_1 screen_cause_death_child_98_3_1 screen_cause_death_child_1_3_2 screen_cause_death_child_2_3_2 screen_cause_death_child_3_3_2 screen_cause_death_child_4_3_2 screen_cause_death_child_5_3_2 screen_cause_death_child_6_3_2 screen_cause_death_child_7_3_2 screen_cause_death_child_8_3_2 screen_cause_death_child_9_3_2 screen_cause_death_child_10_3_2 screen_cause_death_child_11_3_2 screen_cause_death_child_12_3_2 screen_cause_death_child_13_3_2 screen_cause_death_child_14_3_2 screen_cause_death_child_15_3_2 screen_cause_death_child_16_3_2 screen_cause_death_child_17_3_2 screen_cause_death_child_18_3_2 screen_cause_death_child__77_3_2 screen_cause_death_child_999_3_2 screen_cause_death_child_98_3_2 screen_cause_death_child_1_4_1 screen_cause_death_child_2_4_1 screen_cause_death_child_3_4_1 screen_cause_death_child_4_4_1 screen_cause_death_child_5_4_1 screen_cause_death_child_6_4_1 screen_cause_death_child_7_4_1 screen_cause_death_child_8_4_1 screen_cause_death_child_9_4_1 screen_cause_death_child_10_4_1 screen_cause_death_child_11_4_1 screen_cause_death_child_12_4_1 screen_cause_death_child_13_4_1 screen_cause_death_child_14_4_1 screen_cause_death_child_15_4_1 screen_cause_death_child_16_4_1 screen_cause_death_child_17_4_1 screen_cause_death_child_18_4_1 screen_cause_death_child__77_4_1 screen_cause_death_child_999_4_1 screen_cause_death_child_98_4_1 screen_cause_death_child_1_4_2 screen_cause_death_child_2_4_2 screen_cause_death_child_3_4_2 screen_cause_death_child_4_4_2 screen_cause_death_child_5_4_2 screen_cause_death_child_6_4_2 screen_cause_death_child_7_4_2 screen_cause_death_child_8_4_2 screen_cause_death_child_9_4_2 screen_cause_death_child_10_4_2 screen_cause_death_child_11_4_2 screen_cause_death_child_12_4_2 screen_cause_death_child_13_4_2 screen_cause_death_child_14_4_2 screen_cause_death_child_15_4_2 screen_cause_death_child_16_4_2 screen_cause_death_child_17_4_2 screen_cause_death_child_18_4_2 screen_cause_death_child__77_4_2 screen_cause_death_child_999_4_2 screen_cause_death_child_98_4_2 screen_cause_death_child_1_5_1 screen_cause_death_child_2_5_1 screen_cause_death_child_3_5_1 screen_cause_death_child_4_5_1 screen_cause_death_child_5_5_1 screen_cause_death_child_6_5_1 screen_cause_death_child_7_5_1 screen_cause_death_child_8_5_1 screen_cause_death_child_9_5_1 screen_cause_death_child_10_5_1 screen_cause_death_child_11_5_1 screen_cause_death_child_12_5_1 screen_cause_death_child_13_5_1 screen_cause_death_child_14_5_1 screen_cause_death_child_15_5_1 screen_cause_death_child_16_5_1 screen_cause_death_child_17_5_1 screen_cause_death_child_18_5_1 screen_cause_death_child__77_5_1 screen_cause_death_child_999_5_1 screen_cause_death_child_98_5_1 screen_cause_death_child_1_5_2 screen_cause_death_child_2_5_2 screen_cause_death_child_3_5_2 screen_cause_death_child_4_5_2 screen_cause_death_child_5_5_2 screen_cause_death_child_6_5_2 screen_cause_death_child_7_5_2 screen_cause_death_child_8_5_2 screen_cause_death_child_9_5_2 screen_cause_death_child_10_5_2 screen_cause_death_child_11_5_2 screen_cause_death_child_12_5_2 screen_cause_death_child_13_5_2 screen_cause_death_child_14_5_2 screen_cause_death_child_15_5_2 screen_cause_death_child_16_5_2 screen_cause_death_child_17_5_2 screen_cause_death_child_18_5_2 screen_cause_death_child__77_5_2 screen_cause_death_child_999_5_2 screen_cause_death_child_98_5_2 screen_cause_death_child_1_6_1 screen_cause_death_child_2_6_1 screen_cause_death_child_3_6_1 screen_cause_death_child_4_6_1 screen_cause_death_child_5_6_1 screen_cause_death_child_6_6_1 screen_cause_death_child_7_6_1 screen_cause_death_child_8_6_1 screen_cause_death_child_9_6_1 screen_cause_death_child_10_6_1 screen_cause_death_child_11_6_1 screen_cause_death_child_12_6_1 screen_cause_death_child_13_6_1 screen_cause_death_child_14_6_1 screen_cause_death_child_15_6_1 screen_cause_death_child_16_6_1 screen_cause_death_child_17_6_1 screen_cause_death_child_18_6_1 screen_cause_death_child__77_6_1 screen_cause_death_child_999_6_1 screen_cause_death_child_98_6_1 screen_cause_death_child_1_6_2 screen_cause_death_child_2_6_2 screen_cause_death_child_3_6_2 screen_cause_death_child_4_6_2 screen_cause_death_child_5_6_2 screen_cause_death_child_6_6_2 screen_cause_death_child_7_6_2 screen_cause_death_child_8_6_2 screen_cause_death_child_9_6_2 screen_cause_death_child_10_6_2 screen_cause_death_child_11_6_2 screen_cause_death_child_12_6_2 screen_cause_death_child_13_6_2 screen_cause_death_child_14_6_2 screen_cause_death_child_15_6_2 screen_cause_death_child_16_6_2 screen_cause_death_child_17_6_2 screen_cause_death_child_18_6_2 screen_cause_death_child__77_6_2 screen_cause_death_child_999_6_2 screen_cause_death_child_98_6_2 screen_no_consent_reason_1_1 screen_no_consent_reason_2_1 screen_no_consent_reason__77_1 screen_no_consent_reason_1_2 screen_no_consent_reason_2_2 screen_no_consent_reason__77_2 screen_no_consent_reason_1_3 screen_no_consent_reason_2_3 screen_no_consent_reason__77_3 screen_no_consent_reason_1_4 screen_no_consent_reason_2_4 screen_no_consent_reason__77_4 screen_no_consent_reason_1_5 screen_no_consent_reason_2_5 screen_no_consent_reason__77_5 screen_no_consent_reason_1_6 screen_no_consent_reason_2_6 screen_no_consent_reason__77_6




//reshaping at woman level
reshape long screen_woman_name_ screen_consent_woman_ screen_no_consent_reason_ screen_residence_yesno_ screen_vill_woman_ screen_last_5yrs_preg_ screen_child_living_yn_ screen_child_living_num_ screen_child_away_yn_ screen_child_away_num_ screen_child_still_yn_ screen_child_still_num_ sc_child_died_yn_less24_ sc_child_died_num_less24_ sc_child_died_yn_more24_ sc_child_died_num_more24_ screen_name_child_ screen_age_child_ screen_unit_child_age_ screen_cause_death_child_ screen_cause_death_diag_yn_ screen_miscarriage_yn_, i(unique_id) j(num)

drop screen_name_child_ screen_age_child_ screen_unit_child_age_ screen_cause_death_child_ screen_cause_death_diag_yn_ dup


//duplicates in terms of unique_id and woman name
duplicates report unique_id screen_woman_name_
duplicates tag unique_id screen_woman_name_, gen (dup)
tab dup
br if dup>0
duplicates drop unique_id screen_woman_name_, force


//reshaping at child level
reshape long screen_name_child_ screen_age_child_ screen_unit_child_age_ screen_cause_death_child_ screen_cause_death_diag_yn_ screen_date_birth_child_ screen_date_death_child_ , i(unique_id screen_woman_name_) j(child_num) string

sort unique_id num child_num
keep if screen_woman_name_!="" & screen_name_child_!=""


//adding village name for ease of matching later
gen village=""
gen village_code= substr(unique_id, 1, 5)
replace village= "B K Padar" if village_code=="30202"
replace village= "Kuljing" if village_code=="50402"
replace village= "Nathma" if village_code=="50501"


//use the renvars package
drop child_num num dup
renvars screen_woman_name_ - screen_date_death_child_, predrop(7)

save "${DataRaw}Mortality survey_cleaned vars_screenedwomen.dta", replace
