/* LOAD A TABLE IN CAS AND CREATE A NEW CAS TABLE WITH AN INDEX */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Assign a CAS engine libname */
libname casdm cas caslib="DM" ;

/* load SAS dataset from path caslib to CAS */
proc cas ;
   table.loadtable / path="order_fact.sashdat" caslib="DM" casout={name="order_fact" caslib="DM" replace=true} ;
quit ;

/* Make me bigger */
data casdm.order_fact ;
   set casdm.order_fact ;
   do i=1 to 30 ;
      output ;
   end ;
run ;

/* Create new indexed CAS table from existing CAS table */
proc cas ;
   table.index / table={name="order_fact" caslib="DM"}
      casout={caslib="DM" name="order_fact_ind" indexVars={"date_id"} replace=true} ;
quit ;

/* List in-memory table from path CASLIB DM  */
proc cas ;
   table.tableInfo / caslib="DM" name="order_fact%" wildIgnore=false ;
quit ;

/* View CAS table columns level detail information */
proc cas ;
   table.columninfo / table={caslib="DM" name="order_fact_ind"} ;
quit ;

/* View CAS table summary information */
proc cas ;
   table.tabledetails / caslib="DM" name="order_fact_ind" level="sum" ;
quit ;



/* EXECUTE PROC MDSUMMARY ON INDEXED AND NON-INDEXED TABLE 8/

/* Executing PROC against non-indexed CAS table */
proc mdsummary data=casdm.order_fact ;
   where date_id in ("01feb2008"d,"01feb2009"d,"01feb2010"d,"01feb2011"d,"01mar2008"d,"01mar2009"d,"01mar2010"d,"01mar2011"d) ;
   output out=casdm.mdsum ;
run ;

/* Executing PROC against indexed CAS table */
proc mdsummary data=casdm.order_fact_ind ;
   where date_id in ("01feb2008"d,"01feb2009"d,"01feb2010"d,"01feb2011"d,"01mar2008"d,"01mar2009"d,"01mar2010"d,"01mar2011"d) ;
   output out=casdm.mdsum_ind ;
run ;

cas mySession terminate ;
