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
rename R_FU_unique_id unique_id
destring unique_id,replace

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
* Make sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}
capture export excel unique_id using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Follow") firstrow(var) cell(A1) sheetreplace
drop if unique_id_Unique!=1
drop unique_id_Unique


save "${DataDeid}1_2_Followup_cleaned.dta", replace
