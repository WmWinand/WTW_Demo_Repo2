cas conn;

/* add path based caslib */
proc cas;
  table.caslibInfo;

  table.addCaslib / 
      name="my_data",
      path="/mnt/viya-share/homes/T.Winand@sas.com/Data",
      description="Newly added caslib";
quit;

/* set cas engine libraries to access caslibs from compute server */
libname my_data cas caslib=my_data;
libname casuser cas caslib=casuser;

proc print data=casuser.hmeq_prepped_final (obs=10);
run;

proc means data=casuser.hmeq_prepped_final;
  var loan mortdue;
run;

/* list last 10 cas actions executed */
cas conn listhistory 10;

cas conn terminate;

