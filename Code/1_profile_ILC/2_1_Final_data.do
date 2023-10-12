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
	
* File name: ${DataFinal}Final_HH_Odisha_consented_Full.dta", clear
* This is the final data where it contains all the census and follow up variable
* N=HH with the Census consented

use "${DataPre}1_1_Census_cleaned.dta", clear
drop _merge
merge 1:1 unique_id_num using "${DataDeid}1_2_Followup_cleaned.dta",gen(Merge_C_F)

*****************
* Quality check *
*****************

/*	
* There should be no using data
capture export excel unique_id using "${pilot}Data_quality.xlsx" if Merge_C_F==2, sheet("Merge_C_F_2") firstrow(var) cell(A1) sheetreplace
drop if Merge_C_F==2
*/

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



foreach i in R_FU_consent {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}



************************************
*  Create new variables *
************************************

* -77 to 77
foreach i in R_Cen_a12_water_source_prim  {
	replace `i'=77 if `i'==-77
}
* -99 to 99
foreach i in R_Cen_a13_water_sec_yn R_Cen_a18_jjm_drinking {
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
	
* Replacing missing value
gen     C_Cen_a18_jjm_drinking=R_Cen_a18_jjm_drinking
* Do not know
replace C_Cen_a18_jjm_drinking=. if C_Cen_a18_jjm_drinking==99
* Do not have a government tap connection
replace C_Cen_a18_jjm_drinking=. if C_Cen_a18_jjm_drinking==2

//number of pregnant women
forvalues i = 1/17 {
	gen C_total_pregnant_`i'= 1 if R_Cen_a7_pregnant_`i'==1
}
egen      C_total_pregnant_hh = rowtotal(C_total_pregnant_*)
label var C_total_pregnant_hh "Number of pregnant women" 
	
//number of children under 5
forvalues i = 1/17 {
	gen C_U5child_`i'= 1 if R_Cen_a6_hhmember_age_`i'<5

}
egen      C_total_U5child_hh = rowtotal(C_U5child_*)


************
* Labeling *
************
destring R_Cen_a12_ws_prim, replace
	label define R_Cen_a12_ws_priml 1 "PWS: JJM Taps" 2 "PWS: Govt. community standpipe" 3 "PWS: GP/Other community standpipe" 4 "PWS: Manual handpump" 7 "PWS: Surface water" 8 "PWS: Private surface well" 77 "PWS: Other", modify
	label values R_Cen_a12_ws_prim R_Cen_a12_ws_priml
	label define R_Cen_a13_water_sec_ynl 0 "SWS: No secondary water source" 1 "SWS: Yes", modify
	label values R_Cen_a13_water_sec_yn R_Cen_a13_water_sec_ynl
	label define R_Cen_a16_water_treatl 0 "WT: No water treatment" 1 "WT: Yes", modify
	label values R_Cen_a16_water_treat R_Cen_a16_water_treatl
	label define R_Cen_a15_water_sec_freql 1 "Freq: Daily" 2 "Freq: Every 2-3 days in a week" 3 "Freq: Once a week" 4 "Freq: Once every two weeks" ///
	5 "Freq: Once a month" 6 "Freq: Once every few months" 7 "Freq: Once a year" 8 "Freq: No fixed schedule" 999 "Freq: Don't know", modify
	
	label values R_Cen_a15_water_sec_freq R_Cen_a15_water_sec_freql	

	label var C_total_U5child_hh "Number of U5 children" 
	label variable R_Cen_a2_hhmember_count "Household size" 
  	label variable R_Cen_a20_jjm_use_1 "Cooking"
	label variable R_Cen_a20_jjm_use_2 "Washing utensils"
	label variable R_Cen_a20_jjm_use_3 "Washing clothes"
	label variable R_Cen_a20_jjm_use_4 "Cleaning the house"
	label variable R_Cen_a20_jjm_use_5 "Bathing"
	label variable R_Cen_a20_jjm_use_6 "Drinking water for animals"
	label variable R_Cen_a20_jjm_use_7 "Irrigation"
	label variable R_Cen_a20_jjm_use__77 "Other"
	label variable R_Cen_a20_jjm_use_999 "Don't know"
	
	label variable R_Cen_a18_jjm_drinking "Drink JJM water (Do not use this variable)"
	label variable C_Cen_a18_jjm_drinking "Drink JJM water"
	
	
    label var R_Cen_a13_water_sec_yn_0 "No secondary source"
    label variable R_Cen_a13_ws_sec_1 "JJM tap"
	label variable R_Cen_a13_ws_sec_2 "Govt. provided community standpipe"
	label variable R_Cen_a13_ws_sec_3 "GP/Other community standpipe"
	label variable R_Cen_a13_ws_sec_4 "Manual handpump"
	label variable R_Cen_a13_ws_sec_5 "Covered dug well"
	label variable R_Cen_a13_ws_sec_6 "Uncovered dug well"
	label variable R_Cen_a13_ws_sec_7 "Surface water"
	label variable R_Cen_a13_ws_sec_8 "Private surface well"
	label variable R_Cen_a13_ws_sec__77 "Other"
	
	label var R_Cen_a12_ws_prim_1 "JJM tap" 
	label var R_Cen_a12_ws_prim_2 "Govt. provided community standpipe"
	label var R_Cen_a12_ws_prim_3 "GP/Other community standpipe"
	label var R_Cen_a12_ws_prim_4 "Manual handpump"
	label var R_Cen_a12_ws_prim_5 "Covered dug well"
	label var R_Cen_a12_ws_prim_6 "Uncovered dug well"
	label var R_Cen_a12_ws_prim_7 "Surface water"
	label var R_Cen_a12_ws_prim_8 "Private surface well" 
	label var R_Cen_a12_ws_prim_77 "Other"

	label var R_Cen_a16_water_treat_0 "No water treatment"
	label variable R_Cen_a16_water_treat_type_1 "Filter through cloth/sieve" 
	label variable R_Cen_a16_water_treat_type_2 "Letting water stand" 
	label variable R_Cen_a16_water_treat_type_3 "Boiling" 
	label variable R_Cen_a16_water_treat_type_4 "Adding chlorine/bleaching powder" 
	label variable R_Cen_a16_water_treat_type__77 "Other"
	label variable R_Cen_a16_water_treat_type_999 "Don't know"

	label var R_Cen_water_treat_kids_type_1 "Filter through cloth/sieve" 
	label var R_Cen_water_treat_kids_type_2 "Letting water stand" 
	label var R_Cen_water_treat_kids_type_3 "Boiling" 
	label var R_Cen_water_treat_kids_type_4 "Adding chlorine/bleaching powder"
	rename R_Cen_water_treat_kids_type__77 R_Cen_water_treat_kids_type77
	rename R_Cen_water_treat_kids_type_999 R_Cen_water_treat_kids_type99
	label var R_Cen_water_treat_kids_type77 "Other" 
	label var R_Cen_water_treat_kids_type99 "Don't know"
	
	label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	

*******************************************
* Capturing correct section-wise duration
*******************************************
local duration R_Cen_survey_duration R_Cen_intro_dur_end R_Cen_consent_dur_end R_Cen_sectionb_dur_end R_Cen_sectionc_dur_end R_Cen_sectiond_dur_end R_Cen_sectione_dur_end R_Cen_sectionf_dur_end R_Cen_sectiong_dur_end R_Cen_sectionh_dur_end 

foreach x of local duration  {
	replace `x'= `x'/60 if R_Cen_consent==1
	replace `x'= . if R_Cen_consent!=1 
	
}


replace R_Cen_sectione_dur_end= . if C_total_pregnant_hh==0
replace R_Cen_sectionf_dur_end= . if C_total_U5child_hh==0


gen intro_duration= R_Cen_intro_dur_end
gen consent_duration= R_Cen_consent_dur_end-R_Cen_intro_dur_end
gen sectionB_duration= R_Cen_sectionb_dur_end-R_Cen_consent_dur_end
gen sectionC_duration= R_Cen_sectionc_dur_end-R_Cen_sectionb_dur_end
gen sectionD_duration= R_Cen_sectiond_dur_end-R_Cen_sectionc_dur_end
gen sectionE_duration= R_Cen_sectione_dur_end-R_Cen_sectiond_dur_end
gen sectionF_duration= R_Cen_sectionf_dur_end-R_Cen_sectione_dur_end
gen sectionG_duration= R_Cen_sectiong_dur_end-R_Cen_sectionf_dur_end
gen sectionH_duration= R_Cen_sectionh_dur_end-R_Cen_sectiong_dur_end


replace consent_duration=. if consent_duration==0
replace sectionH_duration=. if sectionH_duration<0
local duration2 intro_duration consent_duration sectionB_duration sectionC_duration sectionD_duration sectionE_duration sectionF_duration sectionG_duration sectionH_duration

foreach x of local duration2  {
	sum `x'
	replace `x'=. if `x'<0
	sum `x'
}

egen survey_time= rowtotal(intro_duration consent_duration sectionB_duration sectionC_duration sectionD_duration sectionE_duration sectionF_duration sectionG_duration sectionH_duration)


local duration3 intro_duration consent_duration sectionB_duration sectionC_duration sectionD_duration sectionE_duration sectionF_duration sectionG_duration sectionH_duration survey_time

foreach x of local duration3  {
	rename `x' R_Cen_`x'
}

	
	label var R_Cen_survey_time "Survey duration"
	label var R_Cen_intro_duration "Intro duration"
	label var R_Cen_consent_duration "Consent duration"
	label var R_Cen_sectionB_duration "HH demographics duration"
	label var R_Cen_sectionC_duration "Water section duration"
	label var R_Cen_sectionD_duration "JJM tap section duration"
	label var R_Cen_sectionE_duration "Resp. health section duration"
	label var R_Cen_sectionF_duration "Child health section duration"
	label var R_Cen_sectionG_duration "Assets section duration"
	label var R_Cen_sectionH_duration "Concluding section duration"

* Save final data in STATA/R
save "${DataFinal}Final_HH_Odisha.dta", replace
keep if R_Cen_consent==1
  
* Temporal treatment status
rename R_Cen_village_name village
merge m:1 village using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", keepusing(Treat_V)
drop if _merge==2
drop _merge
rename village R_Cen_village_name
save "${DataFinal}Final_HH_Odisha_consented_Full.dta", replace

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
use  "${DataPre}1_1_Census_cleaned.dta", clear
gen     C_Census=1
merge 1:1 unique_id using "${DataFinal}Final_HH_Odisha_consented_Full.dta", gen(Merge_consented) ///
          keepusing(unique_id Merge_C_F R_FU_consent R_Cen_survey_duration R_Cen_intro_duration R_Cen_consent_duration R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration R_Cen_survey_time R_Cen_a12_ws_prim)

drop if R_Cen_village_name==88888
* Temporal treatment status
	gen     Treat_V=.
	replace Treat_V=1 if R_Cen_village_name==50101 | R_Cen_village_name==50401 | R_Cen_village_name==50402 | R_Cen_village_name==50601 
	replace Treat_V=0 if R_Cen_village_name==50201 | R_Cen_village_name==50301 | R_Cen_village_name==50501 
	
recode Merge_C_F 1=0 3=1


label var C_Screened  "Screened"
	label variable R_Cen_consent "Census consent"
	label variable R_FU_consent "HH survey consent"
	label var Non_R_Cen_consent "Refused"
	label var C_HH_not_available "Respondent not available"
	label var R_Cen_survey_time "Survey duration"
	label var R_Cen_intro_duration "Intro duration"
	label var R_Cen_consent_duration "Consent duration"
	label var R_Cen_sectionB_duration "HH demographics duration"
	label var R_Cen_sectionC_duration "Water section duration"
	label var R_Cen_sectionD_duration "JJM tap section duration"
	label var R_Cen_sectionE_duration "Resp. health section duration"
	label var R_Cen_sectionF_duration "Child health section duration"
	label var R_Cen_sectionG_duration "Assets section duration"
	label var R_Cen_sectionH_duration "Concluding section duration"

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

  use                       "${DataFinal}Final_HH_Odisha_consented_Full.dta", clear
  drop if R_Cen_village_name==88888
  label var R_Cen_a2_hhmember_count "Household size" 
  
end

* Sample size=Number of HH
cap program drop start_from_clean_file_Preglevel
program define   start_from_clean_file_Preglevel
  * Open clean file
  start_from_clean_file_Census
  
keep R_Cen_a29_wom_diarr*  unique_id* C_total_pregnant_hh
reshape long R_Cen_a23_wom_diarr_day_ R_Cen_a23_wom_diarr_week_ R_Cen_a23_wom_diarr_2week_, i(unique_id) j(num)
* Drop missing
end



* Sample size=Number of HH
cap program drop start_from_clean_file_ChildLevel
program define   start_from_clean_file_ChildLevel
  * Open clean file
start_from_clean_file_Census  
keep R_Cen_a29_child_diarr*  unique_id* C_total_U5child_hh Treat_V  R_Cen_village_name R_Cen_a31_child_stool*
reshape long R_Cen_a29_child_diarr_week_ R_Cen_a29_child_diarr_day_ R_Cen_a29_child_diarr_2week_ ///
         R_Cen_a31_child_stool_24h_ R_Cen_a31_child_stool_yest_ R_Cen_a31_child_stool_week_ R_Cen_a31_child_stool_2week_, i(unique_id) j(num)
* Drop the case where there is no children
drop if R_Cen_a29_child_diarr_day_==. & R_Cen_a29_child_diarr_week_==. & R_Cen_a29_child_diarr_2week_==.
* Data quality: Michelle (sometimes they fill the child child diarrhea info although C_total_U5child_hh=0?)
drop if C_total_U5child_hh==0

* Creating diarrhea vars
gen     C_diarrhea_prev_child_1week=0
replace C_diarrhea_prev_child_1week=1  if (R_Cen_a29_child_diarr_day_==1 | R_Cen_a29_child_diarr_week_==1)
gen     C_diarrhea_prev_child_2weeks=0
replace C_diarrhea_prev_child_2weeks=1 if (R_Cen_a29_child_diarr_day_==1 | R_Cen_a29_child_diarr_week_==1 | R_Cen_a29_child_diarr_2week_==1) 

*Using loose & watery stool vars
gen     C_loosestool_child_1week=0
replace C_loosestool_child_1week=1 if (R_Cen_a31_child_stool_24h_==1 | R_Cen_a31_child_stool_yest_==1 | R_Cen_a31_child_stool_week_==1) 
gen     C_loosestool_child_2weeks=0
replace C_loosestool_child_2weeks=1 if (R_Cen_a31_child_stool_24h_==1 | R_Cen_a31_child_stool_yest_==1 | R_Cen_a31_child_stool_week_==1 | R_Cen_a31_child_stool_2week_==1)

*generating new vars using both vars for diarrhea
gen    C_diarrhea_comb_U5_1week=0
replace C_diarrhea_comb_U5_1week=1 if C_diarrhea_prev_child_1week==1 | C_loosestool_child_1week==1

gen    C_diarrhea_comb_U5_2weeks=0
replace C_diarrhea_comb_U5_2weeks=1 if C_diarrhea_prev_child_2weeks==1 | C_loosestool_child_2weeks==1

label var C_diarrhea_prev_child_1week "Diarrhea- U5 (1 week)" 
label var C_diarrhea_prev_child_2weeks "Diarrhea- U5 (2 weeks)" 
label var C_loosestool_child_1week "Loose stool- U5 (1 week)" 
label var C_loosestool_child_2weeks "Loose stool- U5 (2 weeks)" 

label var C_diarrhea_comb_U5_1week "Diarrhea/Loose- U5 (1 week)" 
label var C_diarrhea_comb_U5_2weeks "Diarrhea/Loose- U5 (2 weeks)" 

/*

*Baseline diarrhea incidence for children 
reshape long R_Cen_a29_child_diarr_day_ R_Cen_a29_child_diarr_week_ R_Cen_a29_child_diarr_2week_ R_Cen_a31_child_stool_24h_ R_Cen_a31_child_stool_yest_ R_Cen_a31_child_stool_week_ R_Cen_a31_child_stool_2week_ C_U5child_, i(unique_id) j(num)

*Using diarrhea vars
gen diarrhea_prev_child_2weeks=1 if (R_Cen_a29_child_diarr_day_==1 | R_Cen_a29_child_diarr_week_==1 | R_Cen_a29_child_diarr_2week_==1) & C_total_U5child_hh>0
gen diarrhea_prev_child_1week= 1 if (R_Cen_a29_child_diarr_day_==1 | R_Cen_a29_child_diarr_week_==1) & C_total_U5child_hh>0

* dropping irrelevant vars
drop C_U5child_ R_Cen_a29_child_diarr_2week_ R_Cen_a29_child_diarr_week_ R_Cen_a29_child_diarr_day_ diarrhea_prev_child_2weeks diarrhea_prev_child_1week R_Cen_a31_child_stool_24h_ R_Cen_a31_child_stool_yest_ R_Cen_a31_child_stool_week_ R_Cen_a31_child_stool_2week_ loosestool_child_2weeks loosestool_child_1week

*reshaping the data back to wide
reshape wide total_childrenu5  total_diarrheacases_U5_2weeks total_diarrheacases_U5_1week diarrhea_child_perc_2weeks diarrhea_child_perc_1week total_loosestool_U5_2weeks total_loosestool_U5_1week loosestool_child_perc_2weeks loosestool_child_perc_1week, i(unique_id) j(num)

* final vars creation for use later
egen sum_diarrhea_child_1week = rowtotal(diarrhea_child_perc_1week*)
gen avg_diarrhea_child_1week = sum_diarrhea_child_1week/18
egen sum_loosestool_child_1week = rowtotal(loosestool_child_perc_1week*)
gen avg_loosestool_child_1week = sum_loosestool_child_1week/18

egen sum_diarrhea_child_2weeks = rowtotal(diarrhea_child_perc_2weeks*)
gen avg_diarrhea_child_2weeks = sum_diarrhea_child_2weeks/18
egen sum_loosestool_child_2weeks = rowtotal(loosestool_child_perc_2weeks*)
gen avg_loosestool_child_2weeks = sum_loosestool_child_2weeks/18

drop diarrhea_child_perc_1week* diarrhea_child_perc_2weeks* loosestool_child_perc_1week* loosestool_child_perc_2weeks*

label var avg_loosestool_child_1week "Loose stool- U5 (1 week)" 
label var avg_loosestool_child_2weeks "Loose stool- U5 (2 weeks)" 
label var C_total_U5child_hh "Average U5 children"
label var total_childrenu51 "Total U5 children"

//Baseline diarrhea incidence for pregnant women 
reshape long R_Cen_a23_wom_diarr_day_ R_Cen_a23_wom_diarr_week_ R_Cen_a23_wom_diarr_2week_ R_Cen_a7_pregnant_ R_Cen_a25_wom_stool_24h_ R_Cen_a25_wom_stool_yest_ R_Cen_a25_wom_stool_week_ R_Cen_a25_wom_stool_2week_, i(unique_id) j(num)

*Using diarrhea vars
gen diarrhea_prev_woman_2weeks=1 if (R_Cen_a23_wom_diarr_day_==1 | R_Cen_a23_wom_diarr_week_==1 | R_Cen_a23_wom_diarr_2week_==1) & C_total_pregnant_hh>0
gen diarrhea_prev_woman_1week= 1 if (R_Cen_a23_wom_diarr_day_==1 | R_Cen_a23_wom_diarr_week_==1) & C_total_pregnant_hh>0

*Using loose & watery stool vars
gen loosestool_woman_2weeks=1 if (R_Cen_a25_wom_stool_24h_==1 | R_Cen_a25_wom_stool_yest_==1 | R_Cen_a25_wom_stool_week_==1 | R_Cen_a25_wom_stool_2week_==1) & C_total_pregnant_hh>0
gen loosestool_woman_1week= 1 if (R_Cen_a25_wom_stool_24h_==1 | R_Cen_a25_wom_stool_yest_==1 | R_Cen_a25_wom_stool_week_==1) & C_total_pregnant_hh>0

*generating new vars using both vars for diarrhea
egen total_pregwoman= total(R_Cen_a7_pregnant_) if C_total_pregnant_hh>0
egen total_diarrhea_preg_2weeks= total(diarrhea_prev_woman_2weeks) if C_total_pregnant_hh>0
egen total_diarrhea_preg_1week= total(diarrhea_prev_woman_1week) if C_total_pregnant_hh>0
gen diarrhea_woman_perc_2weeks= total_diarrhea_preg_2weeks/total_pregwoman if C_total_pregnant_hh>0
gen diarrhea_woman_perc_1week= total_diarrhea_preg_1week/total_pregwoman if C_total_pregnant_hh>0

egen total_loosestool_preg_2weeks= total(loosestool_woman_2weeks) if C_total_pregnant_hh>0
egen total_loosestool_preg_1week= total(loosestool_woman_1week) if C_total_pregnant_hh>0
gen loosestool_woman_perc_2weeks= total_loosestool_preg_2weeks/total_pregwoman if C_total_pregnant_hh>0
gen loosestool_woman_perc_1week= total_loosestool_preg_1week/total_pregwoman if C_total_pregnant_hh>0

* dropping irrelevant vars
drop R_Cen_a7_pregnant_ R_Cen_a23_wom_diarr_day_ R_Cen_a23_wom_diarr_week_ R_Cen_a23_wom_diarr_2week_ diarrhea_prev_woman_2weeks diarrhea_prev_woman_1week R_Cen_a25_wom_stool_24h_ R_Cen_a25_wom_stool_yest_ R_Cen_a25_wom_stool_week_ R_Cen_a25_wom_stool_2week_ loosestool_woman_2weeks loosestool_woman_1week

*reshaping the data back to wide
reshape wide total_pregwoman total_diarrhea_preg_2weeks total_diarrhea_preg_1week diarrhea_woman_perc_2weeks diarrhea_woman_perc_1week total_loosestool_preg_2weeks total_loosestool_preg_1week loosestool_woman_perc_2weeks loosestool_woman_perc_1week, i(unique_id) j(num)

* final vars creation for use later
egen sum_diarrhea_preg_1week = rowtotal(diarrhea_woman_perc_1week*)
gen avg_diarrhea_preg_1week = sum_diarrhea_preg_1week/18
egen sum_diarrhea_preg_2weeks = rowtotal(diarrhea_woman_perc_2weeks*)
gen avg_diarrhea_preg_2weeks = sum_diarrhea_preg_2weeks/18

egen sum_loosestool_preg_1week = rowtotal(loosestool_woman_perc_1week*)
gen avg_loosestool_preg_1week = sum_loosestool_preg_1week/18
egen sum_loosestool_preg_2weeks = rowtotal(loosestool_woman_perc_2weeks*)
gen avg_loosestool_preg_2weeks = sum_loosestool_preg_2weeks/18

drop diarrhea_woman_perc_1week* diarrhea_woman_perc_2weeks* loosestool_woman_perc_1week* loosestool_woman_perc_2weeks*

label var C_total_pregnant_hh "Average pregnant women"	
label var total_pregwoman1 "Total pregnant women"
label var avg_diarrhea_preg_2weeks "Diarrhea- Preg women (2 weeks)" 
label var avg_loosestool_preg_2weeks "Loose stool- Preg women (2 weeks)" 
label var avg_diarrhea_preg_1week "Diarrhea- Preg women (1 week)" 
label var avg_loosestool_preg_1week "Loose stool- Preg women (1 week)" 

*/

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
start_from_clean_file_Population
start_from_clean_file_ChildLevel
