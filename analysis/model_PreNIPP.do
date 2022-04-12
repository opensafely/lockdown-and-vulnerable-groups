

global dir "`c(pwd)'"

global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"


import delimited using "$dir/output/input_PreNIPP_2020-02-24.csv", clear

*operations to define groups
gen SG=0
replace SG=1 if age<18 & rcgp_safeguard==1
drop age rcgp_safeguard

*gen MentalHealth=0
*replace MentalHealth=1 if depression==1|anxiety==1 ... etc.

*Collapse to one row each for main group and control group
preserve 
collapse (sum) consultations (count) patient_id, by(intdis)
save "$dir/output/G1_w1.dta", replace

restore
collapse (sum) consultations (count) patient_id, by(intdis)
save "$dir/output/G2_w1.dta", replace
	
	
local input input_PreNIPP_2020-03-02 input_PreNIPP_2020-03-09

foreach file of local input {
	import delimited using "$dir/output/"'file'".csv", clear

	*operations to define groups
	gen SG=0
	replace SG=1 if age<18 & rcgp_safeguard==1
	drop age rcgp_safeguard

	*gen MentalHealth=0
	*replace MentalHealth=1 if depression==1|anxiety==1 ... etc.

	*Collapse to one row each for main group and control group
	preserve 
	collapse (sum) consultations (count) patient_id, by(intdis)
	save "$dir/output/G1_w1.dta", replace

	restore
	collapse (sum) consultations (count) patient_id, by(intdis)
	save "$dir/output/G2_w1.dta", replace