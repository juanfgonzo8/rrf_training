# Reproducible Research Package - Stata

Author: Juan Felipe González Castrillon
Last modified: October 3, 2024

This reproducibility package contains the work developed during the Reproducibility Research Training 2024.

**Folder Structure**

There are two main folders.

1. Stata: It contains the code and the outputs.
2. Data: It contains the original data files and intermediates.

The Stata version used to create these outputs is Stata 17. The ado folder in the Code folder contains the packages (dependencies) with the appropriate versions necessary to replicate the results.

In the main.do file located in Stata/Code, you should change the paths to be in accordance with the location of this elements in your local drive.

**Data Files**

There are three raw datasets:

1. TZA_CCT_baseline.dta
2. TZA_amenity.csv
3. treat_status.dta

These inputs were provided by the teaching team.

**Code Files**

There are four data scripts:

1. main.do: The main.do file executes the whole process to generate the outputs.
2. 01-processing-data.do: It creates tidy and clean data.
3. 02-constructing-data.do: It creates the indicators of interest.
3. 03-analyzing-data.do: it creates the analysis outputs.
