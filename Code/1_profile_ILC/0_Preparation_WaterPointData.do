/*
Purpose: Creation of deidentified raw datasets for village level gps coordinates 
Created by: Niharika Bhagavatula
Last Modified By: Niharika Bhagavatula
Last Modified Date: May 8, 2025
Do file to execute before this: ${github}/Code/1_profile_ILC.do (pathways) till line 179
Input datasets: ${DataRaw}Longitudinal Testing Survey_WIDE.dta and ${DataRaw}Geo location form_WIDE.dta
Output datasets: Deidentified datasets Stored in external box folder: ${external}deidentified_waterpoint_data
*/


********************************************************************************
*** Creating deidentified Longitudinal testing data - treatment group only
********************************************************************************

* Loading the raw data
import delimited  "${DataRaw}Longitudinal Testing Survey_WIDE.csv", clear  

* dropping vars other than gps location and village_code
keep village_name location gpslatitude gpslongitude gpsaltitude gpsaccuracy 

* saving the deidentified dataset
export delimited "${external}deidentified_waterpoint_data/longitudinal_deidentified.csv", replace 

********************************************************************************
*** Creating deidentified Geo Location data 
********************************************************************************

* Loading the raw data
import delimited  "${DataRaw}Geo location form_WIDE.csv", clear  

* dropping the obs for control group and karnapadu
drop if village_name==10201 | village_name==20201 | village_name==30202 | ///
village_name==30501 | village_name==30601 | village_name==40201 | village_name==40202 | village_name==40101 | village_name==50301 | village_name==40301 | village_name==50101 | village_name==50402
//58 obs dropped 

* dropping the obs where landmark in NOT the tank
drop if landmark!=1
//63 obs dropped

* dropping vars other than gps location and village_code
keep village_name gps_manuallatitude gps_manuallongitude gps_manualaltitude gps_manualaccuracy a40_gps_handlongitude a40_gps_handlatitude

* saving the deidentified dataset
export delimited "${external}deidentified_waterpoint_data/tanklocation_deindentified.csv" , replace

