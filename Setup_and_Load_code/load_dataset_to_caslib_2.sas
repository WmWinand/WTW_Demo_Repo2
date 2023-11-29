
/* START CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");


/* SET LIBNAME FOR SOURCE DATA TO LOAD AND SET CAS ENGINE LIBRARY FOR DESTINATION CASLIB */
/* libname mydata "&datapath"; */
libname casuser cas caslib="casuser";

/* CHECK IF CAS TABLE ALREADY EXISTS - IF IT DOES DROP FROM MEMORY */
%if %sysfunc(exist(casuser.pricedata)) %then %do;
  proc casutil;
    droptable incaslib="casuser" casdata="pricedata";
  run;
%end;

/* LOAD CUSTOMERS DATASET TO CAS USING PROC CASUTIL */
proc casutil;
	load data=sashelp.pricedata outcaslib='casuser'
	casout="pricdata" promote;
quit;

proc casutil;
  list tables incaslib="casuser";
  list files incaslib="casuser";
quit;


/* TERMINATE CAS SESSION */
cas mySession terminate;
