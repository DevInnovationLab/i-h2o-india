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

* Baseline child level data
* N=1,123 
* start_from_clean_file_ChildLevel
* save "${DataTemp}Baseline_ChildLevel.dta", replace

* The list of data for analysis
use "${DataTemp}U5_Child_23_24.dta", clear
use "${DataTemp}Medical_expenditure_person_clean.dta", clear
* Number of household with new member 
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear


use "${DataTemp}U5_Child_23_24.dta", clear
replace comb_child_residence=0 if comb_child_residence==-98
replace comb_child_comb_relation=98 if comb_child_comb_relation==-77

* Replace missing to .
foreach i in comb_child_care_dia_day comb_child_care_dia_2wk comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_days comb_child_vomit_day comb_child_diarr_day comb_child_residence {
	replace `i'=. if `i'==999
	replace `i'=. if `i'==888
}

* Create Dummy
	foreach v in comb_child_residence comb_child_breastfeeding comb_med_seek_care_comb comb_child_caregiver_present comb_child_comb_relation {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
	label var comb_child_residence "Usual residence"
	label var comb_child_care_dia_day "Diarrhea today/yester day"
	label var comb_child_care_dia_wk "Diarrhea week"
	label var comb_child_care_dia_2wk "2 weeks"
	label var comb_child_breastfeeding "Exclusive breast feeding"
	label var comb_child_breastfed_num "Up to which months?"
	
	* Creating diarrhea vars
gen     C_diarrhea_prev_child_1day=0
replace C_diarrhea_prev_child_1day=1  if comb_child_diarr_day==1 
gen     C_diarrhea_prev_child_1week=0
replace C_diarrhea_prev_child_1week=1  if (comb_child_diarr_day==1 | comb_child_diarr_wk==1)
gen     C_diarrhea_prev_child_2weeks=0
replace C_diarrhea_prev_child_2weeks=1 if (comb_child_diarr_day==1 | comb_child_diarr_wk==1 | comb_child_diarr_2wk==1) 

*Using loose & watery stool vars
gen     C_loosestool_child_1day=0
replace C_loosestool_child_1day=1  if comb_child_stool_24h==1 | comb_child_stool_yest==1
gen     C_loosestool_child_1week=0
replace C_loosestool_child_1week=1 if (comb_child_stool_24h==1 | comb_child_stool_yest==1 | comb_child_stool_wk==1) 
gen     C_loosestool_child_2weeks=0
replace C_loosestool_child_2weeks=1 if (comb_child_stool_24h==1 | comb_child_stool_yest==1 | comb_child_stool_wk==1 | comb_child_stool_2wk==1)

*generating new vars using both vars for diarrhea
gen     C_diarrhea_comb_U5_1day=0
replace C_diarrhea_comb_U5_1day=1 if C_diarrhea_prev_child_1day==1 | C_loosestool_child_1day==1

gen     C_diarrhea_comb_U5_1week=0
replace C_diarrhea_comb_U5_1week=1 if C_diarrhea_prev_child_1week==1 | C_loosestool_child_1week==1

gen     C_diarrhea_comb_U5_2weeks=0
replace C_diarrhea_comb_U5_2weeks=1 if C_diarrhea_prev_child_2weeks==1 | C_loosestool_child_2weeks==1

label var C_diarrhea_prev_child_1day "Diarrhea- U5 (1 day)" 
label var C_diarrhea_prev_child_1week "Diarrhea- U5 (1 week)" 
label var C_diarrhea_prev_child_2weeks "Diarrhea- U5 (2 weeks)"
label var C_loosestool_child_1day "Loose stool- U5 (1 day)" 
label var C_loosestool_child_1week "Loose stool- U5 (1 week)" 
label var C_loosestool_child_2weeks "Loose stool- U5 (2 weeks)" 

label var C_diarrhea_comb_U5_1day "Diarrhea/Loose- U5 (1 day)"
label var C_diarrhea_comb_U5_1week "Diarrhea/Loose- U5 (1 week)" 
label var C_diarrhea_comb_U5_2weeks "Diarrhea/Loose- U5 (2 weeks)" 

label var comb_child_diarr_wk_num "Number of days they had diarrhea (7 days)" 
label var comb_child_diarr_2wk_num "Number of days they had diarrhea (2 weeks)" 
label var comb_child_diarr_freq "Number of stools in the last 24 hours" 

destring key3, replace
rename key3 num
/*
*/
save "${DataTemp}U5_Child_23_24_clean.dta", replace


* Start with Baseline
use "${DataTemp}Baseline_ChildLevel.dta", clear
 unique  R_Cen_village_name
gen Cen_Type=4
foreach i in C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week C_diarrhea_comb_U5_2weeks {
	rename `i' B_`i'
}

merge 1:1 unique_id num Cen_Type using "${DataTemp}U5_Child_23_24_clean.dta", gen(Merge_Baseline_CL) keepusing(C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week C_diarrhea_comb_U5_2weeks village Treat_V End_date) update
replace R_Cen_village_name=village if R_Cen_village_name==.
drop village
tab Merge_Baseline_CL Cen_Type,m

label var Treat_V "Treatment"
label var B_C_diarrhea_comb_U5_1day "Reported diarrhea in the baseline"
local Notediarrhea "Note: Standard errors in parentheses clustered at the village level, $\sym{*} p<.10,\sym{**} p<.05,\sym{***} p<.01$."
* local     diarrhea_2w_c_1 "Experience of diarrhea within 2 weeks for children under age 5"

keep *_U5_1day *_U5_1week *U5_2weeks Treat_V R_Cen_village_name Merge_Baseline_CL unique_id
sort Merge_Baseline_CL
sort unique_id

unique R_Cen_village_name
unique R_Cen_village_name if Merge_Baseline_CL==3

foreach i in C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week C_diarrhea_comb_U5_2weeks {
	
eststo: reg `i' Treat_V , cluster(R_Cen_village_name)
sum `i' if Treat_V==0
estadd scalar Mean = r(mean)

eststo: reg `i' Treat_V B_`i', cluster(R_Cen_village_name)
sum `i' if Treat_V==0
estadd scalar Mean = r(mean)
}
esttab using "${Table}ILC_Main_Diarrhea_RCT.tex",label se ar2 nomtitle title("Probability of experiencing diarrhea/loose stool among children U5" \label{LabelD}) nonotes nobase nocons ///
			 stats(Mean r2_a N, fmt(%9.2fc %9.2fc %9.0fc) labels(`"Control mean"' `"Adjusted \(R^{2}\)"' `"Observation"')) ///
			 mgroups("1 day" "\shortstack[c]{1 week}" "2 weeks", pattern(1 0  1 0  1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) /// 
			 rename(B_C_diarrhea_comb_U5_1week B_C_diarrhea_comb_U5_1day B_C_diarrhea_comb_U5_2weeks B_C_diarrhea_comb_U5_1day) ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(3) ///
			 substitute("{l}{\footnotesize" "{p{1\linewidth}}{\footnotesize" ///
			 "DSW: Yes" "\textbf{Dispenser for safe water in the community}" ///
			 "Edu: " "~~~" "WT: " "~~~" "CHL Source:" "~~~" "DSW:" "~~~" "Distance_HF: " "~~~" "Gestation: " "~~~" "NumU5:" "~~~" ///
			 ) ///
			 addnote("`Notediarrhea'") ///	
			 replace
eststo clear

*END


use "${DataTemp}U5_Child_23_24_clean.dta", clear

* N_HHmember_age: Add this, Cen_CBW_consent
global U5Var ///
       comb_child_caregiver_present_1 ///
	   comb_child_residence comb_child_comb_relation_1 comb_child_comb_relation_2 comb_child_comb_relation_3 comb_child_comb_relation_5 comb_child_comb_relation_98 ///
	   comb_child_breastfeeding comb_child_breastfed_num comb_child_breastfed_month ///
	   comb_child_breastfed_days ///
	   C_diarrhea_prev_child_1day C_diarrhea_prev_child_1week C_diarrhea_prev_child_2weeks ///
	   comb_child_diarr_wk_num comb_child_diarr_2wk_num comb_child_diarr_freq ///
	   C_loosestool_child_1day C_loosestool_child_1week C_loosestool_child_2weeks ///
	   C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week C_diarrhea_comb_U5_2weeks
	   
	   * Vomit
	   * comb_child_vomit_day comb_child_vomit_wk comb_child_vomit_2wk ///
	  
	   * comb_child_blood_day comb_child_blood_wk comb_child_blood_2wk ///
	   * comb_child_cuts_day comb_child_cuts_wk comb_child_cuts_2wk ///
	   * comb_anti_child_wk comb_anti_child_days comb_anti_child_last comb_anti_child_last_months comb_anti_child_last_days *
	   * comb_anti_child_purpose comb_anti_child_purpose_1 comb_anti_child_purpose_2 comb_anti_child_purpose_3 comb_anti_child_purpose_4 comb_anti_child_purpose__77 comb_anti_child_purpose_oth comb_med_seek_care_comb comb_med_diarrhea_comb comb_med_visits_comb
	   
local U5Var "Incidence of person seeked care outside"
local LabelU5Var "Outside"
					 
foreach k in U5Var {
* Mean
	eststo  model0: estpost summarize $`k'
* Median
	foreach i in $`k' {
	egen m_`i'=median(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Min
	use "${DataTemp}U5_Child_23_24_clean.dta", clear
	foreach i in $`k' {
	egen i_`i'=min(`i')
	replace `i'=i_`i'
	}

	eststo  model6: estpost summarize $`k'
* Max
	use "${DataTemp}U5_Child_23_24_clean.dta", clear
	foreach i in $`k' {
	egen a_`i'=max(`i')
	replace `i'=a_`i'
	}
	eststo  model7: estpost summarize $`k'
* Missing 
	use "${DataTemp}U5_Child_23_24_clean.dta", clear
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

use "${DataTemp}U5_Child_23_24_clean.dta", clear

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
END





keep if Cen_Type==2
* 90 HH
unique R_E_key

gen New_member_111=1 if strpos(comb_hhmember_name, "111") > 0 
br unique_id comb_hhmember_name New_member_111 if New_member_111==1



*DE
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



use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
gen Leng_comb_preg_rch_id=length(comb_preg_rch_id)
 * Create Dummy
	foreach v in comb_hhmember_gender comb_resp_avail_comb {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	* Month of preg: Check togetehr
	scatter comb_preg_delivery comb_preg_month if  comb_preg_delivery!=999 , mlab(R_E_enum_name) mlabangle(15)
	gen Rev_comb_preg_month=4-comb_preg_month-1
	scatter comb_preg_delivery Rev_comb_preg_month if  comb_preg_delivery!=999 , mlab(R_E_enum_name) mlabangle(15)
	graph export "${Figure}End_preg_month_consis.eps", replace  
	
	tab comb_vill_residence comb_preg_residence
	
	
	recode comb_resp_avail_comb 7=2
	tab comb_resp_avail_comb  comb_still_a_member,m
	
	graph bar comb_hhmember_gender_1 if comb_hhmember_age>5, over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title("Percent of the new member being male among" "Excluding children under age 5")
	graph export "${Figure}End_member_gender.eps", replace  
	
	local T_comb_resp_avail_comb_1 "CBW Respondents available for interview"
	local F_comb_resp_avail_comb_1 "End_member_CBW_available"
	local T_comb_resp_avail_comb_8 "CBW Respondents not available any more"
	local F_comb_resp_avail_comb_8 "End_member_CBW_noavailable"
	local T_comb_med_seek_care_comb "Seeked med"
	local F_comb_med_seek_care_comb "End_member_seek_med"
	local T_comb_translator "Translator"
	local F_comb_translator "End_member_translator"
	local T_comb_still_a_member "Percent of the household still present - avereage by enumerators"
	local F_comb_still_a_member "End_member_still"

	foreach i in comb_resp_avail_comb_1 comb_resp_avail_comb_8 comb_med_seek_care_comb comb_still_a_member {
	sum `i'
    graph bar `i', over(R_E_enum_name, sort(1) label(angle(45))) ///
    blabel(bar, position(center) format(%9.2f) color(white) size(tiny))  bar(5, color(black)) ///
	title(`T_`i'')
	graph export "${Figure}`F_`i''.eps", replace  
	}

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
