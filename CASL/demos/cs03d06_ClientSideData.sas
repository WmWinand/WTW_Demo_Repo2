**************************************************************;
* Demo 3.06: Loading Client-Side Data into CAS               *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Using a path *;
proc cas;
    table.upload /
         path="&path/data/my_data/cars.sas7bdat",
         casOut={name="cars_path", 
                 caslib="casuser", 
                 replace=TRUE
         };

    table.tableInfo / caslib="casuser";
quit;



**********;
* Step 2 *;
**********;
* Using a SAS library *;
proc casutil;
    load data=sashelp.heart
         casout="heart_sas_library"
         outcaslib="casuser"
         replace;
quit;

cas conn listhistory 3;

proc cas;
    table.tableInfo / caslib="casuser";
quit;