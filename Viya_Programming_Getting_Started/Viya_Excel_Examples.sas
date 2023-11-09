
/* */
%let sasdir = /home/sasdemo/SAS Studio/DATA/;

PROC IMPORT OUT=WORK.cars
        FILE="&sasdir.cars1.xlsx"
        DBMS=XLSX REPLACE;
    GETNAMES=YES;
RUN;

 
PROC EXPORT DATA=sashelp.cars
        FILE="&sasdir.cars1.xlsx"
        DBMS=XLSX REPLACE;
    SHEET=’Sheet1’;
RUN;


/* START A CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false);

/* PATH */
caslib wtwcas path="/home/sasdemo/SAS Studio/DATA2" 
   datasource=(srctype="path");

/* SET UP LIBRARY REFERENCES */
libname mysas "&sasdir";
libname mycas cas caslib=casuser;
libname mycas2 cas caslib=wtwcas;

proc import FILE="&sasdir.cars1.xlsx"
    out=mycas.cascars
    dbms=xlsx
    replace;
    getnames=yes;
run;

proc contents data=mycas.cascars;
run;

data mycas.air;
   set sashelp.air;
run;

proc export data=mycas.air 
   dbms=xlsx 
   outfile="&sasdir.air1.xlsx"
   replace;
run;


/* LOAD XLS FILE TO CAS USING PROC CASUTIL */
proc casutil;
    load file='/home/sasdemo/SAS Studio/DATA/insightToyDemo.xlsx'
    casout='casInsightToy'
    outcaslib='wtwcas'
    importoptions=(filetype='excel' getnames=true)
    replace;
quit; 

proc casutil;
  save casdata="casInsightToy" incaslib="wtwcas"
      casout="insightToy.xlsx" replace;
quit;

cas mySession terminate;



ods excel file="/home/sasdemo/SAS Studio/DATA/multitablefinal.xlsx" 
   options(sheet_interval="bygroup"
           suppress_bylines="yes"
           sheet_label="country"
           embedded_titles="yes"
           embed_titles_once="yes" );

title "Historical Sales Data";

proc tabulate data=sashelp.prdsale;
   by country;
   var predict actual;
   class region division prodtype year;
   table year=[label=' '],
      region*(division*prodtype all=[label='division total'])
      all=[label='grand total'],
      predict=[label='total predicted sales']*f=dollar10.*sum=[label='']
      actual=[label='total actual sales']*f=dollar10.*sum=[label=''] /
      box=_page_;
run;

ods excel close;


ods html close;
data prdsale;
   set sashelp.prdsale;
   Difference = actual-predict;
run;

proc sort data=prdsale;
   by country region division year;
run;
ods excel file='/home/sasdemo/SAS Studio/DATA/tagattr.xlsx';

proc print data=prdsale(obs=15) noobs label split='*';
   id country region division;

var prodtype product quarter month year;
var predict actual / 
    style(data)={tagattr='format:$#,##0_);[Red]\($#,##0\)'};

var difference /
    style(data)={tagattr='format:$#,##0_);[Red]\($#,##0\) formula:RC[-1]-RC[-2]'};

sum predict actual difference /
    style(data)={tagattr='format:$#,##0_);[Red]\($#,##0\)'};

label prodtype = 'Product*Type'
      predict  = 'Predicted*Sales*For Area'
      actual   = 'Actual*Sales*Amount';
run;

ods excel close;
ods html;
 
