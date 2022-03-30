********************************************************************************
*** descriptive statistics
*** tables
global type "nopart noadjust has_bought_only has_sold_only has_bought_and_sold"
********************************************************************************
use "${OUTPUT}/data", clear

********************************************************************************
*** a) portfolio changes of respondents (weighted)
* first collumn (total)
foreach type in $type {
sum `type' [aw = weight]
	sca s`type' = 100*`r(mean)'
	}

* by asset category
foreach asset in $asset {
foreach type in $type {
sum has_`asset'_changed [aw = weight] if `type'==1
	sca s_`type'_`asset' = 100*`r(mean)'
	}
}

* value (total)
foreach asset in total $asset {
foreach type in $type {
sum value_`asset'_diff [aw = weight] if `type'==1
	sca s_v_`type'_`asset' = round(`r(mean)',100)
	sca s_sd_`type'_`asset' = round(`r(sd)',100)
	}
}



*** a) demographics of stock owner table (weighted)
* first collumn (total)
foreach type in $type {
sum `type' [aw=weights]
	sca s_`type' = 100*`r(mean)'
	}

* by asset category
foreach asset in $asset {
foreach type in $type {
sum has_`asset'_changed [aw=weights] if `type'==1
	sca s_`type'_`asset' = 100*`r(mean)'
	}
}

* value (total)
foreach asset in total $asset {
foreach type in $type {
sum value_`asset'_diff [aw=weights] if `type'==1
	sca s_v_`type'_`asset' = round(`r(mean)',100)
	sca s_sd_`type'_`asset' = round(`r(sd)',100)
	}
}
/*
* first collumn (total)
foreach type in unchanged_v1 unchanged_v2 has_bought_only has_sold_only has_bought_and_sold {
sum `type' [aw=weights]
	sca sca_`type' = 100*`r(mean)'
	}

* by asset category
foreach asset in funds bonds stocks other {
foreach type in unchanged_v1 unchanged_v2 has_bought_only has_sold_only has_bought_and_sold {
sum has_`asset'_changed [aw=weights] if `type'==1
	sca sca_`type'_`asset' = 100*`r(mean)'
	}
}

* value (total)
foreach asset in total funds bonds stocks other {
foreach type in unchanged_v1 unchanged_v2 has_bought_only has_sold_only has_bought_and_sold {
sum value_`asset'_diff [aw=weights] if `type'==1
	sca sca_v_`type'_`asset' = round(`r(mean)',100)
	}
}
*/
*do "${CODE}/2b_sum_stat_table_types.do"

********************************************************************************
*** b) DEMOGRAPHICS OF TYPES
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

gen has_some = has_something
* first collumn (total)
foreach demo in female hhsize_1 hhsize_2 hhsize_3 cohort_1 cohort_2 cohort_3 cohort_4 cohort_5 college labor_0 labor_1 labor_2 labor_3 labor_4 income_1 income_2 income_3 income_4 income_5 owner has_some has_funds has_bonds has_stocks has_other{
sum `demo' [aw = weight]
	sca s_`demo'_total = 100*`r(mean)'
	}



* by type
foreach demo in female hhsize_1 hhsize_2 hhsize_3 cohort_1 cohort_2 cohort_3 cohort_4 cohort_5 college labor_0 labor_1 labor_2 labor_3 labor_4 income_1 income_2 income_3 income_4 income_5 owner has_some has_funds has_bonds has_stocks has_other{
foreach type in $type {
sum `demo' [aw = weight] if `type'==1
	sca s_`demo'_`type' = 100*`r(mean)'
	}
}

********************************************************************************
*** REASONS NO PARTICIPATION
* first row: reasons
	sca name_reason_nopart_c = "information"
	sca name_reason_nopart_k = "no interest"
	sca name_reason_nopart_i = "distrust"
	sca name_reason_nopart_e = "too risky"
	sca name_reason_nopart_b = "no time"
	sca name_reason_nopart_h = "peer-effect"
	sca name_reason_nopart_f = "no savings"
	sca name_reason_nopart_a = "high valuation"
	sca name_reason_nopart_d = "shock"
	sca name_reason_nopart_g = "costs"
	sca name_reason_nopart_j = "moral"
	
* second row: fully agree
* third row: at least rather agree
* fourth row: mean
* fifth: standardized

quietly {
foreach var in c k i e b h f a d g j {
gen fully_reason_nopart_`var' = inlist(reason_nopart_`var',4)
sum fully_reason_nopart_`var' [aw = weight] if nopart == 1
	sca ful_reason_nopart_`var' = `r(mean)'
gen rather_reason_nopart_`var' = inlist(reason_nopart_`var',3,4)
sum rather_reason_nopart_`var' [aw = weight] if nopart == 1
	sca rat_reason_nopart_`var' = `r(mean)'
sum reason_nopart_`var' [aw = weight] if nopart == 1
	sca mean_reason_nopart_`var' = `r(mean)'
sum s_reason_nopart_`var' [aw = weight] if nopart == 1
	sca mean_s_reason_nopart_`var' = `r(mean)'
}
}

********************************************************************************
*** REASONS NO ADJUSTMENT
* first row: reasons
	sca name_reason_noadjust_c = "too risky"
	sca name_reason_noadjust_a = "high valuation"
	sca name_reason_noadjust_b = "no time"
	sca name_reason_noadjust_d = "no savings"
	sca name_reason_noadjust_f = "peer-effect"
	sca name_reason_noadjust_e = "costs"
	
* second row: fully agree
* third row: at least rather agree
* fourth row: mean
* fifth: standardized
quietly {
foreach var in c a b d f e {
gen fully_reason_noadjust_`var' = inlist(reason_noadjust_`var',4)
sum fully_reason_noadjust_`var' [aw = weight] if noadjust == 1
	sca ful_reason_noadjust_`var' = `r(mean)'
gen rather_reason_noadjust_`var' = inlist(reason_noadjust_`var',3,4)
sum rather_reason_noadjust_`var' [aw = weight] if noadjust == 1
	sca rat_reason_noadjust_`var' = `r(mean)'
sum reason_noadjust_`var' [aw = weight] if noadjust == 1
	sca mean_reason_noadjust_`var' = `r(mean)'
sum s_reason_noadjust_`var' [aw = weight] if noadjust == 1
	sca mean_s_reason_noadjust_`var' = `r(mean)'
}
}

* ALTERNATIVE: without high valuation
quietly {
foreach var in c b d f e {
// gen fully_reason_noadjust_`var' = inlist(reason_noadjust_`var',4)
sum fully_reason_noadjust_`var' [aw = weight] if noadjust == 1 & rather_sell == 0
	sca aful_reason_noadjust_`var' = `r(mean)'
// gen rather_reason_noadjust_`var' = inlist(reason_noadjust_`var',3,4)
sum rather_reason_noadjust_`var' [aw = weight] if noadjust == 1 & rather_sell == 0
	sca arat_reason_noadjust_`var' = `r(mean)'
sum reason_noadjust_`var' [aw = weight] if noadjust == 1  & rather_sell == 0
	sca amean_reason_noadjust_`var' = `r(mean)'
sum s_reason_noadjust_`var' [aw = weight] if noadjust == 1  & rather_sell == 0
	sca amean_s_reason_noadjust_`var' = `r(mean)'
}
}
********************************************************************************
*** REASONS BOUGHT
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
sum fully_reason_bought_`var' [aw = weight] if has_bought == 1
	sca ful_reason_bought_`var' = `r(mean)'
gen rather_reason_bought_`var' = inlist(reason_bought_`var',3,4)
sum rather_reason_bought_`var' [aw = weight] if has_bought == 1
	sca rat_reason_bought_`var' = `r(mean)'
sum reason_bought_`var' [aw = weight] if has_bought == 1
	sca mean_reason_bought_`var' = `r(mean)'
sum s_reason_bought_`var' [aw = weight] if has_bought == 1
	sca mean_s_reason_bought_`var' = `r(mean)'
}
}

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
sum fully_reason_sold_`var' [aw = weight] if has_sold == 1
	sca ful_reason_sold_`var' = `r(mean)'
gen rather_reason_sold_`var' = inlist(reason_sold_`var',3,4)
sum rather_reason_sold_`var' [aw = weight]  if has_sold == 1
	sca rat_reason_sold_`var' = `r(mean)'
sum reason_sold_`var' [aw = weight]  if has_sold == 1
	sca mean_reason_sold_`var' = `r(mean)'
sum s_reason_sold_`var' [aw = weight]  if has_sold == 1
	sca mean_s_reason_sold_`var' = `r(mean)'
}
}
