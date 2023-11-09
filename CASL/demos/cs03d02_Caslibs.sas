**************************************************************;
* Demo 3.02: Adding and Exploring Caslibs                    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* View all available caslibs *;
proc cas;
    table.caslibInfo;
quit;



**********;
* Step 2 *;
**********;
* Explore the casuser caslib *;
proc cas;
    lib="casuser";
    table.fileInfo / caslib=lib;
    table.tableInfo / caslib=lib;
quit;



**********;
* Step 3 *;
**********;
* Manually add a caslib *;
proc cas;
* View all caslibs *;
    table.caslibInfo;

* Add a new caslib *;
    table.addCaslib / 
         name="my_data",
         path="&path1/data/my_data",
         description="Newly added caslib";

* View all caslibs *;
    table.caslibInfo;
quit;



**********;
* Step 4 *;
**********;
* Explore the new caslib *;
proc cas;
    lib="my_data";
    table.fileInfo / caslib=lib;
    table.tableInfo / caslib=lib;
quit;