**************************************************************;
* Demo 5.04: Preparing the Cars Table                        *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

* Load client side file *;
    table.upload /
        path="&path/data/my_data/cars_raw.sas7bdat",
        casOut={name=cars_raw.name,
                caslib=cars_raw.caslib,
                replace=TRUE};

* MSRP column is character *;
    table.columnInfo / table=cars_raw;

* Case issues in the Type, Origin and DriveTrain columns *;
    simple.freq / 
         table=cars_raw,
         inputs={"Type", "Origin", "DriveTrain"};

* Missing values in the Cylinders and EngineSize columns *;
    simple.distinct / 
         table=cars_raw;

* The Model column contains a leading blank *;
    table.fetch / 
         table=cars_raw || {where="Model like '_%'"},
         to=5,
         index=FALSE;

* Cylinders over 12 *;
    table.fetch /
        table=cars_raw || {where="Cylinders > 12"};
quit;



**********;
* Step 2 *;
**********;
* Remove any duplicate rows *;

* Step 1: Create a variable with an array of all column names *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

    table.columnInfo result=r / table=cars_raw;
    describe r;

    colNames=r.ColumnInfo[,"Column"];
    print colnames;
quit;


* Step 2: Remove duplicates using the variable as the groupBy value *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};
    cars_nodups={name="cars_nodups", caslib="casuser"};
    dups={name="dups", caslib="casuser"};

* Obtain column names in a variable *;
    table.columnInfo result=r / table=cars_raw;
     colNames=r.ColumnInfo[,"Column"];

* Remove duplicate rows *;
    deduplication.deduplicate /
        table=cars_raw || {groupBy=colNames},
        casOut=cars_nodups,
        duplicateOut=dups,
        noDuplicateKeys=TRUE;
quit;



**********;
* Step 3 *;
**********;
* Create a new cleaned table *;
proc cas;
    cars={name="cars_clean", caslib="casuser"};

* Remove rows with missing values and Cylinders greater than 12 *;
    source filter;
        Cylinders is not null and 
        Cylinders <=12 and
        EngineSize is not null;
    endsource;

* Remove leading space in the Model column *;
    source leadingSpace;
        Model_Stripped=strip(Model);
    endsource;

* DriveTrain *;
    source updateDrivetrain;
        DriveTrain_Fixed=propcase(DriveTrain);
    endsource;

* IFC expression for Origin *;
    source updateOrigin;
       Origin_Fixed=ifc(upcase(Origin)='USA', upcase(Origin), propcase(Origin, ' '));
    endsource;

* IF/THEN/ELSE block for Type *;
    source updateType;
       if upcase(Type)="SUV" then Type_Fixed=upcase(Type);
          else Type_Fixed=propcase(Type);
    endsource;

* Convert MSRP to numeric *;
    source msrpConvert;
       MSRP_Num=inputn(MSRP,'dollar10.');
    endsource;

* Create a new MPG_Avg column *;
    source mpgAvg;
       MPG_Avg=mean(MPG_City,MPG_Highway);
    endsource;

* Create a single variable that holds each source block *;
    clean_program=leadingSpace || updateDrivetrain || updateOrigin || updateType || msrpConvert || mpgAvg;


* Create the new cleaned table *;
    table.copyTable /
        table={name="cars_nodups", 
               caslib="casuser",
               computedVarsProgram=clean_program,
               where=filter
        },
        casOut=cars || {replace=TRUE};
quit;



**********;
* Step 4 *;
**********;
* Explore the new table *;
proc cas;
    cars={name="cars_clean", caslib="casuser"};

* Preview the first 20 rows *;
    table.fetch / table=cars, index=FALSE;

* View column information *;
    table.columnInfo / table=cars;

* View distinct values *;
    simple.freq / 
         table=cars,
         inputs={"Type_Fixed", "Origin_Fixed", "DriveTrain_Fixed", "Cylinders"};

* Missing values in the Cylinders and EngineSize columns *;
    simple.distinct / 
         table=cars;
quit;