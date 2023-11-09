/* TESTED TO RUN ON SSEMONTHLY 11/07/2023 */

/*****************************************/
/* GETTING STARTED WITH VIYA PROGRAMMING */
/*****************************************/


/* STANDARD SAS PROCESSING ON THE COMPUTE SERVER */
/* SEE - WE CAN RUN BASE SAS CODE ************** */
proc print data=sashelp.cars (obs=10);
run;


/* START A CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false);


/* EXAMPLES OF CREATING CASLIBS */

/* PATH */
caslib OLDDATA path="/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Git_Repo/SAS_Studio/Data" 
   datasource=(srctype="path");

/* HDFS */
/* caslib Myvapublic path="/vapublic"  */
/*                           datasource=(srctype="hdfs") global ;  */

/* HADOOP */
/* caslib Hadooplib desc="Hadoop Caslib"  */
/*                datasource=(srctype="hadoop",                                 */
/*                dataTransferMode="parallel", */
/*                hadoopjarpath="Hadoo-jar-file-path", */
/*                hadoopconfigdir="Hadoop-config-files-path", */
/*                username="user-id", */
/*                server="Hadoop-server-hostname", */
/*                schema="schema-name") global; */

/* SETTING UP A CASLIB TO AND AWS S3 BUCKET */
/* caslib ms33 subdirs datasource=(srctype="s3" */
/*                accesskeyid="AKIARPJ6X2NYDF5TYUFX" */
/*                secretaccesskey="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" */
/*                region="US_East" */
/*                bucket="win562960andln" */
/*                objectpath="wtw_files" */
/*                usessl=false); */


/* SET UP LIBRARY REFERENCES */
%let datapath /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data;

libname mysas "&datapath";
libname olddata cas caslib=olddata;
libname mycas cas caslib=casuser;

caslib _all_ list;
caslib _all_ assign;


/* LOAD CUSTOMERS DATASET TO CAS USING DATASTEP TO DEFAULt CAS LIBRARY */
data mycas.mycustomers;
  set mysas.customers;
run;  

proc print data=mycas.mycustomers (obs=10);
run;

/* proc import datafile="&datapath/customers2.xlsx" */
/*             dbms=xlsx */
/*             out=mysas.customers2 */
/*             replace; */
/* run; */


/* LOAD CUSTOMERS DATASET TO CAS USING PROC CASUTIL */
proc casutil;
	load data=mysas.customers outcaslib='casuser'
	casout="mycustomers" replace;

	load data=mysas.customers2 outcaslib='casuser'
	casout="mycustomers2" replace;
quit;

proc print data=mycas.mycustomers (obs=10);
run;
title; footnote;

proc print data=mycas.mycustomers2 (obs=10);
run;
title; footnote;

/* IMPORT EXCEL FILE AS A DATASET */
proc import datafile="&datapath/cars_test.xlsx"
            dbms=xlsx
            out=mysas.cars1
            replace;
run;


/* LOAD XLS FILE TO CAS USING PROC CASUTIL */
proc casutil;
    load file="&datapath/products.xlsx"
    casout='myproducts'
    outcaslib='casuser'
    importoptions=(filetype='excel' getnames=true)
    replace;
quit;   

/* proc casutil; */
/*     load file='/home/sasdemo/SAS Studio/DATA/customers.xlsx' */
/*     casout='mycustomers2' */
/*     outcaslib='casuser' */
/*     importoptions=(filetype='excel' getnames=true) */
/*     replace; */
/* quit;     */

/* proc print data=mycas.mycustomers2 (obs=10); */
/* run; */
/* TITLE; FOOTNOTE; */


/* LOAD CSV FILE TO CAS USING PROC CASUTIL */
/* IN THIS CASE WE ARE LOADING TO PUBLIC & PROMOTING */
%if not %sysfunc(exist(public.mysales)) %then %do;
	proc casutil;
	    load file="&datapath/sales.csv"
	    casout='mysales'
	    outcaslib='public'
	    importoptions=(filetype='csv' getnames=true)
	    promote;
	quit;  
%end;

proc print data=public.mysales (obs=10);
run;
TITLE; FOOTNOTE;


/* LOADING DATA USING PROC SQL*/
proc sql; create table mycas.benchmark as
     select Name, Team, Position, Salary, NHome
     from sashelp.baseball
     where nHome > 20
     order by nHome descending;
run;


/* USING PROC CASUTIL TO LIST TABLES ASSOCIATED WITH CASLIB */
proc casutil;
  list tables incaslib=casuser;
  list files incaslib=casuser;
quit; 

/* proc casutil; */
/*   list tables incaslib=public; */
/* quit; */


 /* USE DATA STEP TO COUNT NA CUSTOMERS - ONE ANSWER AS SINGLE THREAD */
data work.NACustomers;
  set mysas.customers2 end=eof;
  if continent="North America" then NACustomers+1;
  if eof then output;
  keep NACustomers;
run;  

proc print data=work.NACustomers;
run;


/* USE CAS TO COUNT NA CUSTOMERS - ONE TOTAL FOR EACH THREAD */
data mycas.NACustomers;
  set mycas.mycustomers2 end=eof;
  if continent="North America" then NA_SUM+1;
  if eof then output;
  keep NA_SUM;
run; 

proc print data=mycas.NACustomers;
run;


/* SUM TOTALS FOR EACH THREAD TO SINGLE TOTAL */
data mycas.NAcustomers2 / single=yes;
   keep NA_TOTAL;
   set casuser.NACUSTOMERS end=eof;
   NA_TOTAL + NA_sum;
   if eof then output;
run;

proc print data=mycas.NACustomers2;
run;


/* USE SINGLE=YES TO FORCE RUNNING ON A SINGLE THREAD */
data mycas.TestCustomers/single=YES;
  set mycas.mycustomers end=eof;
  if continent="North America" then NAcustomers+1;
  if eof then output;
  keep NAcustomers;
run;  

proc print data=mycas.TestCustomers;
run; 


/* BY GROUP PROCESSING IN SAS */
proc sort data=mysas.customers2 out=customers_sorted;
  by Continent City;
run;

data work.CityTotals;
   set customers_sorted (where=(city ne ' ')) end=last;
   by Continent City;
   if first.City then
      do;
         TotalCost=0;
         numOrders=0;
      end;
   TotalCost+Cost;
   numOrders+1;
   if last.City;
   keep Continent City TotalCost numOrders;
   if last then put _threadid_= _nthreads_=;
run;

proc print data=work.CityTotals(obs=5);
run;


/* BY GROUP PROCESSING IN CAS */
data mycas.CityTotals;
   set mycas.mycustomers2(where=(city ne ' ')) end=last;
   by Continent City;
   if first.City then
      do;
         TotalCost=0;
         numOrders=0;
      end;
   TotalCost+Cost;
   numOrders+1;
   if last.City;
   keep Continent City TotalCost numOrders;
   if last then put _threadid_= _nthreads_=;
run;

proc print data=mycas.CityTotals(obs=5);
run;


/* ADD MSGLEVEL=i */
options msglevel=i;

TITLE;
TITLE1 "CAS.CITYTOTALS (MSGLEVEL=I)";
FOOTNOTE;
FOOTNOTE1 "Generated by SAS (&_SASSERVERNAME, &SYSSCPL) on %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) at %TRIM(%QSYSFUNC(TIME(), NLTIMAP25.))";


proc print data=mycas.CityTotals;
   where city='Abbeville' and continent='North America'  ;
run;
options msglevel=n;


/* RUN SAS 9 PROC IN CAS */
proc sort data=mysas.customers2 out=by_CustGroup;
  by Customer_Group;
run;

proc means data=by_CustGroup chartype mean std min max n range vardef=df;
	var RetailPrice;
	output out=mysas.mycustomers_means mean=std=min=max=n=range= / autoname;
	by Customer_Group;  
run;

proc print data=mysas.mycustomers_means;
run;


proc means data=mycas.mycustomers2 chartype mean std min max n range vardef=df;
	var RetailPrice;
	output out=mycas.mycustomers_means mean=std=min=max=n=range= / autoname;
	by Customer_Group;  
run;

proc print data=mycas.mycustomers_means;
run;


/* RUN CAS PROC */
proc mdsummary data=mycas.mycustomers2;
  groupby Customer_Group;
  var RetailPrice;
  output out=mycas.mycustomers_mdsstats (replace=yes);
quit;

proc print data=mycas.mycustomers_mdsstats;
run;


proc sql;
   select Customer_Name
        , City
        , (quantity*retailPrice) as TotalPaid format=dollar9.2
     from mysas.customers2
     where calculated TotalPaid>2000 
       and Continent eq 'Africa'
     order by City
     ;
quit;

proc fedsql sessref=Mysession;
create table casuser.InvoiceAfrica as
   select Customer_Name
        , City
        , put((quantity*retailPrice),dollar9.2) as TotalPaid 
     from casuser.mycustomers2
     where (quantity*retailPrice)>2000 
       and Continent='Africa'
;
select * 
   from casuser.InvoiceAfrica
   order by City
;
quit;

proc casutil;
   contents casdata="InvoiceAfrica" incaslib="casuser";
run;



proc casutil;
  save casdata="mycustomers2" incaslib="casuser" replace;
quit;

proc casutil;
  droptable casdata="Mycustomers2" incaslib="casuser";
quit;

cas mySession terminate;
