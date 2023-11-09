options msglevel=I;

libname mydata '/enable01-export/enable01-aks/homes/T.Winand@sas.com/Data';

PROC IMPORT OUT= mydata.customers1 DATAFILE= "/enable01-export/enable01-aks/homes/T.Winand@sas.com/Data/customers1.xlsx" 
            DBMS=xlsx REPLACE;
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.customers2 DATAFILE= "/enable01-export/enable01-aks/homes/T.Winand@sas.com/Data/customers2.xlsx" 
            DBMS=xlsx REPLACE;
     GETNAMES=YES;
RUN;


proc append base=mydata.customers data=work.customers2 force;
run;

proc contents data=mydata.customers;
run;

proc print data=mydata.customers (obs=50);
run;