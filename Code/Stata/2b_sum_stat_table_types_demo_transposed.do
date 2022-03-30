* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Types_Demo_transposed", replace
	
	* Write column heads
	putexcel D2 = "nopart"
	putexcel F2 = "noadjust"
	putexcel H2 = "has_bought_only"
	putexcel J2 = "has_sold_only"
	putexcel L2 = "has_bought_and_sold"
	putexcel N2 = "total"
	putexcel P2 = "PHF"
	
	
	* Write row names
	putexcel A3 = "Female"

	putexcel A5 = "Age"
	putexcel B6 = "<30"
	putexcel B7 = "31-40"
	putexcel B8 = "41-50"
	putexcel B9 = "51-60"
	putexcel B10 = "60+"
	
	putexcel A12 = "HH Size"
	putexcel B13 = "1"
	putexcel B14 = "2"
	putexcel B15 = "3+"
	
	putexcel A17 = "College"
	
	putexcel A19 = "Employment"
	putexcel B20 = "full-time" 
	putexcel B21 = "part-time" 
	putexcel B22 = "retired"
	putexcel B23 = "self-employed"
	putexcel B24 = "unemployed"
	
	putexcel A26 = "HH income"
	putexcel B27 = "<1500" 
	putexcel B28 = "1500-3000" 
	putexcel B29 = "3000-5000" 
	putexcel B30 = "5000-8000" 
	putexcel B31 = "8000+"
	
	putexcel A33 = "Owner"
	
	putexcel A35 = "Financial Assets"
	putexcel B36 = "Total"
	putexcel B37 = "Funds"
	putexcel B38 = "Bonds"
	putexcel B39 = "Stocks"
	putexcel B40 = "Other"
	
	* Write data college owner
	local counter = 2
	foreach demo in female {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)

		}
	local counter = `counter' + 2	

	foreach demo in cohort_1 cohort_2 cohort_3 cohort_4 cohort_5  {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)

		}	
	local counter = `counter' + 2
	
	foreach demo in hhsize_1 hhsize_2 hhsize_3 {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}	
	local counter = `counter' + 2
		
	foreach demo in college {
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}
	local counter = `counter' + 2		

	foreach demo in labor_1 labor_2 labor_3 labor_4 labor_0 {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}	
	local counter = `counter' + 2

	foreach demo in income_1 income_2 income_3 income_4 income_5 {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}	
	local counter = `counter' + 2
		
	foreach demo in owner {
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}
	local counter = `counter' + 2
		
	foreach demo in has_some has_funds has_bonds has_stocks has_other {
	local counter = `counter' + 1
	putexcel D`counter' = s_`demo'_nopart, nformat(0.0)
	putexcel F`counter' = s_`demo'_noadjust, nformat(0.0)
	putexcel H`counter' = s_`demo'_has_bought_only, nformat(0.0)
	putexcel J`counter' = s_`demo'_has_sold_only, nformat(0.0)
	putexcel L`counter' = s_`demo'_has_bought_and_sold, nformat(0.0)
	putexcel N`counter' = s_`demo'_total, nformat(0.0)
	putexcel P`counter' = s_`demo'_phf, nformat(0.0)
		}
}


