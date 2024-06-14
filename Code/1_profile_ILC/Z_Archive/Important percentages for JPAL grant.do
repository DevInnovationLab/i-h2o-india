
**********Census data

use "${DataPre}1_1_Census_cleaned.dta", clear
tab R_Cen_a13_water_source_sec_1 if R_Cen_a12_water_source_prim==1

//cleaning the data for 12 obs which are both JJM secondary AND JJM primary 
keep if R_Cen_consent==1 //keeoing only consented obs

replace R_Cen_a13_water_sec_yn=0 if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_2 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_3 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_4 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_5 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_6 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_7 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_8 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec__77 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 
replace R_Cen_a13_water_source_sec_1 =. if R_Cen_a13_water_source_sec_1==1 & R_Cen_a12_water_source_prim==1 


gen only_JJM_prim=0
replace only_JJM_prim= 1 if R_Cen_a12_water_source_prim==1 


gen other_than_JJM_sec=0
replace other_than_JJM_sec=1 if (R_Cen_a13_water_source_sec_2==1 | R_Cen_a13_water_source_sec_3==1 | R_Cen_a13_water_source_sec_4==1 | R_Cen_a13_water_source_sec_5==1 | R_Cen_a13_water_source_sec_6==1 | R_Cen_a13_water_source_sec_7==1 | R_Cen_a13_water_source_sec_8==1 | R_Cen_a13_water_source_sec__77==1 | R_Cen_a13_water_sec_yn== -99) & R_Cen_a12_water_source_prim==1


//generating new var for (1) Only JJM + no sec source (2) JJM prim + oth sec source (0) all other cases
gen new= 0
replace new= 1 if R_Cen_a12_water_source_prim==1 & R_Cen_a13_water_sec_yn==0
replace new= 2 if other_than_JJM_sec==1 

gen jjm_no_secondary=0
replace jjm_no_secondary=1 if R_Cen_a12_water_source_prim==1 & R_Cen_a13_water_sec_yn==0
tab jjm_no_secondary

gen jjm_oth_secondary=0
replace jjm_oth_secondary=1 if other_than_JJM_sec==1 
tab jjm_oth_secondary

gen oth_cases=0
replace oth_cases=1 if new==0
tab oth_cases


//other tabulations
tab only_JJM_prim //only JJM primary
tab other_than_JJM_sec //JJM primary + other secondary sources
tab R_Cen_a13_water_source_sec_1 if not_jjm_prim==1 //JJM secondary + other primary sources
tab JJM_drink //using JJM for drinking

//ICC
gen q1_tap_primary	=(R_Cen_a12_water_source_prim == 1)
gen q2_tap_secondary = (R_Cen_a13_water_source_sec_1 == 1)
gen q3_tap_drinking	= (R_Cen_a18_jjm_drinking == 1) 

gen village=R_Cen_village_str
 
loneway q1_tap_primary village
loneway q2_tap_secondary village
loneway q3_tap_drinking village
loneway jjm_no_secondary village
loneway jjm_oth_secondary village
loneway oth_cases village

tab q1_tap_primary
tab q2_tap_secondary
tab q3_tap_drinking



**********Baseline HH survey
use "${DataPre}Baseline HH survey_cleaned.dta", clear
tab R_Cen_a13_water_source_sec_1 if R_FU_water_source_prim==1 

//cleaning the data for 4 obs which are both JJM secondary AND JJM primary 
replace R_Cen_a13_water_sec_yn=0 if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_2 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_3 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_4 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_5 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_6 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_7 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_8 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec__77 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 
replace R_Cen_a13_water_source_sec_1 =. if R_Cen_a13_water_source_sec_1==1 & R_FU_water_source_prim==1 


gen only_JJM_prim=0
replace only_JJM_prim= 1 if R_FU_water_source_prim==1 


gen other_than_JJM_sec=0
replace other_than_JJM_sec=1 if (R_Cen_a13_water_source_sec_2==1 | R_Cen_a13_water_source_sec_3==1 | R_Cen_a13_water_source_sec_4==1 | R_Cen_a13_water_source_sec_5==1 | R_Cen_a13_water_source_sec_6==1 | R_Cen_a13_water_source_sec_7==1 | R_Cen_a13_water_source_sec_8==1 | R_Cen_a13_water_source_sec__77==1| R_Cen_a13_water_sec_yn== -99) & R_FU_water_source_prim==1


//generating new var for (1) Only JJM + no sec source (2) JJM prim + oth sec source (0) all other cases
gen new= 0
replace new= 1 if R_FU_water_source_prim==1 & R_Cen_a13_water_sec_yn==0
replace new= 2 if other_than_JJM_sec==1 


gen jjm_no_secondary=0
replace jjm_no_secondary=1 if R_FU_water_source_prim==1 & R_Cen_a13_water_sec_yn==0
tab jjm_no_secondary


gen jjm_oth_secondary=0
replace jjm_oth_secondary=1 if other_than_JJM_sec==1 
tab jjm_oth_secondary

gen oth_cases=0
replace oth_cases=1 if new==0
tab oth_cases



//tabulations
tab only_JJM_prim //only JJM primary
tab other_than_JJM_sec //JJM primary + other secondary sources
tab R_Cen_a13_water_source_sec_1 if not_jjm_prim==1 //JJM secondary + other primary sources


//ICC
gen q1_tap_primary	=(R_FU_water_source_prim == 1)
gen q2_tap_secondary = (R_Cen_a13_water_source_sec_1 == 1)
gen q3_tap_drinking	= (R_FU_tap_use_1 == 1) 

gen village=R_FU_r_cen_village_name_str
 
loneway q1_tap_primary village
loneway q2_tap_secondary village
loneway q3_tap_drinking village
loneway jjm_no_secondary village
loneway jjm_oth_secondary village
loneway oth_cases village


tab q1_tap_primary
tab q2_tap_secondary
tab q3_tap_drinking


