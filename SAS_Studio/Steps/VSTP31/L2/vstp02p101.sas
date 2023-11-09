/*About Info:
This custom step creates an report that contains a random sample from an input data set.

Prompts include:
- a Numeric Stepper to enable the user to choose the number of rows to output/print.


Created By:
Date Created:
Version:
*/

proc surveyselect /*1*/
	data=sashelp.shoes /*2*/
	out=Sample  /*3*/
	sampsize=10 /*4*/
	noprint;/*5*/
run;/*6*/

proc print /*7*/ 
	data=Sample;/*2*/
run;/*6*/

/*
1. The SURVEYSELECT procedure provides a variety of methods for selecting probability-based random samples. 
2. The data=specifies the input data set.
3. The out= specifies the output data set.
4. The sampsize= option specifies a sample size value, which must be a positive integer. 
5. The noprint option supresses the display of the output. 
6. The RUN statement executes the previously entered SAS statements.
7. The PRINT procedure prints the observations in a SAS data set. 
*/