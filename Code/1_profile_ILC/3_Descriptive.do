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
	* This do file exports.....
	
do "${Do_pilot}2_1_Final_data.do"

/* Example: 
tabout DATE ENUEMRERATOR using "${Table}Duration_Issue.tex", ///
       f(0c) style(tex) clab(_) replace ///
       topf("${Table}top.tex") botf("${Table}bot.tex")
*/

*********************
* 1) Progress table *
*********************
* Title: Overall statistics of recruitment and program registration
use "${DataFinal}Final_HH_Odisha.dta", clear
recode Merge_C_F 1=0 3=1

foreach i in R_Cen_consent R_FU_consent {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}

expand 2, generate(expand_n)
replace R_Cen_village_name=99999 if expand_n==1
keep Census R_Cen_village_name R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent
collapse  (sum) Census R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent, by(R_Cen_village_name)
	label define R_Cen_village_namel 11111 "Aribi" 11121 "Gopikankubadi" 11131 "Rengalpadu" 11141 "Panichhatra" 11151 "Bhujabala" 11161 "Mukundapur" 11411 "Bichikote" 11412 "Gudiabandha" 11421 "Jatili" 11431 "Mariguda" 11441 "Lachiamanaguda" 11451 "Naira" 11311 "Gulumunda" 11321 "Amiti" 11211 "Penikana" 11331 "Khilingira" 11221 "Gajigaon" 11231 "Barijhola" 11241 "Karlakana" 11251 "Biranarayanpur" 11252 "Kuljing" 11261 "Meerabali" 11271 "Pipalguda" 11281 "Nathma" 99999 "Total", modify
	label values R_Cen_village_name R_Cen_village_namel
	
	decode R_Cen_village_name, gen(R_Cen_village_name_str)
	label var Census  "Submission"
	label var R_Cen_village_name_str "Village"
	label var Non_R_Cen_consent "Refused"
	label var Non_R_FU_consent "Refused"
	label var R_FU_consent "Consented"
	label var R_Cen_consent "Consented"
	
global Variables R_Cen_village_name_str Census  R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent
texsave $Variables using "${Table}Table_Progress.tex", ///
        title("Overall Progress") footnote("Notes: This table presents the overall progress. The table is autocreated by 3_Descriptive.do.") replace varlabels frag location(htbp) headerlines("&\multicolumn{3}{c}{Census}&\multicolumn{2}{c}{Follow up}")

************************
* 2) Descriptive table *
*    Follow-up         *
************************
start_from_clean_file_Follow

************************
* 2) Descriptive table *
*    Census.           *
************************
start_from_clean_file_Census
global All R_Cen_a14_hh_member_count R_Cen_a2_gender_2 R_Cen_a2_gender_1 ///
           R_Cen_a22_water_source_prim_1 R_Cen_a22_water_source_prim_2 R_Cen_a22_water_source_prim_3 ///
           R_Cen_a26_water_treat_0 R_Cen_a26_water_treat_1 ///
           R_Cen_a230_water_sec_yn_0 R_Cen_a230_water_sec_yn_1 ///
           R_Cen_a25_water_sec_freq_2 R_Cen_a25_water_sec_freq_5

local All "Baseline balance among treatment arms"
local LabelAll "MaintableHH"
local ScaleAll "1"
local NoteAll "Notes: This table presents the household characteristics from the census. The table is autocreated by 3_Descriptive.do."

* By R_Enr_treatment
foreach k in All {
start_from_clean_file_Census

***********
** Table **
***********
* Mean
	eststo  model0: estpost summarize $`k'
	eststo  model1: estpost summarize $`k' if Treatment==0
	eststo  model2: estpost summarize $`k' if Treatment==1
	
	* Diff
start_from_clean_file_Census
	
	foreach i in $`k' {
	reg `i' i.Treatment
	replace `i'=_b[1.Treatment]
	}
	eststo  model4: estpost summarize $`k'

	* Significance
start_from_clean_file_Census

	foreach i in $`k' {
	reg `i' i.Treatment
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=99996 if p_1> 0.1
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model5: estpost summarize $`k'
	
	* P-value
start_from_clean_file_Census
	foreach i in $`k' {
	reg `i' i.Treatment
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=p_1
	}
	eststo  model6: estpost summarize $`k'
	
esttab model0 model1 model2 model4 model5 model6 using "${Table}Main_Balance_Census.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{Control}" "\shortstack[c]{Treat}" "Diff" "Sig" "P-value") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
}

	
