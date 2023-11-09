*********************************************************;
* Activity 4.05                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc cas;
    table.loadTable / 
        path="sales.sas7bdat", caslib="casuser", 
        casout={caslib="casuser", name="sales", replace="true"};
    simple.distinct / 
        table={name="sales", caslib="casuser"};
quit;
