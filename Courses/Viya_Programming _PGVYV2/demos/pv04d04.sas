*********************************************************;
* Demo: Summarizing Data and Benchmarking with CASL     *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Compute Server on Base SAS Table */

title "Compute Server PROCS";

libname pvbase "&path/data";

proc contents data=pvbase.bigOrders;
run;
title;

proc freq data=pvbase.bigOrders;
    tables Country OrderType;
run;

proc means data=pvbase.bigOrders;
    var RetailPrice;
    output out=bigOrders_sum;
run;


/* CAS Server with CAS-enabled PROCS */

title "CAS-Enabled PROCS";

caslib pvcas path="&path/data" libref=pvcas;

proc casutil;
   load casdata="bigOrders.sashdat" incaslib="pvcas"
        outcaslib="pvcas" casout="bigOrders" replace; 
   contents casdata="bigOrders" incaslib="pvcas";
quit;
title;

proc freqtab data=pvcas.bigOrders;
    table Country OrderType;
run;

proc mdsummary data=pvcas.bigOrders;
    var RetailPrice;
    output out=pvcas.bigOrders_sum;
run;


/* CAS Server with CASL */

title "CASL Results";
proc cas;
    table.addCaslib / 
        caslib="pvcas" path="&path/data";
    table.loadTable / 
        path="bigOrders.sashdat", caslib="pvcas", 
        casOut={name="bigOrders", caslib="pvcas", replace=true};
    table.columnInfo / 
        table={name="bigOrders", caslib="pvcas"};
    simple.freq / 
        table={name="bigOrders", caslib="pvcas"}, 
        inputs={"Country", "OrderType"};
    simple.summary / 
        table={name="bigOrders", caslib="pvcas"}, 
        input={"RetailPrice"}, 
        casOut={name='bigOrders_sum', replace=true};
quit;
title;

















