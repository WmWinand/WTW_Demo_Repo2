/* CREATE CAS CONNECTION (optional) AND START A CAS SESSION */
/* options cashost="127.0.0.1" casport=5570; */

CAS mySession SESSOPTS=(CASLIB=casuser TIMEOUT=99 LOCALE="en_US" metrics=true);


/* GRANT ACCESS TO GLOBAL CASLIBS & LIST CASLIBS */
caslib _all_ assign;
caslib _all_ list;


/* EXAMPLES OF CREATING OTHER CASLIBS */
/* PATH */
caslib S3_cas path="/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data" 
   datasource=(srctype="path");

/* HDFS */
/* caslib Myvapublic path="/vapublic"  */
/*                           datasource=(srctype="hdfs") global ; 

/* HADOOP */
/* caslib Hadooplib desc="Hadoop Caslib"  */
/*                datasource=(srctype="hadoop",                                
/*                dataTransferMode="parallel", */
/*                hadoopjarpath="Hadoo-jar-file-path", */
/*                hadoopconfigdir="Hadoop-config-files-path", */
/*                username="user-id", */
/*                server="Hadoop-server-hostname", */
/*                schema="schema-name") global; */


/* SETTING UP A CASLIB TO AND AWS S3 BUCKET */
caslib ms33 subdirs datasource=(srctype="s3"
               accesskeyid="AKIARPJ6X2NYDF5TYUFX"
               secretaccesskey="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"
               region="US_East"
               bucket="win562960andln"
               objectpath="wtw_files"
               usessl=false);


/* SETTING SAS LIBRARY REFERENCES TO CASLIBS SO THAT WE CAN USE IN DATA STEP, PROCES, ETC */
libname my_path cas caslib="S3_cas";
libname my_ms33 cas caslib="ms33";
libname my_cas cas caslib="casuser";


/* EXAMPLES OF LOADING SAMPLE SAS DATASETS INTO CAS MEMORY IN THE MS33 CASLIB */
/* USING DATA STEP - NOT OPTIMAL */
data my_ms33.casclass;
  set sashelp.class;
run;

/* USING PROC CASUTIL - BETTER */
proc casutil;
 load data=sashelp.cars outcaslib="ms33"
 casout="cascars" replace;
quit;


/* LIST SAMPLE TO VALIDATE TABLES LOADED INTO CASLIB */
proc print data=my_ms33.casclass (obs=10);
run;

proc print data=my_ms33.cascars (obs=10);
run;


/* DATA STEP RUNNING IN CAS */
data my_ms33.cascars_usa;
  set my_ms33.cascars;

  if origin="USA";
  mpg_average=(mpg_city + mpg_highway)/2;

run;


/* MODIFIED TO RUN IN CAS */
data my_ms33.AvgHP_By_Type;
   set my_ms33.cascars(where=(origin ne ' ')) end=last;
   by Origin Type;
   if first.Type then
      do;
         TotalHP=0;
         numTypes=0;
      end;
   TotalHP+Horsepower;
   numTypes+1;
   if last.Type;
   AvgHP = TotalHP/numTypes;
   Format AvgHP comma10.2;
   keep Origin Type AvgHP numTypes;
   if last then put _threadid_= _nthreads_=;
run;

title "CAS DATA Step (10 rows)";
proc print data=my_ms33.AvgHP_By_Type(obs=10);
run;

/* USING PROC CASUTIL TO LIST SAVED FILES ASSOCIATED WITH CASLIBS AND IN-MEMORY TABLES */
proc casutil;
  list files incaslib="ms33";  /* files */
  list tables incaslib="ms33";  /* in-memory data */
quit;


/* USING PROC CASUTIL TO SAVE IN MEMORY TABLES TO PERSISTENT STORAGE */
proc casutil;
  save casdata="casclass" incaslib="ms33"
      casout="class.parquet" replace;
  save casdata="cascars" incaslib="ms33"
      casout="cars.parquet" replace;
  save casdata="cascars_usa" incaslib="ms33"
      casout="cars_usa.parquet" replace;
  save casdata="AvgHP_By_Type" incaslib="ms33"
      casout="AvgHP_By_Type.csv" replace;
  save casdata="casclass" incaslib="ms33"
      casout="class.csv" replace;
  save casdata="cascars" incaslib="ms33"
      casout="cars.csv" replace;
quit;
 

/* RELEASING OUR TABLES FROM MEMORY */
proc casutil;
  droptable incaslib="ms33" casdata="casclass";
  droptable incaslib="ms33" casdata="cascars";
  droptable incaslib="ms33" casdata="cascars_usa";
  droptable incaslib="ms33" casdata="AvgHP_By_Type";
quit;


/* THEN WE CAN LIST FILES AND TABLES ASSOCIATED WITH OUR CASLIB TO SEE WHAT HAS CHANGED */
proc casutil;
  list files incaslib="ms33";  /* files */
  list tables incaslib="ms33";  /* in-memory data */
quit;


/* DROP CASLIB MS33 AND TERMINATE THE CURRENT CAS SESSION */
caslib ms33 drop;

cas mySession terminate;

