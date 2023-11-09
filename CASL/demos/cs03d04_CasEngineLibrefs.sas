**************************************************************;
* Demo 3.04: Assigning a Libref to a Caslib                  *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Terminate your CAS session *;
cas conn terminate;



**********;
* Step 2 *;
**********;
* Connect to CAS *;
cas conn;

* View your available SAS libraries in the navigation pane *;


**********;
* Step 3 *;
**********;
* View available caslibs *;
proc cas;
    table.caslibInfo;
quit;



**********;
* Step 4 *;
**********;
* Assign a libref to a caslib*;
libname casuser cas caslib=casuser;



**********;
* Step 5 *;
**********;
* Use the CAS table in SAS CAS enabled procedures *;
proc print data=casuser.cars (obs=10);
run;


proc means data=casuser.cars;
    var MPG_City MPG_Highway;
run;

* The number has been modified from the initial demo video *;
cas conn listhistory 8;



**********;
* Step 5 *;
**********;
* Terminate your CAS session *;
cas conn terminate;



**********;
* Step 6 *;
**********;
* Reconnect to CAS by running the autoexec file *;

* View all available caslibs *;
proc cas;
    table.caslibInfo;
quit;