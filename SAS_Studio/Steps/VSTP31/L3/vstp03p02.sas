%macro printSample;/*A*/

%let whereAlso= ;/*B*/
%do i = 1 %to &filterCol2List_count ;/*C*/
   %if &i=1 %then /*D*/
      %let whereAlso="%sysfunc(trim(&&filterCol2List_&i))";/*B*/
   %else %let whereAlso=&whereAlso,"%sysfunc(trim(&&filterCol2List_&i))";/*D*/
%end ;/*E*/

%put whereAlso=&whereAlso ;/*F*/

proc surveyselect /*1*/
	data=&inputTable/*2*/
	out=Sample  /*3*/
	sampsize=&numObs /*4*/
	noprint/*5*/
	method=&method;/*6*/
	%if &filterColumn1 ne  %then %do; /*D*/
		where &filterColumn1 ="&filterCol1DropDown";/*7*/
	%end;/*E*/
	%if &filterColumn2 ne  %then %do;/*D*/
		where also &filterColumn2 in (&whereAlso);/*9*/
	%end;/*E*/
run;/*7*/

%if &chkTitle=1 %then %do;/*D*/
title color="#&pickColor" "A Random Sample from &inputTable";/*8*/
%end;/*E*/

proc print  /*9*/
	data=Sample;/*2*/
	var &varList;/*10*/
run;/*7*/

title;/*11*/

%mend printSample;
%printSample;
/*
A. The %MACRO macro statement begins a macro definition and names the macro program.
B. The %LET macro statement creates a macro vaiable and assigns the value.
C. The %DO begins a %DO group and must be used inside a macro definition.
D. The %IF-%THEN %ELSE macro statement conditionally processes a portion of a macro.
E. The %END macro statement ends a %DO group.
F. The %PUT macro statement writes text or macro variable information to the SAS log.

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





