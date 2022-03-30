********************************************************************************
*** USING PHF WAVE 3 TO ASSESS REPRESENTATIVENESS OF MY SAMPLE
********************************************************************************
use "${PHF}/PHF_p_wave3_v2_0.dta", clear
keep if pid == 1

merge 1:1 hhid impid using "${PHF}/PHF_h_wave3_v2_0.dta"
drop _m
merge 1:1 hhid impid using "${PHF}/PHF_d_wave3_v2_0.dta"
drop _m
* gender
gen gender = dpe9040

* age
gen age = ra0300

gen cohort = .
replace cohort = 1 if age <31
replace cohort = 2 if age>=31 & age <41
replace cohort = 3 if age>=41 & age <51
replace cohort = 4 if age>=51 & age <61
replace cohort = 5 if age>=60
label define cohort_label 1 "$<30$" 2 "31-40" 3 "41-50" 4 "51-60" 5 "60+"
label value cohort cohort_label

* hh size
gen hhsize_cap3 = anzhhm
replace hhsize_cap3 = 3 if anzhhm >=3
label define hhsize_cap3_label 1 "1" 2 "2" 3 "3+"
label value hhsize_cap3 hhsize_cap3_label

* college
gen college = inlist(dpa0400,5,6,7)
label define college_label 1 "college" 0 "no college"
label value college college_label

* employment
gen self_emp = inlist(dpe0200a, 4,5)
label var self_emp "self-employed"

gen labor =.
replace labor = 1 if dpe0100a == 1
replace labor = 2 if dpe0100a == 2
replace labor = 3 if dpe0100a == 7| dpe0100a ==8
replace labor = 0 if labor ==.
replace labor = 4 if self_emp == 1

label define labor_label 1 "full-time" 2 "part-time" 3 "retired" 4 "self-employed" 0 "unemployed"
label value labor labor_label

* hh income
gen ddi2000_m = ddi2000/12
gen income=.
replace income = 1 if ddi2000_m<1500
replace income = 2 if ddi2000_m>=1500 & ddi2000_m<3000
replace income = 3 if ddi2000_m>=3000 & ddi2000_m<5000
replace income = 4 if ddi2000_m>=5000 & ddi2000_m<8000
replace income = 5 if ddi2000_m>=8000

label define income_label 1 "$<1500$" 2 "1500-3000" 3 "3000-5000" 4 "5000-8000" 5 "8000+"
label value income income_label

* home owner
generate owner = 1 if dhb0200a==1 | dhb0200b==1								
replace owner=0 if owner==.

* asset participation
gen has_funds = 1 if dda2102>0
replace has_funds = 0 if dda2102 == .
label var has_funds "has funds"
gen has_stocks = 1 if dda2105>0
replace has_stocks = 0 if dda2105 == .
label var has_stocks "has stocks"
gen has_bonds = 1 if dda2103> 0
replace has_bonds = 0 if dda2103 == .
label var has_bonds "has bonds"
gen has_other = 1 if dda2108> 0
replace has_other = 0 if dda2108 == .
label var has_other "has other"

gen has_some = 1 if has_funds==1 | has_stocks==1 | has_bonds==1 | has_other==1
replace has_some = 0 if has_some ==.

*** average
gen female = inlist(gender,2)

forvalues n = 1/3{
gen hhsize_`n' = inlist(hhsize_cap3,`n')
}

forvalues n = 1/5{
gen cohort_`n' = inlist(cohort,`n')
}

forvalues n = 0/4{
gen labor_`n' = inlist(labor,`n')
}

forvalues n = 1/5{
gen income_`n' = inlist(income,`n')
}


global PHF_VAR "female hhsize_1 hhsize_2 hhsize_3 cohort_1 cohort_2 cohort_3 cohort_4 cohort_5 college labor_0 labor_1 labor_2 labor_3 labor_4 income_1 income_2 income_3 income_4 income_5 owner has_some has_funds has_bonds has_stocks has_other"
collapse (mean) $PHF_VAR [pw=exhoch_hh]

foreach var in $PHF_VAR {
sca s_`var'_phf = 100*`var'
}

/*
* Education
gen college = inlist(eduwork,6,7,8)
label define college_label 1 "college" 0 "no college"
label value college college_label

* Labor Status
gen self_emp = inlist(profession, 4,5)
label var self_emp "self-employed"

gen labor =.
replace labor = 1 if employ == 1
replace labor = 2 if employ == 2
replace labor = 3 if employ == 7| employ ==8
replace labor = 0 if labor ==.
replace labor = 4 if self_emp == 1

label define labor_label 1 "full-time" 2 "part-time" 3 "retired" 4 "self-employed" 0 "unemployed"
label value labor labor_label


* Cohort



*** define income brackets 
gen income=.
replace income = 1 if hhinc<4
replace income = 2 if hhinc>=4 & hhinc<7
replace income = 3 if hhinc>=7 & hhinc<10
replace income = 4 if hhinc>=10 & hhinc<12
replace income = 5 if hhinc>=12

label define income_label 1 "$<1500$" 2 "1500-3000" 3 "3000-5000" 4 "5000-8000" 5 "8000+"
label value income income_label

*** owner vs renter
gen owner = inlist(homeown,3,4)

*** cap hh size at 3
gen hhsize_cap3 = hhsize
replace hhsize_cap3 = 3 if hhsize >=3
label define hhsize_cap3_label 1 "1" 2 "2" 3 "3+"
label value hhsize_cap3 hhsize_cap3_label
