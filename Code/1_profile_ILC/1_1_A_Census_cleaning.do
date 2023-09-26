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
	
clear all               
set seed 758235657 // Just in case

import excel using "${DataRaw}Baseline Census_WIDE.xlsx", sheet("data") firstrow allstring
	
/*------------------------------------------------------------------------------
	1 Formaating dates
------------------------------------------------------------------------------*/
	split starttime, parse("")
	drop starttime2
	gen day_of_month= substr(starttime1, 1, 2)
	gen month= substr(starttime1, 3, 3)
	gen month_num= .
	replace month_num= 9 if month=="sep"
	*replace month_num= 10 if month=="oct"
	destring day_of_month month_num, replace
	keep if (day_of_month>19 & month_num==9)


/*------------------------------------------------------------------------------
	2 Keeping relevant entries
------------------------------------------------------------------------------*/
	destring screen_U5child screen_preg consent, replace
//counting those entries where there was a pregnant woman or child U5
count if (screen_preg==1 | screen_U5child ==1) 
//counting those entries where there was a pregnant woman or child U5, but consent was not given
count if (screen_preg==1 | screen_U5child ==1) & consent==0

//dropping those entries where there was a pregnant woman or child U5 but consent was not given
drop if (screen_preg==1 | screen_U5child ==1) & consent==0

//keeping those entries where there was a pregnant woman or child U5 and consent was obtained
keep if (screen_preg==1 | screen_U5child ==1)


tempfile working_1
save `working_1', replace

/*------------------------------------------------------------------------------
	3 Basic cleaning
------------------------------------------------------------------------------*/

//Cleaning HH head names
preserve
reshape long fam_name, i(unique_ID) j(num)
destring A10_hhhead, replace
keep if num==A10_hhhead
drop A10_hhhead
rename fam_name A10_hhhead

keep unique_ID A10_hhhead

tempfile working_2
save `working_2', replace
restore

use `working_2', clear
merge 1:1 unique_ID using `working_1', gen(merge_hhhead)

tempfile working
save `working', replace


//cleaning village names
clear
import excel using "${DataRaw}India_ILC_Pilot_Baseline Census_Master.xlsx", sheet("choices") firstrow allstring
keep if list_name=="village"
rename value village_name
drop list_name
keep village_name label

tempfile villagename
save `villagename', replace
merge 1:m village_name using `working'
drop if _merge==1 //keeping only merged obs
rename label village_name_str
drop village_name _merge


/*------------------------------------------------------------------------------
	4 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
duplicates report unique_ID
***[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates
***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
save `working', replace


//2. Checking if respondent is the first member of the household in the roster
count if A1_resp_name!=A3_HHmember_name_1
ssc install matchit
ssc install freqindex

	
	*checking if the respondent name appears among other names in the roster
	preserve
	keep if A1_resp_name!=A3_HHmember_name_1
	reshape long A3_HHmember_name_, i(unique_ID) j(num)
	count if A3_HHmember_name_== A1_resp_name
	br A3_HHmember_name_  A1_resp_name if A3_HHmember_name_== A1_resp_name
	* This means that the respondent exists in the roster but is not the first respondent so those cases don't need any change
	gen no_change= 1 if A3_HHmember_name_== A1_resp_name

	keep if A3_HHmember_name_== A1_resp_name
	keep A1_resp_name no_change unique_ID
	tempfile resp_names
	save `resp_names', replace

	restore 


	* Fuzzy matching and then Manually fixing the remaining cases
	use `resp_names', clear
	merge 1:1 unique_ID A1_resp_name using `working'
	count if A1_resp_name!=A3_HHmember_name_1 & no_change!=1

	matchit A1_resp_name A3_HHmember_name_1 
	br A1_resp_name A3_HHmember_name_1 similscore if (A1_resp_name!=A3_HHmember_name_1 & no_change!=1)
	replace A1_resp_name=A3_HHmember_name_1 if (A1_resp_name!=A3_HHmember_name_1 & no_change!=1)



//renaming variables for follow-up preload
rename A1_resp_name a1_resp_name
rename A10_hhhead a10_hhhead 
rename A39_phone_name_1 a39_phone_name_1 
rename A39_phone_num_1  a39_phone_num_1  
rename A39_phone_name_2 a39_phone_name_2  
rename A39_phone_num_2 a39_phone_num_2
rename A11_oldmale_name a11_oldmale_name
rename unique_ID unique_id

* replace unique_id = subinstr(unique_id, "-", "",.)
destring unique_id, replace ignore(-)
format   unique_id %10.0fc


foreach x of var village_name_str hamlet_name landmark address a1_resp_name a10_hhhead a11_oldmale_name a39_phone_name_1 a39_phone_num_1 a39_phone_name_2 a39_phone_num_2 { 
	rename `x' R_Cen_`x' 
} 

/*------------------------------------------------------------------------------
	2 Cleaning (2.1 aaa)
------------------------------------------------------------------------------*/



* Make sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}
* Consider other variables to include
capture export excel unique_id using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Census") firstrow(var) cell(A1) sheetreplace
drop unique_id_Unique

* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force

* Change as we finalzie the treatment village
save "${DataPre}1_1_Census_cleaned.dta", replace
savesome using "${DataPre}1_1_Census_cleaned_consented.dta" if R_Cen_consent==1, replace

** Drop ID information

save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
