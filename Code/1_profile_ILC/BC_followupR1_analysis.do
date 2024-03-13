clear
global In_progress_files "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
import delimited "$In_progress_files/BC_FollowupR1_diffs.csv", bindquote(strict) clear
replace bc_name = "Manas Ranjan" if bc_name == "123"

format  unique_id %15.0gc
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if survey == "" & back_check == "."
drop if survey == "." & back_check == ""
replace follow_respondent = lower(follow_respondent)
replace bc_bc_resp_name = lower(bc_bc_resp_name)


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
keep if variable == "water_sec_yn" | variable == "water_treat" | variable == "water_source_prim" | variable == "tap_use_drinking_yesno" | variable == "chlorine_drank_yesno" | variable == "chlorine_yesno" | variable == "water_source_sec"
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


