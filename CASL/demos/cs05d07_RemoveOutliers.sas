**************************************************************;
* Demo 5.07: Dynamically Remove Outliers                     *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load and preview the cars_raw.sas7bdat table *;
proc cas;
   cars_raw = {name="cars_raw", caslib="casuser"};

* Load client side file *;
   table.upload /
        path="&path/data/my_data/cars_raw.sas7bdat",
        casOut={name=cars_raw.name,
                caslib=cars_raw.caslib,
                replace=TRUE
        };

* Preview in-memory table *;
   simple.freq / table=cars_raw, inputs="Cylinders";
quit;



**********;
* Step 2 *;
**********;
* Run the boxPlot action to find the high and low whiskers *;
proc cas;
   cars_raw = {name="cars_raw", caslib="casuser"};
   percentile.boxplot /
        table=cars_raw;
quit;



**********;
* Step 3 *;
**********;
* Run the boxPlot action on the Cylinders column *;
proc cas;
   cars_raw = {name="cars_raw", caslib="casuser"};
   percentile.boxplot /
        table=cars_raw,
        input="Cylinders";
quit;



**********;
* Step 4 *;
**********;
* Store the results of the boxPlot action *;
proc cas;
   cars_raw = {name="cars_raw", caslib="casuser"};
   percentile.boxplot result=r /
        table=cars_raw,
        input="Cylinders";
    describe r;
quit;



**********;
* Step 5 *;
**********;
* Print only the WhiskerLo and WhiskerHi values for the Cylinders column *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};
    percentile.boxplot result=r /
        table=cars_raw
        input="Cylinders";
    describe r;

* Subset the result table *;
    print r.BoxPlot[,{"WhiskerLo", "WhiskerHi"}];
quit;



**********;
* Step 6 *;
**********;
* Store the WhiskerLo and WhiskerHi values in two new variables *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};
    percentile.boxplot result=r /
        table=cars_raw
        input="Cylinders";

* Obtain whisker values *;
    whiskersTbl=r.BoxPlot[,{"WhiskerLo", "WhiskerHi"}];
    highWhisker=whiskersTbl[1,"WhiskerHi"];
    lowWhisker=whiskersTbl[1,"WhiskerLo"];

* Confirm variable values *;
    print "The value of highWhisker: " highWhisker;
    print "The value of lowWhisker: " lowWhisker;
quit;



**********;
* Step 7 *;
**********;
* Create a where expression to filter a table *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};
    percentile.boxplot result=r /
        table=cars_raw
        input="Cylinders";

* Obtain whisker values *;
    whiskersTbl=r.BoxPlot[,{"WhiskerLo", "WhiskerHi"}];
    highWhisker=whiskersTbl[1,"WhiskerHi"];
    lowWhisker=whiskersTbl[1,"WhiskerLo"];

* Create the where expression *;
    filterOutliers="Cylinders >=" || lowWhisker || " and " || "Cylinders <=" || HighWhisker;
    print "Confirm the where expression: " filterOutliers;
quit;



**********;
* Step 8 *;
**********;
* Add the where expression to the cars_raw dictionary *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};
    percentile.boxplot result=r /
        table=cars_raw
        input="Cylinders";

* Obtain whisker values *;
    whiskersTbl=r.BoxPlot[,{"WhiskerLo", "WhiskerHi"}];
    highWhisker=whiskersTbl[1,"WhiskerHi"];
    lowWhisker=whiskersTbl[1,"WhiskerLo"];

* Create the where expression *;
    filterOutliers="Cylinders >=" || lowWhisker || " and " || "Cylinders <=" || HighWhisker;

* Add the where expression to the cars_raw dictionary *;
    cars_raw.where=filterOutliers;
    describe cars_raw;
    print cars_raw;
quit;



**********;
* Step 9 *;
**********;
* Removing outliers from the table *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};
    percentile.boxplot result=r /
        table=cars_raw
        input="Cylinders";

* Obtain whisker values *;
    whiskersTbl=r.BoxPlot[,{"WhiskerLo", "WhiskerHi"}];
    highWhisker=whiskersTbl[1,"WhiskerHi"];
    lowWhisker=whiskersTbl[1,"WhiskerLo"];

* Create the where expression *;
    filterOutliers="Cylinders <=" || highWhisker || " and " || "Cylinders >=" || lowWhisker;

* Add the where expression to the cars_raw dictionary *;
    cars_raw.where=filterOutliers;

* Create a new table without outliers *;
    table.copyTable / 
        table=cars_raw,
        casOut={name="cars_no_outliers", caslib="casuser", replace=TRUE};
quit;



**********;
* Step 10 *;
**********;
* View the new table *;
proc cas;
    cars={name="cars_no_outliers", caslib="casuser"};
    table.tableInfo / caslib=cars.caslib;
    simple.freq / 
        table=cars, 
        inputs="Cylinders";
quit;