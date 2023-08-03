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
		global github	"/Users/akitokamei/Dropbox/Mac/Documents/GitHub/i-h2o-india/"
		global Overleaf "/Users/akitokamei/Dropbox/Apps/Overleaf"
		
	}

	global code		     "${github}Code"
	
	* Box 
	global pilot     "${box}2_Pilot/Data/"
	global DataRaw   "${pilot}1_raw/"
	global DataDeid  "${pilot}2_deidentified/"
	global DataFinal "${pilot}3_final/"
	global DataTemp  "${pilot}99_temp/"
	
	* Do files
	global Do_pilot   "${github}Code/1_profile_ILC/"
	global Do_lab     "${github}Code/1_profile_ILC/Label/"
	
	* Overleaf
	global Table =  "${Overleaf}/Everything document -ILC/Table/"
	global Figure = "${Overleaf}/Everything document -ILC/Figure/"
	
	cd "${DataRaw}"

/*------------------------------------------------------------------------------
	3 Initial settings
------------------------------------------------------------------------------*/

	* Find user-written commands in GitHub
	sysdir set  PLUS "${code}/ado"
	
    adopath ++  PLUS
    adopath ++  BASE
	
	* Set initial configurations as much as allowed by Stata version
	ieboilstart, v(16.0)
	`r(version)'
	set scheme s2color
	
/*------------------------------------------------------------------------------
	4 Run code
------------------------------------------------------------------------------*/
* Search function
	/* 
local string ABC.dta
	cd "${github}code/1_Implimentation"
	find, match(`string') show zero
*/ 
	
cd "${DataRaw}"

* (0) First apply SurveyCTO code cleaning do file
do "${Do_pilot}0_Preparation.do"

* (1) Cleaning (Discuss more what is needed)
do "${Do_pilot}1_Cleaning.do"

* (2) Descriptive stats
do "${Do_pilot}2_Descriptive.do"

* (3) Analysis
do "${Do_pilot}3_Analysis.do"

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
