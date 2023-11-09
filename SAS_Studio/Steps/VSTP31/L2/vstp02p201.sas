/*About info:
This custom step creates a report that contains a random sample
from an input data set, along with a title. 


Options include:
- an Input Table to enable the user to choose the input table.
- a Radio Button Group to enable the user to choose random selection method.
- a Numeric Stepper to enable the user to choose the number of rows to output/print.
- a Column Selector to enable the user to choose multiple columns to print.
- Text that states the title.
- a Color Picker to enable the user to choose the color of the title.

Created By: 
Date Created:
Version: 
*/

proc surveyselect /*1*/
	data=&inputTable/*2*/
	out=Sample  /*3*/
	sampsize=&numObs /*4*/
	noprint/*5*/
	method=&method;/*6*/
run;/*7*/

title color="#&pickColor" "A Random Sample from &inputTable";/*8*/
proc print  /*9*/
	data=Sample;/*2*/
	var &varList;/*10*/
run;/*7*/

title;/*11*/

/*
1. The SURVEYSELECT procedure provides a variety of methods for selecting probability-based random samples. 
2. The data=specifies the input data set.
3. The out= specifies the output data set.
4. The sampsize= option specifies a sample size value, which must be a positive integer. 
5. The noprint option supresses the display of the output. 
6. The method= option specifies the sample selection method.
7. The RUN statement executes the previously entered SAS statements.
8. The TITLE statement specifies title lines for SAS output.
9. The PRINT procedure prints the observations in a SAS data set. 
10.The VAR statement selects variables that appear in the report and determines their order.
11.Using TITLE without arguments cancels all existing titles. 
*/