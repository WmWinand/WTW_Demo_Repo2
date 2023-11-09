*********************************************************;
* Demo: Summarizing in CAS with the Sum Statement       *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

 /* DATA step in Compute Server */
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

 /* Two DATA steps in CAS */
 /* DATA step 1 */
data casuser.eurorders_thread;
    set casuser.orders end=eof;
    if Continent="Europe" then EurOrders_thread+1;
    if eof=1 then output;
    keep EurOrders_thread;
run;

 /* DATA Step 2 */
data casuser.eurorders / single=yes;
    set casuser.eurorders_thread end=eof;
    EurOrders+EurOrders_thread;
    keep EurOrders;
    if eof then output;
run;
