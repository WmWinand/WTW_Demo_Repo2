/* PERFORM A SERIAL SAVE TO ORC FORMAT */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* CASLIB Path data source located on CAS controller */
/* commented since its pre-defined */
/*
caslib DM path="/gelcontent/data/" type=path;
*/

/* Load a SASHDAT file in the DM CASLIB */
proc casutil incaslib="DM" outcaslib="DM";
   load casdata="order_fact.sashdat" casout="order_fact" replace ;
   list tables ;
quit ;

/* Save the CAS table as an ORC file in the same CASLIB */
proc casutil incaslib="DM" outcaslib="DM";
   save casdata="order_fact" casout="order_fact.orc" replace ;
   list files ;
quit ;




/* PERFORM A PARALLEL SAVE TO PARQUET FORMAT */

/* CASLIB DNFS data source located on CAS controller AND CAS workers */
/* commented since its pre-defined */
/*
caslib DM_DNFS description="OS Directory accessible from every CAS Node (Controller+Workers)"
   datasource=(srctype="dnfs") path="/gelcontent/data/NFS/" subdirs global ;
*/

/* Load a SASHDAT file in the DM_DNFS CASLIB */
proc casutil incaslib="DM_DNFS" outcaslib="DM_DNFS";
   load casdata="big_prdsale.sashdat" casout="big_prdsale" replace ;
   list tables ;
quit ;

/* Save the CAS table as a Parquet file in the same CASLIB */
proc casutil incaslib="DM_DNFS" outcaslib="DM_DNFS";
   save casdata="big_prdsale" casout="big_prdsale.parquet" replace ;
   list files ;
quit ;

proc cas ;
   table.fileInfo / caslib="DM_DNFS" kbytes=true path="big_prdsale.parquet" ;
quit ;

cas mySession terminate ;




/* PERFORM A MULTI-NODE SAVE TO POSTGRESQL */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

caslib _all_ assign ;

%macro libchk ; %if %sysfunc(libref(caspg))=0 %then %do ; caslib caspg clear ; %end ; %mend ; %libchk ;

caslib caspg datasource=(srctype="postgres",username="sas",password="lnxsas",server="gel-postgresql.postgres.svc.cluster.local",
   database="student",schema="public",numreadnodes=10,numwritenodes=10) libref=caspg ;

/* Load a table in CAS */
proc casutil incaslib="caspg" outcaslib="caspg" ;
   droptable casdata="SAS_airline" quiet ;
   load data=sashelp.airline casout="SAS_airline" ;
   list tables ;
quit ;

/* Perform a multi-node save of this CAS table to PostgreSQL */
proc casutil incaslib="caspg" outcaslib="caspg" ;
   save casdata="SAS_airline" casout="SAS_airline" replace ;
   list files ;
quit ;

cas mySession terminate;



