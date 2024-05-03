

use "${DataPre}1_1_Endline_XXX_consented.dta", clear

*renaming some duration vars becuase their names were slightly off and was not in accordance with the section in surveycto

rename R_E_intro_dur_end       R_E_final_consent_duration
rename R_E_consent_duration    R_E_final_intro_dur_end
rename R_E_roster_duration     R_E_census_roster_duration
rename R_E_roster_end_duration R_E_new_roster_duration

drop R_E_wash_duration

rename R_E_healthcare_duration  R_E_wash_duration
rename R_E_resp_health_duration R_E_noncri_health_duration
rename R_E_resp_health_new_duration R_E_CenCBW_health_duration
rename R_E_child_census_duration R_E_NewCBW_health_duration
rename R_E_child_new_duration R_E_CenU5_health_duration
rename R_E_sectiong_dur_end R_E_NewU5_health_duration

foreach  var in  R_E_final_intro_dur_end R_E_final_consent_duration R_E_census_roster_duration R_E_new_roster_duration R_E_wash_duration R_E_noncri_health_duration R_E_CenCBW_health_duration R_E_NewCBW_health_duration R_E_CenU5_health_duration R_E_NewU5_health_duration R_E_survey_end_duration {
destring `var', replace
gen `var'_s = `var'/60
sum `var'_s
}

* Commenting off for Archi
* cap gen diff_minutes_orig = clockdiff(R_E_starttime, R_E_endtime, "minute")
* gen diff_hours=diff_minutes/60
* sum diff_hours,de

gen R_E_Dur_final_consent_duration=R_E_final_consent_duration/60
gen R_E_Dur_census_roster_duration=(R_E_census_roster_duration-R_E_final_consent_duration)/60
gen R_E_Dur_new_roster_duration=(R_E_new_roster_duration-R_E_census_roster_duration)/60
gen R_E_Dur_wash_duration=(R_E_wash_duration-R_E_new_roster_duration)/60
gen R_E_Dur_noncri_health_duration=(R_E_noncri_health_duration-R_E_wash_duration)/60
gen R_E_Dur_CenCBW_health_duration=(R_E_CenCBW_health_duration-R_E_noncri_health_duration)/60
gen R_E_Dur_NewCBW_health_duration=(R_E_NewCBW_health_duration-R_E_CenCBW_health_duration)/60
gen R_E_Dur_CenU5_health_duration=(R_E_CenU5_health_duration-R_E_NewCBW_health_duration)/60
gen R_E_Dur_NewU5_health_duration=(R_E_NewU5_health_duration-R_E_CenU5_health_duration)/60
gen R_E_Dur_survey_end_duration=(R_E_survey_end_duration-R_E_NewU5_health_duration)/60
* R_E_Dur_survey_end_duration: It is okay that this is extremely short: (R_E_NewU5_health_duration: Line 1176 and R_E_survey_end_duration: Line 1178 in SurveyCTO)
 
 * Replacing the value of negative value since they are most likely gone back
 foreach i in R_E_Dur_noncri_health_duration R_E_Dur_NewCBW_health_duration R_E_Dur_CenU5_health_duration R_E_Dur_NewU5_health_duration R_E_Dur_survey_end_duration {
 replace `i'=. if `i'<0	
 }
 
*no of households = 179
destring R_E_cen_num_hhmembers, replace
*avg HH members per HH
sum R_E_cen_num_hhmembers
*avg HH new members added per HH
sum R_E_n_hhmember_count


//NON CRITERIA MEMBERS LOOP

*No of times loop ran for NEW non-criteria members 
split R_E_n_med_seek_all, generate(R_E_n_med_seek_all)

foreach var in R_E_n_med_seek_all1 R_E_n_med_seek_all2{
destring `var', replace
} 

foreach var in R_E_n_med_seek_all1 R_E_n_med_seek_all2{
gen NMA_`var' = 1 if `var' != . & `var' != 21
}

egen temp_group = group(unique_id_num)
egen tota_NMA = rowtotal(NMA_*)
drop temp_group

rename tota_NMA Total_Med_New_noncri

sum Total_Med_New_noncri

gen Num_Med_New_noncri = r(mean)


*No of times loop ran for Census non-criteria members 


split R_E_cen_med_seek_all, generate(R_E_cen_med_seek_all)

foreach var in R_E_cen_med_seek_all1 R_E_cen_med_seek_all2 R_E_cen_med_seek_all3 R_E_cen_med_seek_all4{
destring `var', replace
} 

foreach var in R_E_cen_med_seek_all1 R_E_cen_med_seek_all2 R_E_cen_med_seek_all3 R_E_cen_med_seek_all4{
gen NC_`var' = 1 if `var' != . & `var' != 21
}

egen temp_group = group(unique_id_num)
egen T_NC = rowtotal(NC_*)
drop temp_group

rename T_NC Total_Med_Cen_noncri

sum Total_Med_Cen_noncri

gen Num_Med_Cen_noncri = r(mean)


*Avg non criteria members for medical care (Census + New) 

gen AVG_Med_all_noncri = Num_Med_Cen_noncri + Num_Med_New_noncri

//CHILD BEARING WOMEN

*num of census child bearing women
destring R_E_r_cen_num_female_15to49, replace
*avg of census child bearing women
sum R_E_r_cen_num_female_15to49
gen num_cen_CBW = r(mean)

*num of NEW child bearing women
destring R_E_n_num_female_15to49, replace
*avg of NEW child bearing women
sum  R_E_n_num_female_15to49
gen num_new_CBW = r(mean)


*avg census child bearing women (Census + new)
gen AVG_CBW_all = num_cen_CBW + num_new_CBW




//U5 CHILD 

*num of U5 CHILD
destring R_E_cen_num_childbelow5, replace
*avg of census U5 CHILD
sum R_E_cen_num_childbelow5
gen num_cen_U5 = r(mean)

*num of NEW U5 CHILD
destring R_E_n_num_childbelow5, replace
*avg of NEW U5 CHILD 
sum  R_E_n_num_childbelow5
gen num_new_U5 = r(mean)


*avg census U5 Child (Census + new)
gen AVG_U5_all = num_cen_U5 + num_new_U5


egen temp_group = group(unique_id_num)
egen T_Cen_M = rowtotal(R_E_Count_cm_out_home_all_*)
drop temp_group

ds R_E_Count_cm_symp_all_*
foreach var of varlist `r(varlist)'{
tab `var'
}


gen treat = 1 
replace treat = 0 if inlist(R_E_r_cen_village_name_str, "Barijhola" ,  "Dangalodi" , "Kuljing")


save "${DataTemp}Temp.dta", replace

tab N_HHmember_count

******************************************
        * Survey duration table * 
******************************************
global DurVar R_E_Dur_final_consent_duration R_E_Dur_census_roster_duration R_E_Dur_new_roster_duration R_E_Dur_wash_duration R_E_Dur_noncri_health_duration R_E_Dur_CenCBW_health_duration R_E_Dur_NewCBW_health_duration R_E_Dur_CenU5_health_duration R_E_Dur_NewU5_health_duration R_E_Dur_survey_end_duration
					 
* Mean
	eststo  model0: estpost summarize $DurVar
* Median
	foreach i in $DurVar {
	egen i_`i'=median(`i')
	replace `i'=i_`i'
	}
	eststo  model1: estpost summarize $DurVar

* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $DurVar {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $DurVar
* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $DurVar {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $DurVar
* Missing 
	use "${DataTemp}Temp.dta", clear
	foreach i in $DurVar {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $DurVar

esttab model0 model1 model6 model7 model8 using "${Table}Enr_Duration.tex", title("Survey duration of each sections" \label{DurTable}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "Median" "Min" "Max" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 




erase "${DataTemp}Temp.dta"
