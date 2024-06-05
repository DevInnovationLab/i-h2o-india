cd "C:\Users\Archi Gupta\Box\Data\1_raw"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\import_india_ilc_pilot_backcheck_Master.do"              
set seed 758235657 // Just in case


replace consent = 0 if consent == .

drop if consent == 0

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen BC_surveydate = dofc(submissiondate)
format BC_surveydate %td
drop  if unique_id == 10101110016 & enum_name == 107 & r_cen_a1_resp_name == "Padma Garadia" & a7_resp_name == "999"


bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0



cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"



	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"



	label variable enum_name "What is the name of the enumerator?"
	note enum_name: "What is the name of the enumerator?"
	label define enumerator 101 "Sanjay Naik" 102 "Susanta Kumar Mahanta" 103 "Rajib Panda" 104 "Santosh Kumar Das" 105 "Bibhar Pankaj" 106 "Madhusmita Samal" 107 "Rekha Behera" 108 "Sanjukta Chichuan" 109 "Swagatika Behera" 110 "Sarita Bhatra" 111 "abhishek Rath" 112 "Binod Kumar Mohanandia" 113 "Mangulu Bagh" 114 "Padman Bhatra" 115 "Kuna Charan Naik" 116 "Sushil Kumar Pani" 117 "Jitendra Bagh" 118 "Rajeswar Digal" 119 "Pramodini Gahir" 120 "Manas Ranjan Parida" 121 "Ishadatta Pani"
	label values enum_name enumerator

cap export excel unique_id r_cen_a1_resp_name r_cen_village_name_str enum_name who_interviwed_before a7_resp_name BC_surveydate dup_HHID using "BC_quality_final" if dup_HHID>0, firstrow(variables) sheet(duplicates) sheetreplace
	
replace interviewed_before = 1 if unique_id == 10201108019 & enum_name == 120 & a7_resp_name == "SANYASI ARAKA" & r_cen_village_name_str == "Sanagortha"

tab interviewed_before


cap export excel unique_id  interviewed_before r_cen_a1_resp_name r_cen_village_name_str enum_name who_interviwed_before a7_resp_name BC_surveydate dup_HHID using "BC_quality_final" if interviewed_before == 0, firstrow(variables) sheet(not_interviewed_before) sheetreplace

//AG: List all the cases where BC recorded that under 5 child isn't present but census showed it is present 
gen export_var = 0
levelsof unique_id, local(id_list)
foreach id of local id_list {
replace export_var = 1 if unique_id == `id' & screen_u5child == 0 & (r_cen_u5child_1 != ""| r_cen_u5child_2 != ""| r_cen_u5child_3 != ""| r_cen_u5child_4 != ""| r_cen_u5child_5 != ""| r_cen_u5child_6 != ""| r_cen_u5child_7 != ""| r_cen_u5child_8 != ""| r_cen_u5child_9 != ""| r_cen_u5child_10 != ""| r_cen_u5child_11 != ""| r_cen_u5child_12 != ""| r_cen_u5child_13 != ""| r_cen_u5child_14 != ""| r_cen_u5child_15 != ""| r_cen_u5child_16 != ""| r_cen_u5child_17 != ""| r_cen_u5child_18 != ""| r_cen_u5child_19 != ""| r_cen_u5child_20 != "")
}
export excel unique_id enum_name r_cen_village_name_str using "BC_quality_final" if export_var == 1, sheet(notscreen_u5child_but_incensus) sheetreplace firstrow(variables) 

levelsof unique_id, local(id_list)
foreach id of local id_list{
list unique_id enum_name `i' if unique_id == `id' & screen_u5child == 1 & (a21_child_hh_1== 1 | a21_child_hh_2== 1 | a21_child_hh_3== 1  | a21_child_hh_4== 1 | a21_child_hh_5== 1)  & r_cen_u5child_1== "" &  r_cen_u5child_2== "" &  r_cen_u5child_3== "" &  r_cen_u5child_4== "" &  r_cen_u5child_5== "" &  r_cen_u5child_6== "" &  r_cen_u5child_7== "" &  r_cen_u5child_8== "" &  r_cen_u5child_9== "" &  r_cen_u5child_10== "" &  r_cen_u5child_11== "" &  r_cen_u5child_12== "" &  r_cen_u5child_13== "" &  r_cen_u5child_14== "" &  r_cen_u5child_15== "" &  r_cen_u5child_16== "" &  r_cen_u5child_17== "" &  r_cen_u5child_18== "" &  r_cen_u5child_19== "" &  r_cen_u5child_20== ""
}
//AG: list all the unique IDs where child has been screened for U5 but our previous surveys did not report it 

drop export_var
gen export_var = 0
levelsof unique_id, local(id_list)
foreach id of local id_list{
replace export_var = 1 if unique_id == `id' & screen_u5child == 1 & (a21_child_hh_1== 1 | a21_child_hh_2== 1 | a21_child_hh_3== 1  | a21_child_hh_4== 1 | a21_child_hh_5== 1) & r_cen_u5child_1== "" &  r_cen_u5child_2== "" &  r_cen_u5child_3== "" &  r_cen_u5child_4== "" &  r_cen_u5child_5== "" &  r_cen_u5child_6== "" &  r_cen_u5child_7== "" &  r_cen_u5child_8== "" &  r_cen_u5child_9== "" &  r_cen_u5child_10== "" &  r_cen_u5child_11== "" &  r_cen_u5child_12== "" &  r_cen_u5child_13== "" &  r_cen_u5child_14== "" &  r_cen_u5child_15== "" &  r_cen_u5child_16== "" &  r_cen_u5child_17== "" &  r_cen_u5child_18== "" &  r_cen_u5child_19== "" &  r_cen_u5child_20== ""
}
export excel unique_id enum_name r_cen_village_name_str using "BC_quality_final" if export_var == 1, sheet(screen_u5child_but_notincensus) sheetreplace firstrow(variables) 


//AG: list all the cases where BC recodred that pregnant women isn't present but in our previous surveys it showed present 
foreach i of varlist r_cen_pregwoman_1-r_cen_pregwoman_20{
list unique_id `i' enum_name if screen_preg == 0 & `i'!= ""
*cap export excel unique_id enum_name r_cen_village_name_str using "BC_quality" if screen_preg == 0 & `i'!= "" ,firstrow(variables) sheet(notscreen_preg_but_incensus) sheetreplace
}
drop export_var
gen export_var = 0
levelsof unique_id, local(id_list)
foreach id of local id_list{
replace export_var = 1 if unique_id == `id' & screen_preg == 0 & (r_cen_pregwoman_1 != "" | r_cen_pregwoman_2 != "" | r_cen_pregwoman_3 != "" | r_cen_pregwoman_4 != "" | r_cen_pregwoman_5 != "" | r_cen_pregwoman_6 != "" | r_cen_pregwoman_7 != "" | r_cen_pregwoman_8 != "" | r_cen_pregwoman_8 != "" | r_cen_pregwoman_9 != "" | r_cen_pregwoman_10 != "" | r_cen_pregwoman_11 != "" | r_cen_pregwoman_12 != "" | r_cen_pregwoman_13 != "" | r_cen_pregwoman_14 != "" | r_cen_pregwoman_15 != "" | r_cen_pregwoman_16 != "" | r_cen_pregwoman_17 != "" | r_cen_pregwoman_18 != "" | r_cen_pregwoman_19 != "" | r_cen_pregwoman_20 != "") 
}
export excel unique_id enum_name r_cen_village_name_str using "BC_quality_final" if export_var == 1, sheet(screen_notpregnant_but_incensus) sheetreplace firstrow(variables) 


//AG: list all the cases where BC recorded that pregnant women is presenr and this her usual residence but in our previous surveys it showed absent
drop export_var
gen export_var = 0
levelsof unique_id, local(id_list)
foreach id of local id_list{
replace export_var = 1 if unique_id == `id' & screen_preg == 1 & a21_pregnant_hh_1== 1 & r_cen_pregwoman_1== "" &  r_cen_pregwoman_2== "" &  r_cen_pregwoman_3== "" &  r_cen_pregwoman_4== "" &  r_cen_pregwoman_5== "" &  r_cen_pregwoman_6== "" &  r_cen_pregwoman_7== "" &  r_cen_pregwoman_8== "" &  r_cen_pregwoman_9== "" &  r_cen_pregwoman_10== "" &  r_cen_pregwoman_11== "" &  r_cen_pregwoman_12== "" &  r_cen_pregwoman_13== "" &  r_cen_pregwoman_14== "" &  r_cen_pregwoman_15== "" &  r_cen_pregwoman_16== "" &  r_cen_pregwoman_17== "" &  r_cen_pregwoman_18== "" &  r_cen_pregwoman_19== "" &  r_cen_pregwoman_20== ""

}
cap export excel unique_id enum_name r_cen_village_name_str using "BC_quality_final" if export_var == 1, sheet(screen_pregnant_but_notincensus) sheetreplace firstrow(variables) 


replace change_primary_source = 0 if change_primary_source == 1 & unique_id == 40202108028

tab change_primary_source
encode r_cen_a12_water_source_prim, generate(r_cen_a12_water_source_prim_)
drop r_cen_a12_water_source_prim
rename r_cen_a12_water_source_prim_ r_cen_a12_water_source_prim

cap export excel primary_water_label r_cen_a12_water_source_prim bc_water_source_prim unique_id enum_name r_cen_village_name_str using "BC_quality_final" if change_primary_source == 1, sheet(change_primary_source) sheetreplace firstrow(variables) 

******IGNORE THIS COMMENTED SECTION****************
*cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
*tempfile temp
*foreach i of varlist r_cen_u5child_1-r_cen_u5child_20//
    *list unique_id `i' enum_name if screen_u5child == 0 & `i'!= ""
    *duplicates drop unique_id `i' enum_name, force
    *keep if _n == 1
    *gen B1 = unique_id
    *gen B2 = `i'
    *gen B3 = enum_name
    *gen B4 = r_cen_village_name_str
    *append using `temp'
*}
*export excel using "output1.xlsx", sheet("Sheet1") replace



// Create a new variable that identifies all the v_id that meet the condition

// Export all the v_id that meet the condition to the same sheet in the Excel file
//AG: List all the cases where BC recorded that under 5 child isn't present but census showed it is present 
*local cases ""
*foreach i of varlist r_cen_u5child_1-r_cen_u5child_20{
    *qui list unique_id `i' enum_name if screen_u5child == 0 & `i'!= ""
    *local cases `"`cases' `r(unique_id)'"'
*}
*cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
// Export the cases to an Excel file
*export excel using "cases.xlsx", sheet("Cases") firstrow(variables) replace



*cap confirmatory export excel unique_id `i' enum_name r_cen_village_name_str using "BC_quality", firstrow(variables) sheet(`i'_notscreenu5child_but_incensus) sheetreplace if _N>0










*levelsof unique_id, local(id_list)
*foreach id of local id_list {
    *foreach var of varlist u5child_* {
        *list unique_id enum_name if unique_id == `id' & screen_u5child == 1 & `var' == ""
    *}
*}



save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_cleaned data.dta", replace

rename enum_name BC_name

rename a7_resp_name BC_respondent_name

rename a10_hhhead BC_hhhead

keep unique_id BC_surveydate BC_name BC_respondent_name  BC_hhhead interviewed_before who_interviwed_before r_cen_a1_resp_name r_cen_a10_hhhead r_cen_village_name_str r_cen_a11_oldmale_name r_cen_a39_phone_name_1 r_cen_address
	
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_edited_data.dta", replace

*************importing census data**********************

clear all 

use "C:\Users\Archi Gupta\Box\Data\3_final\Final_HH_Odisha_consented_Full.dta"

renpfix R_Cen_ //removing R_cen prefix 


drop unique_id
rename unique_id_num unique_id
	
keep unique_id enum_name a1_resp_name a10_hhhead block_name village_name
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\census_edited_data.dta", replace

	
***********Merging census data with BC data******************
merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_edited_data.dta"

//aG: at this point once get the whole data find values which are unmatched 



*****************************after cleaning is done*********************************

clear all

use "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_cleaned data.dta"

rename enum_name BC_name

global id unique_id

* VaRIaBLE LISTS
* Type 1 Vars: These should not change. They guage whether the enumerator 
* performed the interview and whether it was with the right respondent. 
* If these are high, you must discuss them with your field team and consider
* disciplinary action against the surveyor and redoing her/his interviews.

rename bc_water_source_prim a12_water_source_prim
rename  a15_hhmember_count a2_hhmember_count


global t1vars a2_hhmember_count screen_u5child screen_preg  a10_hhhead a10_hhhead_gender a11_oldmale a11_oldmale_name a12_water_source_prim a16_water_treat a17_water_source_kids  


global t2vars a18_jjm_drinking a16_stored_treat a16_water_treat_type a16_water_treat_freq a16_stored_treat_freq water_prim_source_kids a17_water_treat_kids water_treat_kids_type a17_treat_kids_freq a33_cotbed a33_electricfan a33_colourtv a33_mobile a33_internet a33_motorcycle


save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC data for bc stats.dta", replace
global bcer_data("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC data for bc stats.dta", replace)


clear 


use "C:\Users\Archi Gupta\Box\Data\1_raw\1_1_Census_cleaned_consented.dta"

renpfix R_Cen_ //removing R_cen prefix 


drop unique_id
rename unique_id_num unique_id

global id unique_id

save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Census date for bc stats.dta", replace

global original ("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Census date for bc stats.dta")

clear 
//BC stats
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
 set matsize 600
 set emptycells drop
bcstats, surveydata("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Census date for bc stats.dta") bcdata("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC data for bc stats.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(a18_jjm_drinking) enumerator(enum_name) backchecker(BC_name)  keepsurvey(village_name a1_resp_name) keepbc(a7_resp_name interviewed_before no_of_u5child no_of_preg change_primary_source a21_pregnant_hh_* a21_pregnant_arrive_* r_cen_village_name_str) showid(30) showall full replace 
*t2vars($t2vars) t3vars($t3vars)	  
 	/*t2vars(`t2vars') signrank(`signrank') */ 
	/* 3vars(`t3vars') ttest(`ttest') */ 
//to do- I am not sure how can i run stability tests on type 1 and type 2 variables so if you do help bcstats it will show a couple of tests like signrank etc so i want to incorporate that 
//so bcstats does create an excel file but it doesnt export error percentage and all other important error rates so how can we incorporate that and export everything 	

	
return list 




foreach i in r(enum1) r(enum2) r(backchecker1) r(backchecker2) r(var1) r(var2){
matrix list `i'
}

//AG: You firstly need to display the stored results in order to export it

putexcel set "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\output.xlsx", sheet("Sheet1") replace
putexcel A1 = "Error rate enum wise type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set output, modify sheet(error rate1)
putexcel A1 = "Error rate enum wise type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set output, modify sheet(error rate2)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set output, modify sheet(error rate3)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set output, modify sheet(error rate4)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set output, modify sheet(error rate5)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set output, modify sheet(error rate6)
putexcel A1 = "T-test results"
putexcel A2 = matrix(r(ttest2))
putexcel set output, modify sheet(ttest)









	
