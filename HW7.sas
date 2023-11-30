/*
Name: Sara O'Brien
Assignment: HW 7
Date: 3/22/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW7.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.tooth;
	infile "/home/u49497589/BIOS645/Data/Tooth_growth.txt" DLM="09"X FIRSTOBS=2;
	input length type :$2. dose;
	* Create a dummy variable;
	if type='VC' then vc = 1;  
		           else vc = 0;
	interaction = vc*dose;
run;  

* Print data;
proc print data=bios645.tooth;
run;

* Check that manipulations have the correct result;

proc freq data=bios645.tooth;
	TABLES vc*type /NOROW NOCOL NOPERCENT;
run;

* vc perfectly mirrors type, there are equal numbers in each type;

* Plots of data;
proc sgplot data=bios645.tooth;  
	HISTOGRAM dose;
	DENSITY   dose     /TYPE=NORMAL;
proc sgplot data=bios645.tooth;   
	HISTOGRAM length;
	DENSITY   length             /TYPE=NORMAL;
proc sgplot data=bios645.tooth  ;
	VBOX      dose     /CATEGORY=vc;
proc sgplot data=bios645.tooth;
	VBOX      length             /CATEGORY=vc;
proc sgplot data=bios645.tooth;
	SCATTER X=dose Y=length;
	REG     X=dose Y=length /NOMARKERS;
	LOESS   X=dose Y=length /NOMARKERS;
run;

* Scatterplot;
proc sgplot data=bios645.tooth;
	SCATTER X=dose Y=length /GROUP=vc;
run;

* Descriptive statistics;
proc means data=bios645.tooth 
           N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;  
	VAR   dose length;  
proc means data=bios645.tooth 
           N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;  
	VAR   length;
	CLASS vc;  * conditional descriptives, length by type;
proc means data=bios645.tooth 
           N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	VAR   dose;
	CLASS vc;  * conditional descriptives, dose by type;

* Run a full model;
proc reg data=bios645.tooth PLOTS=(RESIDUALS(SMOOTH));
	model length = vc dose interaction /VIF;
run;

/*
Since there is an interaction, we can determine
the relationship between the dose and the 
length depending on whether a guinea pig is in the
vc group or the oj group
*/
data _NULL_;
	B_0    = 11.55000;
	B_vc =  -8.25500;
	B_dose  =  7.81143;
	B_int  =  3.90429	;

	* for type;
	vc_int   = B_0   + B_vc;
	vc_slope = B_dose + B_int;

	PUT "Mean of oj group when dose=0:                       "
        B_0;
	PUT "Mean of vc group when dose=0:                     "
        vc_int;
	PUT "Slope of dose-length relationship for oj group:    "
        B_dose;
	PUT "Slope of dose-length relationship for vc group:   "
        vc_slope;
run;

/*
 Mean of oj group when dose=0:                       11.55
 Mean of vc group when dose=0:                     3.295
 Slope of dose-length relationship for oj group:    7.81143
 Slope of dose-length relationship for vc group:   11.71572
*/


ods rtf close;