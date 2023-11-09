**************************************************************;
* Demo 3.03: Exploring a Caslib's Attributes                 *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Terminate your CAS session *;
cas conn terminate;

* Connect to CAS *;
cas conn;

* View available caslibs *;
proc cas;
    table.caslibInfo;
quit;

* Terminate your CAS session *;
cas conn terminate;

**********;
* Step 2 *;
**********;
* Reconnect to CAS: Press F9 to run the autoexec file *;



**********;
* Step 3 *;
**********;
* View all available caslibs *;
proc cas;
    table.caslibInfo;
quit;