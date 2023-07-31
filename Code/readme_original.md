# Code folder

This is the main GitHub folder, containing all the code to process and analyze the data.

## Suggested folder structure

```
code
|_ import
   |_ import-data-source1.R
   |_ import-data-source2.R
   |_ import-data-source3.R
|_ deidentify
   |_ deidentify-data-source1.R
   |_ deidentify-data-source2.R
   |_ deidentify-data-source3.R
|_ clean
   |_ clean-data-source1.R
   |_ clean-data-source2.R
   |_ clean-data-source3.R
|_ tidy
   |_ tidy-data-source1-level1.R
   |_ tidy-data-source1-level2.R
   |_ tidy-data-source3-level1.R
   |_ tidy-data-source3-level2.R
|_ construct
   |_ construct-level1-outcome-group1.R
   |_ construct-level2-outcome-group2.R
   |_ construct-level1-panel.R
|_ analysis 
   |_ balance-table.R
   |_ regression.R
   |_ robustness-check1.R
   |_ robustness-check2.R
```

### `import` folder

The code in this folder should import the data from a format that is not native to your statistical software (e.g. CSV) to one that is (e.g. .rds or .dta).

### `deidentify` folder

The code in this folder should remove direct identifiers from the imported data.

### `clean` folder

The code in this folder should optimize the data for use on statistical software. This means, for example, turning categorical variables into factors or labeled values, turning survey codes into missing values, and creating variable labels.

### `tidy` folder

The code in this folder should reshape the data until each column represents one variable, each row represents one observation, and each table (file) represents one type of observational unit.

For more information on tidying data, see [Hadley Wickham's paper](https://vita.had.co.nz/papers/tidy-data.pdf).

### `construct` folder

The code in this folder should incorporates research decisions into the data through the creation of new indicators or the modification of values. This includes, for example, contructing an index based on a set of variables, winsorizing or trimming observations, and creating subsamples. It should also create the final analysis data sets.

### `analysis` folder

The code in this folder should conduct statistical analyses of the final data and create graphs and table to be included in the final output.