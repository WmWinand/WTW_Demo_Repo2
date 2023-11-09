*******************************************************************;
* Demo: Executing SQL Queries in CAS Using PROC FEDSQL - SOLUTION *;
*   NOTE: If you have not setup the Autoexec file in              *;
*         SAS Studio, open and submit startup.sas first.          *;
*******************************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

 /* Step 1 */
/* Processed in Compute Server */
proc sql;
select distinct Customer_Name, City 
    from pvbase.orders
    where Continent='Africa'
    order by City;
quit;

 /* Steps 2-4 */
/* Processed in CAS */
proc fedsql sessref=mysession;
select distinct Customer_Name, City 
    from casuser.orders
    where Continent='Africa'
    order by City;
quit;

 /* Step 5-6 */
/* Processed in CAS with Log Messages*/
options msglevel=i;
proc fedsql sessref=mysession;
select distinct Customer_Name, City 
    from casuser.orders
    where Continent='Africa'
    order by City;
quit;
options msglevel=n;




