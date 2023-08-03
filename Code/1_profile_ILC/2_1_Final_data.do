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

* 
use "${DataDeid}1_1_Census_cleaned.dta", clear
* Merge follow up and other data sets
merge 1:1 unique_id using  "${DataDeid}1_2_Followup_cleaned.dta"

* Save final data in STATA/R
save "${DataFinal}Final_HH_Odisha.dta", replace
