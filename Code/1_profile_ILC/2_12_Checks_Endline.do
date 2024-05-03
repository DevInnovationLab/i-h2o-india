*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports..... Cleaned data for Endline survey

*=========================================================================*
* Import data
*=========================================================================*
	
	use "${DataPre}1_8_Endline/1_8_Endline_Census_cleaned.dta", clear
	
*=========================================================================* 
* Setting today's date
*=========================================================================*

	local datestamp = substr(c(current_date),1,11)
	
	
*=========================================================================*
* Number of surveys by Village - Total
*=========================================================================*

	preserve
	
	bys R_E_r_cen_village_name_str: egen survey_nbr = count(unique_id)  // total
	bys R_E_r_cen_village_name_str: egen consent_yes = count(unique_id) if R_E_consent == 1  // consent hhs
	bys R_E_r_cen_village_name_str: egen consent_no = count(unique_id)  if R_E_consent == 0  //  NOT consent hhs
	
	foreach var of varlist survey_nbr consent_no consent_yes {
		replace `var' = 0 if `var' ==.
	}
    *Export
	
	keep R_E_r_cen_village_name_str survey_nbr consent_yes consent_no 
	collapse (max) survey_nbr consent_yes consent_no , by(R_E_r_cen_village_name_str)
	
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Village_Total, modify) cell(A10)
	restore
	
	
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Village_Total") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Number of surveys per village", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Village"
	putexcel B10= "Total Submissions"
	putexcel C10= "Consent HHs"
	putexcel D10= "Non Consent HHs"
	
	
*=========================================================================*
* Number of surveys by Village - by day
*=========================================================================*

	preserve
	
	bys R_E_r_cen_village_name_str End_date: egen survey_nbr = count(unique_id)  // total
	bys R_E_r_cen_village_name_str End_date: egen consent_yes = count(unique_id) if R_E_consent == 1  // consent hhs
	bys R_E_r_cen_village_name_str End_date: egen consent_no = count(unique_id)  if R_E_consent == 0  //  NOT consent hhs
	
	foreach var of varlist survey_nbr consent_no consent_yes {
		replace `var' = 0 if `var' ==.
	}
    *Export
	
	keep R_E_r_cen_village_name_str survey_nbr consent_yes consent_no End_date
	rename End_date date
	collapse (max) survey_nbr consent_yes consent_no , by(R_E_r_cen_village_name_str date)
	order R_E_r_cen_village_name_str survey_nbr consent_yes consent_no date
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Village_Day, modify) cell(A10)
	
	restore
	
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Village_Day") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Number of surveys per village per day", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Village"
	putexcel B10= "Total Submissions"
	putexcel C10= "Consent HHs"
	putexcel D10= "Non Consent HHs"
	putexcel E10= "Date"
	
	
	
*=========================================================================*
* Number of surveys by Enumerator - Total
*=========================================================================*

	preserve
	
	bys R_E_enum_name: egen survey_nbr = count(unique_id)  // total
	bys R_E_enum_name: egen consent_yes = count(unique_id) if R_E_consent == 1  // consent hhs
	bys R_E_enum_name: egen consent_no = count(unique_id)  if R_E_consent == 0  //  NOT consent hhs
	
	foreach var of varlist survey_nbr consent_no consent_yes {
		replace `var' = 0 if `var' ==.
	}
    *Export
	
	keep R_E_enum_name survey_nbr consent_yes consent_no 
	collapse (max) survey_nbr consent_yes consent_no , by(R_E_enum_name)
	
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Enumerator_Total, modify) cell(A10)
	restore
	
	
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Enumerator_Total") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Number of surveys per enumerator", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Enumerator Name"
	putexcel B10= "Total Submissions"
	putexcel C10= "Consent HHs"
	putexcel D10= "Non Consent HHs"
	

	
*=========================================================================*
* Number of surveys by Enumerator - Day
*=========================================================================*

	preserve
	
	bys R_E_enum_name End_date: egen survey_nbr = count(unique_id)  // total
	
	keep R_E_enum_name survey_nbr End_date
	collapse (max) survey_nbr, by(R_E_enum_name End_date)
	
	reshape wide survey_nbr, i(R_E_enum_name) j(End_date)
	local  i 1
	foreach var of varlist survey_nbr*{
		rename `var' day_`i'
		local ++i
	}
	
	foreach var of varlist day_*{
		replace `var' = 0 if `var' == .
	}
	
	
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Enumerator_Day, modify) cell(A10)
	restore
	
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Enumerator_Day") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Number of surveys per enumerator per day", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Enumerator Name"
	
	

*=========================================================================*
* Survey duration per enumerator
*=========================================================================*
	
	preserve
	
	bys R_E_enum_name: egen enum_duration = mean(diff_minutes)
	
	keep R_E_enum_name enum_duration 
	duplicates drop R_E_enum_name, force
	sort R_E_enum_name
	order R_E_enum_name enum_duration
	
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Enum_duration, modify) cell(A10)
	restore
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Enum_duration") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Duration by enumerator", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Enumerator Name",
	putexcel B10= "Duration (in minutes)", txtwrap

	
*=========================================================================*
*  Enumerator level productivity
*=========================================================================*
	
	preserve
	keep if R_E_consent == 1
	egen tag = tag(R_E_enum_name End_date)
	egen days_worked = total(tag), by(R_E_enum_name)
	bys R_E_enum_name: gen total_surveys_done = _N
	gen daily_avg = round(total_surveys_done/days_worked, .01) // average productivity per day by surveyor
	tabdisp R_E_enum_name, c(days_worked total_surveys_done daily_avg) format(%9.2f) center
	qui sum daily_avg if tag, d
	qui gen sds= (daily_avg - r(mean))/ r(sd)
	qui egen tag2 = tag(R_E_enum_name)
	
	
	
	keep R_E_enum_name days_worked total_surveys_done daily_avg
	duplicates drop
	order R_E_enum_name
	sort R_E_enum_name days_worked total_surveys_done daily_avg 
	export excel using "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", firstrow(variables) sheet(Enum_productivity, modify) cell(A10)
	restore
	
	*Format exports
	putexcel set "${DataPre}1_8_Endline/HFC_$S_DATE.xlsx", sheet("Enum_productivity") modify
	
	putexcel B2:K2 = "HFCs for Endline Survey", merge hcenter bold border("top", "medium", "black")
	putexcel B3:K3 = "Productivity of Enumerators", merge hcenter  border("bottom", "medium", "black")
	putexcel B2:B3, border("left", "medium", "black")
	putexcel K2:K3, border("right", "medium", "black")

	putexcel A10= "Enumerator Name",
	putexcel B10= "Days worked", txtwrap
	putexcel C10= "Total surveys", txtwrap
	putexcel D10= "Daily Average", txtwrap
	
	
	
	
*=========================================================================*
*  Missing observations for all variables
*=========================================================================*
   preserve	
  
   ds, has(type numeric) 
   local num_vars `r(varlist)'
		ipacheckmissing  `num_vars', 					///
			outfile("${DataPre}1_8_Endline/HFC_$S_DATE.xlsx") 					///
			outsheet("Missing_all")							///
			sheetreplace
 
    restore
	
		 
*=========================================================================*
*  Missing observations for all variables by Enumerator
*=========================================================================*
   preserve	
  
   ds, has(type numeric) 
   local num_vars `r(varlist)'
		ipacheckmissing  `num_vars', 					///
			outfile("${DataPre}1_8_Endline/HFC_$S_DATE.xlsx") 					///
			outsheet("Missing_all")							///
			sheetreplace
 
    restore
	
		 
		 
		 
