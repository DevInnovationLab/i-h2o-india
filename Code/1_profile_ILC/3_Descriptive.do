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

/*------------------------------------------------------------------------------
	1 Descriptive Statistics: Census
------------------------------------------------------------------------------*/

//1. Checking number of screened and screened out cases by enumerator

/*----------------------------------------------
2) Descriptive table
   Village level
----------------------------------------------*/

* Michelle add more variables and enumerators
start_from_clean_file_Population
global All Screened R_Cen_consent R_FU_consent
local All "Table by enumerator"
local LabelAll "MainEnum"
local ScaleAll "1"
local NoteAll "Notes: This table presents the enumerator level stats. The table is autocreated by 3_Descriptive.do."

foreach k in All {
start_from_clean_file_Population
* Mean
	eststo  model0:   estpost summarize $`k'
	eststo  model104: estpost summarize $`k' if R_Cen_enum_name==104
	eststo  model106: estpost summarize $`k' if R_Cen_enum_name==106
	eststo  model107: estpost summarize $`k' if R_Cen_enum_name==107
	** ADD MORE
		
esttab model0 model104 model106 model107 using "${Table}Main_Enum_Census.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Average}" "\shortstack[c]{Santosh}" "\shortstack[c]{Madhusmita}" "Rekha") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _\\" "" ///
				   "BLOCK: Gudari" "\multicolumn{4}{l}{\textbf{Block}} \\ \hline BLOCK: Gudari" ///
				   "Panchat village" "\textbf{Panchat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
}

/* PLEASE INCLUDE WHAT YOU WERE THINKING IN ONE TABLE
	*screened out
	use `screened_out', clear
	replace instruction=0 if screen_preg==0 & screen_u5child==0
	tab enum_name instruction
	*need to put table in overleaf
	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 1: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name instruction, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Screened_Out
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
*/

	*screened
	use `working', clear
	tab R_Cen_enum_name R_Cen_instruction
	*need to put table in overleaf
	
	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 2: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab R_Cen_enum_name R_Cen_instruction, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Screened and interview conducted
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
	*/
	

//2. Checking number of no-consent cases by enumerator and also the reason for no consent
	use `no_consent', clear
	replace no_consent_reason= "Lack of time" if no_consent_reason=="1"
	replace no_consent_reason= "Topic is not interesting to me" if no_consent_reason=="2"
	replace no_consent_reason= "Other" if no_consent_reason=="-77"
	tab enum_name consent
	tab enum_name no_consent_reason
	*need to put tables in overleaf

	/*
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 3: Number Screened out by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name consent, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Rejected
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
	
	putpdf paragraph,  font("Courier",14) halign(left)
    putpdf text ("Table 4: Rejection reason by enumerator"), bold
    *putpdf table tab1 =  matrix(prim_water_source), rownames colnames, varnames
	tab enum_name consent, matcell(x)
	matrix rownames x =  SanjayNaik SusantaKumar  RajibPanda SantoshKumar BibharPankaj MadhusmitaSamal RekhaBehera SanjuktaChichuan SwagatikaBehera ///
	SaritaBhatra AbhishekRath BinodKumar ManguluBagh PadmanBhatra KunaCharan SushilKumar  JitendraBagh RajeswarDigal PramodiniGahir ManasRanjan  IshadattaPani 
	matrix colnames x = Rejected reason
    putpdf table tbl1 = matrix((x/200)*100), rownames colnames width(8)
*/
*/

//3. Checking time per section by enumerator
start_from_clean_file_Census 
***need to check with data that comes in on Friday because for the data submitted 25th Sept the duration function is not working

//4. % of HHs drinking JJM tap water
* Make less sense to create figure for one variable: See I added this info in table: Main_Balance_Census.tex (below)
/*start_from_clean_file_Census
	gen household_num= 1
	egen total_hh= total(household_num)
	display total_hh
	local total_num_hhs = total_hh

	graph hbar (percent) household_num, over(R_Cen_a18_jjm_drinking, label) blabel(total) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_drinking_percentage.png, replace 
/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 1: Percentage of HHs drinking water from JJM taps") , bold
	putpdf image JJM_drinking_percentage.png, linebreak width(6) 
	
*/	

//5. % of HHs by different uses of JJM water
start_from_clean_file_Census
	gen household_num_JJMuses= 1 if R_Cen_a20_jjm_use!=""
	egen total_hh_JJMuses= total(household_num_JJMuses)
	local total_num_hhs_JJMuses = total_hh_JJMuses	
	        
	label variable R_Cen_a20_jjm_use_1 "Cooking"
	label variable R_Cen_a20_jjm_use_2 "Washing utensils"
	label variable R_Cen_a20_jjm_use_3 "Washing clothes"
	label variable R_Cen_a20_jjm_use_4 "Cleaning the house"
	label variable R_Cen_a20_jjm_use_5 "Bathing"
	label variable R_Cen_a20_jjm_use_6 "Drinking water for animals"
	label variable R_Cen_a20_jjm_use_7 "Irrigation"
	label variable R_Cen_a20_jjm_use__77 "Other"
	label variable R_Cen_a20_jjm_use_999 "Don't know"
	
	mrgraph hbar R_Cen_a20_jjm_use_1-R_Cen_a20_jjm_use_999, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs_JJMuses'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_uses.png, replace 
	
//6. % of HHs by different primary water sources
	gen prim_water_source=""
	
	//reducing length of labels
	replace prim_water_source= "JJM tap" if R_Cen_a12_water_source_prim==1
	replace prim_water_source= "Govt. provided community standpipe" if R_Cen_a12_water_source_prim==2
	replace prim_water_source= "Manual handpump" if R_Cen_a12_water_source_prim==4
	replace prim_water_source= "Surface water" if R_Cen_a12_water_source_prim==7

	graph hbar (percent) household_num, over(prim_water_source, label) blabel(total) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export Primary_water_source.png, replace 
/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 2: Primary drinking water source") , bold
	putpdf image Primary_water_source.png, linebreak width(6) 
*/	
	
//7. % of HHs by different secondary water sources
	gen household_num_secondarywater= 1 if R_Cen_a13_water_sec_yn==1
	egen total_hh_secondarywater= total(household_num_secondarywater)
	local total_num_hhs_secwater = total_hh_secondarywater
	
	label variable R_Cen_a13_water_source_sec_1 "JJM tap"
	label variable R_Cen_a13_water_source_sec_2 "Govt. provided community standpipe"
	label variable R_Cen_a13_water_source_sec_3 "GP/Other community standpipe"
	label variable R_Cen_a13_water_source_sec_4 "Manual handpump"
	label variable R_Cen_a13_water_source_sec_5 "Covered dug well"
	label variable R_Cen_a13_water_source_sec_6 "Uncovered dug well"
	label variable R_Cen_a13_water_source_sec_7 "Surface water"
	label variable R_Cen_a13_water_source_sec_8 "Private surface well"
	label variable R_Cen_a13_water_source_sec__77 "Other"

	
	mrgraph hbar R_Cen_a13_water_source_sec_1-R_Cen_a13_water_source_sec__77, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs_secwater'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export Secondary_water_source.png, replace 

	/*
	putpdf paragraph, halign(center)
	putpdf text ("Figure 3: Secondary drinking water source") , bold
	putpdf image Secondary_water_source.png, linebreak width(6) 
*/

//8. % of HHs by different water treatment methods
	        
	gen R_Cen_a16_water_treat_type_0= 1 if R_Cen_a16_water_treat==0

	label variable R_Cen_a16_water_treat_type_0 "No treatment"
	label variable R_Cen_a16_water_treat_type_1 "Filter through cloth/sieve" 
	label variable R_Cen_a16_water_treat_type_2 "Letting water stand" 
	label variable R_Cen_a16_water_treat_type_3 "Boiling" 
	label variable R_Cen_a16_water_treat_type_4 "Adding chlorine/bleaching powder" 
	label variable R_Cen_a16_water_treat_type__77 "Other"
	label variable R_Cen_a16_water_treat_type_999 "Don't know"


	order R_Cen_a16_water_treat_type_0 R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 ///
	R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type_999 R_Cen_a16_water_treat_type__77
	mrgraph hbar R_Cen_a16_water_treat_type_0-R_Cen_a16_water_treat_type__77, blabel(total) stat(column) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	*graph export JJM_uses.png, replace 
*/

/*----------------------------------------------
2) Descriptive table
   Village level
----------------------------------------------*/

global All BlockCode_1 BlockCode_2 BlockCode_3 BlockCode_4 BlockCode_5 Panchatvillage V_Num_HH V_Num_HH_Categ_1 V_Num_HH_Categ_2 V_Num_HH_Categ_3 ///

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
				   "Panchat village" "\textbf{Panchat village}" ///
				   "Number of HH in the village" "\textbf{Number of HH in the village}" ///
				   "BLOCK:" "~~~" "VSize:" "~~~"  ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
}

/*----------------------------------------------
* 1) Progress table *
----------------------------------------------*/
* Title: Overall statistics of recruitment and program registration
start_from_clean_file_Population
expand 2, generate(expand_n)
replace R_Cen_village_name=99999 if expand_n==1
keep Census Screened R_Cen_village_name R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent
collapse  (sum) Census R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent Screened, by(R_Cen_village_name)
	label define R_Cen_village_namel 88888 "Pilot (village)" 99999 "Total", modify
	label values R_Cen_village_name R_Cen_village_namel
	
	decode R_Cen_village_name, gen(R_Cen_village_name_str)
	label var Census  "Submission"
	label var Screened  "Screened"	
	label var R_Cen_village_name_str "Village"
	label var Non_R_Cen_consent "Refused"
	label var Non_R_FU_consent "Refused"
	label var R_FU_consent "Consented"
	label var R_Cen_consent "Consented"
	
global Variables R_Cen_village_name_str Census Screened R_Cen_consent Non_R_Cen_consent R_FU_consent Non_R_FU_consent
texsave $Variables using "${Table}Table_Progress.tex", ///
        title("Overall Progress") footnote("Notes: This table presents the overall progress. The table is autocreated by 3_Descriptive.do. Akito to do: Show the stats by T and C to ensure attrition does not differ.") replace varlabels frag location(htbp) headerlines("&\multicolumn{4}{c}{Census}&\multicolumn{2}{c}{Follow up}")

/*----------------------------------------------
2) Descriptive table
   Census
----------------------------------------------*/
start_from_clean_file_Census
global All R_Cen_a2_hhmember_count R_Cen_a10_hhhead_gender_1 ///
		   R_Cen_a12_water_source_prim_1 R_Cen_a12_water_source_prim_2 R_Cen_a12_water_source_prim_4  ///
		   R_Cen_a13_water_sec_yn_0 ///
		   R_Cen_a13_ws_sec_1 R_Cen_a13_ws_sec_2 R_Cen_a13_ws_sec_3 R_Cen_a13_ws_sec_4 R_Cen_a13_ws_sec_5 R_Cen_a13_ws_sec_6 ///
		   R_Cen_a13_ws_sec_7 R_Cen_a13_ws_sec_8 R_Cen_a13_ws_sec__77 ///
		   R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 ///
		   R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type__77 R_Cen_a16_water_treat_type_999 ///
           R_Cen_a18_jjm_drinking ///
		   R_Cen_a20_jjm_use_1 R_Cen_a20_jjm_use_2 R_Cen_a20_jjm_use_3 R_Cen_a20_jjm_use_4 R_Cen_a20_jjm_use_5 R_Cen_a20_jjm_use_6 R_Cen_a20_jjm_use_7 ///
		   R_Cen_a16_water_treat_1

local All "Baseline balance among treatment arms"
local LabelAll "MaintableHH"
local ScaleAll "1"
local NoteAll "Notes: This table presents the household characteristics from the census. The table is autocreated by 3_Descriptive.do."

foreach k in All {
start_from_clean_file_Census

* Mean
	eststo  model0: estpost summarize $`k'
/* Diff
	eststo  model1: estpost summarize $`k' if Treat_V==0
	eststo  model2: estpost summarize $`k' if Treat_V==1
	
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
*/
* Min
	foreach i in $`k' {
	egen m_`i'=min(`i')
	replace `i'=m_`i'
	}
	eststo  model4: estpost summarize $`k'
* Max
	start_from_clean_file_Census
	foreach i in $`k' {
	egen m_`i'=max(`i')
	replace `i'=m_`i'
	}
	eststo model5: estpost summarize $`k'
* Missing 
	start_from_clean_file_Census
	foreach i in $`k' {
	egen `i'_M=rowmiss(`i')
	egen m_`i'=sum(`i'_M)
	replace `i'=m_`i'
	}
	eststo  model6: estpost summarize $`k'
* esttab model0 model1 model2 model4 model5 model6 using "${Table}Main_Balance_Census.tex",
esttab model0 model4 model5 model6 using "${Table}Main_Balance_Census.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{Min}" "\shortstack[c]{Max}" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _\\" "" ///
				   "PWS: JJM Taps" "\multicolumn{4}{l}{\textbf{Primary water source}} \\ \hline PWS: JJM Taps" ///
				   "WT: No" "\multicolumn{4}{l}{Water treatment} \\ WT: No" ///
				   "Freq: Every 2-3 days in a week" "\multicolumn{4}{l}{Collection frequency} \\ Freq: Every 2-3 days in a week" ///
				   "Drink JJM water" "\textbf{Drink JJM water}" ///
				   "SWS: No" "\multicolumn{4}{l}{\textbf{Secondary water source}} \\ \hline SWS: No" ///
				   "PWS:" "~~~" "WT:" "~~~" "Freq:" "~~~" "SWS:" "~~~" ///
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
* spmap using "${Data_map}phxy" if  village_IDinternal =="`i'" |  village_IDinternal =="", id(id) 
* graph export "${Figure}Map_`i'.eps", replace  
}	  
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

/*------------------------------------------------------------------------------
	1 Descriptive Statistics: Follow up
------------------------------------------------------------------------------*/

start_from_clean_file_Follow


	
