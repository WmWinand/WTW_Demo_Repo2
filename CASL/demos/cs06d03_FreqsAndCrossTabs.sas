****************************************************************;
* Demo 6.03: Creating Frequency and Crosstabulation Reports    *;
* NOTE: If you have not setup the Autoexec file in             *;
*       SAS Studio, open and submit startup.sas first.         *;
****************************************************************;

**********;
* Step 1 *;
**********;
* One-way frequency tables *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Origin"}, 
           {vars="Type"},
           {vars="Cylinders"}
       }; 
quit;



**********;
* Step 2 *;
**********;
* Shortcut for multiple one-way frequency tables *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={"Origin", "Type", "Cylinders"}; 
quit;



**********;
* Step 3 *;
**********;
* Sort frequencies in descending order *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Origin"}, 
           {vars="Type"},
           {vars="Cylinders"}
       },
       order="FREQ";
quit;



**********;
* Step 4 *;
**********;
* Reverse the sort order that is imposed by the order parameter *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Origin"}, 
           {vars="Type"},
           {vars="Cylinders"}
       },
       order="FREQ",
       descending=TRUE;
quit;



**********;
* Step 5 *;
**********;
* Treat missing values as valid levels *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Origin"}, 
           {vars="Type"},
           {vars="Cylinders"}
       },
       order="FREQ",
       includeMissing=TRUE;
quit;



**********;
* Step 6 *;
**********;
* Three columns in the vars sub parameter *;

*****;
* a *;
*****;
* Creates multiple two level frequency tables by each distinct Origin *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars={"Origin","DriveTrain","Type"}}
       };
quit;


*****;
* b *;
*****;
* Creates a single multiway table *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars={"Origin","DriveTrain","Type"}}
       },
       tabDisplay="LIST";
quit;



**********;
* Step 7 *;
**********;
* Create one-way and two-way frequencies *;
proc cas;
    freqtab.freqtab /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Type"},
           {vars="Cylinders"},
           {vars="Origin", cross={"Type", "Cylinders"}}
       },
       includeMissing=TRUE;
quit;



**********;
* Step 8 *;
**********;
* Save displayed result tables as CAS tables *;

*****;
* a *;
*****;
* View result table names *;
proc cas;
    freqtab.freqtab result=ft /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Type"},
           {vars="Cylinders"},
           {vars="Origin", cross={"Type", "Cylinders"}}
       };

* View the table names created from the freqTab action *;
    describe ft;
quit;


*****;
* b *;
*****;
* Save all one-way frequency results into one CAS table *;
proc cas;
    freqtab.freqtab result=ft /
       table={name="cars", caslib="casuser"},
       tabulate={
           {vars="Type"},
           {vars="Cylinders"},
           {vars="Origin", cross={"Type", "Cylinders"}}
       },
       outputTables={
            names={"OneWayFreqs"={name="All_OneWays", caslib="casuser"}}
       };

* Preview the new CAS table *;
    table.tableInfo / caslib="casuser";
    table.fetch / 
       table={name="All_OneWays", caslib="casuser"},
       index=FALSE;
quit;



**********;
* Step 9 *;
**********;
* CrossTab action *;

*****;
* a *;
*****;
* Default crossTab action results *;
proc cas;
    simple.crosstab /
        table={name="cars", caslib="casuser"},
        row="Origin";
quit;


*****;
* b *;
*****;
* Add a column to view Origin by Type *;
proc cas;
    simple.crosstab /
        table={name="cars", caslib="casuser"},
        row="Origin",
        col="Type";
quit;


*****;
* c *;
*****;
* Specify the numeric weight variable used to compute the statistics in the table cell *;
proc cas;
    simple.crosstab /
        table={name="cars", caslib="casuser"},
        row="Origin",
        col="Type",
        weight="MPG_City", 
        aggregator="MEAN";
quit;