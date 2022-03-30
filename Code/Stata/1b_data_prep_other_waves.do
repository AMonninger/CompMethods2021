********************************************************************************
*** ADD VARIABLES FROM OTHER WAVES
********************************************************************************
*** add interesting waves (7 and 9)
use "${BOP}/bophh_suf_v1_3_wave07", clear
foreach num in 9 {
append using "${BOP}/bophh_suf_v1_3_wave0`num'"
}
*** add net wealth from wave 7
merge 1:1 id using "${NETWEALTH}/anonymisation_bophh_netwealth_wave07_v01"
drop _m
replace netwealth =. if netwealth==-9998 | netwealth==-9997

*** prep variables of interest:
* a) expectations: (waves 7,9)
foreach wave in 7 9 {
* qualitative
foreach var in a b c d e f g h {
replace expmacroquali_`var' = . if expmacroquali_`var' == -9997 | expmacroquali_`var' == -9998
gen expmacroquali_`var'_w`wave' = expmacroquali_`var' if wave==`wave'
}

* quantitative
*** House price expectations quantitative: winsorize
gen pp_exp_w`wave' = exphp_point if exphp_point!=-9998 & exphp_point!= -9997 & wave==`wave' // no answer, don't know

quietly {
sum pp_exp_w`wave', d
gen pp_exp_win_w`wave' = pp_exp_w`wave' if pp_exp_w`wave'<`r(p99)' & pp_exp_w`wave'>`r(p1)'
}
label var pp_exp_w`wave' "house price PE"
label var pp_exp_win_w`wave' "house price wins"

*** Inflation expectations quantitative: winsorize
gen infl_exp_w`wave' = inflexppoint if inflexppoint!= -9998 & inflexppoint!= -9997 & wave == `wave' // no answer, don't know
quietly {
sum infl_exp_w`wave', d
gen infl_exp_win_w`wave' = infl_exp_w`wave' if infl_exp_w`wave'<`r(p99)' & infl_exp_w`wave'>`r(p1)'
}
label var infl_exp_w`wave' "inflation PE"
label var infl_exp_win_w`wave' "inflation PE wins"

*** Inflation expectations probabilistic: standard diviation
* expected inflation
gen infl_exp_prob_w`wave' = (infexprob_a * (-12) + infexprob_b * (-10) + infexprob_c * (-6) + infexprob_d * (-3) + infexprob_e *(-1) ///
					+ infexprob_f * 1 + infexprob_g * 3 + infexprob_h * 6 + infexprob_i * 10 + infexprob_j * 12)/100 if wave == `wave'
* drop no answers:
foreach var in a b c d e f g h i j{
replace infl_exp_prob_w`wave' = . if infexprob_`var' ==-9998 | infexprob_`var' ==-9997 & wave == `wave'
}
label var infl_exp_prob_w`wave' "inflation prob exp"

* sd
gen infl_exp_prob_sd_w`wave' = (sqrt((infl_exp_prob_w`wave' - 12)^2 * infexprob_a + (infl_exp_prob_w`wave' - 10)^2 * infexprob_b + (infl_exp_prob_w`wave' - 6)^2 * infexprob_c ///
						+ (infl_exp_prob_w`wave' - 3)^2 * infexprob_d + (infl_exp_prob_w`wave' - 1)^2 * infexprob_e + (1 - infl_exp_prob_w`wave')^2 * infexprob_f ///
						+ (3 - infl_exp_prob_w`wave')^2 * infexprob_g + (6 - infl_exp_prob_w`wave')^2 * infexprob_h + (10 - infl_exp_prob_w`wave')^2 * infexprob_i ///
						+ (12 - infl_exp_prob_w`wave')^2 * infexprob_j))/100 if wave == `wave'
label var infl_exp_prob_sd_w`wave' "inflation prob sd"
}

* b) constraint (liquidity) (wave 7)
foreach var in a b {
replace constr_`var' = . if constr_`var' == -9997 | constr_`var' == -9998
gen liq_constr_`var'_w7 = constr_`var'  if wave==7
}

gen d_liq_constr_a_w7 = 1 if liq_constr_a_w7==3 | liq_constr_a_w7==4
replace d_liq_constr_a_w7 = 0 if liq_constr_a_w7==1 | liq_constr_a_w7==2

gen d2_liq_constr_a_w7 = 1 if liq_constr_a_w7==4
replace d2_liq_constr_a_w7 = 0 if liq_constr_a_w7==1 | liq_constr_a_w7==2 | liq_constr_a_w7==3

* c) income expectation (wave 7)
foreach var in a b c d e f g h i j k l {
replace incexp_`var' = . if incexp_`var' == -9997 | incexp_`var' == -9998
rename incexp_`var' incexp_`var'_w7
}

* exp increase
gen inc_exp_prob_w7 = (incexp_a_w7 * (-2000) + incexp_b_w7 * (-1750) + incexp_c_w7 * (-1250) + incexp_d_w7 * (-750) + incexp_e_w7 *(-375) ///
					+ incexp_f_w7 * (-125) + incexp_g_w7 * (125) + incexp_h_w7 * (375) + incexp_i_w7 * (750) + incexp_j_w7 * (1250) + incexp_k_w7 * (1750) + incexp_l_w7 * (2000))/100

label var inc_exp_prob_w7 "income prob exp"

* sd
gen inc_exp_prob_sd_w7 = (sqrt((inc_exp_prob - 2000)^2 * incexp_a_w7 + (inc_exp_prob - 1750)^2 * incexp_b_w7 + (inc_exp_prob - 1250)^2 * incexp_c_w7 ///
						+ (inc_exp_prob - 750)^2 * incexp_d_w7 + (inc_exp_prob - 375)^2 * incexp_e_w7 + (inc_exp_prob -125)^2 * incexp_f_w7 ///
						+ (125 - inc_exp_prob)^2 * incexp_g_w7 + (375 - inc_exp_prob)^2 * incexp_h_w7 + (750 - inc_exp_prob)^2 * incexp_i_w7 ///
						+ (1250 - inc_exp_prob)^2 * incexp_j_w7 + (1750 - inc_exp_prob)^2 * incexp_k_w7 + (2000 - inc_exp_prob)^2 * incexp_l_w7))/100
label var inc_exp_prob_sd_w7 "income prob sd"

* increase
egen inc_exp_inc_w7 = rowtotal(incexp_g_w7 incexp_h_w7 incexp_i_w7 incexp_j_w7 incexp_k_w7 incexp_l_w7)

* d) restrictions corona (in days)
gen restr_corona_w7 = .
replace restr_corona_w7 = restr_corona_b if restr_corona_a == 1 & restr_corona_b!=-9998 & restr_corona_b!=-9997
replace restr_corona_w7 = restr_corona_b * 7 if restr_corona_a == 2 & restr_corona_b!=-9998 & restr_corona_b!=-9997
replace restr_corona_w7 = restr_corona_b * 30 if restr_corona_a == 3 & restr_corona_b!=-9998 & restr_corona_b!=-9997

* e) spendintention
foreach var in a b c d e f g h i {
replace spendintent_`var' = . if spendintent_`var' == -9997 | spendintent_`var' == -9998
gen spendintent_`var'_w7 = spendintent_`var'  if wave==7
gen spendintent_`var'_w9 = spendintent_`var'  if wave==9
}

***
keep (id netwealth *_w7 *_w9)

*** merge with wave 8 data
merge m:1 id using "${OUTPUT}/data"
drop if _m==1
* mark panel households almost 3/4
gen panel = inlist(_m,3)
drop _m
sort id wave
********************************************************************************
*** gen variables of interest

* a) expectation changes
*** qualitative statements 
/*
a = unemployment rate
b = rent
c = interest for credit
d = interest for savings
e = inflation rate
f = property prices
*/
foreach var in a b c d e f g h {
gen ch_expmacroquali_`var'_w7 = expmacroquali_`var' - expmacroquali_`var'_w7
gen ch_expmacroquali_`var'_w9 = expmacroquali_`var'_w9 - expmacroquali_`var'
gen ch_expmacroquali_`var' = ch_expmacroquali_`var'_w7
replace ch_expmacroquali_`var' = ch_expmacroquali_`var'_w9 if ch_expmacroquali_`var'==.
}

* b) expectation updated
foreach var in a b c d e f g h {
gen ch2_expmacroquali_`var' = .
replace ch2_expmacroquali_`var' = 1 if expmacroquali_`var'!=expmacroquali_`var'_w7 & expmacroquali_`var'_w7!=.
replace ch2_expmacroquali_`var' = 0 if expmacroquali_`var'==expmacroquali_`var'_w7 & expmacroquali_`var'_w7!=.
replace ch2_expmacroquali_`var' = 1 if expmacroquali_`var'!=expmacroquali_`var'_w9 & expmacroquali_`var'_w9!=.
replace ch2_expmacroquali_`var' = 0 if expmacroquali_`var'==expmacroquali_`var'_w9 & expmacroquali_`var'_w9!=.
*replace ch2_expmacroquali_`var' = 0 if ch2_expmacroquali_`var' ==.
}

* c) large differences
foreach var in a b c d e f g h {
gen ch3_expmacroquali_`var' = .
gen ub_expmacroquali_`var' = expmacroquali_`var'+1
gen lb_expmacroquali_`var' = expmacroquali_`var'-1

replace ch3_expmacroquali_`var' = 1 if expmacroquali_`var'_w7>=ub_expmacroquali_`var' & expmacroquali_`var'_w7!=.
replace ch3_expmacroquali_`var' = 1 if expmacroquali_`var'_w7<=lb_expmacroquali_`var' & expmacroquali_`var'_w7!=.
replace ch3_expmacroquali_`var' = 0 if expmacroquali_`var'_w7>lb_expmacroquali_`var' & expmacroquali_`var'_w7<ub_expmacroquali_`var' & expmacroquali_`var'_w7!=.

replace ch3_expmacroquali_`var' = 1 if expmacroquali_`var'_w9>=ub_expmacroquali_`var' & expmacroquali_`var'_w9!=.
replace ch3_expmacroquali_`var' = 1 if expmacroquali_`var'_w9<=lb_expmacroquali_`var' & expmacroquali_`var'_w9!=.
replace ch3_expmacroquali_`var' = 0 if expmacroquali_`var'_w9>lb_expmacroquali_`var' & expmacroquali_`var'_w9<ub_expmacroquali_`var' & expmacroquali_`var'_w9!=.
}

*** quantitative statements
foreach var in pp_exp_win infl_exp_win infl_exp_prob infl_exp_prob_sd{
gen ch_`var' = .
replace ch_`var' = `var' - `var'_w7 if `var'_w7 != .
replace ch_`var' = `var'_w9 - `var' if `var'_w9 != .
}

save "${OUTPUT}/data", replace
********************************************************************************
*** Variables which will be interesting, but are not available yet
* a) all Pro BW questions regarding dax knowledge (wave 9)

* b) net wealth (wave 7)
