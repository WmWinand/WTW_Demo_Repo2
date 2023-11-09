**************************************************************;
* Demo 3.07: Promote Tables to Global Scope                  *;
*   NOTE: If you have not setup the Autoexec file in         *;
*         SAS Studio, open and submit startup.sas first.     *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Promote a table to global scope when loading it into memory *;

*****;
* a *;
*****;
* Load a session scope table into memory *;
proc cas;
    lib="casuser";

* Load a session scope table *;
    table.upload /
          path="&path/data/my_data/cars_raw.sas7bdat",
          casOut={name="cars_not_promoted",
                  caslib=lib,
                  replace=TRUE
          };

* Preview the casuser caslib *;
    table.tableInfo / caslib=lib;
quit;


*****;
* b *;
*****;
* Terminate your CAS session *;
cas conn terminate;

* Reconnect to CAS by running the autoexec programm by pressing F9 *;

* View the casuser caslib *;
proc cas;
    table.tableInfo / caslib="casuser";
quit;


*****;
* c *;
*****;
* Load and promote a table to global scope *;
proc cas;
    lib="casuser";

* Load and promote a table *;
    table.upload /
          path="&path/data/my_data/cars_raw.sas7bdat",
          casOut={name="cars_promoted",
                  caslib=lib,
                  promote=TRUE
          };

* Preview the casuser caslib *;
    table.tableInfo / caslib=lib;
quit;


*****;
* d *;
*****;
* Terminate your CAS session *;
cas conn terminate;

* Reconnect to CAS by running the autoexec programm by pressing F9 *;

* View the casuser caslib *;
proc cas;
    table.tableInfo / caslib="casuser";
quit;



**********;
* Step 2 *;
**********;
* Promote a table that is already in-memory *;

*****;
* a *;
*****;
* Load a session scope table into a session scope caslib *;
proc cas;
    lib="cs";

* Load a client-side file into memory *;
    table.loadTable / 
          path="sales.sas7bdat", caslib=lib,
          casout={name="sales_not_promoted", 
                  caslib=lib,
                  replace=TRUE
          };

* Preview the casuser caslib *;
    table.tableInfo / caslib=lib;
quit;


*****;
* b *;
*****;
* Try to promote a table in a session scope caslib (error) *;
proc cas;
    lib="cs";

* Promote a table to global scope in a session caslib *;
    table.promote /
         name="sales_not_promoted", caslib=lib,
         targetCaslib=lib;

* Preview the casuser caslib *;
    table.tableInfo / caslib=lib;
quit;


*****;
* c *;
*****;
* Promote a table from a session scope caslib to a global caslib *;
proc cas;
    table.promote /
         name="sales_not_promoted", caslib="cs", 
         target="sales_promoted", 
         targetcaslib="casuser";

* Preview the global caslib *;
    table.tableInfo / caslib="casuser";
quit;


*****;
* d *;
*****;
* Terminate your CAS session *;
cas conn terminate;

* Reconnect to CAS by running the autoexec programm by pressing F9 *;

* View the casuser caslib *;
proc cas;
    table.tableInfo / caslib="casuser";
quit;






************;
* Optional *;
************;
* If you didn't delete the tables using the point and click method from the video, *;
* you can delete the promoted tables programmatically with the following code      *;
proc cas;
    tables={"CARS_PROMOTED","SALES_PROMOTED"};
    do i over tables;
        table.dropTable / caslib="casuser", name=i;
    end;
    table.tableInfo / caslib="casuser";
quit;
