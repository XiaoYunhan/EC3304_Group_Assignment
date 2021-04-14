// 1. Data plot with brief overview, sample period used
// <SGDUSD> use data after 1971m12
clear
set more off
use "~/Desktop/NUS/Semester8/EC3304/EC3304_Group_Assignment/assignment_data.dta"
drop if missing(IPI)
tsset month
twoway line IPI month
//
gen lipi=log(IPI)
gen dlipi=d.lipi
// 2. Tests for unit roots and structural breaks
//////////////////unit root checks//////////////////////
twoway (line lipi month) if month >= m(1983m1)

ardl lipi, maxlags(5) bic
//result is 3 lags

dfuller lipi, trend regress lags(3)
//test stat is greater than all the three critical values, meaning that we do
//not reject the null hypothesis. NH: there is nonstationarity in the y-variable
// indication that there is a stochastic trend and that the log of IPI is non-stationary.
//since it's not stationary, we take first difference of log IPI.
//conclusion --> unit root is present.
ardl dlipi, maxlags(6) bic
//result is 2 lags

twoway (line dlipi month) if month >= m(1983m1)

dfuller dlipi, regress lags(2)
//test stat lower than all three critical values. reject null hypothesis. NH is 
//that dlipi is non-stationary. if we reject this NH, we conclude that there is 
//stationarity in dlipi. conclusion --> unit root absent.

//////////////////////end of unit root checks////////////////////
//////////////////chow break testing//////////////////////////
//question: did COVID cause a break? SG measures intensified in Feb/March 2020.
//test for break after March 2020.
gen D20m3 = (month >= m(2020m3))
gen D20m3lipi = D20m3*l.dlipi
reg dlipi l.dlipi D20m3 D20m3lipi, r
test D20m3 D20m3lipi
//Prob > F = 0.8788
//do not reject null hypothesis. we cannot conclude that COVID caused a
//break in IPI.
/////////////////end of chow break testing////////////////////
// 3. Rationale for any additional data used, sources of data
// 4. Data transformation
gen lIPI = log(IPI)
gen dlIPI = lIPI - l.lIPI
twoway line dlIPI month
ac dlIPI
// 5. Lag selection
// calc BIC
qui reg dlIPI if tin(1983m2,2020m12), r
dis "BIC(0) = " ln(e(rss)/e(N))+(0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l.dlIPI if tin(1983m2,2020m12), r
dis "BIC(1) = " ln(e(rss)/e(N))+(0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/2).dlIPI if tin(1983m2,2020m12), r
dis "BIC(2) = " ln(e(rss)/e(N))+(0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/3).dlIPI if tin(1983m2,2020m12), r
dis "BIC(3) = " ln(e(rss)/e(N))+(0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/4).dlIPI if tin(1983m2,2020m12), r
dis "BIC(4) = " ln(e(rss)/e(N))+(0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
//
ardl lIPI if tin(1983m1, 2020m12), maxlags(6) bic
predict IPIhat if month == m(2021m1)
gen error_IPI = IPIhat - lIPI if month == m(2021m1)
list month lIPI IPIhat error_IPI if month == m(2021m1)
// 6. Point and interval forecasts
