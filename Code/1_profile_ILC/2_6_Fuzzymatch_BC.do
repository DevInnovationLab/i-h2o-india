clear
import delimited "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\bc_diffs.csv", bindquote(strict) 
preserve
keep unique_id bc_name bc_a7_resp_name bc_interviewed_before bc_no_of_u5child bc_no_of_preg bc_change_primary_source bc_a21_pregnant_hh_1 bc_a21_pregnant_arrive_1 bc_r_cen_village_name_str
format  unique_id %15.0gc
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0

sort unique_id
drop if dup_HHID != 1
gen bc_a7_resp_name_ = lower(bc_a7_resp_name)
drop bc_a7_resp_name
rename bc_a7_resp_name_ bc_a7_resp_name
rename bc_a7_resp_name a1_resp_name
replace a1_resp_name = trim( a1_resp_name)
replace a1_resp_name = ltrim( a1_resp_name)

split a1_resp_name, parse(" ") gen(first_name)

rename first_name2 middle_name
rename first_name3 last_name
rename unique_id unique_B
clonevar village_match = bc_r_cen_village_name_str
replace last_name = lower(last_name)
replace middle_name = lower(middle_name)
clonevar unique_id = unique_B
format  unique_id %15.0gc
drop dup_HHID


save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_fuzzymatching.dta", replace
restore


rename bc_a7_resp_name Ori_a7_resp_name
rename bc_interviewed_before Ori_interviewed_before
rename bc_no_of_u5child Ori_no_of_u5child
rename bc_no_of_preg Ori_no_of_preg
rename bc_change_primary_source Ori_change_primary_source
rename bc_a21_pregnant_hh_1 Ori_a21_pregnant_hh_1
rename bc_a21_pregnant_arrive_1 Ori_a21_pregnant_arrive_1
rename bc_r_cen_village_name_str Ori_village_name_str
*drop bc_name bc_a7_resp_name bc_interviewed_before bc_no_of_u5child bc_no_of_preg bc_change_primary_source bc_a21_pregnant_hh_1 bc_a21_pregnant_arrive_1
format  unique_id %15.0gc
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id if dup_HHID > 0
drop if dup_HHID!= 1
gen a1_resp_name_ = lower( a1_resp_name)
drop a1_resp_name
rename a1_resp_name_ a1_resp_name
replace a1_resp_name = trim( a1_resp_name)
replace a1_resp_name = ltrim( a1_resp_name)
split a1_resp_name, parse(" ") gen(first_name)
rename first_name2 middle_name
rename first_name3 last_name
rename unique_id unique_C
replace last_name = lower(last_name)
replace middle_name = lower(middle_name)

clonevar unique_id = unique_C
format  unique_id %15.0gc
drop dup_HHID

clonevar village_match = village_name

reclink a1_resp_name first_name1 middle_name unique_id village_match using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_fuzzymatching.dta", idmaster( unique_C) idusing(unique_B) required (unique_id village_match) gen(fuzzy) minscore(.75)
bysort unique_C : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
drop dup_HHID



clonevar fuzzy_respondent_list = Ua1_resp_name
replace fuzzy_respondent_list = Ori_a7_resp_name if fuzzy_respondent_list ==""

replace fuzzy = 1 if unique_C == 20201110007 & a1_resp_name == "aswpina sabara" & fuzzy == .
replace fuzzy = 1 if unique_C == 30202104027 & a1_resp_name == "bachi kondagore" & fuzzy == .
replace fuzzy = 1 if unique_C == 50401105002 & a1_resp_name == "bhimarao wataka" & fuzzy == .
replace fuzzy = 1 if unique_C == 30202109055 & a1_resp_name == "bijyabhati kumbhrika" & fuzzy == .
replace fuzzy = 1 if unique_C == 50401105013 & a1_resp_name == "budei himirika" & fuzzy == .
replace fuzzy = 1 if unique_C == 30501111003 & a1_resp_name == "chedivansha gouri" & fuzzy == .
replace fuzzy = 1 if unique_C == 50601104038 & a1_resp_name == "dalmai saraka" & fuzzy == .
replace fuzzy = 1 if unique_C == 30501105024 & a1_resp_name == "dhanamani chedibansa" & fuzzy == .
replace fuzzy = 1 if unique_C == 10201108016 & a1_resp_name == "geeta sabara" & fuzzy == .
replace fuzzy = 1 if unique_C == 40202110021 & a1_resp_name == "haripriya satpathy" & fuzzy == .
replace fuzzy = 1 if unique_C == 50401107009 & a1_resp_name == "mamata mohanadia" & fuzzy == .
replace fuzzy = 1 if unique_C == 10201110012 & a1_resp_name == "manisha ani" & fuzzy == .
replace fuzzy = 1 if unique_C == 30301109040 & a1_resp_name == "nabanita mahandia" & fuzzy == .
replace fuzzy = 1 if unique_C == 50201115012 & a1_resp_name == "nayeena miniaka" & fuzzy == .
replace fuzzy = 1 if unique_C == 20201113084 & a1_resp_name == "shishili bardhana" & fuzzy == .
replace fuzzy = 1 if unique_C == 50601115031 & a1_resp_name == "sushanti zilakara" & fuzzy == .
replace fuzzy = 1 if unique_C == 50201119012 & a1_resp_name == "timulit kandagari" & fuzzy == .
replace fuzzy = 1 if unique_C == 50601119044 & a1_resp_name == "katka saraka" & fuzzy == .
replace fuzzy = 0 if unique_C == 20201111017 & a1_resp_name == "babita dalabehera" & fuzzy != .
replace fuzzy = 0 if unique_C == 40202111079 & a1_resp_name == "nirmala badisethi" & fuzzy != .
replace fuzzy = 0 if unique_C == 40202110019 & a1_resp_name == "minu minika" & fuzzy != .


cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
export excel unique_C fuzzy fuzzy_respondent_list using "Fuzzymatch", sheetreplace firstrow(variables)
keep unique_C fuzzy_respondent_list fuzzy
rename unique_C unique_id 
save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\After_fuzzymatch_final data.dta", replace

clear
import delimited "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\bc_diffs.csv", bindquote(strict) 
format  unique_id %15.0gc
merge m:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\After_fuzzymatch_final data.dta", assert(master using match) keep(master using match)


replace fuzzy = 1 if fuzzy != .
replace fuzzy = 0 if fuzzy == .
*encode back_check, generate(back_check_num)
*drop back_check
*rename back_check_num  back_check
*encode survey, generate(survey_num)
*drop survey
*rename survey_num survey

global PathGraphs "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\New folder"

//VARIABLE WISE
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
bysort variable: gen total_alldiffs = _N //it includes even cases where difference is 0
drop if diff == 0
bysort variable: gen total_diffs = _N
bysort variable: gen var_diffs_ratio = (total_diffs/total_alldiffs)*100
collapse total_alldiffs var_diffs_ratio total_diffs, by (variable)
graph bar var_diffs_ratio, over(variable, label(labsize(vsmall) angle(45))) ///
    graphregion(c(white)) xsize(7) ylab(0(10)60, labsize(medsmall) angle(0)) ///
	ytitle("Variable wise % of obs with differnces to total obs") bar(1, fc(eltblue%80))
	graph export "$PathGraphs/diff_ratios.png" , replace	
export excel variable total_alldiffs total_diffs var_diffs_ratio using "BC_Census_wise_differences", firstrow(variables) sheet(diff_ratios) sheetreplace 
restore

/////
//FUZZY WISE
preserve
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
bysort variable: gen total_alldiffs = _N //it includes even cases where difference is 0
bysort variable fuzzy: gen all_diffs_res = _N
drop if diff == 0
bysort variable fuzzy: gen not0_diffs_res = _N
bysort variable fuzzy: gen percenatge_res_fuzzy_ratio = (not0_diffs_res/all_diffs_res)*100 
bysort variable fuzzy: gen percenatge_not0diffstoalldiffs = (not0_diffs_res/total_alldiffs)*100 
sort variable
br unique_id enum_name bc_name variable survey back_check diff village_name a1_resp_name bc_a7_resp_name total_alldiffs not0_diffs_res percenatge_not0diffstoalldiffs fuzzy if fuzzy == 1
export excel unique_id enum_name bc_name variable survey back_check diff village_name a1_resp_name bc_a7_resp_name total_alldiffs not0_diffs_res percenatge_not0diffstoalldiffs fuzzy if fuzzy == 1  using "Final_BC_Census_observationswise_sheet", firstrow(variables) sheet(allvars_fuzzywise) sheetreplace
collapse total_alldiffs all_diffs_res not0_diffs_res percenatge_res_fuzzy_ratio percenatge_not0diffstoalldiffs, by(variable fuzzy)
export excel variable fuzzy all_diffs_res not0_diffs_res percenatge_res_fuzzy_ratio total_alldiffs percenatge_not0diffstoalldiffs using "BC_Census_wise_differences", firstrow(variables) sheet(fuzzywise_ratios) sheetreplace 
restore

/////

///ENUM WISE 
preserve
//Total variables
//contains non differences too
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
bysort enum_name: gen total_diffs_enum = _N
bysort enum_name fuzzy: gen fuzzy_wise_enum = _N
drop if diff == 0
bysort enum_name: gen total_not0diffs_enum = _N
bysort enum_name: gen percenatge_not0diffs = (total_not0diffs_enum/total_diffs_enum)*100
bysort enum_name fuzzy: gen not0_fuzzy_wise_enum = _N
bysort enum_name fuzzy: gen percenatge_fuzzy_not0diffs = (not0_fuzzy_wise_enum/fuzzy_wise_enum)*100
br unique_id enum_name variable survey back_check a1_resp_name bc_a7_resp_name fuzzy fuzzy_wise_enum not0_fuzzy_wise_enum percenatge_fuzzy_not0diffs if fuzzy == 1
export excel  unique_id enum_name variable survey back_check a1_resp_name bc_a7_resp_name fuzzy fuzzy_wise_enum not0_fuzzy_wise_enum percenatge_fuzzy_not0diffs if fuzzy == 1 using "Final_BC_Census_observationswise_sheet", firstrow(variables) sheet(enum_allvars_fuzzywise) sheetreplace
collapse total_diffs_enum fuzzy_wise_enum total_not0diffs_enum percenatge_not0diffs not0_fuzzy_wise_enum percenatge_fuzzy_not0diffs, by ( enum_name fuzzy)
export excel enum_name fuzzy total_diffs_enum fuzzy_wise_enum total_not0diffs_enum percenatge_not0diffs not0_fuzzy_wise_enum percenatge_fuzzy_not0diffs using "BC_Census_wise_differences", firstrow(variables) sheet(enumwise_ratios) sheetreplace 
restore



**Only for key variables enum wose***
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
keep if variable == "a12_water_source_prim" | variable == "a16_stored_treat" | variable == "a16_stored_treat_freq" | variable == "a16_water_treat" | variable == "a16_water_treat_freq" | variable == "a17_treat_kids_freq" | variable == "a17_water_source_kids" | variable == "a17_water_treat_kids"| variable == "a18_jjm_drinking" | variable == "water_prim_source_kids" | variable == "water_treat_kids_type"
//Firstly doing enum wise
bysort enum_name : gen key_variable_enum = _N
bysort enum_name fuzzy: gen key_fuzzy_wise_enum = _N
drop if diff == 0
bysort enum_name : gen key_not0variable_enum = _N
bysort enum_name : gen percentage_key_not0variable_enum = (key_not0variable_enum/key_variable_enum)*100
bysort enum_name fuzzy: gen key_not0fuzzy_wise_enum = _N
bysort enum_name fuzzy: gen percentage_key_fuzzy_wise_enum = (key_not0fuzzy_wise_enum/key_fuzzy_wise_enum)*100
collapse key_variable_enum key_fuzzy_wise_enum key_not0variable_enum percentage_key_not0variable_enum key_not0fuzzy_wise_enum percentage_key_fuzzy_wise_enum, by ( enum_name fuzzy)
export excel enum_name fuzzy key_variable_enum key_fuzzy_wise_enum key_not0variable_enum percentage_key_not0variable_enum key_not0fuzzy_wise_enum percentage_key_fuzzy_wise_enum using "BC_Census_wise_differences", firstrow(variables) sheet(keyvariable_enumwise_ratios) sheetreplace
restore

**only for key varaibles, varable wise***
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
//all keyvariable wise
keep if variable == "a12_water_source_prim" | variable == "a16_stored_treat" | variable == "a16_stored_treat_freq" | variable == "a16_water_treat" | variable == "a16_water_treat_freq" | variable == "a17_treat_kids_freq" | variable == "a17_water_source_kids" | variable == "a17_water_treat_kids"| variable == "a18_jjm_drinking" | variable == "water_prim_source_kids" | variable == "water_treat_kids_type"
bysort variable: gen keytotal_alldiffs = _N //it includes even cases where difference is 0
drop if diff == 0
//key variable wise
bysort variable: gen not0keytotal_diffs = _N
bysort variable: gen keyvar_diffs_ratio = (not0keytotal_diffs/keytotal_alldiffs)*100
collapse keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio, by ( variable)
export excel variable keytotal_alldiffs not0keytotal_diffs keyvar_diffs_ratio using "BC_Census_wise_differences", firstrow(variables) sheet(keyvariable_variablewise_ratios) sheetreplace
restore


**only for key varaibles, varable fuzzy wise***
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
//all keyvariable wise
keep if variable == "a12_water_source_prim" | variable == "a16_stored_treat" | variable == "a16_stored_treat_freq" | variable == "a16_water_treat" | variable == "a16_water_treat_freq" | variable == "a17_treat_kids_freq" | variable == "a17_water_source_kids" | variable == "a17_water_treat_kids"| variable == "a18_jjm_drinking" | variable == "water_prim_source_kids" | variable == "water_treat_kids_type"
bysort variable fuzzy: gen key_fuzzy_total = _N
drop if diff == 0
bysort variable fuzzy: gen not0key_fuzzy_total = _N
bysort variable fuzzy: gen percenatge_not0key_fuzzy_total = (not0key_fuzzy_total/key_fuzzy_total)*100
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."

br unique_id enum_name bc_name variable survey back_check village_name diff a1_resp_name bc_a7_resp_name key_fuzzy_total not0key_fuzzy_total percenatge_not0key_fuzzy_total fuzzy if fuzzy == 1

export excel unique_id enum_name bc_name variable survey back_check village_name diff a1_resp_name bc_a7_resp_name key_fuzzy_total not0key_fuzzy_total percenatge_not0key_fuzzy_total fuzzy if fuzzy == 1  using "Final_BC_Census_observationswise_sheet", firstrow(variables) sheet(keyvars_fuzzywise) sheetreplace
collapse key_fuzzy_total not0key_fuzzy_total percenatge_not0key_fuzzy_total, by( variable fuzzy) 
export excel variable fuzzy key_fuzzy_total not0key_fuzzy_total percenatge_not0key_fuzzy_total using "BC_Census_wise_differences", firstrow(variables) sheet(keyvariable_fuzzywise_ratios) sheetreplace
restore


//VILLAGE WISE

preserve
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
bysort village_name: gen villagetotals=_N
bysort village_name fuzzy: gen fuzzyvillagetotals=_N
drop if diff == 0
bysort village_name: gen not0_villagetotals=_N
bysort village_name: gen percentage_not0_villagetotals= (not0_villagetotals/villagetotals)*100
bysort village_name fuzzy: gen not0_fuzzyvillagetotals=_N
bysort village_name fuzzy: gen percentage_fuzzyvillagetotals= (not0_fuzzyvillagetotals/fuzzyvillagetotals)*100
bysort village_name fuzzy: gen percentage_allvillagetotals= (not0_fuzzyvillagetotals/villagetotals)*100
br village_name unique_id enum_name bc_name variable survey back_check a1_resp_name bc_a7_resp_name fuzzy villagetotals not0_fuzzyvillagetotals percentage_allvillagetotals if fuzzy == 1
export excel village_name unique_id enum_name bc_name variable survey back_check a1_resp_name bc_a7_resp_name fuzzy villagetotals not0_fuzzyvillagetotals percentage_allvillagetotals if fuzzy == 1 using "Final_BC_Census_observationswise_sheet", firstrow(variables) sheet(villagewise_fuzzywise) sheetreplace
collapse villagetotals fuzzyvillagetotals not0_villagetotals percentage_not0_villagetotals not0_fuzzyvillagetotals percentage_fuzzyvillagetotals, by ( village_name fuzzy)
export excel village_name fuzzy villagetotals fuzzyvillagetotals not0_villagetotals percentage_not0_villagetotals not0_fuzzyvillagetotals percentage_fuzzyvillagetotals using "BC_Census_wise_differences", firstrow(variables) sheet(village_wise_differences) sheetreplace
restore

//VILLAGE WISE FOR KEY VARIABLES
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
//all keyvariable wise
keep if variable == "a12_water_source_prim" | variable == "a16_stored_treat" | variable == "a16_stored_treat_freq" | variable == "a16_water_treat" | variable == "a16_water_treat_freq" | variable == "a17_treat_kids_freq" | variable == "a17_water_source_kids" | variable == "a17_water_treat_kids"| variable == "a18_jjm_drinking" | variable == "water_prim_source_kids" | variable == "water_treat_kids_type"
bysort village_name: gen keyvariable_villagetotals=_N
bysort village_name fuzzy: gen key_fuzzyvillagetotals=_N
drop if diff == 0
bysort village_name: gen keynot0_villagetotals=_N
bysort village_name: gen keypercentage_not0_villagetotals= (keynot0_villagetotals/keyvariable_villagetotals)*100
bysort village_name fuzzy: gen keynot0_fuzzyvillagetotals=_N
bysort village_name fuzzy: gen keypercentage_fuzzyvillagetotals= (keynot0_fuzzyvillagetotals/key_fuzzyvillagetotals)*100
collapse keyvariable_villagetotals key_fuzzyvillagetotals keynot0_villagetotals keypercentage_not0_villagetotals keynot0_fuzzyvillagetotals keypercentage_fuzzyvillagetotals, by ( village_name fuzzy)
export excel village_name fuzzy keyvariable_villagetotals key_fuzzyvillagetotals keynot0_villagetotals keypercentage_not0_villagetotals keynot0_fuzzyvillagetotals keypercentage_fuzzyvillagetotals using "BC_Census_wise_differences", firstrow(variables) sheet(keyvariable_village_wise) sheetreplace
restore

//FOR each key variable 
preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
keep if variable == "a12_water_source_prim" 
drop if diff == 0
drop if fuzzy == 0
gen earliertap_butBCdiff = 1 if survey == "Government provided household Taps (supply paani)" & back_check != "Government provided household Taps (supply paani)" & back_check != "Government provided community standpipe" & back_check != "."
gen earliercommtap_butBCdiff = 1 if survey == "Government provided community standpipe" & back_check != "Government provided household Taps (supply paani)" & back_check != "Government provided community standpipe" & back_check != "."
cap export excel unique_id enum_name bc_name variable survey back_check diff village_name a1_resp_name bc_a7_resp_name earliertap_butBCdiff earliercommtap_butBCdiff if earliertap_butBCdiff == 1 | earliercommtap_butBCdiff == 1 using "BC_Census_wise_differences", firstrow(variables) sheet(a12_water_source_prim) sheetreplace
restore

preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
keep if variable == "a18_jjm_drinking"
drop if diff == 0
drop if fuzzy == 0
gen censusyes_BCno = 1 if survey == "Yes" & back_check != "Yes" & back_check != "."
cap export excel unique_id enum_name bc_name variable survey back_check diff a1_resp_name bc_a7_resp_name fuzzy censusyes_BCno if censusyes_BCno == 1 using "BC_Census_wise_differences", firstrow(variables) sheet(a18_jjm_drinking) sheetreplace
restore

preserve
drop if variable == "a10_hhhead" & survey == "" & back_check == ""
drop if survey == "" & back_check == ""
drop if survey == "." & back_check == "."
drop if back_check == ""
drop if back_check == "."
keep if variable == "water_prim_source_kids"
drop if diff == 0
drop if fuzzy == 0
gen earliertap_butBCdiff = 1 if survey == "Government provided household Taps (supply paani)" & back_check != "Government provided household Taps (supply paani)" & back_check != "Government provided community standpipe" & back_check != "."
gen earliercommtap_butBCdiff = 1 if survey == "Government provided community standpipe" & back_check != "Government provided household Taps (supply paani)" & back_check != "Government provided community standpipe" & back_check != "."
cap export excel unique_id enum_name bc_name variable survey back_check village_name a1_resp_name bc_a7_resp_name fuzzy earliertap_butBCdiff earliercommtap_butBCdiff  if earliertap_butBCdiff == 1 | earliercommtap_butBCdiff == 1 using "BC_Census_wise_differences", firstrow(variables) sheet(water_prim_source_kids) sheetreplace
restore
