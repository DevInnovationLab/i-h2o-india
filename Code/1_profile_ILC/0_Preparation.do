************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files

* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" {
cd "${DataRaw}"
do "${Do_lab}import_india_ilc_pilot_census.do"
save "${DataRaw}1_1_Census.dta", replace

do "${Do_lab}import_india_ilc_pilot_followup_survey.do"
save "${DataRaw}1_2_Followup.dta", replace
}

* Windows User
else if c(username) == "cueva" | c(username) == "ABC"   {

do   "${Do_lab}1_0_1_label_w.do"
save "${DataRaw}1. Contact details.dta", replace
}

/* Ranodmized once
import excel using "${DataOther}India ILC_Pilot_Rayagada Village Tracking.xlsx", first clear
drop if Block==""
keep Block Selected Village village_IDinternal Pointgeolocationlat1 Pointgeolocationlon1 Panchatvillage BlockCode
destring BlockCode, replace
randtreat if Selected=="Selected", generate(Treat_V) replace strata(BlockCode Panchatvillage) misfits(global) setseed(75823)
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_1.dta", replace
*/

import excel using "${DataOther}India ILC_Pilot_Rayagada Village Tracking.xlsx", first clear sheet("Selected villages")   
keep HHchoicecriteria village_IDinternal
drop if village_IDinternal==""
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_2.dta", replace

use "${DataOther}India ILC_Pilot_Rayagada Village Tracking_1.dta",clear
merge 1:1 village_IDinternal using "${DataOther}India ILC_Pilot_Rayagada Village Tracking_2.dta"
rename village_IDinternal village
rename HHchoicecriteria V_Num_HH
destring village, replace
save "${DataOther}India ILC_Pilot_Rayagada Village Tracking_clean.dta", replace
export excel using "${DataPre}Google_map_village.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1) 
