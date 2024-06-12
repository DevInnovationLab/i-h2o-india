
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Descriptive template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", clear

//generating relevant vars
gen sec_jjm_use=0
replace sec_jjm_use=1 if R_E_water_source_sec_1==1 & R_E_water_source_prim!=1
tab sec_jjm_use

foreach i in R_E_water_source_prim  {
	replace `i'=77 if `i'==-77
}

foreach v in R_E_water_treat R_E_water_source_prim R_E_jjm_drinking  {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
//CODE FOR DESCRIPTIVE TABLE FOR WATER USE AND TREATMENT
label var R_E_water_source_prim_1 "Using govt. taps as primary drinking water"
label var sec_jjm_use "Using govt. taps as secondary drinking water"
label var R_E_jjm_drinking_1 "Using JJM taps for drinking"
label var R_E_water_treat_1 "Using any water treatment method"
  
save "${DataTemp}Temp.dta", replace

global PanelA R_E_water_source_prim_1 sec_jjm_use R_E_jjm_drinking_1 R_E_water_treat_1

local PanelA "Endline TC"
local LabelPanelA "MaintableHH"
local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA "1"

* By R_Enr_treatment
foreach k in PanelA {

use "${DataTemp}Temp.dta", clear
***********
** Table **
***********
* Mean
	eststo  model1: estpost summarize $`k' if Treat_V==1
	eststo  model2: estpost summarize $`k' if Treat_V==0
	
	* Diff
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village)
	replace `i'=_b[1.Treat_V]
	}
	eststo  model3: estpost summarize $`k'
	
	* Significance
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=99996 if p_1> 0.1
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k'
	
	* P-value
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=p_1
	}
	eststo  model5: estpost summarize $`k'

	* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model6: estpost summarize $`k'
	
	* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model7: estpost summarize $`k'
	
	* Missing 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i')
	egen max_`i'=sum(`i'_Miss)
	replace `i'=max_`i'
	}
	eststo  model8: estpost summarize $`k'

	
esttab model1 model2 model3 model4 model5 model6 model7 model8 using "${Table}Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Number of days with diarrhea" "\hline Number of days with diarrhea" ///
				   "Using govt. taps as primary drinking water" "\textbf{Panel A. Water sources \& treatment} \\Using govt. taps as primary drinking water" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
}




