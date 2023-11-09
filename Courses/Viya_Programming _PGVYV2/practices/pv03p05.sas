*********************************************************;
* Lesson 3, Practice #5                                 *;
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
create table work.customerTot as
select City, 
       count(City) as TotalCustomers, 
       today() format=worddate. as CurrentDate
    from pvbase.orders
    group by City
    having TotalCustomers>2000
    order by TotalCustomers descending;
quit;

