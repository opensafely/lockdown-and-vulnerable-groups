

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

*** Intellectual disability

*Get CSV
import delimited using "$dir/output/measure_intdis_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2
gen period = 0							  /*pre-lockdown period */
replace period = 1 if date2>=d(23mar2020) /*start of first lockdown*/
replace period = 2 if date2>=d(13may2020) /*beginning of transition out of first lockdown */
replace period = 3 if date2>=d(31jul2020) /*end of transition out of first lockdown */
replace period = 4 if date2>=d(05nov2020) /*start of second/third lockdown period */
replace period = 5 if date2>=d(29mar2021) /*beginning of transition out of third lockdown */
replace period = 6 if date2>=d(18jul2021) /*end of transition out of thrid lockdown - 'opening up' */

sort date2

gen year = year(date2)
gen week = week(date2)

*create variables for CITS model
gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

gen group=intdis

gen p1=0
replace p1=1 if period==1
gen p2=0
replace p2=1 if period==2
gen p3=0
replace p3=1 if period==3
gen p4=0
replace p4=1 if period==4
gen p5=0
replace p5=1 if period==5
gen p6=0
replace p6=1 if period==6

gen t_g=time*group

gen t_p1=time*p1
gen t_p2=time*p2
gen t_p3=time*p3
gen t_p4=time*p4
gen t_p5=time*p5
gen t_p6=time*p6

gen t_g_p1=time*group*p1
gen t_g_p2=time*group*p2
gen t_g_p3=time*group*p3
gen t_g_p4=time*group*p4
gen t_g_p5=time*group*p5
gen t_g_p6=time*group*p6

sort group time

*Save as .dta file
save "$dir/output/weekly_intdis.dta", replace

*initial plot of rates over time
*graph twoway (line value time if intdis==1, lcolor(black)) (line value time if intdis==0, lcolor(gray)), legend(order(1 "IntDis" 2 "Control")) xline(0, lcolor(black) lpattern(dash)) xline(32.5, lcolor(black) lpattern(dash))
*graph export "$dir/output/intdis_plot.pdf", as(pdf)

*CITS model
glm consultations time group t_g p1 p2 p3 p4 p5 p6 t_p1 t_p2 t_p3 t_p4 t_p5 t_p6 t_g_p1 t_g_p2 t_g_p3 t_g_p4 t_g_p5 t_g_p6, family(nb) link(log) exposure(population)
*putexcel set "$gd/output/CITS_weekly.xlsx", sheet("RTI") replace
*putexcel A1=matrix(r(table)), names

predict intdis_yhat
gen intdis_pred_rate=intdis_yhat/population
graph twoway (line intdis_pred_rate time if group==1, lcolor(black)) (line intdis_pred_rate time if intdis==0, lcolor(gray)) (scatter value time if intdis==1, mcolor(black) msymbol(o)) (scatter value time if intdis==0, mcolor(gray) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
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

*create interaction variables for CITS model [as described in Linden (2015) The Stata Journal, 15(2), pp. 480–500]
gen t_p1 = 0
replace t_p1 = time if period==1

gen time_intervention = 0
replace time_intervention = time if intervention==1

gen intervention_period = 0
replace intervention_period = 1 if intervention==1 & period==1

gen time_int_period = 0
replace time_int_period = time if intervention_period==1

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









