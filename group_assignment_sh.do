clear all
set more off

cd "C:\Users\SHUHANG\OneDrive - National University of Singapore\Y4S2\EC3304 Econometrics II\EC3304_Group_Assignment"

use "`c(pwd)'`c(dirsep)'assignment_data.dta", clear 
drop if missing(IPI)
tsset month

/////// 1. Data plot with brief overview, sample period used /////
twoway line IPI month
* <IPI> only has data after 1983m1. There seem to be an increaasing trend over the years.


/////// 2a. Test for unit roots for dependent variable, IPI /////
dfuller IPI, trend

* I have conducted the dickey-fuller test with trend. In this case, we reject the null hypothesis of a random walk with drift as the test statistic is lower than the 1% critical value. This is evidence that the underlying process is stationary.

/////// 2b. Test for structural breaks for dependent variable, IPI /////

* Do a regression where the dependent variable is IPI and the independent variable is the date
regress IPI month,vce(robust)

* Since it is not obvious from the graph whether there is a structural break in our data, we test for an unknown break date

estat sbsingle

* The test rejects the null hypothesis of no structural break and detects a break in the 2nd month of 1994.

twoway line IPI month, tline(1994m2)

* Unfortunately, the structural break is not obvious from the graph.

///// 3. Rationale for any additional data used, sources of data /////

* We will use Monthly Inflation Rate in Singapore (CPI) as an additional data source to help with forecasting. Friedman’s hypothesis regarding the relationship between inflation, inflation uncertainty and output growth states that full employment policy objective of the government tends to increase the rate of inflation which increases the uncertainty about the future course of inflation. Both variable have an increasing trend over the years. (https://ideas.repec.org/p/ift/wpaper/1211.html)

twoway line IPI month || line CPI month, yaxis(2)

///// Test for unit roots for predictor variable CPI /////
dfuller CPI,trend
* I have conducted the dickey-fuller test with trend. Since the test statistic is higher than all three critical values, we do not reject the null hypothesis that there is non-stationarity in the time series.

///// Test for structural breaks for predictor variable CPI /////

* Do a regression where the dependent variable is CPI and the independent variable is the date
regress CPI month,vce(robust)

* Since it is not obvious from the graph whether there is a structural break in our data, we test for an unknown break date
estat sbsingle

* The test rejects the null hypothesis of no structural break and detects a break in the 7nd month of 2013.
twoway line CPI month, tline(2013m7)

* We can see that there is a significant dip in CPI in July 2013.

///// 4. Data transformation /////

* Generate log IPI and the first difference

gen lIPI = log(IPI)
gen dlIPI = lIPI - L.lIPI

* Generate log CPI and the first difference
gen lCPI = log(CPI)
gen dlCPI = lCPI- L.lCPI

twoway line dlIPI month
twoway line dlCPI month

*Both plot look fairly stationary 

///// Retest for unit roots for transformed dependent variable, dlIPI /////

dfuller dlIPI

* I have conducted the dickey-fuller test without trend. In this case, we reject the null hypothesis of a random walk since the test statistic is significantly lesser than the 1% critical value.

/////// Retest for structural breaks for transformed dependent variable, dlIPI /////

* Do a regression where the dependent variable is dlIPI and the independent variable is the date
regress dlIPI month,vce(robust)

* Since it is not obvious from the graph whether there is a structural break in our data, we test for an unknown break date

estat sbsingle

* Since the p value is very high, we fail to reject the null hypothesis and can conclude it is highly likely that there is no structural break in our data. Hence, dlIPI is stationary

///// Retest for unit roots for transformed predictor variable, dlCPI /////

dfuller dlCPI

* I have conducted the dickey-fuller test without trend. In this case, we reject the null hypothesis of a random walk since the test statistic is significantly lesser than the 1% critical value.

/////// Retest for structural breaks for transformed dependent variable, dlCPI /////

* Do a regression where the dependent variable is dlCPI and the independent variable is the date
regress dlCPI month,vce(robust)

estat sbsingle

* The test rejects the null hypothesis of no structural break and detects a break in May of 2014.

twoway line dlCPI month, tline(2014m5)

/////// 5a. Lag selection with original CPI variable /////
ardl dlIPI CPI if tin(1983m1, 2020m12), maxlags(12 12) bic
predict dlIPI_hat_CPI if month == m(2021m1)
gen sq_error_dlIPI_CPI_2021m1 = dlIPI_hat_CPI - dlIPI if month == m(2021m1)

/////// 5b. Lag selection with logged CPI variable /////
ardl dlIPI lCPI if tin(1983m1, 2020m12), maxlags(12 12) bic
predict dlIPI_hat_lCPI if month == m(2021m1)
gen sq_error_dlIPI_lCPI_2021m1 = dlIPI_hat_lCPI - dlIPI if month == m(2021m1)

/////// 5c. Lag selection with lagged logged CPI variable /////
ardl dlIPI dlCPI if tin(1983m1, 2020m12), maxlags(12 12) bic
predict dlIPI_hat_dlCPI if month == m(2021m1)
gen sq_error_dlIPI_dlCPI_2021m1 = dlIPI_hat_dlCPI - dlIPI if month == m(2021m1)
list month dlIPI dlIPI_hat_CPI sq_error_dlIPI_CPI_2021m1 dlIPI_hat_lCPI sq_error_dlIPI_lCPI_2021m1 dlIPI_hat_dlCPI sq_error_dlIPI_dlCPI_2021m1 if month == m(2021m1)

* Since the ADL(2,0) coefficients in 5c resulted in the lowest squared error, we will be using dlIPI_hat_dlCPI to forecast the value of IPI in Jan 2021

di "The predicted IPI value in January 2021 is " exp(-.0067066 + 4.706065) " and the squared error is " (exp(-.0067066 + 4.706065) - 115.67)^2