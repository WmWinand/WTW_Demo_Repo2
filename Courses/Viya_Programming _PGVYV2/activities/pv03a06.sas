*********************************************************;
* Activity 3.06                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data casuser.test;
	set casuser.orders;
    length LastName $ 40;
    LastName=scan(customer_name, 1, ",");
    keep LastName;
run;

proc casutil;
    contents casdata="test" incaslib="casuser";
    droptable casdata="test" incaslib="casuser";
run;
