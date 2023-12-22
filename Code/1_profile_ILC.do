/*******************************************************************************
	
						  Development Innovation Lab
       [TBF: Name]
						  
FOR THIS TEMPLATE TO WORK CORRECTLY, EDIT THE FILE PATHS IN SECTION 2 TO MATCH YOUR COMPUTER

--------------------------------------------------------------------------------
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
				if c(username) == "Archi Gupta" {		
		global code  "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code"
	}
	
	* Box 
	global pilot     "${box}2_Pilot/Data/"
				if c(username) == "Archi Gupta" {		
		global box 		"C:\Users\Archi Gupta\Box\Data"
		global github	"C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code"
		global Overleaf "C:\Users\Archi Gupta\Dropbox\Overleaf"
		global DataRaw  "C:\Users\Archi Gupta\Box\Data\1_raw"
	    global pilot    "C:\Users\Archi Gupta\Box\Data\" 
	}
    
	global DataRaw   "${pilot}1_raw/"
				if c(username) == "Archi Gupta" {		
		global DataRaw  "C:\Users\Archi Gupta\Box\Data\1_raw\"
	}
	
	global DataDeid  "${pilot}2_deidentified/"
	global DataFinal "${pilot}3_final/"
	global DataOther "${pilot}4_other/"
	global DataTemp  "${pilot}99_temp/"
	global DataPre  "${pilot}99_Preload/"
				if c(username) == "Archi Gupta" {		
		global DataPre  "C:\Users\Archi Gupta\Box\Data\99_Preload"
	}
	
	global Pilotofpilot "${pilot}1_raw/0_Archive/Pilot of pilot"
	
	* Do files
	global Do_pilot   "${github}Code/1_profile_ILC/"
					if c(username) == "Archi Gupta" {		
	    global Do_pilot "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\"
	}

	global Do_lab     "${github}Code/1_profile_ILC/Label/"
					if c(username) == "Archi Gupta" {		
	    global Do_lab   "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\" 
	}

	global Do_lab     "${github}Code/1_profile_ILC/Label/"
					if c(username) == "Archi Gupta" {		
	    global Do_lab   "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\" 
	}

	
	global Data_map   "${box}4_Admin data/shrug-pc11-village-poly-shp/"
	
	* Overleaf
	global Table =  "${Overleaf}/Everything document -ILC/Table/"
	global Figure = "${Overleaf}/Everything document -ILC/Figure/"
	global Table_Pilot_analysis =  "${Overleaf}/India ILC Pilot- analysis/Table/"

	cd "${DataRaw}"

/*------------------------------------------------------------------------------
	3 Initial settings 
------------------------------------------------------------------------------*/
* NOTE: Make sure you also paste the downloaded package ado files to your source ado files for Stata
	* Find user-written commands in GitHub
	sysdir set  PLUS "${code}/ado"
	
    adopath ++  PLUS
    adopath ++  BASE
//Note: Install package ssc install ietoolkit	
	* Set initial configurations as much as allowed by Stata version
	ieboilstart, v(16.0)
	`r(version)'
	set scheme s2color
	
	* Set initial configurations to be able to run R script in Stata
	*net from http://www.stata.com/statausers/packages
    *ssc install rscript

	
/*------------------------------------------------------------------------------
	4 Run code
------------------------------------------------------------------------------*/
* Search function
	/* 
local string pregwoman
	cd "${Do_pilot}"
	find, match(`string') show zero
*/ 
	
cd "${DataRaw}"

* (0) First apply SurveyCTO code cleaning do file
do "${Do_pilot}0_Preparation.do"
* Who: Akito
* Akito to add descrioption

* (1_1_A) Cleaning
do "${Do_pilot}1_1_A_Census_cleaning.do"
* Michelle
* Unit: Household (all)
* Do we have the system to avoid the non-unique unique_id?

/*
* (1_1_C) Uploading selected Household data to Google Drive for HH Survey
do "${Do_pilot}1_1_C_Upload_GDrive.do"
* Astha
* Unit: Household (all)
*/

* (1.2) Cleaning
do "${Do_pilot}1_2_Followup_cleaning.do"
* Who is incharge
* Unit: Household (selected sample)

* (1.3) Cleaning
do "${Do_pilot}1_3_Chlorine_cleaning.do"
* Who is incharge
* Unit: Device (merge at village level)

* (1.4) Cleaning
do "${Do_pilot}1_4_Operator_cleaning.do"
* Who is incharge
* Unit: Pump operater (merge at village level)

* (2.1) Final data creation
* Who: Akito
do "${Do_pilot}2_1_Final_data.do"

* (2.2) High frequency checks
* Who: Astha/Michelle
do "${Do_pilot}2_2_Checks.do"
do "${Do_pilot}2_3_Checks_Follow_Up.do"

* (3) Descriptive stats
* Who: All
do "${Do_pilot}3_Descriptive.do"
do "${Do_pilot}3_2_Descriptive_Follow_Up.do"
* (4) Analysis
* Who: All
do "${Do_pilot}4_Analysis.do"


do "${Do_pilot}1_1_D_Mortality_cleaning.do"

********************************
* Erasing unccessary databases *
********************************
* Deleting data from cleaning folder
foreach i in 0_Append_Issue {
	capture erase "${DataClean}`i'.dta"
}

*********************************************
* The program run successfully till the end * 
*********************************************
