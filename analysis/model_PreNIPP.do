

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

*** Intellectual disability

*Get CSV
import delimited using "$dir/output/measure_intdis_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_intdis.dta", replace

*initial plot of rates over time
graph twoway (line value time if intdis==1, lcolor(black)) (line value time if intdis==0, lcolor(gray)), legend(order(1 "IntDis" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/intdis_plot.pdf", as(pdf)


*** Domestic violence and abuse

*Get CSV
import delimited using "$dir/output/measure_dva_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_dva.dta", replace

*initial plot of rates over time
graph twoway (line value time if dva==1, lcolor(black)) (line value time if dva==0, lcolor(gray)), legend(order(1 "DVA" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/dva_plot.pdf", as(pdf)


*** RCGP child safeguarding

*Get CSV
import delimited using "$dir/output/measure_RCGPsafeguard_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_RCGPsafeguard.dta", replace

*initial plot of rates over time
graph twoway (line value time if rcgpsafeguard==1, lcolor(black)) (line value time if rcgpsafeguard==0, lcolor(gray)), legend(order(1 "RCGP child safeguarding" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/RCGPsafeguard_plot.pdf", as(pdf)


*** Child safeguarding

*Get CSV
import delimited using "$dir/output/measure_safeguard_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_safeguard.dta", replace

*initial plot of rates over time
graph twoway (line value time if safeguard==1, lcolor(black)) (line value time if safeguard==0, lcolor(gray)), legend(order(1 "Child safeguarding" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/safeguard_plot.pdf", as(pdf)


*** Substance misuse

*Get CSV
import delimited using "$dir/output/measure_misuse_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_misuse.dta", replace

*initial plot of rates over time
graph twoway (line value time if misuse==1, lcolor(black)) (line value time if misuse==0, lcolor(gray)), legend(order(1 "Substance misuse" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/misuse_plot.pdf", as(pdf)



*** Opioid dependence

*Get CSV
import delimited using "$dir/output/measure_opioid_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)


sort date2

gen year = year(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

*Save as .dta file
*save "$dir/output/weekly_opioid.dta", replace

*initial plot of rates over time
graph twoway (line value time if opioid==1, lcolor(black)) (line value time if opioid==0, lcolor(gray)), legend(order(1 "Substance misuse" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/opioid_plot.pdf", as(pdf)









