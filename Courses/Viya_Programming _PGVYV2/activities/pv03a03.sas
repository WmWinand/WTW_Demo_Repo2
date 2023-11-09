*********************************************************;
* Activity 3.03                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data casuser.ContTotals;
    set casuser.orders end=eof;
    by Continent;
    if first.Continent then TotalCost=0;
    TotalCost+Cost;
    if last.Continent then output;
    keep Continent TotalCost; 
    format TotalCost dollar15.2;
    if eof then put _nthreads_= _threadid_= _n_= ;
run;
