

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


drop if BC_surveydate >= mdy(3,6,2024)
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


gen Resp_name = ""
forvalues i = 1/20 {
	  replace Resp_name = r_fu1_r_cen_fam_name`i' if who_interviwed_before_`i' == 1 
}

*We have created a BC respondent var to find error rates for the cases where respondent names are diff 

rename enum_name BC_name

rename Resp_name BC_resp_name

global id unique_id

global t1vars water_sec_yn water_source_sec water_source_main_sec water_source_sec_1 water_source_sec_2 water_source_sec_3 water_source_sec_4 water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77 where_prim_locate where_sec_locate water_treat water_treat_when water_treat_when_1 water_treat_when_2 water_treat_when_3 water_treat_when_4 water_treat_when_5 water_treat_when_6 water_treat_when__77 water_treat_type water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type_5 water_treat_type_6 water_treat_type__77   chlorine_yesno chlorine_drank_yesno

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
bcstats, surveydata("$In_progress_files/Follow_up_data_for_matching.dta") bcdata("$In_progress_files/BC_FollowpR1_for_matching.dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(water_source_prim)  enumerator(enum_name) backchecker(BC_name) keepsurvey(survey_village survey_date Follow_Respondent)  keepbc(BC_surveydate BC_village_name BC_resp_name) showid(0) showall full lower trim filename(BC_FollowupR1_diffs.csv) replace 
 

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

