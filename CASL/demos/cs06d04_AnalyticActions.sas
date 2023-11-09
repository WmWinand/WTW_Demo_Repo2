****************************************************************;
* Demo 6.04: Additional Analytic Actions                       *;
* NOTE: If you have not setup the Autoexec file in             *;
*       SAS Studio, open and submit startup.sas first.         *;
****************************************************************;

**********;
* Step 1 *;
**********;
* simple.Correlation action - Calculate Pearson correlations *;

*****;
* a *;
*****;
* Basic correlation action *;
proc cas;
    simple.correlation /
       table={name="cars", caslib="casuser"},
       inputs={"EngineSize", "Weight", "Cylinders", "MPG_City", "MPG_Highway"};
quit;


*****;
* b *;
*****;
* Remove additional information *;
proc cas;
    simple.correlation /
       table={name="cars", caslib="casuser"},
       inputs={"EngineSize", "Weight", "Cylinders", "MPG_City", "MPG_Highway"}, 
       descriptiveStats=FALSE, 
       excludePairStats=TRUE;
quit;


*****;
* c *;
*****;
* Create a CAS table *;
proc cas;
    simple.correlation /
       table={name="cars", caslib="casuser"},
       inputs={"EngineSize", "Weight", "Cylinders", "MPG_City", "MPG_Highway"}, 
       descriptiveStats=FALSE, 
       excludePairStats=TRUE,
       casOut={name="corr", caslib="casuser", replace=TRUE};

* Preview the new table *;
    table.fetch /
        table={name="corr", caslib="casuser"},
        index=FALSE;
quit;



**********;
* Step 2 *;
**********;
* simple.groupBy action - Calculate a summary statistic based on BY group combinations *;
proc cas;
    simple.groupBy /   
       table={name="cars", 
              caslib="casuser",
              computedVarsProgram="MPG_Avg=mean(MPG_City, MPG_Highway);"
       },
       inputs={"Origin" "Type"},    
       weight="MPG_Avg",             
       aggregator="MEAN";
run;



**********;
* Step 3 *;
**********;
* percentile.percentile action - Calculate quantiles and percentiles *;
proc cas;
    percentile.percentile /
        table={name="cars", caslib="casuser"},
        inputs={"Cylinders", "MPG_City"};
quit;



**********;
* Step 4 *;
**********;
* percentile.boxPlot action - Calculate quantiles, high and low whiskers, and outliers *;
proc cas;
    percentile.boxPlot /
       table={name="cars", 
              caslib="casuser",
              computedVarsProgram="MPG_Avg=mean(MPG_City, MPG_Highway);"
       },
        inputs={"MPG_Avg", "Cylinders"};
quit;


    
**********;
* Step 5 *;
**********;
* dataPreprocess.rustats action - Computes a variety of robust univariate statistics *;
proc cas;
    dataPreprocess.rustats / 
       table={name="cars", caslib="casuser"},
       inputs="MPG_City";
quit;



**********;
* Step 6 *;
**********;
* regression.glm action - Fits linear regression models using the method of least squares *;
proc cas;
    regression.glm / 
        table={name="cars", caslib="casuser"}, 
        target="Invoice",
        inputs={"Type", "Origin", "EngineSize", "Cylinders", "HorsePower", "MPG_City"},
        selection={method="BACKWARD"};
quit;