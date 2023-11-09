***************************************************************;
* Demo: Saving a SASHDAT File in a Caslib - SOLUTION          *;
*   NOTE: If you have not setup the Autoexec file in          *; 
*         SAS Studio, open and submit startup.sas first.      *;
***************************************************************;

proc casutil;
    load data=pvbase.employees casout="employees" replace;
quit;

proc casutil;
    save casdata="employees" incaslib="casuser" outcaslib="casuser"
	     casout="emps_hd" replace;
    list files;
quit;
