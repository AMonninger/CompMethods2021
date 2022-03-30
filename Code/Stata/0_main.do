********************************************************************************
*** CORONA AND THE STOCK MARKET
*** AUTHOR: ADRIAN MONNINGER
*** PROJECT ID: 2020/0084
*** DATA: Bundesbank Online Pilot Survey on Consumer Expectations Scientific Use File (SUF) Version 1.3
********************************************************************************
********************************************************************************
*** globals
global ROOT "C:\Users\adria\OneDrive\Dokumente\Corona and the Stockmarket"
global CODE "${ROOT}/code"

** Data bases
global DATA "C:/Users/adria/Desktop/Data"
global BOP "${DATA}/BOP_HH_2020_0084_20201026/Data"
global NETWEALTH "${DATA}/BOP_HH_2020_0084_20210203"
global PHF "${DATA}/PHF/SUF Wellen 1(v4-0) 2(v4-0) 3(v2-0)"
global HFCS "${DATA}/HFCS/wave2"
global OUTPUT "${ROOT}/output"
// global TABLE "${OUTPUT}/table"

global TABLE "E:\VirtualBox/output/table"
global GRAPH "E:\VirtualBox/output/graph"
* others which come in handy
global asset "funds bonds stocks other"
global type "nopart noadjust has_bought_only has_sold_only has_bought_and_sold"

cd "${root}"
********************************************************************************
*** Code
* 1) Data preparation
do "${CODE}/1_data_prep"
do "${CODE}/1b_data_prep_other_waves"
do "${CODE}/1c_expectation_distribution"
do "${CODE}/1d_experienced_stockmarket"


* 2) Descriptive Statistics
do "${CODE}/2a_descriptives_tables"
* I) PhF: check representativeness
do "${CODE}/I_phf.do"

* create tables
do "${CODE}/2b_sum_stat_table_types_demo_transposed.do"
do "${CODE}/2b_sum_stat_table_types_transposed.do"
do "${CODE}/2c_sum_stat_table_reasons.do"

* 3) Regression
do "${CODE}/3a_PCA.do"
do "${CODE}/3b_regression.do"
do "${CODE}/4_robustness.do"

* optional
do "${CODE}/4b_robustness_risky.do"

*** External Data
* I) PhF: check representativeness

* II) Stock market developments
do "${CODE}/II_stock_markets"

* III) Deutsches Aktieninstitut
do "${CODE}/III_dai.do"



