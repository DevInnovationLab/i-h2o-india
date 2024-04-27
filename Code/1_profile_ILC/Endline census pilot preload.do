import delimited "C:\Users\Archi Gupta\Box\Data\1_raw\0_Archive\Pilot of pilot\Baseline Census_WIDE.csv", bindquote(strict)


ds `r(varlist)'
foreach var of varlist `r(varlist)'{
rename `var' R_Cen_`var'
}


gen C_Screened = .
replace C_Screened = 1 if R_Cen_screen_u5child == 1 | R_Cen_screen_preg == 1


keep if C_Screened == 1

gen R_Cen_village_name_str = ""
replace R_Cen_village_name_str = "Gajigaon"

export excel R_Cen_unique_id  R_Cen_block_name R_Cen_village_name R_Cen_village_name_str R_Cen_hamlet_name R_Cen_saahi_name R_Cen_landmark R_Cen_a1_resp_name R_Cen_a10_hhhead R_Cen_a11_oldmale_name using "${pilot}Supervisor_Endline_Tracker_Pilot.xlsx" , sheet("Sheet1", replace) firstrow(varlabels) cell(A1)



gen unique_id = subinstr(R_Cen_unique_id, "-", "", .)

drop R_Cen_a10_hhhead

rename R_Cen_a11_oldmale_name R_Cen_a10_hhhead




local fam_age R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 


forvalues i = 1/9 {
	gen Cen_fam_age`i' = R_Cen_a6_hhmember_age_`i'
    local ++i
}


forvalues i = 10/17 {
	gen Cen_fam_age`i' = .
    local ++i
}


local fam_gender R_Cen_a4_hhmember_gender_1 R_Cen_a4_hhmember_gender_2 R_Cen_a4_hhmember_gender_3 R_Cen_a4_hhmember_gender_4 R_Cen_a4_hhmember_gender_5 R_Cen_a4_hhmember_gender_6 R_Cen_a4_hhmember_gender_7 R_Cen_a4_hhmember_gender_8 R_Cen_a4_hhmember_gender_9 

forvalues i = 1/9 {
	gen Cen_fam_gender`i' = R_Cen_a4_hhmember_gender_`i'
    local ++i
}


forvalues i = 10/17 {
	gen Cen_fam_gender`i' = .
    local ++i
}


forvalues i = 1/17 {
	gen Cen_children_below5_`i' = 1 if Cen_fam_age`i' <= 5   
    local ++i
}


forvalues i = 1/17 {
	gen Cen_u5_child_elig_`i' = `i' if Cen_children_below5_`i' == 1  
    local ++i
}


forvalues i = 1/17 {
	gen Cen_female_15_49_`i' = 1 if Cen_fam_age`i' >= 15 & Cen_fam_age`i' <= 49 & Cen_fam_gender`i' == 2  
    local ++i
}


forvalues i = 1/17 {
	gen Cen_female_eligible_`i' = `i' if Cen_female_15_49_`i' == 1
    local ++i
}

forvalues i = 1/17 {
	gen Cen_males_15_`i' = 1 if Cen_fam_age`i' >= 15 & Cen_fam_gender`i' == 1  
    local ++i
}

forvalues i = 1/17 {
	gen Cen_males_15_elig_`i' = `i' if Cen_males_15_`i' == 1  
    local ++i
}


//eligible women of Child bearing age 
egen R_Cen_num_female_15to49 = anycount(Cen_female_15_49_1-Cen_female_15_49_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_female_eligible = concat(Cen_female_eligible_1-Cen_female_eligible_17), p(" ")
replace R_Cen_female_eligible = subinstr(R_Cen_female_eligible, ".", "", .) 

//child u5

egen R_Cen_num_u5child = anycount(Cen_children_below5_1-Cen_children_below5_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_u5_child = concat(Cen_u5_child_elig_1-Cen_u5_child_elig_17), p(" ")
replace R_Cen_u5_child = subinstr(R_Cen_u5_child, ".", "", .) 


//males more than 15
egen R_Cen_num_males15 = anycount(Cen_males_15_1-Cen_males_15_17), value(1)

sort R_Cen_village_name_str

egen R_Cen_males_list = concat(Cen_males_15_elig_1-Cen_males_15_elig_17), p(" ")
replace R_Cen_males_list = subinstr(R_Cen_males_list, ".", "", .) 



export excel unique_id R_Cen_a10_hhhead R_Cen_a1_resp_name R_Cen_a39_phone_name_1 R_Cen_a39_phone_num_1 R_Cen_a39_phone_name_2 R_Cen_a39_phone_num_2 R_Cen_village_name_str R_Cen_address R_Cen_landmark R_Cen_hamlet_name R_Cen_saahi_name  R_Cen_fam_name1 R_Cen_fam_name2 R_Cen_fam_name3 R_Cen_fam_name4 R_Cen_fam_name5 R_Cen_fam_name6 R_Cen_fam_name7 R_Cen_fam_name8 R_Cen_fam_name9 R_Cen_fam_name10 R_Cen_fam_name11 R_Cen_fam_name12 R_Cen_fam_name13 R_Cen_fam_name14 R_Cen_fam_name15 R_Cen_fam_name16 R_Cen_fam_name17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20  R_Cen_a12_water_source_prim R_Cen_u5child_* R_Cen_pregwoman_* Cen_fam_age* Cen_fam_gender* R_Cen_female_above12 R_Cen_num_femaleabove12  R_Cen_adults_hh_above12 R_Cen_num_adultsabove12 R_Cen_children_below12 R_Cen_num_childbelow12 R_Cen_enum_name R_Cen_enum_code R_Cen_enum_name_label  R_Cen_num_female_15to49  R_Cen_female_eligible R_Cen_num_u5child R_Cen_u5_child R_Cen_num_males15 R_Cen_males_list R_Cen_a2_hhmember_count using "${DataPre}Endline_census_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)



***********************************************************************
* Step 4: Generating tracking list for supervisors for Mortality survey *
***********************************************************************

*renaming women name 
forvalues i = 1/17 {
	rename R_Cen_fam_name`i' R_Cen_fam_name_`i'
}


forvalues i = 10/17 {
	gen R_Cen_a4_hhmember_gender_`i' = .
    local ++i
}

forvalues i = 10/17 {
	gen R_Cen_a6_hhmember_age_`i' = .
    local ++i
}

export excel unique_id R_Cen_fam_name_1 R_Cen_fam_name_2 R_Cen_fam_name_3 R_Cen_fam_name_4 R_Cen_fam_name_5 R_Cen_fam_name_6 R_Cen_fam_name_7 R_Cen_fam_name_8 R_Cen_fam_name_9 R_Cen_fam_name_10 R_Cen_fam_name_11 R_Cen_fam_name_12 R_Cen_fam_name_13 R_Cen_fam_name_14 R_Cen_fam_name_15 R_Cen_fam_name_16 R_Cen_fam_name_17 R_Cen_fam_name18 R_Cen_fam_name19 R_Cen_fam_name20 R_Cen_a4_hhmember_gender_1 R_Cen_a4_hhmember_gender_2 R_Cen_a4_hhmember_gender_3 R_Cen_a4_hhmember_gender_4 R_Cen_a4_hhmember_gender_5 R_Cen_a4_hhmember_gender_6 R_Cen_a4_hhmember_gender_7 R_Cen_a4_hhmember_gender_8 R_Cen_a4_hhmember_gender_9 R_Cen_a4_hhmember_gender_10 R_Cen_a4_hhmember_gender_11 R_Cen_a4_hhmember_gender_12 R_Cen_a4_hhmember_gender_13 R_Cen_a4_hhmember_gender_14 R_Cen_a4_hhmember_gender_15 R_Cen_a4_hhmember_gender_16 R_Cen_a4_hhmember_gender_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 using "${DataPre}Endline_census_hhmember_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

*renaming women name 
forvalues i = 1/17 {
	gen R_Cen_eligible_women_pre_`i' = R_Cen_fam_name_`i' if R_Cen_a6_hhmember_age_`i' >= 15 & R_Cen_a6_hhmember_age_`i' <= 49 & R_Cen_a4_hhmember_gender_`i' == 2
    gen R_Cen_eligible_women_pre_num_`i' = 1 if R_Cen_a6_hhmember_age_`i' >= 15 & R_Cen_a6_hhmember_age_`i' <= 49 & R_Cen_a4_hhmember_gender_`i' == 2 
	}

export excel unique_id R_Cen_eligible_women_pre_1 R_Cen_eligible_women_pre_2 R_Cen_eligible_women_pre_3 R_Cen_eligible_women_pre_4 R_Cen_eligible_women_pre_5 R_Cen_eligible_women_pre_6 R_Cen_eligible_women_pre_7 R_Cen_eligible_women_pre_8 R_Cen_eligible_women_pre_9 R_Cen_eligible_women_pre_10 R_Cen_eligible_women_pre_11 R_Cen_eligible_women_pre_12 R_Cen_eligible_women_pre_13 R_Cen_eligible_women_pre_14 R_Cen_eligible_women_pre_15 R_Cen_eligible_women_pre_16 R_Cen_eligible_women_pre_17 using "${DataPre}Endline_census_eligiblewomen_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

*exporting child names
forvalues i = 1/17 {
	gen R_Cen_u5_child_pre_`i' = R_Cen_fam_name_`i' if R_Cen_a6_hhmember_age_`i' <= 5 
	}

export excel unique_id R_Cen_u5_child_pre_1 R_Cen_u5_child_pre_2 R_Cen_u5_child_pre_3 R_Cen_u5_child_pre_4 R_Cen_u5_child_pre_5 R_Cen_u5_child_pre_6 R_Cen_u5_child_pre_7 R_Cen_u5_child_pre_8 R_Cen_u5_child_pre_9 R_Cen_u5_child_pre_10 R_Cen_u5_child_pre_11 R_Cen_u5_child_pre_12 R_Cen_u5_child_pre_13 R_Cen_u5_child_pre_14 R_Cen_u5_child_pre_15 R_Cen_u5_child_pre_16 R_Cen_u5_child_pre_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 using "${DataPre}Endline_census_u5child_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)

** Loop through R_Cen_eligible_women_pre variables (2 to 20) */
** Loop through R_Cen_eligible_women_pre variables (2 to 20) */


*exporting all non criteria members for health section stuff
forvalues i = 1/17 {
	gen R_Cen_non_cri_mem_`i' = R_Cen_fam_name_`i' if (R_Cen_a6_hhmember_age_`i' > 5 & R_Cen_a4_hhmember_gender_`i' == 1) | (R_Cen_a6_hhmember_age_`i' > 49 & R_Cen_a4_hhmember_gender_`i' == 2)
	}
	

forvalues i = 1/9 {
	gen R_Cen_num_non_cri_mem_`i' = 1 if R_Cen_non_cri_mem_`i' != ""
	}
	

forvalues i = 10/17 {
    drop R_Cen_non_cri_mem_`i'
	gen R_Cen_non_cri_mem_`i' = ""
	gen R_Cen_num_non_cri_mem_`i' = 1 if R_Cen_non_cri_mem_`i' != ""
	}
	
egen temp_group = group(unique_id) //temp_group ensures that rowtotal is done based on unqiue id and inter-mingling doesn't happen
ds R_Cen_num_non_cri_mem_*
foreach var of varlist `r(varlist)'{
replace `var' = . if `var' == 999
replace `var' = . if `var' == 98
}
egen total_noncri = rowtotal(R_Cen_num_non_cri_mem_*)
drop temp_group
	

export excel unique_id R_Cen_non_cri_mem_1 R_Cen_non_cri_mem_2 R_Cen_non_cri_mem_3 R_Cen_non_cri_mem_4 R_Cen_non_cri_mem_5 R_Cen_non_cri_mem_6 R_Cen_non_cri_mem_7 R_Cen_non_cri_mem_8 R_Cen_non_cri_mem_9 R_Cen_non_cri_mem_10 R_Cen_non_cri_mem_11 R_Cen_non_cri_mem_12 R_Cen_non_cri_mem_13 R_Cen_non_cri_mem_14 R_Cen_non_cri_mem_15 R_Cen_non_cri_mem_16 R_Cen_non_cri_mem_17 R_Cen_a6_hhmember_age_1 R_Cen_a6_hhmember_age_2 R_Cen_a6_hhmember_age_3 R_Cen_a6_hhmember_age_4 R_Cen_a6_hhmember_age_5 R_Cen_a6_hhmember_age_6 R_Cen_a6_hhmember_age_7 R_Cen_a6_hhmember_age_8 R_Cen_a6_hhmember_age_9 R_Cen_a6_hhmember_age_10 R_Cen_a6_hhmember_age_11 R_Cen_a6_hhmember_age_12 R_Cen_a6_hhmember_age_13 R_Cen_a6_hhmember_age_14 R_Cen_a6_hhmember_age_15 R_Cen_a6_hhmember_age_16 R_Cen_a6_hhmember_age_17 total_noncri using "${DataPre}Endline_census_noncri_preload.xlsx", sheet("Sheet1", replace) firstrow(variables) cell(A1)





