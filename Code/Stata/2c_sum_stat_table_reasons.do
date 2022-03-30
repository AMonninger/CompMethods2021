*** Reason no part
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_nopart", replace
	
	* Write column heads
	putexcel C2 = "fully agree"
	putexcel E2 = "rather agree"
	putexcel G2 = "mean"
	putexcel I2 = "standardized"
	
	
	* Write data
	local counter = 2
	foreach var in c k i e b h f a d g j {
	local counter = `counter' + 1 
	putexcel A`counter' = name_reason_nopart_`var'
	putexcel C`counter' = ful_reason_nopart_`var', nformat(0%)
	putexcel E`counter' = rat_reason_nopart_`var', nformat(0%)
	putexcel G`counter' = mean_reason_nopart_`var', nformat(0.0)
	putexcel I`counter' = mean_s_reason_nopart_`var', nformat(0.0)
	}
}

***Reason noadjust
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_noadjust", replace
	
	* Write column heads
	putexcel C2 = "fully agree"
	putexcel E2 = "rather agree"
	putexcel G2 = "mean"
	putexcel I2 = "standardized"
	
	
	* Write data
	local counter = 2
	foreach var in c a b d f e {
	local counter = `counter' + 1 
	putexcel A`counter' = name_reason_noadjust_`var'
	putexcel C`counter' = ful_reason_noadjust_`var', nformat(0%)
	putexcel E`counter' = rat_reason_noadjust_`var', nformat(0%)
	putexcel G`counter' = mean_reason_noadjust_`var', nformat(0.0)
	putexcel I`counter' = mean_s_reason_noadjust_`var', nformat(0.0)
	}
}

* ALTERNATIVE: without high valuations
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_noadjust_alt", replace
	
	* Write column heads
	putexcel C2 = "fully agree"
	putexcel E2 = "rather agree"
	putexcel G2 = "mean"
	putexcel I2 = "standardized"
	
	
	* Write data
	local counter = 2
	foreach var in b d c f e {
	local counter = `counter' + 1 
	putexcel A`counter' = name_reason_noadjust_`var'
	putexcel C`counter' = aful_reason_noadjust_`var', nformat(0%)
	putexcel E`counter' = arat_reason_noadjust_`var', nformat(0%)
	putexcel G`counter' = amean_reason_noadjust_`var', nformat(0.0)
	putexcel I`counter' = amean_s_reason_noadjust_`var', nformat(0.0)
	}
}
***Reason bought
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_bought", replace
	
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

***Reason sold
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Reason_sold", replace
	
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
