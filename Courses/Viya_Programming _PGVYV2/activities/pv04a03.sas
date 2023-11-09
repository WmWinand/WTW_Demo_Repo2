*********************************************************;
* Activity 4.03                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc casutil;
    load casdata='sales.sas7bdat' incaslib='casuser'
         outcaslib='casuser' casout='sales' replace; 
quit;