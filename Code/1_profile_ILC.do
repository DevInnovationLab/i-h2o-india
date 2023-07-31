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
		global github	"/Users/akitokamei/Dropbox/Mac/Documents/GitHub/i-h2o-IndiaILC/"
		global Overleaf "/Users/akitokamei/Dropbox/Apps/Overleaf"
		global DataRaw  "${box}01. Raw/"
	}

	global code		     "${github}Code"
	/* 
	global	data_box	"${box}/data"
	global  data_git	"${github}/data"
	global	doc_box		"${box}/documentation"
	global	doc_git		"${github}/documentation"
	global	output		"${github}/output" 
	
	global DataArchive   "${DataRaw}Z_Archive/Keep especially for DOB/"
	global Data          "${box}1_Data/"
	global DataPre       "${box}1_Data/1_0_Project_preload/"
	global DataClean     "${box}1_Data/1_2_Project_clean/"
	global DataFinal     "${box}1_Data/1_3_Project_final/"
	global DataLogistic  "${box}1_Data/1_4_Project_logistic/"
	global Do_impliment  "${github}Code/1_Implimentation/"
	global Do_lab        "${github}Code/1_Implimentation/Label/"
	global Do_analysis   "${github}Code/2_Analysis/"
	* global Map      "${box}1_Shapefiles/ken_adm_iebc_20191031_shp/"
	global MapData  "${box}1_Data/4_Shapefiles/Shape files/"
	global Map      "${box}1_Shapefiles/ken_adm_iebc_20191031_shp/"
	global Data2nd  "${Data}3_Secondary Data/"
	*/
	
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
local string List_ANC_final_HF.dta
	cd "${github}code/1_Implimentation"
	find, match(`string') show zero
*/ 
	
cd "${DataRaw}"

* (1.0) First datat set
* do "${Do_impliment}1_2_0_IssueCoupon.do"

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
