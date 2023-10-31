clear all               
set seed 758235657 // Just in case

import delimited "C:\Users\Archi Gupta\Box\Data\1_raw\Baseline Backcheck_WIDE.csv", bindquote(strict)

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
list dup unique_id if dup_HHID > 0

br BC_surveydate unique_id enum_name r_cen_a1_resp_name a7_resp_name a10_hhhead r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a10_hhhead r_cen_village_name_str r_cen_hamlet_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 if unique_id ==  10101110016

cd "C:\Users\Archi Gupta\Box\Data\New folder"



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
export excel unique_id r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5 r_cen_pregwoman_1 r_cen_pregwoman_2 r_cen_pregwoman_3 r_cen_u5child_1 r_cen_u5child_2 r_cen_u5child_3 r_cen_a12_water_source_prim enum_name enum_name_label interviewed_before who_interviwed_before who_interviwed_before_1 who_interviwed_before_2 who_interviwed_before_3 a7_resp_name BC_surveydate using "BC_quality_checks" if dup_HHID >0,firstrow(variables) sheet(Duplicates) sheetreplace 


tab interviewed_before

export excel interviewed_before unique_id r_cen_saahi_name r_cen_a1_resp_name r_cen_a10_hhhead r_cen_a39_phone_name_1 r_cen_a39_phone_num_1 r_cen_village_name_str r_cen_hamlet_name r_cen_a11_oldmale_name r_cen_fam_name1 r_cen_fam_name2 r_cen_fam_name3 r_cen_fam_name4 r_cen_fam_name5 r_cen_pregwoman_1 r_cen_pregwoman_2 r_cen_pregwoman_3 r_cen_u5child_1 r_cen_u5child_2 r_cen_u5child_3 r_cen_a12_water_source_prim enum_name enum_name_label interviewed_before who_interviwed_before who_interviwed_before_1 who_interviwed_before_2 who_interviwed_before_3 a7_resp_name BC_surveydate using "BC_quality_checks" if interviewed_before == 0,firstrow(variables) sheet(Not_interviewed_before) sheetreplace 

//AG: List all the cases where BC recorded that under 5 child isn't present but census showed it is present 
foreach i of varlist r_cen_u5child_1-r_cen_u5child_20{
list unique_id enum_name if screen_u5child == 0 & `i'!= ""
}

//AG: List all the cases where BC recorded that under 5 child isn't present but census showed it is present 

foreach i of varlist r_cen_u5child_1-r_cen_u5child_20{
list unique_id enum_name if screen_u5child == 1 & `i'== ""
}


br screen_u5child unique_id r_cen_u5child_* if unique_id == 10201108019

save "C:\Users\archi Gupta\Downloads\BC_cleaned data.dta", replace

rename enum_name BC_name

rename a7_resp_name BC_respondent_name

rename a10_hhhead BC_hhhead

keep unique_id BC_surveydate BC_name BC_respondent_name BC_hhhead interviewed_before who_interviwed_before
	
save "C:\Users\archi Gupta\Downloads\BC_edited_data.dta", replace

*************importing census data**********************

clear all               
set seed 758235657 // Just in case

import delimited "C:\Users\archi Gupta\Downloads\Baseline Census_WIDE.csv", bindquote(strict)

drop consented1child_followup5child_h
//Renaming vars with prefix R_Cen
*aG: Making this inactive because for bc stats to run variable names have to be exactly same 
//foreach x of var * {
	//rename `x' `x'
//}



* This variable has to be named consistently across data set
*aG: Changed unique_id to unique_id
rename unique_id unique_id_hyphen
gen unique_id = subinstr(unique_id_hyphen, "-", "",.) 
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id


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

	label variable enum_code "Enumerator to fill up: Enumerator Code"
	note enum_code: "Enumerator to fill up: Enumerator Code"
	label define enum_code 101 "101" 102 "102" 103 "103" 104 "104" 105 "105" 106 "106" 107 "107" 108 "108" 109 "109" 110 "110" 111 "111" 112 "112" 113 "113" 114 "114" 115 "115" 116 "116" 117 "117" 118 "118" 119 "119" 120 "120" 121 "121"
	label values enum_code enum_code

	label variable block_name "Block Name"
	note block_name: "Block Name"
	label define block_name 1 "Gudari" 2 "Gunupur" 3 "Kolnara" 4 "Padmapur" 5 "Rayagada" 888 "Pilot"
	label values block_name block_name

	label variable village_name "Village Name"
	note village_name: "Village Name"
	label define village_name 10101 "asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 30101 "Badaalubadi" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30602 "Mukundpur" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 888 "Pilot"
	label values village_name village_name
	
save "C:\Users\archi Gupta\Downloads\census_cleaned data.dta",replace
	
keep unique_id enum_name a1_resp_name a10_hhhead block_name village_name

save "C:\Users\archi Gupta\Downloads\census_edited_data.dta", replace

	
***********Merging census data with BC data******************
merge 1:1 unique_id using "C:\Users\archi Gupta\Downloads\BC_edited_data.dta"

//aG: at this point once get the whole data find values which are unmatched 



*****************************after cleaning is done*********************************

clear all

use "C:\Users\archi Gupta\Downloads\BC_cleaned data.dta"

rename enum_name BC_name

global id unique_id

* VaRIaBLE LISTS
* Type 1 Vars: These should not change. They guage whether the enumerator 
* performed the interview and whether it was with the right respondent. 
* If these are high, you must discuss them with your field team and consider
* disciplinary action against the surveyor and redoing her/his interviews.

rename bc_water_source_prim a12_water_source_prim
rename  a15_hhmember_count a2_hhmember_count

global t1vars a2_hhmember_count screen_u5child screen_preg  a10_hhhead a10_hhhead_gender a11_oldmale a11_oldmale_name a12_water_source_prim a16_water_treat a17_water_source_kids a18_jjm_drinking 
encode a17_treat_kids_freq, generate(a17_treat_kids_freq_)
drop a17_treat_kids_freq
rename a17_treat_kids_freq_ a17_treat_kids_freq


global t2vars a16_stored_treat a16_water_treat_type a16_water_treat_freq a16_stored_treat_freq water_prim_source_kids a17_water_treat_kids water_treat_kids_type a17_treat_kids_freq a33_cotbed a33_electricfan a33_colourtv a33_mobile a33_internet a33_motorcycle


save "C:\Users\Archi Gupta\Downloads\BC data for bc stats\BC_data.dta", replace
global bcer_data("C:\Users\Archi Gupta\Downloads\BC data for bc stats\BC_data.dta", replace)


clear 
use "C:\Users\Archi Gupta\Downloads\census_cleaned data.dta"
global id unique_id
global original ("C:\Users\Archi Gupta\Downloads\census_cleaned data.dta")

clear 
 set matsize 600
 set emptycells drop
bcstats, surveydata("C:\Users\Archi Gupta\Downloads\census_cleaned data.dta") bcdata("C:\Users\Archi Gupta\Downloads\BC data for bc stats\BC_data.dta") id($id) t1vars($t1vars) t2vars($t2vars) enumerator(enum_name) backchecker(BC_name)  keepsurvey(submissiondate)  showid(30) showall full replace 
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

putexcel set "C:\Users\Archi Gupta\Downloads\output.xlsx", sheet("Sheet1") replace
putexcel A1 = "r(enum1)"
putexcel A2 = matrix(r(enum1))
putexcel A4 = "r(enum2)"
putexcel A5 = matrix(r(enum2))
putexcel A7 = "r(backchecker1)"
putexcel A8 = matrix(r(backchecker1))
putexcel A10 = "r(backchecker2)"
putexcel A11 = matrix(r(backchecker2))
putexcel A13 = "r(var1)"
putexcel A14 = matrix(r(var1))
putexcel A16 = "r(var2)"
putexcel A17 = matrix(r(var2))




putexcel set "C:\Users\Archi Gupta\Downloads\BC data for bc stats\bc_diffs1",replace sheet(error_rates_type1)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set bc_diffs1, modify sheet(error rate2)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set bc_diffs1, modify sheet(error rate3)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set bc_diffs1, modify sheet(bc_error rate2)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set bc_diffs1, modify sheet(type 1 var)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set bc_diffs1, modify sheet(type 2 error rate)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set bc_diffs1, modify sheet(type 3 var)
putexcel A1 = "Error rate type 3 variables"
putexcel A2 = matrix(r(var3))















	
	recode village_name 30101=50601
recode gp_name 301=506
*label define village_namel 50601 "Baadalubadi"
*label values village_name village_namel

decode village_name, gen (village_str)
*aG: remove R_Cen
br village_name village_str
replace village_str= "Badaalubadi" if village_name==50601

drop if key=="uuid:c906fcad-e822-4de6-a183-f1c36e1fba9f"

*Note: the below duplicate case is resolved such that 2 cases with the same HH number 36 do not exist. 
br if unique_id_hyphen=="20201-108-036"
replace unique_id_hyphen="20201-108-037" if key=="uuid:c648052b-4ed8-4f5d-b160-7d373bf11fd4"
replace unique_id = subinstr(unique_id_hyphen, "-", "",.) 


//5. Cleaning the GPS data 
// Keeping the most reliable entry of GPS



//Renaming vars with prefix R_Cen
foreach x in a40_gps_autolatitude a40_gps_autolongitude a40_gps_autoaltitude a40_gps_autoaccuracy {
	rename `x' `x'
}

* auto
foreach i in a40_gps_autolatitude a40_gps_autolongitude a40_gps_autoaltitude a40_gps_autoaccuracy {
	replace `i'=. if a40_gps_autolatitude>25  | a40_gps_autolatitude<15
    replace `i'=. if a40_gps_autolongitude>85 | a40_gps_autolongitude<80
}


foreach x in a40_gps_manuallatitude a40_gps_manuallongitude a40_gps_manualaltitude a40_gps_manualaccuracy{
    rename `x' `x'
}

foreach x in a40_gps_handlongitude a40_gps_handlatitude{
  rename `x' `x'
}

* Manual
foreach i in a40_gps_manuallatitude a40_gps_manuallongitude a40_gps_manualaltitude a40_gps_manualaccuracy {
	replace `i'=. if a40_gps_manuallatitude>25  | a40_gps_manuallatitude<15
    replace `i'=. if a40_gps_manuallongitude>85 | a40_gps_manuallongitude<80
}

* Final GPS
foreach i in latitude longitude {
	gen     a40_gps_`i'=a40_gps_auto`i'
	replace a40_gps_`i'=a40_gps_manual`i' if a40_gps_`i'==.
	* add manual
	drop a40_gps_auto`i' a40_gps_manual`i'
}
* Reconsider puting back back but with less confusing variable name
drop a40_gps_autoaltitude a40_gps_manualaltitude
drop a40_gps_autoaccuracy a40_gps_manualaccuracy a40_gps_handlongitude a40_gps_handlatitude


//4. Capturing correct section-wise duration

//aG: Removing this as not relevant for BC code
//drop consent_duration intro_duration sectionb_duration //old vars
//destring survey_duration intro_dur_end consent_dur_end sectionb_dur_end sectionc_dur_end ///
//sectiond_dur_end sectione_dur_end sectionf_dur_end sectiong_dur_end sectionh_dur_end, replace

*drop intro_dur_end consent_dur_end sectionb_dur_end sectionc_dur_end ///
*sectiond_dur_end sectione_dur_end sectionf_dur_end sectiong_dur_end sectionh_dur_end
*/


//5. Cleaning the names of pregnant women in the data
local i = 1
local pregwoman pregwoman_1 pregwoman_2 pregwoman_3 pregwoman_4 pregwoman_5 ///
 pregwoman_6 pregwoman_7 pregwoman_8 pregwoman_9 pregwoman_10 pregwoman_11 ///
 pregwoman_12 pregwoman_13 pregwoman_14 pregwoman_15 pregwoman_16 pregwoman_17 
   
foreach x of  local pregwoman {
	replace `x' = "" if a7_pregnant_`i' != 1
    local ++i
}

//6. Cleaning the names of children under 5 in the data
local i = 1
local childU5 u5child_1 u5child_2 u5child_3 u5child_4 u5child_5 ///
 u5child_6 u5child_7 u5child_8 u5child_9 u5child_10 u5child_11 ///
 u5child_12 u5child_13 u5child_14 u5child_15 u5child_16 u5child_17  
   
   
    
foreach x of  local childU5 {
	destring a6_hhmember_age_`i', gen(C_hhmember_age_`i')
	replace `x' = "" if a6_hhmember_age_`i' >= 5
    local ++i
}

/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id {
bys `i': gen `i'_Unique=_N
}

tempfile working
save `working', replace


