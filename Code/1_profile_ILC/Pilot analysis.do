*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Pilot data analysis
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports.....
	
	* Loocation of Nathma
	* Tank Location
	* HH survey: After selection code is over
	
do "${Do_pilot}2_1_Final_data.do"

/* Example: 
tabout DATE ENUEMRERATOR using "${Table}Duration_Issue.tex", ///
       f(0c) style(tex) clab(_) replace ///
       topf("${Table}top.tex") botf("${Table}bot.tex")
*/

/*----------------------------------------------
* 1) Descriptive table- 1 *
----------------------------------------------*/


*expand 2, generate(expand_n)
*replace R_Cen_village_name=99999 if expand_n==1

//number of child-bearing age women
start_from_clean_file_Preglevel
gen count_1=1 if (R_Cen_a6_hhmember_age_>=15 & R_Cen_a6_hhmember_age_<=49) & R_Cen_a4_hhmember_gender_==2
collapse (sum) count_1, by (R_Cen_village_name)
sum count_1

//number of children
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a6_hhmember_age_>=0 & R_Cen_a6_hhmember_age_<=14
collapse (sum) count_1, by (R_Cen_village_name)
sum count_1

//number of preg women on avg
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a23_wom_diarr_day_!=.| R_Cen_a23_wom_diarr_week_!=. | R_Cen_a23_wom_diarr_2week_!=.
gen count_2=1 if (R_Cen_a6_hhmember_age_>=15 & R_Cen_a6_hhmember_age_<=49) & R_Cen_a4_hhmember_gender_==2
collapse (sum) count_1 count_2, by (R_Cen_village_name)
gen perc_preg_women= count_1/count_2
br
sum count_1 perc_preg_women

//number of U5 children on avg
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a6_hhmember_age_<5
gen count_2=1 if R_Cen_a6_hhmember_age_>=0 & R_Cen_a6_hhmember_age_<=14
collapse (sum) count_1 count_2, by (R_Cen_village_name)
gen perc_U5child= count_1/count_2
sum count_1 perc_U5child

//number and avg pregnant women+children <5years per village
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a23_wom_diarr_day_!=.| R_Cen_a23_wom_diarr_week_!=. | R_Cen_a23_wom_diarr_2week_!=.| R_Cen_a6_hhmember_age_<5
gen count_2=1 if ((R_Cen_a6_hhmember_age_>=15 & R_Cen_a6_hhmember_age_<=49) & R_Cen_a4_hhmember_gender_==2) | R_Cen_a6_hhmember_age_>=0 & R_Cen_a6_hhmember_age_<=14
collapse (sum) count_1 count_2, by (R_Cen_village_name)
gen perc_total= count_1/count_2
sum count_1 perc_total



//number of HHs with and pregnant women and children <5years per village
start_from_clean_file_Population
gen count1=1
gen count2= 1 if R_Cen_screen_preg==1
gen count3= 1 if R_Cen_screen_u5child ==1
gen count4= 1 if C_Screened ==1
collapse (sum) count1 count2 count3 count4, by (R_Cen_village_name)
gen perc_hh_preg= count2/count1
gen perc_hh_U5= count3/count1
gen perc_hh_screened= count4/count1
sum count1 count2 count3 count4 perc_hh_preg perc_hh_U5 perc_hh_screened


/*---------------------------------------------------------------
* 2) JJM access and other main vars- distribition by categories *
-----------------------------------------------------------------*/
//JJM access
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	


global jjm_nonuse R_Cen_a18_jjm_drink_2 R_Cen_a18_jjm_drink_0 R_Cen_a18_reason_nodrink_1 R_Cen_a18_reason_nodrink_2 R_Cen_a18_reason_nodrink_3 R_Cen_a18_reason_nodrink_4 R_Cen_a18_reason_nodrink_999 R_Cen_a18_reason_nodrink__77 




foreach k in jjm_nonuse {
start_from_clean_file_Census


* Diff
	eststo  model6: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model7: estpost summarize $`k'
	
	

esttab model6 model7 using "${Table}JJM tap_non use.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Reasons for not using JJM taps") 
}


//Water sources
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	   
  
global primary_water R_Cen_a12_ws_prim_1 R_Cen_a12_ws_prim_2 R_Cen_a12_ws_prim_3 R_Cen_a12_ws_prim_4 R_Cen_a12_ws_prim_5 R_Cen_a12_ws_prim_6 R_Cen_a12_ws_prim_7 R_Cen_a12_ws_prim_8 R_Cen_a12_ws_prim_77 
		   
global secondary_water R_Cen_a13_water_sec_yn_0 ///
  R_Cen_a13_ws_sec_1 R_Cen_a13_ws_sec_2 R_Cen_a13_ws_sec_3 R_Cen_a13_ws_sec_4 R_Cen_a13_ws_sec_5 R_Cen_a13_ws_sec_6 R_Cen_a13_ws_sec_7 R_Cen_a13_ws_sec_8 R_Cen_a13_ws_sec__77 
           
local primary_water "Primary Water source"
local secondary_water "Secondary water source"



foreach k in primary_water secondary_water {
start_from_clean_file_Census


* Diff
	eststo  model5: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model4: estpost summarize $`k'
	
	

esttab model5 model4 using "${Table}Use of Water Sources_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Use of Water Sources-`k'") 
}


start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	 
keep if R_Cen_a12_ws_prim==1	
   
global secondary_JJMprim R_Cen_a13_water_sec_yn_0 ///
  R_Cen_a13_ws_sec_1 R_Cen_a13_ws_sec_2 R_Cen_a13_ws_sec_3 R_Cen_a13_ws_sec_4 R_Cen_a13_ws_sec_5 R_Cen_a13_ws_sec_6 R_Cen_a13_ws_sec_7 R_Cen_a13_ws_sec_8 R_Cen_a13_ws_sec__77 
           
local secondary_JJMprim "Secondary water source for JJM as primary water source"


foreach k in secondary_JJMprim {
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	 
keep if R_Cen_a12_ws_prim==1


* Diff
	eststo  model30: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	 
keep if R_Cen_a12_ws_prim==1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model31: estpost summarize $`k'
	
	

esttab model30 model31 using "${Table}Use of Water Sources_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   title("Secondary water sources for JJM as primary water source") 
}




start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	 
keep if R_Cen_a13_ws_sec_1==1
		   
global primary_JJMsecond R_Cen_a12_ws_prim_1 R_Cen_a12_ws_prim_2 R_Cen_a12_ws_prim_3 R_Cen_a12_ws_prim_4 R_Cen_a12_ws_prim_5 R_Cen_a12_ws_prim_6 R_Cen_a12_ws_prim_7 R_Cen_a12_ws_prim_8 R_Cen_a12_ws_prim_77
           
local primary_JJMsecond "Primary water source for JJM as secondary water source"



foreach k in primary_JJMsecond {
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1


* Diff
	eststo  model32: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model33: estpost summarize $`k'
	
	

esttab model32 model33 using "${Table}Use of Water Sources_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Primary water source for JJM as secondary water source") 
}


//NUMBER OF WATER SOURCES PEOPLE HAVE
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	 
rename R_Cen_a13_ws_sec__77 R_Cen_a13_ws_sec_77

egen count_secondary_sources= rowtotal(R_Cen_a13_ws_sec_1 R_Cen_a13_ws_sec_2 R_Cen_a13_ws_sec_3 R_Cen_a13_ws_sec_4 R_Cen_a13_ws_sec_5 R_Cen_a13_ws_sec_6 R_Cen_a13_ws_sec_7 R_Cen_a13_ws_sec_8 R_Cen_a13_ws_sec_77)

egen count_primary_sources= rowtotal (R_Cen_a12_ws_prim_1 R_Cen_a12_ws_prim_2 R_Cen_a12_ws_prim_3 R_Cen_a12_ws_prim_4 R_Cen_a12_ws_prim_5 R_Cen_a12_ws_prim_6 R_Cen_a12_ws_prim_7 R_Cen_a12_ws_prim_8 R_Cen_a12_ws_prim_77)

gen total_num_sources= count_secondary_sources+ count_primary_sources

levelsof total_num_sources
	foreach value in `r(levels)' {
		gen     total_num_sources`value'=0
		replace total_num_sources`value'=1 if total_num_sources==`value'
		replace total_num_sources`value'=. if total_num_sources==.
		label var total_num_sources`value' ": label (total_num_sources) `value'"
		
	}	
	
	
levelsof count_secondary_sources
	foreach value in `r(levels)' {
		gen     count_secondary_sources`value'=0
		replace count_secondary_sources`value'=1 if count_secondary_sources==`value'
		replace count_secondary_sources`value'=. if count_secondary_sources==.
		label var count_secondary_sources`value' ": label (count_secondary_sources) `value'"
		
	}	
	
levelsof count_primary_sources
	foreach value in `r(levels)' {
		gen     count_primary_sources`value'=0
		replace count_primary_sources`value'=1 if count_primary_sources==`value'
		replace count_primary_sources`value'=. if count_primary_sources==.
		label var count_primary_sources`value' ": label (count_primary_sources) `value'"
		
	}	

tempfile new
save `new', replace

global count_sources_prim_sec count_secondary_sources0 count_secondary_sources1 count_secondary_sources2 count_secondary_sources3 count_primary_sources1

global count_tot_sources total_num_sources1 total_num_sources2 total_num_sources3 total_num_sources4


foreach k in count_sources_prim_sec count_tot_sources {
use `new', clear

* Diff
	eststo  model32: estpost summarize $`k'
	
*Min
use `new', clear
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model33: estpost summarize $`k'
	
	

esttab model32 model33 using "${Table}Number of water sources_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Number of water sources_`k'") 
}




//JJM uses

start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	  

global jjm_uses C_Cen_a18_jjm_drinking ///
		   R_Cen_a20_jjm_use_1 R_Cen_a20_jjm_use_2 R_Cen_a20_jjm_use_3 R_Cen_a20_jjm_use_4 R_Cen_a20_jjm_use_5 R_Cen_a20_jjm_use_6 R_Cen_a20_jjm_use_7 
		   
foreach k in jjm_uses {
start_from_clean_file_Census


* Diff
	eststo  model8: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
	

esttab model8 model9 using "${Table}JJM water uses.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "No problem" "\textbf{No problem}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("JJM Water uses") 
}


foreach k in jjm_uses {
start_from_clean_file_Census
keep if R_Cen_a12_ws_prim_1==1  

* Diff
	eststo  model8: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
keep if R_Cen_a12_ws_prim_1==1 
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
	
	
	

esttab model8 model9 using "${Table}JJM water uses_for JJM primary source.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "No problem" "\textbf{No problem}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("JJM Water uses_for JJM primary source") 
}

//Water treatment

start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	   

 
global general R_Cen_a16_water_treat_0 R_Cen_a16_water_treat_1 R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 ///
		   R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type__77 R_Cen_a16_water_treat_type_999 
		   
global kids R_Cen_a17_water_treat_kids_0 R_Cen_a17_water_treat_kids_1 R_Cen_water_treat_kids_type_1 R_Cen_water_treat_kids_type_2 R_Cen_water_treat_kids_type_3 R_Cen_water_treat_kids_type_4 R_Cen_water_treat_kids_type77 R_Cen_water_treat_kids_type99
           
local general "Water treatment methods"
local kids "Water treatment methods for children"


foreach k in  general kids {
start_from_clean_file_Census


* Diff
	eststo  model10: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model11: estpost summarize $`k'
	
	

esttab model10 model11 using "${Table}Water treatment_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Water treatment-`k'") 
}



//Water treatment frequency
start_from_clean_file_Census
drop if R_Cen_village_name== 50601 | R_Cen_village_name== 30601	   


global general R_Cen_a16_water_treat_freq_1 R_Cen_a16_water_treat_freq_2 R_Cen_a16_water_treat_freq_3 R_Cen_a16_water_treat_freq_4 R_Cen_a16_water_treat_freq_5 R_Cen_a16_water_treat_freq_6 R_Cen_a16_water_treat_freq__77 
		   
global kids R_Cen_a17_treat_kids_freq_1 R_Cen_a17_treat_kids_freq_2 R_Cen_a17_treat_kids_freq_3 R_Cen_a17_treat_kids_freq_4 R_Cen_a17_treat_kids_freq_5 R_Cen_a17_treat_kids_freq_6 R_Cen_a17_treat_kids_freq__77
           
local general "Water treatment frequency"
local kids "Water treatment frequency for children"


foreach k in  general kids {
start_from_clean_file_Census


* Diff
	eststo  model16: estpost summarize $`k'
	
*SD
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model17: estpost summarize $`k'
	
	

esttab model16 model17 using "${Table}Frequency of treatment_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Frequency of treatment-`k'") 
}


//Water treatment frequency for stored water

/*
gen hh_num=1 
	egen total_hh= total(hh_num) if R_Cen_a16_stored_treat==1
	display total_hh
	local total_num_hhs = total_hh
graph pie hh_num, over(R_Cen_a16_stored_treat) pie(1,explode) plabel(_all percent) pie (1, color(maroon%70)) pie (2, color(maroon%50))

graph export "${Figure}Stored water treat_yesno.pdf", replace
*/

	
/*	
graph hbar (percent) hh_num, over(R_Cen_a16_stored_treat_freq, label) blabel(total, format(%9.0f)) bar(1, color(maroon) fintensity(30)) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	graph export "${Figure}Stored water treatment frequency.pdf", replace
*/
start_from_clean_file_Census

label define R_Cen_a16_stored_treat_freql 0 "Once at the time of storing" 1 "Each time stored water used" 2 "Daily" 3 "2-3 days in a day" 4 "Every 2-3 days in a week" 5 "No fixed schedule", modify
label values R_Cen_a16_stored_treat_freq R_Cen_a16_stored_treat_freql


levelsof R_Cen_a16_stored_treat
	foreach value in `r(levels)' {
		gen     R_Cen_a16_stored_treat`value'=0
		replace R_Cen_a16_stored_treat`value'=1 if R_Cen_a16_stored_treat==`value'
		replace R_Cen_a16_stored_treat`value'=. if R_Cen_a16_stored_treat==.
		label var R_Cen_a16_stored_treat`value' ": label (R_Cen_a16_stored_treat) `value'"
		
	}	
	
levelsof R_Cen_a16_stored_treat_freq
	foreach value in `r(levels)' {
		gen     R_Cen_a16_stored_treat_freq`value'=0
		replace R_Cen_a16_stored_treat_freq`value'=1 if R_Cen_a16_stored_treat_freq==`value'
		replace R_Cen_a16_stored_treat_freq`value'=. if R_Cen_a16_stored_treat_freq==.
		label var R_Cen_a16_stored_treat_freq`value' ": label (R_Cen_a16_stored_treat_freq) `value'"
		
	}
	
tempfile stored_water
save `stored_water', replace
	
	global stored R_Cen_a16_stored_treat0 R_Cen_a16_stored_treat1 R_Cen_a16_stored_treat_freq0 R_Cen_a16_stored_treat_freq1 R_Cen_a16_stored_treat_freq2 R_Cen_a16_stored_treat_freq3 R_Cen_a16_stored_treat_freq4 R_Cen_a16_stored_treat_freq5
	
	

foreach k in  stored  {
use `stored_water', clear


* Diff
	eststo  model16: estpost summarize $`k'
	
*SD
use `stored_water', clear
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model17: estpost summarize $`k'
	

	
use `stored_water', clear
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1


* Diff
	eststo  model18: estpost summarize $`k'
	
	
*SD
use `stored_water', clear
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model19: estpost summarize $`k'
	
	

esttab model16 model17 model18 model19 using "${Table}Frequency of treatment_stored water.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "SD") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&            _&    _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Frequency of treatment-stored water") 
}




/*----------------------------------------------
* 3) diarrhea incidence- preg women and children
----------------------------------------------*/

global diarrhea_U5 C_diarrhea_prev_child_1week C_diarrhea_prev_child_2weeks ///
                         C_loosestool_child_1week     C_loosestool_child_2weeks ///
						 C_diarrhea_comb_U5_1week     C_diarrhea_comb_U5_2weeks
						 
						 
global diarrhea_preg C_diarrhea_prev_wom_1week C_diarrhea_prev_wom_2weeks ///
                         C_loosestool_wom_1week     C_loosestool_wom_2weeks ///
						 C_diarrhea_comb_wom_1week     C_diarrhea_comb_wom_2weeks
						 
local diarrhea_U5 "Diarrhea_U5"
local diarrhea_preg "Diarrhea_Preg"
						      

//U2 diarrhea
foreach k in diarrhea_U5 {
start_from_clean_file_ChildLevel
keep if R_Cen_a6_hhmember_age_<2

* Mean
	eststo  model12: estpost summarize $`k'
* SD
start_from_clean_file_ChildLevel
keep if R_Cen_a6_hhmember_age_<2
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model13: estpost summarize $`k'
	
esttab model12  model13 using "${Table}Baseline diarrhea_U2.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Average/Total}" "C" "T" "Diff" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Baseline Diarrhea for U2 children") 
}


//U5 diarrhea
foreach k in diarrhea_U5 {
start_from_clean_file_ChildLevel

* Mean
	eststo  model12: estpost summarize $`k'
* SD
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model13: estpost summarize $`k'
	
esttab model12  model13 using "${Table}Baseline diarrhea_U5.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Average/Total}" "C" "T" "Diff" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Baseline Diarrhea for U5 children") 
}


//preg woman diarrhea
foreach k in diarrhea_preg {
start_from_clean_file_PregDiarr

* Mean
	eststo  model14: estpost summarize $`k'
* SD
start_from_clean_file_PregDiarr
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model15: estpost summarize $`k'
	
esttab model14  model15 using "${Table}Baseline diarrhea_preg.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Average/Total}" "C" "T" "Diff" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Baseline Diarrhea for Pregnant women") 
}


/*----------------------------------------------
* Chlorine readings summary
----------------------------------------------*/
use "${DataDeid}1_2_Followup_cleaned.dta", clear
drop if R_FU_r_cen_village_name_str== "Badaalubadi" 
tempfile working
save `working', replace	
   
   
global chlorine_readings R_FU_fc_stored R_FU_tc_stored R_FU_fc_tap R_FU_tc_tap

   
 foreach k in chlorine_readings {


* Mean
use `working', clear
foreach i in $`k' {
	egen m_`i'=mean(`i')
	replace `i'=m_`i'
	}
	eststo  model20: estpost summarize $`k'
	
* SD
use `working', clear
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model21: estpost summarize $`k'
	
* Min
use `working', clear
	foreach i in $`k' {
	egen m_`i'=min(`i')
	replace `i'=m_`i'
	}
	eststo  model22: estpost summarize $`k'
	
* Max
use `working', clear
	foreach i in $`k' {
	egen m_`i'=max(`i')
	replace `i'=m_`i'
	}
	eststo model23: estpost summarize $`k'
	
* Q1
use `working', clear
	foreach i in $`k' {
	egen m_`i'=pctile(`i'), p(25)
	replace `i'=m_`i'
	}
	eststo model24: estpost summarize $`k'
	
* Q2
use `working', clear
	foreach i in $`k' {
	egen m_`i'=pctile(`i'), p(50)
	replace `i'=m_`i'
	}
	eststo model25: estpost summarize $`k'
	
* Q3
use `working', clear
	foreach i in $`k' {
	egen m_`i'=pctile(`i'), p(75)
	replace `i'=m_`i'
	}
	eststo model26: estpost summarize $`k'
	
esttab model20  model21 model22  model24  model25 model26 model23 using "${Table}Chlorine readings summary.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Mean}" "SD" "Min" "Q1" "Q2" "Q3" "Max") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&              _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Chlorine readings summary") 
}



/*----------------------------------------------
*Storage container- source
----------------------------------------------*/
use `working', clear 
keep R_FU_source_container_*  unique_id_num 
reshape long R_FU_source_container_, i(unique_id_num) j(num)


levelsof R_FU_source_container_

foreach i in R_FU_source_container_  {
	replace `i'=77 if `i'==-77
}


levelsof R_FU_source_container_
	foreach value in `r(levels)' {
		gen     R_FU_source_container`value'=0
		replace R_FU_source_container`value'=1 if R_FU_source_container_==`value'
		replace R_FU_source_container`value'=. if R_FU_source_container_==.
		label var R_FU_source_container`value' ": label (R_FU_source_container_) `value'"
		
	}	
	
	
label variable R_FU_source_container1 "JJM Taps"
label var R_FU_source_container3 "Gram Panchayat/Other Community Standpipe"
label var R_FU_source_container4 "Manual handpump"
label var R_FU_source_container77 "Other"
tempfile container
save `container', replace


global container R_FU_source_container1 R_FU_source_container3 R_FU_source_container4 R_FU_source_container77

foreach k in container {


* Mean
use `container', clear 
foreach i in $`k' {
	egen m_`i'=mean(`i')
	replace `i'=m_`i'
	}
	eststo  model27: estpost summarize $`k'
	
* SD
use `container', clear 
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model28: estpost summarize $`k'
	
esttab model27  model28 using "${Table}Container_Source.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Mean}" "SD") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&                     _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Source of water for containers at home") 
}


/*----------------------------------------------
*Chlorine perceptions
----------------------------------------------*/
use `working', clear

foreach i in R_FU_tap_taste_desc R_FU_tap_smell  {
	replace `i'=77 if `i'==-77
}

levelsof R_FU_tap_taste_desc
	foreach value in `r(levels)' {
		gen     R_FU_tap_taste_desc`value'=0
		replace R_FU_tap_taste_desc`value'=1 if R_FU_tap_taste_desc==`value'
		replace R_FU_tap_taste_desc`value'=. if R_FU_tap_taste_desc==.
		label var R_FU_tap_taste_desc`value' ": label (R_FU_tap_taste_desc) `value'"
		
	}	
	
	
	levelsof R_FU_tap_smell
	foreach value in `r(levels)' {
		gen     R_FU_tap_smell`value'=0
		replace R_FU_tap_smell`value'=1 if R_FU_tap_smell==`value'
		replace R_FU_tap_smell`value'=. if R_FU_tap_smell==.
		label var R_FU_tap_smell`value' ": label (R_FU_tap_smell) `value'"
		
	}	
	
	
tempfile working2
save `working2', replace	
	
global taste R_FU_tap_taste_desc1 R_FU_tap_taste_desc2 R_FU_tap_taste_desc3 R_FU_tap_taste_desc77 R_FU_tap_taste_desc999
global smell R_FU_tap_smell1 R_FU_tap_smell2 R_FU_tap_smell3 R_FU_tap_smell77 R_FU_tap_smell999
	
	
foreach k in taste smell {


* Mean
use `working2', clear 
foreach i in $`k' {
	egen m_`i'=mean(`i')
	replace `i'=m_`i'
	}
	eststo  model29: estpost summarize $`k'
	
* SD
use `working2', clear 
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model30: estpost summarize $`k'
	
esttab model29  model30 using "${Table}Perceptions_`k'.tex", ///
	   replace label cell("mean (fmt(3) label(_))") mtitles("\shortstack[c]{Mean}" "SD") ///
	   substitute( ".000" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&                     _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Perceptions of taste & smell of JJM provided tap water") 
}
