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
* 1) Progress table- 1 (counts) *
----------------------------------------------*/
* Title: Overall statistics of recruitment and program registration
start_from_clean_file_Population
expand 2, generate(expand_n)
replace R_Cen_village_name=99999 if expand_n==1

gen     C_Census_C=0
replace C_Census_C=1 if C_Census==1 & Treat_V==0
gen     C_Census_T=0
replace C_Census_T=1 if C_Census==1 & Treat_V==1

keep C_Census C_Screened R_Cen_village_name R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available C_Census_C C_Census_T Non_C_Screened
*  R_FU_consent Non_R_FU_consent
collapse  (sum) C_Census R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available C_Screened C_Census_C C_Census_T Non_C_Screened, by(R_Cen_village_name)
	label define R_Cen_village_namel  ///
	      50601 "Badaalubadi (Raya-T)" 40201 "Bichikote (Padm)" 40202 "Gudiabandh (Padm)" 20201 "Jaltar (Gunu)"  ///
		 50101 "Dangalodi (Raya-T)" 50402 "Kuljing (Raya-T)" 50401 "Birnarayanpur (Raya-T)" 30602 "Mukundpur (Koln)" ///
	     50201 "Barijhola (Raya-C)" 50301 "Karlakana (Raya-C)"   50501 "Nathma (Raya-C)"  99999 "Total", modify
	label values R_Cen_village_name R_Cen_village_namel
	
	decode R_Cen_village_name, gen(R_Cen_village_name_str)
	label var C_Census  "Total"
	label var C_HH_not_available "Resp not available"
	label var C_Screened  "Screened"
	label var Non_C_Screened "Screened out"
	label var R_Cen_village_name_str "Village"
	label var Non_R_Cen_consent "Refuse"
	label var Non_R_Cen_instruction "No eligible resp"
	
	* label var Non_R_FU_consent "Refused"
	* label var R_FU_consent "Consented"
	label var R_Cen_consent "Consent given"
	label var C_Census_C "Control"
	label var C_Census_T "Treatment"
	
global Variables R_Cen_village_name_str C_Census C_HH_not_available Non_C_Screened C_Screened R_Cen_consent  Non_R_Cen_consent Non_R_Cen_instruction C_Census_C C_Census_T
texsave $Variables using "${Table}Table_Progress.tex", ///
        title("Overall Progress") footnote("Notes: This table presents the overall progress. The table is autocreated by 3_Descriptive.do.") replace varlabels frag location(htbp) headerlines("&\multicolumn{7}{c}{Census}&\multicolumn{2}{c}{By assignment}")

		
/*----------------------------------------------
* 1) Progress table- 2 (percentages) *
----------------------------------------------*/
* Title: Overall statistics of recruitment and program registration
start_from_clean_file_Population
expand 2, generate(expand_n)
replace R_Cen_village_name=99999 if expand_n==1


keep C_Census C_Screened R_Cen_village_name R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available  Non_C_Screened
*  R_FU_consent Non_R_FU_consent
collapse  (sum) C_Census R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available C_Screened Non_C_Screened, by(R_Cen_village_name)

gen consent_of_screen_perc= (R_Cen_consent/C_Screened)*100
*gen consent_of_approach_perc = (R_Cen_consent/C_Census)*100
gen not_available_perc = (C_HH_not_available/C_Census)*100
gen Non_Screened_perc= (Non_C_Screened/C_Census)*100
gen screened_perc= (C_Screened/C_Census)*100
gen refused_perc= (Non_R_Cen_consent/C_Screened)*100

local vars_rd consent_of_screen_perc not_available_perc Non_Screened_perc screened_perc refused_perc
foreach x of local vars_rd {
	gen `x'_rd= round(`x', 0.01)
}




	label define R_Cen_village_namel  ///
	      50601 "Badaalubadi (Raya-T)" 40201 "Bichikote (Padm)" 40202 "Gudiabandh (Padm)" 20201 "Jaltar (Gunu)"  ///
		 50101 "Dangalodi (Raya-T)" 50402 "Kuljing (Raya-T)" 50401 "Birnarayanpur (Raya-T)" 30602 "Mukundpur (Koln)" ///
	     50201 "Barijhola (Raya-C)" 50301 "Karlakana (Raya-C)"   50501 "Nathma (Raya-C)"  99999 "Total", modify
	label values R_Cen_village_name R_Cen_village_namel
	
	decode R_Cen_village_name, gen(R_Cen_village_name_str)
	label var C_Census  "Total"
	label var consent_of_screen_perc_rd "%"
	*label var consent_of_approach_perc "% of consent among approached"
	label var not_available_perc_rd  "%"
	label var Non_Screened_perc_rd "%"
	label var screened_perc_rd "%"
	label var refused_perc_rd "%"
	label var R_Cen_village_name_str "Village"
	*label var Non_R_Cen_instruction "No eligible resp"
	label var C_Screened  "No."
	label var Non_C_Screened "No."
	label var R_Cen_consent "No." 
	label var Non_R_Cen_consent "No."
	label var C_HH_not_available "No."

keep C_Census R_Cen_village_name_str C_Screened Non_C_Screened R_Cen_consent Non_R_Cen_consent consent_of_screen_perc_rd not_available_perc_rd Non_Screened_perc_rd screened_perc_rd refused_perc_rd C_HH_not_available
	
global Variables R_Cen_village_name_str C_Census C_HH_not_available not_available_perc_rd Non_C_Screened Non_Screened_perc_rd C_Screened screened_perc_rd R_Cen_consent consent_of_screen_perc_rd Non_R_Cen_consent refused_perc_rd
texsave $Variables using "${Table}Table_Progress_2.tex", ///
        title("Overall Progress- Village-wise Percentages") footnote("Notes: This table presents the overall progress in village-wise percentages. The table is autocreated by 3_Descriptive.do.") replace varlabels frag location(htbp) headerlines("&&\multicolumn{2}{c}{Not available}&\multicolumn{2}{c}{Screened out}&\multicolumn{2}{c}{Screened}&\multicolumn{2}{c}{Consented}&\multicolumn{2}{c}{Refused}")
		
		
		
/*----------------------------------------------
* 1) Progress table- 3 (date-wise) *
----------------------------------------------*/
* Title: Overall statistics of recruitment and program registration
start_from_clean_file_Population
/*
gen work_day = dofc(R_Cen_starttime)
format work_day %td
*/
keep C_Census C_Screened R_Cen_village_name R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available Non_C_Screened month_day 
label define R_Cen_village_namel  ///
	      50601 "Badaalubadi" 40201 "Bichikote" 40202 "Gudiabandh" 20201 "Jaltar"  ///
		 50101 "Dangalodi" 50402 "Kuljing" 50401 "Birnarayanpur" 30602 "Mukundpur" ///
	     50201 "Barijhola" 50301 "Karlakana"   50501 "Nathma" , modify
		 
		 label values R_Cen_village_name R_Cen_village_namel
		 
		 

collapse  (sum) C_Census R_Cen_consent Non_R_Cen_consent Non_R_Cen_instruction C_HH_not_available C_Screened Non_C_Screened, by(R_Cen_village_name month_day)

drop if month_day=="  2023"
	
	
	decode R_Cen_village_name, gen(R_Cen_village_name_str)
	label var C_Census  "Total"
	label var C_HH_not_available "Resp not available"
	label var C_Screened  "Screened"
	label var Non_C_Screened "Screened out"
	label var R_Cen_village_name_str "Village"
	label var Non_R_Cen_consent "Refuse"
	label var Non_R_Cen_instruction "No eligible resp"
	label var month_day "Date"
	
	* label var Non_R_FU_consent "Refused"
	* label var R_FU_consent "Consented"
	label var R_Cen_consent "Consent given"

	
global Variables month_day R_Cen_village_name_str C_Census C_Screened R_Cen_consent Non_R_Cen_consent 
texsave $Variables using "${Table}Table_Progress_3.tex", ///
        title("Overall Progress- Datewise for villages") footnote("Notes: This table presents the overall progress. The table is autocreated by 3_Descriptive.do.") replace varlabels frag location(htbp) 

/*----------------------------------------------
2) Descriptive table: Enumerator level
----------------------------------------------*/
* Michelle add more variables and enumerators
//1. Checking number of screened and screened out cases by enumerator

start_from_clean_file_Population

global Two R_Cen_survey_time R_Cen_intro_duration R_Cen_consent_duration ///
R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration	
	
	label var R_Cen_survey_time "Survey duration"
	label var R_Cen_intro_duration "Intro duration"
	label var R_Cen_consent_duration "Consent duration"
	label var R_Cen_sectionB_duration "HH demographics duration"
	label var R_Cen_sectionC_duration "Water section duration"
	label var R_Cen_sectionD_duration "JJM tap section duration"
	label var R_Cen_sectionE_duration "Resp. health section duration"
	label var R_Cen_sectionF_duration "Child health section duration"
	label var R_Cen_sectionG_duration "Assets section duration"
	label var R_Cen_sectionH_duration "Concluding section duration"
	
	
foreach k in Two {
start_from_clean_file_Population
* Mean
	eststo  model0: estpost summarize $`k'

*Min
start_from_clean_file_Population
	foreach i in $`k' {
	egen m_`i'=min(`i')
	replace `i'=m_`i'
	}
	eststo  model1: estpost summarize $`k'

* Max
	start_from_clean_file_Population
	foreach i in $`k' {
	egen m_`i'=max(`i')
	replace `i'=m_`i'
	}
	eststo model2: estpost summarize $`k'
	
	
	esttab model0  model1  model2  using "${Table}Average_overall_productivity_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}"  "Minimum" "Maximum") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("Overall survey and section duration statistics (in minutes)") 
}




//Team 1- 104, 105, 106, 107, 108	
start_from_clean_file_Population

global All1 C_Screened R_Cen_consent Non_R_Cen_consent C_HH_not_available 
local All1 "Team 1- Table by enumerator"
local LabelAll1 "MainEnum"
local ScaleAll1 "1"
local NoteAll1 "Notes: This table presents the enumerator level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All1 {
start_from_clean_file_Population
* Mean
	eststo  model0:   estpost summarize $`k'
	eststo  model104: estpost summarize $`k' if R_Cen_enum_name==104
	eststo  model105: estpost summarize $`k' if R_Cen_enum_name==105
	eststo  model106: estpost summarize $`k' if R_Cen_enum_name==106
	eststo  model107: estpost summarize $`k' if R_Cen_enum_name==107
	eststo  model108: estpost summarize $`k' if R_Cen_enum_name==108
	eststo  model109: estpost summarize $`k' if R_Cen_enum_name==109
	
	** ADD MORE
esttab model0 model104 model105 model106 model107 model108 model109 using "${Table}Main_Enum_Census_1.tex", ///
	   replace label cell("sum (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{Santosh\\Kumar}" "\shortstack[c]{Bibhar\\Pankaj}" ///
	   "\shortstack[c]{Madhusmita\\Samal}" "\shortstack[c]{Rekha\\Behera}" ///
	   "\shortstack[c]{Sanjukta\\Chichuan}" "\shortstack[c]{Swagatika\\Behera}") substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchayat village" "\textbf{Panchayat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("Team 1: Surveys completed by enumerator") note("`Note`k''") 
}




//Team 2- 110, 111, 113, 115, 117, 119
local All1 "Team 2- Table by enumerator"
local LabelAll1 "MainEnum"
local ScaleAll1 "1"
local NoteAll1 "Notes: This table presents the enumerator level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All1 {
start_from_clean_file_Population
* Mean
	eststo  model0:   estpost summarize $`k'
	eststo  model110: estpost summarize $`k' if R_Cen_enum_name==110
	eststo  model111: estpost summarize $`k' if R_Cen_enum_name==111
	eststo  model113: estpost summarize $`k' if R_Cen_enum_name==113
	eststo  model115: estpost summarize $`k' if R_Cen_enum_name==115
	eststo  model117: estpost summarize $`k' if R_Cen_enum_name==117
	eststo  model119: estpost summarize $`k' if R_Cen_enum_name==119
	** ADD MORE
		
esttab model0 model110 model111 model113 model115 model117 model119 using "${Table}Main_Enum_Census_2.tex", ///
	   replace label cell("sum (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{Sarita\\Bhatra}" "\shortstack[c]{Abhishek\\Rath}" ///
	   "\shortstack[c]{Mangulu\\Bagh}" "\shortstack[c]{Kuna\\Charan}" ///
	   "\shortstack[c]{Jitendra\\Bagh}" "\shortstack[c]{Pramodini\\Gahir}")  substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchayat village" "\textbf{Panchayat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("Team 2: Surveys completed by enumerator") note("`Note`k''") 
}




start_from_clean_file_Population
global All2 R_Cen_survey_time R_Cen_intro_duration R_Cen_consent_duration ///
R_Cen_sectionB_duration R_Cen_sectionC_duration R_Cen_sectionD_duration R_Cen_sectionE_duration R_Cen_sectionF_duration R_Cen_sectionG_duration R_Cen_sectionH_duration 

	label var R_Cen_survey_time "Survey duration"
	label var R_Cen_intro_duration "Intro duration"
	label var R_Cen_consent_duration "Consent duration"
	label var R_Cen_sectionB_duration "HH demographics duration"
	label var R_Cen_sectionC_duration "Water section duration"
	label var R_Cen_sectionD_duration "JJM tap section duration"
	label var R_Cen_sectionE_duration "Resp. health section duration"
	label var R_Cen_sectionF_duration "Child health section duration"
	label var R_Cen_sectionG_duration "Assets section duration"
	label var R_Cen_sectionH_duration "Concluding section duration"
	
	
local All2 "Team 1- Table by enumerator"
local LabelAll2 "MainEnum"
local ScaleAll2 "1"
local NoteAll2 "Notes: This table presents the enumerator level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All2 {
start_from_clean_file_Population
* Mean
	eststo  model0:   estpost summarize $`k'
	eststo  model104: estpost summarize $`k' if R_Cen_enum_name==104
	eststo  model105: estpost summarize $`k' if R_Cen_enum_name==105
	eststo  model106: estpost summarize $`k' if R_Cen_enum_name==106
	eststo  model107: estpost summarize $`k' if R_Cen_enum_name==107
	eststo  model108: estpost summarize $`k' if R_Cen_enum_name==108
	eststo  model109: estpost summarize $`k' if R_Cen_enum_name==109

	** ADD MORE
		
esttab model0 model104 model105 model106 model107 model108 model109 using "${Table}Main_Enum_Census_3.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "\shortstack[c]{Santosh\\Kumar}" "\shortstack[c]{Bibhar\\Pankaj}" ///
	   "\shortstack[c]{Madhusmita\\Samal}" "\shortstack[c]{Rekha\\Behera}" ///
	   "\shortstack[c]{Sanjukta\\Chichuan}" "\shortstack[c]{Swagatika\\Behera}")  substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&     _\\" "" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchayat village" "\textbf{Panchayat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("Team 1: Survey \& Section duration by enumerator (in minutes)") note("`Note`k''") 
}


//Team 2- 110, 111, 113, 115, 117, 119
local All2 "Team 2- Table by enumerator"
local LabelAll2 "MainEnum"
local ScaleAll2 "1"
local NoteAll2 "Notes: This table presents the enumerator level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All2 {
start_from_clean_file_Population
* Mean
	eststo  model0:   estpost summarize $`k'
	eststo  model110: estpost summarize $`k' if R_Cen_enum_name==110
	eststo  model111: estpost summarize $`k' if R_Cen_enum_name==111
	eststo  model113: estpost summarize $`k' if R_Cen_enum_name==113
	eststo  model115: estpost summarize $`k' if R_Cen_enum_name==115
	eststo  model117: estpost summarize $`k' if R_Cen_enum_name==117
	eststo  model119: estpost summarize $`k' if R_Cen_enum_name==119
	** ADD MORE
		
esttab model0 model110 model111 model113 model115 model117 model119 using "${Table}Main_Enum_Census_4.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "\shortstack[c]{Sarita\\Bhatra}" "\shortstack[c]{Abhishek\\Rath}" ///
	   "\shortstack[c]{Mangulu\\Bagh}" "\shortstack[c]{Kuna\\Charan}" ///
	   "\shortstack[c]{Jitendra\\Bagh}" "\shortstack[c]{Pramodini\\Gahir}")  substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&     _\\" "" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchayat village" "\textbf{Panchayat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("Team 2: Survey \& Section duration by enumerator (in minutes)") note("`Note`k''") 
	   
}



*******Daily avg. productivity by enumerator
start_from_clean_file_Population

gen work_day = dofc(R_Cen_starttime)
format work_day %td

gen count=1
egen total_surveys= total(count)
bys R_Cen_enum_name: egen total_surveys_by_enum= total(count) if R_Cen_consent==1
*bys work_day: egen total_surveys_by_day= total(count) if R_Cen_consent==1

label define R_Cen_enum_namel  ///
	      104 "Santosh Kumar" 105 "Bibhar Pankaj" 106 "Madhusmita Samal" 107 "Rekha Behera"  ///
		 108 "Sanjukta Chichuan" 109 "Swagatika Behera" 110 "Sarita Bhatra" 111 "Abhishek Rath" ///
	     113 "Mangulu Bagh" 115 "Kuna Charan"   117 "Jitendra Bagh"  119 "Pramodini Gahir", modify
	label values R_Cen_enum_name R_Cen_enum_namel

decode R_Cen_enum_name, gen(R_Cen_enum_name_str)
keep  R_Cen_consent work_day R_Cen_enum_name total_surveys_by_enum total_surveys R_Cen_enum_name_str
collapse (count) total_surveys_by_enum, by (R_Cen_enum_name_str)
//total days of work so far is 11
gen daily_avg_productivity= total_surveys_by_enum/11 
gen daily_avg_productivity_rd= round(daily_avg_productivity, 0.01)

	
	label var total_surveys_by_enum  "Total surveys completed"
	label var R_Cen_enum_name_str "Enumerator name"
	label var daily_avg_productivity_rd  "Daily average productivity"

global Variables R_Cen_enum_name_str total_surveys_by_enum daily_avg_productivity_rd
texsave $Variables using "${Table}Daily average Productivity_census_by_enumerator.tex", ///
        title("Daily average Productivity for census,by enumerator") replace varlabels frag location(htbp) 

*/

/*----------------------------------------------
2) Descriptive table
Village level
----------------------------------------------*/
global All BlockCode_1 BlockCode_2 BlockCode_3 BlockCode_4 BlockCode_5 Panchatvillage ///
           V_Num_HH V_Num_HH_Categ_1 V_Num_HH_Categ_2 V_Num_HH_Categ_3 ///
		   km_block

local All "Pre-survey balance among treatment arms by village"
local LabelAll "MainVillage"
local ScaleAll "1"
local NoteAll "Notes: This table presents the village level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All {
start_from_clean_file_Village
* Mean
	eststo model0: estpost summarize $`k'
	eststo model1: estpost summarize $`k' if Treat_V==0
	eststo model2: estpost summarize $`k' if Treat_V==1
	
* Diff
start_from_clean_file_Village
	foreach i in $`k' {
	reg `i' i.Treat_V
	replace `i'=_b[1.Treat_V]
	}
	eststo  model4: estpost summarize $`k'

* Significance
start_from_clean_file_Village
	foreach i in $`k' {
	reg `i' i.Treat_V
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=99996 if p_1> 0.1
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model5: estpost summarize $`k'
	
	* P-value
start_from_clean_file_Village
	foreach i in $`k' {
	reg `i' i.Treat_V
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=p_1
	}
	eststo  model6: estpost summarize $`k'
	
esttab model0 model1 model2 model4 model5 model6 using "${Table}Main_Balance_Village.tex", replace ///
	   cell("mean (fmt(2) label(_))") ///
	   mtitles("\shortstack[c]{Total}" "\shortstack[c]{Control}" "\shortstack[c]{Treat}" "Diff" "Sig" "P-value") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _\\" "" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchayat village" "\textbf{Panchayat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
}


/*----------------------------------------------
2) Descriptive table
   Census
----------------------------------------------*/
start_from_clean_file_Census
global demographics R_Cen_a2_hhmember_count R_Cen_a10_hhhead_gender_1 R_Cen_a10_hhhead_gender_2  C_total_U5child_hh C_total_pregnant_hh
		   
global primary_water R_Cen_a12_ws_prim_1 R_Cen_a12_ws_prim_2 R_Cen_a12_ws_prim_3 R_Cen_a12_ws_prim_4 R_Cen_a12_ws_prim_8 R_Cen_a12_ws_prim_77 
		   
global secondary_water R_Cen_a13_water_sec_yn_0 ///
  R_Cen_a13_ws_sec_1 R_Cen_a13_ws_sec_2 R_Cen_a13_ws_sec_3 R_Cen_a13_ws_sec_4 R_Cen_a13_ws_sec_5 R_Cen_a13_ws_sec_6 R_Cen_a13_ws_sec_7 R_Cen_a13_ws_sec_8 R_Cen_a13_ws_sec__77 
  
global treat_water R_Cen_a16_water_treat_0 R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 ///
		   R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type__77 R_Cen_a16_water_treat_type_999 
		   
global treat_water_kids R_Cen_water_treat_kids_type_1 R_Cen_water_treat_kids_type_2 R_Cen_water_treat_kids_type_3 R_Cen_water_treat_kids_type_4 R_Cen_water_treat_kids_type77 R_Cen_water_treat_kids_type99
           
global jjm_uses C_Cen_a18_jjm_drinking ///
		   R_Cen_a20_jjm_use_1 R_Cen_a20_jjm_use_2 R_Cen_a20_jjm_use_3 R_Cen_a20_jjm_use_4 R_Cen_a20_jjm_use_5 R_Cen_a20_jjm_use_6 R_Cen_a20_jjm_use_7 
		   
local demographics "Baseline balance among treatment arms- Household demographics"
local primary_water "Baseline balance among treatment arms- Primary water source"
local secondary_water "Baseline balance among treatment arms- Secondary water source"
local treat_water "Baseline balance among treatment arms- Water treatment methods"
local treat_water_kids "Baseline balance among treatment arms- Water treatment methods for U5 children"
local jjm_uses "Baseline balance among treatment arms- JJM water uses"


local LabelAll "MaintableHH"
local ScaleAll "1"
local Notedemographics "Notes: This table presents the household demographics from the census. The table is autocreated by 3_Descriptive.do."
local Noteprimary_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notesecondary_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notetreat_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notetreat_water_kids "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notejjm_uses "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."

foreach k in demographics primary_water secondary_water treat_water treat_water_kids jjm_uses {
start_from_clean_file_Census

* Mean
	eststo  model0: estpost summarize $`k'
* Diff
	eststo  model1: estpost summarize $`k' if Treat_V==0
	eststo  model2: estpost summarize $`k' if Treat_V==1
	
start_from_clean_file_Census
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	replace `i'=_b[1.Treat_V]
	}
	eststo  model3: estpost summarize $`k'

	* Significance
start_from_clean_file_Census
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=99996 if p_1> 0.1
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k'
	
	* P-value
start_from_clean_file_Census
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=p_1
	}
	eststo  model5: estpost summarize $`k'

* Min
start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=min(`i')
	replace `i'=m_`i'
	}
	eststo  model6: estpost summarize $`k'
* Max
	start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=max(`i')
	replace `i'=m_`i'
	}
	eststo model7: estpost summarize $`k'
* Missing 
	start_from_clean_file_Census
	foreach i in $`k' {
	egen `i'_M=rowmiss(`i')
	egen m_`i'=sum(`i'_M)
	replace `i'=m_`i'
	}
	eststo  model8: estpost summarize $`k'
esttab model0  model1  model2 model3 model4 model5 model6 model7 model8 using "${Table}Main_Balance_Census_`k'.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average/Total}" "C" "T" "Diff" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   title("``k''" \label{`Label`k''}) note("`Note`k''") 
}

* Child level stats
* Akito -> Michelle:
* Please run this with shape file data: N for start_from_clean_file_Census is the number of HH, the one for diarrhea has to be child level (you have to save different final dataset)
global baseline_diarrhea C_diarrhea_prev_child_2weeks C_diarrhea_prev_child_1week ///
                         C_loosestool_child_1week     C_loosestool_child_2weeks ///
						 C_diarrhea_comb_U5_1week     C_diarrhea_comb_U5_2weeks

local Notebaseline_diarrhea "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local baseline_diarrhea "Baseline balance among treatment arms- Baseline Diarrhea Incidence"

foreach k in baseline_diarrhea {
start_from_clean_file_ChildLevel

* Mean
	eststo  model0: estpost summarize $`k'
* Diff
	eststo  model1: estpost summarize $`k' if Treat_V==0
	eststo  model2: estpost summarize $`k' if Treat_V==1
	
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	replace `i'=_b[1.Treat_V]
	}
	eststo  model3: estpost summarize $`k'

	* Significance
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=99996 if p_1> 0.1
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k'
	
	* P-value
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(R_Cen_village_name)
	matrix b = r(table)
	scalar p_1 = b[4,2]
	replace `i'=p_1
	}
	eststo  model5: estpost summarize $`k'

* Min
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	egen m_`i'=min(`i')
	replace `i'=m_`i'
	}
	eststo  model6: estpost summarize $`k'
* Max
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	egen m_`i'=max(`i')
	replace `i'=m_`i'
	}
	eststo model7: estpost summarize $`k'
* Missing 
start_from_clean_file_ChildLevel
	foreach i in $`k' {
	egen `i'_M=rowmiss(`i')
	egen m_`i'=sum(`i'_M)
	replace `i'=m_`i'
	}
	eststo  model8: estpost summarize $`k'
esttab model0  model1  model2 model3 model4 model5 model6 model7 model8 using "${Table}Main_Balance_Census_`k'.tex", ///
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
	   title("``k''" \label{`Label`k''}) note("`Note`k''") 
}


/*----------------------------------------------
2) Descriptive table: Census (Village)
----------------------------------------------*/
start_from_clean_file_Census
local demographics "Baseline characteristics across villages- Household demographics"
local primary_water "Baseline characteristics across villages- Primary water source"
local secondary_water "Baseline characteristics across villages- Secondary water source"
local treat_water "Baseline characteristics across villages- Water treatment methods"
local treat_water_kids "Baseline characteristics across villages- Water treatment methods for U5 children"
local jjm_uses "Baseline characteristics across villages- JJM water uses"
local baseline_diarrhea "Baseline characteristics across villages- Baseline Diarrhea Incidence"


local LabelAll "MaintableHH"
local ScaleAll "1"
local Notedemographics "Notes: This table presents the household demographics from the census. The table is autocreated by 3_Descriptive.do."
local Noteprimary_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notesecondary_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notetreat_water "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notetreat_water_kids "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."
local Notejjm_uses "Notes: This table presents the primary water source reported in the census. The table is autocreated by 3_Descriptive.do."


foreach k in demographics primary_water secondary_water treat_water treat_water_kids jjm_uses  {
start_from_clean_file_Census

* Mean
	eststo  model0: estpost summarize $`k'
* Sub-category
	eststo  model1: estpost summarize $`k' if R_Cen_village_name==20201
	eststo  model2: estpost summarize $`k' if R_Cen_village_name==30602
	eststo  model3: estpost summarize $`k' if R_Cen_village_name==40201
	eststo  model4: estpost summarize $`k' if R_Cen_village_name==40202
	eststo  model5: estpost summarize $`k' if R_Cen_village_name==50101
	eststo  model6: estpost summarize $`k' if R_Cen_village_name==50201
	
	
esttab model0  model1  model2 model3 model4 model5 model6 using "${Table}Main_Village_Census_`k'_Group1.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("Total" "Jaltar" "Mukundpur" "Bichikote" "Gudiabandh" "Dangalodi" "Barijhola" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("``k''- (Group 1 villages)" \label{`Label`k''}) note("`Note`k''") 
}


foreach k in demographics primary_water secondary_water treat_water treat_water_kids jjm_uses  {
start_from_clean_file_Census

* Mean
	eststo  model0: estpost summarize $`k'
* Sub-category
	eststo  model7: estpost summarize $`k' if R_Cen_village_name==50301
	eststo  model8: estpost summarize $`k' if R_Cen_village_name==50401
	eststo  model9: estpost summarize $`k' if R_Cen_village_name==50402
	eststo  model10: estpost summarize $`k' if R_Cen_village_name==50501
	eststo  model11: estpost summarize $`k' if R_Cen_village_name==50601
	
esttab model0  model7  model8 model9 model10 model11 using "${Table}Main_Village_Census_`k'_Group2.tex", ///
	   replace label cell("mean (fmt(2) label(_))") mtitles("Total" "Karlakana" "Birnarayanpur" "Kuljing" "Nathma" "Badaalubadi" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	    title("``k''- (Group 2 villages)" \label{`Label`k''}) note("`Note`k''") 
}

/*----------------------------------------------
3) Map
----------------------------------------------*/
* shp2dta using ${Data_map}village.shp, database(${Data_map}phdb) coordinates(${Data_map}phxy) genid(id) genc(c) replace
* Source: https://www.devdatalab.org/shrug_download/
use "${Data_map}Village_geo.dta", clear

* Village shape file
use "${Data_map}phdb.dta",clear

* Selecting the areas of study
drop if pc11_tv_id=="000000"
gen    Selected_b=0
foreach i in 428438 {
replace Selected_b=1 if id==`i'
}
keep if Selected_b==1
encode pc11_sd_id, gen(pc11_sd_id_num)

* Mark for selected village:  
rename id _ID
merge 1:1 _ID using "${Data_map}Village_geo.dta", gen(Merge_selected)
replace pc11_sd_id_num=. if Merge_selected==3
replace Village=Village + "*" if Selected=="Backup"
savesome x_c y_c Village using "${Data_map}Village_label.dta", replace

/* Village map
spmap pc11_sd_id_num using "${Data_map}phxy" , id(id) clnumber(9) fcolor(Blues) ndfcolor(red) ///
	  ndlabel("Selected") ///
	  label(data("${Data_map}Village_label.dta") x(x_c) y(y_c) label(Village) size(vsmall) color(orange))
graph export "${Figure}Map_villages.eps", replace  
*/

* Adding the location of the HH
append using "${DataDeid}1_1_Census_cleaned_noid_maplab.dta"
label define Typel 1 "Census" 2 "Baseline - Water Survey" 30 "Tank" 31 "Anganwadi center", modify
	label values Type Typel

* Houseeholds map
/*
10101 10201 10301 10401 ///
             20101 ///
			 30101 30201 30202 30301 30401 30501 30502 30601 30602 ///
			  40202 40203 40204 40401 ///
			 50101 50201  50401 50402  ///
*/
gen Map_ID=.
replace Map_ID=40201  if _ID==428438
replace Map_ID=50301  if _ID==428011
replace Map_ID=50501  if _ID==428157
   
foreach i in 40201 50301 50501 {
spmap using "${Data_map}phxy" if  Map_ID==`i', id(_ID) ///
      point(x(R_Cen_a40_gps_longitude) y(R_Cen_a40_gps_latitude) select(keep if R_Cen_village_name==`i') legenda(on) fcolor(Rainbow) by(Type) size(1 2))
graph export "${Figure}Map_`i'.eps", replace  
}	  


/*--------------------
* 1) Tables
--------------------*/
* Title: Overall statistics of recruitment and program registration
use "${DataFinal}Final_HH_Odisha.dta", clear
recode Merge_C_F 1=0 3=1

foreach i in R_Cen_consent R_FU_consent {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}

/*------------------------------------------------------------------------------
	1 Descriptive Statistics: Follow up
------------------------------------------------------------------------------*/

start_from_clean_file_Follow


//1. Checking number of replacements
	
tab  R_FU_replacement

//2. Checking number of cases for non consent and reason why not consenting

use "`non_consent_tab'", clear
gen Consent_provided = R_FU_consent
label define yesno 1 "Yes" 0 "No" 999 "Don't Know"
label values Consent_provided yesno
destring R_FU_reasons_no_consent, gen(Reason_for_non_consent)
label define reason_nonconsent 1 "Lack of time" 2 "Topic not of interest" -77 "Other"
label values Reason_for_non_consent reason_nonconsent

groups Consent_provided Reason_for_non_consent, show(f) 


//3. Checking number of cases by respondent non availablitity
 use "`resp_available'", clear
 tab resp_available 

* output this to overleaf - TODO

	
* output this to overleaf - TODO
* Later, add this count of replacement by enum name - TODO
* Later, add this count of non consent  by enum name - TODO

* tab R_FU_enum_name R_FU_replacement
	
