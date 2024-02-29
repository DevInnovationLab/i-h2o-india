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


preserve 

keep if R_Cen_a4_hhmember_gender_ == 2 & R_Cen_a6_hhmember_age_ >= 15 & R_Cen_a6_hhmember_age_ <= 49
tempfile eligible_women
save `eligible_women'

restore


bys unique_id: gen mother = 1 if R_Cen_u5mother_name_ == num[_n]




