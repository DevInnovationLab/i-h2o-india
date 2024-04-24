************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files

* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" | c(username)=="michellecherian" | c(username)== "asthavohra" | c(username)== "Archi Gupta" {
cd "${DataRaw}"
do "${Do_lab}import_India_ILC_Endline_Census.do"
save "${DataRaw}1_8_Endline_Census.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-accompaniment-survey_member_names.do"
save "${DataRaw}1_8_Endline_Census-accompaniment-survey_member_names.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.do"
save "${DataRaw}1_8_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_all.do"
save "${DataRaw}1_8_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta", replace

do "${Do_lab}import_India_ILC_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.do"
save "${DataRaw}1_8_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.do"
save "${DataRaw}1_8_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.do"
save "${DataRaw}1_8_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.do"
save "${DataRaw}1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.do"
save "${DataRaw}1_8_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-wash_access-water_treatment-treat_resp_list.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-wash_access-water_treatment-treat_resp_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-wash_access-water_sources-water_sec_list.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-wash_access-water_sources-water_sec_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-wash_access-burden_of_water_collection_and_treatment-people_prim_list.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-wash_access-burden_of_water_collection_and_treatment-people_prim_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-N_med_seek_lp_all.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-N_HH_member_names_loop.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-Cen_med_seek_lp_all.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.do"
save "${DataRaw}1_8_Endline_Census-Household_available-survey_start-consented-Cen_HH_member_names_loop.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-N_child_followup.do"
save "${DataRaw}1_8_Endline_Census-Household_available-N_child_followup.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-N_CBW_followup.do"
save "${DataRaw}1_8_Endline_Census-Household_available-N_CBW_followup.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-Cen_child_followup.do"
save "${DataRaw}1_8_Endline_Census-Household_available-Cen_child_followup.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Household_available-Cen_CBW_followup.do"
save "${DataRaw}1_8_Endline_Census-Household_available-Cen_CBW_followup.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.do"
save "${DataRaw}1_8_Endline_Census-Cen_start_u5child_nonull-Cen_caregiver_present-Cen_sought_med_care_U5-Cen_med_visits_not0_U5-Cen_prvdrs_exp_loop_U5.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.do"
save "${DataRaw}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_start_5_years_pregnant-Cen_child_died_repeat.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.do"
save "${DataRaw}1_8_Endline_Census-Cen_start_survey_nonull-Cen_start_survey_CBW-Cen_CBW_yes_consent-Cen_sought_med_care_CBW-Cen_med_visits_not0_CBW-Cen_prvdrs_exp_loop_CBW.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.do"
save "${DataRaw}1_8_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.do"
save "${DataRaw}1_8_Endline_Census-Cen_prvdrs_notnull_U5-Cen_tests_exp_loop_U5.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.do"
save "${DataRaw}1_8_Endline_Census-Cen_prvdrs_notnull_CBW-Cen_tests_exp_loop_CBW.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.do"
save "${DataRaw}1_8_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", replace

}


* Windows User
else if c(username) == "cueva" | c(username) == "ABC"   {

do   "${Do_lab}1_0_1_label_w.do"
save "${DataRaw}1. Contact details.dta", replace
}
