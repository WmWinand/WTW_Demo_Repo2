**************************************************************;
* Demo: Characterizing Data                                  *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load the orders table in the CS caslib *;
proc cas;
    table.loadTable /
       path="orders_raw.sashdat", caslib="cs",
       casout={name="orders", 
               caslib="cs", 
               replace=TRUE
       };
quit;



**********;
* Step 2 *;
**********;
* Identify potential categorical columns (distinct count <= 10% of total rows) *;

*****;
* a *;
*****;
* Use the distinct and numRows actions to determine the columns *;
proc cas;
    ordersTbl = {name="orders", caslib="cs"};

* Total number of rows *;
    simple.numRows result=nr/ 
       table=ordersTbl;

* Distinct values in each column *;
    simple.distinct result=rd/ 
       table=ordersTbl; 

* Print the result table from the results of the distinct action *;
   print rd.Distinct;

* Print only the rows where the number of distinct values is less than 10% of total rows *;
   print rd.Distinct.where(NDistinct <=nr.numrows*.1);
quit;


*****;
* b *;
*****;
* Remove unnecessary columns from the table ;
proc cas;
    ordersTbl = {name="orders", caslib="cs"};
    removeCols={"xyContinentLon","xyContinentLat","Order_Date","Delivery_Date","Discount","Quantity"};

* Store all column names and remove unnecessary columns *;
    table.columnInfo result=ci / 
       table=ordersTbl;
       colNames=ci.columnInfo[,"Column"] - removeCols;

* Total number of rows *;
    simple.numRows result=nr / 
       table=ordersTbl;

* Distinct values in the specified columns *;
    simple.distinct result=rd/ 
       table=ordersTbl,
       inputs=colNames;
 
    print rd.Distinct.where(NDistinct <=nr.numrows*.1);
quit;


*****;
* c *;
*****;
* Save the column names and distinct counts of assumed categorical columns as a CSV file *;
proc cas;
    ordersTbl = {name="orders", caslib="cs"};
    removeCols={"xyContinentLon","xyContinentLat","Order_Date","Delivery_Date","Discount","Quantity"};

* Store all column names and remove unnecessary columns *;
    table.columnInfo result=ci / 
       table=ordersTbl;
       colNames=ci.columnInfo[,"Column"]-removeCols;

* Total number of rows *;
    simple.numRows result=nr / 
       table=ordersTbl;

* Distinct values in the specified columns *;
    simple.distinct result=rd/ 
       table=ordersTbl,
       inputs=colNames;

* Create a new column in the result table and save the result table to a variable *;
    catColumns=rd.Distinct.where(NDistinct <=nr.numrows*.1)
                          .compute("ColumnType","Estimated Categorical Column");

* Save the result table as a CSV file *;
    saveresult catColumns csv="&path/output/ordersCategoricalCols.csv" replace;
quit;