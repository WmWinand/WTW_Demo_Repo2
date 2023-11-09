/*****************************************************************************/
/* ViyaPgm_11: Query Dataset using Proc SQL & CAS Table Using Proc FedSQL    */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01, ViyaPgm_02,          */
/* ViyaPgm_03, ViyaPgm_04, and ViyaPgm_05 PREVIOUSLY                         */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/* ViyaPgm_04: List CAS in-memory tables                                     */
/* ViyaPgm_05: Running DATA Step in Viya                                     */
/* ViyaPgm_06: Running DATA Step with "BIG" Data in Viya                     */
/* ViyaPgm_07: Running a DATA Step with Group By in Viya                     */
/* ViyaPgm_08: Running a DATA Step using Partition and Orderby in CAS        */
/* ViyaPgm_09: Analyze Data using SAS9 Procedures                            */
/* ViyaPgm_10: Analyze Data using Viya Procedures                            */
/*****************************************************************************/
/* options cashost="127.0.0.1" casport=5570; */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib _all_ assign;
caslib _all_ list;
libname mycas cas caslib=casuser;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;


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

cas mySession listhistory;

proc casutil;
   contents casdata="US_FuelEfficient_Cars" incaslib="casuser";
quit;
