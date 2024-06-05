* import_ILC_Data_Quality_survey.do
*
* 	Imports and aggregates "ILC_Data_Quality_survey" (ID: ILC_Data_Quality_survey) data.
*
*	Inputs:  "ILC_Data_Quality_survey_WIDE.csv"
*	Outputs: "ILC_Data_Quality_survey.dta"
*
*	Output by SurveyCTO October 31, 2023 5:18 PM.

* initialize Stata
clear all
cd "C:\Users\Archi Gupta\Box\Data\1_raw"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\import_ILC_Data_Quality_survey.do"

destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen surveydate = dofc(submissiondate)
format surveydate %td


drop if unique_id == 30301109031 & enum_name == 105 & a7_resp_name == "Sujita Karakaria" & surveydate == date("01nov2023", "DMY")
drop if unique_id ==  30301109032 & enum_name == 105 & a7_resp_name == "Sumudra Karkaria" & surveydate == date("01nov2023", "DMY")
drop if unique_id ==  30301109033 & enum_name == 105 & a7_resp_name == "Damini Karakaria" & surveydate == date("01nov2023", "DMY")
drop if unique_id ==  30301109034 & enum_name == 105 & a7_resp_name == "Rachana Karakaria" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301109040 & enum_name == 105 & a7_resp_name == "Nabanita Mahanandia" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301109043 & enum_name == 105 & a7_resp_name == "Rebati Karakaria" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301109046 & enum_name == 105 & a7_resp_name == "Ketaki Kousalya" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301109047 & enum_name == 105 & a7_resp_name == "Maya Kousalya" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301119063 & enum_name == 105 & a7_resp_name == "Bhanubati Senapati" & surveydate == date("01nov2023", "DMY")
drop if unique_id == 30301119077 & enum_name == 105 & a7_resp_name == "Sanjukta Jena" & surveydate == date("01nov2023", "DMY")
replace a7_resp_name = "Kantaru bidika" if unique_id == 50201109027 & enum_name == 101 & a7_resp_name == "" & surveydate == date("26oct2023", "DMY")
drop if  a7_resp_name == "Kantaru bidika" & unique_id == 50201109027 & enum_name == 101 & surveydate == date("01nov2023", "DMY")
drop if  a7_resp_name == "Purnalu Saraka" & unique_id == 50401105039 & enum_name == 112 & surveydate == date("01nov2023", "DMY")
drop if  a7_resp_name == "Kabita Saraka" & unique_id == 50401106038 & enum_name == 112 & surveydate == date("01nov2023", "DMY")
drop if  a7_resp_name == "Gasai Miniaka" & unique_id == 50402106037 & enum_name == 105 & surveydate == date("01nov2023", "DMY")
replace unique_id = 50301117060 if a7_resp_name == "Sara khumbhar" & unique_id == 50301117050 & enum_name == 101 & surveydate == date("30oct2023", "DMY")

bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list dup unique_id if dup_HHID > 0

cd "C:\Users\Archi Gupta\Box\Data\New folder"
//Dupliactes list





cap export excel surveydate unique_id enum_name a7_resp_name a12_water_source_prim a12_prim_source_oth primary_water_label a13_water_sec_yn a13_water_source_sec a13_water_source_sec_1 a18_jjm_drinking change_primary_source a13_water_source_sec__77 a13_water_sec_oth a18_jjm_drinking submissiondate using "Duplicates_Data_Quality_survey" if dup_HHID > 0, sheetreplace firstrow(variables)



keep unique_id
save "C:\Users\Archi Gupta\Box\Data\New folder\Data_Quality_Checks_Only_UQs.dta", replace



//matching with BC_submitted data 
clear all 
cd "C:\Users\Archi Gupta\Box\Data\1_raw"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\import_india_ilc_pilot_backcheck_Master.do"              
set seed 758235657 // Just in case


replace consent = 0 if consent == .

drop if consent == 0

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen BC_surveydate = dofc(submissiondate)
format BC_surveydate %td

drop  if unique_id == 10101110016 & enum_name == 107 & r_cen_a1_resp_name == "Padma Garadia" & a7_resp_name == "999"

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

tab interviewed_before




replace interviewed_before = 1 if unique_id == 10201108019 & enum_name == 120 & a7_resp_name == "SANYASI ARAKA" & r_cen_village_name_str == "Sanagortha"
	


keep unique_id


save "C:\Users\Archi Gupta\Box\Data\New folder\BC_only unqiue Ids for matching with DQ.dta", replace




clear

//generating final sheet by merging new Ids not yet done with the pre load 

import excel "C:\Users\Archi Gupta\Box\Data\99_Preload\DataQuality_preload.xlsx", sheet("Sheet1") firstrow
destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id


bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list dup unique_id if dup_HHID > 0

destring R_Cen_village_name_str, gen (Village_name_num)
label define Village_num 10101 "Asada" 10201 "Sanagortha" 20101 "Badabangi" 20201 "Jaltar" 50601 "Badaalubadi" 30202 "BK Padar" 30301 "Tandipur" 30501 "Bhujbal" 30602 "Mukundpur" 40101 "Karnapadu" 40201 "Bichikote" 40202 "Gudiabandh" 40301 "Mariguda" 40401 "Naira" 50101 "Dangalodi" 50201 "Barijhola" 50301 "Karlakana" 50401 "Birnarayanpur" 50402 "Kuljing" 50501 "Nathma" 88888 "Pilot"
label values Village_name_num Village_num


merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\New folder\Data_Quality_Checks_Only_UQs.dta"

merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\New folder\BC_only unqiue Ids for matching with DQ.dta", generate(_mergewithBC)

export excel using "DQ IDs for field plan 6th nov" if _merge == 1 & _mergewithBC==1, sheetreplace firstrow(variables)

//This matching is done to see what Ids are not present in the pre-load and what Ids to give for planning 
