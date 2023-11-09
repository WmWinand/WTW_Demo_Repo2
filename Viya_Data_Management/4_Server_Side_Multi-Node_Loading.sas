/* PREPARE THE ENVIRONMENT */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Set some macro-variables for monitoring the logs */
%let dclogpath=/gelcontent/data/LOG ;
%let logprefix=_sasdcpg_ ;

/* Some utility macros */

/* Macro to delete the trace files */
%macro deleteTraceFiles(dclogpath=,logprefix=) ;
   /* Delete the TRACE files */
   caslib log type=path path="&dclogpath" ;
   proc cas ;
      table.fileinfo result=fileresult / caslib="log" allFiles=true path="&logprefix.%" ;
      filelist=findtable(fileresult) ;
      do cvalue over filelist ;
         table.deleteSource /
            caslib="log"
            source=cvalue.name
            quiet=true ;
      end ;
   quit ;
   caslib log drop ;
%mend ;

/* Macro to display the trace files */
%macro displayTrace(dclogpath=,logprefix=) ;
   /* Display trace */
   data _null_ ;
      length logname oldlogname $ 256 casnode $ 20 ;
      retain oldlogname "dummy" ;
      infile "&dclogpath/&logprefix.*.log" filename=logname ;
      input ;
      put ;
      if index(_infile_,"DRIVER SQL")>0 then do ;
         if logname ne oldlogname then do ;
            casnode=scan(scan(scan(logname,-1,"/"),1,"."),-1,"_") ;
            put "*****" ;
            put "LOG FROM CAS NODE: " casnode ;
            put "*****" ;
            oldlogname=logname ;
         end ;
         put _infile_ ;
      end ;
   run ;
%mend ;

/* Delete the SAS Data Connector trace files */
%deleteTraceFiles(dclogpath=&dclogpath,logprefix=&logprefix) ;

/* Clear CASLIB if exists */
caslib _all_ assign ;
%macro libchk; %if %sysfunc(libref(caspg))=0 %then %do; caslib caspg clear; %end; %mend; %libchk ;



/* PERFORM A MULTINODE TRANSFER LOAD */

/* Set the numreadnodes parameter high so the log tells us CAS is attempting multi-node load */
/* Set some tracing options */
caslib caspg datasource=(srctype="postgres",username="sas",password="lnxsas",server="gel-postgresql.postgres.svc.cluster.local",
   database="dvdrental",schema="public",numreadnodes=10,numwritenodes=10,
   DRIVER_TRACE="SQL",
   DRIVER_TRACEFILE="/gelcontent/data/LOG/_sasdcpg_$SAS_CURRENT_HOST.log",
   DRIVER_TRACEOPTIONS="TIMESTAMP|APPEND") libref=caspg ;

/* List source files and target tables */
proc casutil incaslib="caspg" ;
   list files ;
   list tables ;
quit ;

/* Load the FILM PostgreSQL table in CAS in multi-node mode */
/* Drop the CAS table before in case it exists */
/* List target tables */
proc casutil incaslib="caspg" outcaslib="caspg" ;
   droptable casdata="pg_film" quiet ;
   load casdata="film" casout="pg_film" ;
   list tables ;
quit ;




/* SPECIFY THE SLICING COLUMN FOR MULTI-NODE LOAD */

/* Delete the SAS Data Connector trace files */
%deleteTraceFiles(dclogpath=&dclogpath,logprefix=&logprefix) ;

/* Check the database table structure */
proc casutil incaslib="caspg" ;
   contents casdata="film" ;
quit ;

/* Force the multi-node mode to use the LENGTH column */
proc casutil incaslib="caspg" outcaslib="caspg" ;
   load casdata="film" casout="pg_film" options=(sliceColumn="length") replace ;
   list tables ;
quit ;

/* Display SAS Data Connector trace files */
%displayTrace(dclogpath=&dclogpath,logprefix=&logprefix) ;




/* SPECIFY SLICE EXPRESSIONS FOR MULTI-NODE LOAD */

/* Delete the SAS Data Connector trace files */
%deleteTraceFiles(dclogpath=&dclogpath,logprefix=&logprefix) ;

/* Force the multi-node mode to use slicing expressions on the LENGTH column */
proc casutil incaslib="caspg" outcaslib="caspg" ;
   load casdata="film" casout="pg_film" options=(numreadnodes=2 sliceExpressions=("length < 100","length >= 100")) replace copies=0 ;
   list tables ;
quit ;

/* Display SAS Data Connector trace files */
%displayTrace(dclogpath=&dclogpath,logprefix=&logprefix) ;

/* Check the target table structure */
proc cas ;
   table.tabledetails / caslib="caspg" name="pg_film" level="node" ;
quit ;



/* Delete the SAS Data Connector trace files */
%deleteTraceFiles(dclogpath=&dclogpath,logprefix=&logprefix) ;

cas mysession terminate ;


