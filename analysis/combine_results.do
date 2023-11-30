

global dir `c(pwd)'

di "$dir"

* Create empty results file ---------------------------------------------------

set obs 0
gen var = ""
gen b = ""
gen se = ""
gen ll = ""
gen ul = ""
gen pvalue = ""
gen group = ""
gen measure = ""
gen lockdown = ""

save "$dir/output/CITS_results.dta", replace

* Append all files into one

foreach group in drugmisuse alcmisuse opioid dvafemale dvamale intdissub14 intdisover14 rcgpsafeguard {
	
	foreach measure in RR RD {
		
		foreach lockdown in 1 2 {
			
			use "$dir/output/CITS_results.dta", clear		
			append using "$dir/output/`group'_`measure'_LD`lockdown'.dta"
			save "$dir/output/CITS_results.dta", replace 	
		}
	}
}

destring b se ll ul pvalue, replace

* Save final results file as csv -----------------------------------------------

use "$dir/output/CITS_results.dta", clear
export delimited "$dir/output/CITS_results.csv", replace

