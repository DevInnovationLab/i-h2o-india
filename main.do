/*******************************************************************************
	
						  Development Innovation Lab
						    Template main do-file
						  
FOR THIS TEMPLATE TO WORK CORRECTLY, EDIT THE FILE PATHS IN SECTION 2 TO MATCH YOUR COMPUTER
						  
--------------------------------------------------------------------------------
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
	if c(username) == "luizaandrade" {
		global box 		"C:/Users/luizaandrade/Box/project-folder"
		global github	"C:/Users/luizaandrade/GitHub/dil-template-repo"
	}
	else if c(username) == "username" {
		global box 		"C:/Users/username/Box/project-folder"
		global github	"C:/Users/username/GitHub/dil-template-repo"
	}
	
	global	code		"${github}/code"
	global	data_box	"${box}/data"
	global  data_git	"${github}/data"
	global	doc_box		"${box}/documentation"
	global	doc_git		"${github}/documentation"
	global	output		"${github}/output"
	
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
	
/*------------------------------------------------------------------------------
	4 Run code
------------------------------------------------------------------------------*/

	if `import' {
		
		/*----------------------------------------------------------------------
			Import survey data into Stata format
			
			Requires: "${data_box}/encrypted/survey.csv"
			Creates:  "${data_box}/encrypted/survey.dta"
		----------------------------------------------------------------------*/
		do "${code}/import/import-survey.do"
		
	}
	if `deidentify' {
		
		/*----------------------------------------------------------------------
			Remove identifying information from survey data
			
			Requires: "${data_box}/encrypted/survey.dta"
			Creates:  "${data_box}/deidentified/survey-deindentified.dta"
		----------------------------------------------------------------------*/
		do "${code}/deidentify/deidentify-survey.do"
		
	}
	if `tidy' {
		
		/*----------------------------------------------------------------------
			Tidy household-level survey data
			
			Requires: "${data_box}/deidentified/survey-deindentified.dta"
			Creates:  "${data_box}/tidy/survey-household-tidy.dta"
		----------------------------------------------------------------------*/
		do "${code}/tidy/tidy-household-survey.do"
		
		/*----------------------------------------------------------------------
			Tidy child-level survey data
			
			Requires: "${data_box}/deidentified/survey-deindentified.dta"
			Creates:  "${data_box}/tidy/survey-child-tidy.dta"
		----------------------------------------------------------------------*/
		do "${code}/clean/clean-child-survey.do"
		
	}
	if `clean' {
		
		/*----------------------------------------------------------------------
			Clean child-level data
			
			Requires: "${data_box}/tidy/survey-household-tidy.dta"
			Creates:  "${data_box}/clean/survey-household-clean.dta"
		----------------------------------------------------------------------*/
		do "${code}/clean/clean-household-survey.do"
		
		/*----------------------------------------------------------------------
			Clean household-level data
			
			Requires: "${data_box}/tidy/survey-child-tidy.dta"
			Creates:  "${data_box}/clean/survey-child-clean.dta"
		----------------------------------------------------------------------*/
		do "${code}/clean/clean-child.do"
		
	}
	if `construct' {
		
		/*----------------------------------------------------------------------
			Construct education outcomes
			
			Requires: "${data_box}/clean/survey-child-clean.dta"
			Creates:  "${data_box}/constructed/child-education-constructed.dta"
		----------------------------------------------------------------------*/
		do "${code}/construct/construct-education.do"
		
		/*----------------------------------------------------------------------
			Construct household demographics
			
			Requires: "${data_box}/constructed/survey-household-tidy.dta"
			Creates:  "${data_box}/constructed/household-demo-constructed.dta"
		----------------------------------------------------------------------*/
		do "${code}/construct/construct-demo.do"
		
		/*----------------------------------------------------------------------
			Create child-level analysis data
			
			Requires: "${data_box}/constructed/household-demo-constructed.dta"
					  "${data_box}/constructed/child-education-constructed.dta"
			Creates:  "${data_box}/analysis/child.dta"
		----------------------------------------------------------------------*/
		do "${code}/construct/combine-child-data.do"
	}
	if `analyze' {
		
		/*----------------------------------------------------------------------
			Balance table
			
			Requires: "${data_box}/analysis/child.dta"
			Creates:  "${output}/balance-table.tex"
		----------------------------------------------------------------------*/
		do "${code}/analysis/balance-table.do"
	}

************************************************************ End of main do-file
