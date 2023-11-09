**************************************************************;
* Demo 6.01: Generating Descriptive Statistics Using Summary *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Default summary action *;
proc cas;
    simple.summary /
        table={name="cars", caslib="casuser"};
quit;



**********;
* Step 2 *;
**********;
* Summarize specific columns *;
proc cas;
    simple.summary /
        table={name="cars", caslib="casuser"},
        inputs={"MSRP", "Cylinders"};
quit;



**********;
* Step 3 *;
**********;
* Specify summary statistics *;
proc cas;
    simple.summary /
        table={name="cars", caslib="casuser"},
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"};
quit;



**********;
* Step 4 *;
**********;
* Create new calculated columns to analyze *;
proc cas;
* Create two new columns *;
    source newCols;
        Total_Diff=MSRP-Invoice;
        MPG_Avg=mean(MPG_City,MPG_Highway);
    endsource;

* Use the simple action to analyze original and calculated columns *;
    simple.summary /
        table={name="cars", 
               caslib="casuser",
               computedVars={
                      {name="Total_Diff", label="Total Difference", format='dollar14.'},
                      {name="MPG_Avg", label="MPG Average"}
               },
               computedVarsProgram=newCols
        },
        inputs={"MSRP", "Invoice", "Total_Diff", "MPG_Avg"},
        subSet={"MIN","MAX","MEAN"};
quit;



**********;
* Step 5 *;
**********;
* Group summary statistics by Origin *;
proc cas;
    simple.summary /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"
        },
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"};
quit;



**********;
* Step 6 *;
**********;
* Save the results of the simple action to a CAS table *;
proc cas;
    simple.summary /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"
        },
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"}
        casOut={name="originAnalysis", caslib="casuser", replace=TRUE};

* Preview *;
    table.fetch / 
        table={name="originAnalysis", caslib="casuser"},
        index=FALSE;
quit;



**********;
* Step 7 *;
**********;
* Save the results of the simple action to a SAS data set *;

*****;
* a *;
*****;
* Save the summary action results as a variable *;
proc cas;
    simple.summary result=r /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"
        },
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"};

* Preview *;
    describe r;
quit;


*****;
* b *;
*****;
* Access a byGroup table*;
proc cas;
    simple.summary result=r /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"
        },
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"};

* Preview one byGroup table*;
    asiaTbl=r["ByGroup1.Summary"];
    print asiaTbl;
quit;


*****;
* c *;
*****;
* Combine all byGroup tables in the results to create a SAS data set *;
proc cas;
    simple.summary result=r /
        table={name="cars", 
               caslib="casuser",
               groupBy="Origin"
        },
        inputs={"MSRP", "Cylinders"},
        subSet={"MIN","MAX","MEAN"};

* Combine all by group tables into a single result table*;
    summaryAnalysis=combine_tables(r);
    print summaryAnalysis;

* Save the result table as a SAS data set *;
    saveresult summaryAnalysis dataout=work.summarycombined;
quit;


*****;
* d *;
*****;
* View the new SAS data set *;
proc print data=work.summarycombined;
run;