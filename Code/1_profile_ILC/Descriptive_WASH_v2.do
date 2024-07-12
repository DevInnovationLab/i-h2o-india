
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Descriptive template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
*** Using the cleaned endline dataset 

/***************************************************************

What all to include in the table from WASH sources
***************************
1. Primary Water sources:
****************************
a) Using govt. taps as primary drinking water 
b) Do your youngest children drink from the same water source as the household’s primary drinking water source i.e (${primary_water_label}) ?
c) Using govt. taps as the primary drinking water source for your youngest children
d) Do pregnant women drink from the same water source as the household’s primary drinking water source i.e (${primary_water_label}) ?
e) Using govt. taps as the primary drinking water source for your pregnant women?
f)Using govt. taps as secondary drinking water 
g) In the past week, how much of your drinking water came from your primary drinking water source: (${primary_water_label})?

***************************
2. Secondary Water sources:
****************************
a) In the past month, did your household use any sources of water for drinking besides ${primary_water_label}?
b)In the past month, what other water sources has your household used for drinking?
c)In what circumstances do you collect drinking water from these other water sources?
d)What is the most used secondary water source among these sources for drinking purpose?
e)Generally, when do you collect water for drinking from these other/secondary water sources?

**********************
3. Water Treatment
*************************

Water Treatment - General
In the last one month, did your household do anything extra to the drinking water (${primary_water_label} ) to make it safe before drinking it?
For the water that is currently stored in the household, did you do anything extra to the drinking water to make it safe for drinking treated? (This is for both primary and secondary source)
What do you do to the water from the primary source (${primary_water_label}) to make it safe for drinking?
If Other, please specify:
When do you make the water from your primary drinking water source (${primary_water_label}) safe before drinking it?
If Other, please specify:
In the past 2 weeks, have you ever decided not to treat your water because you didn’t have enough time?
How often do you make the water currently stored at home safe for drinking?
If Other, please specify:
Water Treatment - U5
Do you ever do anything to the water for your youngest children to make it safe for drinking?
What do you do to the water for your youngest children (children under 5) to make it safe for drinking?
If Other, please specify:
For your youngest children, when do you make the water safe before they drink it?
If Other, please specify: 
Do you treat the water before drinking in your household?

***************************************************************/
use "${DataFinal}0_Master_HHLevel.dta", clear


*Recoding the 'other' response as '77' (for creation of indicator variables in lines 21 to 29)
foreach i in R_Cen_a12_water_source_prim R_E_water_source_prim R_Cen_a17_water_source_kids R_E_water_source_kids R_Cen_water_prim_source_kids R_E_water_prim_source_kids R_E_water_source_preg R_E_water_prim_source_preg R_E_quant R_E_water_sec_yn R_Cen_a13_water_sec_yn R_Cen_a15_water_sec_freq R_Cen_a16_water_treat  R_E_water_treat R_Cen_a16_stored_treat R_E_water_stored R_E_not_treat_tim R_Cen_a16_stored_treat_freq R_Cen_a17_water_treat_kids R_E_water_treat_kids  {
	replace `i'= 77 if `i'== -77
	replace `i' = 98 if `i' == -98
	replace `i' = 999 if `i' == -99 | `i' == 99
}

keep unique_id R_Cen_a12_water_source_prim R_E_water_source_prim R_Cen_a17_water_source_kids R_E_water_source_kids R_Cen_water_prim_source_kids R_E_water_prim_source_kids R_E_water_source_preg R_E_water_prim_source_preg R_E_quant R_Cen_a13_water_sec_yn R_E_water_sec_yn R_Cen_a13_water_source_sec R_Cen_a13_water_source_sec_1 R_Cen_a13_water_source_sec_2 R_Cen_a13_water_source_sec_3 R_Cen_a13_water_source_sec_4 R_Cen_a13_water_source_sec_5 R_Cen_a13_water_source_sec_6 R_Cen_a13_water_source_sec_7 R_Cen_a13_water_source_sec_8 R_Cen_a13_water_source_sec__77 R_E_water_source_sec R_E_water_source_sec_1 R_E_water_source_sec_2 R_E_water_source_sec_3 R_E_water_source_sec_4 R_E_water_source_sec_5 R_E_water_source_sec_6 R_E_water_source_sec_7 R_E_water_source_sec_8 R_E_water_source_sec_9 R_E_water_source_sec_10 R_E_water_source_sec__77 R_Cen_a14_sec_source_reason R_Cen_a14_sec_source_reason_1 R_Cen_a14_sec_source_reason_2 R_Cen_a14_sec_source_reason_3 R_Cen_a14_sec_source_reason_4 R_Cen_a14_sec_source_reason_5 R_Cen_a14_sec_source_reason_6 R_Cen_a14_sec_source_reason_7 R_Cen_a14_sec_source_reason__77 R_Cen_a14_sec_source_reason_999 R_E_sec_source_reason R_E_sec_source_reason_1 R_E_sec_source_reason_2 R_E_sec_source_reason_3 R_E_sec_source_reason_4 R_E_sec_source_reason_5 R_E_sec_source_reason_6 R_E_sec_source_reason_7 R_E_sec_source_reason__77 R_E_sec_source_reason_999 R_E_sec_source_reason_oth R_E_water_source_main_sec R_Cen_a15_water_sec_freq R_E_water_sec_freq R_Cen_a16_water_treat R_E_water_treat R_Cen_a16_stored_treat R_E_water_stored R_Cen_a16_water_treat_type R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type_999 R_Cen_a16_water_treat_type__77 R_E_water_treat_type R_E_water_treat_type_1 R_E_water_treat_type_2 R_E_water_treat_type_3 R_E_water_treat_type_4 R_E_water_treat_type_999 R_E_water_treat_type__77 R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_freq_1 R_Cen_a16_water_treat_freq_2 R_Cen_a16_water_treat_freq_3 R_Cen_a16_water_treat_freq_4 R_Cen_a16_water_treat_freq_5 R_Cen_a16_water_treat_freq_6 R_Cen_a16_water_treat_freq__77 R_E_water_treat_freq R_E_water_treat_freq_1 R_E_water_treat_freq_2 R_E_water_treat_freq_3 R_E_water_treat_freq_4 R_E_water_treat_freq_5 R_E_water_treat_freq_6 R_E_water_treat_freq__77 R_E_not_treat_tim R_Cen_a16_stored_treat_freq R_Cen_a17_water_treat_kids R_E_water_treat_kids R_Cen_water_treat_kids_type R_Cen_water_treat_kids_type_1 R_Cen_water_treat_kids_type_2 R_Cen_water_treat_kids_type_3 R_Cen_water_treat_kids_type_4 R_Cen_water_treat_kids_type_999 R_Cen_water_treat_kids_type__77 R_E_water_treat_kids_type R_E_water_treat_kids_type_1 R_E_water_treat_kids_type_2 R_E_water_treat_kids_type_3 R_E_water_treat_kids_type_4 R_E_water_treat_kids_type_999 R_E_water_treat_kids_type__77 R_Cen_a17_treat_kids_freq R_Cen_a17_treat_kids_freq_1 R_Cen_a17_treat_kids_freq_2 R_Cen_a17_treat_kids_freq_3 R_Cen_a17_treat_kids_freq_4 R_Cen_a17_treat_kids_freq_5 R_Cen_a17_treat_kids_freq_6 R_Cen_a17_treat_kids_freq__77 R_E_treat_kids_freq R_E_treat_kids_freq_1 R_E_treat_kids_freq_2 R_E_treat_kids_freq_3 R_E_treat_kids_freq_4 R_E_treat_kids_freq_5 R_E_treat_kids_freq_6 R_E_treat_kids_freq__77 R_Cen_consent R_E_consent 

/*************************************************************
//VARIABLE NAMES THAT NEED TO BE CHNAGED 
**************************************************************/

rename R_Cen_a12_water_source_prim R_Cen_water_source_prim
rename R_Cen_a17_water_source_kids R_Cen_water_source_kids
rename R_Cen_a13_water_sec_yn R_Cen_water_sec_yn
rename R_Cen_a13_water_source_sec R_Cen_water_source_sec

forvalues i = 1/8{
cap rename R_Cen_a13_water_source_sec_`i' R_Cen_water_source_sec_`i'
}

rename R_Cen_a13_water_source_sec__77 R_Cen_water_source_sec__77 
rename R_Cen_a14_sec_source_reason R_Cen_sec_source_reason

forvalues i = 1/999{
cap rename R_Cen_a14_sec_source_reason_`i' R_Cen_sec_source_reason_`i'
}

rename R_Cen_a14_sec_source_reason__77 R_Cen_sec_source_reason__77

rename R_Cen_a16_water_treat R_Cen_water_treat

rename R_Cen_a16_stored_treat R_Cen_water_stored

rename R_Cen_a16_water_treat_type R_Cen_water_treat_type

forvalues i = 1/999{
cap rename R_Cen_a16_water_treat_type_`i' R_Cen_water_treat_type_`i'
}

rename  R_Cen_a16_water_treat_type__77 R_Cen_water_treat_type__77

rename R_Cen_a16_water_treat_freq R_Cen_water_treat_freq

forvalues i = 1/6{
cap rename R_Cen_a16_water_treat_freq_`i' R_Cen_water_treat_freq_`i'
}

rename R_Cen_a16_water_treat_freq__77 R_Cen_water_treat_freq__77


rename R_Cen_a17_water_treat_kids R_Cen_water_treat_kids


rename R_Cen_a17_treat_kids_freq R_Cen_treat_kids_freq


forvalues i = 1/6{
cap rename R_Cen_a17_treat_kids_freq_`i' R_Cen_treat_kids_freq_`i'
}

rename R_Cen_a17_treat_kids_freq__77 R_Cen_treat_kids_freq__77

rename R_Cen_a15_water_sec_freq R_Cen_water_sec_freq

preserve

drop R_Cen_*

renpfix R_E_

gen survey_type = "E" 

drop if consent != 1

save "${DataTemp}Temp_RE.dta", replace 

restore

preserve

drop R_E_*

renpfix R_Cen_

gen survey_type = "C" 

drop if consent != 1

save "${DataTemp}Temp_Cen.dta", replace

restore

use "${DataTemp}Temp_RE.dta", clear

append using "${DataTemp}Temp_Cen.dta"

gen survey_type_num = .

replace survey_type_num = 0 if survey_type == "C"

replace survey_type_num = 1 if survey_type == "E"

label define water_source_prim_x 1 "JJM"  2 "Government provided community standpipe" 3	"Gram Panchayat/Other Community Standpipe (e.g. non-Basudha source)" ///
4 "Manual handpump" 5	"Covered dug well" 6 "Directly fetched by surface water"  7 "Uncovered dug well" 8 "Private Surface well" 9	"Borewell operated by electric pump" 10 "Non-JJM Household tap connections" 77 "Other"  
 
label values water_source_prim water_source_prim_x

label define water_prim_source_kids_x 1 "JJM"  2 "Government provided community standpipe" 3	"Gram Panchayat/Other Community Standpipe (e.g. non-Basudha source)" ///
4 "Manual handpump" 5	"Covered dug well" 6 "Directly fetched by surface water"  7 "Uncovered dug well" 8 "Private Surface well" 9	"Borewell operated by electric pump" 10 "Non-JJM Household tap connections" 77 "Other"  
 
label values water_prim_source_kids water_prim_source_kids_x


replace water_stored = 0 if water_stored == 2

label define water_stored_x 1 "Yes" 0 "No" 

label values water_stored water_stored_x

*Generating indicator variables for each unique value of variables specified in the loop


foreach v in water_source_prim water_source_kids water_prim_source_kids water_source_preg water_prim_source_preg quant water_sec_yn water_sec_freq water_treat water_stored a16_stored_treat_freq water_treat_kids not_treat_tim  {
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


//this command shows that there is no such case where HH says that JJM isn't their primary source and they say that children drink from a different primary source and if that prim source is JJM 

//that is why I did replacement here because there was no constrain in the baseline census to take care of the same 

br  water_source_kids water_prim_source_kids water_source_prim  if  water_prim_source_kids == 1 & water_source_prim == 1 & water_source_kids == 0

replace water_source_kids = 1 if  water_prim_source_kids == 1 & water_source_prim == 1 & water_source_kids == 0

gen flag = .

replace flag = 1 if water_source_kids == 0 & water_prim_source_kids == water_source_prim

br survey_type water_source_prim  water_source_kids water_prim_source_kids if flag == 1

replace  water_source_kids = 1 if water_source_kids == 0 & water_prim_source_kids == water_source_prim


//Youngest child primary water source being non-JJM but main HH source being JJM 

gen U5_nonjjm_water_source = .
replace U5_nonjjm_water_source  = 1 if water_source_prim_1 == 1 &  water_source_kids_0 == 1 & water_prim_source_kids_1 == 0

br U5_nonjjm_water_source water_source_prim water_source_kids water_prim_source_kids  if U5_nonjjm_water_source  == 1


//Youngest child primary water source being JJM but main HH source being non-JJM 	

gen U5_jjm_water_source = .
replace U5_jjm_water_source  = 1 if water_source_prim_1 != 1 &  water_source_kids_0 == 1 & water_prim_source_kids_1 == 1

br U5_jjm_water_source water_source_prim water_source_kids water_prim_source_kids  if U5_jjm_water_source  == 1


//JJM Treatment vars 
gen treat_JJM = .
replace treat_JJM = 1  if water_treat_1 == 1 & water_source_prim_1 == 1



*** Labelling the variables for use in descriptive stats table
label var water_source_prim_1 "Using govt. taps as primary drinking water"
label var water_source_sec_1 "Using govt. taps as secondary drinking water"
label var water_source_kids_0 "U5 children drinking from a different primary water source"
label var water_prim_source_kids_1 "U5 children primary source is JJM" 
label var U5_nonjjm_water_source "U5 children drinking from other primary sources(non-JJM)"
label var U5_jjm_water_source "U5 children drinking from JJM but not HH"
label var water_source_preg_1 "Pregnant women drinking from the same primary water source as HH"


label var water_treat_1 "Water treatment for primary source"

label var  water_stored_1 "Stored water treatment" 

label var water_treat_type_1 "Filter the water through a cloth or sieve" 
label var  water_treat_type_2 "Let the water stand for some time before drinking" 
label var  water_treat_type_3 "Boil the water" 
label var  water_treat_type_4 "Add chlorine/ bleaching powder" 
label var water_treat_type__77 "Other" 
label var water_treat_type_999 "Don't know" 


label var water_treat_freq_1 "Always treat the water" 
label var water_treat_freq_2 "Treat the water in the summers" 
label var water_treat_freq_3 "Treat the water in the monsoons" 
label var water_treat_freq_4 "Treat the water in the winters" 
label var water_treat_freq_5 "Treat the water when kids/ old people fall sick" 
label var water_treat_freq_6 "Treat the water when it looks or smells dirty" 
label var water_treat_freq__77 "Other"

label var not_treat_tim_1 "In the past 2 weeks, water bot treated because of lack of time"

label var a16_stored_treat_freq_0 "Once at the time of storing" 
label var a16_stored_treat_freq_1 "Every time the stored water is used" 
label var a16_stored_treat_freq_2 "Daily"
label var a16_stored_treat_freq_3 "2-3 times a day" 
label var a16_stored_treat_freq_4 "Every 2-3 days in a week"
label var a16_stored_treat_freq_5   "No fixed schedule" 

label var water_treat_kids_1  "Water treatment for youngest children in HH" 

label var water_treat_kids_type_1 "Filter the water through a cloth or sieve for U5 kids" 
label var  water_treat_kids_type_2  "Let the water stand for some time before drinking for U5 kids" 
label var  water_treat_kids_type_3 "Boil the water for U5 kids" 
label var  water_treat_kids_type_4 "Add chlorine/ bleaching powder for U5 kids" 
label var water_treat_kids_type__77 "Other" 
label var water_treat_kids_type_999 "Don't know" 



label var treat_kids_freq_1 "Always treat the water for U5 kids" 
label var  treat_kids_freq_2 "Treat the water in the summers for U5 kids" 
label var treat_kids_freq_3 "Treat the water in the monsoons for U5 kids" 
label var treat_kids_freq_4 "Treat the water in the winters for U5 kids" 
label var treat_kids_freq_5 "Treat the water when kids/ old people fall sick for U5 kids" 
label var  treat_kids_freq_6 "Treat the water when it looks or smells dirty for U5 kids" 
label var treat_kids_freq__77 "Other"





*** Saving the dataset 
save "${DataTemp}Temp.dta", replace

//water_prim_source_kids_1 U5_nonjjm_water_source water_source_preg_1

*** Creation of the table
*Setting up global macros for calling variables
global PanelA water_source_prim_1  water_source_sec_1 water_source_kids_0  water_treat_1 water_stored_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 water_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999

*Setting up local macros (to be used for labelling the table)
local PanelA "WASH Characteristics Baseline vs Endline"
local LabelPanelA "MaintableHH"
*local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA "1"

* By R_Enr_treatment 
foreach k in PanelA { //loop for all variables in the global marco 

use "${DataTemp}Temp.dta", clear //using the saved dataset 
***********
** Table **
***********

* obs 


* Mean
	//Calculating the summary stats of treatment and control group for each variable and storing them
		
	eststo  model1: estpost summarize $`k' if survey_type_num  == 0 //baseline villages
	eststo  model2: estpost summarize $`k' if survey_type_num  == 1 //endline villages
	
/*	* Diff 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	///reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 129
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of p values
*/




	* Min
	//for baseline 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	*Min
	//for endline 
    use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary 
	
	* Max
	//for baseline 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of maximum value
	
	//for endline 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of maximum value

	
	* Missing 
	//for baseline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Missing 
	//for endline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values


		* SD 
		//for baseline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
		* SD 
		//for endline	
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model10: estpost summarize $`k'


	* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model11: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	
		* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model12: estpost summarize $`k' //Store summary statistics of the variables with their frequency

	
//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)

//arranging the models in a way so that Obs Mean Missing SD order is followed for both baseline and endline
esttab model11 model1 model7 model9 model12 model2 model8 model10  using "${Table}Test_Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\multicolumn{4}{c}{Baseline}" "\multicolumn{4}{c}{Endline}"  \\ "\multicolumn{1}{c}{Obs}" "\multicolumn{1}{c}{Mean}" "\multicolumn{1}{c}{Missing}" "\multicolumn{1}{c}{SD}" "\multicolumn{1}{c}{Obs}" "\multicolumn{1}{c}{Mean}" "\multicolumn{1}{c}{Missing}" "\multicolumn{1}{c}{SD}") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&                _\\" "" ///
				   "Using govt. taps as primary drinking water" "\hline \multicolumn{5}{c}{\textbf{Water sources}} \\ Using govt. taps as primary drinking water" ///
				   "Water treatment for primary source" "\hline \multicolumn{5}{c}{\textbf{Water Treatment}} \\ Water treatment for primary source" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment} \\ Filter the water through a cloth or sieve" ///
				   "Always treat the water" "\textbf{Frequency of the treatment} \\ Always treat the water" ///
				   "Once at the time of storing" "\textbf{Frequency of the stored water treatment} \\ Once at the time of storing" ///
				   "Filter the water through a cloth or sieve for U5 kids" "\textbf{Types of Treatment for U5 kids} \\ Filter the water through a cloth or sieve for U5 kids" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")
}

