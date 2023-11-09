**************************************************************;
* Demo: Validating Data Using CASL                           *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load the cars_raw table into the casuser caslib *;
proc cas;
    tbl={caslib="casuser", name="cars_raw"};
    table.upload / 
        path="&path/data/my_data/" || tbl.name || ".sas7bdat",
        casOut=tbl || {replace=True};
quit;



***************************************************************************;
* Validate cars_raw data to ensure it data conforms to business rules.    *;
* Business Rules for Cars data:                                           *;
*   - DriveTrain should be proper case                                    *;
*   - Origin should be proper case, except USA which is all caps          *;
*   - Type should be proper case, except SUV which is all caps            *;
*   - Check for missing values                                            *;
*   - Check for duplicate rows                                            *;
***************************************************************************;

**********;
* Step 2 *;
**********;
* Explore the table and columns *;
proc cas;
    tbl={caslib="casuser", name="cars_raw"};
    checkCategories={"DriveTrain","Origin","Type"};

* View table details (number of rows and columns) *;
    table.tableInfo  result=ti / 
        name=tbl.name, 
        caslib=tbl.caslib;
    print ti.tableInfo[,{"Name","Rows","Columns"}];

* View the column information *;
    table.columnInfo / table=tbl;

* Preview the table *;
    table.fetch / 
       table=tbl,
       index=false,
       to=5;

* View distinct and missing values *;
    simple.distinct / table=tbl;

* View the unique values and frequency *;
    simple.freq / table=tbl, inputs=checkCategories;
quit;



**********;
* Step 3 *;
**********;
* Check for duplicate IDs (Make, Model and DriveTrain) *;

*****;
* a *;
*****;
* Use the freq action to create a UniqueID column and run a frequency on the unique IDs *;
proc cas;
    simple.freq result=f / 
        table={name="cars_raw",
               caslib="casuser",
               computedVarsProgram="UniqueID=catx('-',upcase(Make), upcase(Model), upcase(DriveTrain))",
               vars={"UniqueID"}
        };

    * Preview the result tables first 10 rows *;
    print f.Frequency[1:10];
quit;


*****;
* b *;
*****;
* Create a CAS table with only IDs with a frequency greater than 1 *;
proc cas;
    simple.freq / 
        table={name="cars_raw",
               caslib="casuser",
               computedVarsProgram="UniqueID=catx('-',upcase(Make), upcase(Model), upcase(DriveTrain))",
               vars={"UniqueID"}
        },
        casout={name="dupIDs",
                caslib="casuser",
                where="_Frequency_ > 1",
                replace=TRUE
        };

    table.fetch / table={name="dupIDs", caslib="casuser"};
quit;



**********;
* Step 4 *;
**********;
* Create a table with all the rows that do not conform to our business rules *;

proc cas;
* Create a source block to create new columns to indicate bad rows in the cars_raw data *;
    source validation;

        * Find all missing rows *;
        charMissing=nmiss(Cylinders,EngineSize);

        * Find category issues in DriveTrain, Origin and Type *;
        if DriveTrain in ("All","Front","Rear") then DriveTrainInvalid=0;
            else DriveTrainInvalid=1;
        if Origin in ("Asia","Europe","USA") then OriginInvalid=0;
            else OriginInvalid=1;
        if Type in ("Hybrid","Sedan","SUV","Sports","Truck","Wagon") then TypeInvalid=0;
            else TypeInvalid=1;

        * Create a BadRow column to indicate if any issues are found in the data *;
        if charMissing > 0 or 
           DriveTrainInvalid=1 or 
           OriginInvalid=1 or 
           TypeInvalid=1 then BadRow=1;
        else BadRow=0;

    endsource;

* Create a new table to keep only bad rows *;
    table.copyTable / 
       table={name="cars_raw", 
              caslib="casuser",
              computedVarsProgram=validation,
              where="BadRow=1"
       }
       casOut={name="BadRows", 
               caslib='casuser', 
               replace=TRUE
       };

    table.tableInfo / caslib="casuser";
    table.fetch / table={name="badRows", caslib="casuser"};
quit;



**********;
* Step 5 *;
**********;
proc cas;
* Check the number of rows in the badRows CAS table. If > 0, print a note that indicates the data must be clean *;
    table.tableInfo result=ti / caslib="casuser", table="badRows";
    totalRows=ti.TableInfo[1,"Rows"];
    if totalRows > 0 then print "The data needs to be cleaned";
quit;