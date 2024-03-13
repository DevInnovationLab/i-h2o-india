

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
replace r_fu1_r_cen_fam_name1 = "Puspani Bag" if r_fu1_r_cen_fam_name1  == "Puspani bag" & unique_id == 30701101001 & key == "uuid:f26e45eb-eef7-456d-a4ed-7145800dd367"
replace r_fu1_r_cen_fam_name1 = "Podugu aruna kumari" if r_fu1_r_cen_fam_name1  == "Podugu aruna" & unique_id == 50301117030 & key == "uuid:3c14fb12-e232-42f3-8de2-1bf375b4b916"
replace r_fu1_r_cen_fam_name1 = "Mamata mohanadia" if r_fu1_r_cen_fam_name1  == "Mamata Mohanandia" & unique_id == 50401107009 & key == "uuid:ddd69e99-1f31-44bc-8e01-d38efca47b4c"
replace r_fu1_r_cen_fam_name1 = "Mandakini Meleka" if r_fu1_r_cen_fam_name1  == "Madankini Meleka" & unique_id == 50501115018 & key == "uuid:a0754952-fdcb-40da-a4ae-63fc56b20b29"
replace r_fu1_r_cen_fam_name1 = "Basant Milka" if r_fu1_r_cen_fam_name1  == "Basant milka" & unique_id == 50401107039 & key == "uuid:396f59ae-1074-44fd-ad9c-be2f49d7672c"

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

export excel unique_id r_fu1_r_cen_village_name_str r_fu1_r_cen_a1_resp_name r_fu1_r_cen_fam_name1 r_fu1_r_cen_fam_name2 r_fu1_r_cen_fam_name3 r_fu1_r_cen_fam_name4 r_fu1_r_cen_fam_name5 r_fu1_r_cen_fam_name6 r_fu1_r_cen_fam_name7 r_fu1_r_cen_fam_name8 r_fu1_r_cen_fam_name9 r_fu1_r_cen_fam_name10 r_fu1_r_cen_fam_name11 r_fu1_r_cen_fam_name12 r_fu1_r_cen_fam_name13 r_fu1_r_cen_fam_name14 r_fu1_r_cen_fam_name15 r_fu1_r_cen_fam_name16 r_fu1_r_cen_fam_name17 r_fu1_r_cen_fam_name18 r_fu1_r_cen_fam_name19 r_fu1_r_cen_fam_name20 who_interviwed_before_1 who_interviwed_before_2 who_interviwed_before_3  who_interviwed_before_4 who_interviwed_before_5 who_interviwed_before_6 who_interviwed_before_7 who_interviwed_before_8 who_interviwed_before_9 who_interviwed_before_10 who_interviwed_before_11 who_interviwed_before_12 who_interviwed_before_13 who_interviwed_before_14 who_interviwed_before_15 who_interviwed_before_16 who_interviwed_before_17 who_interviwed_before_18 who_interviwed_before_19 who_interviwed_before_20  using "$In_progress_files/Final_BC_FollowupR1_sheets" if flag == 1, firstrow(variables) sheet(different_respondent) sheetreplace


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

global t1vars water_sec_yn water_source_sec water_source_main_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 where_prim_locate where_sec_locate water_treat water_treat_when water_treat_when_1 water_treat_when_2 water_treat_when_3 water_treat_when_4 water_treat_when_5 water_treat_when_6 water_treat_when__77 water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type_5 water_treat_type_6 water_treat_type__77 water_treat_type_999  chlorine_yesno chlorine_drank_yesno

global t2vars water_source_prim tap_use_drinking_yesno
rename r_fu1_r_cen_village_name_str BC_village_name

rename r_fu1_r_cen_a10_hhhead BC_hhead_name

save "$In_progress_files/BC_FollowpR1_for_matching.dta", replace



keep unique_id BC_surveydate BC_name  
	
save "$In_progress_files/BC_FollowpR1_for_merging_with_followup.dta", replace

*************importing followup data**********************

 
use  "${DataDeid}1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent == 1

renpfix R_FU1_ //removing R_cen prefix 

clonevar unique_id = unique_id_num
format  unique_id %15.0gc

***********Merging census data with BC data******************
merge 1:1 unique_id using "$In_progress_files/BC_FollowpR1_for_merging_with_followup.dta"

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

rename r_cen_a1_resp_name Follow_Respondent

save "$In_progress_files/Follow_up_data_for_matching.dta", replace



*****************************after cleaning is done*********************************

clear 
//BC stats
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
 set matsize 600
 set emptycells drop
bcstats, surveydata("$In_progress_files/Follow_up_data_for_matching.dta") bcdata("$In_progress_files/BC_FollowpR1_for_matching.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(water_source_prim)  enumerator(enum_name) backchecker(BC_name) keepsurvey(survey_village survey_date survey_hhead Follow_Respondent)  keepbc(BC_surveydate BC_village_name BC_hhead_name BC_resp_name) showid(10) showall full lower trim filename(BC_FollowupR1_diffs.csv) replace 
 

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

