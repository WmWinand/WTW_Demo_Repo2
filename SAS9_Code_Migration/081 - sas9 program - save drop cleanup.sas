* FINAL PROGRAM OPTIMIZED *;

%let serverPath = /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/SAS9_Migration_Data;
%let clientPath = /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data_csv;


* Start timer *;
%let _timer_start = %sysfunc(datetime());  

* Options *;
options fullstimer;

* Create a library reference to the data *;
/* libname o clear; */
/* libname o "&serverPath"; */


* Start a CAS session *;
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false);

cas mySession listsessions;

* Create caslib to &serverpath and data *;
caslib casdata path="&serverpath" 
   datasource=(srctype="path");

caslib casdata list;

* list files and tables in caslib *;
proc casutil;
  list files incaslib=casdata;
  list tables incaslib=casdata;
quit;

libname casdata cas caslib=casdata;

proc contents data=casdata._all_ nods;
run;;


* 1. Load a "Server Side" file into CAS memory in the CASLIB=casdata"                      *;
* 2. list source files and list in-mamory tables in caslib=casdata - orders_demo is loaded *;
* 3. Load a "Client Side" file (CSV) into CAS memory in the CASLIB=casdata                 *;
* 4. List in-memory tables in the CASLIB=casdata                                           *;
proc casutil;
  load casdata="orders_demo.sas7bdat" 
          incaslib=casdata 
          casout="orders_demo" 
          outcaslib="casdata" 
          replace;
  list files incaslib=casdata;
  list tables incaslib=casdata;
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


* Explore continuous columns - CAS *;
proc mdsummary data=casdata.orders_demo;
    output out=casdata.orders_mdsstats (replace=yes);
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


* Preview the tables prior to the join *;
title "Preview the two tables to join";
proc print data=casdata.orders_demo_calc_columns(obs=10);
run;
proc print data=casdata.discount_lookup;
run;
title;


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


* Find the total by each Country and Year using CAS and produce plot using Compute Server *;
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


********************************************************************************************;
* STEP  - Save in-memory tables, drop in-memory tables, close session                      *;
********************************************************************************************;
* 1. PROC MEANS runs in CAS if the table is a CAS in-memory table                          *;
* 2. So change data= to use casdata.orders_demo                                            *;                                        
* 4. Also you can use CAS PROC MDSUMMARY, which also produces descriptive statistics       *;
* 5. Review the log to see performance metrics                                             *;
********************************************************************************************;

proc casutil;
   list tables incaslib=casdata;
   list files incaslib=casdata;
run;

proc casutil;
  save casdata="orders_demo_calc_columns" incaslib="casdata" outcaslib="casuser" replace;
  save casdata="orders_demo_final" incaslib="casdata" outcaslib="casuser" replace;
  save casdata="orders_summary" incaslib="casdata" outcaslib="casuser" replace;
quit;

proc casutil;
  droptable casdata="orders_demo" incaslib="casdata";
  droptable casdata="discount_lookup" incaslib="casdata";
  droptable casdata="orders_demo_calc_columns" incaslib="casdata";
  droptable casdata="orders_demo_final" incaslib="casdata";
  droptable casdata="orders_summary" incaslib="casdata";
  droptable casdata="ordersbycountryyear" incaslib="casdata";
quit;

proc casutil;
   list tables incaslib=casdata;
   list files incaslib=casdata;
quit;

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