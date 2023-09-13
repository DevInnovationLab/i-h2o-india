************************************
* Importing and adding STATA label *
************************************
* Sele note: To run smoothly, the data must be downloaded with the same computer that is running the labels of the do files

* STATA User
if c(username)      == "akitokamei" | c(username)=="MI" {
do "${Do_lab}import_india_ilc_pilot_census.do"
save "${DataRaw}1_1_Census.dta", replace

do "${Do_lab}import_india_ilc_pilot_followup_survey.do"
save "${DataRaw}1_2_Followup.dta", replace
}

* Windows User
else if c(username) == "cueva" | c(username) == "ABC"   {

do   "${Do_lab}1_0_1_label_w.do"
save "${DataRaw}1. Contact details.dta", replace
}
