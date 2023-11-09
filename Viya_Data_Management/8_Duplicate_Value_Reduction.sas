/* LOAD A CUSTOMIZED SAS TABLE TO CAS */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

libname casdm cas caslib="dm" ;

/* Create a medium-sized SAS table */
data prdsale ;
   set sashelp.prdsale ;
   do i=1 to 1000 ;
      output ;
   end ;
run ;

/* Load it in CAS */
proc casutil incaslib="dm" outcaslib="dm" ;
   load data=prdsale casout="prdsale" copies=0 replace ;
   list tables ;
quit ;



/* CREATE A DVR CAS TABLE AND COMPARE MEMORY AND DISK SIZE */

/* Copy it using the DVR format for the target */
proc cas ;
   table.copyTable /
      table={name="prdsale" caslib="dm"}
      casOut={name="prdsale_dvr" caslib="dm" memoryFormat="DVR" replace=true replication=0} ;
   table.tableInfo / caslib="dm" name="prdsale%" wildIgnore=false ;
quit ;

/* Compare size in memory */
proc cas;
   table.tabledetails / caslib="dm" name="prdsale" ;
   table.tabledetails / caslib="dm" name="prdsale_dvr" ;
quit ;

/* Save them on disk and compare size on disk */
proc casutil incaslib="dm" outcaslib="dm" ;
   save casdata="prdsale" casout="prdsale.sashdat" replace ;
   save casdata="prdsale_dvr" casout="prdsale_dvr.sashdat" replace ;
   list files ;
quit ;




/* RUN CAS ACTIONS ON BOTH CAS TABLES */

/* Compare their performance */
proc cas ;
   simple.summary result=r status=s /
      inputs={"actual","predict"},
      subSet={"SUM"},
      table={
         caslib="dm",
         name="prdsale",
         groupBy={"country","product","prodtype"}
      },
      casout={caslib="dm",name="prdsale_summary", replace=true, replication=0} ;
   simple.summary result=r status=s /
      inputs={"actual","predict"},
      subSet={"SUM"},
      table={
         caslib="dm",
         name="prdsale_dvr",
         groupBy={"country","product","prodtype"}
      },
      casout={caslib="dm",name="prdsale_dvr_summary", replace=true, replication=0} ;
quit ;

cas mySession terminate ;


