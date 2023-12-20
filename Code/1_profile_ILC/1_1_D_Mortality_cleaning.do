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

*=========================== PROGRAM ==============================================*
putpdf begin
putpdf paragraph, font("Courier",20) halign(center)
putpdf text  ("Descriptive statistics for ILC Pilot") 
putpdf paragraph, font("Courier")
*=========================== PROGRAM END ==============================================*

clear all               
set seed 758235657 // Just in case


use "${DataRaw}1_4_Mortality.dta", clear
 
 
 * Drop label that are getting auto generated for numeric variables
     capture { 
	  foreach rgvar of varlist child_living_num_* {
		    label drop `rgvar'
		}
	 }
	 capture {
       foreach rgvar of varlist child_notliving_num_* {
		    label drop `rgvar'
			
		}
	 }



* Create a single variable for all the variables that were separated by scenario of screened in (_sc)  and updated (_)

local not_screened women_child_bearing_sc_count child_bearing_index_1 -   translator_4

*rename some of the variables to make them consistent for applying loop
rename unique_id_sc1 unique_id_sc
rename (child_died_u5_count_sc_null_1 child_died_u5_count_sc_null_2 child_died_u5_count_sc_null_3 child_died_u5_count_sc_null_4 child_died_u5_count_sc_null_5 child_died_u5_count_sc_null_6) (child_died_u5_count_sc_1 child_died_u5_count_sc_2 child_died_u5_count_sc_3 child_died_u5_count_sc_4 child_died_u5_count_sc_5 child_died_u5_count_sc_6)
  
  
* Create a local of  screened scenarios, where questions are asked based on scenario == 4 
 local screened  women_child_bearing_sc_count enum_name_sc enum_name_label_sc enum_code_sc  child_bearing_index_sc_1 name_pc_sc_1 name_pc_earlier_sc_1 resp_avail_pc_sc_1 consent_pc_sc_1 no_consent_reason_pc_sc_1 no_consent_reason_pc_sc_1_1 no_consent_reason_pc_sc_2_1 no_consent_reason_pc_sc__77_1 no_consent_pc_oth_sc_1 no_consent_pc_comment_sc_1 residence_yesno_pc_sc_1 vill_pc_sc_1 vill_pc_oth_sc_1 a7_pregnant_leave_sc_1 a7_pregnant_leave_days_sc_1 a7_pregnant_leave_months_sc_1 village_name_res_sc_1 vill_residence_sc_1 last_5_years_pregnant_sc_1 child_living_sc_1 child_living_num_sc_1 child_notliving_sc_1 child_notliving_num_sc_1 child_stillborn_sc_1 child_stillborn_num_sc_1 child_alive_died_24_sc_1 child_died_num_sc_1 child_alive_died_sc_1 child_died_num_more24_sc_1  child_died_u5_count_sc_1 child_died_repeat_sc_count_1 confirm_sc_1 correct_sc_1 translator_sc_1  child_bearing_index_sc_2 name_pc_sc_2 name_pc_earlier_sc_2 resp_avail_pc_sc_2 consent_pc_sc_2 no_consent_reason_pc_sc_2 no_consent_reason_pc_sc_1_2 no_consent_reason_pc_sc_2_2 no_consent_reason_pc_sc__77_2 no_consent_pc_oth_sc_2 no_consent_pc_comment_sc_2 residence_yesno_pc_sc_2 vill_pc_sc_2 vill_pc_oth_sc_2 a7_pregnant_leave_sc_2 a7_pregnant_leave_days_sc_2 a7_pregnant_leave_months_sc_2 village_name_res_sc_2 vill_residence_sc_2 last_5_years_pregnant_sc_2 child_living_sc_2 child_living_num_sc_2 child_notliving_sc_2 child_notliving_num_sc_2 child_stillborn_sc_2 child_stillborn_num_sc_2 child_alive_died_24_sc_2 child_died_num_sc_2 child_alive_died_sc_2 child_died_num_more24_sc_2  child_died_u5_count_sc_2 child_died_repeat_sc_count_2 confirm_sc_2 correct_sc_2 translator_sc_2 child_bearing_index_sc_3 name_pc_sc_3 name_pc_earlier_sc_3 resp_avail_pc_sc_3 consent_pc_sc_3 no_consent_reason_pc_sc_3 no_consent_reason_pc_sc_1_3 no_consent_reason_pc_sc_2_3 no_consent_reason_pc_sc__77_3 no_consent_pc_oth_sc_3 no_consent_pc_comment_sc_3 residence_yesno_pc_sc_3 vill_pc_sc_3 vill_pc_oth_sc_3 a7_pregnant_leave_sc_3 a7_pregnant_leave_days_sc_3 a7_pregnant_leave_months_sc_3 village_name_res_sc_3 vill_residence_sc_3 last_5_years_pregnant_sc_3 child_living_sc_3 child_living_num_sc_3 child_notliving_sc_3 child_notliving_num_sc_3 child_stillborn_sc_3 child_stillborn_num_sc_3 child_alive_died_24_sc_3 child_died_num_sc_3 child_alive_died_sc_3 child_died_num_more24_sc_3 child_died_u5_count_sc_3 child_died_repeat_sc_count_3 confirm_sc_3 correct_sc_3 translator_sc_3 child_bearing_index_sc_4 name_pc_sc_4 name_pc_earlier_sc_4 resp_avail_pc_sc_4 consent_pc_sc_4 no_consent_reason_pc_sc_4 no_consent_reason_pc_sc_1_4 no_consent_reason_pc_sc_2_4 no_consent_reason_pc_sc__77_4 no_consent_pc_oth_sc_4 no_consent_pc_comment_sc_4 residence_yesno_pc_sc_4 vill_pc_sc_4 vill_pc_oth_sc_4 a7_pregnant_leave_sc_4 a7_pregnant_leave_days_sc_4 a7_pregnant_leave_months_sc_4 village_name_res_sc_4 vill_residence_sc_4 last_5_years_pregnant_sc_4 child_living_sc_4 child_living_num_sc_4 child_notliving_sc_4 child_notliving_num_sc_4 child_stillborn_sc_4 child_stillborn_num_sc_4 child_alive_died_24_sc_4 child_died_num_sc_4 child_alive_died_sc_4 child_died_num_more24_sc_4  child_died_u5_count_sc_4 child_died_repeat_sc_count_4 confirm_sc_4 correct_sc_4 translator_sc_4 child_bearing_index_sc_5 name_pc_sc_5 name_pc_earlier_sc_5 resp_avail_pc_sc_5 consent_pc_sc_5 no_consent_reason_pc_sc_5 no_consent_reason_pc_sc_1_5 no_consent_reason_pc_sc_2_5 no_consent_reason_pc_sc__77_5 no_consent_pc_oth_sc_5 no_consent_pc_comment_sc_5 residence_yesno_pc_sc_5 vill_pc_sc_5 vill_pc_oth_sc_5 a7_pregnant_leave_sc_5 a7_pregnant_leave_days_sc_5 a7_pregnant_leave_months_sc_5 village_name_res_sc_5 vill_residence_sc_5 last_5_years_pregnant_sc_5 child_living_sc_5 child_living_num_sc_5 child_notliving_sc_5 child_notliving_num_sc_5 child_stillborn_sc_5 child_stillborn_num_sc_5 child_alive_died_24_sc_5 child_died_num_sc_5 child_alive_died_sc_5 child_died_num_more24_sc_5  child_died_u5_count_sc_5 child_died_repeat_sc_count_5 confirm_sc_5 correct_sc_5 translator_sc_5 child_bearing_index_sc_6 name_pc_sc_6 name_pc_earlier_sc_6 resp_avail_pc_sc_6 consent_pc_sc_6 no_consent_reason_pc_sc_6 no_consent_reason_pc_sc_1_6 no_consent_reason_pc_sc_2_6 no_consent_reason_pc_sc__77_6 no_consent_pc_oth_sc_6 no_consent_pc_comment_sc_6 residence_yesno_pc_sc_6 vill_pc_sc_6 vill_pc_oth_sc_6 a7_pregnant_leave_sc_6 a7_pregnant_leave_days_sc_6 a7_pregnant_leave_months_sc_6 village_name_res_sc_6 vill_residence_sc_6 last_5_years_pregnant_sc_6 child_living_sc_6 child_living_num_sc_6 child_notliving_sc_6 child_notliving_num_sc_6 child_stillborn_sc_6 child_stillborn_num_sc_6 child_alive_died_24_sc_6 child_died_num_sc_6 child_alive_died_sc_6 child_died_num_more24_sc_6   child_died_u5_count_sc_6 child_died_repeat_sc_count_6 confirm_sc_6 correct_sc_6 translator_sc_6
 
 *this is an irrelevant variable
drop sectionb_dur_end child_died_u5_count_sc_null_oth_ child_died_repeat_oth_count_1 survey_member_names_count_1
 
 * Combine women in child bearing age count  - women_child_bearing_count 
foreach x of varlist `screened' {
	local y_`x' = regexr("`x'", "_sc","")
	rename `x' `y_`x''_sc
}

foreach x of varlist women_child_bearing_count - translator_4 {
	gen `x'_f = `x'
	replace `x'_f = `x'_sc if  missing(`x') & !missing(`x'_sc)
	drop `x' `x'_sc
}

local child_roster name_child_sc_1_1 - cause_death_str_sc_1_1 name_child_sc_2_1 - cause_death_str_sc_2_1 name_child_sc_3_1 - cause_death_str_sc_3_1 name_child_sc_4_1 - cause_death_str_sc_4_1 name_child_sc_5_1 - cause_death_str_sc_5_1 name_child_sc_6_1 - cause_death_str_sc_6_1 

foreach x of varlist `child_roster' {
    local y_`x' = regexr("`x'", "_sc","")
	gen `y_`x''_f = `x'
	drop `x'
}

local var_left_sc *_5_sc *_6_sc 
foreach x of varlist `var_left_sc' {
    local y_`x' = regexr("`x'", "_sc","")
	gen `y_`x''_f = `x'
	drop `x'
}

decode village_name, gen(village_name_str)
local preload_notsc village_name_str hamlet_name - saahi_name landmark address  fam_name1 - child_bearing_list

rename child_bearing_list_preload r_cen_child_bearing_list
local cen cen*

foreach x of varlist `cen' {
	rename `x' r_`x'

}

local preload_sc r_cen_landmark - r_cen_child_bearing_list

foreach x of varlist `preload_notsc' {
	gen `x'_f = `x'
	replace `x'_f = r_cen_`x' if  missing(`x') & !missing(r_cen_`x')
    drop `x'
}



* this is unique id for screened in households
destring unique_id ,  gen(unique_id_num)
format unique_id_num %15.0gc

rename unique_id_sc unique_id_hyphen
gen unique_id_sc = subinstr(unique_id_hyphen, "-", "",.) 
destring unique_id_sc, gen(unique_id_sc_num)
format   unique_id_sc_num %15.0gc

replace unique_id_num = unique_id_sc_num if check_scenario == 1

* Stata variable names that are too long need to be rename
rename (r_cen_a12_water_source_prim  previous_primary_source_label change_reason_primary_source change_reason_primary_source*  change_reason_secondary__77 a13_change_reason_secondary  women_child_bearing_oth_count      no_consent_pc_comment_oth_1 a7_pregnant_leave_days_oth_1  last_5_years_pregnant_oth_1 child_died_num_more24_oth_1  women_child_bearing_count_f          child_died_repeat_count_*   no_consent_reason_pc*    a7_pregnant_leave_months*   cause_death_diagnosed_*) (cen_a12_water_prim  previous_prim_label change_reason_prim change_reason_prim*   change_reason_sec__77 a13_change_reason_sec  women_child_oth_count     no_con_pc_com_oth_1 a7_preg_leave_days_oth_1  last_5_years_preg_oth_1 childdied_num_mor24_oth_1  women_child_bear_count_f childdied_repeat_count_*  no_con_reason_pc*   a7_preg_leave_months*   cause_death_diag_*)

//Renaming vars with prefix R_mor
foreach x of var * {
	rename `x' R_mor_`x'
}

rename R_mor_unique_id_num unique_id_num
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	*gen date = dofc(starttime)
	*format date %td
	gen R_mor_day = day(dofc(R_mor_starttime))
	gen R_mor_month_num = month(dofc(R_mor_starttime))
	//to change once survey date is fixed
	drop if (R_mor_day==23 & R_mor_month_num==9)
	
	 generate M_starthour = hh(R_mor_starttime) 
	 gen M_startmin= mm(R_mor_starttime)
	
	gen diff_minutes = clockdiff(R_mor_starttime, R_mor_endtime, "minute")
	

/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/
//1. Changing village_name to string
*recode R_Cen_village_name 30101=50601
*recode R_Cen_gp_name 301=506
*label define R_Cen_village_namel 50601 "Baadalubadi"
*label values R_Cen_village_name R_Cen_village_namel

decode R_mor_village_name, gen (R_mor_village_str)
br R_mor_village_name R_mor_village_str
replace R_mor_village_str= "Badaalubadi" if R_mor_village_name==50601


//2. dropping irrelevant entries

//3. dropping duplicate case based on field team feedback
*Note: the below duplicate is dropped because first the enumerator wrongly screened this HH out of the sample because of language issues. The supervisor later covered this case again
drop if R_mor_key==""

*Note: the below duplicate case is resolved such that 2 cases with the same HH number 36 do not exist. 


//5. Cleaning the GPS data 
// Keeping the most reliable entry of GPS

* Manual
foreach i in R_mor_gpslatitude R_mor_gpslongitude R_mor_gpsaltitude  {
	replace `i'=. if R_mor_gpslatitude>25  | R_mor_gpslatitude<15
    replace `i'=. if R_mor_gpslongitude>85 | R_mor_gpslongitude<80
}
* Auto
foreach i in R_mor_a40_gps_auto_2latitude_1 R_mor_a40_gps_auto_2longitude_1   {
	replace `i'=. if R_mor_a40_gps_auto_2latitude_1>25  | R_mor_a40_gps_auto_2latitude_1<15
    replace `i'=. if R_mor_a40_gps_auto_2longitude_1>85 | R_mor_a40_gps_auto_2longitude_1<80
}
* Final GPS
foreach i in latitude longitude altitude{
	gen     R_mor_a40_gps_`i'=R_mor_a40_gps_auto_2`i'_1
	replace R_mor_a40_gps_`i'=R_mor_gps`i' if R_mor_a40_gps_`i'==.
	* Add manual
	drop R_mor_a40_gps_auto_2`i'_1 R_mor_gps`i'
}

* Reconsider puting back back but with less confusing variable name
drop R_mor_a40_gps_auto_2accuracy_1 R_mor_gpsaccuracy  


/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}

tempfile working
save `working', replace

/**[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates

Respondent Names are recorded only after consent so they should be the same for one unique ID

There can be three types of cases:
1) Where ID is same and in one case respondent name is present but in others it is missing for the same day
2) Where ID is same and name is missing. This could be because respondent wasn't available or was screened out or consent was not given.
3) Where ID is same and names are different
//check if the data is coming from same enumerator? or different enumerators?
//check if village and enumerator are matched correctly; remove consistencies

Case 1 shouldn't exist because for the same HH, we will have only one form => Field team to check
Case 2 also shouldn't exist because for the same HH, we will submit just one form =>  Field team to check
Case 3 can exist due to data entry issues. This will be fixed below 

*/

preserve
keep if unique_id_num_Unique!=1 //for ease of observation and analysis
duplicates report unique_id_num R_mor_fam_name1_f


//keeping instance for IDs where consent was obtained
replace R_mor_consent= 0 if R_mor_consent==.
bys unique_id_num (R_mor_consent): gen M_dup_by_consent= _n if R_mor_consent[_n]!=R_mor_consent[_n+1]
br unique_id_num R_mor_consent M_dup_by_consent
drop if R_mor_consent==0 & M_dup_by_consent[_n]== 1 

//sorting and marking duplicate number by submission time 
bys unique_id_num (R_mor_starttime): gen M_dup_tag= _n if R_mor_consent==0

//Case 1-
gen M_new1= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]!=R_mor_fam_name1_f[_n+1] & R_mor_fam_name1_f[_n]==""

//Case 2-
gen M_new2= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]==R_mor_fam_name1_f[_n+1] 

//Case 3- 
gen M_new3= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]!=R_mor_fam_name1_f[_n+1] & R_mor_fam_name1_f[_n]!=""

tempfile dups
save `dups', replace

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
//submission time to be added Bys unique_id (submissiontime): gen
keep if M_new1==1 | M_new2==1 | M_new3==1
 capture export excel unique_id_num R_mor_enum_name_f R_mor_village_str_f R_m_submissiondate using "${pilot}Data_quality.xlsx" if unique_id_num_Unique!=1, sheet("Dup_ID_Mortality") ///
 firstrow(var) cell(A1) sheetreplace

/* To update this onced discussed with Archi
***** Step 3: Creating new IDs for obvious duplicates; keeping the first ID based on the starttime and consent and changing the IDs of the remaining

use `dups', clear
keep if M_dup_by_consent==2 & R_mor_consent==1
tempfile dups_part1
save `dups_part1', replace

use `dups', clear
keep if M_dup_tag==1
tempfile dups_part2
save `dups_part2', replace


//Using sequential numbers starting from 500 for remaining duplicate ID cases because we wouldn't encounter so many pregnant women/children U5 in a village
use `dups', clear
keep if C_dup_tag>1 & R_Cen_consent!=1
bys unique_id :gen C_seq=_n
replace R_Cen_hh_code= R_Cen_hh_code+ C_seq + 500
egen unique_id_new= concat (R_Cen_village_name R_Cen_enum_code R_Cen_hh_code)
replace unique_id= unique_id_new 

tempfile dups_part3
save `dups_part3', replace


restore
*/

/*

****Step 4: Appending files with unqiue IDs
use `working', clear
drop if unique_id_num_Unique!=1
append using `dups_part1', force
append using `dups_part2', force
append using `dups_part3', force
//also append file that comes corrected from the field

duplicates report unique_id //final check

drop unique_id_num_Unique 
* Recreating the unique variable after solving the duplicates
drop unique_id_num unique_id_hyphen
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc 
gen unique_id_hyphen = substr(unique_id, 1,5) + "-"+ substr(unique_id, 6,3) + "-"+ substr(unique_id, 9,3)

replace R_Cen_consent=. if R_Cen_screen_u5child==0 & R_Cen_screen_preg==0
replace R_Cen_consent=. if R_Cen_screen_u5child==. & R_Cen_screen_preg==.
*replace R_Cen_instruction= 1 if R_Cen_screen_u5child==1 | R_Cen_screen_preg==1


/*
clear all
//Ensuring we have correct observations from all form versions
import excel "${DataRaw}Baseline Census_WIDE.xlsx", sheet("data") firstrow
gen unique_id = subinstr(unique_ID, "-", "",.) 
merge m:1 unique_id using `main'
*/
/*
* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)- not sure this is needed as long as ID is unique

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force
*/
*/


*******Final variable creation for clean data

gen      M_HH_not_available=0
replace M_HH_not_available=1 if R_mor_resp_available!=1

foreach i in R_mor_consent   {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}

tempfile main
save `main', replace


/*
//correcting dates using raw data
clear
import delimited using "${DataRaw}Baseline Census_WIDE.csv"
duplicates drop unique_id, force
keep submissiondate starttime unique_id
rename unique_id unique_id_hyphen
gen unique_id = subinstr(unique_id_hyphen, "-", "",.) 
merge 1:1 unique_id using `main'

drop if _merge==1

//Formatting dates
	split starttime, parse("")
	drop starttime2
	gen month= substr(starttime1, 1, 2)
	replace month="9" if month=="9/"
	gen day_of_month= substr(starttime1, 3, 3)
	replace day_of_month = subinstr(day_of_month, "/", "", .)

	replace month= "Oct" if month=="10"
	replace month= "Sept" if month=="9"
	gen month_day= day_of_month + " " + month + " " + "2023"
*/

save "${DataPre}1_1_Mortality_cleaned.dta", replace
savesome using "${DataPre}1_1_Mortality_cleaned_consented.dta" if R_mor_consent==1, replace

** Drop ID information  - to do : deidentify data
/*
drop R_mor_a1_resp_name R_Cen_a3_hhmember_name_1 R_Cen_a3_hhmember_name_2 R_Cen_a3_hhmember_name_3 R_Cen_a3_hhmember_name_4 R_Cen_a3_hhmember_name_5 R_Cen_a3_hhmember_name_6 R_Cen_a3_hhmember_name_7 R_Cen_a3_hhmember_name_8 R_Cen_a3_hhmember_name_9 R_Cen_a3_hhmember_name_10 R_Cen_a3_hhmember_name_11 R_Cen_a3_hhmember_name_12 R_Cen_namefromearlier_1 R_Cen_namefromearlier_2 R_Cen_namefromearlier_3 R_Cen_namefromearlier_4 R_Cen_namefromearlier_5 R_Cen_namefromearlier_6 R_Cen_namefromearlier_7 R_Cen_namefromearlier_8 R_Cen_namefromearlier_9 R_Cen_namefromearlier_10 R_Cen_namefromearlier_11 R_Cen_namefromearlier_12 
save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
