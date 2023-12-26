
*add check for missing GPS
*add loops for death section specifically 
*add question specific loops for women section
*add Yes ad No checls for child death see if there are any deaths present in No or Yes

*Setting table paths for me Archi and Astha
global Table =  "${Overleaf}/Everything document -ILC/Table/"
					if c(username) == "Archi Gupta" {		
	    global Table   "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\" 
	}

global PathGraphs "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
global PathTables "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
ssc install texsave

**Insert fuzzy matching duplicates too**
**Link it with the J-PAL tracker***
****Put more question specific checks***
****Insert graphs****8
***aggregate village level stats and enum stats****
*****table on overall progress****
****No of households********


/*-----------------------------------------------------------------------------------------------------------------------------------
 Manual cleaning                                                       
-------------------------------------------------------------------------------------------------------------------------------------*/

*Enumerator made a data entry error 
replace R_mor_child_stillborn_1_f = 0 if R_mor_child_stillborn_1_f == 1 & R_mor_village == "Nathma" & unique_id_num == 50501503007 & R_mor_key == "uuid:efe798d4-5679-4b19-9154-1f773c775c2a"
replace R_mor_child_stillborn_num_1_f = . if R_mor_child_stillborn_num_1_f == 1 & R_mor_village == "Nathma" & unique_id_num == 50501503007 & R_mor_key == "uuid:efe798d4-5679-4b19-9154-1f773c775c2a"


/*-----------------------------------------------------------------------------------------------------------------------------------
 Combining var name                                                      
-------------------------------------------------------------------------------------------------------------------------------------*/
*generating a combined var name for resp
clonevar R_mor_resp_name = R_mor_a1_resp_name
replace R_mor_resp_name = R_mor_r_cen_a1_resp_name if R_mor_resp_name  == ""
replace R_mor_resp_name = lower(R_mor_resp_name)

*Astha to include both these in cleaning code


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

	
/*-----------------------------------------------------------------------------------------------------------------------------------
Dulpicates check                                                    
-------------------------------------------------------------------------------------------------------------------------------------*/

**Duplicate Unique IDs*** 
bysort unique_id_num: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id_num if dup_HHID > 0
cap export excel unique_id_num R_mor_enum_name_f R_mor_village R_mor_resp_name R_mor_a2_hhmember_count  if dup_HHID > 0  using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(duplicates) sheetreplace


/*-----------------------------------------------------------------------------------------------------------------------------------
                                                        SECTION 1(PART A) - PRODUCTIVITY
-------------------------------------------------------------------------------------------------------------------------------------*/
 
*install the following packages*
*ssc install labutil
*ssc install fre
fre submission_date
gen T = string(submission_date, "%td") 
labmask submission_date, values(T) 

/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SUB-SECTION 1.1 -  Date wise surveys per day
-----------------------------------------------------------------------------------------------------------------------------------------*/

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
*put a graph here
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

*ttest gender_daily_avg, by(enum_gender)
*graph twoway (hist gender_daily_avg if enum_gender == 1, fc(ebblue%50) lc(ebblue)) ///
	*(hist gender_daily_avg if enum_gender == 0, fc(orange_red%50) lc(orange_red) ///
	*graphregion(c(white)) legend(order(1 "Male" 2 "Female")) xsize(6.5) ///
	*note("ttest difference: 11.12***"))
	*graph export "$PathGraphs/gender_duration.png", replace


	

/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      SECTION 2 - OUTLIERS
-----------------------------------------------------------------------------------------------------------------------------------------*/
	
preserve	
*Add child death variables for non screened cases when it reflects in data
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

ssc install findname
preserve
renpfix R_mor_  //Removing R_mor_ otherwise variable name length is exceeding 
ds marital_*  a7_pregnant_* last_5_years_pregnant_* last_5_years_preg_oth_* child_living_*  child_notliving_*   child_stillborn_*  child_alive_died_24_*  child_alive_died_1_f child_alive_died_2_f child_alive_died_3_f child_alive_died_4_f child_alive_died_5_f child_alive_died_6_f, has (type numeric)
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
	keep if dontknows >= .5 & observations >= 20
	gsort dontknows 
	cap export excel using "$PathTables/responses.xlsx", sheet("Don't knows - num") sheetreplace firstrow(varlabels)
	cap drop mo_* ma_* m9_*
restore
	
*************************************************************** 
//Percentage of Refused to answer in each variable where its applicable
***************************************************************

preserve
renpfix R_mor_  //Removing R_mor_ otherwise variable name length is exceeding 
ds marital_*  a7_pregnant_* last_5_years_pregnant_* last_5_years_preg_oth_* child_living_*  child_notliving_*   child_stillborn_*  child_alive_died_24_*  child_alive_died_1_f child_alive_died_2_f child_alive_died_3_f child_alive_died_4_f child_alive_died_5_f child_alive_died_6_f a4_hhmember_gender_*, has (type numeric)
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
	cap export excel using "$PathTables/responses.xlsx" if refusals != ., sheet("Refusals - num") sheetreplace firstrow(varlabels)
    label variable _j "Variable"
	drop id
	replace refusals = 0 if refusals == .
global Variables8 _j refusals observations
texsave $Variables8 using "$PathTables/refusals.tex", ///
        title("Refusals") replace varlabels frag location(htbp) 
restore


*************************************************************** 
//Percentage of Others in each variable where its applicable
***************************************************************

preserve
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
	cap export excel using "$PathTables/responses.xlsx" if others != ., sheet("Others") sheetreplace firstrow(varlabels)
    label variable _j "Variable"
	drop id
	replace others = 0 if others == .
global Variables9 _j others observations
texsave $Variables9 using "$PathTables/others.tex", ///
        title("% of Others marked in questions") replace varlabels frag location(htbp) 

restore


************************************************************************************************************** 
//Cases of Others in those variables which were multiple select type so they weren't included in previous loop
***************************************************************************************************************

preserve
ds R_mor_cause_death_sc__77_* R_mor_cause_death__77_* R_mor_reason_no_jjm__77 R_mor_reason_yes_jjm__77 R_mor_change_reason_prim__77 R_mor_change_reason_sec__77, has (type numeric)
foreach var of varlist `r(varlist)' {
list `var' if `var' == 1
gen _`var' = 1 if `var' == 1
}
collapse (sum) _*
export excel using "$PathTables/responses.xlsx", sheet("Multiple_choice_others") sheetreplace firstrow(varlabels)
restore





/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 4 - WOMEN AND CHILD RELATED ESTIMATES
-----------------------------------------------------------------------------------------------------------------------------------------*/

//Calculations related to women child bearing age	
destring R_mor_women_child_bear_count_f, replace
rename R_mor_village village

//To do-
//ADD r_cen variable 
*R_mor_child_stillborn_oth_1 R_mor_child_stillborn_1_f R_mor_child_stillborn_2_f R_mor_child_stillborn_3_f R_mor_child_stillborn_4_f R_mor_child_stillborn_5_f R_mor_child_stillborn_6_f
//insert a check for if these values are coming even if selected "No"


********************************************************************************************************************************************
//VILLAGE LEVEL STATS
********************************************************************************************************************************************


preserve
**Number of total child living with the mother child

egen temp_group = group(unique_id_num)
egen total_childlivingnum = rowtotal(R_mor_child_living_num_*)
drop temp_group
br village unique_id_num R_mor_child_living_num_* total_childlivingnum if total_childlivingnum != 0


**Number of total alive child but not living with the mother 

egen temp_group = group(unique_id_num)
egen total_notlivingchild = rowtotal(R_mor_child_notliving_num_*)
drop temp_group
br village unique_id_num R_mor_child_notliving_num_* total_notlivingchild if total_notlivingchild != 0

**Number of total stillborn child
egen temp_group = group(unique_id_num)
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group
br village unique_id_num R_mor_child_stillborn_num_* total_stillborn if total_stillborn != 0


**Number of total child died under 24 hours
 
egen temp_group = group(unique_id_num)
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
egen total_last5preg_women = rowtotal(R_mor_last_5_years_pregnant_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* total_last5preg_women if total_last5preg_women != 0


*Number of women currently pregnant //search if there are more variables 

egen temp_group = group(unique_id_num)
egen total_currently_preg = rowtotal(R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12 )
drop temp_group
br village unique_id_num R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12  total_currently_preg if total_currently_preg != 0


**Number of women who have not been pregnant in last 5 years

ds R_mor_last_5_years_pregnant_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
}
egen temp_group = group(unique_id_num)
egen total_notlast5preg_women = rowtotal(R_mor_last_5_years_pregnant_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* total_notlast5preg_women if total_notlast5preg_women != 0
br village R_mor_submissiondate unique_id_num R_mor_enum_name_f R_mor_child_stillborn_num_* total_stillborn  R_mor_child_died_num_* total_childdiedless24 total_childdiedmore24 if total_stillborn != 0 | total_childdiedless24 !=0 | total_childdiedmore24 != 0

collapse (sum) R_mor_women_child_bear_count_f total_last5preg_women total_notlast5preg_women total_currently_preg total_stillborn total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24, by (village)
egen total_births = rowtotal(total_childlivingnum total_notlivingchild)
egen total_deaths = rowtotal(total_stillborn total_childdiedless24 total_childdiedmore24)
label variable total_births "Total Births in the village"
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
global Variables10 village total_last5preg_women total_notlast5preg_women total_currently_preg  total_childlivingnum total_notlivingchild total_births total_stillborn total_childdiedless24 total_childdiedmore24 total_deaths
texsave $Variables10 using "$PathTables/WC_table_village.tex", ///
        title("Village level stats for pregnancy and child deaths") replace varlabels frag location(htbp) 

export excel village R_mor_women_child_bear_count_f total_last5preg_women total_notlast5preg_women total_currently_preg  total_childlivingnum total_notlivingchild total_births total_stillborn total_childdiedless24 total_childdiedmore24 total_deaths  using "$PathTables/Mortality_quality.xlsx", sheet("last_5_preg") sheetreplace firstrow(varlabels)

restore



********************************************************************************************************************************************
//HOUSEHOLD LEVEL ESTIMATES
********************************************************************************************************************************************

cap drop total_childlivingnum total_notlivingchild total_stillborn total_childdiedless24 total_childdiedmore24 total_last5preg_women total_currently_preg screened_out screened_in HH_available HH_locked HH_not_3rdavailable total

preserve

**Assigning 1 to each unqiue id to calculate total number of hosueholds"
bys unique_id_num: gen total = 1

**Number of total child living with the mother child

egen temp_group = group(unique_id_num)
egen total_childlivingnum = rowtotal(R_mor_child_living_num_*)
drop temp_group
br village unique_id_num R_mor_child_living_num_* total_childlivingnum if total_childlivingnum != 0
gen HH_with_childliving = 1 if total_childlivingnum != 0


**Number of total alive child but not living with the mother 

egen temp_group = group(unique_id_num)
egen total_notlivingchild = rowtotal(R_mor_child_notliving_num_*)
drop temp_group
br village unique_id_num R_mor_child_notliving_num_* total_notlivingchild if total_notlivingchild != 0
gen HH_with_notlivingchild = 1 if total_notlivingchild != 0

**Number of total stillborn child
egen temp_group = group(unique_id_num)
egen total_stillborn = rowtotal(R_mor_child_stillborn_num_*)
drop temp_group
br village unique_id_num R_mor_child_stillborn_num_* total_stillborn if total_stillborn != 0
gen HH_with_stillborn = 1 if total_stillborn != 0


**Number of total child died under 24 hours
 
egen temp_group = group(unique_id_num)
local filtered_vars
foreach var of varlist R_mor_child_died_num_* {
    if !regexm("`var'", "R_mor_child_died_num_more24_") local filtered_vars `filtered_vars' `var'
}
egen total_childdiedless24 = rowtotal(`filtered_vars')
drop temp_group
br village unique_id_num R_mor_child_died_num_* total_childdiedless24 if total_childdiedless24!= 0
gen HH_with_childdiedless24 = 1 if total_childdiedless24 != 0
 
 
**Number of total child died after 24 hours and till the age of 5 years
   
egen temp_group = group(unique_id_num)
egen total_childdiedmore24 = rowtotal(R_mor_child_died_num_more24_*)
drop temp_group
br village unique_id_num R_mor_child_died_num_more24_* total_childdiedmore24 if total_childdiedmore24 != 0
gen HH_with_childdiedmore24 = 1 if total_childdiedmore24 != 0
  

**Number of women who have been pregnant in last 5 years

egen temp_group = group(unique_id_num)
egen total_last5preg_women = rowtotal(R_mor_last_5_years_pregnant_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* total_last5preg_women if total_last5preg_women != 0
gen HH_with_last5preg_women = 1 if total_last5preg_women != 0


*Number of women currently pregnant //search if there are more variables 

egen temp_group = group(unique_id_num)
egen total_currently_preg = rowtotal(R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12 )
drop temp_group
br village unique_id_num R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12  total_currently_preg if total_currently_preg != 0
gen HH_with_currentpreg = 1 if total_currently_preg != 0


**Number of women who have not been pregnant in last 5 years

ds R_mor_last_5_years_pregnant_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 1
replace `var' = 1 if `var' == 0
}
egen temp_group = group(unique_id_num)
egen total_notlast5preg_women = rowtotal(R_mor_last_5_years_pregnant_*)
drop temp_group
br village unique_id_num R_mor_last_5_years_pregnant_* total_notlast5preg_women if total_notlast5preg_women != 0
gen HH_with_notlast5preg_women = 1 if total_notlast5preg_women != 1

collapse (sum) total HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women R_mor_women_child_bear_count_f, by (village)
gen HH_with_eligwomen = 1 if R_mor_women_child_bear_count_f != 0 & R_mor_women_child_bear_count_f != .
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
global Variables11 village total HH_with_eligwomen HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24 
texsave $Variables11 using "$PathTables/WC_table_HHlevel.tex", ///
        title("Village wise HH level stats for pregnancy and child deaths") replace varlabels frag location(htbp) 
export excel village total HH_with_eligwomen HH_with_last5preg_women HH_with_currentpreg HH_with_notlast5preg_women HH_with_childliving HH_with_notlivingchild HH_with_stillborn HH_with_childdiedless24 HH_with_childdiedmore24  using "$PathTables/Mortality_quality.xlsx", sheet("HH_level") sheetreplace firstrow(varlabels)
restore




/*--------------------------------------------------------------------------------------------------------------------------------------
                                              SECTION 5 - AVAILABILITY STATUS ESTIMATES
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
bys unique_id_num: gen total = 1

collapse (sum) total HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented screened_out screened_in, by (village)
label variable total "Total households present"
label variable HH_available "Total no. of available households"
label variable HH_locked "Family has left the house permanently"
label variable HH_not_3rdavailable "HH not available even after 3rd revisit"
label variable R_mor_consent "Available HHs who consented for the survey"
label variable notconsented "Available HHs who did not consent for the survey"
label variable screened_out "Total no. of households which were screened-out in census"
label variable screened_in "Total no. of households which were screened-in in census"
global Variables12 village total HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented  screened_out screened_in 
texsave $Variables12 using "$PathTables/HH_availability_status.tex", ///
        title("Households Availability status") replace varlabels frag location(htbp) 
export excel village total HH_available  HH_locked HH_not_3rdavailable R_mor_consent notconsented  screened_out screened_in using "$PathTables/Mortality_quality.xlsx", sheet("HH_availability_status") sheetreplace firstrow(varlabels)


********************************************************************************************************************************************
//Percentages
********************************************************************************************************************************************

gen consented_perc = (R_mor_consent/HH_available)*100
gen HH_available_perc = (HH_available/total)*100
egen combined_unavail = rowtotal(HH_locked HH_not_3rdavailable)
gen HH_unavail_perc = (combined_unavail/total)*100
gen screened_out_perc = (screened_out/total)*100
gen screened_in_perc = (screened_in/ total)*100
gen not_consent_perc = (notconsented/HH_available)*100
local perc consented_perc HH_available_perc HH_unavail_perc screened_out_perc screened_in_perc  not_consent_perc
foreach x of local perc{
   gen `x'_rd = round(`x', 0.1)
}   
label variable consented_perc "% of available HHs who consented for the survey"
label variable HH_available_perc "% of available households"
label variable HH_unavail_perc "% of unavailable households(combined locked +3rd revisit)"
label variable screened_out_perc "% of households which were screened-out in census)"
label variable screened_in_perc "% of households which were screened-in in census)"
label variable not_consent_perc "% of available HHs who did not consent for the survey"
global Variables13 village HH_available_perc HH_unavail_perc consented_perc not_consent_perc  screened_out_perc screened_in_perc 
texsave $Variables13 using "$PathTables/Perc_HH_availability_status.tex", ///
        title("Percenatges of Households Availability status") replace varlabels frag location(htbp) 
export excel village HH_available_perc HH_unavail_perc consented_perc not_consent_perc  screened_out_perc screened_in_perc  using "$PathTables/Mortality_quality.xlsx", sheet("percentages") sheetreplace firstrow(varlabels)
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

*If changed, what was the previous and current source
preserve
keep if R_mor_change_primary_source == 1
gen Yes_change = 1 if R_mor_change_primary_source == 1
bys R_mor_previous_primary: gen prev_prim = 1
bys R_mor_a12_water_source_prim: gen water = 1
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


**JJM tap
drop total
bys village R_mor_a18_jjm_drinking: gen jjm = _N
bys village: gen total_HHs = _N

preserve
collapse jjm total_HHs , by (village R_mor_a18_jjm_drinking)
drop if R_mor_a18_jjm_drinking == .
label variable jjm "Yes/No total observations"
label variable R_mor_a18_jjm_drinking "Use JJM for drinking"
label variable total_HHs "Total households"
export excel village R_mor_a18_jjm_drinking jjm total_HHs using "$PathTables/Mortality_quality.xlsx", sheet("JJM") sheetreplace firstrow(varlabels)
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
	over(village) bar(1, color(blue)) bar(2, color(red)) bar(3, color(green)) ///
	ylabel(#10) ytitle("Reasons for using JJM") legend(on) ///
	title("Reasons for using JJM in Gopi Kankubadi and Nathma") ///
	subtitle("Comparison of frequency of different reasons") ///
	graphregion(color(white)) plotregion(color(white)) ///
	legend(size(2)) ///
	legend(label(1 "JJM is not broken and does supply water" color(blue)) ///
	       label(2 "JJM tastes good" color(red)) ///
	       label(3 "JJM gives adequate water" color(green)) ///
	       label(4 "JJM gives water regularly" color(yellow)) ///
	       label(5 "JJM supplies high quality water which is suitable for drinking" color(purple)) ///
	       label(6 "JJM safer to drink" color(orange)) ///
	       label(7 "JJM is not muddy or smelly" color(pink)) ///
	       label(8 "JJM is easily accessible" color(brown)) ///
	       label(9 "Other" color(gray)))	
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



/*--------------------------------------------------------------------------------------------------------------------------------------
                                                      Still in working, please ignore 
-----------------------------------------------------------------------------------------------------------------------------------------*/


local i = 1
local R_mor_child_living_num R_mor_child_living_num_* 
foreach x of local living_child {
	list `x' if R_mor_child_living_num_`i' != .
	list `x' if  R_mor_child_living_num_oth_`i' != .
    local ++i
}


local i = 1
local child_notliving_num  child_notliving_num_1_f child_notliving_num_2_f child_notliving_num_3_f  
foreach x of  local child_notliving_num {
	list child_notliving_num_`i'_f if child_notliving_num_`i'_f != .
    local ++i
}

local i = 1
local child_stillborn_num child_stillborn_num_1_f child_stillborn_num_2_f child_stillborn_num_3_f child_stillborn_num_4_f
foreach x of  local child_stillborn_num{
	list child_stillborn_num_`i'_f if child_stillborn_num_`i'_f != .
    local ++i
}


local i = 1
local child_died_num child_died_num_1_f child_died_num_2_f child_died_num_3_f child_died_num_4_f
foreach x of local child_died_num{
  list child_died_num_`i'_f if child_died_num_`i'_f != .
  local ++i 
}

local i = 1
local child_died_num_more24 child_died_num_more24_1_f child_died_num_more24_2_f child_died_num_more24_3_f child_died_num_more24_4_f
foreach x of local child_died_num_more24{
  list child_died_num_more24_`i'_f if child_died_num_more24_`i'_f != .
  local ++i 
}


********************************************************************************************************************************************
// CHECKS FOR DATA ENTRY ERRORS IN WOMEN AND CHILD DEATH SECTION
********************************************************************************************************************************************
local living R_mor_child_living_oth_1 R_mor_child_living_oth_2 R_mor_child_living_1_f R_mor_child_living_2_f R_mor_child_living_3_f R_mor_child_living_4_f R_mor_child_living_5_f R_mor_child_living_6_f
local living_num R_mor_child_living_num_oth_1 R_mor_child_living_num_oth_2 R_mor_child_living_num_1_f R_mor_child_living_num_2_f R_mor_child_living_num_3_f R_mor_child_living_num_4_f R_mor_child_living_num_5_f R_mor_child_living_num_6_f
foreach var of local living{
   list `var' if `var' == 1
   foreach i of local living_num{
       list `i' `var' if `i' == 0 & `var' == 1
	   
	}
}	

