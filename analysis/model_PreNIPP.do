

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

*Convert CSV to Stata file
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

*save "$dir/output/weekly_intdis.dta", replace

*initial plot of rates over time
graph twoway (line value time if intdis==1, lcolor(maroon)) (line value time if intdis==0, lcolor(navy)), legend(order(1 "IntDis rate" 2 "Control rate")) xline(0 32.5, lcolor(black) lpattern(dash))
graph export "$dir/output/intdis_plot.pdf", as(pdf)






