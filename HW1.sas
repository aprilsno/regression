/*
Name: Sara O'Brien
Assignment: HW 1
Date: 1/26/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW1.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create data set in bios645 library;
data bios645.chfl;
	infile "/home/u49497589/BIOS645/Data/Chinese_health_and_family_life_study.txt" DLM="09"X FIRSTOBS=2;
	input R_region :$13. R_age    R_edu :$10. R_income R_health :$9. R_height 
          R_happy  :$15. A_height A_edu :$10. A_income; 
run;   

* Univariate descriptives and plot for region;
proc freq data = bios645.chfl;
	title "1. Univariate stats for woman's region";
	table R_region;
run;

proc sgplot data = bios645.chfl;
	title "Vertical bar graph of woman's region";
	vbar R_region;
run;

* Univariate descriptives and plot for age;
proc univariate data = bios645.chfl;
	title "2. Univariate stats for woman's age";
	var R_age;
run;

proc sgplot data = bios645.chfl;
	title "Histogram of woman's age";
	histogram R_age;
run;

* Univariate descriptives and plot for edu; 
proc freq data = bios645.chfl;
	title "3. Univariate stats for woman's education level";
	table R_edu;
run;

proc sgplot data = bios645.chfl;
	title "Vertical bar graph of woman's education level";
	vbar R_edu;
run;

* Univariate descriptives and plot for income; 
proc univariate data = bios645.chfl;
	title "4. Univariate stats for woman's monthly income";
	var R_income;
run;

proc sgplot data = bios645.chfl;
	title "Histogram of woman's monthly income";
	histogram R_income;
run;

* Univariate descriptives and plot for health;
proc freq data = bios645.chfl;
	title "5. Univariate stats for woman's health status";
	table R_health;
run;

proc sgplot data = bios645.chfl;
	title "Vertical bar graph of woman's health status";
	vbar R_health;
run;

* Univariate descriptives and plot for height;
proc univariate data = bios645.chfl;
	title "6. Univariate stats for woman's height";
	var R_height;
run;

proc sgplot data = bios645.chfl;
	title "Histogram of woman's height";
	histogram R_height;
run;

* Univariate descriptives and plot for happy;
proc freq data = bios645.chfl;
	title "7. Univariate stats for woman's happiness";
	table R_happy;
run;

proc sgplot data = bios645.chfl;
	title "Vertical bar graph of woman's happiness";
	vbar R_happy;
run;

* Univariate descriptives and plot for height 2 (partner);
proc univariate data = bios645.chfl;
	title "8. Univariate stats for partner's height";
	var A_height;
run;

proc sgplot data = bios645.chfl;
	title "Histogram of partner's height";
	histogram A_height;
run;

* Univariate descriptives and plot for edu 2 (partner); 
proc freq data = bios645.chfl;
	title "9. Univariate stats for partner's education level";
	table A_edu;
run;

proc sgplot data = bios645.chfl;
	title "Vertical bar graph of partner's education level";
	vbar A_edu;
run;

* Univariate descriptives and plot for income 2 (partner); 
proc univariate data = bios645.chfl;
	title "10. Univariate stats for partner's monthly income";
	var A_income;
run;

proc sgplot data = bios645.chfl;
	title "Histogram of partner's monthly income";
	histogram A_income;
run;

* Continuous bivariate summary and plot for income (woman) and income (partner);
proc corr data = bios645.chfl NOSIMPLE;
	title "Bivariate summary of woman's income and partner's income";
	var R_income A_income;
run;

proc sgplot data = bios645.chfl;
	title "Scatterplot of woman's income vs partner's income";
	scatter X = R_income Y = A_income;
	reg X = R_income Y = A_income;
run;

* Categorical bivariate summary for health and happy;
proc freq data = bios645.chfl;
	title "Bivariate summary of woman's health and happiness";
	tables R_health*R_happy / NOROW NOCOL NOPCT; 
run;

* Categorical / continuous bivariate summary and plot for income and happy;
proc means data = bios645.chfl N MIN MEDIAN MAX MEAN STD SKEW KURT MAXDEC=3;
	title "Bivariate summary of woman's income and happiness";
	var R_income;  
	class R_happy;      
run;

proc sgplot data = bios645.chfl;
	title "Boxplot of woman's income and happiness";
	vbox R_income /category = R_happy; 
run;

ods rtf close;