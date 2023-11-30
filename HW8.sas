/*
Name: Sara O'Brien
Assignment: HW 8
Date: 4/20/22
*/

* Create rtf output;
ods rtf file='/home/u49497589/BIOS645/Output/OBrien_HW8.rtf' gtitle startpage=no bodytitle;
ods noproctitle;

* Create ref to course data folder;
libname bios645 "/home/u49497589/BIOS645";

* Create permanent data set in bios645 library;
data bios645.quiz;
	infile "/home/u49497589/BIOS645/Data/Quiz_questions2.txt" DLM="09"X FIRSTOBS=2;
	input student q13_y q13_x q22_y q22_x q41_y q41_x;
run;  

* Question 13 simple logistic regression;
proc logistic data=bios645.quiz DESCENDING
			  PLOTS(ONLY)=(ODDSRATIO EFFECT ROC); 
	MODEL  q13_y=q13_x;  * "DESCENDING" (above) means we model Y = 1;
	*OUTPUT OUT=results_int P=predict_int; 
run;

* Question 22 simple logistic regression;
proc logistic data=bios645.quiz DESCENDING
			  PLOTS(ONLY)=(ODDSRATIO EFFECT ROC); 
	MODEL  q22_y=q22_x;  * "DESCENDING" (above) means we model Y = 1;
run;


* Question 41 simple logistic regression;
proc logistic data=bios645.quiz DESCENDING
			  PLOTS(ONLY)=(ODDSRATIO EFFECT ROC); 
	MODEL  q41_y=q41_x;  * "DESCENDING" (above) means we model Y = 1;
run;

ods rtf close;