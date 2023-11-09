/*About Info:
This custom step creates an output data set that is filtered by 
a chosen value of a ranked column. For example, the Top 5 sales made.

Prompts include:
 - a Numeric Stepper to enable the user to filter the ranked rows/observations.
 - an Input Table to enable the user to choose the input table.
 - an Output Table to enable the user to choose the output table.
 - a Column Selector to enable the user to choose a single numeric column to rank.
 - a Column Selector to enable the user to choose a single column to filter.
 - a Drop-down List to enable the user to select a single dynamic value from a drop down list.
 
Created By:
Date Created:
Version:
Testing macro variables:
*/
%let numobs=15;
%let inputTable=sashelp.cars;
%let outputTable=Ranked;
%let rankCol=Invoice;
%let filterColumn1=Origin;
%let filterCol1DropDown=Europe;

proc rank  /*1*/
		data=&inputTable /*2*/
		out=&outputTable /*3*/
		(where = (rank_&rankCol<=&numobs)) /*4*/
		descending; /*5*/
	%if &filterColumn1 ne  %then %do; /*6*/
		where &filterColumn1 ="&filterCol1DropDown";/*7*/
	%end;/*8*/
    var &rankCol;   /*9*/
    ranks rank_&rankCol; /*10*/
run; /*11*/

/*
1. The RANK procedure computes ranks for one or more numeric variables.
2. The data=specifies the input data set.
3. The out= specifies the output data set.
4. The where= data set option on the output data uses specific conditions to write observations to the SAS data set.
5. The descending option reverses the direction of the ranks. With DESCENDING, the largest value receives a rank of 1.
6. The %IF %THEN %DO statement conditionally process a portion of macro/code.
7. The WHERE statement selects rows from SAS tables that meet a particular condition.
8. The %END statement ends a %DO group.
9. The VAR statement specifies the ranking variable(s).
10.The RANKS statement creates new variables for the rank values.
11.The RUN statement executes the previously entered SAS statements.
*/
