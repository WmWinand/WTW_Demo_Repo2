*********************************************************;
* Activity 3.02                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data casuser.eurorders;
    set casuser.orders end=eof;
    if Continent="Europe" then EurOrders+1;
    if eof=1 then output;
    keep EurOrders;
run;
