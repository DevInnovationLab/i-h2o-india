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

use "${DataTemp}Medical_expenditure_person_clean.dta", clear
* N_HHmember_age: Add this, Cen_CBW_consent
global PerVar ///
	   comb_med_symp_comb_1 comb_med_symp_comb_2 comb_med_symp_comb_3 comb_med_symp_comb_4 comb_med_symp_comb_5 ///
	   comb_med_symp_comb_6 comb_med_symp_comb_7 comb_med_symp_comb_8 comb_med_symp_comb_9 comb_med_symp_comb_10 ///
	   comb_med_symp_comb_11 comb_med_symp_comb_12 comb_med_symp_comb_13 comb_med_symp_comb__77

local PerVar "Number of people reporting any sickness"
					 
foreach k in PerVar {
* Mean
	eststo  model0: estpost summarize $`k'
	eststo  model01: estpost summarize $`k' if Cen_Type_1==1 | Cen_Type_6==1
	eststo  model02: estpost summarize $`k' if Cen_Type_2==1 | Cen_Type_3==1
	eststo  model03: estpost summarize $`k' if Cen_Type_4==1 | Cen_Type_5==1
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}Medical_expenditure_person_clean.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Medical_expenditure_person_clean.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Medical_expenditure_person_clean.dta", clear
	foreach i in $`k' {
	egen `i'_s=rowmiss(`i')
	egen s_`i'=sum(`i'_s)
	replace `i'=s_`i'
	}
	eststo  model8: estpost summarize $`k'

esttab model0  model01  model02  model03 model8 using "${Table}Enr_`k'.tex", title("``k''" \label{`Label`k''}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "All" "CBW" "U5" "Number missing") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _\\" "" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }

use "${DataTemp}Medical_expenditure_person_case.dta", clear

* br unique_id enum_name if comb_med_doctor_fees_comb>2000 & comb_med_doctor_fees_comb!=.

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
