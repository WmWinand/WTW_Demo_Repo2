**************************************************************;
* Demo 3.08: Saving In-Memory Tables as Data Source Files    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load a table into memory *;
proc casutil;
    load data=sashelp.air
         casout="air"
         outcaslib="casuser"
         replace;
quit;

* Explore the casuser caslib *;
proc cas;
    lib="casuser";
    table.tableInfo / caslib=lib;
    table.fileInfo / caslib=lib;
quit;



**********;
* Step 2 *;
**********;
* Save an in-memory table as a SAS data set *;
proc cas;
    table.save /
      table={name="air", caslib="casuser"},
      caslib="casuser", name="air.sas7bdat";

* View data source files *;
    table.fileInfo / caslib="casuser";
    table.tableInfo / caslib="casuser";
quit;



**********;
* Step 3 *;
**********;
* Save an in-memory table as a CSV file *;
proc cas;
    inputTbl={name="air", caslib="casuser"};
    outFile={name="air.csv", caslib="casuser"};

* Save the in-memory table *;
    table.save /
      table={name=inputTbl.name, caslib=inputTbl.caslib},
      caslib=outFile.caslib, name=outFile.name;

* View data source files *;
    table.fileInfo / caslib=outFile.caslib;
quit;



**********;
* Step 4 *;
**********;
* Save an in-memory table as sashdat file *;
proc cas;
    inputTbl={name="air", caslib="casuser"};
    outFile={name="air.sashdat", caslib="casuser"};

* Save the in-memory table *;
    table.save /
      table={name=inputTbl.name, caslib=inputTbl.caslib},
      caslib=outFile.caslib, name=outFile.name;

* View data source files *;
    table.fileInfo / caslib=outFile.caslib;
quit;



**********;
* Step 5 *;
**********;
* Delete the data source files *;
proc cas;
    delFiles={"air.sas7bdat", "air.csv", "air.sashdat"};
    do file over delFiles;
        table.deleteSource /
            source=file, caslib="casuser";
    end;

* View the casuser data source *;
    table.fileInfo / caslib="casuser";
quit;