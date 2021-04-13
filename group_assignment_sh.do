clear all
set more off

cd "C:\Users\SHUHANG\OneDrive - National University of Singapore\Y4S2\EC3304 Econometrics II\EC3304_Group_Assignment"

use "`c(pwd)'`c(dirsep)'assignment_data.dta", clear 
drop if missing(IPI)
tsset month

// 1. Data plot with brief overview, sample period used
twoway line IPI month
* <IPI> only has data after 1983m1. There seem to be an increaasing trend over the years.

// 2a. Test for unit roots 
dfuller IPI, trend
* I have conducted the dickey-fuller test with trend. In this case, we reject the null hypothesis of a random walk with drift. This is evidence that the underlying process is stationary.

dfgls IPI
* I have also performed the modified dickey-fuller t test proposed by Elliott, Rothenberg, and Stock (1996). The null hypothesis of a unit root is rejected at 5% level for lag 1 and it is not rejected for all other lags.


//2b. Test for structural breaks
* Do a regression where the dependent variable is IPI and the independent variable is the date
regress IPI month,vce(robust)

* Since it is not obvious from the graph whether there is a structural break in our data, we test for an unknown break date
estat sbsingle

//The test rejects the null hypothesis of no structural break and detects a break in the 2nd month of 1994.

twoway line IPI month, tline(1994m2)

* Unfortunately, the structural break is not obvious from the graph.

// 3. Rationale for any additional data used, sources of data

* We will use Monthly Inflation Rate in Singapore (CPI) as an additional data source to help with forecasting. Friedman’s hypothesis regarding the relationship between inflation, inflation uncertainty and output growth states that full employment policy objective of the government tends to increase the rate of inflation which increases the uncertainty about the future course of inflation. (https://ideas.repec.org/p/ift/wpaper/1211.html)

twoway line IPI month || line CPI month, yaxis(2)


// 4. Data transformation
* Generage log IPI, the MoM growth rate of log IPI
//
gen lIPI = log(IPI)
gen mom_lIPI = lIPI - L.lIPI

twoway line mom_lIPI month
ac mom_lIPI

// 4a. Retest for unit roots 
dfuller mom_lIPI
* I have conducted the dickey-fuller test with trend. In this case, we reject the null hypothesis of a random walk with drift since the approximate p-value is 0. 


//4b. Test for structural breaks
//Do a regression where the dependent variable is IPI and the independent variable is the date
regress mom_lIPI month,vce(robust)

//Since it is not obvious from the graph whether there is a structural break in our data, we test for an unknown break date
estat sbsingle
* Since the p value is very high, we can fail to reject the null hypothesis and can conclude that there is no structural break in our data. Hence, mom_lIPI is stationary

// 5a. Lag selection with original CPI variable
ardl mom_lIPI CPI if tin(1983m1, 2020m12), maxlags(12 12) bic
predict IPIhat if month == m(2021m1)
gen sq_error_IPI_2021m1 = IPIhat - mom_lIPI if month == m(2021m1)
list month mom_lIPI IPIhat sq_error_IPI_2021m1 if month == m(2021m1)

// 5b. Lag selection with lagged CPI variable
gen lCPI = l.CPI
ardl mom_lIPI lCPI if tin(1983m1, 2020m12), maxlags(12 12) bic
predict lIPIhat if month == m(2021m1)
gen sq_error_lIPI_2021m1 = lIPIhat - mom_lIPI if month == m(2021m1)
list month mom_lIPI lIPIhat sq_error_IPI_2021m1 if month == m(2021m1)

// 6. Point and interval forecasts
