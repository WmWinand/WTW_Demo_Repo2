*********************************************************;
* Lesson 4, Practice #2 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

 /* Part c. */
proc casutil;
    load data=pvbase.qtr_sales outcaslib="casuser" casout="qtr_sales";
run;

proc transpose data=casuser.qtr_sales out=casuser.qtr_sales_rotate;
    var Sales;
    id Qtr;
    by Product_ID;
run;

 /* Part d. */
proc casutil;
    altertable casdata="qtr_sales_rotate" incaslib="casuser" drop={"_name_"};
run;

