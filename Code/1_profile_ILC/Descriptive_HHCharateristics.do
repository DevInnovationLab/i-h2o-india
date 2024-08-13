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


	/*%%%%%%%%%%%%%%%%%% HH CHARACTERISTICS %%%%%%%%%%%%%%%%*/
	
********************************************************************************
*** Using Endline_Long_Indiv_analysis.dta to get the pregnancy status variable
********************************************************************************
// clear 
// use  "${DataTemp}Endline_Long_Indiv_analysis.dta", clear //does not include revisit data
// preserve 
// keep comb_preg_status R_E_key unique_id
// bys R_E_key: gen Num=_n
// reshape wide  comb_preg_status , i(R_E_key) j(Num)
// save "${DataTemp}Endline_Preg_status_wide.dta", replace
// restore 

clear 
use  "${DataFinal}Endline_CBW_level_merged_dataset_final.dta", clear //includes revisit data
gen R_E_key_final= R_E_key
replace R_E_key_final= Revisit_R_E_key if R_E_key_final==""
preserve 
keep comb_preg_status R_E_key Revisit_R_E_key R_E_key_final unique_id
bys unique_id: gen Num=_n
drop R_E_key Revisit_R_E_key R_E_key_final
reshape wide  comb_preg_status , i(unique_id) j(Num)
save "${DataTemp}Endline_Preg_status_wide.dta", replace
restore 


********************************************************************************
*** Opening the Dataset 
********************************************************************************
clear
use "${DataFinal}0_Master_HHLevel.dta", clear
merge 1:1 unique_id using "${DataTemp}Endline_Preg_status_wide.dta", gen(merge_desc_stats)
//884 obs matched (30 out of 31 unmatched obs: resp not available; 1 extra obs is empty obs for UID 30501107052 which was dropped in Master data)

********************************************************************************
*** Generating relevant variables
********************************************************************************
drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  
//1 obs dropped


* Combined variable for Number of HH members (both BL and EL including the new members)
//changing the storage type of the no of HH members from baseline census
destring R_Cen_hh_member_names_count, gen(R_Cen_hhmember_count_new) 
destring R_E_n_hhmember_count, replace

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
// clear 
// use  "${DataTemp}Temp_HHLevel(for descriptive stats).dta", clear

*** Creation of the table
*Setting up global macros for calling variables
global HH_characteristics total_hhmembers total_CBW total_pregnant total_U5children total_noncri_members ///
R_Cen_a10_hhhead_gender_1 R_Cen_a10_hhhead_gender_2 /*hh_head_attend_school_1*/ hh_head_age hh_head_edu_0 hh_head_edu_2 hh_head_edu_3 hh_head_edu_4 /// 
hh_head_edu_5 hh_head_edu_6 hh_head_edu_7  respondent_gender_1 respondent_gender_2 respondent_age /*resp_attend_school_1*/ ///
respondent_edu_0 respondent_edu_1 respondent_edu_3 respondent_edu_4 respondent_edu_5 respondent_edu_6 respondent_edu_7 ///
 asset_quintile_1 asset_quintile_2 asset_quintile_3 asset_quintile_4 asset_quintile_5 ///
R_Cen_a37_caste_1 R_Cen_a37_caste_2 R_Cen_a37_caste_3 R_Cen_a37_caste_4

*Setting up local macros (to be used for labelling the table)
local HH_characteristics "Comparing Household Profiles: Insight into Demographic Trends"
local LabelHH_characteristics "MaintableHH"
local noteHH_characteristics "*** p\leq.001 ** p\leq.01, * p\leq.05 \newline Notes: (1)The table presents information on Household characteristics from Baseline and Endline Census (2) Missing value for age of household head: respondent didn't know the age of the household head (3)Asset Quintiles represent household wealth rankings(1 = lowest, 5 = highest)" 
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
				   "Quintile 1" "\hline \multicolumn{9}{c}{\textbf{Household Level Information}} \\ \textbf{Asset Quintiles} \\ \hspace{0.5cm}Quintile 1" ///
				   "Quintile 2" "\hspace{0.5cm}Quintile 2" ///
				   "Quintile 3" "\hspace{0.5cm}Quintile 3" ///
				   "Quintile 4" "\hspace{0.5cm}Quintile 4" ///
				   "Quintile 5" "\hspace{0.5cm}Quintile 5" ///
				   "Scheduled Caste" "\\ \textbf{Caste} \\ \hspace{0.5cm}Scheduled Caste" /// 
				   "Scheduled Tribe" "\hspace{0.5cm}Scheduled Tribe" ///
				   "Other Backward Caste" "\hspace{0.5cm}Other Backward Caste" ///
				   "Other Caste" "\hspace{0.5cm}Other Caste" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }
	
	
	
	
	
	
	
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GOVT TAP INFRASTRUCTURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
		

		
********************************************************************************
*** Opening the dataset
********************************************************************************

clear
use "${DataFinal}0_Master_HHLevel.dta", clear


********************************************************************************
*** Cleaning of relevant variables and generating new ones 
********************************************************************************

* Changing the storage type of relevant variables
		
destring R_E_jjm_drinking R_E_jjm_yes R_E_tap_supply_freq R_E_tap_supply_daily R_E_tap_function R_E_tap_function_reason R_E_tap_function_reason_1 R_E_tap_function_reason_2 R_E_tap_function_reason_3 R_E_tap_function_reason_4 R_E_tap_function_reason_5 R_E_tap_function_reason_999 R_E_tap_function_reason__77 R_E_tap_issues R_E_tap_issues_type R_E_tap_issues_type_1 R_E_tap_issues_type_2 R_E_tap_issues_type_3 R_E_tap_issues_type_4 R_E_tap_issues_type_5 R_E_tap_issues_type__77 R_E_consent, replace


* Supply schedule of JJM tap water
replace R_E_tap_supply_freq=1 if R_E_tap_supply_freq==-77 //recoding the other category into "Daily" category given that water is supplied daily but the quantity is less

* Reason that the jjm tap was not functional
//Recoding the other category responses into proper categories
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" //PO didnt turn on water as he didn't get his salary
replace R_E_tap_function_reason_1=1 if R_E_tap_function_oth=="Pump opertator Not in village"
replace R_E_tap_function_reason_4=1 if R_E_tap_function_oth=="Electricity problem" 
replace R_E_tap_function_reason_2=1 if R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | ///
R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | ///
R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | ///
R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" //tap or the house is at the end or at an elevation

//Replacing the values in "Other" category with zero after categorizing them 
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Salary nehin mila pump operator ko is liye nehin chod raha hain" //PO didnt turn on water as he didn't get his salary
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Pump opertator Not in village"
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="Electricity problem" 
replace R_E_tap_function_reason__77=0 if R_E_tap_function_oth=="1month hogeya khud ka JJm tab Hight me hai to pani nehi arahahai" | ///
R_E_tap_function_oth=="Unke ghar last pe he ,pani ane me late hota he" | ///
R_E_tap_function_oth=="Tap connection hight place me hai isilie pani nai aratha" | ///
R_E_tap_function_oth=="tap connection place hight me hai isilie pani thik se nai arahe hamari tap me" //tap or the house is at the end or at an elevation

/**Responses Not categorised yet: R_E_tap_function_oth

"Late re uthi thibaru Pani banda hoi gala"
"Alpa samaya pain pani chhadi thile"

*/

* Issues with water supply
//the variable R_E_tap_issues_type (select multiple) has 7 categories including dont know and other; creating new variable to recategorise some of the other category responses 
gen R_E_tap_issues_type_6=.
replace R_E_tap_issues_type_6=0 if R_E_tap_issues==1
replace R_E_tap_issues_type_6=1 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" 

//Categorizing the other category variables into proper categories
replace R_E_tap_issues_type_1=1 if R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" 
replace R_E_tap_issues_type_3=1 if R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 

//Replacing the values in "Other" category with zero after categorizing them 
replace R_E_tap_issues_type__77=0 if R_E_tap_issues_type_oth=="Not available water" | ///
R_E_tap_issues_type_oth=="Pani bich bich meain nehin ata hain" | ///
R_E_tap_issues_type_oth=="Ek din current nehi aya tha isilea thoda taklip hua tha" | ///
R_E_tap_issues_type_oth=="Tank problem" | R_E_tap_issues_type_oth=="Pani re gunda bhasuchhi" | ///
R_E_tap_issues_type_oth=="Pani ke sath anya kuch chota mota cheej aa jata hain" 


/**Responses Not categorised yet: R_E_tap_issues_type_oth
Pani re siuli aasuchhi
Cold
Handire pani rakhile cement rakhila vali hei jauchhi
//two blank responses also present
*/


* Water supply frequecny on the days water is supplied regularly
gen water_supply_freq=.
replace water_supply_freq=1 if R_E_tap_supply_daily==555
replace water_supply_freq=2 if R_E_tap_supply_daily==1
replace water_supply_freq=3 if R_E_tap_supply_daily==2
replace water_supply_freq=4 if R_E_tap_supply_daily==7 | R_E_tap_supply_daily==14

label var water_supply_freq "Frequency of Water supply"
label define water_supply_freq 1 "Supplied 24/7" 2 "Supplied once a day" 3 "Supplied twice a day" 4 "Supplied more than twice a day"
label values water_supply_freq water_supply_freq



// * Recoding don't know observations as missing values 
// //Reason that jjm tap is not working
// foreach var in  R_E_tap_function_reason__77 R_E_tap_function_reason_1 R_E_tap_function_reason_2 ///
// R_E_tap_function_reason_3 R_E_tap_function_reason_4 R_E_tap_function_reason_5 {
// 	replace `var'=. if R_E_tap_function_reason=="999"
// }

 
********************************************************************************
*** Generating new variables and dummies
********************************************************************************

* Creating variables for the table only to ensure consistency in number of observations
gen supply_sched=.
replace supply_sched=0 if R_E_jjm_drinking==0 //do not drink jjm
replace supply_sched=1 if R_E_tap_supply_freq==1 //water supplied daily
replace supply_sched=2 if R_E_tap_supply_freq==2 //water supplied few times a week
replace supply_sched=3 if R_E_tap_supply_freq==4 //water supplied few times a moth
replace supply_sched=4 if R_E_tap_supply_freq==6 //no fixed shcedule for water supply

label var supply_sched "Water supply schedule"
label define supply_sched 0 "Do not drink JJM water" 1 "Daily" 2 "Few times a week" 3 "Few times a month" 4 "No fixed schedule"
label values supply_sched supply_sched


gen supply_freq=.
replace supply_freq=0 if R_E_jjm_drinking==0 //do not drink jjm
replace supply_freq=1 if water_supply_freq==1
replace supply_freq=2 if water_supply_freq==2
replace supply_freq=3 if water_supply_freq==3
replace supply_freq=4 if water_supply_freq==4 

label var supply_freq "Frequency of Water supply"
label define supply_freq 0 "Do not drink JJM water" 1 "Supplied 24/7" 2 "Supplied once a day" 3 "Supplied twice a day" 4 "Supplied more than twice a day"
label values supply_freq supply_freq


gen disruption=. //missing
replace disruption=0 if R_E_jjm_drinking==0 //do not drink jjm
replace disruption=1 if R_E_tap_function==0 //no disruptions 
replace disruption=2 if R_E_tap_function_reason_1==1 //disruptions beacuse of supply 
replace disruption=3 if R_E_tap_function_reason_2==1
replace disruption=4 if R_E_tap_function_reason_3==1
replace disruption=5 if R_E_tap_function_reason_4==1
replace disruption=6 if R_E_tap_function_reason_5==1
replace disruption=7 if R_E_tap_function_reason__77==1
replace disruption=8 if R_E_tap_function_reason_999==1 //don't know


label var disruption "Disruptions in tap functioning"
label define disruption 0 "Do not drink JJM tap water" 1 "Tap service not disrupted" 2 "Water supply not turned on" 3 "Issues with water distribution system" 4 "Damaged water supply valve/pipe" 5 "Electricity issue" 6 "Issues with water pump" 7 "Other reasons" 8 "Don't know"
label values disruption disruption


gen issues=.
replace issues=0 if R_E_jjm_drinking==0 & R_E_jjm_yes==0 //dont use jjm for drinking or other purposes
replace issues=1 if R_E_tap_issues==0 //no issues
replace issues=2 if R_E_tap_issues_type_1==1 //odor
replace issues=3 if R_E_tap_issues_type_2==1 //taste
replace issues=4 if R_E_tap_issues_type_3==1 //turbidity
replace issues=5 if R_E_tap_issues_type_4==1 //cooking
replace issues=6 if R_E_tap_issues_type_5==1 //skin
replace issues=7 if R_E_tap_issues_type_6==1 //water supply
replace issues=8 if R_E_tap_issues_type__77==1 //other

label var issues "Issues with JJM water"
label define issues 0 "Don't use JJM for drinking or other purposes" 1 "Did not face issues" 2 "Odor Issues" 3 "Taste Issues" 4 "Turbidity Issues" 5 "Cooking Issues" 6 "Skin-related Issues" 7 "Supply Issues" 8 "Other Issues"
label values issues issues


* Creating dummy variables
foreach v in supply_sched supply_freq disruption issues {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


// foreach v in R_E_tap_supply_freq water_supply_freq R_E_tap_function ///
// R_E_tap_function_reason_1 R_E_tap_function_reason_2 R_E_tap_function_reason_3 ///
// R_E_tap_function_reason_4 R_E_tap_function_reason_5 R_E_tap_function_reason__77 R_E_tap_issues ///
// R_E_tap_issues_type_1 R_E_tap_issues_type_2 R_E_tap_issues_type_3 R_E_tap_issues_type_4 ///
// R_E_tap_issues_type_5 R_E_tap_issues_type_6 R_E_tap_issues_type__77 {
// 	levelsof `v'
// 	foreach value in `r(levels)' {
// 		gen     `v'_`value'=0
// 		replace `v'_`value'=1 if `v'==`value'
// 		replace `v'_`value'=. if `v'==.
// 		label var `v'_`value' "`: label (`v') `value''"
// 	}
// 	}
	
********************************************************************************
*** Labelling the variables for the table
********************************************************************************

// label var R_E_tap_supply_freq_1 "Daily"
// label var R_E_tap_supply_freq_2 "Few times a week"
// label var R_E_tap_supply_freq_4 "Few times a month"
// label var R_E_tap_supply_freq_6 "No fixed schedule"
// label var R_E_tap_function_0 "Tap service not disrupted"
// label var R_E_tap_function_1 "Tap service disrupted:"
// label var R_E_tap_function_reason_1_1 "Water supply not turned on"
// label var R_E_tap_function_reason_2_1 "Issues with water distribution system"
// label var R_E_tap_function_reason_3_1 "Damaged water supply valve/pipe"
// label var R_E_tap_function_reason_4_1 "Electricity issue"
// label var R_E_tap_function_reason_5_1 "Issues with water pump"
// label var R_E_tap_function_reason__77_1 "Other reasons"
// label var R_E_tap_issues_0 "Did not face issues"
// label var R_E_tap_issues_1 "Faced issues:"
// label var R_E_tap_issues_type_1_1 "Odor Issues"
// label var R_E_tap_issues_type_2_1 "Taste Issues"
// label var R_E_tap_issues_type_3_1 "Turbidity Issues" 
// label var R_E_tap_issues_type_4_1 "Cooking Issues"
// label var R_E_tap_issues_type_5_1 "Skin-related Issues"
// label var R_E_tap_issues_type_6_1 "Supply Issues"
// label var R_E_tap_issues_type__77_1 "Other Issues"

********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS 
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
global Govt_tap_infra supply_sched_1 supply_sched_2 supply_sched_3 supply_sched_4 ///
supply_freq_1 supply_freq_2 supply_freq_3 supply_freq_4 disruption_1 disruption_2 ///
disruption_3 disruption_4 disruption_5 disruption_6 disruption_7 disruption_8 issues_1 issues_2 ///
issues_3 issues_4 issues_5 issues_6 issues_7 issues_8


*Setting up local macros (to be used for labelling the table)
local Govt_tap_infra "JJM tap infrastructure: Supply Patterns and Issues"
local LabelGovt_tap_infra "MaintableGovttap1"
local noteGovt_tap_infra "N: 880 - Number of respondents who consented to participate in the Endline Survey \newline \textbf{Notes:} (1)Data for Panels A and B collected only for households drinking JJM tap water (2)Data for Panel C collected only for households using JJM tap water (drinking or other purposes)." 
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
				   "Daily" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Supply Schedule and Frequency}} \\ Water Supply Schedule \\ \hspace{0.5cm} Daily" ///
				   "Few times a week" "\hspace{0.5cm} Few times a week" ///
				   "Few times a month" "\hspace{0.5cm} Few times a month" ///
				   "No fixed schedule" "\hspace{0.5cm} No fixed schedule" ///
				   "Supplied 24/7" "Water Supply Frequency \\ \hspace{0.5cm} Supplied 24/7" ///
				   "Supplied once a day" "\hspace{0.5cm} Supplied once a day" /// 
				   "Supplied twice a day" "\hspace{0.5cm} Supplied twice a day"  ///
				   "Supplied more than twice a day" "\hspace{0.5cm} Supplied more than twice a day" ///
				   "Tap service not disrupted" "\hline \\ \multicolumn{7}{c}{\textbf{Panel 2: Disruptions in Tap Service (ref period: two weeks)}} \\ Tap service not disrupted" ///
				   "Water supply not turned on" "Tap service disrupted: \\ \hspace{0.5cm} Water supply not turned on" ///
				   "Issues with water distribution system" "\hspace{0.5cm} Issues with water distribution system" ///
				   "Damaged water supply valve/pipe" "\hspace{0.5cm} Damaged water supply valve/pipe" ///
				   "Electricity issue" "\hspace{0.5cm} Electricity issue" ///
				   "Issues with water pump" "\hspace{0.5cm} Issues with water pump" ///
				   "Other reasons" "\hspace{0.5cm} Other reasons" ///
				   "Did not face issues" "\hline \\ \multicolumn{7}{c}{\textbf{Panel 3: Issues with tap water(ref period: two weeks)}} \\ Did not face issues" ///
				   "Odor Issues" "Faced issues: \\ \hspace{0.5cm} Odor issues" ///
				   "Taste Issues" "\hspace{0.5cm} Taste issues" ///
				   "Turbidity Issues" "\hspace{0.5cm} Turbidity issues" ///
				   "Cooking Issues" "\hspace{0.5cm} Cooking issues" ///
				   "Skin-related Issues" "\hspace{0.5cm} Skin-related issues" ///
				   "Supply Issues" "\hspace{0.5cm} Water supply related issues" ///
				   "Other Issues" "\hspace{0.5cm} Other issues" ///
				   "Don't know" "\hspace{0.5cm} Don't know" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }


********************************************************************************
*** Generating the table - TREATMENT v CONTROL 
********************************************************************************	
	

clear 
use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear //using the saved dataset 

*** Creation of the table
*Setting up global macros for calling variables
global Govt_tap_infra_TvsC supply_sched_1 supply_sched_2 supply_sched_3 supply_sched_4 ///
supply_freq_1 supply_freq_2 supply_freq_3 supply_freq_4 disruption_1 disruption_2 ///
disruption_3 disruption_4 disruption_5 disruption_6 disruption_7 disruption_8 issues_1 issues_2 ///
issues_3 issues_4 issues_5 issues_6 issues_7 issues_8

*Setting up local macros (to be used for labelling the table)
local Govt_tap_infra_TvsC "JJM Tap Infrastructure across treatment arms: Supply patterns and issues"
local LabelGovt_tap_infra_TvsC "MaintableGovttap2"
local noteGovt_tap_infra_TvsC "*** p<.001 ** p<.01, * p<.05 \newline N: 880 - Number of main respondents who consented to participate in the Endline Survey \newline \textbf{Notes:} (1)Data for Panels A and B collected only for households drinking JJM tap water (2)Data for Panel C collected only for households using JJM tap water (drinking or other purposes)." 
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
	use "${DataTemp}Temp_HHLevel(govttap_infra descriptive stats).dta", clear
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
				   "Daily" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Supply Schedule and Frequency}} \\ Water Supply Schedule \\ \hspace{0.5cm} Daily" ///
				   "Few times a week" "\hspace{0.5cm} Few times a week" ///
				   "Few times a month" "\hspace{0.5cm} Few times a month" ///
				   "No fixed schedule" "\hspace{0.5cm} No fixed schedule" ///
				   "Supplied 24/7" "Water Supply Frequency \\ \hspace{0.5cm} Supplied 24/7" ///
				   "Supplied once a day" "\hspace{0.5cm} Supplied once a day" /// 
				   "Supplied twice a day" "\hspace{0.5cm} Supplied twice a day"  ///
				   "Supplied more than twice a day" "\hspace{0.5cm} Supplied more than twice a day" ///
				   "Tap service not disrupted" "\hline \\ \multicolumn{7}{c}{\textbf{Panel 2: Disruptions in Tap Service (ref period: two weeks)}} \\ Tap service not disrupted" ///
				   "Water supply not turned on" "Tap service disrupted: \\ \hspace{0.5cm} Water supply not turned on" ///
				   "Issues with water distribution system" "\hspace{0.5cm} Issues with water distribution system" ///
				   "Damaged water supply valve/pipe" "\hspace{0.5cm} Damaged water supply valve/pipe" ///
				   "Electricity issue" "\hspace{0.5cm} Electricity issue" ///
				   "Issues with water pump" "\hspace{0.5cm} Issues with water pump" ///
				   "Other reasons" "\hspace{0.5cm} Other reasons" ///
				   "Did not face issues" "\hline \\ \multicolumn{7}{c}{\textbf{Panel 3: Issues with tap water(ref period: two weeks)}} \\ Did not face issues" ///
				   "Odor Issues" "Faced issues: \\ \hspace{0.5cm} Odor issues" ///
				   "Taste Issues" "\hspace{0.5cm} Taste issues" ///
				   "Turbidity Issues" "\hspace{0.5cm} Turbidity issues" ///
				   "Cooking Issues" "\hspace{0.5cm} Cooking issues" ///
				   "Skin-related Issues" "\hspace{0.5cm} Skin-related issues" ///
				   "Supply Issues" "\hspace{0.5cm} Water supply related issues" ///
				   "Other Issues" "\hspace{0.5cm} Other issues" ///
				   "Don't know" "\hspace{0.5cm} Don't know" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }

	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USAGE of GOVT TAP WATER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


// Section relevant for those using JJM tap as primary or secondary water source in BL
// 
/*To check with Vaishnavi/Akito: 
R_Cen_a18_jjm_drinking and A20_JJM_yes (baseline vars): questions applicable only for those who use JJM or other giovt tap water as prim or sec source of water. 5 HHs in baseline (IDs: 10101113025, 30602107130, 50301117063, 50501109014, 50501109017, 50501109023) use prim and sec sources other than govt tap (recorded in other category) and thus got the questions on whether they use jjm water for drinking or other uses. I have recoded the responses to the two questions (and all follow up questions) for these 3 observations in baseline as missing (given these responses are not in line with the skip pattern we have). Is it alright?

br R_Cen_a12_water_source_prim R_Cen_a13_water_source_sec R_Cen_a13_water_source_sec_1 R_Cen_a13_water_source_sec_2 R_Cen_a20_jjm_use R_Cen_a18_jjm_drinking R_Cen_a20_jjm_yes R_E_jjm_use R_E_jjm_yes R_E_jjm_drinking if R_Cen_a13_water_source_sec_1==0 & R_Cen_a13_water_source_sec_2==0 & R_Cen_a12_water_source_prim!=1 & R_Cen_a12_water_source_prim!=2
*/

********************************************************************************
*** Opening the dataset
********************************************************************************

clear
use "${DataFinal}0_Master_HHLevel.dta", clear


********************************************************************************
*** Cleaning and generating new variables
********************************************************************************

*** Changing the storage type of relevant variables
destring R_E_jjm_drinking R_E_jjm_yes R_E_jjm_use R_E_jjm_use_1 R_E_jjm_use_2 R_E_jjm_use_3 R_E_jjm_use_4 R_E_jjm_use_5 R_E_jjm_use_6 R_E_jjm_use_7 R_E_jjm_use__77 R_E_jjm_use_999 R_E_reason_nodrink R_E_reason_nodrink_1 R_E_reason_nodrink_2 R_E_reason_nodrink_3 R_E_reason_nodrink_4 R_E_reason_nodrink_999 R_E_reason_nodrink__77 R_E_consent, replace

*** Recoding observations (manual corrections)
* Recoding observations as missing for the section: usage of govt tap 
//the following three obs do not use govt tap water as their primary or secondary source of water (the source used by them was recorded in "Other" category in  "A12_prim_source_oth"). Given the section is applicable only for HHs who use govt tap as prim or sec source in Baseline, replacing the responses to these questions as missing
replace R_Cen_a18_reason_nodrink="" if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink_1=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink_2=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink_3=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink_4=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink_999=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_reason_nodrink__77=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_water_treat_oth="" if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a18_jjm_drinking=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_yes=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use="" if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_1=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_2=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_3=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_4=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_5=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_6=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_7=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_999=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use__77=. if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"
replace R_Cen_a20_jjm_use_oth="" if unique_id=="10101113025" | unique_id=="30602107130" | unique_id=="50301117063" | unique_id=="50501109014" | unique_id=="50501109017" | unique_id=="50501109023"

*** Cleaning the variables

* Reasons for not drinking JJM tap water: Baseline
//Categorizing the responses from "Other category to the relevant categories"
//Option 4: Reason for not drinking: Water is smelly or muddy 
replace R_Cen_a18_reason_nodrink_4=1 if  R_Cen_a18_water_treat_oth=="Luha luha gandhuchi & dost asuchi" | ///
R_Cen_a18_water_treat_oth=="Supply pani piu nahanti kintu anya kama re lagauchhnti , gadheiba, basana dhaiba, luga dhaiba" 

/*
//Option 3: Reason for not drinking: Water supply is intermittent 
replace R_Cen_a18_reason_nodrink_3=1 if R_Cen_a18_water_treat_oth==

//Option 2: Reason for not drinking: Water supply is inadequate
replace R_Cen_a18_reason_nodrink_2=1 if R_Cen_a18_water_treat_oth==
*/

//Option 1: Reason for not drinking: Tap is broken and doesn't supply water 
replace R_Cen_a18_reason_nodrink_1=1 if R_Cen_a18_water_treat_oth=="Tap bhangi jaichhi" //tap is broken 

//Creating a new category for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank  
gen R_Cen_a18_reason_nodrink_5=.
replace R_Cen_a18_reason_nodrink_5=0 if R_Cen_a18_reason_nodrink!=""
replace R_Cen_a18_reason_nodrink_5=1 if R_Cen_a18_jjm_drinking==2 
replace R_Cen_a18_reason_nodrink_5=1 if R_Cen_a18_water_treat_oth=="Paipe connection heinai" | ///
R_Cen_a18_water_treat_oth=="Paip connection nahi" | R_Cen_a18_water_treat_oth=="Tape connection nahi" | ///
R_Cen_a18_water_treat_oth=="Tap aasi nahi" | R_Cen_a18_water_treat_oth=="Tap Nehni Mila" | ///
R_Cen_a18_water_treat_oth=="Tap pani lagi nahi" | R_Cen_a18_water_treat_oth=="FHTC Tap Not contacting this house hold." | ///
R_Cen_a18_water_treat_oth=="Tap connection dia heini" | R_Cen_a18_water_treat_oth=="Government pani tap connection heini" | ///
R_Cen_a18_water_treat_oth=="Respondent doesn't have personal household Tap water connection provided by government" | ///
R_Cen_a18_water_treat_oth=="Don't have government supply tap" | R_Cen_a18_water_treat_oth=="Government don't supply house hold taps" | ///
R_Cen_a18_water_treat_oth=="Tape conektion nahi" | R_Cen_a18_water_treat_oth=="Gharme government tap nehni laga hai" 

label var R_Cen_a18_reason_nodrink_5 "Don't have a JJM tap connection"
label define R_Cen_a18_reason_nodrink_5 1 "Yes" 0 "No"
label values R_Cen_a18_reason_nodrink_5 R_Cen_a18_reason_nodrink_5

//Creating a new category for those who dont drink jjm water because they fetch drinking water from other private water source
gen R_Cen_a18_reason_nodrink_6=.
replace R_Cen_a18_reason_nodrink_6=0 if R_Cen_a18_reason_nodrink!=""
replace R_Cen_a18_reason_nodrink_6=1 if R_Cen_a18_water_treat_oth=="Jehetu Nijara kua achi se government pani ku use karantini," | ///
R_Cen_a18_water_treat_oth=="Jehetu nija Borwell achi se government tap pani piunahanti" | ///
R_Cen_a18_water_treat_oth=="Nija ghare bore water achi Sethi pai aame supply pani bebahara karunahanti" | ///
R_Cen_a18_water_treat_oth=="Ghare motor achi Sethi pae" | R_Cen_a18_water_treat_oth=="Pani pahanchi parunathila sethipai nija Borwell kholilu" | ///
R_Cen_a18_water_treat_oth=="Government tap pare diahela sethipai nijara Borwell kholeiki piuchu"

label var R_Cen_a18_reason_nodrink_6 "Have other private drinking water source "
label define R_Cen_a18_reason_nodrink_6 1 "Yes" 0 "No"
label values R_Cen_a18_reason_nodrink_6 R_Cen_a18_reason_nodrink_6

//Replacing the values in "Other" with zero after categorizing them 
replace R_Cen_a18_reason_nodrink__77=0 if R_Cen_a18_water_treat_oth=="Paipe connection heinai" | ///
R_Cen_a18_water_treat_oth=="Paip connection nahi" | R_Cen_a18_water_treat_oth=="Tape connection nahi" | ///
R_Cen_a18_water_treat_oth=="Tap aasi nahi" | R_Cen_a18_water_treat_oth=="Tap Nehni Mila" | ///
R_Cen_a18_water_treat_oth=="Tap pani lagi nahi" | R_Cen_a18_water_treat_oth=="FHTC Tap Not contacting this house hold." | ///
R_Cen_a18_water_treat_oth=="Tap connection dia heini" | R_Cen_a18_water_treat_oth=="Government pani tap connection heini" | ///
R_Cen_a18_water_treat_oth=="Respondent doesn't have personal household Tap water connection provided by government" | ///
R_Cen_a18_water_treat_oth=="Don't have government supply tap" | R_Cen_a18_water_treat_oth=="Government don't supply house hold taps" | ///
R_Cen_a18_water_treat_oth=="Tape conektion nahi" | R_Cen_a18_water_treat_oth=="Gharme government tap nehni laga hai" | ///
R_Cen_a18_water_treat_oth=="Luha luha gandhuchi & dost asuchi" | R_Cen_a18_water_treat_oth=="Tap bhangi jaichhi" | ///
R_Cen_a18_water_treat_oth=="Supply pani piu nahanti kintu anya kama re lagauchhnti , gadheiba, basana dhaiba, luga dhaiba" | ///
R_Cen_a18_water_treat_oth=="Jehetu Nijara kua achi se government pani ku use karantini," | ///
R_Cen_a18_water_treat_oth=="Jehetu nija Borwell achi se government tap pani piunahanti" | ///
R_Cen_a18_water_treat_oth=="Nija ghare bore water achi Sethi pai aame supply pani bebahara karunahanti" | ///
R_Cen_a18_water_treat_oth=="Ghare motor achi Sethi pae" | R_Cen_a18_water_treat_oth=="Pani pahanchi parunathila sethipai nija Borwell kholilu" | ///
R_Cen_a18_water_treat_oth=="Government tap pare diahela sethipai nijara Borwell kholeiki piuchu" 

//Replacing the missing observations for "0" where R_Cen_a18_reason_nodrink==2 
*(the reason for not drinking jjm water was skipped for those who said they do nothave a tap connection in baseline. Given that this response has been recoded into a new category/reason for not drinking jjm water in line804, replacing the missing values for consistnency in no of obs)
foreach var in R_Cen_a18_reason_nodrink_1 R_Cen_a18_reason_nodrink_2 R_Cen_a18_reason_nodrink_3 R_Cen_a18_reason_nodrink_4 R_Cen_a18_reason_nodrink_6 R_Cen_a18_reason_nodrink__77 R_Cen_a18_reason_nodrink_999 {
	replace `var'=0 if R_Cen_a18_jjm_drinking==2
}


/** Responses not catergorised yet:  R_Cen_a18_water_treat_oth 
//Not sure about the category:

//Does the hh not get water from the tap (to be categorised into R_Cen_a18_reason_nodrink_1) or does the hh not have a tap connection (to be categorised into reason_nodrink_5_bl): 
"Government doesn't provide house hold tap water"
"No government supply tap water"
"No government supply tap water for household"
"No government supply tap water"
"No supply govt tap water in this Home" 

//the person selected JJM tap water as primary source of water; not sure if this is the case where water is not being supplied or the HH doesn't have a tap connection
"No direct supply water tap" 


//Vague
"Not interested"
"Supply Pani bhala lagunagi" //dont like tap water - should we categorize it into muddy/silty? - R_Cen_a18_reason_nodrink_4
"Pani aasunahi" //water supply related issue - should we categorize it into "intermittent water supply" or "tap is broken and doesn't supply water"



//Translations required: 
"Jane asi pani chek kari kahithile pani kharap achhi" //someone came to check the water and said it's bad?
"Supply pani timing re dia jaunahi Sethi pai tanka bore water used karunahanti" // water not supplied at a fixed time? (irregular supply)
"Nijara bor pani 1st ru piba pain byabahara karichhanti sethipain" 
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
*/


* Reasons for not drinking JJM tap water: Endline
//Categorizing the responses from "Other category to the relevant categories"
//Option 4: Reason for not drinking: Water is silty or muddy 
// replace R_E_reason_nodrink_4=1 if R_E_nodrink_water_treat_oth==

//Option 3: Reason for not drinking: Water supply is intermittent 
replace R_E_reason_nodrink_3=1 if R_E_nodrink_water_treat_oth=="Ise mahine me time pe pani nahi aya esliye wo pani nahi piye hein"  

/*
//Option 2: Reason for not drinking: Water supply is inadequate
replace R_E_reason_nodrink_2=1 if R_E_nodrink_water_treat_oth==

//Option 1: Reason for not drinking: Tap is broken and doesn't supply water 
replace R_E_reason_nodrink_1=1 if R_E_nodrink_water_treat_oth==
*/

//Creating a new category for those who dont drink jjm water because they do not have a govt tap connection or are not connected to the tank 
gen R_E_reason_nodrink_5=.
replace R_E_reason_nodrink_5=0 if R_E_reason_nodrink!=""
replace R_E_reason_nodrink_5=1 if R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | ///
R_E_nodrink_water_treat_oth=="Hh not connected to jjm" | R_E_nodrink_water_treat_oth=="Sarakari tap nai dia hua hai is sahi me" | ///
R_E_nodrink_water_treat_oth=="Sarakari tap idhara nai dia hua hai" | R_E_nodrink_water_treat_oth=="Tap lagi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm hh tap" | R_E_nodrink_water_treat_oth=="Tap nahi diya hua hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hain" | R_E_nodrink_water_treat_oth=="Tap nahi deyegaye hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi diye gaye hai" | R_E_nodrink_water_treat_oth=="Connection nhi hai" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hai" | R_E_nodrink_water_treat_oth=="Tap connection dia heini" | ///
R_E_nodrink_water_treat_oth=="Tap connection nahi" | R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Basudha  connection nehi hai  Annya logo ka jaga se hokar pipe hokar anatha bo log manakarnese pani ka connection nehi hua." | ///
R_E_nodrink_water_treat_oth=="Unki ghar me JJm tap nehi he." | R_E_nodrink_water_treat_oth=="JJm ,Basudha connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="JJm Basudha connection nehi hua hai" | R_E_nodrink_water_treat_oth=="Dia hoi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | R_E_nodrink_water_treat_oth=="Not connected" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="No connection" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tap" | R_E_nodrink_water_treat_oth=="Govt tap no connection" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM  tab connection nehi hua hai." | ///
R_E_nodrink_water_treat_oth=="Isi household meJJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household ka basudha ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hei isi bajase wo tap pani nahin pite hei" | ///
R_E_nodrink_water_treat_oth=="Is household JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Is family me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply water not connected in this house hold" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Not connected to jjm tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hei" | R_E_nodrink_water_treat_oth=="Not connected to JJM tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Government tap nahi." | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply not connected this house hold" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap ka connection nahi hai" 

label var R_E_reason_nodrink_5 "Don't have a JJM tap connection"
label define R_E_reason_nodrink_5 1 "Yes" 0 "No"
label values R_E_reason_nodrink_5 R_E_reason_nodrink_5

//Creating a new category for those who dont drink jjm water because they fetch drinking water from other private water source
gen R_E_reason_nodrink_6=.
replace R_E_reason_nodrink_6=0 if R_E_reason_nodrink!=""
replace R_E_reason_nodrink_6=1 if R_E_nodrink_water_treat_oth=="Khud ka baruel hai" | ///
R_E_nodrink_water_treat_oth=="Unke ghara me khudka surakhita kuan hai," | ///
R_E_nodrink_water_treat_oth=="Khud ka boruel hai" | R_E_nodrink_water_treat_oth=="Khudka bore laga hai isliye use nhi karte hain" | ///
R_E_nodrink_water_treat_oth=="Khudka bore hai isliye" | R_E_nodrink_water_treat_oth=="Electrical Borwell achi to use korunahanti" |  ///
R_E_nodrink_water_treat_oth=="Khudka borewell hei isiliye JJM tap ka pani nahi pite hei" | ///
R_E_nodrink_water_treat_oth=="Don't need inke ghar main already Borewell hain electricity wala" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use karunahanti kohile" | ///
R_E_nodrink_water_treat_oth=="Electricity pump boring available that's and" | ///
R_E_nodrink_water_treat_oth=="Nija ghare Borwell pani achi to tap pani use korunahanti" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use koruchu" | R_E_nodrink_water_treat_oth=="Borwell achi to use karunu" | ///
R_E_nodrink_water_treat_oth=="Apna khudka borwell he ishliye tape pani pinekeliye byabahar nehikartehe" | ///
R_E_nodrink_water_treat_oth=="No connection" 

label var R_E_reason_nodrink_6 "Have other private drinking water source "
label define R_E_reason_nodrink_6 1 "Yes" 0 "No"
label values R_E_reason_nodrink_6 R_E_reason_nodrink_6

//Replacing the values in "Other" with zero after categorizing them 
replace R_E_reason_nodrink__77=0 if R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | ///
R_E_nodrink_water_treat_oth=="Hh not connected to jjm" | R_E_nodrink_water_treat_oth=="Sarakari tap nai dia hua hai is sahi me" | ///
R_E_nodrink_water_treat_oth=="Sarakari tap idhara nai dia hua hai" | R_E_nodrink_water_treat_oth=="Tap lagi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm hh tap" | R_E_nodrink_water_treat_oth=="Tap nahi diya hua hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hain" | R_E_nodrink_water_treat_oth=="Tap nahi deyegaye hain" | ///
R_E_nodrink_water_treat_oth=="Tap nahi diye gaye hai" | R_E_nodrink_water_treat_oth=="Connection nhi hai" | ///
R_E_nodrink_water_treat_oth=="Tap nahi laga hua hai" | R_E_nodrink_water_treat_oth=="Tap connection dia heini" | ///
R_E_nodrink_water_treat_oth=="Tap connection nahi" | R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Basudha  connection nehi hai  Annya logo ka jaga se hokar pipe hokar anatha bo log manakarnese pani ka connection nehi hua." | ///
R_E_nodrink_water_treat_oth=="Unki ghar me JJm tap nehi he." | R_E_nodrink_water_treat_oth=="JJm ,Basudha connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="JJm Basudha connection nehi hua hai" | R_E_nodrink_water_treat_oth=="Dia hoi nahi" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tape" | R_E_nodrink_water_treat_oth=="Not connected" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="No connection" | ///
R_E_nodrink_water_treat_oth=="Not connected to jjm tap" | R_E_nodrink_water_treat_oth=="Govt tap no connection" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM  tab connection nehi hua hai." | ///
R_E_nodrink_water_treat_oth=="Isi household meJJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household ka basudha ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Isi household me basudha ka tap connection nahi hei isi bajase wo tap pani nahin pite hei" | ///
R_E_nodrink_water_treat_oth=="Is household JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Is family me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply water not connected in this house hold" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Not connected to jjm tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hei" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hei" | R_E_nodrink_water_treat_oth=="Not connected to JJM tank" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Isi household me JJM ka tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | R_E_nodrink_water_treat_oth=="Government tap nahi." | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Jjm supply not connected this house hold" | ///
R_E_nodrink_water_treat_oth=="Is household me JJM connection nehi hua hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Esi household me JJM tap ka connection nahi hai" | ///
R_E_nodrink_water_treat_oth=="Khud ka baruel hai" | ///
R_E_nodrink_water_treat_oth=="Unke ghara me khudka surakhita kuan hai," | ///
R_E_nodrink_water_treat_oth=="Khud ka boruel hai" | R_E_nodrink_water_treat_oth=="Khudka bore laga hai isliye use nhi karte hain" | ///
R_E_nodrink_water_treat_oth=="Khudka bore hai isliye" | R_E_nodrink_water_treat_oth=="Electrical Borwell achi to use korunahanti" |  ///
R_E_nodrink_water_treat_oth=="Khudka borewell hei isiliye JJM tap ka pani nahi pite hei" | ///
R_E_nodrink_water_treat_oth=="Don't need inke ghar main already Borewell hain electricity wala" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use karunahanti kohile" | ///
R_E_nodrink_water_treat_oth=="Electricity pump boring available that's and" | ///
R_E_nodrink_water_treat_oth=="Nija ghare Borwell pani achi to tap pani use korunahanti" | ///
R_E_nodrink_water_treat_oth=="Borwell achi to use koruchu" | R_E_nodrink_water_treat_oth=="Borwell achi to use karunu" | ///
R_E_nodrink_water_treat_oth=="Apna khudka borwell he ishliye tape pani pinekeliye byabahar nehikartehe" | ///
R_E_nodrink_water_treat_oth=="No connection" | R_E_nodrink_water_treat_oth=="Ise mahine me time pe pani nahi aya esliye wo pani nahi piye hein"


// * Recoding don't know observations as missing values 
// //Reason for not drinking jjm tap water: Baseline
// foreach var in  R_Cen_a18_reason_nodrink_1 R_Cen_a18_reason_nodrink_2 R_Cen_a18_reason_nodrink_3 ///
// R_Cen_a18_reason_nodrink_4 R_Cen_a18_reason_nodrink_5 R_Cen_a18_reason_nodrink_6 R_Cen_a18_reason_nodrink__77 {
// 	replace `var'=. if R_Cen_a18_reason_nodrink=="999"
// }
// 
// //Reason for not drinking jjm tap water: Endline
// foreach var in  R_E_reason_nodrink_1 R_E_reason_nodrink_2 R_E_reason_nodrink_3 ///
// R_E_reason_nodrink_4 R_E_reason_nodrink_5 R_E_reason_nodrink_6 R_E_reason_nodrink__77 {
// 	replace `var'=. if R_E_reason_nodrink=="999"
// }


/** Responses not catergorised yet:  R_E_nodrink_water_treat_oth 
//Translations required
"Pani ru dhulli gunda baharuchhi" 
"Alga jagare rahuchacnti Sethi TAP conection deinahanti"
"Aagaru khola kua ra Pani  abhiyasa hoi jaichi boli tap Pani piu nahanti"
"Kasa haijauthiba ru piunahanti"
"Nijara achhi bali"
"3 month hogeya supply pani khud bandha kardiya hai  kunki manual Handpump ka pani unko achche lagta hai" //turned off the tap themselves or the water hasn't been supplied in three months??
"Ghare available panira subidha achi"
"Ghare available achi boli"
"Ghare pani achi to use koruchu, tap connection nahi"
"Panire poka ,machhi baharuchhi"
"Gharki borki pani agar mortar chalunehi hone se pite he."
"Handire pani rakhile siment lagila pari hauchhi"

//Unsure about the right category
"Abhi tak supply pani nehi a raha hea." //water hasnt been supplied yet (can be categorised into 1 or 3?)
"Pehele se manual handpump kapanipiyehe ishliye tap pani achanehi lagtahe ishliye manual handpump kapanipitehe" //used to drinking water from handpump and dont like tap water (can be clubbed with reason_nodrink_6_el?)
"Time houni morning utiki dhariba ku Sethi pae jjm tap use korunu" //dont have the time in the morning to fill water from JJM tap 
"Tap ru bhala Pani aasu nahi" // tap water isn't good? (can be categorised as muddy or silty???)
"Tanki saf nahin karne bajase Pani nahin pite hai" //don't drink tap water as tank is not clean (new category or muddy and silty?)
"Tanki ko saf nahi karne bajase Pani nahin pite hain" //don't drink tap water as tank is not clean (new category or muddy and silty?)
"Unki Basudha tap jo hei unki dusre jaga pe hei distance bajase pani nahin pite hei" //their basudha tap is at a diff location 
"Pani ka test achha nhi lag raha hai" //dont like the taste (can be clubbed with silty and muddy?)
"Supply watreTank nehi he ish village pe" //no water tank in the village???? - probably means no water supply 
"Ish Hamlet pe supply water nehi he" //water not supplied to this hamlet 
"Ish Hamlet pe supply water nehi he" //water not supplied to this hamlet 
"Jjm not supply in this area"
"Jjm water not supply in this hamlet"
"Paip  nehihe" //dont have a pipe
"Tap bohot distance me hai isilie" //tap is placed far from the house

//taste and smell?
"Pani ka test achha nhi lag raha hai" //dont like the taste (can be clubbed with silty and muddy?)
"Basna bohut jada hora hai" 
"Chlorine smell pain" 
"Bliching smell" 
"blinchi poudar ka smell ara hai isilie ni pura he" 

//vague
"No specific problem"
"Not safety according to Respondent"
"Not suplay to govt water"
*/

********************************************************************************
*** Generating a baseline dataset - for tables
********************************************************************************

preserve  

** Dropping the endline variables
drop R_E_*


** Removing the prefix R_Cen_
renpfix R_Cen_

** Renaming baseline variables (to make the names shorter and consistent with endline dataset created in line )
foreach var in a18_jjm_drinking a18_reason_nodrink_1 a18_reason_nodrink_2 ///
 a18_reason_nodrink_3 a18_reason_nodrink_4 a18_reason_nodrink_5 ///
 a18_reason_nodrink_6 a18_reason_nodrink__77 a18_reason_nodrink_999 a18_reason_nodrink  {
    local newname : subinstr local var "a18_" ""  // Removing prefix "a18_"
    rename `var' `newname'                      // Renaming the variable
}

foreach var in a20_jjm_use_1 a20_jjm_use_2 a20_jjm_use_3 a20_jjm_use_4 a20_jjm_use_5 ///
a20_jjm_use_6 a20_jjm_use_7 a20_jjm_use_999 a20_jjm_use__77 a20_jjm_yes a20_jjm_use {
	local newname : subinstr local var "a20_" ""  // Removing prefix "a20_"
    rename `var' `newname'  
}

** Creating new variables for tables in baseline dataset 
* Use of JJM water for drinking - Baseline
gen jjm_drinking_new=.
replace jjm_drinking_new=1 if jjm_drinking==1
replace jjm_drinking_new=0 if jjm_drinking==0 | jjm_drinking==2 //in baseline we had 3 options: Yes, No and do not have a tap connection. Recoding "do not have a tap connection" into "No" (dont use JJm for drinking)

drop jjm_drinking //dropping the old variable 
rename jjm_drinking_new jjm_drinking //renaming the new variable

label var jjm_drinking "Use JJM Water for drinking"
// label define jjm_drinking 1 "Yes" 0 "No"
// label values jjm_drinking jjm_drinking

* Use of JJM water for cooking - Baseline
gen jjm_cooking=.
replace jjm_cooking=1 if jjm_use_1==1
replace jjm_cooking=0 if jjm_use_1==0
label var jjm_cooking "Use JJM Water for cooking"
label define jjm_cooking 1 "Yes" 0 "No"
label values jjm_cooking jjm_cooking

* Use of JJM water for other purposes - Baseline
gen jjm_other_use=.
replace jjm_other_use=1 if jjm_use_1==0
replace jjm_other_use=0 if jjm_use_1==1
label var jjm_other_use "Use JJM Water for other purposes"
label define jjm_other_use 1 "Yes" 0 "No"
label values jjm_other_use jjm_other_use


** Generating a variable to identify the survey
gen survey=1 //Baseline observations 

** Saving the dataset 
save "${DataTemp}BL_temp_tapusage.dta", replace

restore //restoring the original dataset 



********************************************************************************
*** Generating an endline dataset - for tables
********************************************************************************

preserve //preserving the original dataset 

** Removing the prefix R_E_
renpfix R_E_

** Creating new variables for tables in endline dataset 
* Use of JJM water for cooking - Endline
gen jjm_cooking=.
replace jjm_cooking=1 if jjm_use_1==1
replace jjm_cooking=0 if jjm_use_1==0
label var jjm_cooking "Use JJM Water for cooking"
label define jjm_cooking 1 "Yes" 0 "No"
label values jjm_cooking jjm_cooking

* Use of JJM water for other purposes - Endline
gen jjm_other_use=.
replace jjm_other_use=1 if jjm_use_1==0
replace jjm_other_use=0 if jjm_use_1==1
label var jjm_other_use "Use JJM Water for other purposes"
label define jjm_other_use 1 "Yes" 0 "No"
label values jjm_other_use jjm_other_use

* Use of JJM water for drinking 
label var jjm_drinking "Use JJM Water for drinking"
// label define jjm_drinking 1 "Yes" 0 "No"
// label values jjm_drinking jjm_drinking

** Dropping the endline variables
drop R_Cen_*
// xx obs dropped

** Generating a variable to identify the survey
gen survey=2 //Endline observations 

** Dropping the obs present only in baseline dataset (obs whose preload information is present in the dataset but no endline information)
drop if consent==. | consent==0

** Saving the dataset 
save "${DataTemp}EL_temp_tapusage.dta", replace

restore //restoring the original dataset 



********************************************************************************
*** Appending the datasets and creating dummy variables for table
********************************************************************************
clear 
use "${DataTemp}EL_temp_tapusage.dta", clear
append using "${DataTemp}BL_temp_tapusage.dta", force //using force as some variables (not being used in table) are of different storage type in BL and EL dataset
//total obs: 1788 (BL: 914; EL: 874)

* Creating new variables to store the results of the total sample (making sure that obs are 908 in baseline and 880 in endline)
gen tap_use_drink=.
replace tap_use_drink=1 if jjm_drinking==1
replace tap_use_drink=2 if reason_nodrink_1==1
replace tap_use_drink=3 if reason_nodrink_2==1
replace tap_use_drink=4 if reason_nodrink_3==1
replace tap_use_drink=5 if reason_nodrink_4==1
replace tap_use_drink=6 if reason_nodrink_5==1
replace tap_use_drink=7 if reason_nodrink_6==1
replace tap_use_drink=8 if reason_nodrink__77==1
replace tap_use_drink=9 if reason_nodrink_999==1


label var tap_use_drink "Drinking jjm tap water"
label define tap_use_drink 1 "Use JJM tap water for drinking" 2 "Tap is broken and doesn't supply water" ///
3 "Water supply is inadequate" 4 "Water supply is intermittent" 5 "Water is muddy/silty" ///
6 "Do not have a govenment tap connection" 7 "Use a private drinking water source" 8 "Other reasons" 9 "Don't know"
label values tap_use_drink tap_use_drink


gen tap_use_oth=.
replace tap_use_oth=0 if jjm_yes==0
replace tap_use_oth=1 if jjm_cooking==1
replace tap_use_oth=2 if jjm_other_use==1

label var tap_use_oth "Using jjm water for other purposes"
label define tap_use_oth 0 "Don't use JJM water for other purposes" 1 "For cooking" 2 "For purposes besides cooking"
label values tap_use_oth tap_use_oth


* Creating dummy/indicator variables for use in tables
foreach v in tap_use_drink tap_use_oth {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS
********************************************************************************

* Saving the dataset
save "${DataTemp}temp_tapusage.dta", replace 

*Setting up global macros for calling variables
// global Govt_tap_use jjm_drinking_1 reason_nodrink_1_1 reason_nodrink_2_1 ///
// reason_nodrink_3_1 reason_nodrink_4_1 reason_nodrink_5_1 reason_nodrink_6_1 ///
// reason_nodrink__77_1 jjm_yes_1 jjm_cooking_1 jjm_other_use_1

global Govt_tap_use tap_use_drink_1 tap_use_drink_2 tap_use_drink_3 ///
tap_use_drink_4 tap_use_drink_5 tap_use_drink_6 tap_use_drink_7 tap_use_drink_8 ///
tap_use_drink_9 tap_use_oth_1 tap_use_oth_2

*Setting up local macros (to be used for labelling the table)
local Govt_tap_use "Comparing JJM Tap Water Usage across time"
local LabelGovt_tap_use "MaintableGovttap3"
local NoteGovt_tap_use "N: Baseline: 914; Endline: 880; Total: 1794 \newline \textbf{Notes:} (1) NA observations for Baseline as data were collected only for households using JJM tap water as primary or secondary source of water (2) In the baseline, 'usage of JJM tap water for drinking' included 'do not have a tap connection', which has been recoded as 'do not use JJM tap water for drinking' for consistency with the endline survey and included in 'reasons for not using tap water'" 
local ScaleGovt_tap_use "1"

* Descritive stats table: Baseline and Endline
foreach k in Govt_tap_use { //loop for all variables in the global marco 

use "${DataTemp}temp_tapusage.dta", clear //using the saved dataset 
	
	* Count: Baseline
	//Calculating the summary stats 
	keep if survey==1 //retaining only baseline observations 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Count: Endline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //retaining only endline observations 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model3: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean: Baseline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==1 //only baseline obs
	eststo  model1: estpost summarize $`k' //Baseline
	
	* Mean: Endline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //only endline obs
	eststo  model4: estpost summarize $`k' //Baseline

	* Min
	use "${DataTemp}temp_tapusage.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}temp_tapusage.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model7: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing :  Baseline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==1 //baseline
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model2: estpost summarize $`k' //summary stats of count of missing values
	
	* Missing : Endline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //endline
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

	
*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4  model5 model6 model7  using  "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	
	   mgroups("Baseline" "Endline" "Range", pattern(1 0 0 1 0 0 1 0) ///
	   prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("Obs" "Mean" "NA" "Obs" "Mean" "NA" "Min" "Max" \\) ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Use JJM tap water for drinking" "\\ Use JJM tap water for drinking" ///
				   "Tap is broken and doesn't supply water" "Do not use JJM tap water for drinking as: \\ \hspace{0.5cm}Tap is broken and doesn't supply water" ///
				   "Water supply is inadequate" "\hspace{0.5cm}Water supply is inadequate" ///
				   "Water supply is intermittent" "\hspace{0.5cm}Water supply is intermittent" ///
				   "Water is muddy/silty" "\hspace{0.5cm}Water is muddy/silty" ///
				   "Do not have a govenment tap connection" "\hspace{0.5cm}Do not have a govenment tap connection" ///
				   "Use a private drinking water source" "\hspace{0.5cm}Use a private drinking water source" ///
				   "Other reasons" "\hspace{0.5cm}Other reasons" ///
				   "For cooking" "\\ \hline \\ Use JJM tap water for other purposes \\ \hspace{0.5cm}For Cooking" ///
				   "Don't know" "\hspace{0.5cm}Don't know" ///
				   "For purposes besides cooking" "\hspace{0.5cm}For purposes besides cooking" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
	   }

	
********************************************************************************
*** Generating the table - TREATMENT v CONTROL 
********************************************************************************	

clear
use "${DataTemp}temp_tapusage.dta", clear


*Setting up global macros for calling variables
global Govt_tap_use_TvsC tap_use_drink_1 tap_use_drink_2 tap_use_drink_3 ///
tap_use_drink_4 tap_use_drink_5 tap_use_drink_6 tap_use_drink_7 tap_use_drink_8 ///
tap_use_drink_9 tap_use_oth_1 tap_use_oth_2

*Setting up local macros (to be used for labelling the table)
local Govt_tap_use_TvsC "Comparing JJM Tap Water Usage: Treatment vs Control across time"
local LabelGovt_tap_use_TvsC "MaintableGovttap4"
local NoteGovt_tap_use_TvsC "*** p<.001 ** p<.01, * p<.05 \newline N: Baseline: 914; Endline: 880; Total: 1794 \newline \textbf{Notes:} (1) NA observations for Baseline as data were collected only for households using JJM tap water as primary or secondary source of water (2) In the baseline, 'usage of JJM tap water for drinking' included 'do not have a tap connection', which has been recoded as 'do not use JJM tap water for drinking' for consistency with the endline survey and included in 'reasons for not using tap water'" 
local ScaleGovt_tap_use_TvsC "1"
	   
	   
* Descritive stats table: Treatment vs Control Groups 
foreach k in Govt_tap_use_TvsC { //loop for all variables in the global marco 

use "${DataTemp}temp_tapusage.dta", clear //using the saved dataset 
	* Count: Baseline
	//Calculating the summary stats 
	keep if survey==1 //retaining only baseline observations 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean : Baseline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==1 //keeping baseline obs
	eststo  model1: estpost summarize $`k' if Treat_V==1 // Treatment group
	eststo  model2: estpost summarize $`k' if Treat_V==0 // Control group
	
	* Diff : Baseline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==1 //keeping baseline obs
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing variables on treatment status and clusering at village level 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance: Baseline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==1 
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
	
	* Mean : Endline
	//Calculating the summary stats 
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //keeping endline obs
	eststo  model5: estpost summarize $`k' if Treat_V==1 // Treatment group
	eststo  model6: estpost summarize $`k' if Treat_V==0 // Control group
	
	* Diff : Endline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //keeping endline obs
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model7: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 
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
	eststo model8: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* Count: Endline
	use "${DataTemp}temp_tapusage.dta", clear
	keep if survey==2 //retaining only endline observations 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model9: estpost summarize $`k' //Store summary statistics of the variables with their frequency

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab model0 model1 model2 model3 model4 model9 model5 model6 model7 model8 using "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	
	   mgroups("Baseline" "Endline" , pattern(1 0 0 0 0 1 0 0 0 0) ///
	   prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "\shortstack[c]{Sig}" "\shortstack[c]{Obs}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "\shortstack[c]{Sig}") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Use JJM tap water for drinking" "\\ Use JJM tap water for drinking" ///
				   "Tap is broken and doesn't supply water" "Do not use JJM tap water for drinking as: \\ \hspace{0.5cm}Tap is broken and doesn't supply water" ///
				   "Water supply is inadequate" "\hspace{0.5cm}Water supply is inadequate" ///
				   "Water supply is intermittent" "\hspace{0.5cm}Water supply is intermittent" ///
				   "Water is muddy/silty" "\hspace{0.5cm}Water is muddy/silty" ///
				   "Do not have a govenment tap connection" "\hspace{0.5cm}Do not have a govenment tap connection" ///
				   "Use a private drinking water source" "\hspace{0.5cm}Use a private drinking water source" ///
				   "Other reasons" "\hspace{0.5cm}Other reasons" ///
				   "Use JJM tap water for other purposes" "\\ \hline \\ Use JJM tap water for other purposes" ///
				   "For cooking" "\\ \hline \\ Use JJM tap water for other purposes \\ \hspace{0.5cm}For Cooking" ///
				   "Don't know" "\hspace{0.5cm}Don't know" ///
				   "For purposes besides cooking" "\hspace{0.5cm}For purposes besides cooking" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
	   }


	
	   

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WASH BURDEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

********************************************************************************
*** getting information on new hh members from new members roster
********************************************************************************
clear 
use "${DataFinal}Endline_New_member_roster_dataset_final", clear 
preserve 
keep comb_hhmember_gender unique_id R_E_key
bysort R_E_key: gen num=_n
reshape wide  comb_hhmember_gender, i(R_E_key) j(num)
save "${DataTemp}Endline_New_member_gender_wide.dta", replace
restore 

********************************************************************************
*** Opening the Dataset 
********************************************************************************
clear
use "${DataFinal}0_Master_HHLevel.dta", clear
merge 1:1 unique_id using "${DataTemp}Endline_New_member_gender_wide.dta", gen(merge_desc_stats)
//200 obs matched 
//dropping empty variables which store the gender of the new members
drop R_E_comb_hhmember_gender*

********************************************************************************
*** Cleaning and generating new variables
*******************************************************************************


*** Changing the storage type of relevant variables
destring R_E_treat_freq R_E_treat_time R_E_collect_treat_difficult R_E_water_stored R_E_water_treat R_E_treat_primresp R_E_where_prim_locate R_E_collect_time R_E_collect_prim_freq R_E_prim_collect_resp R_E_cen_fam_age* R_E_cen_fam_gender* R_E_n_fam_age* R_E_clean_freq_containers R_E_clean_time_containers , replace


*** Manual corrections
*Replacing the values of vars to misssing
//respondent does not treat water but enumertaor incorrectly selected that respondent treats water and later mentioned that they don't treat water in the "other" category for treat_water_type
//replcing R_E_water_treat to 0: does not treat water
replace R_E_water_treat=0 if unique_id=="50401117020"

//replacing follow-up numeric vars to missing 
foreach var in R_E_collect_treat_difficult R_E_treat_freq R_E_treat_time R_E_treat_primresp   {
replace `var'=. if unique_id=="50401117020"
}

//replacing follow-up string vars to missing 
foreach var in R_E_water_treat_type R_E_treat_resp  R_E_water_treat_type_1 R_E_water_treat_type_2 R_E_water_treat_type_4 R_E_water_treat_type_3 R_E_water_treat_type_999 R_E_water_treat_type__77 {
replace `var'="" if unique_id=="50401117020"
}

*** Generating new variables - Water collection burden 
** Split the R_E_collect_resp string into separate variables
split R_E_collect_resp, parse(" ") generate(coll_resp)

** Generate variables to store the age and gender of the person actually responsible for collecting water (Stored in "R_E_prim_collect_resp")
* Create variables for storing age and gender of the water collector
gen collector_age = .
gen collector_gender = .

* Create a variable to store the selected index in "R_E_collect_resp"
gen selected_index = .

* Create a new variable to hold the correct index from collect_resp
destring coll_resp*, replace
forvalues i = 1/6 {
    * Check if resp`i' matches prim_collect_resp and assign the corresponding index
    qui replace selected_index = coll_resp`i' if `i' == R_E_prim_collect_resp
}

* Extract age and gender based on selected_index
/* Determining if selected_index refers to a Census or new member:

* If selected_index <= 20: it's a Census member
* If selected_index > 20: it's a new member
*/
// For census members
forval i=1/20 {
replace collector_age = R_E_cen_fam_age`i' if selected_index==`i' 
replace collector_gender = R_E_cen_fam_gender`i' if selected_index==`i'
}

// For new members (selected_index: max value is 23)
replace collector_age = R_E_n_fam_age1 if selected_index==21
replace collector_age = R_E_n_fam_age2 if selected_index==22
replace collector_age = R_E_n_fam_age3 if selected_index==23

replace collector_gender = comb_hhmember_gender1 if selected_index==21 
replace collector_gender = comb_hhmember_gender2 if selected_index==22 
replace collector_gender = comb_hhmember_gender3 if selected_index==23 


** Time taken to collect water from primary source
gen time_collect=.
replace time_collect=1 if R_E_collect_time>=1 & R_E_collect_time<=10 //10 minutes or less
replace time_collect=2 if R_E_collect_time>10 & R_E_collect_time<=30 //ten to thrity minutes 
replace time_collect=3 if R_E_collect_time>30 & R_E_collect_time<=60 //half an hour to one hour
replace time_collect=4 if R_E_collect_time>60  //more than one hour
replace time_collect=5 if R_E_collect_time==999 | R_E_collect_time==99 //don't know 

** Number of times water is collected from primary source: ref period one week
gen freq_collect=.
replace freq_collect=R_E_collect_prim_freq
replace freq_collect=0 if R_E_collect_prim_freq==999 //don't know 

** Whether the hh treats water or not
gen treats_water=0 
replace treats_water=1 if R_E_water_stored==1 | R_E_water_treat==1

** Generate variables to store the Age and gender of the person actually responsible for treating water(Stored in "R_E_treat_primresp")
* Split the R_E_treat_resp string into separate variables
split R_E_treat_resp, parse(" ") generate(treat_resp)

* Create variables for storing age and gender of the person who treats water
gen treat_age = .
gen treat_gender = . //1 ob missing as respondent selected that one person is responsible (treat_resp) but selected a missing obs in the person who actually treats water (treat_primresp) - should the details of the person who was selected in treat_resp be used here or should this be considered a case where the hh doesnot treat water : to check with Akito 

* Create a variable to store the selected index in "R_E_treat_resp"
gen selected_index_treat = .

* Create a new variable to hold the correct index from treat_resp
destring treat_resp*, replace
forvalues i = 1/6 {
    * Check if resp`i' matches R_E_treat_primresp and assign the corresponding index
    qui replace selected_index_treat = treat_resp`i' if `i' == R_E_treat_primresp
}

* Extract age and gender based on selected_index
/* Determining if selected_index refers to a Census or new member:

* If selected_index <= 20: it's a Census member
* If selected_index > 20: it's a new member
*/
// For census members
forval i=1/20 {
replace treat_age = R_E_cen_fam_age`i' if selected_index_treat==`i' 
replace treat_gender = R_E_cen_fam_gender`i' if selected_index_treat==`i'
}

// For new members (selected_index_treat: max value is 23)
replace treat_age = R_E_n_fam_age1 if selected_index_treat==21
replace treat_age = R_E_n_fam_age2 if selected_index_treat==22
replace treat_age = R_E_n_fam_age3 if selected_index_treat==23

replace treat_gender = comb_hhmember_gender1 if selected_index_treat==21 
replace treat_gender = comb_hhmember_gender2 if selected_index_treat==22 
replace treat_gender = comb_hhmember_gender3 if selected_index_treat==23 
replace treat_gender=0 if treats_water==0 //hh does not treat water 

** Creating new variable for age categories 
//age of person who treats water
gen treat_age_new=. 
replace treat_age_new=1 if treat_age>=1 & treat_age<15 //below 15
replace treat_age_new=2 if treat_age>=15 & treat_age<25 //15-25
replace treat_age_new=3 if treat_age>=25 & treat_age<35 //25-35
replace treat_age_new=4 if treat_age>=35 & treat_age<45 //35-45
replace treat_age_new=5 if treat_age>=45 & treat_age<55 //45-55
replace treat_age_new=6 if treat_age>=55 //above 55
replace treat_age_new=0 if treat_age==. //dont treat water + 1 addtl ob missing as respondent selected that one person is responsible (treat_resp) but selected a missing obs in the person who actually treats water (treat_primresp) - should the details of the person who was selected in treat_resp be used here or should this be considered a case where the hh doesnot treat water : to check with Akito 

//age of person who collects water 
gen collector_age_new=. 
replace collector_age_new=1 if collector_age>=1 & collector_age<15 //below 15
replace collector_age_new=2 if collector_age>=15 & collector_age<25 //15-25
replace collector_age_new=3 if collector_age>=25 & collector_age<35 //25-35
replace collector_age_new=4 if collector_age>=35 & collector_age<45 //35-45
replace collector_age_new=5 if collector_age>=45 & collector_age<55 //45-55
replace collector_age_new=6 if collector_age>=55 //above 55

** Time taken to treat water //relevance condition changed mid-survey
gen time_treat=. 
replace time_treat=1 if R_E_treat_time>=1 & R_E_treat_time<=10 //less than 10 minutes 
replace time_treat=2 if R_E_treat_time>10 & R_E_treat_time<=30 //less than 30 minutes
replace time_treat=3 if R_E_treat_time>30 & R_E_treat_time<=60 //half an hour to one hour
replace time_treat=4 if R_E_treat_time>=60  //more than one hour
replace time_treat=5 if R_E_treat_time==888 //permanent system
replace time_treat=6 if R_E_treat_time==999 | R_E_treat_time==99 //don't know
replace time_treat=0 if treats_water==0 //hh does not treat water  
 

** Water treatment method: periodic or non-periodic/nature of water treatment //relevance condition changed mid-survey
gen treat_method=. 
replace treat_method=0 if R_E_treat_freq==. | R_E_treat_freq==0 //do not treat water 
replace treat_method=1 if R_E_treat_freq==888 //permanent treatment method in place (9 observations)
replace treat_method=. if R_E_treat_freq==999 //don't know - being coded as a missing value
replace treat_method=2 if R_E_treat_freq>0 & (R_E_treat_freq!=999 & R_E_treat_freq!= 888)

** Frequency of periodic water treatment //relevance condition changed mid-survey
gen freq_treat=. 
replace freq_treat=R_E_treat_freq
replace freq_treat=0 if R_E_treat_freq==.| R_E_treat_freq==0 | R_E_treat_freq==888 | R_E_treat_freq==999 //dont treat water at all or always do 

** Difficulty in collecteing //relevance condition changed mid-way
gen difficulty_treat=. 
replace difficulty_treat=R_E_collect_treat_difficult
replace difficulty_treat=0 if treats_water==0
replace difficulty_treat=6 if R_E_collect_treat_difficult==999

 
** Frequency of cleaning containers
// replacing don't know responses as missing values
replace R_E_clean_freq_containers=. if R_E_clean_freq_containers==999
 
** Time taken to clean containers
gen time_clean_container=.
replace time_clean_container=0 if R_E_clean_freq_containers==0 //does not clean containers
replace time_clean_container=1 if R_E_clean_time_containers>=0 & R_E_clean_time_containers<=10 //less than 10 mins
replace time_clean_container=2 if R_E_clean_time_containers>10 & R_E_clean_time_containers<=30 //less than 30 mins
replace time_clean_container=3 if R_E_clean_time_containers>30 & R_E_clean_time_containers<=60 //half an hour to one hr
replace time_clean_container=4 if R_E_clean_time_containers>=60 //more than one hr
replace time_clean_container=5 if R_E_clean_time_containers==999 //dont know 



/* 3 extra missing values for treat_freq, treat_time and collect_treat_difficulty: 
Earlier the relevance condition for these variables was treatment of water by the hhs (water collected from prim source only) - these households do not treat water collected; 
The relevance was changed  mid-survey to include hhs who reported treating the stored water as well (collected from prim and sec source)- these households have treated stored water at their homes.
To check with Akito - should we categorise the observations for these three cases as hhs who do not treat water? 
*/

********************************************************************************
*** Labelling the variables
********************************************************************************
label var collector_age "Age of person person responsible for collecting water"
label var treat_age "Age of person person responsible for treating water"
label var freq_collect "Frequency of water collection"
label var freq_treat "Frequency of periodic water treatment"
label var R_E_clean_freq_containers "Frequency of cleaning water containers"

label var collector_gender "Gender of person responsible for collecting water"
label define collector_gender 1 "Male" 2 "Female"
label values collector_gender collector_gender

label var treat_gender "Gender of person responsible for treating water"
label define treat_gender 1 "Male" 2 "Female" 0 "HH Does not treat water"
label values treat_gender treat_gender

label var R_E_where_prim_locate "Location of water source"
label define R_E_where_prim_locate 1 "In own dwelling" 2 "In own yard/plot" 3 "Elsewhere"
label values R_E_where_prim_locate R_E_where_prim_locate

label var treat_method "Household Water Treatment Method"
label define treat_method 0 "No Treatment" 1 "Permanent Filtration System" 2 "Periodic Treatment"
label values treat_method treat_method

label var time_treat "Time taken to treat water"
label define time_treat 0 "HH does not treat water" 1 "10 mins or less" 2 "More than 10 minutes but upto half hour" 3 "More than half hour but upto one hour" 4 "More than one hour" 5 "Has a permanent filteration system" 6 "Dont know"
label values time_treat time_treat

label var collector_age_new "Age of person who treats water"
label define collector_age_new 1 "Below 15 years" 2 "15-25 years" 3 "25 to 35 years" 4 "35 to 45 years" 5 "45 to 55 years" 6 "Above 55 years"
label values collector_age_new collector_age_new

label var treat_age_new "Age of person who treats water"
label define treat_age_new 0 "HH does not treat water" 1 "Below 15 yrs" 2 "15-25 years" 3 "25 to 35 years" 4 "35 to 45 years" 5 "45 to 55 years" 6 "Above 55 years"
label values treat_age_new treat_age_new

label var treats_water "treats water"
label define treats_water 1 "Treats water" 0 "Does not treat water"
label values treats_water treats_water

label var time_collect "Time taken to collect water from primary source"
label define time_collect 1 "10 minutes or less" 2 "More than 10 minutes but upto half hour" 3 "More than half hour but upto one hour" 4 "More than one hour" 5 "Don't know"
label values time_collect time_collect

label var difficulty_treat "Reported Difficulty level of treating water"
label define difficulty_treat 0 "HH does not treat water" 1 "Very difficult" 2 "Somewhat difficult" 3 "Neither difficult nor easy" 4 "Somewhat easy" 5 "Very easy" 6 "Don't know"
label values difficulty_treat difficulty_treat

label var time_clean_container "Time taken to clean containers water"
label define time_clean_container 0 "HH does not clean containers" 1 "10 mins or less" 2 "More than 10 minutes but upto half hour" 3 "More than half hour but upto one hour" 4 "More than one hour" 5 "Don't know"
label values time_clean_container time_clean_container

********************************************************************************
*** Creating dummy/indicator variables for tables 
********************************************************************************

foreach v in collector_age_new collector_gender R_E_where_prim_locate time_collect ///
treats_water treat_age_new treat_gender treat_method time_treat difficulty_treat ///
time_clean_container  {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

	


********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS (Water collection burden)
********************************************************************************

*** Removing the prefix from the variables
// to ensure that they are not too long 
renpfix R_E_ 

*** Keeping only the endline observations to ensure correct number of obs in the table
keep if consent=="1"

* Saving the dataset
save "${DataTemp}temp_washburden.dta", replace 

*Setting up global macros for calling variables
global Collect_burden collector_age_new_1  collector_age_new_2 collector_age_new_3 collector_age_new_4 ///
collector_age_new_5 collector_age_new_6 collector_gender_1 collector_gender_2 ///
where_prim_locate_1 where_prim_locate_2 where_prim_locate_3 ///
freq_collect time_collect_1 time_collect_2 time_collect_3 time_collect_4 time_collect_5 ///
clean_freq_containers time_clean_container_1 time_clean_container_2 ///
time_clean_container_3 time_clean_container_4 time_clean_container_5


*Setting up local macros (to be used for labelling the table)
local Collect_burden "Insights into the burden of water collection"
local LabelCollect_burden "MaintableCollectBurden"
local NoteCollect_burden "N: Endline: 880 \newline \textbf{Notes:} (1)*: One observation missing as respondent indicated an individual is responsible for water collection but did not specify who. (2)**: 3 observations missing as respondents did not know the frequency of cleaning drinking water containers." 
local ScaleCollect_burden "1"

* Descritive stats table: Baseline and Endline
foreach k in Collect_burden { //loop for all variables in the global marco 
	
	* Count 
	use "${DataTemp}temp_washburden.dta", clear //using the saved dataset 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model1: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}temp_washburden.dta", clear
	eststo  model2: estpost summarize $`k' //Baseline

	* Standard Deviation 
    use "${DataTemp}temp_washburden.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model3: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values

	* Min
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of maximum value
	
	
	* Missing 
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model6: estpost summarize $`k' //summary stats of count of missing values

	
*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model1 model2 model3 model4  model5 model6  using  "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	
	   mtitles("Obs" "Mean" "SD" "Min" "Max" "Missing" \\) ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Below 15 years" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Characteristics of individual responsible for collecting water}}\\ Age  \\ \hspace{0.5cm}Below 15 years" ///
				   "15-25 years" "\hspace{0.5cm}15 to 25 years" ///
				   "25 to 35 years" "\hspace{0.5cm}25 to 35 years" ///
				   "35 to 45 years" "\hspace{0.5cm}35 to 45 years" ///
				   "45 to 55 years" "\hspace{0.5cm}45 to 55 years" ///
				   "Above 55 years" "\hspace{0.5cm}Above 55 years" ///
				   "Male" "Gender* \\ \hspace{0.5cm}Male" ///
				   "Female" "\hspace{0.5cm}Female" ///
				   "In own dwelling" "\\ \multicolumn{7}{c}{\textbf{Panel 2: Collection of water from the primary source }}\\ Location of primary water source \\ \hspace{0.5cm}In own dwelling" ///
				   "In own yard/plot" "\hspace{0.5cm}In own yard/plot" ///
				   "Elsewhere" "\hspace{0.5cm}Elsewhere" ///
				   "Frequency of water collection" "Frequency of collecting water" ///
				   "10 minutes or less" "Time spent in collecting water\\ \hspace{0.5cm}10 minutes or less" ///
				   "More than 10 minutes but upto half hour" "\hspace{0.5cm}More than 10 minutes but upto half hour" ///
				   "More than half hour but upto one hour" "\hspace{0.5cm}More than half hour but upto one hour" ///
				   "More than one hour" "\hspace{0.5cm}More than one hour" ///
				   "Don't know" "\hspace{0.5cm}Don't know" ///			
				   "Frequency of cleaning water containers" "\\ \multicolumn{7}{c}{\textbf{Panel 3: Cleaning of drinking water storage containers}}\\ Frequency**" ///
				   "10 mins or less" "Time spent\\ \hspace{0.5cm}10 minutes or less" ///
				    "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				    "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
	   }

	
********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS (Water treatment burden)
********************************************************************************

*Setting up global macros for calling variables
global Treat_burden treats_water_0 treats_water_1  treat_method_1 treat_method_2  ///
freq_treat  time_treat_1 time_treat_2 time_treat_3 time_treat_4 ///
time_treat_5  time_treat_6 treat_age_new_1 treat_age_new_2 ///
treat_age_new_3 treat_age_new_4 treat_age_new_5 treat_age_new_6 treat_gender_1 ///
treat_gender_2 difficulty_treat_1 difficulty_treat_2 difficulty_treat_3 ///
difficulty_treat_4 difficulty_treat_5 difficulty_treat_6 

*Setting up local macros (to be used for labelling the table)
local Treat_burden "Insights into the burden of water treatment"
local LabelTreat_burden "MaintableTreatBurden"
local NoteTreat_burden "N: Endline: 880 \newline \textbf{Notes:} (1)*: One observation missing as the respondent doesn't know if water which method is being used to treat water (2)**: One observation missing as respondent indicated an individual is responsible for water treatment but did not specify who. (3)***: 4 observations missing as relevance condition was changed for the question"
local ScaleTreat_burden "1"

* Descritive stats table: Baseline and Endline
foreach k in Treat_burden { //loop for all variables in the global marco 
	
	* Count 
	use "${DataTemp}temp_washburden.dta", clear //using the saved dataset 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model1: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}temp_washburden.dta", clear
	eststo  model2: estpost summarize $`k' //Baseline

	* Standard Deviation 
    use "${DataTemp}temp_washburden.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model3: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values

	* Min
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of maximum value
	
	
	* Missing 
	use "${DataTemp}temp_washburden.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model6: estpost summarize $`k' //summary stats of count of missing values

	
*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model1 model2 model3 model4  model5 model6  using  "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	
	   mtitles("Obs" "Mean" "SD" "Min" "Max" "Missing" \\) ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Does not treat water" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Water treatment by the households }} \\ Do not treat the water" ///
				   "Treats water" "Treat the water" ///
				   "Permanent Filtration System" "Nature of water treatment method* \\ \hspace{0.5cm}Permanent filtration system" ///
				   "Periodic Treatment" "\hspace{0.5cm}Periodic treatment system" ///
 				   "10 mins or less" "Time spent on periodic water treatment \\ \hspace{0.5cm}10 minutes or less" ///
				   "More than 10 minutes but upto half hour" "\hspace{0.5cm}More than 10 minutes but upto half hour" ///
				   "More than half hour but upto one hour" "\hspace{0.5cm}More than half hour but upto one hour" ///
				   "More than one hour" "\hspace{0.5cm}More than one hour" ///
				   "Has a permanent filteration system" "\hspace{0.5cm}Has a permanent filteration system" ///
				   "Dont know" "\hspace{0.5cm}Don't know" ///				   
				   "Below 15 yrs" "\\ \multicolumn{7}{c}{\textbf{Panel 2: Characteristics of individual responsible for periodic water treatment}} \\ Age \\ \hspace{0.5cm}Below 15 years" ///
				   "15-25 years" "\hspace{0.5cm}15 to 25 years" ///
				   "25 to 35 years" "\hspace{0.5cm}25 to 35 years" ///
				   "35 to 45 years" "\hspace{0.5cm}35 to 45 years" ///
				   "45 to 55 years" "\hspace{0.5cm}45 to 55 years" ///
				   "Above 55 years" "\hspace{0.5cm}Above 55 years" ///
				   "Male" "Gender** \\ \hspace{0.5cm}Male" ///
				   "Female" "\hspace{0.5cm}Female" ///
				   "Very difficult" "\\ \multicolumn{7}{c}{\textbf{Panel 3: Reported difficulty level of treating water***}} \\ Very difficult" ///
				    "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				    "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`Note`k''") 
	   }

	   






