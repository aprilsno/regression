/*
Name: Sara O'Brien
Assignment: HW 5
Date: 2/22/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW5.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.glucose;
	infile "/home/u49497589/BIOS645/Data/Pima_fasting_glucose.txt" DLM="09"X FIRSTOBS=2;
	input glucose pregnancies dia_bp skin_fold bmi age; 
run;  

* Use univariate and bivariate descriptives to explore the data;
proc means data = bios645.glucose N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	var glucose pregnancies dia_bp skin_fold bmi age;
run;

proc sgplot data = bios645.glucose;
	histogram glucose;
	density   glucose /type=NORMAL;
proc sgplot data = bios645.glucose;
	histogram pregnancies;
	density   pregnancies /type=NORMAL;
proc sgplot data = bios645.glucose;
	histogram dia_bp;
	density   dia_bp /type=NORMAL;
proc sgplot data = bios645.glucose;
	histogram skin_fold;
	density   skin_fold /type=NORMAL;
proc sgplot data = bios645.glucose;
	histogram bmi;
	density   bmi /type=NORMAL;
proc sgplot data = bios645.glucose;
	histogram age;
	density   age /type=NORMAL;
proc sgplot data = bios645.glucose;
	scatter X=pregnancies Y=glucose;
	reg     X=pregnancies Y=glucose /NOMARKERS;
	loess   X=pregnancies Y=glucose /NOMARKERS;
proc sgplot data = bios645.glucose;
	scatter X=dia_bp Y=glucose;
	reg     X=dia_bp Y=glucose /NOMARKERS;
	loess   X=dia_bp Y=glucose /NOMARKERS;        
proc sgplot data = bios645.glucose;
	scatter X=skin_fold Y=glucose;
	reg     X=skin_fold Y=glucose /NOMARKERS;
	loess   X=skin_fold Y=glucose /NOMARKERS;  
proc sgplot data = bios645.glucose;
	scatter X=bmi Y=glucose;
	reg     X=bmi Y=glucose /NOMARKERS;
	loess   X=bmi Y=glucose /NOMARKERS;  
proc sgplot data = bios645.glucose;
	scatter X=age Y=glucose;
	reg     X=age Y=glucose /NOMARKERS;
	loess   X=age Y=glucose /NOMARKERS;  
run;

* We can also make a matrix to look at marginal & bivariate distributions;
proc corr data = bios645.glucose PLOTS=MATRIX(HISTOGRAM) plots(maxpoints=NONE);
	var glucose pregnancies dia_bp skin_fold bmi age;
run;

* Overall, the data looks okay. Let's run
a multiple regression of glucose on the other variables;

proc reg data = bios645.glucose plots=(residuals(smooth));
	model glucose=pregnancies dia_bp skin_fold bmi age;
run;

* This initial model is essentially satisfactory. If we are concerned
about the one higher Cook's D value in our diagnostic plot, we
can attempt to address this by dropping the potential outlier;

* Run another proc reg, creating an output dataset with the CD values;
proc reg data = bios645.glucose plots=(residuals(smooth));
	model glucose=pregnancies dia_bp skin_fold bmi age;
	output out = glucose_CooksD COOKD=cd;
run;

* Sort the Cook's D data to determine which glucose value is associated
with the high Cook's D that we see in our plot; 
proc sort data=glucose_CooksD;
	by cd;
run; 

proc print data=glucose_CooksD;
	where cd > 0.00751879699;
run;

* An alternative method to identifying this outlier would be to consider
that the residual plot for skin_fold appears to have one outlier.
We can run a simple regression and output the Cook's D from this, following
the same process as above;

proc reg data = bios645.glucose plots=(residuals(smooth));
	model glucose=skin_fold;
	output out = skin_cd cookd=cd;
run;

proc sort data = skin_cd;
	by cd;
run;

proc print data=skin_cd;
	where cd > 0.00751879699;
run;

* The skin_fold=99 value is the one which seems like an outlier
In either case, we see that the potential outlier is associated with the
same woman, so we will exclude her by restricting which Cook's D
values are included in the model;

proc reg data = glucose_CooksD plots=(residuals(smooth));
	model glucose=pregnancies dia_bp skin_fold bmi age;
	where cd < 0.05;
run;

* We can accept this model as satisfactory;

ods rtf close;