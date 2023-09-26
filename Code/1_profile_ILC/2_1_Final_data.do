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
	
	* drop R_Cen_a40_gps_auto`i' R_Cen_a40_gps_manual`i'
}
drop R_Cen_a40_gps_autoaltitude R_Cen_a40_gps_manualaltitude


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
geoinpoly Pointgeolocationlat1 Pointgeolocationlon1 using "${Data_map}phxy"
keep if _ID!=.
* keep _ID Village Selected
drop pc11_tv_id
rename _ID pc11_tv_id
tostring pc11_tv_id, replace
save "${Data_map}Village_geo.dta", replace
*/

*********************************
* Household data for google map *
*********************************
use "${DataFinal}Final_HH_Odisha.dta", clear
keep unique_id R_Cen_a40_gps_latitude R_Cen_a40_gps_longitude
gen Type=1
save  "${DataDeid}1_1_Census_cleaned_noid_maplab.dta", replace
export excel using "${DataPre}Google_map.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)


cap program drop start_from_clean_file_Village
program define   start_from_clean_file_Village
  * Open clean file
use "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", clear
drop if Selected=="Backup"

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
  label var R_Cen_a2_hhmember_count "Household size" 
  
  * Akito to drop
	drop Treat_V
	gen  Treat_V=runiform(0,1)
	recode Treat_V 0/0.5=0 0.5/1=1
	save "${DataFinal}Final_HH_Odisha_consented_Full.dta", replace
 
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
start_from_clean_file_Village
