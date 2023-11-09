*********************************************************;
* Demo: Producing Descriptive Statistics in CAS         *;
*       Using PROC MDSUMMARY - SOLUTION                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

/* Step 1 */
/* This step produces an error because the OUTPUT statement is missing. */
proc mdsummary data=casuser.orders;
    var RetailPrice;
run;

/* Step 2 */
proc mdsummary data=casuser.orders;
    var RetailPrice;
    output out=casuser.orders_all;
run;

/* Step 3 */
proc mdsummary data=casuser.orders;
    var RetailPrice;
    groupby Country;
    output out=casuser.orders_country;
run;

/* Steps 4-5 */
proc mdsummary data=casuser.orders;
    var RetailPrice;
    groupby / out=casuser.orders_all;
    groupby Country / out=casuser.orders_country;
run;

proc print data=casuser.orders_country label noobs;
    var Country _NObs_ _Mean_ _Sum_;
    format _mean_ _sum_ dollar12.;
    label _NObs_="Number of Orders"
          _mean_="Average Retail Price per Order"
          _sum_="Total Retail Price";
run;