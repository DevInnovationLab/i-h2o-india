
*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Cool stats for DIL all team meeting 
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
/*------------------------------------------------------------------------------
    0 General program setup
-------------------------------------------------------------------------------*/

	clear               all
	capture log         close _all
	set more            off
	set varabbrev       off
	set emptycells      drop
	set seed            12345
	*set maxvar         2048
	set linesize        135	
						  
/*------------------------------------------------------------------------------
	1 Select parts of the code to run
------------------------------------------------------------------------------*/
	
	local import		0
	local deidentify	0
	local clean			0
	local tidy			0
	local construct		0
	local analyze		0
	
/*------------------------------------------------------------------------------
	2 Set file paths
------------------------------------------------------------------------------*/

	* Enter the file path to the project folder in Box for every new machine you use
	* Type 'di c(username)' to see the name of your machine
	if c(username)      == "luizaandrade" {
		global box 		"C:/Users/luizaandrade/Box/project-folder"
		global github	"C:/Users/luizaandrade/GitHub/dil-template-repo"
	}
	
	else if c(username) == "akitokamei" {		
		global box 		"/Users/akitokamei/Box Sync/India Water project/"
		global github	"/Users/akitokamei/GitHub/i-h2o-india/"
		global Overleaf "/Users/akitokamei/Dropbox/Apps/Overleaf"
		
	}
		
	else if c(username) == "jeremylowe" {		
		global box 		"/Users/jerem/Box/India Water project/"
		global github	"/Users/jerem/Documents/i-h2o-india/"
		*global Overleaf "/Users/jerem/Apps/Overleaf"
		global DataRaw  "${box}01. 2_Pilot/Data/1_raw/"
	}
	
		else if c(username) == "michellecherian" {		
		global box 		"/Users/michellecherian/Library/CloudStorage/Box-Box/India Water project/"
		global github	"/Users/michellecherian/Documents/GitHub/i-h2o-india/"
		global Overleaf "/Users/michellecherian/Dropbox/Apps/Overleaf"
		global DataRaw  "${box}01. 2_Pilot/Data/1_raw/"
	}
	

	else if c(username) == "asthavohra" {		
		global box 		"/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/"
		global github	"/Users/asthavohra/Documents/GitHub/i-h2o-india/"
		global Overleaf "/Users/asthavohra/Dropbox/Apps/Overleaf"
		global DataRaw  "${box}01. 2_Pilot/Data/1_raw/"
	}
	global code		     "${github}Code"
	
	* Box 
	global pilotILC   "${box}2_Pilot/"
	global DataRaw   "${pilot}1_raw/"
	global DataDeid  "${pilot}2_deidentified/"
	global DataFinal "${pilot}3_final/"
	global DataOther "${pilot}4_other/"
	global DataTemp  "${pilot}99_temp/"
	global DataPre  "${pilot}99_Preload/"
	global Pilotofpilot "${pilot}1_raw/0_Archive/Pilot of pilot"
	
	
do "${Do_pilot}2_1_Final_data.do"

start_from_clean_file_Census

// (1) Graph for primary drinking water source
label define R_Cen_a12_ws_priml2 1 "JJM Taps" 2 "Govt. community standpipe" 3 "GP/Other community standpipe" 4 "Manual handpump" 5 "Covered dug well" 7 "Surface water" 8 "Private surface well" 77 "Other", modify
	label values R_Cen_a12_ws_prim R_Cen_a12_ws_priml2

	gen household_num= 1
	egen total_hh= total(household_num)
	display total_hh
	local total_num_hhs = total_hh
	
	
	graph hbar (percent) household_num, over(R_Cen_a12_ws_prim, label) blabel(total, format(%9.0f)) bar(1, color(maroon) fintensity(30)) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	graph export "${pilotILC}Cool Stats-All team meeting/9th Nov 2023/Primary_drinking_water_source.pdf", replace

	
//(2) number of people treating water by different methods 

	label var R_Cen_a16_water_treat_0 "No water treatment"
	label variable R_Cen_a16_water_treat_type_1 "Filter through cloth/sieve" 
	label variable R_Cen_a16_water_treat_type_2 "Letting water stand" 
	label variable R_Cen_a16_water_treat_type_3 "Boiling" 
	label variable R_Cen_a16_water_treat_type_4 "Adding chlorine/bleaching powder" 
	label variable R_Cen_a16_water_treat_type__77 "Other"
	label variable R_Cen_a16_water_treat_type_999 "Don't know"
	
mrgraph hbar R_Cen_a16_water_treat_0 R_Cen_a16_water_treat_type_1-R_Cen_a16_water_treat_type_999, blabel(total, format(%9.0f)) stat(column) bar(1, color(maroon) fintensity(30)) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	graph export "${pilotILC}Cool Stats-All team meeting/9th Nov 2023/Treatment_methods_used.pdf", replace

//(3) number of people treating water by different methods for kids 

	label var R_Cen_a17_water_treat_kids_0 "No water treatment"
	label var R_Cen_water_treat_kids_type_1 "Filter through cloth/sieve" 
	label var R_Cen_water_treat_kids_type_2 "Letting water stand" 
	label var R_Cen_water_treat_kids_type_3 "Boiling" 
	label var R_Cen_water_treat_kids_type_4 "Adding chlorine/bleaching powder"
	label var R_Cen_water_treat_kids_type77 "Other" 
	label var R_Cen_water_treat_kids_type99 "Don't know"
	

mrgraph hbar R_Cen_a17_water_treat_kids_0 R_Cen_water_treat_kids_type_1-R_Cen_water_treat_kids_type99, blabel(total, format(%9.0f)) stat(column) bar(1, color(maroon) fintensity(30)) /// 
	ytitle("Percentage of HHs, total number= `total_num_hhs'") ylabel(0 (10) 100,labsize(small)) graphregion(color(white))
	graph export "${pilotILC}Cool Stats-All team meeting/9th Nov 2023/Treatment_methods_used_kids.pdf", replace
	



