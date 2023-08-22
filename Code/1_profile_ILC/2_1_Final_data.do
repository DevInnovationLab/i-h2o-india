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

use "${DataDeid}1_1_Census_cleaned.dta", clear
* Merge follow up and other data sets
merge 1:1 unique_id using "${DataDeid}1_2_Followup_cleaned.dta",gen(Merge_C_F)


*****************
* Quality check *
*****************
* There should be no using data
capture export excel unique_id using "${pilot}Data_quality.xlsx" if Merge_C_F==2, sheet("Merge_C_F_2") firstrow(var) cell(A1) sheetreplace
drop if Merge_C_F==2


* Save final data in STATA/R
save "${DataFinal}Final_HH_Odisha.dta", replace

* Sample size=ANC contact list
cap program drop start_from_clean_file_Census
program define   start_from_clean_file_Census
  * Open clean file
  use                       "${DataFinal}Final_HH_Odisha.dta", clear
  keep if Merge_C_F==1
  
  label var R_Cen_a14_hh_member_count "Household size"
  
end

* Follof up
cap program drop start_from_clean_file_E
program define   start_from_clean_file_E
  * Open clean file
  start_from_clean_file_Census
  
end


