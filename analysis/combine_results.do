

* Create empty results file ---------------------------------------------------

set obs 0
gen cohort = ""
save "output/CITS_results.dta", replace

* Append all files into one

foreach group in drugmisuse alcmisuse opioid dvafemale dvamale intdissub14 intdisover14 RCGPsafeguard {
	
	foreach measure in RR RD {
		
		foreach lockdown in 1 2 {
			
			use "output/CITS_results.dta", clear		
			destring b se ll ul pvalue, replace
			append using "$dir/output/`group'_`measure'_LD`lockdown'.dta"
			save "output/CITS_results.dta", replace 	
		}
	}
}


* Save final results file as csv -----------------------------------------------

use "output/CITS_results.dta", clear
export delimited "output/CITS_results.csv", replace

