* RRF 2024 - Processing Data Template	
*-------------------------------------------------------------------------------	
* Loading data
*------------------------------------------------------------------------------- 	
	
	* Load TZA_CCT_baseline.dta
	use "${data}/Raw/TZA_CCT_baseline.dta", clear
	
*-------------------------------------------------------------------------------	
* Checking for unique ID and fixing duplicates
*------------------------------------------------------------------------------- 		

	* Identify duplicates 
	ieduplicates	hhid ///
					using "${outputs}/duplicates.xlsx", ///
					uniquevars(key) ///
					keepvars(vid enid submissionday) ///
					nodaily
					
	
*-------------------------------------------------------------------------------	
* Define locals to store variables for each level
*------------------------------------------------------------------------------- 							
	
	* IDs
	local ids vid hhid enid
	
	* Unit: household
	local hh_vars floor walls water enegry rel_head female_head hh_size ///
	n_child_5 n_child_17 n_adult n_elder food_cons nonfood_cons farm    ///
	ar_farm ar_farm_unit crop crop_other crop_prp livestock_now         ///
	livestock_before drought_flood crop_damage trust_mem trust_lead     ///
	assoc health duration submissionday
	* floor - n_elder
	* food_cons - submissionday
	
	* Unit: Household-memebr
	local hh_mem gender age read clinic_visit sick days_sick ///
	treat_fin treat_cost ill_impact days_impact
	
	
	* define locals with suffix and for reshape
	foreach mem in `hh_mem' {
		
		local mem_vars "`mem_vars' `mem'_*"
		local reshape_mem "`reshape_mem' `mem'_"
	}
		
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH
*-------------------------------------------------------------------------------	

	preserve 
		
		* Keep HH vars
		keep `ids' `hh_vars'
		
		
		* Fix data types 
		* numeric should be numeric
		* dates should be in the date format
		* Categorical should have value labels 
		
		* Check if data type is string
		ds, has(type string)		
		
		* Fixing the submission dates
		gen submissiondate = date(submissionday, "YMD hms")
		format submissiondate %td
		
		* Encoding area farm unit
		encode ar_farm_unit, gen(ar_unit)
		
		* Duration turned to number
		destring duration, replace
		
		* Clean crop_other. The "other" category is removed
		replace crop_other = proper(crop_other)
		
		* The new category is added to the crop variable
		replace crop = 40 if regex(crop_other, "Coconut") == 1
		replace crop = 41 if regex(crop_other, "Sesame") == 1
		
		* The label is added
		label define df_CROP 40 "Coconut" 41 "Sesame", add
				
		
		* Turn numeric variables with negative values into missings
		ds, has(type numeric)
		global numVar `r(varlist)'

		foreach numVar of global numVars {
			
			recode `numVar' (-88 = .d) //.d is don't know
			
		}	
		
		* Explore variables for outliers
		sum food_cons nonfood_cons ar_farm, det
		
		* dropping, ordering, labeling before saving
		drop ar_farm_unit submissionday crop_other
				
		order ar_unit, after(ar_farm)
		
		lab var submissiondate "Date of interview"
		
		isid hhid, sort
		
		* Save data		
		iesave 	"${data}/Intermediate/TZA_CCT_HH", ///
				idvars(hhid)  version(15) replace ///
				report(path("${outputs}/TZA_CCT_HH_report.csv") replace)  
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: HH-member 
*-------------------------------------------------------------------------------*

	preserve 

		keep `mem_vars' `ids'

		* tidy: reshape tp hh-mem level 
		reshape long `reshape_mem', i(`ids') j(member)
		
		* clean variable names 
		rename *_ *
		
		* drop missings 
		drop if mi(gender)
		
		* Cleaning using iecodebook
		// recode the non-responses to extended missing
		// add variable/value labels
		// create a template first, then edit the template and change the syntax to 
		// iecodebook apply
		iecodebook template 	using ///
								"${outputs}/hh_mem_codebook.xlsx", replace
								
		isid hhid member				
		
		* Save data: Use iesave to save the clean data and create a report 
		iesave "${data}/Intermediate/TZA_CCT_HH_mem.dta", ///
		idvars(hhid member) version(15) replace ///
		report(path("${outputs}/TZA_CCT_HH_mem_report.csv") replace)
				
	restore			
	
*-------------------------------------------------------------------------------	
* Tidy Data: Secondary data
*------------------------------------------------------------------------------- 	
	
	* Import secondary data 
	import delimited "${data}/Raw/TZA_amenity.csv", clear
	
	* reshape  
	reshape wide n, i(adm2_en) j(amenity) str
	
	* rename for clarity
	rename n* n_*
	
	* Fix data types
	encode adm2_en, gen(district)
	
	* Label all vars 
	lab var district "District"
	lab var n_school "No. of schools"
	lab var n_clinic "No. of clinics"
	lab var n_hospital "No. of hospitals"
	
	* Save
	keeporder district n_*
	
	save "${data}/Intermediate/TZA_amenity_tidy.dta", replace

	
****************************************************************************end!
	
