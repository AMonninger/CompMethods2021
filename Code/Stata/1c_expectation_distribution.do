********************************************************************************
*** Beta Distribution estimation for inflation
********************************************************************************
use "${OUTPUT}/data", clear

*** how many bins do households use?
gen bin = 0
foreach var in a b c d e f g h i j{
replace bin = bin + 1 if infexprob_`var' >0
}

tab bin

* save only necessary data
// preserve
* replace flagged data with missing + rescale between 0,1
drop infexprob_sum
foreach var in a b c d e f g h i j {
drop if infexprob_`var' < 0
gen infexprob_`var'_aux = .
replace infexprob_`var'_aux = infexprob_`var'
drop infexprob_`var'
rename infexprob_`var'_aux infexprob_`var'
// replace infexprob_`var' = round(infexprob_`var'/100,.01)
}
keep id infexprob*
// local count = 1
// foreach var in a b c d e f g h i j {
// rename infexprob_`var' infexprob_`count'
// local count = `count' + 1
// }
save "${OUTPUT}/infexprob.dta", replace
// export delimited using "${OUTPUT}/infexprob", replace
// restore

// replace infexprob_a = . if infexprob_a<0
// replace infexprob_a = round(infexprob_a/100,2)
//
// destring(infexprob_a), replace

*** load python output
import excel "C:\Users\adria\OneDrive\Dokumente\Corona and the Stockmarket\code\Inflation Expectation\Python_output.xlsx", sheet("Sheet1") firstrow clear
// foreach var in InflMean0 InflVar0 InflSD0 Infl90100 {
// replace `var' = "." if `var' == "[]"
// destring `var', replace
// }
drop A

foreach var in InflMean0 InflVar0 InflSD0 Infl90100 {
// replace `var' = "." if `var' == "[]"
destring `var', replace
}
merge 1:1 id using "${OUTPUT}/data"
drop _m

* delete some weird cases
// gen flag = 0
// replace flag = 1 if InflMean0>0 & InflMean0<1 & infl_exp_prob<0
// replace flag = 1 if InflMean0>0 & InflMean0<1 & infl_exp_prob>2

// foreach var in InflMean0 InflVar0 InflSD0 Infl90100 {
// replace `var' = . if flag == 1
// }

save "${OUTPUT}/data", replace


*** who am I still missing?
gen missing = 1 if infl_exp_prob!=. & InflMean0==.

gen nob = 0 // number of bins
foreach var in a b c d e f g h i j {
replace nob = nob + 1 if infexprob_`var'> 0
}

bysort missing: sum nob

keep if missing==1

order id infexprob*

keep id infexprob*
drop infexprob_sum
foreach var in a b c d e f g h i j {
drop if infexprob_`var' < 0
gen infexprob_`var'_aux = .
replace infexprob_`var'_aux = infexprob_`var'
drop infexprob_`var'
rename infexprob_`var'_aux infexprob_`var'
// replace infexprob_`var' = round(infexprob_`var'/100,.01)
}
keep id infexprob*

save "${OUTPUT}/infexprob_missing.dta", replace
/*
*** all the same
egen rowsd = rowsd(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e infexprob_f infexprob_g infexprob_h infexprob_i infexprob_j)
sum rowsd if rowsd == 0

*** gap
egen sum_ab = rsum(infexprob_a infexprob_b)
egen sum_abc = rsum(infexprob_a infexprob_b infexprob_c)
egen sum_abcd = rsum(infexprob_a infexprob_b infexprob_c infexprob_d)
egen sum_abcde = rsum(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e)
egen sum_abcdef = rsum(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e infexprob_f)
egen sum_abcdefg = rsum(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e infexprob_f infexprob_g)
egen sum_abcdefgh = rsum(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e infexprob_f infexprob_g infexprob_h)
egen sum_abcdefghi = rsum(infexprob_a infexprob_b infexprob_c infexprob_d infexprob_e infexprob_f infexprob_g infexprob_h infexprob_i)


gen gap = .
replace gap = 1 if infexprob_a!= 0 & infexprob_b==0 & sum_ab!=100
replace gap = 1 if infexprob_b!= 0 & infexprob_c==0 & sum_abc!=100
replace gap = 1 if infexprob_c!= 0 & infexprob_d==0 & sum_abcd!=100
replace gap = 1 if infexprob_d!= 0 & infexprob_e==0 & sum_abcde!=100
replace gap = 1 if infexprob_e!= 0 & infexprob_f==0 & sum_abcdef!=100
replace gap = 1 if infexprob_f!= 0 & infexprob_g==0 & sum_abcdefg!=100
replace gap = 1 if infexprob_g!= 0 & infexprob_h==0 & sum_abcdefgh!=100
replace gap = 1 if infexprob_h!= 0 & infexprob_i==0 & sum_abcdefghi!=100

tab gap


*/
// keep if InflMean0 == .
/*
use "${OUTPUT}/data", clear
* check mean
sum InflMean0 InflSD0 infl_exp_prob infl_exp_prob_sd

gen diff_mean = infl_exp_prob - InflMean0
gen diff_sd = InflSD0 - infl_exp_prob_sd

sum diff_mean diff_sd

twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob)
* by number of bins:
gen num_bins = 0

foreach var in a b c d e f g h i j{
replace num_bins = num_bins + 1 if infexprob_`var' != 0
}

gen num_bins_aux = num_bins
replace num_bins_aux = 3 if num_bins_aux >=3

twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob), by(num_bins_aux)

* all the same
foreach var in a b c d e f g h i j{
gen infexprob_`var'_aux = infexprob_`var' if infexprob_`var'!=0
}

egen bin_sd = rowsd(infexprob_a_aux infexprob_b_aux infexprob_c_aux infexprob_d_aux infexprob_e_aux infexprob_f_aux infexprob_g_aux infexprob_h_aux infexprob_i_aux infexprob_j_aux)
gen same_bins = 0
replace same_bins = 1 if bin_sd ==0 & num_bins>=3

gen num_bins_aux2 = num_bins_aux
replace num_bins_aux2 = 4 if num_bins_aux == 3 & same_bins == 1

twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob), by(num_bins_aux2)


twoway (scatter InflSD0 infl_exp_prob_sd)(lfit InflSD0 infl_exp_prob_sd)(line infl_exp_prob_sd infl_exp_prob_sd), by(num_bins_aux2)
*** num_bins_aux2 == 3 is the problem
* 2 parameters if no open bins
* 4 parameters if open bins
gen beta_dis = inlist(num_bins_aux2, 3)
gen parameters = 2 if beta_dis == 1
replace parameters = 4 if infexprob_a!=0 & beta_dis == 1
replace parameters = 4 if infexprob_j!=0 & beta_dis == 1

twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob), by(parameters)

* flag weird cases
gen flag = 0
replace flag = 1 if InflMean0>0 & InflMean0<1 & infl_exp_prob<0
replace flag = 1 if InflMean0>0 & InflMean0<1 & infl_exp_prob>2

preserve
drop if flag == 1
twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob), by(parameters)

restore
foreach var in InflMean0 InflVar0 InflSD0 {
replace `var' = 0 if flag == 1
}

save "${OUTPUT}/data", replace

* what cases do we lose?
keep if InflMean0==. & infl_exp_prob!=.
order InflMean0 infl_exp_prob infexprob_*
/*
preserve
drop if InflMean0==0
keep if InflMean0>0 & InflMean0<1
twoway (scatter InflMean0 infl_exp_prob)(lfit InflMean0 infl_exp_prob)(line infl_exp_prob infl_exp_prob), by(parameters)
* what bins?
sum infexprob_*

sum infexprob_* if infl_exp_prob<0 | infl_exp_prob>2
 keep if infl_exp_prob<0 | infl_exp_prob>2
restore
