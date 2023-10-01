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

use "${DataPre}1_1_Census_cleaned.dta", clear
* Merge follow up and other data sets
merge 1:1 unique_id_num using "${DataDeid}1_2_Followup_cleaned.dta",gen(Merge_C_F)

*****************
* Quality check *
*****************
* There should be no using data
capture export excel unique_id using "${pilot}Data_quality_`date'.xlsx" if Merge_C_F==2, sheet("Merge_C_F_2") firstrow(var) cell(A1) sheetreplace
drop if Merge_C_F==2


//4. Checking inconsistencies in age calculator
/*Note: For ages where the age of child is not equal to dob-calculated age, replace the dob-calculated age with a rounded value
Then, replace age in months and age in days for very small children with age in years (because otherwise, age for these children is recorded as 0)
Finally, replace self-reported age with rounded dob-calculated age where the "age is accurate" i.e checked against birth certificate or anganwaadi records
Then check if age matches dob-calculated age; in most cases it will match except maybe where age is imputed
*/


forvalues i = 1/12 {
	destring R_Cen_a5_autoage_`i', replace
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a5_autoage_`i'= ceil(R_Cen_a5_autoage_`i')
	count if R_Cen_a6_hhmember_age_`i'!= R_Cen_a5_autoage_`i' & R_Cen_a5_autoage_`i'!=.
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/12 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==1
	replace R_Cen_a6_hhmember_age_`i' = R_Cen_a6_u1age_`i'/365 if R_Cen_a6_u1age_`i'!=. & R_Cen_unit_age_`i'==2
	replace R_Cen_a6_hhmember_age_`i'=R_Cen_a5_autoage_`i' if R_Cen_a6_hhmember_age_`i'!=R_Cen_a5_autoage_`i' & R_Cen_correct_age_`i'==1
}

************
* Labeling *
************
destring R_Cen_a12_water_source_prim, replace
	label define R_Cen_a12_water_source_priml 1 "PWS: JJM Taps" 2 "PWS: Govt. provided Community standpipe" 4 "PWS: Manual handpump" 8 "PWS: Private surface well" ///
	-77 "PWS: Other", modify
	label values R_Cen_a12_water_source_prim R_Cen_a12_water_source_priml
	label define R_Cen_a13_water_sec_ynl 0 "SWS: No" 1 "SWS: Yes", modify
	label values R_Cen_a13_water_sec_yn R_Cen_a13_water_sec_ynl
	label define R_Cen_a16_water_treatl 0 "WT: No" 1 "WT: Yes", modify
	label values R_Cen_a16_water_treat R_Cen_a16_water_treatl
	label define R_Cen_a15_water_sec_freql 1 "Freq :Daily" 2 "Freq : Every 2-3 days in a week" 3 "Freq : Once a week" 4 "Freq : Once every two weeks" ///
	5 "Freq : Once a month" 6 "Freq :Once every few months" 7 "Freq : Once a year" 8 "Freq :No fixed schedule" 999 "Freq : Don't know", modify
	

	label values R_Cen_a15_water_sec_freq R_Cen_a15_water_sec_freql	
	

	 label var R_Cen_a2_hhmember_count "Household size" 
  
  	label variable R_Cen_a20_jjm_use_1 "Cooking"
	label variable R_Cen_a20_jjm_use_2 "Washing utensils"
	label variable R_Cen_a20_jjm_use_3 "Washing clothes"
	label variable R_Cen_a20_jjm_use_4 "Cleaning the house"
	label variable R_Cen_a20_jjm_use_5 "Bathing"
	label variable R_Cen_a20_jjm_use_6 "Drinking water for animals"
	label variable R_Cen_a20_jjm_use_7 "Irrigation"
	label variable R_Cen_a20_jjm_use__77 "Other"
	label variable R_Cen_a20_jjm_use_999 "Don't know"
	
	label variable R_Cen_a18_jjm_drinking "Drink JJM water"
   
   label variable R_Cen_a13_water_source_sec_1 "JJM tap"
	label variable R_Cen_a13_water_source_sec_2 "Govt. provided community standpipe"
	label variable R_Cen_a13_water_source_sec_3 "GP/Other community standpipe"
	label variable R_Cen_a13_water_source_sec_4 "Manual handpump"
	label variable R_Cen_a13_water_source_sec_5 "Covered dug well"
	label variable R_Cen_a13_water_source_sec_6 "Uncovered dug well"
	label variable R_Cen_a13_water_source_sec_7 "Surface water"
	label variable R_Cen_a13_water_source_sec_8 "Private surface well"
	label variable R_Cen_a13_water_source_sec__77 "Other"

	label variable R_Cen_a16_water_treat_type_1 "Filter through cloth/sieve" 
	label variable R_Cen_a16_water_treat_type_2 "Letting water stand" 
	label variable R_Cen_a16_water_treat_type_3 "Boiling" 
	label variable R_Cen_a16_water_treat_type_4 "Adding chlorine/bleaching powder" 
	label variable R_Cen_a16_water_treat_type__77 "Other"
	label variable R_Cen_a16_water_treat_type_999 "Don't know"

* Create Dummy
* -77 to 77
foreach i in R_Cen_a12_water_source_prim  {
	replace `i'=77 if `i'==-77
}
* -99 to 99
foreach i in R_Cen_a13_water_sec_yn {
	replace `i'=99 if `i'==-99
}
	rename R_Cen_a12_water_source_prim R_Cen_a12_ws_prim
	
	foreach i in 1 2 3 4 5 6 7 8 _77 {
		rename R_Cen_a13_water_source_sec_`i' R_Cen_a13_ws_sec_`i'
	}
	
	foreach v in R_Cen_a10_hhhead_gender R_Cen_a12_ws_prim R_Cen_a16_water_treat R_Cen_a13_water_sec_yn R_Cen_a15_water_sec_freq {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

* Save final data in STATA/R
save "${DataFinal}Final_HH_Odisha.dta", replace
keep if R_Cen_consent==1

  
  * Temporal treatment status
	gen     Treat_V=.
	replace Treat_V=1 if R_Cen_village_name==40201
	replace Treat_V=0 if R_Cen_village_name==50301 | R_Cen_village_name==50501
	save "${DataFinal}Final_HH_Odisha_consented_Full.dta", replace

save "${DataFinal}Final_HH_Odisha_consented.dta", replace

/* Village shape file with geo code
use "${Data_map}phdb.dta",clear
drop if pc11_tv_id=="000000"
keep if pc11_s_id=="21" // Odisha
keep if pc11_d_id=="396" | pc11_d_id=="397" | pc11_d_id=="398" 
gen    Selected_b=0
foreach i in 03196 03197 03198 03199 03200 03201 03202 03204 03205 03207 03176 {
replace Selected_b=1 if pc11_sd_id=="`i'"
}
encode pc11_sd_id, gen(pc11_sd_id_num)
keep if Selected_b==1
append using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", 
geoinpoly Pointgeolocationlat1 Pointgeolocationlon1 using "${Data_map}phxy", inside
keep if _ID!=.
keep _ID Village Selected village
save "${Data_map}Village_geo.dta", replace
*/

*********************************
* Household data for google map *
*********************************
use "${DataFinal}Final_HH_Odisha.dta", clear
drop if R_Cen_village_name==88888
keep unique_id R_Cen_a40_gps_latitude R_Cen_a40_gps_longitude R_Cen_village_name
keep if R_Cen_a40_gps_latitude!=.
gen Type=1
* Adding tank
append using "${DataFinal}90_Village_Geo.dta"
replace Type=30 if unique_id=="Tank"
replace Type=31 if unique_id=="Anganwadi center"
save  "${DataDeid}1_1_Census_cleaned_noid_maplab.dta", replace
export excel using "${DataPre}Google_map.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1) keepcellfmt 

*------------------------------------------------------------ Final data creation ------------------------------------------------------------*
cap program drop start_from_clean_file_Population
program define   start_from_clean_file_Population
  * Open clean file
use "${DataPre}1_1_Census_cleaned.dta", clear
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) keepusing(unique_id Merge_C_F R_FU_consent)

drop if R_Cen_village_name==88888
* Temporal treatment status
	gen     Treat_V=.
	replace Treat_V=1 if R_Cen_village_name==40201
	replace Treat_V=0 if R_Cen_village_name==50301 | R_Cen_village_name==50501

gen     C_Screened=0
replace C_Screened=1 if R_Cen_screen_u5child==1 | R_Cen_screen_preg==1

recode Merge_C_F 1=0 3=1
foreach i in R_Cen_consent R_FU_consent R_Cen_instruction {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}

end

cap program drop start_from_clean_file_Village
program define   start_from_clean_file_Village
  * Open clean file
use "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", clear
egen km_block=rowmin(km_Rayagada km_Kolnara km_Gunupur km_Gudari km_Padmapur) 
label var km_block "Distance to closest block HQ (km)"

drop if Selected=="Backup"

* Labeling
destring village V_Num_HH, replace
label var V_Num_HH "Number of HH in the village"
label define BlockCodel 1 "BLOCK: Gudari"2 "BLOCK: Gunupur" 3 "BLOCK: Kolnara" 4 "BLOCK: Padmapur" 5 "BLOCK: Rayagada", modify
label values BlockCode BlockCodel

xtile  V_Num_HH_Categ = V_Num_HH, nq(3)
label define V_Num_HH_Categl 1 "VSize: Small"2 "VSize: Meduium" 3 "VSize: Large", modify
label values V_Num_HH_Categ V_Num_HH_Categl

* Create Dummy
	foreach v in BlockCode V_Num_HH_Categ {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean_final.dta", replace
  
end

* Sample size=Number of HH
cap program drop start_from_clean_file_Census
program define   start_from_clean_file_Census
  * Open clean file

  use                       "${DataFinal}Final_HH_Odisha_consented.dta", clear
  drop if R_Cen_village_name==88888
  label var R_Cen_a2_hhmember_count "Household size" 
  
end

/*
* Follow up
cap program drop start_from_clean_file_Follow
program define   start_from_clean_file_Follow
  * Open clean file
  start_from_clean_file_Census
  
  * Followed up and consented
  keep if Merge_C_F==3
  keep if R_FU_consent==1
  
end
*/

start_from_clean_file_Census
*start_from_clean_file_Follow
start_from_clean_file_Village
start_from_clean_file_Population
