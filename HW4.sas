/*
Name: Sara O'Brien
Assignment: HW 4
Date: 2/16/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW4.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.steroid;
	infile "/home/u49497589/BIOS645/Data/Women's_steroid_levels.txt" DLM="09"X FIRSTOBS=2;
	input steroid age; 
run;  

* Use univariate descriptives to look at the data;
proc means data = bios645.steroid N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	VAR steroid age;
run;

proc sgplot data = bios645.steroid;
	histogram age;
	density   age /type=NORMAL;
proc sgplot data = bios645.steroid;
	histogram steroid;
	density   steroid /type=NORMAL;
run;

* No immediate concerns, we can proceed with a simple regression;

* 2. Run a simple linear regression of steroid on age;

proc reg data = bios645.steroid;
	model steroid=age;
run;

* There may be a meaningful pattern underlying this model, we can confirm with a LOWESS curve;
proc reg data = bios645.steroid plots=(residuals(smooth));
	model steroid=age;
run;

* 3. Add a power to the model;
data bios645.steroid2;       
	set bios645.steroid;     
	age2 = age**2; 
run;

* Run the regression again with both x terms;
proc reg data = bios645.steroid2 plots=(residuals(smooth));
	model steroid=age age2;
run;

* This model looks much better in terms of heteroscedasticity;

* If we want to plot this model, we can calculate y-hats with a do loop,
insert them into a dataset, and overlay this on a scatterplot of the original values;
data y_hats;
	do i = 8 to 25 by 1;  * every .5, compute another y-hat;
		x_plot  = i;
		y_hat   = -26.32541 + 4.87357*x_plot + -0.11840*x_plot**2;
		drop i;
	   	output;
	end;
run;

data steroid2_plot_data;
	set bios645.steroid   y_hats;  * reads in 2 sets & stacks them;
run;

proc sgplot data=steroid2_plot_data;
	scatter x=age y=steroid;
	series  x=x_plot y=y_hat;
run;

ods rtf close;