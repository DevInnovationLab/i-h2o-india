* import_india_ilc_pilot_backcheck_Master.do
*
* 	Imports and aggregates "Baseline Backcheck" (ID: india_ilc_pilot_backcheck_Master) data.
*
*	Inputs:  "Baseline Backcheck_WIDE.csv"
*	Outputs: "Baseline Backcheck.dta"
*
*	Output by SurveyCTO October 31, 2023 7:33 AM.

* initialize Stata
cd "C:\Users\Archi Gupta\Box\Data\1_raw"
do "C:\Users\Archi Gupta\Documents\GitHub\i-h2o-india\Code\1_profile_ILC\Label\import_india_ilc_pilot_backcheck_Master.do"



* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  Baseline Backcheck_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes




destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id

gen BC_surveydate = dofc(submissiondate)
format BC_surveydate %td

drop  if unique_id == 10101110016 & enum_name == 107 & r_cen_a1_resp_name == "Padma Garadia" & a7_resp_name == "999"


br unique_id
duplicates drop
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID



list dup unique_id if dup_HHID > 0

keep unique_id

save "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_plan matching.dta",replace

clear

import excel "C:\Users\Archi Gupta\Box\Data\99_Preload\Backcheck_preload_8Nov23.xlsx", sheet("Sheet1") firstrow
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"
duplicates drop
bysort unique_id : gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID

destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id



merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\BC_plan matching.dta", generate(_mergewithBCsubmitted)
merge 1:1 unique_id using "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress\Data_Quality_Checks_Only_UQs.dta", generate(_mergewithDQ)
cd "C:\Users\Archi Gupta\Box\Data\99_Archi_things in progress"

export excel using "BC field plan new IDs 6th nov" if _mergewithBCsubmitted==1 & _mergewithDQ == 1, sheetmodify firstrow(variables)
