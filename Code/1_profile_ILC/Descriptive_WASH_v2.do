
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Descriptive template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
*** Using the cleaned endline dataset 

/***************************************************************

What all to include in the table from WASH sources
***************************
1. Primary Water sources:
****************************
a) Using govt. taps as primary drinking water 
b) Do your youngest children drink from the same water source as the household’s primary drinking water source i.e (${primary_water_label}) ?
c) Using govt. taps as the primary drinking water source for your youngest children
d) Do pregnant women drink from the same water source as the household’s primary drinking water source i.e (${primary_water_label}) ?
e) Using govt. taps as the primary drinking water source for your pregnant women?
f)Using govt. taps as secondary drinking water 
g) In the past week, how much of your drinking water came from your primary drinking water source: (${primary_water_label})?

***************************
2. Secondary Water sources:
****************************
a) In the past month, did your household use any sources of water for drinking besides ${primary_water_label}?
b)In the past month, what other water sources has your household used for drinking?
c)In what circumstances do you collect drinking water from these other water sources?
d)What is the most used secondary water source among these sources for drinking purpose?
e)Generally, when do you collect water for drinking from these other/secondary water sources?

**********************
3. Water Treatment
*************************

Water Treatment - General
In the last one month, did your household do anything extra to the drinking water (${primary_water_label} ) to make it safe before drinking it?
For the water that is currently stored in the household, did you do anything extra to the drinking water to make it safe for drinking treated? (This is for both primary and secondary source)
What do you do to the water from the primary source (${primary_water_label}) to make it safe for drinking?
If Other, please specify:
When do you make the water from your primary drinking water source (${primary_water_label}) safe before drinking it?
If Other, please specify:
In the past 2 weeks, have you ever decided not to treat your water because you didn’t have enough time?
How often do you make the water currently stored at home safe for drinking?
If Other, please specify:
Water Treatment - U5
Do you ever do anything to the water for your youngest children to make it safe for drinking?
What do you do to the water for your youngest children (children under 5) to make it safe for drinking?
If Other, please specify:
For your youngest children, when do you make the water safe before they drink it?
If Other, please specify: 
Do you treat the water before drinking in your household?

***************************************************************/


use "${DataTemp}U5_Child_Endline_Census.dta", clear
drop if comb_child_comb_name_label== ""
keep comb_child_comb_name_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence comb_child_comb_caregiver_label unique_id Cen_Type

split comb_child_comb_name_label, generate(common_u5_names) parse("111")
replace comb_child_comb_name_label = common_u5_names2 if common_u5_names2 != ""

//here CEn_Type = 5 means these are entries from new rosters and Cen_Type = 4 means children name from baseline census 
tab Cen_Type
/*tab Cen_Type

	Cen_Type	Freq.	Percent	Cum.
				
	4	977	76.15	76.15
	5	306	23.85	100.00
				
	Total	1,283	100.00 */
gen total_U5_kids = 1
bys unique_id: gen Num=_n
drop common_u5_names1 common_u5_names2

rename comb_child_comb_name_label U5_Child_label
rename comb_child_comb_caregiver_label U5_caregiver_label
reshape wide U5_Child_label comb_combchild_status comb_combchild_index comb_child_caregiver_present comb_child_care_pres_oth comb_child_caregiver_name comb_child_residence U5_caregiver_label Cen_Type, i(unique_id) j(Num)
drop if unique_id=="30501107052" //dropping the obs FOR NOW as the respondent in this case is not a member of the HH  


save "${DataTemp}U5_Child_Endline_Census_for_merge.dta", replace

use "${DataFinal}0_Master_HHLevel.dta", clear

merge 1:1 unique_id using "${DataTemp}U5_Child_Endline_Census_for_merge.dta"

replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Balti dho kar rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bartan Saf"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bartan saf"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bartan saph"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Basana sapha"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Botol saf"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Botoll saf"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Bottal ,Handi safa,or cover karte hai,"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bottal clean"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bottal safa karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bottal, Handi safa karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bottle saf karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Bottle saf karte hain"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean  tha container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean  untensil"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean containers"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Clean containers and cover the contai.."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Clean tha containe, cover the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean tha container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Clean tha container cover the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Wash the container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Wash container,pani ghorei rakhanti"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Wash container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Safkarke cover karke rakhaten hen"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Patra saf karte hen"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Patra saf karke rakhate hen"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Patra saf karke cover karke rakhete hen"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Patra saf karke cover karke rakhate hen"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Patra ko cover karke rakhaten hen"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Patra cover karke rakhaten hen"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Patra Saf karke rakhate hen"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Pani ko Dhankte hai"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Pani dhankte hai"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Pani Ko dhankte"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Pani Ko dhak kar rekte he."
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Pani Ko cover karke  rakte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi, bottal safa karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi safkarte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi safkarke rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi safa karte hai"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi safa karte cover karte hai"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi safa karte Pani Ko dhankte hai"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi safa cover karte hai"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi safa ,cover karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hein"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clean untensil"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleaning Utensils"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleaning utensils"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleansing the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clin contenor"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Clin the contenor"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cover  and clean the container,"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cover and clean the container"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Cover karke rakhaten hen"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Cover karke rakhaten hen Patra ko"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Cover the container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cover the container clean the container"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Covered the container"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Covered the pot"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Covered the water pot"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dabba dhote hai"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Dhak kar rakte he"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Dhak kar rakte he."
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Dhak kar raktehe."
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Dhak ke rakhte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hei"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hain"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi saf karte hai,dhak k rakhte hei"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hain"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi ku dhoiki rakhuchanti"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi ko saf karte hei"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi ko dhak ke rakhte hein"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi ko dhak ke rakhte hei"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi ko dhak kar rakhte hein"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Handi ko dhak k rakhte hei"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Handi ko dhak k rakhte hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi dhote he."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi dhote he or dhak ke rakte he."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi dhote he or dhak kar rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi dhokar rakte te."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi dhokar pani rakta he."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi dhokar dhak kar rakte he."
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Handi dhak k rakhte hei"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi clean karke rakh rhe hai"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi Dhote he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dhokar kar dhaka rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dhokar dhak kar rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dhakrak rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dhakkar rakte he."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Dhakkar rakte he"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Dhak ke rakhte hai, wash container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Dhak ke rakhte hai and wash container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleansing the vessel's before drinking"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi saf karte hei,dhak k rakhte hei"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Paniku ghorei rakhanti, wash container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Clean containers and cover the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleansing the vessel's before collecting water"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Cleansing the container before collecting water"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Clean tha container, cover the container"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Wash water container before storage water."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Wash and cover water container before storage water."
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cover the container, clean the container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Patra saf karke cover karke rakhaten hen"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hei"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi safa karte hai Pani Ko dhankte hai"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Handi ko saf karte hei,dhak k rakhte hei"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Wo pani main kuch nehin jaye is liye odh ke rakhte hain"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cover the container, clean tha container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Cleansing the vessel's before collecting water and cover the container"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Wash container,pani ki ghoreiki rakhuchhanti"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Wash container before storage water."
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Wash water container before storage water"
replace R_E_water_treat_oth = "Clean container and cover the container" if R_E_water_treat_oth == "Patra saf karke cover karke rakheten hen"
replace R_E_water_treat_oth = "Clean container" if R_E_water_treat_oth == "Handi saf karte hei, bottle saf karte hai"

//there is a separate option for bleaching so doesn't make sense to put this in others 
replace R_E_water_treat_type_4 = "1" if R_E_water_treat_oth == "Cover the container , bleaching"
replace R_E_water_treat_oth = "cover the container" if R_E_water_treat_oth == "Cover the container , bleaching"

//tank cleaning is not an applicable treatment method
replace R_E_water_treat_type = "3" if R_E_water_treat_oth == "Tank cleaning" & R_E_water_treat_type == "3 -77"
replace R_E_water_treat_oth = "" if R_E_water_treat_oth == "Tank cleaning" 

//tank cleaning is not an applicable treatment method
replace R_E_water_treat_type = "4" if R_E_water_treat_oth == "Tanki wash" & R_E_water_treat_type == "4 -77"
replace R_E_water_treat_oth = "" if R_E_water_treat_oth == "Tanki wash" 



//50401117020 - unique case for water treatment 

/*Surveyor incorrectly wrote that household doesn't do treatment bu marked actual values in all other values like 
R_E_water_treat R_E_water_treat_type R_E_water_treat_freq R_E_water_treat_freq_* R_E_not_treat_tim

If the HH doesn't do treatment then these questions are not applicable so I did a couple of replacemenst to replacement it with missing

*/

replace R_E_water_treat = "0" if R_E_water_treat_oth == "Kuchbi nei karrehen"

ds R_E_water_treat_type_*  R_E_water_treat_type R_E_water_treat_freq R_E_water_treat_freq_* R_E_not_treat_tim
foreach var of varlist `r(varlist)'{
replace `var' = "" if R_E_water_treat_oth == "Kuchbi nei karrehen" & unique_id == "50401117020" 
}

replace R_E_water_treat_oth = "" if R_E_water_treat_oth == "Kuchbi nei karrehen" 


br R_E_water_treat R_E_water_treat_type R_E_water_treat_oth  R_E_water_treat_type_* R_E_water_treat_freq R_E_water_treat_freq_* R_E_not_treat_tim if R_E_water_treat_oth == "Kuchbi nei karrehen" & unique_id == "50401117020" 


//generating a variable that shows indirect water treatmet methods because in endline these treatment methods have been extensively reported 
gen R_E_C_indirect_treatment = .
//plz note that 1 here represents also those cases where indirect treatment might have been used with other treatment methods
replace R_E_C_indirect_treatment = 1 if R_E_water_treat_type__77 == "1" & (R_E_water_treat_oth == "Clean container" | R_E_water_treat_oth == "Clean container and cover the container" | R_E_water_treat_oth == "cover the container" | R_E_water_treat_oth == "Cover the container, aqua")

gen R_E_C_only_indirect_treatment = .
replace R_E_C_only_indirect_treatment  = 1 if R_E_C_indirect_treatment  == 1 & R_E_water_treat_type_1 != "1" & R_E_water_treat_type_2 != "1" & R_E_water_treat_type_3 != "1" & R_E_water_treat_type_4 != "1" & R_E_water_treat_type_999 != "1"


//finding the case of baseline for same variable 

//The IDs are below all those cases where treatment actually wans't performed but surveyor still went ahead and said yes to the screening variable 

//10101111021
replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "For 1month tank cleaning"

ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_*
 
foreach var of varlist `r(varlist)'{
replace `var' = . if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021" 
}

ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
foreach var of varlist `r(varlist)'{
replace `var' = "" if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021" 
}

replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "For 1month tank cleaning" & unique_id == "10101111021"  


*******************************************************
//20201113035
replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "Kichi karunahanti" 

ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_*
 
foreach var of varlist `r(varlist)'{
replace `var' = . if R_Cen_a16_water_treat_oth == "Kichi karunahanti" & unique_id == "20201113035" 
}

ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
foreach var of varlist `r(varlist)'{
replace `var' = "" if R_Cen_a16_water_treat_oth == "Kichi karunahanti" & unique_id == "20201113035" 
}

replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "Kichi karunahanti" & unique_id == "20201113035" 

*******************************************************
//40201113009
replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "Kichi karanti nahi" 

ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_*
 
foreach var of varlist `r(varlist)'{
replace `var' = . if R_Cen_a16_water_treat_oth == "Kichi karanti nahi" & unique_id == "40201113009" 
}

ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
foreach var of varlist `r(varlist)'{
replace `var' = "" if R_Cen_a16_water_treat_oth == "Kichi karanti nahi" & unique_id == "40201113009" 
}

replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "Kichi karanti nahi" & unique_id == "40201113009" 

**********************************************************
//50301105017
replace R_Cen_a16_water_treat = 0 if R_Cen_a16_water_treat_oth == "Pani clear thauchhi" 

ds  R_Cen_a16_water_treat_type_*  R_Cen_a16_water_treat_freq_*
 
foreach var of varlist `r(varlist)'{
replace `var' = . if R_Cen_a16_water_treat_oth == "Pani clear thauchhi" & unique_id == "50301105017" 
}

ds R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_type
foreach var of varlist `r(varlist)'{
replace `var' = "" if R_Cen_a16_water_treat_oth == "Pani clear thauchhi" & unique_id == "50301105017" 
}

replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "Pani clear thauchhi" & unique_id == "50301105017" 


********************************************************8

replace R_Cen_a16_water_treat_oth = "cover the container" if R_Cen_a16_water_treat_oth ==  "Ghodeiki rakhuchnti" 
//generating a variable that shows indirect water treatmet methods because in endline these treatment methods have been extensively reported 
gen R_Cen_C_indirect_treatment = .
//plz note that 1 here represents also those cases where indirect treatment might have been used with other treatment methods
replace R_Cen_C_indirect_treatment = 1 if R_Cen_a16_water_treat_oth == "cover the container" 

gen R_Cen_C_only_indirect_treatment = .
replace R_Cen_C_only_indirect_treatment  = 1 if R_Cen_C_indirect_treatment == 1 & R_Cen_a16_water_treat_type_1 != 1  & R_Cen_a16_water_treat_type_2 != 1  & R_Cen_a16_water_treat_type_3 != 1  & R_Cen_a16_water_treat_type_4 != 1  &  R_Cen_a16_water_treat_type_999 != 1  


********************************************************\\\

//case of UID - 50401117029

//this is the case where they tie cloth to the pipe so there is already an option for this so doesn't make sens eto includ ein others so I remove dit from other and selected first option

replace R_Cen_a16_water_treat_type_1 = 1 if R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" 

replace R_Cen_a16_water_treat_type = "1" if R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" 

replace R_Cen_a16_water_treat_type__77 = 0 if R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" 

replace R_Cen_a16_water_treat_oth = "" if R_Cen_a16_water_treat_oth == "Pile re kapada bandhi Rakhi chhanti" 


/**************************************************************
CLEANING TREATMENT VARIABLLE FOR KIDS 
***************************************************************/

//ENDLINE

replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Balti,handi safa karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash container"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bartan safa karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottal pe bharte he"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottal saf karte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottal safa karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottal,glass saf karke pani dete hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle dho kar dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle dhokar dete he"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle dhokar rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle dhote he pani bhar ke dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf kar ke dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf karke dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf karte hain"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf karte hei"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottol dhote he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottol pe saf karke pani rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottotle saf kar ke dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Clean tha container"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Clean tha container,cover the container"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Clean the container"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Clean untensil"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Cleaning Utensils"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Cleansing her water bottle"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Cleansing the water bottle"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Clin contenor"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Cover karke rakhete hen"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Cover the container"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Cover water odh ke rakhte hain pani ko"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Dhak ke rakhte hai"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Dhak ke rakhte hai, wash container"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Dhakkan laga ke rakhte hain"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Dhakkar rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glash saf kartehe."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass clean"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass dhote he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass dhote he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass saf arke pani dete hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass saf karke dete he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass saf karke pani dete hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass saf karte hei"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Glass, bottle saf karte hai"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Handi dhak k rakhte hei"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi dhokar rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi dhote he"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi dhote he."
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Handi ko dho kar dhak kar rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi saf kar ke rakte he."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi saf karte hei"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Handi saf karte hei, dhan k rakhte hei"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi safa"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Handi safa cover karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi safa karte hai"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Pani ghorauchhanti,wash container"
replace R_E_water_treat_kids_oth = "cover the container" if R_E_water_treat_kids_oth == "Pani ko Dhankte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Patra saf karke rakhate hen"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Patra saf karte hen"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Wash container and Dhak ke rakhte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash the container"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash water bottle before storage water."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash water container before storage."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash water container before storage water."
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Wash and cover water container before storage water."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash water container before storage water"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Wash water container before storage water"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi saf karte hei , bottle saf karte hai"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Glass saf karke pani dete hai pani ko dhankte"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Cover the container, clean tha container"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Cleansing the vessel's before collecting water"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Cover the container, clean tha container"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Wash container, dhak ke pani ko rakhte hai"
replace R_E_water_treat_kids_oth = "Clean container and cover the container" if R_E_water_treat_kids_oth == "Wash container before storage water."
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Bottle saf karte hain, glass saf karte hai"
replace R_E_water_treat_kids_oth = "Clean container" if R_E_water_treat_kids_oth == "Handi saf karte hain"



gen R_E_C_indirect_treatment_kids = .
//plz note that 1 here represents also those cases where indirect treatment might have been used with other treatment methods
replace R_E_C_indirect_treatment_kids = 1 if R_E_water_treat_kids_type__77 == "1" & (R_E_water_treat_kids_oth == "Clean container" | R_E_water_treat_kids_oth == "Clean container and cover the container" | R_E_water_treat_kids_oth == "cover the container" )

gen R_E_C_only_indirect_treat_kids = .
replace R_E_C_only_indirect_treat_kids = 1 if R_E_C_indirect_treatment_kids  == 1 & R_E_water_treat_kids_type_1 != "1" & R_E_water_treat_kids_type_2 != "1" & R_E_water_treat_kids_type_3 != "1" & R_E_water_treat_kids_type_4 != "1" & R_E_water_treat_kids_type_999 != "1"

//BASELINE

***********************************************************
//Case of UID - 20201113077

//they don't do treatment for kids so I replaced yes with no to U5 kids treatment

replace R_Cen_a17_water_treat_kids = 0 if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti"

ds R_Cen_a17_water_treat_kids  R_Cen_water_treat_kids_type_*  R_Cen_a17_treat_kids_freq_*

foreach var of varlist `r(varlist)'{
replace `var' = . if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti"
}

ds R_Cen_water_treat_kids_type R_Cen_a17_treat_kids_freq

foreach var of varlist `r(varlist)'{
replace `var' = "" if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti"
}

replace R_Cen_water_treat_kids_oth = "" if unique_id == "20201113077" & R_Cen_water_treat_kids_oth == "Kichi karunahanti"

//generating a variable that shows indirect water treatmet methods because in endline these treatment methods have been extensively reported 
gen R_Cen_C_indirect_treatment_kids = 0

gen R_Cen_C_only_indirect_treat_kids = 0





*****************************************************

//finding number of U5 kids for baseline vs endline 
/* U5 Kids */
ds Cen_Type*
foreach var of varlist `r(varlist)'{
clonevar Cl_`var' = `var'
}

egen temp_group = group(unique_id)
ds Cl_*
foreach var of varlist `r(varlist)'{
replace `var' = 1 if `var' == 4
replace `var' = 0 if `var' == 5
}
egen R_Cen_u5_kids_total = rowtotal(Cl_Cen_Type*)


drop Cl_*
ds Cen_Type*
foreach var of varlist `r(varlist)'{
clonevar Cl_`var' = `var'
}

drop temp_group
egen temp_group = group(unique_id)
ds Cl_*
foreach var of varlist `r(varlist)'{
replace `var' = 1 if `var' == 5
replace `var' = 0 if `var' == 4
}
egen R_E_u5_kids_total = rowtotal(Cl_Cen_Type*)


//finding HH level U5 kids i.e. what are the number of HH that have any U5 kids
gen R_Cen_HH_level_U5 = .
replace R_Cen_HH_level_U5 = 1 if R_Cen_u5_kids_total != 0
gen R_E_HH_level_U5 = .
replace R_E_HH_level_U5 = 1 if R_E_u5_kids_total != 0
//all the baseline U5 kids are going to be included in the endline sample that is why we need to replace all the values with 1 where R_Cen_HH_level_U5 is 1 

replace R_E_HH_level_U5 = 1 if R_Cen_HH_level_U5 == 1





//HH level availability stats 
// Endline : 
gen gender_Endline = .
forvalues i = 1/20{
cap replace gender_Endline = 1 if R_E_cen_resp_name == "`i'" & R_Cen_a4_hhmember_gender_`i' == 2
cap replace gender_Endline = 0 if R_E_cen_resp_name == "`i'" & R_Cen_a4_hhmember_gender_`i' == 1

}

br R_E_cen_resp_name R_E_cen_resp_label  R_Cen_a1_resp_name R_Cen_a4_hhmember_gender_* gender_Endline if gender_Endline == 0




*Recoding the 'other' response as '77' (for creation of indicator variables in lines 21 to 29)
foreach i in R_Cen_a12_water_source_prim R_E_water_source_prim R_Cen_a17_water_source_kids R_E_water_source_kids R_Cen_water_prim_source_kids R_E_water_prim_source_kids R_E_water_source_preg R_E_water_prim_source_preg R_E_quant R_E_water_sec_yn R_Cen_a13_water_sec_yn R_Cen_a15_water_sec_freq R_Cen_a16_water_treat  R_E_water_treat R_Cen_a16_stored_treat R_E_water_stored R_E_not_treat_tim R_Cen_a16_stored_treat_freq R_Cen_a17_water_treat_kids R_E_water_treat_kids  {
    destring `i', replace
	replace `i'= 77 if `i'== -77
	replace `i' = 98 if `i' == -98
	replace `i' = 999 if `i' == -99 | `i' == 99
}


keep unique_id R_Cen_a12_water_source_prim R_E_water_source_prim R_Cen_a17_water_source_kids R_E_water_source_kids R_Cen_water_prim_source_kids R_E_water_prim_source_kids R_E_water_source_preg R_E_water_prim_source_preg R_E_quant R_Cen_a13_water_sec_yn R_E_water_sec_yn R_Cen_a13_water_source_sec R_Cen_a13_water_source_sec_1 R_Cen_a13_water_source_sec_2 R_Cen_a13_water_source_sec_3 R_Cen_a13_water_source_sec_4 R_Cen_a13_water_source_sec_5 R_Cen_a13_water_source_sec_6 R_Cen_a13_water_source_sec_7 R_Cen_a13_water_source_sec_8 R_Cen_a13_water_source_sec__77 R_E_water_source_sec R_E_water_source_sec_1 R_E_water_source_sec_2 R_E_water_source_sec_3 R_E_water_source_sec_4 R_E_water_source_sec_5 R_E_water_source_sec_6 R_E_water_source_sec_7 R_E_water_source_sec_8 R_E_water_source_sec_9 R_E_water_source_sec_10 R_E_water_source_sec__77 R_Cen_a14_sec_source_reason R_Cen_a14_sec_source_reason_1 R_Cen_a14_sec_source_reason_2 R_Cen_a14_sec_source_reason_3 R_Cen_a14_sec_source_reason_4 R_Cen_a14_sec_source_reason_5 R_Cen_a14_sec_source_reason_6 R_Cen_a14_sec_source_reason_7 R_Cen_a14_sec_source_reason__77 R_Cen_a14_sec_source_reason_999 R_E_sec_source_reason R_E_sec_source_reason_1 R_E_sec_source_reason_2 R_E_sec_source_reason_3 R_E_sec_source_reason_4 R_E_sec_source_reason_5 R_E_sec_source_reason_6 R_E_sec_source_reason_7 R_E_sec_source_reason__77 R_E_sec_source_reason_999 R_E_sec_source_reason_oth R_E_water_source_main_sec R_Cen_a15_water_sec_freq R_E_water_sec_freq R_Cen_a16_water_treat R_E_water_treat R_Cen_a16_stored_treat R_E_water_stored R_Cen_a16_water_treat_type R_Cen_a16_water_treat_type_1 R_Cen_a16_water_treat_type_2 R_Cen_a16_water_treat_type_3 R_Cen_a16_water_treat_type_4 R_Cen_a16_water_treat_type_999 R_Cen_a16_water_treat_type__77 R_E_water_treat_type R_E_water_treat_type_1 R_E_water_treat_type_2 R_E_water_treat_type_3 R_E_water_treat_type_4 R_E_water_treat_type_999 R_E_water_treat_type__77 R_Cen_a16_water_treat_freq R_Cen_a16_water_treat_freq_1 R_Cen_a16_water_treat_freq_2 R_Cen_a16_water_treat_freq_3 R_Cen_a16_water_treat_freq_4 R_Cen_a16_water_treat_freq_5 R_Cen_a16_water_treat_freq_6 R_Cen_a16_water_treat_freq__77 R_E_water_treat_freq R_E_water_treat_freq_1 R_E_water_treat_freq_2 R_E_water_treat_freq_3 R_E_water_treat_freq_4 R_E_water_treat_freq_5 R_E_water_treat_freq_6 R_E_water_treat_freq__77 R_E_not_treat_tim R_Cen_a16_stored_treat_freq R_Cen_a17_water_treat_kids R_E_water_treat_kids R_Cen_water_treat_kids_type R_Cen_water_treat_kids_type_1 R_Cen_water_treat_kids_type_2 R_Cen_water_treat_kids_type_3 R_Cen_water_treat_kids_type_4 R_Cen_water_treat_kids_type_999 R_Cen_water_treat_kids_type__77 R_E_water_treat_kids_type R_E_water_treat_kids_type_1 R_E_water_treat_kids_type_2 R_E_water_treat_kids_type_3 R_E_water_treat_kids_type_4 R_E_water_treat_kids_type_999 R_E_water_treat_kids_type__77 R_Cen_a17_treat_kids_freq R_Cen_a17_treat_kids_freq_1 R_Cen_a17_treat_kids_freq_2 R_Cen_a17_treat_kids_freq_3 R_Cen_a17_treat_kids_freq_4 R_Cen_a17_treat_kids_freq_5 R_Cen_a17_treat_kids_freq_6 R_Cen_a17_treat_kids_freq__77 R_E_treat_kids_freq R_E_treat_kids_freq_1 R_E_treat_kids_freq_2 R_E_treat_kids_freq_3 R_E_treat_kids_freq_4 R_E_treat_kids_freq_5 R_E_treat_kids_freq_6 R_E_treat_kids_freq__77 R_Cen_consent R_E_consent R_E_quant Treat_V village R_Cen_hamlet_name  R_E_key R_Cen_u5_kids_total R_E_u5_kids_total R_Cen_HH_level_U5 R_E_HH_level_U5 R_E_C_indirect_treatment R_Cen_C_indirect_treatment R_E_C_only_indirect_treatment  R_Cen_C_only_indirect_treatment R_Cen_a16_water_treat_oth R_Cen_a18_water_treat_oth R_E_water_treat_oth R_Cen_water_treat_kids_oth R_E_water_treat_kids_oth R_E_C_indirect_treatment_kids  R_E_C_only_indirect_treat_kids R_Cen_C_indirect_treatment_kids R_Cen_C_only_indirect_treat_kids 


/*************************************************************
//VARIABLE NAMES THAT NEED TO BE CHNAGED 
**************************************************************/

rename R_Cen_a12_water_source_prim R_Cen_water_source_prim
rename R_Cen_a17_water_source_kids R_Cen_water_source_kids
rename R_Cen_a13_water_sec_yn R_Cen_water_sec_yn
rename R_Cen_a13_water_source_sec R_Cen_water_source_sec

forvalues i = 1/8{
cap rename R_Cen_a13_water_source_sec_`i' R_Cen_water_source_sec_`i'
}

rename R_Cen_a13_water_source_sec__77 R_Cen_water_source_sec__77 
rename R_Cen_a14_sec_source_reason R_Cen_sec_source_reason

forvalues i = 1/999{
cap rename R_Cen_a14_sec_source_reason_`i' R_Cen_sec_source_reason_`i'
}

rename R_Cen_a14_sec_source_reason__77 R_Cen_sec_source_reason__77

rename R_Cen_a16_water_treat R_Cen_water_treat

rename R_Cen_a16_stored_treat R_Cen_water_stored

rename R_Cen_a16_water_treat_type R_Cen_water_treat_type

forvalues i = 1/999{
cap rename R_Cen_a16_water_treat_type_`i' R_Cen_water_treat_type_`i'
}

rename  R_Cen_a16_water_treat_type__77 R_Cen_water_treat_type__77

rename R_Cen_a16_water_treat_freq R_Cen_water_treat_freq

forvalues i = 1/6{
cap rename R_Cen_a16_water_treat_freq_`i' R_Cen_water_treat_freq_`i'
}

rename R_Cen_a16_water_treat_freq__77 R_Cen_water_treat_freq__77


rename R_Cen_a17_water_treat_kids R_Cen_water_treat_kids


rename R_Cen_a17_treat_kids_freq R_Cen_treat_kids_freq


forvalues i = 1/6{
cap rename R_Cen_a17_treat_kids_freq_`i' R_Cen_treat_kids_freq_`i'
}

rename R_Cen_a17_treat_kids_freq__77 R_Cen_treat_kids_freq__77

rename R_Cen_a15_water_sec_freq R_Cen_water_sec_freq


rename R_Cen_a16_water_treat_oth  R_Cen_water_treat_oth


preserve

drop R_Cen_* 

renpfix R_E_

gen survey_type = "E" 

drop if consent != "1"

save "${DataTemp}Temp_RE.dta", replace 

restore

preserve

drop R_E_*

renpfix R_Cen_

gen survey_type = "C" 

drop if consent != 1

save "${DataTemp}Temp_Cen.dta", replace

restore

//making variable types uniform so that datasets can be appended easily



use "${DataTemp}Temp_RE.dta", clear
destring consent, replace
ds water_source_sec_* 
foreach var of varlist `r(varlist)'{
destring `var', replace
}
ds sec_source_reason_*
foreach var of varlist `r(varlist)'{
destring `var', replace
}
destring water_sec_freq , replace
ds water_treat_type_*
foreach var of varlist `r(varlist)'{
destring `var', replace
}
ds  water_treat_freq_*
foreach var of varlist `r(varlist)'{
destring `var', replace
}

ds water_treat_kids_type_*
foreach var of varlist `r(varlist)'{
destring `var', replace
}

ds treat_kids_freq_*
foreach var of varlist `r(varlist)'{
destring `var', replace
}

append using "${DataTemp}Temp_Cen.dta"

gen survey_type_num = .
replace survey_type_num = 0 if survey_type == "C"
replace survey_type_num = 1 if survey_type == "E"

label define water_source_prim_x 1 "JJM"  2 "Government provided community standpipe" 3	"Gram Panchayat/Other Community Standpipe (e.g. non-Basudha source)" ///
4 "Manual handpump" 5	"Covered dug well" 6 "Directly fetched by surface water"  7 "Uncovered dug well" 8 "Private Surface well" 9	"Borewell operated by electric pump" 10 "Non-JJM Household tap connections" 77 "Other"  
 
label values water_source_prim water_source_prim_x

label define water_prim_source_kids_x 1 "JJM"  2 "Government provided community standpipe" 3	"Gram Panchayat/Other Community Standpipe (e.g. non-Basudha source)" ///
4 "Manual handpump" 5	"Covered dug well" 6 "Directly fetched by surface water"  7 "Uncovered dug well" 8 "Private Surface well" 9	"Borewell operated by electric pump" 10 "Non-JJM Household tap connections" 77 "Other"  
 
label values water_prim_source_kids water_prim_source_kids_x
replace water_stored = 0 if water_stored == 2

label define water_stored_x 1 "Yes" 0 "No" 
label values water_stored water_stored_x



*Generating indicator variables for each unique value of variables specified in the loop
foreach v in water_source_prim water_source_kids water_prim_source_kids water_source_preg water_prim_source_preg quant water_sec_yn water_sec_freq water_treat water_stored a16_stored_treat_freq water_treat_kids not_treat_tim{
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


//this command shows that there is no such case where HH says that JJM isn't their primary source and they say that children drink from a different primary source and if that prim source is JJM 

//that is why I did replacement here because there was no constrain in the baseline census to take care of the same 

br  water_source_kids water_prim_source_kids water_source_prim  if  water_prim_source_kids == 1 & water_source_prim == 1 & water_source_kids == 0

replace water_source_kids = 1 if  water_prim_source_kids == 1 & water_source_prim == 1 & water_source_kids == 0

gen flag = .

replace flag = 1 if water_source_kids == 0 & water_prim_source_kids == water_source_prim

br survey_type water_source_prim  water_source_kids water_prim_source_kids if flag == 1

replace  water_source_kids = 1 if water_source_kids == 0 & water_prim_source_kids == water_source_prim


gen lastweekJJM = .
replace lastweekJJM = 1 if quant == 1 & water_source_prim == 1


//Youngest child primary water source being non-JJM but main HH source being JJM 
gen U5_nonjjm_water_source = .
replace U5_nonjjm_water_source  = 1 if water_source_prim_1 == 1 &  water_source_kids_0 == 1 & water_prim_source_kids_1 == 0

br U5_nonjjm_water_source water_source_prim water_source_kids water_prim_source_kids  if U5_nonjjm_water_source  == 1


//Youngest child primary water source being JJM but main HH source being non-JJM 	
gen U5_jjm_water_source = .
replace U5_jjm_water_source  = 1 if water_source_prim_1 != 1 &  water_source_kids_0 == 1 & water_prim_source_kids_1 == 1

br U5_jjm_water_source water_source_prim water_source_kids water_prim_source_kids  if U5_jjm_water_source  == 1


//JJM Treatment vars 
gen treat_JJM = .
replace treat_JJM = 1  if water_treat_1 == 1 & water_source_prim_1 == 1

gen bapuji = .

replace bapuji = 1 if hamlet_name == "Bapuji Nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Bapuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana Bapuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Bapuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana, Bapuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana Babuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana (bapuji nagar)" & village == 50301
replace bapuji = 1 if hamlet_name == "Bapujinagar ward no 4" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana(Bapuji nagar)" & village == 50301
replace bapuji = 1 if hamlet_name == "Babuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana,Bapuji nagar" & village == 50301
replace bapuji = 1 if hamlet_name == "Bapujinagar ward no 4," & village == 50301
replace bapuji = 1 if hamlet_name == "Karlakana Babuji nagar right side house" & village == 50301

br water_source_prim village hamlet_name if village == 50301 & bapuji == 1 & (water_source_prim == 1 | water_source_prim == 77)

replace water_source_prim = 77 if village == 50301 & bapuji == 1 & water_source_prim == 1 

/***************************************************************
//VARIABLE MANIPULATION (FOR MISSING VALUES)
****************************************************************/


//Using JJM as secondary source
replace water_source_sec_1 = 0 if  water_source_sec_1  == .

br water_source_kids HH_level_U5

replace water_source_kids_0 = 0 if water_source_kids_0 == .

//here missing values are because of the relevance
replace water_prim_source_kids_1 = 0 if water_prim_source_kids_1 == .


//add a variable how many U5 children are there 
//dont know and refused to answer as sepaarte category 




/***************************************************************GENERATING NEW VARIABLES TO MAKE SURE OPTIONS ARE CONSISTENT ACROSS BASELINE VS ENDLINE
***************************************************************/

/****************************************
//For primary sources

Archi- For this variable we don't have to generate a recoded variable because labeling solved the issue  

Reason: Changes made: few answer options added from FU1; changed text of options 1 and 2: 
Options in Baseline Census:
(1)Government provided household Taps (supply paani)
(2)Government provided community standpipe (part of JJM taps)
(3)Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
(4)Manual handpump
(5)Covered dug well
(6)Uncovered dug well
(7)Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel)
(8)Private Surface well
(-77)Other

All answer options are same in Baseline HH Survey except option 2 (Government provided community standpipe (connected to piped system, through Vasudha tank))

Answer options from Folllow up1 onwards: 
(1)Government provided household Taps (supply paani) connected to RWSS/Basudha/JJM tank
(2)Government provided community standpipe (connected to piped system, through Vasudha tank)
(3)Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
(4)Manual handpump
(5)Covered dug well
(6)Directly fetched by surface water (river/dam/lake/pond/stream/canal/irrigation channel
(7)Uncovered dug well
(8)Private Surface well
(9)Borewell operated by electric pump
(10)Household tap connections not connected to RWSS/Basudha/JJM tank
(-77)Other
******************************************/



/***************************************************************GENERATING RECODED VARIABLES WITH PREFIX C_ to create combined categories
***************************************************************/
/* water_source_prim
. tab water_source_prim

                      water_source_prim |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    JJM |      1,372       76.48       76.48
Government provided community standpipe |         20        1.11       77.59
Gram Panchayat/Other Community Standpip |         66        3.68       81.27
                        Manual handpump |        152        8.47       89.74
                       Covered dug well |          7        0.39       90.13
      Directly fetched by surface water |          5        0.28       90.41
                     Uncovered dug well |          1        0.06       90.47
                   Private Surface well |         25        1.39       91.86
     Borewell operated by electric pump |         72        4.01       95.88
                                  Other |         74        4.12      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,794      100.0
Here we will see that use percentage of Uncovered dug well is very low, surface water, covered dug well so we will put them in other categories 
							  
*/

//Recoding primary water source variable 
gen C_water_source_prim  = .
replace C_water_source_prim = 1 if water_source_prim == 1
replace C_water_source_prim = 2 if water_source_prim == 2
replace C_water_source_prim = 3 if water_source_prim == 3
replace C_water_source_prim = 4 if water_source_prim == 4
replace C_water_source_prim = 77 if water_source_prim == 8
replace C_water_source_prim = 77 if water_source_prim == 10
replace C_water_source_prim = 77 if water_source_prim == 5
replace C_water_source_prim = 77 if water_source_prim == 6
replace C_water_source_prim = 77 if water_source_prim == 7
replace C_water_source_prim = 77 if water_source_prim == 77
replace C_water_source_prim = 77 if water_source_prim == 9


*Generating indicator variables for each unique value of variables specified in the loop
foreach v in C_water_source_prim{
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


//recodidng secondary water source variable 
*water_source_sec_5 water_source_sec_6 water_source_sec_7 water_source_sec_8 water_source_sec_9 water_source_sec_10 water_source_sec__77

gen C_water_source_sec__77 = .
replace C_water_source_sec__77 = 1 if water_source_sec__77 == 1
replace C_water_source_sec__77 = 1 if water_source_sec_5  == 1
replace C_water_source_sec__77 = 1 if water_source_sec_6  == 1
replace C_water_source_sec__77 = 1 if water_source_sec_7  == 1
replace C_water_source_sec__77 = 1 if water_source_sec_10 == 1
replace C_water_source_sec__77 = 1 if water_source_sec_9 == 1
replace C_water_source_sec__77 = 0 if C_water_source_sec__77 == .
replace C_water_source_sec__77 = 1 if water_source_sec_8 == 1


gen C_water_source_sec_1 = .
replace C_water_source_sec_1 = 1 if water_source_sec_1 == 1
replace C_water_source_sec_1 = 0 if C_water_source_sec_1 == .
gen C_water_source_sec_2 = .
replace C_water_source_sec_2 = 1 if water_source_sec_2 == 1
replace C_water_source_sec_2 = 0 if C_water_source_sec_2 == .
gen C_water_source_sec_3 = .
replace C_water_source_sec_3 = 1 if water_source_sec_3 == 1
replace C_water_source_sec_3 = 0 if C_water_source_sec_3 == .
gen C_water_source_sec_4 = .
replace C_water_source_sec_4 = 1 if water_source_sec_4 == 1
replace C_water_source_sec_4 = 0 if C_water_source_sec_4 == .


//here we are tackling indirect water treatment variable because this shouldn't be counted twice like when presenting water treatment between baseline vs Endline this can make the compariosn noisy so we must remove cases of indirect treatment from both endline and baseline to show actual incrrse in this variable 
replace C_indirect_treatment = 0 if C_indirect_treatment == .


//PART A- removing indirect water treatment from main treatment variable for primary water source
***********************************************************
//water treatment
gen C_water_treat = .
//replace C_water_treat = 1 if  C_only_indirect_treatment != 1 &  water_treat == 1
replace C_water_treat = 1 if water_treat == 1
replace C_water_treat = 0 if water_treat == 0

//type of treatmet

gen C_water_treat_type__77 = .
//we are already including this in the indirect treatment method
replace C_water_treat_type__77 = 1 if water_treat_type__77 == 1 & (water_treat_oth != "Clean container" & water_treat_oth != "Clean container and cover the container" & water_treat_oth != "cover the container")
replace C_water_treat_type__77 = 0 if water_treat_type__77 == 0

//water treat fre
gen C_water_treat_freq = ""
replace C_water_treat_freq = water_treat_freq if C_only_indirect_treatment != 1  & water_treat_freq != ""


ds water_treat_freq_*
foreach var of varlist `r(varlist)'{
gen C_`var' = .
replace C_`var' = 1 if C_only_indirect_treatment != 1 & `var' == 1
replace C_`var' = 0 if `var' == 0

}

foreach v in C_water_treat C_indirect_treatment {
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}

	

ds water_stored_1 C_water_treat_0 C_water_treat_1  C_indirect_treatment_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 C_water_treat_type__77 water_treat_type_999 C_water_treat_freq_1 C_water_treat_freq_2 C_water_treat_freq_3 C_water_treat_freq_4 C_water_treat_freq_5 C_water_treat_freq_6 C_water_treat_freq__77

foreach var of varlist `r(varlist)'{
replace `var' = 0 if `var' == .
}
	
//C_water_source_prim_1 C_water_source_prim_2 C_water_source_prim_3 C_water_source_prim_4  C_water_source_prim_77  water_sec_yn_0 water_sec_yn_1 C_water_source_sec_1 C_water_source_sec_2 C_water_source_sec_3 C_water_source_sec_4 C_water_source_sec__77 sec_source_reason_1 sec_source_reason_2 sec_source_reason_3 sec_source_reason_4 sec_source_reason_5 sec_source_reason_6 sec_source_reason_7 sec_source_reason__77 sec_source_reason_999 water_sec_freq_1 water_sec_freq_2 water_sec_freq_3 water_sec_freq_4 water_sec_freq_5 water_sec_freq_6 water_sec_freq_8 water_sec_freq_999	


// PART B - removing indirect water treatment from main treatment variable for KIDS's primary source
***********************************************************

//type of treatmet

gen C_water_treat_kids__77 = .
//we are already including this in the indirect treatment method
replace C_water_treat_kids__77 = 1 if water_treat_kids_type__77 == 1 & (water_treat_kids_oth != "Clean container" & water_treat_kids_oth != "Clean container and cover the container" & water_treat_kids_oth != "cover the container")
replace C_water_treat_kids__77 = 0 if water_treat_kids_type__77 == 0

//water treat fre
gen C_treat_kids_freq = ""
replace C_treat_kids_freq = treat_kids_freq if C_only_indirect_treat_kids != 1  & treat_kids_freq != ""


ds treat_kids_freq_*
foreach var of varlist `r(varlist)'{
gen C_`var' = .
replace C_`var' = 1 if C_only_indirect_treat_kids != 1 & `var' == 1
replace C_`var' = 0 if `var' == 0

}

rename C_indirect_treatment_kids  C_indirect_treat_kids
foreach v in C_indirect_treat_kids {
	levelsof `v' //get the unique values of each variable
	foreach value in `r(levels)' { //Looping through each unique value of each variable
		//generating indicator variables
		gen     `v'_`value'=0 
		replace `v'_`value'=1 if `v'==`value' 
		replace `v'_`value'=. if `v'==.
		//labelling indicator variable with original variable's label and unique value
		label var `v'_`value' "`: label (`v') `value''"
	}
	}


ds water_stored_1 C_water_treat_0 C_water_treat_1  C_indirect_treatment_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 C_water_treat_type__77 water_treat_type_999 C_water_treat_freq_1 C_water_treat_freq_2 C_water_treat_freq_3 C_water_treat_freq_4 C_water_treat_freq_5 C_water_treat_freq_6 C_water_treat_freq__77

foreach var of varlist `r(varlist)'{
replace `var' = 0 if `var' == .
}

ds water_source_kids_1 water_source_kids_3 water_source_kids_4 water_source_kids_999 water_source_kids_98 water_prim_source_kids_1 water_prim_source_kids_4 water_prim_source_kids_8 water_prim_source_kids_77 water_treat_kids_0 water_treat_kids_98 water_treat_kids_999 water_treat_kids_1 C_indirect_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 C_water_treat_kids__77 water_treat_kids_type_999 C_treat_kids_freq_1 C_treat_kids_freq_2 C_treat_kids_freq_3 C_treat_kids_freq_4 C_treat_kids_freq_5 C_treat_kids_freq_6 C_treat_kids_freq__77 

foreach var of varlist `r(varlist)'{
replace `var' = 0 if `var' == .
}

	

*** Labelling the variables for use in descriptive stats table
label var C_water_source_prim_1 "JJM taps"
label var C_water_source_prim_2 "Govt. provided community standpipe"
label var C_water_source_prim_3 "Gram Panchayat/Other community standpipe"
label var C_water_source_prim_4 "Manual handpump"
label var C_water_source_prim_77 "Other" 
label var water_sec_yn_0 "Not using any secondary drinking water source"
label var water_sec_yn_1 "Using any secondary drinking water source:"
label var C_water_source_sec_1 "JJM tap"
label var C_water_source_sec_2 "Govt. provided community standpipe"
label var C_water_source_sec_3 "Gram Panchayat/Other community standpipe"
label var C_water_source_sec_4 "Manual handpump"
label var C_water_source_sec__77 "Other" 

label var u5_kids_total "Total U5 kids" 
label var water_source_kids_1 "U5 drinking from the same primary source"
label var water_source_kids_0 "U5 drinking from a different water source"
//check with NB
label var water_source_kids_3 "No U5 child present in the HH" 
label var water_source_kids_4 "U5 child is being breastfed exclusively"
label var water_source_kids_999 "Don't know"
label var water_source_kids_98 "Refused to answer" 
label var water_prim_source_kids_1 "JJM" 
label var water_prim_source_kids_4 "Manual handpump" 
label var water_prim_source_kids_8 "Private Surface well"
label var water_prim_source_kids_77 "Other"
label var U5_nonjjm_water_source "U5 children drinking from other primary sources(non-JJM)"
label var U5_jjm_water_source "U5 children drinking from JJM but not HH"
label var water_source_preg_1 "Pregnant women drinking from the same primary water source as HH"

label var water_treat_1 "Water treatment for primary source"

label var  water_stored_1 "Stored water treatment" 

label var water_treat_type_1 "Filter the water through a cloth or sieve" 
label var  water_treat_type_2 "Let the water stand before drinking" 
label var  water_treat_type_3 "Boil the water" 
label var  water_treat_type_4 "Add chlorine/ bleaching powder" 
label var C_water_treat_type__77 "Other" 
label var water_treat_type_999 "Don't know" 

label var C_water_treat_0 "Water treatment is not done" 
label var C_water_treat_1 "Water treatment is done"
label var C_water_treat_freq_1 "Always treat the water" 
label var C_water_treat_freq_2 "Treat the water in the summers" 
label var C_water_treat_freq_3 "Treat the water in the monsoons" 
label var C_water_treat_freq_4 "Treat the water in the winters" 
label var C_water_treat_freq_5 "Treat the water when kids/ old people fall sick" 
label var C_water_treat_freq_6 "Treat the water when it looks or smells dirty" 
label var C_water_treat_freq__77 "Other"
label var C_indirect_treatment_1 "Indirect treatment methods"

label var not_treat_tim_1 "In the past 2 weeks, water bot treated because of lack of time"

label var a16_stored_treat_freq_0 "Once at the time of storing" 
label var a16_stored_treat_freq_1 "Every time the stored water is used" 
label var a16_stored_treat_freq_2 "Daily"
label var a16_stored_treat_freq_3 "2-3 times a day" 
label var a16_stored_treat_freq_4 "Every 2-3 days in a week"
label var a16_stored_treat_freq_5   "No fixed schedule" 

label var water_treat_kids_1  "Water treatment for youngest children in HH" 

label var water_treat_kids_type_1 "Filter the water through a cloth or sieve"  
label var  water_treat_kids_type_2  "Let the water stand before drinking"
label var  water_treat_kids_type_3 "Boil the water"
label var  water_treat_kids_type_4 "Add chlorine/ bleaching powder" 
label var C_water_treat_kids__77 "Other" 
label var water_treat_kids_type_999 "Don't know" 
label var C_indirect_treat_kids_1 "Indirect treatment methods"

label var C_treat_kids_freq_1 "Always treat the water"  
label var  C_treat_kids_freq_2 "Treat the water in the summers"
label var C_treat_kids_freq_3 "Treat the water in the monsoons" 
label var C_treat_kids_freq_4 "Treat the water in the winters"
label var C_treat_kids_freq_5 "Treat the water when kids/ old people fall sick"
label var  C_treat_kids_freq_6 "Treat the water when it looks or smells dirty"  
label var C_treat_kids_freq__77 "Other"

label var lastweekJJM  "In the past week, all of the primary drinking water came from JJM" 
label var not_treat_tim_1 "In the past 2 weeks, water not treated due to lack of time" 
label var HH_level_U5 "Households that have U5 kids"

label var sec_source_reason_1 "Primary source is not working" 
label var sec_source_reason_2 "Primary source does not give adequate water" 
label var sec_source_reason_3 "Primary source gives water intermittently" 
label var sec_source_reason_4 "Primary water source is muddy or smelly" 
label var sec_source_reason_5 "During the summer season"
label var sec_source_reason_6 "During monsoon season"
label var sec_source_reason_7 "No fixed reason"
label var sec_source_reason__77   "Other"
label var sec_source_reason_999  "Don't know"

label var water_sec_freq_1 "Daily" 
label var water_sec_freq_2 "Every 2-3 days in a week" 
label var water_sec_freq_3 "Once a week" 
label var water_sec_freq_4 "Once every two weeks" 
label var water_sec_freq_5 "Once a month" 
label var water_sec_freq_6 "Once every few months" 
label var water_sec_freq_8 "No fixed schedule" 
label var water_sec_freq_999 "Don’t know" 

label var water_treat_kids_0 "Do not treat for U5 kids"
label var water_treat_kids_98 "Refused to asnwer"
label var water_treat_kids_999  "Don't know"


*** Saving the dataset 
save "${DataTemp}Temp.dta", replace

*********************
** Good up to hear **
*********************


//water_prim_source_kids_1 U5_nonjjm_water_source water_source_preg_1

*** Creation of the table
*Setting up global macros for calling variables
global PanelA C_water_source_prim_1 C_water_source_prim_2 C_water_source_prim_3 C_water_source_prim_4  C_water_source_prim_77  water_sec_yn_0 water_sec_yn_1 C_water_source_sec_1 C_water_source_sec_2 C_water_source_sec_3 C_water_source_sec_4 C_water_source_sec__77 sec_source_reason_1 sec_source_reason_2 sec_source_reason_3 sec_source_reason_4 sec_source_reason_5 sec_source_reason_6 sec_source_reason_7 sec_source_reason__77 sec_source_reason_999 water_sec_freq_1 water_sec_freq_2 water_sec_freq_3 water_sec_freq_4 water_sec_freq_5 water_sec_freq_6 water_sec_freq_8 water_sec_freq_999
*global PanelA water_source_prim_1 water_sec_yn_1 water_source_sec_1 water_source_kids_0 water_prim_source_kids_1  water_treat_1 water_stored_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 water_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999

*Setting up local macros (to be used for labelling the table)
local PanelA "WASH Characteristics Baseline vs Endline"
local LabelPanelA "WASH"
*local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA "1"
local notePanelA "N: 880 - Number of main respondents who consented to participate in the Endline Survey \newline N: 914 - Number of main respondents who consented to participate in the Baseline Survey \newline \textbf{Notes:} \newline(a)262 Count for Baseline: Only 262 HH use any secondary source of drinking water \newline(b)317 Count for Endline: Only 317 HH use any secondary source of drinking water  \newline(c)419 Count for Baseline: Information collected for 419 HHs out of 914 who do water treatment of either the primary drinking water or stored water  \newline(d)629 Count for Endline: Information collected for 629 HHs out of 874 who do water treatment of either the primary drinking water or stored water \newline(f)**: Respondents allowed to select multiple options \newline(g)***: For the frequency of water treatment, respondents cannot select always treat the water with any other method \newline(h) There are no pregnant women from Endline that drink from a different primary source \newline \textbf{Clarifications:} \newline 1: Out of 0.04 U5 children that drink from a different primary source 0.17 drink from JJM \newline 2: The treatment for stored water was irrespective of the source of stored water and it was asked irrespective of the people saying Yes/No to primary water source treatment. The refernce period was current stored water \newline 3: Time refernce period is of last 1 month \newline 4: In Endline,516 HH say that in the last one week all of their drinking water came from JJM \newline 5: In the past 2 weeks, 87 out of 693 HH said they decided not to treat water because they didn't have time. Here 693 are those HH who either treat their primary or stored water" 


save "${DataTemp}WASH_TvsC.dta", replace 

* By R_Enr_treatment 
foreach k in PanelA { //loop for all variables in the global marco 

use "${DataTemp}Temp.dta", clear //using the saved dataset 
***********
** Table **
***********

* obs 
* Mean
	//Calculating the summary stats of treatment and control group for each variable and storing them
		
	eststo  model1: estpost summarize $`k' if survey_type_num  == 0 //baseline villages
	eststo  model2: estpost summarize $`k' if survey_type_num  == 1 //endline villages
/*	* Diff 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	///reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 129
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of p values
*/

	* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
		
	* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	//general
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Missing 
	//for endline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values


		* SD 
		//for baseline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
		* SD 
		//for endline	
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model10: estpost summarize $`k'


	* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model11: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	
		* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model12: estpost summarize $`k' //Store summary statistics of the variables with their frequency

	
//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)

//arranging the models in a way so that Obs Mean Missing SD order is followed for both baseline and endline
esttab  model11 model1 model7 model12 model2 model8 model3 model4 using "${Table_2}Test_Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))")  ///
	   mgroups("Baseline" "Endline" "Range", pattern(1 0 0 1 0 0 1 0 ) ///
	   prefix(\multicolumn{@span}{c}{)suffix(})span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("Obs" "Mean" "Missing" "Obs" "Mean" "Missing" "Min" "Max") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "JJM taps" "\multicolumn{9}{c}{\textbf{Panel A: Primary Water Source Distribution}} \\ JJM taps" ///
				   "Panel A: Water sources HH vs U5 kids" "\vspace{0.5cm} Panel A: Water sources HH vs U5 kids" ///
				   "Daily" "\textbf{Frequency of water collection from other sources:} \\Daily" ///
				   "Not using any secondary drinking water source" "\multicolumn{9}{c}{\textbf{Panel B: Secondary Water Source Distribution}} \\ Not using any secondary drinking water source" ///
				   "Households that have U5 kids" "\multicolumn{9}{c}{\textbf{Panel C: Water sources distribution of U5 kids}} \\ Households that have U5 kids" ///
				   "U5 drinking from the same primary source" "\textbf{Source of Drinking Water for U5 kids:} \\U5 drinking from the same primary source" ///
				   "Refused to answer" "Refused to answer \\ \textbf{U5 kids drinking from a different source:}" ///
				   "Using any secondary drinking water source:" "\textbf{Using any secondary drinking water source:}" ///
				   "Primary source is not working" "\textbf{Circumstances in which other sources are used:} \\Primary source is not working" ///
				   "Using govt. taps as primary drinking water" "\textbf{JJM usage as a drinking water source} \\ Using govt. taps as primary drinking water" ///
				   "Water treatment for primary source" "\multicolumn{9}{c}{\textbf{Panel B: Water Treatment HH vs U5 kids}} \\ Water treatment for primary source" ///
				   "U5 children primary source is JJM" "\vspace{0.5cm} U5 children primary source is JJM" ///
				   "Always treat the water" "\textbf{Frequency of the treatment***} \\ Always treat the water" ///
				   "Water treatment for primary source"  "\hline \textbf{Water treatment usage\textsuperscript{5}} \\ Water treatment for primary source" ///
				   "Once at the time of storing" "\textbf{Frequency of the stored water treatment} \\ Once at the time of storing" ///
				   "U5 children primary source is JJM" "U5 children primary source is JJM\textsuperscript{1}" ///
				   "Stored water treatment" "Stored water treatment\textsuperscript{2}" ///
				   "Water treatment for primary source" "Water treatment for primary source\textsuperscript{3}" ///
				   "Using govt. taps as primary drinking water" "Using govt. taps as primary drinking water\textsuperscript{4}" ///
				   "Water treatment for youngest children in HH" "\textbf{Water Treatment for U5 kids} \\ Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\textbf{Types of Treatment for U5 kids**} \\ Filter water through a cloth or sieve for U5 kids" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment**} \\ Filter the water through a cloth or sieve" ///
				   "Using govt. taps as primary drinking water" "\hspace{0.5cm} Using govt. taps as primary drinking water" ///
				   "Using govt. taps as secondary drinking water" "\hspace{0.5cm} Using govt. taps as secondary drinking water" ///
				   "Water treatment for primary source" "\hspace{0.5cm} Water treatment for primary source" ///
				   "Stored water treatment" "\hspace{0.5cm} Stored water treatment" ///
				   "Filter the water through a cloth or sieve" "\hspace{0.5cm} Filter the water through a cloth or sieve" ///				 
				   "Let the water stand before drinking" "\hspace{0.5cm} Let the water stand before drinking" ///
				   "Boil the water" "\hspace{0.5cm} Boil the water" ///
				   "Add chlorine/ bleaching powder" "\hspace{0.5cm} Add chlorine/ bleaching powder" ///
				   "Always treat the water" "\hspace{0.5cm} Always treat the water" /// 	
				   "Treat the water in the summers" "\hspace{0.5cm} Treat the water in the summers" ///
				   "Treat the water in the monsoons" "\hspace{0.5cm} Treat the water in the monsoons" ///
				   "Treat the water in the winters" "\hspace{0.5cm} Treat the water in the winters" ///
				   "Treat the water when kids/ old people fall sick" "\hspace{0.5cm} Treat the water when kids/ old people fall sick" ///
				   "Treat the water when it looks or smells dirty" "\hspace{0.5cm} Treat the water when it looks or smells dirty" /// 
				   "Water treatment for youngest children in HH" "\hspace{0.5cm} Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\hspace{0.5cm} Filter water through a cloth or sieve for U5 kids"  ///
				   "Let water stand before drinking for U5" "\hspace{0.5cm} Let water stand before drinking for U5" /// 
				   "Boil water for U5 kids" "\hspace{0.5cm} Boil water for U5 kids" ///
				   "Add chlorine/bleaching powder for U5 kids" "\hspace{0.5cm} Add chlorine/bleaching powder for U5 kids" ///	
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   ".00" "" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")
}

* mtitles("\multicolumn{4}{c}{Baseline}" "\multicolumn{4}{c}{Endline}"  \\ "\multicolumn{1}{c}{Obs}" "\multicolumn{1}{c}{Mean}" "\multicolumn{1}{c}{Missing}" "\multicolumn{1}{c}{SD}" "\multicolumn{1}{c}{Obs}" "\multicolumn{1}{c}{Mean}" "\multicolumn{1}{c}{Missing}" "\multicolumn{1}{c}{SD}") ///

* "Filter the water through a cloth or sieve" "\textbf{Types of Treatment} \\ Filter the water through a cloth or sieve" ///

// Histogram for water quantity (assuming it's a numerical variable)




global PanelA2  water_source_kids_1 water_source_kids_3 water_source_kids_4 water_source_kids_999 water_source_kids_98 water_prim_source_kids_1 water_prim_source_kids_4 water_prim_source_kids_8 water_prim_source_kids_77 water_treat_kids_0 water_treat_kids_98 water_treat_kids_999 water_treat_kids_1 C_indirect_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 C_water_treat_kids__77 water_treat_kids_type_999 C_treat_kids_freq_1 C_treat_kids_freq_2 C_treat_kids_freq_3 C_treat_kids_freq_4 C_treat_kids_freq_5 C_treat_kids_freq_6 C_treat_kids_freq__77 

//HH_level_U5

*global PanelA water_source_prim_1 water_sec_yn_1 water_source_sec_1 water_source_kids_0 water_prim_source_kids_1  water_treat_1 water_stored_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 water_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999

*Setting up local macros (to be used for labelling the table)
local PanelA2 "WASH Characteristics Baseline vs Endline for U5 kids"
local LabelPanelA2 "WASH"
*local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA2 "1"
//local notePanelA "N: 880 - Number of main respondents who consented to participate in the Endline Survey \newline N: 914 - Number of main respondents who consented to participate in the Baseline Survey \newline \textbf{Notes:} \newline(a)262 Count for Baseline: Only 262 HH use any secondary source of drinking water \newline(b)317 Count for Endline: Only 317 HH use any secondary source of drinking water  \newline(c)419 Count for Baseline: Information collected for 419 HHs out of 914 who do water treatment of either the primary drinking water or stored water  \newline(d)629 Count for Endline: Information collected for 629 HHs out of 874 who do water treatment of either the primary drinking water or stored water \newline(f)**: Respondents allowed to select multiple options \newline(g)***: For the frequency of water treatment, respondents cannot select always treat the water with any other method \newline(h) There are no pregnant women from Endline that drink from a different primary source \newline \textbf{Clarifications:} \newline 1: Out of 0.04 U5 children that drink from a different primary source 0.17 drink from JJM \newline 2: The treatment for stored water was irrespective of the source of stored water and it was asked irrespective of the people saying Yes/No to primary water source treatment. The refernce period was current stored water \newline 3: Time refernce period is of last 1 month \newline 4: In Endline,516 HH say that in the last one week all of their drinking water came from JJM \newline 5: In the past 2 weeks, 87 out of 693 HH said they decided not to treat water because they didn't have time. Here 693 are those HH who either treat their primary or stored water" 



foreach k in PanelA2 { //loop for all variables in the global marco 

use "${DataTemp}Temp.dta", clear //using the saved dataset 
***********
** Table **
***********

* obs 
* Mean
	//Calculating the summary stats of treatment and control group for each variable and storing them
		
	eststo  model1: estpost summarize $`k' if survey_type_num  == 0 //baseline villages
	eststo  model2: estpost summarize $`k' if survey_type_num  == 1 //endline villages
/*	* Diff 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	///reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 129
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of p values
*/

	* Min
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
		
	* Max
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	//general
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Missing 
	//for endline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values


		* SD 
		//for baseline
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
		* SD 
		//for endline	
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model10: estpost summarize $`k'


	* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 0
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model11: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	
		* Count 
		//endline
	//Calculating the summary stats 
	use "${DataTemp}Temp.dta", clear
	keep if survey_type_num == 1
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model12: estpost summarize $`k' //Store summary statistics of the variables with their frequency

	
//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)

//arranging the models in a way so that Obs Mean Missing SD order is followed for both baseline and endline
esttab  model11 model1 model7 model12 model2 model8 model3 model4 using "${Table_2}Test_Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))")  ///
	   mgroups("Baseline" "Endline" "Range", pattern(1 0 0 1 0 0 1 0 ) ///
	   prefix(\multicolumn{@span}{c}{)suffix(})span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("Obs" "Mean" "Missing" "Obs" "Mean" "Missing" "Min" "Max") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "Not using any secondary drinking water source" "\multicolumn{9}{c}{\textbf{Panel B: Secondary Water Source Distribution}} \\ Not using any secondary drinking water source" ///
				   "Households that have U5 kids" "\multicolumn{9}{c}{\textbf{Panel C: Water sources distribution of U5 kids}} \\ Households that have U5 kids" ///
				   "U5 drinking from the same primary source" "\textbf{Source of Drinking Water for U5 kids:} \\U5 drinking from the same primary source" ///
				   "Refused to answer" "Refused to answer \\ \textbf{U5 kids drinking from a different source:}" ///
				   "Always treat the water" "\textbf{Frequency of the treatment} \\ Always treat the water" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment} \\ Filter the water through a cloth or sieve" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   ".00" "" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")
}
 

use "${DataTemp}WASH_TvsC.dta", clear
 
global PanelA3 C_water_treat_0 C_water_treat_1  C_indirect_treatment_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 C_water_treat_type__77 water_treat_type_999 C_water_treat_freq_1 C_water_treat_freq_2 C_water_treat_freq_3 C_water_treat_freq_4 C_water_treat_freq_5 C_water_treat_freq_6 C_water_treat_freq__77

*global PanelA water_source_prim_1 water_sec_yn_1 water_source_sec_1 water_source_kids_0 water_prim_source_kids_1  water_treat_1 water_stored_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 water_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999

*Setting up local macros (to be used for labelling the table)
local PanelA3 "WASH Treatment of Primary water source Baseline vs Endline"
local LabelPanelA3 "WASH"
*local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelA3 "1"
//local notePanelA "N: 880 - Number of main respondents who consented to participate in the Endline Survey \newline N: 914 - Number of main respondents who consented to participate in the Baseline Survey \newline \textbf{Notes:} \newline(a)262 Count for Baseline: Only 262 HH use any secondary source of drinking water \newline(b)317 Count for Endline: Only 317 HH use any secondary source of drinking water  \newline(c)419 Count for Baseline: Information collected for 419 HHs out of 914 who do water treatment of either the primary drinking water or stored water  \newline(d)629 Count for Endline: Information collected for 629 HHs out of 874 who do water treatment of either the primary drinking water or stored water \newline(f)**: Respondents allowed to select multiple options \newline(g)***: For the frequency of water treatment, respondents cannot select always treat the water with any other method \newline(h) There are no pregnant women from Endline that drink from a different primary source \newline \textbf{Clarifications:} \newline 1: Out of 0.04 U5 children that drink from a different primary source 0.17 drink from JJM \newline 2: The treatment for stored water was irrespective of the source of stored water and it was asked irrespective of the people saying Yes/No to primary water source treatment. The refernce period was current stored water \newline 3: Time refernce period is of last 1 month \newline 4: In Endline,516 HH say that in the last one week all of their drinking water came from JJM \newline 5: In the past 2 weeks, 87 out of 693 HH said they decided not to treat water because they didn't have time. Here 693 are those HH who either treat their primary or stored water" 
local notePanelA3 "\newline(a)*: Respondents allowed to select multiple options \newline(b)**: For the frequency of water treatment, respondents cannot select always treat the water with any other method \newline(c)1: Indirect water treatment methods are those methods that are not directly applied on water. In this case these mthods are cleaning the container or covering the container or both" 

 
 * By R_Enr_treatment 
foreach k in PanelA3 { //loop for all variables in the global marco 

use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
***********
** Table **
***********

* obs 
* Mean
	//Calculating the summary stats of treatment and control group for each variable and storing them
		
	eststo  model1: estpost summarize $`k' if survey_type_num  == 0 //baseline villages
	eststo  model2: estpost summarize $`k' if survey_type_num  == 1 //endline villages
/*	* Diff 
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	///reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model3: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 129
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model4: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
	use "${DataTemp}Temp.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model5: estpost summarize $`k' //storing summary stats of p values
*/

	* Min
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	foreach i in $`k' {
	egen min_`i'=min(`i')
	replace `i'=min_`i'
	}
	eststo  model3: estpost summarize $`k' //storing summary stats of minimum value
		
	* Max
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	foreach i in $`k' {
	egen max_`i'=max(`i')
	replace `i'=max_`i'
	}
	eststo  model4: estpost summarize $`k' //storing summary stats of maximum value
	
	* Missing 
	//general
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Missing 
	//for endline
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model8: estpost summarize $`k' //summary stats of count of missing values


		* SD 
		//for baseline
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 0
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model9: estpost summarize $`k'
	
		* SD 
		//for endline	
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 1
	foreach i in $`k' {
	egen m_`i'=sd(`i')
	replace `i'=m_`i'
	}
	eststo  model10: estpost summarize $`k'


	* Count 
		//endline
	//Calculating the summary stats 
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 0
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model11: estpost summarize $`k' //Store summary statistics of the variables with their frequency
	
	
		* Count 
		//endline
	//Calculating the summary stats 
use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	keep if survey_type_num == 1
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model12: estpost summarize $`k' //Store summary statistics of the variables with their frequency

	
//Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)

//arranging the models in a way so that Obs Mean Missing SD order is followed for both baseline and endline
esttab  model11 model1 model7 model12 model2 model8 model3 model4 using "${Table_2}Test_Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))")  ///
	   mgroups("Baseline" "Endline" "Range", pattern(1 0 0 1 0 0 1 0 ) ///
	   prefix(\multicolumn{@span}{c}{)suffix(})span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("Obs" "Mean" "Missing" "Obs" "Mean" "Missing" "Min" "Max") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "U5 children primary source is JJM" "\vspace{0.5cm} U5 children primary source is JJM" ///
				   "Indirect treatment methods" "Indirect treatment methods\textsuperscript{1}" ///
				   "Always treat the water" "\textbf{Frequency of the treatment**} \\ Always treat the water" ///
				   "Water treatment for primary source"  "\hline \textbf{Water treatment usage\textsuperscript{5}} \\ Water treatment for primary source" ///
				   "Once at the time of storing" "\textbf{Frequency of the stored water treatment} \\ Once at the time of storing" ///
				   "U5 children primary source is JJM" "U5 children primary source is JJM\textsuperscript{1}" ///
				   "Stored water treatment" "Stored water treatment\textsuperscript{2}" ///
				   "Water treatment for primary source" "Water treatment for primary source\textsuperscript{3}" ///
				   "Using govt. taps as primary drinking water" "Using govt. taps as primary drinking water\textsuperscript{4}" ///
				   "Water treatment for youngest children in HH" "\textbf{Water Treatment for U5 kids} \\ Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\textbf{Types of Treatment for U5 kids**} \\ Filter water through a cloth or sieve for U5 kids" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment*} \\ Filter the water through a cloth or sieve" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   ".00" "" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")
}

STOP

/*
///////////////////////////////////////////////////////////////
------------TREATMENT VS CONTROL-------------------------------
///////////////////////////////////////////////////////////////
*/ 

global PanelB water_source_prim_1  water_source_sec_1 water_source_kids_0 water_prim_source_kids_1  water_treat_1 water_stored_1 water_treat_type_1 water_treat_type_2 water_treat_type_3 water_treat_type_4 water_treat_type__77 water_treat_type_999 water_treat_freq_1 water_treat_freq_2 water_treat_freq_3 water_treat_freq_4 water_treat_freq_5 water_treat_freq_6 water_treat_freq__77 water_treat_kids_1 water_treat_kids_type_1 water_treat_kids_type_2 water_treat_kids_type_3 water_treat_kids_type_4 water_treat_kids_type__77 water_treat_kids_type_999

local PanelB "WASH Characteristics Treatment vs Control"
local LabelPanelB "WASH_tc"
*local notePanelA "Notes: The reference point of each sickness is 2 weeks prior to the date of the interview. The ICC of the diarrhea within household is `ICC'. Standard errors are clustered at the household level."
local ScalePanelB "1"
local notePanelB "N: 880 - Number of main respondents who consented to participate in the Endline Survey \newline N: 914 - Number of main respondents who consented to participate in the Baseline Survey \newline * p<0.1, ** p<0.05, *** p<0.01" 

	
	foreach k in PanelB{ //loop for all variables in the global marco 

use "${DataTemp}WASH_TvsC.dta", clear //using the saved dataset 
	
	
	* Mean
	//Calculating the summary stats 
	eststo  model1: estpost summarize $`k' //Total (for all villages)
	eststo  model2: estpost summarize $`k' if Treat_V==1 //Treatment villages
	eststo  model3: estpost summarize $`k' if Treat_V==0 //Control villages
	
	* Diff 
use "${DataTemp}WASH_TvsC.dta", clear	
foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on the treatment status 
	replace `i'=_b[1.Treat_V] //replacing the value of variable with regression coefficient (estimate of treatment effect)
	}
	eststo  model4: estpost summarize $`k' //Storing summary stats of estimated treatment effects
	
	* Significance
use "${DataTemp}WASH_TvsC.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1' 
	//assigning temporary place holders to p values for categorization into significance levels in line 339
	replace `i'=99996 if p_1> 0.1  
	replace `i'=99997 if p_1<= 0.1
	replace `i'=99998 if p_1<= 0.05
	replace `i'=99999 if p_1<=0.01
	}
	eststo model5: estpost summarize $`k' //storing the summary stats of the transformed variable
	
	* P-value
use "${DataTemp}WASH_TvsC.dta", clear
	foreach i in $`k' {
	reg `i' i.Treat_V, cluster(village) //regressing the variables on treatment status
	matrix b = r(table) //storing the regression results in a matrix 'b'
	scalar p_1 = b[4,2] //storing the p values from the matrix in a scalar 'p_1'
	replace `i'=p_1 //replacing the value of variable with corresponding p value 
	}
	eststo  model6: estpost summarize $`k' //storing summary stats of p values
	
	* Missing 
use "${DataTemp}WASH_TvsC.dta", clear
	foreach i in $`k' {
	egen `i'_Miss=rowmiss(`i') //generating binary variable to record if value of variable is missing
	egen max_`i'=sum(`i'_Miss) //counting the total number of missing values of the variable
	replace `i'=max_`i' //replacing the value of variable with count of missing values 
	}
	eststo  model7: estpost summarize $`k' //summary stats of count of missing values
	
	* Frequency 
	//Calculating the summary stats 
    foreach i in $`k' {
    egen count_`i' = count(`i') //calc. freq of each var 
    replace `i' = count_`i' //replacing values with their freq
}
    eststo model0: estpost summarize $`k' //Store summary statistics of the variables with their frequency


*Tabulating stored sumamry stats of all the estimates (mean, estimated effects, significance levels, p values, min, max and missing values)
esttab  model0 model1 model2 model3 model4 model5 model6 model7 using "${Table_2}WASHTC_`k'.tex", ///
	   replace	   cell("mean (fmt(2) label(_))") ///
	   mtitles("\shortstack[c]{Obs}" "\shortstack[c]{Total}" "\shortstack[c]{T}" "\shortstack[c]{C}" "\shortstack[c]{Diff}" "Sig" "P-value" "Missing") ///
	   substitute( "&           _" "" ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
	               "&           _&           _&           _&           _&           _&           _&           _&           _\\" "" ///
	               "Water sources" "\vspace{0.5cm} Water sources" ///
				   "Using govt. taps as primary drinking water" "\multicolumn{9}{c}{\textbf{Panel A: Water sources HH vs U5 kids}} \\ Using govt. taps as primary drinking water" ///
				   "Panel A: Water sources HH vs U5 kids" "\vspace{0.5cm} Panel A: Water sources HH vs U5 kids" ///
				   "Using govt. taps as primary drinking water" "\textbf{JJM usage as a drinking water source} \\ Using govt. taps as primary drinking water" ///
				   "Water treatment for primary source" "\multicolumn{9}{c}{\textbf{Panel B: Water Treatment HH vs U5 kids}} \\ Water treatment for primary source" ///
				   "U5 children primary source is JJM" "\vspace{0.5cm} U5 children primary source is JJM" ///
				   "Always treat the water" "\textbf{Frequency of the treatment} \\ Always treat the water" ///
				   "Water treatment for primary source"  "\hline \textbf{Water treatment usage} \\ Water treatment for primary source" ///
				   "Once at the time of storing" "\textbf{Frequency of the stored water treatment} \\ Once at the time of storing" ///
				   "Water treatment for youngest children in HH" "\textbf{Water Treatment for U5 kids} \\ Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\textbf{Types of Treatment for U5 kids} \\ Filter water through a cloth or sieve for U5 kids" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment} \\ Filter the water through a cloth or sieve" ///
				   "Using govt. taps as primary drinking water" "\hspace{0.5cm} Using govt. taps as primary drinking water" ///
				   "Using govt. taps as secondary drinking water" "\hspace{0.5cm} Using govt. taps as secondary drinking water" ///
				   "U5 drinking from a different water source" "\hspace{0.5cm} U5 drinking from a different water source" ///
				   "U5 children primary source is JJM" "\hspace{0.5cm} U5 children primary source is JJM" ///
				   "Water treatment for primary source" "\hspace{0.5cm} Water treatment for primary source" ///
				   "Stored water treatment" "\hspace{0.5cm} Stored water treatment" ///
				   "Filter the water through a cloth or sieve" "\hspace{0.5cm} Filter the water through a cloth or sieve" ///				 
				   "Let the water stand before drinking" "\hspace{0.5cm} Let the water stand before drinking" ///
				   "Boil the water" "\hspace{0.5cm} Boil the water" ///
				   "Add chlorine/ bleaching powder" "\hspace{0.5cm} Add chlorine/ bleaching powder" ///
				   "Other" "\hspace{0.5cm} Other" ///
				   "Always treat the water" "\hspace{0.5cm} Always treat the water" /// 	
				   "Treat the water in the summers" "\hspace{0.5cm} Treat the water in the summers" ///
				   "Treat the water in the monsoons" "\hspace{0.5cm} Treat the water in the monsoons" ///
				   "Treat the water in the winters" "\hspace{0.5cm} Treat the water in the winters" ///
				   "Treat the water when kids/ old people fall sick" "\hspace{0.5cm} Treat the water when kids/ old people fall sick" ///
				   "Treat the water when it looks or smells dirty" "\hspace{0.5cm} Treat the water when it looks or smells dirty" /// 
				   "Water treatment for youngest children in HH" "\hspace{0.5cm} Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\hspace{0.5cm} Filter water through a cloth or sieve for U5 kids"  ///
				   "Let water stand before drinking for U5" "\hspace{0.5cm} Let water stand before drinking for U5" /// 
				   "Boil water for U5 kids" "\hspace{0.5cm} Boil water for U5 kids" ///
				   "Add chlorine/bleaching powder for U5 kids" "\hspace{0.5cm} Add chlorine/bleaching powder for U5 kids" ///	
				   "Don't know" "\hspace{0.5cm} Don't know" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " " ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")  
	   }

	   




/*
esttab  model11 model1 model7 model12 model2 model8 model3 model4 using "${Table_2}Test_Main_Endline_`k'.tex", ///
	   replace cell("mean (fmt(2) label(_))")  ///
	   mgroups("Baseline" "Endline" "Range", pattern(1 0 0 1 0 0 1 0 ) ///
	   prefix(\multicolumn{@span}{c}{)suffix(})span erepeat(\cmidrule(lr){@span})) ///
	   mtitles("Obs" "Mean" "Missing" "Obs" "Mean" "Missing" "Min" "Max") ///
	   substitute( ".00" "" "{l}{\footnotesize" "{p{`Scale`k''\linewidth}}{\footnotesize" ///
				   "JJM taps" "\multicolumn{9}{c}{\textbf{Panel A: Primary Water Source Distribution}} \\ JJM taps" ///
				   "Panel A: Water sources HH vs U5 kids" "\vspace{0.5cm} Panel A: Water sources HH vs U5 kids" ///
				   "Using govt. taps as primary drinking water" "\textbf{JJM usage as a drinking water source} \\ Using govt. taps as primary drinking water" ///
				   "Water treatment for primary source" "\multicolumn{9}{c}{\textbf{Panel B: Water Treatment HH vs U5 kids}} \\ Water treatment for primary source" ///
				   "U5 children primary source is JJM" "\vspace{0.5cm} U5 children primary source is JJM" ///
				   "Always treat the water" "\textbf{Frequency of the treatment***} \\ Always treat the water" ///
				   "Water treatment for primary source"  "\hline \textbf{Water treatment usage\textsuperscript{5}} \\ Water treatment for primary source" ///
				   "Once at the time of storing" "\textbf{Frequency of the stored water treatment} \\ Once at the time of storing" ///
				   "U5 children primary source is JJM" "U5 children primary source is JJM\textsuperscript{1}" ///
				   "Stored water treatment" "Stored water treatment\textsuperscript{2}" ///
				   "Water treatment for primary source" "Water treatment for primary source\textsuperscript{3}" ///
				   "Using govt. taps as primary drinking water" "Using govt. taps as primary drinking water\textsuperscript{4}" ///
				   "Water treatment for youngest children in HH" "\textbf{Water Treatment for U5 kids} \\ Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\textbf{Types of Treatment for U5 kids**} \\ Filter water through a cloth or sieve for U5 kids" ///
				   "Filter the water through a cloth or sieve" "\textbf{Types of Treatment**} \\ Filter the water through a cloth or sieve" ///
				   "Using govt. taps as primary drinking water" "\hspace{0.5cm} Using govt. taps as primary drinking water" ///
				   "Using any secondary drinking water source" "\hspace{0.5cm} Using any secondary drinking water source" ///
				   "Using govt. taps as secondary drinking water" "\hspace{0.5cm} Using govt. taps as secondary drinking water" ///
				   "U5 drinking from a different water source" "\hspace{0.5cm} U5 drinking from a different water source" ///
				   "U5 children primary source is JJM" "\hspace{0.5cm} U5 children primary source is JJM" ///
				   "Water treatment for primary source" "\hspace{0.5cm} Water treatment for primary source" ///
				   "Stored water treatment" "\hspace{0.5cm} Stored water treatment" ///
				   "Filter the water through a cloth or sieve" "\hspace{0.5cm} Filter the water through a cloth or sieve" ///				 
				   "Let the water stand before drinking" "\hspace{0.5cm} Let the water stand before drinking" ///
				   "Boil the water" "\hspace{0.5cm} Boil the water" ///
				   "Add chlorine/ bleaching powder" "\hspace{0.5cm} Add chlorine/ bleaching powder" ///
				   "Other" "\hspace{0.5cm} Other" ///
				   "Always treat the water" "\hspace{0.5cm} Always treat the water" /// 	
				   "Treat the water in the summers" "\hspace{0.5cm} Treat the water in the summers" ///
				   "Treat the water in the monsoons" "\hspace{0.5cm} Treat the water in the monsoons" ///
				   "Treat the water in the winters" "\hspace{0.5cm} Treat the water in the winters" ///
				   "Treat the water when kids/ old people fall sick" "\hspace{0.5cm} Treat the water when kids/ old people fall sick" ///
				   "Treat the water when it looks or smells dirty" "\hspace{0.5cm} Treat the water when it looks or smells dirty" /// 
				   "Water treatment for youngest children in HH" "\hspace{0.5cm} Water treatment for youngest children in HH" ///
				   "Filter water through a cloth or sieve for U5 kids" "\hspace{0.5cm} Filter water through a cloth or sieve for U5 kids"  ///
				   "Let water stand before drinking for U5" "\hspace{0.5cm} Let water stand before drinking for U5" /// 
				   "Boil water for U5 kids" "\hspace{0.5cm} Boil water for U5 kids" ///
				   "Add chlorine/bleaching powder for U5 kids" "\hspace{0.5cm} Add chlorine/bleaching powder for U5 kids" ///	
				   "Don't know" "\hspace{0.5cm} Don't know" ///
				   "WTchoice: " "~~~" "TPchoice: " "~~~" "Distance: " "~~~" "WT: " "~~~"  ///
				   ".00" "" ///
				   "-0&" "0&" "99999" "***"  "99998" "**" "99997" "*" "99996" " "  ///
				   ) ///
	   label title("``k''" \label{`Label`k''}) note("`note`k''")
*/
