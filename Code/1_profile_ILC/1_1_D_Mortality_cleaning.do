*=========================================================================* 
* Project information at:https://github.com/DevInnovationLab/i-h2o-india/
****** Country: India (Odisha)
****** Purpose: 
****** Created by: DIL
****** Used by:  DIL
****** Input data : 
****** Output data : 
****** Language: English
*=========================================================================*
** In this do file: 
	* This do file exports.....

*=========================== PROGRAM ==============================================*
putpdf begin
putpdf paragraph, font("Courier",20) halign(center)
putpdf text  ("Descriptive statistics for ILC Pilot") 
putpdf paragraph, font("Courier")
*=========================== PROGRAM END ==============================================*

clear all               
set seed 758235657 // Just in case


use "${DataRaw}Mortality Survey.dta", clear
 
*AG: Variabls which are not labeled correctly- R_mor_child_living_oth_2 R_mor_child_living_1_f R_mor_child_living_2_f R_mor_child_living_3_f R_mor_child_living_4_f R_mor_child_living_5_f R_mor_child_living_6_f
//They are labeled 1 or 0 and not as Yes or NO
*AG: These variables should be labeled as "Yes" or "No" but are labeled as 1 or 0 -R_mor_last_5_years_pregnant_1_f R_mor_last_5_years_pregnant_2_f R_mor_last_5_years_pregnant_3_f R_mor_last_5_years_pregnant_4_f R_mor_last_5_years_pregnant_5_f R_mor_last_5_years_pregnant_6_f R_mor_last_5_years_preg_oth_* 

 * Drop label that are getting auto generated for numeric variables
     capture { 
	  foreach rgvar of varlist child_living_num_* {
		    label drop `rgvar'
		}
	 }
	 capture {
       foreach rgvar of varlist child_notliving_num_* {
		    label drop `rgvar'
			
		}
	 }



* Create a single variable for all the variables that were separated by scenario of screened in (_sc)  and updated (_)

local not_screened women_child_bearing_sc_count child_bearing_index_1 -   translator_4

*rename some of the variables to make them consistent for applying loop
rename unique_id_sc1 unique_id_sc

drop child_died_u5_count_sc_1 child_died_u5_count_sc_2 child_died_u5_count_sc_3 child_died_u5_count_sc_4 child_died_u5_count_sc_5 child_died_u5_count_sc_6 child_died_u5_count_1 child_died_u5_count_2 child_died_u5_count_3 child_died_u5_count_4  

rename (child_died_u5_count_sc_null_1 child_died_u5_count_sc_null_2 child_died_u5_count_sc_null_3 child_died_u5_count_sc_null_4 child_died_u5_count_sc_null_5 child_died_u5_count_sc_null_6 child_died_u5_count_null_1 child_died_u5_count_null_2 child_died_u5_count_null_3 child_died_u5_count_null_4 ) (child_died_u5_count_sc_1 child_died_u5_count_sc_2 child_died_u5_count_sc_3 child_died_u5_count_sc_4 child_died_u5_count_sc_5 child_died_u5_count_sc_6 child_died_u5_count_1 child_died_u5_count_2 child_died_u5_count_3 child_died_u5_count_4 )

rename no_consent_pc_comment_oth_2 no_cons_pc_comm_oth_2
  
* Create a local of  screened scenarios, where questions are asked based on scenario == 4 
//scenario 4 are those cases where household was screened in the baseline and we have roster data for them so we only collected mortality module information for such cases. Except this scenario, all other scenarios were asked questions from the begiining like roster etc  
 local screened  women_child_bearing_sc_count enum_name_sc enum_name_label_sc enum_code_sc  child_bearing_index_sc_1 name_pc_sc_1 name_pc_earlier_sc_1 resp_avail_pc_sc_1 consent_pc_sc_1 no_consent_reason_pc_sc_1 no_consent_reason_pc_sc_1_1 no_consent_reason_pc_sc_2_1 no_consent_reason_pc_sc__77_1 no_consent_pc_oth_sc_1 no_consent_pc_comment_sc_1 residence_yesno_pc_sc_1 vill_pc_sc_1 vill_pc_oth_sc_1 a7_pregnant_leave_sc_1 a7_pregnant_leave_days_sc_1 a7_pregnant_leave_months_sc_1 village_name_res_sc_1 vill_residence_sc_1 last_5_years_pregnant_sc_1 child_living_sc_1 child_living_num_sc_1 child_notliving_sc_1 child_notliving_num_sc_1 child_stillborn_sc_1 child_stillborn_num_sc_1 child_alive_died_24_sc_1 child_died_num_sc_1 child_alive_died_sc_1 child_died_num_more24_sc_1  child_died_u5_count_sc_1 child_died_repeat_sc_count_1 confirm_sc_1 correct_sc_1 translator_sc_1  child_bearing_index_sc_2 name_pc_sc_2 name_pc_earlier_sc_2 resp_avail_pc_sc_2 consent_pc_sc_2 no_consent_reason_pc_sc_2 no_consent_reason_pc_sc_1_2 no_consent_reason_pc_sc_2_2 no_consent_reason_pc_sc__77_2 no_consent_pc_oth_sc_2 no_consent_pc_comment_sc_2 residence_yesno_pc_sc_2 vill_pc_sc_2 vill_pc_oth_sc_2 a7_pregnant_leave_sc_2 a7_pregnant_leave_days_sc_2 a7_pregnant_leave_months_sc_2 village_name_res_sc_2 vill_residence_sc_2 last_5_years_pregnant_sc_2 child_living_sc_2 child_living_num_sc_2 child_notliving_sc_2 child_notliving_num_sc_2 child_stillborn_sc_2 child_stillborn_num_sc_2 child_alive_died_24_sc_2 child_died_num_sc_2 child_alive_died_sc_2 child_died_num_more24_sc_2  child_died_u5_count_sc_2 child_died_repeat_sc_count_2 confirm_sc_2 correct_sc_2 translator_sc_2 child_bearing_index_sc_3 name_pc_sc_3 name_pc_earlier_sc_3 resp_avail_pc_sc_3 consent_pc_sc_3 no_consent_reason_pc_sc_3 no_consent_reason_pc_sc_1_3 no_consent_reason_pc_sc_2_3 no_consent_reason_pc_sc__77_3 no_consent_pc_oth_sc_3 no_consent_pc_comment_sc_3 residence_yesno_pc_sc_3 vill_pc_sc_3 vill_pc_oth_sc_3 a7_pregnant_leave_sc_3 a7_pregnant_leave_days_sc_3 a7_pregnant_leave_months_sc_3 village_name_res_sc_3 vill_residence_sc_3 last_5_years_pregnant_sc_3 child_living_sc_3 child_living_num_sc_3 child_notliving_sc_3 child_notliving_num_sc_3 child_stillborn_sc_3 child_stillborn_num_sc_3 child_alive_died_24_sc_3 child_died_num_sc_3 child_alive_died_sc_3 child_died_num_more24_sc_3 child_died_u5_count_sc_3 child_died_repeat_sc_count_3 confirm_sc_3 correct_sc_3 translator_sc_3 child_bearing_index_sc_4 name_pc_sc_4 name_pc_earlier_sc_4 resp_avail_pc_sc_4 consent_pc_sc_4 no_consent_reason_pc_sc_4 no_consent_reason_pc_sc_1_4 no_consent_reason_pc_sc_2_4 no_consent_reason_pc_sc__77_4 no_consent_pc_oth_sc_4 no_consent_pc_comment_sc_4 residence_yesno_pc_sc_4 vill_pc_sc_4 vill_pc_oth_sc_4 a7_pregnant_leave_sc_4 a7_pregnant_leave_days_sc_4 a7_pregnant_leave_months_sc_4 village_name_res_sc_4 vill_residence_sc_4 last_5_years_pregnant_sc_4 child_living_sc_4 child_living_num_sc_4 child_notliving_sc_4 child_notliving_num_sc_4 child_stillborn_sc_4 child_stillborn_num_sc_4 child_alive_died_24_sc_4 child_died_num_sc_4 child_alive_died_sc_4 child_died_num_more24_sc_4  child_died_u5_count_sc_4 child_died_repeat_sc_count_4 confirm_sc_4 correct_sc_4 translator_sc_4 child_bearing_index_sc_5 name_pc_sc_5 name_pc_earlier_sc_5 resp_avail_pc_sc_5 consent_pc_sc_5 no_consent_reason_pc_sc_5 no_consent_reason_pc_sc_1_5 no_consent_reason_pc_sc_2_5 no_consent_reason_pc_sc__77_5 no_consent_pc_oth_sc_5 no_consent_pc_comment_sc_5 residence_yesno_pc_sc_5 vill_pc_sc_5 vill_pc_oth_sc_5 a7_pregnant_leave_sc_5 a7_pregnant_leave_days_sc_5 a7_pregnant_leave_months_sc_5 village_name_res_sc_5 vill_residence_sc_5 last_5_years_pregnant_sc_5 child_living_sc_5 child_living_num_sc_5 child_notliving_sc_5 child_notliving_num_sc_5 child_stillborn_sc_5 child_stillborn_num_sc_5 child_alive_died_24_sc_5 child_died_num_sc_5 child_alive_died_sc_5 child_died_num_more24_sc_5  child_died_u5_count_sc_5 child_died_repeat_sc_count_5 confirm_sc_5 correct_sc_5 translator_sc_5 child_bearing_index_sc_6 name_pc_sc_6 name_pc_earlier_sc_6 resp_avail_pc_sc_6 consent_pc_sc_6 no_consent_reason_pc_sc_6 no_consent_reason_pc_sc_1_6 no_consent_reason_pc_sc_2_6 no_consent_reason_pc_sc__77_6 no_consent_pc_oth_sc_6 no_consent_pc_comment_sc_6 residence_yesno_pc_sc_6 vill_pc_sc_6 vill_pc_oth_sc_6 a7_pregnant_leave_sc_6 a7_pregnant_leave_days_sc_6 a7_pregnant_leave_months_sc_6 village_name_res_sc_6 vill_residence_sc_6 last_5_years_pregnant_sc_6 child_living_sc_6 child_living_num_sc_6 child_notliving_sc_6 child_notliving_num_sc_6 child_stillborn_sc_6 child_stillborn_num_sc_6 child_alive_died_24_sc_6 child_died_num_sc_6 child_alive_died_sc_6 child_died_num_more24_sc_6   child_died_u5_count_sc_6 child_died_repeat_sc_count_6 confirm_sc_6 correct_sc_6 translator_sc_6 name_child_sc_* name_child_earlier_sc_*  unit_child_sc_* cause_death_sc_* cause_death_oth_sc_* age_child_sc_* cause_death_diagnosed_sc_* cause_death_str_sc_* miscarriage_sc_*
 

 *this is an irrelevant variable
drop sectionb_dur_end child_died_u5_count_sc_null_oth_ child_died_repeat_oth_count_* survey_member_names_count_* consented1roster_sc_1_2_31a10_hh consented1roster_sc_1_2_31a11_ol num_stillborn_null* num_living_null_* num_notliving_null_* num_less24_null_nsc_* num_more24_null_nsc_*
 
 * Combine women in child bearing age count  - women_child_bearing_count
 
/*Objective:

Archi commented this out- 


This command performs a loop over a list of variables stored in the local macro screened. Here's what each part of the code does:

foreach x of varlist \screened'`:

This loops through each variable in the screened list. The variable name is temporarily stored in the local macro x.
local y_\x' = regexr("x'", "_sc", ""):

This uses the regexr() function to create a new local macro y_\x', where the _sc` part of the variable name is removed.
The function regexr("x'", "_sc", "")searches for_scin the variable name stored inx and replaces it with an empty string (""`).
For example, if x is village_name_sc, it will create y_village_name with the value village_name (i.e., without _sc).
rename \x' `y_`x''_sc`:

This renames the variable x (which still has _sc) to the modified version y_\x'but appends_sc` again.
Essentially, the command is removing _sc and then adding it back to the variable name.
Overall, what does this loop do?
This loop appears redundant since it removes the _sc part from the variable name and then adds it back. It may have been written with the intention of performing a different operation but ended up renaming variables to their original names.

IMP- This loop may seem redundent at first but what it is trying to do it chnage the position of suffix _sc in way so that you could call such variables easily like _sc as ulttimatley we want to create final variables that dont have this distinction
*/ 

 
foreach x of varlist `screened' {
	local y_`x' = regexr("`x'", "_sc","") // Removing "_sc" from the variable name
	rename `x' `y_`x''_sc
}


//Archi - for refernce variables starting from women_child_bearing_count - translator_4 are all those cases where housheold was surveyed again from beginning because they were screened out in baseline since in mortality our screening criteria was chnaged from presence of pregnant women or U5 child to  child bearing women so such housheolds were surveyed again so these dont have suffix sc that means they were non screeened from baseline which were surveyed again

/*OBJECTIVE OF THE COMMAND BELOW- 

This command performs a loop over a range of variables (women_child_bearing_count to translator_4) and creates new variables based on the logic defined in the loop. Here's a breakdown of what each part does:

foreach x of varlist women_child_bearing_count - translator_4:

This loops over all variables in the dataset starting from women_child_bearing_count to translator_4. For each variable, it stores the name of the variable in the local macro x.
gen \x'_f = `x'`:

This generates a new variable x_f, which is a copy of the original variable x. For example, if x is women_child_bearing_count, it will create a new variable women_child_bearing_count_f with the same values as women_child_bearing_count.
replace \x'_f = `x'_sc if missing(`x') & !missing(`x'_sc)`:

This command replaces the newly created variable x_f with values from the variable x_sc (another variable that seems to contain a "screened" version of x).
It only performs the replacement if:
The value in the original variable x is missing (i.e., missing(x)).
The value in the "screened" version x_sc is not missing (i.e., !missing(x_sc)).
So, if x has missing values but x_sc has valid (non-missing) values, those will be used to fill in x_f.
drop \x' `x'_sc`:

After the operation is complete, the original variables x and x_sc are dropped from the dataset. This means the final dataset will only contain the new variable x_f.
Overall, what does this loop do?
The loop creates new variables (x_f) that combine data from two sources: the original variable (x) and the "screened" version (x_sc). It uses values from x_sc to fill in missing values in x_f only if they exist in x_sc. After that, it drops the original variables x and x_sc, leaving only the new variable x_f in the dataset.

In summary, it combines data from the original and screened versions into a single variable (x_f), replacing missing values from the original with values from the screened version.

*/ 


foreach x of varlist women_child_bearing_count - translator_4 {
	gen `x'_f = `x'
	replace `x'_f = `x'_sc if  missing(`x') & !missing(`x'_sc)
	drop `x' `x'_sc
}

*local child_roster name_child_sc_1_1 - cause_death_str_sc_1_1 name_child_sc_2_1 - cause_death_str_sc_2_1 name_child_sc_3_1 - cause_death_str_sc_3_1 name_child_sc_4_1 - cause_death_str_sc_4_1 name_child_sc_5_1 - cause_death_str_sc_5_1 name_child_sc_6_1 - cause_death_str_sc_6_1 

*foreach x of varlist `child_roster' {
*    local y_`x' = regexr("`x'", "_sc","")
*	gen `y_`x''_f = `x'
*	drop `x'
*}

****************************************************
//Archi to everyone: Layman explnantion of the code below for reference
****************************************************** 

/* What does this do? 

This block of code operates on a set of variables and performs some renaming and new variable generation. Here's a step-by-step explanation of what it does:

//Breakdown of each part:

1. `local var_left_sc *_5_sc *_6_sc`:
   - A local macro named `var_left_sc` is created. This macro holds the list of variables that match the pattern `*_5_sc` and `*_6_sc`.
   - These patterns likely represent variables that end with `_5_sc` and `_6_sc`. For example, it might refer to variables like `var_5_sc`, `var_6_sc`, etc.

2. `foreach x of varlist \`var_left_sc'`:
   - This loop iterates over the variables stored in the local macro `var_left_sc` (i.e., variables matching the patterns `*_5_sc` and `*_6_sc`).
   - For each iteration, the current variable name is assigned to the local macro `x`.

3. `local y_\`x' = regexr("\`x'", "_sc","")`:
   - A new local macro `y_\`x'` is created. Its value is obtained by applying the `regexr()` function to the variable name `x`.
   - `regexr("\`x'", "_sc", "")` uses regular expression to remove the suffix `_sc` from the variable name `x`. So, if `x` was `var_5_sc`, this command will remove `_sc` and store the result (e.g., `var_5`) in the local macro `y_\`x'`.

4. `gen \`y_\`x''_f = \`x'`:
   - This generates a new variable named `y_\`x'_f` (where `y_\`x'` is the variable name without `_sc`).
   - The new variable is created as a copy of the original variable `x`.
   - For example, if `x` is `var_5_sc` and `y_\`x'` is `var_5`, this command will generate a new variable called `var_5_f`, which will be a copy of `var_5_sc`.

5. `drop \`x'`:
   - This command drops the original variable `x` from the dataset. After the loop finishes, only the newly created `_f` variables will remain, and the original variables ending in `_sc` will be removed.

// Overall, what does this code do?

1. The code identifies variables ending in `_5_sc` and `_6_sc`.
2. It creates new variables by removing the `_sc` suffix and appending `_f` to the new variable name.
3. It copies the values from the original `_sc` variables into the new `_f` variables.
4. Finally, it drops the original `_sc` variables.

// Example:

- If you have variables `age_5_sc` and `income_6_sc`, this code will:
  - Create new variables `age_5_f` and `income_6_f`.
  - Copy the values from `age_5_sc` into `age_5_f`, and from `income_6_sc` into `income_6_f`.
  - Drop the original variables `age_5_sc` and `income_6_sc`.

In summary, it creates cleaner versions of variables by removing the `_sc` suffix and stores the new variables with an `_f` suffix, while dropping the old ones.


*/ 

local var_left_sc *_5_sc *_6_sc 
foreach x of varlist `var_left_sc' {
    local y_`x' = regexr("`x'", "_sc","")
	gen `y_`x''_f = `x'
	drop `x'
}


/*Explanation of Suffixes:
_sc: This suffix likely stands for "screened" and refers to variables associated with scenarios in which the household was screened for mortality data.
_f: The suffix _f represents "final" or "merged" variables that combine data from both screened and non-screened households.
*/

decode village_name, gen(village_name_str)
local preload_notsc village_name_str hamlet_name - saahi_name landmark address  fam_name1 - child_bearing_list

rename child_bearing_list_preload r_cen_child_bearing_list
local cen cen*

foreach x of varlist `cen' {
	rename `x' r_`x'

}

local preload_sc r_cen_landmark - r_cen_child_bearing_list

foreach x of varlist `preload_notsc' {
	gen `x'_f = `x'
	replace `x'_f = r_cen_`x' if  missing(`x') & !missing(r_cen_`x')
    drop `x'
}



* this is unique id for screened in households
destring unique_id ,  gen(unique_id_num)
format unique_id_num %15.0gc

rename unique_id_sc unique_id_hyphen
gen unique_id_sc = subinstr(unique_id_hyphen, "-", "",.) 
destring unique_id_sc, gen(unique_id_sc_num)
format   unique_id_sc_num %15.0gc

replace unique_id_num = unique_id_sc_num if  unique_id_num == .



* Stata variable names that are too long need to be rename
rename (r_cen_a12_water_source_prim  previous_primary_source_label change_reason_primary_source change_reason_primary_source*  change_reason_secondary__77 a13_change_reason_secondary  women_child_bearing_oth_count      no_consent_pc_comment_oth_1 a7_pregnant_leave_days_oth_*  last_5_years_pregnant_oth_* child_died_num_more24_oth_*  women_child_bearing_count_f          child_died_repeat_count_*   no_consent_reason_pc*    a7_pregnant_leave_months*   cause_death_diagnosed_* consented1preg_child_hist1women_*) (cen_a12_water_prim  previous_prim_label change_reason_prim change_reason_prim*   change_reason_sec__77 a13_change_reason_sec  women_child_oth_count     no_con_pc_com_oth_1 a7_preg_leave_days_oth_*  last_5_years_preg_oth_* childdied_num_mor24_oth_*  women_child_bear_count_f childdied_repeat_count_*  no_con_reason_pc*   a7_preg_leave_months*   cause_death_diag_* consent1preg_child_1women_*)

//Renaming vars with prefix R_mor
foreach x of var * {
	rename `x' R_mor_`x'
}

rename R_mor_unique_id_num unique_id_num

*Creating one village variable

tostring R_mor_village_name, gen (R_mor_village)
replace R_mor_village = "Gopi Kankubadi" if R_mor_village == "30701"
replace R_mor_village = "Nathma" if R_mor_village == "50501"
replace R_mor_village =  R_mor_r_cen_village_name_str if R_mor_village == "."


*creating combined enum name
clonevar R_mor_enum_name_f = R_mor_enum_name_label
replace R_mor_enum_name_f = R_mor_enum_name_label_sc if R_mor_enum_name_f == ""




* Household Head's name 


/*------------------------------------------------------------------------------
	1 Formatting dates
------------------------------------------------------------------------------*/
	
	*gen date = dofc(starttime)
	*format date %td
	gen M_mor_day = day(dofc(R_mor_starttime))
	gen M_mor_month_num = month(dofc(R_mor_starttime))
	//to change once survey date is fixed
	drop if (M_mor_day==23 & M_mor_month_num==9)
	
	 generate M_starthour = hh(R_mor_starttime) 
	 gen M_startmin= mm(R_mor_starttime)
	
	*gen diff_minutes = clockdiff(R_mor_starttime, R_mor_endtime, "minute")
	

/*------------------------------------------------------------------------------
	2 Basic cleaning
------------------------------------------------------------------------------*/


//1. dropping duplicate case based on field team feedback
*Note: the below duplicate is dropped because first the enumerator wrongly screened this HH out of the sample because of language issues. The supervisor later covered this case again
drop if R_mor_key==""

*Note: the below duplicate case is resolved such that 2 cases with the same HH number 36 do not exist. 


//2. Cleaning the GPS data 
// Keeping the most reliable entry of GPS

* Manual
foreach i in R_mor_gpslatitude R_mor_gpslongitude R_mor_gpsaltitude  {
	replace `i'=. if R_mor_gpslatitude>25  | R_mor_gpslatitude<15
    replace `i'=. if R_mor_gpslongitude>85 | R_mor_gpslongitude<80
}
* Auto
foreach i in R_mor_a40_gps_auto_2latitude_1 R_mor_a40_gps_auto_2longitude_1   {
	replace `i'=. if R_mor_a40_gps_auto_2latitude_1>25  | R_mor_a40_gps_auto_2latitude_1<15
    replace `i'=. if R_mor_a40_gps_auto_2longitude_1>85 | R_mor_a40_gps_auto_2longitude_1<80
}
* Final GPS
foreach i in latitude longitude altitude{
	gen     R_mor_a40_gps_`i'=R_mor_a40_gps_auto_2`i'_1
	replace R_mor_a40_gps_`i'=R_mor_gps`i' if R_mor_a40_gps_`i'==.
	* Add manual
	drop R_mor_a40_gps_auto_2`i'_1 R_mor_gps`i'
}

* Reconsider puting back back but with less confusing variable name
drop R_mor_a40_gps_auto_2accuracy_1 R_mor_gpsaccuracy  


/*------------------------------------------------------------------------------
	3 Quality check
------------------------------------------------------------------------------*/
//1. Making sure that the unique_id is unique
foreach i in unique_id_num {
bys `i': gen `i'_Unique=_N
}

tempfile working
save `working', replace



preserve
keep if unique_id_num_Unique!=1 //for ease of observation and analysis
duplicates report unique_id_num R_mor_fam_name1_f


//keeping instance for IDs where consent was obtained
replace R_mor_consent= 0 if R_mor_consent==.
bys unique_id_num (R_mor_consent): gen M_dup_by_consent= _n if R_mor_consent[_n]!=R_mor_consent[_n+1]
br unique_id_num R_mor_consent M_dup_by_consent
drop if R_mor_consent==0 & M_dup_by_consent[_n]== 1 

//sorting and marking duplicate number by submission time 
bys unique_id_num (R_mor_starttime): gen M_dup_tag= _n if R_mor_consent==0

//Case 1-
gen M_new1= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]!=R_mor_fam_name1_f[_n+1] & R_mor_fam_name1_f[_n]==""

//Case 2-
gen M_new2= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]==R_mor_fam_name1_f[_n+1] 

//Case 3- 
gen M_new3= 1 if unique_id_num[_n]==unique_id_num[_n+1] & R_mor_fam_name1_f[_n]!=R_mor_fam_name1_f[_n+1] & R_mor_fam_name1_f[_n]!=""

tempfile dups
save `dups', replace

***** Step 2: For cases that don't get resolved, outsheet an excel file with the duplicate ID cases and send across to Santosh ji for checking with supervisors]
//submission time to be added Bys unique_id (submissiontime): gen
keep if M_new1==1 | M_new2==1 | M_new3==1
 capture export excel unique_id_num R_mor_enum_name_f R_mor_village_str_f R_m_submissiondate using "${pilot}Data_quality.xlsx" if unique_id_num_Unique!=1, sheet("Dup_ID_Mortality") ///
 firstrow(var) cell(A1) sheetreplace

 restore
 
/*------------------------------------------------------------------------------
	4  Manual corrections for duplicates and missing fields
------------------------------------------------------------------------------*/
 
// 1. Cleaning Duplicates

*Dropping this ID because this was submitted during training by the enumerator because we wanted to check how data comes in the server. So, this is just a practise ID
drop if unique_id_num == 30701119004 & R_mor_key == "uuid:152626bc-0c8a-49cb-88f7-9a00146848f7" & R_mor_enum_name_f == "Sarita Bhatra"

*Dropping this ID because this form was in edit saved but without completing the full survey enumerator by mistake finalized the survey so a new form was submitted under the same HHID and was submitted after completing the survey
drop if unique_id_num == 30701119004 & R_mor_key == "uuid:75c83961-fafd-4284-a28b-fb9fb975d120" &  R_mor_resp_avail_pc_2_f == 3

*Dropping this ID because enumerator by mistake again submitted this survey it was already submitted earlier, so the survey where HH members are 8 is the original one 
drop if unique_id_num == 30701503009 & R_mor_key == "uuid:674c4468-e498-431f-a5a4-b56e1af2629a" &  R_mor_a2_hhmember_count  == 2

*Dropping this ID because this was submitted during training by the enumerator because we wanted to check how data comes in the server. So, this is just a practise ID
drop if unique_id_num == 77519001 & R_mor_key == "uuid:919be1f7-875d-49bd-be0c-bb3a3ce25171" & R_mor_village == "-77"	

*Replacing response

*Enumerator made a data entry error here, there was no child at the HH who died under 24 hours. So, that is why replacing this with . becasue the number questioned won't be asked to them if that case hasn't happened at the HH at the first place 
replace R_mor_child_died_num_1_f = . if R_mor_child_died_num_1_f == 1 & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b" & R_mor_enum_name_f == "Pramodini Gahir"	


// 2. Manual data

**HHID- 30701119003
**There was an error in the form due to which survey wasn't showing death section for the child if the death has occured and form was already in the edit saved so we had to ask the enum to submit the form without doing death section as it was in edit saved and any update from our side couldn't be incorporated in the edit saved form. We asked them to collect details for death section on a piece of paper which was destroyed later. Form error has been fixed now
replace R_mor_name_child_1_1_f = "New baby" if R_mor_name_child_1_1_f == "" & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_age_child_1_1_f = 4 if R_mor_age_child_1_1_f == . & unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_unit_child_1_1_f = 2 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_date_birth_sc_1_1 = date("24/02/2019", "DMY") if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_date_death_sc_1_1 = date("27/02/2019", "DMY")  if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
cap destring R_mor_cause_death_diag_1_1_f, replace
cap destring R_mor_cause_death_999_1_1_f, replace
replace R_mor_cause_death_999_1_1_f = 1 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_cause_death_diag_1_1_f = 0 if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"
replace R_mor_cause_death_str_1_1_f  = "It was a normal delivery and ASHA took the lady to the hospital but child died in the hospital, she wasn't informed about the issue and she could not find that out on her own" if unique_id_num == 30701119003 & R_mor_key == "uuid:af6ad7ee-8c88-4dfa-bab5-610ee055d26b"

**HHID- 30701505008
**There was an error in the form due to which survey wasn't showing death section for the child if the death has occured and form was already in the edit saved so we had to ask the enum to submit the form without doing death section as it was in edit saved and any update from our side couldn't be incorporated in the edit saved form. We asked them to collect details for death section on a piece of paper which was destroyed later. Form error has been fixed now

replace R_mor_name_child_1_1_f = "New baby" if R_mor_name_child_1_1_f == "" & unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_age_child_1_1_f = 1 if R_mor_age_child_1_1_f == . & unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_unit_child_1_1_f = 2 if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_date_birth_sc_1_1 = date("10/11/2020", "DMY") if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_date_death_sc_1_1 = date("10/11/2020", "DMY")  if  unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_cause_death_999_1_1_f = 1 if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_cause_death_diag_1_1_f = 999 if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"
replace R_mor_cause_death_str_1_1_f  = "Delivery was done in the hospital and child died in the hospital, she wasn't informed about the issue and she could not find that out on her own" if unique_id_num == 30701505008 & R_mor_key == "uuid:9a0e5fe4-fc48-4f4f-a838-c5f676bad2ab"



 
/*

****Step 4: Appending files with unqiue IDs
use `working', clear
drop if unique_id_num_Unique!=1
append using `dups_part1', force
append using `dups_part2', force
append using `dups_part3', force
//also append file that comes corrected from the field

duplicates report unique_id //final check

drop unique_id_num_Unique 
* Recreating the unique variable after solving the duplicates
drop unique_id_num unique_id_hyphen
destring unique_id, gen(unique_id_num)
format   unique_id_num %15.0gc 
gen unique_id_hyphen = substr(unique_id, 1,5) + "-"+ substr(unique_id, 6,3) + "-"+ substr(unique_id, 9,3)

replace R_Cen_consent=. if R_Cen_screen_u5child==0 & R_Cen_screen_preg==0
replace R_Cen_consent=. if R_Cen_screen_u5child==. & R_Cen_screen_preg==.
*replace R_Cen_instruction= 1 if R_Cen_screen_u5child==1 | R_Cen_screen_preg==1


/*
clear all
//Ensuring we have correct observations from all form versions
import excel "${DataRaw}Baseline Census_WIDE.xlsx", sheet("data") firstrow
gen unique_id = subinstr(unique_ID, "-", "",.) 
merge m:1 unique_id using `main'
*/
/*
* Astha: Check if the same HH is interviewed twice
* 
* merge 1:1 key using "drop_ID.dta", keep(1 2)
* excel: key, unique ID, reason (same HH interview: choice dropbown menu) for droping. 

* Make sure that unique ID is consective (no jumping)- not sure this is needed as long as ID is unique

* Discussion point: Agree what to do when we have duplicate
duplicates drop unique_id, force
*/
*/


*******Final variable creation for clean data

gen      M_HH_not_available=0
replace M_HH_not_available=1 if R_mor_resp_available!=1

foreach i in R_mor_consent   {
	gen    Non_`i'=`i'
	recode Non_`i' 0=1 1=0	
}

tempfile main
save `main', replace



/*
//correcting dates using raw data
clear
import delimited using "${DataRaw}Baseline Census_WIDE.csv"
duplicates drop unique_id, force
keep submissiondate starttime unique_id
rename unique_id unique_id_hyphen
gen unique_id = subinstr(unique_id_hyphen, "-", "",.) 
merge 1:1 unique_id using `main'

drop if _merge==1

//Formatting dates
	split starttime, parse("")
	drop starttime2
	gen month= substr(starttime1, 1, 2)
	replace month="9" if month=="9/"
	gen day_of_month= substr(starttime1, 3, 3)
	replace day_of_month = subinstr(day_of_month, "/", "", .)

	replace month= "Oct" if month=="10"
	replace month= "Sept" if month=="9"
	gen month_day= day_of_month + " " + month + " " + "2023"
*/



/*-----------------------------------------------------------------------------------------------------------------------------------
 Village name correction                                                      
-------------------------------------------------------------------------------------------------------------------------------------*/
replace R_mor_village = "BK Padar" if R_mor_village == "30202" 
replace R_mor_village = "Kuljing" if R_mor_village == "50402" 

/*-----------------------------------------------------------------------------------------------------------------------------------
 Manual cleaning                                                       
-------------------------------------------------------------------------------------------------------------------------------------*/

*Enumerator made a data entry error 
replace R_mor_child_stillborn_1_f = 0 if R_mor_child_stillborn_1_f == 1 & R_mor_village == "Nathma" & unique_id_num == 50501503007 & R_mor_key == "uuid:efe798d4-5679-4b19-9154-1f773c775c2a"
replace R_mor_child_stillborn_num_1_f = . if R_mor_child_stillborn_num_1_f == 1 & R_mor_village == "Nathma" & unique_id_num == 50501503007 & R_mor_key == "uuid:efe798d4-5679-4b19-9154-1f773c775c2a"

*Miscarriage cases
//This question wasn't added before that's why this needs to be hard-coded
replace R_mor_miscarriage_2_f = 1 if  R_mor_last_5_years_pregnant_2_f == 1 &  unique_id_num == 30202519019 & R_mor_key == "uuid:697cf30f-3cac-43b7-9132-9032dc308232"
replace R_mor_miscarriage_1_f = 1 if  R_mor_last_5_years_pregnant_1_f == 1 &  unique_id_num == 50501505011 & R_mor_key == "uuid:5920710d-48b8-45f0-8926-3f0d2589814a"
replace R_mor_miscarriage_1_f = 1 if  R_mor_last_5_years_pregnant_1_f == 1 &  unique_id_num == 50501503007 & R_mor_key == "uuid:efe798d4-5679-4b19-9154-1f773c775c2a"
replace R_mor_miscarriage_2_f = 1 if  R_mor_last_5_years_pregnant_2_f == 1 &  unique_id_num == 50501521005 & R_mor_key == "uuid:553d8275-7dc8-4bef-8297-85adb99d1775"


/*-----------------------------------------------------------------------------------------------------------------------------------
 Combining var name                                                      
-------------------------------------------------------------------------------------------------------------------------------------*/
*generating a combined var name for resp
clonevar R_mor_resp_name = R_mor_a1_resp_name
replace R_mor_resp_name = R_mor_r_cen_a1_resp_name if R_mor_resp_name  == ""
replace R_mor_resp_name = lower(R_mor_resp_name)




	
/*-----------------------------------------------------------------------------------------------------------------------------------
Dulpicates check                                                    
-------------------------------------------------------------------------------------------------------------------------------------*/

**Duplicate Unique IDs*** 

//Enumerator by mistake submitted this twice so deleting the data which was marked as unavailable and submitted on 4th jan
*Astha to include this in her cleaning code ( submission_date == date("04/01/2024", "DMY")
drop if unique_id_num == 50402117028 & R_mor_key == "uuid:3bd8aa78-f7cc-4cdc-80ff-ed106cb1b57d" 

bysort unique_id_num: gen dup_HHID = cond(_N==1,0,_n)
count if dup_HHID > 0 
tab dup_HHID
list unique_id_num if dup_HHID > 0
cap export excel unique_id_num R_mor_enum_name_f R_mor_village R_mor_resp_name R_mor_a2_hhmember_count  if dup_HHID > 0  using "$PathTables/Mortality_tables.xlsx", firstrow(varlabels) sheet(duplicates) sheetreplace



save "${DataFinal}1_1_Mortality_cleaned.dta", replace
savesome using "${DataFinal}1_1_Mortality_cleaned_consented.dta" if R_mor_consent==1, replace

** Drop ID information  - to do : deidentify data
/*
drop R_mor_a1_resp_name R_Cen_a3_hhmember_name_1 R_Cen_a3_hhmember_name_2 R_Cen_a3_hhmember_name_3 R_Cen_a3_hhmember_name_4 R_Cen_a3_hhmember_name_5 R_Cen_a3_hhmember_name_6 R_Cen_a3_hhmember_name_7 R_Cen_a3_hhmember_name_8 R_Cen_a3_hhmember_name_9 R_Cen_a3_hhmember_name_10 R_Cen_a3_hhmember_name_11 R_Cen_a3_hhmember_name_12 R_Cen_namefromearlier_1 R_Cen_namefromearlier_2 R_Cen_namefromearlier_3 R_Cen_namefromearlier_4 R_Cen_namefromearlier_5 R_Cen_namefromearlier_6 R_Cen_namefromearlier_7 R_Cen_namefromearlier_8 R_Cen_namefromearlier_9 R_Cen_namefromearlier_10 R_Cen_namefromearlier_11 R_Cen_namefromearlier_12 
save "${DataDeid}1_1_Census_cleaned_noid.dta", replace
