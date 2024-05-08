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
	* This do file exports..... Cleaned data for Endline survey

clear all               
set seed 758235657 // Just in case

cap program drop key_creation
program define   key_creation

	split  key, p("/" "[" "]")
	rename key key_original
	rename key1 key
	
end

cap program drop prefix_rename
program define   prefix_rename

	//Renaming vars with prefix R_E
	foreach x of var * {
	rename `x' R_E_`x'
	}	

end

* Cen_Typel 1 "n_all" 2 "n_cbw" 3 "cen_cbw" 4 "cen_u5" 5 "n_u5" 6 "cen_all", modify

/* ---------------------------------------------------------------------------
* ID 19 and 20: Mortality info
 ---------------------------------------------------------------------------*/
 * ID 19
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta", clear
key_creation 
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
save "${DataTemp}temp.dta", replace

* ID 20
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", clear
key_creation 
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
append using "${DataTemp}temp.dta"
save "${DataTemp}Mortality_19_20.dta", replace

/* ---------------------------------------------------------------------------
* ID 23 and 24: Morbidity for children U5
 ---------------------------------------------------------------------------*/
 * ID 23
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_child_followup.dta", clear
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
gen Cen_Type=4
save "${DataTemp}temp.dta", replace
 * ID 24
 
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_child_followup.dta", clear
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
gen Cen_Type=5
append using "${DataTemp}temp.dta"
drop if comb_child_caregiver_present==.
tab Cen_Type,m
save "${DataTemp}Morbidity_23_24.dta", replace

/* ---------------------------------------------------------------------------
* Long indivual data from the roster
 ---------------------------------------------------------------------------*/
* ID 26
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", clear
key_creation 
keep n_hhmember_gender n_hhmember_relation n_hhmember_age n_u5mother_name n_u5mother n_u5father_name key key3 n_hhmember_name namenumber

br if key=="uuid:0b09e54d-a47a-414a-8c3c-ba16ed4d9db9"
save "${DataTemp}temp0.dta", replace

* ID 22
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-N_CBW_followup.dta", clear
key_creation 
drop if n_resp_avail_cbw==.
keep n_not_curr_preg key key3
save "${DataTemp}temp1.dta", replace

use "${DataTemp}temp0.dta", clear
merge 1:1 key key3 using "${DataTemp}temp1.dta"
* N=141
gen Type=1
save "${DataTemp}Requested_long_backcheck1.dta", replace

* ID 25
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", clear
key_creation 
keep cen_still_a_member key key3 name_from_earlier_hh
br if key=="uuid:00241596-007f-45dd-9698-12b5c418e3e7"
save "${DataTemp}temp0.dta", replace

* ID 21
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", clear
 key_creation 
 drop if  cen_name_cbw_woman_earlier==""
 * keep if cen_resp_avail_cbw==1
 keep cen_name_cbw_woman_earlier cen_resp_avail_cbw cen_preg_status cen_not_curr_preg cen_preg_residence key key3
 save "${DataTemp}temp1.dta", replace
 
 use "${DataTemp}temp0.dta", clear
 merge 1:1 key key3 using "${DataTemp}temp1.dta"
gen Type=2
save "${DataTemp}Requested_long_backcheck2.dta", replace

use "${DataTemp}Requested_long_backcheck1.dta", clear
append using "${DataTemp}Requested_long_backcheck2.dta"
* Adding unique ID
merge m:1 key using "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", keepusing(unique_id) keep(3) nogen
unique Type key key3
unique key
save  "${DataTemp}Endline_Long_Indiv.dta", replace

erase "${DataTemp}Requested_long_backcheck1.dta"
erase "${DataTemp}Requested_long_backcheck2.dta"


 /* ---------------------------------------------------------------------------
* ID of the data 6 15
* Unit: What amount did ${N_med_name_all} pay for ${N_other_exp_all} at ${N_out_names_all} ?
* At the level of "other" expenses 
 ---------------------------------------------------------------------------*/
* ID 6
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", clear
key_creation

foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
drop if comb_tests_val_comb==""

gen Cen_Type=6
save "${DataTemp}temp.dta", replace

* ID 15
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", clear
key_creation
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}
drop if comb_tests_val_comb==""

gen Cen_Type=2
append using "${DataTemp}temp.dta"

drop comb_tests_ind_comb
drop key7 key8 key2 key5 key4
unique key Cen_Type key3 key6 key9
order key Cen_Type key3 key6 key9, first
* This is the item wise
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse (sum) comb_med_otherpay_comb, by(key Cen_Type key3 key6) 
* Now it is collapsed at incidence wise: 71 incidence
save "${DataTemp}Medical_expenditure_6_15.dta", replace

/* ---------------------------------------------------------------------------
* ID of the data 5 and 11
* Out of the 105 HHH 134 sample shows records of  medical care in the past months
* Unit: This is medical care incidence level
* Cen all and N all
 ---------------------------------------------------------------------------*/
* ID 5
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta", clear
key_creation
// List all variables starting with "cen"
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
foreach var of varlist *_all {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=6
save "${DataTemp}temp.dta", replace

* ID 11
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta", clear
key_creation
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=1
append using "${DataTemp}temp.dta", gen(Cen)

drop if comb_med_seek_val_comb==""
drop comb_med_seek_ind_comb
unique key
save "${DataTemp}Medical_expenditure_5_11.dta", replace

/* ---------------------------------------------------------------------------
* ID 8, 10,  13, and 17
* Unit: Payment for each facility: What amount did ${Cen_med_name_all} pay for ${Cen_other_exp_all} at ${Cen_out_names_all} ?
* Finally I made it to the incidence of sickness level
* U5 and CBW (Both cen and New member)
 ---------------------------------------------------------------------------*/
* ID 17
 use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.dta", clear 
 drop if n_tests_val_u5==""
key_creation
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)

gen Cen_Type=5
save "${DataTemp}temp1.dta", replace

* ID 10
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta", clear 
drop if cen_tests_val_u5==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)

gen Cen_Type=4
save "${DataTemp}temp1.dta", replace

* ID 8
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.dta", clear
drop if cen_tests_val_cbw==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)
gen Cen_Type=3
save "${DataTemp}temp.dta", replace

* ID 13
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta.dta", clear
drop if n_tests_val_all==""
key_creation

foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}

drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse comb_med_otherpay_comb, by(key key3 key6)
gen Cen_Type=1
append using "${DataTemp}temp.dta"
append using "${DataTemp}temp1.dta"
save "${DataTemp}Medical_expenditure_8_10_13_17.dta", replace




/* ---------------------------------------------------------------------------
* ID of the data 4 and 7and 12 and 14 and 18
* Unit: Numeber of individual experienced medical care times Location that they seeked care
 ---------------------------------------------------------------------------*/
* ID 18
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.dta", clear 
drop if n_out_val2_u5==""
drop if n_out_names_u5==""
key_creation
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=5
save "${DataTemp}temp4.dta", replace

 * ID 9
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta", clear
drop if cen_out_val2_u5==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_u5*  {
	local newname = subinstr("`var'", "_u5", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=4
save "${DataTemp}temp3.dta", replace

* ID 7
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta", clear
drop if cen_out_val2_cbw==""
key_creation
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=3
save "${DataTemp}temp2.dta", replace

 * ID 14
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", clear
drop if n_out_val2_cbw==""
key_creation
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=2
save "${DataTemp}temp1.dta", replace

* ID 4
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", clear
drop if cen_out_val2_all==""
key_creation
unique key
unique parent_key
duplicates tag parent_key, gen(Dup)
// List all variables starting with "cen"
foreach var of varlist cen_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}

gen Cen_Type=6
save "${DataTemp}temp.dta", replace

* ID 12
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", clear
key_creation
// List all variables starting with "n_"
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb_", 1)
    rename `var' `newname'
}
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
gen Cen_Type=1

append using "${DataTemp}temp.dta"
append using "${DataTemp}temp1.dta"
append using "${DataTemp}temp2.dta"
append using "${DataTemp}temp3.dta"
append using "${DataTemp}temp4.dta"

	label define Cen_Typel 1 "n_all" 2 "n_cbw" 3 "cen_cbw" 4 "cen_u5" 5 "n_u5" 6 "cen_all", modify
	label values Cen_Type Cen_Typel

 * Create Dummy
	foreach v in comb_med_time_comb {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
	gen comb_med_time=.
replace comb_med_time=comb_med_time_mins_comb if comb_med_time_comb==1
replace comb_med_time=comb_med_time_hrs_comb if comb_med_time_comb==2
replace comb_med_time=. if comb_med_time_comb==999

label var comb_med_time "Travel time to seek care (mins)" 
label var comb_med_treat_type_comb_1 "Treat: Allopathy (english medicines)"
label var comb_med_treat_type_comb_2 "Treat: Indian system of medicine"
label var comb_med_treat_type_comb_3 "Treat: Homoeopathy"
label var comb_med_treat_type_comb_4 "Treat: Yoga and Naturopathy"
label var comb_med_treat_type_comb__77 "Treat: Other"
label var comb_med_treat_type_comb_999 "Treat: Do not know"

label var comb_med_scheme_comb_1 "Expenditure sch: Gov funded insurance"
label var comb_med_scheme_comb_4 "Expenditure sch: Not covered"
label var comb_med_scheme_comb_999 "Expenditure sch: Do not know"

label var comb_med_doctor_fees_comb "doctor fees all: What did .... This is how much?"
drop key2 key4 key5
unique key
unique key key3 Cen_Type
unique key key3 key6 Cen_Type
mdesc  Cen_Type
save "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", replace

/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
/* ---------------------------------------------------------------------------
* Final data creation at the incidence level and indivdual level
 ---------------------------------------------------------------------------*/
 ---------------------------------------------------------------------------*/
  ---------------------------------------------------------------------------*/
 ---------------------------------------------------------------------------*/
use "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", clear
drop if mi(comb_med_illness_other_comb)  // Drop if 'comb_med_illness_other_all' is missing
keep key Cen_Type key3 key6 key_original
merge 1:1 key_original using "${DataTemp}Medical_expenditure_4_7_12_14_18.dta", keep(2 3)

* Come back
duplicates drop key Cen_Type key3 key6,force
* Come back here: There are some _merge==2
merge 1:1 key Cen_Type key3 key6 using "${DataTemp}Medical_expenditure_6_15.dta", gen(Merge_othermed1)
drop if Merge_othermed1==2
* Come back
duplicates drop key Cen_Type key3 key6,force
merge 1:1 key Cen_Type key3 key6 using "${DataTemp}Medical_expenditure_8_10_13_17.dta", gen(Merge_othermed2)
drop if Merge_othermed2==2
merge m:1 key using "${DataRaw}1_8_Endline/1_8_Endline_Census.dta", keepusing(unique_id enum_name) keep(3) nogen
* N=148: Number of incidnce times Location they seeked care
savesome using "${DataTemp}Medical_expenditure_person_case.dta" if comb_out_val2_comb!="", replace
collapse (sum) comb_med_time, by(key Cen_Type key3)
* N=134: Number of incidnce
merge 1:1 key Cen_Type key3 using "${DataTemp}Medical_expenditure_5_11.dta"

* Create Dummy
	foreach v in Cen_Type {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

save "${DataTemp}Medical_expenditure_person.dta", replace


use "${DataTemp}Medical_expenditure_person.dta", clear
* N_HHmember_age: Add this, Cen_CBW_consent
global PerVar ///
       Cen_Type_1 Cen_Type_2 Cen_Type_3 Cen_Type_4 Cen_Type_5 Cen_Type_6

local PerVar "Number of people reporting any sickness"
					 
foreach k in PerVar {
* Mean
	eststo  model0: estpost summarize $`k'
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}Medical_expenditure_person.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Medical_expenditure_person.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Medical_expenditure_person.dta", clear
	foreach i in $`k' {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $`k'

esttab model0 model1 model6 model7 model8 using "${Table}Enr_`k'.tex", title("``k''" \label{`Label`k''}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "Median" "Min" "Max" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }

use "${DataTemp}Medical_expenditure_person_case.dta", clear

br unique_id enum_name if comb_med_doctor_fees_comb>2000 & comb_med_doctor_fees_comb!=.

* N_HHmember_age: Add this, Cen_CBW_consent
global MedVar ///
       comb_med_time comb_med_time_comb_3 comb_med_time_comb_999 ///
       comb_med_treat_type_comb_1 comb_med_treat_type_comb_2 comb_med_treat_type_comb_3 comb_med_treat_type_comb_4 comb_med_treat_type_comb__77 comb_med_treat_type_comb_999 ///
	   comb_med_scheme_comb_1 comb_med_scheme_comb_2 comb_med_scheme_comb_3 comb_med_scheme_comb_4 comb_med_scheme_comb_999 comb_med_scheme_comb__77 ///
	   comb_med_doctor_fees_comb

local MedVar "Incidence of person seeked care outside"
local LabelMedVar "Outside"
					 
foreach k in MedVar {
* Mean
	eststo  model0: estpost summarize $`k'
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}Medical_expenditure_person_case.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Medical_expenditure_person_case.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Medical_expenditure_person_case.dta", clear
	foreach i in $`k' {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $`k'

esttab model0 model1 model6 model7 model8 using "${Table}Enr_`k'.tex", title("``k''" \label{`Label`k''}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "Median" "Min" "Max" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }


	   
	   key	comb_med_doctor_fees_comb
uuid:2cfb84ed-d5fc-4833-8bd8-3fdedfcbcdc6	5000
uuid:71670fd6-47d6-4454-bc78-77166fb9c5eb	6000
uuid:75295248-57b7-466d-8e55-bd2db05c4a48	2700





ENMD


n_med_trans_all_7 n_med_scheme_all


key_creation
* Parent key does not match with the one in the master data unelss we process in the following way
global keepvar cen_med_treat_type_all_* cen_med_trans_all_*
* HH level (37 HH)
collapse (sum) $keepvar, by(key)

foreach i in cen_med_treat_type_all_ cen_med_trans_all_ {
	rename `i'* Count_`i'*
}

rename *cen_med* *cm* 
prefix_rename
save "${DataTemp}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all_HH.dta", replace

Cen_med_seek_all

use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", clear
* Key creation
key_creation

global keepvar n_med_trans_all_*
keep key $keepvar
collapse (sum) $keepvar, by(key)

prefix_rename
save "${DataTemp}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all_HH.dta", replace
