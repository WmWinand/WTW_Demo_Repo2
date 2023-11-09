/*****************************************************************************/
/* ViyaPgm_HOW: Complete Program                                             */
/*****************************************************************************/

/*****************************************************************************/
/* This program contains all code steps that are associated with the         */
/* following indepent code examples                                          */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/* ViyaPgm_04: List CAS in-memory tables                                     */
/* ViyaPgm_05: Run DATA Step in Viya                                         */
/* ViyaPgm_06: Run DATA Step with "BIG" Data in Viya                         */
/* ViyaPgm_07: Run a DATA Step with Group By in Viya                         */
/* ViyaPgm_08: Run a DATA Step using Partition and Orderby in CAS            */
/* ViyaPgm_09: Analyze Data using SAS9 Procedures                            */
/* ViyaPgm_10: Analyze Data using Viya Procedures                            */
/* ViyaPgm_11: Query Dataset using Proc SQL & CAS Table Using Proc FedSQL    */
/* ViyaPgm_12: Create and Use User-Defined Formats in CAS                    */
/* ViyaPgm_13: Clean Up                                                      */
/*****************************************************************************/

/*****************************************************************************/
/*  Set the options necessary for creating a connection to a CAS server.     */
/*  Once the options are set, the cas command connects the default session   */ 
/*  to the specified CAS server and CAS port, for example the default value  */
/*  is 5570.                                                                 */
/*****************************************************************************/

/* options cashost="127.0.0.1" casport=5570; */

/*****************************************************************************/
/*  Start a session named mySession using the existing CAS server connection */
/*  while allowing override of caslib, timeout (in seconds), and locale     */
/*  defaults.                                                                */
/*****************************************************************************/

cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");


/*****************************************************************************/
/*  Create SAS librefs for existing caslibs                                  */
/*  so that they are visible in the SAS Studio Libraries tree.               */
/*  Create a separate libref for the casuser caslib                          */
/*****************************************************************************/

caslib _all_ assign;
caslib _all_ list;

libname mycas cas caslib=casuser;

%let path=/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data;
libname mysas "&path"; 


/*****************************************************************************/
/*  Three simple ways to load a SAS dataset into a CASLIB as a CAS in-memory */
/*  table                                                                    */
/*****************************************************************************/

data mycas.cars;
  set sashelp.cars;
run;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;

proc sql;
  create table mycas.cars as
    select * from sashelp.cars;
quit;


/*****************************************************************************/
/*  Using PROC CASUTIL to load xlsx and csv files                            */
/*****************************************************************************/

proc casutil;
    load file="&path/products.xlsx"
    casout='myproducts'
    outcaslib='casuser'
    importoptions=(filetype='excel' getnames=true)
    replace;

    load file="&path/sales.csv"
    casout='mysales'
    outcaslib='casuser'
    importoptions=(filetype='csv' getnames=true)
    replace;
quit;   


/*****************************************************************************/
/*  Using PROC CASUTIL to list in-memory tables                              */
/*****************************************************************************/

proc casutil;
  list tables;
quit;


/*****************************************************************************/
/*  Running a DATA Step in SAS9 (Compute Server)                             */
/*****************************************************************************/

data work.cars;
  set sashelp.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  Keep origin Make Model Type MSRP MPG_City MPG_Highway Average_MPG;
run;



/*****************************************************************************/
/*  Running a DATA Step in CAS Using CAS In-Memory Tables                    */
/*****************************************************************************/

data mycas.cars;
  set mycas.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  Keep origin Make Model Type MSRP MPG_City MPG_Highway Average_MPG;
run;


/*****************************************************************************/
/*  Running a DATA Step with Big Data in SAS9 (Compute Server)                */
/*****************************************************************************/
data bigcars;
  set sashelp.cars;

  do i=1 to 100000;
    output;
  end;
run;

data bigcars_score;
  set bigcars;

  length myscore 8;
  myscore=0.3*Invoice/(MSRP-Invoice)
    + 0.5*(EngineSize+Horsepower)/Weight + 0.2*(MPG_City+MPG_Highway);
run;


/*****************************************************************************/
/*  Running a DATA Step with Big Data in CAS                                 */
/*****************************************************************************/
data mycas.bigcars;
  set mycas.cars;

  do i=1 to 100000;
    output;
  end;
run;

data mycas.bigcars_score;
  set mycas.bigcars;

  length myscore 8;
  myscore=0.3*Invoice/(MSRP-Invoice)
    + 0.5*(EngineSize+Horsepower)/Weight + 0.2*(MPG_City+MPG_Highway);
  Thread=_threadid_;
run;


/*****************************************************************************/
/*  Runninga DATA Step with Group By in SAS9 (Compute Server)                */
/*****************************************************************************/
proc sort data=sashelp.cars out=sort_cars;
  by Type MSRP;
run;

data cars2;
  set sort_cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  keep Make Model Type Average_MPG MSRP LowMSRP HighMSRP;

  by Type;
  if first.Type then LowMSRP=1;
    else LowMSRP=0;
  if last.Type then HighMSRP=1;
    else HighMSRP=0;
run;


/*****************************************************************************/
/*  Running a DATA Step with Group By in CAS                                 */
/*****************************************************************************/
data mycas.cars2;
  set mycas.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  keep Make Model Type Average_MPG MSRP LowMSRP HighMSRP;

  by Type MSRP;
  if first.Type then LowMSRP=1;
    else LowMSRP=0;
  if last.Type then HighMSRP=1;
    else HighMSRP=0;
run;


/*****************************************************************************/
/*  Running a DATA Step using Partition and Orderby in CAS                   */
/*****************************************************************************/
data mycas.cars2 (partition=(type) orderby=(MSRP));
  set mycas.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  keep Make Model Type Average_MPG MSRP LowMSRP HighMSRP;

  by Type;
  if first.Type then LowMSRP=1;
    else LowMSRP=0;
  if last.Type then HighMSRP=1;
    else HighMSRP=0;
run;


/*****************************************************************************/
/*  Analyze Data Using SAS9 Procedures                                       */
/*****************************************************************************/
proc means data=sort_cars chartype mean std min max n range vardef=df;
	var MSRP;
	output out=mycas.cars_means mean=std=min=max=n=range= / autoname;
	by Type;  
run;

proc means data=mycas.cars chartype mean std min max n range vardef=df;
	var MSRP;
	output out=mycas.cars_means mean=std=min=max=n=range= / autoname;
	by Type;  
run;

proc print data=mycas.cars_means;
run;


/*****************************************************************************/
/*  Analyze Data Using Viya Procedures                                       */
/*****************************************************************************/
proc mdsummary data=mycas.cars;
  groupby Type;
  var MSRP;
  output out=mycas.cars_mdsstats (replace=yes);
quit;

proc print data=mycas.cars_mdsstats;
run;


/*****************************************************************************/
/*  Query SAS Dataset using Proc SQL and CAS Table Using Proc FedSQL         */
/*****************************************************************************/
proc sql;
/* create table mycas.cars_sql as    */
   select Make
        , Model
        , MSRP
        , (MPG_City + MPG_Highway)/2 as Average_MPG format=9.2
     from sashelp.cars
     where calculated Average_MPG > 25 
       and Origin eq 'USA'
     order by MSRP
     ;
quit;

%if not %sysfunc(exist(mycas.US_FuelEfficient_Cars)) %then %do;

	proc fedsql sessref=Mysession;
	create table casuser.US_FuelEfficient_Cars as
	   select Make
	        , Model
	        , MSRP
	        , put((MPG_City + MPG_Highway)/2, 9.2) as Average_MPG 
	     from casuser.cars
	     where (MPG_City + MPG_Highway)/2 > 25 
	       and Origin = 'USA'
	;
	select * 
	   from casuser.US_FuelEfficient_Cars
	   order by MSRP
	;
	quit;

%end;

proc print data=casuser.US_FuelEfficient_Cars;
run;

cas mySession listhistory;

proc casutil;
   contents casdata="US_FuelEfficient_Cars" incaslib="casuser";
run;



/*****************************************************************************/
/* Creating and Using a User-defined Format in SAS9 (Compute Server)         */
/*****************************************************************************/
proc format;
  value pricerange_sas low-25000=”Low”
                       25000<-50000=”Mid”
                       50000<-75000=”High”
                       75000<-high=”Luxury”;
run;

data cars_formatted;
  set sashelp.cars;

  format MSRP pricerange_sas.;
  keep Make Model MSRP MPG_Highway;
run;

proc print data=cars_formatted;
run;


/*****************************************************************************/
/* Creating and Using a User-defined Format in CAS                           */
/*****************************************************************************/
proc format casfmtlib="casformats";
  value pricerange_cas low-25000=”Low”
                       25000<-50000=”Mid”
                       50000<-75000=”High”
                       75000<-high=”Luxury”;
run;

data mycas.cars_formatted;
 set sashelp.cars;

  format MSRP pricerange_cas.;
  keep Make Model MSRP MPG_Highway;
run;

proc mdsummary data=mycas.cars_formatted;
  var MPG_Highway;
  groupby MSRP / out=mycas.cars_summary;
run;

proc print data=mycas.cars_summary;
run;

/*****************************************************************************/
/* ViyaPgm_10: Cleaning Up                                                   */
/*****************************************************************************/

/* LIST FILES AND TABLES ASSOCIATED WITH OUR CASLIB*/
proc casutil;
  list files incaslib=casuser;
  list tables incaslib=casuser;
run;

/* USING PROC CASUTIL TO SAVE IN MEMORY TABLES TO PERSISTENT STORAGE */
proc casutil;
  save casdata="cars" incaslib="casuser" replace;
  save casdata="bigcars" incaslib="casuser" replace;
quit;
 

/* RELEASING OUR TABLES FROM MEMORY */
proc casutil;
  droptable incaslib="casuser" casdata="cars";
  droptable incaslib="casuser" casdata="bigcars";
  droptable incaslib="casuser" casdata="bigcars_score";
  droptable incaslib="casuser" casdata="cars2";
  droptable incaslib="casuser" casdata="myproducts";
  droptable incaslib="casuser" casdata="mysales";
quit;


/* LIST FILES AND TABLES ASSOCIATED WITH OUR CASLIB TO SEE WHAT HAS CHANGED */
proc casutil;
  list files incaslib=casuser;
  list tables incaslib=casuser;
quit;

/* TERMINATE SESSION AND RELEASE RESOURCES */
cas mySession terminate;
