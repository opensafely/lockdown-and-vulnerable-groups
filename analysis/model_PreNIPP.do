

global dir "`c(pwd)'"

global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

* patient_id <n>, age <n>, msoa <c>, sex <c>, intdis <n>, etc.

import delimited using "$dir/output/measure_intdis_rate.csv", clear
save "$dir/output/weekly_intdis.dta", replace

generate date2 = date(date, "YMD")
format %td date2
gen period = 0
replace period = 1 if date2>=d(23mar2020)
replace period = 2 if date2>=d(13may2020)&date2<=d(31jul2020)

*consecutively number weeks
sort date2 practice_id

gen year = year(date2)
gen week = week(date2)

gen week_date = week - 27
replace week_date = week + 25 if year==2021




