*********************************************************;
* Demo: Executing SQL Queries in CAS Using PROC FEDSQL  *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

proc sql;
select distinct Customer_Name, City 
    from pvbase.orders
    where Continent='Africa'
    order by City;
quit;

proc fedsql sessref=mySession;
select distinct Customer_Name, City 
    from casuser.orders
    where Continent='Africa'
    order by City;
quit;






