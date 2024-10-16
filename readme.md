# Template README and Guidance

Relevant link
- [Survey tools](https://drive.google.com/drive/u/1/folders/1DTvu3EhsxN6-HjEp9H0WAufLSEDoudp-)
- [Excel village list](https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1529467115)

## Final data description ([Process document](https://docs.google.com/document/d/1Hpv5HF5ICO5FSVdQnPtDECCYORn2qy5S7C_KIx0pDuM/edit))

### Villages
The final village list of 20 villages info with block and Panchayatta code is saved at "[Excel village list](https://docs.google.com/spreadsheets/d/1iWDd8k6L5Ny6KklxEnwvGZDkrAHBd0t67d-29BfbMGo/edit?pli=1#gid=1529467115)". 

### Baseline and Endline (3_X_Final_Data_Creation.do)
Household Level Information:
The baseline census consists of 3,848 households from 20 villages. There are 915 households with children under age 5 or pregnant women. Among these, there were 1,002 children under age 5. In the endline survey, 914 households were targeted for the survey, and interviews were conducted with 881 households (${DataFinal}UPDATE.dta).

Child Level Information:
There are 1,006 children from the 915 households. In the endline survey, 847 children were followed up, and 155 children were not found to be interviewed (4 cases are still to be resolved). Additionally, 116 children under age 5 were newly added in the endline survey.
 
> INSTRUCTIONS: Include a brief project summary here, as well as short instructions for how to run the code in the repository. This may be simple, or may involve many complicated steps. It should be a simple list, no excess prose. Strict linear sequence. If more than 4-5 manual steps, please wrap a master program/Makefile around them, in logical sequences. Examples follow.




> ## List of final outputs

> INSTRUCTIONS: Your programs should clearly identify the tables and figures as they appear in the manuscript, by number. Sometimes, this may be obvious, e.g. a program called "`table1.do`" generates a file called `table1.png`. Sometimes, mnemonics are used, and a mapping is necessary. In all circumstances, provide a list of tables and figures, identifying the program (and possibly the line number) where a figure is created.


| Figure/Table #    | Program                  | Line Number | Output file                      | Note                            |
|-------------------|--------------------------|-------------|----------------------------------|---------------------------------|
| Table 1           | 02_analysis/table1.do    |             | summarystats.csv                 ||
| Table 2           | 02_analysis/table2and3.do| 15          | table2.csv                       ||
| Table 3           | 02_analysis/table2and3.do| 145         | table3.csv                       ||
| Figure 1          | n.a. (no data)           |             |                                  | Source: Herodus (2011)          |
| Figure 2          | 02_analysis/fig2.do      |             | figure2.png                      ||
| Figure 3          | 02_analysis/fig3.do      |             | figure-robustness.png            | Requires confidential data      |

## List of datasets

> INSTRUCTIONS: In some cases, authors will provide one dataset (file) per data source, and the code to combine them. In others, in particular when data access might be restrictive, the replication package may only include derived/analysis data. Every file should be described. This can be provided as a Excel/CSV table, or in the table below. See a more detailed discussion on how to create these tables [here](https://dimewiki.worldbank.org/Data_Linkage_Table).

### Master data sets

| Data set name    | Location                            | [Key](https://dimewiki.worldbank.org/ID_Variable_Properties)        | [Foreign keys](https://en.wikipedia.org/wiki/Foreign_key)  | Main variables         | Created by |
|------------------|-------------------------------------|------------|------------|------------------------------------------------|--------|
| Village master   | Data/MasterData/VillageMaster.dta   | village_id |            | Treatment status, county, sub-county, location | Code/MasterData/create-village-master.do |
| Household master | Data/MasterData/HouseholdMaster.dta | hh_id      | village_id | GPS location, Enrollment status             | Code/MasterData/create-hh-master.do |

### Raw data

| Data set name    | Location                     | Unit of observation | Key        | Foreign keys | Main variables                          | Instrument/source |
|------------------|------------------------------|---------------------|------------|--------------|-----------------------------------------|-------------------|
| Chlorine tests   | Data/Raw/ChlorineTests.csv   | Household-time      | hh_id date | village_id   | Chlorine residual test result           | Link to survey instrument or data provider documentation |
| Household survey | Data/Raw/HouseholdSurvey.csv | Household           | hh_id      | village_id   | Chlorine use (self-reported), migration | |

### Tidy data

| Data set name  | Location                    | Unit of observation | Key        | Foreign keys | Main variables                          | Created by |
|----------------|-----------------------------|---------------------|------------|--------------|-----------------------------------------|------------|
| Chlorine tests | Data/Tidy/ChlorineTests.dta | Household-time      | hh_id date | village_id   | Chlorine residual test result           | Code/Tidy/tidy-chlorine.do |
| Household tidy | Data/Tidy/HouseholdTidy.dta | Household           | hh_id      | village_id   | Chlorine use (self-reported), migration | Code/Tidy/tidy-hh.do |
| Children tidy  | Data/Tidy/ChildrenTidy.dta  | Household-child     | child_id   | hh_id        | Data of birth, date of death, symptoms  | Code/Tidy/tidy-child.do |


### Intermediate/constructed data

| Data set name         | Location                                  | Unit of observation | Key        | Foreign keys | Main variables               | Created by |
|-----------------------|-------------------------------------------|---------------------|------------|--------------|------------------------------|------------|
| Children constructed  | Data/Constructed/ChildrenConstructed.dta  | Household-child     | child_id   | hh_id        | Age at death, cause of death | Code/Construct/construct-child.do |
| Household constructed | Data/Constructed/HouseholdConstructed.dta | Household           | hh_id      | village_id   | Chlorine use (self-reported, tested), exposure to treatment | Code/Construct/construct-hh.do |

### Analysis/final data

| Data set name    | Location                        | Unit of observation | Key      | Main variables | Created by |
|------------------|---------------------------------|---------------------|----------|----------------|------------|
| Children final   | Data/Analysis/ChildrenFinal.dta | Child               | child_id | Treatment status, death indicator, cause of death, chlorine use, exposure to treatment | Code/Construct/create-children-final.do |

---


# TO BE CLEANED (Do not read the rest)
**Contents**
- [Comments for replicators](#comments-for-replicators)
- [Computational requirements](#computational-requirements)
- [Description of programs/code](#description-of-programscode)
- [List of final outputs](#list-of-final-outputs)
- [List of datasets](#list-of-datasets)
- [Acknowledgements](#acknowledgements)

## Comments for replicators

- Edit `1_profile_ILC.do` to adjust the default path:

Add your directory around Line 38 (GitHub/i-h2o-india/Code/1_profile_ILC.do)
- Run `1_profile_ILC.do` once on a new system to set up the working environment. 
- Download the data files referenced above. Each should be stored in the prepared subdirectories of `data/`, in the format that you download them in. Do not unzip. Scripts are provided in each directory to download the public-use files. Confidential data files requested as part of your FSRDC project will appear in the `/data` folder. No further action is needed on the replicator's part.
- Run `1_profile_ILC.do` to run all steps in sequence.

## To be cleaned


- `programs/00_setup.do`: will create all output directories, install needed ado packages. 
   - If wishing to update the ado packages used by this archive, change the parameter `update_ado` to `yes`. However, this is not needed to successfully reproduce the manuscript tables. 
- `programs/01_dataprep`:  
   - These programs were last run at various times in 2018. 
   - Order does not matter, all programs can be run in parallel, if needed. 
   - A `programs/01_dataprep/master.do` will run them all in sequence, which should take about 2 hours.
- `programs/02_analysis/master.do`.
   - If running programs individually, note that ORDER IS IMPORTANT. 
   - The programs were last run top to bottom on July 4, 2019.
- `programs/03_appendix/master-appendix.do`. The programs were last run top to bottom on July 4, 2019.
- Figure 1: The figure can be reproduced using the data provided in the folder “2_data/data_map”, and ArcGIS Desktop (Version 10.7.1) by following these (manual) instructions:
  - Create a new map document in ArcGIS ArcMap, browse to the folder
“2_data/data_map” in the “Catalog”, with files  "provinceborders.shp", "lakes.shp", and "cities.shp". 
  - Drop the files listed above onto the new map, creating three separate layers. Order them with "lakes" in the top layer and "cities" in the bottom layer.
  - Right-click on the cities file, in properties choose the variable "health"... (more details)

## Computational requirements

> INSTRUCTIONS: In general, the specific computer code used to generate the results in the article will be within the repository that also contains this README. However, other computational requirements - shared libraries or code packages, required software, specific computing hardware - may be important, and is always useful, for the goal of replication. Some example text follows. 

### Software Requirements

> INSTRUCTIONS: For the oldest version of the code, the code has been replicable at least for version 15 or onwards. Set the version of Stata to 15 when running the code in later versions (by using version 15).

  - the program "`0_setup.do`" will install all dependencies locally, and should be run once.
- Python 3.6.4
  - the file "`requirements.txt`" lists these dependencies, please run "`pip install -r requirements.txt`" as the first step. See [https://pip.readthedocs.io/en/1.1/requirements.html](https://pip.readthedocs.io/en/1.1/requirements.html) for further instructions on using the "`requirements.txt`" file.
- R 3.4.3
  - the file "`0_setup.R`" will install all dependencies (latest version), and should be run once prior to running other programs.

### Controlled randomness

> INSTRUCTIONS: Some estimation code uses random numbers, almost always provided by pseudorandom number generators (PRNGs). For reproducibility purposes, these should be provided with a deterministic seed, so that the sequence of numbers provided is the same for the original author and any replicators. While this is not always possible, it is a requirement by many journals’ policies. The seed should be set once, and not use a time-stamp. If using parallel processing, special care needs to be taken. If using multiple programs in sequence, care must be taken on how to call these programs, ideally from a main program, so that the sequence is not altered.

Random seed is set at line ___ of program ____

## Description of programs/code

> INSTRUCTIONS: Give a high-level overview of the program files and their purpose.
- Programs in `programs/01_dataprep` will extract and reformat all datasets referenced above. The file `programs/01_dataprep/master.do` will run them all.
- Programs in `programs/02_analysis` generate all tables and figures in the main body of the article. The program `programs/02_analysis/master.do` will run them all. Each program called from `master.do` identifies the table or figure it creates (e.g., `05_table5.do`).  Output files are called appropriate names (`table5.tex`, `figure12.png`) and should be easy to correlate with the manuscript.
- Programs in `programs/03_appendix` will generate all tables and figures  in the online appendix. The program `programs/03_appendix/master-appendix.do` will run them all. 
- Ado files have been stored in `programs/ado` and the `master.do` files set the ADO directories appropriately. 
- The program `programs/00_setup.do` will populate the `programs/ado` directory with updated ado packages, but for purposes of exact reproduction, this is not needed. The file `programs/00_setup.log` identifies the versions as they were last updated.
- The program `programs/config.do` contains parameters used by all programs, including a random seed. Note that the random seed is set once for each of the two sequences (in `02_analysis` and `03_appendix`). If running in any order other than the one outlined below, your results may differ.


## Acknowledgements

This file was adapted from the Social Science Data Editors website. For the latest version, visit [https://social-science-data-editors.github.io/template_README/](https://social-science-data-editors.github.io/template_README/)


## Quick note
- "Data" is the place where people have been placing data with no PII. The data with PII collected in the field will be saved in the U chicago box
- We will not create the branch out of the master. We will always create the branch off of the “stem”

