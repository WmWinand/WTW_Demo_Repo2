*********************************************************;
* Activity 2.09                                         *;
*   NOTE: If you have not setup the Autoexec file in    *; 
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc casutil;
    load data=pvbase.orders casout="orders_loadbase" replace;
quit;

proc casutil;
    load casdata="orders_hd.sashdat" casout="orders_loadhdat" replace;
quit;






