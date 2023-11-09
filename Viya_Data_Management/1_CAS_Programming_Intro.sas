/* Establish a CAS session */
cas mysession sessopts=(metrics=true) ;

/* List all available CASLIBs */
caslib _all_ list ;

/* List source (physical) files and in-memory tables from the DM CASLIB */
proc casutil incaslib="dm" ;
   list files ;
   list tables ;
quit ;

/* Assign a CAS engine library to a CASLIB */
libname casdm cas caslib="dm" ;

/* Load a SAS data set from the CASLIB physical location */
proc casutil ;
   /* Drop it before in case it already exists */
   dropTable casdata="prdsale" incaslib="dm" quiet ;
   load casdata="prdsale.sas7bdat" incaslib="dm" outcaslib="dm" casout="prdsale" ;
   list tables incaslib="dm" ;
quit ;

/* Run a data step in CAS */
data casdm.prdsale_canada ;
   set casdm.prdsale ;
   where country="CANADA" ;
run ;

/* Run a CAS action */
proc cas ;
   table.recordCount / table={caslib="dm" name="prdsale_canada"} ;
quit ;

/* Run a NON-CAS-enabled SAS procedure on CAS data */
proc freq data=casdm.prdsale_canada ;
   tables country*product ;
run ;

/* Run a CAS-enabled SAS procedure on CAS data */
proc mdsummary data=casdm.prdsale_canada ;
   var actual ;
   groupby country product ;
   output out=casdm.prdsale_canada_summary ;
run ;

/* Promote the last created CAS table */
proc casutil ;
   promote casdata="prdsale_canada_summary" incaslib="dm" outcaslib="dm" casout="prdsale_canada_summary" ;
quit ;

/* Drop the global table */
proc casutil ;
   dropTable casdata="prdsale_canada_summary" incaslib="dm" ;
quit ;

/* Assign all possible CASLIBs to CAS engine libraries */
caslib _all_ assign ;

/* Terminate the CAS session */
cas mysession terminate ;








