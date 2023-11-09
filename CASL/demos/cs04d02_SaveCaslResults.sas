**************************************************************;
* Demo 4.02: Saving CASL Results                             *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* View available data *;
proc cas;
    table.caslibInfo;
    table.fileInfo / caslib="cs";
quit;



**********;
* Step 2 *;
**********;
* Load the ORDERS table in the CS caslib *;
proc cas;
   table.loadTable /
      path="orders_clean.sashdat", caslib="cs",
      casout={name="orders", 
              caslib="cs", 
              replace=TRUE
      };
quit;



**********;
* Step 3 *;
**********;
* Explore the table structure and contents *;
proc cas;
   ordersTbl = {name="orders", caslib="cs"};

   table.tableInfo / caslib=ordersTbl.caslib;
   table.columnInfo / table=ordersTbl;
   table.fetch / table=ordersTbl, index=FALSE;
quit;



**********;
* Step 4 *;
**********;
* Save the columnInfo table information as a CSV file to use as a data dictionary *;

*****;
* a *;
*****;
proc cas;
    table.columnInfo result=ci / 
       table={name="orders", caslib="cs"};

* 1. Store the table and specified columns in a variable *;
    ciTbl=ci.columnInfo[,{"Column","Label","Type","RawLength","Format"}];
    describe ciTbl;
    print ciTbl;

* 2. Add the TableName and Caslib columns to the table *;
    ciTbl=ci.columnInfo[,{"Column","Label","Type","RawLength","Format"}]
                .compute("TableName","Orders")
                .compute("Caslib","cs");
    describe ciTbl;
    print ciTbl;      
quit;


*****;
* b *;
*****;
* Save as the table information as a CSV file to use as a data dictionary *;
proc cas;
    table.columnInfo result=ci / 
       table={name="orders", caslib="cs"};

* Add the TableName and Caslib columns to the table *;
    ciTbl=ci.columnInfo[,{"Column","Label","Type","RawLength","Format"}]
                .compute("TableName","Orders")
                .compute("Caslib","cs");

* Save as a CSV file *;
    saveresult ciTbl csv="&path/output/orders_data_dictionary.csv";   
quit;



**********;
* Step 5 *;
**********;
* Retrieve all rows using simple.numRows and save to SAS data set *;

*****;
* a *;
*****;
* Save all rows where Country=Australia to a SAS data set *;
proc cas;
* Set variables *;
    ordersTbl = {name="orders", 
                 caslib="cs",
                 where="Country = 'Australia'"
    };
    vars={"Customer_Name", "Order_ID", "Cost","OrderType"};
    sortCost={
        {name="Cost", order="DESCENDING"}
    };

* Store the total number of rows where Country=Australia *;
    simple.numRows result=nr / 
       table=ordersTbl;

* Retrieve all rows from the table where Country=Australia *;
    table.fetch result=rf/
       table=ordersTbl,
       fetchVars=vars,
       to=nr.numrows,
       sortBy=sortCost;

* Save the fetch results as a SAS data set *;
    saveresult rf.Fetch dataout=work.au_orders;
quit;


*****;
* b *;
*****;
* Use the new SAS data set *;
proc print data=work.au_orders(obs=10) noobs;
run;

proc sgplot data=work.au_orders;
    vbar OrderType;
run;