proc print data=sashelp.cars;
run;

proc format;
  value pricerange_sas 
      low-25000=”Low”
      25000<-50000=”Mid”
      50000<-75000=”High”
      75000<-high=”Luxury”;
run;

data cars_formatted;
  set sashelp.cars;

  format MSRP pricerange_sas.;

  keep Make Model MSRP MPG_Highway engine_size;
run;

proc print data=cars_formatted;
run;


cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

libname mycas cas caslib=casuser;

proc format casfmtlib="casformats";
  value pricerange_cas 
      low-25000=”Low”
      25000<-50000=”Mid”
      50000<-75000=”High”
      75000<-high=”Luxury”;
run;

data mycas.cars_formatted;
  set sashelp.cars;
 
  format weight comma5.;
  format engineSize 3.1;
  format MSRP pricerange_cas.;

  keep Make Model MSRP MPG_Highway Weight engineSize;
run;

proc print data=mycas.cars_formatted;
run;

proc mdsummary data=mycas.cars_formatted;
  var MPG_Highway;
  groupby MSRP / out=mycas.cars_summary;
run;

proc format library=work.formats casfmtlib= "casformats";
  value enginesize
      low - <2.7 = "Very economical"
      2.7 - <4.1 = "Small"
      4.1 - <5.5 = "Medium"
      5.5 - <6.9 = "Large"
      6.9 - high = "Very large";
  run;
  
cas mySession savefmtlib fmtlibname=casformats table=enginefmt replace;

proc casutil;
  format enginesize enginesize.;
  load data=sashelp.cars casout="cars" replace;
quit;

proc print data=sashelp.cars;
  format enginesize enginesize.;
  run;

proc print data=mycas.cars;
run;

proc casutil;
  list tables;
  list files;
run;  

cas mySession listformats scope=global;

cas mySession listfmtsearch;

cas mySession listfmtranges fmtname=enginesize;