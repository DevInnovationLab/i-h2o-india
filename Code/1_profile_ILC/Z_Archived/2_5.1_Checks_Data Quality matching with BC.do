import excel "C:\Users\Archi Gupta\Downloads\Plan 2nd nov all IDs.xlsx", sheet("Sheet1") firstrow
duplicates drop
preserve
clear
import excel "C:\Users\Archi Gupta\Downloads\Alloted_IDs_DQs.xlsx", sheet("JJM drink ") firstrow
drop L-AA
format  unique_id %15.0gc
drop if  Fieldplandate ==.
duplicates drop
keep unique_id
duplicates drop
save "C:\Users\Archi Gupta\Downloads\DQ_1.dta", replace
restore
merge 1:1 unique_id using "C:\Users\Archi Gupta\Downloads\DQ_1.dta", assert(master using match) keep(master using match)
destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id
merge 1:1 unique_id using "C:\Users\Archi Gupta\Downloads\DQ_1.dta", assert(master using match) keep(master using match)
cd "C:\Users\Archi Gupta\Box\Data\New folder"
export excel using "BC_IDs_new_3rd nov" if _merge == 1, sheetreplace firstrow(variables)
clear
//Matching IDs with the list containing all BC IDS
import excel "C:\Users\Archi Gupta\Downloads\BC Plan 2nd nov new.xlsx", sheet("Sheet2") firstrow
destring unique_id, gen(unique_id_num)
format  unique_id_num %15.0gc
drop unique_id
rename unique_id_num unique_id
keep unique_id
duplicates drop
save "C:\Users\Archi Gupta\Downloads\Old_BC_IDs.dta"
clear
import excel "C:\Users\Archi Gupta\Box\Data\New folder\BC_IDs_new_3rd nov.xls", sheet("Sheet1") firstrow
format  unique_id %15.0gc
merge 1:1 unique_id using "C:\Users\Archi Gupta\Downloads\Old_BC_IDs.dta", assert(master using match) keep(master using match)
drop merge
clear
import excel "C:\Users\Archi Gupta\Box\Data\New folder\BC_IDs_new_3rd nov.xls", sheet("Sheet1") firstrow
format  unique_id %15.0gc
drop _merge
merge 1:1 unique_id using "C:\Users\Archi Gupta\Downloads\Old_BC_IDs.dta", assert(master using match) keep(master using match)
export excel using "BC_IDs_new_3rd nov (excluded) " if _merge == 1, sheetreplace firstrow(variables)
