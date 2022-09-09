*******************************************
************ STATA WORKSHOP ***************
****** by: Alfonso Rojas-Alvarez, PhD *****
***** LBJ School of Public Affairs ********
*******************************************

*** Create a log
log using "stata_workshop", replace

*** Load the data
sysuse census.dta, clear

******************************
*** Exploring

*** Some initial explorations
describe
summarize pop region popurban death
tab region
table state region
** Table is not very helpful unless we have groups

*** We can use conditional commands to restrict our data to what we need

summarize pop region popurban death if region == 1 

tab region if pop <= 1000000
tab region if pop > 10000000 
tab region if pop <= 1000000 | pop > 10000000 

******************************
*** Cleaning

rename state2 state_ab
rename medage median_age

label variable state_ab "State abbreviation with clear name"
gen urban_per = popurban/pop 

*** More advanced new variable generation
egen highest_pop_group = rowmax(poplt5 pop5_17 pop18p pop65p)
gen largest_18p = 1 if pop18p == highest_pop_group
tab largest_18p

*** But this doesn't make a lot of sense analytically, 
*** of course it is the largest_18p
*** Let's generate the population between 18 and 65

gen pop18_35 = pop18p - pop65p
drop highest_pop_group largest_18p
egen highest_pop_group = rowmax(poplt5 pop5_17 pop65p pop18_35)
gen largest_18p = 1 if pop18_35 == highest_pop_group
tab largest_18p

*** Generate id's 
sort region
by region: gen id = _n

*** drop conditionally
* drop if region != 4 

******************************
*** Graphs

*** Scatterplot
scatter pop death
scatter pop death if state_ab != "CA" & state_ab != "TX" 
scatter pop death if pop < 15000000

*** Histogram
histogram pop
histogram median_age

*** Boxplots
graph box median_age, over(region)

*** Density graphs

kdensity urban_per
kdensity urban_per, ///
title("Density Estimation for Urban Population in Sample Dataset") subtitle("Stata Workshop, 2022") ///
ytitle("Density Estimation of Population Proportion") xtitle("Percent of Urban Population")

*** The three dashes allows you to go from one line to the other in the editor

*******************************
*** Intro to regression

*** Basic OLS
regress death pop divorce i.region

*** Logistic

**** We need a binary variable

gen very_urban = 1 if urban_per > 0.7
replace very_urban = 0 if very_urban != 1
tab very_urban

logit very_urban pop death divorce i.region

log close
