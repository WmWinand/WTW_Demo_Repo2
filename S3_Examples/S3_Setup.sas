cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

caslib _all_ list;

caslib _all_ assign;

caslib ms33 subdirs datasource=(srctype="s3"
               accesskeyid="AKIARPJ6X2NYDF5TYUFX"
               secretaccesskey="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"
               region="US_East"
               bucket="win562960andln"
               objectpath="wtw_files"
               usessl=false);


/* SETTING SAS LIBRARY REFERENCES TO CASLIBS SO THAT WE CAN USE IN DATA STEP, PROCES, ETC */
libname my_sas "/enable01-export/enable01-aks/homes/T.Winand@sas.com/Data";
libname my_cas cas caslib="casuser";
libname my_ms33 cas caslib="ms33";


/* LOAD CUSTOMERS_ALL DATASET INTO MS33 CASLIB */
proc casutil;
	load data=my_sas.customers outcaslib='ms33'
	casout="cascustomers" replace;
quit;


/* LOAD PRODUCTS XLS FILE TO CAS USING PROC CASUTIL */
proc casutil;
    load file='/enable01-export/enable01-aks/homes/T.Winand@sas.com/Data/product_order_detail.xlsx'
    casout='casproductorders'
    outcaslib='ms33'
    importoptions=(filetype='excel' getnames=true)
    replace;
quit; 


/* LIST TOP 10 ROWS OF CASCUSTOMERS TABLE */
proc print data=my_ms33.cascustomers (obs=10);
run;

proc print data=my_ms33.casproductorders (obs=10);
run;


/* LIST IN-MEMORY TABLES AND FILES ASSOCIATED WITH CASLIB */
proc casutil;
  list tables;
  list files incaslib="ms33";
quit; 


/* SAVE CASCUSTOMERS & CASPRODUCTORDERS TO S3 PARQUET FORMAT PERSISTENT STORAGE */
proc casutil;
  save casdata="cascustomers" incaslib="ms33"
      casout="customers.parquet" replace;
  save casdata="casproductorders" incaslib="ms33"
      casout="productorders.parquet" replace;
quit;


/* LIST IN-MEMORY TABLES AND FILES ASSOCIATED WITH CASLIB */
proc casutil;
  list tables;
  list files incaslib="ms33";
quit; 

/* CLOSE CAS SESSION */
cas mysession terminate;
