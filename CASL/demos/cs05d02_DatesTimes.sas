**************************************************************;
* Demo 5.02: Working with Dates and Times                    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Create a CAS table with datetime values *;
data casuser.datetime;
    datetime="06MAR1988 12:00:53"dt;
    output;
    datetime="26JAN1995 16:30:00"dt;
    output;
    datetime="18JUN2019 20:10:7"dt;
    output;
    datetime="03NOV2020 8:35:15"dt;
    output;
    format datetime datetime.;
run;

* Preview the datetime table *;
proc cas;
    tbl={name="datetime", caslib="casuser"};
    table.fetch / table=tbl;
    table.columnInfo / table=tbl;
quit;



**********;
* Step 2 *;
**********;
* Create new calculated columns using the DATEPART and TIMEPART functions without a format *;
proc cas;
    outTbl={name="date_functions", caslib="casuser"};

* Create a new table *;
    table.copyTable /
        table={name="datetime", 
               caslib="casuser",
               computedVars={
                           {name="date"},
                           {name="time"}
               }
               computedVarsProgram="
                                  date=datepart(datetime);
                                  time=timepart(datetime);
                                   "
        }
        casOut=outTbl || {replace=TRUE};

* Preview the table *;
    table.fetch / table=outTbl;
    table.columnInfo / table=outTbl;
quit;



**********;
* Step 3 *;
**********;
* Add a format to calculated columns *;
proc cas;
    outTbl={name="date_functions", caslib="casuser"};

* Create a new table *;
    table.copyTable /
        table={name="datetime", 
               caslib="casuser",
               computedVars={
                           {name="date", format="date9."},
                           {name="time", format="time."}
               }
               computedVarsProgram="
                                  date=datepart(datetime);
                                  time=timepart(datetime);
                                   "
        }
        casOut=outTbl || {replace=TRUE};

* Preview the table *;
    table.fetch / table=outTbl;
    table.columnInfo / table=outTbl;
quit;



**********;
* Step 4 *;
**********;
* Use additional date functions in a SOURCE statement *;
proc cas;
    outTbl={name="date_functions", caslib="casuser"};

* Create assignment statements using date functions *;
    source d;
          date=datepart(datetime);
          time=timepart(datetime);
          Year_Value=year(date);
          Month_Value=month(date);
          Day_Value=day(date);
          Qtr_value=qtr(date);
          Today=today();
          Age_Value=intck('year',date, Today, 'c');
          MDY_Function=mdy(Month_Value, Day_Value, Year_Value);
    endsource;

* Create a new table *;
    table.copyTable /
        table={name="datetime", 
               caslib="casuser",
               computedVars={
                           {name="date", format="date9."},
                           {name="time", format="time."},
                           {name="Year_Value"},
                           {name="Month_Value"},
                           {name="Day_Value"},
                           {name="Qtr_Value"},
                           {name="today", format="mmddyy10."},
                           {name="Age_Value"}, 
                           {name="MDY_Function", format="weekdate."}
               }
               computedVarsProgram=d
        }
        casOut=outTbl || {replace=TRUE};

* Preview the table *;
    table.fetch / table=outTbl;
    table.columnInfo / table=outTbl;
quit;



**********;
* Step 5 *;
**********;
* Filter date values *;

* Preview the full table *;
proc cas;
    tbl={name="date_functions", caslib="casuser"};
    table.fetch / table=tbl;
quit;

* Filter using a static date value *;
proc cas;
    tbl={name="date_functions", 
         caslib="casuser",
         where="Date > '01JAN2000'd"};
    table.fetch / table=tbl;
quit;