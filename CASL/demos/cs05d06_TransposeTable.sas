**************************************************************;
* Demo 5.06: Transposing a Table                             *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Create the profits table *;
data casuser.profits;
    call streaminit(999);
    do Country="US","CA","GR","PT";
        do Region="A","B","C";
        Year2018=round(rand('uniform',100000,2000000),.01);
        Year2019=round(rand('uniform',100000,2000000),.01);
        Year2020=round(rand('uniform',100000,2000000),.01);
        output;
        end;
    end;
    format Year: dollar14.2;
run; 

proc cas;
    table.fetch / 
       table={name="profits", caslib="casuser"},
       index=FALSE;
quit;


**********;
* Step 2 *;
**********;
* Transpose profits (no groupBy)*;
proc cas;
    inTbl={name="profits", caslib="casuser"};   
    outTbl={name="profits_restructured", caslib="casuser"};

* Transpose *;
    transpose.transpose /
        table=inTbl,
        casOut=outTbl || {replace=TRUE},
        id={"Country","Region"}
        transpose={"Year2018", "Year2019","Year2020"}
    ;

* Preview output table *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
    table.columnInfo / table=outTbl;
quit;


**********;
* Step 3 *;
**********;
* Transpose profits (add a groupBy)*;
proc cas;
    inTbl={name="profits", 
           caslib="casuser",
           groupBy="Country"};   
    outTbl={name="profits_restructured", caslib="casuser"};

* Transpose *;
    transpose.transpose /
        table=inTbl,
        casOut=outTbl || {replace=TRUE},
        id={"Region"},
        transpose={"Year2018", "Year2019","Year2020"}
    ;

* preview *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
    table.columnInfo / table=outTbl;
quit;



**********;
* Step 4 *;
**********;
* Transpose profits and rename the new column *;
proc cas;
    inTbl={name="profits", 
           caslib="casuser",
           groupBy="Country"};   
    outTbl={name="profits_restructured", caslib="casuser"};

* Transpose *;
    transpose.transpose /
        table=inTbl,
        casOut=outTbl || {replace=TRUE},
        transpose={"Year2018", "Year2019","Year2020"}
        id="Region",
        name="Year"
    ;

* preview *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
    table.columnInfo / table=outTbl;
quit;



**********;
* Step 5 *;
**********;
* Create a new table *;
data casuser.profits;
    call streaminit(999);
    do Country="US","CA","GR","PT";
        Year2018=round(rand('uniform',100000,2000000),.01);
        Year2019=round(rand('uniform',100000,2000000),.01);
        Year2020=round(rand('uniform',100000,2000000),.01);
        output;
    end;
    format Year: dollar14.2;
run; 

proc cas;
    table.fetch / 
       table={name="profits", caslib="casuser"},
       index=FALSE;
quit;



**********;
* Step 6 *;
**********;
* Use Country as an ID column *;
proc cas;
    tbl={name="profits", 
         caslib="casuser",
         groupBy="Country"};   
    outTbl={name="profits_restructured", caslib="casuser"};

* Transpose *;
    transpose.transpose /
        table=tbl,
        casOut=outTbl || {replace=TRUE},
        transpose={"Year2018", "Year2019","Year2020"}
        id="Country",
        name="Year"
    ;

* preview *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
quit;



**********;
* Step 7 *;
**********;
* Create an ID column when one doesn't exist *;
proc cas;
    tbl={name="profits", 
         caslib="casuser",
         groupBy="Country",
         computedVarsProgram="ID='Profit'"};   
    outTbl={name="profits_restructured", caslib="casuser"};

* Transpose *;
    transpose.transpose /
        table=tbl,
        casOut=outTbl || {replace=TRUE},
        transpose={"Year2018", "Year2019","Year2020"}
        id="ID",
        name="Year"
    ;

* Preview *;
    table.fetch / 
       table=outTbl,
       index=FALSE;
quit;