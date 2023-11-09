***********************************************;
* Macro to create a table of a specified size *;
***********************************************;
%macro makeData(dsn,numrows,nthreads);
%local size;
%if &numrows <=1000 %then %let size=Tiny; 
  %else %if &numrows <=500000 %then %let size=Small; 
  %else %let size=Large; 

data work.&size&dsn(label="&size data for testing");
    call streaminit(12345);
    do i=1 to &numrows*&nthreads;  
        x=rand('uniform');
        if x<.10 then Product="A";
            else if x<.30 then Product="B";
            else if x<.60 then Product="C";
            else Product="D"; 
        Quantity=abs(round(rand('normal',100,20)));
        output;
    end;
    drop x i;
run;


* Load table into memory *;
proc casutil;
   load data=work.&size&dsn casout="&size&dsn" outcaslib="casuser" replace;
run;quit;

title;
%mend;
***********************************************;
* End macro                                   *;
***********************************************;

%makeData(Table,1000,16);
%makeData(Table,100000,16);
%makeData(Table,6000000,16);

title "Tables in Compute";
proc sql;
    describe table dictionary.tables;
    select libname,
           memname,
           nobs,
           sum(num_character,num_numeric) "Total Columns"
        from dictionary.tables
        where libname="WORK"
        order by nobs ;
quit;


title "Tables in the casuser Caslib";
proc cas;
    table.tableInfo result=r / caslib="casuser";
    print r.tableInfo.where(name="TINYTABLE" or name="LARGETABLE" or name="SMALLTABLE")[,{1,2,3,4}];
quit;

title;
