

do "${Do_lab}import_india_ilc_pilot_backcheck_follow_up_R1_Master.do"

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



drop if BC_surveydate == mdy(3,6,2024)
duplicates list unique_id

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
list unique_id r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name1 key if r_fu1_r_cen_a1_resp_name != r_fu1_r_cen_fam_name1

*correct spelling errors to make them uniform 
replace r_fu1_r_cen_fam_name1 = "Podugu aruna kumari" if r_fu1_r_cen_fam_name1  == "Podugu aruna" & unique_id == 50301117030 & key == "uuid:627636e7-263e-4747-bcd1-e66ad5a89763"
replace r_fu1_r_cen_fam_name1 = "Mamata mohanadia" if r_fu1_r_cen_fam_name1  == "Mamata Mohanandia" & unique_id ==  50401107009   & key == "uuid:d83ee7f3-58ea-4f00-b5c3-a4c46133c144"

*To verify if BC resp are same or not we need to check if 
list unique_id r_fu1_r_cen_village_name_str if  who_interviwed_before_1 == 0

* To check the actual resp 

forvalues i = 2/20 {
      list unique_id r_fu1_r_cen_village_name_str r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1
	  gen not_matched_`i' = 1 if who_interviwed_before_`i' == 1 & r_fu1_r_cen_a1_resp_name != r_fu1_r_cen_fam_name`i'
	  }

* Initialize the flag variable to 0 (assume no matches to start)
gen flag = 0

* Loop through each of the not_matched variables
forvalues i = 2/20 {
replace flag = 1 if not_matched_`i' == 1
}

*export excel unique_id r_fu1_r_cen_village_name_str r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name1 r_fu1_r_cen_fam_name2 r_fu1_r_cen_fam_name3 r_fu1_r_cen_fam_name4 r_fu1_r_cen_fam_name5 r_fu1_r_cen_fam_name6 r_fu1_r_cen_fam_name7 r_fu1_r_cen_fam_name8 r_fu1_r_cen_fam_name9 r_fu1_r_cen_fam_name10 r_fu1_r_cen_fam_name11 r_fu1_r_cen_fam_name12 r_fu1_r_cen_fam_name13 r_fu1_r_cen_fam_name14 r_fu1_r_cen_fam_name15 r_fu1_r_cen_fam_name16 r_fu1_r_cen_fam_name17 r_fu1_r_cen_fam_name18 r_fu1_r_cen_fam_name19 r_fu1_r_cen_fam_name20 who_interviwed_before_1 who_interviwed_before_2 who_interviwed_before_3  who_interviwed_before_4 who_interviwed_before_5 who_interviwed_before_6 who_interviwed_before_7 who_interviwed_before_8 who_interviwed_before_9 who_interviwed_before_10 who_interviwed_before_11 who_interviwed_before_12 who_interviwed_before_13 who_interviwed_before_14 who_interviwed_before_15 who_interviwed_before_16 who_interviwed_before_17 who_interviwed_before_18 who_interviwed_before_19 who_interviwed_before_20  using "$In_progress_files/Final_BC_FollowupR1_sheets" if flag == 1, firstrow(variables) sheet(different_respondent) sheetreplace


//find the reasons why the resp was not the same 
gen r_fu1_r_BC_village_name_str = ""
replace r_fu1_r_BC_village_name_str = r_fu1_r_cen_a1_resp_name if (r_fu1_r_cen_a1_resp_name == r_fu1_r_cen_fam_name1) & flag == 0

forvalues i = 2/20 {
replace r_fu1_r_BC_village_name_str = r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1 & flag == 1
}

*We have created a BC respondent var to find error rates for the cases where respondent names are diff 

rename enum_name BC_name

drop r_fu1_r_cen_a1_resp_name 
rename r_fu1_r_BC_village_name_str BC_resp_name
 
global id unique_id

global t1vars water_sec_yn water_source_sec water_source_main_sec where_prim_locate where_sec_locate water_treat water_treat_when water_treat_type chlorine_yesno chlorine_drank_yesno

global t2vars water_source_prim tap_use_drinking_yesno
rename r_fu1_r_cen_village_name_str BC_village_name

rename r_fu1_r_cen_a10_hhhead BC_hhead_name

rename * BC_*
save "$In_progress_files/BC_data.dta", replace



keep unique_id BC_surveydate BC_name  
	
save "$In_progress_files/BC_FollowpR1_for_comparison_with_verification.dta", replace





*************importing verif data**********************








do "${Do_lab}import_india_ilc_pilot_backcheck_follow_up_R1_Master.do"

*hey, astha not setting any common path for exporting working files because they are merely used for merging etc 
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"

replace consent = 0 if consent == .

drop if consent == 0

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen verif_surveydate = dofc(submissiondate)
format verif_surveydate %td


bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0



keep if verif_surveydate == mdy(3,6,2024)
duplicates list unique_id

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
list unique_id r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name1 key if r_fu1_r_cen_a1_resp_name != r_fu1_r_cen_fam_name1

*correct spelling errors to make them uniform 
replace r_fu1_r_cen_fam_name1 = "Podugu aruna kumari" if r_fu1_r_cen_fam_name1  == "Podugu aruna" & unique_id == 50301117030 & key == "uuid:627636e7-263e-4747-bcd1-e66ad5a89763"
replace r_fu1_r_cen_fam_name1 = "Mamata mohanadia" if r_fu1_r_cen_fam_name1  == "Mamata Mohanandia" & unique_id ==  50401107009   & key == "uuid:d83ee7f3-58ea-4f00-b5c3-a4c46133c144"

*To verify if BC resp are same or not we need to check if 
list unique_id r_fu1_r_cen_village_name_str if  who_interviwed_before_1 == 0

* To check the actual resp 

forvalues i = 2/20 {
      list unique_id r_fu1_r_cen_village_name_str r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1
	  gen not_matched_`i' = 1 if who_interviwed_before_`i' == 1 & r_fu1_r_cen_a1_resp_name != r_fu1_r_cen_fam_name`i'
	  }

* Initialize the flag variable to 0 (assume no matches to start)
gen flag = 0

* Loop through each of the not_matched variables
forvalues i = 2/20 {
replace flag = 1 if not_matched_`i' == 1
}

*export excel unique_id r_fu1_r_cen_village_name_str r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name1 r_fu1_r_cen_fam_name2 r_fu1_r_cen_fam_name3 r_fu1_r_cen_fam_name4 r_fu1_r_cen_fam_name5 r_fu1_r_cen_fam_name6 r_fu1_r_cen_fam_name7 r_fu1_r_cen_fam_name8 r_fu1_r_cen_fam_name9 r_fu1_r_cen_fam_name10 r_fu1_r_cen_fam_name11 r_fu1_r_cen_fam_name12 r_fu1_r_cen_fam_name13 r_fu1_r_cen_fam_name14 r_fu1_r_cen_fam_name15 r_fu1_r_cen_fam_name16 r_fu1_r_cen_fam_name17 r_fu1_r_cen_fam_name18 r_fu1_r_cen_fam_name19 r_fu1_r_cen_fam_name20 who_interviwed_before_1 who_interviwed_before_2 who_interviwed_before_3  who_interviwed_before_4 who_interviwed_before_5 who_interviwed_before_6 who_interviwed_before_7 who_interviwed_before_8 who_interviwed_before_9 who_interviwed_before_10 who_interviwed_before_11 who_interviwed_before_12 who_interviwed_before_13 who_interviwed_before_14 who_interviwed_before_15 who_interviwed_before_16 who_interviwed_before_17 who_interviwed_before_18 who_interviwed_before_19 who_interviwed_before_20  using "$In_progress_files/Final_BC_FollowupR1_sheets" if flag == 1, firstrow(variables) sheet(different_respondent) sheetreplace


//find the reasons why the resp was not the same 
gen r_fu1_r_BC_village_name_str = ""
replace r_fu1_r_BC_village_name_str = r_fu1_r_cen_a1_resp_name if (r_fu1_r_cen_a1_resp_name == r_fu1_r_cen_fam_name1) & flag == 0

forvalues i = 2/20 {
replace r_fu1_r_BC_village_name_str = r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1 & flag == 1
}

*We have created a BC respondent var to find error rates for the cases where respondent names are diff 

rename enum_name verif_name

drop r_fu1_r_cen_a1_resp_name 
rename r_fu1_r_BC_village_name_str verif_resp_name
 
global id unique_id

global t1vars water_sec_yn water_source_sec water_source_main_sec where_prim_locate where_sec_locate water_treat water_treat_when water_treat_type chlorine_yesno chlorine_drank_yesno

global t2vars water_source_prim tap_use_drinking_yesno
rename r_fu1_r_cen_village_name_str verif_village_name

rename r_fu1_r_cen_a10_hhhead verif_hhead_name


global id unique_id



save "$In_progress_files/Verif_comparison.dta", replace


	


*****************************after cleaning is done*********************************

clear 
//BC stats
cd "$In_progress_files"
 set matsize 600
 set emptycells drop
bcstats, surveydata("$In_progress_files/BC_FollowupR1_comparison.dta") bcdata("$In_progress_files/Verif_comparison.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(water_source_prim)  enumerator(BC_name) backchecker(verif_name) keepsurvey(BC_village_name BC_surveydate BC_hhead_name BC_resp_name) ///
keepbc(verif_surveydate verif_village_name verif_hhead_name verif_resp_name) showid(10) showall full lower trim filename(Verif_BC_diffs.csv) replace 
 

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

putexcel set "$In_progress_files\Verif.xlsx", sheet("error rate1") replace
putexcel A1 = "Error rate enum wise type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set Verif, modify sheet(error rate2)
putexcel A1 = "Error rate enum wise type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set Verif, modify sheet(error rate3)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set Verif, modify sheet(error rate4)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set Verif, modify sheet(error rate5)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set Verif, modify sheet(error rate6)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set Verif, modify sheet(error rate7)
putexcel A1 = "T-test results"
putexcel A2 = matrix(r(ttest2))
putexcel set Verif, modify sheet(ttest)





//COMPARISON WITH BACK CHECK - VERIFICATIN











/// MAIN ANALYSIS 



clear
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
import delimited "$In_progress_files/Verif_FollowupR1_diffs.csv", bindquote(strict) clear
replace bc_name = "Prasanta Panda" if bc_name == "Rajib Panda"

format  unique_id %15.0gc
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if survey == "" & back_check == "."
drop if survey == "." & back_check == ""
replace follow_respondent = lower(follow_respondent)
replace bc_bc_resp_name = lower(bc_bc_resp_name)


//Unique_ID_wise
preserve
*drop if follow_respondent != bc_bc_resp_name
bysort unique_id: gen u_alldiffs = _N
drop if diff == 0
bysort unique_id: gen total_diffs = _N
bysort unique_id: gen u_diffs_ratio = (total_diffs/u_alldiffs)*100
restore

//VARIABLE WISE
preserve
//same resp only
drop if follow_respondent != bc_bc_resp_name
br variable follow_respondent bc_bc_resp_name if follow_respondent != bc_bc_resp_name
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
	
global Variables variable total_alldiffs total_diffs var_diffs_ratio 
texsave $Variables using "$In_progress_files/var_diff_ratios.tex", ///
        title("Variable wise differences") footnote("Notes: Responses of only same respondents across survey and back cehcks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")

export excel variable total_alldiffs total_diffs var_diffs_ratio using "$In_progress_files/BC_Followup_wise_differences", firstrow(varlabels) sheet(var_diff_ratios) sheetreplace 
restore

///ENUM WISE 
preserve
//Total variables
//contains non differences too
drop if follow_respondent != bc_bc_resp_name
bysort enum_name: gen total_diffs_enum = _N
drop if diff == 0
bysort enum_name: gen total_not0diffs_enum = _N
bysort enum_name: gen percenatge_not0diffs = (total_not0diffs_enum/total_diffs_enum)*100
collapse total_diffs_enum  total_not0diffs_enum percenatge_not0diffs, by (enum_name)
label variable total_diffs_enum "Total observations for each enum"
label variable total_not0diffs_enum "Total differences for each enum"
label variable percenatge_not0diffs "Percentages"

	
global Variables enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs
texsave $Variables using "$In_progress_files/enum_diff_ratios.tex", ///
        title("Enumerator wise differences") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Enumeartors}")

export excel enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs using "$In_progress_files/BC_Followup_wise_differences", firstrow(varlabels) sheet(enumwise_ratios) sheetreplace 
restore



**Only for key variables enum wose***
preserve
drop if follow_respondent != bc_bc_resp_name
//Firstly doing enum wise
bysort enum_name : gen key_variable_enum = _N
drop if diff == 0
bysort enum_name : gen key_not0variable_enum = _N
bysort enum_name : gen percentage_key_not0variable_enum = (key_not0variable_enum/key_variable_enum)*100
label variable key_variable_enum "Total observations for each enum (only key vars)"
label variable key_not0variable_enum "Total differences for each enum (only key variables)"
label variable percentage_key_not0variable_enum "Percentages (only key variables)"
rename 	percentage_key_not0variable_enum percentage
global Variables enum_name bc_name variable  survey back_check   key_variable_enum key_not0variable_enum percentage
texsave $Variables using "$In_progress_files/key_enum_diff_ratios.tex", ///
        title("Enumerator wise differences (Only key variables)") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Enumeartors}")

export excel enum_name bc_name variable  survey back_check   key_variable_enum key_not0variable_enum percentage using "$In_progress_files/BC_Followup_wise_differences", firstrow(varlabels) sheet(keyvariable_enumwise_ratios) sheetreplace
restore

**only for key varaibles, varable wise***
preserve
drop if follow_respondent != bc_bc_resp_name
keep if variable == "water_sec_yn" | variable == "water_treat" | variable == "water_source_prim" | variable == "tap_use_drinking_yesno" | variable == "chlorine_drank_yesno" | variable == "chlorine_yesno" | variable == "water_source_sec"
//all keyvariable wise
bysort variable: gen keytotal_alldiffs = _N //it includes even cases where difference is 0
drop if diff == 0
//key variable wise
bysort variable: gen not0keytotal_diffs = _N
bysort variable: gen keyvar_diffs_ratio = (not0keytotal_diffs/keytotal_alldiffs)*100
label variable keytotal_alldiffs "Total observations for each variable (only key vars)"
label variable not0keytotal_diffs "Total differences for each variable (only key vars)"
label variable keyvar_diffs_ratio " Percentages (only key vars)"
global Variables variable survey back_check keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio
texsave $Variables using "$In_progress_files/key_var_diff_ratios.tex", ///
        title("Variable wise differences (Only key variables)") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")


export excel variable survey back_check keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio using "$In_progress_files/BC_Followup_wise_differences", firstrow(varlabels) sheet(keyvariable_variablewise_ratios) sheetreplace
restore



//VILLAGE WISE for key

preserve
drop if follow_respondent != bc_bc_resp_name
replace bc_bc_village_name = "Gopi Kankubadi" if bc_bc_village_name == "Gopi_Kankubadi"
keep if variable == "water_sec_yn" | variable == "water_treat" | variable == "water_source_prim" | variable == "tap_use_drinking_yesno" | variable == "chlorine_drank_yesno" | variable == "chlorine_yesno" | variable == "water_source_sec"
clonevar village = survey_village
bysort village: gen villagetotals=_N
drop if diff == 0
bysort village: gen not0_villagetotals=_N
bysort village: gen percentage_not0_villagetotals= (not0_villagetotals/villagetotals)*100
collapse villagetotals not0_villagetotals percentage_not0_villagetotals, by ( village)
label variable villagetotals "Total observations for each village (only key vars)"
label variable not0_villagetotals "Total differences for each village (only key vars)"
rename percentage_not0_villagetotals Percentages
label variable percentage_not0_villagetotals " Percentages (only key vars)"

global Variables village villagetotals not0_villagetotals percentage_not0_villagetotals
texsave $Variables using "$In_progress_files/key_village_diff_ratios.tex", ///
        title("Village wise differences (Only key variables)") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Villages}")


export excel village villagetotals not0_villagetotals percentage_not0_villagetotals using "$In_progress_files/BC_Followup_wise_differences", firstrow(varlabels) sheet(key_village_wise_differences) sheetreplace
restore


