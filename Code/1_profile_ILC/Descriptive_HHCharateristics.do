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
use "${DataFinal}0_Master_HHLevel_NB.dta", clear
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

//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab model0 model1 model2 model3 model4 model5 model6 model7 model8 using "${Table}DescriptiveStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{Total}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Min" "Max" "Missing") ///
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
	

