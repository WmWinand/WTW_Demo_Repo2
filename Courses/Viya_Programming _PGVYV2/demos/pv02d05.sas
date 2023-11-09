*********************************************************;
* Saving a SASHDAT File in a Caslib                     *;
*   NOTE: If you have not setup the Autoexec file in    *; 
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc casutil;
    load data=pvbase.employees casout="employees" replace;
quit;
