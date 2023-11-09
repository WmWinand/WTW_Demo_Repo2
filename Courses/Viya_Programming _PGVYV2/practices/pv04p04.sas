*********************************************************;
* Lesson 4, Practice #4                                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

 /* Compute Server Program */
 /* Part a. */
data profit;
    set pvbase.orders;
    Profit=RetailPrice-(Cost*Quantity);
run;

proc freq data=profit;
    tables Customer_Group;
run;

proc means data=profit noprint;
    var Profit;
    class Customer_Group;
    output out=profitSummary;
run;	

proc print data=profitSummary;
run;

 /* CAS Actions */
 /* Part b. */
proc cas;
    table.loadTable / 
        caslib="casuser"
        path="orders_hd.sashdat"
        casOut={caslib="casuser", name="orders", replace=TRUE};
    datastep.runCode / 
        code="data casuser.ordersProfit;
                  set casuser.orders;
                  Profit=RetailPrice-(Cost*Quantity);
              run;";
quit;