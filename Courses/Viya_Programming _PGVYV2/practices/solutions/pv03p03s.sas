*********************************************************;
* Lesson 3, Practice #3 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

 /* Part a. */
 /* DATA step processed in Compute Server */
proc sort data=pvbase.orders out=orders;
    by Continent City;
run;

data work.CityTotals(where=(city ne ' '));
    set orders;
    by Continent City;
    if first.City then do;
        TotalCost=0;
        TotalOrders=0;
    end;
    TotalCost+Cost;
    TotalOrders+1;
    if last.City then output;
    keep Continent City TotalCost TotalOrders;
run;

 /* Parts b.-c. */
 /* DATA step processed in CAS */
data casuser.CityTotals;
    set casuser.orders(where=(city ne ' ')) end=last;
    by Continent City;
    if first.City then do;
        TotalCost=0;
        TotalOrders=0;
    end;
    TotalCost+Cost;
    TotalOrders+1;
    if last.City;
    keep Continent City TotalCost TotalOrders;
    if last then put _threadid_=_nthreads_=;
run;

 /* Parts d.-e. */
options msglevel=i;
title "work.cityTotals";
proc print data=work.CityTotals;
    where city='Abbeville' and continent='North America';
run;

title "casuser.cityTotals";
proc print data=casuser.CityTotals;
    where city='Abbeville' and continent='North America';
run;
options msglevel=n;

