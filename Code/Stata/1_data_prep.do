use "${BOP}/bophh_suf_v1_3_wave08", clear

merge 1:1 id using "${BOP}/anonymisation_bophh_originPRO_A1_wave08_v01"
drop _merge

********************************************************************************
********************************************************************************
*** DEMOGRAPHICS
********************************************************************************
********************************************************************************
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

gen kurzarbeit = inlist(employ2, 1)
label var kurzarbeit "short-time work"

* Cohort
gen cohort = .
replace cohort = 1 if age <31
replace cohort = 2 if age>=31 & age <41
replace cohort = 3 if age>=41 & age <51
replace cohort = 4 if age>=51 & age <61
replace cohort = 5 if age>=60
label define cohort_label 1 "$<30$" 2 "31-40" 3 "41-50" 4 "51-60" 5 "60+"
label value cohort cohort_label

gen young = inlist(cohort,1)
label var young "$<30$"

* Define flag variables0 as does not apply (for hhsize who did not answer hhchildren does not apply --> interpreted as no children)
foreach var in profession hhsize hhchildren hhinc pinc {
gen `var'_orig = `var'
replace `var' = 0 if `var'== -6666 //does not apply
replace `var' = . if `var'== -9999 | `var'== -9998 | `var'== -9997 | `var'== -5555 //dropout, no answer, do not know, recoded by bbk
}

*** define income brackets 
gen income=.
replace income = 1 if hhinc<4
replace income = 2 if hhinc>=4 & hhinc<7
replace income = 3 if hhinc>=7 & hhinc<10
replace income = 4 if hhinc>=10 & hhinc<12
replace income = 5 if hhinc>=12

label define income_label 1 "$<1500$" 2 "1500-3000" 3 "3000-5000" 4 "5000-8000" 5 "8000+"
label value income income_label

gen poor = inlist(income,1)
label var poor "$<1500$"

*** owner vs renter
gen owner = inlist(homeown,3,4)

*** has children
gen has_children = inlist(hhchildren,1,2,3)
label var has_children "children"

*** cap hh size at 5
gen hhsize_cap5 = hhsize
replace hhsize_cap5 = 5 if hhsize ==6

*** cap hh size at 3
gen hhsize_cap3 = hhsize
replace hhsize_cap3 = 3 if hhsize >=3
label define hhsize_cap3_label 1 "1" 2 "2" 3 "3+"
label value hhsize_cap3 hhsize_cap3_label

*** single dummy
gen single = inlist(hhsize,1)

*** consumption restrictions 
replace consrestr=. if consrestr == -9997 | consrestr == -9998

*** east vs west
/*
1 = In eastern Germany, the former GDR
2 = In western Germany, the Federal Republic of Germany
3 = I moved to Germany after 1989
*/
gen east = inlist(eastwest1989, 1)
gen west = inlist(eastwest1989,2)

* check for coding errors
local demographics "college labor kurzarbeit cohort profession hhsize hhchildren hhinc pinc income owner has_children hhsize_cap5 hhsize_cap3 single consrestr east west"
foreach var in `demographics' {
tab `var'
}
********************************************************************************
********************************************************************************
*** EXPECTATIONS
********************************************************************************
********************************************************************************
*** expectations qualitative  
/*
a = unemployment rate
b = rent
c = interest for credit
d = interest for savings
e = inflation rate
f = property prices
g = economic growth in Germany
h = fuel price
*/
foreach var in a b c d e f g h {
replace expmacroquali_`var' = . if expmacroquali_`var' == -9997 // Don't know
}
label var expmacroquali_a "unemp quali"
label var expmacroquali_b "rent quali"
label var expmacroquali_c "i credit quali"
label var expmacroquali_d "i save quali"
label var expmacroquali_e "infl quali"
label var expmacroquali_f "prop quali"
label var expmacroquali_g "gdp quali"
label var expmacroquali_h "fuel quali"

* as dummy (increase)
foreach var in a b c d e f g h {
gen d_expmacroquali_`var' = inlist(expmacroquali_`var',4,5) 
}

* house price qualitative: use rent for renter and property prices for owner
gen pp_quali = .
replace pp_quali = expmacroquali_b if owner == 0
replace pp_quali = expmacroquali_f if owner == 1
label var pp_quali "housing quali"

*** House price expectations quantitative: winsorize
gen pp_exp = exphp_point if exphp_point!=-9998 & exphp_point!= -9997 // no answer, don't know
quietly {
sum pp_exp [aw = weight], d
// gen pp_exp_win = pp_exp if pp_exp<`r(p99)' & pp_exp>`r(p1)'
// replace pp_exp_win = `r(p99)' if pp_exp >=`r(p99)'
// replace pp_exp_win = `r(p1)' if pp_exp <=`r(p1)'
gen pp_exp_win = pp_exp if pp_exp<`r(p95)' & pp_exp>`r(p5)'
replace pp_exp_win = `r(p95)' if pp_exp >=`r(p95)'
replace pp_exp_win = `r(p5)' if pp_exp <=`r(p5)'
replace pp_exp_win = . if pp_exp== .
}
label var pp_exp "house price PE"
label var pp_exp_win "house price wins"
*** Inflation development devinfpoint --> needed for illiteracy


*** Inflation expectations qualitative: inflation or deflation make dummy for inflation
gen d_infdef = inlist(infdef, 1)
replace d_infdef = . if infdef == -9998 | infdef == -9997 // no answer, don't know

*** Inflation expectations quantitative: winsorize
gen infl_exp = inflexppoint if inflexppoint!= -9998 & inflexppoint!= -9997 // no answer, don't know
quietly {
sum infl_exp [aw = weight], d
gen infl_exp_win = infl_exp if infl_exp<`r(p99)' & infl_exp>`r(p1)'
replace infl_exp_win = `r(p99)' if infl_exp >=`r(p99)'
replace infl_exp_win = `r(p1)' if infl_exp <=`r(p1)'
replace infl_exp_win = . if infl_exp_win == .
}
label var infl_exp "inflation PE"
label var infl_exp_win "inflation PE wins"

* subsample: 0-10% 
gen infl_exp_10 = infl_exp if infl_exp>=0 & infl_exp<=10
label var infl_exp_10 "$0<$ inflation $<10$"

* subsample: 0-5%
gen infl_exp_5 = infl_exp if infl_exp>=0 & infl_exp<=5
label var infl_exp_5 "$0<$ inflation $<5$"

*** Inflation expectations probabilistic: sum inflation
egen infexprob_sum = rowtotal(infexprob_f infexprob_g infexprob_h infexprob_i infexprob_j)
replace infexprob_sum = . if infexprob_sum<0

*** Inflation expectations probabilistic: standard diviation
* expected inflation
gen infl_exp_prob = (infexprob_a * (-13) + infexprob_b * (-10) + infexprob_c * (-6) + infexprob_d * (-3) + infexprob_e *(-1) ///
					+ infexprob_f * 1 + infexprob_g * 3 + infexprob_h * 6 + infexprob_i * 10 + infexprob_j * 13)/100
* drop no answers:
foreach var in a b c d e f g h i j{
replace infl_exp_prob = . if infexprob_`var' ==-9998 | infexprob_`var' ==-9997
}
label var infl_exp_prob "inflation prob exp"

* sd
gen infl_exp_prob_sd = (sqrt((infl_exp_prob - 13)^2 * infexprob_a + (infl_exp_prob - 10)^2 * infexprob_b + (infl_exp_prob - 6)^2 * infexprob_c ///
						+ (infl_exp_prob - 3)^2 * infexprob_d + (infl_exp_prob - 1)^2 * infexprob_e + (1 - infl_exp_prob)^2 * infexprob_f ///
						+ (3 - infl_exp_prob)^2 * infexprob_g + (6 - infl_exp_prob)^2 * infexprob_h + (10 - infl_exp_prob)^2 * infexprob_i ///
						+ (13 - infl_exp_prob)^2 * infexprob_j))/100
label var infl_exp_prob_sd "inflation prob sd"
					
*** Planned expenditure 
/*
a major purchases (e.g. car, furniture, electrical devices, etc.)?
b daily essentials (e.g. food and beverages, non-food items such as cleaning products or similar)?
c clothing and footwear?
d entertainment/recreation (e.g. restaurant visits, cultural events, gym)?
e mobility (e.g. fuel, car loans and running costs, bus and train tickets)?
f services (e.g. hairdresser, childcare, medical costs)?
g travel, holidays?
h housing costs (e.g. rent, mortgage, ancillary costs)?
i financial reserves?
*/
foreach var in a b c d e f g h i{
tab spendintent_`var'
replace spendintent_`var' = . if spendintent_`var' ==-9998 | spendintent_`var' ==-9997 
}
* spend more/less on durables 
gen more_dur = inlist(spendintent_a, 1) 
gen less_dur = inlist(spendintent_a, 3)

* spend more/less on nondurables
gen more_nondur = inlist(spendintent_b, 1)
gen less_nondur = inlist(spendintent_b, 3)

* spend more/less on housing/rent
gen more_house = inlist(spendintent_h, 1)
gen less_house = inlist(spendintent_h, 3)

* spend more/less on financial reserves
gen more_fin = inlist(spendintent_i, 1)
gen less_fin = inlist(spendintent_i, 3)

*** financial illiterate
* v1: expectation and previous inflation >|30| + no answer and don't know
gen fin_illiterate = 0
replace fin_illiterate = 1 if infl_exp > 30
replace fin_illiterate = 1 if devinfpoint > 30 | devinfpoint < -30
label var fin_illiterate "fin illiterate: inflation $>|30|$"

* v1: expectation and previous inflation >|10|
gen fin_illiterate_v1 = 0
replace fin_illiterate_v1 = 1 if infl_exp > 10
replace fin_illiterate_v1 = 1 if devinfpoint > 10 | devinfpoint < -10
label var fin_illiterate_v1 "fin illiterate: inflation $>|10|$"

*** Perceived problems
/*
a Climate change
b Brexit
c Coronavirus pandemic
d Refugee situation in Greece, Syria and Turkey
e The economy
*/
foreach var in a b c d e {
replace percprob_`var' = . if percprob_`var' == -9997
}

* mean problem
egen meanproblem = rmean(percprob_a percprob_b percprob_c percprob_d percprob_e)
foreach var in a b c d e {
replace meanproblem = . if percprob_`var' == -9997
}

*** MPC
/*
a Saving for future expenditure [input field]
b Repaying debt [input field]
c Purchasing durable goods (e.g. cars, furniture, TV, etc.) [input field]
d Modernising your house / apartment [input field]
e Purchasing short-lived consumer goods and services (e.g. food, clothing, holiday, etc.) [input field]

*/
foreach var in a b c d e {
replace propcon_`var' = . if propcon_`var' == -9998 | propcon_`var' == -9997
}

gen MPS = propcon_a + propcon_b

gen MPC = propcon_c + propcon_d + propcon_e
*** Payment behavior
foreach var in a b c d e f g{
replace payment_behav_`var' = . if payment_behav_`var' ==-9998 | payment_behav_`var' ==-9997 
}
gen pay_cash = payment_behav_a

egen pay_card = rsum(payment_behav_b payment_behav_c payment_behav_d payment_behav_e)

gen pay_mobile = payment_behav_f

* check for coding errors
local expectations "expmacroquali_a expmacroquali_b expmacroquali_c expmacroquali_d expmacroquali_e expmacroquali_f expmacroquali_g expmacroquali_h d_expmacroquali_a d_expmacroquali_b d_expmacroquali_c d_expmacroquali_d d_expmacroquali_e d_expmacroquali_f d_expmacroquali_g d_expmacroquali_h pp_exp pp_exp_win d_infdef infl_exp infl_exp_win infexprob_sum more_dur less_dur more_nondur less_nondur more_house less_house more_fin less_fin fin_illiterate fin_illiterate_v1"
foreach var in `expectations' {
tab `var'
}
********************************************************************************
********************************************************************************
*** PORTFOLIO ITEMS
********************************************************************************
********************************************************************************

*** has portfolio itmes
gen has_funds = inlist(has_portfolio_a,1)
label var has_funds "has funds"
gen has_stocks = inlist(has_portfolio_b,1)
label var has_stocks "has stocks"
gen has_bonds = inlist(has_portfolio_c,1)
label var has_bonds "has bonds"
gen has_other = inlist(has_portfolio_d,1)
label var has_other "has other"

gen has_nothing = 1 if has_funds==0 & has_stocks==0 & has_bonds==0 & has_other==0
replace has_nothing = 0 if has_nothing==.

gen has_something = 1 if has_funds==1 | has_stocks==1 | has_bonds==1 | has_other==1
replace has_something = 0 if has_something ==.

*** value portfolio items
gen value_funds = value_portfolio_a if value_portfolio_a>=1
label var value_funds "value funds" 
gen value_stocks = value_portfolio_b if value_portfolio_b>=1
label var value_stocks "value stocks" 
gen value_bonds = value_portfolio_c if value_portfolio_c>=1
label var value_bonds "value bonds" 
gen value_other = value_portfolio_d if value_portfolio_d>=1
label var value_other "value other" 

*** has bought
gen has_funds_bought = inlist(portfolio_bought_a,1)
gen has_stocks_bought = inlist(portfolio_bought_b,1)
gen has_bonds_bought = inlist(portfolio_bought_c,1)
gen has_other_bought = inlist(portfolio_bought_d,1)

gen has_not_bought = 1 if has_funds_bought==0 & has_stocks_bought==0 & has_bonds_bought==0 & has_other_bought==0
replace has_not_bought = 0 if has_not_bought==.

gen has_bought = 1 if has_funds_bought==1 | has_stocks_bought==1 | has_bonds_bought==1 | has_other_bought==1
replace has_bought = 0 if has_bought ==.

* first time buyers
foreach var in funds stocks bonds other {
gen ft_`var' = 1 if has_`var' == 0 & has_`var'_bought==1
replace ft_`var' = 0 if ft_`var' ==.
}
gen ft_bought = 1 if has_nothing == 1 & has_bought == 1
replace ft_bought = 0 if ft_bought ==.
label var ft_bought "first time"

*** value bought
gen value_funds_bought = portfolio_value_bought_a if portfolio_value_bought_a >=1
gen value_stocks_bought = portfolio_value_bought_b if portfolio_value_bought_b >=1
gen value_bonds_bought = portfolio_value_bought_c if portfolio_value_bought_c >=1
gen value_other_bought = portfolio_value_bought_d if portfolio_value_bought_d >=1 

egen value_total_bought = rsum(value_funds_bought value_stocks_bought value_bonds_bought value_other_bought)

foreach var in funds stocks bonds other {
gen share_`var'_bought = 100*(value_`var'_bought/value_total_bought)
}

*** has sold
gen has_funds_sold = inlist(portfolio_sold_a,1)
gen has_stocks_sold = inlist(portfolio_sold_b,1)
gen has_bonds_sold = inlist(portfolio_sold_c,1)
gen has_other_sold = inlist(portfolio_sold_d,1)

gen has_not_sold = 1 if has_funds_sold==0 & has_stocks_sold==0 & has_bonds_sold==0 & has_other_sold==0
replace has_not_sold = 0 if has_not_sold==.

gen has_sold = 1 if has_funds_sold==1 | has_stocks_sold==1 | has_bonds_sold==1 | has_other_sold==1
replace has_sold = 0 if has_sold ==.

*** has bought and sold
gen has_bought_and_sold = 1 if has_bought==1 & has_sold==1
replace has_bought_and_sold = 0 if has_bought_and_sold ==.
label var has_bought_and_sold "bought \& sold"

gen has_sold_only = 1 if has_sold == 1 & has_bought == 0
replace has_sold_only = 0 if has_sold_only==.
gen has_bought_only = 1 if has_bought == 1 & has_sold ==0
replace has_bought_only = 0 if has_bought_only ==.

gen has_total_changed = 1 if has_sold ==1 | has_bought ==1
replace has_total_changed = 0 if has_total_changed==.

foreach asset in funds bonds stocks other {
gen has_`asset'_changed = 1 if has_`asset'_sold ==1 | has_`asset'_bought ==1
replace has_`asset'_changed = 0 if has_`asset'_changed==.
}

*** value sold
gen value_funds_sold = portfolio_value_sold_a if portfolio_value_sold_a >=1
gen value_stocks_sold = portfolio_value_sold_b if portfolio_value_sold_b >=1
gen value_bonds_sold = portfolio_value_sold_c if portfolio_value_sold_c >=1
gen value_other_sold = portfolio_value_sold_d if portfolio_value_sold_d >=1 

egen value_total_sold = rsum(value_funds_sold value_stocks_sold value_bonds_sold value_other_sold)

foreach var in funds stocks bonds other {
gen share_`var'sold = 100*(value_`var'_sold/value_total_sold)
}

*** value difference
foreach asset in stocks funds bonds other total {
gen aux = (-1)*value_`asset'_sold
egen value_`asset'_diff = rsum(value_`asset'_bought aux)
gen con_value_`asset'_diff = value_`asset'_diff if has_bought ==1 | has_sold ==1
drop aux 
}

*** unchanged
gen unchanged = 1 if has_not_bought ==1 & has_not_sold ==1
replace unchanged = 0 if unchanged ==.

gen nopart = 1 if unchanged ==1 & has_nothing==1
replace nopart =0 if nopart==.

gen noadjust = 1 if unchanged == 1 & has_nothing==0
replace noadjust =0 if noadjust==.

********************************************************************************
********************************************************************************
*** REASONS
********************************************************************************
********************************************************************************
*** reason bought
foreach var in a b c d e f g h {
gen reason_bought_`var' = .
replace reason_bought_`var' = 1 if portfolio_reason_bought_`var'==4
replace reason_bought_`var' = 2 if portfolio_reason_bought_`var'==3
replace reason_bought_`var' = 3 if portfolio_reason_bought_`var'==2
replace reason_bought_`var' = 4 if portfolio_reason_bought_`var'==1
}
label var reason_bought_a "low valuations"
label var reason_bought_b "time"
label var reason_bought_c "information"
label var reason_bought_d "less consumption"
label var reason_bought_e "more income"
label var reason_bought_f "bank fees"
label var reason_bought_g "peer-effect"
label var reason_bought_h "plan"

* rank reasons
gen count=0
gen aux = 0
foreach var in a b c d e f g h {
gen rank_reason_bought_`var' = .
}

foreach i in 4 3 2 1{
replace aux = count + 1
foreach var in a b c d e f g h {
replace rank_reason_bought_`var' = aux if reason_bought_`var' == `i'
replace count = count + 1 if rank_reason_bought_`var' == aux
}
}
drop count aux

* above/below average
egen reason_bought_mean = rmean(reason_bought*)
foreach var in a b c d e f g h {
gen ab_reason_bought_`var' = 1 if reason_bought_`var'> reason_bought_mean
replace ab_reason_bought_`var' = 0 if reason_bought_`var'<= reason_bought_mean
replace ab_reason_bought_`var' =. if reason_bought_`var'==.
replace ab_reason_bought_`var' =. if has_bought==0
}

*drop reason_bought_mean

* standardize:
egen reason_bought_sd = rowsd(reason_bought*)
foreach var in a b c d e f g h {
gen s_reason_bought_`var' =(reason_bought_`var'-reason_bought_mean)/(reason_bought_sd)
}

*** reason sold
foreach var in a b c d e f g h i {
gen reason_sold_`var' = .
replace reason_sold_`var' = 1 if portfolio_reason_sold_`var'==4
replace reason_sold_`var' = 2 if portfolio_reason_sold_`var'==3
replace reason_sold_`var' = 3 if portfolio_reason_sold_`var'==2
replace reason_sold_`var' = 4 if portfolio_reason_sold_`var'==1
}

label var reason_sold_a "high valuations"
label var reason_sold_b "no time"
label var reason_sold_c "shock"
label var reason_sold_d "too risky"
label var reason_sold_e "need debt obligations"
label var reason_sold_f "need support friends/family"
label var reason_sold_g "need consumption"
label var reason_sold_h "peer-effect"
label var reason_sold_i "rebalancing"

* rank reasons
gen count=0
gen aux = 0
foreach var in a b c d e f g h i {
gen rank_reason_sold_`var' = .
}

foreach i in 4 3 2 1{
replace aux = count + 1
foreach var in a b c d e f g h i {
replace rank_reason_sold_`var' = aux if reason_sold_`var' == `i'
replace count = count + 1 if rank_reason_sold_`var' == aux
}
}
drop count aux

* above/below average
egen reason_sold_mean = rmean(reason_sold*)
foreach var in a b c d e f g h i {
gen ab_reason_sold_`var' = 1 if reason_sold_`var'> reason_sold_mean
replace ab_reason_sold_`var' = 0 if reason_sold_`var'<= reason_sold_mean
replace ab_reason_sold_`var' =. if reason_sold_`var'==.
replace ab_reason_sold_`var' =. if has_sold==0
}
*drop reason_sold_mean

* standardize:
egen reason_sold_sd = rowsd(reason_sold*)
foreach var in a b c d e f g h i {
gen s_reason_sold_`var' =(reason_sold_`var'-reason_sold_mean)/(reason_sold_sd)
}

*** reasons unchanged no part
foreach var in a b c d e f g h i j k {
gen reason_nopart_`var' = .
replace reason_nopart_`var' = 1 if portfolio_reason_nostocks_`var'==4
replace reason_nopart_`var' = 2 if portfolio_reason_nostocks_`var'==3
replace reason_nopart_`var' = 3 if portfolio_reason_nostocks_`var'==2
replace reason_nopart_`var' = 4 if portfolio_reason_nostocks_`var'==1
}

label var reason_nopart_a "high valuations"
label var reason_nopart_b "no time"
label var reason_nopart_c "information"
label var reason_nopart_d "shock"
label var reason_nopart_e "too risky"
label var reason_nopart_f "no savings"
label var reason_nopart_g "costs"
label var reason_nopart_h "peer-effect"
label var reason_nopart_i "distrust"
label var reason_nopart_j "moral"
label var reason_nopart_k "no interest"

* rank reasons
gen count=0
gen aux = 0
foreach var in a b c d e f g h i j k {
gen rank_reason_nopart_`var' = .
}

foreach i in 4 3 2 1{
replace aux = count + 1
foreach var in a b c d e f g h i j k {
replace rank_reason_nopart_`var' = aux if reason_nopart_`var' == `i'
replace count = count + 1 if rank_reason_nopart_`var' == aux
}
}
drop count aux

* above/below average
egen reason_nopart_mean = rmean(reason_nopart*)
foreach var in a b c d e f g h i j k {
gen ab_reason_nopart_`var' = 1 if reason_nopart_`var'> reason_nopart_mean
replace ab_reason_nopart_`var' = 0 if reason_nopart_`var'<= reason_nopart_mean
replace ab_reason_nopart_`var' =. if reason_nopart_`var'==.
replace ab_reason_nopart_`var' =. if nopart!=1
}
*drop reason_nopart_mean

* standardize:
egen reason_nopart_sd = rowsd(reason_nopart*)
foreach var in a b c d e f g h i j k {
gen s_reason_nopart_`var' =(reason_nopart_`var'-reason_nopart_mean)/(reason_nopart_sd)
}

*** reasons noadjust
foreach var in a b c d e f{
gen reason_noadjust_`var' = .
replace reason_noadjust_`var' = 1 if portfolio_reason_unchange_`var'==4
replace reason_noadjust_`var' = 2 if portfolio_reason_unchange_`var'==3
replace reason_noadjust_`var' = 3 if portfolio_reason_unchange_`var'==2
replace reason_noadjust_`var' = 4 if portfolio_reason_unchange_`var'==1
}

label var reason_noadjust_a "high valuations"
label var reason_noadjust_b "no time"
label var reason_noadjust_c "too risky"
label var reason_noadjust_d "no savings"
label var reason_noadjust_e "costs"
label var reason_noadjust_f "peer-effect"

* rank reasons
gen count=0
gen aux = 0
foreach var in a b c d e f {
gen rank_reason_noadjust_`var' = .
}

foreach i in 4 3 2 1{
replace aux = count + 1
foreach var in a b c d e f {
replace rank_reason_noadjust_`var' = aux if reason_noadjust_`var' == `i'
replace count = count + 1 if rank_reason_noadjust_`var' == aux
}
}
drop count aux

* above/below average
egen reason_noadjust_mean = rmean(reason_noadjust*)
foreach var in a b c d e f {
gen ab_reason_noadjust_`var' = 1 if reason_noadjust_`var'> reason_noadjust_mean
replace ab_reason_noadjust_`var' = 0 if reason_noadjust_`var'<= reason_noadjust_mean
replace ab_reason_noadjust_`var' =. if reason_noadjust_`var'==.
replace ab_reason_noadjust_`var' =. if noadjust!=1
}
*drop reason_noadjust_mean

* standardize:
egen reason_noadjust_sd = rowsd(reason_noadjust*)
foreach var in a b c d e f {
gen s_reason_noadjust_`var' =(reason_noadjust_`var'-reason_noadjust_mean)/(reason_noadjust_sd)
}

 * split up between high valuation and not
gen rather_sell = inlist(ab_reason_noadjust_a,1)
replace rather_sell = 0 if ab_reason_noadjust_a == .

*** some data cleaning
drop if has_sold_only & has_something==0

save "${OUTPUT}/data", replace

**** check
egen check = rsum(has_sold_only has_bought_only has_bought_and_sold nopart noadjust)

/*
** indicate importance (value 3 and 4)
/*
foreach var in a b c d e f g h {
gen ind_reason_bought_`var' = .
replace ind_reason_bought_`var' = 1 if reason_bought_`var'>=3
replace ind_reason_bought_`var' = 0 if reason_bought_`var'<3
}
*/

** rank them
*egen rank_reason_bought=rank(reason_bought_a reason_bought_b reason_bought_c reason_bought_d reason_bought_e reason_bought_f reason_bought_g reason_bought_h)

** indicate importance (value 4) Problem: either everything or nothing was important
foreach var in a b c d e f g h i j k {
gen ind_reason_nostocks_`var' = .
replace ind_reason_nostocks_`var' = 1 if reason_nostocks_`var'==4
replace ind_reason_nostocks_`var' = 0 if reason_nostocks_`var'<=3
}
