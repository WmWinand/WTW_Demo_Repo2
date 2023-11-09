**************************************************************;
* Demo 4.01: Creating an Array from a Result Table Column    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
*Explore the CAS table *;
proc cas;
    tbl={caslib="casuser", name="cars"};

* View column information *;
    table.columninfo / table=tbl;

* Preview the table *;
    table.fetch / table=tbl;
quit;



**********;
* Step 2 *;
**********;
* Store the column names of a table in an array *;

*****;
* a *;
*****;
* Default results from the columnInfo action *;
proc cas;
    tbl={caslib="casuser", name="cars"};
    table.columninfo / table=tbl;
quit;  

 
*****;
* b *;
*****;
* Store and view the results from columnInfo action. Notice no output is shown. *;
proc cas;
    tbl={caslib="casuser", name="cars"};
    table.columninfo result=ci / table=tbl;
quit;


*****;
* c *;
*****;
* View the data type of the ci variable *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    describe ci;
quit;


*****;
* d *;
*****;
* PRINT the ci varaible *;
* When PRINTING the dictionary, all values will be output to a specific location.
* 1. Tables will be shown in the results tab. 
* 2. All other values will be show in the log.

* This example dictionary has a single table and will be shown in the results tab *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    describe ci;
    print ci;
quit;


*****;
* e *;
*****;
* Use the columnInfo key to print the result table *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    describe ci.ColumnInfo;
    print ci.ColumnInfo;
quit;


*****;
* f *;
*****;
* Describe and view the newly created variable *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    colInfoTbl=ci.ColumnInfo;
    
    describe colInfoTbl;
    print colInfoTbl;
quit;


*****;
* g *;
*****;
* Storing the Column names in a variable *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    colInfoTbl=ci.ColumnInfo;

* Select the column as an array *;
    print "------------useArrayMethod-----------------";
    useArrayMethod=colInfoTbl[,{"Column"}];
    describe useArrayMethod;
    print useArrayMethod;

    print "------------useStringMethod-----------------";

* Select a single column name *;
    useStringMethod=colInfoTbl[,"Column"];
    describe useStringMethod;
    print useStringMethod;
quit;


*****;
* h *;
*****;
* Create the final program to store column names from a table as an array *;
proc cas;
    tbl={caslib="casuser", name="cars"};

    table.columninfo result=ci / table=tbl;
    colNames=ci.ColumnInfo[,"Column"];
    print colNames;
quit;



**********;
* Step 3 *;
**********;
* Select the specified columns and print all rows where Make=Toyota *;

*****;
* a *;
*****;
* Select specific columns *;
proc cas;
* Set up variables *;
    tbl={caslib="casuser",
         name="cars",
         where="Make='Toyota'"
    };

    removeCols={"Weight","Length","Wheelbase"};

* Store the column names from a table in an array *;
    table.columninfo result=ci / table=tbl;
    colNames=ci.ColumnInfo[,"Column"];
    print colNames;

* Remove unnecessary columns *;
    colNames=colNames-removeCols;
    print colNames;
quit;


*****;
* b *;
*****;
* Find the number of rows where Make=Toyota *;
proc cas;
* Set up variables *;
    tbl={caslib="casuser",
         name="cars",
         where="Make='Toyota'"
    };

    removeCols={"Weight","Length","Wheelbase"};

* Store the column names from a table in an array *;
    table.columninfo result=ci / table=tbl;
    colNames=ci.ColumnInfo[,"Column"];
    colNames=colNames-removeCols;

* Find the number of rows where Make=Toyota *;
    simple.numRows result=nr / table=tbl;
    print "---Describe and print the nr dictionary---";
    describe nr;
    print nr; * no tables, output goes to log *;

* Store the total number of rows in a variable *;
    print "---Store the total number of rows in a variable---";
    totalRows=nr.numRows;
    print totalRows;
quit;


*****;
* c *;
*****;
* Print all the rows where Make=Toyota and specified columns *;
proc cas;
* Set up variables *;
    tbl={caslib="casuser",
         name="cars",
         where="Make='Toyota'"
    };

    removeCols={"Weight","Length","Wheelbase"};

* Store the column names from a table in an array *;
    table.columninfo result=ci / table=tbl;
    colNames=ci.ColumnInfo[,"Column"];
    colNames=colNames-removeCols;

* Find the number of rows where Make=Toyota *;
    simple.numRows result=nr / table=tbl;
    totalRows=nr.numRows;

* Print the table *;
    table.fetch /
        table=tbl,
        fetchVars=colNames,
        to=totalRows,
        index=FALSE,
        sortBy={
            {name="Type"},
            {name="MSRP",order="DESCENDING"}
        };
quit;