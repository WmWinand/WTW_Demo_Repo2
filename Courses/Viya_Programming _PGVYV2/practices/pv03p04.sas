*********************************************************;
* Lesson 3, Practice #4                                 *;
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
select Customer_Name, 
       Quantity, 
       Customer_BirthDate
    from pvbase.orders
    where customer_group contains 'Gold' 
          and Continent eq 'Africa' 
          and quantity gt 3;
quit;

