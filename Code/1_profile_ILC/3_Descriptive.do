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
	
* do "${Do_pilot}2_1_Final_data.do"

/* Example: 
tabout DATE ENUEMRERATOR using "${Table}Duration_Issue.tex", ///
       f(0c) style(tex) clab(_) replace ///
       topf("${Table}top.tex") botf("${Table}bot.tex")
*/

/*----------------------------------------------
* 1) Progress table *
----------------------------------------------*/
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
	label define R_Cen_village_namel 10101 "Asada" 10201 "Sanagortha"  20101 "Badabangi" 30501 "Bhujbal" 99999 "Total", modify
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
        title("Overall Progress") footnote("Notes: This table presents the overall progress. The table is autocreated by 3_Descriptive.do. Akito to do: Show the stats by T and C to ensure attrition does not differ.") replace varlabels frag location(htbp) headerlines("&\multicolumn{3}{c}{Census}&\multicolumn{2}{c}{Follow up}")

		
		
/*----------------------------------------------
2) Descriptive table
   Census
----------------------------------------------*/
start_from_clean_file_Census
global All R_Cen_a2_hhmember_count R_Cen_a10_hhhead_gender_1 ///
           R_Cen_a12_water_source_prim_1 ///
           R_Cen_a16_water_treat_1 ///
		   R_Cen_a13_water_sec_yn_0

local All "Baseline balance among treatment arms"
local LabelAll "MaintableHH"
local ScaleAll "1"
local NoteAll "Notes: This table presents the household characteristics from the census. The table is autocreated by 3_Descriptive.do."

foreach k in All {
start_from_clean_file_Census
* Mean
	eststo  model0: estpost summarize $`k'
	eststo  model1: estpost summarize $`k' if Treat_V==0
	eststo  model2: estpost summarize $`k' if Treat_V==1
	
	* Diff
start_from_clean_file_Census
	
	foreach i in $`k' {
	reg `i' i.Treat_V
	replace `i'=_b[1.Treat_V]
	}
	eststo  model4: estpost summarize $`k'

	* Significance
start_from_clean_file_Census

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
start_from_clean_file_Census
	foreach i in $`k' {
	reg `i' i.Treat_V
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

/*----------------------------------------------
2) Descriptive table
   Village level
----------------------------------------------*/

global All BlockCode_1 BlockCode_2 BlockCode_3 BlockCode_4 BlockCode_5  Panchatvillage ///

local All "Pre-survey balance among treatment arms by village"
local LabelAll "MainVillage"
local ScaleAll "1"
local NoteAll "Notes: This table presents the village level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All {
start_from_clean_file_Village
* Mean
	eststo  model0: estpost summarize $`k'
	eststo  model1: estpost summarize $`k' if Treat_V==0
	eststo  model2: estpost summarize $`k' if Treat_V==1
	
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
	
esttab model0 model1 model2 model4 model5 model6 using "${Table}Main_Balance_Village.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{Control}" "\shortstack[c]{Treat}" "Diff" "Sig" "P-value") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _\\" "" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchat village" "\textbf{Panchat village}" ///
				   "BLOCK:" "~~~" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
}

/*----------------------------------------------
3) Map
----------------------------------------------*/
* shp2dta using ${Data_map}village.shp, database(${Data_map}phdb) coordinates(${Data_map}phxy) genid(id) genc(c) replace
* Source: https://www.devdatalab.org/shrug_download/

* Village shape file
use "${Data_map}phdb.dta",clear

* Selecting the areas of study
drop if pc11_tv_id=="000000"
gen    Selected_b=0
foreach i in 03196 03197 03198 03199 03200 03201 03202 03204 03205 03207 03176 {
replace Selected_b=1 if pc11_sd_id=="`i'"
}
keep if Selected_b==1
encode pc11_sd_id, gen(pc11_sd_id_num)

* Mark for selected village
merge 1:1 pc11_tv_id using "${Data_map}Village_geo.dta", keepusing(Village Selected village_IDinternal) gen(Merge_selected)
replace pc11_sd_id_num=. if Merge_selected==3
replace Village=Village + "*" if Selected=="Backup"
savesome x_c y_c Village using "${Data_map}Village_label.dta", replace

* Village map
spmap pc11_sd_id_num using "${Data_map}phxy" , id(id) clnumber(9) fcolor(Blues) ndfcolor(red) ///
	  ndlabel("Selected") ///
	  label(data("${Data_map}Village_label.dta") x(x_c) y(y_c) label(Village) size(vsmall) color(orange))
graph export "${Figure}Map_villages.eps", replace  

* Adding the location of the HH
append using "${DataDeid}1_1_Census_cleaned_noid_maplab.dta"
count
local observation = `r(N)'+1
set obs `observation'
replace  R_Cen_a40_gps_latitude=19.18 in `observation'
replace  R_Cen_a40_gps_longitude=83.41824 in `observation'
replace  Type=2 in `observation'

label define Typel 1 "Census" 2 "Baseline - Water Survey", modify
	label values Type Typel

* Houseeholds map
foreach i in 10101 10201 10301 10401 ///
             20101 ///
			 30101 30201 30202 30301 30401 30501 30502 30601 30602 ///
			 40201 40202 40203 40204 40401 ///
			 50101 50201 50301 50401 50402 50501 ///
 {
spmap using "${Data_map}phxy" if  village_IDinternal =="`i'" |  village_IDinternal =="", id(id) 
graph export "${Figure}Map_`i'.eps", replace  
}	  

* point(x(R_Cen_a40_gps_longitude) y(R_Cen_a40_gps_latitude) legenda(on) fcolor(Reds) by(Type))
* label(data("${Data_map}Village_label.dta") x(x_c) y(y_c) label(Village) size(tiny))

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

************************
* 2) Descriptive table *
*    Follow-up         *
************************
start_from_clean_file_Follow


	
