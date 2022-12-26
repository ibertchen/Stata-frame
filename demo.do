/* 
purpose: frame intro
date: 2022-11-16
last update: 2022-11-15
*/

* -----------------------------  frlink  ------------------------------------ *

clear all
cls

webuse persons
frame rename default persons

list

frame create counties
frame counties: webuse txcounty
frame counties: list
frame counties: label list

frame dir

* link persons and counties (m:1)
frlink m:1 countyid, frame(counties)
frlink m:1 countyid, frame(counties) gen(match_id) // or give a name


* ------------------------------  frget  ------------------------------------ *
* pull median_income column into the current working frame (persons)
frget med_inc=median_income, from(counties)

list


* ------------------------------  frval  ------------------------------------ *
* use variable from another frame without merging it

drop median_income med_inc match_id

list

* flag personal income lower than median_income in the counties
gen high_low = income<frval(counties, median_income)

* calculate relative income number
gen rel_inc = income/frval(counties, median_income)

list 

* -----------------------------frame post------------------------------------ *
clear all
cls

webuse apple

summarize weight

* summarize weight by treatment
* use bysort
bysort treatment: summarize weight

collapse (mean) w_mean=weight (sd) w_sd=weight (min) w_min=weight (max) ///
	w_max=weight, by(treatment) // problem: the original data is gone. 

list

* use frame post
clear all
cls

webuse apple

* create a new frame "sumweight" with four empty variables
frame create sumweight treatment w_mean w_sd w_min w_max

forvalues t=1/4 {
	summarize weight if treatment == `t'
	frame post sumweight (`t') (r(mean)) (r(sd)) (r(min)) (r(max))
}

frame sumweight: list

list //the original data is still there 

* But it won't work if the number of pre-created columns doesn't match to the number of expressions. 

* ---------------------------- framesave------------------------------------ *

* example 1: save output to another frame
clear all
cls

* "load" framesave function
do framesave.do

webuse apple

framesave sumweight: collapse (mean) w_mean=weight (sd) w_sd=weight (min) ///
	w_min=weight (max) w_max=weight, by(treatment)


* example 2: split data into subsets
clear all
cls

sysuse auto

do framesave.do

* split data based on the value of foreign
forvalues i = 0/1 {
	framesave subset`i': keep if foreign == `i'
	frame subset`i': save auto_sub`i'
}

