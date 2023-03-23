# Data folder

Following UChicago's guidelines, data should be stored in Box, not in GitHub. However, this folder should have the same structure as the Box folder, saving metadata such as data dictionaries and codebooks instead of the actual data tables. This can be done in Stata using `iesave` and in R using `skimr`.

## Suggested folder structure

```
data
|_ encrypted
   |_ data-source1-identified.csv
   |_ data-source1-identified.rds
   |_ data-source2-identified.csv
   |_ data-source2-identified.rds
   |_ data-source3-identified.csv
   |_ data-source3-identified.rds
|_ raw-deidentified
   |_ data-source1-deidentified.rds
   |_ data-source2-deidentified.rds
   |_ data-source3-deidentified.rds
|_ clean
   |_ data-source1-clean.rds
   |_ data-source2-clean.rds
   |_ data-source3-clean.rds
|_ tidy
   |_ data-source1-level1-tidy.rds
   |_ data-source1-level2-tidy.rds
   |_ data-source3-level1-tidy.rds
   |_ data-source3-level2-tidy.rds
|_ constructed
|_ analysis 
```

### `encrypted` folder

This folder should contain the "raw" data. That is, the original data you have collected or received, *exactly* as it was received. Note that this folder is only required if the original data contains personally identifiable information or other sensitive data, and that the entire folder should be encrypted. That means you will need to decrypt it every time you want to access the data. 

If the data was received in a format that is not easily handled by statistical software, such as CSV, you should also save a version of the data in a format that the statistical software you are using can read natively (for example .dta in Stata and .rds in R). This will reduce the time it takes to load the data.

### `raw-deidentified` folder

This folder should contain a deidentified version of the original data, that is, the original data stripped of direct identifiers. The point of storing de-identified data is to reduce the need to use files that contain confidential information, reducing both the risk of leaking sensitive data and the time and work required to decrypt the data before using it.

### `clean` folder

The clean version of the data set contains exactly the same information as the original data, but in a format that is optimized for use on statistical software. This means, for example, turning categorical variables into factors or labeled values, turning survey codes into missing values, and creating variable labels.

### `tidy` folder

When a single data table contains multiple units of observation (levels), it typically contains information in a *wide* format. However, although this may be an efficient format to transfer information on multiple units of observation in a single file, it is not an efficient format to analyze data. So the data needs to be tidied, or normalized, before it can be analyzed. This means reshaping the data until each column represents one variable, each row represents one observation, and each table (file) represents one type of observational unit.

For example, if you collected survey data that has both household-level and household member-level information, then you will create two data tables, one called `survey-household-tidy` and one called `survey-household-member-tidy`. If you only have data on one unit of observation, then your clean data will already be tidy, and this folder is not necessary.

For more information on tidying data, see [Hadley Wickham's paper](https://vita.had.co.nz/papers/tidy-data.pdf).

### `constructed` folder

Note that the differences between the data stored in each of the folders described above is only on format, and not on it's content. Some confidential information has been removed, some data has been labeled, and it may have been reshaped. But there are no meaningful changes to individual data points between the original data and its tidy version. The `constructed` folder will store data that incorporates research decisions through the creation of new indicators or the modification of values. This includes, for example, contructing an index based on a set of variables, winsorizing or trimming observations, and creating subsamples. The data in this folder should still be in tidy format.

### `analysis` folder

The `analysis` folder should contain the data sets that will be used as inputs for analysis. These are typically created by combining multiple constructed tables, and are not necessarily in tidy format. You may, for example, combine multiple units of observation so that values for higher levels are used as controls in analysis conducted at a lower level of observation. All data sets that needs to be included in a reproducibility package should be stored in this folder.