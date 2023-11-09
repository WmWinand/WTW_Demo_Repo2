/* SET MACRO VARIABLES: PATH TO SOURCE DATA, DESTINATION CASLIB, & NAME OF TABLE TO LOAD */
/* CHANGE VALUES AS NEEDED */
%let datapath=/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data;


/* START CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

/* SET LIBNAME FOR SOURCE DATA TO LOAD AND SET CAS ENGINE LIBRARY FOR DESTINATION CASLIB */
libname mydata "&datapath";
libname mycas cas caslib="casuser";
libname casuser cas caslib="casuser";
 

/* CHECK IF CAS TABLE ALREADY EXISTS - IF IT DOES DROP FROM MEMORY */
%if %sysfunc(exist(mycas.orioncc)) %then %do;
  proc casutil;
    droptable incaslib="casuser" casdata="orioncc";
  run;
%end;

/* LOAD DATASET INTO CASLIB AND PROMOTE */
proc casutil;
  load data=mydata.orioncc outcaslib="casuser" casout="orioncc" promote;
  list tables incaslib="casuser";  
quit;

proc casutil;
  save casdata="orioncc" casout="orioncc.sas7bdat" incaslib="casuser" replace;
  droptable casdata="orioncc";
  list files;
quit;
/*  */
/* proc casutil; */
/*   load casdata="orioncc.sas7bat" importoptions=(filetype="basesas") incaslib="casuser" outcaslib="casuser" casout="orioncc" promote; */
/*   list tables incaslib="casuser"; */
/* quit; */
/*  */
/*  */
/* LIST FIRST 10 ROWS TO VALIDATE */
/* proc print data=mycas.orioncc (obs=10); */
/* run; */

/* TERMINATE CAS SESSION */
cas mySession terminate;