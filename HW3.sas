/*
Name: Sara O'Brien
Assignment: HW 3
Date: 2/9/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW3.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.smokecancer;
	infile "/home/u49497589/BIOS645/Data/Smoke_and_cancer.txt" DLM="09"X FIRSTOBS=2;
	input state :$2. cig blad lung kid leuk; 
	keep cig blad lung kid leuk;
run;  

/* 
We are observing the relationship between cig and lung.
We can start by doing a couple simple plots.
*/

* Create a scatterplot of lung on cig;
proc sgplot data = bios645.smokecancer;
	scatter x=cig y=lung;
	reg x=cig y=lung /NOMARKERS;
run;

* We can also look at the histogram to see if there are any spikes/irregularities;
proc sgplot data=bios645.smokecancer;
	histogram lung;
	density   lung /type=normal;
run;

/* 
It is difficult to tell from this scatterplot and histogram whether 
we should be concerned about a particular outlier or other unmet 
assumption. We can proceed with fitting a model.
*/

* Run a simple regression of lung on cig;
proc reg data = bios645.smokecancer;
	model lung=cig;
run;

/*
Homoscedastic: Relatively constant variance
Outliers: potential outlier with a Cook's D around 0.8 (.8 > 4/N=.091). 
	We can save the Cook's D to identify the value associated with it.
Normality: Our qq-plot looks good 
Indepndence: Residuals don't follow specific pattern

We will focus on the errors not being identically distributed.
*/

* Run another proc reg, creating an output dataset with the CD values;
proc reg data = bios645.smokecancer noprint;
	model lung=cig;
	output out=lung_CooksD COOKD=cd; 
run;

* Print the values associated with CD > 4/N to determine which to exclude;
proc print data=lung_CooksD;
	where cd > 0.0909090909;
run;

/*
The value associated with a Cook's D of 0.82479 is 42.40.
There is also a value, 21.58, with a Cook's D of 0.10055. 
*/

* Regress lung on cig, excluding the outliers above;
proc reg data=lung_CooksD;  
	model lung=cig;
	where cd < 0.0909090909;   
run;

/*
The plots of this model all look satisfactory. We can choose to 
also attempt a transformation to see if there can be improvement in
the homoscedasticity
*/

* Transform the y-values using the techniques discussed in class;
data smokecancer_transform;
	set lung_CooksD;            
	lung_ln  = log(lung);    
	lung_rcp = 1/lung; 
	lung_sq = lung**2;
	lung_sqrt = lung**1/2;
run;

* Run regressions of the transformed lung on cig;
proc reg data=smokecancer_transform;
	model lung_ln=cig;
	where cd < 0.0909090909;
proc reg data=smokecancer_transform;
	model lung_rcp=cig;
	where cd < 0.0909090909;
proc reg data=smokecancer_transform;
	model lung_sq=cig;
	where cd < 0.0909090909;
proc reg data=smokecancer_transform;
	model lung_sqrt=cig;
	where cd < 0.0909090909;
run;

/*
None of these models yield considerably better results in terms of their
residual and diagnostic plots. For the sake of simplicity in our model,
we will proceed with the previous model which only excluded the outliers
and did not transform y.
*/

ods rtf close;