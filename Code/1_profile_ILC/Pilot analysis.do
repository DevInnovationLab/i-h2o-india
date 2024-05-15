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
gen perc_preg_women= count_1/192.22
br
sum count_1 perc_preg_women

//number of U5 children on avg
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a6_hhmember_age_<5
gen count_2=1 if R_Cen_a6_hhmember_age_>=0 & R_Cen_a6_hhmember_age_<=14
collapse (sum) count_1 count_2, by (R_Cen_village_name)
gen perc_U5child= count_1/192.22
sum count_1 perc_U5child

//number and avg pregnant women+children <5years per village
start_from_clean_file_Preglevel
gen count_1=1 if R_Cen_a23_wom_diarr_day_!=.| R_Cen_a23_wom_diarr_week_!=. | R_Cen_a23_wom_diarr_2week_!=.| R_Cen_a6_hhmember_age_<5
gen count_2=1 if ((R_Cen_a6_hhmember_age_>=15 & R_Cen_a6_hhmember_age_<=49) & R_Cen_a4_hhmember_gender_==2) | R_Cen_a6_hhmember_age_>=0 & R_Cen_a6_hhmember_age_<=14
collapse (sum) count_1 count_2, by (R_Cen_village_name)
gen perc_total= count_1/192.22
sum count_1 perc_total



//number of HHs with and pregnant women and children <5years per village
start_from_clean_file_Population
gen count1=1
forvalues i = 1/17 {
	gen C_total_pregnant_`i'= 1 if R_Cen_a7_pregnant_`i'==1
}
egen      C_total_pregnant_hh = rowtotal(C_total_pregnant_*)
label var C_total_pregnant_hh "Number of pregnant women"

gen count2= 1 if C_total_pregnant_hh>0
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


*	FOR JJM USERS
foreach k in  general {
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1


* Diff
	eststo  model10: estpost summarize $`k'
	
*Min
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1

	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model11: estpost summarize $`k'
	
	

esttab model10 model11 using "${Table}Water treatment_JJM users.tex", ///
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
	   title("Water treatment-JJM users") 
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

*	FOR JJM USERS
foreach k in  general {
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1


* Diff
	eststo  model16: estpost summarize $`k'
	
*SD
start_from_clean_file_Census
keep if R_Cen_a13_ws_sec_1==1 | R_Cen_a12_ws_prim_1==1

	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model17: estpost summarize $`k'
	
	

esttab model16 model17 using "${Table}Frequency of treatment_JJM USERS.tex", ///
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
	   title("Frequency of treatment_JJM Users") 
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

global diarrhea_U5 C_diarrhea_prev_child_1day C_diarrhea_prev_child_1week C_diarrhea_prev_child_2weeks ///
                         C_loosestool_child_1day C_loosestool_child_1week     C_loosestool_child_2weeks ///
						 C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week     C_diarrhea_comb_U5_2weeks   
						 
						 
global diarrhea_preg C_diarrhea_prev_wom_1day C_diarrhea_prev_wom_1week C_diarrhea_prev_wom_2weeks ///
                         C_loosestool_wom_1day C_loosestool_wom_1week     C_loosestool_wom_2weeks ///
						 C_diarrhea_comb_wom_1day C_diarrhea_comb_wom_1week     C_diarrhea_comb_wom_2weeks   
						 
local diarrhea_U5 "Diarrhea_U5"
local diarrhea_preg "Diarrhea_Preg"

start_from_clean_file_ChildLevel
keep if R_Cen_a6_hhmember_age_<2

decode R_Cen_village_name, gen(R_Cen_village_name_str)
drop if R_Cen_village_name_str== "Badaalubadi" | R_Cen_village_name_str=="Haathikambha"
gen treatment= 1 if R_Cen_village_name_str== "Birnarayanpur" | R_Cen_village_name_str=="Nathma"|R_Cen_village_name_str== "Badabangi"| R_Cen_village_name_str=="Naira"| R_Cen_village_name_str== "Bichikote"|R_Cen_village_name_str== "Karnapadu"| R_Cen_village_name_str=="Mukundpur"|R_Cen_village_name_str== "Tandipur"|R_Cen_village_name_str== "Gopi Kankubadi"|R_Cen_village_name_str== "Asada" 

replace treatment=0 if treatment==.

ttest C_diarrhea_comb_U5_2weeks, by(treatment)
						      

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
drop if R_FU_r_cen_village_name_str== "Badaalubadi" | R_FU_r_cen_village_name_str=="Haathikambha"
replace R_FU_fc_stored=0 if R_FU_fc_stored<0.14
replace R_FU_tc_stored=0 if R_FU_tc_stored<0.14
replace R_FU_fc_tap=0 if R_FU_fc_tap<0.14
replace R_FU_tc_tap=0 if R_FU_tc_tap<0.14
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
*Storage container- number and quantity
----------------------------------------------*/
use "${DataDeid}1_2_Followup_cleaned.dta", clear
drop if R_FU_r_cen_village_name_str== "Badaalubadi" 


forvalues i = 1/25 {
	gen container_size_midpt_`i'=. if R_FU_size_container_`i'!=.
	replace container_size_midpt_`i'= 2.5 if R_FU_size_container_`i'==1
	replace container_size_midpt_`i'= 7 if R_FU_size_container_`i'==2
	replace container_size_midpt_`i'= 12 if R_FU_size_container_`i'==3
	replace container_size_midpt_`i'= 17 if R_FU_size_container_`i'==4
	replace container_size_midpt_`i'= 20 if R_FU_size_container_`i'==5
}

egen avg_water_per_hh= rowmean(container_size_midpt_1 container_size_midpt_2 container_size_midpt_3 container_size_midpt_4 container_size_midpt_5 container_size_midpt_6 container_size_midpt_7 container_size_midpt_8 container_size_midpt_9 container_size_midpt_10 container_size_midpt_11 container_size_midpt_12 container_size_midpt_13 container_size_midpt_14 container_size_midpt_15 container_size_midpt_16 container_size_midpt_17 container_size_midpt_18 container_size_midpt_19 container_size_midpt_20 container_size_midpt_21 container_size_midpt_22 container_size_midpt_23 container_size_midpt_24 container_size_midpt_25)

replace avg_water_per_hh= round(avg_water_per_hh)
sum R_FU_quant_containers //avg number of containers
sum avg_water_per_hh // avg water at home


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



****************************************************************************************************************

/*----------------------------------------------
*Comparing data from baseline and followup data
----------------------------------------------*/

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Looking at Baseline HH survey data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataPre}1_1_Census_cleaned.dta", clear
merge 1:1 unique_id_num using "${DataDeid}1_2_Followup_cleaned.dta",gen(Merge_C_F)
keep if Merge_C_F==3


keep if R_FU_consent==1
tab R_FU_r_cen_village_name_str
drop if R_FU_r_cen_village_name_str=="Badaalubadi" | R_FU_r_cen_village_name_str=="Haathikambha"


**creating new vars
gen taste_satisfy=0
replace taste_satisfy=1 if R_FU_tap_taste_satisfied==1 | R_FU_tap_taste_satisfied==2
gen tap_trust=0
replace tap_trust= 1 if R_FU_tap_trust==1 | R_FU_tap_trust==2
gen tap_use_future= 0
replace tap_use_future= 1 if R_FU_tap_use_future==1 | R_FU_tap_use_future==2
gen stored_rc=0
replace stored_rc=1 if R_FU_fc_stored>0.14 & R_FU_fc_stored!=.
gen tap_rc=0
replace tap_rc=1 if R_FU_fc_tap>0.14 & R_FU_fc_tap!=.
gen stored_tc=0
replace stored_tc=1 if R_FU_tc_stored>0.14 & R_FU_tc_stored!=.
gen tap_tc=0
replace tap_tc=1 if R_FU_tc_tap>0.14 & R_FU_tc_tap!=.


gen secondary_water_source_JJM= 0
replace secondary_water_source_JJM= 1 if R_Cen_a13_water_source_sec_1==1
tab secondary_water_source_JJM

gen sec_jjm_use=0
replace sec_jjm_use=1 if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim!=1
tab secondary_water_source_JJM
tab sec_jjm_use

gen panchayat_village=0
replace panchayat_village=1 if R_FU_r_cen_village_name_str=="Asada" | R_FU_r_cen_village_name_str=="Jaltar" | R_FU_r_cen_village_name_str=="BK Padar" | R_FU_r_cen_village_name_str=="Mukundpur" | R_FU_r_cen_village_name_str=="Gudiabandh" | R_FU_r_cen_village_name_str=="Naira" | R_FU_r_cen_village_name_str=="Dangalodi" | R_FU_r_cen_village_name_str=="Karlakana" 


**assign treatment

gen treatment= 1 if R_FU_r_cen_village_name_str== "Birnarayanpur" | R_FU_r_cen_village_name_str=="Nathma"|R_FU_r_cen_village_name_str== "Badabangi"| R_FU_r_cen_village_name_str=="Naira"| R_FU_r_cen_village_name_str== "Bichikote"|R_FU_r_cen_village_name_str== "Karnapadu"| R_FU_r_cen_village_name_str=="Mukundpur"|R_FU_r_cen_village_name_str== "Tandipur"|R_FU_r_cen_village_name_str== "Gopi Kankubadi"|R_FU_r_cen_village_name_str== "Asada" 

replace treatment=0 if treatment==.

gen control= 1 if treatment==0
replace control=0 if treatment==1





foreach i in R_FU_water_source_prim  {
	replace `i'=77 if `i'==-77
}


foreach v in R_FU_water_treat R_FU_water_source_prim R_Cen_a18_jjm_drinking R_Cen_a13_water_source_sec_1 taste_satisfy tap_trust tap_use_future {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	


tempfile baseline
save `baseline', replace
save "${DataDeid}Baseline HH survey_cleaned.dta", replace




************ TTests and regressions

local baseline R_FU_water_source_prim_1 sec_jjm_use R_Cen_a18_jjm_drinking_1 R_FU_water_treat_1 taste_satisfy tap_trust tap_use_future tap_tc stored_tc tap_rc stored_rc  


*** CODE FOR DESCRIPTIVE TABLE
foreach k of local baseline {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
}

foreach k of local baseline {
		sum `k' if control==0
reg `k' control panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
}


*** CODE FOR REGRESSION TYPE TABLE

local baseline1 R_FU_water_source_prim_1 sec_jjm_use R_Cen_a18_jjm_drinking_1 R_FU_water_treat_1 
local baseline2 taste_satisfy tap_trust tap_use_future
local baseline3 tap_tc stored_tc tap_rc stored_rc 


local TitleA "Title"
local LabelA "TableA"
local  NoteA "Note: ABC."

foreach k of local baseline1 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
	 
}

esttab using "${Table}Comparison_BL_FU_1.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons  ///
   mtitle("\shortstack{Using JJM as\\Primary source}" "\shortstack{Using JJM as\\Secondary source}" "\shortstack{Drinking\\JJM water}" "\shortstack{Using any water\\treatment methods}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline2 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_2.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{Satisfied with\\JJM's taste}" "\shortstack{Confident that\\JJM is safe}" "\shortstack{Likely to use\\JJM in future}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline3 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_3.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{TRC$>$0.1ppm\\Running water}" "\shortstack{TRC$>$0.1ppm\\Stored water}" "\shortstack{FRC$>$0.1ppm\\Running water}" "\shortstack{FRC$>$0.1ppm\\Stored water}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*E.coli results at baseline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

import delimited "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/5_lab data/idexx/cleaned/BL_idexx_master_cleaned.csv", clear
drop if assignment=="NA"
drop if date=="2024-02-20T00:00:00Z"

//Cleaning the data for contamination (from field lab data)
replace cf_mpn=. if date=="2023-10-17T00:00:00Z" & village_name=="Mukundpur"
replace cf_mpn=. if date=="2023-11-04T00:00:00Z" & village_name=="Karnapadu"
replace cf_mpn=. if date=="2023-11-08T00:00:00Z" & village_name=="Mariguda"
replace cf_mpn=. if date=="2023-11-09T00:00:00Z" & village_name=="GopiKankubadi"

//creating new vars
gen positive_ecoli=1 if ec_mpn>0 & ec_mpn!=.
replace positive_ecoli=0 if ec_mpn==0

gen positive_totalcoliform=1 if cf_mpn>0 & cf_mpn!=.
replace positive_totalcoliform=0 if cf_mpn==0

gen treatment= 1 if assignment=="T"
replace treatment=0 if assignment=="C"

gen control= 1 if treatment==0
replace control= 0 if treatment==1

gen panchayat_village=0
replace panchayat_village=1 if village_name=="Asada" | village_name=="Jaltar" | village_name=="BK Padar" | village_name=="Mukundpur" | village_name=="Gudiabandh" | village_name=="Naira" | village_name=="Dangalodi" | village_name=="Karlakana" 

save "${DataDeid}Ecoli results baseline_cleaned.dta", replace

/*
ttest positive_ecoli if sample_type=="Tap", by(treatment)
ttest positive_ecoli if sample_type=="Stored", by(treatment)

ttest positive_totalcoliform if sample_type=="Tap", by(treatment)
ttest positive_totalcoliform if sample_type=="Stored", by(treatment)
*/


//regressions and ttests
sum positive_ecoli if sample_type=="Tap" & treatment==1
sum positive_ecoli if sample_type=="Tap" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 


sum positive_ecoli if sample_type=="Stored" & treatment==1
sum positive_ecoli if sample_type=="Stored" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 

sum ec_log if sample_type=="Tap" & treatment==1
sum ec_log if sample_type=="Tap" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 

sum ec_log if sample_type=="Stored" & treatment==1
sum ec_log if sample_type=="Stored" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 


sum positive_totalcoliform if sample_type=="Tap" & treatment==1
sum positive_totalcoliform if sample_type=="Tap" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Tap", cluster(village)  

sum positive_totalcoliform if sample_type=="Stored" & treatment==1
sum positive_totalcoliform if sample_type=="Stored" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Stored", cluster(village)

sum cf_log if sample_type=="Tap" & treatment==1
sum cf_log if sample_type=="Tap" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 


sum cf_log if sample_type=="Stored" & treatment==1
sum cf_log if sample_type=="Stored" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 

//log10 transformed density plots

twoway histogram ecoli_log10 if sample_type=="Tap" || kdensity ecoli_log10 if sample_type=="Tap", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Running water, ecoli baseline.jpg", as(jpg) name("Graph") quality(90)

twoway histogram ecoli_log10 if sample_type=="Stored" || kdensity ecoli_log10 if sample_type=="Stored", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Stored water, ecoli baseline.jpg", as(jpg) name("Graph") quality(90) replace


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Follow-up R1 survey data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataPre}1_1_Census_cleaned.dta", clear 
merge 1:1 unique_id_num using "${DataDeid}1_5_Followup_R1_cleaned.dta", gen(Merge_C_F) 
keep if Merge_C_F==3
keep if R_FU1_consent ==1
tab R_FU1_r_cen_village_name_str


**creating new vars
gen taste_satisfy=0
replace taste_satisfy=1 if R_FU1_tap_taste_satisfied==1 | R_FU1_tap_taste_satisfied==2
gen tap_trust=0
replace tap_trust= 1 if R_FU1_tap_trust==1 | R_FU1_tap_trust==2
gen tap_use_future= 0
replace tap_use_future= 1 if R_FU1_tap_use_future==1 | R_FU1_tap_use_future==2
gen stored_rc=0
replace stored_rc=1 if R_FU1_fc_stored>0.1 & R_FU1_fc_stored!=.
gen tap_rc=0
replace tap_rc=1 if R_FU1_fc_tap>0.1 & R_FU1_fc_tap!=.
gen stored_tc=0
replace stored_tc=1 if R_FU1_tc_stored>0.1 & R_FU1_tc_stored!=.
gen tap_tc=0
replace tap_tc=1 if R_FU1_tc_tap>0.1 & R_FU1_tc_tap!=.

gen secondary_water_source_JJM= 0
replace secondary_water_source_JJM= 1 if R_FU1_water_source_sec_1==1
tab secondary_water_source_JJM

gen sec_jjm_use=0
replace sec_jjm_use=1 if R_FU1_water_source_sec_1==1 & R_FU1_water_source_prim!=1
tab secondary_water_source_JJM
tab sec_jjm_use

gen panchayat_village=0
replace panchayat_village=1 if R_FU1_r_cen_village_name_str=="Asada" | R_FU1_r_cen_village_name_str=="Jaltar" | R_FU1_r_cen_village_name_str=="BK Padar" | R_FU1_r_cen_village_name_str=="Mukundpur" | R_FU1_r_cen_village_name_str=="Gudiabandh" | R_FU1_r_cen_village_name_str=="Naira" | R_FU1_r_cen_village_name_str=="Dangalodi" | R_FU1_r_cen_village_name_str=="Karlakana" 

**assign treatment

gen treatment= 1 if R_FU1_r_cen_village_name_str== "Birnarayanpur" | R_FU1_r_cen_village_name_str=="Nathma"|R_FU1_r_cen_village_name_str== "Badabangi"| R_FU1_r_cen_village_name_str=="Naira"| R_FU1_r_cen_village_name_str== "Bichikote"|R_FU1_r_cen_village_name_str== "Karnapadu"| R_FU1_r_cen_village_name_str=="Mukundpur"|R_FU1_r_cen_village_name_str== "Tandipur"|R_FU1_r_cen_village_name_str== "Gopi Kankubadi"|R_FU1_r_cen_village_name_str== "Asada" 

replace treatment=0 if treatment==.
                                                                  
gen control= 1 if treatment==0
replace control=0 if treatment==1


foreach i in R_FU1_water_source_prim  {
	replace `i'=77 if `i'==-77
}

foreach v in R_FU1_water_source_prim R_FU1_tap_use_drinking_yesno R_FU1_water_treat taste_satisfy tap_trust tap_use_future {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
**doing some chlorine data cleaning
replace R_FU1_fc_tap=. if R_FU1_fc_tap==999
replace R_FU1_tc_tap=. if R_FU1_tc_tap==999
replace R_FU1_tc_stored=. if R_FU1_tc_stored==999


	
tempfile followup
save `followup', replace


save "${DataDeid}Followup R1 survey_cleaned_additional vars.dta", replace

gen round=1
rename R_FU1_water_source_prim_1 R_FU_water_source_prim_1 
rename R_FU1_tap_use_drinking_yesno_1 R_FU_tap_use_drinking_yesno_1 
rename R_FU1_water_treat_1 R_FU_water_treat_1 

save "${DataDeid}Followup R1 survey_for pooling data.dta", replace


************ TTests and regressions
use "${DataDeid}Followup R1 survey_cleaned_additional vars.dta", clear
local followup R_FU1_water_source_prim_1 sec_jjm_use R_FU1_tap_use_drinking_yesno_1 R_FU1_water_treat_1 taste_satisfy_1 tap_trust_1 tap_use_future_1 tap_tc stored_tc tap_rc stored_rc

/*
foreach k of local followup {
	
ttest `k', by(treatment) 
}
*/

foreach k of local followup {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_FU1_r_cen_village_name_str) 
}


foreach k of local followup {
	
reg `k' control , cluster(R_FU1_r_cen_village_name_str) 
}

*** CODE FOR REGRESSION TYPE TABLE

local baseline1 R_FU1_water_source_prim_1 sec_jjm_use R_FU1_tap_use_drinking_yesno_1 R_FU1_water_treat_1
local baseline2 taste_satisfy tap_trust tap_use_future
local baseline3 tap_tc stored_tc tap_rc stored_rc 


local TitleA "Title"
local LabelA "TableA"
local  NoteA "Note: ABC."

foreach k of local baseline1 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_4.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{Using JJM as\\Primary source}" "\shortstack{Using JJM as\\Secondary source}" "\shortstack{Drinking\\JJM water}" "\shortstack{Using any water\\treatment methods}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline2 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_5.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{Satisfied with\\JJM's taste}" "\shortstack{Confident that\\JJM is safe}" "\shortstack{Likely to use\\JJM in future}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline3 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_6.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{TRC$>$0.1ppm\\Running water}" "\shortstack{TRC$>$0.1ppm\\Stored water}" "\shortstack{FRC$>$0.1ppm\\Running water}" "\shortstack{FRC$>$0.1ppm\\Stored water}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*E.coli results at followup R1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
import delimited "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/5_lab data/idexx/cleaned/R1_idexx_master_cleaned.csv", clear

split date, parse("-")
replace date3 = substr(date3, 1, 2)
egen date_comb= concat(date3 date2 date1)
gen date_comb_num = date(date_comb, "DMY")
format date_comb_num %td

duplicates tag sample_id, gen(dup)
sort sample_id
br if dup>0
/*
keep if dup>0
export excel using "${pilot}Duplicates in Ecoli data_Followup R1.xlsx", sheet("data") firstrow(var) cell(A1) sheetreplace
*/
bys sample_id (date_comb), sort: keep if _n == _N 
duplicates report sample_id 

gen positive_ecoli=1 if ec_mpn>0
replace positive_ecoli=0 if ec_mpn==0
gen positive_totalcoliform=1 if cf_mpn>0
replace positive_totalcoliform=0 if cf_mpn==0


gen treatment= 1 if assignment=="Treatment"
replace treatment=0 if assignment=="Control"

gen control= 1 if treatment==0
replace control= 0 if treatment==1

gen panchayat_village=0
replace panchayat_village=1 if village_name=="Asada" | village_name=="Jaltar" | village_name=="BK Padar" | village_name=="Mukundpur" | village_name=="Gudiabandh" | village_name=="Naira" | village_name=="Dangalodi" | village_name=="Karlakana" 

save "${DataDeid}Ecoli results followup R1_cleaned.dta", replace
gen round=1

save "${DataDeid}Ecoli results followup R1_for pooling.dta", replace

preserve
keep village_name village_id block_code block
duplicates drop village_name, force
save "${DataDeid}Village & block list.dta", replace
restore


******regressions and ttests
sum positive_ecoli if sample_type=="Tap" & treatment==1
sum positive_ecoli if sample_type=="Tap" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village)  

sum positive_ecoli if sample_type=="Stored" & treatment==1
sum positive_ecoli if sample_type=="Stored" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 

sum ec_log if sample_type=="Tap" & treatment==1
sum ec_log if sample_type=="Tap" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village)

sum ec_log if sample_type=="Stored" & treatment==1
sum ec_log if sample_type=="Stored" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 

sum positive_totalcoliform if sample_type=="Tap" & treatment==1
sum positive_totalcoliform if sample_type=="Tap" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Tap", cluster(village) 

sum positive_totalcoliform if sample_type=="Stored" & treatment==1
sum positive_totalcoliform if sample_type=="Stored" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Stored", cluster(village) 

sum cf_log if sample_type=="Tap" & treatment==1
sum cf_log if sample_type=="Tap" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 

sum cf_log if sample_type=="Stored" & treatment==1
sum cf_log if sample_type=="Stored" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 


//log10 transformed density plots

twoway histogram ecoli_log10 if sample_type=="Tap" || kdensity ecoli_log10 if sample_type=="Tap", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Running water, ecoli R1 FU.jpg", as(jpg) name("Graph") quality(90)

twoway histogram ecoli_log10 if sample_type=="Stored" || kdensity ecoli_log10 if sample_type=="Stored", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Stored water, ecoli R1 FU.jpg", as(jpg) name("Graph") quality(90)

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Follow-up R2 survey data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataPre}1_1_Census_cleaned.dta", clear 
merge 1:1 unique_id_num using "${DataDeid}1_6_Followup_R2_cleaned.dta", gen(Merge_C_F) 
keep if Merge_C_F==3
keep if R_FU2_consent ==1
tab R_FU2_r_cen_village_name_str


**creating new vars
gen taste_satisfy=0
replace taste_satisfy=1 if R_FU2_tap_taste_satisfied==1 | R_FU2_tap_taste_satisfied==2
gen tap_trust=0
replace tap_trust= 1 if R_FU2_tap_trust==1 | R_FU2_tap_trust==2
gen tap_use_future= 0
replace tap_use_future= 1 if R_FU2_tap_use_future==1 | R_FU2_tap_use_future==2
gen stored_rc=0
replace stored_rc=1 if R_FU2_fc_stored>0.1 & R_FU2_fc_stored!=.
gen tap_rc=0
replace tap_rc=1 if R_FU2_fc_tap>0.1 & R_FU2_fc_tap!=.
gen stored_tc=0
replace stored_tc=1 if R_FU2_tc_stored>0.1 & R_FU2_tc_stored!=.
gen tap_tc=0
replace tap_tc=1 if R_FU2_tc_tap>0.1 & R_FU2_tc_tap!=.

gen secondary_water_source_JJM= 0
replace secondary_water_source_JJM= 1 if R_FU2_water_source_sec_1==1
tab secondary_water_source_JJM

gen sec_jjm_use=0
replace sec_jjm_use=1 if R_FU2_water_source_sec_1==1 & R_FU2_water_source_prim!=1
tab secondary_water_source_JJM
tab sec_jjm_use

gen panchayat_village=0
replace panchayat_village=1 if R_FU2_r_cen_village_name_str=="Asada" | R_FU2_r_cen_village_name_str=="Jaltar" | R_FU2_r_cen_village_name_str=="BK Padar" | R_FU2_r_cen_village_name_str=="Mukundpur" | R_FU2_r_cen_village_name_str=="Gudiabandh" | R_FU2_r_cen_village_name_str=="Naira" | R_FU2_r_cen_village_name_str=="Dangalodi" | R_FU2_r_cen_village_name_str=="Karlakana" 

**assign treatment

gen treatment= 1 if R_FU2_r_cen_village_name_str== "Birnarayanpur" | R_FU2_r_cen_village_name_str=="Nathma"|R_FU2_r_cen_village_name_str== "Badabangi"| R_FU2_r_cen_village_name_str=="Naira"| R_FU2_r_cen_village_name_str== "Bichikote"|R_FU2_r_cen_village_name_str== "Karnapadu"| R_FU2_r_cen_village_name_str=="Mukundpur"|R_FU2_r_cen_village_name_str== "Tandipur"|R_FU2_r_cen_village_name_str== "Gopi Kankubadi"|R_FU2_r_cen_village_name_str== "Asada" 

replace treatment=0 if treatment==.
                                                                  
gen control= 1 if treatment==0
replace control=0 if treatment==1


foreach i in R_FU2_water_source_prim  {
	replace `i'=77 if `i'==-77
}

foreach v in R_FU2_water_source_prim R_FU2_tap_use_drinking_yesno R_FU2_water_treat taste_satisfy tap_trust tap_use_future {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	

	
tempfile followup2
save `followup2', replace


save "${DataDeid}Followup R2 survey_cleaned_additional vars.dta", replace

gen round=2
rename R_FU2_water_source_prim_1 R_FU_water_source_prim_1 
rename R_FU2_tap_use_drinking_yesno_1 R_FU_tap_use_drinking_yesno_1 
rename R_FU2_water_treat_1 R_FU_water_treat_1 

save "${DataDeid}Followup R2 survey_for pooling data.dta", replace

************ TTests and regressions
use "${DataDeid}Followup R2 survey_cleaned_additional vars.dta", clear
local followup2 R_FU2_water_source_prim_1 sec_jjm_use R_FU2_tap_use_drinking_yesno_1 R_FU2_water_treat_1 taste_satisfy_1 tap_trust_1 tap_use_future_1 tap_tc stored_tc tap_rc stored_rc

/*
foreach k of local followup {
	
ttest `k', by(treatment) 
}
*/ 

foreach k of local followup2 {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_FU2_r_cen_village_name_str) 
}


foreach k of local followup2 {
	
reg `k' control, cluster(R_FU2_r_cen_village_name_str) 
}


*** CODE FOR REGRESSION TYPE TABLE

local baseline1 R_FU2_water_source_prim_1 sec_jjm_use R_FU2_tap_use_drinking_yesno_1 R_FU2_water_treat_1
local baseline2 taste_satisfy tap_trust tap_use_future
local baseline3 tap_tc stored_tc tap_rc stored_rc 


local TitleA "Title"
local LabelA "TableA"
local  NoteA "Note: ABC."

foreach k of local baseline1 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_7.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{Using JJM as\\Primary source}" "\shortstack{Using JJM as\\Secondary source}" "\shortstack{Drinking\\JJM water}" "\shortstack{Using any water\\treatment methods}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline2 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_8.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{Satisfied with\\JJM's taste}" "\shortstack{Confident that\\JJM is safe}" "\shortstack{Likely to use\\JJM in future}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear

foreach k of local baseline3 {
    eststo: reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
	sum `k' if treatment==0
	estadd scalar Mean = r(mean)
}

esttab using "${Table}Comparison_BL_FU_9.tex",label se ar2 title("`TitleTakeup`k'_FE'" \label{`LabelTakeup`k'_FE'}) nonotes nobase nocons ///
   mtitle("\shortstack{TRC$>$0.1ppm\\Running water}" "\shortstack{TRC$>$0.1ppm\\Stored water}" "\shortstack{FRC$>$0.1ppm\\Running water}" "\shortstack{FRC$>$0.1ppm\\Stored water}") ///
			 stats(Mean N, fmt(%9.2fc %9.0fc) labels(`"Control mean"' `"Observations"')) ///
			 indicate("Block FE=*R_Cen_block_name" "Panchayat dummy=*panchayat_village") ///
			 starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.010) b(2) ///
			 substitute("{l}{\footnotesize" "{p{0.8\linewidth}}{\footnotesize" ///
			 "Edu: " "" "CHL Source:" "~~~" "DSW:" "~~~" "Gestation: " "Gestational age: " "Swindex: "  "~~~" ///
			 ) ///
			 addnote("`NoteTakeup`k'_FE'") ///	
			 replace
eststo clear


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*E.coli results at followup R2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
import delimited "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/5_lab data/idexx/cleaned/R2_idexx_master_cleaned.csv", clear

split submissiondate, parse("/")
replace submissiondate3 = substr(submissiondate3, 1, 4)
egen date_comb= concat(submissiondate2 submissiondate1 submissiondate3)
gen date_comb_num = date(date_comb, "DMY")
format date_comb_num %td

drop if field_blank ==1
drop if lab_blank==1
duplicates report sample_id


gen positive_ecoli=1 if ec_mpn>0
replace positive_ecoli=0 if ec_mpn==0
gen positive_totalcoliform=1 if cf_mpn>0
replace positive_totalcoliform=0 if cf_mpn==0

*gen ecoli_log10= log10(ec_mpn)
*gen tc_log10= log10(cf_mpn)

gen treatment= 1 if assignment=="T"
replace treatment=0 if assignment=="C"

gen control= 1 if treatment==0
replace control= 0 if treatment==1

gen panchayat_village=0
replace panchayat_village=1 if village_name=="Asada" | village_name=="Jaltar" | village_name=="BK Padar" | village_name=="Mukundpur" | village_name=="Gudiabandh" | village_name=="Naira" | village_name=="Dangalodi" | village_name=="Karlakana"

save "${DataDeid}Ecoli results followup R2_cleaned.dta", replace
merge m:1 village_name using "${DataDeid}Village & block list.dta"
gen round=2

save "${DataDeid}Ecoli results followup R2_for pooling.dta", replace
********Regressions

sum positive_ecoli if sample_type=="Tap" & treatment==1
sum positive_ecoli if sample_type=="Tap" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 

sum positive_ecoli if sample_type=="Stored" & treatment==1
sum positive_ecoli if sample_type=="Stored" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village) 

sum ec_log if sample_type=="Tap" & treatment==1
sum ec_log if sample_type=="Tap" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village)  

sum ec_log if sample_type=="Stored" & treatment==1
sum ec_log if sample_type=="Stored" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village)

sum positive_totalcoliform if sample_type=="Tap" & treatment==1
sum positive_totalcoliform if sample_type=="Tap" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Tap", cluster(village) 

sum positive_totalcoliform if sample_type=="Stored" & treatment==1
sum positive_totalcoliform if sample_type=="Stored" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Stored", cluster(village) 

sum cf_log if sample_type=="Tap" & treatment==1
sum cf_log if sample_type=="Tap" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village) 

sum cf_log if sample_type=="Stored" & treatment==1
sum cf_log if sample_type=="Stored" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village)


//log10 transformed density plots

twoway histogram ec_log if sample_type=="Tap" || kdensity ec_log if sample_type=="Tap", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Running water, ecoli R2 FU.jpg", as(jpg) name("Graph") quality(90)

twoway histogram ec_log if sample_type=="Stored" || kdensity ec_log if sample_type=="Stored", by(treatment) 
graph export "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data Checks/Stored water, ecoli R2 FU.jpg", as(jpg) name("Graph") quality(90)


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Follow-up R3 survey data
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataPre}1_1_Census_cleaned.dta", clear 
merge 1:1 unique_id_num using "${DataDeid}1_7_Followup_R3_cleaned.dta", gen(Merge_C_F) 
keep if Merge_C_F==3
keep if R_FU3_consent ==1
tab R_FU3_r_cen_village_name_str

**doing some chlorine data cleaning
replace R_FU3_fc_tap=. if R_FU3_fc_tap==999
replace R_FU3_tc_tap=. if R_FU3_tc_tap==999
replace R_FU3_tc_stored=. if R_FU3_tc_stored==999
replace R_FU3_fc_stored=. if R_FU3_fc_stored==999


**creating new vars
gen taste_satisfy=0
replace taste_satisfy=1 if R_FU3_tap_taste_satisfied==1 | R_FU3_tap_taste_satisfied==2
gen tap_trust=0
replace tap_trust= 1 if R_FU3_tap_trust==1 | R_FU3_tap_trust==2
gen tap_use_future= 0
replace tap_use_future= 1 if R_FU3_tap_use_future==1 | R_FU3_tap_use_future==2
gen stored_rc=0
replace stored_rc=1 if R_FU3_fc_stored>0.1 & R_FU3_fc_stored!=.
gen tap_rc=0
replace tap_rc=1 if R_FU3_fc_tap>0.1 & R_FU3_fc_tap!=.
gen stored_tc=0
replace stored_tc=1 if R_FU3_tc_stored>0.1 & R_FU3_tc_stored!=.
gen tap_tc=0
replace tap_tc=1 if R_FU3_tc_tap>0.1 & R_FU3_tc_tap!=.

gen secondary_water_source_JJM= 0
replace secondary_water_source_JJM= 1 if R_FU3_water_source_sec_1==1
tab secondary_water_source_JJM

gen sec_jjm_use=0
replace sec_jjm_use=1 if R_FU3_water_source_sec_1==1 & R_FU3_water_source_prim!=1
tab secondary_water_source_JJM
tab sec_jjm_use

gen panchayat_village=0
replace panchayat_village=1 if R_FU3_r_cen_village_name_str=="Asada" | R_FU3_r_cen_village_name_str=="Jaltar" | R_FU3_r_cen_village_name_str=="BK Padar" | R_FU3_r_cen_village_name_str=="Mukundpur" | R_FU3_r_cen_village_name_str=="Gudiabandh" | R_FU3_r_cen_village_name_str=="Naira" | R_FU3_r_cen_village_name_str=="Dangalodi" | R_FU3_r_cen_village_name_str=="Karlakana" 

**assign treatment

gen treatment= 1 if R_FU3_r_cen_village_name_str== "Birnarayanpur" | R_FU3_r_cen_village_name_str=="Nathma"|R_FU3_r_cen_village_name_str== "Badabangi"| R_FU3_r_cen_village_name_str=="Naira"| R_FU3_r_cen_village_name_str== "Bichikote"|R_FU3_r_cen_village_name_str== "Karnapadu"| R_FU3_r_cen_village_name_str=="Mukundpur"|R_FU3_r_cen_village_name_str== "Tandipur"|R_FU3_r_cen_village_name_str== "Gopi Kankubadi"|R_FU3_r_cen_village_name_str== "Asada" 

replace treatment=0 if treatment==.
                                                                  
gen control= 1 if treatment==0
replace control=0 if treatment==1


foreach i in R_FU3_water_source_prim  {
	replace `i'=77 if `i'==-77
}

foreach v in R_FU3_water_source_prim R_FU3_tap_use_drinking_yesno R_FU3_water_treat taste_satisfy tap_trust tap_use_future {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


tempfile followup3
save `followup3', replace


save "${DataDeid}Followup R3 survey_cleaned_additional vars.dta", replace

gen round=3
rename R_FU3_water_source_prim_1 R_FU_water_source_prim_1 
rename R_FU3_tap_use_drinking_yesno_1 R_FU_tap_use_drinking_yesno_1 
rename R_FU3_water_treat_1 R_FU_water_treat_1 

save "${DataDeid}Followup R3 survey_for pooling data.dta", replace

************ TTests and regressions
use "${DataDeid}Followup R3 survey_cleaned_additional vars.dta", clear
local followup3 R_FU3_water_source_prim_1 sec_jjm_use R_FU3_tap_use_drinking_yesno_1 R_FU3_water_treat_1 taste_satisfy_1 tap_trust_1 tap_use_future_1 tap_tc stored_tc tap_rc stored_rc

/*
foreach k of local followup {
	
ttest `k', by(treatment) 
}
*/ 

foreach k of local followup3 {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_FU3_r_cen_village_name_str) 
}


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*E.coli results at followup R3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
import delimited "/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/5_lab data/idexx/cleaned/R3_idexx_master_cleaned.csv", clear


duplicates report sample_id
//ABR testing was done and so we have duplicates. We keep only data without the ABR test duplicates
keep if abr==0
drop if sample_id==0
drop if sample_id==20344 & cf_95hi=="NA"


gen positive_ecoli=1 if ec_mpn>0
replace positive_ecoli=0 if ec_mpn==0
gen positive_totalcoliform=1 if cf_mpn>0
replace positive_totalcoliform=0 if cf_mpn==0

*gen ecoli_log10= log10(ec_mpn)
*gen tc_log10= log10(cf_mpn)

gen treatment= 1 if assignment=="Treatment"
replace treatment=0 if assignment=="Control"

gen control= 1 if treatment==0
replace control= 0 if treatment==1

gen panchayat_village=0
replace panchayat_village=1 if village_name=="Asada" | village_name=="Jaltar" | village_name=="BK Padar" | village_name=="Mukundpur" | village_name=="Gudiabandh" | village_name=="Naira" | village_name=="Dangalodi" | village_name=="Karlakana"

save "${DataDeid}Ecoli results followup R3_cleaned.dta", replace
*merge m:1 village_name using "${DataDeid}Village & block list.dta", force
gen round=3
destring block_code, replace
save "${DataDeid}Ecoli results followup R3_for pooling.dta", replace
********Regressions

sum positive_ecoli if sample_type=="Tap" & treatment==1
sum positive_ecoli if sample_type=="Tap" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village_name) 

sum positive_ecoli if sample_type=="Stored" & treatment==1
sum positive_ecoli if sample_type=="Stored" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village_name)

sum ec_log if sample_type=="Tap" & treatment==1
sum ec_log if sample_type=="Tap" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village_name)  

sum ec_log if sample_type=="Stored" & treatment==1
sum ec_log if sample_type=="Stored" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village_name) 


sum positive_totalcoliform if sample_type=="Tap" & treatment==1
sum positive_totalcoliform if sample_type=="Tap" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Tap", cluster(village_name) 

sum positive_totalcoliform if sample_type=="Stored" & treatment==1
sum positive_totalcoliform if sample_type=="Stored" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code  if sample_type=="Stored", cluster(village_name) 

sum cf_log if sample_type=="Tap" & treatment==1
sum cf_log if sample_type=="Tap" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village_name) 

sum cf_log if sample_type=="Stored" & treatment==1
sum cf_log if sample_type=="Stored" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village_name)


 

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Pooled Follow-up rounds survey data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

use "${DataDeid}Followup R1 survey_for pooling data.dta", clear
append using "${DataDeid}Followup R2 survey_for pooling data.dta"
append using "${DataDeid}Followup R3 survey_for pooling data.dta"


local followup R_FU_water_source_prim_1 sec_jjm_use R_FU_tap_use_drinking_yesno_1 R_FU_water_treat_1 taste_satisfy_1 tap_trust_1 tap_use_future_1 tap_tc stored_tc tap_rc stored_rc



foreach k of local followup {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name i.round, cluster(R_Cen_village_str) 
}


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*Pooled E.coli survey data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
use "${DataDeid}Ecoli results followup R1_for pooling.dta", clear
append using "${DataDeid}Ecoli results followup R2_for pooling.dta", force
append using "${DataDeid}Ecoli results followup R3_for pooling.dta", force


sum positive_ecoli if sample_type=="Tap" & treatment==1
sum positive_ecoli if sample_type=="Tap" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code i.round if sample_type=="Tap", cluster(village_name) 

sum positive_ecoli if sample_type=="Stored" & treatment==1
sum positive_ecoli if sample_type=="Stored" & treatment==0
reg positive_ecoli treatment panchayat_village i.block_code i.round if sample_type=="Stored", cluster(village_name) 

sum ec_log if sample_type=="Tap" & treatment==1
sum ec_log if sample_type=="Tap" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village_name)  

sum ec_log if sample_type=="Stored" & treatment==1
sum ec_log if sample_type=="Stored" & treatment==0
reg ec_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village_name)

sum positive_totalcoliform if sample_type=="Tap" & treatment==1
sum positive_totalcoliform if sample_type=="Tap" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code i.round  if sample_type=="Tap", cluster(village_name) 

sum positive_totalcoliform if sample_type=="Stored" & treatment==1
sum positive_totalcoliform if sample_type=="Stored" & treatment==0
reg positive_totalcoliform treatment panchayat_village i.block_code i.round if sample_type=="Stored", cluster(village_name) 


sum cf_log if sample_type=="Tap" & treatment==1
sum cf_log if sample_type=="Tap" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Tap", cluster(village_name) 

sum cf_log if sample_type=="Stored" & treatment==1
sum cf_log if sample_type=="Stored" & treatment==0
reg cf_log treatment panchayat_village i.block_code if sample_type=="Stored", cluster(village_name)



/*----------------------------------------------------
*Comparing data between baseline and endline census
------------------------------------------------------*/

use "${DataPre}1_1_Census_cleaned.dta", clear
tab R_Cen_consent
keep if R_Cen_consent==1
drop if R_Cen_village_str=="Badaalubadi" | R_Cen_village_str=="Hatikhamba"


//panchayat_village
gen panchayat_village=0
replace panchayat_village=1 if R_Cen_village_str=="Asada" | R_Cen_village_str=="Jaltar" | R_Cen_village_str=="BK Padar" | R_Cen_village_str=="Mukundpur" | R_Cen_village_str=="Gudiabandh" | R_Cen_village_str=="Naira" | R_Cen_village_str=="Dangalodi" | R_Cen_village_str=="Karlakana" 


//assign treatment

gen treatment= 1 if R_Cen_village_str== "Birnarayanpur" | R_Cen_village_str=="Nathma"|R_Cen_village_str== "Badabangi"| R_Cen_village_str=="Naira"| R_Cen_village_str== "Bichikote"|R_Cen_village_str== "Karnapadu"| R_Cen_village_str=="Mukundpur"|R_Cen_village_str== "Tandipur"|R_Cen_village_str== "Gopi Kankubadi"|R_Cen_village_str== "Asada" 

replace treatment=0 if treatment==.

gen control= 1 if treatment==0
replace control=0 if treatment==1


//generating relevant vars
gen sec_jjm_use=0
replace sec_jjm_use=1 if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim!=1
tab sec_jjm_use

foreach i in R_Cen_a12_water_source_prim  {
	replace `i'=77 if `i'==-77
}


foreach v in R_Cen_a16_water_treat R_Cen_a12_water_source_prim R_Cen_a18_jjm_drinking  {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	

//CODE FOR DESCRIPTIVE TABLE FOR WATER USE AND TREATMENT
local baseline R_Cen_a12_water_source_prim_1 sec_jjm_use R_Cen_a18_jjm_drinking_1 R_Cen_a16_water_treat_1

foreach k of local baseline {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
}


//CODE FOR DIARRHEA PREVELANCE
***Note: Run 2_1_Final_data code once before this section to generate the datasets for the diarrhea prevelance

local diarrhea_U5 C_diarrhea_prev_child_1day C_diarrhea_prev_child_1week C_diarrhea_prev_child_2weeks ///
                         C_loosestool_child_1day C_loosestool_child_1week     C_loosestool_child_2weeks ///
						 C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week     C_diarrhea_comb_U5_2weeks   
						 
						 
local diarrhea_preg C_diarrhea_prev_wom_1day C_diarrhea_prev_wom_1week C_diarrhea_prev_wom_2weeks ///
                         C_loosestool_wom_1day C_loosestool_wom_1week     C_loosestool_wom_2weeks ///
						 C_diarrhea_comb_wom_1day C_diarrhea_comb_wom_1week     C_diarrhea_comb_wom_2weeks   
						 


**U2 diarrhea
start_from_clean_file_ChildLevel
//panchayat_village
gen panchayat_village=0
replace panchayat_village=1 if R_Cen_village_str=="Asada" | R_Cen_village_str=="Jaltar" | R_Cen_village_str=="BK Padar" | R_Cen_village_str=="Mukundpur" | R_Cen_village_str=="Gudiabandh" | R_Cen_village_str=="Naira" | R_Cen_village_str=="Dangalodi" | R_Cen_village_str=="Karlakana" 


//assign treatment

gen treatment= 1 if R_Cen_village_str== "Birnarayanpur" | R_Cen_village_str=="Nathma"|R_Cen_village_str== "Badabangi"| R_Cen_village_str=="Naira"| R_Cen_village_str== "Bichikote"|R_Cen_village_str== "Karnapadu"| R_Cen_village_str=="Mukundpur"|R_Cen_village_str== "Tandipur"|R_Cen_village_str== "Gopi Kankubadi"|R_Cen_village_str== "Asada" 

replace treatment=0 if treatment==.

//keeping children under age 2
keep if R_Cen_a6_hhmember_age_<2

foreach k of local diarrhea_U5 {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
}


**U5 diarrhea
start_from_clean_file_ChildLevel
//panchayat_village
gen panchayat_village=0
replace panchayat_village=1 if R_Cen_village_str=="Asada" | R_Cen_village_str=="Jaltar" | R_Cen_village_str=="BK Padar" | R_Cen_village_str=="Mukundpur" | R_Cen_village_str=="Gudiabandh" | R_Cen_village_str=="Naira" | R_Cen_village_str=="Dangalodi" | R_Cen_village_str=="Karlakana" 


//assign treatment

gen treatment= 1 if R_Cen_village_str== "Birnarayanpur" | R_Cen_village_str=="Nathma"|R_Cen_village_str== "Badabangi"| R_Cen_village_str=="Naira"| R_Cen_village_str== "Bichikote"|R_Cen_village_str== "Karnapadu"| R_Cen_village_str=="Mukundpur"|R_Cen_village_str== "Tandipur"|R_Cen_village_str== "Gopi Kankubadi"|R_Cen_village_str== "Asada" 

replace treatment=0 if treatment==.

local diarrhea_U5 C_diarrhea_prev_child_1day C_diarrhea_prev_child_1week C_diarrhea_prev_child_2weeks ///
                         C_loosestool_child_1day C_loosestool_child_1week     C_loosestool_child_2weeks ///
						 C_diarrhea_comb_U5_1day C_diarrhea_comb_U5_1week     C_diarrhea_comb_U5_2weeks   
						 

foreach k of local diarrhea_U5 {
	sum `k' if treatment==1
	sum `k' if treatment==0
reg `k' treatment panchayat_village i.R_Cen_block_name, cluster(R_Cen_village_str) 
}



