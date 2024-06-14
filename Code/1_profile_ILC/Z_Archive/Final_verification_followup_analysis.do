

do "${Do_lab}import_india_ilc_pilot_backcheck_follow_up_R1_Master.do"

*hey, astha not setting any common path for exporting working files because they are merely used for merging etc 
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"

replace consent = 0 if consent == .

drop if consent == 0

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen V_surveydate = dofc(submissiondate)
format V_surveydate %td


bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0

keep if V_surveydate >= mdy(3,6,2024)

duplicates list  unique_id 

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
tab r_fu1_r_cen_village_name_str


//Label respondent name values to check if respondent name is same in BC and followup R1 
*The command below shwos that all the actual respondnet names will be found at 1st spot in the roster

gen Resp_name = ""
forvalues i = 1/20 {
	  replace Resp_name = r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1 
}


rename Resp_name V_resp_name
rename enum_name V_enum_name
rename r_fu1_r_cen_village_name_str V_Village
global id unique_id

global t1vars water_sec_yn water_source_sec water_source_main_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 where_prim_locate where_sec_locate water_treat water_treat_when water_treat_when_1 water_treat_when_2 water_treat_when_3 water_treat_when_4 water_treat_when_5 water_treat_when_6 water_treat_when__77 water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type_5 water_treat_type_6 water_treat_type__77   chlorine_yesno chlorine_drank_yesno

global t2vars water_source_prim tap_use_drinking_yesno



save "$In_progress_files/Verif_R1_matching.dta", replace



keep unique_id V_surveydate V_enum_name  
	
save "$In_progress_files/Verif_R1_merging_with_followup.dta", replace

*************importing followup data**********************

 
use  "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent == 1

renpfix R_FU1_ //removing R_cen prefix 

clonevar unique_id = unique_id_num
format  unique_id %15.0gc

***********Merging census data with BC data******************
merge 1:1 unique_id using "$In_progress_files/Verif_R1_merging_with_followup.dta"

//since all IDs have matched

 //import follow up cleaned data again
use  "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent == 1

renpfix R_FU1_ //removing R_cen prefix 

clonevar unique_id = unique_id_num
format  unique_id %15.0gc

global id unique_id

rename r_cen_village_name_str survey_village

rename FU1_date survey_date

rename r_cen_a10_hhhead  survey_hhead

rename r_cen_a1_resp_name survey_Respondent

save "$In_progress_files/Follow_up_data_for_matching.dta", replace



*****************************after cleaning is done*********************************

clear 
//BC stats
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
 set matsize 600
 set emptycells drop
bcstats, surveydata("$In_progress_files/Follow_up_data_for_matching.dta") bcdata("$In_progress_files/Verif_R1_matching.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(water_source_prim)  enumerator(enum_name) backchecker(V_enum_name) keepsurvey(survey_village survey_date survey_Respondent)  keepbc(V_surveydate V_Village V_resp_name) showid(0) showall full lower trim filename(Verif_FollowupR1_diffs.csv) replace 
 

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

putexcel set "$In_progress_files\output.xlsx", sheet("error rate1") replace
putexcel A1 = "Error rate enum wise type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set output, modify sheet(error rate2)
putexcel A1 = "Error rate enum wise type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set output, modify sheet(error rate3)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set output, modify sheet(error rate4)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set output, modify sheet(error rate5)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set output, modify sheet(error rate6)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set output, modify sheet(error rate7)
putexcel A1 = "T-test results"
putexcel A2 = matrix(r(ttest2))
putexcel set output, modify sheet(ttest)









clear
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
import delimited "$In_progress_files/Verif_FollowupR1_diffs.csv", bindquote(strict) clear
replace v_enum_name = "Prasanta Panda" if v_enum_name == "Rajib Panda"

format  unique_id %15.0gc
replace survey = "" if survey == "."
replace back_check = "" if back_check == "."
replace survey_respondent = lower(survey_respondent)
replace bc_v_resp_name = lower(bc_v_resp_name)
drop type
rename survey FV_survey
rename back_check Verification
rename diff V_diff
rename survey_respondent FV_respondent
rename enum_name FV_enum_name
rename survey_village FV_survey_village
rename survey_date FV_survey_date

preserve
import delimited "$In_progress_files/BC_FollowupR1_diffs.csv", bindquote(strict) clear
format  unique_id %15.0gc
replace survey = "" if survey == "."
replace back_check = "" if back_check == "."
replace follow_respondent = lower(follow_respondent)
replace  bc_bc_resp_name = lower( bc_bc_resp_name)
drop type 
rename diff BC_diff
rename enum_name FB_enum_name
rename survey FB_survey
rename survey_village FB_survey_village
rename survey_date FB_survey_date
rename follow_respondent FB_respondent
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_FollowupR1_diffs_for_reshape.dta", replace
restore

merge m:m unique_id variable using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_FollowupR1_diffs_for_reshape.dta", assert(master using match) keep(master using match)
drop if _merge == 1
bysort unique_id: gen match = 1 if FV_survey == FB_survey & _merge == 3
br match if match != 1 & _merge == 3
//put a check to see if all follow up survey values match for matched_IDs
tostring V_diff, gen (V_diff_str)
tostring BC_diff, gen (BC_diff_str)
sort unique_id
br unique_id variable FB_survey back_check Verification  V_diff BC_diff V_diff_str BC_diff_str _merge
replace V_diff = 0 if FV_survey == "" &  Verification == "" & V_diff != .
replace BC_diff = 0 if FB_survey == "" &  back_check == "" & BC_diff != .
replace V_diff_str = "Error" if V_diff == 1
replace V_diff_str = "No Error" if V_diff == 0
replace BC_diff_str = "No Error" if BC_diff == 0
replace BC_diff_str = "Error" if BC_diff == 1
replace V_diff_str = "ID yet to be done" if V_diff == .
sort unique_id variable

save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Reshaped_BCR1_Verif_Followup_PIs.dta", replace

preserve
keep unique_id variable FB_survey back_check Verification  V_diff_str BC_diff_str _merge
rename FB_survey Followup_answers
rename V_diff_str Verification_errors
rename BC_diff_str Back_check_errors
gen dataset = ""
replace dataset = "Back_check_only" if _merge == 2
replace dataset = "Matched in both Verif and BC" if _merge == 3
drop _merge
export excel unique_id variable Followup_answers back_check Verification  Verification_errors Back_check_errors dataset using "$In_progress_files/reshaped_subset_BCR1_verif_followup_PIs", firstrow(variables) sheet(reshaped) sheetreplace 
restore

replace BC_diff = 0 if  unique_id == 40301111032 & variable == "water_treat_type"
replace BC_diff = 0 if unique_id == 30301119022 & variable == "water_treat_type"
replace V_diff = 0 if variable == "water_source_sec_1" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_1" & FB_survey == "0" & back_check == "1"
replace V_diff = 0 if variable == "water_source_sec_2" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_2" & FB_survey == "0" & back_check == "1"
replace V_diff = 0 if variable == "water_source_sec_3" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_3" & FB_survey == "0" & back_check == "1"
replace V_diff = 0 if variable == "water_source_sec_4" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_4" & FB_survey == "0" & back_check == "1"
replace V_diff = 0 if variable == "water_source_sec_5" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_5" & FB_survey == "0" & back_check == "1"
replace V_diff = 0 if variable == "water_source_sec_6" & FB_survey == "0" & Verification == "1"
replace BC_diff = 0 if variable == "water_source_sec_6" & FB_survey == "0" & back_check == "1"

//treatment wise
gen treatment = .
replace treatment = 1 if FB_survey_village == "Asada"
replace treatment = 1 if FB_survey_village == "Badabangi"
replace treatment = 1 if FB_survey_village == "Bichikote"
replace treatment = 1 if FB_survey_village == "Birnarayanpur"
replace treatment = 1 if FB_survey_village == "Gopi Kankubadi"
replace treatment = 0 if FB_survey_village == "Gudiabandh"
replace treatment = 0 if FB_survey_village == "Karlakana"
replace treatment = 1 if FB_survey_village == "Karnapadu"
replace treatment = 0 if FB_survey_village == "Kuljing"
replace treatment = 0 if FB_survey_village == "Mariguda"
replace treatment = 1 if FB_survey_village == "Mukundpur"
replace treatment = 1 if FB_survey_village == "Naira"
replace treatment = 1 if FB_survey_village == "Nathma"
replace treatment = 1 if FB_survey_village == "Tandipur"

//making resp same 
replace bc_v_resp_name = "podugu aruna kumari" if bc_v_resp_name == "podugu aruna"
replace bc_v_resp_name = "mamata mohanadia" if bc_v_resp_name == "mamata mohanandia"
replace bc_bc_resp_name = "mamata mohanadia" if bc_bc_resp_name == "mamata mohanandia"
replace bc_bc_resp_name = "podugu aruna kumari" if bc_bc_resp_name == "podugu aruna"
replace bc_bc_resp_name = "mandakini meleka" if bc_bc_resp_name == "madankini meleka"

//BC and Follow up comparison

preserve
drop if BC_diff == .
//gen same_Resp = 1 if FB_respondent == bc_bc_resp_name
//sum same_Resp
//gen total_same = r(sum)
//gen total_resp = _N
//gen ratio_same = (total_same/ total_resp)*100
bysort treatment variable: gen F_B_all = _N
drop if BC_diff == 0
bysort treatment variable: gen F_B_diff = _N
bysort treatment variable: gen F_B_Perc = (F_B_diff / F_B_all)*100
gen C_F_B_Perc = F_B_Perc if treatment == 0
gen C_F_B_all = F_B_all if treatment == 0
gen C_F_B_diff = F_B_diff if treatment == 0
gen T_F_B_all = F_B_all if treatment == 1
gen T_F_B_Perc = F_B_Perc if treatment == 1
gen T_F_B_diff = F_B_diff if treatment == 1
collapse C_F_B_all C_F_B_diff C_F_B_Perc T_F_B_all T_F_B_diff T_F_B_Perc, by(variable)
rename C_F_B_all BF_Control_total
rename C_F_B_diff BF_Control_differences
rename C_F_B_Perc BF_Control_Percentages
rename T_F_B_all BF_Treat_total
rename T_F_B_diff BF_Treat_differnces
rename T_F_B_Perc BF_Treat_Percentages
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Treatment_Control_BF.dta", replace
restore

//Verif and Follow up comparison
preserve
keep unique_id variable FV_survey Verification V_diff treatment
drop if V_diff == .
//gen same_Resp = 1 if FV_respondent == bc_bc_resp_name
//sum same_Resp
//gen total_same = r(sum)
//gen total_resp = _N
//gen ratio_same = (total_same/ total_resp)*100
bysort treatment variable: gen F_B_all = _N
drop if V_diff == 0
bysort treatment variable: gen F_B_diff = _N
bysort treatment variable: gen F_B_Perc = (F_B_diff / F_B_all)*100
gen C_F_B_Perc = F_B_Perc if treatment == 0
gen C_F_B_all = F_B_all if treatment == 0
gen C_F_B_diff = F_B_diff if treatment == 0
gen T_F_B_all = F_B_all if treatment == 1
gen T_F_B_Perc = F_B_Perc if treatment == 1
gen T_F_B_diff = F_B_diff if treatment == 1
collapse C_F_B_all C_F_B_diff C_F_B_Perc T_F_B_all T_F_B_diff T_F_B_Perc, by(variable)
rename C_F_B_all VF_Control_total
rename C_F_B_diff VF_Control_differences
rename C_F_B_Perc VF_Control_Percentages
rename T_F_B_all VF_Treat_total
rename T_F_B_diff VF_Treat_differnces
rename T_F_B_Perc VF_Treat_Percentages
merge 1:1 variable using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Treatment_Control_BF.dta"
export excel variable VF_Control_total VF_Control_differences VF_Control_Percentages VF_Treat_total VF_Treat_differnces VF_Treat_Percentages BF_Control_total BF_Control_differences BF_Control_Percentages BF_Treat_total BF_Treat_differnces BF_Treat_Percentages using "$In_progress_files/Reshaped_data_analysis", firstrow(variables) sheet(Combined_Treat_Control) sheetreplace
restore



//VARIABLE WISE//

//BC and Follow up comparison

preserve
drop if BC_diff == .
bysort variable: gen total_alldiffs = _N //it includes even cases where difference is 0
drop if BC_diff == 0
bysort variable: gen total_diffs = _N
bysort variable: gen var_diffs_ratio = (total_diffs/total_alldiffs)*100
collapse total_alldiffs var_diffs_ratio total_diffs, by (variable)
graph bar var_diffs_ratio, over(variable, label(labsize(vsmall) angle(45))) ///
    graphregion(c(white)) xsize(7) ylab(0(10)60, labsize(medsmall) angle(0)) ///
	ytitle("Variable wise % of obs with differnces to total obs") bar(1, fc(eltblue%80))
	graph export "$In_progress_files/diff_ratios.png" , replace	
rename total_alldiffs BF_Total
rename total_diffs BF_differences
rename var_diffs_ratio BF_Percentages
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Variable_BF.dta", replace
restore

//Verif and Follow up comparison

preserve
drop if V_diff == .
bysort variable: gen total_alldiffs = _N //it includes even cases where difference is 0
drop if V_diff == 0
bysort variable: gen total_diffs = _N
bysort variable: gen var_diffs_ratio = (total_diffs/total_alldiffs)*100
collapse total_alldiffs var_diffs_ratio total_diffs, by (variable)
graph bar var_diffs_ratio, over(variable, label(labsize(vsmall) angle(45))) ///
    graphregion(c(white)) xsize(7) ylab(0(10)60, labsize(medsmall) angle(0)) ///
	ytitle("Variable wise % of obs with differnces to total obs") bar(1, fc(eltblue%80))
	graph export "$In_progress_files/diff_ratios.png" , replace	
rename total_alldiffs VF_Total
rename total_diffs VF_differences
rename var_diffs_ratio VF_Percentages
merge 1:1 variable using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Variable_BF.dta"
export excel variable VF_Total VF_differences VF_Percentages BF_Total BF_differences BF_Percentages  using "$In_progress_files/Reshaped_data_analysis", firstrow(variables) sheet(Combined_Variable) sheetreplace
restore



//VILLAGE WISE


//BC and follow up wise


preserve
drop if BC_diff == .
rename FB_survey_village village 
bysort village: gen villagetotals=_N
drop if BC_diff == 0
bysort village: gen not0_villagetotals=_N
bysort village: gen percentage_not0_villagetotals= (not0_villagetotals/villagetotals)*100
collapse villagetotals not0_villagetotals percentage_not0_villagetotals, by ( village)
rename villagetotals BF_Total
rename not0_villagetotals BF_differences
rename percentage_not0_villagetotals BF_Percentages
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Village_BF.dta", replace
restore



//Verif and follow up wise
preserve
drop if V_diff == .
rename FB_survey_village village 
bysort village: gen villagetotals=_N
drop if V_diff == 0
bysort village: gen not0_villagetotals=_N
bysort village: gen percentage_not0_villagetotals= (not0_villagetotals/villagetotals)*100
collapse villagetotals not0_villagetotals percentage_not0_villagetotals, by ( village)
rename villagetotals V_Total
rename not0_villagetotals V_differences
rename percentage_not0_villagetotals V_Percentages
merge 1:1 village using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Village_BF.dta"
export excel village V_Total V_differences V_Percentages BF_Total BF_differences BF_Percentages using "$In_progress_files/Reshaped_data_analysis", firstrow(variables) sheet(Combined_Village) sheetreplace
restore












///////////////////////////////////////

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


