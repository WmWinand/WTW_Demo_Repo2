****************************************************************;
* Demo 6.06: Exporting Results                                 *;
* NOTE: If you have not setup the Autoexec file in             *;
*       SAS Studio, open and submit startup.sas first.         *;
****************************************************************;

**********;
* Step 1 *;
**********;
* Create a table with 10 million rows if the table doesn't exist *;

*****;
* a *;
*****;
* Check to see if the products CAS table exists in the casuser caslib using the tableExists action *;
proc cas;
    table.tableExists / name="products", caslib="casuser";
quit;


*****;
* b *;
*****;
* Use conditional logic on the result of the tableExists action *;
proc cas;
    table.tableExists result=tbl / name="products", caslib="casuser";
        if tbl.exists=1 then print "Table already exists as a CAS table";
        else print "Table doesn't exist";
quit;


*****;
* c *;
*****;
* Create the products table if the CAS table doesn't exist. If it does exist, print a note in the log *;
proc cas;
* Create DATA step source block to create the 10 million row table *;
    source createTable;
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
    endsource;

* Check to see if the products CAS table exists. If it doesn't, create it *;
    table.tableExists result=tbl / name="products", caslib="casuser";
        if tbl.exists=1 then print "Table already exists as a CAS table";
        else dataStep.runCode / code=createTable, single="YES";
quit;



**********;
* Step 2 *;
**********;
* Create a SAS data set using the summary action *;
proc cas;
* Store the results of the summary action *;
    simple.summary result=s /
        table={name="products", 
               caslib="casuser",
               groupBy="Product"},
        input="Quantity",
        subSet={"SUM"};

* Store the results as a single table *;
    summary=combine_tables(s);

* Save the table as a SAS data set *;
    saveresult summary dataout=work.products_sum;
quit;


* Preview the SAS data set *;
proc print data=work.products_sum noobs;
run;



*****************************;
* Step 3 - Export to Excel  *;
*****************************;
* Begin output to Excel *;
ods excel file="&path/output/products.xlsx"  
          options(sheet_interval="none"
                  sheet_name="product_summary");

* Print the table to Excel *;
proc print data=work.products_sum noobs label;
    var Product Sum;
    format Sum comma16.;
    label sum="Total Quantity";
run;

* Print the visualization to Excel *;
proc sgplot data=work.products_sum;
    vbar Product / 
         response=sum
         categoryorder=respdesc;
    format sum comma16.;
    label sum="Total Quantity";
quit;

* End output to Excel *;
ods excel close;



*********************************;
* Step 4 - Export to PowerPoint *;
*********************************;
* Begin output to PowerPoint *;
ods PowerPoint file="&path/output/products.pptx";

* Print the table to a slide in PowerPoint *;
proc print data=work.products_sum noobs label;
    var Product Sum;
    format Sum comma16.;
    label sum="Total Quantity";
run;

* Print the visualization to a slide in PowerPoint *;
proc sgplot data=work.products_sum;
    vbar Product / 
         response=sum
         categoryorder=respdesc;
    format sum comma16.;
    label sum="Total Quantity";
quit;

* End output to PowerPoint *;
ods PowerPoint close;



*******************************************;
* Step 5 - Export to PDF on a Single Page *;
*******************************************;

* Clear all titles *;
title;

* Close all ODS destinations *;
ods _all_ close;

* Set the escape character to add text *;
ods escapechar='~';


* Begin output to PDF *;
ods pdf file="&path/output/products.pdf";

* Set up the gridded layout: 3 columns and 2 rows and set sizes *;
ods layout gridded columns=3 column_widths=(2in 2.5in 2.5in)
                   rows=2 row_heights=(1in 4in);


*****************;
* Report Title  *;
*****************;
title justify=center '~{style[width=100pct 
                              color=blue 
                              verticalalign=middle
                              fontsize=18pt] 
                        View Product Sales }';


*****************;
* REGION: Row 1 *;
*****************;
ods region row=1 column=1 column_span=3;

ods text='~{style[color=blue verticalalign=middle textalign=left width=10in fontsize=16pt fontweight=bold] 
                  Report Summary}';
ods text='~{style[color=blue verticalalign=middle textalign=left width=10in fontsize=12pt] 
                  This report contains information about the total quantity of sales for each product}';
title;


*****************;
* REGION: Row 2 *;
*****************;
* Column 1 *;
ods region row=2 column=1;

title "Table Information";
proc print data=work.products_sum noobs;
    var Product Sum;
    format Sum comma16.;
    label Sum="Total Quantity";
run;


* Column 2-3 *;
ods region row=2 column=2 column_span=2;

title "Bar Graph";
proc sgplot data=work.products_sum 
            noborder;
    vbar Product / 
         response=sum
         categoryorder=respdesc;
    format sum comma16.;
    label sum="Total Quantity";
quit;

********************************;
* Set Ending Options           *;
********************************;
* Clear any titles *;
title; 

* End the gridded layout *;
ods layout end;

* Close the PDF destination *;
ods pdf close;