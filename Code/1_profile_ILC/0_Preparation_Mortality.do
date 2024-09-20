************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files
* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" | c(username)=="michellecherian" | c(username)== "asthavohra" | c(username)== "Archi Gupta" {
cd "${DataRaw}"

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey.dta", replace

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist-women_child_bearing.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-consented-preg_child_hist-women_child_bearing.dta", replace

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist_oth-women_child_bearing_oth.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-consented-preg_child_hist_oth-women_child_bearing_oth.dta", replace


do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-preg_child_hist_sc-women_child_bearing_sc.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-consented-preg_child_hist_sc-women_child_bearing_sc.dta", replace

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-consented-roster_sc_1_2_3-HH_member_names.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-consented-consented-roster_sc_1_2_3-HH_member_names.dta", replace


do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey-consented_pc-start_5_years_pregnant-child_died_repeat.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey-consented_pc-start_5_years_pregnant-child_died_repeat.dta", replace

do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-child_died_repeat_oth.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-child_died_repeat_oth.dta", replace


do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-survey_member_names.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey_oth-consented_pc_oth-start_5_years_pregnant_oth-survey_member_names.dta", replace


do "${Do_lab}india_ilc_pilot_mortality_Master_stata_template_long\import_india_ilc_pilot_mortality_Master-start_pc_survey_sc-consented_pc_sc-start_5_years_pregnant_sc-child_died_repeat_sc.do"
save "${DataRaw}Mortality survey long datasets/1_10_Mortality_survey-start_pc_survey_sc-consented_pc_sc-start_5_years_pregnant_sc-child_died_repeat_sc.dta", replace

}

