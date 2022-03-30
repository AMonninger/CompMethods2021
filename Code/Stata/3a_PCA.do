********************************************************************************
*** PCA 
* Using: ‘Using Multivariate Statistics’ from Tabachnick and Fidell
* And: Ani Katchova https://www.youtube.com/watch?v=xNTsAVj0t7U&ab_channel=econometricsacademy
********************************************************************************
use "${OUTPUT}/data", clear

*** reason nopart: above average
gen high_valuation = ab_reason_nopart_a
gen no_time = ab_reason_nopart_b
gen information = ab_reason_nopart_c
gen shock = ab_reason_nopart_d
gen too_risky = ab_reason_nopart_e
gen no_savings = ab_reason_nopart_f
gen costs = ab_reason_nopart_g
gen peer_effect = ab_reason_nopart_h
gen distrust = ab_reason_nopart_i
gen moral = ab_reason_nopart_j
gen no_interest = ab_reason_nopart_k

* set globals
global ab_reason_nopart "high_valuation no_time information shock too_risky no_savings costs peer_effect distrust moral no_interest"

* a) correlation matrix
corr $ab_reason_nopart
pca $ab_reason_nopart

* screeplot, yline(1)

* pca with only 3 components
global ncomp 3
*pca $ab_reason_nopart , mineigen(1) blank(.32)
pca $ab_reason_nopart , comp($ncomp) blank(.32)

*** TABLE
putexcel set "${OUTPUT}/table/PCA_ab_reason_nopart", sheet("unrotated") replace
matrix PCA_ab_reason_nopart = e(L)
putexcel B1=matrix(PCA_ab_reason_nopart)
local counter = 1
foreach var in $ab_reason_nopart {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

* component rotation (varimax)
rotate, varimax 
rotate, varimax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_nopart", sheet("varimax") modify
matrix PCA_ab_reason_nopart = e(r_L)
putexcel B1=matrix(PCA_ab_reason_nopart)
local counter = 1
foreach var in $ab_reason_nopart {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}
rotate, clear

* component rotation (promax)
rotate, promax 
rotate, promax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_nopart", sheet("promax") modify
matrix PCA_ab_reason_nopart = e(r_L)
putexcel B1=matrix(PCA_ab_reason_nopart)
local counter = 1
foreach var in $ab_reason_nopart {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

rotate, clear

* take mean of each component
egen no_part_comp_1 = rowmean(too_risky distrust shock high_valuation)
foreach var in too_risky distrust shock high_valuation {
replace no_part_comp_1 = . if `var' ==.
}

* shock is negative:
egen no_part_comp_2 = rowmean(no_interest information no_time no_savings)
foreach var in no_interest information no_time no_savings {
replace no_part_comp_2 = . if `var' ==.
}
* moral is negative:
// gen moral_aux = moral*(-1)
// egen comp_3 = rowmean(no_savings moral_aux)
egen no_part_comp_3 = rowmean(no_savings moral)
foreach var in no_savings moral {
replace no_part_comp_3 = . if `var' ==.
}

drop $ab_reason_nopart
/*
Three componants have eigenvalues above 1
Capture 47.45% of the variation

* Following Tabachnick and Fidell 2007 and consider loadings of at least 0.32
* Unrotated
First component: 	too risky (0.4211) --> risky/bad timing --> risk aversion
					distrust (0.4199)
					shock (0.3666)
					high valuation (0.3454)
					
Second component: 	no interest (0.4660) --> uninterested/poor --> lack of resources
					information (0.4042)
					no time (0.3997)
					no savings (0.3418)
					shock (-0.3273)
				
Third component:	no savings (0.6376) --> poor
					moral (-0.5963)
* Rotated:
First component: 	shock (0.5063) --> risky/bad timing --> risk aversion
					high valuation (0.4981)
					too risky (0.4719)
					costs (0.3663)
					distrust (0.3569)
														
Second component: 	no interest (0.5364) --> uninterested/poor --> lack of resources
					information (0.4850)
					no time (0.4787)
					peer-effect (0.3266)
				
Third component:	no savings (0.7010) --> poor
					moral (-0.5963)
					
==> 1. risk aversion; 2. lack of resources; 3: poor

*/

*** reason noadjust
gen high_valuation = ab_reason_noadjust_a
gen no_time = ab_reason_noadjust_b
gen too_risky = ab_reason_noadjust_c
gen no_savings = ab_reason_noadjust_d
gen costs = ab_reason_noadjust_e
gen peer_effect = ab_reason_noadjust_f

global ab_reason_noadjust "high_valuation no_time too_risky no_savings costs peer_effect"
pca $ab_reason_noadjust
* screeplot, yline(1)

* pca with only 2 components
* global ncomp 3
*pca $ab_reason_noadjust , mineigen(1) blank(.32)
pca $ab_reason_noadjust , comp(2) blank(.32)
*** TABLE
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust", sheet("unrotated") replace
matrix PCA_ab_reason_noadjust = e(L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

* component rotation (varimax)
rotate, varimax 
rotate, varimax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust", sheet("varimax") modify
matrix PCA_ab_reason_noadjust = e(r_L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}
rotate, clear

* component rotation (promax)
rotate, promax 
rotate, promax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust", sheet("promax") modify
matrix PCA_ab_reason_noadjust = e(r_L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

rotate, clear

* take mean of each component
egen no_adjust_comp_1 = rowmean(high_valuation too_risky peer_effect costs)
foreach var in high_valuation too_risky peer_effect costs {
replace no_adjust_comp_1 = . if `var' ==.
}

egen no_adjust_comp_2 = rowmean(no_time no_savings)
foreach var in no_time no_savings {
replace no_adjust_comp_2 = . if `var' ==.
}


global ab_reason_noadjust "no_time too_risky no_savings costs peer_effect"
pca $ab_reason_noadjust if rather_sell == 0
* screeplot, yline(1)

* ALTERNATIVE: without high valuation
* pca with only 2 components
* global ncomp 3
*pca $ab_reason_noadjust , mineigen(1) blank(.32)
pca $ab_reason_noadjust if rather_sell == 0, comp(3) blank(.32)

*** TABLE
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust_alt", sheet("unrotated") replace
matrix PCA_ab_reason_noadjust = e(L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

* component rotation (varimax)
rotate, varimax 
rotate, varimax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust_alt", sheet("varimax") modify
matrix PCA_ab_reason_noadjust = e(r_L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}
rotate, clear

* component rotation (promax)
rotate, promax 
rotate, promax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_noadjust_alt", sheet("promax") modify
matrix PCA_ab_reason_noadjust = e(r_L)
putexcel B1=matrix(PCA_ab_reason_noadjust)
local counter = 1
foreach var in $ab_reason_noadjust {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

rotate, clear

* take mean of each component
egen no_adjust_comp_1_alt = rowmean(too_risky peer_effect costs)
foreach var in too_risky peer_effect costs {
replace no_adjust_comp_1_alt = . if `var' ==.
}

egen no_adjust_comp_2_alt = rowmean(no_savings peer_effect)
foreach var in no_savings peer_effect {
replace no_adjust_comp_2_alt = . if `var' ==.
}

gen no_adjust_comp_3_alt = no_time
drop $ab_reason_noadjust high_valuation

/*
Two componants have eigenvalues above 1 (almost)
Capture 43.02% of the variation

* Following Tabachnick and Fidell 2007 and consider loadings of at least 0.32
First component: 	too risky (0.5985)			--> First three: economically bad decision to change
					high valuation (0.5058)
					costs (0.4200)
					peer-effect (0.3731)
					
Second component: 	no savings (0.6659) 		--> lack of resources?
					peer-effect (-0.4331)
					no time (-0.4277)

* rotated
First component: 	high valuation (0.5348)			--> First three: Bad timing
					too risky (0.5262)
					costs (0.4390)
					peer-effect (0.4045)
					
Second component: 	no savings (0.8961) 		--> lack of resources?
					no time (0.3350)
*/

*** reason bought

gen low_valuation = ab_reason_bought_a 
gen time = ab_reason_bought_b 
gen information = ab_reason_bought_c 
gen less_consumption = ab_reason_bought_d 
gen more_income = ab_reason_bought_e 
gen costs = ab_reason_bought_f 
gen peer_effect = ab_reason_bought_g 
gen plan = ab_reason_bought_h 

global ab_reason_bought "low_valuation time information less_consumption more_income costs peer_effect plan"
pca $ab_reason_bought
* screeplot, yline(1)

pca $ab_reason_bought , comp(3) blank(.32)
*** TABLE
putexcel set "${OUTPUT}/table/PCA_ab_reason_bought", sheet("unrotated") replace
matrix PCA_ab_reason_bought = e(L)
putexcel B1=matrix(PCA_ab_reason_bought)
local counter = 1
foreach var in $ab_reason_bought {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

* component rotation (varimax)
rotate, varimax 
rotate, varimax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_bought", sheet("varimax") modify
matrix PCA_ab_reason_bought = e(r_L)
putexcel B1=matrix(PCA_ab_reason_bought)
local counter = 1
foreach var in $ab_reason_bought {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}
rotate, clear

* component rotation (promax)
rotate, promax 
rotate, promax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_bought", sheet("promax") modify
matrix PCA_ab_reason_bought = e(r_L)
putexcel B1=matrix(PCA_ab_reason_bought)
local counter = 1
foreach var in $ab_reason_bought {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

rotate, clear

* take mean of each component
egen bought_comp_1 = rowmean(time information more_income costs)
foreach var in time information more_income costs {
replace bought_comp_1 = . if `var' ==.
}
egen bought_comp_2 = rowmean(low_valuation plan)
foreach var in low_valuation plan {
replace bought_comp_2 = . if `var' ==.
}
egen bought_comp_3 = rowmean(less_consumption peer_effect)
foreach var in less_consumption peer_effect {
replace bought_comp_3 = . if `var' ==.
}

drop $ab_reason_bought



***
/*
drop $ab_reason_bought

egen comp1 = rmean(time information more_income costs)
egen comp2 = rmean(low_valuation plan)
egen comp3 = rmean(less_consumption peer_effect)

gen plan_aux = plan*(-1)
egen comp2_aux = rmean(low_valuation plan_aux)

global control "college i.labor i.gender kurzarbeit has_children i.income owner i.cohort"
est clear
foreach var in 1 2 2_aux 3 {
eststo: reg comp`var' $control has_bought_and_sold [pw=weight], robust
estadd local Controls  "Yes"
}

esttab
*/
/*
Three components have eigenvalues above 1
Capture 49.84$ of variation
* Following Tabachnick and Fidell 2007 and consider loadings of at least 0.32

* Rotated
First component:	costs (56.77)
					more income (51.07)
					information (0.4884)
					time (36.64)
					
Second component:	Plan (-0.6919)
					low valuation (0.5845)
					
Third component:	less consumption (0.7023)
					Peer effect (0.6711)
*/

/*
Two componants have eigenvalues above 1
Capture 49.40% of the variation

* Following Tabachnick and Fidell 2007 and consider loadings of at least 0.32
First component: 	less consumption (0.4263)			--> Economically good decision to buy --> covid related?
					time (0.4148)
					costs (0.4139)
					more income (0.3867)
					more information (0.3780)
					peer effect (0.3601)
					
Second component: 	plan (0.6983) 		--> plan: covid unrelated
					low valuation (-0.6177)

*/

*** for bought only --> same as for bought
// pca $ab_reason_bought if has_bought_only ==1
// screeplot, yline(1)
//
// * pca with 2 components
// * global ncomp 3
// *pca $ab_reason_noadjust , mineigen(1) blank(.32)
// pca $ab_reason_bought if has_bought_only ==1, comp(2) blank(.32)
//
// * component rotation (varimax)
// rotate, varimax 
// rotate, varimax blanks(.3)
// rotate, clear
//
// * component rotation (promax)
// rotate, promax 
// rotate, promax blanks(.3)
// rotate, clear
//
// drop $ab_reason_bought

*** reason sold
gen high_valuation = ab_reason_sold_a 
gen no_time = ab_reason_sold_b 
gen shock = ab_reason_sold_c
gen too_risky = ab_reason_sold_d 
gen need_debt_obligations = ab_reason_sold_e 
gen need_support_ff = ab_reason_sold_f 
gen need_consumption = ab_reason_sold_g 
gen peer_effect = ab_reason_sold_h 
gen rebalancing = ab_reason_sold_i 

global ab_reason_sold "high_valuation no_time shock too_risky need_debt_obligations need_support_ff need_consumption peer_effect rebalancing"
pca $ab_reason_sold
* screeplot, yline(1)

pca $ab_reason_sold, comp(4) blank(.32)
*** TABLE
putexcel set "${OUTPUT}/table/PCA_ab_reason_sold", sheet("unrotated") replace
matrix PCA_ab_reason_sold = e(L)
putexcel B1=matrix(PCA_ab_reason_sold)
local counter = 1
foreach var in $ab_reason_sold {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

* component rotation (varimax)
rotate, varimax 
rotate, varimax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_sold", sheet("varimax") modify
matrix PCA_ab_reason_sold = e(r_L)
putexcel B1=matrix(PCA_ab_reason_sold)
local counter = 1
foreach var in $ab_reason_sold {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}
rotate, clear

* component rotation (promax)
rotate, promax 
rotate, promax blanks(.3)
putexcel set "${OUTPUT}/table/PCA_ab_reason_sold", sheet("promax") modify
matrix PCA_ab_reason_sold = e(r_L)
putexcel B1=matrix(PCA_ab_reason_sold)
local counter = 1
foreach var in $ab_reason_sold {
putexcel A`counter' ="`var'"
local counter = `counter' + 1
}

rotate, clear

egen sold_comp1 = rmean(too_risky shock no_time high_valuation)
foreach var in too_risky shock no_time high_valuation {
replace sold_comp1 = . if `var' ==.
}

egen sold_comp2 = rmean(need_debt_obligations need_consumption)
foreach var in need_debt_obligations need_consumption {
replace sold_comp2 = . if `var' ==.
}
egen sold_comp3 = rmean(peer_effect need_support_ff)
foreach var in peer_effect need_support_ff {
replace sold_comp3 = . if `var' ==.
}
egen sold_comp4 = rmean(rebalancing)
foreach var in rebalancing {
replace sold_comp4 = . if `var' ==.
}
drop $ab_reason_sold

// * pca with 3 components
// * global ncomp 3
// *pca $ab_reason_noadjust , mineigen(1) blank(.32)
// pca $ab_reason_sold, comp(4) blank(.32)
//
// * component rotation (varimax)
// rotate, varimax 
// rotate, varimax blanks(.32)
// rotate, clear
//
// * component rotation (promax)
// rotate, promax 
// rotate, promax blanks(.32)
// rotate, clear

/*
Four componants have eigenvalues above 1
Capture 68.23% of the variation

* Following Tabachnick and Fidell 2007 and consider loadings of at least 0.32
*rotation:
First component:	too risky (0.5889)			--> crisis
					shock (0.5646)
					no time (0.4401)
					high valuation (0.3547)
					
Second component:	need debt obligation (0.6620)	--> need money
					need consumption (0.6459)
					
Third component:	peer effect (0.7543)			--> social component
					need support friends and family (0.5570)
					
Fourth component:	Rebalancing			--> rebalancing


First component: 	need support friends/family (0.4464)				--> Driven out due to to crisis: involuntarily? needed money
					no time (0.4306)
					too risky (0.3984)
					shock (0.3515)
					need debt obligations (0.3374)
					
					
Second component: 	need consumption (-0.4925) 		--> Driven out due to crisis: voluntarily don't need money
					high_valuation (0.4775)
					need debt obligations (-0.4316)
					shock (0.3829)
					too risky (0.3311)

Third component:	rebalancing (0.8711) 			--> Rebalance
					high_valuation (-0.3232)

* rotation
First component: 	shock (0.5171)			--> Driven out due to to crisis: risk
					too risky (0.5161)
					high_valuation (0.4871)
					
					
Second component: 	need consumption (0.6060) 		--> Driven out due to crisis: involuntarily don't need money
					need debt obligations (0.5674)
					need support friends/family(0.4525)

Third component:	rebalancing (0.8800) 			--> Rebalance
					high_valuation (-0.3409)
*/
********************************************************************************
*** PCA components: not above mean, but standardized

*** reason nopart: above average
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

egen no_part_comp_1_s = rowmean(too_risky distrust shock high_valuation)
foreach var in too_risky distrust shock high_valuation {
replace no_part_comp_1_s = . if `var' ==.
}

egen no_part_comp_2_s = rowmean(no_interest information no_time no_savings)
foreach var in no_interest information no_time no_savings {
replace no_part_comp_2_s = . if `var' ==.
}

egen no_part_comp_3_s = rowmean(no_savings moral)
foreach var in no_savings moral {
replace no_part_comp_3_s = . if `var' ==.
}

drop $s_reason_nopart

*** reason noadjust
gen high_valuation = s_reason_noadjust_a
gen no_time = s_reason_noadjust_b
gen too_risky = s_reason_noadjust_c
gen no_savings = s_reason_noadjust_d
gen costs = s_reason_noadjust_e
gen peer_effect = s_reason_noadjust_f

global s_reason_noadjust "high_valuation no_time too_risky no_savings costs peer_effect"

egen no_adjust_comp_1_s = rowmean(high_valuation too_risky peer_effect costs)
foreach var in high_valuation too_risky peer_effect costs {
replace no_adjust_comp_1_s = . if `var' ==.
}

egen no_adjust_comp_2_s = rowmean(no_time no_savings)
foreach var in no_time no_savings {
replace no_adjust_comp_2_s = . if `var' ==.
}


drop $s_reason_noadjust

*** reason bought

gen low_valuation = s_reason_bought_a 
gen time = s_reason_bought_b 
gen information = s_reason_bought_c 
gen less_consumption = s_reason_bought_d 
gen more_income = s_reason_bought_e 
gen costs = s_reason_bought_f 
gen peer_effect = s_reason_bought_g 
gen plan = s_reason_bought_h 
global s_reason_bought "low_valuation time information less_consumption more_income costs peer_effect plan"

egen bought_comp1_s = rowmean(time information more_income costs)
foreach var in time information more_income costs {
replace bought_comp1_s = . if `var' ==.
}
egen bought_comp2_s = rowmean(low_valuation plan)
foreach var in low_valuation plan {
replace bought_comp2_s = . if `var' ==.
}
egen bought_comp3_s = rowmean(less_consumption peer_effect)
foreach var in less_consumption peer_effect {
replace bought_comp3_s = . if `var' ==.
}

drop $s_reason_bought

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

egen sold_comp1_s = rmean(too_risky shock no_time high_valuation)
foreach var in too_risky shock no_time high_valuation {
replace sold_comp1_s = . if `var' ==.
}

egen sold_comp2_s = rmean(need_debt_obligations need_consumption)
foreach var in need_debt_obligations need_consumption {
replace sold_comp2_s = . if `var' ==.
}
egen sold_comp3_s = rmean(peer_effect need_support_ff)
foreach var in peer_effect need_support_ff {
replace sold_comp3_s = . if `var' ==.
}
egen sold_comp4_s = rmean(rebalancing)
foreach var in rebalancing {
replace sold_comp4_s = . if `var' ==.
}
drop $s_reason_sold
********************************************************************************
*** Expectations
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

global expmacroquali "expmacroquali_a expmacroquali_b expmacroquali_c expmacroquali_d expmacroquali_e expmacroquali_f expmacroquali_g expmacroquali_h"
pca $expmacroquali

* screeplot, yline(1)

* pca with only 3 components
global ncomp 3
*pca $ab_reason_nopart , mineigen(1) blank(.32)
pca $expmacroquali , comp($ncomp) blank(.32)
rotate, varimax blanks(.3)

* group accordingly
egen expec_comp_1 = rmean(expmacroquali_b expmacroquali_f) // housing
foreach var in expmacroquali_b expmacroquali_f {
replace expec_comp_1 = . if `var' ==.
}
label var expec_comp_1 "housing quali"


gen expmacroquali_a_aux = .
replace expmacroquali_a_aux = 5 if expmacroquali_a == 1
replace expmacroquali_a_aux = 4 if expmacroquali_a == 2
replace expmacroquali_a_aux = 3 if expmacroquali_a == 3
replace expmacroquali_a_aux = 2 if expmacroquali_a == 4
replace expmacroquali_a_aux = 1 if expmacroquali_a == 5

egen expec_comp_2 = rmean(expmacroquali_a_aux expmacroquali_d expmacroquali_g) // growth
foreach var in expmacroquali_a_aux expmacroquali_d expmacroquali_g {
replace expec_comp_2 = . if `var' ==.
}

label var expec_comp_2 "growth quali"

egen expec_comp_3 = rmean(expmacroquali_c expmacroquali_e expmacroquali_h) // inflation
foreach var in expmacroquali_c expmacroquali_e expmacroquali_h {
replace expec_comp_3 = . if `var' ==.
}
label var expec_comp_3 "inflation quali"

save "${OUTPUT}/data", replace
