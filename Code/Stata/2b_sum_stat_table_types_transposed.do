* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Types_transposed", replace
	
	* Write column heads
	putexcel E2 = "nopart"
	putexcel G2 = "noadjust"
	putexcel I2 = "has_bought_only"
	putexcel K2 = "has_sold_only"
	putexcel M2 = "has_bought_and_sold"
	
	* Write row names
	putexcel B3 = "Total"
	putexcel B7 = "Funds"
	putexcel B11 = "Bonds"
	putexcel B15 = "Stocks"
	putexcel B19 = "Other"
	
	* Write % and €
	local counter = 2
	forvalues j = 1/5 {
	local counter = `counter' + 1
	putexcel C`counter' = "%"
	local counter = `counter' + 1
	putexcel C`counter' = "€"
	local counter = `counter' + 1
	putexcel C`counter' = "sd"
	local counter = `counter' + 1

	}

	* Write data
	putexcel E3 = s_nopart, nformat(#.0)
	putexcel G3 = s_noadjust, nformat(#.0)
	
	local counter = 3
	local euro = 4
 	local sd = 5
foreach asset in total funds bonds stocks other {
	sca s_has_bought_only_total = s_has_bought_only
	sca s_has_sold_only_total = s_has_sold_only
	sca s_has_bought_and_sold_total = s_has_bought_and_sold


	putexcel I`counter' = s_has_bought_only_`asset', nformat(#.0)
	putexcel I`euro' = s_v_has_bought_only_`asset', nformat(#,###)
	putexcel I`sd' = s_sd_has_bought_only_`asset', nformat((#,###))
	
	putexcel K`counter' = s_has_sold_only_`asset', nformat(#.0)
	putexcel K`euro' = s_v_has_sold_only_`asset', nformat(#,###)
	putexcel K`sd' = s_sd_has_sold_only_`asset', nformat((#,###))

	putexcel M`counter' = s_has_bought_and_sold_`asset', nformat(#.0)
	putexcel M`euro' = s_v_has_bought_and_sold_`asset', nformat(#,###)
	putexcel M`sd' = s_sd_has_bought_and_sold_`asset', nformat((#,###))
	
	local counter = `counter' + 4
	local euro = `euro' + 4
	local sd = `sd' + 4
}
}

*** weighted
* in excel file
quietly {
	putexcel set "${OUTPUT}/table/Sum_Stat_Table_Types_transposed_weighted", replace
	
	* Write column heads
	putexcel E2 = "nopart"
	putexcel G2 = "noadjust"
	putexcel I2 = "has_bought_only"
	putexcel K2 = "has_sold_only"
	putexcel M2 = "has_bought_and_sold"
	
	* Write row names
	putexcel B3 = "Total"
	putexcel B7 = "Funds"
	putexcel B11 = "Bonds"
	putexcel B15 = "Stocks"
	putexcel B19 = "Other"
	
	* Write % and €
	local counter = 2
	forvalues j = 1/5 {
	local counter = `counter' + 1
	putexcel C`counter' = "%"
	local counter = `counter' + 1
	putexcel C`counter' = "€"
	local counter = `counter' + 1
	putexcel C`counter' = "sd"
	local counter = `counter' + 1

	}

	* Write data
	putexcel E3 = s_nopart, nformat(#.0)
	putexcel G3 = s_noadjust, nformat(#.0)
	
	local counter = 3
	local euro = 4
 	local sd = 5
	
foreach asset in total funds bonds stocks other {
	sca s_has_bought_only_total = s_has_bought_only
	sca s_has_sold_only_total = s_has_sold_only
	sca s_has_bought_and_sold_total = s_has_bought_and_sold
	
	putexcel I`counter' = s_has_bought_only_`asset', nformat(#.0)
	putexcel I`euro' = s_v_has_bought_only_`asset', nformat(#,###)
	putexcel I`sd' = s_sd_has_bought_only_`asset', nformat((#,###))
	
	putexcel K`counter' = s_has_sold_only_`asset', nformat(#.0)
	putexcel K`euro' = s_v_has_sold_only_`asset', nformat(#,###)
	putexcel K`sd' = s_sd_has_sold_only_`asset', nformat((#,###))

	putexcel M`counter' = s_has_bought_and_sold_`asset', nformat(#.0)
	putexcel M`euro' = s_v_has_bought_and_sold_`asset', nformat(#,###)
	putexcel M`sd' = s_sd_has_bought_and_sold_`asset', nformat((#,###))
	
	local counter = `counter' + 4
	local euro = `euro' + 4
	local sd = `sd' + 4
}
}


