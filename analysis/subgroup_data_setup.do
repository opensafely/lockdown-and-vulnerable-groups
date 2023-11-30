
/****************************************************************/
/* Project repo:	opensafely/lockdown-and-vulnerable groups  	*/
/* Program author:	Scott Walter (Git: SRW612) 					*/

/* Data used:		output/measure_dva_rate.csv					*/
/*					output/measure_intdis_rate.csv				*/
/*					output/measure_RCGPsafeguard_rate.csv		*/
					
/* Outputs:			output/dva_female.dta						*/
/*					output/dva_male.dta							*/
/*					output/intdis_sub14.dta						*/
/*					output/intdis_over14.dta					*/
/*					output/safeguard_sub18.dta					*/

/* Purpose:			Create dta files for specific subgroups		*/
/*					as well as for all groups combined			*/
/****************************************************************/


/* PREAMBLE */

global dir `c(pwd)'

/*** SETUP DATA - Substance misuse ***/

*alcohol misuse
import delimited using "$dir/output/measure_alcmisuse_rate.csv", clear
save "$dir/output/measure_alcmisuse_rate.dta", replace

*drug misuse
import delimited using "$dir/output/measure_drugmisuse_rate.csv", clear
save "$dir/output/measure_drugmisuse_rate.dta", replace

*opioid dependence
import delimited using "$dir/output/measure_opioid_rate.csv", clear
save "$dir/output/measure_opioid_rate.dta", replace


/*** SETUP DATA - Domestic violence and abuse ***/

import delimited using "$dir/output/measure_dva_rate.csv", clear

*Females only
keep if sex=="F"

rename dva dvafemale

save "$dir/output/measure_dvafemale_rate.dta", replace


*Males only
import delimited using "$dir/output/measure_dva_rate.csv", clear

keep if sex=="M"

rename dva dvamale

save "$dir/output/measure_dvamale_rate.dta", replace


/*** SETUP DATA - Intellectual disability ***/

	import delimited using "$dir/output/measure_intdis_rate.csv", clear

	*Age<14
	keep if age14==0

	rename intdis intdissub14

	save "$dir/output/measure_intdissub14_rate.dta", replace


	*Age>=14 
	import delimited using "$dir/output/measure_intdis_rate.csv", clear

	keep if age14==1


	rename intdis intdisover14

	save "$dir/output/measure_intdisover14_rate.dta", replace


/*** SETUP DATA - Child safeguarding ***/

import delimited using "$dir/output/measure_RCGPsafeguard_rate.csv", clear

*Age<18
keep if age18==0

save "$dir/output/measure_rcgpsafeguard_rate.dta", replace