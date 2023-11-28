

** Program to reformat regression results

cap prog drop reformat
prog def reformat

* Define arguments ---------------------------------------------------------

args group measure lockdown

*Get data
	
import excel "$dir/output/CITS_`group'_`measure'_LD`lockdown'.xlsx", firstrow clear

drop A z df crit eform
rename B var
drop if var=="" | var=="_cons"

order var b se ll ul pvalue

gen model="`group'"
gen measure="`measure'"
gen lockdown="`lockdown'"

save "$dir/output/`group'_`measure'_LD`lockdown'.dta", replace

end
