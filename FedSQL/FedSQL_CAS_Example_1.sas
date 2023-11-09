/*****************************************************************************/
/* ViyaPgm_11: Query Dataset using Proc SQL & CAS Table Using Proc FedSQL    */
/*****************************************************************************/

/* options cashost="127.0.0.1" casport=5570; */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=TRUE);
caslib _all_ assign;
caslib _all_ list;
libname mycas cas caslib=casuser;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;


/**********************************************************************************/
/*  Query SAS Dataset using Proc SQL - on Compute Server - create SAS dataset     */
/**********************************************************************************/
proc sql;
 create table work.cars_sql as    
   select Origin
        , Make
        , Model
        , MSRP
        , (MPG_City + MPG_Highway)/2 as Average_MPG format=9.2
     from sashelp.cars
     where calculated Average_MPG > 25 
       and Origin eq 'USA'
     order by MSRP
     ;
quit;

/**********************************************************************************/
/*  Query SAS Dataset using Proc SQL - on Compute Server - and load data into CAS */
/**********************************************************************************/
proc sql;
 create table mycas.cars_sql as    
   select Origin
        , Make
        , Model
        , MSRP
        , (MPG_City + MPG_Highway)/2 as Average_MPG format=9.2
     from sashelp.cars
     where calculated Average_MPG > 25 
       and Origin eq 'USA'
     order by MSRP
     ;
quit;



/************************************************************************************/
/*  Query CAS Table using Proc SQL - runs on Compute Server - Creates a SAS Dataset */
/************************************************************************************/
proc sql;
 create table cars_sql as    
   select Origin
        , Make
        , Model
        , MSRP
        , (MPG_City + MPG_Highway)/2 as Average_MPG format=9.2
     from mycas.cars
     where calculated Average_MPG > 25 
       and Origin eq 'USA'
     order by MSRP
     ;
quit;

/**********************************************************************************/
/*  Query CAS Table using Proc FedSQL - on CAS - to create CAS table              */
/**********************************************************************************/
	proc fedsql sessref=mySession;
      drop table US_FuelEfficientCars force;
	  create table casuser.US_FuelEfficientCars as
	    select Make
	        , Model
	        , MSRP
	        , Average_MPG 
	     from casuser.cars_sql
	     where Average_MPG > 25 
	       and Origin = 'USA'
	;
	select * 
	   from casuser.US_FuelEfficientCars
	   order by MSRP
	;
	quit;



proc casutil;
   contents casdata="US_FuelEfficientCars" incaslib="casuser";
run;

cas mySession terminate;

