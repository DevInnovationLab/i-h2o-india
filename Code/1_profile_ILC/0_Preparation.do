************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files

* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" | c(username)=="michellecherian" | c(username)== "asthavohra" | c(username)== "Archi Gupta" | c(username)=="j_lowe" {
cd "${DataRaw}"
do "${Do_lab}import_india_ilc_pilot_census.do"
save "${DataRaw}1_1_Census.dta", replace

do "${Do_lab}import_india_ilc_pilot_followup_survey_enc.do"
save "${DataRaw}1_2_Followup.dta", replace

do "${Do_lab}import_Geo_location_form.do"
save "${DataRaw}90_Village_Geo.dta", replace

do "${Do_lab}import_india_ilc_pilot_backcheck_Master.do"
save "${DataRaw}1_3_Back_Check.dta", replace

do "${Do_lab}import_india_ilc_pilot_mortality_Master.do"
save "${DataRaw}1_4_Mortality.dta", replace


do "${Do_lab}import_india_ilc_pilot_hh_followup_survey_enc.do"
save "${DataRaw}1_5_FollowUp_R1.dta", replace


do "${Do_lab}import_india_ilc_pilot_hh_followup_R2_survey_enc.do"
save "${DataRaw}1_6_FollowUp_R2.dta", replace

do "${Do_lab}import_india_ilc_pilot_hh_followup_R3_survey_enc.do"
save "${DataRaw}1_7_FollowUp_R3.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census.do"
save "${DataRaw}1_8_Endline.dta", replace

do "${Do_lab}import_e.coli_results_follow_up_R2.do"
save "${DataRaw}1_7_E.Coli_R2.dta", replace
}

* Windows User
else if c(username) == "cueva" | c(username) == "ABC"   {

do   "${Do_lab}1_0_1_label_w.do"
save "${DataRaw}1. Contact details.dta", replace
}

/* Ranodmized once (among those 20 villages)!
import excel using "${DataOther}India ILC_Pilot_Rayagada Village Tracking.xlsx", first clear
drop if Block==""
keep Block Selected Village village_IDinternal Pointgeolocationlat1 Pointgeolocationlon1 Panchatvillage BlockCode
destring BlockCode, replace
sort village_IDinternal
* randtreat if Selected=="Selected", generate(Treat_V) replace strata(BlockCode Panchatvillage) misfits(missing) setseed(75823)
* randtreat if Selected=="Selected", generate(Treat_V) replace strata(BlockCode)                misfits(global)  setseed(75823)
randtreat if Selected=="Selected", generate(Treat_V) replace strata(BlockCode Panchatvillage)   misfits(global)  setseed(75823)
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_1.dta", replace
*/

/* Distance calculation: Do not run many times (There is API limit)
use "${DataOther}India ILC_Pilot_Rayagada Village Tracking_1.dta",clear
gen Rayagada_lat=18.9727740098182
gen Rayagada_lon=84.15647750019056
gen Kolnara_lat=19.247514206433397
gen Kolnara_lon=83.45801657266972
gen Gunupur_lat=19.079402540325376
gen Gunupur_lon=83.80685582365435
gen Gudari_lat=19.347469535217364
gen Gudari_lon=83.78395602415917
gen Padmapur_lat=19.24631931009169
gen Padmapur_lon=83.83696380451754
foreach i in Rayagada Kolnara Gunupur Gudari Padmapur {
	georoute, herekey("v0w4nBGNSdsah7pYDxtGSLcxs8wpwMdmWkC0uzJIJAI") startxy(Pointgeolocationlat1 Pointgeolocationlon1) endxy(`i'_lat `i'_lon) km distance(km_`i') ti(tt_`i') diag(diag_`i')
}
keep km_* village_IDinternal
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_3.dta", replace
*/

* Village level info
import excel using "${DataOther}India ILC_Pilot_Rayagada Village Tracking.xlsx", first clear sheet("Selected villages")   
keep HHchoicecriteria village_IDinternal
drop if village_IDinternal==""
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_2.dta", replace

use "${DataOther}India ILC_Pilot_Rayagada Village Tracking_1.dta",clear
merge 1:1 village_IDinternal using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_2.dta"
merge 1:1 village_IDinternal using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_3.dta", nogen
rename village_IDinternal village
rename HHchoicecriteria V_Num_HH
destring village, replace
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", replace
export excel using "${DataPre}Google_map_village.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1) 

* Village gep info
use "${DataRaw}90_Village_Geo.dta", clear
*************************
* Cleaning the GPS data: Keeping the most reliable entry of GPS
*************************
split   a40_gps_manual, p(" ") destring
replace gps_manuallatitude=a40_gps_manual1 if gps_manuallatitude==.
replace gps_manuallongitude=a40_gps_manual2 if gps_manuallongitude==.
replace gps_manualaltitude=a40_gps_manual3 if gps_manualaltitude==.
replace gps_manualaccuracy=a40_gps_manual4 if gps_manualaccuracy==.
drop a40_gps_manual1 a40_gps_handlongitude a40_gps_handlatitude a40_gps_manual2 a40_gps_manual3 a40_gps_manual4 a40_gps_manual

decode landmark, gen(unique_id)
keep gps_manuallatitude gps_manuallongitude village_name unique_id awc_connect_basudha school_connect_basudha
rename (gps_manuallatitude gps_manuallongitude village_name) (R_Cen_a40_gps_latitude R_Cen_a40_gps_longitude R_Cen_village_name)
save "${DataFinal}90_Village_Geo.dta", replace
