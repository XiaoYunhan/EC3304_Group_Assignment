// 1. Data plot with brief overview, sample period used
// <SGDUSD> use data after 1971m12
clear
set more off
use "~/Desktop/NUS/Semester8/EC3304/EC3304_Group_Assignment/assignment_data.dta"
drop if missing(IPI)
tsset month
twoway line IPI month
// 2. Tests for unit roots and structural breaks
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
