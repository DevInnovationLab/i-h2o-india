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

/* ---------------------------------------------------------------------------
* ID of 13
* Unit: What amount did ${Cen_med_name_all} pay for ${Cen_other_exp_all} at ${Cen_out_names_all} ?
 ---------------------------------------------------------------------------*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta.dta", clear
drop if n_tests_val_all==""
key_creation
drop key2 key4 key5 key7 key8
unique key key3 key6 key9
replace n_med_otherpay_all=. if n_med_otherpay_all==999
collapse n_med_otherpay_all, by(key key3 key6)
save "${DataTemp}Medical_expenditure_13.dta", replace

ENBD


/* ---------------------------------------------------------------------------
* ID of the data 4 and 12 and 14
* Unit: Numeber of individual experienced medical care times Location that they seeked care
 ---------------------------------------------------------------------------*/
 * ID 14
use "${DataRaw}1_8_Endline/1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", clear
drop if n_out_val2_cbw==""
key_creation
foreach var of varlist n_* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "n_", "comb", 1)
    rename `var' `newname'
}
foreach var of varlist *_cbw*  {
	local newname = subinstr("`var'", "_cbw", "_comb", 1)
    rename `var' `newname'
}

save "${DataTemp}temp1.dta", replace

* ID 4
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", clear
drop if cen_out_val2_all==""
key_creation
unique key
unique parent_key
duplicates tag parent_key, gen(Dup)
// List all variables starting with "cen"
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}

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
append using "${DataTemp}temp.dta", gen(Cen)
drop if comb_out_val2_all==""
drop comb_out_ind2_all
foreach var of varlist *_all*  {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
append using "${DataTemp}temp1.dta", gen(Cen_pus)

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

save "${DataTemp}Medical_expenditure_4_12_14.dta", replace



/* ---------------------------------------------------------------------------
* Final data creation at the incidence level
 ---------------------------------------------------------------------------*/
use "${DataTemp}Medical_expenditure_4_12_14.dta", clear
drop if mi(comb_med_illness_other_comb)  // Drop if 'comb_med_illness_other_all' is missing
keep key Cen key3 key6 key_original
* Come back here: There are some _merge==2
merge 1:1 key Cen key3 key6 using "${DataTemp}Medical_expenditure_6_15.dta", keep(1 3) gen(Merge_othermed1)
merge 1:1 key key3 key6 using "${DataTemp}Medical_expenditure_13.dta", keep(1 3) gen(Merge_othermed2)
merge 1:1 key_original using "${DataTemp}Medical_expenditure_4_12_14.dta", keep(2 3)
drop key2 key4 key5
* N=148: Number of incidnce times Location they seeked care
collapse (sum) comb_med_time, by(key Cen key3)
* N=134: Number of incidnce
merge 1:1 key Cen key3 using "${DataTemp}Medical_expenditure_5_11.dta"

save "${DataTemp}Medical_expenditure_final_4_5_6_11_12_13_14_15.dta", replace

/* ---------------------------------------------------------------------------
* This one is at the level of "other" expenses 
* ID of the data 6 15
* Unit: What amount did ${N_med_name_all} pay for ${N_other_exp_all} at ${N_out_names_all} ?
 ---------------------------------------------------------------------------*/
* ID 6
use "${DataRaw}1_8_Endline/1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", clear
key_creation
br if key=="uuid:be8a8776-eb55-4531-89e2-ac9efb0d0465"
foreach var of varlist cen* {
    // Generate the new variable name by replacing 'old' with 'new'
    local newname = subinstr("`var'", "cen", "comb", 1)
    rename `var' `newname'
}
foreach var of varlist *_all {
	local newname = subinstr("`var'", "_all", "_comb", 1)
    rename `var' `newname'
}
drop if comb_tests_val_comb==""
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
append using "${DataTemp}temp.dta", gen(Cen)

drop comb_tests_ind_comb
drop key7 key8 key2 key5 key4
unique key Cen key3 key6 key9
order key Cen key3 key6 key9, first
* This is the item wise
replace comb_med_otherpay_comb=. if comb_med_otherpay_comb==999
collapse (sum) comb_med_otherpay_comb, by(key Cen key3 key6) 
* Now it is collapsed at incidence wise: 71 incidence
save "${DataTemp}Medical_expenditure_6_15.dta", replace

/* ---------------------------------------------------------------------------
* This is incidence level
* ID of the data 5
* Unit: This is incidence level
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
append using "${DataTemp}temp.dta", gen(Cen)
drop if comb_med_seek_val_all==""
drop comb_med_seek_ind_all

* Out of the 105 HHH 134 sample shows records of  medical care in the past months

save "${DataTemp}Medical_expenditure_5_11.dta", replace












use "${DataTemp}Medical_expenditure_4_12.dta", clear

tab Cen_med_where_all Cen_med_trans_all

* N_HHmember_age: Add this, Cen_CBW_consent
global MedVar comb_med_time comb_med_time_all_3 comb_med_time_all_999 ///
       comb_med_treat_type_all_1 comb_med_treat_type_all_2 comb_med_treat_type_all_3 comb_med_treat_type_all_4 comb_med_treat_type_all__77 comb_med_treat_type_all_999 ///
	   comb_med_scheme_all_1 comb_med_scheme_all_2 comb_med_scheme_all_3 comb_med_scheme_all_4 comb_med_scheme_all_999 comb_med_scheme_all__77 ///
	   comb_med_doctor_fees_all

local MedVar "Medical outcomes"
					 
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
	use "${DataTemp}Medical_expenditure_4_12.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Medical_expenditure_4_12.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Medical_expenditure_4_12.dta", clear
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
