/* cas mySession terminate; */

*****************************************************;
* STEP 0                                            *;
*****************************************************;
* This program is the SAS9 program. It does not     *;
* run successfully because the paths have not been  *;
* updated for SAS Librefs and files to point to the *;
* new Paths in Viya versus SAS9                     *; 
*****************************************************;

*****************************************************;
* STEP 1                                            *;
*****************************************************;
* 1. MODIFY PATHS FOR SAS LIBRARIES AND FILE        *;
*    REFERENCES                                     *;
* 2. TEST THAT THE PROGRAM RUNS SUCCESSFULLY ON THE *;
*    COMPUTE SERVER                                 *;  
*****************************************************;
* In this first step the paths are updated for SAS  *;
* Librefs and files to point to the new  Paths in   *;
* Viya versus SAS9                                  *; 
*****************************************************;

*****************************************************;
* STEP 2                                            *;
*****************************************************;
* 1. START A CAS SESSION   
* 2. CREATE A PATH BASED CASLIB TO DATA             *;
*****************************************************;
* This program uses the SAS9 program that was       *;
* migrated to successfully run on the compute       *;
* server, and it adds steps to start a CAS session  *;
* and to create a path-based caslib for the data    *;
*****************************************************;

*****************************************************;
* STEP 3                                            *;
*****************************************************;
* 1. LOAD TABLES INTO CASLIB                        *;  
*****************************************************;
* After starting the session & creating caslibs as  *;
* needed to access our data, data needs to be       *;
* loaded into CAS memory for use within CAS         *;
*****************************************************;


*****************************************************;
* STEP 4                                            *;
*****************************************************;
* 1. REFACTOR DATA STEP STEPS TO RUN IN CAS         *; 
* 2. REFACTOR SAS9 PROCEDURES TO RUN IN CAS         *;  
*****************************************************;
* Change data step librefs to be cas engine librefs.*;
* No other changes are needed.                      *;
* If procedure steps are slow running, running      *;
* against big data, or are compute intensive,       *;
* consider refactoring them to run in CAS           *;
* PROC FREQTAB or CAS actions can replace PROC FREQ *;
* PROC MEANS can run in CAS against a CAS table     *;
* CAS procedure PROC MDSUMMARY can also be used     *;
*****************************************************;


*****************************************************;
* STEP 5                                            *;
*****************************************************;
* 1. USE PROC FEDSQL INSTEAD OF PROC SQL IN CAS     *;  
*****************************************************;
* If SQL query is slow running, running             *;
* against big data, or complex, consider            *;
* refactoring the query to run in CAS by using      *;
* PROC FedSQL.  PROC SQL does not run in CAS, but   *;
* PROC FedSQL does.                                 *;
*****************************************************;


*****************************************************************************************;
* STEP 1: Change pathnames for Viya environment                                         *;
*****************************************************************************************;
* Set options to view detailed metrics & set Base SAS library *;
%let serverPath = /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/SAS9_Migration_Data;
%let clientPath = /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data_csv;
*****************************************************************************************;


* Start timer *;
%let _timer_start = %sysfunc(datetime());  

* Options *;
options fullstimer;

* Create a library reference to the data *;
/* libname o clear; */
libname o "&serverPath";


*****************************************************************************************;
* STEP 2                                                                                *;
*****************************************************************************************;
* 1. Start CAS session                                                                  *;
* 2. List CAS sessions                                                                  *;
* 3. create path-based caslib=casdata                                                   *;
* 4. list caslib info                                                                       *;
* 5. list source files and list in-memory tables in caslib=casdata                      *;
* 6. create a cas engine libref=casdata to the caslib=casdata                           *;
* 7. use proc contents to show information about libref=casdata                         *;
*****************************************************************************************;
* Start a CAS session *;
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false);

cas mySession listsessions;

* Create caslib to &serverpath and data *;
caslib casdata path="&serverpath" 
   datasource=(srctype="path");

caslib casdata list;

proc casutil;
  list files incaslib=casdata;
  list tables incaslib=casdata;
quit;

libname casdata cas caslib=casdata;

proc contents data=casdata._all_ nods;
run;
*****************************************************************************************;


********************************************************************************************;
* STEP 3                                                                                   *;
********************************************************************************************;
* 1. Load a "Server Side" file into CAS memory in the CASLIB=casdata"                      *;
* 2. list source files and list in-mamory tables in caslib=casdata - orders_demo is loaded *;
* 3. Load a "Client Side" file (CSV) into CAS memory in the CASLIB=casdata                 *;
* 4. List in-memory tables in the CASLIB=casdata                                           *;
********************************************************************************************;
proc casutil;
  load casdata="orders_demo.sas7bdat" 
          incaslib=casdata 
          casout="orders_demo" 
          outcaslib="casdata" 
          replace;
quit;
 
proc casutil;
    load file="&clientPath/DISCOUNT_LOOKUP.csv"
    casout='discount_lookup'
    outcaslib='casdata'
	importoptions=(filetype='csv' getnames=true)
    replace;
  list tables incaslib=casdata;
quit;   

proc print data=casdata.orders_demo (obs=5);
run;

proc print data=casdata.discount_lookup (obs=5);
run;
********************************************************************************************;

********************************************************************************************;
* STEP 4 - Refactor SAS9 Procedure Steps and DATA Steps to run in CAS                                     *;
********************************************************************************************;
* 1. Change PROC FREQ TO PROC FREQTAB
* 2. Set data to in-memory table casdata.orders_demo                                       *;
* 3 FREQTAB syntax is about the same as FREQ                                               *;
* 4. FREQTAB does not support adding formats to an existing table, so use alterTable       *;
*    action to set format for OrderDate                                                    *;
********************************************************************************************;
* Explore categorical columns - Compute Server*;
proc freq data=o.orders_demo;
    tables Product Country DiscountCode Return OrderDate;
    format OrderDate year4.;
run;


* Explore categorical columns - CAS 8;
proc cas;
  table.alterTable / caslib="casdata", name="orders_demo",
    columns={
              {name="OrderDate" format="year4."}
        };

quit;

proc freqtab data=casdata.orders_demo;
    tables Product Country DiscountCode Return OrderDate;
run;
********************************************************************************************;


********************************************************************************************;
* STEP 4 - Refactor SAS9 Procedure Steps to run in CAS                                     *;
********************************************************************************************;
* 1. PROC MEANS runs in CAS if the table is a CAS in-memory table                          *;
* 2. So change data= to use casdata.orders_demo                                            *;                                        
* 4. Also you can use CAS PROC MDSUMMARY, which also produces descriptive statistics       *;
* 5. Review the log to see performance metrics                                             *;
********************************************************************************************;
* Explore continuous columns - Compute Server *;
proc means data=o.orders_demo;
run;

* Explore continuous columns - CAS *;
proc means data=casdata.orders_demo;
run;

proc mdsummary data=casdata.orders_demo;
    output out=casdata.orders_mdsstats (replace=yes);
run;

proc print data=casdata.orders_mdsstats;
run;
********************************************************************************************;


********************************************************************************************;
* STEP 4                                                                                   *;
********************************************************************************************;
* 1. Change the libraries to the CAS engine library CASDATA                                *;
* 2. That is all you need to do to refactor this data step in run in CAS                   *;
********************************************************************************************;
* Execute a simple data step on the Compute Server *;
data work.orders_demo_calc_columns;
    set o.orders_demo;
    Year = year(OrderDate);
    Month = Month(OrderDate);
    TotalCost = Quantity * Cost;
    TotalPrice = Quantity * Price;    
    Profit = TotalPrice - TotalCost;
    pctProfit = Profit / TotalCost;
    if Return='' then Return='No';
    format pctProfit percent7.2
           Price Cost TotalPrice TotalCost Profit dollar28.2;
run;

* Execute a simple data step in CAS *;
data casdata.orders_demo_calc_columns;
    set casdata.orders_demo;
    Year = year(OrderDate);
    Month = Month(OrderDate);
    TotalCost = Quantity * Cost;
    TotalPrice = Quantity * Price;    
    Profit = TotalPrice - TotalCost;
    pctProfit = Profit / TotalCost;
    if Return='' then Return='No';
    format pctProfit percent7.2
           Price Cost TotalPrice TotalCost Profit dollar28.2;
run;
********************************************************************************************;


*****************************************************************************************;
* STEP 1: Change pathnames for Viya environment                                         *;
*****************************************************************************************;
* Import discount_lookup.csv *;
filename REFFILE DISK '/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/SAS9_Migration_Data/DISCOUNT_LOOKUP.csv';
*****************************************************************************************;


PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=O.DISCOUNT_LOOKUP
    REPLACE;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=O.DISCOUNT_LOOKUP; RUN;


* Preview the tables prior to the join *;
title "Preview the two tables to join";
proc print data=work.orders_demo_calc_columns(obs=10);
run;
proc print data=o.discount_lookup;
run;
title;

********************************************************************************************;
* STEP 5 - Modify long running PROC SQL queries to PROC FedSQL                              *;
********************************************************************************************;
* 1. PROC MEANS runs in CAS if the table is a CAS in-memory table                          *;
* 2. So change data= to use casdata.orders_demo                                            *;                                        
* 4. Also you can use CAS PROC MDSUMMARY, which also produces descriptive statistics       *;
* 5. Review the log to see performance metrics                                             *;
********************************************************************************************;
* Join the orders_demo_calc_columns and the Discount_Lookup tables using PROC SQL - Compute Server Datasets *;
proc sql;
create table orders_demo_final as
    select f.*, 
           l.pct_discount * .01 as pctDiscount, 
           l.discount_description
        from work.orders_demo_calc_columns as f left join 
             o.discount_lookup as l
        on f.DiscountCode = l.discountCode;
quit;

* Join the orders_demo_calc_columns and the Discount_Lookup tables using PROC SQL - CAS Tables*;
/* proc sql; */
/* create table o.orders_demo_final as */
/*     select f.*,  */
/*            l.pct_discount * .01 as pctDiscount,  */
/*            l.discount_description */
/*         from casdata.orders_demo_calc_columns as f left join  */
/*              casdata.discount_lookup as l */
/*         on f.DiscountCode = l.discountCode; */
/* quit; */

* Join the orders_demo_calc_columns and the Discount_Lookup tables using PROC FedSQL - CAS Tables*;
proc FedSQL sessref=mySession;
create table casdata.orders_demo_final as
    select f.*, 
           l.pct_discount * .01 as pctDiscount, 
           l.discount_description
        from casdata.orders_demo_calc_columns as f left join 
             casdata.discount_lookup as l
        on f.DiscountCode = l.discountCode;
quit;

* Preview the joined data *;
proc print data=casdata.orders_demo_final(obs=10);
run;
********************************************************************************************;



* Find the total by each Country and Year *;
proc means data=orders_demo_final noprint;
    class Country Year;
    var TotalCost TotalPrice Profit;
    output out=orders_summary(where=(_Type_ = 3))
           sum(TotalCost)=TotalCostYearCountry
           sum(TotalPrice)=TotalPriceYearCountry
           sum(Profit)=TotalProfitYearCountry;
run;

proc print data=orders_summary;
    var Country Year TotalCostYearCountry TotalPriceYearCountry TotalProfitYearCountry;
run;

********************************************************************************************;
* STEP 4 - Refactor SAS9 Procedure Steps to run in CAS                                     *;
********************************************************************************************;
* 1. Refactor PROC MEANS to MDSUMMARY as PROC MEANS options here do not run in CAS         *;
* 2. Results are transfered to Compute Server to run PROC SG PLOT                          *;
*********************************************************************************************;
proc mdsummary data=casdata.orders_demo_final;
  var TotalCost TotalPrice Profit;
  groupby / out=casdata.orders_summary;
  groupby Country Year /out=casdata.OrdersByCountryYear;
run;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=CASDATA.ORDERSBYCOUNTRYYEAR;
	vbar Year / response=_Sum_ group=Country groupdisplay=stack;
	yaxis grid;
run;
ods graphics / reset;

cas mySession terminate;

* Turn off options *;
options nofullstimer;


* Clear library *;
/* libname o clear; */


/* Stop timer */
data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;