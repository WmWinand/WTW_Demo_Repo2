/*********************************************************************************************************************/
/*
This SAS code (Connect to Snowflake using SASIOSNF.sas) is being shared in good faith and 
does not come with any warranty or respective SAS support SLA commitment.
The user accepts this SAS code "AS IS".
*/
/*********************************************************************************************************************/

cas;
Libname MyCAS CAS caslib='CASUSER(Rex.Pruitt@sas.com)' datalimit=all;

/******************************************************************************/
/* BEGIN - Set relevant OPTIONS for Application Development Debugging */
/* Options to help with debugging Macros.  */
Options symbolgen mlogic mprint mrecall;

/* Options to help with determining when execution occurs in-database.  */
OPTION 
	SASTRACE=',,,ds' 
	SASTRACELOC=SASLOG 
	NOSTSUFFIX 
	SQL_IP_TRACE=(note, source) 
	msglevel=i 
	DBIDIRECTEXEC
	sqlgeneration=none
	;
/* END - Set relevant OPTIONS for Application Development Debugging */
/******************************************************************************/
/*********************************************************************************************************************/
/*
This SAS code is being shared in good faith and 
does not come with any warranty or respective SAS support SLA commitment.
The user accepts this SAS code "AS IS".
*/
/*********************************************************************************************************************//*********************************************************************************************/
/* BEGIN - Set up Macro to Check for existing table and delete if exists to mitigate errors. */
%macro checkds(dsn);
   %if %sysfunc(exist(&dsn)) %then
      %do;
         proc delete data=&dsn;
         run;
      %end;
%mend checkds;
/* END - Set up Macro to Check for existing table and delete if exists to mitigate errors. */
/*********************************************************************************************/

/******************************************************************************/
/* BEGIN - Set up IMPLICIT LIbname statements to leverage In-Database PROCS. */
/* Set up connection to Snowflake... */
libname snow SASIOSNF 
	server="saspartner.snowflakecomputing.com"
	user=REPRUI 
	pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C"
	schema=REPRUI 
	preserve_tab_names=yes
	bulkload=yes 
	bulkunload=yes 
	bl_internal_stage="user/test1"
	;

/* Clean up the existing data table. */
%checkds(snow.cars);

/* Write a sas dataset to Snowflake DBMS. */
Data snow.cars;
	set sashelp.cars;
	run;

Title 'PROC PRINT of snow.cars';
proc print data=snow.cars (obs=10); run;

/* Clean up the existing data table. */
%checkds(snow.baseball);

/* Write a sas dataset to Snowflake DBMS. */
Data snow.baseball;
	set sashelp.baseball;
	run;

Title 'PROC PRINT of snow.baseball';
proc print data=snow.baseball (obs=10); run;

/* Write a Snowflake table to SAS Work. */
data work.test;
	set snow.cars;
	run;

/* Write a Snowflake table to my personal CAS Library. */
data MyCAS.cars_from_snow;
	set snow.cars;
	run;
cas _all_ terminate;