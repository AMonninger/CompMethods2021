********************************************************************************
*** ROOBUSTNESS: Only risky assets
*				Argument: bonds are not risky and hence reasons to buy should be
*							different for investors who bought risky vs safe assets
*
*
* a) Reasons to buy
* b) Reasons and demographics
* c) Bought and expectations
* d) Adjustment
********************************************************************************
use "${OUTPUT}/data", clear
* cleaning
replace gender = . if gender==3

global control "college i.labor i.gender kurzarbeit has_children i.income owner i.cohort fin_illiterate"

label var fin_illiterate "fin illiterate"
label var age "age"

*** only risky assets
gen has_bought_risky = has_bought
replace has_bought_risky = 0 if has_bonds_bought == 1| has_other_bought == 1

gen has_sold_risky = has_sold
replace has_sold_risky = 0 if has_bonds_sold == 1| has_other_sold == 1

gen has_bought_and_sold_risky = 0
replace has_bought_and_sold_risky = 1 if has_bought_risky == 1 & has_sold_risky == 1

********************************************************************************
*** a) REASONS TO BUY
*** table
* first row: reasons
	sca name_reason_bought_a = "low valuation"
	sca name_reason_bought_h = "plan"
	sca name_reason_bought_b = "time"
	sca name_reason_bought_c = "information"
	sca name_reason_bought_d = "less consumption"
	sca name_reason_bought_g = "more income"
	sca name_reason_bought_e = "peer-effect"
	sca name_reason_bought_f = "bank fees"
* second row: fully agree
* third row: at least rather agree
* fourth row: mean
* fifth: standardized
quietly {
foreach var in a h b c d g e f {
gen fully_reason_bought_`var' = inlist(reason_bought_`var',4)
sum fully_reason_bought_`var' [aw = weight] if has_bought_risky == 1
	sca ful_reason_bought_`var' = `r(mean)'
gen rather_reason_bought_`var' = inlist(reason_bought_`var',3,4)
sum rather_reason_bought_`var' [aw = weight] if has_bought_risky == 1
	sca rat_reason_bought_`var' = `r(mean)'
sum reason_bought_`var' [aw = weight] if has_bought_risky == 1
	sca mean_reason_bought_`var' = `r(mean)'
sum s_reason_bought_`var' [aw = weight] if has_bought_risky == 1
	sca mean_s_reason_bought_`var' = `r(mean)'
}
}


quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_bought_risky", replace
	
	* Write column heads
	putexcel C2 = "fully agree"
	putexcel E2 = "rather agree"
	putexcel G2 = "mean"
	putexcel I2 = "standardized"
	
	
	* Write data
	local counter = 2
	foreach var in a h b c d g e f {
	local counter = `counter' + 1 
	putexcel A`counter' = name_reason_bought_`var'
	putexcel C`counter' = ful_reason_bought_`var', nformat(0%)
	putexcel E`counter' = rat_reason_bought_`var', nformat(0%)
	putexcel G`counter' = mean_reason_bought_`var', nformat(0.0)
	putexcel I`counter' = mean_s_reason_bought_`var', nformat(0.0)
	}
}

********************************************************************************
*** b) REASONS BY DEMOGRAPHICS 
********************************************************************************
gen passive_buyer = inlist(ab_reason_bought_h,1) 

gen active_buyer = inlist(ab_reason_bought_a,1)
replace active_buyer = 0 if passive_buyer==1 

* replace if not risky
replace passive_buyer = 0 if has_bought_risky!=1
replace active_buyer = 0 if has_bought_risky!=1

gen time = s_reason_bought_b 
gen information = s_reason_bought_c 
gen less_consumption = s_reason_bought_d
label var less_consumption "less consumption" 
gen more_income = s_reason_bought_e 
label var more_income "more income"
gen costs = s_reason_bought_f 
gen peer_effect = s_reason_bought_g
label var peer_effect "peer effect" 

global s_reason_bought "time information less_consumption more_income costs peer_effect"


* how many active, passive, none
preserve
gen n = 1
gen neither = 1 if has_bought_risky == 1 & passive_buyer ==0 & active_buyer==0
drop if has_bought_risky == 0
collapse (sum) n [pw = weights], by(active_buyer passive_buyer neither)
egen total = total(n)
foreach var in active_buyer passive_buyer neither {
gen s_`var' = n/total if `var' ==1
}
sum s_active_buyer s_passive_buyer s_neither
restore

global control3 "college i.labor i.gender kurzarbeit has_children i.income owner young fin_illiterate"

quietly{
est clear
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold_risky [pw = weights], robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold_risky [pw = weights], robust
estadd local Controls  "Yes"
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold_risky [pw = weights] if has_bought_risky ==1, robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold_risky [pw = weights] if has_bought_risky ==1, robust
estadd local Controls  "Yes"
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold_risky $s_reason_bought [pw = weights] if has_bought_risky ==1, robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold_risky $s_reason_bought [pw = weights] if has_bought_risky ==1, robust
estadd local Controls  "Yes"
}
esttab 

drop $s_reason_bought
********************************************************************************
*** c) Bought and Expectations
********************************************************************************
* House prices
est clear
quietly {
eststo: prob has_bought_risky $control pp_quali [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control expmacroquali_f [pw = weights] if owner==1, robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control expmacroquali_b  [pw = weights] if owner==0, robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control pp_exp_win [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control pp_exp_win [pw = weights] if owner==1, robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control pp_exp_win [pw = weights] if owner==0, robust
estadd local Controls  "Yes"
}
esttab 

* Inflation 
label var infl_exp_prob "inflation exp mean"
label var infl_exp_prob_sd "inflation exp sd"
label var InflMean0 "inflation dist mean"
label var InflSD0 "inflation dist sd"

global control4 "college i.labor i.gender kurzarbeit has_children i.income owner i.cohort"

est clear
quietly{
global expectations "expec_comp_3 infl_exp_win " 
foreach expec in $expectations {
eststo: prob has_bought_risky $control4 `expec'  [pw = weights], robust
estadd local Controls  "Yes"
}

eststo: prob has_bought_risky $control4 infl_exp_win fin_illiterate_v1  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control4 infl_exp_5  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control4 infl_exp_prob  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control4 infl_exp_prob infl_exp_prob_sd [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control4 InflMean0  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control4 InflMean0 InflSD0 [pw = weights], robust
estadd local Controls  "Yes"
}
esttab

label var percprob_e "pess economy"
label var expmacroquali_c "interest rates change"

est clear
quietly{
eststo: reg infl_exp_win $control percprob_e  [pw = weights], robust
estadd local Controls  "Yes"
eststo: reg infl_exp_win $control  expmacroquali_c [pw = weights], robust
estadd local Controls  "Yes"
eststo: reg infl_exp_win $control percprob_e expmacroquali_c [pw = weights], robust
estadd local Controls  "Yes"
eststo: prob has_bought_risky $control infl_exp_win [pw = weights], robust
estadd local Controls  "Yes"
eststo: prob has_bought_risky $control infl_exp_win percprob_e expmacroquali_c [pw = weights], robust
estadd local Controls  "Yes"
}

esttab

* expectations
* a) expecting increasing prices: Why did some buy and others not?
gen low_valuation = .
replace low_valuation = 1 if ab_reason_nopart_a == 0 & nopart == 1
replace low_valuation = 0 if ab_reason_nopart_a == 1 & nopart == 1
replace low_valuation = 1 if ab_reason_noadjust_a == 0 & noadjust == 1
replace low_valuation = 0 if ab_reason_noadjust_a == 1 & noadjust == 1
replace low_valuation = 1 if ab_reason_bought_a == 1 & has_bought == 1
replace low_valuation = 0 if ab_reason_bought_a == 0 & has_bought == 1
replace low_valuation = 1 if ab_reason_sold_a == 1 & has_sold_only == 1
replace low_valuation = 0 if ab_reason_sold_a == 0 & has_sold_only == 1

label var low_valuation "low valuation (above average)"

* v1: only highest/lowest value
gen low_valuation_v1 = .
replace low_valuation_v1 = 1 if reason_nopart_a == 1 & nopart == 1
replace low_valuation_v1 = 0 if reason_nopart_a > 1 & nopart == 1
replace low_valuation_v1 = . if reason_nopart_a == . & nopart == 1
replace low_valuation_v1 = 1 if reason_noadjust_a == 1 & noadjust == 1
replace low_valuation_v1 = 0 if reason_noadjust_a > 1 & noadjust == 1
replace low_valuation_v1 = . if reason_noadjust_a == . & noadjust == 1
replace low_valuation_v1 = 1 if reason_bought_a == 4 & has_bought == 1
replace low_valuation_v1 = 0 if reason_bought_a < 4 & has_bought == 1
replace low_valuation_v1 = . if reason_bought_a == . & has_bought == 1
replace low_valuation_v1 = 1 if reason_sold_a == 1 & has_sold_only == 1
replace low_valuation_v1 = 0 if reason_sold_a > 1 & has_sold_only == 1
replace low_valuation_v1 = . if reason_sold_a == . & has_sold_only == 1
label var low_valuation_v1 "low valuation (fully agree)"


* v2: take 3 and 4
gen low_valuation_v2 = .
replace low_valuation_v2 = 1 if reason_nopart_a <= 2 & nopart == 1
replace low_valuation_v2 = 0 if reason_nopart_a > 2 & nopart == 1
replace low_valuation_v2 = . if reason_nopart_a == . & nopart == 1
replace low_valuation_v2 = 1 if reason_noadjust_a <= 2 & noadjust == 1
replace low_valuation_v2 = 0 if reason_noadjust_a > 2 & noadjust == 1
replace low_valuation_v2 = . if reason_noadjust_a == . & noadjust == 1
replace low_valuation_v2 = 1 if reason_bought_a >= 3 & has_bought == 1
replace low_valuation_v2 = 0 if reason_bought_a < 3 & has_bought == 1
replace low_valuation_v2 = . if reason_bought_a == . & has_bought == 1
replace low_valuation_v2 = 1 if reason_sold_a <= 2 & has_sold_only == 1
replace low_valuation_v2 = 0 if reason_sold_a > 2 & has_sold_only == 1
replace low_valuation_v2 = . if reason_sold_a == . & has_sold_only == 1
label var low_valuation_v2 "low valuation (rather agree)"

* v3: all values
gen low_valuation_v3 = .
replace low_valuation_v3 = 1 if reason_nopart_a == 4 & nopart == 1
replace low_valuation_v3 = 2 if reason_nopart_a == 3 & nopart == 1
replace low_valuation_v3 = 3 if reason_nopart_a == 2 & nopart == 1
replace low_valuation_v3 = 4 if reason_nopart_a == 1 & nopart == 1
replace low_valuation_v3 = 1 if reason_noadjust_a == 4 & noadjust == 1
replace low_valuation_v3 = 2 if reason_noadjust_a == 3 & noadjust == 1
replace low_valuation_v3 = 3 if reason_noadjust_a == 2 & noadjust == 1
replace low_valuation_v3 = 4 if reason_noadjust_a == 1 & noadjust == 1
replace low_valuation_v3 = 1 if reason_sold_a == 4 & has_sold_only == 1
replace low_valuation_v3 = 2 if reason_sold_a == 3 & has_sold_only == 1
replace low_valuation_v3 = 3 if reason_sold_a == 2 & has_sold_only == 1
replace low_valuation_v3 = 4 if reason_sold_a == 1 & has_sold_only == 1
replace low_valuation_v3 = reason_bought_a if has_bought == 1
label var low_valuation_v3 "low valuation (all values)"

est clear
quietly{

eststo: prob has_bought_risky $control low_valuation [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control low_valuation_v1 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control low_valuation_v2 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought_risky $control low_valuation_v3 [pw = weights], robust
estadd local Controls  "Yes"

}
esttab 

**** Now negatively correlated. Which is driven by passive buyers. See below:
est clear
quietly{

eststo: prob active_buyer $control low_valuation [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob active_buyer $control low_valuation_v1 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob active_buyer $control low_valuation_v2 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob active_buyer $control low_valuation_v3 [pw = weights], robust
estadd local Controls  "Yes"

}
esttab

********************************************************************************
********************************************************************************
*** SOLD AND RISKY
********************************************************************************
*** REASONS SOLD
* first row: reasons
	sca name_reason_sold_a = "high valuation"
	sca name_reason_sold_i = "rebalancing"
	sca name_reason_sold_c = "shock"
	sca name_reason_sold_d = "too risky"
	sca name_reason_sold_g = "need consumption"
	sca name_reason_sold_e = "need debt obligations"
	sca name_reason_sold_b = "no time"
	sca name_reason_sold_h = "peer-effect"
	sca name_reason_sold_f = "need support friends/family"

* second row: fully agree
* third row: at least rather agree
* fourth row: mean
* fifth: standardized
quietly {
foreach var in a i c d g e b h f {
gen fully_reason_sold_`var' = inlist(reason_sold_`var',4)
sum fully_reason_sold_`var' [aw = weight] if has_sold_risky == 1
	sca ful_reason_sold_`var' = `r(mean)'
gen rather_reason_sold_`var' = inlist(reason_sold_`var',3,4)
sum rather_reason_sold_`var' [aw = weight]  if has_sold_risky == 1
	sca rat_reason_sold_`var' = `r(mean)'
sum reason_sold_`var' [aw = weight]  if has_sold_risky == 1
	sca mean_reason_sold_`var' = `r(mean)'
sum s_reason_sold_`var' [aw = weight]  if has_sold_risky == 1
	sca mean_s_reason_sold_`var' = `r(mean)'
}
}

* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_sold_risky", replace
	
	* Write column heads
	putexcel C2 = "fully agree"
	putexcel E2 = "rather agree"
	putexcel G2 = "mean"
	putexcel I2 = "standardized"
	
	
	* Write data
	local counter = 2
	foreach var in a i c d g e b h f {
	local counter = `counter' + 1 
	putexcel A`counter' = name_reason_sold_`var'
	putexcel C`counter' = ful_reason_sold_`var', nformat(0%)
	putexcel E`counter' = rat_reason_sold_`var', nformat(0%)
	putexcel G`counter' = mean_reason_sold_`var', nformat(0.0)
	putexcel I`counter' = mean_s_reason_sold_`var', nformat(0.0)
	}
}

********************************************************************************
* REASONS SOLD AND DEMOGRAPHICS
gen high_valuation = s_reason_sold_a 
gen no_time = s_reason_sold_b 
gen shock = s_reason_sold_c
gen too_risky = s_reason_sold_d 
gen need_debt_obligations = s_reason_sold_e 
gen need_support_ff = s_reason_sold_f 
gen need_consumption = s_reason_sold_g 
gen peer_effect = s_reason_sold_h 
gen rebalancing = s_reason_sold_i 

*global s_reason_sold "high_valuation no_time shock too_risky need_debt_obligations need_support_ff need_consumption peer_effect rebalancing"

global control2 "college i.labor i.gender kurzarbeit has_children i.income owner age fin_illiterate"

est clear
quietly{
foreach var in high_valuation rebalancing shock too_risky need_consumption need_debt_obligations no_time peer_effect need_support_ff{ 
eststo: reg `var' $control2 has_bought_and_sold_risky [pw=weight] if has_sold_risky == 1, robust
}
}

esttab
