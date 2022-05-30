
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

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"


/*** SETUP DATA - Domestic violence and abuse ***/

import delimited using "$dir/output/measure_dva_rate.csv", clear

*Females only
keep if sex=="F"

rename consultations consultations_f
rename population population_f
rename value value_f

save "$dir/output/dva_female.dta", replace


*Males only
import delimited using "$dir/output/measure_dva_rate.csv", clear

keep if sex=="M"

rename consultations consultations_m
rename population population_m
rename value value_m

save "$dir/output/dva_male.dta", replace

*Females and males combined
merge m:1 date dva using "$dir/output/dva_female.dta"

gen consultations=consultations_f + consultations_m
gen population=population_f + population_m
gen value=consultations/population

drop sex consultations_f consultations_m population_f population_m value_f value_m _merge

save "$dir/output/dva_all.dta", replace


/*** SETUP DATA - Intellectual disability ***/

	import delimited using "$dir/output/measure_intdis_rate.csv", clear

	*Age<14
	keep if age14==0

	rename consultations consultations_sub14
	rename population population_sub14
	rename value value_sub14

	save "$dir/output/intdis_sub14.dta", replace


	*Age>=14 
	import delimited using "$dir/output/measure_intdis_rate.csv", clear

	keep if age14==1

	rename consultations consultations_over14
	rename population population_over14
	rename value value_over14

	save "$dir/output/intdis_over14.dta", replace

	*All ages combined
	merge m:1 date intdis using "$dir/output/intdis_sub14.dta"

	gen consultations=consultations_over14 + consultations_sub14
	gen population=population_over14 + population_sub14
	gen value=consultations/population

	drop age14 consultations_over14 consultations_sub14 population_over14 population_sub14 value_over14 value_sub14 _merge

	save "$dir/output/intdis_all.dta", replace


/*** SETUP DATA - Child safeguarding ***/

import delimited using "$dir/output/measure_RCGPsafeguard_rate.csv", clear

*Age<18
keep if age18==0

save "$dir/output/RCGPsafeguard_sub18.dta", replace


/*** SETUP DATA - Covid weekly counts of new cases ***/

*Get Covid weekly case counts;
import delimited using "$dir/output/CovidNewCaseCounts.csv", clear

save "$dir/output/CovidNewCaseCounts.dta", replace