**************************************************************;
* Demo 5.03: Converting Column Data Types                    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load and preview the cars_raw.sas7bdat table *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

* Load client side file *;
    table.upload /
        path="&path/data/my_data/cars_raw.sas7bdat",
        casOut={name=cars_raw.name,
                caslib=cars_raw.caslib,
                replace=TRUE};

* Preview in-memory table *;
    table.columnInfo / table=cars_raw;
    table.fetch / 
        table=cars_raw, 
        sortBy={
             {name="Invoice", order="descending"}
        };
quit;



**********;
* Step 2 *;
**********;
* Specified an informat without quotes (error) *;
proc cas;
    cars_clean={name="cars_clean", caslib="casuser"};
   
* Convert the MSRP column to numeric *;
    table.copyTable /
        table={name="cars_raw",
               caslib="casuser",
               computedVars={
                         {name="MSRP_num", label="MSRP Numeric"}
               }
               computedVarsProgram="MSRP_num=inputn(MSRP,dollar7.);"
        }
        casout=cars_clean || {replace=TRUE};

* Preview the new table *;
    table.columnInfo / table=cars_clean;
    table.fetch / 
        table=cars_clean, 
        sortBy={
             {name="Invoice", order="descending"}
        };
quit;



**********;
* Step 3 *;
**********;
* Informat with a shorter width *;
proc cas;
    cars_clean={name="cars_clean", caslib="casuser"};

* Convert the MSRP column to numeric *;
    table.copyTable /
        table={name="cars_raw",
               caslib="casuser",
               computedVars={
                         {name="MSRP_num", label="MSRP Numeric"}
               }
               computedVarsProgram="MSRP_num=inputn(MSRP,'dollar7.');"
        }
        casout=cars_clean || {replace=TRUE};

* Preview the new table *;
    table.columnInfo / table=cars_clean;
    table.fetch / 
        table=cars_clean, 
        sortBy={
             {name="Invoice", order="descending"}
        };
quit;


**********;
* Step 4 *;
**********;
* Convert the MSRP column to numeric correctly *;
proc cas;
    cars_clean={name="cars_clean", caslib="casuser"};

* Convert the MSRP column to numeric *;
    table.copyTable /
        table={name="cars_raw",
               caslib="casuser",
               computedVars={
                         {name="MSRP_num", label="MSRP Numeric"}
               }
               computedVarsProgram="MSRP_num=inputn(MSRP,'dollar10.');"
        }
        casout=cars_clean || {replace=TRUE};

* Preview the new table *;
    table.columnInfo / table=cars_clean;
    table.fetch / 
        table=cars_clean, 
        sortBy={
             {name="Invoice", order="descending"}
        };
quit;



**********;
* Step 5 *;
**********;
* Apply a format to the new numeric column *;
proc cas;
    cars_clean={name="cars_clean", caslib="casuser"};

* Convert the MSRP column to numeric *;
    table.copyTable /
        table={name="cars_raw",
               caslib="casuser",
               computedVars={
                         {name="MSRP_num", label="MSRP Numeric", format="dollar10."}
               }
               computedVarsProgram="MSRP_num=inputn(MSRP,'dollar10.')"
        }
        casout=cars_clean || {replace=TRUE};

* Preview the new table *;
    table.columnInfo / table=cars_clean;
    table.fetch / 
        table=cars_clean, 
        sortBy={
             {name="Invoice", order="descending"}
        };
quit;