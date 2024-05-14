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


use "${DataTemp}U5_Child_23_24.dta", clear

END

use "${DataTemp}Medical_expenditure_person_clean.dta", clear


* Number of household with new member 
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
keep if Cen_Type==2
* 90 HH
unique R_E_key

gen New_member_111=1 if strpos(comb_hhmember_name, "111") > 0 
br unique_id comb_hhmember_name New_member_111 if New_member_111==1



DE
/* ----------------------------------------------------
* Name of the new mother and father exported in excel
 ----------------------------------------------------*/
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear 

foreach i in father mother {
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
unique R_E_key key3
tostring comb_u5mother_name, replace force
keep R_E_key comb_u5`i'_name comb_hhmember_gender comb_age_ch_comb
drop if comb_u5`i'_name=="" | comb_u5`i'_name=="."
rename comb_u5`i'_name key3
keep R_E_key key3
merge 1:m R_E_key key3 using "${DataTemp}Endline_Long_Indiv_analysis.dta", keep(1 3) keepusing(Cen_Type comb_hhmember_name comb_hhmember_gender comb_hhmember_age name_from_earlier_hh)
capture export excel R_E_key Cen_Type key3 name_from_earlier_hh comb_hhmember_name comb_hhmember_gender comb_hhmember_age using "${Endline}Master_Excel_Endline_HFC.xlsx", sheet("List of new `i'", modify) firstrow(var) 
}


use "${DataTemp}U5_Child_23_24.dta", clear
replace comb_child_residence=0 if comb_child_residence==-98
* Create Dummy
	foreach v in comb_child_residence comb_child_breastfeeding comb_med_seek_care_comb {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
	graph bar comb_med_seek_care_comb_1, over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title("Seek med yes by enum")
	  graph export "${Figure}End_member_seek.eps", replace  

	graph bar comb_child_breastfeeding_1, over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title("Breast feeding yes by enum")
	  graph export "${Figure}End_member_breast.eps", replace  
	
	graph bar comb_child_residence_0, over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title("Child residence is no, or refused to answer by enum")
	  graph export "${Figure}End_member_residence.eps", replace  



use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
 * Create Dummy
	foreach v in comb_hhmember_gender cen_child_residence {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
	recode comb_resp_avail_comb 7=2
	tab comb_resp_avail_comb  comb_still_a_member,m
	/*
	graph bar comb_hhmember_gender_1 if comb_hhmember_age>5, over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title("Percent of the new member being male among" "Excluding children under age 5")
	graph export "${Figure}End_member_gender.eps", replace  

use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
graph bar comb_still_a_member, over(R_E_enum_name, sort(1) label(angle(45))) ///
      blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	  title("Percent of the household still present - avereage by enumerators")
	  graph export "${Figure}End_member_still.eps", replace  
	  
*/

use "${DataTemp}Medical_expenditure_person_clean.dta", clear
* N_HHmember_age: Add this, Cen_CBW_consent
global PerVar ///
	   comb_med_symp_comb_1 comb_med_symp_comb_2 comb_med_symp_comb_3 comb_med_symp_comb_4 comb_med_symp_comb_5 ///
	   comb_med_symp_comb_6 comb_med_symp_comb_7 comb_med_symp_comb_8 comb_med_symp_comb_9 comb_med_symp_comb_10 ///
	   comb_med_symp_comb_11 comb_med_symp_comb_12 comb_med_symp_comb_13 comb_med_symp_comb__77 ///
	   comb_med_where_comb_1 comb_med_where_comb_2 comb_med_where_comb_3 comb_med_where_comb__77 ///
	   comb_med_out_home_comb_1 comb_med_out_home_comb_2 comb_med_out_home_comb_3 comb_med_out_home_comb_4 comb_med_out_home_comb_5 comb_med_out_home_comb_6 comb_med_out_home_comb_7 comb_med_out_home_comb_8 comb_med_out_home_comb_9 comb_med_out_home_comb_999 comb_med_out_home_comb__77 ///
	   comb_med_work_comb

local PerVar "Number of people reporting any sickness"
					 
foreach k in PerVar {
* Mean
	eststo  model0: estpost summarize $`k'
	eststo  model01: estpost summarize $`k' if Cen_Type_1==1 | Cen_Type_6==1
	eststo  model02: estpost summarize $`k' if Cen_Type_2==1 | Cen_Type_3==1
	eststo  model03: estpost summarize $`k' if Cen_Type_4==1 | Cen_Type_5==1
	eststo  model031: estpost summarize $`k' if (Cen_Type_4==1 | Cen_Type_5==1) & End_date<23499
	eststo  model032: estpost summarize $`k' if (Cen_Type_4==1 | Cen_Type_5==1) & End_date>23499
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

esttab model0  model01  model02 model03 model031 model032 model8 using "${Table}Enr_`k'.tex", title("``k''" \label{`Label`k''}) ///
	   cell("mean (fmt(2) label(_))") stats(N, fmt("%9.0fc") label(Observations) ) /// 
	   mtitles("Mean" "All" "CBW" "U5" "\shortstack[c]{U5\\(Before)}" "\shortstack[c]{U5\\(After)}" "\shortstack[c]{Number\\missing}") nonum ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{0.87\linewidth}}{\footnotesize" ///
				   "&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Fever" "\textbf{Symptom} \\\hline Fever" ///
				   "Home" "\textbf{Place seeked care} \\\hline Home" ///
				   "Chemist" "\multicolumn{4}{l}{\textbf{Place seeked care - outside of home (Multiple choice)}} \\\hline Chemist" ///
				   "-0 " "0" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }
	  

use "${DataTemp}Medical_expenditure_person_case_clean.dta", clear
* br unique_id enum_name if comb_med_doctor_fees_comb>2000 & comb_med_doctor_fees_comb!=.

* N_HHmember_age: Add this, Cen_CBW_consent
global MedVar ///
       comb_med_time comb_med_time_comb_3 comb_med_time_comb_999 ///
       comb_med_treat_type_comb_1 comb_med_treat_type_comb_2 comb_med_treat_type_comb_3 comb_med_treat_type_comb_4 comb_med_treat_type_comb__77 comb_med_treat_type_comb_999 ///
	   comb_med_doctor_fees_comb ///
	   comb_med_scheme_comb_1 comb_med_scheme_comb_2 comb_med_scheme_comb_3 comb_med_scheme_comb_4 comb_med_scheme_comb_999 comb_med_scheme_comb__77 ///
	   comb_med_trans_comb_1 comb_med_trans_comb_2 comb_med_trans_comb_3 comb_med_trans_comb_4 comb_med_trans_comb_5 comb_med_trans_comb_6 comb_med_trans_comb_7 comb_med_trans_comb_8 comb_med_trans_comb__77

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
	use "${DataTemp}Medical_expenditure_person_case_clean.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}Medical_expenditure_person_case_clean.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}Medical_expenditure_person_case_clean.dta", clear
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
				   "Walking" "\textbf{Transportation} \\\hline Walking" ///
				   "Expenditure sch: Gov funded insurance" "\textbf{Expenditure scheme} \\\hline Expenditure sch: Gov funded insurance" ///
				   "Treat: Allopathy (english medicines)" "\textbf{Treatment} \\\hline Treat: Allopathy (english medicines)" ///
				   "-0 " "0" ///
				   "Expenditure sch: " "~~~" "Treat:"  "~~~" ///
				   ) ///
	   label  note("`note`k''")  ///
	   replace 
	   }





END

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
