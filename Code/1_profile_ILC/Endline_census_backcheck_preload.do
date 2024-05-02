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
************************************************

do "${github}1_8_A_Endline_cleaning.do"
do "${github}1_8_A_Endline_cleaning_v2.do"

use "${DataPre}1_1_Endline_XXX_consented.dta", clear

//some basic cleaning 
gen submit_date = dofc(R_E_submissiondate)
format submit_date %td 

//survey start date - 21st apr 2024
drop if submit_date < mdy(04,21,2024)

drop if R_E_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 

//differentiating baseline census variables with existing variables now 


// Loop over all variables
//foreach var of varlist _all {
    // Check if the variable name does not start with 'r_cen_'
    //if strpos("`var'", "r_cen_") == 0 {
        // Rename the variable by adding prefix 'E_'
        //rename `var' E_`var'
    //}
//}


replace R_E_r_cen_village_name_str = "Gopi_Kankubadi" if R_E_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_E_r_cen_village_name_str = "BK_Padar" if R_E_r_cen_village_name_str == "BK Padar" 
drop if R_E_cen_resp_name == .

local mylist2  Birnarayanpur Gopi_Kankubadi Kuljing Nathma Barijhola Bichikote Dangalodi

foreach j of local mylist2 {

preserve
keep R_E_r_cen_village_name_str unique_id  R_E_enum_name 	
keep if R_E_r_cen_village_name_str== "`j'"	


*keep if selected==1 

egen strata= group(R_E_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_E_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
*replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata_random_hhsurvey
//Bys R_FE3_enum (state random hhsurvey): gen sele (try it)

bys R_E_enum_name (strata_random_hhsurvey): generate selected_hhsurvey = _n <= 2


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
//replacing ishadatta's ID 
//kuljing ID



tab R_E_enum_name selected



*keep if selected==1 

keep if selected==1

gen rand_num = .
replace rand_num = runiform() if selected_hhsurvey

* Sort by enumerator and the random number
sort R_E_enum_name rand_num

* Assign numbers 1 and 2 within each enumerator group to the selected observations
by R_E_enum_name: gen assigned_number = cond(selected_hhsurvey, _n, .)


*gsort -R_FU3_enum_name

sort strata_random_hhsurvey rand_num


bysort  assigned_number: gen enum = _n

// Reorder the enum variable based on the sorted random numbers
egen rank = group(enum)

save "${DataPr}selected_`j'_27thApr2024_for_endlineboth.dta", replace
keep if assigned_number == 1
save "${DataPr}selected_`j'_27thApr2024_for_endlineBC.dta", replace

use "${DataPr}selected_`j'_27thApr2024_for_endlineboth.dta", clear
keep if assigned_number == 2

save "${DataPr}selected_`j'_27thApr2024_for_endlineAudioaudits.dta", replace

restore
}


use "${DataPre}1_1_Endline_XXX_consented.dta", clear

//some basic cleaning 
gen submit_date = dofc(R_E_submissiondate)
format submit_date %td 

//survey start date - 21st apr 2024
drop if submit_date < mdy(04,21,2024)

drop if R_E_key == "uuid:54261fb3-0798-4528-9e85-3af458fdbad9" 



replace R_E_r_cen_village_name_str = "Gopi_Kankubadi" if R_E_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_E_r_cen_village_name_str = "BK_Padar" if R_E_r_cen_village_name_str == "BK Padar" 
drop if R_E_cen_resp_name == .

*merge 1:1 unique_id using "${DataPr}selected_Karlakana_8thmar2024_for_R2_FollowupBC.dta", gen(merge_BC_select)
preserve
clear
local mylist2  Gopi_Kankubadi Kuljing Nathma Barijhola Bichikote Dangalodi 
use "${DataPr}selected_Birnarayanpur_27thApr2024_for_endlineBC.dta", replace

foreach j of local mylist2 {
append using "${DataPr}selected_`j'_27thApr2024_for_endlineBC.dta"

}
save "${DataPr}selected_allvillages_27thApr2024_for_endlineBC.dta", replace
restore

drop _merge
merge 1:1 unique_id using "${DataPr}selected_allvillages_27thApr2024_for_endlineBC.dta"
rename _merge merge_BC_select
keep if merge_BC_select==3

sort R_E_r_cen_village_name_str rank
gen previous_Respondent = ""
//replacing with main respondnet name 
forvalues i = 1/20 {
replace previous_Respondent = R_E_r_cen_fam_name`i' if R_E_cen_resp_name == `i'
}

//phone numbers and lankmark r_cen_address r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_saahi_name

forvalues i = 1/20 {
gen E_N_noncri_care_`i' = 1 if R_E_n_med_seek_all_`i' == 1

}

egen temp_group = group(unique_id_num)
egen E_N_num_noncri_care = rowtotal(E_N_noncri_care_*)
drop temp_group


drop E_N_noncri_care_*

cap forvalues i = 1/20 {
cap gen E_N_totalCBW_`i' = 1 if R_E_n_name_cbw_woman_earlier`i' != ""

}

egen temp_group = group(unique_id_num)
egen E_N_num_CBW = rowtotal(E_N_totalCBW_*)
drop temp_group



export excel unique_id R_E_r_cen_village_name_str R_E_cen_resp_name R_E_r_cen_a1_resp_name R_E_r_cen_hamlet_name R_E_r_cen_landmark R_E_r_cen_saahi_name R_E_r_cen_address R_E_r_cen_a10_hhhead R_E_r_cen_a11_oldmale_name R_E_r_cen_a39_phone_name_1 R_E_r_cen_a39_phone_num_1 R_E_r_cen_a39_phone_name_2 R_E_r_cen_a39_phone_num_2 R_E_n_hhmember_count R_E_n_fam_name1 R_E_n_fam_name2 R_E_n_fam_name3 R_E_n_fam_name4 R_E_n_fam_name5 R_E_n_fam_name6 R_E_n_fam_name7 R_E_n_fam_name8 R_E_n_fam_name9 R_E_n_fam_name10 R_E_n_fam_name11 R_E_n_fam_name12 R_E_n_fam_name13 R_E_n_fam_name14 R_E_n_fam_name15 R_E_n_fam_name16 R_E_n_fam_name17 R_E_n_fam_name18 R_E_n_fam_name19 R_E_n_fam_name20 R_E_n_name_cbw_woman_earlier1 R_E_n_preg_residence1 R_E_n_fam_age1 R_E_n_fam_age2 R_E_n_fam_age3 R_E_n_fam_age4 R_E_n_fam_age5 R_E_n_fam_age6 R_E_n_fam_age7 R_E_n_fam_age8 R_E_n_fam_age9 R_E_n_fam_age10 R_E_n_fam_age11 R_E_n_fam_age12 R_E_n_fam_age13 R_E_n_fam_age14 R_E_n_fam_age15 R_E_n_fam_age16 R_E_n_fam_age17 R_E_n_fam_age18 R_E_n_fam_age19 R_E_n_fam_age20 R_E_cen_name_cbw_woman_earlier1 R_E_cen_name_cbw_woman_earlier2 R_E_cen_name_cbw_woman_earlier3 R_E_cen_name_cbw_woman_earlier4 R_E_cen_preg_status1 R_E_cen_preg_status2 R_E_cen_preg_status3 R_E_cen_preg_status4  R_E_cen_not_curr_preg1 R_E_cen_not_curr_preg2 R_E_cen_not_curr_preg3 R_E_cen_not_curr_preg4  R_E_cen_preg_residence1 R_E_cen_preg_residence2 R_E_cen_preg_residence3 R_E_cen_preg_residence4  R_E_n_female_above12 R_E_n_num_femaleabove12 R_E_n_male_above12 R_E_n_num_maleabove12 R_E_n_adults_hh_above12 R_E_n_num_adultsabove12 R_E_n_children_below12 R_E_n_num_childbelow12 R_E_n_female_15to49 R_E_n_num_female_15to49 R_E_n_children_below5 R_E_n_num_childbelow5 R_E_n_allmembers_h  R_E_n_num_allmembers_h E_N_num_noncri_care E_N_num_CBW previous_Respondent R_E_cen_resp_label using "${DataPre}Backcheck_Endline_preload_27thApr24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)


***********************************************************************
* Step 4: Generating tracking list for supervisors for BC survey *
***********************************************************************

gen newvar1 = substr(unique_id, 1, 5)
gen newvar2 = substr(unique_id, 6, 3)
gen newvar3 = substr(unique_id, 9, 3)
gen ID=newvar1 + "-" + newvar2 + "-" + newvar3


//Changing labels 
	label variable ID "Unique ID"
	label variable R_E_r_cen_village_name_str "Village Name"
	label variable R_E_r_cen_hamlet_name "Hamlet name"
	label variable R_E_r_cen_saahi_name "Saahi name"
	label variable R_E_r_cen_landmark "Landmark"
	label variable R_E_enum_name  "Enumerator name"
	label variable previous_Respondent  "Endline Respondent name"

	


sort R_E_r_cen_village_name_str R_E_enum_name rank 
export excel ID R_E_enum_name R_E_r_cen_village_name_str R_E_r_cen_hamlet_name R_E_r_cen_saahi_name R_E_r_cen_landmark previous_Respondent using "${pilot}Supervisor_BC_endline_Tracker_checking.xlsx" , sheet("sheet1", replace) firstrow(varlabels) cell(A1) 


*for check
*drop unique_id
*rename unique_id_num unique_id 
*merge 1:1 unique_id using "${DataRaw}BC_Followup_Matching.dta", gen(merge_BC_match2)


















