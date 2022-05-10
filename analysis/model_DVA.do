
*** Domestic violence and abuse

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"


*Get CSV
import delimited using "$dir/output/measure_dva_rate.csv", clear

*Set up time variables
generate date2 = date(date, "YMD")
format %td date2

gen week_date=date2
format %tw week_date

gen period = 0							  /*pre-lockdown period */
replace period = 1 if date2>=d(23mar2020) /*start of first lockdown*/
replace period = 2 if date2>=d(13may2020) /*beginning of inter lockdown period */
replace period = 3 if date2>=d(05nov2020) /*start of second/third lockdown period */
replace period = 4 if date2>=d(29mar2021) /*beginning of transition out of third lockdown */

sort date2

gen year = year(date2)
gen month = month(date2)
gen week = week(date2)

gen time = 0
replace time = week - 63.5 if year==2019
replace time = week - 11.5 if year==2020
replace time = week + 40.5 if year==2021

sort dva time
by dva: gen trperiod=_n
gen group=dva 

tsset dva trperiod

** CITS model for first lockdown

* run itsa initially to get dummy variables
xi: itsa consultations i.month, treat(1) trperiod(30 37) replace, if date2<d(02nov2020)

* run NegBin model using variables defined above: z=group x=period(pre/post) t=time
glm consultations _Imonth* _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37 if date2<d(02nov2020), family(nb) link(log) exposure(population) 

* Change point 1: start of 1st lockdown
*   step change = _z_x30 
*   slope change
lincom _z_t + _z_x_t30

* Change point 2: end of 1st lockdown
*   step change = _z_x37 
*   slope change
lincom _z_t + _z_x_t37

* plot observed and predicted values
predict dva_yhat
gen dva_pred_rate=dva_yhat/population

graph twoway (line dva_pred_rate time if group==1, lcolor(black)) (line dva_pred_rate time if dva==0, lcolor(gray)) (scatter value time if dva==1&date2<d(02nov2020), mcolor(black) msymbol(o)) (scatter value time if dva==0&date2<d(02nov2020), mcolor(gray) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash)) xline(8, lcolor(black) lpattern(dash)) xscale(range(-30 32)) xlabel(-30 -20 -10 0 10 20 30)

graph export "$dir/output/dva_plot1.pdf", as(pdf) replace


** CITS model for second and thrid lockdowns

* run itsa initially to get dummy variables
xi: itsa consultations i.month, treat(1) trperiod(62 83) replace, if date2>d(13may2020)&date2<=d(20sep2021)

* run NegBin model using variables defined above: z=group x=period(pre/post) t=time
glm consultations _Imonth* _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83 if date2>=d(11may2020)&date2<=d(20sep2021), family(nb) link(log) exposure(population) 

* Change point 1: start of 2nd lockdown
*   step change = _z_x62 
*   slope change
lincom _z_t + _z_x_t62

* Change point 2: end of 3rd lockdown
*   step change = _z_x83
*   slope change
lincom _z_t + _z_x_t83

* plot observed and predicted values
predict dva_yhat2
gen dva_pred_rate2=dva_yhat2/population

graph twoway (line dva_pred_rate2 time if group==1, lcolor(black)) (line dva_pred_rate2 time if dva==0, lcolor(gray)) (scatter value time if dva==1&date2>d(11may2020)&date2<=d(20sep2021), mcolor(black) msymbol(o)) (scatter value time if dva==0&date2>d(11may2020)&date2<=d(20sep2021), mcolor(gray) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(33, lcolor(black) lpattern(dash)) xline(54, lcolor(black) lpattern(dash)) xscale(range(8 79)) xlabel(10 20 30 40 50 60 70 80)

graph export "$dir/output/dva_plot2.pdf", as(pdf) replace