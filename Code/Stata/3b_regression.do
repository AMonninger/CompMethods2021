********************************************************************************
*** Regressions
* I) Types and Demographics
* II) Reasons by demographics
* III) Bought and asset type
* IV) Bought and expectations
********************************************************************************
use "${OUTPUT}/data", clear
* cleaning
replace gender = . if gender==3

global control "college i.labor i.gender kurzarbeit has_children i.income owner i.cohort fin_illiterate"

label var fin_illiterate "fin illiterate"
label var age "age"
********************************************************************************
*** I) TYPES AND DEMOGRAPHICS
********************************************************************************
global control2 "college i.gender has_children young owner fin_illiterate i.labor kurzarbeit poor"

est clear
quietly{
foreach type in nopart noadjust has_bought has_sold {
eststo: prob `type' $control2  [pw=weight], robust
estadd local Controls  "Yes"
}
}
esttab using "${TABLE}\regression_types_dem_input.tex", f replace ///
b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
keep(college 2.gender 1.labor 2.labor 3.labor 4.labor poor owner young fin_illiterate) ///
scalars("Controls") sfmt(3)  extracols(1,2,3,4) ///
mtitles("\shortstack{No \\ Participation}" "\shortstack{No \\ Adjustment}" "\shortstack{Has\\ Bought}" "\shortstack{Has\\ Sold}")

********************************************************************************
*** II) REASONS BY DEMOGRAPHICS
********************************************************************************
*** no participation
* PCA and demographics
est clear
quietly{
foreach var in no_part_comp_1_s no_part_comp_2_s no_part_comp_3_s {
eststo: reg `var' college i.gender has_children owner fin_illiterate i.labor kurzarbeit age poor [pw=weight], robust
estadd local Controls  "Yes"
}
}

esttab using "${TABLE}\regression_pca_nopart_dem_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 gaps keep(age poor) ///
  scalars("Controls") sfmt(3) extracols(1,2,3)  ///
 mtitles("\shortstack{Risk \\ Aversion}" "\shortstack{Lack of \\ Resources}" "\shortstack{Lack of\\ Savings}") ///
 title(Regression Table: Reason No Participation and Demographics \label{tab:reg_nopart_dem}) subs("tab:reg\_nopart\_dem" "tab:reg_nopart_dem" )  
 
* all controls
esttab using "${TABLE}\regression_pca_nopart_dem_ctrl_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(college 1.labor 2.labor 3.labor 4.labor 2.gender kurzarbeit has_children owner fin_illiterate age poor) ///
  sfmt(3) extracols(1,2,3) gaps ///
 mtitles("\shortstack{Risk \\ Aversion}" "\shortstack{Lack of \\ Resources}" "\shortstack{Lack of\\ Savings}") 

* a parsimonious way
gen labor_new = labor
replace labor_new = 1 if labor_new == 2
gen unemployed = inlist(labor,0)

est clear
quietly{
eststo: reg no_part_comp_1_s age [pw=weight], robust // no owner, female, and poor
eststo: reg no_part_comp_2_s i.gender age [pw=weight], robust // no children
eststo: reg no_part_comp_3_s  unemployed poor [pw=weight], robust // no owner
}
esttab using "${TABLE}\regression_pca_nopart_dem_pars_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(age 2.gender unemployed poor) ///
  sfmt(3) extracols(1,2,3) gaps ///
 mtitles("\shortstack{Risk \\ Aversion}" "\shortstack{Lack of \\ Resources}" "\shortstack{Lack of\\ Savings}") 

* reason
*** reason nopart:
gen high_valuation = s_reason_nopart_a
gen no_time = s_reason_nopart_b
gen information = s_reason_nopart_c
gen shock = s_reason_nopart_d
gen too_risky = s_reason_nopart_e
gen no_savings = s_reason_nopart_f
gen costs = s_reason_nopart_g
gen peer_effect = s_reason_nopart_h
gen distrust = s_reason_nopart_i
gen moral = s_reason_nopart_j
gen no_interest = s_reason_nopart_k

* set globals
global s_reason_nopart "high_valuation no_time information shock too_risky no_savings costs peer_effect distrust moral no_interest"
global control2 "college i.labor i.gender kurzarbeit has_children i.income owner age fin_illiterate"

* all together
est clear
quietly{
foreach var in information no_interest distrust too_risky no_time peer_effect no_savings high_valuation shock costs moral {
eststo: reg `var' $control2 [pw=weight], robust
}
}

esttab using "${TABLE}\regression_nopart_dem_input.tex", f replace ///
b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
keep(college 1.labor 2.labor 3.labor 4.labor 2.gender kurzarbeit has_children 2.income 3.income 4.income 5.income owner age fin_illiterate) ///
sfmt(3) gaps ///
mtitles("\shortstack{no information}" "\shortstack{no interest}" "\shortstack{distrust}" "\shortstack{too risky}""\shortstack{no time}""\shortstack{peer-effect}" "\shortstack{no savings}" "\shortstack{prices fall}""\shortstack{shock}""\shortstack{cost}""\shortstack{moral}") 

drop $s_reason_nopart
********************************************************************************
*** no adjustment
** reason noadjust: without high valuation
gen no_time = s_reason_noadjust_b
gen too_risky = s_reason_noadjust_c
gen no_savings = s_reason_noadjust_d
gen costs = s_reason_noadjust_e
gen peer_effect = s_reason_noadjust_f

global s_reason_noadjust "no_time too_risky no_savings costs peer_effect"

est clear
quietly{
foreach var in $s_reason_noadjust {
eststo: reg `var' $control2 [pw=weight] if rather_sell == 0, robust
}
}

esttab using "${TABLE}\regression_noadjust_dem_alt_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) ///
  keep(college 1.labor 2.labor 3.labor 4.labor 2.gender kurzarbeit has_children 2.income 3.income 4.income 5.income owner age fin_illiterate) ///
  sfmt(3) extracols(1,2,3,4,5,6) ///
   mtitles("\shortstack{no time}" "\shortstack{no savings}" "\shortstack{too risky}" "\shortstack{peer effect}""\shortstack{costs}") 

drop  $s_reason_noadjust

********************************************************************************
*** bought
* passive vs active buyer
gen passive_buyer = inlist(ab_reason_bought_h,1) 

gen active_buyer = inlist(ab_reason_bought_a,1)
replace active_buyer = 0 if passive_buyer==1 

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
gen neither = 1 if has_bought == 1 & passive_buyer ==0 & active_buyer==0
drop if has_bought == 0
collapse (sum) n [pw = weights], by(active_buyer passive_buyer neither)
egen total = total(n)
foreach var in active_buyer passive_buyer neither {
gen s_`var' = n/total if `var' ==1
}
restore

global control3 "college i.labor i.gender kurzarbeit has_children i.income owner young fin_illiterate"

quietly{
est clear
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold [pw = weights], robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold [pw = weights], robust
estadd local Controls  "Yes"
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold [pw = weights] if has_bought ==1, robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold [pw = weights] if has_bought ==1, robust
estadd local Controls  "Yes"
eststo: prob active_buyer $control3 ft_bought has_bought_and_sold $s_reason_bought [pw = weights], robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold $s_reason_bought [pw = weights], robust
estadd local Controls  "Yes"
}
esttab using "${TABLE}\regression_bought_active_passive_input.tex", f replace ///
 b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) ///
 keep(owner young ft_bought has_bought_and_sold time information less_consumption more_income peer_effect costs) ///
  scalars("Controls") sfmt(3) eqlabels(" " " ") extracols(1,2,3,4,5,6) ///
 mtitles("\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}") ///
 title(Regression Table: Reason bought and Demographics \label{tab:reg_bought_active_passive}) subs("tab:reg\_bought\_active\_passive" "tab:reg_bought_active_passive" )   ///
 addnotes("Dependent variable: Passive or Active buyer." "Additional controls are education, labor status, gender, children" "Data source: BOP Wave 8")

 *** for presentation make two tables:
  est clear
 quietly{
eststo: prob active_buyer college i.labor i.gender kurzarbeit has_children poor owner young ft_bought has_bought_and_sold [pw = weights] if has_bought ==1, robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer college i.labor i.gender kurzarbeit has_children poor owner young ft_bought has_bought_and_sold [pw = weights] if has_bought ==1, robust
estadd local Controls  "Yes"
}
esttab using "${TABLE}\regression_bought_active_passive_1_input.tex", f replace ///
 b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(owner young ft_bought has_bought_and_sold) ///
  scalars("Controls") sfmt(3) ///
 mtitles("\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}") ///
 title(Regression Table: Reason bought and Demographics \label{tab:reg_bought_active_passive}) subs("tab:reg\_bought\_active\_passive" "tab:reg_bought_active_passive" )   ///
 addnotes("Dependent variable: Passive or Active buyer." "Additional controls are education, labor status, gender, children" "Data source: BOP Wave 8")

 est clear
 quietly{
 eststo: prob active_buyer $control3 ft_bought has_bought_and_sold $s_reason_bought [pw = weights], robust 
estadd local Controls  "Yes"
eststo: prob passive_buyer $control3 ft_bought has_bought_and_sold $s_reason_bought [pw = weights], robust
estadd local Controls  "Yes"
}
esttab using "${TABLE}\regression_bought_active_passive_2_input.tex", f replace ///
 b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) eqlabels(" " " ") ///
 keep(time information less_consumption more_income peer_effect costs) ///
  scalars("Controls") sfmt(3) ///
 mtitles("\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}""\shortstack{active}" "\shortstack{passive}") ///
 title(Regression Table: Reason bought and Demographics \label{tab:reg_bought_active_passive}) subs("tab:reg\_bought\_active\_passive" "tab:reg_bought_active_passive" )   ///
 addnotes("Dependent variable: Passive or Active buyer." "Additional controls are education, labor status, gender, children" "Data source: BOP Wave 8")
 
drop $s_reason_bought
 
gen low_valuation = s_reason_bought_a 
gen time = s_reason_bought_b 
gen information = s_reason_bought_c 
gen less_consumption = s_reason_bought_d 
gen more_income = s_reason_bought_e 
gen costs = s_reason_bought_f 
gen peer_effect = s_reason_bought_g 
gen plan = s_reason_bought_h 

global s_reason_bought "low_valuation plan time information less_consumption more_income peer_effect costs"  

 * reasons
 est clear
quietly{
foreach var in low_valuation plan time information less_consumption more_income peer_effect costs {
eststo: reg `var' $control ft_bought has_bought_and_sold [pw=weight], robust
}
}

esttab using "${TABLE}\regression_bought_dem_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) ///
  keep(college 1.labor 2.labor 3.labor 4.labor 2.gender kurzarbeit has_children 2.income 3.income 4.income 5.income owner 2.cohort 3.cohort 4.cohort 5.cohort fin_illiterate ft_bought has_bought_and_sold) ///
   sfmt(3) extracols(1,2,3,4,5,6,7,8) ///
   mtitles("\shortstack{prices rise}" "\shortstack{savingsplan}" "\shortstack{time}" "\shortstack{information}""\shortstack{less \\ consumption}""\shortstack{more \\ income}""\shortstack{peer-effect}""\shortstack{bank fees}") 

 drop $s_reason_bought
 
********************************************************************************
*** sold
 * reasons
 *** reason sold
gen high_valuation = s_reason_sold_a 
gen no_time = s_reason_sold_b 
gen shock = s_reason_sold_c
gen too_risky = s_reason_sold_d 
gen need_debt_obligations = s_reason_sold_e 
gen need_support_ff = s_reason_sold_f 
gen need_consumption = s_reason_sold_g 
gen peer_effect = s_reason_sold_h 
gen rebalancing = s_reason_sold_i 

global s_reason_sold "high_valuation no_time shock too_risky need_debt_obligations need_support_ff need_consumption peer_effect rebalancing"

est clear
quietly{
foreach var in high_valuation rebalancing shock too_risky need_consumption need_debt_obligations no_time peer_effect need_support_ff{ 
eststo: reg `var' $control2 has_bought_and_sold [pw=weight], robust
}
}

esttab using "${TABLE}\regression_sold_dem_input.tex", f replace ///
 b(3) se(3) label ar2  star(* 0.10 ** 0.05 *** 0.01) ///
  keep(college 1.labor 2.labor 3.labor 4.labor 2.gender kurzarbeit has_children 2.income 3.income 4.income 5.income owner age fin_illiterate has_bought_and_sold) ///
  sfmt(3) extracols(1,2,3,4,5,6,7,8,9) ///
   mtitles("\shortstack{prices fall}" "\shortstack{re-balancing}" "\shortstack{shock}" "\shortstack{too risky}""\shortstack{need \\ consumption}""\shortstack{need \\ debt obligation}""\shortstack{no time}""\shortstack{peer-effect}""\shortstack{need support \\ friends and family}") 

drop  $s_reason_sold

********************************************************************************
*** III) BOUGHT AND ASSET TYPE
********************************************************************************
foreach asset in $asset {
replace value_`asset' = 0 if value_`asset' ==.
}
 * conditional on having bought
est clear
quietly{
foreach asset in $asset {
eststo: probit has_`asset'_bought $control has_funds has_bonds has_stocks has_other value_funds value_bonds value_stocks value_other ft_bought has_bought_and_sold [pw = weights] if has_bought == 1, robust
estadd local Controls  "Yes"
}
}
esttab using "${TABLE}\regression_bought_asset_input.tex", f replace ///
 b(3) se(3) label  star(* 0.10 ** 0.05 *** 0.01) ///
 keep(owner 2.gender has_funds has_bonds has_stocks has_other value_funds value_bonds value_stocks value_other ft_bought has_bought_and_sold) ///
  scalars("Controls") sfmt(3) extracols(1,2,3,4) ///
 eqlabel("") mtitles("\shortstack{Funds}" "\shortstack{Bonds}" "\shortstack{Stocks}" "\shortstack{Other}") ///
 title(Regression Table: Has bought by asset type (Probit) \label{tab:reg_has_asset_bought}) subs("tab:reg\_has\_asset\_bought" "tab:reg_has_asset_bought" )  ///
 addnotes("Dependent variable: Has asset type." "Additional controls are income, age, children, labor status" "Data source: BOP Wave 8")

********************************************************************************
*** IV) BOUGHT AND EXPECTATIONS
********************************************************************************
* has bought
foreach var in ft_bought has_bought_and_sold {
replace `var' = 0 if `var'==.
}

* House prices
est clear
quietly {
eststo: prob has_bought $control pp_quali [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control expmacroquali_f [pw = weights] if owner==1, robust
estadd local Controls  "Yes"

eststo: prob has_bought $control expmacroquali_b  [pw = weights] if owner==0, robust
estadd local Controls  "Yes"

eststo: prob has_bought $control pp_exp_win [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control pp_exp_win [pw = weights] if owner==1, robust
estadd local Controls  "Yes"

eststo: prob has_bought $control pp_exp_win [pw = weights] if owner==0, robust
estadd local Controls  "Yes"
}
esttab using "${TABLE}\regression_bought_expec_pp_input.tex", f replace ///
wrap b(3) se(3) label  star(* 0.10 ** 0.05 *** 0.01) ///
 keep(pp_quali expmacroquali_f expmacroquali_b pp_exp_win) ///
 mtitles("\shortstack{All}" "\shortstack{Owner}" "\shortstack{Renter}" "\shortstack{All}" "\shortstack{Owner}" "\shortstack{Renter}") ///
 eqlabel("") scalars("Controls") sfmt(3) ///
  title(Regression Table: Has bought and Expectations of Property Prices(Probit) \label{tab:reg_has_bought_exp_pp}) subs("tab:reg\_has\_bought\_exp\_pp" "tab:reg_has_bought_exp_pp" )  ///
 addnotes("Dependent variable: Has assets bought." "Controls are income, age, gender, home owner, children, labor status, college" "Data source: BOP Wave 8")


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
eststo: prob has_bought $control4 `expec'  [pw = weights], robust
estadd local Controls  "Yes"
}

eststo: prob has_bought $control4 infl_exp_win fin_illiterate_v1  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control4 infl_exp_5  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control4 infl_exp_prob  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control4 infl_exp_prob infl_exp_prob_sd [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control4 InflMean0  [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control4 InflMean0 InflSD0 [pw = weights], robust
estadd local Controls  "Yes"
}
esttab using "${TABLE}\regression_bought_expec_infl_input.tex", f replace ///
wrap b(3) se(3) label  star(* 0.10 ** 0.05 *** 0.01) ///
 keep(expec_comp_3 infl_exp_win fin_illiterate_v1 infl_exp_5 infl_exp_prob infl_exp_prob_sd InflMean0 InflSD0) ///
 nomtitles eqlabel("") scalars("Controls") sfmt(3) ///
  title(Regression Table: Has bought and Expectations of Inflation (Probit) \label{tab:reg_has_bought_exp_infl}) subs("tab:reg\_has\_bought\_exp\_infl" "tab:reg_has_bought_exp_infl" )  ///
 addnotes("Dependent variable: Has assets bought." "Controls are income, age, gender, home owner, children, labor status, college" "Data source: BOP Wave 8")


 ********************************************************************************
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
eststo: prob has_bought $control infl_exp_win [pw = weights], robust
estadd local Controls  "Yes"
eststo: prob has_bought $control infl_exp_win percprob_e expmacroquali_c [pw = weights], robust
estadd local Controls  "Yes"
}

esttab using "${TABLE}\regression_expec_infl_input.tex", f replace ///
wrap b(3) se(3) label  star(* 0.10 ** 0.05 *** 0.01) ///
 keep(percprob_e expmacroquali_c infl_exp_win) ///
 eqlabel("") scalars("Controls") sfmt(3) extracols(1,2,3,4,5) ///
mtitles("\shortstack{inflation}" "\shortstack{inflation}" "\shortstack{inflation}" "\shortstack{Bought}" "\shortstack{Bought}")

********************************************************************************
*** Has bought: valuation and other expectations
*** 1) Valuation (All types)
*** Without savingsplan
gen bought_nosav = has_bought
replace bought_nosav = 0 if passive_buyer == 1

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

eststo: prob has_bought $control low_valuation [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control low_valuation_v1 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control low_valuation_v2 [pw = weights], robust
estadd local Controls  "Yes"

eststo: prob has_bought $control low_valuation_v3 [pw = weights], robust
estadd local Controls  "Yes"

}
esttab using "${TABLE}\regression_bought_expec_stocks_input.tex", f replace ///
wrap b(3) se(3) label  star(* 0.10 ** 0.05 *** 0.01) ///
 keep(low_valuation low_valuation_v1 low_valuation_v2 low_valuation_v3) ///
 mtitles("\shortstack{Has bought}" "\shortstack{Has bought}" "\shortstack{Has bought}" "\shortstack{Has bought}") ///
 eqlabel("") scalars("Controls") sfmt(3) extracols(1,2,3,4)
