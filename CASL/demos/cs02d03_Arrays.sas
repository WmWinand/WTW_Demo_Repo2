**************************************************************;
* Demo 2.03: Using an Array with CAS Actions                 *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

***********;
* Step 1  *;
***********;
proc cas;
* Set variables *;
   tbl1="cars";
   tbl2="heart";
   n=5;
* CARS *;
   table.fetch / table=tbl1, to=n;
   table.tableDetails / name=tbl1;
   table.columnInfo / table=tbl1;
* HEART *;
   table.fetch / table=tbl2, to=n;
   table.tableDetails / name=tbl2;
   table.columnInfo / table=tbl2;
quit;



***********;
* Step 2  *;
***********;
* Test the loop of an array with the PRINT statement *;
proc cas;
* Set variables *;
   tables={"cars", "heart"};
   n=5;
* Results for each table *;
   do i over tables;
      print i;
   end;
quit;



***********;
* Step 3  *;
***********;
* Test loop of an array with one action *;
proc cas;
* Set variables *;
   tables={"cars", "heart"};
   n=5;
* Results for each table *;
   do i over tables;
      table.fetch / table=i, to=n;
   end;
quit;



***********;
* Step 4  *;
***********;
* Loop over three actions *;
proc cas;
* Set variables *;
   tables={"cars", "heart"};
   n=5;
* Results for each table *;
   do i over tables;
      table.fetch / table=i, to=n;
      table.tableDetails / name=i;
      table.columnInfo / table=i;
   end;
quit;