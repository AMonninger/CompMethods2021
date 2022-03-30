********************************************************************************
*** Robustness Section
* a) experienced stock market returns and reason no participation
* b) PCA components
********************************************************************************
use "${OUTPUT}/data", clear
* cleaning
replace gender = . if gender==3

global control "college i.labor i.gender kurzarbeit has_children i.income owner i.cohort fin_illiterate"

label var fin_illiterate "fin illiterate"
label var age "age"
label var exp_v1 "Experience (k=1)"
label var exp_v2 "Experience (k=1.4322)"
label var exp_v3 "Experience (k=1.325)"
label var exp_v4 "Experience (k=1.166)"
label var exp_v5 "Experience (k=1.5)"

label var InflMean0 "Mean"
label var InflSD0 "SD"
label var Infl90100 "90-10 Percentile"

label var dax_sd_v1 "Volatility (k=1)"
label var dax_sd_v2 "Volatility (k=1.4322)"
label var dax_sd_v3 "Volatility (k=1.325)"
label var dax_sd_v4 "Volatility (k=1.166)"
label var dax_sd_v5 "Volatility (k=1.5)"

********************************************************************************
*** a) age or experienced stock market returns?
* parsimonious model (only age)
est clear
quietly{
foreach var in no_part_comp_1_s {
eststo: reg `var' age [pw=weight], robust
forvalues ver = 1/5{
eststo: reg `var' age exp_v`ver' [pw=weight], robust
}
}
}
* all controls
esttab using "${TABLE}\regression_pca_nopart_dem_experience_pars_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(age exp_v1 exp_v2 exp_v3 exp_v4 exp_v5) ///
  sfmt(3) extracols(1,2,3,4,5,6) gaps ///
 mtitles("\shortstack{Risk \\ Aversion}" "\shortstack{Risk \\ Aversion}""\shortstack{Risk \\ Aversion}""\shortstack{Risk \\ Aversion}""\shortstack{Risk \\ Aversion}""\shortstack{Risk \\ Aversion}") 


********************************************************************************
*** PCA components: not above mean, but standardized
*** regressions
* no participation: parsimonious model
gen labor_new = labor
replace labor_new = 1 if labor_new == 2
gen unemployed = inlist(labor,0)

est clear
quietly{
eststo: reg no_part_comp_1 age [pw=weight], robust // no owner, female, and poor
eststo: reg no_part_comp_2 i.gender age [pw=weight], robust // no children
eststo: reg no_part_comp_3  unemployed poor [pw=weight], robust // no owner
}
esttab using "${TABLE}\regression_pca_nopart_dem_robust_pars_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(age 2.gender unemployed poor) ///
  sfmt(3) extracols(1,2,3) gaps ///
 mtitles("\shortstack{Risk \\ Aversion}" "\shortstack{Lack of \\ Resources}" "\shortstack{Lack of\\ Savings}") 
 