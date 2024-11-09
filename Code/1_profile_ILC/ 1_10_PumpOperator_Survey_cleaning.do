/*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: Creates descriptive stats for household characteristics with merged endline & baseline dataset
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
	- "${DataDeid}/pump_operator_survey.dta"
****** Output data/file : 
	- "${DataFinal}pump_operator_survey.dta"
****** Do file to run before this do file
	- "2_15_Checks_PumpOperatorSurvey.do"
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

*** Removing prefix for now
renpfix po_

*** Manual Corrections
//the respondent received salary timely but the response to the question on salary_issue was incorrectly selecetd as "Yes"; replacing the same as "No"
replace salary_issue=0 if salary_freq_oth=="Every month he is getting selery"
replace salary_freq=. if salary_freq_oth=="Every month he is getting selery"
replace reason_irregular_salary="" if salary_freq_oth=="Every month he is getting selery"

/*to check with Jeremy
salary_freq_oth==One time //received salary once in last 6 months: payment for all six months made at once
*/

//As per Audio recordings, respondent was selected by Panchayat & formally appointed by RWSS; recoding the response to "appointed by panchayat"
replace appointment_po_person=1 if unique_id=="30602103001"

//The respondent is the PO of two villages and gets paid for both the villages, for one village he is paid by the actual PO for whom he is the proxy and for the other village, he gets paid by Panchayat/RWSS 
replace salary="4000" if unique_id=="30602103002"


// *** Replacing don't know as missing
// replace tap_connection_nmbr=. if tap_connection_nmbr==999
// replace operation_valves=. if operation_valves==999
//

*** Changing storage type
destring salary, replace



********************************************************************************
*** Cleaning text response variables - categorising into new variables
********************************************************************************

*** Training for the job 
//categorizing as yes if they received training from JE during a pump visit, or attended any training session responses as yes who 
//categorizing as no if they learnt from prev PO, plumber. technician, electrician 
gen C_training=.
replace C_training=1 if training_po=="Block je Rwss se sikha ha" | ///
training_po=="Pump Visit pai  Rwss je aay thay je k pas se pump chalana sikha ha" | ///
training_po=="Rwss se training liye hue he" | training_po=="Rayagada se koi to ayethe unone sikhaye" | ///
training_po=="RWSS se training diye the" | training_po=="Govt. Se training horahe gunpur me" | ///
training_po=="JJM Se training diye the kolnora block se." | ///
training_po=="Gunupur pe liye the training lekin kisne diyethe Pata nehi" | ///
training_po=="Block k taraf se Rwss ki JE Gaon me aya thay unse traning Mila ha" | ///
training_po=="JJM KE KOI AETHE USNE SIKHAYE HUE HE/ RWSS SE BHI TRAINING LIYE HUE HE." | ///
training_po=="Gudari block me se koi ngo ake training diye the or BDO se certificate diyehue he election se pehele bhi training liye hue he" 

replace C_training=2 if training_po=="Plumber se sikha he" | ///
training_po=="Anya operator tharu training naichanti" | training_po=="Purbatana operator tharu sikhi thila" | ///
training_po=="Unka husband Po the unse sikhe he." | ///
training_po=="Moter makanic  se sikha ha" | training_po=="Pump chalana Plumber se sikha ha" | ///
training_po=="Gaon ke jo contractor he usne sikhaya he" | ///
training_po=="Temporary operator se kisa pump operate karna ha sikha ha" | ///
training_po=="Electricians se Pump  chalana sikha and plumber sa pipe tap ka kam sikha" 

replace C_training=3 if training_po=="Training nehi liye he kahnape bhi" 

label var C_training "Received formal training"
label define C_training 1 "Received formal training" 2 "Received informal training" 3 "Did not receive any training"
label values C_training C_training

*** Reason for irregular salary
//clubbing the reasons irregualr payment and no payment
gen C_reason_irreg_pay=""
replace C_reason_irreg_pay="1" if reason_irregular_salary=="Gram sevak ne thik se salary likh ke nehi detehe thik time pe esiliye late hotahe" | ///
reason_irregular_salary=="Gram sevak thik se govt. Ko report nehi kartehe esiliye nehi miltshe" | ///
reason_irregular_salary=="Gram sevak sign karneke bad he atahe" | ///
reason_irregular_salary=="Gram sevak ne late kartehe" | ///
reason_irregular_salary=="Gram sevak thik se govt. Ko report nehi kartehe esiliye nehi miltshe"

replace C_reason_irreg_pay="2" if reason_irregular_salary=="PEO ne likh ke dedetehe lekin block pe thoda late kartehe" | ///
reason_irregular_salary=="Gram sevak ne report kardetehe Jo block me CP Jo hotehe wo late process kartehe." | ///
reason_irregular_salary=="Gram sevak thik time pe CP ko report detehe lekin CP ne time pe salary nehi chodtehe"

replace C_reason_irreg_pay="3" if reason_irregular_salary=="Po side se late ho ta he" | ///
reason_irregular_salary=="Election boli time re dela nahi abong 3 ta gaon ra pump operator nka darama sangara hua kintu karlakana pump operator thik samaya re documents daithila madhya auu 3ta gaon ra operator thik samaya re documents jama Kari thibaru thik samaya re payment milu nahi documents ta( po) nku dauchanti" 

replace C_reason_irreg_pay="4" if reason_irregular_salary=="Panchayat mey Paisa aneke bad signature Karne ke liye bolate hey. Signature Karne ke baad 7 den ke ander account me payment karte hai." 

replace C_reason_irreg_pay="5" if reason_irregular_salary=="Vlw payment karna k lia late karta ha" 

replace C_reason_irreg_pay="6" if reason_irregular_salary=="Thoda sa salary he esiliye Dhyn nehi derahehe" | ///
reason_irregular_salary=="Government change haichi boli time re miluni" | ///
reason_irregular_salary=="Sarpanch ko he bolnese bhi thikse nehi miltahe" | ///
no_salary_reason=="Rwss je  Gp po  ko be complen Kia ha lakin koi sunta nahi ha abhi Rwss ka je election hone k bad kosis karanga bole ha" | ///
no_salary_reason=="4 sal se payment nahi Mila ha BDO ka pas Jana se Rwss ke pass Jana ko bola or RWSS JE  k pass Jana se Rwss je sarpanch k pass bhaj ta ha sarpanch k pass Jana k bad sarpanch hum ko RWSS se notice Ane k bad payment milaga bol rahahan Abhi tak koi hal nahi nikla ha"

replace C_reason_irreg_pay="3 4" if reason_irregular_salary=="Panchyat re Paisa asi nathibaru ebong thik samaya re sarpanch Gram sewak ebong Rwss JE akka thee hau na thibaru payment thik samaya re hai paruni." 

label var C_reason_irreg_pay "Reason for irregular salary payment"
// label define reason_irreg_pay 1 "Document issuance delay" 2 "Processing delay from CP to PO" ///
// 3 "Document signing delay" 4 "Processing delay from BDO to Panchayat" 5 "Processing delay from Panchayat to PO" ///
// 6 "Lack of accountability"
// label values reason_irreg_pay reason_irreg_pay

gen C_reason_irreg_pay_1=1 if C_reason_irreg_pay=="1"
replace C_reason_irreg_pay_1=0 if C_reason_irreg_pay!="1"
replace C_reason_irreg_pay_1=. if C_reason_irreg_pay==""

gen C_reason_irreg_pay_2=1 if C_reason_irreg_pay=="2"
replace C_reason_irreg_pay_2=0 if C_reason_irreg_pay!="2"
replace C_reason_irreg_pay_2=. if C_reason_irreg_pay==""

gen C_reason_irreg_pay_3=1 if C_reason_irreg_pay=="3" | C_reason_irreg_pay=="3 4"
replace C_reason_irreg_pay_3=0 if C_reason_irreg_pay!="3" & C_reason_irreg_pay!="3 4"
replace C_reason_irreg_pay_3=. if C_reason_irreg_pay==""

gen C_reason_irreg_pay_4=1 if C_reason_irreg_pay=="4" | C_reason_irreg_pay=="3 4"
replace C_reason_irreg_pay_4=0 if C_reason_irreg_pay!="4" & C_reason_irreg_pay!="3 4"
replace C_reason_irreg_pay_4=. if C_reason_irreg_pay==""

gen C_reason_irreg_pay_5=1 if C_reason_irreg_pay=="5" 
replace C_reason_irreg_pay_5=0 if C_reason_irreg_pay!="5"
replace C_reason_irreg_pay_5=. if C_reason_irreg_pay==""

gen C_reason_irreg_pay_6=1 if C_reason_irreg_pay=="6"
replace C_reason_irreg_pay_6=0 if C_reason_irreg_pay!="6"
replace C_reason_irreg_pay_6=. if C_reason_irreg_pay==""

/*
Classifying based on inputs from Enumerators on each village: 
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
gen C_salary_source_new=.
replace C_salary_source_new=1 if salary_source=="Panchyat ru account re jama hua" | ///
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
replace C_salary_source_new=2 if salary_source=="Gramasebaka ne unke account pe detehe." | ///
salary_source=="Gram sevak ne cp BDO request karke salary miltahe"

replace C_salary_source_new=999 if salary_source=="Don't know" 
replace C_salary_source_new=1 if C_salary_source_new==999 //these three respondents mentioned that they get paid by RWSS office or GRam Panchayat in "Salary_source" but don't know the details of how payment is collected and paid as asked in "salary_source" so recategorsing these responses to salary paid by "Panchayat/RWSS"

label var C_salary_source_new "Source of source"
label define C_salary_source_new 1 "Panchayat/RWSS" 2 "Paid by a proxy" 999 "Don't know"
label values C_salary_source_new C_salary_source_new

*** What else is done to clean the tank or treat the drinking water other than adding bleaching powder or cleaning the tank
gen C_other_treatment_method=.
replace C_other_treatment_method=1 if other_treatment_method=="GB bale ne device lagaya he" | other_treatment_method=="GB bale ake Lagayethe device or unke sath America wale be the Po ne bole."
label var C_other_treatment_method "Treatment methods beyond adding chlorine and cleaning tank"
label define C_other_treatment_method 1 "ILC device" 
label values C_other_treatment_method C_other_treatment_method 

*Categorising into no other cleaning done given PO mentioned cleaning the tank (adjusting after checking with enumertaor)
replace other_treatment=0 if other_treatment_method=="Siuli safa karuchanti(Kai saff karta ha)"


*** Suggestions for maintenance of the device (clubbing the responses from the maint_improvements and maint_notes variables)
gen C_maintenance_suggestions=""
replace C_maintenance_suggestions="1" if maint_notes=="Wal bhallv ka handle mil Jaye to achha hoga." 
replace C_maintenance_suggestions="1 4" if maint_improvements=="1.Ilc device ko boundary jesa kuch hota to thik hota 2. Jo device kholeko mujhe provide hota to thik hota"
replace C_maintenance_suggestions="2" if maint_notes=="Iron se banane se thik hota"
replace C_maintenance_suggestions="3" if maint_notes=="Uske upar kuch knowledge nehi he ilc device ke upar"
replace C_maintenance_suggestions="4" if maint_notes=="Usko gate ya boundary karde to accha hoga or safe rahega" | maint_improvements=="Village k kuch log device ko ched chod kar dete ha isilia  ILC device ko ekk boundary dia Jaya to achha ho ga" | maint_improvements=="Ilc device ko boundary karde ya iron se karde to thik hota"
replace C_maintenance_suggestions="5" if maint_improvements=="Amara payment badaila bhala heba"
replace C_maintenance_suggestions="6" if maint_improvements=="Device us time control karneko dete to thik hota"
replace C_maintenance_suggestions="7" if maint_improvements=="Adjust ke hisab se jana chahiye pani to thik hoga" | maint_improvements=="Continue chlorine agar jaega pineko to thik hoga"

* Create binary variables for responses 1 to 4
foreach issue of numlist 1/7 {
    gen C_maintenance_suggestions_`issue' = (strpos(C_maintenance_suggestions, "`issue'") > 0)
}

label var C_maintenance_suggestions "Suggestions for maintenance of the device"
label var C_maintenance_suggestions_1 "PO should be provided with wrench to operate the device"
label var C_maintenance_suggestions_2 "Material used for building the device should be metal/non-PVC"
label var C_maintenance_suggestions_3 "Require more knowledge about the device"
label var C_maintenance_suggestions_4 "Need a Boundary or Cage for the device"
label var C_maintenance_suggestions_5 "PO should be for operating the device"
label var C_maintenance_suggestions_6 "PO should've been allowed to control device initially"
label var C_maintenance_suggestions_7 "Dose showld be controlled and consistent"


//Translations for responses for text variables which mention the issues selected in other questions in detail 
*** Issues from HH: In detail
gen C_issues_detail_translation=""
replace C_issues_detail_translation="Odor related complaints if the dose is higher" if hh_issues_detail=="Pani chadila clorine dose adhika thibaru basna hauchi"
replace C_issues_detail_translation="Most people like the chlorinated water but some have odor related complaints" if hh_issues_detail=="Pehele se etna smell nehi hotatha abhi jyada smell hotahe jab se ilc device laga hua he bolke thoda log he boltehe or jyada log ko ye pani acha lagtahe"
replace C_issues_detail_translation="Supply related issues (not related to chlorination)" if hh_issues_detail=="Electric problem and boring me Pani Kam ho raha hai."  | hh_issues_detail=="Current nehi Hoge to wo boltehe or kuch nehi"
replace C_issues_detail_translation="Odor related complaints immediately after a refill" if hh_issues_detail=="Smell jyada horahe jab new tablet daltehe tabhi boltehe"
replace C_issues_detail_translation="Odor goes down if water is stored for longer" if hh_issues_detail=="Store karke rakhenge to smell nehi hotahe"
replace C_issues_detail_translation="Odor related complaints: Pakhala and drinikng water have a strong smell of chlorine" if hh_issues_detail=="Pani pine keliye or khana banane keliye smell hotahe usme jyada tar pakhal me smell atahe"
replace C_issues_detail_translation="Odor related complaints" if hh_issues_detail=="Smell jyada horahahe"

label var C_issues_detail_translation "Translation of HH Issues: In detail"

*** Response to HH complaints: In detail 
gen C_issues_response_translation=""
replace C_issues_response_translation="Suggested that storing water for sometime before use can help reduce odor" if hh_issues_response_detail=="Karana Sir mana  kahi thila j Pani ku rakhi ki use kale basna heba nahi boli ."
replace C_issues_response_translation="Supply related issues (not related to chlorination)" if hh_issues_response_detail=="Corrent problem ka bajaya se."
replace C_issues_response_translation="Counseled that the water is good for drinking" if hh_issues_response_detail=="Pinekeliye sahi rahegaa esiliye esa kiye"
replace C_issues_response_translation="Reported the complaints due to lot of complaints" if hh_issues_response_detail=="Lok ne jyada complaint kiye esiliye"
replace C_issues_response_translation="Adjusted the valves in response to complaints" if hh_issues_response_detail=="Lok ne jyada bolnese adjust kiya" | hh_issues_response_detail=="Jyada smell hotahe esiliye khud se adjust kiye" | hh_issues_response_detail=="Log bole ke jyada chlorine he esiliye thoda kam kiya"
replace C_issues_response_translation="Call GV when people complain" if hh_issues_response_detail=="Gaon ke log jabhi boltehe tabhi unko boltahe"

label var C_issues_response_translation "Translation of Response to HH Issues: In detail"


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
replace water_supply_reason="8" if water_supply_reason_oth=="Borewell ka Jo layer he wo kam he esiliye pani utha"

*replacing water_supply_reason__77 as 0 after categorizing the responses in other category
replace water_supply_reason__77=0 if water_supply_reason_oth=="Borewell ka Jo layer he wo kam he esiliye pani utha"


*** Frequency of cleaning the tank
*recategorising other category response to existing category
replace cleaning_tank_freq=2 if cleaning_tank_freq_oth=="Month me 2 bar" //twice a month
replace cleaning_tank_freq=0 if cleaning_tank_freq_oth=="Jab tank hua tha tabhi saf kiye the" //cleaned only when the tank was installed
replace cleaning_tank_freq=4 if cleaning_tank_freq_oth=="3 ya 4 month me ek bar" //every 3-4 months
replace cleaning_tank_freq=5 if cleaning_tank_freq_oth=="1 year me ekk bar saaf karta han" //once a year
replace cleaning_tank_freq=7 if cleaning_tank_freq_oth=="Ek sal me 3 bar horahahe or barish ke time pe hotahe" //thrice an year and more frequently during monsoon 


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
foreach var in hh_issues_type__77 hh_issues_type_1 hh_issues_type_2 ///
hh_issues_type_3 hh_issues_type_4 hh_issues_type_5 hh_issues_response_1 ///
hh_issues_response_2 hh_issues_response_3 hh_issues_response_4 hh_issues_response_5 ///
hh_issues_response_6 hh_issues_response_7 hh_issues_response_8 hh_issues_response__77 hh_issues_percent {
replace `var'=. if hh_issues_type_other=="Pani Kam hauthiba katha janai thile."
}

*replacing hh_issues_response as  "" after recategorizing the responses in other category
replace hh_issues_response="" if hh_issues_type_other=="Pani Kam hauthiba katha janai thile."

*** Redressal of complaints by the POs
*recategorising other category responses to existing responses
replace hh_issues_response_6=1 if hh_issues_response_oth=="Device ko adjust karnese samdhan hogeya" //adjusted the device

*replacing hh_issues_response__77 as 0 after recategorizing the responses in other category
replace hh_issues_response__77=0 if hh_issues_response_oth=="Store karke pani pine se etna smell nehi hoga esa he bole" //already selected "tried to convince/explian the villagers"
replace hh_issues_response__77=0 if hh_issues_response_oth=="Device ko adjust karnese samdhan hogeya" //adjusted the device


*** Frequency of adding bleaching powder to the tank
* recategorising into existing catgeories
//Option 2: Few times a month
replace bleaching_powder_freq=2 if bleaching_powder_freq_oth=="One month me 4 time daltehe"
//Option 7: No fixed schedule
replace bleaching_powder_freq=7 if bleaching_powder_freq_oth=="Jab tanki saf hotahe tabhi" //cleaned whenever tank is cleaned 

* Creating new answer category for those who don/t clean it 
replace bleaching_powder_freq=8 if bleaching_powder_freq_oth=="Eba device lagiba tharu bleaching paka jau nahi agaru 3 thara masa ku paka jau thila." | bleaching_powder_freq_oth=="Jab se chlorine device laga hua he tab se nehi Dala hua he"

*** Way of appointing the next PO
replace next_po_appointment=6 if next_po_appoint_oth=="Gaon me meeting me decide hotahe kon rahega"
label drop next_po_appointment
label var next_po_appointment "How will the next Po be appointed"
label define next_po_appointment 1 "Appointed by the Gram Panchayat after elections" 2 "Appointed by RWSS after election" 3 "Appointed on a fixed schedule" 4 "Appointed indefinitely or no fixed schedule" 5 "When volunteers change" 6 "Appointed by villagers in village meeting" 999 "Don't know" -77 "Other"
label values next_po_appointment next_po_appointment

*** Appointment as PO
replace appointment_po_person=1 if appointment_po_person_oth=="Po me Jo president hote he usne bolke rakhe hue he" //In this village the Po was appointed based on suggestion of President of informal PO union of three other villges 

*** Support during installation of ILC device
* Generating a new category 
gen ilc_install_support_8=.
replace ilc_install_support_8=0 if ilc_install_support!=""
replace ilc_install_support_8=1 if ilc_install_support=="2 -77"

replace ilc_install_support="2 8" if ilc_install_support=="2 -77"

* Replacing othe rcategory response iwth missing after recategorising 
replace ilc_install_support__77=0 if ilc_install_support=="2 8" 

* Labelling the variables 
label var ilc_install_support "Support given during device installation"
label var ilc_install_support_1 "Observed the installation but did not take part in helping"
label var ilc_install_support_2 "Assisted the installation team by cleaning/digging the area for the installation"
label var ilc_install_support_3 "Assisted the installation team in sourcing material for the installation"
label var ilc_install_support_4 "Assisted the installation team in installing parts of the device to the tank/inlet"
label var ilc_install_support_5 "Assisted installation team in explaining the storage reservoir and distribution system"
label var ilc_install_support_6 "Assisted installation team in getting necessary village level approvals"
label var ilc_install_support_7 "Tuned the valves on/off during installation"
label var ilc_install_support_8 "Assisted in identifying place for installation"
label var ilc_install_support__77 "Other"

*** Reasons for villagers not being satisfied with ILC 
* Generating a new category for those who said there's sedimentation in water 
gen ilc_unsatisfied_village_7=.
replace ilc_unsatisfied_village_7=0 if ilc_unsatisfied_village!=""
replace ilc_unsatisfied_village_7=1 if ilc_unsatisfied_village_oth=="Pani jab store hotahe tab pani ke niche kuch vapor jesa Beth jatahe"

replace ilc_unsatisfied_village = "1 7" if ilc_unsatisfied_village_oth=="Pani jab store hotahe tab pani ke niche kuch vapor jesa Beth jatahe"

* Replacing othe rcategory response iwth missing after recategorising 
replace ilc_unsatisfied_village__77= 0 if ilc_unsatisfied_village_oth=="Pani jab store hotahe tab pani ke niche kuch vapor jesa Beth jatahe"

* Labelling the variables 
label var ilc_unsatisfied_village "Reason for dissatisfaction of villagers  with ILC"
label var ilc_unsatisfied_village_1 "They don't like the taste and smell of the water"
label var ilc_unsatisfied_village_2 "They don't like using the chlorinated water for cooking"
label var ilc_unsatisfied_village_3 "They believe it makes water look dirtier"
label var ilc_unsatisfied_village_4 "They don't trust the chemical being added to the water"
label var ilc_unsatisfied_village_5 "They liked the way their water was before and are averse to change"
label var ilc_unsatisfied_village_6 "Health related issues"
label var ilc_unsatisfied_village_7 "Sedimentation related issues"
label var ilc_unsatisfied_village__77 "Other"


*** Who did you report to about device being turned off
* Recategorising into existing categories
replace turnoff_report_3=1 if turnoff_report_oth=="Mohan Kadraka Jo he unko be bolethe wo gaon me pehele pani chodtethe" //Reprot to president of informal PO union of three villages who holds significant power in teh village --> considering him as a village leader given his sway over people
replace turnoff_report= "3" if turnoff_report_oth=="Mohan Kadraka Jo he unko be bolethe wo gaon me pehele pani chodtethe"

* Replacing othe rcategory response iwth missing after recategorising 
replace turnoff_report__77=0 if turnoff_report_oth=="Mohan Kadraka Jo he unko be bolethe wo gaon me pehele pani chodtethe"


*** Variables not categorised
//The following variables are not categorised as these are more of comments of the POs 
// ilc_satisfied_po_oth == "Jo bhi log nehi pitethe abhi abhi pitehe" //people who didn't use jjm water previously are now drinking it 
// ilc_satisfied_village_oth == "Jab se ilc laga hua he ye pani he pitehe" | ilc_satisfied_village_oth == "Filter pani se ye pani se santisti he log"


********************************************************************************
*** Generating new variables
********************************************************************************
 
*** Job duration
gen C_duration_job_new=.
replace C_duration_job_new=2 if job_duration>=1 & job_duration<=4
replace C_duration_job_new=3 if job_duration>=5 & job_duration<=8
replace C_duration_job_new=4 if job_duration>=7 & job_duration<=12
replace C_duration_job_new=5 if job_duration>12
replace C_duration_job_new=1 if job_duration==7 & job_duration_units==3

label var C_duration_job_new "Job duration"
label define C_duration_job_new 1 "Less than 1 year" 2 "1-4 years" 3 "5-8 years" 4 "9-12 years" 5 "More than 12 years"
label values C_duration_job_new C_duration_job_new 

*** Additional duties
gen C_addtl_duties_yn=.
replace C_addtl_duties_yn=1 if addtl_duties=="1 2 3 4"

label var C_addtl_duties_yn "Willing to take up additional duties"
label define C_addtl_duties_yn 1 "Yes" 0 "No"
label values C_addtl_duties_yn C_addtl_duties_yn

*** Appointment 
gen C_appointment_new=appointment_po_person
replace C_appointment_new=1 if appointment_po_person_oth=="Po me Jo president hote he usne bolke rakhe hue he" //the president of informal po union recommended her name to GP

label var C_appointment_new "Appointment"
label define C_appointment_new 1 "Appointed by Gram Panchayat" 3 "Appointed by Village Leadership" 2 "Appointed by RWSS" 
label values C_appointment_new C_appointment_new

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
gen C_ilc_daily_task=""
replace C_ilc_daily_task="2" if ilc_monitor_type=="2 6 7" & unique_id=="30301101001"
replace C_ilc_daily_task="1 3" if ilc_monitor_type=="1 3 6" & unique_id=="30701101001"
replace C_ilc_daily_task="1" if ilc_monitor_type=="1 2 3 7" & unique_id=="50401101001"
replace C_ilc_daily_task="3" if ilc_monitor_type=="2 3 6" & unique_id=="10101103001"
replace C_ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="30602103002"
replace C_ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="30602103001"
replace C_ilc_daily_task="1 2 3 4" if ilc_monitor_type=="1 2 3 4 6" & unique_id=="50501103001"
replace C_ilc_daily_task="1" if ilc_monitor_type=="2 6" & unique_id=="20101103001"
replace C_ilc_daily_task="0" if ilc_monitor_type=="2 6" & unique_id=="40201103001" //respondent does not perform any task daily and selected an empty response in ilc_monitor_freq_daily
replace C_ilc_daily_task="1 3 6" if ilc_monitor_type=="1 2 3 6" & unique_id=="40401103001"

*** Creating binary variables to store the responses of ilc_daily_task
* List of values for which binary variables are required
local values "1 2 3 4 5 6 7 8"

* Create new binary variables
foreach value of local values {
    gen C_ilc_daily_task_`value' = 0
}

* Populate the binary variables based on ilc_daily_task
foreach value of local values {
    * Check if the value is present in ilc_daily_task
    replace C_ilc_daily_task_`value' = 1 if strpos(C_ilc_daily_task, "`value'") > 0
}

* Labelling the binary variables
label var C_ilc_daily_task "Tasks performed daily"
label var C_ilc_daily_task_1 "Opening/closing valves of device during the time of filling the tank"
label var C_ilc_daily_task_2 "Adjusting the valves on the device to control the chlorine dose"
label var C_ilc_daily_task_3 "Draining the valves of the device"
label var C_ilc_daily_task_4 "Cleaning the device regularly"
label var C_ilc_daily_task_5 "Checking the device for leaks"
label var C_ilc_daily_task_6 "Checking the device for chlorine refills"
label var C_ilc_daily_task_7 "Informing the installation team of any issues"
label var C_ilc_daily_task_7 "Repairing the device as needed"


*** Generating variable for the duties that are not performed daily:
* Creating binary variables for tasks that are not performed daily
forvalues i = 1/8 {
    gen C_ilc_notdaily_task_`i' = ilc_monitor_type_`i' & !C_ilc_daily_task_`i'
	replace C_ilc_notdaily_task_`i'=. if ilc_monitor_type_`i'==.
	
}

* Create a space-separated string for ilc_notdaily_task: tasks not done daily
gen C_ilc_notdaily_task = ""
forvalues i = 1/8 {
    * Append task index to task3 if the task3_`i' variable is 1
    replace C_ilc_notdaily_task = C_ilc_notdaily_task + cond(C_ilc_notdaily_task_`i' == 1, "`i' ", "") if C_ilc_notdaily_task_`i' == 1
}

* Labelling the binary variables
label var C_ilc_notdaily_task "Tasks not performed daily"
label var C_ilc_notdaily_task_1 "Opening/closing valves of device during the time of filling the tank"
label var C_ilc_notdaily_task_2 "Adjusting the valves on the device to control the chlorine dose"
label var C_ilc_notdaily_task_3 "Draining the valves of the device"
label var C_ilc_notdaily_task_4 "Cleaning the device regularly"
label var C_ilc_notdaily_task_5 "Checking the device for leaks"
label var C_ilc_notdaily_task_6 "Checking the device for chlorine refills"
label var C_ilc_notdaily_task_7 "Informing the installation team of any issues"
label var C_ilc_notdaily_task_8 "Repairing the device as needed"

*** Time taken to carry out dailiy tasks
gen C_time_taken=ilc_monitor_duration //missing values pertain to control group and those who don't know how much time it. takes
replace C_time_taken=0 if ilc_monitor_duration==0 | ilc_monitor==0 //no time taken: either does not perform any tasks daily or does not perform any tasks at all
replace C_time_taken=. if C_time_taken==999

label var C_time_taken "Time taken to carry out daily tasks related to ILC"



********************************************************************************
*** Renaming variables 
********************************************************************************



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
label var C_reason_irreg_pay_1 "Document issuance delay"
label var C_reason_irreg_pay_2 "Processing delay from CP to PO"
label var C_reason_irreg_pay_3 "Document signing delay"
label var C_reason_irreg_pay_4 "Processing delay from BDO to panchayat"
label var C_reason_irreg_pay_5 "Processing delay from Panchayat to PO"
label var C_reason_irreg_pay_6 "Lack of accountabilty"
label var ilc_refill "Provides refill to the ILC device"
label var reason_chlorination_1 "To make the water safer to drink"
label var reason_chlorination_2 "The water will make people healthier"
label var reason_chlorination_3 "The water will taste and smell better"
label var reason_chlorination_4 "The water will become clearer or less muddy"
label var reason_chlorination_5 "The chlorine will kill microbes (bacteria or viruses) in the water "
label var reason_chlorination__77 "Other"
label var reason_chlorination_999 "Don't know"
label var hh_issues_response_1 "Tried to explain the villagers about the benefits of chlorination"
label var hh_issues_response_2 "Reported the complaints to Gram Vikas"
label var hh_issues_response_3 "Reported the complaints to JPAL"
label var hh_issues_response_4 "Reported the complaints to a village leader (sarpanch, elder, ASHA, etc)"
label var hh_issues_response_5 "Reported the complaints to RWSS or other government office"
label var hh_issues_response_6 "Tried adjusting the chlorine dose"
label var hh_issues_response_7 "Turned the device off"
label var hh_issues_response_8 "Removed chlorine tablets from the device"
label var hh_issues_response__77 "Other"
label var ilc_unsatisfied_po "Reason for dissatisfaction of PO with ILC"
label var ilc_unsatisfied_po_1 "Doesn't like the taste and smell of the water"
label var ilc_unsatisfied_po_2 "Doesn't like using the chlorinated water for cooking"
label var ilc_unsatisfied_po_3 "Believes it makes water look dirtier"
label var ilc_unsatisfied_po_4 "Doesn't trust the chemical being added to the water"
label var ilc_unsatisfied_po_5 "Liked the way their water was before and are averse to change"
label var ilc_unsatisfied_po_6 "Health related issues"
label var ilc_unsatisfied_po__77 "Other"
label var ilc_satisfied_village "Reason for Satisfaction of villagers with ILC"
label var ilc_satisfied_village_1 "They believe that the water tastes and smells better now"
label var ilc_satisfied_village_2 "They like using the chlorinated water for cooking"
label var ilc_satisfied_village_3 "They believe it makes the water look clearer"
label var ilc_satisfied_village_4 "They believe the device makes their water safer to drink"
label var ilc_satisfied_village_5 "They believe the water will make them healthier"
label var ilc_satisfied_village__77 "Other"
label var ilc_satisfied_po "Reason for Satisfaction of PO with ILC"
label var ilc_satisfied_po_1 "Believes that the water tastes and smells better now"
label var ilc_satisfied_po_2 "Likes using the chlorinated water for cooking"
label var ilc_satisfied_po_3 "Believes it makes the water look clearer"
label var ilc_satisfied_po_4 "Believes the device makes water safe to drink"
label var ilc_satisfied_po_5 "Believes the water will make me and everyone healthier"
label var ilc_satisfied_village__77 "Other"


********************************************************************************
*** Dropping variables 
********************************************************************************

//Dropping variables not erequired for analyiss or capturing duration of each section 
drop caseid deviceid subscriberid simid devicephonenum username intronote no_caseid note_conf info_update enum_name_label unique_id_label unique_id_note revisit_note noconsent_reason noconsent_reason_oth job_duration_units_label audio_audit_note_start tenure_duration_unit_label tenure_dur_note note_audio_recording_2 turnoff_duration_unit_label note_pop_work instancename review_quality review_comments review_corrections consent_duration background_duration water_infra_duration ilc_install_maintain_duration ilc_perceptions_duration job_duration_units_label job_dur_note intronote review_consent_note job_dur_note school_anganwadis_note school_anganwadis_tap_note cleaning_tank_note operation_valves_who_label


********************************************************************************
*** Saving the cleaned dataset 
********************************************************************************

save "${DataFinal}1_14_PO_Survey_final.dta", replace






