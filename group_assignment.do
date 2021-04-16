// 1. Data plot with brief overview, sample period used
// <SGDUSD> use data after 1971m12
clear
set more off
use "~/Desktop/NUS/Semester8/EC3304/EC3304_Group_Assignment/assignment_data.dta"
drop if missing(IPI)
tsset month
//plots graph of IPI
twoway line IPI month 
gen lIPI=log(IPI)
gen dlIPI=d.lIPI
////unit root checks and predicting
// plots graph of log (IPI)
twoway (line lIPI month)
ardl lIPI if month <= m(2020m12), maxlags(5) bic
//result is 3 lags
predict lIPIhat if month == m(2021m1)
dfuller lIPI, trend regress lags(3)
//test stat is greater than all three critical values, meaning that we do
//not reject the null hypothesis. NH: there is nonstationarity in the y-variable
//nonstationary indicates that there is a stochastic trend
//since it's not stationary, we take first difference of log IPI.
//conclusion --> unit root is present.
ardl dlIPI if month <= m(2020m12), maxlags(6) bic
//result is 2 lags
predict dlIPIhat if month == m(2021m1)
twoway (line dlIPI month)
dfuller dlIPI, regress lags(2)
//test stat is smaller than all three critical values. reject null hypothesis. 
//NH: dlIPI is non-stationary. if we reject this NH, we conclude that there is 
//stationarity in dlIPI. conclusion --> unit root absent. concurs with graph.
gen predictedvalue = exp(-.0103116 + 4.706065)
gen squarederror = (predictedvalue - 115.67)^2
di "PV is " predictedvalue " and squared error is " squarederror

//structural break for lIPI
regress lIPI month, vce(robust)
estat sbsingle
twoway line IPI month if tin(1995m6, 1997m6), tline(1996m6)

//dlIPI has no significant structural break

////Chow break testing for COVID
//question: did COVID cause a break? SG measures intensified in Feb/March 2020.
//test for break after March 2020.
//checking for first lag
gen D20m3 = (month >= m(2020m3))
gen D20m3lIPI = D20m3*l.dlIPI
reg dlIPI l.dlIPI D20m3 D20m3lIPI, r
test D20m3 D20m3lIPI
//Prob > F = 0.8788

//checking for second lag
gen D20m3lIPI2 = D20m3*l2.dlIPI
reg dlIPI l2.dlIPI D20m3 D20m3lIPI2, r 
test D20m3 D20m3lIPI2 
//Prob > F =    0.7199. 
//do not reject null hypothesis. we cannot conclude that COVID caused a
//break in IPI.

//some manual confirmation checks//
qui reg lIPI if month <= m(2020m12), r
dis "BIC(0) = " ln(e(rss)/e(N)) + (0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg lIPI l.lIPI if month <= m(2020m12), r
dis "BIC(1) = " ln(e(rss)/e(N)) + (1+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg lIPI l(1/2).lIPI if month <= m(2020m12), r
dis "BIC(2) = " ln(e(rss)/e(N)) + (2+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg lIPI l(1/3).lIPI if month <= m(2020m12), r
dis "BIC(3) = " ln(e(rss)/e(N)) + (3+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
//3 lags has the most negative BIC value for lIPI
qui reg lIPI l(1/4).lIPI if month <= m(2020m12), r
dis "BIC(4) = " ln(e(rss)/e(N)) + (4+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg lIPI l(1/5).lIPI if month <= m(2020m12), r
dis "BIC(5) = " ln(e(rss)/e(N)) + (5+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg lIPI l(1/6).lIPI if month <= m(2020m12), r
dis "BIC(6) = " ln(e(rss)/e(N)) + (6+1)*ln(e(N))/e(N) ", R-sq = " e(r2)

qui reg dlIPI if month <= m(2020m12), r
dis "BIC(0) = " ln(e(rss)/e(N)) + (0+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l.dlIPI if month <= m(2020m12), r
dis "BIC(1) = " ln(e(rss)/e(N)) + (1+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/2).dlIPI if month <= m(2020m12), r
dis "BIC(2) = " ln(e(rss)/e(N)) + (2+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
//2 lags has the most negative BIC value for dlIPI
qui reg dlIPI l(1/3).dlIPI if month <= m(2020m12), r
dis "BIC(3) = " ln(e(rss)/e(N)) + (3+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/4).dlIPI if month <= m(2020m12), r
dis "BIC(4) = " ln(e(rss)/e(N)) + (4+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/5).dlIPI if month <= m(2020m12), r
dis "BIC(5) = " ln(e(rss)/e(N)) + (5+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
qui reg dlIPI l(1/6).dlIPI if month <= m(2020m12), r
dis "BIC(6) = " ln(e(rss)/e(N)) + (6+1)*ln(e(N))/e(N) ", R-sq = " e(r2)
