*********************************************************;
* Lesson 3, Practice #4 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

proc fedsql sessref=Mysession;
select Customer_Name, 
       Quantity,
       Customer_BirthDate
    from casuser.orders
    where customer_group like '%Gold%' 
          and Continent = 'Africa' 
          and quantity > 3;
quit;
