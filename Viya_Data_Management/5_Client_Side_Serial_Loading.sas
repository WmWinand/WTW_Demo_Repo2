/* PERFORM CLIENT SIDE CSV LOAD */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

%let myworkpath=%sysfunc(pathname(work)) ;

/* Save a csv file under SASWORK's directory */
proc export data=sashelp.prdsale
   outfile="&myworkpath/prdsale.csv" replace dbms=dlm ;
   putnames=yes ;
   delimiter=',' ;
run ;

/* Drop in-memory CAS table if it exists */
proc casutil ;
   droptable casdata="csv_client_prdsale" incaslib="DM" quiet ;
quit ;

/* Load csv file from client machine to CAS */
proc casutil ;
   load file="&myworkpath/prdsale.csv"
        outcaslib="DM" casout="csv_client_prdsale" copies=0 ;
quit ;

/* List in-memory table from path CASLIB DM */
proc casutil ;
   list tables incaslib="DM" ;
quit ;

cas mySession terminate ;



/* PERFORM A CLIENT-SIDE SAS DATASET LOAD */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Assign a BASE SAS library */
/* Commented since pre-assigned
libname sasdm "/gelcontent/data" ; */

/* Drop in-memory CAS table  */
proc casutil ;
   droptable casdata="sas_client_prdsale" incaslib="DM" quiet ;
quit ;

/* Load SAS dataset from client machine to CAS */
/* Notice where clause, repeat, and compress statement during data load */
proc casutil ;
   load data=sasdm.prdsale(where=(country="U.S.A."))
      outcaslib="DM" casout="sas_client_prdsale" repeat compress ;
quit ;

/* List in-memory table from path CASLIB DM */
proc casutil ;
   list tables incaslib="DM" ;
quit ;

cas mySession terminate ;



/* PERFORM A CLIENT SIDE DATA STEP LOAD */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Assign a BASE SAS library */
/* Commented since pre-assigned
libname sasdm "/gelcontent/data" ; */

/* Assign a CAS engine library */
libname myCaslib cas caslib="DM" ;

/* Drop in-memory CAS table if it exists */
proc casutil ;
   droptable casdata="ds_prdsale" incaslib="DM" quiet ;
quit ;

/* Load SAS dataset from client machine to CAS */
data myCaslib.ds_prdsale ;
   set sasdm.prdsale ;
run;

/* List in-memory table from path CASLIB DM  */
proc casutil ;
   list tables incaslib="DM" ;
quit ;

cas mySession terminate ;




/* PERFORM A CLIENT SIDE SAS PROCEDURE LOAD */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Assign a BASE SAS library */
/* Commented since pre-assigned
libname sasdm "/gelcontent/data" ; */

/* Assign a CAS engine library */
libname myCaslib cas caslib="DM" ;

/* Drop in-memory CAS table if it exists */
proc casutil ;
   droptable casdata="sql_prdsale" incaslib="DM" quiet ;
quit ;

/* Load SAS dataset using SAS proc sql from client machine to CAS */
proc sql noprint ;
   create table myCaslib.sql_prdsale as select country, year, sum(actual) as total_actual
   from sasdm.prdsale group by country, year ;
quit ;

/* List in-memory table from path CASLIB DM  */
proc casutil ;
   list tables incaslib="DM" ;
quit ;

cas mySession terminate ;



