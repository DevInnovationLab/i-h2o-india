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
	(1) This do file exports the preload data for backcheck survey 
	(2) Also exports tracking sheets for supervisors for backchecks ------ */

*------------------------------------------------------------------- -------------------------------------------------------------------*


***************************************************
* Step 1: Cleaning  *
***************************************************
*cap program drop start_from_clean_file_Population
*program define   start_from_clean_file_Population
  * Open clean file

  // Start of your do file

  
do "${Do_lab}import_india_ilc_pilot_hh_followup_R3_survey_enc.do"
save "${DataRaw}1_7_FollowUp_R3.dta", replace
do "${github}1_7_A_Followup_R3_cleaning.do"
use "${DataDeid}1_7_Followup_R3_cleaned.dta",clear
keep if R_FU3_consent == 1
clonevar unique_id =  unique_id_num
label variable R_FU3_consent "HH survey consent"
replace R_FU3_r_cen_village_name_str = "Gopi_Kankubadi" if R_FU3_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_FU3_r_cen_village_name_str = "BK_Padar" if R_FU3_r_cen_village_name_str == "BK Padar" 

tab R_FU3_r_cen_village_name_str 

***********************************************************************
* Step 2: Selecting households for BC survey based on random numbers *
***********************************************************************
set seed 123456789
*local mylist2 BK_Padar Bhujbal Birnarayanpur Jaltar Mukundpur Naira Nathma Tandipur Sanagortha Kuljing 
*Karlakana done already
*Barijhola done
*Dangalodi done
*Kuljing  done
*Nathma done
*Birnarayanpur done
*Gopi_Kankubadi done 
*Mukundpur done
*Tandipur done
*BK_Padar done
*Bhujbal done
*Bichikote done
*Gudiabandh done
*Mariguda done
*Naira done
*Karnapadu done
*Badabangi done
*Jaltar done
*Sanagortha
local mylist2 Asada
foreach j of local mylist2 {

preserve
keep R_FU3_r_cen_village_name_str unique_id  R_FU3_enum_name 	
keep if R_FU3_r_cen_village_name_str== "`j'"	


*keep if selected==1 
tostring R_FU3_enum_name, generate(R_FU3_enum_name_)

egen strata= group(R_FU3_enum_name) 

//Total number of BC surveys needed per enumerator - 10%
gen count= 1
bys R_FU3_enum_name: egen total= total(count)
gen ten_perc_per_enum= 0.1*total
*replace ten_perc_per_enum= round(ten_perc_per_enum)

//Randomly generating numbers that are assigned to obervations
bys strata (unique_id): gen strata_random_hhsurvey= runiform(0,1) 


//selecting observations based on sampling criteria
sort strata_random_hhsurvey
//Bys R_FE3_enum (state random hhsurvey): gen sele (try it)

bys R_FU3_enum_name: generate selected_hhsurvey = _n == 1


//Final selection variable
gen selected= 1 if selected_hhsurvey==1 
//replacing ishadatta's ID 
//kuljing ID

replace selected = 1 if unique_id == 30701101005 
replace selected = 1 if unique_id == 30602105023
replace selected = 1 if unique_id == 30501111013
replace selected = 1 if unique_id == 40202111072
 
replace selected = 1 if unique_id == 20201113088
replace selected = 1 if unique_id == 40301113016

replace selected = 1 if unique_id == 10101110015



tab R_FU3_enum_name selected



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
save "${DataPr}selected_`j'_7thApr2024_for_R3_FollowupBC.dta", replace

restore
}

use "${DataDeid}1_7_Followup_R3_cleaned.dta", clear
keep if R_FU3_consent == 1
clonevar unique_id =  unique_id_num
label variable R_FU3_consent "HH survey consent"
replace R_FU3_r_cen_village_name_str = "Gopi_Kankubadi" if R_FU3_r_cen_village_name_str == "Gopi Kankubadi" 
replace R_FU3_r_cen_village_name_str = "BK_Padar" if R_FU3_r_cen_village_name_str == "BK Padar" 
*merge 1:1 unique_id using "${DataPr}selected_Karlakana_8thmar2024_for_R2_FollowupBC.dta", gen(merge_BC_select)
merge 1:1 unique_id using "${DataPr}selected_Asada_7thApr2024_for_R3_FollowupBC.dta"
rename _merge merge_BC_select
keep if merge_BC_select==3

sort R_FU3_r_cen_village_name_str R_FU3_enum_name_label rank
gen Main_Respondent = ""

//replacing with main respondnet name 
forvalues i = 1/20 {
replace Main_Respondent = R_FU3_r_cen_fam_name`i' if R_FU3_main_respondent == `i'
}

rename Main_Respondent R_FU3_Main_Respondent
export excel unique_id R_FU3_r_cen_village_name_str R_FU3_enum_name R_FU3_enum_name_label R_FU3_r_cen_a10_hhhead R_FU3_Main_Respondent R_FU3_r_cen_a39_phone_name_1 R_FU3_r_cen_a39_phone_num_1 R_FU3_r_cen_a39_phone_name_2 R_FU3_r_cen_a39_phone_num_2 R_FU3_r_cen_landmark R_FU3_r_cen_address R_FU3_r_cen_hamlet_name R_FU3_r_cen_saahi_name R_FU3_r_cen_a11_oldmale_name R_FU3_r_cen_fam_name1 R_FU3_r_cen_fam_name2 R_FU3_r_cen_fam_name3 R_FU3_r_cen_fam_name4 R_FU3_r_cen_fam_name5 R_FU3_r_cen_fam_name6 R_FU3_r_cen_fam_name7 R_FU3_r_cen_fam_name8 R_FU3_r_cen_fam_name9 R_FU3_r_cen_fam_name10 R_FU3_r_cen_fam_name11 R_FU3_r_cen_fam_name12 R_FU3_r_cen_fam_name13 R_FU3_r_cen_fam_name14 R_FU3_r_cen_fam_name15 R_FU3_r_cen_fam_name16 R_FU3_r_cen_fam_name17 R_FU3_r_cen_fam_name18 R_FU3_r_cen_fam_name19 R_FU3_r_cen_fam_name20 R_FU3_water_source_prim using "${DataPre}Backcheck_FU3_preload_7thApr24.xlsx", sheet("Sheet1", replace) firstrow(var) cell(A1)


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




















































































