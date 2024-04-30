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


use "${DataRaw}1_1_Census.dta", clear
 
drop consented1child_followup5child_h
//Renaming vars with prefix R_Cen
foreach x of var * {
	rename `x' R_Cen_`x'
}



* This variable has to be named consistently across data set
rename R_Cen_unique_id unique_id_hyphen
gen unique_id = subinstr(unique_id_hyphen, "-", "",.) 
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	*gen date = dofc(starttime)
	*format date %td
	gen R_Cen_day = day(dofc(R_Cen_starttime))
	gen R_Cen_month_num = month(dofc(R_Cen_starttime))
	//to change once survey date is fixed
	drop if (R_Cen_day==23 & R_Cen_month_num==9)
	
	 generate C_starthour = hh(R_Cen_starttime) 
	 gen C_startmin= mm(R_Cen_starttime)

	gen diff_minutes = clockdiff(R_Cen_starttime, R_Cen_endtime, "minute")
	

    gen R_Cen_yr_num = year(dofc(R_Cen_starttime))

	
    
    gen cen_date = mdy(R_Cen_month_num, R_Cen_day, R_Cen_yr_num)

	format cen_date  %d


/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/
//1. Changing village_name to string
recode R_Cen_village_name 30101=50601
recode R_Cen_gp_name 301=506
*label define R_Cen_village_namel 50601 "Baadalubadi"
*label values R_Cen_village_name R_Cen_village_namel

decode R_Cen_village_name, gen (R_Cen_village_str)
br R_Cen_village_name R_Cen_village_str
replace R_Cen_village_str= "Badaalubadi" if R_Cen_village_name==50601


//2. dropping irrelevant entries
count if R_Cen_village_name==88888
tab R_Cen_day if R_Cen_village_name==88888
drop if  R_Cen_village_name==88888
*drop if R_Cen_village_name==10101

//3. dropping duplicate case based on field team feedback
*Note: the below duplicate is dropped because first the enumerator wrongly screened this HH out of the sample because of language issues. The supervisor later covered this case again
drop if R_Cen_key=="uuid:c906fcad-e822-4de6-a183-f1c36e1fba9f"

*Note: the below duplicate case is resolved such that 2 cases with the same HH number 36 do not exist. 
br if unique_id_hyphen=="20201-108-036"
replace unique_id_hyphen="20201-108-037" if R_Cen_key=="uuid:c648052b-4ed8-4f5d-b160-7d373bf11fd4"
replace unique_id = subinstr(unique_id_hyphen, "-", "",.) 


//5. Cleaning the GPS data 
// Keeping the most reliable entry of GPS

* Auto
foreach i in R_Cen_a40_gps_autolatitude R_Cen_a40_gps_autolongitude R_Cen_a40_gps_autoaltitude R_Cen_a40_gps_autoaccuracy {
	replace `i'=. if R_Cen_a40_gps_autolatitude>25  | R_Cen_a40_gps_autolatitude<15
    replace `i'=. if R_Cen_a40_gps_autolongitude>85 | R_Cen_a40_gps_autolongitude<80
}

* Manual
foreach i in R_Cen_a40_gps_manuallatitude R_Cen_a40_gps_manuallongitude R_Cen_a40_gps_manualaltitude R_Cen_a40_gps_manualaccuracy {
	replace `i'=. if R_Cen_a40_gps_manuallatitude>25  | R_Cen_a40_gps_manuallatitude<15
    replace `i'=. if R_Cen_a40_gps_manuallongitude>85 | R_Cen_a40_gps_manuallongitude<80
}

* Final GPS
foreach i in latitude longitude {
	gen     R_Cen_a40_gps_`i'=R_Cen_a40_gps_auto`i'
	replace R_Cen_a40_gps_`i'=R_Cen_a40_gps_manual`i' if R_Cen_a40_gps_`i'==.
	* Add manual
	drop R_Cen_a40_gps_auto`i' R_Cen_a40_gps_manual`i'
}
* Reconsider puting back back but with less confusing variable name
drop R_Cen_a40_gps_autoaltitude R_Cen_a40_gps_manualaltitude
drop R_Cen_a40_gps_autoaccuracy R_Cen_a40_gps_manualaccuracy R_Cen_a40_gps_handlongitude R_Cen_a40_gps_handlatitude


//4. Capturing correct section-wise duration

drop R_Cen_consent_duration R_Cen_intro_duration R_Cen_sectionb_duration //old vars
destring R_Cen_survey_duration R_Cen_intro_dur_end R_Cen_consent_dur_end R_Cen_sectionb_dur_end R_Cen_sectionc_dur_end ///
R_Cen_sectiond_dur_end R_Cen_sectione_dur_end R_Cen_sectionf_dur_end R_Cen_sectiong_dur_end R_Cen_sectionh_dur_end, replace

*drop R_Cen_intro_dur_end R_Cen_consent_dur_end R_Cen_sectionb_dur_end R_Cen_sectionc_dur_end ///
*R_Cen_sectiond_dur_end R_Cen_sectione_dur_end R_Cen_sectionf_dur_end R_Cen_sectiong_dur_end R_Cen_sectionh_dur_end
*/


//5. Cleaning the names of pregnant women in the data
local i = 1
local pregwoman R_Cen_pregwoman_1 R_Cen_pregwoman_2 R_Cen_pregwoman_3 R_Cen_pregwoman_4 R_Cen_pregwoman_5 ///
 R_Cen_pregwoman_6 R_Cen_pregwoman_7 R_Cen_pregwoman_8 R_Cen_pregwoman_9 R_Cen_pregwoman_10 R_Cen_pregwoman_11 ///
 R_Cen_pregwoman_12 R_Cen_pregwoman_13 R_Cen_pregwoman_14 R_Cen_pregwoman_15 R_Cen_pregwoman_16 R_Cen_pregwoman_17 
   
foreach x of  local pregwoman {
	replace `x' = "" if R_Cen_a7_pregnant_`i' != 1
    local ++i
}

//6. Cleaning the names of children under 5 in the data
local i = 1
local childU5 R_Cen_u5child_1 R_Cen_u5child_2 R_Cen_u5child_3 R_Cen_u5child_4 R_Cen_u5child_5 ///
 R_Cen_u5child_6 R_Cen_u5child_7 R_Cen_u5child_8 R_Cen_u5child_9 R_Cen_u5child_10 R_Cen_u5child_11 ///
 R_Cen_u5child_12 R_Cen_u5child_13 R_Cen_u5child_14 R_Cen_u5child_15 R_Cen_u5child_16 R_Cen_u5child_17  
   
   
    
foreach x of  local childU5 {
	destring R_Cen_a6_hhmember_age_`i', gen(C_hhmember_age_`i')
	replace `x' = "" if R_Cen_a6_hhmember_age_`i' >= 5
    local ++i
}

/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id {
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
keep if unique_id_Unique!=1 //for ease of observation and analysis
duplicates report unique_id R_Cen_a1_resp_name


//keeping instance for IDs where consent was obtained
replace R_Cen_consent= 0 if R_Cen_consent==.
bys unique_id (R_Cen_consent): gen C_dup_by_consent= _n if R_Cen_consent[_n]!=R_Cen_consent[_n+1]
br unique_id_hyphen R_Cen_consent C_dup_by_consent
drop if R_Cen_consent==0 & C_dup_by_consent[_n]== 1 

//sorting and marking duplicate number by submission time 
bys unique_id (R_Cen_starttime): gen C_dup_tag= _n if R_Cen_consent==0

//Case 1-
gen C_new1= 1 if unique_id[_n]==unique_id[_n+1] & R_Cen_a1_resp_name[_n]!=R_Cen_a1_resp_name[_n+1] & R_Cen_a1_resp_name[_n]==""

//Case 2-
gen C_new2= 1 if unique_id[_n]==unique_id[_n+1] & R_Cen_a1_resp_name[_n]==R_Cen_a1_resp_name[_n+1] 

//Case 3- 
gen C_new3= 1 if unique_id[_n]==unique_id[_n+1] & R_Cen_a1_resp_name[_n]!=R_Cen_a1_resp_name[_n+1] & R_Cen_a1_resp_name[_n]!=""

tempfile dups
save `dups', replace

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
//submission time to be added Bys unique_id (submissiontime): gen
keep if C_new1==1 | C_new2==1 | C_new3==1
 capture export excel unique_id R_Cen_enum_name R_Cen_village_str R_Cen_submissiondate using "${pilot}Data_quality.xlsx" if unique_id_Unique!=1, sheet("Dup_ID_Census") ///
 firstrow(var) cell(A1) sheetreplace

***** Step 3: Creating new IDs for obvious duplicates; keeping the first ID based on the starttime and consent and changing the IDs of the remaining

use `dups', clear
keep if C_dup_by_consent==2 & R_Cen_consent==1
tempfile dups_part1
save `dups_part1', replace

use `dups', clear
keep if C_dup_tag==1
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

****Step 4: Appending files with unqiue IDs
use `working', clear
drop if unique_id_Unique!=1
append using `dups_part1', force
append using `dups_part2', force
append using `dups_part3', force
//also append file that comes corrected from the field

duplicates report unique_id //final check

drop unique_id_Unique 
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


*******Final variable creation for clean data

gen      C_HH_not_available=0
replace C_HH_not_available=1 if R_Cen_resp_available!=1
gen     C_Screened=.
replace C_Screened=1 if R_Cen_screen_u5child==1 | R_Cen_screen_preg==1
replace C_Screened=0 if R_Cen_resp_available==1 & C_Screened!=1

foreach i in R_Cen_consent R_Cen_instruction C_Screened {
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

save "${DataPre}1_1_Census_cleaned.dta", replace
*use "${DataPre}1_1_Census_cleaned.dta", clear
savesome using "${DataPre}1_1_Census_cleaned_consented.dta" if R_Cen_consent==1, replace

** Drop ID information

drop R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 R_Cen_a3_hhmember_name_2 R_Cen_a3_hhmember_name_3 R_Cen_a3_hhmember_name_4 R_Cen_a3_hhmember_name_5 R_Cen_a3_hhmember_name_6 R_Cen_a3_hhmember_name_7 R_Cen_a3_hhmember_name_8 R_Cen_a3_hhmember_name_9 R_Cen_a3_hhmember_name_10 R_Cen_a3_hhmember_name_11 R_Cen_a3_hhmember_name_12 R_Cen_namefromearlier_1 R_Cen_namefromearlier_2 R_Cen_namefromearlier_3 R_Cen_namefromearlier_4 R_Cen_namefromearlier_5 R_Cen_namefromearlier_6 R_Cen_namefromearlier_7 R_Cen_namefromearlier_8 R_Cen_namefromearlier_9 R_Cen_namefromearlier_10 R_Cen_namefromearlier_11 R_Cen_namefromearlier_12 
save "${DataDeid}1_1_Census_cleaned_noid.dta", replace



