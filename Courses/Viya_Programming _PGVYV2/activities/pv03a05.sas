*********************************************************;
* Activity 3.05                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

options msglevel=i;
proc sql;
select distinct Customer_Name, City 
    from pvbase.orders
    where  Continent eq 'Africa' 
           and city ne ' ' 
           and cost ge 500
    order by City;
quit;
options msglevel=n;