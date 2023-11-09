/* CREATE A CAS SESSION, A SESSION CASLIB, AND LOAD DATA */

cas mySession sessopts=(metrics=true messagelevel=all) ;

options msglevel=i ;

caslib dataproc datasource=(srctype=path) path="/gelcontent/data/SAMPLE" ;

libname libcas cas caslib="dataproc" ;

/* List source files */
proc casutil ;
   list files incaslib="dataproc" ;
quit ;

/* Load tables */
proc casutil ;
   load casdata="megacorp_facts.sashdat" incaslib="dataproc" outcaslib="dataproc" casout="facts" copies=0 replace ;
   load casdata="megacorp_proddim.sashdat" incaslib="dataproc" outcaslib="dataproc" casout="proddim" copies=0 replace ;
   list tables incaslib="dataproc" ;
quit ;



/* DISPLAY TABLE ATTRIBUTES */

/* Table information */
proc casutil ;
   contents casdata="facts" incaslib="dataproc" ;
   contents casdata="proddim" incaslib="dataproc" ;
quit ;

proc cas;
   table.tabledetails / name="facts" caslib="dataproc" level="node" ;
   table.tabledetails / name="proddim" caslib="dataproc" level="node" ;
quit ;



/* USE DATA STEP TO MANIPULATE DATA */

/* Data Step Merge */
data libcas.merge_ds(copies=0) ;
   merge libcas.facts(in=a) libcas.proddim ;
   by ProductID ;
   if a ;
run ;



/* COMPUTE AN AGGREGATED COLUMN WITH BY-GROUPS AND FIRST. LAST. NOTATION */

/* Data Step by groups and first. last. notation */
data libcas.dsby(copies=0 drop=expenses) ;
   length sum_expenses 8 ;
   retain sum_expenses 0 ;
   set libcas.merge_ds(keep=Product expenses) ;
   by Product ;
   if first.Product then sum_expenses=0 ;
   sum_expenses=sum_expenses+expenses ;
   if last.Product then output ;
run ;



/* UNDERSTAND MULTI-THREADING IMPACTS */

/* Multi-threading behavior */
data libcas.dsmulti(copies=0 drop=expenses) ;
   length max_expenses 8 ;
   retain max_expenses 0 ;
   set libcas.merge_ds(keep=expenses) end=last ;
   if expenses>max_expenses then max_expenses=expenses ;
   if last then output ;
run ;

/* Single-threading behavior */
data libcas.dssingle(copies=0 drop=expenses) / single=yes ;
   length max_expenses 8 ;
   retain max_expenses 0 ;
   set libcas.merge_ds(keep=expenses) end=last ;
   if expenses>max_expenses then max_expenses=expenses ;
   if last then output ;
run ;



/* USE DS2 CODE TO MANIPULATE DATA */

/* DS2 Merge */
proc cas ;
   ds2.runDS2 / program=
   "thread dataproc.join_th / overwrite=yes ;
      method run() ;
         merge dataproc.facts(in=a) dataproc.proddim ;
         by ProductID ;
         if a ;
      end ;
   endthread ;
   data dataproc.merge_ds2(copies=0) / overwrite=yes ;
      dcl thread dataproc.join_th t ;
      method run() ;
         set from t ;
      end ;
   enddata ;
   " ;
quit ;



/* USE FEDSQL TO MANIPULATE DATA */

/* FedSQL Join and Aggregation */
proc fedsql sessref=mySession _method ;
   create table dataproc.join_agg_fed {options replace=true replication=0} as
   select Date, Product, sum(Revenue) as Revenue
   from dataproc.facts as a
      left join dataproc.proddim as b
      on a.ProductID=b.ProductID
   group by Date, Product ;
quit ;



/* PASS=THROUGH A FEDSQL QUERY AND GET THE RESULTS IN CAS */

/* Pass-through */
caslib pg datasource=(srctype="postgres",user="sas",password="lnxsas",server="gel-postgresql.postgres.svc.cluster.local",database="dvdrental",schema="public") ;

proc fedsql sessref=mySession _method /* cntl=(disablePassThrough) */;
   create table dataproc.fed_pt{options replace=true replication=0} as
   select customer.first_name, customer.last_name, address.address
   from pg."customer" as customer, pg."address" as address where customer.address_id=address.address_id ;
quit ;



/* TRANSPOSE DATA */

/* Table Transposition */
proc cas ;
   action transpose.transpose /
      table={caslib="dataproc",name="join_agg_fed",groupby={"Date"}}
      transpose={"revenue"}
      id={"Product"}
      casOut={caslib="dataproc",name="agg_tr",replace=true,replication=0} ;
quit ;

proc casutil;
  list tables incaslib="dataproc";
quit;



/* USE SAS FORMATS TO PERFORM A FORMAT-JOIN OR FORMAT-LOOKUP */

/* Create format */
proc format casfmtlib="userformats1" ;
   value myDayName
               1="Sunday"
               2="Monday"
               3="Tuesday"
               4="Wednesday"
               5="Thursday"
               6="Friday"
               7="Saturday" ;
run ;

/* List formats */
cas mySession listfmtsearch ;
cas mySession listformats members ;

/* Apply format */
data libcas.facts_fmt(copies=0) ;
   length DayName $ 9 ;
   set libcas.facts(keep=Date DayOfWeek FacilityId FacilityCity ProductId Revenue Profit Expenses) ;
   DayName=put(DayOfWeek,myDayName.) ;
run ;



/* TERMINATE THE CAS SESSION */

cas mySession terminate ;