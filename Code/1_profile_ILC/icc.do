
clear
set more off
cap log close

global working "/Users/vp/Downloads/icc estimates"
log using "$working/jpal_icc", text replace

/*
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// ISSUES
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
(1) Duplicates
BL 50501115027 Tap water has a dup
FU1 has several dupes

(2) Extra villages
Haathikamaba is there but not bada alubadi
*/

*************************************************************
// DIRECTORIES
*************************************************************

global data_deid "/Users/vp/Downloads/icc estimates"
global data_idexx "/Users/vp/Downloads/icc estimates"

clear 
tempfile temp1
save `temp1', emptyok replace

*************************************************************
// IDEXX DATA
*************************************************************

#delimit ;
local idexx_keepvars
round
village
assignment
sample_type
unique_id

cf_mpn 
ec_mpn 
cf_pa_binary 
ec_pa_binary

/*
fc_stored_avg 
fc_tap_avg 
tc_stored_avg 
tc_tap_avg
*/ 
;
#delimit cr;

***
// IDEXX HH BASELINE
***

import delimited using "$data_idexx/BL_idexx_master_cleaned.csv", clear

format unique_id %20.0g
duplicates list unique_id sample_type
 
gen round=0
keep `idexx_keepvars'

tempfile idexx_bl
save `idexx_bl', replace

***
// IDEXX FU1
***

import delimited using "$data_idexx/R1_idexx_master_cleaned.csv", clear

format unique_id %20.0g
duplicates list unique_id sample_type
 
gen round=1 
keep `idexx_keepvars'
 
tempfile idexx_fu1
save `idexx_fu1', replace

***
// APPEND ALL IDEXX, CLEAN
***

use `idexx_bl', clear
append using `idexx_fu1'

replace assignment="Treatment" if assignment=="T"
replace assignment="Control" if assignment=="C"
replace assignment="" if assignment=="NA"
tab assignment, miss

// duplicates drop and ask Jeremy to check
duplicates list round unique_id sample_type
duplicates drop round unique_id sample_type, force

// reshape

replace sample_type="_tap" if sample_type=="Tap"
replace sample_type="_stored" if sample_type=="Stored"

rename cf_pa_binary cf_pa
rename ec_pa_binary ec_pa
reshape wide cf_mpn ec_mpn cf_pa ec_pa, i(unique_id round) j(sample_type) string

rename unique_id unique_id_num

tempfile idexx
save `idexx', replace


*************************************************************
// HH SURVEY DATA
*************************************************************

#delimit ;
local hh_keepvars
unique_id_num
round
village

fc_tap
fc_stored
fc_tap_02	
fc_stored_02

tap_drinking 
tap_primary 
;
#delimit cr;

***
// HH SURVEY BASELINE
***

use "$data_deid/1_2_Followup_cleaned.dta", clear
keep if R_FU_consent ==1

gen round=0
gen village=R_FU_r_cen_village_name_str

gen fc_tap_02 = (R_FU_fc_tap>0.2 & !missing(R_FU_fc_tap))
gen fc_stored_02 = (R_FU_fc_stored>0.2 & !missing(R_FU_fc_stored))

clonevar fc_tap = R_FU_fc_tap 
clonevar fc_stored = R_FU_fc_stored 

merge 1:1 unique_id_num using "$data_deid/1_1_Census_cleaned_noid.dta", keep(master match) ///
keepusing(unique_id_num R_Cen_a18_jjm_drinking R_Cen_a12_water_source_prim) nogen

gen tap_drinking	=(R_Cen_a18_jjm_drinking == 1) 
gen tap_primary		=(R_Cen_a12_water_source_prim == 1)

keep `hh_keepvars'

tempfile bl_hh
save `bl_hh', replace

***
// HH SURVEY FU1
***

use "$data_deid/1_5_Followup_R1_cleaned.dta", clear
keep if R_FU1_consent ==1

gen round=1
gen village= R_FU1_r_cen_village_name_str

gen fc_tap_02 = (R_FU1_fc_tap>0.2 & !missing(R_FU1_fc_tap))
gen fc_stored_02 = (R_FU1_fc_stored>0.2 & !missing(R_FU1_fc_stored))

clonevar fc_tap = R_FU1_fc_tap 
clonevar fc_stored = R_FU1_fc_stored 

gen tap_drinking	=(R_FU1_tap_use_drinking_yesno == 1) 
gen tap_primary		=(R_FU1_water_source_prim == 1)

keep `hh_keepvars'

tempfile fu1_hh
save `fu1_hh', replace

***
// HH SURVEY FU2
***
use "$data_deid/1_6_Followup_R2_cleaned.dta", clear
keep if R_FU2_consent ==1

gen round=2
gen village= R_FU2_r_cen_village_name_str

gen fc_tap_02 = (R_FU2_fc_tap>0.2 & !missing(R_FU2_fc_tap))
gen fc_stored_02 = (R_FU2_fc_stored>0.2 & !missing(R_FU2_fc_stored))

clonevar fc_tap = R_FU2_fc_tap 
clonevar fc_stored = R_FU2_fc_stored 

gen tap_drinking	=(R_FU2_tap_use_drinking_yesno == 1) 
gen tap_primary		=(R_FU2_water_source_prim == 1)

keep `hh_keepvars'

tempfile fu2_hh
save `fu2_hh', replace

***
// APPEND ALL HH SURVEYS, CLEAN
***

use `bl_hh', clear
append using `fu1_hh'
append using `fu2_hh'

replace fc_tap=. if inlist(fc_tap, 999)
replace fc_stored=. if inlist(fc_stored, 999)

// Assign Treatment

gen treatment = "Control"

replace treatment= "Treatment" if inlist(village, "Birnarayanpur", "Nathma", "Badabangi", "Naira", "Bichikote")
replace treatment="Treatment" if inlist(village, "Karnapadu", "Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada")

replace treatment= "" if inlist(village, "Badaalubadi", "Haathikambha")

*************************************************************
// MERGE HH SURVEY DATA AND IDEXX
*************************************************************
merge 1:1 round unique_id using `idexx', keep(master match)


// LONEWAY FOR BASELINE HH & FOLLOW UP SURVEY DATA 
keep if !missing(treatment) // drop Haathikamba

tempfile temp2
save `temp2', replace

#delimit ;
local icc_vars 
cf_pa_tap
cf_pa_stored

ec_pa_tap
ec_pa_stored

tap_drinking 
tap_primary

fc_tap_02

;
#delimit cr;


forvalues r=0/1 {
	foreach v in `icc_vars' {
		
		use `temp2', clear
		loneway `v' village if inrange(round, 0, `r')
		
		clear
		set obs 1
		
		gen variable = "`v'"
		gen round=`r'
		gen obs=`r(N)'
		gen icc=`r(rho)'
		gen icc_95cil=`r(lb)'
		gen icc_95ciu=`r(ub)'
		
		append using `temp1'
		save `temp1', replace

	}
}



*************************************************************
// BASELINE CENSUS DATA
*************************************************************

use "$data_deid/1_1_Census_cleaned_noid.dta", clear
keep if R_Cen_consent ==1



decode R_Cen_village_name, gen(village)
gen treatment = "Control"

replace treatment= "Treatment" if inlist(village, "Birnarayanpur", "Nathma", "Badabangi", "Naira", "Bichikote")
replace treatment="Treatment" if inlist(village, "Karnapadu", "Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada")

replace treatment= "" if inlist(village, "Badaalubadi", "Haathikambha", "Hatikhamba")
keep if !missing(treatment)

gen tap_drinking	=(R_Cen_a18_jjm_drinking == 1) 
gen tap_primary		=(R_Cen_a12_water_source_prim == 1)

// LONEWAY FOR CENSUS DATA 
loneway tap_drinking village
loneway tap_primary village

log close
