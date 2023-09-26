*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
********** (1) Outsheeting HHs for mock/field test of Baseline HH survey
********** (2) Producing preloaded data for mock/field test
****** Created by: DIL (Michelle; repurposed from Akito's code)
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*

* Seed
clear all               
set seed 758235657 // Just in case

import excel using "${DataRaw}Baseline Census_WIDE.xlsx", sheet("data") firstrow allstring
	
//Formatting dates
	split starttime, parse("")
	drop starttime2
	gen day_of_month= substr(starttime1, 1, 2)
	gen month= substr(starttime1, 3, 3)
	gen month_num= .
	replace month_num= 9 if month=="sep"
	*replace month_num= 10 if month=="oct"
	destring day_of_month month_num, replace
	keep if (day_of_month>19 & month_num==9)


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

//cleaning hh head names
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

//keeping relevant variables
keep unique_ID district_name village_name hamlet_name landmark address A39_phone_name_1 A39_phone_num_1 A39_phone_name_2 A39_phone_num_2 A10_hhhead A1_resp_name A11_oldmale_name

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
	
	
//Make sure that the unique_id is unique
duplicates report unique_ID

//Outsheeting list for follow-up
order unique_ID district_name village_name_str hamlet_name landmark address A1_resp_name A10_hhhead A11_oldmale_name A39_phone_name_1 A39_phone_num_1 A39_phone_name_2 A39_phone_num_2
export excel using "${pilot}Follow-up tracking_0925.xlsx", firstrow(var) replace
	


//outsheeting preload data for follow-up survey

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

export excel using "${DataPre}Followup_preload_0925.xlsx", firstrow(var) replace
