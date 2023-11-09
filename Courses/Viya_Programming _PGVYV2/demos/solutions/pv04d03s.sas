*********************************************************;
* Demo: Load a Table into Memory with a CAS Action      *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Step 1 */
proc cas;
    table.loadTable / 
        path="orders_hd.sashdat",
        caslib="casuser",
        casout={caslib="casuser", name="orders"};
quit;

/* Step 2 */
proc cas;
    table.loadTable / 
        path="orders_hd.sashdat",
        caslib="casuser",
        casout={caslib="casuser", name="orders", replace=true};
quit;

/* Step 3 */
proc cas;
    table.loadTable / 
        path="orders_hd.sashdat",
        caslib="casuser",
        casout={caslib="casuser", name="ordersEurope", replace=true},
        vars={"Order_Date", "Order_ID", "Product_ID", "RetailPrice"},
        where="Continent='Europe'";
    table.tableDetails / 
        table="ordersEurope", caslib="casuser";
quit;

