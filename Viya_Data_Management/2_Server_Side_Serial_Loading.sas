/* SERIAL LOAD FROM A SAS DATASET */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* CASLIB Path data source accessible from the CAS controller */
/* commented since its pre-defined */
/*
caslib DM path="/gelcontent/data/" type=path;
*/

/* Assign a CAS Engine library to DM */
libname casdm cas caslib="DM" ;

/* List available source files/tables which can be loaded to CAS */
proc casutil ;
   list files incaslib="DM" ;
quit ;

/* Drop in-memory CAS table in case it already exists */
proc casutil ;
   droptable casdata="sas_prdsale" incaslib="DM" quiet ;
quit ;

/* Load SAS dataset from path caslib DM to CAS */
proc casutil ;
   load casdata="prdsale.sas7bdat" incaslib="DM"
   outcaslib="DM" casout="sas_prdsale" promote ;
quit ;

/* List in-memory tables from path CASLIB DM  */
proc casutil ;
   list tables incaslib="DM" ;
quit ;

cas mySession terminate ;



/* DROP THE PROMOTED CAS TABLE */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Drop in-memory CAS table  */
proc casutil ;
   droptable casdata="sas_prdsale" incaslib="DM" quiet ;
quit ;

cas mySession terminate ;



/* SERIAL LOAD OF POSTGRESQL DATABASE TABLE */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Clear CASLIB if exists */
caslib _all_ assign ;
%macro libchk ; %if %sysfunc(libref(caspgdvd))=0 %then %do ; caslib caspgdvd clear ; %end ; %mend ; %libchk ;

/* Create session scoped CASLIB  */
caslib caspgdvd
   datasource=(srctype="postgres",username="sas",password="lnxsas",
   server="gel-postgresql.postgres.svc.cluster.local",database="dvdrental",schema="public") libref=caspgdvd ;

/* List available source files/tables which can be loaded to CAS */
proc casutil ;
   list files incaslib="caspgdvd" ;
quit ;

/* Drop in-memory CAS table in case it already exists */
proc casutil ;
   droptable casdata="pg_film" incaslib="caspgdvd" quiet ;
quit ;

/* Load a PGSQL table to CAS */
proc casutil ;
   load casdata="film" incaslib="caspgdvd"
   casout="pg_film" outcaslib="caspgdvd" ;
quit ;

/* List in-memory tables from CASLIB caspgdvd */
proc casutil ;
   list tables incaslib="caspgdvd" ;
quit ;

cas mySession terminate ;



/* SERIAL LOAD OF DOCUMENTS, IMAGES AND VIDEOS */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* CASLIB Path data source located on CAS controller */
/* commented since its pre-defined */
/*
caslib DM_MEDIA datasource=(srctype=PATH) path="/gelcontent/data/mediafiles" subdirs ;
*/

libname DM_MEDIA cas caslib="DM_MEDIA" ;

/* List CASLIB files (sub-directories) */
proc casutil incaslib="DM_MEDIA" ;
   list files ;
quit ;

/* Load documents, images and videos from 3 sub-directories */
proc casutil incaslib="DM_MEDIA" outcaslib="DM_MEDIA" ;
   load casdata="doc" importOptions=(filetype="DOCUMENT" tikaconv=true) casout="DOCS" replace ;
   load casdata="img" importOptions=(filetype="IMAGE") casout="IMGS" replace ;
   load casdata="video" importOptions=(filetype="VIDEO") casout="VIDEOS" replace ;
quit ;

/* Import any type of files recursively */
proc cas ;
   loadTable path="" importOptions="ANY" caslib="DM_MEDIA"
             casout={caslib="DM_MEDIA" name="FILES" replication=0 replace=true} ;
quit ;

/* Check the contents and structure of the CAS tables */
proc casutil incaslib="DM_MEDIA" ;
   list tables ;
   contents casdata="DOCS" ;
   contents casdata="IMGS" ;
   contents casdata="VIDEOS" ;
   contents casdata="FILES" ;
quit ;

cas mySession terminate ;

