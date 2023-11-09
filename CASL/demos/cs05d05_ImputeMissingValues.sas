**************************************************************;
* Demo 5.05: Imputing Missing Values                         *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load the cars_raw table into memory *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    table.upload /
        path="&path/data/my_data/cars_raw.sas7bdat",
        casOut={name=cars_raw.name, 
                caslib=cars_raw.caslib, 
                replace=TRUE
        };
    table.fetch / table=cars_raw;
quit;



**********;
* Step 2 *;
**********;
* View the number of missing rows in each column *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

    simple.distinct / table=cars_raw;

    table.fetch / 
       table=cars_raw || {where="EngineSize is null"};
quit;



**********;
* Step 3 *;
**********;
* Impute the missing values of EngineSize using the default method *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    outTbl={name="cars_impute", caslib="casuser"};

* Impute missing values *;
    dataPreprocess.impute /
        table=cars_raw,
        inputs={"EngineSize"},
        casOut=outTbl || {replace=TRUE};

* Preview the new table *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
    simple.distinct / table=outTbl;
quit;



**********;
* Step 4 *;
**********;
* CopyAllVars to the casOut table *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    outTbl={name="cars_impute", caslib="casuser"};

* Impute missing values *;
    dataPreprocess.impute /
        table=cars_raw,
        inputs={"EngineSize"},
        copyAllvars=TRUE,          /* <-------- */
        casOut=outTbl || {replace=TRUE};

* Preview the new table *;
    table.fetch / table=outTbl;
    simple.distinct / table=outTbl;
quit;



**********;
* Step 5 *;
**********;
* Impute with the Median value *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    outTbl={name="cars_impute", caslib="casuser"};

* Impute missing values *;
    dataPreprocess.impute /
        table=cars_raw,
        inputs={"EngineSize"},
        methodInterval="MEDIAN",   /* <-------- */
        copyAllvars=TRUE,
        casOut=outTbl || {replace=TRUE};

* Preview the new table *;
    table.fetch / table=outTbl;
    simple.distinct / table=outTbl;
quit;



**********;
* Step 6 *;
**********;
* Impute with a user specified value *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    outTbl={name="cars_impute", caslib="casuser"};

* Impute missing values *;
    dataPreprocess.impute /
        table=cars_raw,
        inputs={"EngineSize"},
        methodInterval="VALUE",   /* <-------- */
        valuesInterval=5,         /* <-------- */
        copyAllvars=TRUE,
        casOut=outTbl || {replace=TRUE};

* Preview the new table *;
    table.fetch / table=outTbl;
    simple.distinct / table=outTbl;
quit;