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

/*------ In this do file: 
	(1) This do file exports the preload data for mortality survey 
	(2) Also exports tracking sheets for supervisors for mortality survey ------ */

*------------------------------------------------------------------- -------------------------------------------------------------------*


***************************************************
* Step 1: Cleaning  *
***************************************************

use "C:\Users\Archi Gupta\Box\Data\1_raw\1_8_Endline\1_8_Endline_Census.dta", clear

//some basic cleaning 
gen submit_date = dofc(submissiondate)
format submit_date %td 

//survey start date - 21st apr 2024
drop if submit_date < mdy(04,21,2024)

drop if key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 

//differentiating baseline census variables with existing variables now 

ds cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12 cen_children_below12 cen_num_childbelow12 cen_num_childbelow5 cen_num_malesabove15 cen_malesabove15_list_preload cen_num_hhmembers cen_num_noncri
foreach i of varlist `r(varlist)'{
rename `i' r_`i'
}

// Loop over all variables
foreach var of varlist _all {
    // Check if the variable name does not start with 'r_cen_'
    if strpos("`var'", "r_cen_") == 0 {
        // Rename the variable by adding prefix 'E_'
        rename `var' E_`var'
    }
}

rename E_unique_id unique_id
rename (E_submissiondate E_starttime E_endtime E_submit_date) (submissiondate starttime endtime submit_date)

replace r_cen_village_name_str = "Gopi_Kankubadi" if r_cen_village_name_str == "Gopi Kankubadi" 
replace r_cen_village_name_str = "BK_Padar" if r_cen_village_name_str == "BK Padar" 
drop if E_cen_resp_name == .

local mylist2  Birnarayanpur Gopi_Kankubadi Kuljing Nathma

foreach j of local mylist2 {

preserve
keep r_cen_village_name_str unique_id  E_enum_name 	
keep if r_cen_village_name_str== "`j'"	


*keep if selected==1 

egen strata= group(E_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys E_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
*replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata_random_hhsurvey
//Bys R_FE3_enum (state random hhsurvey): gen sele (try it)

bys E_enum_name: generate selected_hhsurvey = _n == 1


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
//replacing ishadatta's ID 
//kuljing ID



tab E_enum_name selected



*keep if selected==1 

keep if selected==1
set seed 863344

*gsort -R_FU3_enum_name

sort strata_random_hhsurvey


gen enum = _n

// Generate a random number for each observation
gen random_number = runiform()

// Sort the dataset by the random numbers


// Reorder the enum variable based on the sorted random numbers
egen rank = group(enum)
save "${DataPr}selected_`j'_27thApr2024_for_endlineBC.dta", replace

restore
}


use "C:\Users\Archi Gupta\Box\Data\1_raw\1_8_Endline\1_8_Endline_Census.dta", clear

//some basic cleaning 
gen submit_date = dofc(submissiondate)
format submit_date %td 

//survey start date - 21st apr 2024
drop if submit_date < mdy(04,21,2024)

drop if key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 

//differentiating baseline census variables with existing variables now 

ds cen_fam_age1 cen_fam_age2 cen_fam_age3 cen_fam_age4 cen_fam_age5 cen_fam_age6 cen_fam_age7 cen_fam_age8 cen_fam_age9 cen_fam_age10 cen_fam_age11 cen_fam_age12 cen_fam_age13 cen_fam_age14 cen_fam_age15 cen_fam_age16 cen_fam_age17 cen_fam_age18 cen_fam_age19 cen_fam_age20 cen_fam_gender1 cen_fam_gender2 cen_fam_gender3 cen_fam_gender4 cen_fam_gender5 cen_fam_gender6 cen_fam_gender7 cen_fam_gender8 cen_fam_gender9 cen_fam_gender10 cen_fam_gender11 cen_fam_gender12 cen_fam_gender13 cen_fam_gender14 cen_fam_gender15 cen_fam_gender16 cen_fam_gender17 cen_fam_gender18 cen_fam_gender19 cen_fam_gender20 cen_female_above12 cen_female_15to49 cen_num_female_15to49 cen_adults_hh_above12 cen_num_adultsabove12 cen_children_below12 cen_num_childbelow12 cen_num_childbelow5 cen_num_malesabove15 cen_malesabove15_list_preload cen_num_hhmembers cen_num_noncri
foreach i of varlist `r(varlist)'{
rename `i' r_`i'
}

// Loop over all variables
foreach var of varlist _all {
    // Check if the variable name does not start with 'r_cen_'
    if strpos("`var'", "r_cen_") == 0 {
        // Rename the variable by adding prefix 'E_'
        rename `var' E_`var'
    }
}

rename E_unique_id unique_id
rename (E_submissiondate E_starttime E_endtime E_submit_date) (submissiondate starttime endtime submit_date)

replace r_cen_village_name_str = "Gopi_Kankubadi" if r_cen_village_name_str == "Gopi Kankubadi" 
replace r_cen_village_name_str = "BK_Padar" if r_cen_village_name_str == "BK Padar" 
drop if E_cen_resp_name == .

*merge 1:1 unique_id using "${DataPr}selected_Karlakana_8thmar2024_for_R2_FollowupBC.dta", gen(merge_BC_select)
preserve
clear
local mylist2  Gopi_Kankubadi Kuljing Nathma
use "${DataPr}selected_Birnarayanpur_27thApr2024_for_endlineBC.dta", replace

foreach j of local mylist2 {
append using "${DataPr}selected_`j'_27thApr2024_for_endlineBC.dta"

}
save "${DataPr}selected_allvillages_27thApr2024_for_endlineBC.dta", replace
restore

merge 1:1 unique_id using "${DataPr}selected_allvillages_27thApr2024_for_endlineBC.dta"
rename _merge merge_BC_select
keep if merge_BC_select==3

sort r_cen_village_name_str rank
gen previous_Respondent = ""
//replacing with main respondnet name 
forvalues i = 1/17 {
replace previous_Respondent = r_cen_fam_name`i' if E_cen_resp_name == `i'
}


export excel unique_id r_cen_village_name_str E_enum_name E_enum_name_label r_cen_a10_hhhead previous_Respondent r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_a39_phone_name_2 r_cen_a39_phone_num_2  r_cen_landmark r_cen_address r_cen_hamlet_name r_cen_saahi_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5 r_cen_fam_name6 r_cen_fam_name7 r_cen_fam_name8 r_cen_fam_name9 r_cen_fam_name10 r_cen_fam_name11 r_cen_fam_name12 r_cen_fam_name13 r_cen_fam_name14 r_cen_fam_name15 r_cen_fam_name16 r_cen_fam_name17 r_cen_fam_name18 r_cen_fam_name19 r_cen_fam_name20 E_n_fam_name1 E_n_fam_name2 E_n_fam_name3 E_n_fam_name4 E_n_fam_name5 E_n_fam_name6 E_n_fam_name7 E_n_fam_name8 E_n_fam_name9 E_n_fam_name10 E_n_fam_name11 E_n_fam_name12 E_n_fam_name13 E_n_fam_name14 E_n_fam_name15 E_n_fam_name16 E_n_fam_name17 E_n_fam_name18 E_n_fam_name19 E_n_fam_name20 water_source_prim using "${DataPre}Backcheck_Endline_preload_27thApr24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)


***********************************************************************
* Step 4: Generating tracking list for supervisors for BC survey *
***********************************************************************

tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3


//Changing labels 
	label variable ID "Unique ID"
	label variable R_FU3_r_cen_village_name_str "Village Name"
	label variable R_FU3_r_cen_hamlet_name "Hamlet name"
	label variable R_FU3_r_cen_saahi_name"Saahi name"
	label variable R_FU3_r_cen_landmark "Landmark"
	label variable R_FU3_enum_name "Enumerator name"
	

*sort R_FU3_r_cen_village_name_str R_FU3_enum_name 
*export excel ID R_FU3_enum_name R_FU3_r_cen_village_name_str R_FU3_r_cen_hamlet_name R_FU3_r_cen_saahi_name R_FU3_r_cen_landmark rank using "${pilot}Supervisor_BC_FU3_Tracker_checking_repl.xlsx" if selected_replacementBC==1, sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


sort R_FU3_r_cen_village_name_str R_FU3_enum_name rank 
export excel ID R_FU3_enum_name R_FU3_r_cen_village_name_str R_FU3_r_cen_hamlet_name R_FU3_r_cen_saahi_name R_FU3_r_cen_landmark rank R_FU3_chlorine_yesno R_FU3_chlorine_drank_yesno R_FU3_water_treat_when using "${pilot}Supervisor_BC_FU3_Tracker_checking.xlsx" , sheet("sheet1", replace) firstrow(varlabels) cell(A1) 


*for check
*drop unique_id
*rename unique_id_num unique_id 
*merge 1:1 unique_id using "${DataRaw}BC_Followup_Matching.dta", gen(merge_BC_match2)




************************************************************************
* Step 2: Classifying households for Mortality survey based on Scenarios *
************************************************************************

// Create scenarios 
keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 
//Cleaning the name of the household head
rename R_Cen_a10_hhhead R_Cen_a10_hhhead_num

gen     R_Cen_a10_hhhead=""
forvalue i = 1/9 {
	replace R_Cen_a10_hhhead=R_Cen_a3_hhmember_name_`i' if R_Cen_a10_hhhead_num==`i'
}


decode R_Cen_village_name, gen(R_Cen_village_name_str)


local fam_age R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 R_Cen_a6_hhmember_age_18 R_Cen_a6_hhmember_age_19 R_Cen_a6_hhmember_age_20


forvalues i = 1/17 {
	gen Cen_fam_age`i' = R_Cen_a6_hhmember_age_`i'
    local ++i
}


local fam_gender R_Cen_a4_hhmember_gender_1 R_Cen_a4_hhmember_gender_2 R_Cen_a4_hhmember_gender_3 R_Cen_a4_hhmember_gender_4 R_Cen_a4_hhmember_gender_5 R_Cen_a4_hhmember_gender_6 R_Cen_a4_hhmember_gender_7 R_Cen_a4_hhmember_gender_8 R_Cen_a4_hhmember_gender_9 R_Cen_a4_hhmember_gender_10 R_Cen_a4_hhmember_gender_11 R_Cen_a4_hhmember_gender_12 R_Cen_a4_hhmember_gender_13 R_Cen_a4_hhmember_gender_14 R_Cen_a4_hhmember_gender_15 R_Cen_a4_hhmember_gender_16 R_Cen_a4_hhmember_gender_17 R_Cen_a4_hhmember_gender_18 R_Cen_a4_hhmember_gender_19 R_Cen_a4_hhmember_gender_20

forvalues i = 1/17 {
	gen Cen_fam_gender`i' = R_Cen_a4_hhmember_gender_`i'
    local ++i
}



forvalues i = 1/17 {
	gen Cen_children_below5_`i' = 1 if Cen_fam_age`i' < 5   
    local ++i
}


forvalues i = 1/17 {
	gen Cen_u5_child_elig_`i' = `i' if Cen_children_below5_`i' == 1  
    local ++i
}


forvalues i = 1/17 {
	gen Cen_female_15_49_`i' = 1 if Cen_fam_age`i' >= 15 & Cen_fam_age`i' <= 49 & Cen_fam_gender`i' == 2  
    local ++i
}


forvalues i = 1/17 {
	gen Cen_female_eligible_`i' = `i' if Cen_female_15_49_`i' == 1
    local ++i
}

forvalues i = 1/17 {
	gen Cen_males_15_`i' = 1 if Cen_fam_age`i' >= 15 & Cen_fam_gender`i' == 1  
    local ++i
}

forvalues i = 1/17 {
	gen Cen_males_15_elig_`i' = `i' if Cen_males_15_`i' == 1  
    local ++i
}


//eligible women of Child bearing age 
egen R_Cen_num_female_15to49 = anycount(Cen_female_15_49_1-Cen_female_15_49_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_female_eligible = concat(Cen_female_eligible_1-Cen_female_eligible_17), p(" ")
replace R_Cen_female_eligible = subinstr(R_Cen_female_eligible, ".", "", .) 

//child u5

egen R_Cen_num_u5child = anycount(Cen_children_below5_1-Cen_children_below5_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_u5_child = concat(Cen_u5_child_elig_1-Cen_u5_child_elig_17), p(" ")
replace R_Cen_u5_child = subinstr(R_Cen_u5_child, ".", "", .) 


//males more than 15
egen R_Cen_num_males15 = anycount(Cen_males_15_1-Cen_males_15_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_males_list = concat(Cen_males_15_elig_1-Cen_males_15_elig_17), p(" ")
replace R_Cen_males_list = subinstr(R_Cen_males_list, ".", "", .) 


*visitors 
egen temp_group = group(unique_id_num) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen

ds R_Cen_a7_pregnant_hh_1 R_Cen_a7_pregnant_hh_2 R_Cen_a7_pregnant_hh_3 R_Cen_a7_pregnant_hh_4 R_Cen_a7_pregnant_hh_5 R_Cen_a7_pregnant_hh_6 R_Cen_a7_pregnant_hh_7 R_Cen_a7_pregnant_hh_8 R_Cen_a7_pregnant_hh_9 R_Cen_a7_pregnant_hh_10 R_Cen_a7_pregnant_hh_11 R_Cen_a7_pregnant_hh_12 R_Cen_a7_pregnant_hh_13 R_Cen_a7_pregnant_hh_14 R_Cen_a7_pregnant_hh_15 R_Cen_a7_pregnant_hh_16 R_Cen_a7_pregnant_hh_17
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
replace `var' = . if `var' == -99
replace `var' = . if `var' == -98
replace `var' = 1 if `var' == 0
replace `var' = 0 if `var' == 1


}
egen total_preg_visitors = rowtotal(R_Cen_a7_pregnant_hh_1 R_Cen_a7_pregnant_hh_2 R_Cen_a7_pregnant_hh_3 R_Cen_a7_pregnant_hh_4 R_Cen_a7_pregnant_hh_5 R_Cen_a7_pregnant_hh_6 R_Cen_a7_pregnant_hh_7 R_Cen_a7_pregnant_hh_8 R_Cen_a7_pregnant_hh_9 R_Cen_a7_pregnant_hh_10 R_Cen_a7_pregnant_hh_11 R_Cen_a7_pregnant_hh_12 R_Cen_a7_pregnant_hh_13 R_Cen_a7_pregnant_hh_14 R_Cen_a7_pregnant_hh_15 R_Cen_a7_pregnant_hh_16 R_Cen_a7_pregnant_hh_17)
drop temp_group
*no visitors found



export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name R_Cen_a11_oldmale_name R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20  R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* Cen_fam_age* Cen_fam_gender* R_Cen_female_above12 R_Cen_num_femaleabove12  R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12 R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label  R_Cen_num_female_15to49  R_Cen_female_eligible R_Cen_num_u5child R_Cen_u5_child R_Cen_num_males15 R_Cen_males_list R_Cen_a2_hhmember_count using "${DataPre}Endline_census_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)



***********************************************************************
* Step 4: Generating tracking list for supervisors for Mortality survey *
***********************************************************************

use `new', clear

keep if C_Screened == 1
drop if R_Cen_a1_resp_name == "" 

tostring unique_id, force replace format(%15.0gc)
gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3



//Changing labels 
	label variable ID "Unique ID"
	label variable R_Cen_village_str "Village Name"
	label variable R_Cen_block_name "Block name"
	label variable R_Cen_hamlet_name "Hamlet name"
	label variable R_Cen_saahi_name "Saahi name"
	label variable R_Cen_landmark "Landmark"
	label variable R_Cen_enum_name_label "Enumerator name"
	


sort R_Cen_village_str R_Cen_enum_name_label  
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name using "${pilot}Supervisor_Endline_Tracker_checking.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 


replace R_Cen_village_str = "BK_Padar" if R_Cen_village_str == "BK Padar"
replace R_Cen_village_str = "Gopi_Kankubadi" if R_Cen_village_str == "Gopi Kankubadi"

local mylist2 Asada Bhujbal BK_Padar Badabangi Barijhola Bichikote  Birnarayanpur  Dangalodi Gopi_Kankubadi  Gudiabandh    Jaltar Karlakana  Karnapadu Kuljing  Mariguda Mukundpur   Naira  Nathma Sanagortha Tandipur  
foreach i of local mylist2 {
export excel ID R_Cen_enum_name_label R_Cen_block_name R_Cen_village_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark   R_Cen_a1_resp_name if R_Cen_village_str == "`i'" using "${pilot}Supervisor_Endline_Tracker_`i'.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1) 
}


*renaming women name 
forvalues i = 1/17 {
	rename R_Cen_fam_name`i' R_Cen_fam_name_`i'
}


export excel unique_id R_Cen_fam_name_1 R_Cen_fam_name_2 R_Cen_fam_name_3 R_Cen_fam_name_4 R_Cen_fam_name_5 R_Cen_fam_name_6 R_Cen_fam_name_7 R_Cen_fam_name_8 R_Cen_fam_name_9 R_Cen_fam_name_10 R_Cen_fam_name_11 R_Cen_fam_name_12 R_Cen_fam_name_13 R_Cen_fam_name_14 R_Cen_fam_name_15 R_Cen_fam_name_16 R_Cen_fam_name_17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a4_hhmember_gender_1 R_Cen_a4_hhmember_gender_2 R_Cen_a4_hhmember_gender_3 R_Cen_a4_hhmember_gender_4 R_Cen_a4_hhmember_gender_5 R_Cen_a4_hhmember_gender_6 R_Cen_a4_hhmember_gender_7 R_Cen_a4_hhmember_gender_8 R_Cen_a4_hhmember_gender_9 R_Cen_a4_hhmember_gender_10 R_Cen_a4_hhmember_gender_11 R_Cen_a4_hhmember_gender_12 R_Cen_a4_hhmember_gender_13 R_Cen_a4_hhmember_gender_14 R_Cen_a4_hhmember_gender_15 R_Cen_a4_hhmember_gender_16 R_Cen_a4_hhmember_gender_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 using "${DataPre}Endline_census_hhmember_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

*renaming women name 
forvalues i = 1/17 {
	gen R_Cen_eligible_women_pre_`i' = R_Cen_fam_name_`i' if R_Cen_a6_hhmember_age_`i' >= 15 & R_Cen_a6_hhmember_age_`i' <= 49 & R_Cen_a4_hhmember_gender_`i' == 2
    gen R_Cen_eligible_women_pre_num_`i' = 1 if R_Cen_a6_hhmember_age_`i' >= 15 & R_Cen_a6_hhmember_age_`i' <= 49 & R_Cen_a4_hhmember_gender_`i' == 2 
	}

forvalues i = 1/17 {
	gen R_Cen_a7_pregnant_s_`i' = 1 if R_Cen_a7_pregnant_`i' == 1
	replace R_Cen_a7_pregnant_s_`i' = 0 if R_Cen_a7_pregnant_`i' == 0
	}
	
export excel unique_id R_Cen_eligible_women_pre_1 R_Cen_eligible_women_pre_2 R_Cen_eligible_women_pre_3 R_Cen_eligible_women_pre_4 R_Cen_eligible_women_pre_5 R_Cen_eligible_women_pre_6 R_Cen_eligible_women_pre_7 R_Cen_eligible_women_pre_8 R_Cen_eligible_women_pre_9 R_Cen_eligible_women_pre_10 R_Cen_eligible_women_pre_11 R_Cen_eligible_women_pre_12 R_Cen_eligible_women_pre_13 R_Cen_eligible_women_pre_14 R_Cen_eligible_women_pre_15 R_Cen_eligible_women_pre_16 R_Cen_eligible_women_pre_17 R_Cen_a7_pregnant_s_1 R_Cen_a7_pregnant_s_2 R_Cen_a7_pregnant_s_3 R_Cen_a7_pregnant_s_4 R_Cen_a7_pregnant_s_5 R_Cen_a7_pregnant_s_6 R_Cen_a7_pregnant_s_7 R_Cen_a7_pregnant_s_8 R_Cen_a7_pregnant_s_9 R_Cen_a7_pregnant_s_10 R_Cen_a7_pregnant_s_11 R_Cen_a7_pregnant_s_12 R_Cen_a7_pregnant_s_13 R_Cen_a7_pregnant_s_14 R_Cen_a7_pregnant_s_15 R_Cen_a7_pregnant_s_16 R_Cen_a7_pregnant_s_17 using "${DataPre}Endline_census_eligiblewomen_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

*exporting child names
forvalues i = 1/17 {
	gen R_Cen_u5_child_pre_`i' = R_Cen_fam_name_`i' if R_Cen_a6_hhmember_age_`i' < 5 
	}

export excel unique_id R_Cen_u5_child_pre_1 R_Cen_u5_child_pre_2 R_Cen_u5_child_pre_3 R_Cen_u5_child_pre_4 R_Cen_u5_child_pre_5 R_Cen_u5_child_pre_6 R_Cen_u5_child_pre_7 R_Cen_u5_child_pre_8 R_Cen_u5_child_pre_9 R_Cen_u5_child_pre_10 R_Cen_u5_child_pre_11 R_Cen_u5_child_pre_12 R_Cen_u5_child_pre_13 R_Cen_u5_child_pre_14 R_Cen_u5_child_pre_15 R_Cen_u5_child_pre_16 R_Cen_u5_child_pre_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 using "${DataPre}Endline_census_u5child_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

** Loop through R_Cen_eligible_women_pre variables (2 to 20) */
** Loop through R_Cen_eligible_women_pre variables (2 to 20) */


*exporting all non criteria members for health section stuff
forvalues i = 1/17 {
	gen R_Cen_non_cri_mem_`i' = R_Cen_fam_name_`i' if (R_Cen_a6_hhmember_age_`i' >= 5 & R_Cen_a4_hhmember_gender_`i' == 1) | (R_Cen_a6_hhmember_age_`i' > 49  & R_Cen_a4_hhmember_gender_`i' == 2) | ( R_Cen_a6_hhmember_age_`i' < 15 & R_Cen_a6_hhmember_age_`i' >=5 & R_Cen_a4_hhmember_gender_`i' == 2)
	}
	

forvalues i = 1/17 {
	gen R_Cen_num_non_cri_mem_`i' = 1 if R_Cen_non_cri_mem_`i' != ""
	}
	
	
egen temp_group = group(unique_id_num) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen
ds R_Cen_num_non_cri_mem_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_noncri = rowtotal(R_Cen_num_non_cri_mem_*)
drop temp_group
	

	

forvalues i = 1/17 {
	gen Cen_noncri_`i' = 1 if (R_Cen_a6_hhmember_age_`i' >= 5 & R_Cen_a4_hhmember_gender_`i' == 1) | (R_Cen_a6_hhmember_age_`i' > 49  & R_Cen_a4_hhmember_gender_`i' == 2) | ( R_Cen_a6_hhmember_age_`i' < 15 & R_Cen_a6_hhmember_age_`i' >=5 & R_Cen_a4_hhmember_gender_`i' == 2) 
    local ++i
}


forvalues i = 1/17 {
	gen Cen_noncri_list_`i' = `i' if Cen_noncri_`i' == 1
    local ++i
}


egen R_Cen_num_noncri_tot = anycount(Cen_noncri_1-Cen_noncri_17), value(1)


egen R_Cen_noncri_elig_list = concat(Cen_noncri_list_1-Cen_noncri_list_17), p(" ")
replace R_Cen_noncri_elig_list = subinstr(R_Cen_noncri_elig_list, ".", "", .) 
	
export excel unique_id R_Cen_non_cri_mem_1 R_Cen_non_cri_mem_2 R_Cen_non_cri_mem_3 R_Cen_non_cri_mem_4 R_Cen_non_cri_mem_5 R_Cen_non_cri_mem_6 R_Cen_non_cri_mem_7 R_Cen_non_cri_mem_8 R_Cen_non_cri_mem_9 R_Cen_non_cri_mem_10 R_Cen_non_cri_mem_11 R_Cen_non_cri_mem_12 R_Cen_non_cri_mem_13 R_Cen_non_cri_mem_14 R_Cen_non_cri_mem_15 R_Cen_non_cri_mem_16 R_Cen_non_cri_mem_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 total_noncri R_Cen_noncri_elig_list using "${DataPre}Endline_census_noncri_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)




























