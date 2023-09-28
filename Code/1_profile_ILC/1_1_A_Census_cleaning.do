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
//Renaming vars with prefix R_Cen
* Please do not change the location of this command: We do not want to change the name of variables
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
	keep if (R_Cen_day>19 & R_Cen_month_num>=9)

/*------------------------------------------------------------------------------
	2 Keeping relevant entries
------------------------------------------------------------------------------*/
* Akito->Michelle
* See: 2_1_Final_data.do (We are mostly keeping all the sample and do cleaning, after cleaning we drop sample depending on the need)
* This "dropping sample and creating data will happen in 2_1_Final_data.do"
/*/saving tempfile where HHs were screened out
preserve
keep if (screen_preg==0 & screen_u5child ==0) 
tempfile screened_out
save `screened_out', replace
restore */

* Akito->Michelle (Please look at Descriptve do file and everything document)
* Title: Overall statistics of recruitment and program registration
/*/counting those entries where there was a pregnant woman or child U5
count if (screen_preg==1 | screen_u5child ==1) 
//counting those entries where there was a pregnant woman or child U5, but consent was not given
count if (screen_preg==1 | screen_u5child ==1) & consent==0
*/

* Same withe line 39: For any dropping data,,,, please do not do here and there. Cleaning do file only do clean,,,, then sample selection happen in "2_1_Final_data.do"
/*/saving tempfile and dropping those entries where there was a pregnant woman or child U5 but consent was not given
preserve
keep if (screen_preg==1 | screen_u5child ==1) & consent==0
tempfile no_consent
save `no_consent', replace
restore
drop if (screen_preg==1 | screen_u5child ==1) & consent==0

//keeping those entries where there was a pregnant woman or child U5 and consent was obtained
keep if (screen_preg==1 | screen_u5child ==1)

tempfile working
save `working', replace
*/

/*------------------------------------------------------------------------------
	3 Basic cleaning
------------------------------------------------------------------------------*/
* I am not sure what this is doing (village vairiable label is already done by SurveyCTO do file)
* See the village appear as "pilot" rather than "88888"
/*/cleaning village names

clear
import excel using "${DataRaw}India_ILC_Pilot_Baseline Census_Master.xlsx", sheet("choices") firstrow allstring
keep if list_name=="village"
rename value village_name
drop list_name
keep village_name label
destring village_name, replace

tempfile villagename
save `villagename', replace
merge 1:m village_name using `working'
drop if _merge==1 //keeping only merged obs
rename label village_name_str
drop village_name _merge

save `working', replace
*/

*************************
* Cleaning the GPS data *
* Keeping the most reliable entry of GPS
*************************
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

/*------------------------------------------------------------------------------
	4 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}

***[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates
* Akito to Michelle: Do you want to code this later to flag similar samples (less priority)? 

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]

* Consider other variables to include when exporting duplicate IDs for checking
capture export excel unique_id using "${pilot}Data_quality.xlsx" if unique_id!=1, sheet("Dup_ID_Census") firstrow(var) cell(A1) sheetreplace
drop unique_id_Unique

***** Step 3: Please create the system to assign different ID if the HH is ovbiously different (Action point for Michelle)

* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)- not sure this is needed as long as ID is unique

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force

* Change as we finalzie the treatment village
save "${DataPre}1_1_Census_cleaned.dta", replace
savesome using "${DataPre}1_1_Census_cleaned_consented.dta" if R_Cen_consent==1, replace

** Drop ID information

save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
