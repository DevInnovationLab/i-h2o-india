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

use "${DataRaw}1_7_E.Coli_R2.dta", clear
/*------------------------------------------------------------------------------
	1 Manually adding lab blanks for all days
------------------------------------------------------------------------------*/
* Sort observations by date to be able to add blank dates
 sort date_counted
 
* Correcting labels for when Prasanta did the review (earlier the option was Sanjay as drop down didn't contain PP)
 label define reviewed_by 500 "Prasanta Panda" , add

 replace reviewed_by = 500 if reviewed_by == 101

* Convert unique id for sample to string as we want to add the value in case of field and lab blanks

 tostring unique_sample_id, replace
 replace end_comments = lower(end_comments)
 replace unique_sample_id = "Lab Blank" if end_comments == "lab blank"
 replace unique_sample_id = "Field Blank" if end_comments == "field blank"

 


/*------------------------------------------------------------------------------
	2 Checking for duplicates & droping duplicates
------------------------------------------------------------------------------*/

  duplicates tag unique_sample_id_check if unique_sample_id_check != 0, gen(dup)
  
/*------------------------------------------------------------------------------
	3 Saving this file
------------------------------------------------------------------------------*/
  save "${DataPre}1_7_E.Coli_R2_cleaned.dta", replace








