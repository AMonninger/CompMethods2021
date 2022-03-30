********************************************************************************
*** Summary statistics of private investors in Germany based on DAI 2021
********************************************************************************
import excel "${ROOT}\DAI_2021.xlsx", sheet("Tabelle1") firstrow clear
*** total Bar chart
graph bar (mean) y_14_19 y_20_29 y_30_39 y_40_49 y_50_59 y_60, by(Year) stack ///
legend(order(1 "14-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" 6 "60+"))  ///
ytitle(Equity Holders in 1000) by(, title("Equity Holders in Germany") note("Source: DAI 2021"))
graph export "${OUTPUT}/graph/Equity_Holders.png", replace


*** percent of age group plot
twoway (lfit Total_percent Year)(lfit y_14_19_percent Year)(lfit y_20_29_percent Year)(lfit y_30_39_percent Year)(lfit y_40_49_percent Year)(lfit y_50_59_percent Year)(lfit y_60_percent Year)

*** percentage change Bar chart
foreach var in y_14_19 y_20_29 y_30_39 y_40_49 y_50_59 y_60{
gen d_`var' = (`var'- `var'[_n+1])/(`var'[_n+1])* 100
}

graph bar (mean) d_y_14_19 d_y_20_29 d_y_30_39 d_y_40_49 d_y_50_59 d_y_60, ///
legend(order(1 "14-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" 6 "60+"))  ///
ytitle("Change of Equity Holders in %") yscale(titlegap(3))title("Change of Equity Holders in Germany" "between 2019 and 2020") note("Source: DAI 2021")
graph export "${OUTPUT}/graph/Equity_Holders_change.png", replace
