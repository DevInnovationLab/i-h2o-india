************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files
* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" | c(username)=="michellecherian" | c(username)== "asthavohra" | c(username)== "Archi Gupta" {
cd "${DataRaw}"
clear
set maxvar 30000
do "${Do_lab}import_India_ILC_Endline_Census_Revisit.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census_revisit.dta", replace

//accomapniment
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-accompaniment-survey_member_names.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-accompaniment-survey_member_names.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_u5child_start_eligible-N_caregiver_present-N_sought_med_care_U5-N_med_visits_not0_U5-N_prvdrs_exp_loop_U5.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_all-N_tests_exp_loop_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_prvdrs_notnull_all-N_tests_exp_loop_alldta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_prvdrs_notnull_U5-N_tests_exp_loop_U5.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_prvdrs_notnull_CBW-N_tests_exp_loop_CBW.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_med_notnull_all-N_prvidr_exp_lp_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_med_notnull_all-N_prvidr_exp_lp_all.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_start_5_years_pregnant-N_child_died_repeat.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-N_CBW_start_eligible-N_start_survey_CBW-N_CBW_yes_consent-N_sought_med_care_CBW-N_med_visits_not0_CBW-N_prvdrs_exp_loop_CBW.dta", replace

//HH AVASILABLE DATASETS
//here the change from main endline census is that it has WASH_applicable as an extra field
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_treatment-treat_resp_list.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_treatment-treat_resp_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_sources-water_sec_list.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-wash_access-water_sources-water_sec_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-wash_access-burden_of_water_collection_and_treatment-people_prim_list.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-consented-wash_access-burden_of_water_collection_and_treatment-people_prim_list.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-N_med_seek_lp_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-N_med_seek_lp_all.dta", replace


do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-N_HH_member_names_loop.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-Cen_med_seek_lp_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_med_seek_lp_all.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-WASH_applicable_start-survey_start-consented-Cen_HH_member_names_loop.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-N_child_followup.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_child_followup.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-N_CBW_followup.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-N_CBW_followup.dta", replace

//the dataset below is similar to main endline dataaset called Cen_child_followup.dta
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-comb_child_followup.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_child_followup.dta", replace

//the dataset below is similar to main endline dataaset called Cen_CBW_followup.dta
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Household_available-comb_CBW_followup.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Household_available-comb_CBW_followup.dta", replace

//the dataset below is comparaable with the main endline dataset but with a Cen prefix
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_start_u5child_nonull-comb_caregiver_present-comb_sought_med_care_U5-comb_med_visits_not0_U5-comb_prvdrs_exp_loop_U5.dta", replace

//mortality dataset
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_start_5_years_pregnant-comb_child_died_repeat.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_start_5_years_pregnant-comb_child_died_repeat.dta", replace

//I have to remove the prefix "import_India_ILC_" from this because the path became too long and exceeded windows limit. It is possible that mac users don't face this problem but to run it smoothly I couldn't remove anything else because of the name resonating with endline main census file   
//Archi to Mac Users- Please check Akito, Jeremy and Niharika if this is working for you. 
do "${Do_lab}Endline_Census_Revisit-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_sought_med_care_CBW-comb_med_visits_not0_CBW-comb_prvdrs_exp_loop_CBW.do"

save"${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_start_survey_nonull-comb_start_survey_CBW-comb_CBW_yes_consent-comb_sought_med_care_CBW-comb_med_visits_not0_CBW-comb_prvdrs_exp_loop_CBW.dta", replace

//Archi- There is a Cen variable in the endline re-visit survey because in the main respondent section we ask about health of the non criteria members and for that we couldn't chnage variable names to comb so that is why you would see occurence of N and Cen prefix 
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Cen_prvdrs_notnull_all-Cen_tests_exp_loop_all.dta", replace

//here Cen gets replaced by comb_
do "${Do_lab}import_India_ILC_Endline_Census_Revisit-comb_prvdrs_notnull_U5-comb_tests_exp_loop_U5.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_prvdrs_notnull_U5-comb_tests_exp_loop_U5.dta", replace

//here Cen gets replaced by comb_

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-comb_prvdrs_notnull_CBW-comb_tests_exp_loop_CBW.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-comb_prvdrs_notnull_CBW-comb_tests_exp_loop_CBW.dta", replace

do "${Do_lab}import_India_ILC_Endline_Census_Revisit-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.do"
save "${DataRaw}1_9_Endline_Revisit/1_9_Endline_Census-Cen_med_notnull_all-Cen_prvdrs_exp_lp_all.dta", replace

}


/* Windows User
else if c(username) == "cueva" | c(username) == "ABC"   {

do   "${Do_lab}1_0_1_label_w.do"
save "${DataRaw}1. Contact details.dta", replace
}*/

