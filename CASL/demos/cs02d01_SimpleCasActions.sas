**************************************************************;
* Demo 2.01: Executing CAS Actions                           *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

***********;
* Step 1  *;
***********;
* View the first 20 rows of the CARS table in active caslib(casuser) *;
proc cas;
   table.fetch / table="cars";
quit;



***********;
* Step 2  *;
***********;
* View the first 5 rows of the CARS table *;
proc cas;
   table.fetch / table="cars", to=5;
quit;



***********;
* Step 3  *;
***********;
* View the first 5 rows and summary statistics of the CARS table *;
proc cas;
   table.fetch / table="cars", to=5;
   simple.summary / table="cars";
quit;



***********;
* Step 4  *;
***********;
* View the first 5 rows, summary statistics, and number of rows of the CARS table *;
proc cas;
   table.fetch / table="cars", to=5;
   simple.summary / table="cars";
   simple.numrows / table="cars";
quit;