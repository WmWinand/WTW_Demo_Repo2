*********************************************************;
* Lesson 3, Practice #5 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

/* Part a. */
proc sql;
create table work.customerTot as
select City, 
       count(City) as TotalCustomers "Total Customers", 
       today() format=worddate. as CurrentDate "Current Date"
    from pvbase.orders
    group by City
    having TotalCustomers>2000
    order by TotalCustomers descending;
select * 
    from work.customerTot;
quit;

/* Part b. */
proc fedsql sessref=Mysession;
create table casuser.customerTot{options replace=true} as
select city, 
       count(city) as TotalCustomers, 
       today() as CurrentDate
    from casuser.orders
    group by city
    having count(city)>2000;
quit;

/* Part c.-d. */
proc casutil;
    altertable casdata="customerTot" incaslib="casuser"
        columns={{name="TotalCustomers" format="comma8."         
                  label="Total Customers"},
                 {name="CurrentDate" format="nldate." 
                  label="Current Date"}};
    contents casdata="customerTot" incaslib="casuser";
quit;


