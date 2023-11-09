/*About Info:
This custom step creates an output data table that is filtered by 
a chosen value of a ranked column. For example, the top 5 sales made.

Prompts include:
 - a Numeric Stepper to enable the user to filter the ranked rows/observations.

Created By:
Date Created:
Version:
*/


proc rank  /*1*/
		data=sashelp.cars /*2*/
		out=Rank /*3*/
		(where = (rank_MSRP<=10)) /*4*/
		descending; /*5*/
    var MSRP;   /*6*/
    ranks rank_MSRP; /*7*/
run; /*8*/

/*
1. The RANK procedure computes ranks for one or more numeric variables.
2. The data=specifies the input data set.
3. The out= specifies the output data set.
4. The where= data set option on the output data uses specific conditions to write observations to the SAS data set.
5. The descending option reverses the direction of the ranks. With DESCENDING, the largest value receives a rank of 1.
6. The VAR statement specifies the ranking variable(s).
7. The RANKS statement creates new variables for the rank values.
8. The RUN statement executes the previously entered SAS statements.
*/
