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

*------------------------------------------------------------ Final data creation ------------------------------------------------------------*
use "${DataDeid}1_1_Census_cleaned_noid.dta", clear
* Merge follow up and other data sets
merge 1:1 unique_id using "${DataDeid}1_2_Followup_cleaned.dta",gen(Merge_C_F)

*****************
* Quality check *
*****************
* There should be no using data
capture export excel unique_id using "${pilot}Data_quality.xlsx" if Merge_C_F==2, sheet("Merge_C_F_2") firstrow(var) cell(A1) sheetreplace
drop if Merge_C_F==2

*************************
* Cleaning the GPS data *
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

************
* Labeling *
************
destring R_Cen_a12_water_source_prim, replace
	label define R_Cen_a12_water_source_priml 1 "PWS: JJM Taps" 2 "PWS: Community standpipe" 3 "PWS: Manual handpump", modify
	label values R_Cen_a12_water_source_prim R_Cen_a12_water_source_priml
	label define R_Cen_a13_water_sec_ynl 0 "SWS: No" 1 "SWS: Yes", modify
	label values R_Cen_a13_water_sec_yn R_Cen_a13_water_sec_ynl
	label define R_Cen_a16_water_treatl 0 "WT: No" 1 "WT: Yes", modify
	label values R_Cen_a16_water_treat R_Cen_a16_water_treatl
	label define R_Cen_a15_water_sec_freql 2 "Freq: Every 2-3 days in a week" 5 "Freq: Once a month", modify
	label values R_Cen_a15_water_sec_freq R_Cen_a15_water_sec_freql	

* Create Dummy
	foreach v in R_Cen_a10_hhhead_gender R_Cen_a12_water_source_prim R_Cen_a16_water_treat R_Cen_a13_water_sec_yn R_Cen_a15_water_sec_freq {
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

save "${DataFinal}Final_HH_Odisha_consented.dta", replace
*------------------------------------------------------------ Final data creation (END)-----------------------------------------------------------*

* Sample size=ANC contact list
cap program drop start_from_clean_file_Census
program define   start_from_clean_file_Census
  * Open clean file
  use                       "${DataFinal}Final_HH_Odisha_consented.dta", clear
  label var R_Cen_a2_hhmember_count "Household size"
  
end

* Follow up
cap program drop start_from_clean_file_Follow
program define   start_from_clean_file_Follow
  * Open clean file
  start_from_clean_file_Census
  
  * Followed up and consented
  keep if Merge_C_F==3
  keep if R_FU_consent==1
  
end


start_from_clean_file_Census
start_from_clean_file_Follow
