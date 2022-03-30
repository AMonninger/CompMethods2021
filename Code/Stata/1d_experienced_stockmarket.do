*** Dax Historic Data
/*
import excel "C:\Users\adria\OneDrive\Dokumente\Corona and the Stockmarket\dax_historic_data.xlsx", sheet("Daten") cellrange(B6:C39) clear

rename (B C)(year dax)
destring year, replace
destring dax, replace
save "${OUTPUT}/dax.dta", replace

import excel "C:\Users\adria\OneDrive\Dokumente\Corona and the Stockmarket\dax_historic_data.xlsx", sheet("Historic") firstrow clear
append using "${OUTPUT}/dax.dta"

sort year
gen R = (dax - dax[_n-1])/(dax[_n-1])

save "${OUTPUT}/dax_historic.dta", replace

**** gen weights
forvalues ver = 1/5 {
quietly{
clear
set obs 1
local k1 = 1
local k2 = 1.433
local k3 = 1.325
local k4 = 1.166
local k5 = 1.50

forvalues age = 16/61 {
// forvalues age = 18/40 {
gen den_weight_`age' = 0
local age_min1 = `age' - 1
forvalues i = 1/`age_min1' {
replace den_weight_`age' = den_weight_`age' + `i'^`k`ver''
}

local birthyear = 2020-`age'

forvalues year = `birthyear'/2019 {
gen weight_`age'_`year' = ((`year' - `birthyear')^`k`ver'')/den_weight_`age'
}
}

* do the weights sum up to 1?
egen weighttotal_18 = rsum(weight_18_2019 weight_18_2018 weight_18_2017 weight_18_2016 weight_18_2015 weight_18_2014 weight_18_2013 weight_18_2012 weight_18_2011 weight_18_2010 weight_18_2009 weight_18_2008 weight_18_2007 weight_18_2006 weight_18_2005 weight_18_2004 weight_18_2003 weight_18_2002)
sum weighttotal_18
drop weighttotal_18
drop den*

gen weight_age = 0

reshape long weight_16_ weight_17_ weight_18_ weight_19_ weight_20_ weight_21_ weight_22_ weight_23_ weight_24_ weight_25_ weight_26_ weight_27_ weight_28_ weight_29_ ///
weight_30_ weight_31_ weight_32_ weight_33_ weight_34_ weight_35_ weight_36_ weight_37_ weight_38_ weight_39_ /// 
weight_40_ weight_41_ weight_42_ weight_43_ weight_44_ weight_45_ weight_46_ weight_47_ weight_48_ weight_49_ ///
weight_50_ weight_51_ weight_52_ weight_53_ weight_54_ weight_55_ weight_56_ weight_57_ weight_58_ weight_59_ ///
weight_60_ weight_61_ , i(weight_age) j(year)
drop weight_age
// gen age = .
forvalues age = 16/61 {
rename weight_`age'_ weight_`age'
}
reshape long weight_, i(year) j(age)
rename weight_ weight_v`ver'
save "${OUTPUT}/weight_vk`ver'.dta", replace
}
}
use "${OUTPUT}/weight_vk1.dta", clear
forvalues ver = 2/5{
merge 1:1 year age using "${OUTPUT}/weight_vk`ver'.dta"
drop _m
}
merge m:1 year using "${OUTPUT}/dax_historic.dta"
drop if _m!=3
drop _m

forvalues ver = 1/5{
gen exp_v`ver' = weight_v`ver' * R
}

collapse (sum) exp_v*, by(age)

save "${OUTPUT}/dax_experience.dta", replace


********************************************************************************
*** Experienced Stock Market Volatility
import delimited "C:\Users\adria\OneDrive\Dokumente\Corona and the Stockmarket\GDAXI_historic_data_yahoo.csv", varnames(1) clear
* only need year
gen year = substr(date,1,4)
keep year close
* destring
destring year, replace
replace close = "" if close == "null"
destring close, replace

collapse (sd) close, by(year)
rename close dax_sd
save "${OUTPUT}/dax_historic_sd.dta", replace

*** weight by year
use "${OUTPUT}/weight_vk1.dta", clear
forvalues ver = 2/5{
merge 1:1 year age using "${OUTPUT}/weight_vk`ver'.dta"
drop _m
}
merge m:1 year using "${OUTPUT}/dax_historic_sd.dta"
drop if _m!=3
drop _m

forvalues ver = 1/5{
gen dax_sd_v`ver' = weight_v`ver' * dax_sd
}

collapse (sum) dax_sd_v*, by(age)

save "${OUTPUT}/dax_experienced_sd.dta", replace
*/
use "${OUTPUT}/data", clear
merge m:1 age using "${OUTPUT}/dax_experience.dta"
drop _m
merge m:1 age using "${OUTPUT}/dax_experienced_sd.dta"
drop _m
save "${OUTPUT}/data",replace
