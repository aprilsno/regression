/*
Name: Sara O'Brien
Assignment: HW 6
Date: 3/2/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW6.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.fertility;
	infile "/home/u49497589/BIOS645/Data/Swiss_fertility.txt" DLM="09"X FIRSTOBS=2;
	input municipality :$20. fertility agriculture examination education catholic InfantMortality; 
	interact = education*catholic; *create the interaction term;
	keep fertility agriculture examination education catholic InfantMortality interact;
run;  

* Visualize the data;
proc corr data=bios645.fertility plots=matrix(histogram nvar=all);
	var fertility agriculture examination education catholic InfantMortality ;
run;

* There appears to be some correlations, let's keep this in mind when running
our regressions;

* 1. Fit a model with the interaction term;
proc reg data=bios645.fertility plots=(RESIDUALS(SMOOTH));
	model fertility=agriculture examination education catholic InfantMortality interact;
run;

* Run a proc means to look at Catholic data;
proc means data=bios645.fertility N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	var catholic;
run;

* Based on this, we will arbitrarily set low, medium, and high values of 
Catholic at 0, 50, and 100 to better understand the model above;

* We also need the means for the vars that are controlled for in the model;
proc means data=bios645.fertility N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	var agriculture examination InfantMortality;
run;

/*
Mean of agr: 50.660
Mean of exam: 16.489
Mean of infantmortality: 19.943
*/

* Compute simple effect of education at these 3 levels;

data _null_;
	low    = -0.31333 + -0.01248*0; 
	mean    = -0.31333 + -0.01248*50; 
	high   = -0.31333 + -0.01248*100;
	low_i  = 59.50006 + -0.15601*50.660 + -0.35675*16.489 + 1.25531*19.943 + 0.18758*0;  
	mean_i  = 59.50006 + -0.15601*50.660 + -0.35675*16.489 + 1.25531*19.943 + 0.18758*50; 
	high_i = 59.50006 + -0.15601*50.660 + -0.35675*16.489 + 1.25531*19.943 + 0.18758*100;
	PUT "intercept at catholic=0  =  " low_i;
	PUT "    slope at catholic=0  = "  low;
	PUT "intercept at catholic=50  =  " mean_i;
	PUT "    slope at catholic=50  = "  mean;
	PUT "intercept at catholic=100 = "  high_i;
	PUT "    slope at catholic=100 =  " high;
run;

/* from log:
 intercept at catholic=0  =  70.74878998
     slope at catholic=0  = -0.31333
 intercept at catholic=50  =  80.12778998
     slope at catholic=50  = -0.93733
 intercept at catholic=100 = 89.50678998
     slope at catholic=100 =  -1.56133
*/

* We can also plot the data obtained above to be able to 
better interpret and communicate the model;
data interaction_plot_data;
	set bios645.fertility;
	low  = 70.74878998 +  -0.31333*education;
	mean = 80.12778998 + -0.93733*education;
	high = 89.50678998 + -1.56133*education;
run;

proc sgplot DATA=interaction_plot_data;
	scatter X=education Y=fertility / LEGENDLABEL="data";  
	reg     X=education Y=low  /NOMARKERS LEGENDLABEL="Percent Catholic = 0%";
	reg     X=education Y=mean /NOMARKERS LEGENDLABEL="Percent Catholic = 50%";
	reg     X=education Y=high /NOMARKERS LEGENDLABEL="Percent Catholic = 100%";
run;

* 2. Fit two models: one regressing fertility on all the variables except education, 
then on all the variables including education;

* Excluding education;
proc reg data=bios645.fertility plots=(RESIDUALS(SMOOTH));
	model fertility=agriculture examination catholic InfantMortality /VIF CLB;
run;

* Including education;
proc reg data=bios645.fertility plots=(RESIDUALS(SMOOTH));
	model fertility=agriculture examination education catholic InfantMortality /VIF;
run;

* We will interpret these models as they are;

ods rtf close;