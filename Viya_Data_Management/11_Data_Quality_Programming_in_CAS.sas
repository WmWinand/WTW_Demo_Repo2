/* CREATE A CAS SESSION, A SESSION CASLIB AND LOAD DATA */

cas mySession sessopts=(metrics=true messagelevel=all) ;

options msglevel=i ;

caslib dataproc datasource=(srctype=path) path="/gelcontent/data/SAMPLE" ;

libname libcas cas caslib="dataproc" ;

/* Load the customers table from the new dataproc caslib */
proc casutil ;
   load casdata="customers.sashdat" incaslib="dataproc" outcaslib="dataproc" casout="customers" copies=0 replace ;
quit ;



/* USE DATA QUALITY FUNCTIONS IN A DATA STEP */

/* Data quality functions */
data libcas.customers_dq(copies=0) ;
   length mcName mcAddress stdName varchar(50) stdState $ 2 ;
   set libcas.customers ;
   stdState=dqStandardize(state,'State/Province (Abbreviation)','ENUSA');
   stdName=dqStandardize(name,'Name','ENUSA');
   mcName=dqMatch(name,'Name',85,'ENUSA') ;
   mcAddress=dqMatch(address,'Address (Street Only)',85,'ENUSA') ;
run ;



/* USE DATA QUALITY FUNCTIONS IN DS2 */

/* Data quality functions in DS2 */
proc ds2 sessref=mysession ;
   thread dataproc.mythread / overwrite=yes ;
      declare varchar(50) mcName mcAddress stdName lastName ;
      declare char(2) stdState ;
      method run() ;
         set dataproc.customers ;
         stdState=dqStandardize(state,'State/Province (Abbreviation)','ENUSA');
         stdName=dqStandardize(name,'Name','ENUSA');
         mcName=dqMatch(name,'Name',85,'ENUSA') ;
         mcAddress=dqMatch(address,'Address (Street Only)',85,'ENUSA') ;
         lastName=dqParseTokenGet(dqParse(stdName,'NAME','ENUSA'),'Family Name','NAME','ENUSA') ;
      end ;
   endthread ;
   data dataproc.customers_dq_ds2(replication=0) / overwrite=yes ;
      dcl thread dataproc.mythread t ;
      method run() ;
         set from t threads=2 ;
      end ;
   enddata ;
run ;
quit ;



/* USE THE MATCH CAS ACTIONS TO CLUSTER RECORDS */

/* Clustering */
proc cas ;
   entityRes.match /
      clusterId="clusterID"
      inTable={caslib="dataproc",name="customers_dq"}
      columns={"stdName","address","mcName","mcAddress"}
      matchRules={{
         rule = { { columns = { "mcName" , "mcAddress" } } }
      }}
      nullValuesMatch=false
      emptyStringIsNull=true
      outTable={caslib="dataproc",name="customers_clustered",replace=true} ;
quit ;



/* SUBSET THE TABLE WITH ONLY THE MULTI-ROWS CLUSTERS */

/* Output only multi-rows clusters */
data libcas.customers_dups(copies=0) ;
   set libcas.customers_clustered(keep=clusterId stdName address) ;
   by clusterId ;
   if first.clusterId and last.clusterId then delete ;
run ;



/* PROFILE THE CUSTOMERS TABLE */

/* Profile and Identity analysis */
proc cas;
   dataDiscovery.profile /
      algorithm="PRIMARY"
      table={caslib="dataproc" name="customers"}
      columns={"state"}
      multiIdentity=true
      locale="ENUSA"
      qkb="QKB CI 33"
      identities= {
         {pattern=".*", type="*", definition="Field Content", prefix="QKB_"}
      }
      cutoff=20
      frequencies=10
      outliers=5
      casOut={caslib="dataproc" name="customers_profiled" replace=true replication=0}
   ;
   table.fetch /
      table={caslib="dataproc" name="customers_profiled"} to=200 ;
quit ;



/* TERMIATE THE CAS SESSION */

cas mySession terminate ;