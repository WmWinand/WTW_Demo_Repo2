**************************************************************;
* Demo 3.05: Loading Server-Side Data Into CAS               *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Explore the cs caslib *;
proc cas;
    lib="cs";
    table.fileInfo / caslib=lib;
    table.tableInfo / caslib=lib;
quit;



**********;
* Step 2 *;
**********;
* Load a server-side SAS data set *;
proc cas;
    lib="cs";

* Load file *;
    table.loadTable /
         path="sales.sas7bdat", caslib=lib,
         casout={caslib=lib, 
                 name="sales",
                 replace=TRUE
         };

* View in-memory tables in the cs caslib *;
    table.tableInfo / caslib=lib;
quit;



**********;
* Step 3 *;
**********;
* Preview the in-memory table *;
proc cas;
    salesTbl={name="sales", caslib="cs"};
    table.fetch / table=salesTbl; 
quit;



**********;
* Step 4 *;
**********;
* Load a server-side Excel file *;
proc cas;
    lib="cs";

* Load file *;
    table.loadTable /
         path="products.xlsx", caslib=lib,
         casout={caslib=lib, 
                 name="products_excel",
                 replace=TRUE
         };

* Preview the in-memory table *;
    table.tableInfo / caslib=lib;
    table.fetch / table={name="products_excel", caslib=lib}; 
quit;



**********;
* Step 5 *;
**********;
* Load a server-side CSV file *;

*****;
* a *;
*****;
* Load a server-side CSV file (incorrect column names) *;
proc cas;
    lib="cs";

* Load file *;
    table.loadTable /
         path="sales.csv", caslib=lib,
         casout={caslib=lib,
                 name="sales_csv", 
                 replace=True
         };

* Preview the in-memory table *;
    table.tableInfo / caslib=lib;
    table.fetch / table={name="sales_csv", caslib=lib};
quit;


*****;
* b *;
*****;
* Load a server-side CSV file with additional import options *;
proc cas;
    lib="cs";

* Load file *;
    table.loadTable /
         path="sales.csv", caslib=lib,
         casout={caslib=lib,
                 name="sales_csv", 
                 replace=True
         },
         importOptions={fileType="CSV", getNames=FALSE};

* Preview the in-memory table *;
    table.tableInfo / caslib=lib;
    table.fetch / table={name="sales_csv", caslib=lib};
quit;


*****;
* c *;
*****;
* Load a server-side CSV file and add the column names *;
proc cas;
    lib="cs";
    colNames={"Employee_ID", "First_Name", "Last_Name", "Salary", 
              "Job_Title", "Country", "Birth_Date", "Hire_Date"};

* Load file *;
    table.loadTable /
         path="sales.csv", caslib=lib,
         casout={caslib=lib,
                 name="sales_csv", 
                 replace=True},
         importOptions={fileType="CSV", getNames=FALSE, vars=colNames};

* Preview the in-memory table *;
    table.tableInfo / caslib=lib;
    table.fetch / table={name="sales_csv", caslib=lib};
quit;