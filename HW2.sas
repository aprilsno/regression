/*
Name: Sara O'Brien
Assignment: HW 2
Date: 2/2/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW2.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library with only height variables;
data bios645.chflheights;
	infile "/home/u49497589/BIOS645/Data/Chinese_health_and_family_life_study.txt" DLM="09"X FIRSTOBS=2;
	input R_region :$13. R_age    R_edu :$10. R_income R_health :$9. R_height 
          R_happy  :$15. A_height A_edu :$10. A_income; 
	keep R_height A_height;
run;  

* 1. Compute univariate descriptives for variables;
proc means data=bios645.chflheights N MIN MEDIAN MAX MEAN STD SKEW KURT;
	title "1. Univariate descriptives for height variables";
	var R_height A_height;
run;

* this could alternatively be done using proc univariate;

* 2. Regress A onto R and R onto A;
proc reg data=bios645.chflheights plots=none;
	title "2. Regression of height variables";
	model A_height=R_height;
		*in this model, A_height is the dependent var;
	model R_height=A_height;
		*in this model, R_height is the dependent var;
run;

* 3. Correlate A and R;
proc corr data=bios645.chflheights;
	title "3. Correlation of height variables";
	var R_height A_height;
run;

* 3. Turn A and R into z-scores;
proc standard data=bios645.chflheights 
	mean=0 
	std=1 
	out=z_height;
run;

* 3. Regress z(A) onto z(R) and confirm slope=correlation;
proc corr data=z_height;  
	title "3. Correlation of z-scores of woman's height and partner's height";
	var R_height A_height;
run;	
	
proc reg data=z_height plots=none;
	title "3. Regression of z-score of partner's height on woman's height";
	model A_height=R_height;
run; 

* 4. Regress A onto R, suppressing the intercept;
proc reg data=bios645.chflheights plots=none;
	title "4. Regression of partner's height on woman's height (intercept suppressed)";
	model A_height=R_height / noint;
run;

* 4. Show the regression line goes through in #2 but not when intercept is suppressed;

data _NULL_;
	x = 159.3017636;
	b =  1.07389;
	y_hat = x*b;
	y = 171.1835402;
	put "The predicted y at x-bar is: " y_hat;
	put "The observed y-bar is:       " y;
run;

data _NULL_;
	x  = 159.3017636;
	b0 = 117.25862;
	b1 =  0.33851;
	y_hat = b0 + x*b1;
	y = 171.1835402;
	put "The predicted y at x-bar is: " y_hat;
	put "The observed y-bar is:       " y;
run;

/*
Suppressed intercept:
 The predicted y at x-bar is: 171.07257091
 The observed y-bar is:       171.1835402

With intercept fitted:
The predicted y at x-bar is: 171.18386
The observed y-bar is:       171.1835402
*/

* 5. Compute a 95% CI for the slope of regressing A on R;
data _NULL_;
	slope = 0.33851;
	SE    = 0.02552;
	lq    = QUANTILE("T", .025, 1532);  
	uq    = QUANTILE("T", .975, 1532);   
	ll    = slope+(lq*SE);              
	ul    = slope+(uq*SE);              
	put "The 95% CI for the slope is (" ll ", " ul ")";
run;
* The 95% CI for the slope is (0.2884521712 , 0.3885678288 );

* Using the above manual method yields the same 95% CI as the following;
proc reg data=bios645.chflheights;
	title "5. Regression of A on R with 95% CI";
	model A_height=R_height /clb;
run;

ods rtf close;