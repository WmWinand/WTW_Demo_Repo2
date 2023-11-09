******************************************************;
* Alternate Methods to Load Data to In-Memory Tables *;
******************************************************;

/* DATA Step */
data casuser.sales_import;
    infile "&path/data/copy-to-casuser/sales.csv" dsd firstobs=2;
    input Employee_ID  FirstName:  $12. 
          LastName : $15. Salary 
          JobTitle : $20. Country : $2. 
          BirthDate : date9. HireDate : mmddyy10.;
    YearsEmployed=yrdif(HireDate,today());
    format BirthDate HireDate mmddyy10.;
run;

/* PROC IMPORT */
proc import datafile="&path/data/sales.xlsx" 
            dbms=xlsx    
            out=casuser.sales_AU replace;
            sheet=Australia;
run;

