ssc install ietoolkit // Install the package if not already installed

// Import the dataset
import delimited "C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\1_1_baseline_census.csv", clear

// Convert assignment from string to numeric
encode assignment, generate(assignment_num)

// Label the assignment variable correctly
label define assign_lbl 1 "Control" 2 "Treatment"
label values assignment_num assign_lbl

// Convert string variables (if necessary) to numeric
foreach var in sec_source jjm_drinking water_treat_binary electricity_binary tv_binary mobile_binary fridge_binary motorcycle_binary {
    destring `var', replace ignore("NA")
}

// Generate a combined fixed effect variable using blockcode
gen block_panchayat_fe = blockcode * 10 + panchayat_village

// Generate the balance table
iebaltab ///
    hhmember_count hhhead_gender read_write_1 sec_source jjm_drinking water_treat_binary ///
    electricity_binary tv_binary mobile_binary fridge_binary ///
    motorcycle_binary, ///
    groupvar(assignment_num) ///
    fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
    vce(cluster village_id) ///
    nostars /// Hide significance stars
    groupcodes /// Include only if 'assignment' has value labels
    rowvarlabels /// Ensure balance variables have labels
    grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
    rowlabels("hhmember_count Household Members @ hhhead_gender Head Gender @ read_write_1 Literacy Status @ sec_source Secondary Water Source @ jjm_drinking JJM Drinking Water @ water_treat_binary Water Treatment @ electricity_binary Electricity @ tv_binary TV Ownership @ mobile_binary Mobile Ownership @ fridge_binary Fridge Ownership @ motorcycle_binary Motorcycle Ownership") ///
    savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table.xlsx")

	
// Generating Standard Errors to be pasted into the table	

// Import the dataset again
import delimited "C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\1_1_baseline_census.csv", clear

// Convert assignment from string to numeric
encode assignment, generate(assignment_num)

// Label the assignment variable correctly
label define assign_lbl 1 "Control" 2 "Treatment"
label values assignment_num assign_lbl

// Convert string variables (if necessary) to numeric
foreach var in sec_source jjm_drinking water_treat_binary electricity_binary tv_binary mobile_binary fridge_binary motorcycle_binary {
    destring `var', replace ignore("NA")
}

// Generate a combined fixed effect variable using blockcode
gen block_panchayat_fe = blockcode * 10 + panchayat_village

// Generate the standard errors balance table
iebaltab ///
    hhmember_count hhhead_gender read_write_1 sec_source jjm_drinking water_treat_binary ///
    electricity_binary tv_binary mobile_binary fridge_binary ///
    motorcycle_binary, ///
    groupvar(assignment_num) ///
    fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
    vce(cluster village_id) ///
    nostars /// Hide significance stars
    stats(pair(se)) /// Replaces difference in means with SE of difference in means
    groupcodes /// Include only if 'assignment' has value labels
    rowvarlabels /// Ensure balance variables have labels
    grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
    rowlabels("hhmember_count Household Members @ hhhead_gender Head Gender @ read_write_1 Literacy Status @ sec_source Secondary Water Source @ jjm_drinking JJM Drinking Water @ water_treat_binary Water Treatment @ electricity_binary Electricity @ tv_binary TV Ownership @ mobile_binary Mobile Ownership @ fridge_binary Fridge Ownership @ motorcycle_binary Motorcycle Ownership") ///
    savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table_SEs.xlsx")

	
	
	
	
	
	
	
// baseline survey	
// Import the dataset
import delimited "C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\1_1_baseline_survey.csv", clear

// Convert assignment from string to numeric
encode assignment, generate(assignment_num)

// Label the assignment variable correctly
label define assign_lbl 1 "Control" 2 "Treatment"
label values assignment_num assign_lbl

// Convert string variables (if necessary) to numeric
foreach var in tap_taste_binary treat_time_5min {
    destring `var', replace ignore("NA")
}

// Generate a combined fixed effect variable using blockcode
gen block_panchayat_fe = blockcode * 10 + panchayat_village

// Generate the balance table
iebaltab ///
    tap_taste_binary treat_time_5min, ///
    groupvar(assignment_num) ///
    fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
    vce(cluster village_id) /// Cluster at village level
    nostars /// Hide significance stars
    groupcodes /// Include only if 'assignment' has value labels
    rowvarlabels /// Ensure balance variables have labels
    grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
    rowlabels("tap_taste_binary Taste Satisfaction @ treat_time_5min Treatment Time") ///
    savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table_survey.xlsx")

// Generate Standard Errors balance table
// Generate the balance table
iebaltab ///
    tap_taste_binary treat_time_5min, ///
    groupvar(assignment_num) ///
    fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
    vce(cluster village_id) /// Cluster at village level
    nostars /// Hide significance stars
	stats(pair(se)) /// Replaces difference in means with SE of difference in means
    groupcodes /// Include only if 'assignment' has value labels
    rowvarlabels /// Ensure balance variables have labels
    grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
    rowlabels("tap_taste_binary Taste Satisfaction @ treat_time_5min Treatment Time") ///
    savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table_survey_SEs.xlsx")


	
	
// Running for IDEXX results, E. coli and Total Coliform


// Import the dataset
import delimited "C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\1_10_idexx_all_rounds.csv", clear

// Keep only the baseline (BL) round
keep if data_round == "BL"

// Convert assignment from string to numeric
encode assignment, generate(assignment_num)

// Convert block (string) to numeric
encode block, generate(block_num)

// Convert village string to numeric
encode village, generate(village_num)


// Label the assignment variable correctly
label define assign_lbl 1 "Control" 2 "Treatment"
label values assignment_num assign_lbl

// Loop through sample types
foreach sample in Tap Stored {
    
    // Keep only current sample type
    preserve
    keep if sample_type == "`sample'"

    // Generate a combined fixed effect variable using block and panchayat_village
    gen block_panchayat_fe = block_num * 10 + panchayat_village

    // Generate the balance table
    iebaltab ///
        ec_log cf_log ec_pa_binary cf_pa_binary, ///
        groupvar(assignment_num) ///
        fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
        vce(cluster village_num) ///
        nostars /// Hide significance stars
        groupcodes /// Include only if 'assignment' has value labels
        rowvarlabels /// Ensure balance variables have labels
        grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
        rowlabels("ec_log Log E. coli @ cf_log Log Total Coliform @ ec_pa_binary E. coli Presence @ cf_pa_binary Total Coliform Presence") ///
        savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table_`sample'.xlsx")
	iebaltab ///
        ec_log cf_log ec_pa_binary cf_pa_binary, ///
        groupvar(assignment_num) ///
        fixedeffect(block_panchayat_fe) /// Uses combined fixed effect
        vce(cluster village_num) ///
        nostars /// Hide significance stars
		stats(pair(se)) /// Replaces difference in means with SE of difference in means
        groupcodes /// Include only if 'assignment' has value labels
        rowvarlabels /// Ensure balance variables have labels
        grouplabels(1 "Control" @ 2 "Treatment") /// Use numeric values with labels
        rowlabels("ec_log Log E. coli @ cf_log Log Total Coliform @ ec_pa_binary E. coli Presence @ cf_pa_binary Total Coliform Presence") ///
        savexlsx ("C:\Users\jerem\Box\India Water project\2_Pilot\Data\3_final\manuscript_datasets\balance_table_`sample'_SEs.xlsx")

    restore
}

	
