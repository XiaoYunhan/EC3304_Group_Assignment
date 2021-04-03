// 1. Data plot with brief overview, sample period used
// <SGDUSD> use data after 1971m12
clear
use "~/Desktop/NUS/Semester8/EC3304/Group Assignment/assignment_data.dta"
tsset month
// 2. Tests for unit roots and structural breaks
// 3. Rationale for any additional data used, sources of data
// 4. Data transformation
gen lIPI = log(IPI)
gen dlIPI = lIPI - L3.lIPI
ac dlIPI
// 5. Lag selection
ardl lIPI if(1983m1, 2020m12), maxlags(6) bic
predict IPIhat if month == m(2021m1)
gen error_IPI = IPIhat - lIPI if month == m(2021m1)
list month lIPI IPIhat error_IPI if month == m(2021m1)
// 6. Point and interval forecasts
