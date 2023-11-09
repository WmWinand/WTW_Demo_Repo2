****************************************************************;
* Demo 6.02: Generating Descriptive Statistics Using Aggregate *;
* NOTE: If you have not setup the Autoexec file in             *;
*       SAS Studio, open and submit startup.sas first.         *;
****************************************************************;

**********;
* Step 1 *;
**********;
* Using the inputs parameter *;
proc cas;
    aggregation.aggregate /
        table={name="cars", caslib="casuser"},
        inputs={"MSRP", "Cylinders"};
quit;



**********;
* Step 2 *;
**********;
* Summarize statistics for specific columns *;
proc cas;
    aggregation.aggregate /
        table={name="cars", caslib="casuser"},
        varSpecs={"MSRP", "Cylinders"};
quit;



**********;
* Step 3 *;
**********;
* Specify specific summary statistics using the subSet subparameter *;
proc cas;
    aggregation.aggregate /
        table={name="cars", caslib="casuser"},
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"}}, 
             {name="Cylinders", subSet={"MIN","MAX","MEAN"}}
        };
quit;



**********;
* Step 4 *;
**********;
* Group summary statistics by a specific Origin *;
proc cas;
    aggregation.aggregate /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"},
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"}}, 
             {name="Cylinders", subSet={"MIN","MAX","MEAN"}}
        };
quit;



**********;
* Step 5 *;
**********;
* Save the results of the aggregate action to a CAS table *;
proc cas;
    aggregation.aggregate /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"},
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"}}, 
             {name="Cylinders", subSet={"MIN","MAX","MEAN"}}
        },
        casOut={name="originAnalysis2", caslib="casuser", replace=TRUE};

* Preview *;
    table.fetch / 
        table={name="originAnalysis2", caslib="casuser"},
        index=FALSE;
quit;



**********;
* Step 6 *;
**********;
* Combine all byGroup tables in the results to create a SAS data set *;
proc cas;
    aggregation.aggregate result=agg/
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"},
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"}}, 
             {name="Cylinders", subSet={"MIN","MAX","MEAN"}}
        };

* Preview *;
    print agg;
    describe agg;

* Combine by group tables and create a SAS data set *;
    aggTables=combine_tables(agg);
    saveresult aggTables dataout=work.aggTables_sas;
quit;


* View the SAS data set *;
proc print data=work.aggTables_sas;
run;



**********;
* Step 7 *;
**********;
* Using additional aggregate functionality and create a calculated column *;
proc cas;
    aggregation.aggregate /
        table={name="cars", 
               caslib="casuser",
               computedVarsProgram="MPG_Avg=mean(MPG_City,MPG_Highway);"
        },
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"}}, 
             {name="MSRP", agg="PERCENTILE"},
             {names={"MPG_Avg","Cylinders","EngineSize"}, agg="MEDIAN"}
        };
quit;



**********;
* Step 8 *;
**********;
* - Remove variable specification columns  *;
* - Name the analysis columns              *;
* - Modify the percentiles aggregator      *;
proc cas;
    aggregation.aggregate /
        table={name="cars", 
               caslib="casuser",
               computedVarsProgram="MPG_Avg=mean(MPG_City,MPG_Highway);"
        },
        saveVariableSpecification=FALSE,
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"},
                           colNames={"Min_MSRP","Max_MSRP","Avg_MSRP"}
             }, 
             {name="MSRP", agg="PERCENTILE",
                           percentile={1,10,90},
                           colNames={"Pct_1", "Pct_10", "Pct_90"}
             },
             {names={"MPG_Avg","Cylinders","EngineSize"}, agg="MEDIAN"}
        };
quit;



**********;
* Step 9 *;
**********;
* Saving the additional functionality to a CAS table *;
proc cas;
    aggregation.aggregate /
        table={name="cars", 
               caslib="casuser",
               computedVarsProgram="MPG_Avg=mean(MPG_City,MPG_Highway);"
        },
        saveVariableSpecification=FALSE,
        varSpecs={
             {name="MSRP", subSet={"MIN","MAX","MEAN"},
                           colNames={"Max_MSRP","Min_MSRP","Avg_MSRP"}
             }, 
             {name="MSRP", agg="PERCENTILE",
                           percentile={1,10,90},
                           colNames={"Pct_1", "Pct_10", "Pct_90"}
             },
             {names={"MPG_Avg","Cylinders","EngineSize"}, agg="MEDIAN"}
        },
        casOut={name="aggAction", caslib="casuser", replace=TRUE};

* Preview *;
    table.fetch / 
       table={name="aggAction", caslib="casuser"}, 
       index=FALSE;
quit;