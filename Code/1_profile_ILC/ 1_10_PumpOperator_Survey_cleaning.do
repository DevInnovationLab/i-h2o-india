/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creates descriptive stats for household characteristics with merged endline & baseline dataset
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
	- "${DataDeid}/pump_operator_survey.dta"
****** Output data/file : 
	- 
****** Do file to run before this do file
	- "2_15_Checks_PumpOperatorSurvey"
****** Language: English
*=========================================================================*/
** In this do file: 
	* This do file exports..... Cleaned data for Pump operator survey


********************************************************************************
*** Opening the deidentified dataset
********************************************************************************
clear 
use "${DataDeid}/pump_operator_survey.dta", clear 


********************************************************************************
*** General Changes
********************************************************************************

// *** Drop variables (not required or notes or empty variables)
// drop po_job_duration_units_label po_job_dur_note po_subscriberid po_simid po_devicephonenum po_intronote po_no_caseid po_info_update po_revisit_note po_review_consent_note po_job_dur_note po_audio_audit_note_start school_anganwadis_note school_anganwadis_tap_note

*** Removing prefix for now
renpfix po_

*** Manual Corrections
//the respondent received salary timely but the response to the question on salary_issue was incorrectly selecetd as "Yes"; replacing the same as "No"
replace salary_issue=0 if salary_freq_oth=="Every month he is getting selery"
replace salary_freq=. if salary_freq_oth=="Every month he is getting selery"
replace reason_irregular_salary="" if salary_freq_oth=="Every month he is getting selery"

/*to check with akito/Vaish
*/
//As per Audio recordings, respondent was selected by Panchayat & formally appointed by RWSS; recoding the response to "appointed by panchayat"
replace appointment_po_person=1 if unique_id=="30602103001"

//The respondent is the PO of two villages and gets paid for both the villages, for one village he is paid by the actual PO for whom he is the proxy and for the other village, he gets paid by Panchayat/RWSS 
replace salary="4000" if unique_id=="30602103002"


*** Replacing don't know as missing
replace tap_connection_nmbr=. if tap_connection_nmbr==999
replace operation_valves=. if operation_valves==999


*** Changing storage type
destring salary, replace



********************************************************************************
*** Cleaning text response variables - categorising into new variables
********************************************************************************

*** Training for the job 
//categorizing as yes if they received training from JE during a pump visit, or attended any training session responses as yes who 
//categorizing as no if they learnt from prev PO, plumber. technician, electrician 
gen training=.
replace training=1 if training_po=="Block je Rwss se sikha ha" | ///
training_po=="Pump Visit pai  Rwss je aay thay je k pas se pump chalana sikha ha" | ///
training_po=="Rwss se training liye hue he" | training_po=="Rayagada se koi to ayethe unone sikhaye" | ///
training_po=="RWSS se training diye the" | training_po=="Govt. Se training horahe gunpur me" | ///
training_po=="JJM Se training diye the kolnora block se." | ///
training_po=="Gunupur pe liye the training lekin kisne diyethe Pata nehi" | ///
training_po=="Block k taraf se Rwss ki JE Gaon me aya thay unse traning Mila ha" | ///
training_po=="JJM KE KOI AETHE USNE SIKHAYE HUE HE/ RWSS SE BHI TRAINING LIYE HUE HE." | ///
training_po=="Gudari block me se koi ngo ake training diye the or BDO se certificate diyehue he election se pehele bhi training liye hue he" 

replace training=2 if training_po=="Plumber se sikha he" | ///
training_po=="Anya operator tharu training naichanti" | training_po=="Purbatana operator tharu sikhi thila" | ///
training_po=="Unka husband Po the unse sikhe he." | ///
training_po=="Moter makanic  se sikha ha" | training_po=="Pump chalana Plumber se sikha ha" | ///
training_po=="Gaon ke jo contractor he usne sikhaya he" | ///
training_po=="Temporary operator se kisa pump operate karna ha sikha ha" | ///
training_po=="Electricians se Pump  chalana sikha and plumber sa pipe tap ka kam sikha" 

replace training=3 if training_po=="Training nehi liye he kahnape bhi" 

label var training "Received formal training"
label define training 1 "Received formal training" 2 "Received informal training" 3 "Did not receive any training"
label values training training

*** Reason for irregular salary
//clubbing the reasons irregualr payment and no payment
gen reason_irreg_pay=""
replace reason_irreg_pay="1" if reason_irregular_salary=="Gram sevak ne thik se salary likh ke nehi detehe thik time pe esiliye late hotahe" | ///
reason_irregular_salary=="Gram sevak thik se govt. Ko report nehi kartehe esiliye nehi miltshe" | ///
reason_irregular_salary=="Gram sevak sign karneke bad he atahe" | ///
reason_irregular_salary=="Gram sevak ne late kartehe" | ///
reason_irregular_salary=="Gram sevak thik se govt. Ko report nehi kartehe esiliye nehi miltshe"

replace reason_irreg_pay="2" if reason_irregular_salary=="PEO ne likh ke dedetehe lekin block pe thoda late kartehe" | ///
reason_irregular_salary=="Gram sevak ne report kardetehe Jo block me CP Jo hotehe wo late process kartehe." | ///
reason_irregular_salary=="Gram sevak thik time pe CP ko report detehe lekin CP ne time pe salary nehi chodtehe"

replace reason_irreg_pay="3" if reason_irregular_salary=="Po side se late ho ta he" | ///
reason_irregular_salary=="Election boli time re dela nahi abong 3 ta gaon ra pump operator nka darama sangara hua kintu karlakana pump operator thik samaya re documents daithila madhya auu 3ta gaon ra operator thik samaya re documents jama Kari thibaru thik samaya re payment milu nahi documents ta( po) nku dauchanti" 

replace reason_irreg_pay="4" if reason_irregular_salary=="Panchayat mey Paisa aneke bad signature Karne ke liye bolate hey. Signature Karne ke baad 7 den ke ander account me payment karte hai." 

replace reason_irreg_pay="5" if reason_irregular_salary=="Vlw payment karna k lia late karta ha" 

replace reason_irreg_pay="6" if reason_irregular_salary=="Thoda sa salary he esiliye Dhyn nehi derahehe" | ///
reason_irregular_salary=="Government change haichi boli time re miluni" | ///
reason_irregular_salary=="Sarpanch ko he bolnese bhi thikse nehi miltahe" | ///
no_salary_reason=="Rwss je  Gp po  ko be complen Kia ha lakin koi sunta nahi ha abhi Rwss ka je election hone k bad kosis karanga bole ha" | ///
no_salary_reason=="4 sal se payment nahi Mila ha BDO ka pas Jana se Rwss ke pass Jana ko bola or RWSS JE  k pass Jana se Rwss je sarpanch k pass bhaj ta ha sarpanch k pass Jana k bad sarpanch hum ko RWSS se notice Ane k bad payment milaga bol rahahan Abhi tak koi hal nahi nikla ha"

replace reason_irreg_pay="3 4" if reason_irregular_salary=="Panchyat re Paisa asi nathibaru ebong thik samaya re sarpanch Gram sewak ebong Rwss JE akka thee hau na thibaru payment thik samaya re hai paruni." 

label var reason_irreg_pay "Reason for irregular salary payment"
// label define reason_irreg_pay 1 "Document issuance delay" 2 "Processing delay from CP to PO" ///
// 3 "Document signing delay" 4 "Processing delay from BDO to Panchayat" 5 "Processing delay from Panchayat to PO" ///
// 6 "Lack of accountability"
// label values reason_irreg_pay reason_irreg_pay

gen reason_irreg_pay_1=1 if reason_irreg_pay=="1"
replace reason_irreg_pay_1=0 if reason_irreg_pay!="1"
replace reason_irreg_pay_1=. if reason_irreg_pay==""

gen reason_irreg_pay_2=1 if reason_irreg_pay=="2"
replace reason_irreg_pay_2=0 if reason_irreg_pay!="2"
replace reason_irreg_pay_2=. if reason_irreg_pay==""

gen reason_irreg_pay_3=1 if reason_irreg_pay=="3" | reason_irreg_pay=="3 4"
replace reason_irreg_pay_3=0 if reason_irreg_pay!="3" & reason_irreg_pay!="3 4"
replace reason_irreg_pay_3=. if reason_irreg_pay==""

gen reason_irreg_pay_4=1 if reason_irreg_pay=="4" | reason_irreg_pay=="3 4"
replace reason_irreg_pay_4=0 if reason_irreg_pay!="4" & reason_irreg_pay!="3 4"
replace reason_irreg_pay_4=. if reason_irreg_pay==""

gen reason_irreg_pay_5=1 if reason_irreg_pay=="5" 
replace reason_irreg_pay_5=0 if reason_irreg_pay!="5"
replace reason_irreg_pay_5=. if reason_irreg_pay==""

gen reason_irreg_pay_6=1 if reason_irreg_pay=="6"
replace reason_irreg_pay_6=0 if reason_irreg_pay!="6"
replace reason_irreg_pay_6=. if reason_irreg_pay==""

/*
Classifying based on inpurts from Enumerators on each village: 
reason_irregular_salary
Panchyat re Paisa asi nathibaru ebong thik samaya re sarpanch Gram sewak ebong Rwss JE akka thee hau na thibaru payment thik samaya re hai paruni.  //6
Panchayat mey Paisa aneke bad signature Karne ke liye bolate hey. Signature Karne ke baad 7 den ke ander account me payment karte hai. //4
Po side se late ho ta he //3???
Gram sevak ne thik se salary likh ke nehi detehe thik time pe esiliye late hotahe //1
Vlw payment karna k lia late karta ha //5
Gram sevak thik se govt. Ko report nehi kartehe esiliye nehi miltshe //1
Gram sevak thik time pe CP ko report detehe lekin CP ne time pe salary nehi chodtehe //1 (Asada: more details from audio recordings)
Gram sevak ne report kardetehe Jo block me CP Jo hotehe wo late process kartehe. //2
Sarpanch ko he bolnese bhi thikse nehi miltahe //7????
Gram sevak ne late kartehe //1
Government change haichi boli time re miluni //7
PEO ne likh ke dedetehe lekin block pe thoda late kartehe //2
Election boli time re dela nahi abong 3 ta gaon ra pump operator nka darama sangara hua kintu karlakana pump operator thik samaya re documents daithila madhya auu 3ta gaon ra operator thik samaya re documents jama Kari thibaru thik samaya re payment milu nahi documents ta( po) nku dauchanti  //3 (Karlakana: more details from audio recordings)
Gram sevak sign karneke bad he atahe //1
Thoda sa salary he esiliye Dhyn nehi derahehe //7 (Naira: add quote from the audio recordings)

no_salary_reason
Rwss je  Gp po  ko be complen Kia ha lakin koi sunta nahi ha abhi Rwss ka je election hone k bad kosis karanga bole ha //7
4 sal se payment nahi Mila ha BDO ka pas Jana se Rwss ke pass Jana ko bola or RWSS JE  k pass Jana se Rwss je sarpanch k pass bhaj ta ha sarpanch k pass Jana k bad sarpanch hum ko RWSS se notice Ane k bad payment milaga bol rahahan Abhi tak koi hal nahi nikla ha //7
*/


*** Salary Source  - how is salary collected and paid to you
gen salary_source_new=.
replace salary_source_new=1 if salary_source=="Panchyat ru account re jama hua" | ///
salary_source=="Panchyat ka taraf se bank account me milta hai." | ///
salary_source=="Panchyat se bank account me aya ha" | ///
salary_source=="Gram sevak ne likh ke sarpanch ko detehe or block se pesa atahe" | ///
salary_source=="Panchayat se vlw account me payment karte hai" | ///
salary_source=="Gram sevak ne CP chodtehe or CP ne account pe detehe" | ///
salary_source=="Gram sevak ne likh ke detehe or salary account pe atahe" | ///
salary_source=="salary unko Gp derahahe or Salary govt. Ne derahehe" | ///
salary_source=="Rwss tarafru account ku jama hua" | ///
salary_source=="BDO se CP se account pe chodrahehe" | ///
salary_source=="Account me payment milta ha Rwss k taraf se" | ///
salary_source=="Bank account me block Rwss se milta ha"

//two respondents who get apid by proxys have said they are paid by gram sevak but based on observer's notes, enumertor's comments and translations from audio recordings, categorsing them to a new category 
replace salary_source_new=2 if salary_source=="Gramasebaka ne unke account pe detehe." | ///
salary_source=="Gram sevak ne cp BDO request karke salary miltahe"

replace salary_source_new=999 if salary_source=="Don't know" 
replace salary_source_new=1 if salary_source_new==999 //these three respondents mentioned that they get paid by RWSS office or GRam Panchayat in "Salary_source" but don't know the details of how payment is collected and paid as asked in "salary_source" so recategorsing these responses to salary paid by "Panchayat/RWSS"

label var salary_source_new "Source of source"
label define salary_source_new 1 "Panchayat/RWSS" 2 "Paid by a proxy" 999 "Don't know"
label values salary_source_new salary_source_new


********************************************************************************
*** Cleaning other category variables - categorizing into existing/new categories
********************************************************************************

*** Duties as the Pump operator
*creating new category for duties related to power supply to the pump 
gen duties_po_10=.
replace duties_po_10=1 if duties_po_oth=="Electric problem hua to thik karta ha" | ///
duties_po_oth=="Electric problem bhi kartehe" | ///
duties_po_oth=="Electric Panel me  problem hota to fuse bandhta ha" | ///
duties_po_oth=="1.Current ka reading lerahehe 2.Note maintain kartehe kitna pani chodtehe" | ///
duties_po_oth=="ILC Device Pe Tablet dalta ha ,Electric fuse banta ha" | ///
duties_po_oth=="Meter reading le rahehe" | ///
duties_po_oth=="Current Ata jata rehetahe usko firs se dekhana padtahe. Current jab fuse jatahe tabhi khud fuse lagadetehe wo be karna padtahe."

*creating new category for refilling the ilc device
gen duties_po_11=.
replace duties_po_11=1 if duties_po_oth=="Refill karrahehe" | ///
duties_po_oth=="ILC Device Pe Tablet dalta ha ,Electric fuse banta ha"

*recategorising other category responses to existing categories  
replace duties_po_8=1 if duties_po_oth=="New water tap connection"
replace duties_po_4=1 if duties_po_oth=="Ilc device ko control kartehe" //control the ILC device 

*replacing po_duties_po__77 as 0 after categorising the responses in other category 
replace duties_po__77=0 if duties_po_oth=="Electric problem hua to thik karta ha" | ///
duties_po_oth=="Electric problem bhi kartehe" | ///
duties_po_oth=="Electric Panel me  problem hota to fuse bandhta ha" | ///
duties_po_oth=="1.Current ka reading lerahehe 2.Note maintain kartehe kitna pani chodtehe" | ///
duties_po_oth=="ILC Device Pe Tablet dalta ha ,Electric fuse banta ha" | ///
duties_po_oth=="Meter reading le rahehe" | ///
duties_po_oth=="Current Ata jata rehetahe usko firs se dekhana padtahe. Current jab fuse jatahe tabhi khud fuse lagadetehe wo be karna padtahe." | ///
duties_po_oth=="Refill karrahehe" | ///
duties_po_oth=="ILC Device Pe Tablet dalta ha ,Electric fuse banta ha" | ///
duties_po_oth=="New water tap connection" | duties_po_oth=="Ilc device ko control kartehe"


*** Reason for issues with water supply
*recategorising other category response to existing category
replace water_supply_reason_8=1 if water_supply_reason_oth=="Borewell ka Jo layer he wo kam he esiliye pani utha"

*replacing water_supply_reason__77 as 0 after categorizing the responses in other category
replace water_supply_reason__77=0 if water_supply_reason_oth=="Borewell ka Jo layer he wo kam he esiliye pani utha"


*** Frequency of cleaning the tank
*recategorising other category response to existing category
replace cleaning_tank_freq=2 if cleaning_tank_freq_oth=="Month me 2 bar" //twice a month
replace cleaning_tank_freq=0 if cleaning_tank_freq_oth=="Jab tank hua tha tabhi saf kiye the" //cleaned only when the tank was installed
replace cleaning_tank_freq=4 if cleaning_tank_freq_oth=="3 ya 4 month me ek bar" //every 3-4 months
replace cleaning_tank_freq=5 if cleaning_tank_freq_oth=="1 year me ekk bar saaf karta han" //once a year

/* Not categorised yet: cleaning_tank_freq_oth
"Ek sal me 3 bar horahahe or barish ke time pe hotahe"
*/

*** Operation of water supply valves
*recategorising other category response to existing category
replace operation_valves_who=3 if operation_valves_who_oth=="Gaon me ek ladka ko sikhaya he"
replace operation_valves_who=1 if operation_valves_who_oth=="Additional Po chalatehe or unka beta bhi chalatehe"


*** Challenges while installing the device
*creating new category 
gen ilc_install_challenge_0=.
replace ilc_install_challenge_0=0 if ilc_install_challenge!=""
replace ilc_install_challenge_0=1 if ilc_install_challenge_oth=="No" | ///
ilc_install_challenge_oth=="Me dusra jage kam kartahu jab device lagane atehe to wo bas bulatehe." | /// //respondent works at a different placeand was called to be there for installation
ilc_install_challenge_oth=="Esa kuch hard nehi hua tha" | ///
ilc_install_challenge_oth=="Kuch problem nehi tha" | ///
ilc_install_challenge_oth=="Answer -NO" | ilc_install_challenge_oth=="Koi problem nehi tha" | ///
ilc_install_challenge_oth=="Esa kuch jyada hard nehi sochatha"

/* Not categorised yet: ilc_install_challenge_oth
"Device lagagila samaya re Pani ra pressure asu na thila."
"Jese ki hole karneko pipe line hard hoga sochrhethe"
*/

*replacing ilc_install_challenge__77 as 0 after categorizing the responses in other category
replace ilc_install_challenge__77=0 if ilc_install_challenge_oth=="No" | ///
ilc_install_challenge_oth=="Me dusra jage kam kartahu jab device lagane atehe to wo bas bulatehe." | ///
ilc_install_challenge_oth=="Esa kuch hard nehi hua tha" | ///
ilc_install_challenge_oth=="Kuch problem nehi tha" | ///
ilc_install_challenge_oth=="Answer -NO" | ilc_install_challenge_oth=="Koi problem nehi tha" | ///
ilc_install_challenge_oth=="Esa kuch jyada hard nehi sochatha" 


*** Frequency of interactions with GP/RWSS JE
*creating new category 
replace interaction_freq=7 if interaction_freq_oth=="Mahina me 2 bar"
label drop interaction_freq
label var interaction_freq "Interaction with GP/JE"
label define interaction_freq 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Every 6 months" 5 "Annually" 6 "No fixed schedule" 7 "Bi-monthly" -77 "Other"
label values interaction_freq interaction_freq


*** Types of issues discussed during interactions
*recategorising other category responses to existing responses
replace interaction_issues_2=1 if interaction_issues_oth=="Unko bolrahe ke current bale se Samprk kare/ Rwss ko boltehe ke dusra borewell keliye bhi boltehe." | ///
interaction_issues_oth=="Agar pipe line pe kuch problems hua to bhi batatehe" //related to new borewell and electricity issue; related to water pipeline

*replacing interaction_issues__77 as 0 after categorizing the responses in other category
replace interaction_issues__77=0 if interaction_issues_oth=="Unko bolrahe ke current bale se Samprk kare/ Rwss ko boltehe ke dusra borewell keliye bhi boltehe." | ///
interaction_issues_oth=="Agar pipe line pe kuch problems hua to bhi batatehe" 

/*Not categorised yet: interaction_issues_oth:
"Kuch bhi assessorys chahiye to bat hotahe"
*/



*** Type of issues reported by the hosueholds 
*recategorising other category responses to existing responses
replace hh_issues=0 if hh_issues_type_other=="Pani Kam hauthiba katha janai thile." //problem mentioned in the othe rcategory is related to water supply, recoding this as "No problem reported"

*replacing hh_issues_type__77 and other binary variables as . after recategorizing the responses in other category
foreach var in varlist hh_issues_type__77 hh_issues_type_1 hh_issues_type_2 ///
hh_issues_type_3 hh_issues_type_4 hh_issues_type_5 hh_issues_response_1 ///
hh_issues_response_2 hh_issues_response_3 hh_issues_response_4 hh_issues_response_5 ///
hh_issues_response_6 hh_issues_response_7 hh_issues_response_8 hh_issues_response__77 {
replace `var'=. if hh_issues_type_other=="Pani Kam hauthiba katha janai thile."
}

*replacing hh_issues_response as  "" after recategorizing the responses in other category
replace hh_issues_response="" if hh_issues_type_other=="Pani Kam hauthiba katha janai thile."

***


********************************************************************************
*** Generating new variables
********************************************************************************
 
*** Job duration
gen duration_job_new=.
replace duration_job_new=2 if job_duration>=1 & job_duration<=4
replace duration_job_new=3 if job_duration>=5 & job_duration<=8
replace duration_job_new=4 if job_duration>=7 & job_duration<=12
replace duration_job_new=5 if job_duration>12
replace duration_job_new=1 if job_duration==7 & job_duration_units==3

label var duration_job_new "Job duration"
label define duration_job_new 1 "Less than 1 year" 2 "1-4 years" 3 "5-8 years" 4 "9-12 years" 5 "More than 12 years"
label values duration_job_new duration_job_new 

*** Additional duties
gen addtl_duties_yn=.
replace addtl_duties_yn=1 if addtl_duties=="1 2 3 4"

label var addtl_duties_yn "Willing to take up additional duties"
label define addtl_duties_yn 1 "Yes" 0 "No"
label values addtl_duties_yn addtl_duties_yn

*** Appointment 
gen appointment_new=appointment_po_person
replace appointment_new=1 if appointment_po_person_oth=="Po me Jo president hote he usne bolke rakhe hue he" //the president of informal po union recommended her name to GP

label var appointment_new "Appointment"
label define appointment_new 1 "Appointed by Gram Panchayat" 3 "Appointed by Village Leadership" 2 "Appointed by RWSS" 
label values appointment_new appointment_new

***  

//
// * Create new variables for mapping ilc_monitor_freq_daily
// forvalues i = 1/8 {
//     gen duties_daily_`i' = .
// }
//
// * Loop through each possible re-encoded value in ilc_monitor_freq_daily
// forvalues i = 1/8 {
//     * Loop through each corresponding ilc_monitor_type_`j' variables
//     forvalues j = 1/8 {
//         * Check if ilc_monitor_type_`j' is not zero and if it matches the current re-encoded value
//         if ilc_monitor_type_`j' == 1 {
//             * Assign `j` to the corresponding duties_daily_`i' if `i` matches the re-encoded value
//             replace duties_daily_`i' = `j'
//         }
//     }
// }
//
//

*** Generating new variable to store re-encoded values of ilc_monitor_freq_daily
gen ilc_daily_task=""
replace ilc_daily_task="2" if ilc_monitor_type=="2 6 7" & unique_id=="30301101001"
replace ilc_daily_task="1 3" if ilc_monitor_type=="1 3 6" & unique_id=="30701101001"
replace ilc_daily_task="1" if ilc_monitor_type=="1 2 3 7" & unique_id=="50401101001"
replace ilc_daily_task="3" if ilc_monitor_type=="2 3 6" & unique_id=="10101103001"
replace ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="30602103002"
replace ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="30602103001"
replace ilc_daily_task="1 2 3 4" if ilc_monitor_type=="1 2 3 4 6" & unique_id=="50501103001"
replace ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="20101103001"
replace ilc_daily_task="0" if ilc_monitor_type=="2 6" & unique_id=="40201103001" //respondent does not perform any task daily and selected an empty response in ilc_monitor_freq_daily
replace ilc_daily_task="1 3 6" if ilc_monitor_type=="1 2 3 6" & unique_id=="40401103001"

*** Creating binary variables to store the responses of ilc_daily_task
* List of values for which binary variables are required
local values "1 2 3 4 5 6 7 8"

* Create new binary variables
foreach value of local values {
    gen ilc_daily_task_`value' = 0
}

* Populate the binary variables based on ilc_daily_task
foreach value of local values {
    * Check if the value is present in ilc_daily_task
    replace ilc_daily_task_`value' = 1 if strpos(ilc_daily_task, "`value'") > 0
}

* Labelling the binary variables
label var ilc_daily_task "Tasks performed daily"
label var ilc_daily_task_1 "Opening/closing valves of device during the time of filling the tank"
label var ilc_daily_task_2 "Adjusting the valves on the device to control the chlorine dose"
label var ilc_daily_task_3 "Draining the valves of the device"
label var ilc_daily_task_4 "Cleaning the device regularly"
label var ilc_daily_task_5 "Checking the device for leaks"
label var ilc_daily_task_6 "Checking the device for chlorine refills"
label var ilc_daily_task_7 "Informing the installation team of any issues"
label var ilc_daily_task_8 "Repairing the device as needed"


*** Generating variable for the duties that are not performed daily:
* Creating binary variables for tasks that are not performed daily
forvalues i = 1/8 {
    gen ilc_notdaily_task_`i' = ilc_monitor_type_`i' & !ilc_daily_task_`i'
	replace ilc_notdaily_task_`i'=. if ilc_monitor_type_`i'==.
	
}

* Create a space-separated string for ilc_notdaily_task: tasks not done daily
gen ilc_notdaily_task = ""
forvalues i = 1/8 {
    * Append task index to task3 if the task3_`i' variable is 1
    replace ilc_notdaily_task = ilc_notdaily_task + cond(ilc_notdaily_task_`i' == 1, "`i' ", "") if ilc_notdaily_task_`i' == 1
}

* Labelling the binary variables
label var ilc_notdaily_task "Tasks not performed daily"
label var ilc_notdaily_task_1 "Opening/closing valves of device during the time of filling the tank"
label var ilc_notdaily_task_2 "Adjusting the valves on the device to control the chlorine dose"
label var ilc_notdaily_task_3 "Draining the valves of the device"
label var ilc_notdaily_task_4 "Cleaning the device regularly"
label var ilc_notdaily_task_5 "Checking the device for leaks"
label var ilc_notdaily_task_6 "Checking the device for chlorine refills"
label var ilc_notdaily_task_7 "Informing the installation team of any issues"
label var ilc_notdaily_task_8 "Repairing the device as needed"

*** Time taken to carry out dailiy tasks
gen time_taken=ilc_monitor_duration //missing values pertain to control group and those who don't know how much time it. takes
replace time_taken=0 if ilc_monitor_duration==0 | ilc_monitor==0 //no time taken: either does not perform any tasks daily or does not perform any tasks at all
replace time_taken=. if time_taken==999

*** 


********************************************************************************
*** Labelling variables
********************************************************************************
 
label var duties_po_1 "Operating the pump"
label var duties_po_2 "Operating the water supply valves"
label var duties_po_3 "Cleaning the tank"
label var duties_po_4 "Operating the ILC Device"
label var duties_po_5 "Draining the ILC device"
label var duties_po_6 "Fixing the pump when it breaks"
label var duties_po_7 "Fixing the supply line or valves when they break"
label var duties_po_8 "Fixing the tap connections"
label var duties_po_9 "Contacting RWSS or another government body to fix problems"
label var duties_po_10 "Power supply related duties"
label var duties_po_11 "Refilling the device"
label var duties_po__77  "Other"
label var other_work_type_1 "Self-employed (agriculture-related)"
label var other_work_type_2 "Self-employed (non-agricultural)"
label var other_work_type_3 "Agriculture labour"
label var other_work_type_4 "Casual daily wage labour (non-agricultural)"
label var other_work_type_5 "Salaried job"
label var other_work_type__77 "Other"
label var addtl_duties_1 "Operate a water treatment device daily"
label var addtl_duties_2 "Fix a water treatment device if it breaks down"
label var addtl_duties_3 "Monitor and inform RWSS if a water treatment device breaks down"
label var addtl_duties_4 "Communicate to villagers the importance of water treatment"
label var addtl_duties_0 "No, I do not want to take up additional responsibilities"
label var addtl_duties_no_1 "Not enough compensation"
label var addtl_duties_no_2 "Not enough time"
label var addtl_duties_no_3 "The tasks are too difficult"
label var addtl_duties_no_4 "Not enough support from people in the village"
label var addtl_duties_no_5 "Not enough support from Gram Panchayat"
label var addtl_duties_no_6 "Not enough support from RWSS"
label var addtl_duties_no__77 "Other"
label var interaction_issues_1 "Issues related to water supply"
label var interaction_issues_2 "Issues related to infratsructure" 
label var interaction_issues_3 "Complaints from households in the village"
label var interaction_issues_4 "My salary and compensation"
label var interaction_issues__77 "Other"
label var water_supply_reason_1 "Pump had some technical issues and it would not work"
label var water_supply_reason_2 "Solar powered pump did not receive water"
label var water_supply_reason_3 "Electricity was out because of a technical problem"
label var water_supply_reason_4 "Electricity bill wasn't paid (smart meter)"
label var water_supply_reason_5 "Recent pipeline leakages/damages"
label var water_supply_reason_6 "Pump was not turned on "
label var water_supply_reason_7 "Major village events (holiday/festival/funeral/etc)"
label var water_supply_reason_8 "Borehole was dry"
label var water_supply_reason__77 "Other"
label var ilc_install_support_1 "Observed the installation but did not take part in helping"
label var ilc_install_support_2 "Assisted the installation team by cleaning/digging the area for the installation"
label var ilc_install_support_3 "Assisted the installation team in sourcing material for the installation "
label var ilc_install_support_4 "Assisted the installation team in installing parts of the device to the tank/inlet"
label var ilc_install_support_5 "Assisted installation team in explaining the storage reservoir and distribution system"
label var ilc_install_support_6 "Assisted installation team in getting necessary village level approvals"
label var ilc_install_support_7 "Tuned the valves on/off during installation"
label var ilc_install_support__77 "Other"
label var ilc_install_challenge_0 "No challenges"
label var ilc_install_challenge_1 "Chosen pipeline was not the correct location to install the device"
label var ilc_install_challenge_2 "Installing device was labor-intensive"
label var ilc_install_challenge_3 "Installing device was time-intensive"
label var ilc_install_challenge_4 "Chlorination device was complicated to understand"
label var ilc_install_challenge_5 "Insufficient materials or materials not available at the time of installing device"
label var ilc_install_challenge__77 "Other"
label var ilc_monitor_type_1 "Opening/closing valves of device while filling the tank"
label var ilc_monitor_type_2 "Adjusting the valves on the device to control the chlorine dose"
label var ilc_monitor_type_3 "Draining the valves of the device"
label var ilc_monitor_type_4 "Cleaning the device regularly"
label var ilc_monitor_type_5 "Checking the device for leaks"
label var ilc_monitor_type_6 "Checking the device for chlorine refills"
label var ilc_monitor_type_7 "Informing the installation team of any issues"
label var ilc_monitor_type_8 "Repairing the device as needed"
label var ilc_monitor_type__77 "Other"
label var reason_irreg_pay_1 "Document issuance delay"
label var reason_irreg_pay_2 "Processing delay from CP to PO"
label var reason_irreg_pay_3 "Document signing delay"
label var reason_irreg_pay_4 "Processing delay from BDO to panchayat"
label var reason_irreg_pay_5 "Processing delay from Panchayat to PO"
label var reason_irreg_pay_6 "Lack of accountabilty"
label var ilc_refill "Provides refill to the ILC device"
label var reason_chlorination_1 "To make the water safer to drink"
label var reason_chlorination_2 "The water will make people healthier"
label var reason_chlorination_3 "The water will taste and smell better"
label var reason_chlorination_4 "The water will become clearer or less muddy"
label var reason_chlorination_5 "The chlorine will kill microbes (bacteria or viruses) in the water "
label var reason_chlorination__77 "Other"
label var reason_chlorination_999 "Don't know"

********************************************************************************
*** Saving the cleaned dataset 
********************************************************************************

save "{DataFinal}pump_operator_survey.dta", replace

********************************************************************************
*** Creating variables for use in summary stats tables -- MOVE TO NEW CODE FILE AFTERWARDS
********************************************************************************

use "{DataFinal}pump_operator_survey.dta", clear 

*** Creating new variables to ensure consistency of obs 
//Payment
gen pay_new=.
replace pay_new=0 if receive_salary==0 //does not receive salary
replace pay_new=1 if salary_source_new==1 //recieves salary from panchayat/rwss 
replace pay_new=2 if salary_source_new==2 //recieves salary from proxy 

//Payment issues
gen pay_issues=.
replace pay_issues=0 if receive_salary==0 //does not receive salary
replace pay_issues=1 if salary_issue==1 //faces issues
replace pay_issues=2 if salary_issue==0 //no issues

//Reasons for irregular pay: detailed
gen pay_delay=.
replace pay_delay=0 if salary_issue==0 //does not face any issues with pay 
replace pay_delay=1 if reason_irreg_pay_1==1 //document issuance delay
replace pay_delay=2 if reason_irreg_pay_2==1 //processing delay form CP to BDO
replace pay_delay=3 if reason_irreg_pay_3==1 //document signing delay
replace pay_delay=4 if reason_irreg_pay_4==1 //processing delay from bdo to panchayat
replace pay_delay=5 if reason_irreg_pay_5==1 //processing delay from panchayat to po
replace pay_delay=6 if reason_irreg_pay_6==1 //lack of accountability

//Reasons for irregular pay: categorised
gen pay_delay2=.
replace pay_delay2=0 if salary_issue==0 //does not face any issues with pay 
replace pay_delay2=1 if reason_irreg_pay_1==1 | reason_irreg_pay_3==1 | reason_irreg_pay_5==1 //delay on the part of GP
replace pay_delay2=2 if reason_irreg_pay_2==1 | reason_irreg_pay_4==1 //delay on the part of BDO officials
replace pay_delay2=3 if reason_irreg_pay_6==1 //delay due to lack of accountabilty

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
replace monitor_daily=0 if ilc_daily_task=="0" | ilc_monitor==0 //does not carry out any tasks daily (includes karnapadu)
replace monitor_daily=1 if ilc_daily_task_1==1 //openig and closing the valves
replace monitor_daily=2 if ilc_daily_task_2==1 //adjusting the valves
replace monitor_daily=3 if ilc_daily_task_3==1 //draining the device
replace monitor_daily=4 if ilc_daily_task_4==1 //cleaning the device
replace monitor_daily=5 if ilc_daily_task_6==1 //checking for refills

//Tasks not perfomed daily
gen monitor_notdaily=. //control group 
replace monitor_notdaily=0 if ilc_notdaily_task=="0" | ilc_monitor==0 //does not carry out any tasks even irregularly (includes karnapadu)
replace monitor_notdaily=1 if ilc_notdaily_task_2==1 //adjusting the valves
replace monitor_notdaily=2 if ilc_notdaily_task_6==1 //checking for refills
replace monitor_notdaily=3 if ilc_notdaily_task_7==1 //informing installation team 

//performs refills
gen refill=. //control group
replace refill=1 if ilc_refill==1 //provides refills
replace refill=0 if ilc_monitor==0 | ilc_refill==0 //does not provide refills (includes karnapadu)

//frequency of perfoming occasional tasks
gen freq_notdaily_tasks=ilc_monitor_freq //missing values pertain to control group
replace freq_notdaily_tasks=0 if village_name=="Karnapadu" 

//hh issues type
gen_type_issues=. //control group
replace type_issues=0 if hh_issues==0 //no issues 
replace type_issues=1 if hh_issues_type_1==1 //smell
replace type_issues=2 if hh_issues_type_4==1 //taste

//percentage of hhs reporting issues
gen pc_issues=. //control group
replace pc_issues=0 if hh_issues==0 //no issues/0%
replace pc_issues=1 if hh_issues_percent==1 //all hhs (100%)
replace pc_issues=2 if hh_issues_percent==4 //some hhs (25%)
replace pc_issues=3 if hh_issues_percent==5 //few hhs (>25%)

//



//changing refused to know as missing
replace school_level=. if school_level==-98

*** Creating dummies
foreach v in duration_job_new school_level appointment_new training otherwork_tables ///
 pay_new pay_issues pay_delay pay_delay2 interaction_gp interaction_freq ///
 interaction_issues_1 interaction_issues_2 interaction_issues_3 ///
 interaction_issues_4 interaction_issues__77 op_valve_new op_ilc_new op_valve_no ///
 op_ilc_30 refill monitor_notdaily monitor_daily ilc_monitor addtl_duties_yn ///
 addtl_duties_comp reason_chlorination_1 reason_chlorination_2 reason_chlorination_3 ///
 reason_chlorination_4 reason_chlorination_5 reason_chlorination_999 op_satisfaction ilc_satisfaction_po {
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
label var time_taken "Time spent on daily operation and maintainence"
//Willingness to perform additional duties 
// label var addtl_duties_yn_0 "Unwilling to do additional duties"
label var addtl_duties_yn_1 "Willing to do additional duties" 
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

********************************************************************************
*** Generating the table - DESCRIPTIVE STATISTICS 
********************************************************************************	

*** Saving the dataset 
save "${DataTemp}PO_findings.dta", replace

*** Creation of the table

	   *%%%%%%%%%%%%%%%%%%%% Table 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%*

*Setting up global macros for calling variables
global PO_1 resp_age school_level_1 school_level_2 school_level_3 school_level_5 ///
otherwork_tables_0 otherwork_tables_1 otherwork_tables_2 otherwork_tables_3 otherwork_tables_4 ///
duration_job_new_1 duration_job_new_2 duration_job_new_3 duration_job_new_4 duration_job_new_5 ///
appointment_new_1 appointment_new_2 appointment_new_3 training_1 training_2 training_3 ///
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
monitor_daily_2 monitor_daily_3 monitor_daily_4 monitor_daily_5 time_taken /// 
monitor_notdaily_1 monitor_notdaily_2 monitor_notdaily_3 refill_1 refill_0 ///
addtl_duties_yn_1 addtl_duties_comp_1 


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




