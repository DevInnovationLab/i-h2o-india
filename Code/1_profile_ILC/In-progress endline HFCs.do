

use "${DataPre}1_1_Endline_XXX_consented.dta", clear
 
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

label var R_E_n_new_members "Any new member in the household"
label var R_E_water_treat "Any water treatment in the last one month"
label var R_E_water_sec_yn "Secondary water source"
label var R_E_jjm_drinking "Use JJM for drinking"
label var R_E_cen_resp_avail_cbw "Find CBWwoman"
label var R_E_consent "Consent"

save "${DataTemp}Temp.dta", replace

******************************************
        * Survey duration table * 
******************************************
use "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long2.dta", clear
rename key R_E_key
merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(R_E_enum_name) keep(1 3)
keep cen_preg_status cen_last_5_years_pregnant cen_med_seek_care_cbw cen_cbw_consent cen_preg_status cen_last_5_years_pregnant cen_med_seek_care_cbw R_E_enum_name
/*
foreach i in cen_preg_status cen_last_5_years_pregnant cen_med_seek_care_cbw cen_cbw_consent cen_preg_status cen_last_5_years_pregnant cen_med_seek_care_cbw {
	sum `i'
	cibar `i', over(R_E_enum_name) graphopt(yline(`r(mean)'))
	graph export "${Figure}`i'_enum.eps", replace  
}
*/

label var cen_cbw_consent "Consent"
label var cen_med_seek_care_cbw "CBW seek medical care (1 months)"
label var cen_last_5_years_pregnant "CBW pregnant in the last 5 years"
label var cen_preg_status "Is CBW earlier still pregnant?"

save "${DataTemp}Temp.dta", replace


use "${DataTemp}Temp.dta", clear

global CencbsVar cen_cbw_consent cen_preg_status cen_last_5_years_pregnant cen_med_seek_care_cbw
local  CencbsVar "Statistics at CBW level"

foreach k in CencbsVar {

* Mean
	eststo  model0: estpost summarize $`k'
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $`k'

esttab model0 model1 model6 model7 model8 using "${Table}Enr_`k'.tex", title("`k'" \label{DurTable}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "Median" "Min" "Max" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }



use "${DataFinal}1_8_Endline_Census-Household_available-Cen_CBW_Long1.dta", clear
rename key R_E_key
merge m:1 R_E_key using "${DataPre}1_8_Endline_XXX.dta", keepusing(R_E_enum_name)
 
 * Create Dummy
	foreach v in cen_resp_avail_cbw {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
foreach i in cen_resp_avail_cbw_1 {
	sum `i'
	cibar `i', over(R_E_enum_name) graphopt(yline(`r(mean)'))
	graph export "${Figure}`i'_enum.eps", replace  
} 


use "${DataTemp}Temp.dta", clear
foreach i in Total_time R_E_n_new_members R_E_water_sec_yn R_E_jjm_drinking {
	* graph bar `i', over(R_E_enum_name, label(angle(90)))
	sum `i'
	cibar `i', over(R_E_enum_name) graphopt(yline(`r(mean)'))
	graph export "${Figure}`i'_enum.eps", replace  
} 

 reg Total_time i.R_E_enum_code i.R_E_n_new_members i.R_E_water_sec_yn i.R_E_jjm_drinking
 * 134: Tend to be long

use "${DataTemp}Temp.dta", clear

* N_HHmember_age: Add this, Cen_CBW_consent
global SkipVar R_E_consent R_E_n_new_members R_E_water_sec_yn R_E_water_treat R_E_jjm_drinking

global DurVar R_E_Dur_final_consent_duration R_E_Dur_census_roster_duration R_E_Dur_new_roster_duration R_E_Dur_wash_duration R_E_Dur_noncri_health_duration R_E_Dur_CenCBW_health_duration R_E_Dur_NewCBW_health_duration R_E_Dur_CenU5_health_duration R_E_Dur_NewU5_health_duration R_E_Dur_survey_end_duration Total_time

local SkipVar "Varaibles with skippint pattern"
local DurVar "Survey duration"
					 
foreach k in DurVar SkipVar {
* Mean
	eststo  model0: estpost summarize $`k'
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $`k'

esttab model0 model1 model6 model7 model8 using "${Table}Enr_`k'.tex", title("`k'" \label{DurTable}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "Median" "Min" "Max" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }
	   
erase "${DataTemp}Temp.dta"


//trial
//trial2
