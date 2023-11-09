*********************************************************;
* Demo: Multiple Threads in a DATA Step                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

 /* Single-threaded processing in Compute Server */
data work.eurorders;
    set pvbase.orders end=eof;
    if Continent="Europe" then EurOrders+1;
    if eof=1 then output;
    keep EurOrders;
run;


/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

 /* Multi-threaded processing in CAS */
data casuser.eurorders;
    set casuser.orders end=eof;
    if Continent="Europe" then EurOrders+1;
    if eof=1 then output;
    keep EurOrders;
run;

