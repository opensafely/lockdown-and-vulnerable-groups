
/****************************************************************/
/* Project repo:	opensafely/lockdown-and-vulnerable groups  	*/
/* Program author:	Scott Walter (Git: SRW612) 					*/

/* Data used:		output/intdis_over14.dta					*/
					
/* Outputs:			analysis/diagnostics/intdis_diagnostics_sr1.svg	*/
/*					analysis/diagnostics/intdis_diagnostics_sr2.svg	*/
/*					output/intdis_ratioLoess_sr1.svg				*/
/*					output/intdis_ratioLoess_sr2.svg				*/
/*					output/intdis_over14_plot1.svg					*/
/*					output/intdis_over14_plot2.svg					*/
/*					output/intdis_over14_2.dta						*/
/*					output/intdis_over14_2_ld1.dta					*/
/*					output/intdis_over14_2_ld2.dta					*/
/*					output/CITS_intdis_over14.xlsx					*/

/* Purpose:			Run CITS models of GP contact rates through	*/
/*					Covid lockdowns for people with intellectual*/
/*					disability aged under 14					*/
/****************************************************************/


/* PREAMBLE */

global dir "`c(pwd)'"

*global dir "C:/Users/dy21108/OneDrive - University of Bristol/Documents/GitHub/lockdown-and-vulnerable-groups"

adopath + "$dir/analysis/adofiles"

capture confirm file "$dir/output/diagnostics/"
if _rc mkdir "$dir/output/diagnostics/"

set scheme s1color


*Get data
use "$dir/output/intdis_over14.dta", clear

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

sort intdis time
by intdis: gen trperiod=_n

*define interaction terms as per the itsa function
gen _z=intdis 
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
  replace _x62=1 if period>=3
gen _x_t62=_x62*(_t-62)
gen _z_x62=_z*_x62
gen _z_x_t62=_z_x62*(_t-62)

gen _x83=0
  replace _x83=1 if period>=4
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

*add control group rates as a covariate
sort date2 _z
gen control_rate=value[_n-1]
replace control_rate=. if _z==0

save "$dir/output/intdis_over14_2.dta", replace

*summary stats
tabstat consultations_over14 population_over14 if _z==0, statistics(mean) by(period)
tabstat consultations_over14 population_over14 if _z==1, statistics(mean) by(period)


/*** CITS model for first lockdown ***/

drop if _t>61

** Simple model of rate ratio
generate rr=value_over14/control_rate
xi: glm rr _t _x30 _x_t30 _x37 _x_t37, family(gaussian) link(id)
predict yhat_rr
graph twoway (line yhat_rr date2 if _z==1, lcolor(black)) (scatter rr date2 if _z==1, mcolor(black) msymbol(o)), xline(`=daily("23mar2020", "DMY")' `=daily("13may2020", "DMY")')
graph export "$dir/output/intdis_ratioLoess_sr1.svg", replace


** Main model: NegBin regression using variables defined above: z=group x=period(pre/post) t=time
xi: glm consultations_over14 i.month xmas ny easter pubhol _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37, family(nb ml) link(log) exposure(population_over14) vce(robust)

*export model outputs
putexcel set "$dir/output/CITS_intdis_over14.xlsx", sheet("Intdis_over14_1") replace
putexcel A1=matrix(r(table)), names 

*postestimation values for plotting
predict intdis_yhat
gen intdis_pred_rate=intdis_yhat/population_over14
predict res, pearson
predict error, stdp
generate ll=(intdis_yhat - invnormal(0.975)*error)/population_over14
generate ul=(intdis_yhat + invnormal(0.975)*error)/population_over14

list intdis_yhat intdis_pred_rate res error population_over14 value_over14 ul ll if _z==1&_n<10

save "$dir/output/intdis_over14_2_ld1.dta", replace

* model diagnostics
graph twoway (scatter res intdis_pred_rate), title("Pearson residuals vs. predicted rates") yline(0) name(graph1, replace)
graph twoway (scatter res time), title("Pearson residual vs. time") yline(0) name(graph2, replace)
qnorm res, title("QQplot of Pearson residuals") name(graph3, replace)
graph twoway (scatter value_over14 intdis_pred_rate) (line value_over14 value_over14), title("Observed vs. predicted rates") name(graph4, replace)
graph combine graph1 graph2 graph3 graph4, title("Intellectual disability (<14) diagnostics - 1st lockdown")

graph export "$dir/output/diagnostics/intdis_diagnostics_sr1.svg", replace

* plot observed and predicted values
graph twoway (rarea ll ul date2 if _z==1, sort lcolor(gray) fcolor(gs11) lwidth(0)) ///
(scatter value_over14 date2 if _z==0, mcolor(gray) msymbol(o)) ///
(scatter value_over14 date2 if _z==1, mcolor(black) msymbol(o)) ///
(line intdis_pred_rate date2 if _z==0, lcolor(gray)) ///
(line intdis_pred_rate date2 if _z==1, lcolor(black)), ///
legend(order(1 "Main series: 95%CI" 2 "Control series: observed rates" 3 "Main series: observed rates" 4 "Control series: model estimates" 5 "Main series: model estimates") size(small)) ///
xline(`=daily("27mar2020", "DMY")' `=daily("3apr2020", "DMY")' `=daily("10apr2020", "DMY")' `=daily("17apr2020", "DMY")' `=daily("24apr2020", "DMY")' ///
`=daily("1may2020", "DMY")' `=daily("8may2020", "DMY")', lwidth(vvthick) lcolor(gs14)) ///
xlabel(`=daily("2sep2019", "DMY")' `=daily("2dec2019", "DMY")' `=daily("23mar2020", "DMY")' `=daily("13may2020", "DMY")' `=daily("1sep2020", "DMY")', format(%td) labsize(vsmall)) ///
xtitle(" ") ///
ttext(0.5 17apr2020 "First lockdown period", size(small)) ///
yscale(range(0 0.5)) ylabel(0 0.1 0.2 0.3 0.4 0.5) ///
ytitle("GP consultations per patient per week") ///
graphregion(color(white)) bgcolor(white)

graph export "$dir/output/intdis_over14_plot1.svg", replace


/*** CITS model for second and third lockdowns ***/

use "$dir/output/intdis_over14_2.dta", clear

drop if date2<d(11may2020)|date2>d(20sep2021)


**Simple model of rate ratio
generate rr2=value_over14/control_rate
xi: glm rr2 _t _x62 _x_t62 _x83 _x_t83, family(gaussian) link(id)
predict yhat_rr2
graph twoway (line yhat_rr2 date2 if _z==1, lcolor(black)) (scatter rr2 date2 if _z==1, mcolor(black) msymbol(o)), xline(`=daily("5nov2020", "DMY")' `=daily("29mar2021", "DMY")')
graph export "$dir/output/intdis_ratioLoess_sr2.svg", replace


** Main model: NegBin regression using variables defined above: z=group x=period(pre/post) t=time
xi: glm consultations_over14 i.month xmas ny easter pubhol _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83, family(nb ml) link(log) exposure(population_over14) vce(robust)

*export model outputs
putexcel set "$dir/output/CITS_intdis_over14.xlsx", sheet("intdis_over14_2") modify
putexcel A1=matrix(r(table)), names 

*postestimation values for plotting
predict intdis_yhat2
gen intdis_pred_rate2=intdis_yhat2/population_over14
predict res2, pearson
predict error2, stdp
generate ll2=(intdis_yhat2 - invnormal(0.975)*error2)/population_over14
generate ul2=(intdis_yhat2 + invnormal(0.975)*error2)/population_over14

list value_over14 ul2 ll2 if _z==1&_n<10

save "$dir/output/intdis_over14_2_ld2.dta", replace

* model diagnostics
graph twoway (scatter res2 intdis_pred_rate2), title("Pearson residuals vs. predicted rates") yline(0) name(graph1, replace)
graph twoway (scatter res2 time), title("Pearson residual vs. time") yline(0) name(graph2, replace)
qnorm res2, title("QQplot of Pearson residuals") name(graph3, replace)
graph twoway (scatter value_over14 intdis_pred_rate2) (line value_over14 value_over14), title("Observed vs. predicted rates") name(graph4, replace)
graph combine graph1 graph2 graph3 graph4, title("Intellectual disability (<14) diagnostics - 2nd & 3rd lockdowns")

graph export "$dir/output/diagnostics/intdis_diagnostics_sr2.svg", replace

* plot observed and predicted values
graph twoway (rarea ll2 ul2 date2 if _z==1, sort lcolor(gray) fcolor(gs11) lwidth(0)) ///
(scatter value_over14 date2 if _z==0, mcolor(gray) msymbol(o)) ///
(scatter value_over14 date2 if _z==1, mcolor(black) msymbol(o)) ///
(line intdis_pred_rate date2 if _z==0, lcolor(gray)) ///
(line intdis_pred_rate date2 if _z==1, lcolor(black)), ///
legend(order(1 "Main series: 95%CI" 2 "Control series: observed rates" 3 "Main series: observed rates" 4 "Control series: model estimates" 5 "Main series: model estimates") size(small)) ///
xline(`=daily("12nov2020", "DMY")' `=daily("19nov2020", "DMY")' `=daily("26nov2020", "DMY")' `=daily("3dec2020", "DMY")' `=daily("10dec2020", "DMY")' ///
`=daily("17dec2020", "DMY")' `=daily("24dec2020", "DMY")' `=daily("31dec2020", "DMY")' `=daily("7jan2021", "DMY")' `=daily("15jan2021", "DMY")' ///
 `=daily("21jan2021", "DMY")' `=daily("28jan2021", "DMY")' `=daily("4feb2021", "DMY")' `=daily("11feb2021", "DMY")' `=daily("18feb2021", "DMY")'  ///
 `=daily("25feb2021", "DMY")'  `=daily("4mar2021", "DMY")'  `=daily("11mar2021", "DMY")'  `=daily("18mar2021", "DMY")'  `=daily("25mar2021", "DMY")', ///
lwidth(vvthick) lcolor(gs14)) ///
xlabel(`=daily("11may2020", "DMY")' `=daily("10aug2020", "DMY")' `=daily("5nov2020", "DMY")' `=daily("29mar2021", "DMY")' `=daily("29jun2021", "DMY")', format(%td) labsize(vsmall)) ///
xtitle(" ") ///
ttext(0.5 17jan2021 "Second and third lockdown periods", size(small)) ///
yscale(range(0 0.5)) ylabel(0 0.1 0.2 0.3 0.4 0.5) ///
ytitle("GP consultations per patient per week") ///
graphregion(color(white)) bgcolor(white)

graph export "$dir/output/intdis_over14_plot2.svg", replace

