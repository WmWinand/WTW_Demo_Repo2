/*****************************************************************/
/*  Create a default CAS session and create SAS librefs for      */
/*  existing caslibs so that they are visible in the SAS Studio  */
/*  Libraries tree.                                              */
/*****************************************************************/
cas casauto; 
caslib _all_ assign;

libname mycas cas caslib=casuser;


%if %sysfunc(exist(casuser.cars)) %then %do;

  proc casutil;
    droptable casdata="cars";
  run;

%end;

proc casutil;
  load data=sashelp.cars casout="cars" promote;
quit;


/*****************************************************************/
/*  Define macro variables for:                                  */
/*  lib- caslib                                                  */
/*  ds- dataset/ CAS table                                       */
/*  libds- caslib.table                                          */
/*****************************************************************/
%let lib = mycas;
%let ds = cars;
%let libds = &lib..&ds.;

%let _var=MSRP;

/*****************************************************************/
/*  Execute PROC UNIVARIATE with selected variable               */
/*****************************************************************/

title1 'Basic Summary Statistics';
footnote '<a href= "/SASJobExecution/?_program=/Users/T.Winand@sas.com/My Folder/Jobs/2_Returning_Results_w_HTML"> Click here to pick a different variable</a>';
proc univariate data=&libds.;
	var &_var.;
run;


cas casauto terminate;