*****************************************************;
* STEP 0                                            *;
*****************************************************;
* This program is the SAS9 program. It does not     *;
* run successfully because the paths have not been  *;
* updated for SAS Librefs and files to point to the *;
* new Paths in Viya versus SAS9                     *; 
*****************************************************;


************************************************;
* CHANGE THE PATH WHERE THE DATA IS LOCATED    *;
************************************************;
%let serverPath = C:\MyDemos\SAS9_Code_Migration\data;
%let clientPath = C:\MyDemos\SAS9_Code_Migration\data;

* Start timer *;
%let _timer_start = %sysfunc(datetime());  

* Options *;
options fullstimer;

* Create a library reference to the data *;
/*libname o clear;*/
libname o "&serverPath";


* View available SAS data sets *;
proc contents data=o._all_ nods;
run;


* Preview the data *;
proc print data=o.orders_demo(obs=10);
run;


* Explore categorical columns *;
proc freq data=o.orders_demo;
    tables Product Country DiscountCode Return OrderDate;
    format OrderDate year4.;
run;


* Explore continuous columns *;
proc means data=o.orders_demo;
run;


* Execute a simple data step *;
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

* Import discount_lookup.csv *;
filename REFFILE DISK 'C:\MyDemos\SAS9_Code_Migration\data\DISCOUNT_LOOKUP.csv';

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


* Join the orders_demo_calc_columns and the Discount_Lookup tables *;
proc sql;
create table orders_demo_final as
    select f.*, 
           l.pct_discount * .01 as pctDiscount, 
           l.discount_description
        from work.orders_demo_calc_columns as f left join 
             o.discount_lookup as l
        on f.DiscountCode = l.discountCode;
quit;


* Preview the joined data *;
proc print data=orders_demo_final(obs=10);
run;


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

* Turn off options *;
options nofullstimer;


* Clear library *;
libname o clear;


/* Stop timer */
data _null_;
  dur = datetime() - &_timer_start;
  put 30*'-' / ' TOTAL DURATION:' dur time13.2 / 30*'-';
run;