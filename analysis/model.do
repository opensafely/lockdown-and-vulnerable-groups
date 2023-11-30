
/********************************************************************/
/* Project repo:	opensafely/lockdown-and-vulnerable-groups  		*/
/* Program author:	Scott Walter (Git: SRW612) 						*/

/* Data used:		output/measure_<group>_rate.csv					*/
					
/* Outputs:			analysis/diagnostics/<group>_diagnostics1.svg	*/
/*					analysis/diagnostics/<group>_diagnostics2.svg	*/
/*					output/<group>_plot1.svg						*/
/*					output/<group>_plot2.svg						*/								*/
/*					output/<group>_RR_LD1.dta					*/
/*					output/<group>_RD_LD1.dta					*/
/*					output/<group>_RR_LD2.dta					*/
/*					output/<group>_RD_LD2.dta					*/

/* Purpose:			Run CITS models of GP contact rates through		*/
/*					Covid lockdowns 								*/
/********************************************************************/


/* PREAMBLE */

global dir `c(pwd)'

di "$dir"

local group "`1'"

di "Arguments: (1) `group'"

adopath + "$dir/analysis/adofiles"

capture confirm file "$dir/output/diagnostics/"
if _rc mkdir "$dir/output/diagnostics/"

set scheme s1color


* Source functions

run "$dir/analysis/functions/reformat-output.do"


*Get data
use "$dir/output/measure_`group'_rate.dta", clear
count

ta `group'

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

sort `group' time
by `group': gen trperiod=_n

*define interaction terms as per the itsa function
gen _z=`group'
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


save "$dir/output/`group'.dta", replace

*summary stats
tabstat consultations population if _z==0, statistics(mean) by(period) format(%20.2f)
tabstat consultations population if _z==1, statistics(mean) by(period) format(%20.2f)


/*** CITS model for first lockdown ***/

drop if _t>61
drop if _t<4

** Main model: NegBin regression using variables defined above: z=group x=period(pre/post) t=time
 * Relative change -> log link
glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37, family(nb ml) link(log) exposure(population) vce(robust) eform

*export model outputs
putexcel set "$dir/output/CITS_`group'_RR_LD1.xlsx", sheet("main") replace
putexcel A1=matrix(r(table)'), names

nlcom (t_xt30:_b[_t]+_b[_x_t30]) (t_xt37:_b[_t]+_b[_x_t37]) (t_zt:_b[_t]+_b[_z_t]) (t_zt_xt30_zxt30:_b[_t]+_b[_z_t]+_b[_x_t30]+_b[_z_x_t30]) ///
	  (t_zt_xt37_zxt37:_b[_t]+_b[_z_t]+_b[_x_t37]+_b[_z_x_t37]) (x30_zx30:_b[_x30]+_b[_z_x30]) (x37_zx37:_b[_x37]+_b[_z_x37]) ///
	  (xt30_zxt30:_b[_x_t30]+_b[_z_x_t30]) (xt37_zxt37:_b[_x_t37]+_b[_z_x_t37]), post

ereturn display /* r(table) for nlcom only seems to be saved when this line is run */
putexcel set "$dir/output/CITS_`group'_RR_LD1.xlsx", sheet("main") modify
putexcel B18=matrix(r(table)'), names 


*postestimation values for plotting
quietly: glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37, family(nb ml) link(log) exposure(population) vce(robust)

predict yhat
gen pred_rate=yhat/population
predict res, pearson
predict error, stdp
generate ll=pred_rate - invnormal(0.975)*error
generate ul=pred_rate + invnormal(0.975)*error

* model diagnostics
graph twoway (scatter res pred_rate), title("Pearson residuals vs. predicted rates") yline(0) name(graph1, replace)
graph twoway (scatter res time), title("Pearson residual vs. time") yline(0) name(graph2, replace)
qnorm res, title("QQplot of Pearson residuals") name(graph3, replace)
graph twoway (scatter value pred_rate) (line value value), title("Observed vs. predicted rates") name(graph4, replace)
graph combine graph1 graph2 graph3 graph4, title("`group' diagnostics - 1st lockdown")

graph export "$dir/output/diagnostics/`group'_diagnostics1.svg", replace

* plot observed and predicted values
graph twoway (rarea ll ul date2 if _z==1, sort lcolor(gray) fcolor(gs11) lwidth(0)) ///
(scatter value date2 if _z==0, mcolor(gray) msymbol(o)) ///
(scatter value date2 if _z==1, mcolor(black) msymbol(o)) ///
(line pred_rate date2 if _z==0, lcolor(gray)) ///
(line pred_rate date2 if _z==1, lcolor(black)), ///
legend(order(1 "Main series: 95%CI" 2 "Control series: observed rates" 3 "Main series: observed rates" 4 "Control series: model estimates" 5 "Main series: model estimates") size(small)) ///
xline(`=daily("27mar2020", "DMY")' `=daily("3apr2020", "DMY")' `=daily("10apr2020", "DMY")' `=daily("17apr2020", "DMY")' `=daily("24apr2020", "DMY")' ///
`=daily("1may2020", "DMY")' `=daily("8may2020", "DMY")', lwidth(vvthick) lcolor(gs14)) ///
xlabel(`=daily("23Sep2019", "DMY")' `=daily("23Mar2020", "DMY")' `=daily("11May2020", "DMY")' `=daily("1Nov2020", "DMY")', format(%td) labsize(vsmall)) ///
xtitle(" ") ///
ttext(0.5 17apr2020 "First lockdown period", size(small)) ///
yscale(range(0 0.5)) ylabel(0 0.1 0.2 0.3 0.4 0.5) ///
ytitle("GP consultations per patient per week") ///
graphregion(color(white)) bgcolor(white)

graph export "$dir/output/`group'_plot1.svg", replace


*Reformat saved model outputs
reformat "`group'" "RR" "1"


** Risk difference model -> id link

use "$dir/output/`group'.dta", clear

drop if _t>61
drop if _t<4

glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x30 _x_t30 _z_x30 _z_x_t30 _x37 _x_t37 _z_x37 _z_x_t37, family(poisson) link(id) exposure(population) vce(robust)

*export model outputs and reformat
putexcel set "$dir/output/CITS_`group'_RD_LD1.xlsx", sheet("main") replace
putexcel A1=matrix(r(table)'), names 

nlcom (t_xt30:_b[_t]+_b[_x_t30]) (t_xt37:_b[_t]+_b[_x_t37]) (t_zt:_b[_t]+_b[_z_t]) (t_zt_xt30_zxt30:_b[_t]+_b[_z_t]+_b[_x_t30]+_b[_z_x_t30]) ///
	  (t_zt_xt37_zxt37:_b[_t]+_b[_z_t]+_b[_x_t37]+_b[_z_x_t37]) (x30_zx30:_b[_x30]+_b[_z_x30]) (x37_zx37:_b[_x37]+_b[_z_x37]) ///
	  (xt30_zxt30:_b[_x_t30]+_b[_z_x_t30]) (xt37_zxt37:_b[_x_t37]+_b[_z_x_t37]), post

ereturn display /* r(table) for nlcom only seems to be saved when this line is run */
putexcel set "$dir/output/CITS_`group'_RD_LD1.xlsx", sheet("main") modify
putexcel B18=matrix(r(table)'), names 

*Reformat saved model outputs
reformat "`group'" "RD" "1"


/*** CITS model for second/thrid lockdown ***/

use "$dir/output/`group'.dta", clear

drop if date2<d(11may2020)|date2>d(20sep2021)


** Main model: NegBin regression using variables defined above: z=group x=period(pre/post) t=time
 * Relative change -> log link
glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83, family(nb ml) link(log) exposure(population) vce(robust)

*export model outputs and reformat
putexcel set "$dir/output/CITS_`group'_RR_LD2.xlsx", sheet("main") replace
putexcel A1=matrix(r(table)'), names 

nlcom (t_xt62:_b[_t]+_b[_x_t62]) (t_xt83:_b[_t]+_b[_x_t83]) (t_zt:_b[_t]+_b[_z_t]) (t_zt_xt62_zxt62:_b[_t]+_b[_z_t]+_b[_x_t62]+_b[_z_x_t62]) ///
	  (t_zt_xt83_zxt83:_b[_t]+_b[_z_t]+_b[_x_t83]+_b[_z_x_t83]) (x62_zx62:_b[_x62]+_b[_z_x62]) (x83_zx83:_b[_x83]+_b[_z_x83]) ///
	  (xt62_zxt62:_b[_x_t62]+_b[_z_x_t62]) (xt83_zxt83:_b[_x_t83]+_b[_z_x_t83]), post

ereturn display /* r(table) for nlcom only seems to be saved when this line is run */
putexcel set "$dir/output/CITS_`group'_RR_LD2.xlsx", sheet("main") modify
putexcel B18=matrix(r(table)'), names 


*postestimation values for plotting
quietly: glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83, family(nb ml) link(log) exposure(population) vce(robust)

predict yhat
gen pred_rate=yhat/population
predict res, pearson
predict error, stdp
generate ll=pred_rate - invnormal(0.975)*error
generate ul=pred_rate + invnormal(0.975)*error

* model diagnostics
graph twoway (scatter res pred_rate), title("Pearson residuals vs. predicted rates") yline(0) name(graph1, replace)
graph twoway (scatter res time), title("Pearson residual vs. time") yline(0) name(graph2, replace)
qnorm res, title("QQplot of Pearson residuals") name(graph3, replace)
graph twoway (scatter value pred_rate) (line value value), title("Observed vs. predicted rates") name(graph4, replace)
graph combine graph1 graph2 graph3 graph4, title("`group' diagnostics - 2nd lockdown")

graph export "$dir/output/diagnostics/`group'_diagnostics2.svg", replace

* plot observed and predicted values
graph twoway (rarea ll ul date2 if _z==1, sort lcolor(gray) fcolor(gs11) lwidth(0)) ///
(scatter value date2 if _z==0, mcolor(gray) msymbol(o)) ///
(scatter value date2 if _z==1, mcolor(black) msymbol(o)) ///
(line pred_rate date2 if _z==0, lcolor(gray)) ///
(line pred_rate date2 if _z==1, lcolor(black)), ///
legend(order(1 "Main series: 95%CI" 2 "Control series: observed rates" 3 "Main series: observed rates" 4 "Control series: model estimates" 5 "Main series: model estimates") size(small)) ///
xline(`=daily("27mar2020", "DMY")' `=daily("3apr2020", "DMY")' `=daily("10apr2020", "DMY")' `=daily("17apr2020", "DMY")' `=daily("24apr2020", "DMY")' ///
`=daily("1may2020", "DMY")' `=daily("8may2020", "DMY")', lwidth(vvthick) lcolor(gs14)) ///
xlabel(`=daily("23Sep2019", "DMY")' `=daily("23Mar2020", "DMY")' `=daily("11May2020", "DMY")' `=daily("1Nov2020", "DMY")', format(%td) labsize(vsmall)) ///
xtitle(" ") ///
ttext(0.5 17apr2020 "Second and third lockdown period", size(small)) ///
yscale(range(0 0.5)) ylabel(0 0.1 0.2 0.3 0.4 0.5) ///
ytitle("GP consultations per patient per week") ///
graphregion(color(white)) bgcolor(white)

graph export "$dir/output/`group'_plot2.svg", replace

*Reformat saved model outputs
reformat "`group'" "RR" "2"


** Risk difference -> id link

use "$dir/output/`group'.dta", clear
drop if date2<d(11may2020)|date2>d(20sep2021)

glm consultations /*i.month*/ xmas ny easter pubhol _t _z _z_t _x62 _x_t62 _z_x62 _z_x_t62 _x83 _x_t83 _z_x83 _z_x_t83, family(poisson) link(id) exposure(population) vce(robust)

*export model outputs and reformat
putexcel set "$dir/output/CITS_`group'_RD_LD2.xlsx", sheet("main") replace
putexcel A1=matrix(r(table)'), names 

nlcom (t_xt62:_b[_t]+_b[_x_t62]) (t_xt83:_b[_t]+_b[_x_t83]) (t_zt:_b[_t]+_b[_z_t]) (t_zt_xt62_zxt62:_b[_t]+_b[_z_t]+_b[_x_t62]+_b[_z_x_t62]) ///
	  (t_zt_xt83_zxt83:_b[_t]+_b[_z_t]+_b[_x_t83]+_b[_z_x_t83]) (x62_zx62:_b[_x62]+_b[_z_x62]) (x83_zx83:_b[_x83]+_b[_z_x83]) ///
	  (xt62_zxt62:_b[_x_t62]+_b[_z_x_t62]) (xt83_zxt83:_b[_x_t83]+_b[_z_x_t83]), post

ereturn display /* r(table) for nlcom only seems to be saved when this line is run */
putexcel set "$dir/output/CITS_`group'_RD_LD2.xlsx", sheet("main") modify
putexcel B18=matrix(r(table)'), names 

*Reformat saved model outputs
reformat "`group'" "RD" "2"





