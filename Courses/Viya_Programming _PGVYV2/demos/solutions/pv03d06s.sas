****************************************************************;
* Demo: Create an In-Memory Table Using PROC FEDSQL - SOLUTION *;
*   NOTE: If you have not setup the Autoexec file in           *;
*         SAS Studio, open and submit startup.sas first.       *;
****************************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

 /* Step 1 */
proc sql;
create table work.OceaniaProfit as
select Order_ID, Customer_Name, City, Country, 
       Order_Date "Order Date" format=ddmmyy10.,
       (RetailPrice-(Cost*Quantity)) as Profit "Order Profit" format=dollar8.
    from pvbase.orders
    where calculated Profit>500 
          and Continent = 'Oceania'
    order by calculated Profit desc;
select *
    from work.OceaniaProfit;
quit;

 /* Steps 2-3 */
proc fedsql sessref=mysession;
create table casuser.OceaniaProfit as
select Order_ID, Customer_Name, City, Country, Order_Date,
       (RetailPrice-(Cost*Quantity)) as Profit
    from casuser.orders
    where (RetailPrice-(Cost*Quantity))>500 
          and Continent = 'Oceania';
select *
    from casuser.OceaniaProfit
    order by Profit desc;
quit;

/* Step 4 */
proc fedsql sessref=mysession;
create table casuser.OceaniaProfit{options replace=true} as
select Order_ID, Customer_Name, City, Country, Order_Date,
       (RetailPrice-(Cost*Quantity)) as Profit
    from casuser.orders
    where (RetailPrice-(Cost*Quantity))>500 
          and Continent = 'Oceania';
select *
    from casuser.OceaniaProfit
    order by Profit desc;
quit;

 /* Step 5 */
proc casutil;
    altertable casdata="OceaniaProfit" incaslib="casuser"
        columns={{name="Order_Date" format="ddmmyy10." label="Order Date"}};
    contents casdata="OceaniaProfit" incaslib="casuser";
quit;

 /* Steps 6-7 */
proc casutil;
    altertable casdata="OceaniaProfit" incaslib="casuser"
        columns={{name="Order_Date" format="ddmmyy10." label="Order Date"},
                 {name="Profit" format="dollar8." label="Order Profit"}};
    contents casdata="OceaniaProfit" incaslib="casuser";
quit;