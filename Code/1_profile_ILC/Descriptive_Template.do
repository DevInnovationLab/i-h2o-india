
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Descriptive template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
*** Using the cleaned endline dataset 
use "${DataRaw}1_8_Endline/1_8_Endline_Census_cleaned_consented.dta", clear


*** Generating relevant variables 
*JJM Tap used only as secondary source
gen sec_jjm_use=0
replace sec_jjm_use=1 if R_E_water_source_sec_1==1 & R_E_water_source_prim!=1
tab sec_jjm_use

*Recoding the 'other' response as '77' (for creation of indicator variables in lines 21 to 29)
foreach i in R_E_water_source_prim  {
	replace `i'=77 if `i'==-77
}

*Generating indicator variables for each unique value of variables specified in the loop
foreach v in R_E_water_treat R_E_water_source_prim R_E_jjm_drinking  {
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
	
	
*** Labelling the variables for use in descriptive stats table
label var R_E_water_source_prim_1 "Using govt. taps as primary drinking water"
label var sec_jjm_use "Using govt. taps as secondary drinking water"
label var R_E_jjm_drinking_1 "Using JJM taps for drinking"
label var R_E_water_treat_1 "Using any water treatment method"

*** Saving the dataset 
save "${DataTemp}Temp.dta", replace

*** Creation of the table
*Setting up global macros for calling variables
global PanelA R_E_water_source_prim_1 sec_jjm_use R_E_jjm_drinking_1 R_E_water_treat_1

*Setting up local macros (to be used for labelling the table)
local PanelA "Endline TC"
local LabelPanelA "MaintableHH"
local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA "1"

* By R_Enr_treatment 
foreach k in PanelA { //loop for all variables in the global marco 

use "${DataTemp}Temp.dta", clear //using the saved dataset 
***********
** Table **
***********
* Mean
	//Calculating the summary stats of treatment and control group for each variable and storing them
	eststo  model1: estpost summarize $`k' if Treat_V==1 //Treatment villages
	eststo  model2: estpost summarize $`k' if Treat_V==0 //Control villages
	
	* Diff 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
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

	* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model7: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values

//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab model1 model2 model3 model4 model5 model6 model7 model8 using "${Table}Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") mtitles("\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Min" "Max" "Missing") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Number of days with diarrhea" "\hline Number of days with diarrhea" ///
				   "Using govt. taps as primary drinking water" "\textbf{Panel A. Water sources \& treatment} \\Using govt. taps as primary drinking water" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
}




