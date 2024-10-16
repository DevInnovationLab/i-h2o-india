

use "${DataFinal}1_1_Mortality_cleaned_consented.dta", clear

*Astha for now please add your directories in PathGraphs and PathTables (I didn't add it because my dropbox and overleaf isn't linked and global paths for table export is happening in dropbox once that's sorted I will add a global dropbox path 

global PathGraphs "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
global PathTables "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
*ssc install texsave



/*-----------------------------------------------------------------------------------------------------------------------------------
*Checking if any IDs are there which are sent before the survey start date or before 9 am on 12th dec"                                                      
-------------------------------------------------------------------------------------------------------------------------------------*/
	gen Mor_day = day(dofc(R_mor_starttime))
	gen Mor_month_num = month(dofc(R_mor_starttime))
	list if (Mor_day<12 & Mor_month_num<12)	
	 gen submission_date = dofc(R_mor_submissiondate)
	 format submission_date %td
	 gen enddate = dofc(R_mor_endtime)
	 format enddate %td
	 gen startdate = dofc(R_mor_starttime)
	 format startdate %td
list R_mor_starttime M_starthour M_startmin unique_id_num if M_starthour < 9 & submission_date == date("12/12/2023", "DMY")

//cases where startdate > enddate
list unique_id_num R_mor_village R_mor_enum_name_f if startdate>enddate


//cases where starttime is greater or equal to endtime if startdate and enddaate are same
gen double cstart = hh(R_mor_starttime)*3600 + mm(R_mor_starttime)*60
gen double cend = hh(R_mor_endtime)*3600 + mm(R_mor_endtime)*60
list unique_id_num R_mor_village R_mor_enum_name_f if cstart>cend & (startdate == enddate)
list unique_id_num R_mor_village R_mor_enum_name_f if cstart==cend & (startdate == enddate)



	 gen starttime= dofc(R_mor_starttime)
	 format starttime %td
	 gen endtime = dofc(R_mor_endtime)
	 format endtime %td 
	 gen diff_date = submission_date- starttime

	 
/*-----------------------------------------------------------------------------------------------------------------------------------
Age calculation                                                  
-------------------------------------------------------------------------------------------------------------------------------------*/
*********************************************************

ds R_mor_a6_dob_*
foreach var of varlist `r(varlist)'{ 
gen days_`var' = submission_date - `var'
gen years_`var' = days_`var' / 365
}

forvalues i = 1/12 {
      gen diff_`i' = years_R_mor_a6_dob_`i' - R_mor_a6_hhmember_age_`i'
}

export excel R_mor_village unique_id_num submission_date R_mor_a6_dob_1 years_R_mor_a6_dob_1 R_mor_a6_hhmember_age_1 R_mor_a6_dob_2 years_R_mor_a6_dob_2 R_mor_a6_hhmember_age_2 R_mor_a6_dob_3 years_R_mor_a6_dob_3 R_mor_a6_hhmember_age_3 R_mor_a6_dob_4 years_R_mor_a6_dob_4 R_mor_a6_hhmember_age_4 R_mor_a6_dob_5 years_R_mor_a6_dob_5 R_mor_a6_hhmember_age_5 R_mor_a6_dob_6 years_R_mor_a6_dob_6 R_mor_a6_hhmember_age_6 R_mor_a6_dob_7 years_R_mor_a6_dob_7 R_mor_a6_hhmember_age_7 R_mor_a6_dob_8 years_R_mor_a6_dob_8 R_mor_a6_hhmember_age_8 R_mor_a6_dob_9 years_R_mor_a6_dob_9 R_mor_a6_hhmember_age_9 R_mor_a6_dob_10 years_R_mor_a6_dob_10 R_mor_a6_hhmember_age_10 R_mor_a6_dob_11 years_R_mor_a6_dob_11 R_mor_a6_hhmember_age_11 R_mor_a6_dob_12 years_R_mor_a6_dob_12 R_mor_a6_hhmember_age_12 using "$PathTables/Ages_tables.xlsx", firstrow(varlabels) sheet(HH_member_age) sheetreplace

 
forvalues i = 1/4 {
      gen child_diff_`i' = R_mor_date_death_`i'_1 - R_mor_date_birth_`i'_1
      gen child_diff_years_`i' = child_diff_`i' / 365 
}

*export excel R_mor_village unique_id_num submission_date R_mor_date_death_1_1 R_mor_date_birth_1_1 child_diff_years_1  using "$PathTables/Ages_tables.xlsx", firstrow(varlabels) sheet(HH_member_age) sheetreplace

  
forvalues i = 1/6 {
      gen sc_child_diff_`i' = R_mor_date_death_sc_`i'_1 - R_mor_date_birth_sc_`i'_1
      gen sc_child_diff_years_`i' = sc_child_diff_`i' / 365 

}

  
forvalues i = 1/6 {
      gen sc_2_child_diff_`i' = R_mor_date_death_sc_`i'_2 - R_mor_date_birth_sc_`i'_2
	  gen sc_2_child_diff_years_`i' = sc_2_child_diff_`i' / 365
}

*******************************************************

//creating a subset for child deaths to match with CDR
/*-----------------------------------------------------------------------------------------------------------------------------------
                                                        SECTION 1(PART A) - PRODUCTIVITY
-------------------------------------------------------------------------------------------------------------------------------------*/
 
*install the following packages*
//ssc install labutil
//ssc install fre
fre submission_date
gen T = string(submission_date, "%td") 
labmask submission_date, values(T) 

/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SUB-SECTION 1.1 -  Date wise surveys per day
-----------------------------------------------------------------------------------------------------------------------------------------*/

*Date wise total surveys
qui bys submission_date: gen daily_total = _N

//export this graph in everything doc 
graph bar daily_total, over(submission_date, label(labsize(vsmall) angle(45))) ///
	graphregion(c(white)) xsize(7) ylab(0(20)200, labsize(medsmall) angle(0)) ///
	ytitle("Daily total surveys") bar(1, fc(eltblue%80))
	graph export "$PathGraphs/Surveys_per_day.png", replace

/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SUB-SECTION 1.2 -  Daily average productivity 
-----------------------------------------------------------------------------------------------------------------------------------------*/
sum daily_total
gen daily_avg = r(mean) 
preserve
collapse daily_total daily_avg, by (submission_date)
label variable daily_total "Total surveys per day"
label variable daily_avg "Average surveys on all days"
global Variables1 submission_date daily_total daily_avg
texsave $Variables1 using "$PathTables/Date_wise_surveys.tex", ///
        title("Date wise total surveys per day in comparison with average") replace varlabels frag location(htbp) 
export excel submission_date daily_total daily_avg using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(Date_wise_surveys) sheetreplace
restore
	
/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SUB-SECTION 1.3 -  Village-Date wise surveys per day
-----------------------------------------------------------------------------------------------------------------------------------------*/
bys R_mor_village submission_date: gen date_wise_village_total = _N	

// Scatter plot with line connections
	scatter date_wise_village_total submission_date, by(R_mor_village) ///
    xtitle("Submission Date", size(small)) ytitle("Date Wise Village Total", size(small)) ///
    graphregion(margin(small)) || ///
    line date_wise_village_total submission_date, by(R_mor_village) ///
    xtitle("Submission Date", size(small)) ytitle("Date Wise Village Total", size(small)) ///
    xlabel(, angle(45))
graph export "$PathGraphs\Date_village_wise_total.png", as(png) replace	



preserve
collapse date_wise_village_total daily_avg, by (R_mor_village submission_date)
label variable R_mor_village "Village"
label variable date_wise_village_total "Village wise and date wise total surveys per day"
label variable daily_avg "Average surveys on all days"
global Variables2 R_mor_village submission_date date_wise_village_total daily_avg
texsave $Variables2 using "$PathTables/Village_Date_wise_surveys.tex", ///
        title("Village-Date wise total surveys per day in comparison with average") replace varlabels frag location(htbp) 
export excel R_mor_village submission_date date_wise_village_total daily_avg using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(Village_productivity) sheetreplace
restore

/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SECTION 1 (PART B) - ENUM WISE PRODUCTIVITY CHECKS
-----------------------------------------------------------------------------------------------------------------------------------------*/

********************************************************************************************************************************************
//Including all surveys (Complete and unavailable surveys)
********************************************************************************************************************************************


// Step 1: Sort the dataset by R_mor_village and submission_date
sort R_mor_village submission_date

// Step 2: Use by prefix to group observations by R_mor_village
by R_mor_village: egen unique_dates = total(submission_date != submission_date[_n-1])

// Step 3: List the village-wise total number of unique dates
list R_mor_village unique_dates

 *Average productivity per day by surveyor                                                          

egen tag = tag(R_mor_enum_name_f submission_date)
egen days_worked = total(tag), by(R_mor_enum_name_f)
bys R_mor_enum_name_f: gen total_surveys_done_enum = _N
gen daily_avg_enum = round(total_surveys_done_enum/days_worked, .01) 
egen enum_tag = tag(R_mor_enum_name_f)
egen total_enums = total(enum_tag)
gen total_avg_enum_pro = round(daily_avg/total_enums, .01)
tabdisp R_mor_enum_name_f, c(days_worked total_surveys_done_enum daily_avg_enum) format(%9.2f) center
graph bar daily_avg_enum, over(R_mor_enum_name_f, sort(1) lab(labsize(vsmall) angle(45))) ///
	graphregion(c(white)) xsize(8) ytitle("Average surveys per day") ///
	bar(1, fc(ebblue%50) lc(ebblue))
	graph export "$PathGraphs/average_daily_surveys.png", replace

preserve
collapse days_worked total_surveys_done_enum daily_avg_enum total_avg_enum_pro, by(R_mor_enum_name_f)
label variable R_mor_enum_name_f "Enumerators"
label variable days_worked "Total number of days worked by each Enum"
label variable total_surveys_done_enum "Total surveys done by each Enum"
label variable daily_avg_enum "Each enum's daily average productivity"
label variable days_worked "Total number of days worked by each Enum"
label variable total_avg_enum_pro "Average productivity per day for all enums"
global Variables3 R_mor_enum_name_f days_worked total_surveys_done_enum daily_avg_enum total_avg_enum_pro
texsave $Variables3 using "$PathTables/Avg_enum_productivity.tex", ///
        title("Enumerators daily average productivity") replace varlabels frag location(htbp) 
export excel R_mor_enum_name_f days_worked total_surveys_done_enum daily_avg_enum total_avg_enum_pro using "$PathTables/Mortality_tables.xlsx", sheet("Avg_enum_productivity") sheetreplace firstrow(varlabels)
restore


*Outlier productivity
sum daily_avg_enum, d 
gen ninetyfive_perc = r(p95)
sum daily_avg_enum, d 
gen tenth_perc =  r(p10)
preserve
list R_mor_enum_name_f daily_avg_enum if (daily_avg_enum > ninetyfive_perc | daily_avg_enum < tenth_perc)  & daily_avg_enum != . , abbr(24) 
collapse days_worked total_surveys_done_enum daily_avg_enum total_avg_enum_pro ninetyfive_perc tenth_perc, by(R_mor_enum_name_f)
label variable R_mor_enum_name_f "Enumerators"
label variable days_worked "Total number of days worked by each Enum"
label variable total_surveys_done_enum "Total surveys done by each Enum"
label variable daily_avg_enum "Each enum's daily average productivity"
label variable days_worked "Total number of days worked by each Enum"
label variable total_avg_enum_pro "Average productivity per day for all enums"
cap export excel R_mor_enum_name_f days_worked total_surveys_done_enum daily_avg_enum total_avg_enum_pro using "$PathTables/Mortality_tables.xlsx" if  (daily_avg_enum > ninetyfive_perc | daily_avg_enum < tenth_perc)  & daily_avg_enum != . , sheet("outlier_avg_enum_productivity") sheetreplace firstrow(varlabels)
restore


*Total productivity per day by surveyor
bys R_mor_enum_name_f submission_date: gen total_pro_enum_date = _N
preserve
collapse total_pro_enum_date total_avg_enum_pro, by ( R_mor_enum_name_f submission_date)
label variable R_mor_enum_name_f "Enumerators"
label variable total_avg_enum_pro "Average productivity per day for all enums"
label variable total_pro_enum_date "Enum each day productivity"
global Variables4 R_mor_enum_name_f submission_date total_pro_enum_date total_avg_enum_pro
texsave $Variables4 using "$PathTables/Datewise_enum_productivity.tex", ///
        title("Enumerators date-wise productivity") replace varlabels frag location(htbp) 
export excel R_mor_enum_name_f submission_date total_pro_enum_date total_avg_enum_pro using "$PathTables/Mortality_tables.xlsx", sheet("Datewise_enum_productivity") sheetreplace firstrow(varlabels)
restore




********************************************************************************************************************************************
//Including only Completed surveys 
********************************************************************************************************************************************
 
*Average productivity per day by surveyor                                                          

preserve
drop if R_mor_resp_available != 1
drop tag
drop days_worked
drop daily_avg_enum
drop total_surveys_done_enum
qui bys submission_date: gen com_daily_total = _N
sum com_daily_total
gen com_daily_avg = r(mean) 
egen tag = tag(R_mor_enum_name_f submission_date)
egen days_worked = total(tag), by(R_mor_enum_name_f)
bys R_mor_enum_name_f: gen total_surveys_done_enum = _N
gen daily_avg_enum = round(total_surveys_done_enum/days_worked, .01) 
egen enum_tag_c = tag(R_mor_enum_name_f)
egen total_enums_c = total(enum_tag_c)
gen com_total_avg_enum_pro = round(com_daily_avg/total_enums_c, .01)
tabdisp R_mor_enum_name_f, c(days_worked total_surveys_done_enum daily_avg_enum) format(%9.2f) center
graph bar daily_avg_enum, over(R_mor_enum_name_f, sort(1) lab(labsize(vsmall) angle(45))) ///
	graphregion(c(white)) xsize(8) ytitle("Average Completed surveys per day") ///
	bar(1, fc(ebblue%50) lc(ebblue))
	graph export "$PathGraphs/average_completed_daily_surveys.png", replace
collapse days_worked total_surveys_done_enum daily_avg_enum com_total_avg_enum_pro, by(R_mor_enum_name_f)
label variable R_mor_enum_name_f "Enumerators"
label variable days_worked "Total number of days worked by each Enum"
label variable total_surveys_done_enum "Total complete surveys done by each Enum"
label variable daily_avg_enum "Each enum's daily average productivity for completed surveys"
label variable days_worked "Total number of days worked by each Enum"
label variable com_total_avg_enum_pro "Average productivity per day for all enums only for completed surveys"
global Variables5 R_mor_enum_name_f days_worked total_surveys_done_enum daily_avg_enum com_total_avg_enum_pro
texsave $Variables5 using "$PathTables/Completed_Avg_enum_productivity.tex", ///
        title("Enumerators daily average productivity only for completed surveys") replace varlabels frag location(htbp) 
export excel R_mor_enum_name_f days_worked total_surveys_done_enum daily_avg_enum com_total_avg_enum_pro using "$PathTables/Mortality_tables.xlsx", sheet("Completed_Avg_enum_productivity") sheetreplace firstrow(varlabels)
restore


*Total productivity per day by surveyor

preserve
drop if R_mor_resp_available != 1
drop enum_tag
drop total_enums
qui bys submission_date: gen com_daily_total = _N
sum com_daily_total
gen com_daily_avg = r(mean) 
bys R_mor_enum_name_f submission_date: gen com_total_pro_enum_date = _N
egen enum_tag = tag(R_mor_enum_name_f)
egen total_enums = total(enum_tag)
gen com_total_avg_enum_pro = round(com_daily_avg/total_enums, .01)
collapse com_total_pro_enum_date com_total_avg_enum_pro total_avg_enum_pro, by (R_mor_enum_name_f submission_date)
label variable R_mor_enum_name_f "Enumerators"
label variable total_avg_enum_pro "Average productivity per day for all enums for all the surveys(including unavailable)"
label variable com_total_avg_enum_pro "Average productivity per day for all enums only for completed surveys"
label variable com_total_pro_enum_date "Enum each day productivity for only completed surveys"
global Variables6 R_mor_enum_name_f submission_date com_total_pro_enum_date com_total_avg_enum_pro total_avg_enum_pro
texsave $Variables6 using "$PathTables/Comp_Datewise_enum_productivity.tex", ///
        title("Enumerators date-wise productivity only for completed surveys") replace varlabels frag location(htbp) 
export excel R_mor_enum_name_f submission_date com_total_pro_enum_date com_total_avg_enum_pro total_avg_enum_pro using "$PathTables/Mortality_tables.xlsx", sheet("Comp_Datewise_enum_productivity") sheetreplace firstrow(varlabels)
restore



********************************************************************************************************************************************
//Gender based productivity
********************************************************************************************************************************************

* dummy for male and female enum
*1 stands for male and 0 stands for female
gen enum_gender = 1 if R_mor_enum_name_f == "Bibhar Pankaj" | R_mor_enum_name_f == "Ishadatta Pani" | R_mor_enum_name_f == "Rajib Panda"
replace enum_gender = 0 if R_mor_enum_name_f == "Sarita Bhatra" | R_mor_enum_name_f == "Pramodini Gahir"
egen tag_gender = tag(enum_gender submission_date)
egen days_gender = total(tag_gender) , by(enum_gender)
bysort enum_gender: gen gender_wise_total= _N 
gen gender_daily_avg = round(gender_wise_total/days_gender, .01)
tabdisp enum_gender, c(days_gender gender_wise_total gender_daily_avg) format(%9.2f) center
preserve
collapse days_gender gender_wise_total gender_daily_avg, by(enum_gender)
label define Gender_var 0 "Female" 1 "Male"
label values enum_gender Gender_var
label variable days_gender "No of days each gender worked"
label variable gender_wise_total "Total surveys gender wise"
label variable gender_daily_avg "Daily avg gender wise"
label variable enum_gender "Gender wise classification"
global Variables7 enum_gender days_gender gender_wise_total gender_daily_avg
texsave $Variables7 using "$PathTables/gender_productivity.tex", ///
        title("gender wise productivity") replace varlabels frag location(htbp) 
export excel enum_gender days_gender gender_wise_total gender_daily_avg using "$PathTables/Mortality_tables.xlsx", sheet("gender_productivity") sheetreplace firstrow(varlabels)
restore



/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SECTION 1 (PART C) - ENUM WISE DURATION
-----------------------------------------------------------------------------------------------------------------------------------------*/
destring R_mor_consent_dur_end, replace
gen duration_mins = R_mor_consent_dur_end/60	
sum duration_mins
gen overall_avg = r(mean)
sum duration_mins, d
gen perc90 = r(p90)
sum duration_mins, d
gen perc10 = r(p10)
sum duration_mins, d
gen perc99 = r(p99)
sum duration_mins, d
gen perc5 = r(p5)
bys R_mor_enum_name_f: egen avg_dur = mean(duration_mins)
label variable R_mor_enum_name_f "Enumerator"
label variable duration_mins "Daily duration (in mins)"
label variable avg_dur "Avg duration for each enum"
label variable overall_avg "Avg duration for all enums"
label variable R_mor_resp_available "Resp. availability"
label define hh 1 "Available HH" 2 "Family left permanently" 6 "Not available after 3rd revisit"
label values R_mor_resp_available hh 
br submission_date R_mor_enum_name_f duration_mins avg_dur overall_avg R_mor_resp_available if duration_mins > perc99 | duration_mins < perc5 
export excel submission_date R_mor_enum_name_f duration_mins avg_dur overall_avg R_mor_resp_available if duration_mins > perc99 | duration_mins < perc5   using "$PathTables/Mortality_tables.xlsx", sheet("duration") sheetreplace firstrow(varlabels)


ttest duration_mins, by(enum_gender)
graph twoway (hist duration_mins if enum_gender == 1, fc(ebblue%50) lc(ebblue)) ///
	(hist duration_mins if enum_gender == 0, fc(orange_red%50) lc(orange_red) ///
	graphregion(c(white)) legend(order(1 "Male" 2 "Female")) xsize(6.5))
	graph export "$PathGraphs/gender_duration.png", replace


/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SECTION 2 - OUTLIERS
-----------------------------------------------------------------------------------------------------------------------------------------*/
drop perc99 perc10 perc5 	
preserve	
*Added child death variables for non screened cases when it reflects in data
ds  R_mor_hh_repeat_code R_mor_a2_hhmember_count R_mor_a6_hhmember_age_* R_mor_a7_pregnant_month_* R_mor_a7_preg_leave_days_*  R_mor_a7_preg_leave_months_* R_mor_child_living_num_* R_mor_child_notliving_num_* R_mor_child_stillborn_num_* R_mor_child_died_num_* R_mor_child_died_num_more24_* 
	foreach var of varlist `r(varlist)' {
        drop if `var' == 999 | `var' == 98
		qui sum `var', d   
        gen perc99 = r(p99)
		qui sum `var', d   
        gen perc95 = r(p95)
		qui sum `var', d 
		gen perc10 = r(p10)
		qui sum `var', d   
        gen perc5 = r(p5)
		qui sum `var', d 
		gen perc50 = r(p50)
		cap export excel R_mor_enum_name_f  R_mor_block_name R_mor_block_name R_mor_resp_name `var' if (`var' > perc99 | `var' < perc5) & !missing(`var') using "$PathTables/updated_outliers.xlsx", firstrow(varlabels) sheet(`var') sheetreplace  
		drop perc99
		drop perc95
		drop perc10
		drop perc50
		drop perc5
	}
cap drop perc99 perc95 perc10 perc5	
restore



/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 3 - PERCENTAGES OF DON'T KNOWS, REFUSALS AND OTHERS 
-----------------------------------------------------------------------------------------------------------------------------------------*/

*************************************************************** 
//Percentage of Don't knows in each variable where its applicable
***************************************************************

//ssc install findname
preserve
drop starttime endtime
renpfix R_mor_  //Removing R_mor_ otherwise variable name length is exceeding 
ds marital_*  a7_pregnant_* last_5_years_pregnant_* last_5_years_preg_oth_* child_living_*  child_notliving_*   child_stillborn_*  child_alive_died_* miscarriage_*
foreach var of varlist `r(varlist)' {
	
	count if `var' == 999
	gen m9_`var' = r(N)
	sum `var'
	gen ma_`var' = r(N)
	gen mo_`var' = m9_`var' / ma_`var'
	
	label var mo_`var' "Don't knows"
}

	findname, all(@==0) varlabeltext(Don*) // finds variables == 0 with label w/ "Don"
	drop `r(varlist)'	
	collapse mo_* ma_*
	gen id = _n
	reshape long mo_ ma_, i(id) string
	rename mo_ dontknows
	rename ma_ observations
	sum dontknows, det
	sort dontknows observations
	drop if dontknows == .
	gsort dontknows
	label variable _j "Variable"
	drop id
	cap export excel using "$PathTables/responses.xlsx", sheet("Don't knows - num") sheetreplace firstrow(varlabels)
	cap drop mo_* ma_* m9_*
restore
	
*************************************************************** 
//Percentage of Refused to answer in each variable where its applicable
***************************************************************

preserve
drop starttime endtime
renpfix R_mor_  //Removing R_mor_ otherwise variable name length is exceeding 
ds marital_*  a7_pregnant_* last_5_years_pregnant_* last_5_years_preg_oth_* child_living_*  child_notliving_*   child_stillborn_*  child_alive_died_* a4_hhmember_gender_*
foreach var of varlist `r(varlist)' {

	count if `var' == 98
	gen m9_`var' = r(N)
	sum `var'
	gen ma_`var' = r(N)
	gen mo_`var' = m9_`var' / ma_`var'
	
	label var mo_`var' "Refuse to answer"
	
}

	findname, all(@==0) varlabeltext(Ref*)
	drop `r(varlist)'	
	collapse mo_* ma_*
	gen id = _n
	reshape long mo_ ma_, i(id) string
	rename mo_ refusals
	rename ma_ observations
	sum refusals, det
	label variable _j "Variable"
	drop id
	cap export excel using "$PathTables/responses.xlsx" if refusals != ., sheet("Refusals - num") sheetreplace firstrow(varlabels)
global Variables8 _j refusals observations
texsave $Variables8 using "$PathTables/refusals.tex", ///
        title("Refusals") replace varlabels frag location(htbp) 
restore


*************************************************************** 
//Percentage of Others in each variable where its applicable
***************************************************************

preserve
drop starttime endtime
renpfix R_mor_  //Removing R_mor_ otherwise variable name length is exceeding 
ds block_name gp_name village a12_water_source_prim a5_hhmember_relation_* , has (type numeric)
foreach var of varlist `r(varlist)' {

	count if `var' == -77
	gen m9_`var' = r(N)
	sum `var'
	gen ma_`var' = r(N)
	gen mo_`var' = m9_`var' / ma_`var'
	
	label var mo_`var' "Others"
	
}

	findname, all(@==0) varlabeltext(Oth*)
	drop `r(varlist)'
	collapse mo_* ma_*
	gen id = _n
	reshape long mo_ ma_, i(id) string
	rename mo_ others
	rename ma_ observations
	sum others, det
	label variable _j "Variable"
	drop id
	cap export excel using "$PathTables/responses.xlsx" if others != ., sheet("Others") sheetreplace firstrow(varlabels)
global Variables9 _j others observations
texsave $Variables9 using "$PathTables/others.tex", ///
        title("% of Others marked in questions") replace varlabels frag location(htbp) 

restore


************************************************************************************************************** 
//Cases of Others in those variables which were multiple select type so they weren't included in previous loop
***************************************************************************************************************

preserve
ds R_mor_cause_death_oth_* R_mor_cause_death__77_* R_mor_reason_no_jjm__77 R_mor_reason_yes_jjm__77 R_mor_change_reason_prim__77 R_mor_change_reason_sec__77, has (type numeric)
foreach var of varlist `r(varlist)' {
list `var' if `var' == 1
gen _`var' = 1 if `var' == 1
}
br _R_mor_reason_yes_jjm__77 R_mor_reason_yes_jjm__77 R_mor_oth_reason_yes_jjm  R_mor_reason_no_jjm__77 _R_mor_reason_no_jjm__77  R_mor_oth_reason_no_jjm if _R_mor_reason_no_jjm__77 == 1 | _R_mor_reason_yes_jjm__77 == 1 | _R_mor_reason_no_jjm__77 == 1 | _R_mor_reason_yes_jjm__77 == 1
export excel _R_mor_reason_yes_jjm__77 R_mor_reason_yes_jjm__77 R_mor_oth_reason_yes_jjm  R_mor_reason_no_jjm__77 _R_mor_reason_no_jjm__77  R_mor_oth_reason_no_jjm if _R_mor_reason_no_jjm__77 == 1 | _R_mor_reason_yes_jjm__77 == 1 | _R_mor_reason_no_jjm__77 == 1 | _R_mor_reason_yes_jjm__77 == 1 using "$PathTables/responses.xlsx", sheet("Multiple_choice_others_specify") sheetreplace firstrow(varlabels)  
collapse (sum) _*
export excel using "$PathTables/responses.xlsx", sheet("Multiple_choice_others") sheetreplace firstrow(varlabels)
restore



/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 4 - WOMEN AND CHILD RELATED ESTIMATES
-----------------------------------------------------------------------------------------------------------------------------------------*/

//Calculations related to women child bearing age	
destring R_mor_women_child_bear_count_f, replace
rename R_mor_village village
//R_mor_women_child_bear_count_f independently doesn't reflect the total child beraing women because it does not include cases where eligible women was included in "other" category so we nned to add those other women to this variable to find the total number
egen temp_group = group(unique_id_num)
egen total_CBW = rowtotal(R_mor_women_child_bear_count_f R_mor_how_many_oth)
drop temp_group
drop R_mor_women_child_bear_count_f
rename total_CBW R_mor_women_child_bear_count_f


/***********************************************************
AGE WISE DISTRIBUTION OF U5 DIED CHILDREN
*************************************************************/
br R_mor_check_scenario R_mor_unique_id R_mor_age_child_*

egen temp_group = group(unique_id_num)
egen total_CBW = rowtotal(R_mor_women_child_bear_count_f R_mor_how_many_oth)
drop temp_group






********************************************************************************************************************************************
//VILLAGE LEVEL STATS
********************************************************************************************************************************************


preserve

//Because of roster present each unqiue ID has many variables for one category we need to combine it to find the total that's why rowtotal command is used
//In all the calculations below I have excluded observations where it was 999 or 98 otherwise they would disrupt the total calculation
**Number of total child living with the mother

egen temp_group = group(unique_id_num) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen
ds R_mor_child_living_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_childlivingnum = rowtotal(R_mor_child_living_num_*)
drop temp_group
br village unique_id_num R_mor_child_living_num_* total_childlivingnum if total_childlivingnum != 0


**Number of total alive child but not living with the mother 

egen temp_group = group(unique_id_num)
ds R_mor_child_notliving_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_notlivingchild = rowtotal(R_mor_child_notliving_num_*)
drop temp_group
br village unique_id_num R_mor_child_notliving_num_* total_notlivingchild if total_notlivingchild != 0

**Number of total stillborn child
egen temp_group = group(unique_id_num)
ds R_mor_child_stillborn_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group
br village unique_id_num R_mor_child_stillborn_num_* total_stillborn if total_stillborn != 0


**Number of total child died under 24 hours
 
egen temp_group = group(unique_id_num)
ds R_mor_child_died_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
//We need to remove R_mor_child_died_num_more24 from this calculation as we are only intrested in child died less than 24 hours and R_mor_child_died_num_* also includes more than 24hours cases so that needs to be excluded
local filtered_vars
foreach var of varlist R_mor_child_died_num_* {
    if !regexm("`var'", "R_mor_child_died_num_more24_") local filtered_vars `filtered_vars' `var'
}
egen total_childdiedless24 = rowtotal(`filtered_vars')
drop temp_group
br village unique_id_num R_mor_child_died_num_* total_childdiedless24 if total_childdiedless24!= 0
 
 
**Number of total child died after 24 hours and till the age of 5 years
   
egen temp_group = group(unique_id_num)
egen total_childdiedmore24 = rowtotal(R_mor_child_died_num_more24_*)
drop temp_group
br village unique_id_num R_mor_child_died_num_more24_* total_childdiedmore24 if total_childdiedmore24 != 0
   

**Number of women who have been pregnant in last 5 years
//Since there are 2 variables for women pregnant in last 5 years one for screened and non sreened households and one for other women we need to combine these to get a total number for each unqiue ID 
egen temp_group = group(unique_id_num)
ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_last5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_last5preg_women if total_last5preg_women != 0


*Number of women currently pregnant 
*This commands only outputs data for Non screened households as in this survey we are only asking about current pregnancy status of women belonging to non screend households for this reason number in the overleaf pdf for this category are different because I added current pregnancy numbers shared by michelle from census in that document. Sharing the numbers below for reference 
*Current preg women (based on census data)
*Gopi Kankubadi = 5
*BK Padar = 6 
*Nathma = 7 
*Kuljing = 7 

egen temp_group = group(unique_id_num)
//Variables will have to be selected individually because R_mor_a7_pregnant otherwise will also include leave days, month, days etc which are not required for this calculation
ds R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_currently_preg = rowtotal(R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12 )
drop temp_group
br village unique_id_num R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12  total_currently_preg if total_currently_preg != 0

* Visitor females 
//Since question is about whether this household is their current residence visitors will say "No" and that would be coded as 0 so to calculate no. of visitors I replaced "1" which is coded as "Yes" with a missing value and "0" which means "No" with 1 because rowtotal doesn't calculate 0 and missing values and to get the true picture of visitors 0 needs to be replaced with 1 
egen temp_group = group(unique_id_num)
ds R_mor_residence_yesno_pc_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
}
egen visitors = rowtotal(R_mor_residence_yesno_pc_*)
drop temp_group

**Permamnent residence in last 5 years for visitor females (Only for visitors) 
//This command makes sure that a variable is generated witha prefix "P" which highlights that 1 is allocated to an observation only when women is a visitor (0 recoded as 1 for calculation purpose) and says that current village has been her permamnent residence at any point of time in last 5 years
forval X = 1/6 {
    gen P`X' = (R_mor_residence_yesno_pc_`X'_f == 1) & (R_mor_vill_residence_`X'_f == 1)
}
egen temp_group = group(unique_id_num)
egen perm_5years = rowtotal(P*)
drop temp_group



**Number of women with miscarriages
br unique_id_num R_mor_key R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f R_mor_last_5_years_preg_oth_1 R_mor_last_5_years_preg_oth_2 R_mor_a41_end_comments R_mor_miscarriage_*  if R_mor_last_5_years_pregnant_1_f == 1 | R_mor_last_5_years_pregnant_2_f == 1| R_mor_last_5_years_pregnant_3_f == 1 | R_mor_last_5_years_pregnant_4_f == 1 | R_mor_last_5_years_pregnant_5_f == 1 | R_mor_last_5_years_pregnant_6_f == 1 | R_mor_last_5_years_preg_oth_1 == 1| R_mor_last_5_years_preg_oth_2 == 1& (total_stillborn == 0 | total_childdiedless24 == 0 | total_childdiedmore24 == 0)
ds R_mor_miscarriage_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_miscarriages = rowtotal(R_mor_miscarriage_*)
drop temp_group
br village unique_id_num R_mor_miscarriage_* total_miscarriages if total_miscarriages != 0

**Minor pregnancies
//This command separates out age from name variable, this is done because order of people recorded in the women roster might not exactly follow the order of the main roster for eg- person 1 in main roster can be different than person 1 in the women roster so to avoid miscalculation of minor pregnancies I followed women roster order only 
ds R_mor_name_pc_earlier_*
foreach var of varlist `r(varlist)'{
gen A_`var' = regexs(1) if regexm( `var' , "([0-9]+) years")
destring A_`var', replace
}
//the command below generates a var with prefix Q and assigns number 1 wherever there is a minor
ds A_*
foreach var of varlist `r(varlist)'{
gen Q_`var' = 1 if `var' > 14 & `var' < 18 & `var' != .
}
//the command below generates a var with prefix MP and assigns number 1 wherever there is a minor and she says she has been pregnant in last 5 years
br unique_id_num village R_mor_name_pc_* Q_* R_mor_last_5_years_preg_* R_mor_last_5_years_pregnant_* if Q_A_R_mor_name_pc_earlier_oth_1 == 1 | Q_A_R_mor_name_pc_earlier_oth_2 == 1 | Q_A_R_mor_name_pc_earlier_1_f == 1 | Q_A_R_mor_name_pc_earlier_2_f == 1 | Q_A_R_mor_name_pc_earlier_3_f == 1 | Q_A_R_mor_name_pc_earlier_4_f == 1 | Q_A_R_mor_name_pc_earlier_5_f == 1 | Q_A_R_mor_name_pc_earlier_6_f == 1 
forval X = 1/6 {
    gen MP`X' = (Q_A_R_mor_name_pc_earlier_`X'_f == 1) & (R_mor_last_5_years_pregnant_`X'_f == 1)
}
//the command below generates a var with prefix OP and assigns number 1 wherever there is a minor and she says she has been pregnant in last 5 years (only for other women)
forval X = 1/2 {
    gen OP`X' = (Q_A_R_mor_name_pc_earlier_oth_`X' == 1) & (R_mor_last_5_years_preg_oth_`X' == 1)
}
egen temp_group = group(unique_id_num)
egen total_minor_preg = rowtotal(MP* OP*)
drop temp_group


**Number of women who have not been pregnant in last 5 years
//Since rowtotal doesn't count 0 and missing value to calculate all the NO I had to recode NO's value from 0 to 1 
ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_notlast5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_notlast5preg_women if total_notlast5preg_women != 0

br village R_mor_submissiondate unique_id_num R_mor_enum_name_f R_mor_child_stillborn_num_* total_stillborn  R_mor_child_died_num_* total_childdiedless24 total_childdiedmore24 if total_stillborn != 0 | total_childdiedless24 !=0 | total_childdiedmore24 != 0

collapse (sum) R_mor_women_child_bear_count_f total_last5preg_women total_notlast5preg_women total_currently_preg total_stillborn total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24 total_miscarriages visitors  perm_5years total_minor_preg, by (village)

egen total_live_births = rowtotal(total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24)

egen total_deaths = rowtotal(total_childdiedless24 total_childdiedmore24)

 
label variable total_live_births "Total Births in the village"
label variable total_deaths "Total deaths in the village"
label variable R_mor_women_child_bear_count_f "Total child bearing women"
label variable total_last5preg_women "Total women pregnant in the last 5 years"
label variable total_notlast5preg_women "Total women not been pregnant in the last 5 years"
label variable total_stillborn "Total no. of stillborn children"
label variable total_childlivingnum "Total no. of children who are living with the respondent currently"
label variable total_notlivingchild "Total no. of children who are alive and do not live with respondent"
label variable total_childdiedless24 "Total no. of children died within less than 24 hours of birth"
label variable total_childdiedmore24 "Total no. of children died after 24 hours of birth"
label variable total_currently_preg "Total no. of women currently pregnant in non screened households"
label variable total_miscarriages "Total no. of miscarriages"
label variable visitors "Eligible women who were visitors"
label variable perm_5years "Visitors's perm. residence(last 5 years)"
label variable total_minor_preg "Minor pregnancies"

egen total_livebirths_all = total(total_live_births)
egen total_deaths_all = total(total_deaths)
egen total_women_all = total(R_mor_women_child_bear_count_f)
egen total_last5preg_women_all = total(total_last5preg_women)
egen total_notlast5preg_women_all = total(total_notlast5preg_women)
egen total_stillborn_all = total(total_stillborn)
egen total_childlivingnum_all = total(total_childlivingnum)
egen total_notlivingchild_all = total(total_notlivingchild)
egen total_childdiedless24_all = total(total_childdiedless24)
egen total_childdiedmore24_all = total(total_childdiedmore24)
egen total_currently_preg_all = total(total_currently_preg)
egen total_miscarriages_all = total(total_miscarriages)
egen total_visitors_all = total(visitors)
egen perm_5years_all = total(perm_5years)
egen total_minor_preg_all = total(total_minor_preg)

label variable total_miscarriages_all "Total no. of miscarriages (All villages)"
label variable total_livebirths_all "Total Births (All villages)"
label variable total_deaths_all "Total deaths (All villages)"
label variable total_women_all "Total child bearing women (All villages)"
label variable total_last5preg_women_all "Total women pregnant in the last 5 years (All villages)"
label variable total_notlast5preg_women_all "Total women not been pregnant in the last 5 years (All villages)"
label variable total_stillborn_all "Total no. of stillborn children (All villages)"
label variable total_childlivingnum_all "Total no. of children who are living with the respondent currently (All villages)"
label variable total_notlivingchild_all "Total no. of children who are alive and do not live with respondent (All villages)"
label variable total_childdiedless24_all "Total no. of children died within less than 24 hours of birth (All villages)"
label variable total_childdiedmore24_all "Total no. of children died after 24 hours of birth (All villages)"
label variable total_currently_preg_all "Total no. of women currently pregnant in non screened households (All villages)"
label variable total_visitors_all "Total visitors (all villages)"
label variable perm_5years_all "Visitors perm. residence last 5 years (All villages)"
label variable total_minor_preg_all "Total minor pregnant"


			
export excel village R_mor_women_child_bear_count_f total_last5preg_women total_notlast5preg_women total_currently_preg  total_childlivingnum total_notlivingchild total_live_births total_stillborn total_childdiedless24 total_childdiedmore24 total_deaths total_miscarriages visitors perm_5years total_minor_preg total_livebirths_all total_deaths_all total_women_all  total_last5preg_women_all total_notlast5preg_women_all total_stillborn_all total_childlivingnum_all total_notlivingchild_all total_childdiedless24_all total_childdiedmore24_all total_currently_preg_all total_miscarriages_all total_visitors_all  perm_5years_all total_minor_preg_all using "$PathTables/Mortality_quality.xlsx", sheet("last_5_preg") sheetreplace firstrow(varlabels)


// Stacked bar chart for births and deaths
graph bar (sum) total_stillborn total_childdiedless24 total_childdiedmore24 ///
    total_live_births total_deaths, over(village) stack ///
    title("Births and Deaths by Village") ///
    ytitle("Count", size(small)) ///
    ylabel(, format(%9.0g)) ///
    ysize(6) ///
    graphregion(color(white)) ///
    legend(order(1 "Stillborn" 2 "<24 Hours" 3 ">24 Hours" 4 "Total Births" 5 "Total Deaths")) ///
    bar(1, color(blue)) bar(2, color(yellow)) bar(3, color(green)) bar(4, color( lavender)) bar(5, color(pink))
	graph export "$PathGraphs/child_births_deaths.png", replace


	// Grouped bar chart for pregnancies and miscarriages
graph bar (sum) total_last5preg_women total_notlast5preg_women ///
    total_currently_preg total_miscarriages, over(village) ///
    title("Pregnancies and Miscarriages by Village") ///
    ytitle("Count") ///
    ylabel(, format(%9.0g)) ///
    ysize(6) ///
    graphregion(color(white)) ///
    legend(order(1 "Last 5 Years" 2 "Not Last 5 Years" 3 "Currently Pregnant" 4 "Miscarriages")) ///
    bar(1, color(eltgreen)) bar(2, color(stone)) bar(3, color(green)) bar(4, color(pink))
	graph export "$PathGraphs/women_pregnancies.png", replace
	
**Percentages
gen perc_pregwomen_last5 = (total_last5preg_women/ R_mor_women_child_bear_count_f)*100
gen perc_stillborn	= (total_stillborn/total_deaths)*100
gen perc_child_less24 = (total_childdiedless24/total_deaths)*100
gen perc_child_more24 = (total_childdiedmore24/total_deaths)*100	
gen perc_livingchild = (total_childlivingnum/total_live_births)*100
gen perc_notlivingchild = (total_notlivingchild/total_live_births)*100
gen perc_miscarriage = (total_miscarriages/total_last5preg_women)*100
gen perc_minor = (total_minor_preg/total_last5preg_women)*100	

label variable perc_pregwomen_last5 "% of women preg (last 5 years)"
label variable perc_stillborn "% of stillborn"
label variable perc_child_less24 "% of child died (<24 hours)"
label variable perc_child_more24 "% of child died (>24 hours)"
label variable perc_livingchild "% of child living with resp"
label variable perc_notlivingchild "% of child not living with resp"
label variable perc_miscarriage "% of miscarraiges"
label variable perc_minor "% of minor pregnancies"


export excel village perc_pregwomen_last5 perc_stillborn perc_child_less24 perc_child_more24 perc_livingchild perc_notlivingchild perc_miscarriage perc_minor using "$PathTables/Mortality_quality.xlsx", sheet("perc_last_5_preg") sheetreplace firstrow(varlabels)

restore



********************************************************************************************************************************************
//HOUSEHOLD LEVEL ESTIMATES 
********************************************************************************************************************************************

cap drop total_childlivingnum total_notlivingchild total_stillborn total_childdiedless24 total_childdiedmore24 total_last5preg_women total_currently_preg  total_miscarriages

preserve

**Assigning 1 to each unqiue id to calculate total number of hosueholds"
bys unique_id_num: gen total = 1

**Number of total child living with the mother

egen temp_group = group(unique_id_num)
ds R_mor_child_living_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_childlivingnum = rowtotal(R_mor_child_living_num_*)
drop temp_group
br village unique_id_num R_mor_child_living_num_* total_childlivingnum if total_childlivingnum != 0
gen HH_with_childliving = 1 if total_childlivingnum != 0 & total_childlivingnum != .


**Number of total alive child but not living with the mother 

egen temp_group = group(unique_id_num)
ds R_mor_child_notliving_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_notlivingchild = rowtotal(R_mor_child_notliving_num_*)
drop temp_group
br village unique_id_num R_mor_child_notliving_num_* total_notlivingchild if total_notlivingchild != 0
gen HH_with_notlivingchild = 1 if total_notlivingchild != 0 & total_notlivingchild != .

**Number of total stillborn child
egen temp_group = group(unique_id_num)
ds R_mor_child_stillborn_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group
br village unique_id_num R_mor_child_stillborn_num_* total_stillborn if total_stillborn != 0
gen HH_with_stillborn = 1 if total_stillborn != 0 & total_stillborn != .


**Number of total child died under 24 hours
ds R_mor_child_died_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
local filtered_vars
foreach var of varlist R_mor_child_died_num_* {
    if !regexm("`var'", "R_mor_child_died_num_more24_") local filtered_vars `filtered_vars' `var'
}
egen total_childdiedless24 = rowtotal(`filtered_vars')
drop temp_group
br village unique_id_num R_mor_child_died_num_* total_childdiedless24 if total_childdiedless24!= 0
gen HH_with_childdiedless24 = 1 if total_childdiedless24 != 0 & total_childdiedless24 != .
 
 
**Number of total child died after 24 hours and till the age of 5 years
   
egen temp_group = group(unique_id_num)
egen total_childdiedmore24 = rowtotal(R_mor_child_died_num_more24_*)
drop temp_group
br village unique_id_num R_mor_child_died_num_more24_* total_childdiedmore24 if total_childdiedmore24 != 0
gen HH_with_childdiedmore24 = 1 if total_childdiedmore24 != 0 & total_childdiedmore24 != .
  

**Number of women who have been pregnant in last 5 years

egen temp_group = group(unique_id_num)
ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_last5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_last5preg_women if total_last5preg_women != 0
gen HH_with_last5preg_women = 1 if total_last5preg_women != 0 & total_last5preg_women != .


*Number of women currently pregnant  

egen temp_group = group(unique_id_num)
ds R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_currently_preg = rowtotal(R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12 )
drop temp_group
br village unique_id_num R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12  total_currently_preg if total_currently_preg != 0
gen HH_with_currentpreg = 1 if total_currently_preg != 0 & total_currently_preg != .


**Number of women who have not been pregnant in last 5 years

ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_notlast5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_notlast5preg_women if total_notlast5preg_women != 0
gen HH_with_notlast5preg_women = 1 if total_notlast5preg_women != 0 & total_notlast5preg_women != .


**Number of women with miscarriages
br unique_id_num R_mor_key R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f R_mor_last_5_years_preg_oth_1 R_mor_last_5_years_preg_oth_2 R_mor_a41_end_comments R_mor_miscarriage_*  if R_mor_last_5_years_pregnant_1_f == 1 | R_mor_last_5_years_pregnant_2_f == 1| R_mor_last_5_years_pregnant_3_f == 1 | R_mor_last_5_years_pregnant_4_f == 1 | R_mor_last_5_years_pregnant_5_f == 1 | R_mor_last_5_years_pregnant_6_f == 1 | R_mor_last_5_years_preg_oth_1 == 1| R_mor_last_5_years_preg_oth_2 == 1& (total_stillborn == 0 | total_childdiedless24 == 0 | total_childdiedmore24 == 0)
ds R_mor_miscarriage_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_miscarriages = rowtotal(R_mor_miscarriage_*)
drop temp_group
gen HH_with_totalmiscarriages = 1 if total_miscarriages != 0 & total_miscarriages != .
br village unique_id_num R_mor_miscarriage_* total_miscarriages if total_miscarriages != 0 

gen HH_with_eligwomen = 1 if R_mor_women_child_bear_count_f != 0 & R_mor_women_child_bear_count_f != .


collapse (sum) total HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women R_mor_women_child_bear_count_f HH_with_totalmiscarriages HH_with_eligwomen, by (village)
label variable total "Total Households"
label variable HH_with_eligwomen "Households with any child bearing women present"
label variable HH_with_last5preg_women "Households with any women pregnant in the last 5 years"
label variable HH_with_notlast5preg_women "Total Households with any women not been pregnant in the last 5 years"
label variable HH_with_stillborn "Households with any stillborn children"
label variable HH_with_childliving "Households with any no. of children living with the respondent currently"
label variable HH_with_notlivingchild "Households with any no. of children are alive and do not live with respondent"
label variable HH_with_childdiedless24 "Households with any no. of children who died within less than 24 hours of birth"
label variable HH_with_childdiedmore24 "Households with any no. of children who died after 24 hours of birth"
label variable HH_with_currentpreg "Households with any  women who are currently pregnant in non screened households"
label variable HH_with_totalmiscarriages "Households with miscarriages"
label variable R_mor_women_child_bear_count_f "Total child bearing wommen village wise"
global Variables11 village total HH_with_eligwomen HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_totalmiscarriages
texsave $Variables11 using "$PathTables/WC_table_HHlevel.tex", ///
        title("Village wise HH level stats for pregnancy and child deaths") replace varlabels frag location(htbp) 
egen total_households_all = total(total)
egen total_women_all = total(HH_with_eligwomen)
egen total_last5preg_women_all = total(HH_with_last5preg_women)
egen total_notlast5preg_women_all = total(HH_with_notlast5preg_women)
egen total_stillborn_all = total(HH_with_stillborn)
egen total_childlivingnum_all = total(HH_with_childliving)
egen total_notlivingchild_all = total(HH_with_notlivingchild)
egen total_childdiedless24_all = total(HH_with_childdiedless24)
egen total_childdiedmore24_all = total(HH_with_childdiedmore24)
egen total_currently_preg_all = total(HH_with_currentpreg)
egen total_miscarriages_all = total(HH_with_totalmiscarriages)
label variable total_miscarriages_all "Total households with miscarriages "
label variable total_women_all "Total child bearing women "
label variable total_last5preg_women_all "Total households with women pregnant in the last 5 years "
label variable total_notlast5preg_women_all "Total households with women not pregnant (5 years)"
label variable total_stillborn_all "Total households with stillborn children"
label variable total_childlivingnum_all "Total households with children who are living with the respondent currently"
label variable total_notlivingchild_all "Total households with children who are alive and do not live with respondent"
label variable total_childdiedless24_all "Total households with children died within less than 24 hours of birth"
label variable total_childdiedmore24_all "Total households with children died after 24 hours of birth"
label variable total_currently_preg_all "Total households with women currently pregnant in non screened households"
		
		
		
export excel village total R_mor_women_child_bear_count_f HH_with_eligwomen HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_totalmiscarriages total_households_all total_women_all total_last5preg_women_all total_notlast5preg_women_all total_stillborn_all total_childlivingnum_all total_notlivingchild_all total_childdiedless24_all total_childdiedmore24_all total_currently_preg_all total_miscarriages_all   using "$PathTables/Mortality_quality.xlsx", sheet("HH_level") sheetreplace firstrow(varlabels)



// Graph for specified variables with custom bar color
graph bar (sum) HH_with_eligwomen HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women ///
    HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 ///
    HH_with_totalmiscarriages, over(village) ///
    title("Household Characteristics Village Wise") ///
    name(specified_graph, replace) ///
    bar(1, color(erose)) bar(2, color(khaki)) bar(3, color(pink)) ///   // Specify colors for each variable
    bar(4, color(eltblue)) bar(5, color(orange)) bar(6, color(purple)) /// 
    bar(7, color(cyan)) bar(8, color(magenta)) bar(9, color(brown)) ///
    legend(size(small)) ///
    scheme(s1color) 
	graph export "$PathGraphs/HH_women_child.png", replace
restore




/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 5 (PART A) - AVAILABILITY STATUS ESTIMATES
-----------------------------------------------------------------------------------------------------------------------------------------*/


********************************************************************************************************************************************
//Absolute numbers 
********************************************************************************************************************************************

gen screened_out = 1 if R_mor_check_scenario == 0
gen screened_in = 1 if R_mor_check_scenario == 1
preserve 
gen HH_available=1 if R_mor_resp_available == 1
gen HH_locked =1 if R_mor_resp_available == 2
gen HH_not_3rdavailable=1 if R_mor_resp_available == 6
gen notconsented = 1 if R_mor_consent == 0

**Assigning 1 to each unqiue id to calculate total number of hosueholds"
bys unique_id_num: gen total_H = 1

collapse (sum) total_H HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented screened_out screened_in, by (village)
label variable total_H "Total households present"
label variable HH_available "Total no. of available households"
label variable HH_locked "Family has left the house permanently"
label variable HH_not_3rdavailable "HH not available even after 3rd revisit"
label variable R_mor_consent "Available HHs who consented for the survey"
label variable notconsented "Available HHs who did not consent for the survey"
label variable screened_out "Total no. of households which were screened-out in census"
label variable screened_in "Total no. of households which were screened-in in census"
global Variables12 village total_H HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented  screened_out screened_in 
texsave $Variables12 using "$PathTables/HH_availability_status.tex", ///
        title("Households Availability status") replace varlabels frag location(htbp) 
		
export excel village total_H HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented  screened_out screened_in using "$PathTables/Mortality_quality.xlsx", sheet("HH_availability_status") sheetreplace firstrow(varlabels)


********************************************************************************************************************************************
//Percentages
********************************************************************************************************************************************

gen consented_perc = (R_mor_consent/HH_available)*100
gen HH_available_perc = (HH_available/total_H)*100
egen combined_unavail = rowtotal(HH_locked HH_not_3rdavailable)
gen HH_unavail_perc = (combined_unavail/total_H)*100
gen screened_out_perc = (screened_out/total_H)*100
gen screened_in_perc = (screened_in/ total_H)*100
gen not_consent_perc = (notconsented/HH_available)*100
gen permenetly_left_perc = (HH_locked/total_H)*100
gen not_avail3rd_perc = (HH_not_3rdavailable/total_H)*100

local perc consented_perc HH_available_perc HH_unavail_perc screened_out_perc screened_in_perc  not_consent_perc permenetly_left_perc not_avail3rd_perc 
foreach x of local perc{
   gen `x'_rd = round(`x', 0.1)
}   
label variable consented_perc "% of available HHs who consented for the survey"
label variable HH_available_perc "% of available households"
label variable HH_unavail_perc "% of unavailable households(combined locked +3rd revisit)"
label variable screened_out_perc "% of households which were screened-out in census)"
label variable screened_in_perc "% of households which were screened-in in census)"
label variable not_consent_perc "% of available HHs who did not consent for the survey"
label variable permenetly_left_perc "% of HHs permanently locked"
label variable not_avail3rd_perc "% of HHs unavailable after 3rd revisit "

global Variables13 village HH_available_perc HH_unavail_perc consented_perc not_consent_perc  screened_out_perc screened_in_perc 
texsave $Variables13 using "$PathTables/Perc_HH_availability_status.tex", ///
        title("Percenatges of Households Availability status") replace varlabels frag location(htbp) 
export excel village HH_available_perc HH_unavail_perc consented_perc not_consent_perc  screened_out_perc screened_in_perc permenetly_left_perc not_avail3rd_perc  using "$PathTables/Mortality_quality.xlsx", sheet("percentages") sheetreplace firstrow(varlabels)
restore




/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 5 (PART B) - AVAILABILITY STATUS ESTIMATES (Eligible women wise)
-----------------------------------------------------------------------------------------------------------------------------------------*/

********************************************************************************************************************************************
//Absolute numbers 
********************************************************************************************************************************************


preserve

//Because of roster one variable has many sub variables we need to find category wise total
ds R_mor_resp_avail_pc_*
foreach var of varlist `r(varlist)'{
gen A_`var' = 1 if `var' == 1 //woman avialble
gen P_`var' = 1 if `var' == 2 //women left permanently 
gen T_`var' = 1 if `var' == 3 //women temp unavailable
gen FR_`var' = 1 if `var' == 4  //unavail after 1st revsiit
gen SR_`var' = 1 if `var' == 5  //unavail after 2nd revisit
gen TR1_`var' = 1 if `var' == 6  //unavail after 3rd revisit (not within 2 days)
gen TR2_`var' = 1 if `var' == 7  //unavail after 3rd revisit (temp unavail)
}

ds R_mor_consent_pc_*
foreach var of varlist `r(varlist)'{
gen C_`var' = 1 if `var' == 1 //women who consented
gen NC_`var' = 1 if `var' == 0  //women who did not consent
}

//Total consented 
egen temp_group = group(unique_id_num)
egen total_consent = rowtotal(C_*)
drop temp_group
br R_mor_consent_pc_* C_* total_consent

//Total non-consented 
egen temp_group = group(unique_id_num)
egen total_notconsent = rowtotal(NC_*)
drop temp_group
br R_mor_consent_pc_* NC_* total_notconsent


//Total available respondent wise
egen temp_group = group(unique_id_num)
egen total_avail_resp = rowtotal(A_*)
drop temp_group
br R_mor_resp_avail_pc_* A_* total_avail_resp

//Family has left the house permanently
egen temp_group = group(unique_id_num)
egen total_resp_permanently_left = rowtotal(P_*)
drop temp_group
br R_mor_resp_avail_pc_* P_* total_resp_permanently_left


//The respondent is temporarily unavailable but might be available later (the enumerator will check with the neighbors or ASHA or Anganwaadi worker)
egen temp_group = group(unique_id_num)
egen total_resp_temp_unavail = rowtotal(T_*)
drop temp_group
br R_mor_resp_avail_pc_* T_* total_resp_temp_unavail


//First revisit
egen temp_group = group(unique_id_num)
egen total_resp_1strevisit = rowtotal(FR_*)
drop temp_group
br R_mor_resp_avail_pc_* FR_* total_resp_1strevisit

//2nd revisit
egen temp_group = group(unique_id_num)
egen total_resp_2ndrevisit = rowtotal(SR_*)
drop temp_group
br R_mor_resp_avail_pc_* SR_* total_resp_2ndrevisit

//3rd revisit_1
egen temp_group = group(unique_id_num)
egen total_resp_3rdrevisit1 = rowtotal(TR1_*)
drop temp_group
br R_mor_resp_avail_pc_* TR1_* total_resp_3rdrevisit1

//3rd revisit_2
egen temp_group = group(unique_id_num)
egen total_resp_3rdrevisit2 = rowtotal(TR2_*)
drop temp_group
br R_mor_resp_avail_pc_* TR2_* total_resp_3rdrevisit2

collapse (sum) total_consent total_notconsent total_avail_resp total_resp_permanently_left total_resp_temp_unavail total_resp_1strevisit total_resp_2ndrevisit total_resp_3rdrevisit1 total_resp_3rdrevisit2, by (village)
egen total_resp = rowtotal(total_avail_resp total_resp_permanently_left total_resp_temp_unavail total_resp_1strevisit total_resp_2ndrevisit total_resp_3rdrevisit1 total_resp_3rdrevisit2)
label variable total_avail_resp "Total available eligible women"
label variable total_resp_permanently_left  "Total eligible women who left permanently"
label variable total_resp_temp_unavail "eligible women are temporarily unavailable"
label variable total_resp_1strevisit "eligible women not unavailable after 1st revisit"
label variable total_resp_2ndrevisit "eligible women not unavailable after 2nd revisit"
label variable total_resp_3rdrevisit1 "eligible women not unavailable after 3rd revisit_1"
label variable total_resp_3rdrevisit2 "eligible women not unavailable after 3rd revisit_2"
label variable total_consent "Consented eligible women"
label variable total_notconsent "Non-Consented eligible women"

export excel using "$PathTables/Mortality_quality.xlsx", sheet("Resp_wise_unavail") sheetreplace firstrow(varlabels)


// Graph with reduced label and text size
graph bar (sum) total_avail_resp total_resp_permanently_left total_resp_temp_unavail ///
    total_resp_1strevisit total_resp_2ndrevisit total_resp_3rdrevisit1 total_resp_3rdrevisit2, over(village) ///
    title("Eligible Women Response by Village") ///
    name(response_graph, replace) ///
    ytitle("Number of Women") ///
    ylabel(#10, format(%9.0g)) ///
    legend(size(small)) ///
	bar(1, color(erose)) bar(2, color(khaki)) bar(3, color(pink)) ///   // Specify colors for each variable
    bar(4, color(eltblue)) bar(5, color(orange)) bar(6, color(purple)) /// 
    bar(7, color(cyan)) ///
	graphregion(color(white))

graph export "$PathGraphs/Eligible_women_availability.png", replace



********************************************************************************************************************************************
//Percentages
********************************************************************************************************************************************

gen consented_perc = (total_consent/total_avail_resp)*100
gen Resp_available_perc = (total_avail_resp/total_resp )*100
egen combined_unavail = rowtotal(total_resp_permanently_left total_resp_temp_unavail total_resp_1strevisit total_resp_2ndrevisit total_resp_3rdrevisit1 total_resp_3rdrevisit2)
gen Resp_unavail_perc = (combined_unavail/total_resp)*100
gen not_consent_perc = (total_notconsent/total_avail_resp)*100
gen unavail_permamnent = (total_resp_permanently_left/total_resp)*100
gen unavail_temp = (total_resp_temp_unavail/total_resp)*100
gen unavail_1strevisit = (total_resp_1strevisit/total_resp)*100
gen unavail_2ndrevisit = (total_resp_2ndrevisit/total_resp)*100
gen unavail_3rdrevisit1 = (total_resp_3rdrevisit1/total_resp)*100
gen unavail_3rdrevisit2 = (total_resp_3rdrevisit2/ total_resp)*100

local perc consented_perc Resp_available_perc Resp_unavail_perc  not_consent_perc unavail_permamnent unavail_temp unavail_1strevisit unavail_2ndrevisit unavail_3rdrevisit1 unavail_3rdrevisit2 
foreach x of local perc{
   gen `x'_rd = round(`x', 0.1)
}   
label variable consented_perc "% of available Eligible women consented"
label variable Resp_available_perc "% of available Eligible women"
label variable Resp_unavail_perc "% of unavailable Eligible women(combined locked +3rd revisit)"
label variable unavail_permamnent "% of permanently unavailable"
label variable unavail_temp "% of resp. temporarily unavailable"
label variable unavail_1strevisit "% of resp. unavailable after 1st-revisit"
label variable unavail_2ndrevisit "% of resp. unavailable after 2nd-revisit"
label variable unavail_3rdrevisit1 "% of resp. unavailable after 3rd-revisit (permamently)"
label variable unavail_3rdrevisit2 "% of resp. unavailable after 3rd-revisit (within 2 days)"
label variable not_consent_perc "% of available Eligible women not consented"
export excel village consented_perc  not_consent_perc Resp_available_perc Resp_unavail_perc  unavail_permamnent unavail_temp unavail_1strevisit unavail_2ndrevisit unavail_3rdrevisit1 unavail_3rdrevisit2 using "$PathTables/Mortality_quality.xlsx", sheet("percentages_eligible women") sheetreplace firstrow(varlabels)
restore





/*--------------------------------------------------------------------------------------------------------------------------------------
                                                       SECTION 6 - WASH SECTION
-----------------------------------------------------------------------------------------------------------------------------------------*/

**Primary water source distribution
bys R_mor_a12_water_source_prim: gen water = 1
preserve
collapse (sum) water, by (village R_mor_a12_water_source_prim )
drop if R_mor_a12_water_source_prim == .
egen total_water = sum(water), by(village)
gen percentage = (water / total_water) * 100
export excel village R_mor_a12_water_source_prim water total_water percentage  using "$PathTables/Mortality_quality.xlsx", sheet("prim_source") sheetreplace firstrow(varlabels)
restore

**change in primary source
bys village R_mor_change_primary_source : gen prev = _N
preserve
collapse prev, by ( village R_mor_change_primary_source)
drop  if R_mor_change_primary_source == .
egen total_prev = sum(prev), by(village)
gen perc = (prev/total_prev)*100
label variable prev "change in primary source" 
label variable total_prev "total observations"
label variable perc "percenatges"
export excel village R_mor_change_primary_source prev total_prev perc  using "$PathTables/Mortality_quality.xlsx", sheet("prim_prev_source") sheetreplace firstrow(varlabels)
restore

*If changed, what was the previous primary and current primary source
preserve
drop water
bys R_mor_a12_water_source_prim: gen water = 1
keep if R_mor_change_primary_source == 1
gen Yes_change = 1 if R_mor_change_primary_source == 1
bys R_mor_previous_primary: gen prev_prim = 1
collapse (sum)Yes_change prev_prim water R_mor_change_reason_prim_1 R_mor_change_reason_prim_2 R_mor_change_reason_prim_3 R_mor_change_reason_prim_4 R_mor_change_reason_prim_5 R_mor_change_reason_prim_6 R_mor_change_reason_prim_7 R_mor_change_reason_prim_8 R_mor_change_reason_prim__77, by (village R_mor_previous_primary R_mor_a12_water_source_prim)
egen total_reason = rowtotal( R_mor_change_reason_prim_*)
ds R_mor_change_reason_prim_*
foreach var of varlist `r(varlist)'{
bys village: gen n_`var' = (`var'/total_reason)*100
}
label variable n_R_mor_change_reason_prim_2  "Current primary source tastes better"
label variable Yes_change "Yes,Primary source changed"
label variable R_mor_a12_water_source_prim "Current primary source"
label variable R_mor_previous_primary "Previous primary source"
export excel village Yes_change R_mor_a12_water_source_prim R_mor_previous_primary n_R_mor_change_reason_prim_2  using "$PathTables/Mortality_quality.xlsx", sheet("change_prev_source") sheetreplace firstrow(varlabels)
restore


**Secondary water source distribuion type (cases of each category)

preserve
ds R_mor_a13_water_source_sec_*
foreach var of varlist `r(varlist)'{
drop if `var' == .
}
collapse (sum) R_mor_a13_water_source_sec_*, by (village)
egen total_sec_water = rowtotal(R_mor_a13_water_source_sec_*)
label variable R_mor_a13_water_source_sec_1 "JJM taps"
label variable R_mor_a13_water_source_sec_2 "Govt. provided community standpipe"
label variable R_mor_a13_water_source_sec_3 "Gram Panchayat/others"
label variable R_mor_a13_water_source_sec_4 "Manual handpump"
label variable R_mor_a13_water_source_sec_5 "Covered dug well"
label variable R_mor_a13_water_source_sec_6 "Uncovered dug well"
label variable R_mor_a13_water_source_sec_7 "Surface water"
label variable R_mor_a13_water_source_sec_8 "Private surface well"
label variable R_mor_a13_water_source_sec_9 "Borewell (electric)"
label variable R_mor_a13_water_source_sec_10 "HH tap connections exlcude JJM"
label variable R_mor_a13_water_source_sec__77 "others"
export excel using "$PathTables/Mortality_quality.xlsx", sheet("sec_source_dist") sheetreplace firstrow(varlabels)
restore




**Secondary water source distribution
preserve
bys R_mor_a13_water_sec_yn: gen sec = 1
br R_mor_a13_water_sec_yn sec
collapse (sum) sec, by (village  R_mor_a13_water_sec_yn)
drop if R_mor_a13_water_sec_yn == .
egen total_water = sum(sec), by(village)
gen percentage = (sec / total_water) * 100
label variable R_mor_a13_water_sec_yn "Use secondary source" 
label variable sec "total no. of Yes or No"
label variable total_water "total observations"
label variable percentage "percentage"
export excel village R_mor_a13_water_sec_yn sec total_water percentage  using "$PathTables/Mortality_quality.xlsx", sheet("sec_source") sheetreplace firstrow(varlabels)
restore


**Change secondary source
bys village R_mor_change_secondary_source: gen change_sec = _N
preserve
collapse change_sec, by (village R_mor_change_secondary_source)
drop if R_mor_change_secondary_source == .
egen total_sec = sum(change_sec), by(village)
gen perc_sec = (change_sec/total_sec )*100
label variable R_mor_change_secondary_source "Change in secondary source"
label variable change_sec "No. of Yes/No" 
label variable total_sec "total observations"
label variable perc_sec "percenatges"
export excel village R_mor_change_secondary_source change_sec total_sec perc_sec using "$PathTables/Mortality_quality.xlsx", sheet("change_sec_source") sheetreplace firstrow(varlabels)
restore


*If changed, what was the previous sec and current sec  source
preserve
bys R_mor_a13_water_sec_yn: gen sec = 1
keep if R_mor_change_secondary_source == 1
gen Yes_change = 1 if R_mor_change_secondary_source == 1
bys R_mor_previous_secondary: gen prev_sec = 1
collapse (sum)Yes_change prev_sec sec R_mor_change_reason_secondary_1 R_mor_change_reason_secondary_2 R_mor_change_reason_secondary_3 R_mor_change_reason_secondary_4 R_mor_change_reason_secondary_5 R_mor_change_reason_secondary_6 R_mor_change_reason_secondary_7 R_mor_change_reason_secondary_8 R_mor_a13_water_source_sec_* , by (village R_mor_previous_secondary R_mor_a13_water_sec_yn)
egen total_reason = rowtotal( R_mor_change_reason_secondary_*)
label variable R_mor_change_reason_secondary_1 "current source is not broken and does supply water"
label variable Yes_change "Yes,Secondary source changed"
label variable R_mor_previous_secondary "Gram panchayat/othecommmunity standpipe"
label variable R_mor_a13_water_source_sec_4 "Manual handpump"
export excel village R_mor_a13_water_source_sec_4 Yes_change R_mor_previous_secondary R_mor_change_reason_secondary_1 using "$PathTables/Mortality_quality.xlsx", sheet("change_sec_source_reason") sheetreplace firstrow(varlabels)
restore

**JJM tap
cap drop total total_H
preserve
drop if R_mor_a18_jjm_drinking == .
bys village R_mor_a18_jjm_drinking: gen jjm = _N
bys village: gen total_H = _N
collapse jjm total_H , by (village R_mor_a18_jjm_drinking)
gen percentage = (jjm / total_H) * 100
label variable jjm "Yes/No total observations"
label variable R_mor_a18_jjm_drinking "Use JJM for drinking"
label variable total_H "Total households"
label variable percentage "percenatges"
export excel village R_mor_a18_jjm_drinking jjm total_H percentage using "$PathTables/Mortality_quality.xlsx", sheet("JJM") sheetreplace firstrow(varlabels)
restore


**Reasons for using JJM
preserve
collapse (sum)R_mor_a18_jjm_drinking R_mor_reason_yes_jjm_1 R_mor_reason_yes_jjm_2 R_mor_reason_yes_jjm_3 R_mor_reason_yes_jjm_4 R_mor_reason_yes_jjm_5 R_mor_reason_yes_jjm_6 R_mor_reason_yes_jjm_7 R_mor_reason_yes_jjm_8 R_mor_reason_yes_jjm__77, by(village)
label variable R_mor_reason_yes_jjm_1 "JJM is not broken and does supply water"
label variable R_mor_reason_yes_jjm_2 "JJM tastes good"
label variable R_mor_reason_yes_jjm_3 "JJM gives adequate water"
label variable R_mor_reason_yes_jjm_4 "JJM gives water regularly"
label variable R_mor_reason_yes_jjm_5 "JJM supplies high quality water which is suitable for drinking"
label variable R_mor_reason_yes_jjm_6 "JJM safer to drink"
label variable R_mor_reason_yes_jjm_7 "JJM is not muddy or smelly"
label variable R_mor_reason_yes_jjm_8 "JJM is easily accessible"
label variable R_mor_reason_yes_jjm__77 "Other"
label variable R_mor_a18_jjm_drinking "Use JJM for drinking"
export excel using "$PathTables/Mortality_quality.xlsx", sheet("JJM_yesreason") sheetreplace firstrow(varlabels)
graph bar R_mor_reason_yes_jjm_1 R_mor_reason_yes_jjm_2 R_mor_reason_yes_jjm_3 ///
	R_mor_reason_yes_jjm_4 R_mor_reason_yes_jjm_5 R_mor_reason_yes_jjm_6 ///
	R_mor_reason_yes_jjm_7 R_mor_reason_yes_jjm_8 R_mor_reason_yes_jjm__77, ///
	over(village) bar(1, color(erose)) bar(2, color(eltblue)) bar(3, color(green)) ///
	ylabel(#10) ytitle("Reasons for using JJM") legend(on) ///
	title("Reasons for using JJM in Gopi Kankubadi and Nathma") ///
	subtitle("Comparison of frequency of different reasons") ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(size(2)) ///
	legend(label(1 "JJM is not broken and does supply water") ///
	       label(2 "JJM tastes good") ///
	       label(3 "JJM gives adequate water") ///
	       label(4 "JJM gives water regularly") ///
	       label(5 "JJM supplies high quality water which is suitable for drinking") ///
	       label(6 "JJM safer to drink") ///
	       label(7 "JJM is not muddy or smelly") ///
	       label(8 "JJM is easily accessible") ///
	       label(9 "Other"))	
graph export "$PathGraphs\Reasons_for_using_JJM.png", as(png) replace		   
restore



**Reasons for not using JJM
preserve
replace R_mor_a18_jjm_drinking = . if R_mor_a18_jjm_drinking == 1
replace R_mor_a18_jjm_drinking = 1 if R_mor_a18_jjm_drinking == 0
collapse (sum) R_mor_a18_jjm_drinking R_mor_reason_no_jjm_1 R_mor_reason_no_jjm_2 R_mor_reason_no_jjm_3 R_mor_reason_no_jjm_4 R_mor_reason_no_jjm_5 R_mor_reason_no_jjm_6 R_mor_reason_no_jjm_7 R_mor_reason_no_jjm_8 R_mor_reason_no_jjm__77, by(village)
label variable R_mor_reason_no_jjm_1 "JJM is broken and doesn't supply water"
label variable R_mor_reason_no_jjm_2 "JJM doesn't taste good"
label variable R_mor_reason_no_jjm_3 "JJM doesn't give adequate water"
label variable R_mor_reason_no_jjm_4 "JJM doesn't give water regularly"
label variable R_mor_reason_no_jjm_5 "JJM doesn't supply high quality water which is suitable for drinking"
label variable R_mor_reason_no_jjm_6 "JJM is not safer to drink"
label variable R_mor_reason_no_jjm_7 "JJM is muddy or smelly"
label variable R_mor_reason_no_jjm_8 "JJM is not easily accessible"
label variable R_mor_reason_no_jjm__77 "Other"
label variable R_mor_a18_jjm_drinking "Use JJM for drinking"
export excel using "$PathTables/Mortality_quality.xlsx", sheet("JJM_noreason") sheetreplace firstrow(varlabels)
restore



/*-------------------------------------------------------------------------------------------------------------------------------------------------
                                                      SECTION 7: TREATMENT AND CONTROL VILLAGE WISE CLASSIFICATION (still in working plz ignore)
---------------------------------------------------------------------------------------------------------------------------------------------------*/

preserve

clonevar TC = village
replace TC = "0" if village == "BK Padar"
replace TC = "0" if village == "Kuljing"
replace TC = "1" if village == "Gopi Kankubadi"
replace TC = "1" if village == "Nathma"

**Number of total child living with the mother

egen temp_group = group(unique_id_num)
ds R_mor_child_living_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_childlivingnum = rowtotal(R_mor_child_living_num_*)
drop temp_group
br village unique_id_num R_mor_child_living_num_* total_childlivingnum if total_childlivingnum != 0


**Number of total alive child but not living with the mother 

egen temp_group = group(unique_id_num)
ds R_mor_child_notliving_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_notlivingchild = rowtotal(R_mor_child_notliving_num_*)
drop temp_group
br village unique_id_num R_mor_child_notliving_num_* total_notlivingchild if total_notlivingchild != 0

**Number of total stillborn child
egen temp_group = group(unique_id_num)
ds R_mor_child_stillborn_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group
br village unique_id_num R_mor_child_stillborn_num_* total_stillborn if total_stillborn != 0


**Number of total child died under 24 hours
 
egen temp_group = group(unique_id_num)
ds R_mor_child_died_num_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
//We need to remove R_mor_child_died_num_more24 from this calculation as we are only intrested in child died less than 24 hours and R_mor_child_died_num_* also includes more than 23hours cases so that needs to be excluded
local filtered_vars
foreach var of varlist R_mor_child_died_num_* {
    if !regexm("`var'", "R_mor_child_died_num_more24_") local filtered_vars `filtered_vars' `var'
}
egen total_childdiedless24 = rowtotal(`filtered_vars')
drop temp_group
br village unique_id_num R_mor_child_died_num_* total_childdiedless24 if total_childdiedless24!= 0
 
 
**Number of total child died after 24 hours and till the age of 5 years
   
egen temp_group = group(unique_id_num)
egen total_childdiedmore24 = rowtotal(R_mor_child_died_num_more24_*)
drop temp_group
br village unique_id_num R_mor_child_died_num_more24_* total_childdiedmore24 if total_childdiedmore24 != 0
   

**Number of women who have been pregnant in last 5 years

egen temp_group = group(unique_id_num)
ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_last5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_last5preg_women if total_last5preg_women != 0


*Number of women currently pregnant //search if there are more variables 

egen temp_group = group(unique_id_num)
//Variables will have to be sleected individually because R_mor_a7_pregnant otherwise will also include leave days, month, days etc which are not required for this calculation
ds R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_currently_preg = rowtotal(R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12 )
drop temp_group
br village unique_id_num R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12  total_currently_preg if total_currently_preg != 0

* Visitor females 
egen temp_group = group(unique_id_num)
ds R_mor_residence_yesno_pc_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
}
egen visitors = rowtotal(R_mor_residence_yesno_pc_*)
drop temp_group

**Permamnent residence in last 5 years for visitor females (Only for visitors) 
forval X = 1/6 {
    gen P`X' = (R_mor_residence_yesno_pc_`X'_f == 1) & (R_mor_vill_residence_`X'_f == 1)
}
egen temp_group = group(unique_id_num)
egen perm_5years = rowtotal(P*)
drop temp_group



**Number of women with miscarriages
br unique_id_num R_mor_key R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f R_mor_last_5_years_preg_oth_1 R_mor_last_5_years_preg_oth_2 R_mor_a41_end_comments R_mor_miscarriage_*  if R_mor_last_5_years_pregnant_1_f == 1 | R_mor_last_5_years_pregnant_2_f == 1| R_mor_last_5_years_pregnant_3_f == 1 | R_mor_last_5_years_pregnant_4_f == 1 | R_mor_last_5_years_pregnant_5_f == 1 | R_mor_last_5_years_pregnant_6_f == 1 | R_mor_last_5_years_preg_oth_1 == 1| R_mor_last_5_years_preg_oth_2 == 1& (total_stillborn == 0 | total_childdiedless24 == 0 | total_childdiedmore24 == 0)
ds R_mor_miscarriage_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_miscarriages = rowtotal(R_mor_miscarriage_*)
drop temp_group
br village unique_id_num R_mor_miscarriage_* total_miscarriages if total_miscarriages != 0



**Number of women who have not been pregnant in last 5 years
ds R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen temp_group = group(unique_id_num)
egen total_notlast5preg_women = rowtotal(R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* R_mor_last_5_years_preg_oth_* total_notlast5preg_women if total_notlast5preg_women != 0

br village R_mor_submissiondate unique_id_num R_mor_enum_name_f R_mor_child_stillborn_num_* total_stillborn  R_mor_child_died_num_* total_childdiedless24 total_childdiedmore24 if total_stillborn != 0 | total_childdiedless24 !=0 | total_childdiedmore24 != 0

collapse (sum) R_mor_women_child_bear_count_f total_last5preg_women total_notlast5preg_women total_currently_preg total_stillborn total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24 total_miscarriages visitors  perm_5years, by (TC)

restore



































































































