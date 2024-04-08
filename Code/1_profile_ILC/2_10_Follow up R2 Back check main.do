
cap do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC.do"


do "${Do_lab}import_india_ilc_pilot_backcheck_follow_up_R2_Master.do"

*hey, astha not setting any common path for exporting working files because they are merely used for merging etc 
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"

replace consent = 0 if consent == .

drop if consent == 0

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen BC_surveydate = dofc(submissiondate)
format BC_surveydate %td


bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0



*change in data
*50401117012	chlorine_yesno	No	Yes 16mar2024
*40201111008    water_treat	Yes	No (water_treat_when_1 water_treat_type__77)
*40201111006    water treatment happened in stored water and we dont ask it in BCs 

   
 

 
 
*data entry error
replace chlorine_yesno = 0 if  unique_id == 50401117012 & key == "uuid:2da3fbdc-6bb8-4f42-8eba-b836df6ca651"

	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"
	label variable enum_name "Enumerator Name"

	

tab interviewed_before

cap export excel unique_id  interviewed_before enum_name_label r_fu1_r_cen_a1_resp_name r_fu1_r_cen_village_name_str BC_surveydate using "$In_progress_files/Final_BC_FollowupR1_sheets" if interviewed_before == 0, firstrow(variables) sheet(not_interviewed_before) sheetreplace


// Check if all villages have been back checked atleast once 
//replacing with main respondnet name 
gen Main_Respondent_str = ""
forvalues i = 1/20 {
replace Main_Respondent_str = r_fu2_r_cen_fam_name`i' if main_respondent == `i'
}

*follow up resp
gen followup_resp = ""
forvalues i = 1/20 {
replace followup_resp = r_fu2_r_cen_fam_name`i' if  who_interviwed_before_`i' == 1
}

//Label respondent name values to check if respondent name is same in BC and followup R1 

*We have created a BC respondent var to find error rates for the cases where respondent names are diff 

rename enum_name BC_name

rename Main_Respondent_str BC_Main_Respondent

global id unique_id
global t1vars water_sec_yn water_source_sec water_source_main_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 where_prim_locate where_sec_locate water_treat  water_treat_when_1 water_treat_when_2 water_treat_when_3 water_treat_when_4 water_treat_when_5 water_treat_when_6 water_treat_when__77  water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type_5 water_treat_type_6 water_treat_type__77 water_treat_type_999  chlorine_yesno chlorine_drank_yesno tap_trust


global t2vars water_source_prim tap_use_drinking_yesno
rename r_fu2_r_cen_village_name_str BC_village_name

rename r_fu2_r_cen_a10_hhhead BC_hhead_name



save "$In_progress_files/BC_FollowpR2_for_matching.dta", replace



keep unique_id BC_surveydate BC_name  
	
save "$In_progress_files/BC_FollowpR2_for_merging_with_followup.dta", replace

*************importing followup data**********************

 
use "${DataDeid}1_6_Followup_R2_cleaned.dta", clear
keep if R_FU2_consent == 1
clonevar unique_id =  unique_id_num

renpfix R_FU2_

//renpfix R_FU1_ //removing R_cen prefix 

***********Merging census data with BC data******************
merge 1:1 unique_id using "$In_progress_files/BC_FollowpR2_for_merging_with_followup.dta"

//since all IDs have matched

 //import follow up cleaned data again
use "${DataDeid}1_6_Followup_R2_cleaned.dta", clear
keep if R_FU2_consent == 1
clonevar unique_id =  unique_id_num


global id unique_id

renpfix R_FU2_


rename r_cen_village_name_str survey_village

gen surveydate = dofc(submissiondate)
format surveydate %td


rename r_cen_a10_hhhead  survey_hhead

rename r_cen_a1_resp_name Follow_Respondent

replace chlorine_drank_yesno = 0 if  unique_id == 50402117005 & key == "uuid:0f936bc4-d83c-424a-8577-f3bdab1f7908"


replace where_sec_locate = 3 if  unique_id == 50402106042 & key == "uuid:265a6388-366a-4302-829c-bc67e7a64ae6"


replace water_treat_type_2 = 0 if  unique_id == 50402117014 & key == "uuid:6b0df70d-e092-42c6-a4c4-2c11dd10d169"

//40201111025  chlorine_drank_yesno	No	Yes
*40202110024     water_treat_when_1  survey 0	 BC- 1 for sarita 
*40202110024     water_treat_when_6  survey 1	 BC- 0 for sarita 
*correct pankaj's data entry error in household data 	Sarita Bhatra

*20101110004 correction in sarita's data water_treat_when_1	survey- 0, BC-	1	
*20101110004 correction in sarita's data water_treat_when__77	survey- 1	, BC- 0

 


save "$In_progress_files/Follow_upR2_data_for_matching.dta", replace



*****************************after cleaning is done*********************************

clear 
ssc install bcstats
//BC stats
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
 set matsize 600
 set emptycells drop
bcstats, surveydata("$In_progress_files/Follow_upR2_data_for_matching.dta") bcdata("$In_progress_files/BC_FollowpR2_for_matching.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(water_source_prim)  enumerator(enum_name) backchecker(BC_name) keepsurvey(survey_village surveydate)  keepbc(BC_surveydate BC_village_name  BC_Main_Respondent followup_resp) showid(10) showall full lower trim filename(BC_FollowupR2_diffs.csv) replace 
 

*t2vars($t2vars) t3vars($t3vars)	  
 	/*t2vars(`t2vars') signrank(`signrank') */ 
	/* 3vars(`t3vars') ttest(`ttest') */ 
//to do- I am not sure how can i run stability tests on type 1 and type 2 variables so if you do help bcstats it will show a couple of tests like signrank etc so i want to incorporate that 
//so bcstats does create an excel file but it doesnt export error percentage and all other important error rates so how can we incorporate that and export everything 	

	
return list 

foreach i in r(enum1) r(enum2) r(backchecker1) r(backchecker2) r(var1) r(var2) r(ttest2){
matrix list `i'
}

//AG: You firstly need to display the stored results in order to export it

putexcel set "$In_progress_files\outputR2.xlsx", sheet("error rate1") replace
putexcel A1 = "Error rate enum wise type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set outputR2, modify sheet(error rate2)
putexcel A1 = "Error rate enum wise type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set outputR2, modify sheet(error rate3)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set outputR2, modify sheet(error rate4)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set outputR2, modify sheet(error rate5)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set outputR2, modify sheet(error rate6)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set outputR2, modify sheet(error rate7)
putexcel A1 = "T-test results"
putexcel A2 = matrix(r(ttest2))
putexcel set outputR2, modify sheet(ttest)


//ANALYSIS //////////////////////////////////////////////////////////

clear
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
import delimited "$In_progress_files/BC_FollowupR2_diffs.csv", bindquote(strict) clear

format  unique_id %15.0gc
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if survey == "" & back_check == "."
drop if survey == "." & back_check == ""
rename bc_followup_resp followup_respondent
replace followup_respondent = lower(followup_respondent)
replace bc_bc_main_respondent = lower(bc_bc_main_respondent)


//Unique_ID_wise
preserve
*drop if follow_respondent != bc_bc_resp_name
bysort unique_id: gen u_alldiffs = _N
drop if diff == 0
bysort unique_id: gen total_diffs = _N
bysort unique_id: gen u_diffs_ratio = (total_diffs/u_alldiffs)*100
label variable u_alldiffs "Total observations"
label variable total_diffs "Total differences"
label variable u_diffs_ratio "Percentages"
label variable surveydate "Followup date" 
label variable bc_bc_surveydate "BC date" 
label variable survey_village "Village"
label variable bc_bc_main_respondent "BC_respondent"
export excel unique_id variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent u_alldiffs total_diffs u_diffs_ratio using "$In_progress_files/R2_BC_Followup_wise_differences", firstrow(varlabels) sheet(unqiue_diff_ratios) sheetreplace 

*global Variables unique_id variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent u_alldiffs total_diffs u_diffs_ratio

global Variables unique_id variable survey back_check u_alldiffs total_diffs u_diffs_ratio
texsave $Variables using "$In_progress_files/R2_unique_diff_ratios.tex", ///
        title("Unique ID wise differences") footnote("Notes: Responses of only same respondents across survey and back cehcks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Unique_ID}")

restore

//VARIABLE WISE
preserve
//same resp only
//drop if follow_respondent != bc_bc_resp_name
bysort variable: gen total_alldiffs = _N //it includes even cases where difference is 0
drop if diff == 0
bysort variable: gen total_diffs = _N
bysort variable: gen var_diffs_ratio = (total_diffs/total_alldiffs)*100
collapse total_alldiffs var_diffs_ratio total_diffs, by (variable)
graph bar var_diffs_ratio, over(variable, label(labsize(vsmall) angle(45))) ///
    graphregion(c(white)) xsize(7) ylab(0(10)60, labsize(medsmall) angle(0)) ///
	ytitle("Variable wise % of obs with differnces to total obs") bar(1, fc(eltblue%80))
	graph export "$In_progress_files/diff_ratios.png" , replace	
label variable total_alldiffs "Total observations for this variable"
label variable total_diffs "Total differences"
label variable var_diffs_ratio "Percentages"
export excel variable total_alldiffs total_diffs var_diffs_ratio using "$In_progress_files/R2_BC_Followup_wise_differences", firstrow(varlabels) sheet(var_diff_ratios) sheetreplace 

*global Variables variable total_alldiffs total_diffs var_diffs_ratio 
	
global Variables variable total_alldiffs total_diffs var_diffs_ratio 
texsave $Variables using "$In_progress_files/R2_var_diff_ratios.tex", ///
        title("Variable wise differences") footnote("Notes: Responses of only same respondents across survey and back cehcks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")

restore



///ENUM WISE 
preserve
//Total variables
//contains non differences too
//drop if follow_respondent != bc_bc_resp_name
bysort enum_name: gen total_diffs_enum = _N
drop if diff == 0
bysort enum_name: gen total_not0diffs_enum = _N
bysort enum_name: gen percenatge_not0diffs = (total_not0diffs_enum/total_diffs_enum)*100
collapse total_diffs_enum  total_not0diffs_enum percenatge_not0diffs, by (enum_name)
label variable total_diffs_enum "Total observations for each enum"
label variable total_not0diffs_enum "Total differences for each enum"
label variable percenatge_not0diffs "Percentages"
export excel enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs using "$In_progress_files/R2_BC_Followup_wise_differences", firstrow(varlabels) sheet(enumwise_ratios) sheetreplace 	
global Variables enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs
texsave $Variables using "$In_progress_files/R2_enum_diff_ratios.tex", ///
        title("Enumerator wise differences") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Enumeartors}")

restore



**Variable wise- exporting var values too***
preserve
*drop if follow_respondent != bc_bc_resp_name
*keep if variable == "water_sec_yn" | variable == "water_treat" | variable == "water_source_prim" | variable == "tap_use_drinking_yesno" | variable == "chlorine_drank_yesno" | variable == "chlorine_yesno" | variable == "water_source_sec"
//all keyvariable wise
bysort variable: gen keytotal_alldiffs = _N //it includes even cases where difference is 0
drop if diff == 0
//key variable wise
bysort variable: gen not0keytotal_diffs = _N
bysort variable: gen keyvar_diffs_ratio = (not0keytotal_diffs/keytotal_alldiffs)*100
label variable keytotal_alldiffs "Total observations for each variable (only key vars)"
label variable not0keytotal_diffs "Total differences for each variable (only key vars)"
label variable keyvar_diffs_ratio " Percentages (only key vars)"
export excel variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio using "$In_progress_files/R2_BC_Followup_wise_differences", firstrow(varlabels) sheet(variable_values) sheetreplace 
*global Variables variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio

global Variables variable survey back_check keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio
texsave $Variables using "$In_progress_files/R2_var_values_diff_ratios.tex", ///
        title("Variable wise differences (With variable values)") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")
restore



//VILLAGE WISE for key

preserve
*drop if follow_respondent != bc_bc_resp_name
*replace bc_bc_village_name = "Gopi Kankubadi" if bc_bc_village_name == "Gopi_Kankubadi"
*keep if variable == "water_sec_yn" | variable == "water_treat" | variable == "water_source_prim" | variable == "tap_use_drinking_yesno" | variable == "chlorine_drank_yesno" | variable == "chlorine_yesno" | variable == "water_source_sec"
clonevar village = survey_village
bysort village: gen villagetotals=_N
drop if diff == 0
bysort village: gen not0_villagetotals=_N
bysort village: gen percentage_not0_villagetotals= (not0_villagetotals/villagetotals)*100
collapse villagetotals not0_villagetotals percentage_not0_villagetotals, by ( village)
label variable villagetotals "Total observations for each village"
label variable not0_villagetotals "Total differences for each village"
rename percentage_not0_villagetotals Percentages
label variable Percentages "Percentages"
export excel village villagetotals not0_villagetotals Percentages using "$In_progress_files/R2_BC_Followup_wise_differences", firstrow(varlabels) sheet(village_wise_differences) sheetreplace

global Variables village villagetotals not0_villagetotals Percentages
texsave $Variables using "$In_progress_files/R2_village_diff_ratios.tex", ///
        title("Village wise differences") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Villages}")

restore


















