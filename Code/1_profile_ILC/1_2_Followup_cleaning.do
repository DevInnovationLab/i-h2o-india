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

use "${DataRaw}1_2_Followup.dta", clear
/*------------------------------------------------------------------------------
	1 Deidentify and renaming
------------------------------------------------------------------------------*/
foreach x of var * { 
	rename `x' R_FU_`x' 
} 
* Variable cuts across will not have prefix
* R_FU_hh_code
rename R_FU_hh_code unique_id

* Ad hoc until we fix the ID management system
replace  unique_id=1111110101 if R_FU_key=="uuid:c4913cc2-4b5d-409a-a245-ee619feffda4"

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/
save "${DataDeid}1_2_Followup_cleaned.dta", replace
