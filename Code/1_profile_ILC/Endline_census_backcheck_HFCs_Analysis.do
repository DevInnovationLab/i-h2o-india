


do "${Do_lab}import_India_ILC_Endline_BackCheck_Census.do"

global In_progress_files "${DataRaw}Endline BackCheck output"


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


	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"
	label variable enum_name "Enumerator Name"

	

tab interviewed_before



rename enum_name BC_name

rename bc_cen_resp_name_lab BC_Main_Respondent

list if BC_Main_Respondent != interview_before_label

forvalues i = 1/20 {
gen eligible_Main_resp`i' = 1 if cen_fam_gender`i' == "1" & who_interviwed_before == `i'

}

egen temp_group = group(unique_id)
egen eligible_Main_resp_T = rowtotal(eligible_Main_resp*)
drop temp_group


split interview_before_label, generate(resp_name_diff) parse(" and ")
rename resp_name_diff1 interview_before_noage


gen diff_resp_baseline = 1 if interview_before_noage != r_cen_a1_resp_name

label variable r_cen_a1_resp_name "Baseline Census Resp"
label variable interview_before_label "Endline main resp reported by enum"
label variable eligible_Main_resp_T "Is main resp male"
label variable BC_Main_Respondent "BC main resp"
label variable diff_resp_baseline "Main resp diff from baseline"



*gen mismatch = 0

*forvalues i = 1/2 {
    *forvalues j = 1/20 {
        *replace mismatch = 1 if b_hhmember_name_`i' != r_cen_fam_name`j' & b_hhmember_name_`i' != "" & r_cen_fam_name`j' != ""
    *}
*}

forvalues i = 1/2 {
    gen mismatch_`i' = 0 
    forvalues j = 1/20 {
        replace mismatch_`i' = 1 if (b_hhmember_name_`i' != r_cen_fam_name`j' & b_hhmember_name_`i' != "" & r_cen_fam_name`j' != "") | (b_hhmember_name_`i' != r_e_n_fam_name`j' & b_hhmember_name_`i' != "" & r_e_n_fam_name`j' != "")
    }
}

export excel unique_id BC_name r_cen_a1_resp_name interview_before_label eligible_Main_resp_T BC_Main_Respondent diff_resp_baseline  using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(Resp_diff) sheetreplace 
export excel unique_id BC_name b_hhmember_name_1 b_hhmember_name_2 r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5 r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17 r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 r_e_n_fam_name1 r_e_n_fam_name2 r_e_n_fam_name3 r_e_n_fam_name4 r_e_n_fam_name5 r_e_n_fam_name6 r_e_n_fam_name7 r_e_n_fam_name8 r_e_n_fam_name9 r_e_n_fam_name10 r_e_n_fam_name11 r_e_n_fam_name12 r_e_n_fam_name13 r_e_n_fam_name14 r_e_n_fam_name15 r_e_n_fam_name16 r_e_n_fam_name17 r_e_n_fam_name18 r_e_n_fam_name19 r_e_n_fam_name20 mismatch_1 mismatch_2  using "$In_progress_files/BC_Endline_differences" if mismatch_1 != 0 | mismatch_2 != 0, firstrow(varlabels) sheet(new_memebers_diff) sheetreplace 


*cen_still_a_member_1 cen_still_a_member_2 cen_still_a_member_3 cen_still_a_member_4 cen_still_a_member_5 cen_still_a_member_6 cen_still_a_member_7 cen_still_a_member_8 cen_still_a_member_9 cen_still_a_member_10 n_hhmember_gender_1 n_hhmember_gender_2 n_hhmember_gender_3 n_hhmember_gender_4 n_hhmember_relation_1 n_hhmember_relation_2 n_hhmember_relation_3 n_hhmember_relation_4 n_hhmember_age_1 n_hhmember_age_2 n_hhmember_age_3 n_hhmember_age_4 n_u5mother_1 n_u5mother_name_1 n_u5mother_2 n_u5mother_name_2 n_u5mother_3 n_u5mother_name_3 n_u5mother_4 n_u5mother_name_4 n_u5father_name_1 n_u5father_name_2 n_u5father_name_3 n_u5father_name_4 cen_preg_status_1 cen_preg_status_2 cen_preg_status_3 cen_preg_status_4 cen_preg_status_5 cen_preg_status_6 cen_preg_status_7 cen_preg_status_8 cen_preg_status_9 cen_preg_status_10 cen_preg_status_11 cen_preg_status_12 cen_preg_status_13 cen_preg_status_14 cen_preg_status_15 cen_preg_status_16 cen_preg_status_17 cen_not_curr_preg_1 cen_not_curr_preg_2 cen_not_curr_preg_3 cen_not_curr_preg_4 cen_not_curr_preg_5 cen_not_curr_preg_6 cen_not_curr_preg_7 cen_not_curr_preg_8 cen_not_curr_preg_9 cen_not_curr_preg_10 cen_not_curr_preg_11 cen_not_curr_preg_12 cen_not_curr_preg_13 cen_not_curr_preg_14 cen_not_curr_preg_15 cen_not_curr_preg_16 cen_not_curr_preg_17 cen_preg_residence_1 cen_preg_residence_2 cen_preg_residence_3 cen_preg_residence_4 cen_preg_residence_5 cen_preg_residence_6 cen_preg_residence_7 cen_preg_residence_8 cen_preg_residence_9 cen_preg_residence_10 cen_preg_residence_11 cen_preg_residence_12 cen_preg_residence_13 cen_preg_residence_14 cen_preg_residence_15 cen_preg_residence_16 cen_preg_residence_17 n_preg_status_1 n_not_curr_preg_1 n_preg_residence_1
global id unique_id
global t1vars  water_source_prim water_sec_yn water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 water_source_main_sec where_prim_locate where_prim_locate_enum_obs water_treat water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_freq water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 jjm_drinking tap_supply_freq 


rename r_cen_village_name_str BC_village_name

rename r_cen_a10_hhhead BC_hhead_name



save "$In_progress_files/BC_Endline_for_matching.dta", replace



keep unique_id BC_surveydate BC_name  
	
save"$In_progress_files/BC_for_merging_with_endline.dta", replace

*************importing endline data**********************

use "${DataPre}1_1_Endline_XXX_consented.dta", clear

gen submit_date = dofc(R_E_submissiondate)
format submit_date %td 

//survey start date - 21st apr 2024
drop if submit_date < mdy(04,21,2024)

drop if R_E_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 

replace R_E_r_cen_village_name_str = "Gopi_Kankubadi" if R_E_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_E_r_cen_village_name_str = "BK_Padar" if R_E_r_cen_village_name_str == "BK Padar" 

renpfix R_E_

save "$In_progress_files/endline_census_interim.dta", replace

***********Merging census data with BC data******************
drop _merge
destring unique_id, replace
merge 1:1 unique_id using "$In_progress_files/BC_for_merging_with_endline.dta"


//since all IDs have matched

 //import follow up cleaned data again
use "$In_progress_files/endline_census_interim.dta", clear

destring unique_id, replace


global id unique_id

rename r_cen_village_name_str survey_village

gen surveydate = dofc(submissiondate)
format surveydate %td


rename r_cen_a10_hhhead  survey_hhead

rename cen_resp_label Endline_resp_name


save "$In_progress_files/endline_census_for_matching.dta", replace



*****************************after cleaning is done*********************************

clear 
*ssc install bcstats
//BC stats
cd "${DataRaw}Endline BackCheck output"
 set matsize 600
 set emptycells drop
bcstats, surveydata("$In_progress_files/endline_census_for_matching.dta") bcdata("$In_progress_files/BC_Endline_for_matching.dta") id($id) t1vars($t1vars)  enumerator(enum_name) backchecker(BC_name) keepsurvey(Endline_resp_name survey_village surveydate)  keepbc(BC_surveydate BC_village_name  BC_Main_Respondent sec_source_days_ago treat_days_ago) showid(5) showall full lower trim filename(BC_Endline_bctstas.csv) replace 
 


	
return list 



//ANALYSIS //////////////////////////////////////////////////////////

clear
global In_progress_files "${DataRaw}Endline BackCheck output"

import delimited "$In_progress_files/BC_Endline_bctstas.csv", bindquote(strict) clear

format  unique_id %15.0gc
*drop if survey == "" & back_check == ""
*drop if survey == "." & back_check == "."
*drop if survey == "" & back_check == "."
*drop if survey == "." & back_check == ""
replace endline_resp_name = lower(endline_resp_name)
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
export excel unique_id variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village endline_resp_name bc_bc_main_respondent u_alldiffs total_diffs u_diffs_ratio using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(unqiue_diff_ratios) sheetreplace 

*global Variables unique_id variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent u_alldiffs total_diffs u_diffs_ratio

/*global Variables unique_id variable survey back_check u_alldiffs total_diffs u_diffs_ratio
texsave $Variables using "$In_progress_files/R3_unique_diff_ratios.tex", ///
        title("Unique ID wise differences") footnote("Notes: Responses of only same respondents across survey and back cehcks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Unique_ID}")*/

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
export excel variable total_alldiffs total_diffs var_diffs_ratio using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(var_diff_ratios) sheetreplace 

*global Variables variable total_alldiffs total_diffs var_diffs_ratio 
	
/*global Variables variable total_alldiffs total_diffs var_diffs_ratio 
texsave $Variables using "$In_progress_files/R3_var_diff_ratios.tex", ///
        title("Variable wise differences") footnote("Notes: Responses of only same respondents across survey and back cehcks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")*/

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
export excel enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(enumwise_ratios) sheetreplace 	

/*global Variables enum_name total_diffs_enum total_not0diffs_enum percenatge_not0diffs
texsave $Variables using "$In_progress_files/R3_enum_diff_ratios.tex", ///
        title("Enumerator wise differences") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Enumeartors}")*/

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
export excel variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village endline_resp_name bc_bc_main_respondent keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(variable_values) sheetreplace 
*global Variables variable survey back_check diff enum_name bc_name surveydate bc_bc_surveydate survey_village followup_respondent bc_bc_main_respondent keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio

/*global Variables variable survey back_check keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio
texsave $Variables using "$In_progress_files/R3_var_values_diff_ratios.tex", ///
        title("Variable wise differences (With variable values)") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Variables}")*/
		
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
export excel village villagetotals not0_villagetotals Percentages using "$In_progress_files/BC_Endline_differences", firstrow(varlabels) sheet(village_wise_differences) sheetreplace

/*global Variables village villagetotals not0_villagetotals Percentages
texsave $Variables using "$In_progress_files/R3_village_diff_ratios.tex", ///
        title("Village wise differences") footnote("Notes: Responses of only same respondents across survey and back checks are taken into account") replace varlabels frag location(htbp) headerlines("&\multicolumn{8}{c}{Villages}")*/

restore


















