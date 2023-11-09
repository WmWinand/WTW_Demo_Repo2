*********************************************************;
* Demo: BY-Group Processing in CAS                      *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;


proc sort data=pvbase.orders out=orders_s;
    by Continent;
run;

data work.ContTotals;
    set orders_s;
    by Continent;
    if first.Continent then TotalCost=0;
    TotalCost+Cost;
    if last.Continent;
    keep Continent TotalCost;
    format TotalCost dollar15.2; 
run;


/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data casuser.ContTotals;
    set casuser.orders;
    by Continent;
    if first.Continent then TotalCost=0;
    TotalCost+Cost;
    if last.Continent;
    keep Continent TotalCost;
    format TotalCost dollar15.2; 
run;

