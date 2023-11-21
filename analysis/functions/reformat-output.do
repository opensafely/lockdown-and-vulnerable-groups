

** Program to reformat regression results

cap prog drop reformat
prog def reformat

* Define arguments ---------------------------------------------------------

args group measure lockdown

*Get data
	
import excel "$dir/output/CITS_`group'_`measure'_LD`lockdown'.xlsx", firstrow clear

*Transpose

drop Q

rename (A consultations C D E F G H I J K L M N O P xlincom S T U V W X Y Z) ///
	   (stat v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24) 

reshape long v, i(stat) j(id) 
drop if stat==""
reshape wide v, i(id) j(stat) string 
rename (v*) (*) 

drop crit df eform z
gen var="xmas" if id==1
replace var="ny" if id==2
replace var="easter" if id==3
replace var="pubhol" if id==4
replace var="_t" if id==5
replace var="_z" if id==6
replace var="_z_t" if id==7
replace var="_x30" if id==8
replace var="_x_t30" if id==9
replace var="_z_x30" if id==10
replace var="_z_x_t30" if id==11
replace var="_x37" if id==12
replace var="_x_t37" if id==13
replace var="_z_x37" if id==14
replace var="_z_x_t37" if id==15
replace var="_t+_x_t30" if id==16 
replace var="_t+_x_t37" if id==17
replace var="_t+_z_t" if id==18
replace var="_t +_z_t+_x_t30+_z_x_t30" if id==19
replace var="_t+_z_t+_x_t37+_z_x_t37" if id==20
replace var="_x30+_z_x30" if id==21
replace var="_x37+_z_x37" if id==22
replace var="_x_t30+_z_x_t30" if id==23
replace var="_x_t37+_z_x_t37" if id==24

drop id

order var b se ll ul pvalue

gen model="`group'"
gen measure="`measure'"
lockdown="`lockdown'"

save "$dir/output/`group'_`measure'_LD`lockdown'.dta", replace

end
