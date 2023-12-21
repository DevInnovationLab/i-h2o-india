global PathTables "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
global PathGraphs "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\New folder (2)"


tostring R_mor_village_name, gen (R_mor_village)
replace R_mor_village = "Gopi Kankubadi" if R_mor_village == "30701"
replace R_mor_village = "Nathma" if R_mor_village == "50501"
replace R_mor_village =  R_mor_r_cen_village_name_str if R_mor_village == "."


**Insert fuzzy matching duplicates too**
**Link it with the J-PAL tracker***
****Put more question specific checks***
****Insert graphs****8
***aggregate village level stats and enum stats****
*****table on overall progress****
****No of households********


//creating combined enum name
clonevar enum_name_f = R_mor_enum_name_label
replace enum_name_f = R_mor_enum_name_label_sc if enum_name_f == ""

***Checking if any IDs are there which are sent before the survey start date or before 9 am on 12th dec"
	gen Mor_day = day(dofc(R_mor_starttime))
	gen Mor_month_num = month(dofc(R_mor_starttime))
	list if (Mor_day<12 & Mor_month_num<12)	
	 gen submission_date = dofc(R_mor_submissiondate)
	 format submission_date %td
	 gen enddate = dofc(R_mor_endtime)
	 format enddate %td
	 gen startdate = dofc(R_mor_starttime)
	 format startdate %td
br R_mor_starttime M_starthour M_startmin unique_id_num if M_starthour < 9 & submission_date == date("12/12/2023", "DMY")

//cases where startdate > enddate
list unique_id_num R_mor_village enum_name_f if startdate>enddate


//cases where starttime is greater or equal to endtime if startdate and enddaate are same
gen double cstart = hh(R_mor_starttime)*3600 + mm(R_mor_starttime)*60
gen double cend = hh(R_mor_endtime)*3600 + mm(R_mor_endtime)*60
list unique_id_num R_mor_village enum_name_f if cstart>cend & (startdate == enddate)
list unique_id_num R_mor_village enum_name_f if cstart==cend & (startdate == enddate)

***submiison range

//dropped the ID since it was sent during training
drop if unique_id_num == 77519001 & R_mor_key == "uuid:919be1f7-875d-49bd-be0c-bb3a3ce25171" & R_mor_village == "-77"	
	
	

**Duplicate Unique IDs*** (clarify with the fiedl team) (//Ask Astha how did she deal with this case to keep it uniform)
bysort unique_id_num: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id_num if dup_HHID > 0
br a1_resp_name_f a2_hhmember_count_f a3_hhmember_name_1_f namefromearlier_2_f namefromearlier_3_f a3_hhmember_name_4_f namefromearlier_5_f namefromearlier_6_f a3_hhmember_name_7_f namefromearlier_8_f name_pc_earlier_1_f name_pc_earlier_2_f if unique_id_num ==  30701503009
export excel unique_id_num enum_name_f R_mor_village R_mor_r_cen_a1_resp_name R_mor_a1_resp_name a2_hhmember_count_f a3_hhmember_name_1_f namefromearlier_2_f namefromearlier_3_f a3_hhmember_name_4_f namefromearlier_5_f namefromearlier_6_f a3_hhmember_name_7_f namefromearlier_8_f name_pc_earlier_1_f name_pc_earlier_2_f  if dup_HHID > 0  using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(duplicates) sheetreplace

	
preserve
drop if unique_id_num_Unique == 1	
***Check the kind of duplicates that are present***
restore	


//PRODUCTIVITY

 
*install the following packages*
ssc install labutil
ssc install fre
fre submission_date
gen T = string(submission_date, "%td") 
labmask submission_date, values(T) 

//Date wise surveys per day//
qui bys submission_date: gen daily_total = _N

//export this graph in everything doc (export table for the same)
graph bar daily_total, over(submission_date, label(labsize(vsmall) angle(45))) ///
	graphregion(c(white)) xsize(7) ylab(0(20)200, labsize(medsmall) angle(0)) ///
	ytitle("Daily total surveys") bar(1, fc(eltblue%80))
	graph export "$PathGraphs/Surveys_per_day.png", replace
	
* daily average productivity (//output this in overleaf)
egen tag = tag(submission_date)
sum daily_total if tag
gen daily_avg = r(mean) // line 1
sum daily_total, d
gen daily_min = r(min) // line 2
gen daily_max = r(max) // line 3

 
**ENUM WISE CHECKS***

* List all the villages that are not "XY" and fall outside the specified date range
list enum_name_f village_name_f if village_name_f!= 30701 & (startdate > date("11/12/2023", "DMY") & enddate < date("17/12/2023", "DMY")) & village_name_f !=.
//automate this (make a table including villages and dates) //add it in the overleaf 
//if condition needs to be changed daily
cap export excel enum_name_f village_name_f startdate enddate if village_name_f!= 30701 & (startdate > date("11/12/2023", "DMY") & enddate < date("17/12/2023", "DMY")) & village_name_f !=. using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(Wrong_Village_input) sheetreplace


*output by date and enum
* enumerator level productivity
drop tag
egen tag = tag(enum_name_f submission_date)
egen days_worked = total(tag), by(enum_name_f)
bys enum_name_f: gen total_surveys_done = _N

gen daily_avg_enum = round(total_surveys_done/days_worked, .01) // line 4

// average productivity per day by surveyor:
tabdisp enum_name_f, c(days_worked total_surveys_done daily_avg_enum) format(%9.2f) center
preserve
collapse days_worked total_surveys_done daily_avg_enum, by(enum_name_f submission_date)
export excel enum_name_f submission_date days_worked total_surveys_done daily_avg_enum using "$PathTables/Mortality_tables.xlsx", sheet("summary_days") sheetreplace firstrow(varlabels)
restore

graph bar daily_avg_enum, over(enum_name_f, sort(1) lab(labsize(vsmall) angle(45))) ///
	graphregion(c(white)) xsize(8) ytitle("Average surveys per day") ///
	bar(1, fc(ebblue%50) lc(ebblue))
	
	graph export "$PathGraphs/average_daily_surveys.png", replace

//those enumerators whose productivity is either very less or very high	
sum daily_avg_enum if tag, d
qui gen sds = (daily_avg_enum - r(mean))/r(sd)
sum daily_avg_enum if tag
gen mean_avg_enum= r(mean)
ssc install extremes
extremes daily_avg_enum, iqr(1.5)  

list enum_name_f daily_avg_enum if (abs(sds) > 2 & daily_avg_enum != .), abbr(24) //calculate a percentile field 
preserve
collapse days_worked mean_avg_enum total_surveys_done daily_avg_enum sds, by(enum_name_f submission_date)
export excel enum_name_f submission_date days_worked total_surveys_done daily_avg_enum using "$PathTables/Mortality_tables.xlsx" if abs(sds)>2, sheet("outlier_productivity") sheetreplace firstrow(varlabels)
restore

//What is the action and what are you exp

* date-wise
bys submission_date enum_name_f: gen daywise_productivity = _N //added this to get enum"s that date's productivyt 
preserve
collapse daywise_productivity, by(enum_name_f submission_date) 
export excel enum_name_f submission_date daywise_productivity using "$PathTables/Mortality_tables.xlsx", sheet("per_day_productivity") sheetreplace firstrow(varlabels)
restore

* dummy for male and female enum
*1 stands for male and 0 stands for female
gen enum_gender = 1 if enum_name_f == 503 | enum_name_f == 521 | enum_name_f == 505 
replace enum_gender = 0 if enum_name_f == 519 | enum_name_f == 510


* gender-wise
egen tag_gender = tag(enum_gender submission_date)
egen days_gender = total(tag_gender) , by(enum_gender)
bysort enum_gender: gen gender_wise_total= _N 
gen gender_daily_avg = round(gender_wise_total/days_gender, .01)

tabdisp enum_gender, c(days_gender gender_wise_total gender_daily_avg) format(%9.2f) center
preserve
collapse days_gender gender_wise_total gender_daily_avg, by(enum_gender)
export excel enum_gender days_gender gender_wise_total gender_daily_avg using "$PathTables/Mortality_tables.xlsx", sheet("gender_productivity") sheetreplace firstrow(varlabels)
restore

**avialblilty is diff for men and women (at the end day)

//Put duration here once you get it
*ttest gender_daily_avg, by(enum_gender)
*graph twoway (hist gender_daily_avg if enum_gender == 1, fc(ebblue%50) lc(ebblue)) ///
	*(hist gender_daily_avg if enum_gender == 0, fc(orange_red%50) lc(orange_red) ///
	*graphregion(c(white)) legend(order(1 "Male" 2 "Female")) xsize(6.5) ///
	*note("ttest difference: 11.12***"))
	*graph export "$PathGraphs/gender_duration.png", replace


cap drop sds
//Outliers
ds  hh_repeat_code_f a2_hhmember_count_f a6_hhmember_age_* a7_pregnant_month_* a7_pregnant_leave_days_*  a7_pregnant_leave_months_* child_living_num_* child_notliving_num_* child_stillborn_num_* child_died_num_* child_died_num_more24_* 
	foreach var of varlist `r(varlist)' {

		qui sum `var' if `var' != 999 & `var' != 98, d   

        gen sds = (`var' - r(mean))/(r(sd))
		list sds unique_id_num enum_name_f `var' if abs(sds) > 3 & !missing(`var') & !missing(sds) 
		cap export excel enum_name_f  block_name_f village_name_f a1_resp_name `var' if abs(sds) > 2 & !missing(`var') & (`var' != 999 | `var' != 98) using "$PathTables/outliers.xlsx", firstrow(varlabels) sheet(`var') sheetreplace  
		drop sds
	}
 cap drop sds   //A:added because sds of the last variable running is not getting dropped for me 


//To find any cases of child deaths 
 
local i = 1
local child_living_num child_living_num_1_f child_living_num_2_f child_living_num_3_f child_living_num_4_f  
foreach x of  local child_living_num {
	list child_living_num_`i'_f if child_living_num_`i'_f != .
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


//This command will start working when the issue of do template is fixed

*graph hbox invalid varlist child_living_num_2_f a6_hhmember_age_1_f ///
    *legend(order(1 "Children living with them" ///	
	*2 "HH member age"))
	*pos(12) size(small)) xsize(6.5) graphregion(c(white)) ///
	*title("{bf:Outliers}", size(medsmall) c(black))
	

* Percentage of Don't knows in each variable where its applicable
ssc install findname

ds marital_1_f marital_2_f marital_3_f marital_4_f marital_5_f marital_6_f marital_7_f marital_8_f  a7_pregnant_1_f a7_pregnant_2_f a7_pregnant_3_f a7_pregnant_4_f a7_pregnant_5_f a7_pregnant_6_f a7_pregnant_7_f a7_pregnant_8_f last_5_years_pregnant_oth_1_f child_living_oth_1_f child_notliving_oth_1_f child_stillborn_oth_1_f child_alive_died_24_oth_1_f child_alive_died_oth_1_f
foreach var of varlist `r(varlist)' {
	
	count if `var' == 999
	gen n9_`var' = r(N)
	sum `var'
	gen na_`var' = r(N)
	gen no_`var' = n9_`var' / na_`var'
	
	label var no_`var' "Don't knows"
}

	findname, all(@==0) varlabeltext(Don*) // finds variables == 0 with label w/ "Don"
	drop `r(varlist)'
	
preserve
	collapse no_* na_*
	gen id = _n
	reshape long no_ na_, i(id) string
	rename no_ dontknows
	rename na_ observations
	sum dontknows, det
	sort dontknows observations
	drop if dontknows == .
	keep if dontknows >= .5 & observations >= 20
	gsort dontknows 
	cap export excel using "$PathTables/responses.xlsx", sheet("Don't knows - num") sheetreplace firstrow(varlabels)

restore

	drop no_* na_* n9_*

// percentage of Refuse to answer in each variable


ds marital_1_f marital_2_f marital_3_f marital_4_f marital_5_f marital_6_f marital_7_f marital_8_f  a7_pregnant_1_f a7_pregnant_2_f a7_pregnant_3_f a7_pregnant_4_f a7_pregnant_5_f a7_pregnant_6_f a7_pregnant_7_f a7_pregnant_8_f last_5_years_pregnant_oth_1_f child_living_oth_1_f child_notliving_oth_1_f child_stillborn_oth_1_f child_alive_died_24_oth_1_f child_alive_died_oth_1_f a4_hhmember_gender_1_f a4_hhmember_gender_2_f a4_hhmember_gender_3_f a4_hhmember_gender_4_f a4_hhmember_gender_5_f a4_hhmember_gender_6_f a4_hhmember_gender_7_f a4_hhmember_gender_8_f
foreach var of varlist `r(varlist)' {

	count if `var' == 98
	gen n9_`var' = r(N)
	sum `var'
	gen na_`var' = r(N)
	gen no_`var' = n9_`var' / na_`var'
	
	label var no_`var' "Refuse to answer"
	
}

	findname, all(@==0) varlabeltext(Ref*)
	drop `r(varlist)'
	
preserve
	collapse no_* na_*
	gen id = _n
	reshape long no_ na_, i(id) string
	rename no_ refusals
	rename na_ observations
	sum refusals, det
	
	cap export excel using "$PathTables/responses.xlsx" if refusals != ., sheet("Refusals - num") sheetreplace firstrow(varlabels)

restore

// percentage of others  (//export others see if theres a pattern if there something  numeric
ds a12_water_source_prim_f previous_primary_f a5_hhmember_relation_*  previous_secondary_f 
foreach var of varlist `r(varlist)' {

	count if `var' == -77
	gen n9_`var' = r(N)
	sum `var'
	gen na_`var' = r(N)
	gen no_`var' = n9_`var' / na_`var'
	
	label var no_`var' "Others"
	
}

	findname, all(@==0) varlabeltext(Oth*)
	drop `r(varlist)'
	
preserve
	collapse no_* na_*
	gen id = _n
	reshape long no_ na_, i(id) string
	rename no_ refusals
	rename na_ observations
	sum refusals, det
	
	cap export excel using "$PathTables/responses.xlsx" if refusals != ., sheet("Others") sheetreplace firstrow(varlabels)

restore

//availabililty status
gen HH_available=1 if R_mor_resp_available == 1
gen HH_locked =1 if R_mor_resp_available == 2
gen HH_not_3rdavailable=1 if R_mor_resp_available == 6
gen total= 1 

//Calculations related to women child bearing age	
destring R_mor_women_child_bear_count_f, replace

rename R_mor_village village


//VILLAGE WISE STATS

preserve
*R_mor_child_stillborn_oth_1 R_mor_child_stillborn_1_f R_mor_child_stillborn_2_f R_mor_child_stillborn_3_f R_mor_child_stillborn_4_f R_mor_child_stillborn_5_f R_mor_child_stillborn_6_f
//insert a check for if these values are coming even if selected "No"

**Number of total stillborn child
foreach i in R_mor_child_stillborn_num_oth_1 R_mor_child_stillborn_num_1_f R_mor_child_stillborn_num_2_f R_mor_child_stillborn_num_3_f R_mor_child_stillborn_num_4_f R_mor_child_stillborn_num_5_f R_mor_child_stillborn_num_6_f R_mor_child_stillborn_num_1_f R_mor_child_stillborn_num_2_f R_mor_child_stillborn_num_3_f R_mor_child_stillborn_num_4_f R_mor_child_stillborn_num_5_f R_mor_child_stillborn_num_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_stillborn = R_mor_child_stillborn_num_oth_1 + R_mor_child_stillborn_num_1_f + R_mor_child_stillborn_num_2_f + R_mor_child_stillborn_num_3_f + R_mor_child_stillborn_num_4_f + R_mor_child_stillborn_num_5_f + R_mor_child_stillborn_num_6_f + R_mor_child_stillborn_num_1_f + R_mor_child_stillborn_num_2_f + R_mor_child_stillborn_num_3_f + R_mor_child_stillborn_num_4_f + R_mor_child_stillborn_num_5_f + R_mor_child_stillborn_num_6_f


**Number of total child living with the mother child

foreach i in R_mor_child_living_num_oth_1 R_mor_child_living_num_1_f R_mor_child_living_num_2_f R_mor_child_living_num_3_f R_mor_child_living_num_4_f R_mor_child_living_num_5_f R_mor_child_living_num_6_f{
replace `i' = 0 if `i' == .
}

bys unique_id_num: gen total_childlivingnum = R_mor_child_living_num_oth_1 + R_mor_child_living_num_1_f + R_mor_child_living_num_2_f + R_mor_child_living_num_3_f + R_mor_child_living_num_4_f + R_mor_child_living_num_5_f + R_mor_child_living_num_6_f

**Number of total alive child but not living with the mother 

foreach i in R_mor_child_notliving_num_oth_1 R_mor_child_notliving_num_1_f R_mor_child_notliving_num_2_f R_mor_child_notliving_num_3_f R_mor_child_notliving_num_4_f R_mor_child_notliving_num_5_f R_mor_child_notliving_num_6_f{
replace `i' = 0 if `i' == .
}

bys unique_id_num: gen total_notlivingchild = R_mor_child_notliving_num_oth_1 + R_mor_child_notliving_num_1_f + R_mor_child_notliving_num_2_f + R_mor_child_notliving_num_3_f + R_mor_child_notliving_num_4_f + R_mor_child_notliving_num_5_f + R_mor_child_notliving_num_6_f

**Number of total child died under 24 hours

foreach i in R_mor_child_died_num_oth_1 R_mor_child_died_num_1_f R_mor_child_died_num_2_f R_mor_child_died_num_3_f R_mor_child_died_num_4_f R_mor_child_died_num_5_f R_mor_child_died_num_6_f{
replace `i' = 0 if `i' == .
}

bys unique_id_num: gen total_childdiedless24 = R_mor_child_died_num_oth_1 + R_mor_child_died_num_1_f + R_mor_child_died_num_2_f + R_mor_child_died_num_3_f + R_mor_child_died_num_4_f + R_mor_child_died_num_5_f + R_mor_child_died_num_6_f
   
**Number of total child died after 24 hours and till the age of 5 years
   
foreach i in R_mor_child_died_num_more24_1_f R_mor_child_died_num_more24_2_f R_mor_child_died_num_more24_3_f R_mor_child_died_num_more24_4_f R_mor_child_died_num_more24_5_f R_mor_child_died_num_more24_6_f{
replace `i' = 0 if `i' == .
} 
  
bys unique_id_num: gen total_childdiedmore24 = R_mor_child_died_num_more24_1_f + R_mor_child_died_num_more24_2_f + R_mor_child_died_num_more24_3_f + R_mor_child_died_num_more24_4_f + R_mor_child_died_num_more24_5_f + R_mor_child_died_num_more24_6_f
   

**Number of women who have been pregnant in last 5 years

foreach i in R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_last5preg_women = R_mor_last_5_years_pregnant_1_f + R_mor_last_5_years_pregnant_2_f +  R_mor_last_5_years_pregnant_3_f +  R_mor_last_5_years_pregnant_4_f +  R_mor_last_5_years_pregnant_5_f +  R_mor_last_5_years_pregnant_6_f


collapse (sum) total_last5preg_women R_mor_women_child_bear_count_f total_stillborn total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24, by (village)
rename R_mor_women_child_bear_count_f Total_eligible_women_found
export excel village Total_eligible_women_found total_last5preg_women total_stillborn total_childlivingnum total_notlivingchild total_childdiedless24 total_childdiedmore24  using "$PathTables/Mortality_quality.xlsx", sheet("last_5_preg") sheetreplace firstrow(variables)
restore

**Number of women who have not been pregnant in last 5 years

preserve
foreach i in R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f{
replace `i' = . if `i' == 1
replace `i' = 1 if `i' == 0
replace `i' = 0 if `i' == .
}

bys unique_id_num: gen no_last5preg_women_perHH = R_mor_last_5_years_pregnant_1_f + R_mor_last_5_years_pregnant_2_f +  R_mor_last_5_years_pregnant_3_f +  R_mor_last_5_years_pregnant_4_f +  R_mor_last_5_years_pregnant_5_f +  R_mor_last_5_years_pregnant_6_f
collapse (sum) no_last5preg_women_perHH, by (village)
export excel village no_last5preg_women_perHH  using "$PathTables/Mortality_quality.xlsx", sheet("no_last_5_preg") sheetreplace firstrow(variables) 
restore

**Calculating number of screened in and screend out cases
gen screened_out = 1 if R_mor_check_scenario == 0
gen screened_in = 1 if R_mor_check_scenario == 1

*8Table below exports staus wise estimates
preserve 

*Number of women currently oregnant
foreach i in R_mor_a7_pregnant_1 R_mor_a7_pregnant_2 R_mor_a7_pregnant_3 R_mor_a7_pregnant_4 R_mor_a7_pregnant_5 R_mor_a7_pregnant_6 R_mor_a7_pregnant_7 R_mor_a7_pregnant_8 R_mor_a7_pregnant_9 R_mor_a7_pregnant_10 R_mor_a7_pregnant_11 R_mor_a7_pregnant_12{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen screenedout_currentpreg_women = R_mor_a7_pregnant_1 + R_mor_a7_pregnant_2 + R_mor_a7_pregnant_3 + R_mor_a7_pregnant_4 + R_mor_a7_pregnant_5 + R_mor_a7_pregnant_6 + R_mor_a7_pregnant_7 + R_mor_a7_pregnant_8 + R_mor_a7_pregnant_9 + R_mor_a7_pregnant_10 + R_mor_a7_pregnant_11 + R_mor_a7_pregnant_12


collapse (sum) total HH_available R_mor_consent HH_locked HH_not_3rdavailable screened_out screenedout_currentpreg_women screened_in R_mor_a2_hhmember_count, by (village)
rename R_mor_consent consented
rename R_mor_a2_hhmember_count Number_of_HH_nonscreend
export excel village total HH_available consented HH_locked HH_not_3rdavailable screened_in screened_out screenedout_currentpreg_women  Number_of_HH_nonscreend using "$PathTables/Mortality_quality.xlsx", sheet("stats") sheetreplace firstrow(variables)

//PERCENTAGES
rename R_mor_any_oth  Other_eli_females_present

gen consented_perc = (consented/HH_available)*100
gen HH_available_perc = (HH_available/total)*100
gen screened_out_perc = (screened_out/total)*100
gen screened_in_perc = (screened_in/ total)*100
gen current_preg_screened_out = (screenedout_currentpreg_women/screened_out)*100
gen Other_eli_females_perc = (Other_eli_females_present/screened_out)*100

local perc consented_perc HH_available_perc screened_out_perc screened_in_perc  current_preg_screened_out Other_eli_females_perc
foreach x of local perc{
   gen `x'_rd = round(`x', 0.1)
}   

export excel village consented_perc HH_available_perc screened_out_perc screened_in_perc current_preg_screened_out Other_eli_females_perc using "$PathTables/Mortality_quality.xlsx", sheet("percentages") sheetreplace firstrow(variables)

restore




//HOUSEHOLD WISE ESTIMATES
**Number of total stillborn child
preserve
foreach i in R_mor_child_stillborn_num_oth_1 R_mor_child_stillborn_num_1_f R_mor_child_stillborn_num_2_f R_mor_child_stillborn_num_3_f R_mor_child_stillborn_num_4_f R_mor_child_stillborn_num_5_f R_mor_child_stillborn_num_6_f R_mor_child_stillborn_num_1_f R_mor_child_stillborn_num_2_f R_mor_child_stillborn_num_3_f R_mor_child_stillborn_num_4_f R_mor_child_stillborn_num_5_f R_mor_child_stillborn_num_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_stillborn = R_mor_child_stillborn_num_oth_1 + R_mor_child_stillborn_num_1_f + R_mor_child_stillborn_num_2_f + R_mor_child_stillborn_num_3_f + R_mor_child_stillborn_num_4_f + R_mor_child_stillborn_num_5_f + R_mor_child_stillborn_num_6_f + R_mor_child_stillborn_num_1_f + R_mor_child_stillborn_num_2_f + R_mor_child_stillborn_num_3_f + R_mor_child_stillborn_num_4_f + R_mor_child_stillborn_num_5_f + R_mor_child_stillborn_num_6_f

gen HH_with_stillborn = 1 if total_stillborn != 0

**Number of total child living with the mother child

foreach i in R_mor_child_living_num_oth_1 R_mor_child_living_num_1_f R_mor_child_living_num_2_f R_mor_child_living_num_3_f R_mor_child_living_num_4_f R_mor_child_living_num_5_f R_mor_child_living_num_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_childlivingnum = R_mor_child_living_num_oth_1 + R_mor_child_living_num_1_f + R_mor_child_living_num_2_f + R_mor_child_living_num_3_f + R_mor_child_living_num_4_f + R_mor_child_living_num_5_f + R_mor_child_living_num_6_f
gen HH_with_childliving = 1 if total_childlivingnum != 0



**Number of total alive child but not living with the mother 

foreach i in R_mor_child_notliving_num_oth_1 R_mor_child_notliving_num_1_f R_mor_child_notliving_num_2_f R_mor_child_notliving_num_3_f R_mor_child_notliving_num_4_f R_mor_child_notliving_num_5_f R_mor_child_notliving_num_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_notlivingchild = R_mor_child_notliving_num_oth_1 + R_mor_child_notliving_num_1_f + R_mor_child_notliving_num_2_f + R_mor_child_notliving_num_3_f + R_mor_child_notliving_num_4_f + R_mor_child_notliving_num_5_f + R_mor_child_notliving_num_6_f
gen HH_with_notlivingchild = 1 if total_notlivingchild != 0



**Number of total child died under 24 hours

foreach i in R_mor_child_died_num_oth_1 R_mor_child_died_num_1_f R_mor_child_died_num_2_f R_mor_child_died_num_3_f R_mor_child_died_num_4_f R_mor_child_died_num_5_f R_mor_child_died_num_6_f{
replace `i' = 0 if `i' == .
}

bys unique_id_num: gen total_childdiedless24 = R_mor_child_died_num_oth_1 + R_mor_child_died_num_1_f + R_mor_child_died_num_2_f + R_mor_child_died_num_3_f + R_mor_child_died_num_4_f + R_mor_child_died_num_5_f + R_mor_child_died_num_6_f
gen HH_with_childdiedless24 = 1 if total_childdiedless24 != 0

   
**Number of total child died after 24 hours and till the age of 5 years
   
foreach i in R_mor_child_died_num_more24_1_f R_mor_child_died_num_more24_2_f R_mor_child_died_num_more24_3_f R_mor_child_died_num_more24_4_f R_mor_child_died_num_more24_5_f R_mor_child_died_num_more24_6_f{
replace `i' = 0 if `i' == .
}   
bys unique_id_num: gen total_childdiedmore24 = R_mor_child_died_num_more24_1_f + R_mor_child_died_num_more24_2_f + R_mor_child_died_num_more24_3_f + R_mor_child_died_num_more24_4_f + R_mor_child_died_num_more24_5_f + R_mor_child_died_num_more24_6_f
gen HH_with_childdiedmore24 = 1 if total_childdiedmore24 != 0
   

**Number of women who have been pregnant in last 5 years

foreach i in R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f{
replace `i' = 0 if `i' == .
}
bys unique_id_num: gen total_last5preg_women = R_mor_last_5_years_pregnant_1_f + R_mor_last_5_years_pregnant_2_f +  R_mor_last_5_years_pregnant_3_f +  R_mor_last_5_years_pregnant_4_f +  R_mor_last_5_years_pregnant_5_f +  R_mor_last_5_years_pregnant_6_f
gen HH_with_last5preg_women = 1 if total_last5preg_women != 0


collapse (sum) total HH_with_stillborn HH_with_childliving HH_with_notlivingchild HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_last5preg_women, by (village)
export excel village total HH_with_stillborn HH_with_childliving HH_with_notlivingchild HH_with_childdiedless24 HH_with_childdiedmore24 HH_with_last5preg_women  using "$PathTables/Mortality_quality.xlsx", sheet("HH_level") sheetreplace firstrow(variables)
restore


//percenatges 


**WASH SECTION***

preserve
gen water = 1 if R_mor_a12_water_source_prim != .
drop if R_mor_a12_water_source_prim == .
collapse (sum) water, by (R_mor_a12_water_source_prim  village)






   
   label variable a13_water_source_sec_1_f  "Sec-source-JJM tap"
	label variable a13_water_source_sec_2_f "Sec-source-Govt. provided community standpipe"
	label variable a13_water_source_sec_3_f "Sec-source-GP/Other community standpipe"
	label variable a13_water_source_sec_4_f "Sec-source-Manual handpump"
	label variable a13_water_source_sec_5_f "Sec-source-Covered dug well"
	label variable a13_water_source_sec_6_f "Sec-source-Uncovered dug well"
	label variable a13_water_source_sec_7_f "Sec-source-Surface water"
	label variable a13_water_source_sec_8_f "Sec-source-Private surface well"
	label variable a13_water_source_sec_9_f "Sec-source-Borewell"
	label variable a13_water_source_sec_10_f "Sec-source-tap except JJM"
	label variable a13_water_source_sec__77_f "Sec-source-other"
	

