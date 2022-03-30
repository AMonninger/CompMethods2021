********************************************************************************
*** CORONA AND THE STOCK MARKET
*** AUTHOR: ADRIAN MONNINGER
*** PROJECT ID: 2020/0084
*** DATA: Bundesbank Online Pilot Survey on Consumer Expectations Scientific Use File (SUF) Version 1.3

*** STOCK MARKET DEVELOPMENTS (S&P 500, DAX, Eurostoxx)
********************************************************************************
*** S&P 500
import excel "C:\Users\adria\Desktop\Data\stocks\SP500.xls", sheet("FRED Graph") cellrange(A1088:B1317) clear
* date
rename A date
format date %d
rename B sp500
replace sp500 = . if sp500==0
tsset  date, daily

twoway(line sp500 date, tlabel(01jan2020 01apr2020 01jul2020 01oct2020, format(%tdmd))), ///
xtitle(" ") ytitle("S&P 500") title("S&P 500")
// graph export "${OUTPUT}/graph/stock_market/sp500.png", replace
graph export "${GRAPH}/sp500.png", replace


*** EUROSTOXX 50
import delimited "C:\Users\adria\Desktop\Data\stocks\Euro Stoxx 50 Historical Data.csv", varnames(1) clear 
*** date
rename ïdate idate
generate month_aux = substr(idate,1,3)
gen month_aux2 = .
replace month_aux2 = 1 if month_aux=="Jan"
replace month_aux2 = 2 if month_aux=="Feb"
replace month_aux2 = 3 if month_aux=="Mar"
replace month_aux2 = 4 if month_aux=="Apr"
replace month_aux2 = 5 if month_aux=="May"
replace month_aux2 = 6 if month_aux=="Jun"
replace month_aux2 = 7 if month_aux=="Jul"
replace month_aux2 = 8 if month_aux=="Aug"
replace month_aux2 = 9 if month_aux=="Sep"
replace month_aux2 = 10 if month_aux=="Oct"
replace month_aux2 = 11 if month_aux=="Nov"
replace month_aux2 = 12 if month_aux=="Dez"

generate day_aux = substr(idate, 5,2)
destring day_aux, replace
generate year_aux = substr(idate, 9,4)
destring year_aux, replace
gen date = mdy(month_aux2,day,year)
tsset  date, daily

gen price_aux = substr(price,1,1)
gen price_aux2 = substr(price,3,.)
gen eurostoxx = price_aux + price_aux2
destring eurostoxx, replace
keep date eurostoxx

twoway(line eurostoxx date, tlabel(01jan2020 01apr2020 01jul2020 01oct2020, format(%tdmd))), ///
xtitle(" ") ytitle("Eurostoxx 50") title("Eurostoxx 50")
// graph export "${OUTPUT}/graph/stock_market/eurostoxx50.png", replace
graph export "${GRAPH}/eurostoxx50.png", replace


*** Dax
import delimited "C:\Users\adria\Desktop\Data\stocks\DAX Historical Data.csv", varnames(1) clear 
*** date
rename ïdate idate
generate month_aux = substr(idate,1,3)
gen month_aux2 = .
replace month_aux2 = 1 if month_aux=="Jan"
replace month_aux2 = 2 if month_aux=="Feb"
replace month_aux2 = 3 if month_aux=="Mar"
replace month_aux2 = 4 if month_aux=="Apr"
replace month_aux2 = 5 if month_aux=="May"
replace month_aux2 = 6 if month_aux=="Jun"
replace month_aux2 = 7 if month_aux=="Jul"
replace month_aux2 = 8 if month_aux=="Aug"
replace month_aux2 = 9 if month_aux=="Sep"
replace month_aux2 = 10 if month_aux=="Oct"
replace month_aux2 = 11 if month_aux=="Nov"
replace month_aux2 = 12 if month_aux=="Dez"

generate day_aux = substr(idate, 5,2)
destring day_aux, replace
generate year_aux = substr(idate, 9,4)
destring year_aux, replace
gen date = mdy(month_aux2,day,year)
tsset  date, daily

forvalues i=1/10 {
gen price_aux`i' = substr(price,`i',1)
replace price_aux`i' = "" if price_aux`i'==","
} 

gen price_aux = substr(price,1,1)

// gen price_aux2 = substr(price,4,.)
gen dax = price_aux1 + price_aux2 + price_aux3 + price_aux4 + price_aux5 + price_aux6 + price_aux7 + price_aux8 + price_aux9
destring dax, replace
keep date dax

twoway(line dax date, tlabel(01jan2020 01apr2020 01jul2020 01oct2020, format(%tdmd))), ///
xtitle(" ") ytitle("Dax") title("Dax")
// graph export "${OUTPUT}/graph/stock_market/dax.png", replace
graph export "${GRAPH}/dax.png", replace

/*
********************************************************************************
*** Dax Historic Data
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
*gen age = 2020-year


**** gen weights
// clear
// set obs 1
// local k1 = 1
// local k2 = 1.433
// local k3 = 1.325
// local k4 = 1.166
// local k5 = 1.50

forvalues ver = 1/5 {
clear
set obs 1
local k1 = 1
local k2 = 1.433
local k3 = 1.325
local k4 = 1.166
local k5 = 1.50

forvalues age = 18/61 {
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

// forvalues age = 18/61 {
// gen weight_`age' = .
// } 

gen weight_age = 0

reshape long weight_18_ weight_19_ weight_20_ weight_21_ weight_22_ weight_23_ weight_24_ weight_25_ weight_26_ weight_27_ weight_28_ weight_29_ ///
weight_30_ weight_31_ weight_32_ weight_33_ weight_34_ weight_35_ weight_36_ weight_37_ weight_38_ weight_39_ /// 
weight_40_ weight_41_ weight_42_ weight_43_ weight_44_ weight_45_ weight_46_ weight_47_ weight_48_ weight_49_ ///
weight_50_ weight_51_ weight_52_ weight_53_ weight_54_ weight_55_ weight_56_ weight_57_ weight_58_ weight_59_ ///
weight_60_ weight_61_ , i(weight_age) j(year)
drop weight_age
// gen age = .
forvalues age = 18/61 {
rename weight_`age'_ weight_`age'
}
reshape long weight_, i(year) j(age)
rename weight_ weight_v`ver'
save "${OUTPUT}/weight_vk`ver'.dta", replace
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


/*
gen k = age
gen lambda = 1
gen weight =.
gen R = .

forvalues x = 16/61{

	replace R = yrret[yri - `x',1] if age> `x'
	
	gen weight_nom = R*(age - k)^lambda if age > `x'
	gen weight_den = (R^2)*(age - k)^lambda
	replace weight = 


replace R = dax 

}


***
local k1 1
local k2 1.433
local k3 1.325
local k4 1.166
local k5 1.50
forvalues j=1/5 {
   qui gen f`j' = 0
   qui gen w`j' = 0
   qui gen v`j' = 0
   }
quietly gen lret = . 
// quietly gen yri = rownumb(yrret,string(year)) 
forvalues i=1/61 {
//      qui replace lret = yrret[yri-`i',1] if age > `i'
	 qui replace lret = R[_n-`i'] if age > `i' 
     forvalues j=1/5 {
       qui replace f`j' = f`j' + lret*((age-`i')/age)^`k`j'' if age > `i'
       qui replace v`j' = v`j' + (lret^2)*((age-`i')/age)^`k`j'' if age > `i'
       qui replace w`j' = w`j' + ((age-`i')/age)^`k`j'' if age > `i'
     }
}
qui gen retave1 = f1/w1
qui gen retave1433 = f2/w2
qui gen retave1325 = f3/w3
qui gen retave1166 = f4/w4
qui gen retave150 = f5/w5
qui gen ret2ave1 = sqrt(v1/w1-(f1/w1)^2)
qui gen ret2ave1433 = sqrt(v2/w2-(f2/w2)^2)
qui gen ret2ave1325 = sqrt(v3/w3-(f3/w3)^2)
qui gen ret2ave1166 = sqrt(v4/w4-(f4/w4)^2)
qui gen ret2ave150 = sqrt(v5/w5-(f5/w5)^2)

drop f1 f2 f3 f4 f5
drop w1 w2 w3 w4 w5
drop v1 v2 v3 v4
drop lret 
// drop yri
