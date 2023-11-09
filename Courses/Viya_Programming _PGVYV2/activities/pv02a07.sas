*********************************************************;
* Activity 2.07                                         *;
*   NOTE: If you have not setup the Autoexec file in    *; 
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc casutil;
    load data=pvbase.employees casout="employees";
    load data=pvbase.products casout="products";
run;


