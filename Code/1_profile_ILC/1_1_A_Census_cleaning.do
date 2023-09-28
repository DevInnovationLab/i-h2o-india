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

use "${DataRaw}1_1_Census.dta", clear


putpdf begin
putpdf paragraph, font("Courier",20) halign(center)
putpdf text  ("Descriptive statistics for ILC Pilot") 
	

putpdf paragraph, font("Courier")
	
/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	*gen date = dofc(starttime)
	*format date %td
	
	gen day = day(dofc(starttime))
	gen month_num = month(dofc(starttime))
	
	//to change once survey date is fixed
	keep if (day>19 & month_num>=9)


/*------------------------------------------------------------------------------
	2 Keeping relevant entries
------------------------------------------------------------------------------*/
//saving tempfile where HHs were screened out
preserve
keep if (screen_preg==0 & screen_u5child ==0) 
tempfile screened_out
save `screened_out', replace
restore

//counting those entries where there was a pregnant woman or child U5
count if (screen_preg==1 | screen_u5child ==1) 
//counting those entries where there was a pregnant woman or child U5, but consent was not given
count if (screen_preg==1 | screen_u5child ==1) & consent==0

//saving tempfile and dropping those entries where there was a pregnant woman or child U5 but consent was not given
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

/*------------------------------------------------------------------------------
	3 Basic cleaning
------------------------------------------------------------------------------*/

//cleaning village names
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



//Renaming vars with prefix R_Cen

foreach x of var * {
	rename `x' R_Cen_`x'
}


save `working', replace

/*------------------------------------------------------------------------------
	4 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique

foreach i in R_Cen_unique_id {
bys `i': gen `i'_Unique=_N
}


***[For cases with duplicate ID:
***** Step 1: Check respondent names, phone numbers and address to see if there are similarities and drop obvious duplicates
***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]

* Consider other variables to include when exporting duplicate IDs for checking
capture export excel R_Cen_unique_id using "${pilot}Data_quality.xlsx" if R_Cen_unique_id!=1, sheet("Dup_ID_Census") firstrow(var) cell(A1) sheetreplace
drop R_Cen_unique_id_Unique





//2. Checking if respondent is the first member of the household in the roster
count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1


	*checking if the respondent name appears among other names in the roster
	preserve
	keep if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1
	reshape long R_Cen_a3_hhmember_name_, i(R_Cen_unique_id) j(num)
	count if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	br R_Cen_a3_hhmember_name_ R_Cen_a1_resp_name if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	* This means that the respondent exists in the roster but is not the first respondent so those cases don't need any change
	gen no_change= 1 if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name

	keep if R_Cen_a3_hhmember_name_== R_Cen_a1_resp_name
	keep R_Cen_a1_resp_name no_change R_Cen_unique_id
	tempfile resp_names
	save `resp_names', replace

	restore 


	* Fuzzy matching and then Manually fixing the remaining cases
	use `resp_names', clear
	merge 1:1 R_Cen_unique_id using `working'
	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1

	
	matchit R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 
	br R_Cen_a1_resp_name R_Cen_a3_hhmember_name_1 similscore if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)
	replace R_Cen_a1_resp_name=R_Cen_a3_hhmember_name_1 if (R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1)

	count if R_Cen_a1_resp_name!=R_Cen_a3_hhmember_name_1 & no_change!=1
	
	
//3. Checking if primary water source is not repeated as secondary water source

gen new=.
forvalues i = 1/8 {
	count if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1
	replace new= 1  if R_Cen_a12_water_source_prim==`i' & R_Cen_a13_water_source_sec_`i'==1

}

preserve
keep R_Cen_unique_id R_Cen_enum_name_label R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec_* new
export excel using "${pilot}Data_quality.xlsx" if new==1, sheet("prim_sec_source") firstrow(var) sheetreplace
restore


//4. Checking inconsistencies in age calculator

/*Note: For ages where the age of child is not equal to dob-calculated age, replace the dob-calculated age with a rounded value
Then, replace age in months and age in days for very small children with age in years (because otherwise, age for these children is recorded as 0)
Finally, replace self-reported age with rounded dob-calculated age where the "age is accurate" i.e checked against birth certificate or anganwaadi records
Then check if age matches dob-calculated age; in most cases it will match except maybe where age is imputed
*/

forvalues i = 1/9 {
	destring R_Cen_a5_autoage_`i', replace
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a5_autoage_`i'= ceil(R_Cen_a5_autoage_`i')
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/12 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==1
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/365 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==2
	replace R_Cen_a6_hhmember_age_`i'=R_Cen_a5_autoage_`i' if R_Cen_a6_hhmember_age_`i'!=R_Cen_a5_autoage_`i' & R_Cen_correct_age_`i'==1
}


/*------------------------------------------------------------------------------
	5 Descriptive Statistics
------------------------------------------------------------------------------*/

//1. Checking number of screened and screened out cases by enumerator

	*screened out
	use `screened_out', clear
	replace instruction=0 if screen_preg==0 & screen_u5child==0
	tab enum_name instruction
	*need to put table in overleaf
	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 1: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name instruction, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Screened_Out
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
*/

	*screened
	use `working', clear
	tab R_Cen_enum_name R_Cen_instruction
	*need to put table in overleaf
	
	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 2: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab R_Cen_enum_name R_Cen_instruction, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Screened and interview conducted
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
	*/
	

//2. Checking number of no-consent cases by enumerator and also the reason for no consent
	use `no_consent', clear
	replace no_consent_reason= "Lack of time" if no_consent_reason=="1"
	replace no_consent_reason= "Topic is not interesting to me" if no_consent_reason=="2"
	replace no_consent_reason= "Other" if no_consent_reason=="-77"
	tab enum_name consent
	tab enum_name no_consent_reason
	*need to put tables in overleaf

	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 3: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name consent, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Rejected
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
	
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 4: Rejection reason by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name consent, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Rejected reason
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
*/

//3. Checking time per section by enumerator
use `working', clear
***need to check with data that comes in on Friday because for the data submitted 25th Sept the duration function is not working


//4. % of HHs drinking JJM tap water
	gen household_num= 1
	egen total_hh= total(household_num)
	display total_hh
	local total_num_hhs = total_hh

	graph hbar (percent) household_num, over(R_Cen_a18_jjm_drinking, label) blabel(total) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_drinking_percentage.png, replace 
/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 1: Percentage of HHs drinking water from JJM taps") , bold
	putpdf image JJM_drinking_percentage.png, linebreak width(6) 
	
*/	


//5. % of HHs by different uses of JJM water
	gen household_num_JJMuses= 1 if R_Cen_a20_jjm_use!=""
	egen total_hh_JJMuses= total(household_num_JJMuses)
	local total_num_hhs_JJMuses = total_hh_JJMuses	
	        
	label variable R_Cen_a20_jjm_use_1 "Cooking"
	label variable R_Cen_a20_jjm_use_2 "Washing utensils"
	label variable R_Cen_a20_jjm_use_3 "Washing clothes"
	label variable R_Cen_a20_jjm_use_4 "Cleaning the house"
	label variable R_Cen_a20_jjm_use_5 "Bathing"
	label variable R_Cen_a20_jjm_use_6 "Drinking water for animals"
	label variable R_Cen_a20_jjm_use_7 "Irrigation"
	label variable R_Cen_a20_jjm_use__77 "Other"
	label variable R_Cen_a20_jjm_use_999 "Don't know"

	
	mrgraph hbar R_Cen_a20_jjm_use_1-R_Cen_a20_jjm_use_999, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs_JJMuses'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_uses.png, replace 

	
//6. % of HHs by different primary water sources
	gen prim_water_source=""
	
	//reducing length of labels
	replace prim_water_source= "JJM tap" if R_Cen_a12_water_source_prim==1
	replace prim_water_source= "Govt. provided community standpipe" if R_Cen_a12_water_source_prim==2
	replace prim_water_source= "Manual handpump" if R_Cen_a12_water_source_prim==4
	replace prim_water_source= "Surface water" if R_Cen_a12_water_source_prim==7

	graph hbar (percent) household_num, over(prim_water_source, label) blabel(total) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export Primary_water_source.png, replace 
/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 2: Primary drinking water source") , bold
	putpdf image Primary_water_source.png, linebreak width(6) 
*/	
	
//7. % of HHs by different secondary water sources
	gen household_num_secondarywater= 1 if R_Cen_a13_water_sec_yn==1
	egen total_hh_secondarywater= total(household_num_secondarywater)
	local total_num_hhs_secwater = total_hh_secondarywater
	
	label variable R_Cen_a13_water_source_sec_1 "JJM tap"
	label variable R_Cen_a13_water_source_sec_2 "Govt. provided community standpipe"
	label variable R_Cen_a13_water_source_sec_3 "GP/Other community standpipe"
	label variable R_Cen_a13_water_source_sec_4 "Manual handpump"
	label variable R_Cen_a13_water_source_sec_5 "Covered dug well"
	label variable R_Cen_a13_water_source_sec_6 "Uncovered dug well"
	label variable R_Cen_a13_water_source_sec_7 "Surface water"
	label variable R_Cen_a13_water_source_sec_8 "Private surface well"
	label variable R_Cen_a13_water_source_sec__77 "Other"

	
	mrgraph hbar R_Cen_a13_water_source_sec_1-R_Cen_a13_water_source_sec__77, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs_secwater'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export Secondary_water_source.png, replace 

	/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 3: Secondary drinking water source") , bold
	putpdf image Secondary_water_source.png, linebreak width(6) 
*/



//8. % of HHs by different water treatment methods
	        
	gen R_Cen_a16_water_treat_type_0= 1 if R_Cen_a16_water_treat==0

	label variable R_Cen_a16_water_treat_type_0 "No treatment"
	label variable R_Cen_a16_water_treat_type_1 "Filter through cloth/sieve" 
	label variable R_Cen_a16_water_treat_type_2 "Letting water stand" 
	label variable R_Cen_a16_water_treat_type_3 "Boiling" 
	label variable R_Cen_a16_water_treat_type_4 "Adding chlorine/bleaching powder" 
	label variable R_Cen_a16_water_treat_type__77 "Other"
	label variable R_Cen_a16_water_treat_type_999 "Don't know"


	order R_Cen_a16_water_treat_type_0 R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 ///
	R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type_999 R_Cen_a16_water_treat_type__77
	mrgraph hbar R_Cen_a16_water_treat_type_0-R_Cen_a16_water_treat_type__77, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_uses.png, replace 

* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)- not sure this is needed as long as ID is unique

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force

* Change as we finalzie the treatment village
gen     Census=1
save "${DataPre}1_1_Census_cleaned.dta", replace
savesome using "${DataPre}1_1_Census_cleaned_consented.dta" if R_Cen_consent==1, replace

** Drop ID information

save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
