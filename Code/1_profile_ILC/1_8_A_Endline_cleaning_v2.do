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


use ".dta", clear
 

reshape wide  
//Renaming vars with prefix R_E
foreach x of var * {
	rename `x' R_E_`x'
}

rename R_E_key key
rename  R_E_parent_key R_E_key

/*------------------------------------------------------------------------------
	1 Merging with cleaned 1_8_Endline_Census
------------------------------------------------------------------------------*/
	
	merge  1:1  R_E_key using "${DataPre}1_8_Endline/1_8_Endline_Census_cleaned.dta" , keep( _merge == 3)


/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/

*******Final variable creation for clean data

save "${DataPre}1_8_Endline_XXX.dta", replace
savesome using "${DataPre}1_1_Endline_XXX_consented.dta" if R_E_consent==1, replace

/*
** Drop ID information

drop R_E_a1_resp_name R_E_a3_hhmember_name_1 R_E_a3_hhmember_name_2 R_E_a3_hhmember_name_3 R_E_a3_hhmember_name_4 R_E_a3_hhmember_name_5 R_E_a3_hhmember_name_6 R_E_a3_hhmember_name_7 R_E_a3_hhmember_name_8 R_E_a3_hhmember_name_9 R_E_a3_hhmember_name_10 R_E_a3_hhmember_name_11 R_E_a3_hhmember_name_12 R_E_namefromearlier_1 R_E_namefromearlier_2 R_E_namefromearlier_3 R_E_namefromearlier_4 R_E_namefromearlier_5 R_E_namefromearlier_6 R_E_namefromearlier_7 R_E_namefromearlier_8 R_E_namefromearlier_9 R_E_namefromearlier_10 R_E_namefromearlier_11 R_E_namefromearlier_12 
save "${DataDeid}1_1_Endline_cleaned_noid.dta", replace
