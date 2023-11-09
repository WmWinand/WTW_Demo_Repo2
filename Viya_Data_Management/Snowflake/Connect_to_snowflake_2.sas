/*********************************************************************************************************************/
/*
This SAS code is being shared in good faith and 
does not come with any warranty or respective SAS support SLA commitment.
The user accepts this SAS code "AS IS".
*/
/*********************************************************************************************************************/

/******************************************************************/
/******************************************************************/
/* DEMO Segment 1 - Viya CAS Session Start and LIBNAME Connection */
/******************************************************************/
/******************************************************************/
/* Let's start with a clean slate. */
cas _all_ terminate;
libname _ALL_ clear;

/* Start a session and set the active caslib to Casuser.  */
/* You can start a session manually with the CAS statement.  */
/* In this example, the CAS statement starts the CAS session named CASAUTO. */
cas casauto sessopts=(caslib=casuser);

/* The CAS LIBNAME engine connects a SAS session to a CAS session.  */
/* The libref is your link between SAS and the in-memory tables on the CAS server. */
/* This example uses a LIBNAME to my personal Read/Write CASLIB location.  */
Libname MyCAS CAS caslib='CASUSER' datalimit=all;

/********************************************/
/********************************************/
/* DEMO Segment 2 - SAS Viya System Options */
/********************************************/
/********************************************/

/******************************************************************************/
/* Set relevant OPTIONS for Application Development Debugging */
/* Options to help with debugging Macros.  */
Options symbolgen mlogic mprint mrecall;

/* Set Options to help with determining when execution occurs in-database...  */
/* and ensure in-database processing when possible. */
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

/**********************************************************************/
/**********************************************************************/
/* DEMO Segment 3 - SAS9 LIBNAME to Database Management System (DBMS) */
/**********************************************************************/
/**********************************************************************/

/**********************************************************************************/
/* Set up IMPLICIT Libname statement to leverage In-Database PROCS and Data Step. */
/* Set up connection to Snowflake... */
libname snow SNOW 
	server="saspartner.snowflakecomputing.com"
	user=REPRUI 
	pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C"
	schema=REPRUI 
	preserve_tab_names=yes
	bulkload=yes 
	bulkunload=yes 
	bl_internal_stage="user/test1"
	;
/**********************************************************************************/

/**************************************************************/
/**************************************************************/
/* DEMO Segment 4 - Database Management System (DBMS) Utility */
/**************************************************************/
/**************************************************************/

/*************************************************************************************************/
/* Set up "Write Once" Macro to Check for existing table...  */
/* and delete if exists to mitigate file exists errors. */
%macro checkds(dsn);
   %if %sysfunc(exist(&dsn)) %then
      %do;
         proc delete data=&dsn;
         run;
      %end;
%mend checkds;
/* Set up Macro to Check for existing table and delete if exists to mitigate file exists errors. */
/*************************************************************************************************/

/*******************************************************************/
/*******************************************************************/
/* DEMO Segment 5 - Data Movement:  SAS9->DBMS->SAS9 and DBMS->CAS */
/*******************************************************************/
/*******************************************************************/

/*****************************************************************************************************/
/* Bulkload Write a sas dataset to Snowflake DBMS, Bulk Unload to SAS, Load to CAS In-Memory. */
/* NOTE: This will leverage the Bulk Load capabilty established in the LIBNAME Statement. */

/* First Check for existing table and delete using %checkds if exists to mitigate file exists error. */
%checkds(snow.SNOWFLAKE_CARS_IMPLICIT);

/* Write SAS9 data to SNOWFLAKE. */
Data snow.SNOWFLAKE_CARS_IMPLICIT;
	set sashelp.cars;
	run;
Title 'LIBNAME Loading SAS data to SNOWFLAKE snow.SNOWFLAKE_CARS_IMPLICIT';
proc contents data=snow.SNOWFLAKE_CARS_IMPLICIT; run;

/* Write a Snowflake table to SAS Work. */
data work.BULK_UNLOAD_CARS_IMPLICIT;
	set snow.SNOWFLAKE_CARS_IMPLICIT;
	run;
Title 'LIBNAME Bulkunload SNOWFLAKE data to SAS work.BULK_UNLOAD_CARS_IMPLICIT';
proc contents data=work.BULK_UNLOAD_CARS_IMPLICIT; run;

/* Write a Snowflake table to my personal MyCAS In-Memory Library. */
data MyCAS.Client_Offers_ACCESS (replace=Yes);
	length
		SubscriberKey $20.
		OfferIDs $200.
		;
	Format
		SubscriberKey $CHAR20.
		OfferIDs $CHAR200.
		;
	set snow.Client_Offers_New;
	run;
Title 'LIBNAME Loading SNOWFLAKE table to my personal MyCAS In-Memory Library MyCAS.Client_Offers_ACCESS';
proc contents data=MyCAS.Client_Offers_ACCESS; run;
/*****************************************************************************************************/

/*******************************************************************/
/*******************************************************************/
/* DEMO Segment 6 - Data Movement:  DBMS->CAS using PROC CASUTIL   */
/*******************************************************************/
/*******************************************************************/
/*****************************************************************************/
/*  Load SAS data set from a Base engine library (library.tableName) into    */
/*  the specified caslib ("myCaslib") and save as "targetTableName".         */
/*****************************************************************************/
/* Let's start with a clean slate. */
cas _all_ terminate;
libname _ALL_ clear;

cas casauto sessopts=(caslib=casuser);
Libname MyCAS CAS caslib='CASUSER' datalimit=all;
libname snow SNOW 
	server="saspartner.snowflakecomputing.com"
	user=REPRUI 
	pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C"
	schema=REPRUI 
	preserve_tab_names=yes
	bulkload=yes 
	bulkunload=yes 
	bl_internal_stage="user/test1"
	;

caslib SFcaslib 
	desc='Snowflake Caslib' 
	/** Admin option only. **/
/* 	Global	 */
	/************************/ 
	dataSource=(
		srctype='snowflake',          
		server='saspartner.snowflakecomputing.com'
		username='REPRUI',          
		password='{SAS002}B87C6F3C3D2FB7D53AC0FC1C',         
		schema='REPRUI'
		);
	
proc casutil;
	load 
		casdata="Client_Offers_New" 
		incaslib="SFcaslib" 
		outcaslib="casuser"
        casout="Client_Offers_CAS"
		replace
		;  
	/** Admin option only. **/  
/* 	Promote casdata="Client_Offers_CAS" outcaslib="SFcaslib";           */
	/************************/ 
	quit;
Title 'PROC CASUTIL Loading SNOWFLAKE table to my personal MyCAS In-Memory Library MyCAS.Client_Offers_CAS';
proc contents data=MyCAS.Client_Offers_CAS; run;
proc contents data=snow.Client_Offers_New; run;

/******************************************************************/
/******************************************************************/
/* DEMO Segment 7 - SAS9 â€“ Explicit SQL Pass-Through Works Too!!! */
/******************************************************************/
/******************************************************************/

/***************************************************************************************************/
/* Run EXPLICIT pass-through SQL CONNECT TO via the Snowflake Connection */
/* First Check for existing table and delete using %checkds if exists to mitigate file exists error. */
%checkds(snow.SNOWFLAKE_CARS_EXPLICIT);
proc sql;
	connect to SNOW (
		server="saspartner.snowflakecomputing.com"
		user=REPRUI 
		pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C" 
		schema=REPRUI 
		);
		execute	(	
			create table SNOWFLAKE_CARS_EXPLICIT as 
			select * from "USERS_DB"."REPRUI"."SNOWFLAKE_CARS_IMPLICIT"
			) by SNOW;
	disconnect from SNOW;
	quit;
title 'EXPLICIT sql pass-through to Create Table SNOWFLAKE_CARS_EXPLICIT';
proc contents data=snow.SNOWFLAKE_CARS_EXPLICIT; run;
/*** END - Run EXPLICIT passthrough SQL CONNECT TO via the Snowflake Connection ***/
/***************************************************************************************************/

/********************************************************************/
/********************************************************************/
/* DEMO Segment 8 - Terminate your session(s) to preserve resources */
/********************************************************************/
/********************************************************************/

/***************************************************************************************************/
/* At the end of your program, when you no longer need to access data in CAS,  */
/* you can use the following statement to terminate your session(s) to preserve resources. */

cas _all_ terminate;
libname _ALL_ clear;

/***************************************************************************************************/
				