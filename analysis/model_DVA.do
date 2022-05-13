
*** Domestic violence and abuse

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

*adopath + "$dir/analysis/adofiles"

*Get Covid weekly case counts;
import delimited using "$dir/output/CovidNewCaseCounts.csv", clear

save "$dir/output/CovidNewCaseCounts.dta", replace

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

*define interaction terms as per the itsa function
gen _z=dva 
gen _t=trperiod
gen _z_t=_z*trperiod
gen _x30=period
  replace _x30=1 if period>=1
gen _x_t30=_x30*(_t-30)
gen _z_x30=_z*_x30
gen _z_x_t30=_z_x30*(_t-30)

gen _x37=0
  replace _x37=1 if period>=2
gen _x_t37=_x37*(_t-37)
gen _z_x37=_z*_x37
gen _z_x_t37=_z_x37*(_t-37)

gen _x62=0
  replace _x62=1 if period>=2
gen _x_t62=_x62*(_t-62)
gen _z_x62=_z*_x62
gen _z_x_t62=_z_x62*(_t-62)

gen _x83=0
  replace _x83=1 if period>=2
gen _x_t83=_x83*(_t-83)
gen _z_x83=_z*_x83
gen _z_x_t83=_z_x83*(_t-83)



*Indicator variables for public holidays
gen xmas=0
replace xmas=1 if date2==d(23dec2019)
replace xmas=1 if date2==d(21dec2020)
replace xmas=1 if date2==d(20dec2021)

gen ny=0
replace ny=1 if date2==d(30dec2019)
replace ny=1 if date2==d(28dec2020)
replace ny=1 if date2==d(27dec2021)

gen easter=0
replace easter=1 if date2==d(06apr2020)
replace easter=1 if date2==d(13apr2020)
replace easter=1 if date2==d(29mar2021)
replace easter=1 if date2==d(05apr2021)

gen pubhol=0
replace pubhol=1 if date2==d(04may2020)
replace pubhol=1 if date2==d(25may2020)
replace pubhol=1 if date2==d(31aug2020)
replace pubhol=1 if date2==d(03may2021)
replace pubhol=1 if date2==d(31may2021)
replace pubhol=1 if date2==d(30aug2021)


*Merge on covid case counts
merge m:1 trperiod using "$dir/output/CovidNewCaseCounts.dta"
replace newcases=0 if newcases==.

export delimited using "$dir/output/check.csv", replace


** CITS model for first lockdown

preserve

drop if _t>61

* run itsa initially to get dummy variables
* tsset dva trperiod
* xi: itsa consultations i.month , treat(1) trperiod(30 37) replace, if trperiod<=61

* run NegBin model using variables defined above: z=group x=period(pre/post) t=time
xi: glm consultations _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37, family(nb) link(log) exposure(population) 

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

graph twoway (line dva_pred_rate time if _z==1, lcolor(black)) (line dva_pred_rate time if _z==0, lcolor(gray)) (scatter value time if _z==1, mcolor(black) msymbol(o)) (scatter value time if _z==0, mcolor(gray) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash)) xline(8, lcolor(black) lpattern(dash)) xscale(range(-30 32)) xlabel(-30 -20 -10 0 10 20 30)

graph export "$dir/output/dva_plot1.pdf", as(pdf) replace

restore

** CITS model for second and thrid lockdowns

drop if date2<d(11may2020)|date2>d(20sep2021)

* run itsa initially to get dummy variables
* xi: itsa consultations i.month, treat(1) trperiod(62 83) replace, if date2>d(13may2020)&date2<=d(20sep2021)

* run NegBin model using variables defined above: z=group x=period(pre/post) t=time
xi: glm consultations i.month xmas ny easter pubhol _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83, family(nb) link(log) exposure(population) 

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

graph twoway (line dva_pred_rate2 time if _z==1, lcolor(black)) (line dva_pred_rate2 time if _z==0, lcolor(gray)) (scatter value time if _z==1, mcolor(black) msymbol(o)) (scatter value time if _z==0, mcolor(gray) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(33, lcolor(black) lpattern(dash)) xline(54, lcolor(black) lpattern(dash)) xscale(range(8 79)) xlabel(10 20 30 40 50 60 70 80)

graph export "$dir/output/dva_plot2.pdf", as(pdf) replace