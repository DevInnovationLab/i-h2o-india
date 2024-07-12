/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creates descriptive stats for household characteristics with merged endline & baseline dataset
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
	- "${DataFinal}0_Master_HHLevel.dta"
****** Output data/file : 
	- "${Table}DescriptiveStats_HH_characteristics.tex"
	
****** Do file to run before this do file
	- 3_X_Final_Data_Creation.do
****** Language: English
*=========================================================================*/
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey


	/*%%%%%%%%%%%%%%%%%% HH CHARACTERISTICS %%%%%%%%%%%%%%%%*/
	
********************************************************************************
*** Using Endline_Long_Indiv_analysis.dta to get the pregnancy status variable
********************************************************************************
clear 
use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear
preserve
keep comb_preg_status R_E_key unique_id
bys R_E_key: gen Num=_n
reshape wide  comb_preg_status , i(R_E_key) j(Num)
save "${DataTemp}Endline_Preg_status_wide.dta", replace
restore 

********************************************************************************
*** Opening the Dataset 
********************************************************************************
clear
use "${DataFinal}0_Master_HHLevel.dta", clear
merge 1:1 unique_id using "${DataTemp}Endline_Preg_status_wide.dta", gen(merge_desc_stats)
//875 obs matched (unmatched 40 obs are present in baseline only)

********************************************************************************
*** Generating relevant variables
********************************************************************************
drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  
//1 obs dropped


* Combined variable for Number of HH members (both BL and EL including the new members)
//changing the storage type of the no of HH members from baseline census
destring R_Cen_hh_member_names_count, gen(R_Cen_hhmember_count_new) 

egen total_hhmembers=rowtotal(R_Cen_hhmember_count_new R_E_n_hhmember_count) 
label var total_hhmembers "Total HH Members"


* Number of U5 Children
//Generating new binary variable if age of HH member is <5
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen Cen_U5child_`i' =1 if R_Cen_a6_hhmember_age_`i'<5 
}
forvalues i=1/20 { //loop for all new members in Endline Census
    destring R_E_n_fam_age`i', gen (R_E_n_fam_age`i'_num) 
	gen E_n_U5child_`i'=1 if  R_E_n_fam_age`i'_num<5
}
//Generating variable for total no of U5 children in Baseline and Endline
egen total_U5children= rowtotal(Cen_U5child_* E_n_U5child_*)
label var total_U5children "U5 Children"


* Number of pregnant women
//Generating new binary variable if HH member is pregnant 
forvalues i = 1/17 { //loop for all HH memebers in Baseline Census
	gen Cen_total_pregnant_`i'= 1 if R_Cen_a7_pregnant_`i'==1
}

// Generating variable for total no of pregnant women in Endline 
egen total_pregnant= rowtotal(comb_preg_status*)
label var total_pregnant "Pregnant Women (Endline)" 
	
	
* Number of Women of Child Bearing Age
forvalues i=1/17 { //loop for all family members in Baseline Census
	gen Cen_female_15to49_`i'=1 if R_Cen_a6_hhmember_age_`i'>=15 & R_Cen_a6_hhmember_age_`i'<=49
}
destring R_E_n_num_female_15to49, gen (R_E_n_num_female_15to49_num) //changing the storage type
egen total_CBW= rowtotal(R_E_n_num_female_15to49_num Cen_female_15to49_*)
label var total_CBW "Women of Child Bearing Age"


* Number of Other Members in the HH 
//Generating binary variable if HH member is neither CBW nor U5
forvalues i=1/17{ //loop for all HH members in Baseline
	gen Cen_noncri_members_`i'=1 if (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a4_hhmember_gender_`i'==1) | (R_Cen_a6_hhmember_age_`i'>49 & R_Cen_a4_hhmember_gender_`i'==2) | (R_Cen_a6_hhmember_age_`i'>=5 & R_Cen_a6_hhmember_age_`i'<15 & R_Cen_a4_hhmember_gender_`i'==2)
}
//Generating vairable for total no of non criteria/Other members in Baseline and Endline
destring  R_E_n_num_allmembers_h, gen (R_E_n_num_allmembers_h_num) //chnaging the storage type
egen total_noncri_members=rowtotal(Cen_noncri_members_* R_E_n_num_allmembers_h_num)
label var total_noncri_members "Other Members (non-U5/non-CBW)"

* Index of the HH Head (to ascertain which HH member is the head)
//Extracting the index from name of HH Head
gen hh_head_index =.
replace hh_head_index=R_Cen_a10_hhhead
label var hh_head_index "Household Head's index"

* Age of the HH head
gen hh_head_age = .
forval i = 1/17 { 
    replace hh_head_age = R_Cen_a6_hhmember_age_`i' if hh_head_index== `i'
}
label var hh_head_age "Age of the HH Head"

// * Whether HH head ever attended school
// gen hh_head_attend_school=.
// forval i = 1/17 {
//     replace hh_head_attend_school = R_Cen_a9_school_`i' if hh_head_index== `i'
// }
// label var hh_head_attend_school "HH head attended school"
// label define hh_head_attend_school 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
// label values hh_head_attend_school hh_head_attend_school

* Education Level of the HH Head
gen hh_head_edu = .
forval i = 1/17 {
    replace hh_head_edu = R_Cen_a9_school_level_`i' if hh_head_index== `i'
	replace hh_head_edu = 0 if R_Cen_a9_school_level_`i'==. & hh_head_index== `i'
}
label var hh_head_edu "Level of Education of HH Head"
label define hh_head_edu 0 "Never Attended School" 1 "HH head: Incomplete Pre-school" 2 "HH head: Completed Pre-school" ///
3 "Incomplete Primary Education" 4 "Completed Primary Education" ///
5 "Incomplete Secondary Education" 6 "Completed Secondary Education" ///
7 "Post-secondary Education" -98 "Refused" 999 "Don't know"
label values hh_head_edu hh_head_edu

* Age of the Respondent
gen respondent_age = .
replace respondent_age = R_Cen_a6_hhmember_age_1
// replace respondent_age=. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 
label var respondent_age "Age of the Respondent"

* Gender of the Respondent
gen respondent_gender = .
replace respondent_gender =R_Cen_a4_hhmember_gender_1
// replace respondent_gender =. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 
label var respondent_gender "Gender of the Respondent"
label define respondent_gender 1 "Male" 2 "Female" 3 "Other" 
label values respondent_gender respondent_gender

// * Whether respondent ever attended school
// gen resp_attend_school=.
// forval i = 1/17 {
//     replace resp_attend_school = R_Cen_a9_school_`i' if hh_head_index== `i'
// }
// label var resp_attend_school "Respondent attended school"
// label define resp_attend_school 1 "Yes" 0 "No" -99 "Don't know" -98 "Refused to answer"
// label values resp_attend_school resp_attend_school


* Education Level of the Respondent
gen respondent_edu = .
replace respondent_edu = R_Cen_a9_school_level_1
replace respondent_edu = 0 if R_Cen_a9_school_level_1==. //replcaing the missing values (in case respondent never attended school) with 0
// replace respondent_edu =. if unique_id=="30501107052" //coded as missing as the respondent for this unique id was not a member of the HH 
label var respondent_edu "Level of Education of Respondent"
label define respondent_edu 0 "Never Attended School" 1 "Incomplete Pre-school" 2 "Completed Pre-school" ///
3 "Incomplete Primary Education" 4 "Completed Primary Education" ///
5 "Incomplete Secondary Education" 6 "Completed Secondary Education" ///
7 "Post-secondary Education" -98 "Refused" 999 "Don't know"
label values respondent_edu respondent_edu

* Asset index
local assets R_Cen_a33_ac R_Cen_a33_bicycle R_Cen_a33_bwtv R_Cen_a33_car R_Cen_a33_cart R_Cen_a33_chair R_Cen_a33_colourtv R_Cen_a33_computer R_Cen_a33_cotbed R_Cen_a33_electricfan R_Cen_a33_electricity R_Cen_a33_fridge R_Cen_a33_internet R_Cen_a33_landline R_Cen_a33_mattress R_Cen_a33_mobile R_Cen_a33_motorcycle R_Cen_a33_pressurecooker R_Cen_a33_radiotransistor R_Cen_a33_sewingmachine R_Cen_a33_table R_Cen_a33_thresher R_Cen_a33_tractor R_Cen_a33_washingmachine R_Cen_a33_watchclock R_Cen_a33_waterpump R_Cen_labels
 foreach i in `assets' {
    replace `i'=. if `i'==-99 | `i'==-98 //if respondent didn't know or refused to answer, recoding as missing value
   }
egen asset_index=rowtotal(R_Cen_a33_*) //total of 26 assets
label var asset_index "Asset Index (total of 26 assets)"

* Asset Quintiles
egen asset_rank = rank(asset_index)

egen asset_quintile = xtile(asset_rank), nq(5)
label var asset_quintile "Asset Quintiles"
label define asset_quintile 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values asset_quintile asset_quintile

drop asset_rank //dropping the var that is not required 

* relabelling caste variable for table
// label drop R_Cen_a37_caste
label define R_Cen_a37_caste 1 "Scheduled Caste" 2 "Scheduled Tribe" 3 "Other Backward Caste" 4 "Other Caste" 999 "Don't know"
label values R_Cen_a37_caste R_Cen_a37_caste


********************************************************************************
*** Recoding the variables for use in tables 
********************************************************************************

* -98 to 98
foreach i in respondent_edu hh_head_edu /*hh_head_attend_school resp_attend_school*/ {
	replace `i'=98 if `i'==-98
}	
	
// * -99 to 99
// foreach i in  hh_head_attend_school resp_attend_school {
// 	replace `i'=99 if `i'==-99
// }	

********************************************************************************
*** Creating Dummy variables
********************************************************************************

foreach v in R_Cen_a10_hhhead_gender respondent_gender respondent_edu ///
hh_head_edu asset_quintile R_Cen_a37_caste /*resp_attend_school hh_head_attend_school*/ {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

********************************************************************************
*** Generating the table
********************************************************************************	
	
*** Labelling the variables for use in descriptive stats table
label var R_Cen_a10_hhhead_gender_1 "HH Head is Male"
label var R_Cen_a10_hhhead_gender_2 "HH Head is Female"
label var respondent_gender_1 "Respondent is Male"
label var respondent_gender_2 "Respondent is Female"
// label var hh_head_attend_school_1 "HH Head Attended School"
// label var resp_attend_school_1 "Respondent Attended school" 

*** Saving the dataset 
save "${DataTemp}Temp_HHLevel(for descriptive stats).dta", replace

*** Creation of the table
*Setting up global macros for calling variables
global HH_characteristics total_hhmembers total_CBW total_pregnant total_U5children total_noncri_members ///
R_Cen_a10_hhhead_gender_1 R_Cen_a10_hhhead_gender_2 /*hh_head_attend_school_1*/ hh_head_edu_0 hh_head_edu_2 hh_head_edu_3 hh_head_edu_4 /// 
hh_head_edu_5 hh_head_edu_6 hh_head_edu_7 hh_head_age respondent_gender_1 respondent_gender_2 /*resp_attend_school_1*/ ///
respondent_edu_0 respondent_edu_1 respondent_edu_3 respondent_edu_4 respondent_edu_5 respondent_edu_6 respondent_edu_7 ///
respondent_age asset_quintile_1 asset_quintile_2 asset_quintile_3 asset_quintile_4 asset_quintile_5 ///
R_Cen_a37_caste_1 R_Cen_a37_caste_2 R_Cen_a37_caste_3 R_Cen_a37_caste_4

*Setting up local macros (to be used for labelling the table)
local HH_characteristics "Comparing Household Profiles: Insight into Demographic Trends"
local LabelHH_characteristics "MaintableHH"
local noteHH_characteristics "Notes: (1)The table presents information on Household characteristics from Baseline and Endline Census (2) Missing value for age of household head: respondent didn't know the age of the household head (3)Asset Quintiles represent household wealth rankings(1 = lowest, 5 = highest)" 
local ScaleHH_characteristics "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in HH_characteristics { //loop for all variables in the global marco 

use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear //using the saved dataset 
	
	* Mean
	//Calculating the summary stats 
	eststo  model0: estpost summarize $`k' //Total (for all villages)
	eststo  model1: estpost summarize $`k' if Treat_V==1 //Treatment villages
	eststo  model2: estpost summarize $`k' if Treat_V==0 //Control villages
	
	* Diff 
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 339
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of p values

	* Min
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model7: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab model0 model1 model2 model3 model4 model5 model6 model7 model8 using "${Table}DescriptiveStats_`k'.tex", ///
	   replace  cell("mean (fmt(2) label(_))") ///
	   mtitles("\shortstack[c]{Total}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Total HH Members" "\multicolumn{10}{c}{\textbf{Number of Household Members}} \\ Total HH Members" ///
				   "HH Head is Male" "\hline \multicolumn{9}{c}{\textbf{Household Head Information}} \\ HH Head is Male" ///
				   "Never Attended School" "\\ \textbf{Level of Schooling} \\ Never Attended School" ///
				   "Age of the HH Head" "\\ Age of the HH Head" ///
				   "Respondent is Male" "\hline \multicolumn{9}{c}{\textbf{Respondent Information}} \\ Respondent is Male" ///
				   "Age of the Respondent" "\\ Age of the Respondent" ///
				   "Quintile 1" "\hline \multicolumn{9}{c}{\textbf{Household Level Information}} \\ \textbf{Asset Quintiles} \\ Quintile 1" ///
				   "Scheduled Caste" "\\ \textbf{Caste} \\ Scheduled Caste" /// 
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }
	
	
	
	
		/*%%%%%%%%%%%%%%%%%% GOVT TAP INFRASTRUCTURE %%%%%%%%%%%%%%%%*/
		
********************************************************************************
*** Opening the dataset
********************************************************************************

clear
use "${DataFinal}0_Master_HHLevel.dta", clear

********************************************************************************
*** Cleaning of relevant variables
********************************************************************************

* Dropping relevant obs
drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  
//1 obs dropped

* Supply schedule of JJM tap water
replace R_E_tap_supply_freq=1 if R_E_tap_supply_freq==-77 //recoding the other category into "Daily" category given that water is supplied daily but the quantity is less

* Reason that the jjm tap was not functional
//recoding the other category responses into proper categories
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" //PO didnt turn on water as he didn't get his salary
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Pump opertator Not in village"
replace R_E_tap_function_reason_4=1 if R_E_tap_function_oth=="Electricity problem" 
replace R_E_tap_function_reason_2=1 if R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | ///
R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | ///
R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | ///
R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" //tap or the house is at the end or at an elevation

replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" //PO didnt turn on water as he didn't get his salary
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Pump opertator Not in village"
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Electricity problem" 
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | ///
R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | ///
R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | ///
R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" //tap or the house is at the end or at an elevation

* Issues with water supply
//the variable R_E_tap_issues_type (select multiple) has 7 categories including dont know and other; creating new variable to recategorise some of the other category responses 
gen R_E_tap_issues_type_6=.
replace R_E_tap_issues_type_6=0 if R_E_tap_issues==1
replace R_E_tap_issues_type_6=1 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" 

//categorizing the other category variables into proper categories
replace R_E_tap_issues_type_1=1 if R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" 
replace R_E_tap_issues_type_3=1 if R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 

replace R_E_tap_issues_type__77=0 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" | R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" | ///
R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 

/*Not categorised 
Pani re siuli aasuchhi
Cold
Handire pani rakhile cement rakhila vali hei jauchhi
*/


********************************************************************************
*** Generating new variables and dummies
********************************************************************************

* Water supply frequecny on the days water is supplied regularly
gen water_supply_freq=.
replace water_supply_freq=1 if R_E_tap_supply_daily==555
replace water_supply_freq=2 if R_E_tap_supply_daily==1
replace water_supply_freq=3 if R_E_tap_supply_daily==2
replace water_supply_freq=4 if R_E_tap_supply_daily==7 | R_E_tap_supply_daily==14

label var water_supply_freq "Frequency of Water supply"
label define water_supply_freq 1 "Supplied 24/7" 2 "Supplied once a day" 3 "Supplied twice a day" 4 "Supplied more than twice a day"
label values water_supply_freq water_supply_freq


* Creating dummy variables

foreach v in R_E_tap_supply_freq water_supply_freq R_E_tap_function ///
R_E_tap_function_reason_1 R_E_tap_function_reason_2 R_E_tap_function_reason_3 ///
R_E_tap_function_reason_4 R_E_tap_function_reason_5 R_E_tap_function_reason__77 R_E_tap_issues ///
R_E_tap_issues_type_1 R_E_tap_issues_type_2 R_E_tap_issues_type_3 R_E_tap_issues_type_4 ///
R_E_tap_issues_type_5 R_E_tap_issues_type_6 R_E_tap_issues_type__77 {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}
	
********************************************************************************
*** Labelling the variables for the table
********************************************************************************

label var R_E_tap_supply_freq_1 "Daily"
label var R_E_tap_supply_freq_2 "Few times a week"
label var R_E_tap_supply_freq_4 "Few times a month"
label var R_E_tap_supply_freq_6 "No fixed schedule"
label var R_E_tap_function_0 "Tap service not disrupted"
label var R_E_tap_function_1 "Tap service disrupted:"
label var R_E_tap_function_reason_1_1 "Water supply not turned on"
label var R_E_tap_function_reason_2_1 "Issues with water distribution system"
label var R_E_tap_function_reason_3_1 "Damaged water supply valve/pipe"
label var R_E_tap_function_reason_4_1 "Electricity issue"
label var R_E_tap_function_reason_5_1 "Issues with water pump"
label var R_E_tap_function_reason__77_1 "Other reasons"
label var R_E_tap_issues_0 "Did not face issues"
label var R_E_tap_issues_1 "Faced issues:"
label var R_E_tap_issues_type_1_1 "Odor Issues"
label var R_E_tap_issues_type_2_1 "Taste Issues"
label var R_E_tap_issues_type_3_1 "Turbidity Issues"
label var R_E_tap_issues_type_4_1 "Cooking Issues"
label var R_E_tap_issues_type_5_1 "Skin-related Issues"
label var R_E_tap_issues_type_6_1 "Supply Issues"
label var R_E_tap_issues_type__77_1 "Other Issues"

********************************************************************************
*** Generating the table - ENDLINE ONLY 
********************************************************************************	
 
*** Removing the prefix from the variables
// to ensure that they are not too long 
renpfix R_E_

*** Keeping only the endline observations to ensure correct number of obs in the table
keep if consent==1 

*** Saving the dataset 
save "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", replace

*** Creation of the table
*Setting up global macros for calling variables
global Govt_tap_infra tap_supply_freq_1 tap_supply_freq_2 tap_supply_freq_4 ///
tap_supply_freq_6 water_supply_freq_1 water_supply_freq_2 water_supply_freq_3 ///
water_supply_freq_4 tap_function_0 tap_function_1 tap_function_reason_1_1 ///
tap_function_reason_2_1 tap_function_reason_3_1 tap_function_reason_4_1 ///
tap_function_reason_5_1 tap_function_reason__77_1 tap_issues_0 tap_issues_1 tap_issues_type_1_1 ///
tap_issues_type_2_1 tap_issues_type_3_1 tap_issues_type_4_1 tap_issues_type_5_1 ///
tap_issues_type_6_1 tap_issues_type__77_1


*Setting up local macros (to be used for labelling the table)
local Govt_tap_infra "JJM tap infrastructure: Supply Patterns and Issues"
local LabelGovt_tap_infra "MaintableGovttap1"
local noteGovt_tap_infra "N: 874 - Number of main respondents who consented to participate in the Endline Survey \newline \textbf{Notes:} \newline(a)168 Missing Obs: Information collected for 706 HHs who use JJM water for drinking \newline(b)669 Missing Obs: Information collected for 205 out of 706 HHs who experienced disruptions \newline(c)37 Missing Obs: Information collected for 837 HHs who use JJM water \newline(d)815 Missing Obs: Information collected for 59 out of 837 HHs who faced issues \newline(e)*: Respondents allowed to select more than one reason \newline(f)**: Respondents allowed to select more than one issue" 
local ScaleGovt_tap_infra "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in Govt_tap_infra { //loop for all variables in the global marco 

use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	//Calculating the summary stats 
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Daily" "\multicolumn{7}{c}{\textbf{Panel 1: Supply Schedule and Frequency}} \\ Water Supply Schedule \\ \hspace{0.5cm} Daily" ///
				   "Few times a week" "\hspace{0.5cm} Few times a week" ///
				   "Few times a month" "\hspace{0.5cm} Few times a month" ///
				   "No fixed schedule" "\hspace{0.5cm} No fixed schedule" ///
				   "Supplied 24/7" "Water Supply Frequency \\ \hspace{0.5cm} Supplied 24/7" ///
				   "Supplied once a day" "\hspace{0.5cm} Supplied once a day" /// 
				   "Supplied twice a day" "\hspace{0.5cm} Supplied twice a day"  ///
				   "Supplied more than twice a day" "\hspace{0.5cm} Supplied more than twice a day" ///
				   "Tap service not disrupted" "\hline \multicolumn{7}{c}{\textbf{Panel 2: Disruptions in Tap Service (ref period: two weeks)}} \\ Tap service not disrupted" ///
				   "Tap service disrupted" "Tap service disrupted*" ///
				   "Water supply not turned on" "\hspace{0.5cm} Water supply not turned on" ///
				   "Issues with water distribution system" "\hspace{0.5cm} Issues with water distribution system" ///
				   "Damaged water supply valve/pipe" "\hspace{0.5cm} Damaged water supply valve/pipe" ///
				   "Electricity issue" "\hspace{0.5cm} Electricity issue" ///
				   "Issues with water pump" "\hspace{0.5cm} Issues with water pump" ///
				   "Other reasons" "\hspace{0.5cm} Other reasons" ///
				   "Did not face issues" "\hline \multicolumn{7}{c}{\textbf{Issues with tap water(ref period: two weeks)}} \\ Did not face issues" ///
				   "Faced issues:" "Faced issues:**" ///
				   "Odor Issues" "\hspace{0.5cm} Issues related to smell" ///
				   "Taste Issues" "\hspace{0.5cm} Issues related to taste" ///
				   "Turbidity Issues" "\hspace{0.5cm} Issues related to turbidity" ///
				   "Cooking Issues" "\hspace{0.5cm} Issues related to cooking" ///
				   "Skin-related Issues" "\hspace{0.5cm} Issues related to health (skin-related)" ///
				   "Supply-related issues" "\hspace{0.5cm} Issues related to supply of water" ///
				   "Other Issues" "\hspace{0.5cm} Other issues" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }


********************************************************************************
*** Generating the table - TREATMENT v CONTROL 
********************************************************************************	
	
*** Saving the dataset 
clear 
use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear //using the saved dataset 

*** Creation of the table
*Setting up global macros for calling variables
global Govt_tap_infra_TvsC tap_supply_freq_1 tap_supply_freq_2 tap_supply_freq_4 ///
tap_supply_freq_6 water_supply_freq_1 water_supply_freq_2 water_supply_freq_3 ///
water_supply_freq_4 tap_function_0 tap_function_1 tap_function_reason_1_1 ///
tap_function_reason_2_1 tap_function_reason_3_1 tap_function_reason_4_1 ///
tap_function_reason_5_1 tap_function_reason__77_1 tap_issues_0 tap_issues_1 tap_issues_type_1_1 ///
tap_issues_type_2_1 tap_issues_type_3_1 tap_issues_type_4_1 tap_issues_type_5_1 ///
tap_issues_type_6_1 tap_issues_type__77_1

*Setting up local macros (to be used for labelling the table)
local Govt_tap_infra_TvsC "Comparing JJM Tap Supply Patterns and Issues: Treatment vs. Control Groups"
local LabelGovt_tap_infra_TvsC "MaintableGovttap1"
local noteGovt_tap_infra_TvsC "N: 874 - Number of main respondents who consented to participate in the Endline Survey \newline \textbf{Notes:} \newline(a)*, **, *** in Column (5) represents statistical significance at 10\%, 5\% and 1\% respectively \newline(b)168 Missing Obs: Information collected for 706 HHs who use JJM water for drinking \newline(c)669 Missing Obs: Information collected for 205 out of 706 HHs who experienced disruptions \newline(d)37 Missing Obs: Information collected for the 837 HHs who use JJM water \newline(e)815 Missing Obs: Information collected for 59 out of 837 HHs who faced issues \newline(f)*: Respondents allowed to select more than one reason \newline(g)**: Respondents allowed to select more than one issue" 
local ScaleGovt_tap_infra_TvsC "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in Govt_tap_infra_TvsC { //loop for all variables in the global marco 

use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear //using the saved dataset 
	
	
	* Mean
	//Calculating the summary stats 
	eststo  model1: estpost summarize $`k' //Total (for all villages)
	eststo  model2: estpost summarize $`k' if Treat_V==1 //Treatment villages
	eststo  model3: estpost summarize $`k' if Treat_V==0 //Control villages
	
	* Diff 
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model4: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 339
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model5: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of p values
	
	* Missing 
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Frequency 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency


*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 model6 model7 using "${Table}DescriptiveStats_`k'.tex", ///
	   replace	   cell("mean (fmt(2) label(_))") ///
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Total}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Daily" "\multicolumn{9}{c}{\textbf{Supply Schedule and Frequency*}} \\ Water Supply Schedule \\ \hspace{0.5cm} Daily" ///
				   "Few times a week" "\hspace{0.5cm} Few times a week" ///
				   "Few times a month" "\hspace{0.5cm} Few times a month" ///
				   "No fixed schedule" "\hspace{0.5cm} No fixed schedule" ///
				   "Supplied 24/7" "Water Supply Frequency \\ \hspace{0.5cm} Supplied 24/7" ///
				   "Supplied once a day" "\hspace{0.5cm} Supplied once a day" /// 
				   "Supplied twice a day" "\hspace{0.5cm} Supplied twice a day"  ///
				   "Supplied more than twice a day" "\hspace{0.5cm} Supplied more than twice a day" ///
				   "Tap service not disrupted" "\hline \multicolumn{9}{c}{\textbf{Disruptions in Tap Service (ref period: two weeks)}} \\ Tap service not disrupted" ///
				   "Tap service disrupted" "Tap service disrupted**" ///
				   "Water supply not turned on" "\hspace{0.5cm} Water supply not turned on" ///
				   "Issues with water distribution system" "\hspace{0.5cm} Issues with water distribution system" ///
				   "Damaged water supply valve/pipe" "\hspace{0.5cm} Damaged water supply valve/pipe" ///
				   "Electricity issue" "\hspace{0.5cm} Electricity issue" ///
				   "Issues with water pump" "\hspace{0.5cm} Issues with water pump" ///
				   "Other reasons" "\hspace{0.5cm} Other reasons" ///
				   "Did not face issues" "\hline \multicolumn{9}{c}{\textbf{Issues with tap water(ref period: two weeks)***}} \\ Did not face issues" ///
				   "Faced issues:" "Faced issues:****" ///
				   "Issues related to smell" "\hspace{0.5cm} Issues related to smell" ///
				   "Issues related to taste" "\hspace{0.5cm} Issues related to taste" ///
				   "Issues related to turbidity" "\hspace{0.5cm} Issues related to turbidity" ///
				   "Issues related to cooking" "\hspace{0.5cm} Issues related to cooking" ///
				   "Issues related to health (skin-related)" "\hspace{0.5cm} Issues related to health (skin-related)" ///
				   "Issues related to supply of water" "\hspace{0.5cm} Issues related to supply of water" ///
				   "Other issues" "\hspace{0.5cm} Other issues" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }

	   
	   
		/*%%%%%%%%%%%%%%%%%% USAGE of GOVT TAP WATER %%%%%%%%%%%%%%%%*/

		
// Section relevant for those using JJM tap as primary or secondary water source in BL
// 

********************************************************************************
*** Opening the dataset
********************************************************************************

clear
use "${DataFinal}0_Master_HHLevel.dta", clear

********************************************************************************
*** Cleaning of relevant variables
********************************************************************************

* Dropping relevant obs
drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  
//1 obs dropped

********************************************************************************
*** Cleaning relevant variables
********************************************************************************

* Reasons for not drinking JJM tap water: Baseline
replace 
gen reason_nodrink_5_bl=.
replace reason_nodrink_5_bl=1 if R_Cen_a18_jjm_drinking==2 | R_Cen_a18_water_treat_oth=="Government doesn't provide house hold tap water" | ///
R_Cen_a18_water_treat_oth=="Paipe connection heinai" | R_Cen_a18_water_treat_oth=="Paip connection nahi" | ///
R_Cen_a18_water_treat_oth=="Tape connection nahi" | R_Cen_a18_water_treat_oth=="No government supply tap water" | ///
R_Cen_a18_water_treat_oth=="No government supply tap water for household" | R_Cen_a18_water_treat_oth=="Tap aasi nahi" | ///
R_Cen_a18_water_treat_oth=="Tap pani lagi nahi" | R_Cen_a18_water_treat_oth=="FHTC Tap Not contacting this house hold." | ///
R_Cen_a18_water_treat_oth=="Tap connection dia heini" | R_Cen_a18_water_treat_oth=="Government pani tap connection heini" | ///
R_Cen_a18_water_treat_oth=="No government supply tap water" | R_Cen_a18_water_treat_oth=="Tap Nehni Mila" | ///
R_Cen_a18_water_treat_oth=="Respondent doesn't have personal household Tap water connection provided by government" | ///
R_Cen_a18_water_treat_oth=="Don't have government supply tap" | R_Cen_a18_water_treat_oth=="Government don't supply house hold taps" | ///
R_Cen_a18_water_treat_oth=="Tape conektion nahi" | R_Cen_a18_water_treat_oth=="Gharme government tap nehni laga hai" | ///
R_Cen_a18_water_treat_oth=="No supply govt tap water in this Home"  


R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" |R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" | R_Cen_a18_water_treat_oth=="" 

R_Cen_a18_reason_nodrink__77 
R_Cen_a18_reason_nodrink_1 
R_Cen_a18_reason_nodrink_2 
R_Cen_a18_reason_nodrink_3 
R_Cen_a18_reason_nodrink_4 

R_Cen_a18_water_treat_oth
"Not interested"
"No direct supply water tap" //the person selected JJM tap water as primary source of water; not sure if this is the case where water is not being supplied or the HH doesn't have a tap connection
//translations required: 
"Nijara bor pani 1st ru piba pain byabahara karichhanti sethipain" 
"Jane asi pani chek kari kahithile pani kharap achhi" //someone came to check the water and said it's bad?
"Agaru  handpump paniobhayas heichu Sethi pae  tap Pani piunu" 
"Tankara bore water achi Sethi pai tap Pani used karunahanti"
"Ghare morar achi Sethi pae suffly Pani piunahnti"
"Nija ra  electrical motar pani achi Sethi pae piunahi"
"Ye hamlet me jo nichewala hissa he usko hi pani atahe khud ki tap he lekin pani nehi atahe wo dusre gharse latehe."
"Ehi ghara ra sakaranka jogaidiajaithiba gharei tap uchha jagare achhi tenu pani  totally asuni sethipain se podishi Gharara sarakaranka jogaithiba ghorei tap ru pani piba pain anuchhanti"
"Agaru abhayas heichanti to ghorai tap pani piunahanti" 
"Pani stock rahithibaru , bacteria thiba boli pintini"
"Sarakara nka tarafaru pani jogai dia jainahni"
"Tube well pani peibara abhyasa hoijaichhi sethipai sarakari tap pani pieunahu"
"Thanda kasa haba boli tap pani peunahanti"
"Pani aani ki ghare rakhile tela bhalia hoi hauchi au gadheile dehare phutuka hoi jauchi"
"Pakhare Manual Hand pump achhi" 


"Luha luha gandhuchi & dost asuchi"  //smell issues
"Supply Pani bhala lagunagi" //dont like tap water
"Supply pani piu nahanti kintu anya kama re lagauchhnti , gadheiba, basana dhaiba, luga dhaiba" //use it for other purposes as it smells and is muddy 

"Tap bhangi jaichhi" //tap is broken

"Pani aasunahi" //water supply related issue
"Supply pani timing re dia jaunahi Sethi pai tanka bore water used karunahanti" // water not supplied at a fixed time? (irregular supply)

"Jehetu Nijara kua achi se government pani ku use karantini," //private well
"Jehetu nija Borwell achi se government tap pani piunahanti" //private well
"Nija ghare bore water achi Sethi pai aame supply pani bebahara karunahanti" //use pvt borewell
"Ghare motor achi Sethi pae" //have their own motor
"Government tap pare diahela sethipai nijara Borwell kholeiki piuchu" //they use  private borewell
"Pani pahanchi parunathila sethipai nija Borwell kholilu" //has a private borewell











* Reasons for not drinking JJM tap water: Endline


R_E_nodrink_water_treat_oth
Khud ka baruel hai
Unke ghara me khudka surakhita kuan hai,
Khud ka boruel hai
Khudka bore laga hai isliye use nhi karte hain
Pani ru dhulli gunda baharuchhi
Basna bohut jada hora hai
Abhi tak supply pani nehi a raha hea.
Not connected to jjm tape
Hh not connected to jjm
Sarakari tap nai dia hua hai is sahi me
Sarakari tap idhara nai dia hua hai
Khudka bore hai isliye
Pehele se manual handpump kapanipiyehe ishliye tap pani achanehi lagtahe ishliye manual handpump kapanipitehe
Alga jagare rahuchacnti Sethi TAP conection deinahanti
Time houni morning utiki dhariba ku Sethi pae jjm tap use korunu
Aagaru khola kua ra Pani  abhiyasa hoi jaichi boli tap Pani piu nahanti
Kasa haijauthiba ru piunahanti
Tap lagi nahi
Not connected to jjm hh tap
Tap nahi diya hua hain
Tap nahi laga hua hain
Tap nahi deyegaye hain
Tap nahi diye gaye hai
Connection nhi hai
Tap nahi laga hua hai
Electrical Borwell achi to use korunahanti
Nijara achhi bali
Tap connection dia heini
Tap connection dia heini
Tap connection dia heini
Tap connection nahi
Tap ru bhala Pani aasu nahi
Khudka borewell hei isiliye JJM tap ka pani nahi pite hei
Esi household me JJM tap connection nahi hai
Unki ghar me JJm tap nehi he.
Tanki saf nahin karne bajase Pani nahin pite hai
Tanki ko saf nahi karne bajase Pani nahin pite hain
3 month hogeya supply pani khud bandha kardiya hai  kunki manual Handpump ka pani unko achche lagta hai
Basudha  connection nehi hai  Annya logo ka jaga se hokar pipe hokar anatha bo log manakarnese pani ka connection nehi hua.
JJm ,Basudha connection nehi hua hai
JJm Basudha connection nehi hua hai
Is household me JJM  tab connection nehi hua hai.
Isi household meJJM tap connection nahi hai
Isi household me basudha ka tap connection nahi hai
Isi household me JJM tap connection nahi hai
Unki Basudha tap jo hei unki dusre jaga pe hei distance bajase pani nahin pite hei
Isi household ka basudha ka tap connection nahi hei
Isi household me basudha ka tap connection nahi hei isi bajase wo tap pani nahin pite hei
Ise mahine me time pe pani nahi aya esliye wo pani nahi piye hein
Don't need inke ghar main already Borewell hain electricity wala
No specific problem
Not safety according to Respondent
Chlorine smell pain
Dia hoi nahi
Ghare available panira subidha achi
Borwell achi to use karunahanti kohile
Ghare available achi boli
Electricity pump boring available that's and
Ghare pani achi to use koruchu, tap connection nahi
Nija ghare Borwell pani achi to tap pani use korunahanti
Borwell achi to use koruchu
Borwell achi to use karunu
Panire poka ,machhi baharuchhi
Not connected to jjm tape
Not connected to jjm tape
Not connected to jjm tape
Apna khudka borwell he ishliye tape pani pinekeliye byabahar nehikartehe
Not connected
Supply watreTank nehi he ish village pe
Ish Hamlet pe supply water nehi he
No connection
Ish Hamlet pe supply water nehi he
No connection
Not connected to jjm tap
Govt tap no connection
Pani ka test achha nhi lag raha hai
Jjm not supply in this area
Is household JJM connection nehi hua hai
Is family me JJM connection nehi hua hai
Is family me JJM connection nehi hua hai
Jjm supply water not connected in this house hold
Esi household me JJM tap connection nahi hai
Not connected to jjm tank
Isi household me JJM ka tap connection nahi hei
Esi household me JJM tap connection nahi hei
Not connected to JJM tank
Isi household me JJM ka tap connection nahi hai
Isi household me JJM ka tap connection nahi hai
Jjm water not supply in this hamlet
Not suplay to govt water
Esi household me JJM tap connection nahi hai
Esi household me JJM tap connection nahi hai
Government tap nahi.
Gharki borki pani agar mortar chalunehi hone se pite he.
Esi household me JJM tap connection nahi hai
Esi household me JJM tap connection nahi hai
Jjm supply not connected this house hold
Is household me JJM connection nehi hua hai
Esi household me JJM tap ka connection nahi hai
Paip  nehihe
No connection
blinchi poudar ka smell ara hai isilie ni pura he
Handire pani rakhile siment lagila pari hauchhi
Tap bohot distance me hai isilie
Bliching smell


********************************************************************************
*** Generating new variables for tables 
********************************************************************************

* Use of JJM water for drinking - Baseline
gen jjm_drinking_bl=.
replace jjm_drinking_bl=1 if R_Cen_a18_jjm_drinking==1
replace jjm_drinking_bl=0 if R_Cen_a18_jjm_drinking==0 | R_Cen_a18_jjm_drinking==2 //in baseline we had 3 options: Yes, No and do not have a tap connection. Recoding "do not have a tap connection" into "No" (dont use JJm for drinking)
label var jjm_drinking_bl "Use JJM Water for drinking: Baseline"
label define jjm_drinking_bl 1 "Yes" 0 "No"
label values jjm_drinking_bl jjm_drinking_bl

* Use of JJM water for cooking - Baseline
gen jjm_cooking_bl=.
replace jjm_cooking_bl=1 if 
replace jjm_cooking_bl=0 if 
label var jjm_cooking_bl "Use JJM Water for cooking: Baseline"
label define jjm_cooking_bl 1 "Yes" 0 "No"
label values jjm_cooking_bl jjm_cooking_bl

* Use of JJM water for other purposes - Baseline
gen jjm_other_use_bl=.
replace jjm_other_use_bl=1 if 
replace jjm_other_use_bl=0 if 
label var jjm_other_use_bl "Use JJM Water for other purposes: Baseline"
label define jjm_other_use_bl 1 "Yes" 0 "No"
label values jjm_other_use_bl jjm_other_use_bl

* Use of JJM water for cooking - Endline
gen jjm_cooking_el=.
replace jjm_cooking_el=1 if 
replace jjm_cooking_el=0 if 
label var jjm_cooking_el "Use JJM Water for drinking: Endline"
label define jjm_cooking_el 1 "Yes" 0 "No"
label values jjm_cooking_el jjm_cooking_el

* Use of JJM water for other purposes - Endline
gen jjm_other_use_el=.
replace jjm_other_use_el=1 if 
replace jjm_other_use_el=0 if 
label var jjm_other_use_el "Use JJM Water for other purposes: Endline"
label define jjm_other_use_el 1 "Yes" 0 "No"
label values jjm_other_use_el jjm_other_use_el

* Reasons for not drinking JJM tap water - Baseline
gen reason_nodrink_bl=.
replace reason_nodrink_bl=R_Cen_a18_reason_nodrink 
replace reason_nodrink_bl=. if R_Cen_a18_reason_nodrink==999 //coding the don't know options as missing values
replace reason_nodrink_bl=5 if R_Cen_a18_jjm_drinking==2 //coding a new option for those who do not have a jjm tap as 5th reason for not using JJM water for drinking 
label var reason_nodrink_bl "Reasons for not drinking JJM tap water"
label define reason_nodrink_bl 1 "" 2 "" 3 "" 4 "" 5 "" -77 "Other reasons"
label values reason_nodrink_bl reason_nodrink_bl




// baseline variables: jjm_drinking_bl (1: use; 0: don't use for drinking); jjm_cooking_bl; jjm_other_use_bl
// endline variables: R_E_jjm_drinking (1: yse; 0: don't use for drinking); jjm_cooking_el; jjm_other_use_el
