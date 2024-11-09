/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creates descriptive statistics tables for PO survey 
****** Used by:  DIL
****** Last modified by : Niharika 
****** Input data : 
	- "${DataFinal}pump_operator_survey.dta"
****** Output data/file : 
	-  NA
****** Do file to run before this do file
	- "1_10_PumpOperator_Survey_cleaning.do"
****** Language: English
*=========================================================================*/
** In this do file: 
	* This do file exports..... Descriptive statistics tables for Pump operator survey




********************************************************************************
*** Loading the dataset 
********************************************************************************
use  "${DataFinal}1_14_PO_Survey_final.dta", clear

********************************************************************************
*** Creating variables for use in summary stats tables -- MOVE TO NEW CODE FILE AFTERWARDS
********************************************************************************

*** Creating new variables to ensure consistency of obs 
//Payment
gen pay_new=.
replace pay_new=0 if receive_salary==0 //does not receive salary
replace pay_new=1 if C_salary_source_new==1 //recieves salary from panchayat/rwss 
replace pay_new=2 if C_salary_source_new==2 //recieves salary from proxy 

//Payment issues
gen pay_issues=.
replace pay_issues=0 if receive_salary==0 //does not receive salary
replace pay_issues=1 if salary_issue==1 //faces issues
replace pay_issues=2 if salary_issue==0 //no issues

//Reasons for irregular pay: detailed
gen pay_delay=.
replace pay_delay=0 if salary_issue==0 //does not face any issues with pay 
replace pay_delay=1 if C_reason_irreg_pay_1==1 //document issuance delay
replace pay_delay=2 if C_reason_irreg_pay_2==1 //processing delay form CP to BDO
replace pay_delay=3 if C_reason_irreg_pay_3==1 //document signing delay
replace pay_delay=4 if C_reason_irreg_pay_4==1 //processing delay from bdo to panchayat
replace pay_delay=5 if C_reason_irreg_pay_5==1 //processing delay from panchayat to po
replace pay_delay=6 if C_reason_irreg_pay_6==1 //lack of accountability

//Reasons for irregular pay: categorised
gen pay_delay2=.
replace pay_delay2=0 if salary_issue==0 //does not face any issues with pay 
replace pay_delay2=1 if C_reason_irreg_pay_1==1 | C_reason_irreg_pay_3==1 | C_reason_irreg_pay_5==1 //delay on the part of GP
replace pay_delay2=2 if C_reason_irreg_pay_2==1 | C_reason_irreg_pay_4==1 //delay on the part of BDO officials
replace pay_delay2=3 if C_reason_irreg_pay_6==1 //delay due to lack of accountabilty

/*
missing obs in pay_delay and pay_delay2 were never informed of any payment when they started working as PO */

//Other work
gen otherwork_tables=.
replace otherwork_tables=0 if other_work==0 //does not do other work
replace otherwork_tables=1 if other_work_type_1==1 //self-employed (agriculture related work)
replace otherwork_tables=2 if other_work_type_2==1 //self-employed (non agriculture related work)
replace otherwork_tables=3 if other_work_type_3==1 //Agricultural labour
replace otherwork_tables=4 if other_work_type_4==1 //Casual labour

//Operation of valves
gen op_valve_new=. //missing (doesn't know)
replace op_valve_new=0 if operation_valves==0 //no one knows
replace op_valve_new=1 if operation_valves_who==1 //addtl PO
replace op_valve_new=2 if operation_valves_who==2 //someone in family
replace op_valve_new=3 if operation_valves_who==3 //someone in village

//Operation ILC
gen op_ilc_new=. //missing (control group + Karnapadu + dont know)
replace op_ilc_new=0 if operation_ilc==0 //no
replace op_ilc_new=1 if operation_ilc==1 //yes

//Number of times someone else operated water supply
gen op_valve_no=. //missing 
replace op_valve_no=0 if operation_valves_nmbr==. //noone else knows how to operate valves
replace op_valve_no=1 if operation_valves_nmbr==0 //noone else operated it
replace op_valve_no=2 if operation_valves_nmbr>=1 & operation_valves_nmbr<=5 //someone else operated 5 times or less
replace op_valve_no=3 if operation_valves_nmbr>=6 & operation_valves_nmbr<=10 //someone else operated 10 times or less
replace op_valve_no=4 if operation_valves_nmbr>10  //someone else operated more than 10 times

//did this person also operate ILC on these instances
gen op_ilc_30=. //missing (control grouop + Karnapadu)
replace op_ilc_30=1 if operation_ilc_lastmonth==1 //yes
replace op_ilc_30=0 if operation_ilc_lastmonth==0 //no
replace op_ilc_30=0 if operation_valves_nmbr==0 & (village_name=="Naira" | village_name=="Bichikote") //noone else tuned on water supply in T villages

//salary
gen salary_new=salary
replace salary_new=0 if salary==.

//Tasks as part of Monitoring the ILC device
gen monitor_task=. //missing values corres to control group
replace monitor_task=0 if ilc_monitor==0 //karnapadu (do not monitor the device)
replace monitor_task=1 if ilc_monitor_type_1==1 //opening and closing teh valves
replace monitor_task=2 if ilc_monitor_type_2==1 //adjusting the valves
replace monitor_task=3 if ilc_monitor_type_3==1 //draining the device
replace monitor_task=4 if ilc_monitor_type_4==1 //cleaning the device
replace monitor_task=5 if ilc_monitor_type_5==1 //checking for leaks
replace monitor_task=6 if ilc_monitor_type_6==1 //checking for refills
replace monitor_task=7 if ilc_monitor_type_7==1 //informing installation team 
replace monitor_task=8 if ilc_monitor_type_8==1 //repairing the device
replace monitor_task=9 if ilc_monitor_type__77==1 //other tasks
	
//Tasks performed daily
gen monitor_daily=. //control group 
replace monitor_daily=0 if C_ilc_daily_task=="0" | ilc_monitor==0 //does not carry out any tasks daily (includes karnapadu)
replace monitor_daily=1 if C_ilc_daily_task_1==1 //openig and closing the valves
replace monitor_daily=2 if C_ilc_daily_task_2==1 //adjusting the valves
replace monitor_daily=3 if C_ilc_daily_task_3==1 //draining the device
replace monitor_daily=4 if C_ilc_daily_task_4==1 //cleaning the device
replace monitor_daily=5 if C_ilc_daily_task_6==1 //checking for refills

//Tasks not perfomed daily
gen monitor_notdaily=. //control group 
replace monitor_notdaily=0 if C_ilc_notdaily_task=="0" | ilc_monitor==0 //does not carry out any tasks even irregularly (includes karnapadu)
replace monitor_notdaily=1 if C_ilc_notdaily_task_2==1 //adjusting the valves
replace monitor_notdaily=2 if C_ilc_notdaily_task_6==1 //checking for refills
replace monitor_notdaily=3 if C_ilc_notdaily_task_7==1 //informing installation team 

//performs refills
gen refill=. //control group
replace refill=1 if ilc_refill==1 //provides refills
replace refill=0 if ilc_monitor==0 | ilc_refill==0 //does not provide refills (includes karnapadu)

//frequency of perfoming occasional tasks
gen freq_notdaily_tasks=ilc_monitor_freq //missing values pertain to control group
replace freq_notdaily_tasks=0 if village_name=="Karnapadu" 

//hh issues type
gen type_issues=. //control group
replace type_issues=0 if hh_issues==0 //no issues 
replace type_issues=1 if hh_issues_type_1==1 //smell
replace type_issues=2 if hh_issues_type_4==1 //cooking 

//percentage of hhs reporting issues
gen pc_issues=. //control group
replace pc_issues=0 if hh_issues==0 //no issues/0%
replace pc_issues=1 if hh_issues_percent==1 //all hhs (100%)
replace pc_issues=2 if hh_issues_percent==4 //some hhs (25%)
replace pc_issues=3 if hh_issues_percent==5 //few hhs (>25%)

//Complaint redressal by POs
gen redressal_issues=. //control group
replace redressal_issues=0 if hh_issues==0 //no issues
replace redressal_issues=1 if hh_issues_response_1==1 //tried to convince the villagers
replace redressal_issues=2 if hh_issues_response_2==1 //reported to GV
replace redressal_issues=3 if hh_issues_response_3==1 //reported to JPAL
replace redressal_issues=4 if hh_issues_response_4==1 //reported to village leader
replace redressal_issues=5 if hh_issues_response_5==1 //reported to rwss
replace redressal_issues=6 if hh_issues_response_6==1 //adjusted dosage
replace redressal_issues=7 if hh_issues_response_7==1 //turned off the device
replace redressal_issues=8 if hh_issues_response_8==1 //removed tablets from the device

//changing refused to know as missing
replace school_level=. if school_level==-98

*** Creating dummies
foreach v in C_duration_job_new school_level C_appointment_new C_training otherwork_tables ///
 pay_new pay_issues pay_delay pay_delay2 interaction_gp interaction_freq ///
 interaction_issues_1 interaction_issues_2 interaction_issues_3 ///
 interaction_issues_4 interaction_issues__77 op_valve_new op_ilc_new op_valve_no ///
 op_ilc_30 refill monitor_notdaily monitor_daily ilc_monitor C_addtl_duties_yn ///
 addtl_duties_comp reason_chlorination_1 reason_chlorination_2 reason_chlorination_3 ///
 reason_chlorination_4 reason_chlorination_5 reason_chlorination_999 op_satisfaction ///
 ilc_satisfaction_po ilc_satisfaction type_issues pc_issues redressal_issues {
	levelsof `v'
	foreach value in `r(levels)' {
		gen     `v'_`value'=0
		replace `v'_`value'=1 if `v'==`value'
		replace `v'_`value'=. if `v'==.
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

********************************************************************************
*** Labelling variables for tables
********************************************************************************
//Other variables
label var salary_new "Amount of Payment received"	
label var resp_age "Age of the respondent"
label var school_level_1 "Did not complete primary education"
label var school_level_2 "Completed primary education"
label var school_level_3 "Did not complete secondary education"
label var school_level_5 "Completed Post-secondary education"
//Other work by PO
label var otherwork_tables_1 "Self employed (agriculture-related)"
label var otherwork_tables_2 "Self employed (non-agriculture related)"
label var otherwork_tables_3 "Agricultural Labor"
label var otherwork_tables_4 "Casual Labor"
label var otherwork_tables_0 "Doesn't do any other work"
//salary and payment related variables
label var pay_new_0 "Does not receive payment"
label var pay_new_1 "Receives payment from Panchayat or RWSS"
label var pay_new_2 "Receives payment from a proxy"
label var pay_issues_0 "Does not receive payment"
label var pay_issues_1 "Payments received irregularly"
label var pay_issues_2 "Payments received regularly"
label var pay_delay_0 "Does not face any issues with pay"
label var pay_delay_1 "Document issuance delay" //"Reasons for irregular payment"
label var pay_delay_2 "Processing delay form CP to BDO"
label var pay_delay_3 "Document signing delay"
label var pay_delay_4 "Processing delay from bdo to panchayat"
label var pay_delay_5 "Processing delay from panchayat to po"
label var pay_delay_6 "Lack of accountability"
label var pay_delay2_0 "Does not face any issues with pay" //"Reasons for irregular payment"
label var pay_delay2_1 "Delay on the part of GP"
label var pay_delay2_2 "Delay on the part of BDO officials"
label var pay_delay2_3 "Lack of accountability"
//interaction with GP/RWSS related variables
label var interaction_gp_1 "Only with the Gram Panchayat"
label var interaction_gp_2 "Only with the RWSS"
label var interaction_gp_3 "Both with the Gram Panchayat and the RWSS"
label var interaction_issues_1_1 "Water supply-related issues"
label var interaction_issues_2_1 "Infrastructure-related issues"
label var interaction_issues_3_1 "Household complaints-related issues"
label var interaction_issues_4_1 "Compensation-related issues"
label var interaction_issues__77_1 "Other issues"
//Operation of Pump and Device related variables
label var op_valve_new_0 "No other operators of water supply valve"
label var op_valve_new_1 "Additional Pump Operator" //"Other operators of water supply valve include:"
label var op_valve_new_2 "Someone in the family"
label var op_valve_new_3 "Someone in the village"
label var op_ilc_new_1 "Knows how to operate the device" //"Operation of ILC device by someone else"
label var op_valve_no_1 "Not even once" //"Instances of others Operating Water supply valves (Past Month)"
label var op_valve_no_2 "5 times or less"
label var op_valve_no_3 "10 times or less"
label var op_valve_no_4 "More than 10 times"
label var op_ilc_30_1 "Operated the device in past month"
//montioring of the device
label var ilc_monitor_1 "Monitors and operates the device"
label var ilc_monitor_0 "Does not monitor or operate the device"
//tasks performed daily 
label var monitor_daily_0 "Does not perform any tasks daily"
label var monitor_daily_1 "Opening and closing the valves"
label var monitor_daily_2 "Adjusting the valves"
label var monitor_daily_3 "Draining the devices"
label var monitor_daily_4 "Cleaning the device"
label var monitor_daily_5 "Checking for refills"
//tasks perfomed occasionally 
label var monitor_notdaily_0 "Does not perform any occasional tasks"
label var monitor_notdaily_1 "Adjusting valve"
label var monitor_notdaily_2 "Checking refill"
label var monitor_notdaily_3 "Informing the installation team of any issues"
//provision of refills
label var refill_0 "Does not provide refills to the device"
label var refill_1 "Provides refills to the device"
//time taken to perform tasks daily
label var C_time_taken "Time spent on daily operation and maintainence"
//Willingness to perform additional duties 
// label var C_addtl_duties_yn_0 "Unwilling to do additional duties"
label var C_addtl_duties_yn_1 "Willing to do additional duties" 
//Willingness to perform additional duties in the same compensation 
label var addtl_duties_comp_0 "Unwilling to do additional duties (same compensation)"
label var addtl_duties_comp_1 "Willing to do additional tasks (same compensation)"
//frequency of performing occasional tasks
label var freq_notdaily_tasks "Frequency of performing occasional tasks"
label define freq_notdaily_tasks 0 "Does not perform occasional tasks" 2 "Once a week" 3 "Once every two weeks" 4 "Once a month" 5 "No fixed schedule"
label values freq_notdaily_tasks freq_notdaily_tasks
//reasons for chlorination
label var reason_chlorination_1_1 "To make water safer"
label var reason_chlorination_2_1 "To enhance health"
label var reason_chlorination_3_1 "To improve taste and smell of water"
label var reason_chlorination_4_1 "To make water clearer"
label var reason_chlorination_5_1 "To eliminate microbes"
label var reason_chlorination_999_1 "Don't know"
//level of satisfaction operating teh device (changing label for use uin table)
label var op_satisfaction_1 "Very satisfy"
//type of complaints
label var type_issues_0 "No complaints"
label var type_issues_1 "Odor-related complaints"
label var type_issues_2 "Cooking-related complaints"
//percentage of hhs reporting complaints 
label var pc_issues_0 "No issues reported"
label var pc_issues_1 "100 per cent"
label var pc_issues_2 "25 per cent"
label var pc_issues_3 "Less than 25 percent"
//complaint redressal
label var redressal_issues_0 "No issues reported"
label var redressal_issues_1 "Tried to convince the villagers"
label var redressal_issues_2 "Reported the complaints to GV"
label var redressal_issues_4 "Reported the complaints to village leader"
label var redressal_issues_6 "Adjusted the dosage"


********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS 
********************************************************************************	

/* TO DROP OR NOT
drop if unique_id=="30602103001" //dropping the observation of the main PO of Mukundpur who has outsourced his job to the PO of hatikhamba
*/

*** Saving the dataset 
save "${DataTemp}PO_findings.dta", replace

*** Creation of the table

	   *%%%%%%%%%%%%%%%%%%%% Table 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%*

*Setting up global macros for calling variables
global PO_1 resp_age school_level_1 school_level_2 school_level_3 school_level_5 ///
otherwork_tables_0 otherwork_tables_1 otherwork_tables_2 otherwork_tables_3 otherwork_tables_4 ///
C_duration_job_new_1 C_duration_job_new_2 C_duration_job_new_3 C_duration_job_new_4 C_duration_job_new_5 ///
C_appointment_new_1 C_appointment_new_2 C_appointment_new_3 C_training_1 C_training_2 C_training_3 ///
pay_new_0 pay_new_1 pay_new_2 salary_new pay_issues_2 pay_issues_1  ///
pay_delay2_1 pay_delay2_2 pay_delay2_3 


*Setting up local macros (to be used for labelling the table)
local PO_1 "Diverse Profiles of Pump Operators"
local LabelPO_1 "PO_Table1"
local notePO_1 "N: 21 - Number of main respondents from 20 villages (one village had two pump operators) \newline \textbf{Notes:} (1)The average salary is elevated due to an outlier—one respondent who previously worked with RWSS \& earns Rs. 18,000 per month (2) Respondents allowed to select multiple reasons for irregular payments (2) Missing observation for the education level as one respondent refused to provide information (3)Missing observations for reasons for irregular payments as respondents were not informed of payments due, had no expectations, and are unaware of specific reasons." 
local ScalePO_1 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_1 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings.dta", clear //using the saved dataset 
	
	* Count 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. no of obs of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings.dta", clear
	eststo  model1: estpost summarize $`k' 

	* Standard Deviation 
    use "${DataTemp}PO_findings.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	* Min
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Age of the respondent" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Respondent's Background}} \\ Age" ///
				   "Did not complete primary education" "Education level of Respondents: \\ \hspace{0.5cm}Did not complete primary education" ///
				   "Completed primary education" "\hspace{0.5cm} Completed primary education" ///
				   "Did not complete secondary education" "\hspace{0.5cm}Did not complete secondary education" ///
				   "Completed Post-secondary education" "\hspace{0.5cm}Completed Post-secondary education" ///
				   "Doesn't do any other work" "Additional Work \\ \hspace{0.5cm}Doesn't do any other work" ///
				   "Self employed (agriculture-related)" "\hspace{0.5cm}Self employed (agriculture-related)" ///
				   "Self employed (non-agriculture related)" "\hspace{0.5cm}Self employed (non-agriculture related)" ///
				   "Agricultural Labor" "\hspace{0.5cm}Agricultural Labor" ///
				   "Casual Labor" "\hspace{0.5cm}Casual Labor" ///
				   "Less than 1 year" "\\ \multicolumn{7}{c}{\textbf{Panel 2: Employment Information}} \\Job Duration \\ \hspace{0.5cm}Less than 1 year" ///
				   "1-4 years" "\hspace{0.5cm}1-4 years" ///
				   "5-8 years" "\hspace{0.5cm}5-8 years" ///
				   "9-12 years" "\hspace{0.5cm}9-12 years" ///
				   "More than 12 years" "\hspace{0.5cm}More than 12 years" ///
				   "Appointed by Gram Panchayat" "Appointment Authority \\ \hspace{0.5cm}Appointed by Gram Panchayat" ///
				   "Appointed by RWSS" "\hspace{0.5cm}Appointed by RWSS"  ///
				   "Appointed by Village Leadership" "\hspace{0.5cm}Appointed by Village Leadership" ///
				   "Received formal training" "Training for the Job \\ \hspace{0.5cm}Received formal training" ///
				   "Received informal training" "\hspace{0.5cm}Received informal training" ///
				   "Did not receive any training" "\hspace{0.5cm}Did not receive any training" ///
				   "Does not receive payment" "\\ \multicolumn{7}{c}{\textbf{Panel 3: Payment Details and Discrepencies}} \\Does not receive payment" ///
				   "Payments received regularly" "Regularity of Payments Received \\ \hspace{0.5cm}Payments received regularly" ///
				   "Payments received irregularly" "\hspace{0.5cm}Payments received irregularly" ///
				   "Delay on the part of GP" "Reasons for Irregular Payments \\ \hspace{0.5cm}Delay on the part of GP" ///
				   "Delay on the part of BDO officials" "\hspace{0.5cm}Delay on the part of BDO officials" ///
				   "Lack of accountability" "\hspace{0.5cm}Lack of accountability" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }

// 				   "Receives payment from Panchayat or RWSS" "hspace{0.5cm}Receives payment from Panchayat or RWSS" ///
// 				   "Receives payment from a proxy" "hspace{0.5cm}Receives payment from a proxy" ///
	   
	   *%%%%%%%%%%%%%%%%%%%% Table 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%*

*Setting up global macros for calling variables
global PO_2 pay_delay_1 pay_delay_2 pay_delay_3 pay_delay_4 pay_delay_5 pay_delay_6  ///

*Setting up local macros (to be used for labelling the table)
local PO_2 "Reasons for irregular payment"
local LabelPO_2 "PO_Table2"
local notePO_2 "N: 21 - Number of main respondents from 20 villages (one village had two pump operators) \newline \textbf{Notes:} (1)Missing observations as respondents were not informed of payments due, had no expectations, and are unaware of specific reasons. (2) Respondents were allowed to select multiple responses" 
local ScalePO_2 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_2 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings.dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings.dta", clear
	eststo  model1: estpost summarize $`k' 

	* Standard Deviation 
    use "${DataTemp}PO_findings.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Daily" "Water Supply Schedule \\ \hspace{0.5cm} Daily" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }




	   *%%%%%%%%%%%%%%%%%%%% Table 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%*

*Setting up global macros for calling variables
global PO_3 op_valve_new_0 op_valve_new_1 op_valve_new_2 op_valve_new_3 op_valve_no_1 op_valve_no_2 op_valve_no_3 op_valve_no_4 op_ilc_new_1 op_ilc_30_1

*Setting up local macros (to be used for labelling the table)
local PO_3 "Operational Knowledge of Water Supply Valves and ILC Device"
local LabelPO_3 "PO_Table3"
local notePO_3 "N: 21 - Number of main respondents from 20 villages (one village had two pump operators) \newline \textbf{Notes:} (1)*: Missing observation as one respondent does not know whether others have operational knowledge or not (2)**: Missing data includes control group observations and one observation from Karnapadu where the question was not asked" 
local ScalePO_3 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_3 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings.dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings.dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}PO_findings.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "No other operators of water supply valve" "Other operators of water supply valve include:*\\ \hspace{0.5cm}No other operators" ///
				   "Additional Pump Operator" "\hspace{0.5cm}Additional Pump Operator" ///
				   "Someone in the family" "\hspace{0.5cm}Someone in the family" ///
				   "Someone in the village" "\hspace{0.5cm}Someone in the village" ///
				   "Not even once" "Instances of others operating water supply valves (past month) \\ \hspace{0.5cm}Not even once" ///
				   "5 times or less" "\hspace{0.5cm}5 times or less" ///
				   "10 times or less" "\hspace{0.5cm}10 times or less" ///
				   "More than 10 times" "\hspace{0.5cm}More than 10 times" ///
				   "Knows how to operate the device" "Operation of ILC device by someone else** \\ \hspace{0.5cm}Knows how to operate the device" ///
				   "Operated the device in past month" "\hspace{0.5cm}Operated the device in past month" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }




	   *%%%%%%%%%%%%%%%%%%%% Table 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%*

*Setting up global macros for calling variables
global PO_4 interaction_gp_1 interaction_gp_2 interaction_gp_3 ///
interaction_freq_6 interaction_freq_2 interaction_freq_7 interaction_freq_3   ///
interaction_issues_1_1 interaction_issues_2_1 interaction_issues_3_1 interaction_issues_4_1 ///
interaction_issues__77_1 


*Setting up local macros (to be used for labelling the table)
local PO_4 "Level of Interaction of Pump Operators with GP and RWSS"
local LabelPO_4 "PO_Table4"
local notePO_4 "N: 21 - Number of main respondents from 20 villages (one village had two pump operators) \newline \textbf{Notes:} (1)*: Respondents allowed to select multiple responses"
local ScalePO_4 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_4 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings.dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings.dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}PO_findings.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Only with the Gram Panchayat" "Interactions: \\ \hspace{0.5cm}Only with the Gram Panchayat" ///
				   "Only with the RWSS" "\hspace{0.5cm}Only with the RWSS" ///
				   "Both with the Gram Panchayat and the RWSS" "\hspace{0.5cm}Both with the Gram Panchayat and the RWSS" ///
				   "Water supply-related issues" "Issues discussed during Interactions*: \\ \hspace{0.5cm}Water supply-related issues" ///
				   "Infrastructure-related issues" " \hspace{0.5cm}Infrastructure-related issues" ///
				   "Household complaints-related issues" "\hspace{0.5cm}Household complaints-related issues" ///
				   "Compensation-related issues" "\hspace{0.5cm}Compensation-related issues" ///
				   "Other issues" "\hspace{0.5cm}Other issues" ///
				   "No fixed schedule" "Frequency of Interactions: \\ \hspace{0.5cm}No fixed schedule" ///
				   "Weekly" "\hspace{0.5cm}Weekly" ///
				   "Monthly" "\hspace{0.5cm}Monthly" ///
				   "Bi-monthly" "\hspace{0.5cm}Bi-monthly" ///		   
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }


	   *%%%%%%%%%%%%%%%%%%%% Table 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%*
*Loading teh dataset
use "${DataTemp}PO_findings.dta", clear

*Keeping only treatment group observations 
keep if ilc_monitor!=.

*Saving teh dataset
save "${DataTemp}PO_findings_treatment.dta", replace


*Setting up global macros for calling variables
global PO_5 ilc_monitor_1  monitor_daily_1 ///
monitor_daily_2 monitor_daily_3 monitor_daily_4 monitor_daily_5 C_time_taken /// 
monitor_notdaily_1 monitor_notdaily_2 monitor_notdaily_3 refill_1 refill_0 ///
C_addtl_duties_yn_1 addtl_duties_comp_1 


*Setting up local macros (to be used for labelling the table)
local PO_5 "ILC Operation & Maintenance: Existing Tasks and Potential for Additional Tasks"
local LabelPO_5 "PO_Table5"
local notePO_5 "N: 11 - Number of main respondents from 10 treatment villages (one village had two pump operators) \newline \textbf{Notes:} (1)*: Respondents allowed to select multiple responses (2)**: Missing values correspond to two respondents who don't know how much time they spend on daily operation and maintainence (3)***: Additional tasks: operating, maintaining, and monitoring the water treatment device, and sensitizing villagers on its importancet" 
local ScalePO_5 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_5 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings_treatment.dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings_treatment.dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}PO_findings_treatment.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Monitors and operates the device" "\textbf{Monitors and operates the device}" ///
				   "Time spent on daily operation and maintainence" "\hspace{0.25cm}Time spent on daily tasks**" ///
				   "Opening and closing the valves" "\hspace{0.25cm}Daily Tasks Perfomed*: \\ \hspace{0.5cm}Opening and closing the valves" ///
				   "Adjusting the valves" "\hspace{0.5cm}Adjusting the valves" ///
				   "Draining the devices" "\hspace{0.5cm}Draining the devices" ///
				   "Cleaning the device" "\hspace{0.5cm}Cleaning the device" ///
				   "Checking for refills" "\hspace{0.5cm}Checking for refills" ///
				   "Adjusting valve" "\hspace{0.25cm}Occasional Tasks Perfomed*: \\ \hspace{0.5cm}Adjusting the valves" ///
				   "Checking refill" "\hspace{0.5cm}Checking for refills" ///
				   "Informing the installation team of any issues" "\hspace{0.5cm}Informing the installation team of any issues" ///
				   "Provides refills to the device" "\textbf{Refilling the tablets in the ILC Device} \\ \hspace{0.5cm}Provides refills" ///
				   "Does not provide refills to the device" "\hspace{0.5cm}Does not provide refills" ///
				   "Willing to do additional duties" "\textbf{Reported williness to do additional tasks}*** \\ \hspace{0.5cm}Willing to do additional duties" ///
				   "Willing to do additional tasks (same compensation)" "\hspace{0.5cm}Willing to do additional tasks (same compensation)" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }


	   *%%%%%%%%%%%%%%%%%%%% Table 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%*
*Loading teh dataset
use "${DataTemp}PO_findings_treatment.dta", clear

*Setting up global macros for calling variables
global PO_6  ilc_satisfaction_po_1 ilc_satisfaction_po_2 op_satisfaction_1 ///
op_satisfaction_2 reason_chlorination_1_1 reason_chlorination_2_1 ///
reason_chlorination_3_1 reason_chlorination_4_1 reason_chlorination_5_1 ///
reason_chlorination_999_1

*Setting up local macros (to be used for labelling the table)
local PO_6 "Perceptions on Device and Chlorination"
local LabelPO_6 "PO_Table6"
local notePO_6 "N: 11 - Number of main respondents from 10 treatment villages (one village had two pump operators) \newline \textbf{Notes:} (1)*: Includes the response of the PO of Karnapadu (where device was uninstalled)" 
local ScalePO_6 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_6 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings_treatment.dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings_treatment.dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}PO_findings_treatment.dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings_treatment.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Very satisfied" "\\ \textbf{Reported satisfaction with ILC device} \\Satisfaction with device in general \\ \hspace{0.5cm}Very Satisfied" ///
				   "Somewhat satisfied" "\hspace{0.5cm}Somewhat satisfied" ///
				   "Very satisfy" "Satisfaction with operating the device \\ \hspace{0.5cm}Very Satisfied" ///
				   "To make water safer" "\\ \textbf{Reasons for chlorinating the water} \\ \hspace{0.5cm}To make water safer" ///
				   "To enhance health" "\hspace{0.5cm}To enhance health" ///
				   "To improve taste and smell of water" "\hspace{0.5cm}To improve taste \& smell of the water" ///
				   "To make water clearer" "\hspace{0.5cm}To make water clearer" ///
				   "To eliminate microbes" "\hspace{0.5cm}To eliminate microbes" ///
				   "Don't know" "\hspace{0.5cm}Don't know" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }

	   

	   *%%%%%%%%%%%%%%%%%%%% Table 7 %%%%%%%%%%%%%%%%%%%%%%%%%%%*
*Loading the dataset
use "${DataTemp}PO_findings_treatment.dta", clear

drop if unique_id=="30602103001" //dropping the observation of the main PO of Mukundpur who has outsourced his job to the PO of hatikhamba
save "${DataTemp}PO_findings_treatment(10obs).dta", replace

*Setting up global macros for calling variables
global PO_7  ilc_satisfaction_1 ilc_satisfaction_2 ilc_satisfaction_4 ///
 type_issues_0 type_issues_1 type_issues_2  pc_issues_1 pc_issues_2 pc_issues_3 ///
 redressal_issues_1 redressal_issues_2  redressal_issues_4  

*Setting up local macros (to be used for labelling the table)
local PO_7 "POs' Perceptions on Household Feedback and Complaint Management"
local LabelPO_7 "PO_Table7"
local notePO_7 "N: 10 - Number of main respondents from 10 treatment villages \newline \textbf{Notes:} (1) One village had two pump operators - included only the responses of the actual operator (2) Included the responses of the pump operator of Karnapadu (where device was uninstalled)" 
local ScalePO_7 "1"

* Descritive stats table: Treatment vs Control Groups 
foreach k in PO_7 { //loop for all variables in the global marco 

use "${DataTemp}PO_findings_treatment(10obs).dta", clear //using the saved dataset 
	
	* Count 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	* Mean
	use "${DataTemp}PO_findings_treatment(10obs).dta", clear
	eststo  model1: estpost summarize $`k' //Total (for all villages)

	* Standard Deviation 
    use "${DataTemp}PO_findings_treatment(10obs).dta", clear
    foreach i in $`k' {
    egen sd_`i' = sd(`i') //calc. sd of each var 
    replace `i' = sd_`i' //replacing values with their sd
}
    eststo model2: estpost summarize $`k' //Store summary statistics of the variables with standard deviation values
	
	
	* Min
	use "${DataTemp}PO_findings_treatment(10obs).dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
	
	* Max
	use "${DataTemp}PO_findings_treatment(10obs).dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	use "${DataTemp}PO_findings_treatment(10obs).dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model5: estpost summarize $`k' //summary stats of count of missing values

*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 using  "${Table}SummStats_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))") /// 	  
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Mean}" "\shortstack[c]{SD}" "Min" "Max" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
				   "Very satisfied" "\\ \multicolumn{7}{c}{\textbf{Panel 1: Level of satisfaction of households}} \\ Reported satisfaction with ILC device\\ \hspace{0.5cm}Very Satisfied" ///
				   "Somewhat satisfied" "\hspace{0.5cm}Somewhat satisfied" ///
				   "Somewhat unsatisfied" "\hspace{0.5cm}Somewhat unsatisfied" ///
				   "No complaints" "\\ \multicolumn{7}{c}{\textbf{Panel 2: Complaints and Redressal}} \\ Types of complaints reported by households \\ \hspace{0.5cm}No complaints" ///
				   "Odor-related complaints" "\hspace{0.5cm}Odor-related complaints" ///
				   "Cooking-related complaints" "\hspace{0.5cm}Cooking-related conplaints" ///
				   "100 per cent" "Percentage of households reporting complaints \\ \hspace{0.5cm}100 per cent" ///
				   "25 per cent" "\hspace{0.5cm}25 per cent" ///
				   "Less than 25 percent" "\hspace{0.5cm}Less than 25 per cent" ///
				   "Tried to convince the villagers" "Measures taken by PO for complaint redressal \\ \hspace{0.5cm}Tried to convince the villagers" ///
				   "Reported the complaints to GV" "\hspace{0.5cm}Reported the complaints to GV" ///
				   "Reported the complaints to village leader" "\hspace{0.5cm}Reported the complaints to village leader" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''") 
	   }

