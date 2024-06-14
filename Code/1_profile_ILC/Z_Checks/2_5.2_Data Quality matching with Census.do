cd "C:\Users\Archi Gupta\Box\Data\1_raw"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\import_ILC_Data_Quality_survey.do"
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen surveydate = dofc(submissiondate)
format surveydate %td
replace unique_id = 50501109017 if unique_id == 50501107017 & key == "uuid:6b1d4f4c-81ae-4221-a882-47adbb96ca95" & a7_resp_name == "Sundari melaka" 

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

drop r_cen_*

rename enum_name DQ_name
rename a7_resp_name a1_resp_name
*tostring a11_oldmale_name, gen(a11_oldmale_name_)
*drop a11_oldmale_name
*rename a11_oldmale_name_ a11_oldmale_name

global id unique_id


global t1vars a1_resp_name a10_hhhead a11_oldmale_name a12_water_source_prim a13_water_sec_yn a13_water_source_sec a13_water_source_sec_1 a13_water_source_sec_2 a13_water_source_sec_3 a13_water_source_sec_4 a13_water_source_sec_5 a13_water_source_sec_6 a13_water_source_sec_7 a13_water_source_sec_8 a13_water_source_sec__77 a13_water_sec_oth  

global t2vars a18_jjm_drinking

save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\census and DQ merge(main).dta", replace



//importing DQ preload 
clear all 

use "C:\Users\Archi Gupta\Box\Data\1_raw\1_1_Census_cleaned_consented.dta"

renpfix R_Cen_ //removing R_cen prefix 


drop unique_id
rename unique_id_num unique_id

tostring a10_hhhead, gen(a10_hhhead_)
drop a10_hhhead
rename a10_hhhead_ a10_hhhead


save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Census data for DQ bc stats.dta", replace


	
keep unique_id enum_name a1_resp_name a10_hhhead block_name village_name
ds enum_name a1_resp_name a10_hhhead block_name village_name
foreach var of varlist `r(varlist)' {
	rename `var' R_Cen_`var'
}

merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\census and DQ merge(main).dta"



clear 
//BC stats
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
 set matsize 600
 set emptycells drop
bcstats, surveydata("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Census data for DQ bc stats.dta") bcdata("C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\census and DQ merge(main).dta") id($id) t1vars($t1vars) t2vars($t2vars) ttest(a18_jjm_drinking) enumerator(enum_name) backchecker(DQ_name)  keepsurvey(submissiondate) keepbc(change_primary_source)  showid(30) lower trim showall full filename(Data_quality_diffs.csv) replace 
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

putexcel set "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Data_quality_output.xlsx", sheet("Sheet1") replace
putexcel A1 = "Error rate enum wise type 1 variables"
putexcel A2 = matrix(r(enum1))
putexcel set Data_quality_output, modify sheet(error rate1)
putexcel A1 = "Error rate enum wise type 2 variables"
putexcel A2 = matrix(r(enum2))
putexcel set Data_quality_output, modify sheet(error rate2)
putexcel A1 = "Error rate type 1 variables for BC"
putexcel A2 = matrix(r(backchecker1))
putexcel set Data_quality_output, modify sheet(error rate3)
putexcel A1 = "Error rate type 2 variables for BC"
putexcel A2 = matrix(r(backchecker2))
putexcel set Data_quality_output, modify sheet(error rate4)
putexcel A1 = "Error rate type 1 variables"
putexcel A2 = matrix(r(var1))
putexcel set Data_quality_output, modify sheet(error rate5)
putexcel A1 = "Error rate type 2 variables"
putexcel A2 = matrix(r(var2))
putexcel set Data_quality_output, modify sheet(error rate6)
putexcel A1 = "T-test results"
putexcel A2 = matrix(r(ttest2))
putexcel set Data_quality_output, modify sheet(ttest)




