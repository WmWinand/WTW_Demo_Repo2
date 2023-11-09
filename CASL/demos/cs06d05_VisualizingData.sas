****************************************************************;
* Demo 6.05: Data Visualization Using CAS Tables               *;
* NOTE: If you have not setup the Autoexec file in             *;
*       SAS Studio, open and submit startup.sas first.         *;
****************************************************************;

**********;
* Step 1 *;
**********;
* Create a table with 10 million rows *;
data casuser.products;
   call streaminit(99);
    do i=1 to 10000000;
        x=rand('normal');
        if x<.10 then Product="A";
            else if x<.30 then Product="B";
            else if x<.60 then Product="C";
            else Product="D"; 
        Quantity=round(rand('uniform',1,100));
        output;
    end;
    drop x i;
run;



**********;
* Step 2 *;
**********;
* Create a vertical bar chart using a 10 million row CAS table *;
* Override the SGPLOT data limit size *;
ods graphics / maxobs=10000000;
proc sgplot data=casuser.products;
    vbar Product / 
           response=Quantity 
           stat=sum categoryorder=respdesc;
    format Quantity comma16.;
run;
ods graphics / reset;



**********;
* Step 3 *;
**********;
* View information about the products CAS table.                       *;
* The Data size column indicates the total size of the table in bytes. *;
proc cas;
    table.tableDetails / name="products", caslib="casuser";
quit;



***************************************************;
* Step 4 - SOLUTION 1 (typically not recommended) *;
***************************************************;
* Override the default transfer limit of tables from CAS to compute *;
ods graphics / maxobs=10000000;
proc sgplot data=casuser.products(datalimit=160000000);
    vbar Product / 
           response=Quantity 
           stat=sum categoryorder=respdesc;
    format Quantity comma16.;
run;
ods graphics / reset;



***********************;
* Step 5 - SOLUTION 2 *;
***********************;
**********************************************************;
* a. Summarize the data in CAS and create a SAS data set *;
* b. Graph the data                                      *;
**********************************************************;

*****;
* a *;
*****;
proc cas;
* Summarize the CAS table with an action, and save the results *;
    simple.summary result=s /
        table={name="products", 
               caslib="casuser",
               groupBy="Product"},
        input="Quantity",
        subSet={"SUM"};

* View the result variable *;
    print s;
    describe s;

* Store the result tables as a single table and print the new table *;
    summary=combine_tables(s);
    print summary;

* Save the table variable as a SAS data set *;
    saveresult summary dataout=work.products_sum;
quit;


* Preview the SAS data set *;
proc print data=work.products_sum;
run;


*****;
* b *;
*****;
proc sgplot data=work.products_sum;
    vbar Product / 
           response=sum
           categoryorder=respdesc;
    format sum comma16.;
    label sum="Total Quantity";
quit;



***********************;
* Step 6 - SOLUTION 3 *;
***********************;
**********************************************************;
* a. Summarize the data in CAS and create a CAS table    *;
* b. Graph the summarized CAS table                      *;
**********************************************************;

*****;
* a *;
*****;
proc cas;
    outTbl={name="products_sum", caslib="casuser"};

* Summarize the CAS table with an action and save the results as a CAS table *;
    simple.summary /
        table={name="products", 
               caslib="casuser",
               groupBy="Product"
        },
        input="Quantity",
        subSet={"SUM"},
        casOut=outTbl || {replace=TRUE};

* Preview the new summarized CAS table *;
    table.tableDetails / 
        name=outTbl.name, 
        caslib=outTbl.caslib;
    table.fetch / table=outTbl, index=FALSE;
quit;


*****;
* b *;
*****;
* Plot a small CAS table *;
proc sgplot data=casuser.products_sum;
    vbar Product / 
           response=_sum_
           categoryorder=respdesc;
    format _sum_ comma16.;
    label _sum_="Total Quantity";
quit;