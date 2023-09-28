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
	* This do file exports.....
	
use "${DataFinal}Final_HH_Odisha.dta", clear

/*--------------------------------------- Census quality check ---------------------------------------*/

//2. Checking if respondent is the first member of the household in the roster
* Akito to Michelle: I know what this is doing but not sure what is the action item: We make stats by enumerator?

count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1
br R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 R_Cen_enum_name if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1

	*checking if the respondent name appears among other names in the roster
	preserve
	keep if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1
	reshape long R_Cen_a3_hhmember_name_, i(unique_id_num) j(num)
	count if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	br R_Cen_a3_hhmember_name_ R_Cen_a1_resp_name if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	* This means that the respondent exists in the roster but is not the first respondent so those cases don't need any change
	gen no_change= 1 if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name

	keep if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	keep R_Cen_a1_resp_name no_change unique_id_num
	tempfile resp_names
	save `resp_names', replace

	restore 

	* Fuzzy matching and then Manually fixing the remaining cases
	use `resp_names', clear
	merge 1:1 unique_id_num using "${DataPre}1_1_Census_cleaned_consented.dta"
	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1
	* reclink is better command than matchit
	matchit R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 
	br R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 similscore if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)
	replace R_Cen_a1_resp_name=R_Cen_a3_hhmember_name_1 if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)
	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1

* This is good
//3. Checking if primary water source is not repeated as secondary water source
gen new=.
forvalues i = 1/8 {
	count if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
	replace new= 1  if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
}

preserve
keep unique_id_num R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* new
export excel using "${pilot}Data_quality.xlsx" if new==1, sheet("prim_sec_source") firstrow(var) sheetreplace
restore


//4. Checking inconsistencies in age calculator
/*Note: For ages where the age of child is not equal to dob-calculated age, replace the dob-calculated age with a rounded value
Then, replace age in months and age in days for very small children with age in years (because otherwise, age for these children is recorded as 0)
Finally, replace self-reported age with rounded dob-calculated age where the "age is accurate" i.e checked against birth certificate or anganwaadi records
Then check if age matches dob-calculated age; in most cases it will match except maybe where age is imputed
*/

* Akito to Michelle: I know what this is doing but not sure what is the action item: We make stats by enumerator?
forvalues i = 1/9 {
	destring R_Cen_a5_autoage_`i', replace
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a5_autoage_`i'= ceil(R_Cen_a5_autoage_`i')
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/12 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==1
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/365 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==2
	replace R_Cen_a6_hhmember_age_`i'=R_Cen_a5_autoage_`i' if R_Cen_a6_hhmember_age_`i'!=R_Cen_a5_autoage_`i' & R_Cen_correct_age_`i'==1
}

* High frequnecy chekc
